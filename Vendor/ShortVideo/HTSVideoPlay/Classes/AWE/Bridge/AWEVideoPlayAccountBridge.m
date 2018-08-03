//
//  AWEVideoPlayAccountBridge.m
//  Pods
//
//  Created by 01 on 18/11/2016.
//
//

#import "AWEVideoPlayAccountBridge.h"
#import "TTModuleBridge.h"
#import "HTSVideoPlayUserModel.h"
#import "AWEVideoPlayNetworkManager.h"
#import "TTAccountManager.h"
#import "TTAccountManager+HTSAccountBridge.h"

static NSString *currentUserId;
NSString * const AWEVideoPlayCurrentLoginUserKey = @"AWEVideoPlayCurrentLoginUserKey";

@implementation AWEVideoPlayAccountBridge

+ (void)registerLoginResultListener
{
    //注册结果回调 注意：这里主端登录后并不会触发 所以在详情页打开的时候再检查一次登录态
    [[TTModuleBridge sharedInstance_tt] registerListener:self object:nil forKey:@"HTSLoginResult" withBlock:^(id  _Nullable params) {
        //登陆结果回调
        if ([params[@"success"] boolValue]) {
//            [self checkin];
            [self fetchTTAccount];
        }
    }];
}

+ (void)registerLogoutResultListener
{
    [[TTModuleBridge sharedInstance_tt] registerListener:self object:nil forKey:@"HTSLogoutResult" withBlock:^(id  _Nullable params) {
//        if ([params[@"success"] boolValue]) {
//            [self checkout];
//        }
        currentUserId = nil;
    }];
}

+ (void)checkin
{
    NSString *url = @"https://aweme.snssdk.com/aweme/v1/check/in/";
    [[AWEVideoPlayNetworkManager sharedInstance] requestJSONFromURL:url params:nil method:@"GET" needCommonParams:YES callback:^(NSError *error, id jsonObj){
    }];
}

+ (void)checkout
{
    NSString *url = @"https://aweme.snssdk.com/aweme/v1/check/out/";
    [[TTNetworkManager shareInstance] requestForJSONWithURL:url params:nil method:@"GET" needCommonParams:YES callback:^(NSError *error, id jsonObj) {
    }];
}

+ (BOOL)isCurrentLoginUser:(NSString *)userId
{
    return currentUserId != nil && [currentUserId isEqualToString:userId];
}

+ (BOOL)isLogin
{
    return currentUserId != nil;
}

+ (void)fetchTTAccount
{
    [AWEVideoPlayAccountBridge fetchTTAccountWithCompletion:nil];
}

+ (void)fetchTTAccountWithCompletion:(void(^)(BOOL success))completion
{
    [[TTModuleBridge sharedInstance_tt] triggerAction:@"HTSGetUserInfo" object:nil withParams:nil complete:^(id  _Nullable result) {
        if(!result || ![result isKindOfClass: [NSDictionary class]]){
            !completion?:completion(NO);
            return;
        }
        NSDictionary *dict = (NSDictionary *)result;
        if(dict[@"userID"]){
            currentUserId = (NSString *)dict[@"userID"];
            !completion?:completion(YES);
        }else{
            !completion?:completion(NO);
        }
    }];
}


+ (void)showLoginView
{
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
}

+ (NSString *)currentLoginUserId
{
    return currentUserId;
}

@end
