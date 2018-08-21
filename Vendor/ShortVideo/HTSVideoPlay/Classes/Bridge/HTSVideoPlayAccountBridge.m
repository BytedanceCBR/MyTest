//
//  HTSVideoPlayAccountBridge.m
//  Pods
//
//  Created by SongLi.02 on 18/11/2016.
//
//

#import "HTSVideoPlayAccountBridge.h"
#import "TTModuleBridge.h"
#import "HTSVideoPlayUserModel.h"
#import "HTSVideoPlayNetworkManager.h"
#import "TTAccountManager.h"
#import "TTAccountManager+HTSAccountBridge.h"

static HTSVideoPlayUserModel *currUserModel;
NSString * const HTSVideoPlayCurrentLoginUserKey = @"HTSVideoPlayCurrentLoginUserKey";

@implementation HTSVideoPlayAccountBridge

+ (void)registerLoginResultListener
{
    //注册结果回调
    [self registerLoginResultListenerWithListenr:self object:nil completion:^(BOOL success) {
        if (success) {
            [self loginHotsoon];
        }
    }];
}

+ (void)registerLogoutResultListener
{
    [[TTModuleBridge sharedInstance_tt] registerListener:self object:nil forKey:@"HTSLogoutResult" withBlock:^(id  _Nullable params) {
        [self clearLoginUser];
        
        NSString *urlStr = @"https://hotsoon.snssdk.com/hotsoon/logout/";
        [[HTSVideoPlayNetworkManager sharedInstance] requestJSONFromURL:urlStr params:nil method:@"GET" needCommonParams:YES callback:^(NSError *error, id jsonObj) {
        }];
    }];
}

+ (void)registerLoginResultListenerWithListenr:(id)listerner object:(nullable id)object completion:(void(^)(BOOL success))completion
{
    //注册结果回调
    [[TTModuleBridge sharedInstance_tt] registerListener:listerner object:object forKey:@"HTSLoginResult" withBlock:^(id  _Nullable params) {
        if (completion) {
            completion([params[@"success"] boolValue]);
        }
    }];
}

+ (void)removeLoginResultListenerWithListner:(id)listerner
{
     [[TTModuleBridge sharedInstance_tt] removeListener:listerner forKey:@"HTSLoginResult"];
}

+ (void)loginHotsoon
{
    NSString *urlStr = @"https://hotsoon.snssdk.com/hotsoon/user/";
    [[HTSVideoPlayNetworkManager sharedInstance] requestJSONFromURL:urlStr params:nil method:@"GET" needCommonParams:YES callback:^(NSError *error, id jsonObj) {
        if (error || ![jsonObj isKindOfClass:[NSDictionary class]] || ![jsonObj[@"data"] isKindOfClass:[NSDictionary class]]) {
            return;
        }
        
        // Persist user
        HTSVideoPlayUserModel *userModel = [MTLJSONAdapter modelOfClass:[HTSVideoPlayUserModel class] fromJSONDictionary:jsonObj[@"data"] error:nil];
        
        if (!userModel) {
            return;
        }
        
        [self persistenceAccountUser:userModel];
        
        // Hotsoon Check in
        NSString *urlStr = @"https://hotsoon.snssdk.com/hotsoon/checkin/";
        [[HTSVideoPlayNetworkManager sharedInstance] requestJSONFromURL:urlStr params:nil method:@"GET" needCommonParams:YES callback:^(NSError *error, id jsonObj) {}];
    }];
}

+ (BOOL)isCurrentLoginUser:(NSString *)userId
{
    return [[self currentLoginUser].userID.stringValue isEqualToString:userId];
}

+ (BOOL)isLogin
{
    return ([self currentLoginUser] != nil);
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
    return [self currentLoginUser].userID.stringValue;
}

+ (HTSVideoPlayUserModel *)currentLoginUser
{
    if (currUserModel) {
        return currUserModel;
    }
    
    NSData *userData = [[NSUserDefaults standardUserDefaults] objectForKey:HTSVideoPlayCurrentLoginUserKey];
    if (userData) {
        currUserModel = [NSKeyedUnarchiver unarchiveObjectWithData:userData];
    }
    return currUserModel;
}

+ (void)clearLoginUser
{
    currUserModel = nil;
    
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:HTSVideoPlayCurrentLoginUserKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (BOOL)persistenceAccountUser:(HTSVideoPlayUserModel *)user
{
    if (currUserModel) {
        [currUserModel mergeValuesForKeysFromModel:user];
    } else {
        currUserModel = user;
    }
    NSData *accountUserData = [NSKeyedArchiver archivedDataWithRootObject:currUserModel];
    [[NSUserDefaults standardUserDefaults] setObject:accountUserData forKey:HTSVideoPlayCurrentLoginUserKey];
    return [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
