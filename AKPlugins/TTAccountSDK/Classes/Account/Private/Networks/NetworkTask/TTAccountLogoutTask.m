//
//  TTAccountLogoutTask.m
//  TTAccountSDK
//
//  Created by liuzuopeng on 4/26/17.
//  Copyright © 2017 com.bytedance.news. All rights reserved.
//

#import "TTAccountLogoutTask.h"
#import "TTAccountURLSetting.h"
#import "TTAccountDefine.h"
#import "TTAccountCookie.h"
#import "TTAccount.h"
#import "TTAccountMulticastDispatcher.h"
#import "TTAccountLogDispatcher.h"
#import "TTAccountNetworkManager.h"



@implementation TTAccountLogoutTask

+ (id<TTAccountSessionTask>)requestLogout:(void (^)(BOOL success, NSError *error))completedBlock
{
    return [TTAccountNetworkManager getRequestForJSONWithURL:[TTAccountURLSetting TTALogoutURLString] params:nil needCommonParams:YES callback:^(NSError *error, id jsonObj) {
        
        if (error) {
            if (completedBlock) {
                completedBlock(NO, error);
            }
            
            [TTAccountLogDispatcher dispatchAccountLogoutFailure];
            
            return;
        }
        
        // 退出成功，清空用户信息
        [TTAccountCookie clearAccountCookie];
//        [TTAccountCookie clearAllCookies];
        
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
        if ([[TTAccount sharedAccount] respondsToSelector:@selector(setIsLogin:)]) {
            [[TTAccount sharedAccount] setIsLogin:NO];
        }
#pragma clang diagnostic pop
        
        [TTAccountMulticastDispatcher dispatchAccountLogoutWithBisectBlock:^{
            // 回调
            if (completedBlock) {
                completedBlock(YES, nil);
            }
        }];
        
        // logger
        [TTAccountLogDispatcher dispatchAccountLogoutSuccess];
    }];
}

+ (id<TTAccountSessionTask>)requestLogoutClearCookie:(void (^)(BOOL success, NSError *error))completedBlock
{
    // 退出成功，清空用户信息
    [TTAccountCookie clearAccountCookie];
    
    return [TTAccountNetworkManager getRequestForJSONWithURL:[TTAccountURLSetting TTALogoutURLString] params:nil needCommonParams:YES callback:^(NSError *error, id jsonObj) {
        
        if (error) {
            if (completedBlock) {
                completedBlock(NO, error);
            }
                    
            return;
        }
        
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
        if ([[TTAccount sharedAccount] respondsToSelector:@selector(setIsLogin:)]) {
            [[TTAccount sharedAccount] setIsLogin:NO];
        }
#pragma clang diagnostic pop
        // 回调
        if (completedBlock) {
            completedBlock(YES, nil);
        }
        // logger
    }];
}


#pragma mark - 解绑第三方账号

+ (id<TTAccountSessionTask>)requestLogoutPlatform:(NSString *)platformName
                                       completion:(void(^)(BOOL success, NSError *error))completedBlock
{
    NSMutableDictionary *getParams = [NSMutableDictionary dictionaryWithCapacity:1];
    [getParams setValue:platformName forKey:@"platform"];
    
    return [TTAccountNetworkManager getRequestForJSONWithURL:[TTAccountURLSetting TTALogoutThirdPartyPlatformURLString] params:getParams needCommonParams:YES callback:^(NSError *error, id jsonObj) {
        
        if (error) {
            
            completedBlock(NO, error);
            
        } else {
            // logout local platform data
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
            if ([[TTAccount sharedAccount] respondsToSelector:@selector(logoutAuthorizedPlatform:)]) {
                [[TTAccount sharedAccount] performSelector:@selector(logoutAuthorizedPlatform:) withObject:platformName];
            }
#pragma clang diagnostic pop
            
            [TTAccountMulticastDispatcher dispatchAccountLogoutAuthPlatform:platformName error:error bisectBlock:^{
                if (completedBlock) {
                    completedBlock(YES, nil);
                }
            }];
        }
    }];
}

@end
