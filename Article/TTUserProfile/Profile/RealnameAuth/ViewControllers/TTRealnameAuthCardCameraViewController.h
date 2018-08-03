//
//  TTRealnameAuthCardCameraViewController.h
//  Article
//
//  Created by lizhuoli on 16/12/19.
//
//

#import <UIKit/UIKit.h>
#import "TTCameraDetectionViewController.h"
#import "TTRealnameAuthViewModel.h"
#import "TTRealnameAuthDelegate.h"

@interface TTRealnameAuthCardCameraViewController : TTCameraDetectionViewController <RealnameAuthViewDelegate, CameraButtonTouchDelegate>

- (instancetype)initWithViewModel:(TTRealnameAuthViewModel *)viewModel;
- (void)setupViewsWithModel:(TTRealnameAuthModel *)model;

@end
