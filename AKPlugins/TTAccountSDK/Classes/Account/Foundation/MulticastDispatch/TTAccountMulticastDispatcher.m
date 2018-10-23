//
//  TTAccountMulticastDispatcher.m
//  TTAccountSDK
//
//  Created by liuzuopeng on 15/06/2017.
//  Copyright © 2017 com.bytedance.news. All rights reserved.
//

#import "TTAccountMulticastDispatcher.h"
#import "TTAccountMulticast.h"
#import "TTAccountMulticast+Internal.h"
#import "TTAccount.h"
#import "TTAccountLogDispatcher.h"



@implementation TTAccountMulticastDispatcher

+ (void)dispatchAccountProfileChanged:(NSDictionary *)changedFields
                                error:(NSError *)error
                          bisectBlock:(void (^)(void))bisectBlock
{
    tta_dispatch_sync_main_thread_safe(^{
        id<TTAccountMulticastProtocol> firstResponderDelegate = [TTAccount accountConf].accountMessageFirstResponder;
        if ([firstResponderDelegate respondsToSelector:@selector(onAccountUserProfileChanged:error:)]) {
            [firstResponderDelegate onAccountUserProfileChanged:changedFields error:error];
        }
    });
    
    if (bisectBlock) bisectBlock();
    
    [[TTAccountMulticast sharedInstance] broadcastAccountProfileChanged:changedFields error:error];
}

+ (void)dispatchAccountSessionExpired:(NSError *)error
                          bisectBlock:(void (^)(void))bisectBlock
{
    [self.class dispatchAccountSessionExpirationWithUser:nil error:error bisectBlock:bisectBlock];
}

+ (void)dispatchAccountSessionExpirationWithUser:(NSString *)userIdString
                                           error:(NSError *)error
                                     bisectBlock:(void (^)(void))bisectBlock

{
    tta_dispatch_sync_main_thread_safe(^{
        id<TTAccountMulticastProtocol> firstResponderDelegate = [TTAccount accountConf].accountMessageFirstResponder;
        if ([firstResponderDelegate respondsToSelector:@selector(onAccountSessionExpired:)]) {
            [firstResponderDelegate onAccountSessionExpired:error];
        }
        if ([firstResponderDelegate respondsToSelector:@selector(onAccountStatusChanged:platform:)]) {
            [firstResponderDelegate onAccountStatusChanged:TTAccountStatusChangedReasonTypeSessionExpiration platform:nil];
        }
    });
    
    if (bisectBlock) bisectBlock();
    
    [[TTAccountMulticast sharedInstance] broadcastAccountSessionExpired:error];
    
    // session expiration logger
    NSString *userId = userIdString ? : error.userInfo[@"user_id"];
    [TTAccountLogDispatcher dispatchAccountSessionExpired:error withUserID:userId];
}

+ (void)dispatchAccountLoginSuccess:(TTAccountUserEntity *)user
                           platform:(NSString *)platformName
                             reason:(TTAccountStatusChangedReasonType)reasonType
                        bisectBlock:(void (^)(void))bisectBlock
{
    tta_dispatch_sync_main_thread_safe(^{
        id<TTAccountMulticastProtocol> firstResponderDelegate = [TTAccount accountConf].accountMessageFirstResponder;
        if ([firstResponderDelegate respondsToSelector:@selector(onAccountLogin)]) {
            [firstResponderDelegate onAccountLogin];
        }
        if ([firstResponderDelegate respondsToSelector:@selector(onAccountStatusChanged:platform:)]) {
            [firstResponderDelegate onAccountStatusChanged:reasonType platform:platformName];
        }
    });
    
    if (bisectBlock) bisectBlock();
    
    [[TTAccountMulticast sharedInstance] broadcastLoginSuccess:user platform:platformName reason:reasonType];
}

+ (void)dispatchAccountLoginSuccess:(TTAccountUserEntity *)user
                           platform:(NSString *)platformName
                             reason:(TTAccountStatusChangedReasonType)reasonType
                        bisectBlock:(void (^)(void))bisectBlock
                               wait:(BOOL)waitUntilMainThreadDone
{
    if (waitUntilMainThreadDone) {
        [self.class dispatchAccountLoginSuccess:user platform:platformName reason:reasonType bisectBlock:bisectBlock];
        return;
    }
    
    tta_dispatch_async_main_thread_safe(^{
        id<TTAccountMulticastProtocol> firstResponderDelegate = [TTAccount accountConf].accountMessageFirstResponder;
        if ([firstResponderDelegate respondsToSelector:@selector(onAccountLogin)]) {
            [firstResponderDelegate onAccountLogin];
        }
        if ([firstResponderDelegate respondsToSelector:@selector(onAccountStatusChanged:platform:)]) {
            [firstResponderDelegate onAccountStatusChanged:reasonType platform:platformName];
        }
    });
    
    if (bisectBlock) bisectBlock();
    
    [[TTAccountMulticast sharedInstance] broadcastLoginSuccess:user platform:platformName reason:reasonType];
}

+ (void)dispatchAccountLogoutWithBisectBlock:(void (^)(void))bisectBlock
{
    tta_dispatch_sync_main_thread_safe(^{
        id<TTAccountMulticastProtocol> firstResponderDelegate = [TTAccount accountConf].accountMessageFirstResponder;
        if ([firstResponderDelegate respondsToSelector:@selector(onAccountLogout)]) {
            [firstResponderDelegate onAccountLogout];
        }
        if ([firstResponderDelegate respondsToSelector:@selector(onAccountStatusChanged:platform:)]) {
            [firstResponderDelegate onAccountStatusChanged:TTAccountStatusChangedReasonTypeLogout platform:nil];
        }
    });
    
    if (bisectBlock) bisectBlock();
    
    [[TTAccountMulticast sharedInstance] broadcastLogout];
}

+ (void)dispatchAccountGetUserInfoWithBisectBlock:(void (^)(void))bisectBlock
{
    tta_dispatch_sync_main_thread_safe(^{
        id<TTAccountMulticastProtocol> firstResponderDelegate = [TTAccount accountConf].accountMessageFirstResponder;
        if ([firstResponderDelegate respondsToSelector:@selector(onAccountGetUserInfo)]) {
            [firstResponderDelegate onAccountGetUserInfo];
        }
    });
    
    if (bisectBlock) bisectBlock();
    
    [[TTAccountMulticast sharedInstance] broadcastGetUserInfo];
}

+ (void)dispatchAccountLoginAuthPlatform:(NSString *)platformName
                                   error:(NSError *)error
                             bisectBlock:(void (^)(void))bisectBlock
{
    tta_dispatch_sync_main_thread_safe(^{
        id<TTAccountMulticastProtocol> firstResponderDelegate = [TTAccount accountConf].accountMessageFirstResponder;
        if ([firstResponderDelegate respondsToSelector:@selector(onAccountAuthPlatformStatusChanged:platform:error:)]) {
            [firstResponderDelegate onAccountAuthPlatformStatusChanged:TTAccountAuthPlatformStatusChangedReasonTypeLogin platform:platformName error:error];
        }
    });
    
    if (bisectBlock) bisectBlock();
    
    [[TTAccountMulticast sharedInstance] broadcastLoginAccountAuthPlatform:platformName error:error];
}

+ (void)dispatchAccountLogoutAuthPlatform:(NSString *)platformName
                                    error:(NSError *)error
                              bisectBlock:(void (^)(void))bisectBlock
{
    tta_dispatch_sync_main_thread_safe(^{
        id<TTAccountMulticastProtocol> firstResponderDelegate = [TTAccount accountConf].accountMessageFirstResponder;
        if ([firstResponderDelegate respondsToSelector:@selector(onAccountAuthPlatformStatusChanged:platform:error:)]) {
            [firstResponderDelegate onAccountAuthPlatformStatusChanged:TTAccountAuthPlatformStatusChangedReasonTypeLogout platform:platformName error:error];
        }
    });
    
    if (bisectBlock) bisectBlock();
    
    [[TTAccountMulticast sharedInstance] broadcastLogoutAccountAuthPlatform:platformName error:error];
}

+ (void)dispatchAccountExpireAuthPlatform:(NSString *)platformName
                                    error:(NSError *)error
                              bisectBlock:(void (^)(void))bisectBlock
{
    tta_dispatch_sync_main_thread_safe(^{
        id<TTAccountMulticastProtocol> firstResponderDelegate = [TTAccount accountConf].accountMessageFirstResponder;
        if ([firstResponderDelegate respondsToSelector:@selector(onAccountAuthPlatformStatusChanged:platform:error:)]) {
            [firstResponderDelegate onAccountAuthPlatformStatusChanged:TTAccountAuthPlatformStatusChangedReasonTypeExpiration platform:platformName error:error];
        }
    });
    
    if (bisectBlock) bisectBlock();
    
    [[TTAccountMulticast sharedInstance] broadcastExpireAccountAuthPlatform:platformName error:error];
    
    // platform expire logger
    NSString *userIdString __unused = error.userInfo[@"user_id"];
    [TTAccountLogDispatcher dispatchAccountPlatformExpired:error withPlatform:platformName];
}

@end
