//
//  TTAccountConfiguration_Priv.m
//  TTAccountSDK
//
//  Created by liuzuopeng on 4/9/17.
//
//

#import "TTAccountConfiguration_Priv.h"
#import "TTAccount.h"



@implementation TTAccountConfiguration (tta_internal)

#pragma mark - internal methods

- (NSDictionary *)tta_appRequiredParameters
{
    return self.appRequiredParamsHandler ? [self.appRequiredParamsHandler() copy] : nil;
}

- (NSDictionary *)tta_commonNetworkParameters
{
    NSMutableDictionary *mutParamsDict = [NSMutableDictionary dictionary];
    NSDictionary *commonParams = self.networkParamsHandler ? self.networkParamsHandler() : nil;
    if (commonParams && [commonParams count] > 0) {
        [mutParamsDict addEntriesFromDictionary:commonParams];
    }
    
    NSDictionary *appRequiredParams = [self tta_appRequiredParameters];
    if (appRequiredParams && [appRequiredParams count] > 0) {
        [mutParamsDict addEntriesFromDictionary:appRequiredParams];
    }
    
    return ([mutParamsDict count] > 0 ? [mutParamsDict copy] : nil);
}

+ (NSDictionary *)tta_defaultURLParameters
{
    NSMutableDictionary *result = [NSMutableDictionary dictionaryWithCapacity:2];
    
    NSString *channelString = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CHANNEL_NAME"];
    [result setValue:channelString forKey:@"channel"];
    
    NSString *appNameString = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"AppName"];
    [result setValue:appNameString forKey:@"app_name"];
    
    NSString *aidString = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"SSAppID"];
    [result setValue:aidString forKey:@"aid"];
    
    NSString *shortVerString = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    [result setValue:shortVerString forKey:@"version_code"];
    
    NSString *platformNameString = [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad ? @"ipad" : @"iphone";
    [result setValue:platformNameString forKey:@"device_platform"];
    
    [result setValue:[[UIDevice currentDevice] systemVersion] forKey:@"os_version"];
    
    NSString *vendorId = [[UIDevice currentDevice].identifierForVendor UUIDString];
    [result setValue:vendorId forKey:@"vid"];
    [result setValue:vendorId forKey:@"vendor_id"];
    
    // 广告标识
    // NSString *idfaString = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
    // [result setValue:idfaString forKey:@"idfa"];
    
    NSString *idfvString = nil;
    if([[UIDevice currentDevice] respondsToSelector:@selector(identifierForVendor)]) {
        idfvString = [[UIDevice currentDevice].identifierForVendor UUIDString];
    }
    [result setValue:idfvString forKey:@"idfv"];
    
    CGFloat scale = [[UIScreen mainScreen] scale];
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    CGSize resolution = CGSizeMake(screenBounds.size.width * scale, screenBounds.size.height * scale);
    NSString *resolutionString = [NSString stringWithFormat:@"%d*%d", (int)resolution.width, (int)resolution.height];
    [result setValue:resolutionString forKey:@"resolution"];
    
    [result setValue:@"a" forKey:@"ssmix"];
    
    [result setValue:[[TTAccount accountConf] tta_deviceID] forKey:@"device_id"];
    [result setValue:[[TTAccount accountConf] tta_installID] forKey:@"install_id"];
    
    return result;
}

- (UIViewController *)tta_currentViewController
{
    return self.visibleViewControllerHandler ? self.visibleViewControllerHandler() : nil;
}

+ (NSString *)tta_appBundleID
{
    static NSString *s_bundleIDString = nil;
    if (!s_bundleIDString) {
        s_bundleIDString = [[NSBundle mainBundle] bundleIdentifier];
    }
    return s_bundleIDString;
}

- (NSString *)tta_ssAppID
{
    static NSString *ssAppID = nil;
    if (!ssAppID) {
        NSDictionary *requiredParams = [self tta_appRequiredParameters];
        if (requiredParams) {
            ssAppID = requiredParams[TTAccountSSAppIdKey];
        }
        if (!ssAppID) {
            ssAppID = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"SSAppID"];
        }
    }
    return ssAppID;
}

- (NSString *)tta_ssMID
{
    static NSString *ssMID = nil;
    if (!ssMID) {
        ssMID = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"SSMID"];
    }
    return ssMID;
}

- (NSString *)tta_deviceID
{
    NSString *deviceIDString = nil;
    NSDictionary *requiredParams = [self tta_appRequiredParameters];
    if (requiredParams) {
        deviceIDString = requiredParams[TTAccountDeviceIdKey];
    }
    return deviceIDString;
}

- (NSString *)tta_installID
{
    NSString *installIDString = nil;
    NSDictionary *requiredParams = [self tta_appRequiredParameters];
    if (requiredParams) {
        installIDString = requiredParams[TTAccountInstallIdKey];
    }
    return installIDString;
}

- (NSString *)tta_sharingKeyChainGroup
{
    return self.sharingKeyChainGroup;
}

@end
