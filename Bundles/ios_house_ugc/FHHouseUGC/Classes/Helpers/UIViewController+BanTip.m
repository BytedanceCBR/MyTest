//
//  UIViewController+BanTip.m
//  FHHouseUGC
//
//  Created by wangzhizhou on 2020/3/27.
//

#import "UIViewController+BanTip.h"
#import <objc/runtime.h>
#import "SSAPNsAlertManager.h"
#import "FHBubbleTipManager.h"

@implementation UIViewController(BanTip)

- (void)banTip:(BOOL)isBan {
    [self banFHMessageTipBubble:isBan];
    [self banInAppRemotePushTip:isBan];
}

- (BOOL)isSavedFhBubbleTipManagerCanShowStatus {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

- (void)setIsSavedFHBubbleTipManagerCanShowStatus:(BOOL)isSaved {
    objc_setAssociatedObject(self, @selector(isSavedFhBubbleTipManagerCanShowStatus), @(isSaved), OBJC_ASSOCIATION_ASSIGN);
}

- (BOOL)fhBubbleTipManagerCanShow {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

- (void)setFHBubbleTipManagerCanShow:(BOOL)fh_bubble_tip_manager_can_show {
    objc_setAssociatedObject(self, @selector(fhBubbleTipManagerCanShow), @(fh_bubble_tip_manager_can_show), OBJC_ASSOCIATION_ASSIGN);
}

- (void)banFHMessageTipBubble:(BOOL)isBan {
    if(isBan) {
        [self setFHBubbleTipManagerCanShow:[FHBubbleTipManager shareInstance].canShowTip];
        [self setIsSavedFHBubbleTipManagerCanShowStatus:YES];
        
        [FHBubbleTipManager shareInstance].canShowTip = NO;
    }
    else {
        
        if([self isSavedFhBubbleTipManagerCanShowStatus]) {
            [FHBubbleTipManager shareInstance].canShowTip = [self fhBubbleTipManagerCanShow];
        }
    }
}

- (BOOL)isSavedInAppRemotePushTipCanShowStatus {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

- (void)setIsSavedInAppRemotePushTipCanShowStatus:(BOOL)isSaved {
    objc_setAssociatedObject(self, @selector(isSavedInAppRemotePushTipCanShowStatus), @(isSaved), OBJC_ASSOCIATION_ASSIGN);
}

- (BOOL)inAppRemotePushTipCanShow {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

- (void)setInAppRemotePushTipCanShow:(BOOL)in_app_remote_push_tip_can_show {
    objc_setAssociatedObject(self, @selector(inAppRemotePushTipCanShow), @(in_app_remote_push_tip_can_show), OBJC_ASSOCIATION_ASSIGN);
}

- (void)banInAppRemotePushTip:(BOOL)isBan {
    if(isBan) {
        [self setInAppRemotePushTipCanShow:!kFHInAppPushTipsHidden];
        [self setIsSavedInAppRemotePushTipCanShowStatus:YES];
        
        kFHInAppPushTipsHidden = YES;
    }
    else {
        
        if([self isSavedInAppRemotePushTipCanShowStatus]) {
            kFHInAppPushTipsHidden = ![self inAppRemotePushTipCanShow];
        }
    }
}
@end
