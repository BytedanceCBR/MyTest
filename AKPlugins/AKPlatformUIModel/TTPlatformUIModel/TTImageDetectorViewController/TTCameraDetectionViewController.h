//
//  TTCameraDetectionViewController.h
//  Article
//
//  Created by lizhuoli on 16/12/19.
//
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "SSViewControllerBase.h"
#import "TTCameraDetectionDelegate.h"

typedef NS_ENUM(NSInteger, TTCameraDetectionType) {
    TTCameraDetectionTypeNone, // 不进行识别
    TTCameraDetectionTypeFace NS_AVAILABLE(10_7, 5_0), // 人脸
    TTCameraDetectionTypeQRCode NS_AVAILABLE(10_10, 8_0), // QR码
    TTCameraDetectionTypeText NS_AVAILABLE(10_11, 9_0), // 文本
    TTCameraDetectionTypeRectangle NS_AVAILABLE(10_10, 8_0), // 矩形
}; // 暂时使用了CIDetector，注意兼容性。只有设置了setupDetectorOptions才会开启识别

@interface TTCameraDetectionViewController : SSViewControllerBase <AVCaptureVideoDataOutputSampleBufferDelegate>

/** 处理视频流，或者识别图像得到的Features的代理，均dispatch_async到主线程 */
@property (nonatomic, weak) id<TTCameraDetectionDelegate> delegate;
/** 设置启动时视频录制方向，默认为垂直。如果已启动并需要重新设置，使用toggleVideoOrientation: */
@property (nonatomic, assign) AVCaptureVideoOrientation defaultVideoOrientation;
/** 设置启动时调用的摄像头，默认为后置。如果已启动并需要重新设置，使用toggleCamera */
@property (nonatomic, assign) AVCaptureDevicePosition defaultDevicePosition;
/** 设置启动时闪关灯模式，默认为Auto。如果已启动并需要重新设置，使用toggleFlashMode: */
@property (nonatomic, assign) AVCaptureFlashMode defaultFlashmode;
/** 设置是否自动保存拍摄的照片到相册，默认为NO */
@property (nonatomic, assign) BOOL saveToAlbum;
/** 设置拍摄时（不影响识别过程），是否自动根据设备当前方向拍摄该方向上的照片，而不是根据currentVideoOrientation来拍摄，默认为NO */
@property (nonatomic, assign) BOOL autoVideoOrientation;

/** 状态，是否就绪 */
@property (nonatomic, assign, readonly) BOOL hasInitialCamera;
/** 当前拍摄到的照片，如果未拍摄为nil */
@property (nonatomic, strong, readonly) UIImage *currentImage;
/** 当前的摄像录制方向 */
@property (nonatomic, assign, readonly) AVCaptureVideoOrientation currentVideoOrientation;
/** 当前的摄像头 */
@property (nonatomic, assign, readonly) AVCaptureDevicePosition currentDevicePosition;
/** 当前的闪光灯模式 */
@property (nonatomic, assign, readonly) AVCaptureFlashMode currentFlashMode;
/** 当前的视频帧率，影响PreviewLayer显示和所有视频输出（照相）帧率 */
@property (nonatomic, assign, readonly) CMTime currentFrameDuration;
/** 当前的采样频率，指的每多少帧回调一次，默认不限制，0和1都无效 */
@property (nonatomic, assign, readonly) NSUInteger currentSamplingRate;

- (instancetype)initWithType:(TTCameraDetectionType)type;

/** 设置相机初始设置，如果设置有default参数，在设置完成后调用 */
- (void)setupCamera;
/** 通过Frame设置预览视频流的Background Layer */
- (void)setupPreviewLayerWithFrame:(CGRect)frame;
/** 通过CIDetector的参数，初始化Detecotr，想要使用识别必须调用此初始化，必须在setupCamera之前调用 */
- (void)setupDetectorOptions:(NSDictionary *)detectorOptions;
/** 设置CIDetector识别图像Feature用到的ImageOptions，建议必填图像的方向 */
- (void)setupDetectorImageOptions:(NSDictionary *)imageOptions;
/** 设置视频帧率，同时也会影响PreviewLayer的显示帧率 */
- (void)setupFrameDuration:(CMTime)frameDuration;
/** 设置采样频率，仅影响回调的频率 */
- (void)setupSamplingRate:(NSUInteger)samplingRate;
/** 启动照相（previewLayer会显示视频预览），若未设置初始设置会自动配置 */
- (void)startCamera;
/** 停止照相（previewLayer会停止视频预览），注意请在拍摄完及时关闭，比如dismiss前（默认的viewWillDisappear方法会自动停止），否则额外的delegate回调可能会导致不确定的问题 */
- (void)stopCamera;
/** 手动拍照，回调中可以拿到照片 */
- (void)captureWithComplectionBlock:(void (^)(UIImage *, NSError *))block;
/** 手动切换摄像录制方向 */
- (void)toggleVideoOrientation:(AVCaptureVideoOrientation)videoOrientation;
/** 手动切换前后置摄像头，切换成功时callback中的参数为YES */
- (void)toggleCameraWithCallback:(void(^)(BOOL))callback;
/** 手动设置闪关灯模式 */
- (void)toggleFlashMode:(AVCaptureFlashMode)flashMode;

@end
