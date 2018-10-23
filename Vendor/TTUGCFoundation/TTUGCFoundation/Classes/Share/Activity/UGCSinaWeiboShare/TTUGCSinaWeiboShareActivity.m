//
//  TTUGCSinaWeiboShareActivity.m
//  Article
//
//  Created by 王霖 on 17/2/28.
//
//

#import "TTUGCSinaWeiboShareActivity.h"
#import "TTUGCSinaWeiboShareContentItem.h"
#import "TTUGCSinaWeiboShareInputViewController.h"
#import <TTNavigationController.h>
#import <TTAccountBusiness.h>
#import <TTPlatformExpiration.h>
#import <TTUIResponderHelper.h>

NSString * const TTActivityTypeUGCSinaWeiboShare = @"com.toutiao.UIKit.activity.UGCSinaWeiboShare";

@implementation TTUGCSinaWeiboShareActivity

#pragma mark - Identifier

- (NSString *)contentItemType {
    return TTActivityContentItemTypeUGCSinaWeiboShare;
}

- (NSString *)activityType {
    return TTActivityTypeUGCSinaWeiboShare;
}

#pragma mark - Action

- (void)performActivityWithCompletion:(TTActivityCompletionHandler)completion {
    NSDate * weiboExpiredLastTime = [[NSUserDefaults standardUserDefaults] valueForKey:@"weiboExpiredLastTime"];
    NSTimeInterval alertAfterTime = [[[NSUserDefaults standardUserDefaults] valueForKey:@"weiboExpiredShowInterval"] doubleValue];
    NSDate * nowDate = [NSDate date];
    if ([TTPlatformExpiration sharedInstance].alertWeiboExpired && (!weiboExpiredLastTime ||(weiboExpiredLastTime && [nowDate timeIntervalSinceDate:weiboExpiredLastTime] >= alertAfterTime))) {
        [[NSUserDefaults standardUserDefaults] setValue:[NSDate date] forKey:@"weiboExpiredLastTime"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        NSString *title = NSLocalizedString(@"新浪微博授权过期，如需分享到新浪微博，请重新授权", @"新浪微博授权过期，如需分享到新浪微博，请重新授权");
        TTThemedAlertController *alert = [[TTThemedAlertController alloc] initWithTitle:title message:@"" preferredType:TTThemedAlertControllerTypeAlert];
        [alert addActionWithTitle:NSLocalizedString(@"取消", @"取消") actionType:TTThemedAlertActionTypeCancel actionBlock:nil];
        [alert addActionWithTitle:NSLocalizedString(@"去授权", @"去授权") actionType:TTThemedAlertActionTypeNormal actionBlock:^{
            
            [TTAccountLoginManager requestLoginPlatformByName:PLATFORM_SINA_WEIBO completion:^(BOOL success, NSError * _Nonnull error) {
                
            }];
            
            [TTPlatformExpiration sharedInstance].alertWeiboExpired = NO;
        }];
        [alert showFrom:[TTUIResponderHelper topmostViewController] animated:YES];
    }
    
    if (![TTPlatformExpiration sharedInstance].hasAlertWeiboExpired) {
        if (![[TTPlatformAccountManager sharedManager] isBoundedPlatformForKey:PLATFORM_SINA_WEIBO]) {
            
            [TTAccountLoginManager requestLoginPlatformByName:PLATFORM_SINA_WEIBO completion:^(BOOL success, NSError * _Nonnull error) {
                
            }];
            
        }else if ([self.contentItem isKindOfClass:[TTUGCSinaWeiboShareContentItem class]]) {
            TTUGCSinaWeiboShareContentItem * contentItem = (TTUGCSinaWeiboShareContentItem *)self.contentItem;
            WeakSelf;
            TTUGCSinaWeiboShareInputViewController * shareInputViewController
            = [[TTUGCSinaWeiboShareInputViewController alloc] initWithUniqueID:contentItem.uniqueID
                                                                     shareText:contentItem.shareText
                                                               shareSourceType:contentItem.shareSourceType
                                                                    completion:^(NSError * _Nullable error) {
                                                                        if (completion) {
                                                                            NSString * tips = nil;
                                                                            if (error) {
                                                                                tips = [error.userInfo tt_stringValueForKey:@"description"];
                                                                                if (isEmptyString(tips)) {
                                                                                    tips = NSLocalizedString(@"网络出现问题，请稍后再试", nil);
                                                                                }
                                                                            }else {
                                                                                tips = NSLocalizedString(@"发送成功", nil);
                                                                            }
                                                                            completion(wself, error, tips);
                                                                        }
                                                                    }];
            TTNavigationController * nav = [[TTNavigationController alloc] initWithRootViewController:shareInputViewController];
            nav.ttDefaultNavBarStyle = @"White";
            [[TTUIResponderHelper topmostViewController] presentViewController:nav
                                                                      animated:YES
                                                                    completion:nil];
        }
    }
}

#pragma mark - Display

- (NSString *)activityImageName {
    return @"sina_allshare";
}

- (NSString *)contentTitle {
    return @"新浪微博";
}

- (NSString *)shareLabel {
    return nil;
}

@end
