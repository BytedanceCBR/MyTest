//
//  TTNewPanelController+ShareAd.m
//  Article
//
//  Created by yin on 2017/3/21.
//
//

#import "TTNewPanelController+ShareAd.h"
#import <objc/runtime.h>
#import "SSThemed.h"
#import "TTAdConstant.h"
#import "TTAdShareBoardView.h"
#import "TTAdManager.h"

#define kShareAdHeight 55*kTTAdShareScreenRate

static char *const TTShareAdViewKeyName = "TTShareAdViewKeyName";

@implementation TTNewPanelController (ShareAd)

+ (void)load
{
    Method showMethod = class_getInstanceMethod(self, @selector(show));
    Method shareShowMethod = class_getInstanceMethod(self, @selector(shareAd_show));
    
    [self swizzelClass:[self class] originalSelector:@selector(show) originalMethod:showMethod swizzledSelector:@selector(shareAd_show) swizzelMethod:shareShowMethod];
    
    
    Method hideMethod = class_getInstanceMethod(self, NSSelectorFromString(@"cancelWithBlock:animation:"));
    Method shareHideMethod = class_getInstanceMethod(self, @selector(shareAd_hideWithBlock:animation:));
    [self swizzelClass:[self class] originalSelector:NSSelectorFromString(@"cancelWithBlock:animation:") originalMethod:hideMethod swizzledSelector:@selector(shareAd_hideWithBlock:animation:) swizzelMethod:shareHideMethod];
    
    
    Method changeMethod = class_getInstanceMethod(self, NSSelectorFromString(@"deviceOrientationDidChange"));
    Method shareChangeMethod = class_getInstanceMethod(self, @selector(shareAd_deviceOrientationDidChange));
    [self swizzelClass:[self class] originalSelector:NSSelectorFromString(@"deviceOrientationDidChange") originalMethod:changeMethod swizzledSelector:@selector(shareAd_deviceOrientationDidChange)swizzelMethod:shareChangeMethod];
    
    
    
}

+ (void)swizzelClass:(Class)class originalSelector:(SEL)originalSelector originalMethod:(Method)originalMethod swizzledSelector:(SEL)swizzledSelector swizzelMethod:(Method)swizzledMethod
{
    BOOL didAddMethod =
    class_addMethod(class,
                    originalSelector,
                    method_getImplementation(swizzledMethod),
                    method_getTypeEncoding(swizzledMethod));
    
    if (didAddMethod) {
        class_replaceMethod(class,
                            swizzledSelector,
                            method_getImplementation(originalMethod),
                            method_getTypeEncoding(originalMethod));
    } else {
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}

- (void)shareAd_show
{
    Ivar ivar_maskView = class_getInstanceVariable([self class], "_maskView");
    SSThemedView* maskView = object_getIvar(self, ivar_maskView);
    
    Ivar ivar_backView = class_getInstanceVariable([self class], "_backView");
    SSThemedView* backView = object_getIvar(self, ivar_backView);
    
    TTAdShareBoardView* shareView = [TTAdManager share_createShareViewFrame:CGRectMake(0, 0, backView.width, kShareAdHeight + [TTDeviceHelper ssOnePixel])];
    if (!shareView) {
        [self shareAd_show];
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
    [self shareAd_show];
}

- (void)shareAd_hideWithBlock:(void (^)(void))block animation:(BOOL)animated
{
    [self shareAd_hideWithBlock:block animation:animated];
    
    [TTAdManageInstance share_hideInPage];
    
    TTAdShareBoardView* shareView = objc_getAssociatedObject(self, TTShareAdViewKeyName);
    if (!shareView) {
        return;
    }
    if (animated) {
        [UIView animateWithDuration:0.3 delay:0 usingSpringWithDamping:1.0 initialSpringVelocity:10 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            shareView.bottom = [UIScreen mainScreen].bounds.size.height;
            shareView.alpha = 0.0f;
        } completion:^(BOOL finished) {
            shareView.hidden = YES;
        }];
    }
    else {
        shareView.hidden = YES;
    }
    
}

- (void)shareAd_deviceOrientationDidChange
{
    Ivar ivar_backWindow = class_getInstanceVariable([self class], "_backWindow");
    UIWindow * backWindow = object_getIvar(self, ivar_backWindow);
    CGRect oldBackWindowFrame = backWindow.frame;
    [self shareAd_deviceOrientationDidChange];
    if (!CGRectEqualToRect(oldBackWindowFrame, backWindow.frame)) {
        TTAdShareBoardView* shareView = objc_getAssociatedObject(self, TTShareAdViewKeyName);
        if (shareView) {
            shareView.hidden = YES;
        }
    }
}

@end
