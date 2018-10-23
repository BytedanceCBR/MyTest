//
//  TTRealnameAuthViewController.h
//  Article
//
//  Created by lizhuoli on 16/12/18.
//
//

#import "SSViewControllerBase.h"
#import "TTRealnameAuthViewModel.h"
#import "TTRealnameAuthModel.h"
#import "TTRealnameAuthDelegate.h"
#import "TTUserProfileInputView.h"

@interface TTRealnameAuthViewController : SSViewControllerBase <RealnameAuthViewDelegate, AuthButtonTouchDelegate, UIViewControllerErrorHandler, TTUserProfileInputViewDelegate>

- (instancetype)initWithViewModel:(TTRealnameAuthViewModel *)viewModel;
- (void)setupViewsWithModel:(TTRealnameAuthModel *)model;

@end
