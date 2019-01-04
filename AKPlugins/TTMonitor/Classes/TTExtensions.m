//
//  TTExtensions.m
//  TTLive
//
//  Created by Ray on 16/3/4.
//  Copyright © 2016年 Nick Yu. All rights reserved.
//

#import "TTExtensions.h"
#include <sys/socket.h>
#include <sys/sysctl.h>
#include <net/if.h>
#include <net/if_dl.h>
#include <netdb.h>
#include <arpa/inet.h>
#include <sys/xattr.h>
#import <zlib.h>
#import <stdlib.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <CoreTelephony/CTCarrier.h>
#import <AdSupport/AdSupport.h>
#import "TTReachability.h"

static NSString *currentWWANName = nil;
static CTTelephonyNetworkInfo *sharedNetworkInfo = nil;

@implementation TTExtensions

+ (NSString*)bundleIdentifier{
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"];
}

+ (NSString*)versionName{
    return [[NSBundle  mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
}

+ (NSString*)buildVersion{
    //    NSString * buildVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];
    NSString * buildVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"UPDATE_VERSION_CODE"];
    
    if (buildVersion) {
        return [buildVersion stringByReplacingOccurrencesOfString:@"." withString:@""];
    }
    return nil;
}

+ (BOOL)isJailBroken
{
    NSString *filePath = @"/Applications/Cydia.app";
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        return YES;
    }
    
    filePath = @"/private/var/lib/apt";
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        return YES;
    }
    
    return NO;
}

+ (NSString*)carrierName
{
    CTTelephonyNetworkInfo *netinfo = [[CTTelephonyNetworkInfo alloc] init];
    CTCarrier *carrier = [netinfo subscriberCellularProvider];
    NSString *name = [carrier carrierName];
    return name;
}

+ (NSString*)carrierMCC
{
    CTTelephonyNetworkInfo *netInfo = [[CTTelephonyNetworkInfo alloc] init];
    CTCarrier *carrier = [netInfo subscriberCellularProvider];
    NSString *mcc = [carrier mobileCountryCode];
    return mcc;
}

+ (NSString*)carrierMNC{
    CTTelephonyNetworkInfo *netInfo = [[CTTelephonyNetworkInfo alloc] init];
    CTCarrier *carrier = [netInfo subscriberCellularProvider];
    NSString *mnc = [carrier mobileNetworkCode];
    return mnc;
}

+ (NSString*)connectMethodName
{
    return [TTExtensions _stringFromNetworkStatus:[TTExtensions _syncToGetCurrentNetWorkStatus]];
}

+ (NSString*)appDisplayName
{
    NSString *appName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"];
    if (!appName){
        appName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleName"];
    }
    return appName;
}

static NSString * currentOSVersion = nil;

+ (NSString*)OSVersion
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        currentOSVersion = [[[UIDevice currentDevice] systemVersion] copy];
    });
    
    return currentOSVersion;
}

+ (NSString*)currentLanguage
{
    return [[NSLocale preferredLanguages] objectAtIndex:0];
}

+ (NSString *)MACAddress
{
    int                 mgmtInfoBase[6];
    char                *msgBuffer = NULL;
    size_t              length;
    unsigned char       macAddress[6];
    struct if_msghdr    *interfaceMsgStruct;
    struct sockaddr_dl  *socketStruct;
    NSString            *errorFlag = NULL;
    mgmtInfoBase[0] = CTL_NET;        // Request network subsystem
    mgmtInfoBase[1] = AF_ROUTE;       // Routing table info
    mgmtInfoBase[2] = 0;
    mgmtInfoBase[3] = AF_LINK;        // Request link layer information
    mgmtInfoBase[4] = NET_RT_IFLIST;  // Request all configured interfaces
    if ((mgmtInfoBase[5] = if_nametoindex("en0")) == 0)
        errorFlag = @"if_nametoindex failure";
    else
    {
        if (sysctl(mgmtInfoBase, 6, NULL, &length, NULL, 0) < 0)
            errorFlag = @"sysctl mgmtInfoBase failure";
        else
        {
            if ((msgBuffer = malloc(length)) == NULL)
                errorFlag = @"buffer allocation failure";
            else
            {
                if (sysctl(mgmtInfoBase, 6, msgBuffer, &length, NULL, 0) < 0)
                    errorFlag = @"sysctl msgBuffer failure";
            }
        }
    }
    if (errorFlag != NULL)
    {
        free(msgBuffer);
        return errorFlag;
    }
    interfaceMsgStruct = (struct if_msghdr *) msgBuffer;
    socketStruct = (struct sockaddr_dl *) (interfaceMsgStruct + 1);
    NSString *macAddressString = @"00:00:00:00:00:00";
    if (socketStruct != nil) {
        memcpy(&macAddress, socketStruct->sdl_data + socketStruct->sdl_nlen, 6);
        macAddressString = [NSString stringWithFormat:@"%02X:%02X:%02X:%02X:%02X:%02X",
                            macAddress[0], macAddress[1], macAddress[2],
                            macAddress[3], macAddress[4], macAddress[5]];
    }
    free(msgBuffer);
    return macAddressString;
}

+ (NSString*)openUDID{
    return nil;
}

+ (NSString*)ssAppID
{
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"SSAppID"];
}

+ (NSString*)idfaString
{
    if([self OSVersionNumber] >= 6.0)
    {
        NSString *idfa = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
        return idfa;
    }
    return nil;
}


static float currentOsVersionNumber = 0;
+ (float)OSVersionNumber
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        currentOsVersionNumber = [[[UIDevice currentDevice] systemVersion] floatValue];
    });
    return currentOsVersionNumber;
}


+ (CGSize)resolution
{
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    float scale = [[UIScreen mainScreen] scale];
    CGSize resolution = CGSizeMake(screenBounds.size.width * scale, screenBounds.size.height * scale);
    return resolution;
}

+ (NSString *)resolutionString
{
    CGSize resolution = [self resolution];
    return [NSString stringWithFormat:@"%d*%d", (int)resolution.width, (int)resolution.height];
}

+ (NSString *)generateUUID{
    CFUUIDRef uuidObject = CFUUIDCreate(kCFAllocatorDefault);
    NSString *uuidStr = (NSString *)CFBridgingRelease(CFUUIDCreateString(kCFAllocatorDefault, uuidObject));
    CFRelease(uuidObject);
    return uuidStr;
}

+ (NSString *)userAgentString
{
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSString *appName = [bundle objectForInfoDictionaryKey:@"CFBundleName"];
    if (!appName) {
        appName = [bundle objectForInfoDictionaryKey:@"CFBundleName"];
    }
    NSData *latin1Data = [appName dataUsingEncoding:NSUTF8StringEncoding];
    appName = [[NSString alloc] initWithData:latin1Data encoding:NSISOLatin1StringEncoding];
    if (!appName) {
        return nil;
    }
    NSString *appVersion = nil;
    NSString *marketingVersionNumber = [bundle objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    NSString *developmentVersionNumber = [bundle objectForInfoDictionaryKey:@"CFBundleVersion"];
    if (marketingVersionNumber && developmentVersionNumber) {
        if ([marketingVersionNumber isEqualToString:developmentVersionNumber]) {
            appVersion = marketingVersionNumber;
        } else {
            appVersion = [NSString stringWithFormat:@"%@ rv:%@",marketingVersionNumber,developmentVersionNumber];
        }
    } else {
        appVersion = (marketingVersionNumber ? marketingVersionNumber : developmentVersionNumber);
    }
    
    NSString *deviceName;
    NSString *OSName;
    NSString *OSVersion;
    NSString *locale = [[NSLocale currentLocale] localeIdentifier];
    
    UIDevice *device = [UIDevice currentDevice];
    deviceName = [device model];
    OSName = [device systemName];
    OSVersion = [device systemVersion];
    
    NSString * userAgentStr = [NSString stringWithFormat:@"%@ %@ (%@ %@ %@ %@)", appName, appVersion, deviceName, OSName, OSVersion, locale];
    return userAgentStr;
}

+ (NSString*)_dictToUrlComponentsFor:(NSDictionary *)params
{
    NSMutableArray* args = [NSMutableArray arrayWithCapacity:[params count]];
    NSArray *allKey = [params allKeys];
    for (NSString* key in allKey) {
        [args addObject:[NSString stringWithFormat:
                         @"%@=%@",key, [params objectForKey:key]]];
    }
    return [args componentsJoinedByString:@"&"];
}

+ (NSString*)joinBaseUrlStr:(NSString*)baseUrl withParams:(NSDictionary*)params
{
    if (TTIsEmpty(params)) {
        return baseUrl;
    }
    NSString* joinCharactor = [baseUrl rangeOfString:@"?"].location==NSNotFound ? @"?" : @"&";
    NSString *newURL = [NSString stringWithFormat:@"%@%@%@",
                        baseUrl,
                        joinCharactor,
                        [TTExtensions _dictToUrlComponentsFor:params]];
    return newURL;
}


+ (CTTelephonyNetworkInfo *)_getGlobalTelephonyNetworkInfo
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedNetworkInfo = [CTTelephonyNetworkInfo new];
        if ([[[UIDevice currentDevice] systemVersion] floatValue]>=7.0) {
            currentWWANName = sharedNetworkInfo.currentRadioAccessTechnology;
            [NSNotificationCenter.defaultCenter addObserverForName:CTRadioAccessTechnologyDidChangeNotification
                                                            object:nil
                                                             queue:nil
                                                        usingBlock:^(NSNotification *note)
             {
                 currentWWANName = sharedNetworkInfo.currentRadioAccessTechnology;
             }];
        }
    });
    
    return sharedNetworkInfo;
}

+ (MNetworkStatus)_syncToGetCurrentNetWorkStatus
{
    [TTExtensions _getGlobalTelephonyNetworkInfo];
    NetworkStatus status = [[TTReachability reachabilityWithHostName:@"www.apple.com"] currentReachabilityStatus];
    if (status==ReachableViaWiFi) {
        return MNReachableViaWiFi;
    }else
    if (status == ReachableViaWWAN) {
        if (currentWWANName.length > 0) {
            if ([currentWWANName isEqualToString:CTRadioAccessTechnologyGPRS] ||
                [currentWWANName isEqualToString:CTRadioAccessTechnologyEdge] ||
                [currentWWANName isEqualToString:CTRadioAccessTechnologyCDMA1x]) {
                return MNReachableVia2G;
            } else if ([currentWWANName isEqualToString:CTRadioAccessTechnologyLTE]) {
                return MNReachableVia4G;
            } else{
                return MNReachableVia3G;
            }
        }
    }
    
    return status;
}

+ (NSString *)_stringFromNetworkStatus:(MNetworkStatus)netStatus
{
    switch (netStatus) {
        case MNNotReachable:{
            return @"none";
        }
            break;
        case MNReachableViaWWAN:{
            return @"mobile";
        }
            break;
        case MNReachableViaWiFi:{
            return @"wifi";
        }
            break;
        case MNReachableVia2G:{
            return @"2g";
        }
            break;
        case MNReachableVia3G:{
            return @"3g";
        }
            break;
        case MNReachableVia4G:{
            return @"4g";
        }
            break;
            
        default:
            break;
    }
    return @"mobile";
}

+ (void)applyCookieHeader:(NSMutableURLRequest*)request{
    
    NSArray *cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies];
    
    
    if ([cookies count] > 0) {
        NSHTTPCookie *cookie;
        NSString *cookieHeader = nil;
        for (cookie in cookies) {
            if (!cookieHeader) {
                cookieHeader = [NSString stringWithFormat: @"%@=%@",[cookie name],[cookie value]];
            } else {
                cookieHeader = [NSString stringWithFormat: @"%@; %@=%@",cookieHeader,[cookie name],[cookie value]];
            }
        }
        if (cookieHeader) {
            [request setValue: cookieHeader forHTTPHeaderField:@"Cookie"];
            [request setValue: cookieHeader forHTTPHeaderField:@"X-SS-Cookie"];
        }
    }
}

+ (MNetworkStatus)networkStatus{
    return [self _syncToGetCurrentNetWorkStatus];
}

+ (NSString *)getCurrentChannel{
   return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CHANNEL_NAME"];
}


+ (NSString*)URLString:(NSString *)URLStr appendCommonParams:(NSDictionary *)commonParams
{
    if ((!URLStr || ![URLStr isKindOfClass:[NSString class]] || URLStr.length == 0)) {
        return nil;
    }
    if ([commonParams count] == 0) {
        return URLStr;
    }
    URLStr = [URLStr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    NSString *sep = @"?";
    if ([URLStr rangeOfString:@"?"].location != NSNotFound) {
        sep = @"&";
    }
    
    NSMutableString *query = [NSMutableString new];
    for (NSString *key in [commonParams allKeys]) {
        [query appendFormat:@"%@%@=%@", sep, key, commonParams[key]];
        sep = @"&";
    }
    
    NSString *result = [NSString stringWithFormat:@"%@%@", URLStr, query];
    if ([NSURL URLWithString:result]) {
        return result;
    }
    
    if ([NSURL URLWithString:URLStr]) {
        query = [query stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        if (query) { // 如果query里含有不可转义的字符，会返回nil。
            NSString *result = [NSString stringWithFormat:@"%@%@", URLStr, query];
            if ([NSURL URLWithString:result]) {
                return result;
            }
        }
        return URLStr;
    }
    
    // 走到这里，说明 URLStr 不合法，可能含有空格或汉字等；或者 query 包含不可转义的字符；
    // 此时如果 URLStr 既包含 % 又包含空格或汉字等需百分号转义的字符，进行百分号转义后依然是错误的；
    // URLStr 是我们调用时传进来的，原则上应该保证其是一个合法的URL。
    return [result stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}


+ (NSData *)gzipDeflate:(NSData*) src{
    if ([src length] == 0) return src;
    z_stream strm;
    strm.zalloc = Z_NULL;
    strm.zfree = Z_NULL;
    strm.opaque = Z_NULL;
    strm.total_out = 0;
    strm.next_in=(Bytef *)[src bytes];
    strm.avail_in = (uInt)[src length];
    if (deflateInit2(&strm, Z_DEFAULT_COMPRESSION, Z_DEFLATED, (15+16), 8, Z_DEFAULT_STRATEGY) != Z_OK) return nil;
    NSMutableData *compressed = [NSMutableData dataWithLength:16384];  // 16K chunks for expansion
    do {
        if (strm.total_out >= [compressed length])
            [compressed increaseLengthBy: 16384];
        strm.next_out = [compressed mutableBytes] + strm.total_out;
        strm.avail_out = (uInt)([compressed length] - strm.total_out);
        deflate(&strm, Z_FINISH);
        
    } while (strm.avail_out == 0);
    deflateEnd(&strm);
    [compressed setLength: strm.total_out];
    return [NSData dataWithData:compressed];
}

+ (NSString*)addressOfHost:(NSString*)host {
    struct addrinfo hints, *res, *p;
    int status;
    char ipstr[INET6_ADDRSTRLEN];
    memset(&hints, 0, sizeof hints);
    hints.ai_family = AF_UNSPEC; // AF_INET or AF_INET6 to force version
    hints.ai_socktype = SOCK_STREAM;
    
    if ((status = getaddrinfo([host UTF8String], "http", &hints, &res)) != 0) {
        fprintf(stderr, "getaddrinfo: %s\n", gai_strerror(status));
        return @"";
    }
    
    NSMutableArray *resultList = [NSMutableArray array];
    
    for(p = res;p != NULL; p = p->ai_next) {
        void *addr;
        char *ipver;
        
        // get the pointer to the address itself,
        // different fields in IPv4 and IPv6:
        if (p->ai_family == AF_INET) { // IPv4
            struct sockaddr_in *ipv4 = (struct sockaddr_in *)p->ai_addr;
            addr = &(ipv4->sin_addr);
            ipver = "IPv4";
        } else { // IPv6
            struct sockaddr_in6 *ipv6 = (struct sockaddr_in6 *)p->ai_addr;
            addr = &(ipv6->sin6_addr);
            ipver = "IPv6";
        }
        
        // convert the IP to a string and print it:
        const char* ip = inet_ntop(p->ai_family, addr, ipstr, sizeof ipstr);
        printf("  %s: %s\n", ipver, ipstr);
        
        [resultList addObject:[NSString stringWithUTF8String:ip]];
    }
    freeaddrinfo(res); // 释放 getaddrinfo() 返回的 res 链表
    if (resultList.count>0) {
        return [resultList objectAtIndex:0];
    }
    return @"";
}

+ (NSDateFormatter*)_dateformatter
{
    static NSDateFormatter* formatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
        NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"];
        [formatter setLocale:locale];
    });
    return formatter;
}
@end
