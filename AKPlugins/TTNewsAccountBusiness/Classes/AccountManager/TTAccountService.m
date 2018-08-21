//
//  TTAccountService.m
//  Article
//
//  Created by liuzuopeng on 27/05/2017.
//
//

#import "TTAccountService.h"
#import "SSCookieManager.h"
#import "PGCAccountManager.h"
#import "TTAccountManager+HTSAccountBridge.h"
#import "TTPlatformExpiration.h"



@implementation TTAccountService

+ (instancetype)sharedAccountService
{
    static TTAccountService *sharedInst;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInst = [self new];
    });
    return sharedInst;
}

#pragma mark - TTAccountMulticastProtocol

- (void)onAccountLogin
{
    [SSCookieManager setSessionIDToCookie:[[TTAccount sharedAccount] sessionKey]];
    
    [[TTAccountManager sharedManager] synchronizeOldMyUser];
    [PGCAccountManager synchronizePGCAccount];
    [[TTPlatformAccountManager sharedManager] synchronizePlatformAccountsStatus];
    
    [TTAccountManager notifyHTSLoginSuccess];
    
    [TTAccount getUserInfoIgnoreDispatchWithCompletion:nil];
}

- (void)onAccountSessionExpired:(NSError *)error
{
    [SSCookieManager setSessionIDToCookie:nil];
    
    [TTAccountManager setIsLogin:NO];
    [[TTAccountManager sharedManager] synchronizeOldMyUser];
    [PGCAccountManager synchronizePGCAccount];
    [[TTPlatformAccountManager sharedManager] synchronizePlatformAccountsStatus];
    
    [TTAccountManager notifyHTSSessionExpire];
}

- (void)onAccountLogout
{
    [SSCookieManager setSessionIDToCookie:nil];
    
    [TTAccountManager setIsLogin:NO];
    [[TTAccountManager sharedManager] synchronizeOldMyUser];
    [PGCAccountManager synchronizePGCAccount];
    [[TTPlatformAccountManager sharedManager] synchronizePlatformAccountsStatus];
    
    [TTAccountManager notifyHTSLogout];
}

- (void)onAccountGetUserInfo
{
    [[TTAccountManager sharedManager] synchronizeOldMyUser];
    [[TTPlatformAccountManager sharedManager] synchronizePlatformAccountsStatus];
}

- (void)onAccountUserProfileChanged:(NSDictionary *)changedFields error:(NSError *)error
{
    [[TTAccountManager sharedManager] synchronizeOldMyUser];
}

- (void)onAccountAuthPlatformStatusChanged:(TTAccountAuthPlatformStatusChangedReasonType)reasonType platform:(NSString *)platformName error:(NSError *)error
{
    [[TTAccountManager sharedManager] synchronizeOldMyUser];
    [[TTPlatformAccountManager sharedManager] synchronizePlatformAccountsStatus];
    
    if (TTAccountAuthPlatformStatusChangedReasonTypeExpiration == reasonType) {
        NSArray *platforms = [platformName componentsSeparatedByString:@","];
        [[TTPlatformExpiration sharedInstance] platformsExpired:platforms error:error];
    }
}

@end
