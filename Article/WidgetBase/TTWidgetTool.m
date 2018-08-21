//
//  TTWidgetTool.m
//  Article
//
//  Created by xushuangqing on 2017/6/19.
//
//

#import "TTWidgetTool.h"
#import <TTBaseLib/TTBaseMacro.h>
#include <sys/sysctl.h>
#include <sys/socket.h>
#include <sys/xattr.h>
#include <net/if.h>
#include <net/if_dl.h>
#import <AdSupport/AdSupport.h>
#import "SSkeyChainStorage.h"
#import <TTBaseLib/TTNetworkHelper.h>
#import "ExploreExtenstionDataHelper.h"

#define IFPGA_NAMESTRING                @"iFPGA"

#define IPHONE_1G_NAMESTRING            @"iPhone 1G"
#define IPHONE_3G_NAMESTRING            @"iPhone 3G"
#define IPHONE_3GS_NAMESTRING           @"iPhone 3GS"
#define IPHONE_4_NAMESTRING             @"iPhone 4"
#define IPHONE_4S_NAMESTRING            @"iPhone 4S"
#define IPHONE_5GSM_NAMESTRING          @"iPhone 5 (GSM)"
#define IPHONE_5Global_NAMESTRING       @"iPhone 5 (Global)"
#define IPHONE_5C_NAMESTRING            @"iPhone 5C"
#define IPHONE_5S_NAMESTRING            @"iPhone 5S"
#define IPHONE_6_NAMESTRING             @"iPhone 6"
#define IPHONE_6_PLUS_NAMESTRING        @"iPhone 6 Plus"
#define IPHONE_6S_NAMESTRING            @"iPhone 6S"
#define IPHONE_6S_PLUS_NAMESTRING       @"iPhone 6S Plus"
#define IPHONE_SE                       @"iPhone SE"
#define IPHONE_7_NAMESTRING             @"iPhone 7"
#define IPHONE_7_PLUS_NAMESTRING        @"iPhone 7 Plus"



#define IPHONE_UNKNOWN_NAMESTRING       @"Unknown iPhone"


#define IPOD_1G_NAMESTRING              @"iPod touch 1G"
#define IPOD_2G_NAMESTRING              @"iPod touch 2G"
#define IPOD_3G_NAMESTRING              @"iPod touch 3G"
#define IPOD_4G_NAMESTRING              @"iPod touch 4G"
#define IPOD_5G_NAMESTRING              @"iPod touch 5G"
#define IPOD_UNKNOWN_NAMESTRING         @"Unknown iPod"

#define IPAD_1G_NAMESTRING              @"iPad 1G"
#define IPAD_2G_NAMESTRING              @"iPad 2G"
#define IPAD_3G_NAMESTRING              @"iPad 3G"
#define IPAD_4G_NAMESTRING              @"iPad 4G"
#define IPAD_AIR_NAMESTRING             @"iPad AIR"
#define IPAD_MINI_Retina_NAMESTRING     @"iPad Mini Retina"
#define IPAD_MINI_NAMESTRING            @"ipad Mini"
#define IPAD_PRO_NAMESTRING             @"ipad Pro"
#define IPAD_UNKNOWN_NAMESTRING         @"Unknown iPad"

#define APPLETV_2G_NAMESTRING           @"Apple TV 2G"
#define APPLETV_UNKNOWN_NAMESTRING      @"Unknown Apple TV"

#define IOS_FAMILY_UNKNOWN_DEVICE       @"Unknown iOS device"

#define IPHONE_SIMULATOR_NAMESTRING         @"iPhone Simulator"
#define IPHONE_SIMULATOR_IPHONE_NAMESTRING  @"iPhone Simulator"
#define IPHONE_SIMULATOR_IPAD_NAMESTRING    @"iPad Simulator"

typedef enum {
    UIDeviceUnknown,
    
    UIDeviceiPhoneSimulator,
    UIDeviceiPhoneSimulatoriPhone, // both regular and iPhone 4 devices
    UIDeviceiPhoneSimulatoriPad,
    
    UIDevice1GiPhone,
    UIDevice3GiPhone,
    UIDevice3GSiPhone,
    UIDevice4iPhone,
    UIDevice4siPhone,
    UIDevice5GSMiPhone,
    UIDevice5GlobaliPhone,
    UIDevice5CiPhone,
    UIDevice5SiPhone,
    UIDevice6iPhone,
    UIDevice6PlusiPhone,
    UIDevice6SiPhone,
    UIDevice6SPlusiPhone,
    UIDeviceSEiPhone,
    UIDevice7_1iPhone,
    UIDevice7_3iPhone,
    UIDevice7_2PlusiPhone,
    UIDevice7_4PlusiPhone,
    
    UIDevice1GiPod,
    UIDevice2GiPod,
    UIDevice3GiPod,
    UIDevice4GiPod,
    UIDevice5GiPod,
    
    UIDevice1GiPad,
    UIDevice2GiPad,
    UIDevice3GiPad,
    UIDevice4GiPad,
    UIDeviceAiriPad,
    UIDeviceiPadMiniRetina,
    UIDeviceiPadMini,
    UIDeviceiPadPro,
    
    UIDeviceAppleTV2,
    UIDeviceUnknownAppleTV,
    
    UIDeviceUnknowniPhone,
    UIDeviceUnknowniPod,
    UIDeviceUnknowniPad,
    UIDeviceIFPGA,
    
} UIDevicePlatform;

@implementation TTWidgetTool

#pragma mark - URLWithURLString

+ (NSURL *)URLWithURLString:(NSString *)str {
    if (isEmptyString(str)) {
        return nil;
    }
    NSString *fixStr = [str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSURL *u = [NSURL URLWithString:fixStr];
    if (!u) {
        u = [NSURL URLWithString:[fixStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    }
    return u;
}

#pragma mark - OSVersionNumber

+ (float)OSVersionNumber {
    static float currentOsVersionNumber = 0;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        currentOsVersionNumber = [[[UIDevice currentDevice] systemVersion] floatValue];
    });
    return currentOsVersionNumber;
}

#pragma mark - ssOnePixel

+ (CGFloat)ssOnePixel {
    return 1.0f / [[UIScreen mainScreen] scale];
}

#pragma mark - ssAppScheme

+ (NSString *)ssAppScheme {
    NSString * mid = [self ssAppMID];
    if (mid) {
        return [NSString stringWithFormat:@"snssdk%@://", mid];
    }
    NSLog(@"*** CAN NOT generate AppScheme");
    return nil;
}

+ (NSString *)ssAppMID {
    NSString * mid = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"SSMID"];
    if (!mid) {
        NSLog(@"*** NO SSMID set in plist");
    }
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"SSMID"];
}

#pragma mark - customURLStringFromString:supportedMix:

+ (NSString*)customURLStringFromString:(NSString*)urlStr supportedMix:(BOOL)supportedMix
{
    if (isEmptyString(urlStr)) {
        return nil;
    }
    NSRange range = [urlStr rangeOfString:@"?"];
    __block NSString *sep = (range.location == NSNotFound) ? @"?" : @"&";
    NSMutableString *string = [NSMutableString stringWithString:urlStr];
    NSDictionary *params = [self commonHeaderDictionaryWithSupportedMix:supportedMix];
    NSMutableDictionary * newParams = [[NSMutableDictionary alloc] initWithDictionary:params];
    [newParams enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        NSString *stringKey = key;
        NSString *stringValue = obj;
        NSString *queryString = [NSString stringWithFormat:@"%@=", key];
        if (!isEmptyString(stringValue) && [string rangeOfString:queryString].location == NSNotFound) {
            stringValue = [stringValue stringByAddingPercentEscapesUsingEncoding :NSUTF8StringEncoding];
            [string appendFormat:@"%@%@=%@", sep, stringKey, stringValue];
            sep = @"&";
        }
    }];
    return [string copy];
}

+ (NSDictionary *)commonHeaderDictionaryWithSupportedMix:(BOOL)supportedMix
{
    NSMutableDictionary *params = @{}.mutableCopy;
    NSString * iid = [self _installID];
    if (!isEmptyString(iid)) {
        params[@"iid"] = iid;
    }
    if (supportedMix) {
        params[@"ssmix"] = @"a";
    }
    if ([TTNetworkHelper connectMethodName]) {
        params[@"ac"] = [TTNetworkHelper connectMethodName];
    }
    if ([self getCurrentChannel]) {
        params[@"channel"] = [self getCurrentChannel];
    }
    if ([self appName]) {
        params[@"app_name"] = [self appName];
    }
    if(!isEmptyString([self ssAppID])){
        params[@"aid"] = [self ssAppID];
    }
    if([self versionName]) {
        params[@"version_code"] = [self versionName];
    }
    if ([self platformName]) {
        params[@"device_platform"] = [self platformName];
    }
    if([self OSVersionNumber]){
        params[@"os_version"] = [[UIDevice currentDevice] systemVersion];
    }
    if ([self platformString]) {
        params[@"device_type"] = [self platformString];
    }
    if([[UIDevice currentDevice] respondsToSelector:@selector(identifierForVendor)]){
        NSString *vid = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
        if(!isEmptyString(vid)){
            params[@"vid"] = vid;
        }
    }
    if (!isEmptyString([ExploreExtenstionDataHelper sharedDeviceID])) {
        params[@"device_id"] = [ExploreExtenstionDataHelper sharedDeviceID];
    }
    
    if ([self openUDID]) {
        params[@"openudid"] = [self openUDID];
    }

    if (!isEmptyString([self idfaString])) {
        params[@"idfa"] = [self idfaString];
    }
    
    if ([self resolutionString]) {
        params[@"resolution"] = [self resolutionString];
    }
    
    return [params copy];
}

+ (NSString *)_installID {
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"kInstallIDStorageKey"];
}

+ (NSString *)getCurrentChannel {
    static NSString *channelName;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        channelName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CHANNEL_NAME"];
    });
    return channelName;
}

+ (NSString*)appName {
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"AppName"];
}

+ (NSString*)ssAppID {
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"SSAppID"];
}

+ (NSString*)versionName {
    return [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
}

+ (NSString*)platformName {
    NSString *result = [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad ? @"ipad" : @"iphone";
    return result;
}

+ (NSUInteger) platformType
{
    NSString *platform = [self platform];
    
    // The ever mysterious iFPGA
    if ([platform isEqualToString:@"iFPGA"])        return UIDeviceIFPGA;
    
    // iPhone
    if ([platform isEqualToString:@"iPhone1,1"])    return UIDevice1GiPhone;
    if ([platform isEqualToString:@"iPhone1,2"])    return UIDevice3GiPhone;
    if ([platform hasPrefix:@"iPhone2"])            return UIDevice3GSiPhone;
    if ([platform hasPrefix:@"iPhone3"])            return UIDevice4iPhone;
    if ([platform hasPrefix:@"iPhone4"])            return UIDevice4siPhone;
    if ([platform isEqualToString:@"iPhone5,1"])    return UIDevice5GSMiPhone;
    if ([platform isEqualToString:@"iPhone5,2"])    return UIDevice5GlobaliPhone;
    if ([platform isEqualToString:@"iPhone5,3"] || [platform isEqualToString:@"iPhone5,4"])    return UIDevice5CiPhone;
    if ([platform isEqualToString:@"iPhone6,1"] || [platform isEqualToString:@"iPhone6,2"])    return UIDevice5SiPhone;
    if ([platform isEqualToString:@"iPhone7,1"])    return UIDevice6PlusiPhone;
    if ([platform isEqualToString:@"iPhone7,2"])    return UIDevice6iPhone;
    if ([platform isEqualToString:@"iPhone8,1"])    return UIDevice6SiPhone;
    if ([platform isEqualToString:@"iPhone8,2"])    return UIDevice6SPlusiPhone;
    if ([platform isEqualToString:@"iPhone8,4"])    return UIDeviceSEiPhone;
    if ([platform isEqualToString:@"iPhone9,1"])    return UIDevice7_1iPhone;
    if ([platform isEqualToString:@"iPhone9,3"])    return UIDevice7_3iPhone;
    if ([platform isEqualToString:@"iPhone9,2"])    return UIDevice7_2PlusiPhone;
    if ([platform isEqualToString:@"iPhone9,4"])    return UIDevice7_4PlusiPhone;
    
    // iPod
    if ([platform hasPrefix:@"iPod1"])              return UIDevice1GiPod;
    if ([platform hasPrefix:@"iPod2"])              return UIDevice2GiPod;
    if ([platform hasPrefix:@"iPod3"])              return UIDevice3GiPod;
    if ([platform hasPrefix:@"iPod4"])              return UIDevice4GiPod;
    if ([platform hasPrefix:@"iPod5"])              return UIDevice5GiPod;
    
    // iPad
    if ([platform hasPrefix:@"iPad1"])              return UIDevice1GiPad;
    if ([platform hasPrefix:@"iPad2,5"] || [platform hasPrefix:@"iPad2,6"] || [platform hasPrefix:@"iPad2,7"])            return UIDeviceiPadMini;
    if ([platform hasPrefix:@"iPad2,1"] || [platform hasPrefix:@"iPad2,2"] || [platform hasPrefix:@"iPad2,3"] || [platform hasPrefix:@"iPad2,4"])              return UIDevice2GiPad;
    if ([platform isEqualToString:@"iPad3,1"] || [platform isEqualToString:@"iPad3,2"] || [platform isEqualToString:@"iPad3,3"])    return UIDevice3GiPad;
    if ([platform isEqualToString:@"iPad3,4"] || [platform isEqualToString:@"iPad3,5"] || [platform isEqualToString:@"iPad3,6"])    return UIDevice4GiPad;
    if ([platform isEqualToString:@"iPad4,1"] || [platform isEqualToString:@"iPad4,2"] || [platform isEqualToString:@"iPad4,3"])    return UIDeviceAiriPad;
    if ([platform isEqualToString:@"iPad4,4"] || [platform isEqualToString:@"iPad4,5"])    return UIDeviceiPadMiniRetina;
    if ([platform isEqualToString:@"iPad6,7"] || [platform isEqualToString:@"iPad6,8"]) {
        return UIDeviceiPadPro;
    }
    
    // Apple TV
    if ([platform hasPrefix:@"AppleTV2"])           return UIDeviceAppleTV2;
    
    if ([platform hasPrefix:@"iPhone"])             return UIDeviceUnknowniPhone;
    if ([platform hasPrefix:@"iPod"])               return UIDeviceUnknowniPod;
    if ([platform hasPrefix:@"iPad"])               return UIDeviceUnknowniPad;
    
    // Simulator thanks Jordan Breeding
    if ([platform hasSuffix:@"86"] || [platform isEqual:@"x86_64"])
    {
        BOOL smallerScreen = [[UIScreen mainScreen] bounds].size.width < 768;
        return smallerScreen ? UIDeviceiPhoneSimulatoriPhone : UIDeviceiPhoneSimulatoriPad;
    }
    
    return UIDeviceUnknown;
}

+ (NSString *) platformString
{
    switch ([self platformType])
    {
        case UIDevice1GiPhone: return IPHONE_1G_NAMESTRING;
        case UIDevice3GiPhone: return IPHONE_3G_NAMESTRING;
        case UIDevice3GSiPhone: return IPHONE_3GS_NAMESTRING;
        case UIDevice4iPhone: return IPHONE_4_NAMESTRING;
        case UIDevice4siPhone: return IPHONE_4S_NAMESTRING;
        case UIDevice5GSMiPhone: return IPHONE_5GSM_NAMESTRING;
        case UIDevice5GlobaliPhone: return IPHONE_5Global_NAMESTRING;
        case UIDevice5CiPhone:  return IPHONE_5C_NAMESTRING;
        case UIDevice5SiPhone: return IPHONE_5S_NAMESTRING;
        case UIDevice6iPhone: return IPHONE_6_NAMESTRING;
        case UIDevice6PlusiPhone: return IPHONE_6_PLUS_NAMESTRING;
        case UIDevice6SiPhone: return IPHONE_6S_NAMESTRING;
        case UIDevice6SPlusiPhone: return IPHONE_6S_PLUS_NAMESTRING;
        case UIDeviceSEiPhone: return IPHONE_SE;
        case UIDevice7_1iPhone: return IPHONE_7_NAMESTRING;
        case UIDevice7_3iPhone: return IPHONE_7_NAMESTRING;
        case UIDevice7_2PlusiPhone: return IPHONE_7_PLUS_NAMESTRING;
        case UIDevice7_4PlusiPhone: return IPHONE_7_PLUS_NAMESTRING;
            
            
        case UIDeviceUnknowniPhone: return [self platform];
            
        case UIDevice1GiPod: return IPOD_1G_NAMESTRING;
        case UIDevice2GiPod: return IPOD_2G_NAMESTRING;
        case UIDevice3GiPod: return IPOD_3G_NAMESTRING;
        case UIDevice4GiPod: return IPOD_4G_NAMESTRING;
        case UIDevice5GiPod: return IPOD_5G_NAMESTRING;
        case UIDeviceUnknowniPod: return [self platform];
            
        case UIDevice1GiPad : return IPAD_1G_NAMESTRING;
        case UIDevice2GiPad : return IPAD_2G_NAMESTRING;
        case UIDevice3GiPad : return IPAD_3G_NAMESTRING;
        case UIDevice4GiPad : return IPAD_4G_NAMESTRING;
        case UIDeviceAiriPad : return IPAD_AIR_NAMESTRING;
        case UIDeviceiPadMini: return IPAD_MINI_NAMESTRING;
        case UIDeviceiPadMiniRetina: return IPAD_MINI_Retina_NAMESTRING;
        case UIDeviceiPadPro: return IPAD_PRO_NAMESTRING;
        case UIDeviceUnknowniPad : return [self platform];
            
        case UIDeviceAppleTV2 : return APPLETV_2G_NAMESTRING;
        case UIDeviceUnknownAppleTV: return APPLETV_UNKNOWN_NAMESTRING;
            
        case UIDeviceiPhoneSimulator: return IPHONE_SIMULATOR_NAMESTRING;
        case UIDeviceiPhoneSimulatoriPhone: return IPHONE_SIMULATOR_IPHONE_NAMESTRING;
        case UIDeviceiPhoneSimulatoriPad: return IPHONE_SIMULATOR_IPAD_NAMESTRING;
            
        case UIDeviceIFPGA: return IFPGA_NAMESTRING;
            
        default: return IOS_FAMILY_UNKNOWN_DEVICE;
    }
}

+ (NSString *) getSysInfoByName:(char *)typeSpecifier
{
    size_t size;
    sysctlbyname(typeSpecifier, NULL, &size, NULL, 0);
    
    char *answer = malloc(size);
    sysctlbyname(typeSpecifier, answer, &size, NULL, 0);
    
    NSString *results = [NSString stringWithCString:answer encoding: NSUTF8StringEncoding];
    
    free(answer);
    return results;
}

+ (NSString *) platform
{
    return [self getSysInfoByName:"hw.machine"];
}

+ (NSString*)openUDID {
    return [ExploreExtenstionDataHelper sharedOpenUDID];
}

+ (NSString*)idfaString {
    return [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
}

+ (CGSize)resolution {
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    float scale = [[UIScreen mainScreen] scale];
    CGSize resolution = CGSizeMake(screenBounds.size.width * scale, screenBounds.size.height * scale);
    return resolution;
}


+ (NSString *)resolutionString {
    CGSize resolution = [self resolution];
    return [NSString stringWithFormat:@"%d*%d", (int)resolution.width, (int)resolution.height];
}

+ (NSString*)customtimeStringSince1970:(NSTimeInterval)timeInterval {
    if (midnightInterval == 0) {
        [self refreshMidnightInterval];
    }
    return [self customtimeStringSince1970:timeInterval midnightInterval:midnightInterval];
}

#pragma mark - customtimeStringSince1970:midnightInterval:

static NSDateFormatter *simpleFormatter;
static NSTimeInterval midnightInterval;//午夜时间

+ (void)refreshMidnightInterval {
    NSDateComponents *comp = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitYear | NSCalendarUnitMonth fromDate:[NSDate date]];
    [comp setHour:0];
    [comp setMinute:0];
    [comp setSecond:0];
    midnightInterval = [[[NSCalendar currentCalendar] dateFromComponents:comp] timeIntervalSince1970];
}

+ (NSString*)customtimeStringSince1970:(NSTimeInterval)timeInterval midnightInterval:(NSTimeInterval)midInterval {
    if (midnightInterval == 0) {
        [self refreshMidnightInterval];
    }
    NSString *retString = nil;
    if(timeInterval >= midInterval) {
        int t = [[NSDate date] timeIntervalSince1970] - timeInterval;
        if(t < 60) {
            retString = NSLocalizedString(@"刚刚", nil);
        }
        else if (t < 3600) {
            int val = t / 60;
            retString = [NSString stringWithFormat:NSLocalizedString(@"%d分钟前", nil), val];
        }
        else if(t < 24 * 3600) {
            int val = t / 3600;
            retString = [NSString stringWithFormat:NSLocalizedString(@"%d小时前", nil), val];
        }
        else {
            retString = [self simpleDateStringSince:timeInterval];
        }
    }
    else {
        retString = [self simpleDateStringSince:timeInterval];
    }
    return retString;
}

+ (NSString*)simpleDateStringSince:(NSTimeInterval)timerInterval {
    if (!simpleFormatter) {
        simpleFormatter = [[NSDateFormatter alloc] init];
        [simpleFormatter setDateFormat:@"MM-dd HH:mm"];
    }
    return [simpleFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:timerInterval]];
}

@end
