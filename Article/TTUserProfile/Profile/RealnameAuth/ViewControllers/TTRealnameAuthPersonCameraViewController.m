//
//  TTRealnameAuthPersonCameraViewController.m
//  Article
//
//  Created by lizhuoli on 16/12/19.
//
//

#import "TTRealnameAuthPersonCameraViewController.h"
#import "TTRealnameAuthViewController.h"
#import "TTRealnameAuthModel.h"
#import "TTRealnameAuthCameraView.h"

#import "UIImage+Normalization.h"
#import "TTRealnameAuthMacro.h"


@interface TTRealnameAuthPersonCameraViewController ()

@property (nonatomic, strong) TTRealnameAuthViewModel *viewModel;
@property (nonatomic, strong) TTRealnameAuthCameraView *cameraView;

@end

@implementation TTRealnameAuthPersonCameraViewController

- (void)dealloc
{
    LOGD(@"%@", @"TTRealnameAuthPersonCameraViewController dealloc");
}

- (instancetype)initWithViewModel:(TTRealnameAuthViewModel *)viewModel
{
    self = [super initWithType:TTCameraDetectionTypeFace];
    if (self) {
        _viewModel = viewModel;
        
        self.defaultVideoOrientation = AVCaptureVideoOrientationPortrait;
        self.defaultDevicePosition = AVCaptureDevicePositionFront;
        
        // Face detector setting
        NSMutableDictionary *detectorOptions = [NSMutableDictionary dictionaryWithCapacity:1];
        detectorOptions[CIDetectorAccuracy] = CIDetectorAccuracyHigh; // 高精度
        [self setupDetectorOptions:detectorOptions];
        NSMutableDictionary *imageOptions = [NSMutableDictionary dictionaryWithCapacity:1];
        imageOptions[CIDetectorImageOrientation] = @(6); // 识别的视频流均为横屏模式
        [self setupDetectorImageOptions:imageOptions];
        
        self.delegate = self;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupCamera];
    [self setupPreviewLayerWithFrame:[UIScreen mainScreen].bounds];
    [self setupViewsWithModel:self.viewModel.model];
    
    self.cameraView.bottomView.captureButton.enabled = NO;
    self.cameraView.bottomView.flipButton.enabled = self.currentDevicePosition != AVCaptureDevicePositionUnspecified;
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
    BOOL dismissFlag = self.viewModel.model.dismissFlag;
    
    [self captureWithComplectionBlock:^(UIImage *image, NSError *error) {
        TTRealnameAuthModel *model = [TTRealnameAuthModel new];
        if (!error) {
            image = [self croppedPersonImageWithImage:image];
            model.state = TTRealnameAuthStatePersonSubmit;
            model.personImage = image;
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

- (void)flipButtonTouched:(UIButton *)sender
{
    self.cameraView.bottomView.flipButton.enabled = NO;
    [self toggleCameraWithCallback:^(BOOL success) {
        self.cameraView.bottomView.flipButton.enabled = YES;
    }];
}

#pragma mark - TTCameraDetectorDelegate delegate
- (void)didDetectSuccess:(BOOL)success withFeatures:(NSArray<CIFeature *> *)features ofImage:(UIImage *)image
{
    if (success && features && features.count == 1) { // 识别一张人脸
        CIFeature *obj = features[0];
        if (obj.type == CIFeatureTypeFace) {
            // 调参数，只有当识别的人脸的Rect，位于人像图轮廓对应的内边距左右为76pt，下边距53pt。才认为识别
            CGRect rawOverlayRect = self.cameraView.overlayView.frame; // 竖屏拍摄，overLay不需要旋转
            CGRect rawFeatureRect = obj.bounds; // 竖屏拍摄，feature需要旋转
            rawFeatureRect = CGRectMake(rawFeatureRect.origin.y, rawFeatureRect.origin.x, rawFeatureRect.size.height, rawFeatureRect.size.width);
            
            CGSize imageSize = image.size; // 此时为@1x的size
            CGFloat H = [UIScreen mainScreen].bounds.size.height; // 注意，此时为竖屏拍摄，高宽不对换
            CGFloat W = [UIScreen mainScreen].bounds.size.width;
            
            CGFloat HRatio = rawOverlayRect.size.height / kPersonOverlayImageHeight;
            CGFloat WRatio = rawOverlayRect.size.width / kPersonOverlayImageWidth;
            
            CGRect overlayRect = CGRectMake(CGRectGetMinX(rawOverlayRect) + kPersonOverlayImageLeft * WRatio, CGRectGetMinY(rawOverlayRect), (kPersonOverlayImageWidth - kPersonOverlayImageLeft * 2) * WRatio, (kPersonOverlayImageHeight - kPersonOverlayImageBottom) * HRatio);
            
            CGRect featureRect = CGRectMake(rawFeatureRect.origin.x * W / imageSize.width, rawFeatureRect.origin.y * H / imageSize.height, rawFeatureRect.size.width * W / imageSize.width, rawFeatureRect.size.height * H / imageSize.height);
            
            if (CGRectContainsRect(CGRectInset(overlayRect, -50, -50), featureRect)) {
                if (self.cameraView.bottomView.captureButton.enabled && self.cameraView.toastView.hidden) {
                    return;
                }
                self.cameraView.bottomView.captureButton.enabled = YES; // 启用拍照
                self.cameraView.toastView.hidden = YES;
                return;
            }
        }
    }
    
    if (!self.cameraView.bottomView.captureButton.enabled && !self.cameraView.toastView.hidden) {
        return;
    }
    self.cameraView.bottomView.captureButton.enabled = NO; // 禁用拍照
    self.cameraView.toastView.hidden = NO;
}

- (UIImage *)croppedPersonImageWithImage:(UIImage *)image
{
    CGFloat height = image.size.width * 4 / 3;
    CGRect cropRect = CGRectMake(0, 0, image.size.width, height);
    
    return [image croppedImageWithFrame:cropRect];
}

@end
