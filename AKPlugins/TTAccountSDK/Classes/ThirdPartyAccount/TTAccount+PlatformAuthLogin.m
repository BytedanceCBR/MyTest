//
//  TTAccount+PlatformAuthLogin.m
//  TTAccountSDK
//
//  Created by liuzuopeng on 4/9/17.
//
//

#import "TTAccount+PlatformAuthLogin.h"
#import "TTAccountAuthLoginManager.h"
#import "TTAccount.h"
#import "TTAccountConfiguration+PlatformAccount.h"



@implementation TTAccount (PlatformAuthLogin)

#pragma mark - register

+ (void)registerPlatform:(TTAccountPlatformConfiguration *)platformConf
{
    [[TTAccount accountConf] addPlatformConfiguration:platformConf];
}

+ (void)registerPlatforms:(NSArray<TTAccountPlatformConfiguration *> *)platformConfs
{
    [[TTAccount accountConf] addPlatformConfigurations:platformConfs];
}

+ (void)registerAuthAccount:(Class<TTAccountAuthProtocol>)cls
{
    [TTAccountAuthLoginManager registerPlatformAuthAccount:cls];
}

#pragma mark - handle URL

+ (BOOL)handleOpenURL:(NSURL *)url
{
    return [TTAccountAuthLoginManager handleOpenURL:url];
}

#pragma mark - Platform Info

+ (TTAccountAuthType)accountAuthTypeForPlatform:(NSString *)platformName
{
    return [TTAccountAuthLoginManager accountAuthTypeForPlatform:platformName];
}

+ (NSString *)platformNameForAccountAuthType:(TTAccountAuthType)type
{
    return [TTAccountAuthLoginManager platformForAccountAuthType:type];
}

+ (NSString *)platformAppIdForAccountAuthType:(TTAccountAuthType)type
{
    return [TTAccountAuthLoginManager platformAppIdForAccountAuthType:type];
}

+ (BOOL)canSSOForPlatform:(TTAccountAuthType)type
{
    return [TTAccountAuthLoginManager canSSOForPlatform:type];
}

+ (BOOL)canWebSSOForPlatform:(TTAccountAuthType)type;
{
    return [TTAccountAuthLoginManager canWebSSOForPlatform:type];
}

+ (BOOL)canCustomWebSSOForPlatform:(TTAccountAuthType)type
{
    return [TTAccountAuthLoginManager canCustomWebSSOForPlatform:type];
}

+ (BOOL)isAppInstalledForPlatform:(TTAccountAuthType)type
{
    return [TTAccountAuthLoginManager isAppInstalledForPlatform:type];
}

+ (NSString *)localizedDisplayNameForPlatform:(TTAccountAuthType)type
{
    return [TTAccountAuthLoginManager localizedDisplayNameForPlatform:type];
}

+ (NSString *)getAppInstallUrlForPlatform:(TTAccountAuthType)type
{
    return [TTAccountAuthLoginManager getAppInstallUrlForPlatform:type];
}

#pragma mark - login

+ (void)requestLoginForPlatform:(TTAccountAuthType)type
                     completion:(TTAccountLoginCompletedBlock)completedBlock
{
    [TTAccountAuthLoginManager requestLoginForPlatform:type willLogin:nil completion:completedBlock];
}

+ (void)requestLoginForPlatformName:(NSString *)platformName
                         completion:(TTAccountLoginCompletedBlock)completedBlock
{
    TTAccountAuthType platformType = [self.class validAuthPlatformTypeOfPlatformName:platformName];
    
    [self.class requestLoginForPlatform:platformType completion:completedBlock];
}

+ (void)requestLoginForPlatform:(TTAccountAuthType)type
                inCustomWebView:(BOOL)useCustomWap
                     completion:(TTAccountLoginCompletedBlock)completedBlock
{
    [TTAccountAuthLoginManager requestLoginForPlatform:type inCustomWebView:useCustomWap willLogin:nil completion:completedBlock];
}

+ (void)requestLoginForPlatformName:(NSString *)platformName
                    inCustomWebView:(BOOL)useCustomWap
                         completion:(TTAccountLoginCompletedBlock)completedBlock
{
    TTAccountAuthType platformType = [self.class validAuthPlatformTypeOfPlatformName:platformName];
    
    [self.class requestLoginForPlatform:platformType inCustomWebView:useCustomWap completion:completedBlock];
}

+ (void)requestLoginForPlatform:(TTAccountAuthType)type
                      willLogin:(void (^)(NSString *))willLoginBlock
                     completion:(TTAccountLoginCompletedBlock)completedBlock
{
    [TTAccountAuthLoginManager requestLoginForPlatform:type willLogin:willLoginBlock completion:completedBlock];
}

+ (void)requestLoginForPlatform:(TTAccountAuthType)type
                inCustomWebView:(BOOL)useCustomWap
                      willLogin:(void (^)(NSString *))willLoginBlock
                     completion:(TTAccountLoginCompletedBlock)completedBlock
{
    [TTAccountAuthLoginManager requestLoginForPlatform:type inCustomWebView:useCustomWap willLogin:willLoginBlock completion:completedBlock];
}

+ (void)requestLogoutForPlatform:(TTAccountAuthType)type
                      completion:(void (^)(BOOL success, NSError *error))completedBlock
{
    [TTAccountAuthLoginManager requestLogoutForPlatform:type completion:completedBlock];
}

+ (void)requestLogoutForPlatformName:(NSString *)platformName
                          completion:(void (^)(BOOL success, NSError *error))completedBlock
{
    TTAccountAuthType platformType = [self.class validAuthPlatformTypeOfPlatformName:platformName];
    
    [self.class requestLogoutForPlatform:platformType completion:completedBlock];
}

#pragma mark - helper

+ (TTAccountAuthType)validAuthPlatformTypeOfPlatformName:(NSString *)platformName
{
    NSCAssert(platformName, @"platform name cann't be nil");
    
    TTAccountAuthType platformType = [TTAccount accountAuthTypeForPlatform:platformName];
    
    NSCAssert(platformType != TTAccountAuthTypeUnsupport, @"platform name is invalid");
    
    return platformType;
}

#pragma mark - sso_callback

+ (id<TTAccountSessionTask>)loginWithSSOCallback:(NSDictionary *)params
                                     forPlatform:(NSInteger)platformType
                                       willLogin:(void (^)(NSString *))willLoginBlock
                                      completion:(void(^)(BOOL success, BOOL loginOrBind, NSError *error))completedBlock
{
    return [TTAccountAuthLoginManager loginWithSSOCallback:params
                                               forPlatform:platformType
                                                 willLogin:willLoginBlock
                                                completion:completedBlock];
}

@end



@implementation TTAccount (PlatformAuthLogin_Deprecated)

#pragma mark - register

+ (void)registerAppId:(NSString *)appId
          forPlatform:(TTAccountAuthType)type
{
    return [TTAccountAuthLoginManager registerAppId:appId forPlatform:type];
}

@end
