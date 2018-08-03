//
//  TTCertificationTakePhotoViewController.m
//  Article
//
//  Created by wangdi on 2017/5/16.
//
//

#import "TTCertificationTakePhotoViewController.h"
#import "TTRealnameAuthCameraView.h"
#import "UIImage+Normalization.h"

@interface TTCertificationTakePhotoViewController ()

@property (nonatomic, strong) TTRealnameAuthCameraView *cameraView;

@end

@implementation TTCertificationTakePhotoViewController

- (instancetype)init
{
    if(self = [super initWithType:TTCameraDetectionTypeRectangle]) {
        self.autoVideoOrientation = YES;
        self.defaultDevicePosition = AVCaptureDevicePositionBack;
    }
    return self;
}

- (void)setupViewsWithModel:(TTRealnameAuthModel *)model
{
    
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupSubviews];
}

- (void)setupSubviews
{
    self.view.backgroundColor = [UIColor blackColor];
    self.cameraView = [TTRealnameAuthCameraView new];
    [self.view addSubview:self.cameraView];
    [self.cameraView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    self.cameraView.delegate = self;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    [self.cameraView performSelector:@selector(setupCameraCardViewIsForeground:) withObject:[NSNumber numberWithInteger:1]];
#pragma clang diagnostic pop
    if(!self.needEdging) {
        self.cameraView.overlayView.image = nil;
        SSThemedLabel *titleLabel = (SSThemedLabel *)[self.cameraView valueForKey:@"tipLabel"];
        titleLabel.text = nil;
    }
}

- (void)captureButtonTouched:(UIButton *)sender
{
    self.cameraView.bottomView.captureButton.enabled = NO; // 阻止连续拍摄
    [self captureWithComplectionBlock:^(UIImage *image, NSError *error) {
        if (!error) {
            if(self.didFinishBlock) {
                self.didFinishBlock([image normalizedImage]);
            }
        } else {
            self.cameraView.bottomView.captureButton.enabled = YES; // 阻止连续拍摄
            return;
        }
        [self stopCamera];
        [self dismissViewControllerAnimated:YES completion:nil];
    }];
}

@end
