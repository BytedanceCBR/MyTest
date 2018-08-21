//
//  TTAccountConfiguration_Priv+PlatformAccount.m
//  TTAccountSDK
//
//  Created by liuzuopeng on 4/9/17.
//
//

#import "TTAccountConfiguration_Priv+PlatformAccount.h"



@implementation TTAccountConfiguration (tta_PlatformAccountInternal)

#pragma mark - internal call methods

- (NSString *)tta_consumerKeyForPlatformType:(TTAccountAuthType)type
{
    return [self __platformConfigurationForType:type].consumerKey;
}

- (NSString *)tta_platformAppNameForPlatformType:(TTAccountAuthType)type
{
    NSString *platformName = [self __platformConfigurationForType:type].platformName;
    if (platformName.length > 0) return platformName;
    
    static NSDictionary *defaultPlatformNameMapper = nil;
    if (!defaultPlatformNameMapper) {
        defaultPlatformNameMapper = @{
                                      @(TTAccountAuthTypeWeChat)    : @"weixin",
                                      @(TTAccountAuthTypeTencentQQ) : @"qzone_sns",
                                      @(TTAccountAuthTypeTencentWB) : @"qq_weibo",
                                      @(TTAccountAuthTypeSinaWeibo) : @"sina_weibo",
                                      @(TTAccountAuthTypeTianYi)    : @"telecom",
                                      @(TTAccountAuthTypeRenRen)    : @"renren_sns",
                                      @(TTAccountAuthTypeKaixin)    : @"kaixin_sns",
                                      @(TTAccountAuthTypeFacebook)  : @"facebook",
                                      @(TTAccountAuthTypeTwitter)   : @"twitter",
                                      @(TTAccountAuthTypeHuoshan)   : @"live_stream",
                                      @(TTAccountAuthTypeDouyin)    : @"aweme",
                                      };
    }
    
    platformName = defaultPlatformNameMapper[@(type)];
    return platformName;
}

- (NSString *)tta_platformAppIdForPlatformType:(TTAccountAuthType)type
{
    return [self __platformConfigurationForType:type].platformAppId;
}

- (NSString *)tta_platformAppDisplayNameForPlatformType:(TTAccountAuthType)type
{
    return [self __platformConfigurationForType:type].platformAppDisplayName;
}

- (NSString *)tta_authSchemeCallbackURLForPlatformType:(TTAccountAuthType)type
{
    return [self __platformConfigurationForType:type].authCallbackSchemeUrl;
}

- (NSString *)tta_redirectURLForPlatformType:(TTAccountAuthType)type
{
    return [self __platformConfigurationForType:type].platformRedirectUrl;
}

- (NSString *)tta_scopeForPlatformType:(TTAccountAuthType)type
{
    return nil;
}

- (void)tta_laziedRegisterPlatformAppIDForPlatformType:(TTAccountAuthType)type
{
    void (^registerHandler)() = [self __platformConfigurationForType:type].laziedRegisterPlatformHandler;
    if (registerHandler) {
        registerHandler();
    }
}

- (BOOL)tta_useDefaultWAPLoginForPlatformType:(TTAccountAuthType)type
{
    return [self __platformConfigurationForType:type].useDefaultWAPLogin;
}

- (BOOL)tta_tryCustomWAPLoginWhenSDKFailureForPlatformType:(TTAccountAuthType)type
{
    return [self __platformConfigurationForType:type].tryCustomLoginWhenSDKFailure;
}

- (BOOL)tta_SNSBarHiddenForPlatformType:(TTAccountAuthType)type
{
    return [self __platformConfigurationForType:type].snsBarHidden;
}

- (NSString *)tta_SNSBarTextForPlatformType:(TTAccountAuthType)type
{
    return [self __platformConfigurationForType:type].snsBarText;
}

#pragma mark - Bytedancebase SDK

- (NSString *)tta_platformAppInstallUrlForPlatformType:(TTAccountAuthType)type
{
    return [self __platformConfigurationForType:type].platformAppInstallUrl;
}

- (NSArray<NSString *> *)tta_platformAppInstalledSchemesForPlatformType:(TTAccountAuthType)type
{
    return [[self __platformConfigurationForType:type].platformInstalledURLSchemes copy];
}

- (NSArray<NSString *> *)tta_platformAppSupportedSchemesForPlatformType:(TTAccountAuthType)type
{
    return [[self __platformConfigurationForType:type].platformSupportedURLSchemes copy];
}

#pragma mark - privates

- (TTAccountPlatformConfiguration *)__platformConfigurationForType:(TTAccountAuthType)type
{
    NSDictionary<NSString *, TTAccountPlatformConfiguration *> *confs = [self.platformConfigurations copy];
    
    NSAssert([confs count] > 0, @"Must call [TTAccount registerConfiguration:] to configrate platform (%ld) at [application:didFinishLaunchingWithOptions:]", (long)type);
    
    TTAccountPlatformConfiguration *platformConf = [confs valueForKey:TTAccountEnumString(type)];
    if (!platformConf) {
        NSLog(@"Platform (%ld) configuration is nil, check if call [TTAccount registerConfiguration:] to configrate platform", (long)type);
    }
    return platformConf;
}

@end
