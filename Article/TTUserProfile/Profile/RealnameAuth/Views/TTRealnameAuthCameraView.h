//
//  TTRealnameAuthCameraView.h
//  Article
//
//  Created by lizhuoli on 16/12/19.
//
//

#import <UIKit/UIKit.h>
#import "TTRealnameAuthModel.h"
#import "TTRealnameAuthDelegate.h"
#import "TTRealnameAuthButton.h"

@interface TTRealnameAuthCameraBottomView : UIView

@property (nonatomic, strong) TTRealnameAuthCaptureButton *captureButton;
@property (nonatomic, strong) SSThemedButton *flipButton;

@end

@interface TTRealnameAuthCameraTopView : UIView
@end

@interface TTRealnameAuthCameraOverlayView : UIImageView
@end

@interface TTRealnameAuthCameraToastView : UIView
@end

@interface TTRealnameAuthCameraView : UIView

@property (nonatomic, weak) id<CameraButtonTouchDelegate> delegate;
@property (nonatomic, strong) UIImageView *overlayView;
@property (nonatomic, strong) TTRealnameAuthCameraTopView *topView;
@property (nonatomic, strong) TTRealnameAuthCameraBottomView *bottomView;
@property (nonatomic, strong) UIView *toastView;

- (void)setupCameraViewWithModel:(TTRealnameAuthModel *)model;

@end
