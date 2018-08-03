//
//  TTRNDeviceInfo.m
//  Article
//
//  Created by yangning on 2017/5/4.
//
//

#import "TTRNDeviceInfo.h"
#import "TTDeviceHelper.h"
#import "TTSandBoxHelper.h"
#import "TTInstallIDManager.h"

static NSString *const kAppNameKey   = @"appName";
static NSString *const kUrlSchemeKey = @"urlScheme";

@implementation TTRNDeviceInfo

RCT_EXPORT_MODULE()

- (dispatch_queue_t)methodQueue
{
    return dispatch_get_main_queue();
}

- (NSDictionary<NSString *, id> *)constantsToExport
{
    UIDevice *currentDevice = [UIDevice currentDevice];
    
    return @{
             @"systemName":         currentDevice.systemName ?: [NSNull null],
             @"systemVersion":      currentDevice.systemVersion ?: [NSNull null],
             @"model":              currentDevice.model ?: [NSNull null],
             @"brand":              @"Apple",
             @"deviceId":           [[TTInstallIDManager sharedInstance] deviceID] ?: [NSNull null],
             @"deviceName":         currentDevice.name ?: [NSNull null],
             @"deviceLocale":       [[NSLocale preferredLanguages] objectAtIndex:0],
             @"deviceCountry":      [[NSLocale currentLocale] objectForKey:NSLocaleCountryCode] ?: [NSNull null],
             @"bundleId":           [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleIdentifier"] ?: [NSNull null],
             @"appName":            [TTSandBoxHelper appName] ?: [NSNull null],
             @"appDisplayName":     [TTSandBoxHelper appDisplayName] ?: [NSNull null],
             @"appVersion":         [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"] ?: [NSNull null],
             @"buildNumber":        [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"] ?: [NSNull null],
             @"systemManufacturer": @"Apple",
             @"idfa":               [TTDeviceHelper idfaString] ?: [NSNull null],
             @"idfv":               [TTDeviceHelper idfvString] ?: [NSNull null],
             @"jailbroken":         @([TTDeviceHelper isJailBroken]),
             };
}

RCT_EXPORT_METHOD(isAppInstalled:(NSString *)urlScheme callback:(RCTResponseSenderBlock)callback)
{
    if (!callback) {
        return;
    }
    
    BOOL installed = [self isAppInstalled:urlScheme];
    callback(@[ @(installed) ]);
}

RCT_EXPORT_METHOD(isTaobaoInstalled:(RCTResponseSenderBlock)callback)
{
    [self isAppInstalled:@"taobao://" callback:callback];
}

RCT_EXPORT_METHOD(isAlipayInstalled:(RCTResponseSenderBlock)callback)
{
    [self isAppInstalled:@"alipay://" callback:callback];
}

RCT_EXPORT_METHOD(isTmallInstalled:(RCTResponseSenderBlock)callback)
{
    [self isAppInstalled:@"tmall://" callback:callback];
}

RCT_EXPORT_METHOD(isWeixinInstalled:(RCTResponseSenderBlock)callback)
{
    [self isAppInstalled:@"weixin://" callback:callback];
}

RCT_EXPORT_METHOD(isQQInstalled:(RCTResponseSenderBlock)callback)
{
    [self isAppInstalled:@"mqq://" callback:callback];
}

RCT_EXPORT_METHOD(isSinaWeiboInstalled:(RCTResponseSenderBlock)callback)
{
    [self isAppInstalled:@"sinaweibo://" callback:callback];
}

RCT_EXPORT_METHOD(isJDInstalled:(RCTResponseSenderBlock)callback)
{
    [self isAppInstalled:@"openapp.jdmobile://" callback:callback];
}

- (BOOL)isAppInstalled:(NSString *)urlScheme
{
    if (![urlScheme isKindOfClass:[NSString class]] || [urlScheme length] == 0) {
        return NO;
    }
    
    BOOL installed = NO;
    NSURL *URL = [NSURL URLWithString:urlScheme];
    if (URL && [[UIApplication sharedApplication] canOpenURL:URL]) {
        installed = YES;
    }
    return installed;
}

@end
