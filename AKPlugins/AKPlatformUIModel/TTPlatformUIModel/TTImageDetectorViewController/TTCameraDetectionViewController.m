//
//  TTCameraDetectionViewController.m
//  Article
//
//  Created by lizhuoli on 16/12/19.
//
//

#import "TTCameraDetectionViewController.h"
#import "TTThemedAlertController.h"
#import "TTUIResponderHelper.h"
#import <CoreMotion/CoreMotion.h>

#ifndef dispatch_main_sync_safe
#define dispatch_main_sync_safe(block)\
    if ([NSThread isMainThread]) {\
        block();\
    } else {\
        dispatch_sync(dispatch_get_main_queue(), block);\
    }
#endif

#ifndef dispatch_main_async_safe
#define dispatch_main_async_safe(block)\
    if ([NSThread isMainThread]) {\
        block();\
    } else {\
        dispatch_async(dispatch_get_main_queue(), block);\
    }
#endif

#define kTTCameraDetectionAccelerometerUpdateInterval 0.2
#define kTTCameraDetectionAccelerometerOffset 0.5

@interface TTCameraDetectionViewController ()

@property (nonatomic) dispatch_queue_t sessionQueue; //AVFoundation Session Queue
@property (nonatomic) dispatch_queue_t outputQueue; //Video Output Queue
@property (nonatomic, strong) NSOperationQueue *accelerometerQueue; //Core Motion Accelerometer Queue

@property (nonatomic, strong) AVCaptureDevice *device;
@property (nonatomic, strong) AVCaptureDeviceInput *deviceInput;
@property (nonatomic, strong) AVCaptureStillImageOutput *deviceOutput;
@property (nonatomic, strong) AVCaptureVideoDataOutput *deviceVideoOutput;
@property (nonatomic, strong) AVCaptureSession *session;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;

@property (nonatomic, strong) CIDetector *detector;
@property (nonatomic, strong) NSDictionary *imageOptions;

@property (nonatomic, strong) CMMotionManager *motionManager; //Core Motion用于检测设备握持方向，因为锁定方向时无法通过UIDevice拿到方向
@property (nonatomic, assign) UIDeviceOrientation currentDeviceOrientation;

@property (nonatomic, assign) TTCameraDetectionType type;
@property (nonatomic, assign) BOOL hasInitialCamera;
@property (nonatomic, assign) NSUInteger currentSampleCount;
@property (nonatomic, assign) NSUInteger maxSampleCount;

@end

@implementation TTCameraDetectionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:animated ? UIStatusBarAnimationSlide : UIStatusBarAnimationNone];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self stopCamera];
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:animated ? UIStatusBarAnimationSlide : UIStatusBarAnimationNone];
    [super viewWillDisappear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    AVAuthorizationStatus authStatus = [self checkVideoAuth];
    if (authStatus == AVAuthorizationStatusNotDetermined) { // 未弹出授权框
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
            if (!granted) { // 授权回调非主线程
                dispatch_main_async_safe(^{
                    [self showAlertWithTitle:@"无访问权限" msg:@"请在手机的「设置-隐私-相机」选项中，允许幸福里访问你的相机" callback:^{
                        [self dismissSelf];
                    }];
                });
            }
        }];
    } else if (authStatus == AVAuthorizationStatusDenied) {
        [self showAlertWithTitle:@"无访问权限" msg:@"请在手机的「设置-隐私-相机」选项中，允许幸福里访问你的相机" callback:^{
            [self dismissSelf];
        }];
    } else if (authStatus == AVAuthorizationStatusRestricted) {
        [self showAlertWithTitle:@"无访问权限" msg:@"您的手机暂不支持拍摄或者启用了访问限制" callback:^{
            [self dismissSelf];
        }];
    }
}

- (instancetype)initWithType:(TTCameraDetectionType)type
{
    self = [super init];
    if (self) {
        self.type = type;
    }
    return self;
}

- (dispatch_queue_t)sessionQueue
{
    if (!_sessionQueue) {
        _sessionQueue = dispatch_queue_create("com.toutiao.TTCameraDetectionSession", DISPATCH_QUEUE_SERIAL);
    }
    
    return _sessionQueue;
}

- (dispatch_queue_t)outputQueue
{
    if (!_outputQueue) {
        _outputQueue = dispatch_queue_create("com.toutiao.TTCameraDetectionOutput", DISPATCH_QUEUE_SERIAL);
    }
    
    return _outputQueue;
}

- (NSOperationQueue *)accelerometerQueue
{
    if (!_accelerometerQueue) {
        _accelerometerQueue = [[NSOperationQueue alloc] init];
    }
    
    return _accelerometerQueue;
}

- (CMMotionManager *)motionManager
{
    if (!_motionManager) {
        _motionManager = [[CMMotionManager alloc] init];
    }
    
    return _motionManager;
}

- (void)flipPreviewLayer
{
    self.previewLayer.opacity = .5f;
    CATransition *animation = [CATransition animation];
    animation.duration = 0.5f;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    animation.type = @"oglFlip";
    if (self.currentDevicePosition == AVCaptureDevicePositionFront) {
        animation.subtype = kCATransitionFromRight;
    } else if(self.currentDevicePosition == AVCaptureDevicePositionBack){
        animation.subtype = kCATransitionFromLeft;
    }
    [self.previewLayer addAnimation:animation forKey:nil];
}

- (AVCaptureVideoOrientation)currentVideoOrientation
{
    AVCaptureConnection *connection = [self.deviceOutput connectionWithMediaType:AVMediaTypeVideo];
    return connection.videoOrientation;
}

- (AVCaptureFlashMode)currentFlashMode
{
    return self.device.flashMode;
}

- (AVCaptureDevicePosition)currentDevicePosition
{
    AVCaptureInput *currentCameraInput = [self.session.inputs firstObject];
    AVCaptureDeviceInput *currentInput = (AVCaptureDeviceInput *)currentCameraInput;
    if (currentInput) {
        return currentInput.device.position;
    } else {
        return AVCaptureDevicePositionUnspecified;
    }
}

- (void)setupPreviewLayerWithFrame:(CGRect)frame
{
    if (!self.hasInitialCamera || !self.session) {
        return;
    }
    // Preview
    self.previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:self.session];
    self.previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    self.previewLayer.frame = frame;
    
    [self.view.layer insertSublayer:self.previewLayer atIndex:0];
}

- (void)setupDetectorOptions:(NSDictionary *)options
{
    NSMutableDictionary *detectorOptions = [NSMutableDictionary dictionaryWithDictionary:options];
    switch (self.type) {
        case TTCameraDetectionTypeNone:
            break;
        case TTCameraDetectionTypeFace: {
            if (detectorOptions.count == 0) {
                detectorOptions[CIDetectorAccuracy] = CIDetectorAccuracyHigh;
            }
            self.detector = [CIDetector detectorOfType:CIDetectorTypeFace context:nil options:detectorOptions];
        }
            break;
        case TTCameraDetectionTypeText: {
            if (detectorOptions.count == 0) {
                detectorOptions[CIDetectorAccuracy] = CIDetectorAccuracyHigh;
            }
            self.detector = [CIDetector detectorOfType:CIDetectorTypeText context:nil options:detectorOptions];
        }
            break;
        case TTCameraDetectionTypeQRCode: {
            if (detectorOptions.count == 0) {
                detectorOptions[CIDetectorAccuracy] = CIDetectorAccuracyHigh;
            }
            self.detector = [CIDetector detectorOfType:CIDetectorTypeQRCode context:nil options:detectorOptions];
        }
            break;
        case TTCameraDetectionTypeRectangle: {
            if (detectorOptions.count == 0) {
                detectorOptions[CIDetectorAccuracy] = CIDetectorAccuracyHigh;
                detectorOptions[CIDetectorAspectRatio] = @(1.0);
            }
            self.detector = [CIDetector detectorOfType:CIDetectorTypeRectangle context:nil options:detectorOptions];
        }
            break;
        default:
            break;
    }
}

- (void)setupDetectorImageOptions:(NSDictionary *)imageOptions
{
    self.imageOptions = imageOptions;
}

- (void)setupCamera {
    if (self.hasInitialCamera) {
        if (![self.session isRunning]) {
            dispatch_async(self.sessionQueue, ^{
                [self.session startRunning];
            });
        }
        return;
    }
    
    if ([self checkVideoAuth] == AVAuthorizationStatusDenied) {
        return;
    }
    
    // Device
    self.device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if (!self.device) {
        return;
    }
    if (self.defaultDevicePosition) {
        AVCaptureDevice *device = [self cameraWithPosition:self.defaultDevicePosition];
        if (device) {
            self.device = device;
        } else {
            NSLog(@"Not support for device position: %ld", (long)self.defaultDevicePosition);
        }
    }
    
    // Session
    self.session = [[AVCaptureSession alloc] init];
    [self.session setSessionPreset:AVCaptureSessionPresetHigh];
    
    // FlashMode
    dispatch_async(self.sessionQueue, ^{
        [self.device lockForConfiguration:nil];
        if (self.defaultFlashmode && [self.device isFlashModeSupported:self.defaultFlashmode]) {
            self.device.flashMode = self.defaultFlashmode;
        } else if ([self.device isFlashModeSupported:AVCaptureFlashModeAuto]) {
            self.device.flashMode = AVCaptureFlashModeAuto;
        }
        [self.device unlockForConfiguration];
    });
    
    // Input
    self.deviceInput = [AVCaptureDeviceInput deviceInputWithDevice:self.device error:nil];
    
    // Output for Photo(JPEG)
    self.deviceOutput = [[AVCaptureStillImageOutput alloc] init];
    NSDictionary *outputSettings = [[NSDictionary alloc] initWithObjectsAndKeys: AVVideoCodecJPEG, AVVideoCodecKey, nil];
    [self.deviceOutput setOutputSettings:outputSettings];
    
    if ([self.session canAddInput:self.deviceInput]) {
        [self.session addInput:self.deviceInput];
    }
    if ([self.session canAddOutput:self.deviceOutput]) {
        [self.session addOutput:self.deviceOutput];
    }
    
    // Output for Detector
    if (self.detector) {
        self.deviceVideoOutput = [[AVCaptureVideoDataOutput alloc] init];
        [self.deviceVideoOutput setSampleBufferDelegate:self queue:self.outputQueue]; // 非主线程，对外接口可能会调用UIKit方法，因此后面dispatch_async到mainQueue上
        
        if ([self.session canAddOutput:self.deviceVideoOutput]) {
            [self.session addOutput:self.deviceVideoOutput];
        }
    }
    
    // Connection
    AVCaptureConnection *connection = [self connectionWithOutput:self.deviceOutput];
    if (connection && connection.isVideoOrientationSupported && !self.autoVideoOrientation) {
        connection.videoOrientation = self.defaultVideoOrientation;
    }
    
    self.hasInitialCamera = YES;
}

- (void)toggleCameraWithCallback:(void (^)(BOOL success))callback
{
    if (self.hasInitialCamera && self.session) {
        // 如果不支持切换摄像头，直接return
        if (self.currentDevicePosition == AVCaptureDevicePositionUnspecified) {
            if (callback) {
                callback(NO);
            }
            return;
        }
        
        dispatch_main_async_safe(^{
            [self flipPreviewLayer];
        });
        
        dispatch_async(self.sessionQueue, ^{
            [self.session beginConfiguration];
            
            AVCaptureInput *currentCameraInput = [self.session.inputs firstObject];
            if (currentCameraInput) {
                [self.session removeInput:currentCameraInput];
            }
            
            AVCaptureDevice *newCamera = nil;
            if (((AVCaptureDeviceInput *)currentCameraInput).device.position == AVCaptureDevicePositionBack) {
                newCamera = [self cameraWithPosition:AVCaptureDevicePositionFront];
            } else {
                newCamera = [self cameraWithPosition:AVCaptureDevicePositionBack];
            }
            
            self.device = newCamera; // 更新Device
            
            NSError *err = nil;
            AVCaptureDeviceInput *newVideoInput = [[AVCaptureDeviceInput alloc] initWithDevice:newCamera error:&err];
            if (err || !newVideoInput || ![self.session canAddInput:newVideoInput]) {
                NSLog(@"Error creating capture device input: %@", err.localizedDescription);
                if (callback) {
                    callback(NO);
                }
                return;
            } else {
                [self.session addInput:newVideoInput];
                self.deviceInput = newVideoInput;
            }
            
            [self.session commitConfiguration];
            
            dispatch_main_async_safe(^{
                [UIView animateWithDuration:0.3 animations:^{
                    self.previewLayer.opacity = 1;
                } completion:^(BOOL finished) {
                    if (callback) {
                        callback(YES);
                    }
                }];
            });
        });
    }
}

- (void)toggleFlashMode:(AVCaptureFlashMode)flashMode
{
    if (!self.hasInitialCamera) {
        return;
    }
    if (self.device && [self.device hasFlash]) {
        dispatch_async(self.sessionQueue, ^{
            [self.device lockForConfiguration:nil];
            
            self.device.flashMode = flashMode;
            
            [self.device unlockForConfiguration];
        });
    }
}

- (void)toggleVideoOrientation:(AVCaptureVideoOrientation)videoOrientation
{
    AVCaptureConnection *connection = [self.deviceOutput connectionWithMediaType:AVMediaTypeVideo];
    if (connection && connection.isVideoOrientationSupported && !self.autoVideoOrientation) {
        connection.videoOrientation = videoOrientation;
    }
}

- (void)setupFrameDuration:(CMTime)frameDuration
{
    NSArray *supportedFrameRateRanges = [self.device.activeFormat videoSupportedFrameRateRanges];
    BOOL frameRateSupported = NO;
    for (AVFrameRateRange *range in supportedFrameRateRanges) {
        if (CMTIME_COMPARE_INLINE(frameDuration, >=, range.minFrameDuration) &&
            CMTIME_COMPARE_INLINE(frameDuration, <=, range.maxFrameDuration)) {
            frameRateSupported = YES;
        }
    }
    
    dispatch_async(self.sessionQueue, ^{
        if (frameRateSupported && [self.device lockForConfiguration:nil]) {
            [self.device setActiveVideoMaxFrameDuration:frameDuration];
            [self.device setActiveVideoMinFrameDuration:frameDuration];
            [self.device unlockForConfiguration];
        }
    });
}

- (CMTime)currentFrameDuration
{
    return self.device.activeVideoMaxFrameDuration;
}

- (void)setupSamplingRate:(NSUInteger)samplingRate
{
    _maxSampleCount = samplingRate;
}

- (NSUInteger)currentSamplingRate
{
    return _maxSampleCount;
}

- (AVCaptureDevice *)cameraWithPosition:(AVCaptureDevicePosition)position
{
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    
    for (AVCaptureDevice *device in devices) {
        if ([device position] == position) {
            return device;
        }
    }
    return nil;
}

- (AVCaptureConnection *)connectionWithOutput:(AVCaptureOutput *)output
{
    AVCaptureConnection *videoConnection = nil;
    for (AVCaptureConnection *connection in output.connections) {
        for (AVCaptureInputPort *port in [connection inputPorts]) {
            if ([[port mediaType] isEqual:AVMediaTypeVideo]) {
                videoConnection = connection;
                break;
            }
        }
        if (videoConnection) {
            break;
        }
    }
    
    return videoConnection;
}

- (AVAuthorizationStatus)checkVideoAuth
{
    AVAuthorizationStatus videoAuthStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    return videoAuthStatus;
}

- (BOOL)checkAlbumAuth
{
    ALAuthorizationStatus photoAuthStatus = [ALAssetsLibrary authorizationStatus];
    if (photoAuthStatus == ALAuthorizationStatusDenied) {
        NSString *msg = @"请在手机的「设置-隐私-照片」选项中，允许幸福里访问你的相册";
        [self showAlertWithTitle:@"无访问权限" msg:msg callback:nil];
        return NO;
    } else if (photoAuthStatus == ALAuthorizationStatusRestricted) {
        NSString *msg = @"请在手机的「设置-通用-访问限制」选项中，允许访问相册";
        [self showAlertWithTitle:@"无访问权限" msg:msg callback:nil];
    }
    
    return YES;
}

- (void)showAlertWithTitle:(NSString *)title msg:(NSString *)msg callback:(void(^)(void))callback
{
    TTThemedAlertController *alert = [[TTThemedAlertController alloc] initWithTitle:title message:msg preferredType:TTThemedAlertControllerTypeAlert];
    [alert addActionWithTitle:@"确定" actionType:TTThemedAlertActionTypeCancel actionBlock:callback];
    [alert showFrom:[TTUIResponderHelper topmostViewController] animated:YES];
}

- (void)startCamera
{
    if (!self.hasInitialCamera) {
        return;
    }
    
    if (![self.session isRunning]) {
        dispatch_async(self.sessionQueue, ^{
            [self.session startRunning];
        });
    }
    
    if (self.autoVideoOrientation) {
        self.motionManager.accelerometerUpdateInterval = kTTCameraDetectionAccelerometerUpdateInterval;
        [self.motionManager startAccelerometerUpdatesToQueue:self.accelerometerQueue withHandler:^(CMAccelerometerData * _Nullable accelerometerData, NSError * _Nullable error) {
            if (!error && accelerometerData) {
                CMAcceleration acceleration = accelerometerData.acceleration;
                if (acceleration.x >= kTTCameraDetectionAccelerometerOffset) {
                    self.currentDeviceOrientation = UIDeviceOrientationLandscapeRight;
                } else if (acceleration.x <= -kTTCameraDetectionAccelerometerOffset) {
                    self.currentDeviceOrientation = UIDeviceOrientationLandscapeLeft;
                } else if (acceleration.y <= -kTTCameraDetectionAccelerometerOffset) {
                    self.currentDeviceOrientation = UIDeviceOrientationPortrait;
                } else if (acceleration.y >= kTTCameraDetectionAccelerometerOffset) {
                    self.currentDeviceOrientation = UIDeviceOrientationPortraitUpsideDown;
                } else {
                    self.currentDeviceOrientation = [UIDevice currentDevice].orientation;
                }
            }
        }];
    }
}

- (void)stopCamera
{
    if (self.hasInitialCamera && [self.session isRunning]) {
        dispatch_async(self.sessionQueue, ^{
            [self.session stopRunning];
        });
    }
    
    if (self.autoVideoOrientation) {
        if (self.motionManager.accelerometerActive) {
            [self.motionManager stopAccelerometerUpdates];
        }
    }
}

- (void)captureWithComplectionBlock:(void (^)(UIImage *, NSError *))block;
{
    if (!self.hasInitialCamera) {
        if (block) {
            block(nil, [NSError errorWithDomain:@"kCommonErrorDomain" code:-1 userInfo:nil]);
        }
        return;
    }

    AVCaptureConnection *connection = [self.deviceOutput connectionWithMediaType:AVMediaTypeVideo];
    if (!connection.enabled) {
        if (block) {
            dispatch_main_async_safe(^{
                block(nil, [NSError errorWithDomain:@"kCommonErrorDomain" code:-1 userInfo:nil]);
            })
        }
        return;
    }
    
    if (self.autoVideoOrientation && connection.isVideoOrientationSupported) {
        AVCaptureVideoOrientation orientation = [self currentDeviceVideoOrientation];
        [connection setVideoOrientation:orientation];
    }
    //AVFoundation StillImage was deprecated in iOS 10 and later.
    [self.deviceOutput captureStillImageAsynchronouslyFromConnection:connection completionHandler: ^(CMSampleBufferRef imageSampleBuffer, NSError *error)
     {
         if (error) {
             if (block) {
                 dispatch_main_async_safe(^{
                     block(nil, error);
                 })
             }
             return;
         }
         
         NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageSampleBuffer];
         UIImage *image = [[UIImage alloc] initWithData:imageData];
         
         if (self.currentDevicePosition == AVCaptureDevicePositionFront) {
             image = [UIImage imageWithCGImage:image.CGImage scale:1.0 orientation:UIImageOrientationLeftMirrored]; // rotate for front camera
         }
         
         _currentImage = image;
         
         if (_saveToAlbum && [self checkAlbumAuth]) {
             UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
         }
         
         if (block) {
             dispatch_main_async_safe(^{
                 block(image, nil);
             })
         }
     }];
}


- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection
{
    // only for detector and delegate
    if (!self.hasInitialCamera || !self.detector || !self.delegate || ![self.delegate respondsToSelector:@selector(didDetectSuccess:withFeatures:ofImage:)]) {
        return;
    }
    
    if (_maxSampleCount > 1 && _currentSampleCount < _maxSampleCount - 1) {
        _currentSampleCount++;
        return; // 视频采样
    }
    if (_maxSampleCount > 1) {
        _currentSampleCount = 0;
    }
    
    CVImageBufferRef cvImage = CMSampleBufferGetImageBuffer(sampleBuffer);
    CIImage *ciImage = [[CIImage alloc] initWithCVPixelBuffer:cvImage];
    NSArray *features = [self.detector featuresInImage:ciImage options:self.imageOptions];
    
    BOOL success = NO;
    UIImage *image = nil;
    if (features && features.count > 0) {
        success = YES;
        switch (self.currentVideoOrientation) {
            case AVCaptureVideoOrientationPortrait:
                image = [UIImage imageWithCIImage:ciImage scale:1.0 orientation:UIImageOrientationRight];
                break;
            case AVCaptureVideoOrientationLandscapeRight:
                image = [UIImage imageWithCIImage:ciImage];
                break;
            case AVCaptureVideoOrientationLandscapeLeft:
                image = [UIImage imageWithCIImage:ciImage scale:1.0 orientation:UIImageOrientationDown];
                break;
            case AVCaptureVideoOrientationPortraitUpsideDown:
                image = [UIImage imageWithCIImage:ciImage scale:1.0 orientation:UIImageOrientationLeft];
                break;
        }
    }
    
    dispatch_main_async_safe(^{
        [self.delegate didDetectSuccess:success withFeatures:features ofImage:image];
    });
}

- (AVCaptureVideoOrientation)currentDeviceVideoOrientation
{
    AVCaptureVideoOrientation newOrientation;
    UIDeviceOrientation deviceOrientation = self.currentDeviceOrientation;
    switch (deviceOrientation) {
        case UIDeviceOrientationPortrait:
            newOrientation = AVCaptureVideoOrientationPortrait;
            break;
        case UIDeviceOrientationPortraitUpsideDown:
            newOrientation = AVCaptureVideoOrientationPortraitUpsideDown;
            break;
        case UIDeviceOrientationLandscapeLeft:
            newOrientation = AVCaptureVideoOrientationLandscapeRight;
            break;
        case UIDeviceOrientationLandscapeRight:
            newOrientation = AVCaptureVideoOrientationLandscapeLeft;
            break;
        default:
            newOrientation = self.currentVideoOrientation;
    }
    
    return newOrientation;
}

@end
