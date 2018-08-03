//
//  TTActivityPanelController+ShareAd.m
//  Article
//
//  Created by 延晋 张 on 2017/2/3.
//
//

#import "TTActivityPanelController+ShareAd.h"
#import <objc/runtime.h>
#import <TTThemed/SSThemed.h>
#import <TTBaseLib/TTDeviceHelper.h>
#import <TTBaseLib/UIViewAdditions.h>
#import "TTAdConstant.h"
#import "TTAdShareBoardView.h"
#import "TTAdShareManager.h"

#define kShareAdHeight 55*kTTAdShareScreenRate

extern char *const TTShareAdViewKeyName;

@implementation TTActivityPanelController (ShareAd)

+ (void)load
{
    Method showMethod = class_getInstanceMethod(self, @selector(show));
    Method shareShowMethod = class_getInstanceMethod(self, @selector(shareAd_show));
    if (showMethod && shareShowMethod) {
        method_exchangeImplementations(showMethod, shareShowMethod);
    }
    
    Method hideMethod = class_getInstanceMethod(self, NSSelectorFromString(@"cancelWithItem:"));
    Method shareHideMethod = class_getInstanceMethod(self, @selector(shareAd_cancelWithItem:));
    if (hideMethod && shareHideMethod) {
        method_exchangeImplementations(hideMethod, shareHideMethod);
    }
    
    Method rotateMethod = class_getInstanceMethod(self, NSSelectorFromString(@"applicationStautsBarDidRotate"));
    
    Method shareRotateMethod = class_getInstanceMethod(self, @selector(shareAd_applicationStautsBarDidRotate));
    if (showMethod && shareShowMethod) {
        method_exchangeImplementations(rotateMethod, shareRotateMethod);
    }
}

- (void)shareAd_show
{
    [self shareAd_show];
    
    Ivar ivar_maskView = class_getInstanceVariable([self class], "_maskView");
    SSThemedView* maskView = object_getIvar(self, ivar_maskView);
    
    Ivar ivar_backView = class_getInstanceVariable([self class], "_backView");
    SSThemedView* backView = object_getIvar(self, ivar_backView);
    
    TTAdShareBoardView* shareView = [TTAdShareManager createShareViewFrame:CGRectMake(0, 0, backView.width, kShareAdHeight + [TTDeviceHelper ssOnePixel])];
    if (!shareView) {
        return;
    }
    shareView.alpha = 0.0f;
    [maskView addSubview:shareView];
    shareView.bottom = [UIScreen mainScreen].bounds.size.height;
    objc_setAssociatedObject(self, TTShareAdViewKeyName, shareView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    CGFloat backview_height = backView.height;
    
    [UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:0.9 initialSpringVelocity:0.1 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        shareView.bottom = [UIScreen mainScreen].bounds.size.height - backview_height;
        shareView.alpha = 1.0f;
    } completion:^(BOOL finished) {
        
    }];
}

- (void)shareAd_cancelWithItem:(id<TTActivityProtocol>)activity
{
    [self shareAd_cancelWithItem:activity];
    [[TTAdShareManager sharedManager] hideInPage];
    
    TTAdShareBoardView* shareView = objc_getAssociatedObject(self, TTShareAdViewKeyName);
    if (!shareView) {
        return;
    }
    [UIView animateWithDuration:0.3 delay:0 usingSpringWithDamping:1.0 initialSpringVelocity:10 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        shareView.bottom = [UIScreen mainScreen].bounds.size.height;
        shareView.alpha = 0.0f;
    } completion:^(BOOL finished) {
        shareView.hidden = YES;
    }];    
}

- (void)shareAd_applicationStautsBarDidRotate
{
    [self shareAd_applicationStautsBarDidRotate];
    TTAdShareBoardView* shareView = objc_getAssociatedObject(self, TTShareAdViewKeyName);
    if (shareView) {
        shareView.hidden = YES;
    }
}

@end
