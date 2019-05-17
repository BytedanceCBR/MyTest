//
//  TTRealnameAuthServiceForWebManager.m
//  Article
//
//  Created by chenren on 27/04/2017.
//
//

#import "TTRealnameAuthServiceForWebManager.h"
#import "TTNetworkManager.h"
#import "MBProgressHUD.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "TTVideoUploadManager.h"
#import "TTVideoUploadOperation.h"
#import "TTNetworkManager.h"
#import "TTRealnameAuthIDCradOverlayerView.h"
#import "TTRealnameAuthPeopleOutlineOverlayerView.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <AVFoundation/AVFoundation.h>
#import "TTVideoCompressHelper.h"
#import <TTBaseLib/JSONAdditions.h>
#import <Photos/Photos.h>

#pragma mark  Auth-bridge方法名
NSString * const TTRealnameAuthForWebManagerAllService          = @"auth_totalServices";
NSString * const TTRealnameAuthForWebManagerImageShotService    = @"takePicture";
NSString * const TTRealnameAuthForWebManagerImageUploadService  = @"uploadPicture";
NSString * const TTRealnameAuthForWebManagerVideoShotService    = @"takeVideo";
NSString * const TTRealnameAuthForWebManagerVideoUploadService  = @"uploadVideo";
NSString * const TTRealnameAuthForWebManagerPGCUploadPath       = @"/pgcui/media_ocr/upload_identity_pic/";

typedef NS_ENUM(NSUInteger, TTRealnameAuthOverlayViewType) {
    TTRealnameAuthOverlayViewTypeIDCard = 1,
    TTRealnameAuthOverlayViewTypeIDCardBack = 2,
    TTRealnameAuthOverlayViewTypePeopleOutline = 3
};
@interface TTRealnameAuthServiceForWebManager ()<UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (nonatomic, weak)   SSJSBridgeWebView *jsWebView;
@property (nonatomic, copy)   NSString *taskId;
@property (nonatomic, copy)   NSString *callJsBackName; // 有回调的必须传JS回调的名称

// 拍照相关
@property (nonatomic, strong) UIImagePickerController *imagePicker;

// 拍视频相关
@property (nonatomic, strong) UIImagePickerController *videoPicker;
@property (nonatomic, strong) TTVideoUploadManager *videoUploadManager;
@property (nonatomic, strong) MBProgressHUD *progressHud;

@property (nonatomic, weak) UIImagePickerController *currentPicker;
@property (nonatomic, strong) UIView *stashOverlayView;
@end


@implementation TTRealnameAuthServiceForWebManager

#pragma mark Auth服务
+ (NSArray *)services
{
    // 拍照
    NSMutableDictionary *imageShot = [[NSMutableDictionary alloc] init];
    [imageShot setValue:@(TTRealnameAuthServiceForWebTypeImageShot) forKey:@"code"];
    [imageShot setValue:@[@{@"taskId":@"",@"type":@"album",@"callBack":@""},
                          @{@"taskId":@"",@"type":@"record",@"callBack":@""}]
                 forKey:@"paramsDic"];
    [imageShot setValue:TTRealnameAuthForWebManagerImageShotService forKey:@"name"];
    
    // 上传照片
    NSMutableDictionary *imageUpload = [[NSMutableDictionary alloc] init];
    [imageUpload setValue:@(TTRealnameAuthServiceForWebTypeImageUpload) forKey:@"code"];
    [imageUpload setValue:@[@{@"type":@"startUpload",@"callBack":@""},
                            @{@"type":@"stopUpload",@"callBack":@""}]
                   forKey:@"paramsDic"];
    [imageUpload setValue:TTRealnameAuthForWebManagerImageUploadService forKey:@"name"];
    
    // 拍视频
    NSMutableDictionary *videoShot = [[NSMutableDictionary alloc] init];
    [videoShot setValue:@(TTRealnameAuthServiceForWebTypeVideoShot) forKey:@"code"];
    [videoShot setValue:@[@{@"type":@"startRecord",@"filePath":@"",@"callBack":@""},
                          @{@"type":@"stopRecord",@"filePath":@"",@"callBack":@""}]
                 forKey:@"paramsDic"];
    [videoShot setValue:TTRealnameAuthForWebManagerVideoShotService forKey:@"name"];
    
    // 上传视频
    NSMutableDictionary *videoUpload = [[NSMutableDictionary alloc] init];
    [videoUpload setValue:@(TTRealnameAuthServiceForWebTypeVideoUpload) forKey:@"code"];
    [videoUpload setValue:@[@{@"taskId":@"",@"filePath":@"",
                              @"callBack":@""}]
                   forKey:@"paramsDic"];
    [videoUpload setValue:TTRealnameAuthForWebManagerVideoUploadService forKey:@"name"];
    
    return @[imageShot, imageUpload, videoShot, videoUpload];
}

+ (void)supportNativeServiceForWebView:(SSJSBridgeWebView *)webView
{
    [webView.ttr_staticPlugin registerHandlerBlock:^(NSDictionary *result, TTRJSBResponse callback) {
        if (callback) {
            callback(TTRJSBMsgSuccess, @{@"servicesArray":[[self class] services]});
        }
    } forMethodName:TTRealnameAuthForWebManagerAllService];
    
    // 默认全部注册
    for (NSDictionary *serviceDic in [[self class] services]) {
        NSUInteger type = ((NSNumber *)[serviceDic valueForKey:@"code"]).integerValue;
        [[self class] registerWebView:webView forService:type];
    }
}

+ (void)registerWebView:(SSJSBridgeWebView *)webView forService:(TTRealnameAuthServiceForWebType)serviceType
{
    switch (serviceType) {
        case TTRealnameAuthServiceForWebTypeImageShot:
            [[TTRealnameAuthServiceForWebManager sharedInstance_tt] imageShotForWebView:webView];
            break;
            
        case TTRealnameAuthServiceForWebTypeImageUpload:
            [[TTRealnameAuthServiceForWebManager sharedInstance_tt] imageUploadForWebView:webView];
            break;
            
        case TTRealnameAuthServiceForWebTypeVideoShot:
            [[TTRealnameAuthServiceForWebManager sharedInstance_tt] videoShotForWebView:webView];
            break;
            
        case TTRealnameAuthServiceForWebTypeVideoUpload:
            [[TTRealnameAuthServiceForWebManager sharedInstance_tt] videoUploadForWebView:webView];
            break;
        default:
            break;
    }
}
- (instancetype)init {
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(imagePickerControllerUserDidCaptureItem:) name:@"_UIImagePickerControllerUserDidCaptureItem" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(imagePickerControllerUserDidRejectItem:) name:@"_UIImagePickerControllerUserDidRejectItem" object:nil];
    }
    return self;
}

#pragma mark 拍照与视频录制以及上传
- (UIImagePickerController *)imagePicker
{
    if (!_imagePicker) {
        _imagePicker = [[UIImagePickerController alloc] init];
        _imagePicker.mediaTypes = [NSArray arrayWithObjects:(NSString *)kUTTypeImage,nil];
        _imagePicker.delegate = self;
    }
    
    return _imagePicker;
}

- (UIImagePickerController *)videoPicker
{
    if (!_videoPicker) {
        _videoPicker = [[UIImagePickerController alloc] init];
        _videoPicker.mediaTypes = [NSArray arrayWithObjects:(NSString *)kUTTypeMovie,nil];
        _videoPicker.delegate = self;
    }
    
    return _videoPicker;
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    self.currentPicker = nil;
    if (picker == self.imagePicker) {
        [self processImageShotWithInfo:info forImagePickerController:self.imagePicker];
    }
    
    if (picker == self.videoPicker) {
        [self processVideoShotWithInfo:info forImagePickerController:self.videoPicker];
    }
}

- (void)processJSCallbackWithImageURL:(NSURL *)assetURL
{
    __weak typeof(self) wSelf = self;
    ALAssetsLibrary *allib = [[ALAssetsLibrary alloc] init];
    [allib assetForURL:assetURL resultBlock:^(ALAsset *asset) {
        // 获取参数信息
        ALAssetRepresentation *assetRep = [asset defaultRepresentation];
        CGSize dimension = [assetRep dimensions];
        long long size = [assetRep size];
        
        NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
        [params setValue:assetURL.absoluteString forKey:@"uri"];
        [params setValue:@(size) forKey:@"size"];
        [params setValue:@(dimension.width) forKey:@"width"];
        [params setValue:@(dimension.height) forKey:@"height"];
        [wSelf invokeJSWithFunctionName:wSelf.callJsBackName parameters:params finishBlock:nil];
    } failureBlock:^(NSError *error) {
        [wSelf invokeJSCallbackWithErrorInfo:@"Auth fetching image info failed." forVideoCall:NO];
    }];
}

- (void)processImageShotWithInfo:(NSDictionary *)info forImagePickerController:(UIImagePickerController *)picker
{
    if (picker.sourceType == UIImagePickerControllerSourceTypePhotoLibrary) {
        NSLog(@"Auth fetching image photo succeeded.");
        
        NSURL *assetURL = info[UIImagePickerControllerReferenceURL];
        __weak typeof(self) wSelf = self;
        [picker dismissViewControllerAnimated:YES completion:^{
            [wSelf processJSCallbackWithImageURL:assetURL];
        }];
        
    } else {
        UIImage *image = info[UIImagePickerControllerOriginalImage];
        __weak typeof(self) wSelf = self;
        [picker dismissViewControllerAnimated:YES completion:^{
            ALAuthorizationStatus authStatus = [ALAssetsLibrary authorizationStatus];
            if (authStatus == ALAuthorizationStatusRestricted || authStatus == ALAuthorizationStatusDenied) {
                NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
                [params setValue:@(1) forKey:@"image"];
                [params setValue:@(1) forKey:@"error"];
                [params setValue:@(0) forKey:@"auth"];
                [params setValue:@"User has no photo authorization." forKey:@"info"];
                [wSelf invokeJSWithFunctionName:wSelf.callJsBackName parameters:params finishBlock:nil];
            } else {
                ALAssetsLibrary *assetsLibrary= [[ALAssetsLibrary alloc] init];
                [assetsLibrary writeImageToSavedPhotosAlbum:[image CGImage] orientation:(ALAssetOrientation)[image imageOrientation] completionBlock:^(NSURL *assetURL, NSError *error) {
                    if (error) {
                        NSLog(@"Auth saving image failed：%@", error);
                        [wSelf invokeJSCallbackWithErrorInfo:@"Auth saving image failed." forVideoCall:NO];
                    } else {
                        NSLog(@"Auth saving image succeeded.");
                        [wSelf processJSCallbackWithImageURL:assetURL];
                    }
                }];
            }
        }];
    }
}

- (void)processVideoShotWithInfo:(NSDictionary *)info forImagePickerController:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:^{
        
        [self updateStatusBarHidden:NO animated:NO];
        
        NSString * tempVideoPath = [self videosCachePath];
        tempVideoPath = [tempVideoPath stringByAppendingPathComponent:@"video"];
        tempVideoPath = [tempVideoPath stringByAppendingPathExtension:@"mp4"];
        if ([[NSFileManager defaultManager] removeItemAtPath:tempVideoPath error:NULL]) {
            NSLog(@"successfully removed cached video..");
        }
        
        __weak typeof(self) wSelf = self;
        NSURL *tempVideoPathURL = [NSURL fileURLWithPath:tempVideoPath isDirectory:NO];
        NSURL *tempShotVideoPathURL = info[@"UIImagePickerControllerMediaURL"];
        
        ALAuthorizationStatus authStatus = [ALAssetsLibrary authorizationStatus];
        if (authStatus == ALAuthorizationStatusRestricted || authStatus == ALAuthorizationStatusDenied) {
            NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
            [params setValue:@(1) forKey:@"image"];
            [params setValue:@(1) forKey:@"error"];
            [params setValue:@(0) forKey:@"auth"];
            [params setValue:@"User has no photo authorization." forKey:@"info"];
            [wSelf invokeJSWithFunctionName:wSelf.callJsBackName parameters:params finishBlock:nil];
            if ([[NSFileManager defaultManager] removeItemAtPath:tempShotVideoPathURL.path error:NULL]) {
                NSLog(@"successfully removed cached video..");
            }
        } else {
            [TTVideoCompressHelper compressVideoFromInputUrl:tempShotVideoPathURL toOutputUrl:tempVideoPathURL scaleDuration:NO withBlock:^(BOOL success) {
                if (success) {
                    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
                    [library writeVideoAtPathToSavedPhotosAlbum:tempVideoPathURL completionBlock:^(NSURL *assetURL, NSError *error) {
                        if (error) {
                            NSLog(@"Auth saving mp4 video failed：%@", error);
                            [self invokeJSCallbackWithErrorInfo:@"Auth writing mp4 video failed." forVideoCall:YES];
                            
                        } else {
                            NSLog(@"Auth saving mp4 video succeeded.");
                            
                            AVURLAsset *avAsset = [AVURLAsset assetWithURL:assetURL];
                            CMTime duration = avAsset.duration;
                            float seconds = 0.f;
                            if (duration.timescale != 0) {
                                seconds = duration.value / (float)duration.timescale;
                            }
                            ALAssetsLibrary *allib = [[ALAssetsLibrary alloc] init];
                            [allib assetForURL:assetURL resultBlock:^(ALAsset *asset) {
                                
                                ALAssetRepresentation *assetRep = [asset defaultRepresentation];
                                CGSize dimension = [assetRep dimensions];
                                long long size = [assetRep size];
                                
                                NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
                                [params setValue:assetURL.absoluteString forKey:@"uri"];
                                [params setValue:@(size) forKey:@"size"];
                                [params setValue:@(dimension.width) forKey:@"width"];
                                [params setValue:@(dimension.height) forKey:@"height"];
                                [params setValue:@(seconds) forKey:@"duration"];
                                [wSelf invokeJSWithFunctionName:wSelf.callJsBackName parameters:params finishBlock:nil];
                            } failureBlock:^(NSError *error) {
                                [self invokeJSCallbackWithErrorInfo:@"Auth saving mp4 video failed." forVideoCall:YES];
                            }];
                            
                            if ([[NSFileManager defaultManager] removeItemAtPath:tempVideoPath error:NULL]) {
                                NSLog(@"successfully removed cached video..");
                            }
                        }
                    }];
                } else {
                    [self invokeJSCallbackWithErrorInfo:@"Auth compressing mp4 video failed." forVideoCall:YES];
                }
                
                if ([[NSFileManager defaultManager] removeItemAtPath:tempShotVideoPathURL.path error:NULL]) {
                    NSLog(@"successfully removed cached video..");
                }
            }];
        }
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    BOOL isVideo = NO;
    if (picker == self.videoPicker) {
        isVideo = YES;
    }
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    if (isVideo) {
        [params setValue:@(1) forKey:@"video"];
    } else {
        [params setValue:@(1) forKey:@"image"];
    }
    [params setValue:@(1) forKey:@"error"];
    [params setValue:@(1) forKey:@"cancel"];
    [params setValue:@"User canceled shot process." forKey:@"info"];
    [self invokeJSWithFunctionName:self.callJsBackName parameters:params finishBlock:nil];
    
    self.currentPicker = nil;
    self.stashOverlayView = nil;
    [picker dismissViewControllerAnimated:YES completion:^{
        [self updateStatusBarHidden:NO animated:NO];
    }];
}

- (void)imageShotForWebView:(SSJSBridgeWebView *)webView
{
    self.jsWebView = webView;
    
    __weak typeof(self) wSelf = self;
    [webView.ttr_staticPlugin registerHandlerBlock:^(NSDictionary *result, TTRJSBResponse callback) {
        wSelf.callJsBackName = result[@"callback"];
        NSInteger overLayerType = [result tt_integerValueForKey:@"overlayer_type"];
        UIView *overlayView = [self overlayViewWithType:overLayerType];
        
        if ([result[@"type"] isEqualToString:@"photo"]) {
            ALAuthorizationStatus authStatus = [ALAssetsLibrary authorizationStatus];
            if (authStatus == ALAuthorizationStatusRestricted || authStatus == ALAuthorizationStatusDenied) {
                NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
                [params setValue:@(1) forKey:@"image"];
                [params setValue:@(1) forKey:@"error"];
                [params setValue:@(0) forKey:@"auth"];
                [params setValue:@"User has no photo authorization." forKey:@"info"];
                [wSelf invokeJSWithFunctionName:wSelf.callJsBackName parameters:params finishBlock:nil];
            } else {
                wSelf.imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            }
        } else {
            AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
            if(authStatus == AVAuthorizationStatusRestricted || authStatus == AVAuthorizationStatusDenied) {
                NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
                [params setValue:@(1) forKey:@"video"];
                [params setValue:@(1) forKey:@"error"];
                [params setValue:@(0) forKey:@"auth"];
                [params setValue:@"User has no camera authorization." forKey:@"info"];
                [wSelf invokeJSWithFunctionName:wSelf.callJsBackName parameters:params finishBlock:nil];
            } else {
                wSelf.imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
                wSelf.imagePicker.cameraOverlayView = overlayView;
            }
        }
        UIViewController *topVC = [TTUIResponderHelper topViewControllerFor:wSelf.jsWebView];
        [topVC presentViewController:wSelf.imagePicker animated:YES completion:nil];
        wSelf.currentPicker = wSelf.imagePicker;
    } forMethodName:TTRealnameAuthForWebManagerImageShotService];
}

- (void)imageUploadForWebView:(SSJSBridgeWebView *)webView
{
    self.jsWebView = webView;
    
    __weak typeof(self) wSelf = self;
    [webView.ttr_staticPlugin registerHandlerBlock:^(NSDictionary *result, TTRJSBResponse callback) {
        
        wSelf.callJsBackName = result[@"callback"];
        
        NSURL *assetURL = [NSURL URLWithString:@""];
        assetURL = [NSURL URLWithString:@"assets-library://asset/asset.JPG?id=33C4C988-7FBA-470A-B882-A4599C45DC54&ext=JPG"];
        if (result[@"uri"]) {
            assetURL = [NSURL URLWithString:result[@"uri"]];
        }
        
        NSString *picTypeName = @"identity_front_pic";
        if (result[@"upload_key"]) {
            picTypeName = result[@"upload_key"];
        }
        
        NSDictionary *paramDic = nil;
        if (result[@"param"]) {
            paramDic = [[NSDictionary alloc] initWithObjectsAndKeys:result[@"param"], @"web_param", nil];
        }
        
        NSString *uploadURL = [result tt_stringValueForKey:@"upload_url"]? :TTRealnameAuthForWebManagerPGCUploadPath;
        
        NSString *uploadHost = [result tt_stringValueForKey:@"upload_host"]? :[CommonURLSetting baseURL];
        
        uploadURL = [NSString stringWithFormat:@"%@%@", uploadHost, uploadURL];
        
        NSString *callJsBackName = result[@"callback"];
        
        if ([UIDevice currentDevice].systemVersion.floatValue >= 9.0f && [SSCommonLogic useImageVideoNewApi]) { // iOS9 later
            PHFetchResult<PHAsset *> *fetchResult = [PHAsset fetchAssetsWithALAssetURLs:@[assetURL] options:nil];
            if (!fetchResult || !fetchResult.firstObject) {
                [wSelf invokeJSCallbackWithErrorInfo:@"PHAsset first fetching upload image info failed." forVideoCall:NO];
                return;
            }
            PHAsset *asset = fetchResult.firstObject;
            if (asset) {
                PHImageRequestOptions * options = [[PHImageRequestOptions alloc] init];
                options.version = PHImageRequestOptionsVersionOriginal;
                options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
                options.synchronous = YES;
                [[PHImageManager defaultManager] requestImageDataForAsset:asset
                                                                  options:options
                                                            resultHandler:^(NSData *imageData, NSString *dataUTI, UIImageOrientation orientation, NSDictionary * info) {
                                                                [[TTNetworkManager shareInstance] uploadWithURL:uploadURL parameters:paramDic constructingBodyWithBlock:^(id<TTMultipartFormData> formData) {
                                                                    [formData appendPartWithFileData:imageData name:picTypeName fileName:@"image.jpeg" mimeType:@"image/jpeg"];
                                                                } progress:nil needcommonParams:YES callback:^(NSError *error, id jsonObj) {
                                                                    if (error && !jsonObj) {
                                                                        [wSelf invokeJSCallbackWithErrorInfo:@"PHAsset uploading image file failed." forVideoCall:NO];
                                                                    } else {
                                                                        [wSelf invokeJSWithFunctionName:wSelf.callJsBackName parameters:jsonObj finishBlock:nil];
                                                                    }
                                                                }];
                                                            }];
            } else {
                [wSelf invokeJSCallbackWithErrorInfo:@"PHAsset second fetching upload image info failed." forVideoCall:NO];
            }
        } else {
            ALAssetsLibrary *allib = [[ALAssetsLibrary alloc] init];
            [allib assetForURL:assetURL resultBlock:^(ALAsset *asset) {
                
                if (asset) {
                    // 获取照片参数
                    ALAssetRepresentation *assetRep = [asset defaultRepresentation];
                    CGImageRef imgRef = [assetRep fullResolutionImage];
                    UIImage *assetImage = [UIImage imageWithCGImage:imgRef scale:assetRep.scale orientation:(UIImageOrientation)assetRep.orientation];
                    [[TTNetworkManager shareInstance] uploadWithURL:uploadURL parameters:paramDic constructingBodyWithBlock:^(id<TTMultipartFormData> formData) {
                        [formData appendPartWithFileData:UIImageJPEGRepresentation(assetImage, 0.f) name:picTypeName fileName:@"image.jpeg" mimeType:@"image/jpeg"];
                    } progress:nil needcommonParams:YES callback:^(NSError *error, id jsonObj) {
                        
                        if (error && !jsonObj) {
                            [wSelf invokeJSCallbackWithErrorInfo:@"Auth uploading image file failed." forVideoCall:NO];
                        } else {
                            [wSelf invokeJSWithFunctionName:wSelf.callJsBackName parameters:jsonObj finishBlock:nil];
                        }
                    }];
                } else {
                    [wSelf invokeJSCallbackWithErrorInfo:@"Auth fetching upload image info failed." forVideoCall:NO];
                }
                
            } failureBlock:^(NSError *error) {
                [self invokeJSCallbackWithErrorInfo:@"Auth fetching upload image info failed." forVideoCall:NO];
            }];
        }
        
    } forMethodName:TTRealnameAuthForWebManagerImageUploadService];
}

- (void)videoShotForWebView:(SSJSBridgeWebView *)webView
{
    self.jsWebView = webView;
    
    __weak typeof(self) wSelf = self;
    [webView.ttr_staticPlugin registerHandlerBlock:^(NSDictionary *result, TTRJSBResponse callback) {
        [self updateStatusBarHidden:YES animated:YES];
        wSelf.callJsBackName = result[@"callback"];
        NSInteger overLayerType = [result tt_integerValueForKey:@"overlayer_type"];
        UIView *overlayView = [self overlayViewWithType:overLayerType];
        
        AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
        if(authStatus == AVAuthorizationStatusRestricted || authStatus == AVAuthorizationStatusDenied) {
            NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
            [params setValue:@(1) forKey:@"video"];
            [params setValue:@(1) forKey:@"error"];
            [params setValue:@(0) forKey:@"auth"];
            [params setValue:@"User has no camera authorization." forKey:@"info"];
            [wSelf invokeJSWithFunctionName:wSelf.callJsBackName parameters:params finishBlock:nil];
        }
        
        wSelf.videoPicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        wSelf.videoPicker.videoQuality = UIImagePickerControllerQualityTypeIFrame1280x720;
        wSelf.videoPicker.cameraCaptureMode = UIImagePickerControllerCameraCaptureModeVideo;
        wSelf.videoPicker.videoMaximumDuration = 600;
        wSelf.videoPicker.cameraOverlayView = overlayView;
        BOOL isFrontCameraSupport = [UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront];
        if (isFrontCameraSupport) {
            wSelf.videoPicker.cameraDevice = UIImagePickerControllerCameraDeviceFront;
        }
        UIViewController *topVC = [TTUIResponderHelper topViewControllerFor:wSelf.jsWebView];
        [topVC presentViewController:wSelf.videoPicker animated:YES completion:nil];
        wSelf.currentPicker = wSelf.videoPicker;
        
    } forMethodName:TTRealnameAuthForWebManagerVideoShotService];
}

- (void)videoUploadForWebView:(SSJSBridgeWebView *)webView
{
    self.jsWebView = webView;
    __weak typeof(self) wSelf = self;
    [webView.ttr_staticPlugin registerHandlerBlock:^(NSDictionary *result, TTRJSBResponse callback) {
        wSelf.callJsBackName = result[@"callback"];
        
        NSURL *assetURL = [NSURL URLWithString:@""];
        assetURL = [NSURL URLWithString:@"assets-library://asset/asset.mp4?id=9D4DA39F-3D9E-4436-B7D1-E46F79FB4FF6&ext=mp4"];
        if (result[@"uri"]) {
            assetURL = [NSURL URLWithString:result[@"uri"]];
        }
        
        NSString *liveVideo = @"live_video";
        if (result[@"upload_key"]) {
            liveVideo = result[@"upload_key"];
        }
        
        NSDictionary *paramDic = nil;
        if (result[@"param"]) {
            paramDic = [[NSDictionary alloc] initWithObjectsAndKeys:result[@"param"], @"web_param", nil];
        }
        
        NSString *uploadURL = [result tt_stringValueForKey:@"upload_url"]? :[CommonURLSetting imageIDVideoUploadURLString];
        NSString *uploadHost = [result tt_stringValueForKey:@"upload_host"]? :[CommonURLSetting baseURL];
        
        uploadURL = [NSString stringWithFormat:@"%@%@", uploadHost, uploadURL];
        
        NSString *callJsBackName = result[@"callback"];
        
        if ([UIDevice currentDevice].systemVersion.floatValue >= 9.0f && [SSCommonLogic useImageVideoNewApi]) { // iOS9 later
            PHFetchResult<PHAsset *> *fetchResult = [PHAsset fetchAssetsWithALAssetURLs:@[assetURL] options:nil];
            if (!fetchResult || !fetchResult.firstObject) {
                [wSelf invokeJSCallbackWithErrorInfo:@"PHAsset first fetching upload video file failed." forVideoCall:YES];
                return;
            }
            PHAsset *asset = fetchResult.firstObject;
            if (asset) {
                PHVideoRequestOptions * options = [[PHVideoRequestOptions alloc] init];
                options.version = PHVideoRequestOptionsVersionOriginal;
                options.deliveryMode = PHVideoRequestOptionsDeliveryModeHighQualityFormat;
                [[PHImageManager defaultManager] requestAVAssetForVideo:asset
                                                                options:options
                                                          resultHandler:^(AVAsset *asset, AVAudioMix *audioMix, NSDictionary *info) {
                                                              
                                                              if (asset) {
                                                                  AVURLAsset *urlAsset = (AVURLAsset *)asset;
                                                                  NSURL *url = urlAsset.URL;
                                                                  NSData *videoFileData = [NSData dataWithContentsOfURL:url];
                                                                  
                                                                  if (videoFileData) {
                                                                      // http://i.snsdk.com/pgcui/media_ocr/upload_live_video/
                                                                      [[TTNetworkManager shareInstance] uploadWithURL:uploadURL parameters:paramDic constructingBodyWithBlock:^(id<TTMultipartFormData> formData) {
                                                                          [formData appendPartWithFileData:videoFileData name:liveVideo fileName:@"video.mp4" mimeType:@"video/mp4"];
                                                                      } progress:nil needcommonParams:YES callback:^(NSError *error, id jsonObj) {
                                                                          if (error && !jsonObj) {
                                                                              [wSelf invokeJSCallbackWithErrorInfo:@"PHAsset uploading video file failed." forVideoCall:YES];
                                                                          } else {
                                                                              [wSelf invokeJSWithFunctionName:callJsBackName parameters:jsonObj finishBlock:nil];
                                                                          }
                                                                      }];
                                                                  } else {
                                                                      [wSelf invokeJSCallbackWithErrorInfo:@"PHAsset fetching video file failed." forVideoCall:YES];
                                                                  }
                                                                  
                                                              } else {
                                                                  [wSelf invokeJSCallbackWithErrorInfo:@"PHAsset fetching mp4 video data failed." forVideoCall:YES];
                                                              }
                                                          }];
            } else {
                [wSelf invokeJSCallbackWithErrorInfo:@"PHAsset second fetching upload video file failed." forVideoCall:YES];
            }
            
        } else {
            ALAssetsLibrary *allib = [[ALAssetsLibrary alloc] init];
            [allib assetForURL:assetURL resultBlock:^(ALAsset *asset) {
                
                if (asset) {
                    ALAssetRepresentation *assetRep = [asset defaultRepresentation];
                    long long videoSize = [assetRep size];
                    NSMutableData *videoData = [[NSMutableData alloc] initWithCapacity:videoSize];
                    void *buffer = [videoData mutableBytes];
                    [assetRep getBytes:buffer fromOffset:0 length:videoSize error:nil];
                    NSData *videoFileData = [[NSData alloc] initWithBytes:buffer length:videoSize];
                    
                    // http://i.snsdk.com/pgcui/media_ocr/upload_live_video/
                    [[TTNetworkManager shareInstance] uploadWithURL:uploadURL parameters:paramDic constructingBodyWithBlock:^(id<TTMultipartFormData> formData) {
                        [formData appendPartWithFileData:videoFileData name:liveVideo fileName:@"video.mp4" mimeType:@"video/mp4"];
                    } progress:nil needcommonParams:YES callback:^(NSError *error, id jsonObj) {
                        if (error && !jsonObj) {
                            [wSelf invokeJSCallbackWithErrorInfo:@"Auth uploading video file failed." forVideoCall:YES];
                        } else {
                            [wSelf invokeJSWithFunctionName:callJsBackName parameters:jsonObj finishBlock:nil];
                        }
                    }];
                } else {
                    [wSelf invokeJSCallbackWithErrorInfo:@"Auth fetching mp4 video failed." forVideoCall:YES];
                }
                
            } failureBlock:^(NSError *error) {
                [self invokeJSCallbackWithErrorInfo:@"Auth fetching mp4 video failed." forVideoCall:YES];
            }];
        }
        
    } forMethodName:TTRealnameAuthForWebManagerVideoUploadService];
}

- (void)invokeJSCallbackWithErrorInfo:(NSString *)info forVideoCall:(BOOL)isVideo
{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    if (isVideo) {
        [params setValue:@(1) forKey:@"video"];
    } else {
        [params setValue:@(1) forKey:@"image"];
    }
    [params setValue:@(1) forKey:@"error"];
    [params setValue:info forKey:@"info"];
    [self invokeJSWithFunctionName:self.callJsBackName parameters:params finishBlock:nil];
}

- (NSString *)videosCachePath
{
    NSString *cachePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject stringByAppendingString:@"/TTRealnameAuthVideo/"];
    BOOL isDirectory = NO;
    BOOL needCreateDirectory = NO;
    BOOL directoryExist = [[NSFileManager defaultManager] fileExistsAtPath:cachePath isDirectory:&isDirectory];
    NSError *error = nil;
    if (directoryExist) {
        if (!isDirectory) {
            [[NSFileManager defaultManager] removeItemAtPath:cachePath error:&error];
            needCreateDirectory = YES;
        }
    } else {
        needCreateDirectory = YES;
    }
    if (error) {
        return nil;
    }
    if (needCreateDirectory) {
        [[NSFileManager defaultManager] createDirectoryAtPath:cachePath withIntermediateDirectories:YES attributes:nil error:&error];
    }
    if (error) {
        return nil;
    } else {
        return cachePath;
    }
}

- (void)invokeJSWithFunctionName:(NSString*)functionName
                      parameters:(NSDictionary*)tParameters
                     finishBlock:(JavaScriptCompletionBlock)block
{
    NSString *jsString  = [NSString stringWithFormat:@";window.%@ && %@(%@);",functionName, functionName,[tParameters tt_JSONRepresentation]];
    
    if([NSThread isMainThread])
    {
        [self.jsWebView evaluateJavaScriptFromString:jsString completionBlock:block];
    }
    else
    {
        dispatch_sync(dispatch_get_main_queue(), ^{
            [self.jsWebView evaluateJavaScriptFromString:jsString completionBlock:block];
        });
    }
}

#pragma private Method
- (void)imagePickerControllerUserDidCaptureItem:(NSNotification *)notification {
    if (!self.currentPicker) {
        return;
    }
    
    if (self.currentPicker.sourceType != UIImagePickerControllerSourceTypeCamera) {
        return;
    }
    
    self.stashOverlayView = self.currentPicker.cameraOverlayView;
    self.currentPicker.cameraOverlayView = nil;
}

- (void)imagePickerControllerUserDidRejectItem:(NSNotification *)notification {
    if (!self.currentPicker) {
        return;
    }
    
    if (self.currentPicker.sourceType != UIImagePickerControllerSourceTypeCamera) {
        return;
    }
    
    self.currentPicker.cameraOverlayView = self.stashOverlayView;
    self.stashOverlayView = nil;
}

- (void)updateStatusBarHidden:(BOOL)hidden animated:(BOOL)animted
{
    if ([TTDeviceHelper OSVersionNumber] < 10){
        [[UIApplication sharedApplication] setStatusBarHidden:hidden withAnimation:animted];
    }
}

- (UIView *)overlayViewWithType:(TTRealnameAuthOverlayViewType)type {
    UIView *overlayView = nil;
    CGRect frame = [UIScreen mainScreen].bounds;
    switch(type) {
        case TTRealnameAuthOverlayViewTypeIDCard:
            overlayView = [[TTRealnameAuthIDCradOverlayerView alloc] initWithFrame:frame isBack:NO];
            break;
        case TTRealnameAuthOverlayViewTypeIDCardBack:
            overlayView = [[TTRealnameAuthIDCradOverlayerView alloc]  initWithFrame:frame isBack:YES];
            break;
        case TTRealnameAuthOverlayViewTypePeopleOutline:
            overlayView = [[TTRealnameAuthPeopleOutlineOverlayerView alloc] initWithFrame:frame];
            break;
        default:
            break;
    }
    
    return overlayView;
}
@end

