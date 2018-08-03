//
//  TTPushAlertManager.m
//  Article
//
//  Created by liuzuopeng on 21/07/2017.
//
//

#import "TTPushAlertManager.h"
#import "ExploreMovieView.h"
#import "TTVPlayVideo.h"
#import <TTKeyboardListener.h>
#import "TTInAppPushSettings.h"
#import <TTAccountLoginManager.h>
#import <TTPhotoScrollViewController.h>
//#import "FRPhotoBrowserViewController.h"
#import <TTDialogDirector/TTDialogDirector.h>



NSString * const TTStrongPushHideOnlyResultKey = @"hide_result";
NSString * const TTStrongPushNotificationWillShowNotification = @"TTStrongPushNotificationWillShowNotification";
NSString * const TTStrongPushNotificationDidShowNotification  = @"TTStrongPushNotificationDidShowNotification";
NSString * const TTStrongPushNotificationWillHideNotification = @"TTStrongPushNotificationWillHideNotification";
NSString * const TTStrongPushNotificationDidHideNotification  = @"TTStrongPushNotificationDidHideNotification";

@implementation TTPushAlertManager

static TTPushWeakAlertPageType s_currentPageType = TTPushWeakAlertPageTypeNone;

/** 进入feed页 */
+ (void)enterFeedPage:(TTPushWeakAlertPageType)pageType
{
    s_currentPageType = pageType;
    
    if (s_currentPageType != TTPushWeakAlertPageTypeNone) {
        [self.class showWeakAlertLocationDialog];
    }
}

/** 退出feed页 */
+ (void)leaveFeedPage:(TTPushWeakAlertPageType)pageType
{
    s_currentPageType = TTPushWeakAlertPageTypeNone;
}

+ (void)showWeakAlertLocationDialog
{
    [TTDialogDirector showLocationDialogForKey:@"weak_push_alert@loc.feed"];
}

#pragma mark - show

+ (id<TTPushAlertViewProtocol>)showPushAlertViewWithModel:(TTPushAlertModel *)aModel
                                                  urgency:(TTPushAlertUrgency)urgency
                                              didTapBlock:(TTPushAlertDismissBlock)didTaphandler
                                            willHideBlock:(TTPushAlertDismissBlock)willHideHandler
                                             didHideBlock:(TTPushAlertDismissBlock)didHideHandler
{
    if (!aModel) return nil;
    
    if (urgency == TTPushAlertImportance) {
        TTStrongPushAlertView *strongPushAlert = [[TTStrongPushAlertView alloc] initWithAlertModel:aModel willHideBlock:nil didHideBlock:nil];
        strongPushAlert.shouldAutorotate = YES;
        strongPushAlert.didTapHandler = didTaphandler;
        strongPushAlert.willHideHandler = ^(NSInteger hideReason) {
            if (willHideHandler) {
                willHideHandler(hideReason);
            }
            
            BOOL hideOnly = !(TTStrongAlertHideTypeTapOk == hideReason || TTStrongAlertHideTypeTapContent == hideReason);
            NSMutableDictionary *mutUserInfo = [NSMutableDictionary dictionaryWithCapacity:1];
            [mutUserInfo setValue:@(hideOnly) forKey:TTStrongPushHideOnlyResultKey];
            [[NSNotificationCenter defaultCenter] postNotificationName:TTStrongPushNotificationWillHideNotification object:nil userInfo:mutUserInfo];
        };
        
        __weak typeof(strongPushAlert) weakImportantPushAlert = strongPushAlert;
        strongPushAlert.didHideHandler = ^(NSInteger hideReason) {
            if (didHideHandler) {
                didHideHandler(hideReason);
            }
            
            BOOL hideOnly = !(TTStrongAlertHideTypeTapOk == hideReason || TTStrongAlertHideTypeTapContent == hideReason);
            NSMutableDictionary *mutUserInfo = [NSMutableDictionary dictionaryWithCapacity:1];
            [mutUserInfo setValue:@(hideOnly) forKey:TTStrongPushHideOnlyResultKey];
            [[NSNotificationCenter defaultCenter] postNotificationName:TTStrongPushNotificationDidHideNotification object:nil userInfo:mutUserInfo];
            
            [TTDialogDirector dequeueDialog:weakImportantPushAlert];
        };
        
        [TTDialogDirector showInstantlyDialog:strongPushAlert shouldShowMe:^BOOL(BOOL * _Nullable keepAlive) {
            BOOL meetCondition = [self.class meetsStrongAlertCondition];
            if (!meetCondition) {
                *keepAlive = YES;
            }
            return meetCondition;
        } showMe:^(id  _Nonnull dialogInst) {
            if (strongPushAlert) {
                [[NSNotificationCenter defaultCenter] postNotificationName:TTStrongPushNotificationWillShowNotification object:nil];
            }
            
            [strongPushAlert showWithAnimated:YES completion:^{
                [[NSNotificationCenter defaultCenter] postNotificationName:TTStrongPushNotificationDidShowNotification object:nil];
            }];
        } hideForcedlyMe:nil];
        
        return strongPushAlert;
    }
    
    // 非重要弹窗
    TTWeakPushAlertView *weakAlertView = [[TTWeakPushAlertView alloc] initWithAlertModel:aModel willHideBlock:nil didHideBlock:nil];
    weakAlertView.shouldAutorotate = YES;
    weakAlertView.didTapHandler = didTaphandler;
    weakAlertView.willHideHandler = ^(NSInteger hideReason) {
        if (willHideHandler) {
            willHideHandler(hideReason);
        }
    };
    __weak typeof(weakAlertView) weakUnimportantPushAlert = weakAlertView;
    weakAlertView.didHideHandler = ^(NSInteger hideReason) {
        if (didHideHandler) {
            didHideHandler(hideReason);
        }
        
        NSTimeInterval delay = 0.1;
        if (hideReason == TTStrongAlertHideTypeTapOk ||
            hideReason == TTStrongAlertHideTypeTapContent) {
            delay = 0.25;
        }
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [TTDialogDirector dequeueDialog:weakUnimportantPushAlert];
        });
    };
    
    [TTDialogDirector enqueueDialog:weakAlertView atLocation:@"weak_push_alert@loc.feed" shouldShowMe:^BOOL(BOOL * _Nullable keepAlive) {
        BOOL meetCondition = [self.class meetsWeakAlertCondition];
        if (!meetCondition) {
            *keepAlive = YES;
        }
        return meetCondition;
    } showMe:^(id  _Nonnull dialogInst) {
        if ([self.class isKeyboardShowing])  {
            weakAlertView.slipIntoDirection = TTWeakPushSlideDirectionFromTop;
        } else {
            weakAlertView.slipIntoDirection = [TTInAppPushSettings weakAlertAnimationSlideIntoDirection];
        }
        [weakAlertView show];
    } hideForcedlyMe:^(id  _Nonnull dialogInst) {
        [weakAlertView hide];
    }];
    
    if ([self.class meetsWeakAlertCondition]) {
        [self.class showWeakAlertLocationDialog];
    }
    
    return weakAlertView;
}

#pragma mark - conditions helper

+ (BOOL)meetsStrongAlertCondition
{
    if ([self.class isFullScreenVideoPlaying]) {
        return NO;
    }
    if ([self.class isFullScreenPhotoBrowsering]) {
        return NO;
    }
    if ([TTAccountLoginManager isLoginAlertShowing]) {
        return NO;
    }
    if ([TTStrongPushAlertView isShowing]) {
        return NO;
    }
    if ([TTWeakPushAlertView isShowing]) {
        return NO;
    }
    return YES;
}

+ (BOOL)meetsWeakAlertCondition
{
    if ([self.class isFullScreenVideoPlaying]) {
        return NO;
    }
    if ([self.class isFullScreenPhotoBrowsering]) {
        return NO;
    }
    if ([TTAccountLoginManager isLoginAlertShowing]) {
        return NO;
    }
    if ([TTStrongPushAlertView isShowing]) {
        return NO;
    }
    if ([TTWeakPushAlertView isShowing]) {
        return NO;
    }
    
    if ([TTInAppPushSettings weakAlertShowPageScope] == 1) {
        return YES;
    }
    if (TTPushWeakAlertPageTypeNone != s_currentPageType) {
        return YES;
    }
    
    return NO;
}

+ (BOOL)isFullScreenVideoPlaying
{
    if ([ExploreMovieView isFullScreen]) {
        return YES;
    }
    
    if ([[TTVPlayVideo currentPlayingPlayVideo].player.context isFullScreen] ||
        [[TTVPlayVideo currentPlayingPlayVideo].player.context isRotating]) {
        return YES;
    }
    
    NSArray<UIView *> *subViewsInWindow = [[UIApplication sharedApplication].delegate.window subviews];
    if (!subViewsInWindow) return NO;
    
    for (UIView *aView in subViewsInWindow) {
        if ([aView isKindOfClass:[ExploreMovieView class]] || [aView isKindOfClass:[TTVPlayVideo class]]) {
            return YES;
        }
    }
    return NO;
}

+ (BOOL)isFullScreenPhotoBrowsering
{
//    if ([FRPhotoBrowserViewController photoBrowserAtTop]) {
//        return YES;
//    }
    if ([TTPhotoScrollViewController photoBrowserAtTop]) {
        return YES;
    }
    return NO;
}

+ (BOOL)isKeyboardShowing
{
    return ([TTKeyboardListener sharedInstance].keyboardHeight > 0 &&
            [[TTKeyboardListener sharedInstance] isVisible]);
}

+ (BOOL)newAlertEnabled
{
    return [TTInAppPushSettings newAlertEnabled];
}

@end
