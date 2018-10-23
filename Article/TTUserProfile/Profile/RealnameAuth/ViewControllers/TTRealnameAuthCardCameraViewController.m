//
//  TTRealnameAuthCardCameraViewController.m
//  Article
//
//  Created by lizhuoli on 16/12/19.
//
//

#import "TTRealnameAuthCardCameraViewController.h"
#import "TTRealnameAuthViewController.h"
#import "TTRealnameAuthModel.h"
#import "TTRealnameAuthCameraView.h"

#import "UIImage+Normalization.h"
#import "TTRealnameAuthMacro.h"
#import "TTThemedAlertController.h"


@interface TTRealnameAuthCardCameraViewController ()

@property (nonatomic, strong) TTRealnameAuthViewModel *viewModel;
@property (nonatomic, strong) TTRealnameAuthCameraView *cameraView;

@end

@implementation TTRealnameAuthCardCameraViewController

- (void)dealloc
{
    LOGD(@"%@", @"TTRealnameAuthCardCameraViewController dealloc");
}

- (instancetype)initWithViewModel:(TTRealnameAuthViewModel *)viewModel
{
    self = [super initWithType:TTCameraDetectionTypeRectangle];
    if (self) {
        _viewModel = viewModel;
        
        self.defaultVideoOrientation = AVCaptureVideoOrientationLandscapeRight;
        self.defaultDevicePosition = AVCaptureDevicePositionBack;
        
// 产品说暂时不做身份证矩形框的识别
//        NSMutableDictionary *detectorOptions = [NSMutableDictionary dictionaryWithCapacity:3];
//        detectorOptions[CIDetectorAccuracy] = CIDetectorAccuracyHigh; // 高精度
//        detectorOptions[CIDetectorAspectRatio] = @(kIDCardPhotoRatio); // 身份证矩形宽高比
//        [self setupDetectorOptions:detectorOptions];
//        
//        NSMutableDictionary *imageOptions = [NSMutableDictionary dictionaryWithCapacity:1];
//        imageOptions[CIDetectorImageOrientation] = @(6); // 识别的视频流均为横屏模式
//        [self setupDetectorImageOptions:imageOptions];
//        
//        self.delegate = self;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupCamera];
    [self setupPreviewLayerWithFrame:[UIScreen mainScreen].bounds];
    [self setupViewsWithModel:self.viewModel.model];
    
//    self.cameraView.bottomView.captureButton.enabled = NO;
#if TARGET_IPHONE_SIMULATOR
    self.view.backgroundColor = [UIColor grayColor];
    return;
#else
    [self startCamera];
#endif
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)setupViewsWithModel:(TTRealnameAuthModel *)model
{
    self.view.backgroundColor = [UIColor blackColor];
    self.cameraView = [TTRealnameAuthCameraView new];
    [self.view addSubview:self.cameraView];
    [self.cameraView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    self.cameraView.delegate = self;
    [self.cameraView setupCameraViewWithModel:self.viewModel.model];
}

- (void)updateViewsWithModel:(TTRealnameAuthModel *)model
{
    
}

- (void)dismissButtonTouched:(UIButton *)sender
{
    [self dismissSelf];
}

- (void)captureButtonTouched:(UIButton *)sender
{
    self.cameraView.bottomView.captureButton.enabled = NO; // 阻止连续拍摄
    TTRealnameAuthState state = self.viewModel.model.state;
    BOOL dismissFlag = self.viewModel.model.dismissFlag;
    
    [self captureWithComplectionBlock:^(UIImage *image, NSError *error) {
        TTRealnameAuthModel *model = [TTRealnameAuthModel new];
        if (!error) {
            CGRect overlayRect = CGRectMake(0, self.cameraView.topView.frame.size.height, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - self.cameraView.topView.frame.size.height - self.cameraView.bottomView.frame.size.height);
//            CGFloat overlayRatio = self.cameraView.overlayView.frame.size.width / self.cameraView.overlayView.frame.size.height; // 横屏
//            CGRect overlayRect = self.cameraView.overlayView.frame;
//            if (overlayRatio > kIDCardPhotoRatio) { // 显示高度不足
//                CGFloat width = CGRectGetHeight(overlayRect) * kIDCardPhotoRatio;
//                overlayRect = CGRectMake(CGRectGetMinX(overlayRect) + (CGRectGetWidth(overlayRect) - width) / 2, CGRectGetMinY(overlayRect), width, CGRectGetHeight(overlayRect));
//            } else { // 显示宽度不足
//                CGFloat height = CGRectGetWidth(overlayRect) / kIDCardPhotoRatio;
//                overlayRect = CGRectMake(CGRectGetMinX(overlayRect), CGRectGetMinY(overlayRect) + (CGRectGetHeight(overlayRect) - height) / 2, CGRectGetWidth(overlayRect), height);
//            }
            image = [self croppedPhotoImageWithImage:image rect:CGRectMake(overlayRect.origin.y, overlayRect.origin.x, overlayRect.size.height, overlayRect.size.width)];
            if (state == TTRealnameAuthStateCardForegroundCamera) {
                model.state = TTRealnameAuthStateCardForegroundInfo;
                model.foregroundImage = image;
            } else {
                model.state = TTRealnameAuthStateCardBackgroundInfo;
                model.backgroundImage = image;
            }
        } else {
            self.cameraView.bottomView.captureButton.enabled = YES; // 阻止连续拍摄
            return;
        }
        [self.viewModel setupModel:model withSender:self];
        
        UINavigationController *nav = [TTUIResponderHelper topNavigationControllerFor:self];
        SSViewControllerBase<RealnameAuthViewDelegate> *parentVC = (SSViewControllerBase<RealnameAuthViewDelegate> *)nav.viewControllers.lastObject;
        TTRealnameAuthViewModel *viewModel = self.viewModel;
        
        if (dismissFlag && parentVC && [parentVC respondsToSelector:@selector(updateViewsWithModel:)]) {
            [parentVC updateViewsWithModel:self.viewModel.model];
            self.viewModel.model.dismissFlag = NO;
        }
        
        [self stopCamera];
        [self dismissViewControllerAnimated:YES completion:^{
            if (!dismissFlag) { // 点击"重拍"进入拍照流程，更新图片不跳转
                TTRealnameAuthViewController *vc = [[TTRealnameAuthViewController alloc] initWithViewModel:viewModel];
                [nav pushViewController:vc animated:YES];
            }
        }];
    }];
}

- (void)flashButtonTouched:(UIButton *)sender
{
    [self toggleFlashMode:sender.tag];
}

//#pragma mark -#pragma mark - TTCameraDetectorDelegate delegate
//- (void)didDetectFeatures:(NSArray<CIFeature *> *)features ofImage:(UIImage *)image
//{
//    if (features && features.count == 1) {
//        CIFeature *obj = features[0];
//        if (obj.type == CIFeatureTypeRectangle) {
//            // 调参数，只有当识别的矩形，在显示的身份证轮廓图外边距60pt以内，内边距60pt以外才认为识别
//            CGRect rawOverlayRect = self.cameraView.overlayView.frame;
//            CGRect overlayRect = CGRectMake(rawOverlayRect.origin.y, rawOverlayRect.origin.x, rawOverlayRect.size.height, rawOverlayRect.size.width); // 轮廓图Rect旋转到横屏
//            CGRect rawFeatureRect = obj.bounds;
//            CGSize imageSize = image.size;
//            CGFloat H = [UIScreen mainScreen].bounds.size.width; // 注意，此时为横屏拍摄，高宽对换
//            CGFloat W = [UIScreen mainScreen].bounds.size.height;
//            
//            CGRect featureRect = CGRectMake(rawFeatureRect.origin.x * W / imageSize.width, rawFeatureRect.origin.y * H / imageSize.height, rawFeatureRect.size.width * W / imageSize.width, rawFeatureRect.size.height * H / imageSize.height);
//            
//            if (CGRectContainsRect(CGRectInset(overlayRect, -60, -60), featureRect) && CGRectContainsRect(featureRect, CGRectInset(overlayRect, 60, 60))) {
//                if (self.cameraView.bottomView.captureButton.enabled && self.cameraView.toastView.hidden) {
//                    return;
//                }
//                self.cameraView.bottomView.captureButton.enabled = YES; // 启用拍照
//                self.cameraView.toastView.hidden = YES;
//                return;
//            }
//        }
//    }
//    if (!self.cameraView.bottomView.captureButton.enabled && !self.cameraView.toastView.hidden) {
//        return;
//    }
//    
//    self.cameraView.bottomView.captureButton.enabled = NO; // 禁用拍照
//    self.cameraView.toastView.hidden = NO;
//}

- (UIImage *)croppedPhotoImageWithImage:(UIImage *)image rect:(CGRect)rect
{
    if (!image || CGSizeEqualToSize(image.size, rect.size)) {
        return image;
    }
    
    // 浮层 : 屏幕 == 变换后的浮层 : 图片
    CGFloat H = [UIScreen mainScreen].bounds.size.width; // 横屏
    CGFloat W = [UIScreen mainScreen].bounds.size.height; // 横屏
    CGFloat w1 = image.size.width;
    CGFloat h1 = image.size.height;
    CGFloat w2 = rect.size.width;
    CGFloat h2 = rect.size.height;
    CGFloat x = rect.origin.x;
    CGFloat y = rect.origin.y;
    
    CGFloat cropW = w1 * w2 / W;
    CGFloat cropH = h1 * h2 / H;
    CGFloat cropX = x * w1 / W;
    CGFloat cropY = y * h1 / H;
    
    CGRect cropRect = CGRectMake(cropX, cropY, cropW, cropH);
    
    return [image croppedImageWithFrame:cropRect];
}

@end
