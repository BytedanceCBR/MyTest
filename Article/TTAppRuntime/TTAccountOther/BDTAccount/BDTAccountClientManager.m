
//
//  BDTAccountClientManager.m
//  Article
//
//  Created by zuopengliu on 14/9/2017.
//
//

#import "BDTAccountClientManager.h"
#import <TTAccountSDK.h>
#import <TTUIResponderHelper.h>
#import "TTAccountBindingMobileViewController.h"
#import <TTSettingsManager.h>
#import "UIViewController+BDTAccountModalPresentor.h"


@interface BDTAccountClientManager ()
<
TTAccountMulticastProtocol
>

@end

@implementation BDTAccountClientManager

+ (void)load
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self sharedAccountClient];
    });
}

+ (instancetype)sharedAccountClient
{
    static BDTAccountClientManager *sharedInst;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInst = [self new];
    });
    return sharedInst;
}

- (instancetype)init
{
    if ((self = [super init])) {
        [TTAccount addMulticastDelegate:self];
    }
    return self;
}

- (void)dealloc
{
    [TTAccount removeMulticastDelegate:self];
}


#pragma mark - TTAccountMulticastProtocol

- (void)onAccountStatusChanged:(TTAccountStatusChangedReasonType)reasonType platform:(NSString *)platformName
{
    if (reasonType == TTAccountStatusChangedReasonTypeAuthPlatformLogin) {
        if (platformName && [[TTAccount platformNameForAccountAuthType:TTAccountAuthTypeSinaWeibo] isEqualToString:platformName]) {
            // 标记可显示绑定手机号
            [TTAccountBindingMobileViewController setShowBindingMobileEnabled:YES];
            [self.class presentBindingMobileVCFrom:BDTABindingMobileFromLogin bindingCompletion:nil];
        }
    }
}

static NSString *kTTShowBindingMobileTimeIntervalKey = @"kTTShowBindingMobileTimeIntervalKey";

+ (void)presentBindingMobileVCFrom:(NSInteger)pageSource
                 bindingCompletion:(void (^)(BOOL finished /** 是否绑定成功 */))completion
{
    if (![[TTAccount sharedAccount] isLogin]) return;
    
    if (![TTAccountBindingMobileViewController showBindingMobileEnabled]) return;
    
    NSString *mobileString = [[TTAccount sharedAccount] user].mobile;
    NSInteger numberOfPlatforms = [[[TTAccount sharedAccount] user].connects count];
    
    NSDictionary *accountSettings = [[TTSettingsManager sharedManager] settingForKey:@"tt_account_settings" defaultValue:[NSDictionary dictionary] freeze:NO];
    NSInteger currentNumberOfTimes = [TTAccountBindingMobileViewController showBindingMobileTimes];
    NSInteger maxNumberOfTimes = 1; // 默认弹出次数
    NSString *titleTextString = nil;
    BOOL enabledShowFromMine = YES;
    NSTimeInterval showFromMineTimeInterval = -1;
    if ([accountSettings isKindOfClass:[NSDictionary class]] && [accountSettings count] > 0) {
        NSDictionary *bindingSettings = accountSettings[@"tt_binding_mobile_settings"];
        NSInteger controlledTimes = [bindingSettings[@"max_show_times"] integerValue];
        if (controlledTimes > 0) maxNumberOfTimes = controlledTimes;
        titleTextString = bindingSettings[@"binding_mobile_title_text"];
        
        enabledShowFromMine = accountSettings[@"show_from_mine_enabled"] ? [accountSettings[@"show_from_mine_enabled"] boolValue] : YES;
        showFromMineTimeInterval = [accountSettings[@"show_from_mine_timeinterval"] doubleValue];
    }
    
    if (!enabledShowFromMine && pageSource == BDTABindingMobileFromMine) return;
    if (showFromMineTimeInterval > 0)  {
        NSTimeInterval currentTimeInterval = [[NSDate date] timeIntervalSince1970];
        NSTimeInterval lastTimeInterval = [[[NSUserDefaults standardUserDefaults] objectForKey:kTTShowBindingMobileTimeIntervalKey] doubleValue];
        if (currentTimeInterval - lastTimeInterval < showFromMineTimeInterval) return;
    }
    
    static TTAccountBindingMobileViewController *bindMobileVC = nil;
    if (bindMobileVC) return;
    
    NSString *sinaPlatormName = [TTAccount platformNameForAccountAuthType:TTAccountAuthTypeSinaWeibo];
    TTAccountPlatformEntity *firstConnectedPlatform = [[[TTAccount sharedAccount] user].connects firstObject];
    if ([mobileString length] == 0 && currentNumberOfTimes < maxNumberOfTimes &&
        numberOfPlatforms == 1 && sinaPlatormName && [firstConnectedPlatform.platform isEqualToString:sinaPlatormName]) {
        bindMobileVC = [TTAccountBindingMobileViewController new];
        bindMobileVC.titleHintString = titleTextString;
        bindMobileVC.bindingCompletionCallback = ^(BOOL finished, BOOL isDismissed) {
            if (completion) completion(finished);
            
            bindMobileVC = nil;
            
            [[NSUserDefaults standardUserDefaults] setObject:@([[NSDate date] timeIntervalSince1970]) forKey:kTTShowBindingMobileTimeIntervalKey];
            [[NSUserDefaults standardUserDefaults] synchronize];
        };
        
        if ([TTUIResponderHelper topmostViewController].presentedViewController)  {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.35 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                if (![TTUIResponderHelper topmostViewController].presentedViewController) {
                    [[TTUIResponderHelper topmostViewController] bdta_presentModalViewController:bindMobileVC animated:YES completion:nil];
                } else {
                    // 有些小设备上，真是坑爹，动画死都执行不完，导致[TTUIResponderHelper topmostViewController].presentedViewController还在
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        if (![TTUIResponderHelper topmostViewController].presentedViewController) {
                            [[TTUIResponderHelper topmostViewController] bdta_presentModalViewController:bindMobileVC animated:YES completion:nil];
                        } else {
                            // 最后延迟0.15s，还存在不显示了下次显示
                            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.15 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                if (![TTUIResponderHelper topmostViewController].presentedViewController) {
                                    [[TTUIResponderHelper topmostViewController] bdta_presentModalViewController:bindMobileVC animated:YES completion:nil];
                                } else {
                                    bindMobileVC = nil;
                                }
                            });
                        }
                    });
                }
            });
        } else {
            [[TTUIResponderHelper topmostViewController] bdta_presentModalViewController:bindMobileVC animated:YES completion:nil];
        }
    }
}

@end
