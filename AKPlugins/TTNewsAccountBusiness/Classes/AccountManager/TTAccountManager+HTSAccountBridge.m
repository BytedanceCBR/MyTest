//
//  TTAccountManager+HTSAccountBridge.m
//  Article
//
//  Created by liuzuopeng on 21/06/2017.
//
//

#import "TTAccountManager+HTSAccountBridge.h"
#import <TTModuleBridge.h>
#import "TTAccountManager.h"



@implementation TTAccountManager (HTSAccountBridge)

+ (void)load
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self registerHTSAccountActions];
    });
}

+ (void)registerHTSAccountActions
{
    [[TTModuleBridge sharedInstance_tt] registerAction:@"HTSNeedLogin" withBlock:^id _Nullable(id  _Nullable object, id  _Nullable params) {
        [TTAccountManager showLoginAlertWithType:TTAccountLoginAlertTitleTypeDefault source:@"HTSLive" completion:^(TTAccountAlertCompletionEventType type, NSString * _Nullable phoneNum) {
            if (type == TTAccountAlertCompletionEventTypeTip) {
                [TTAccountManager presentQuickLoginFromHTSModuleWithType:TTAccountLoginDialogTitleTypeDefault
                                                                  source:@"HTSLive"];
            } else if (type == TTAccountAlertCompletionEventTypeDone) {
                // 此处去掉，所有登录成功后统一调
                // [TTAccountManager notifyHTSLoginSuccess];
            } else {
                [TTAccountManager notifyHTSLoginFailure];
            }
        }];
        return nil;
    }];
    
    [[TTModuleBridge sharedInstance_tt] registerAction:@"HTSGetUserInfo" withBlock:^id _Nullable(id  _Nullable object, id  _Nullable params) {
        NSMutableDictionary *result = [NSMutableDictionary dictionary];
        if ([TTAccountManager isLogin]) {
            [result setValue:[TTAccountManager userID] forKey:@"userID"];
        }
        return result;
    }];
}

+ (void)unregisterHTSAccountActions
{
    [[TTModuleBridge sharedInstance_tt] removeAction:@"HTSNeedLogin"];
    [[TTModuleBridge sharedInstance_tt] removeAction:@"HTSGetUserInfo"];
}

+ (void)notifyHTSLoginSuccess
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setValue:@(YES) forKey:@"success"];
    [[TTModuleBridge sharedInstance_tt] notifyListenerForKey:@"HTSLoginResult" object:self withParams:params complete:nil];
}

+ (void)notifyHTSLoginFailure
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setValue:@(NO) forKey:@"success"];
    [[TTModuleBridge sharedInstance_tt] notifyListenerForKey:@"HTSLoginResult" object:self withParams:params complete:nil];
}

+ (void)notifyHTSLogout
{
    [[TTModuleBridge sharedInstance_tt] notifyListenerForKey:@"HTSLogoutResult" object:self withParams:nil complete:nil];
}

+ (void)notifyHTSSessionExpire
{
    [[TTModuleBridge sharedInstance_tt] notifyListenerForKey:@"HTSLogoutResult" object:self withParams:nil complete:nil];
}

@end
