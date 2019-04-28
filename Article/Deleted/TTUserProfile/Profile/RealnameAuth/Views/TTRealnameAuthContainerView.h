//
//  TTRealnameAuthContainerView.h
//  Article
//
//  Created by lizhuoli on 16/12/18.
//
//

#import <UIKit/UIKit.h>
#import "SSThemed.h"
#import "TTRealnameAuthModel.h"
#import "TTRealnameAuthDelegate.h"
#import "TTRealnameAuthSubmitView.h"
#import "TTUserProfileInputView.h"

@interface TTRealnameAuthContainerView : SSThemedView

@property (nonatomic, strong) TTRealnameAuthSubmitView *submitView;
@property (nonatomic, weak) SSViewControllerBase<AuthButtonTouchDelegate, TTUserProfileInputViewDelegate> *delegate;

- (void)setupContainerViewWithModel:(TTRealnameAuthModel *)model;
- (void)updateContainerViewWithModel:(TTRealnameAuthModel *)model;

@end
