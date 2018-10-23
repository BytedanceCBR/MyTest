//
//  SSWebViewUtil.m
//  Article
//
//  Created by Zhang Leonardo on 13-8-19.
//
//

#import "SSWebViewUtil.h"
#import "TTTracker.h"
#import "NetworkUtilities.h"
#import <TTBaseLib/TTDeviceHelper.h>
#import <TTSettingsManager/TTSettingsManager.h>

#define kSSEnableLongPressSaveImgKey @"kSSEnableLongPressSaveImgKey"

@implementation SSWebViewUtil

+ (NSURLRequest*)requestWithURL:(NSURL*)url httpHeaderDict:(NSDictionary *)headers
{
    NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:url];
    
    if ([headers isKindOfClass:[NSDictionary class]]) {
        [headers enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            [request setValue:obj forHTTPHeaderField:key];
        }];
    }
    
    return request;
}

+ (NSURLRequest*)requestWithURL:(NSURL *)url httpHeaderDict:(NSDictionary *)headers cachePolicy:(NSURLRequestCachePolicy)cachePolicy timeoutInterval:(NSTimeInterval)timeoutInterval
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:cachePolicy timeoutInterval:timeoutInterval];
    
    if ([headers isKindOfClass:[NSDictionary class]]) {
        [headers enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            [request setValue:obj forHTTPHeaderField:key];
        }];
    }
    
    return request;
}

+ (void)trackWebViewLinksWithKey:(NSString *)trackKey URLStrings:(NSArray *)URLStrings adID:(NSString *)adid logExtra:(NSString *)logExtra {
    if (isEmptyString(trackKey) || SSIsEmptyArray(URLStrings)) {
        return;
    }
    NSMutableDictionary * dict = [NSMutableDictionary dictionaryWithCapacity:10];
    [dict setValue:@"wap_stat" forKey:@"category"];
    [dict setValue:@"jump_links" forKey:@"tag"];
    [dict setValue:trackKey forKey:@"track_key"];
    [dict setValue:URLStrings forKey:@"links"];
    [dict setValue:adid forKey:@"ext_value"];
    [dict setValue:logExtra forKey:@"log_extra"];
    [TTTracker eventData:dict];
}

static NSString *s_oldAgent = nil;

+ (void)registerUserAgent:(BOOL)appendAppInfo
{
    if ([[[TTSettingsManager sharedManager] settingForKey:@"tt_optimize_start_enabled" defaultValue:@0 freeze:YES] boolValue]) {
//        [self registerUserAgentV2:appendAppInfo];
//        return;
    }
    
    NSMutableString *ua = [[self userAgentString:appendAppInfo] mutableCopy];

    NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:ua, @"UserAgent", ua, @"User-Agent", ua, @"User_Agent", nil];
    [[NSUserDefaults standardUserDefaults] registerDefaults:dictionary];
}

//新版, 不会每次都创建一个webview里
+ (void)registerUserAgentV2:(BOOL)appendAppInfo {
    CFPropertyListRef CFCurrentUA = CFPreferencesCopyAppValue(CFSTR("UserAgent"), CFSTR("com.apple.WebFoundation"));
    NSString *currentUA = CFPropertyListRefToNSString(CFCurrentUA);
    
    if (isEmptyString(currentUA) || [currentUA rangeOfString:@"WebKit" options:NSCaseInsensitiveSearch].location == NSNotFound) {
        CFPreferencesSetAppValue(CFSTR("UserAgent"), NULL, CFSTR("com.apple.WebFoundation"));
        currentUA = [self origUA];
    }
    
    NSString *toutiaoUA = [self toutiaoUA];
    NSRange toutiaoUARange = [currentUA rangeOfString:toutiaoUA];
    if (appendAppInfo && toutiaoUARange.location == NSNotFound) { //需要拼接,并且目前UA里没有头条相关参数
        NSString *appendAppInfoUA = [currentUA stringByAppendingFormat:@" %@", toutiaoUA];
        CFPreferencesSetAppValue(CFSTR("UserAgent"), (__bridge CFPropertyListRef _Nullable)(appendAppInfoUA), CFSTR("com.apple.WebFoundation"));
    }
    
    if (!appendAppInfo && toutiaoUARange.location != NSNotFound) { //不需要拼接, 但已经包含了头条相关
        NSString *deappendAppInfoUA = [currentUA componentsSeparatedByString:toutiaoUA].firstObject;
        deappendAppInfoUA = [deappendAppInfoUA stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        CFPreferencesSetAppValue(CFSTR("UserAgent"), (__bridge CFPropertyListRef _Nullable)(deappendAppInfoUA), CFSTR("com.apple.WebFoundation"));
    }
    return;
}

+ (NSString *)userAgentString:(BOOL)appendAppInfo
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        UIWebView *webView = [[UIWebView alloc] init];
        s_oldAgent = [webView stringByEvaluatingJavaScriptFromString:@"navigator.userAgent"];
    });

    if (appendAppInfo) {
        NSMutableString *ua = [NSMutableString string];
        [ua appendFormat:@"%@ %@", s_oldAgent, [self toutiaoUA]];
        /// 如果加了 Channel/_test  百度知道访问会出问题.所以统一不加了
        //    [ua appendFormat:@" Channel/%@", [TTSandBoxHelper getCurrentChannel]];
        
        return ua;
    }
    else
    {
        return s_oldAgent;
    }
}

+ (NSString *)origUA {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        UIWebView *webView = [[UIWebView alloc] init];
        s_oldAgent = [webView stringByEvaluatingJavaScriptFromString:@"navigator.userAgent"];
    });
    return s_oldAgent;
}

+ (NSString *)toutiaoUA {
    NSMutableString *ua = [NSMutableString string];
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    
    // Attempt to find a name for this application
    NSString *appName = [bundle objectForInfoDictionaryKey:@"CFBundleName"];
    if (!appName) {
        appName = [bundle objectForInfoDictionaryKey:@"CFBundleName"];
    }
    
    NSData *latin1Data = [appName dataUsingEncoding:NSUTF8StringEncoding];
    appName = [[NSString alloc] initWithData:latin1Data encoding:NSISOLatin1StringEncoding];
    
    NSString *marketingVersionNumber = [bundle objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    NSString *developmentVersionNumber = [bundle objectForInfoDictionaryKey:@"CFBundleVersion"];
    
    [ua appendFormat:@"NewsArticle/%@", developmentVersionNumber];
    
    NSString *netType = nil;
    if(TTNetworkWifiConnected())
    {
        netType = @"WIFI";
    }
    else if(TTNetwork4GConnected())
    {
        netType = @"4G";
    }
    else if(TTNetwork4GConnected())
    {
        netType = @"3G";
    }
    else if(TTNetworkConnected())
    {
        netType = @"2G";
    }
    
    [ua appendFormat:@" JsSdk/%@", @"2.0"];
    [ua appendFormat:@" NetType/%@", netType];
    [ua appendFormat:@" (%@ %@ %f)", appName, marketingVersionNumber, [TTDeviceHelper OSVersionNumber]];
    
    return [ua copy];
}

static NSString *s_referrer = nil;

+ (void)setWebViewReferrer:(NSString*)referrer
{
    if(s_referrer != referrer)
    {
        if(isEmptyString(s_referrer)) s_referrer = @"";  // empty string means has set from server but its empty
        
        [[NSUserDefaults standardUserDefaults] setObject:s_referrer forKey:kWebViewReferrerStorageKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
    }
}

+ (NSString*)webViewReferrer
{
    if(isEmptyString(s_referrer))
    {
        s_referrer = [[NSUserDefaults standardUserDefaults] objectForKey:kWebViewReferrerStorageKey];
    }
    
    if(s_referrer == nil) //nil means it has not been set from server
    {
        s_referrer = kWebViewReferrerDefaultValue;
    }
    
    return s_referrer;
}

#pragma mark - joint param
+ (NSString *)jointFragmentParams:(NSString *)query toURL:(NSString *)urlStr {
    NSDictionary *fragmentDic = [self paramItemsForString:query];
    return [self jointFragmentParamsDict:fragmentDic toURL:urlStr];
}

+ (NSString *)jointFragmentParamsDict:(NSDictionary<NSString *, NSString *> *)fragmentDic toURL:(NSString *)urlStr {
    if (![urlStr isKindOfClass:[NSString class]]) {
//        LOGE(@"Method: %s Line %d: url must be NSString!", __func__, __LINE__);
        return nil;
    }
    
    if (![fragmentDic isKindOfClass:[NSDictionary class]]) {
        return urlStr;
    }
    
    NSURLComponents *urlComponents = [[NSURLComponents alloc] initWithString:urlStr];
    
    NSString *origFragment = urlComponents.fragment? :@"";
    NSDictionary *origFragmentDic = [self paramItemsForString:origFragment];
    
    NSMutableDictionary *newFramgmentDic = [NSMutableDictionary dictionaryWithDictionary:origFragmentDic];
    [newFramgmentDic addEntriesFromDictionary:fragmentDic];
    
    NSString *newFragment = [self paramStringForDictionary:newFramgmentDic];
    urlComponents.fragment = newFragment;
    
    NSString *origPath = [urlComponents.percentEncodedPath copy];
    @try {
        urlComponents.percentEncodedPath = [origPath stringByRemovingPercentEncoding];
    } @catch (NSException *exception) {
        urlComponents.percentEncodedPath = origPath;
        origPath = nil;
    }
    return urlComponents.URL.absoluteString;
}

+ (NSString *)jointQueryParams:(NSString *)query toURL:(NSString *)urlStr {
    NSDictionary *queryDic = [self paramItemsForString:query];
    return [self jointQueryParamsDict:queryDic toURL:urlStr];
}

+ (NSString *)jointQueryParamsDict:(NSDictionary<NSString *, NSString *> *)queryDic toURL:(NSString *)urlStr {
    if (![urlStr isKindOfClass:[NSString class]]) {
//        LOGE(@"Method: %s Line %d: urlStr must be NSString!", __func__, __LINE__);
        return nil;
    }
    
    if (![queryDic isKindOfClass:[NSDictionary class]]) {
        return urlStr;
    }
    
    NSURLComponents *urlComponents = [[NSURLComponents alloc] initWithString:urlStr];
    
    NSString *origQuery = urlComponents.query? :@"";
    NSDictionary *origQueryDic = [self paramItemsForString:origQuery];
    
    NSMutableDictionary *newQueryDic = [NSMutableDictionary dictionaryWithDictionary:origQueryDic];
    [newQueryDic addEntriesFromDictionary:queryDic];
    
    NSString *newQuery = [self paramStringForDictionary:newQueryDic];
    urlComponents.query = newQuery;
    
    return urlComponents.URL.absoluteString;
}

+ (NSDictionary *)paramItemsForString:(NSString *)string {
    if (isEmptyString(string)) {
        return [[NSDictionary alloc] init];
    }
    
    NSMutableDictionary * result = [NSMutableDictionary dictionaryWithCapacity:10];
    NSArray *paramsList = [string componentsSeparatedByString:@"&"];
    [paramsList enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSArray *keyAndValue = [obj componentsSeparatedByString:@"="];
        if ([keyAndValue count] > 1) {
            NSString *paramKey = [keyAndValue objectAtIndex:0];
            NSString *paramValue = [keyAndValue objectAtIndex:1];
            
            if (paramValue) {
                [result setObject:paramValue forKey:paramKey];
            }
        } else {
            [result setValue:@"" forKey:obj];
        }
    }];
    return [result copy];
}

+ (NSString *)paramStringForDictionary:(NSDictionary<NSString *, NSString *> *)dictionary {
    
    __block NSString *paramString = @"";
    
    if (![dictionary isKindOfClass:[NSDictionary class]]) {
//        LOGE(@"Method: %s Line %d: input param must be a dic", __func__, __LINE__);
        return paramString;
    }
    
    [dictionary enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, id _Nonnull obj, BOOL * _Nonnull stop) {
        NSString *value = obj;
        if ([obj respondsToSelector:@selector(stringValue)]) {
            value = [obj stringValue];
        }
        if (isEmptyString(value)) {
            paramString = [paramString stringByAppendingFormat:@"&%@", key];
            return;
        }
        paramString = [paramString stringByAppendingFormat:@"&%@=%@", key, value];
        
    }];
    
    if (!isEmptyString(paramString)) {
        paramString = [paramString substringFromIndex:1];
    }
    
    return paramString;
}
@end
