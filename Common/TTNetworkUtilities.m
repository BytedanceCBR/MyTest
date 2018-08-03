//
//  TTNetworkUtilities.m
//  Article
//
//  Created by SunJiangting on 15-4-24.
//
//

#import "TTNetworkUtilities.h"
#import "SSCommon.h"
#import "UIDevice-Hardware.h"
#import "Foundation+STKit.h"
#import "DNSManager.h"
#import "NewsUserSettingManager.h"
#import "ExploreArchitectureManager.h"
#import "FRArchitectureManager.h"
#import "TTABHelper.h"

@implementation TTNetworkUtilities

+ (NSString *)IPForDomain:(NSString *)domain {
    if ([SSCommonLogic enabledDNSMapping]) {
        return [DNSManager IPForHost:domain];
    }
    return nil;
}

+ (NSDictionary *)commonURLParameters {
    NSMutableDictionary *result = [NSMutableDictionary dictionaryWithCapacity:2];
    [result setValue:[SSCommon installID] forKey:@"iid"];
    [result setValue:[SSCommon connectMethodName] forKey:@"ac"];
    [result setValue:getCurrentChannel() forKey:@"channel"];
    [result setValue:[SSCommon appName] forKey:@"app_name"];
    [result setValue:[SSCommon ssAppID] forKey:@"aid"];
    [result setValue:[SSCommon versionName] forKey:@"version_code"];
    [result setValue:[SSCommon platformName] forKey:@"device_platform"];
    [result setValue:[SSCommon OSVersion] forKey:@"os_version"];
    [result setValue:[UIDevice currentDevice].platformString forKey:@"device_type"];
    [result setValue:[UIDevice currentDevice].identifierForVendor.UUIDString forKey:@"vid"];
    [result setValue:[SSCommon deviceID] forKey:@"device_id"];
    [result setValue:[SSCommon openUDID] forKey:@"openudid"];
    [result setValue:[SSCommon idfaString] forKey:@"idfa"];
    [result setValue:[SSCommon idfvString] forKey:@"idfv"];
    [result setValue:[SSCommon resolutionString] forKey:@"resolution"];
#ifndef SS_TODAY_EXTENSTION
    [result setValue:@([SSCommon ABTestFlag]) forKey:@"abflag"];
    [result setValue:[SSCommon ABTestClient]forKey:@"ab_client"];
    
    NSString * abVersion = [[TTABHelper sharedInstance_tt] ABVersion];
    if (!isEmptyString(abVersion)) {
        [result setValue:abVersion forKey:@"ab_version"];
    }
    
    NSString * abFeature = [[TTABHelper sharedInstance_tt] ABFeature];
    if (!isEmptyString(abFeature)) {
        [result setValue:abFeature forKey:@"ab_feature"];
    }
    
    NSString * ABGroup = [[TTABHelper sharedInstance_tt] ABGroup];
    if (!isEmptyString(ABGroup)) {
        [result setValue:ABGroup forKey:@"ab_group"];
    }
    
#endif
    [result setValue:@"a" forKey:@"ssmix"];
    return [result copy];
}

+ (NSDictionary *)commonURLParametersExcludeKeys:(NSArray *)keys {
    NSMutableDictionary *result = [[self commonURLParameters] mutableCopy];
    [result removeObjectsForKeys:keys];
    return [result copy];
}

@end

@implementation NSDictionary (TTURLQuery)

- (NSString *)tt_URLQueryString {
    return [self st_compontentsJoinedUsingURLStyle];
}

@end

@implementation NSURL (TTURL)

+ (instancetype)tt_URLWithString:(NSString *)URLString parameters:(NSDictionary *)parameters {
    NSMutableString *result = [NSMutableString stringWithCapacity:20];
    if (SSIsEmptyString(URLString)) {
        return nil;
    }
    [result appendString:URLString];
    NSString *queryString = [parameters tt_URLQueryString];
    if (!SSIsEmptyString(queryString)) {
        if ([URLString contains:@"?"]) {
            [result appendFormat:@"&%@", queryString];
        } else {
            [result appendFormat:@"?%@", queryString];
        }
    }
    NSString *fixedURLString = [result stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSURL *URL = [NSURL URLWithString:fixedURLString];
    if (!URL) {
        URL = [NSURL URLWithString:[fixedURLString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    }
    return URL;
}

+ (instancetype)tt_URLWithString:(NSString *)URLString joinCommonPatameters:(BOOL)joinCommonPatameters {
    NSDictionary *parameters = joinCommonPatameters ? [TTNetworkUtilities commonURLParameters]:nil;
    return [self tt_URLWithString:URLString parameters:parameters];
}

+ (instancetype)tt_URLWithString:(NSString *)URLString joinCommonPatametersExcludeKeys:(NSArray *)keys {
    NSDictionary *parameters = [TTNetworkUtilities commonURLParametersExcludeKeys:keys];
    return [self tt_URLWithString:URLString parameters:parameters];
}

- (BOOL)tt_isValidFragmentForNativeSetting {
    NSString *fragment = self.fragment;
    NSString *fontType = [NewsUserSettingManager settedFontShortString];
    NSDictionary *parameters = [NSDictionary dictionaryWithURLQuery:fragment];
    BOOL isDayMode = ([[SSResourceManager shareBundle] currentMode] == SSThemeModeDay) || [SSCommon isPadDevice];
    return ([parameters[@"tt_daymode"] boolValue] == isDayMode) && [fontType isEqualToString:parameters[@"tt_font"]];
}

- (instancetype)tt_URLByReplacingDomainName {
    NSString *host = self.host;
    NSString *IP = [TTNetworkUtilities IPForDomain:host];
    if (SSIsEmptyString(host) || SSIsEmptyString(IP)) {
        return self;
    }
    if (NSClassFromString(@"NSURLComponents")) {
        NSURLComponents *URLComponents = [NSURLComponents componentsWithURL:self resolvingAgainstBaseURL:NO];
        URLComponents.host = IP;
        return [URLComponents URL];
    }
    NSString *absoluteString = self.absoluteString;
    NSRange range = [absoluteString rangeOfString:host];
    absoluteString = [absoluteString stringByReplacingCharactersInRange:range withString:IP];
    return [NSURL URLWithString:absoluteString];
}

- (instancetype)tt_URLByUpdatingFragmentForNativeSetting {
    BOOL isDayMode = ([[SSResourceManager shareBundle] currentMode] == SSThemeModeDay) || [SSCommon isPadDevice];
    // 如果已经存在fragment,就去掉原来的fragment（王老师说头条这边肯定没问题），然后添加新的fragment
    NSString *fontType = [NewsUserSettingManager settedFontShortString];
    NSString *fragment = [NSString stringWithFormat:@"#tt_daymode=%@&tt_font=%@",@(isDayMode), fontType];
    NSString *temp = self.absoluteString;
    NSRange range = [temp rangeOfString:@"#"];
    if (range.location != NSNotFound) {
        temp = [temp substringToIndex:range.location];
    }
    NSString *absoluteString = [temp stringByAppendingString:fragment];
    return [NSURL URLWithString:absoluteString];
}


- (instancetype)tt_URLByUpdatingParameters:(NSDictionary *)parameters {
    NSMutableDictionary *dictionary = [[NSDictionary dictionaryWithURLQuery:self.query] mutableCopy];
    [parameters enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [dictionary setValue:obj forKey:key];
    }];
    // 将URL替换成最新的
    NSString *query = [dictionary tt_URLQueryString];
    NSString *absoluteString = nil;
    if (isEmptyString(self.query)) {
        absoluteString = [self.absoluteString stringByAppendingString:[NSString stringWithFormat:@"?%@", query]];
    } else {
        absoluteString = [self.absoluteString stringByReplacingOccurrencesOfString:self.query withString:query];
    }
    return [NSURL URLWithString:absoluteString];
}

@end

@implementation NSString (TTURL)

- (instancetype)tt_URLStringByReplacingDomainName {
    NSURL *URL = [SSCommon URLWithURLString:self];
    return [URL.absoluteString tt_URLStringByReplacingDomainNamed:URL.host];
}

- (instancetype)tt_URLStringByReplacingDomainNamed:(NSString *)domain {
    if (SSIsEmptyString(domain)) {
        return self;
    }
    NSRange range = [self rangeOfString:domain];
    if (range.location == NSNotFound) {
        return self;
    }
    NSString *IP = [TTNetworkUtilities IPForDomain:domain];
    if (SSIsEmptyString(IP)) {
        return self;
    }
    return [self stringByReplacingCharactersInRange:range withString:IP];
}

@end
