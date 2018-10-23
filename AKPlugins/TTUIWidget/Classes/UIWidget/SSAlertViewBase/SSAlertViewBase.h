//
//  SSAlertViewBase.h
//  Article
//
//  Created by Zhang Leonardo on 13-3-7.
//
//

#import <UIKit/UIKit.h>
#import "SSViewBase.h"
#import "TTBaseMacro.h"

@interface SSAlertViewBase : SSViewBase
/*
 * 如果要使用动画，将子view添加到该view上
 */
@property(nonatomic, retain)UIView * contentBaseView;

- (void)showOnWindow:(UIWindow *)window;
//通常iphone调用，如果是ipad再UIPopoverViewController中，不掉用，否则为类似iphone的行为
- (void)showOnViewController:(UIViewController *)controller;
//通常iphone调用，如果是ipad再UIPopoverViewController中，不掉用，否则为类似iphone的行为
- (void)dismissWithAnimation:(BOOL)animation;

#pragma mark -- protected
//消失动画结束后,将调用该方法
- (void)dismissDone;

@end
