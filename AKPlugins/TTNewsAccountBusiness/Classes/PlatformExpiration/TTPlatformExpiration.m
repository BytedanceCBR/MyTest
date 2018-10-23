//
//  TTPlatformExpiration.m
//  Article
//
//  Created by 刘廷勇 on 16/1/26.
//
//

#import "TTPlatformExpiration.h"
#import <TTACustomWapAuthViewController.h>
#import <TTThemedAlertController.h>
#import <TTNavigationController.h>
#import <TTUIResponderHelper.h>
#import "TTAccountManager.h"



#define kDisplayDuration            15 * 24 * 3600 // 15 days
#define kPlatformExpireDisplayKey   @"kPlatformExpireDisplayKey"

NSString * const SSWeiboExpiredKey = @"SSWeiboExpiredKey";
NSString * const SSWeiboExpiredNeedAlertKey = @"SSWeiboExpiredNeedAlertKey";

@interface TTPlatformExpiration () <UIAlertViewDelegate>

@property (nonatomic, assign) BOOL              platformExpiredAlertViewDisplaying;
@property (nonatomic,   copy) NSString         *lastExpiredPlatform;
@property (nonatomic, strong) UIViewController *topmostController;

@end

@implementation TTPlatformExpiration

+ (instancetype)sharedInstance
{
    static TTPlatformExpiration *expiration = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        expiration = [[TTPlatformExpiration alloc] init];
        expiration.platformExpiredAlertViewDisplaying = NO;
    });
    return expiration;
}

- (UIViewController *)topmostController
{
    if (!_topmostController) {
        _topmostController = [TTUIResponderHelper topmostViewController];
    }
    return _topmostController;
}

- (void)setAlertWeiboExpired:(BOOL)alertWeiboExpired
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setValue:@(alertWeiboExpired) forKey:SSWeiboExpiredNeedAlertKey];
    [userDefaults synchronize];
}

- (BOOL)hasAlertWeiboExpired
{
    return [[[NSUserDefaults standardUserDefaults] valueForKey:SSWeiboExpiredNeedAlertKey] boolValue];
}

- (void)setWeiboExpired:(BOOL)weiboExpired
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setValue:@(weiboExpired) forKey:SSWeiboExpiredKey];
    [userDefaults synchronize];
}

- (BOOL)isWeiboExpired
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return [[userDefaults valueForKey:SSWeiboExpiredKey] boolValue];
}

- (void)platformsExpired:(NSArray *)platforms error:(NSError *)error
{
    double delayInSeconds = 2.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        
        if ([self.topmostController isKindOfClass:[UINavigationController class]]) {
            UIViewController *lastController = ((UINavigationController*)self.topmostController).topViewController;
            if ([lastController isKindOfClass:[TTACustomWapAuthViewController class]]) {
                return;
            }
            
            if ([self.topmostController respondsToSelector:@selector(presentedViewController)]) {
                UIViewController *topPresentedController = self.topmostController.presentedViewController;
                while (topPresentedController.presentedViewController != nil) {
                    topPresentedController = topPresentedController.presentedViewController;
                }
                
                if ([topPresentedController isKindOfClass:[TTACustomWapAuthViewController class]]) {
                    return;
                }
            }
        }
        
        if (!self.platformExpiredAlertViewDisplaying) {
            NSMutableString *tips = [NSMutableString stringWithCapacity:100];
            if (platforms.count > 0 && !error) {
                NSString *platformKey = [platforms objectAtIndex:0];
                NSMutableDictionary *mDict = [NSMutableDictionary dictionaryWithDictionary:[[NSUserDefaults standardUserDefaults] objectForKey:kPlatformExpireDisplayKey]];
                
                NSTimeInterval lastDisplay = [[mDict objectForKey:platformKey] doubleValue];
                
                if ([[NSDate date] timeIntervalSince1970] - lastDisplay > kDisplayDuration) {
                    TTThirdPartyAccountInfoBase *accountInfo = [[TTPlatformAccountManager sharedManager] platformAccountInfoForKey:platformKey];
                    NSString *platformName = [accountInfo displayName];
                    [tips appendFormat:@"%@", platformName];
                    self.lastExpiredPlatform = platformKey;
                    
                    if (!isEmptyString(tips)) {
                        self.platformExpiredAlertViewDisplaying = YES;
                        [tips appendString:NSLocalizedString(@"登录过期，需要重新登录", nil)];
                        double delayInSeconds = 2.0;
                        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
                        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                            TTThemedAlertController *alert = [[TTThemedAlertController alloc] initWithTitle:nil message:tips preferredType:TTThemedAlertControllerTypeAlert];
                            [alert addActionWithTitle:NSLocalizedString(@"不再提示", nil) actionType:TTThemedAlertActionTypeCancel actionBlock:^{
                                NSMutableDictionary *mDict = [NSMutableDictionary dictionaryWithDictionary:[[NSUserDefaults standardUserDefaults] objectForKey:kPlatformExpireDisplayKey]];
                                [mDict setValue: [NSNumber numberWithDouble:[[NSDate date] timeIntervalSince1970]] forKey:self.lastExpiredPlatform];
                                [[NSUserDefaults standardUserDefaults] setObject:mDict forKey:kPlatformExpireDisplayKey];
                            }];
                            [alert addActionWithTitle:NSLocalizedString(@"登录", nil) actionType:TTThemedAlertActionTypeNormal actionBlock:^{
                                if ([TTAccountManager isLogin]) {
                                    if (!isEmptyString(self.lastExpiredPlatform)) {
                                        
                                        [TTAccountLoginManager requestLoginPlatformByName:self.lastExpiredPlatform completion:^(BOOL success, NSError *error) {
                                            
                                        }];
                                    }
                                } else {
                                    
                                    [TTAccountManager showLoginAlertWithType:TTAccountLoginAlertTitleTypeDefault source:nil completion:^(TTAccountAlertCompletionEventType type, NSString *phoneNum) {
                                        if (type == TTAccountAlertCompletionEventTypeTip) {
                                            [TTAccountManager presentQuickLoginFromVC:[TTUIResponderHelper topNavigationControllerFor:nil] type:TTAccountLoginDialogTitleTypeDefault source:nil completion:^(TTAccountLoginState state) {
                                            }];
                                        }
                                    }];
                                }
                            }];
                            [alert showFrom:self.topmostController animated:YES];
                        });
                    }
                }
            }
        }
    });
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == alertView.cancelButtonIndex) {
        NSMutableDictionary *mDict = [NSMutableDictionary dictionaryWithDictionary:[[NSUserDefaults standardUserDefaults] objectForKey:kPlatformExpireDisplayKey]];
        [mDict setValue: [NSNumber numberWithDouble:[[NSDate date] timeIntervalSince1970]] forKey:self.lastExpiredPlatform];
        [[NSUserDefaults standardUserDefaults] setObject:mDict forKey:kPlatformExpireDisplayKey];
    } else {
        if ([TTAccountManager isLogin]) {
            if (!isEmptyString(self.lastExpiredPlatform)) {
                [TTAccountLoginManager requestLoginPlatformByName:self.lastExpiredPlatform completion:^(BOOL success, NSError *error) {
                    
                }];
            }
        } else {
            [TTAccountManager showLoginAlertWithType:TTAccountLoginAlertTitleTypeDefault source:nil completion:^(TTAccountAlertCompletionEventType type, NSString *phoneNum) {
                if (type == TTAccountAlertCompletionEventTypeTip) {
                    [TTAccountManager presentQuickLoginFromVC:[TTUIResponderHelper topNavigationControllerFor:nil] type:TTAccountLoginDialogTitleTypeDefault source:nil completion:^(TTAccountLoginState state) {
                    }];
                }
            }];
        }
    }
    
    self.lastExpiredPlatform = nil;
    self.platformExpiredAlertViewDisplaying = NO;
}

@end
