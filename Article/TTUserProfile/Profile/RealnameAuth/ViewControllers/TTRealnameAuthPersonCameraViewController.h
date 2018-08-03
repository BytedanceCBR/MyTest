//
//  TTRealnameAuthPersonCameraViewController.h
//  Article
//
//  Created by lizhuoli on 16/12/19.
//
//

#import <UIKit/UIKit.h>
#import "TTCameraDetectionViewController.h"
#import "TTRealnameAuthViewModel.h"
#import "TTRealnameAuthDelegate.h"

@interface TTRealnameAuthPersonCameraViewController : TTCameraDetectionViewController <RealnameAuthViewDelegate, CameraButtonTouchDelegate, TTCameraDetectionDelegate>

- (instancetype)initWithViewModel:(TTRealnameAuthViewModel *)viewModel;
- (void)setupViewsWithModel:(TTRealnameAuthModel *)model;

@end
