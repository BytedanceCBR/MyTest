//
//  SSWebViewUtil.m
//  Article
//
//  Created by Zhang Leonardo on 13-8-19.
//
//

#import "SSWebViewUtil.h"
#import "SSCommonLogic.h"
#import "SSUserSettingManager.h"
#import "SSTracker.h"
#import "NetworkUtilities.h"
#import "SSJSBridge.h"
#import "YSWebView.h"

#define kSSEnableLongPressSaveImgKey @"kSSEnableLongPressSaveImgKey"

@implementation SSWebViewUtil

+ (void)enableLongPressSaveImg:(BOOL)enable
{
    [[NSUserDefaults standardUserDefaults] setValue:@(enable) forKey:kSSEnableLongPressSaveImgKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (BOOL)isEnableLongPressSaveImg
{
    NSNumber * enable = [[NSUserDefaults standardUserDefaults] objectForKey:kSSEnableLongPressSaveImgKey];
    if (enable == nil) {
        return YES;
    }
    return [enable boolValue];
}


+ (BOOL)webView:(YSWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(YSWebViewNavigationType)navigationType
{
    //拦截 跳转
    NSArray * ary = [SSCommonLogic getInterceptURLs];
    for (NSString * url in ary) {
        if ([request.URL.absoluteString hasPrefix:url]) {
            return NO;
        }
    }
    return YES;
}

+ (NSURLRequest*)requestWithURL:(NSURL*)url
{
    NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:url];
    
    NSString *referrer = [SSUserSettingManager webViewReferrer];
    if(!isEmptyString(referrer)) {
        [request setValue:referrer forHTTPHeaderField:@"Referer"];
    }
    
    return request;
}

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
    [SSTracker eventData:dict];
}

+ (BOOL)shouldTrackWebViewWithNavigationType:(UIWebViewNavigationType)navigationType {
    return YES;
    /// (navigationType == UIWebViewNavigationTypeLinkClicked || navigationType == UIWebViewNavigationTypeFormSubmitted);
//    秋良老师说所有的都需要记下来
}

static NSString *s_oldAgent = nil;

+ (void)registerUserAgent:(BOOL)appendAppInfo
{
    NSMutableString *ua = [[self userAgentString:appendAppInfo] mutableCopy];

    NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:ua, @"UserAgent", ua, @"User-Agent", ua, @"User_Agent", nil];
    [[NSUserDefaults standardUserDefaults] registerDefaults:dictionary];
}

+ (NSString *)userAgentString:(BOOL)appendAppInfo
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        UIWebView *webView = [[UIWebView alloc] init];
        s_oldAgent = [webView stringByEvaluatingJavaScriptFromString:@"navigator.userAgent"];
    });

    if (appendAppInfo) {
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
        
        NSMutableString *ua = [NSMutableString string];
        [ua appendFormat:@"%@ NewsArticle/%@", s_oldAgent, developmentVersionNumber];
        
        NSString *netType = nil;
        if([SSCommon OSVersionNumber] >= 7.0)
        {
            if(SSNetworkWifiConnected())
            {
                netType = @"WIFI";
            }
            else if(SSNetwork4GConnected())
            {
                netType = @"4G";
            }
            else if(SSNetwork3GConnected())
            {
                netType = @"3G";
            }
            else if(SSNetworkConnected())
            {
                netType = @"2G";
            }
        }
        else
        {
            if(SSNetworkWifiConnected())
            {
                netType = @"WIFI";
            }
            else if(SSNetworkConnected())
            {
                netType = @"2G";
            }
        }
        
        [ua appendFormat:@" JsSdk/%@", [SSJSBridge currentJSSDKVersion]];
        [ua appendFormat:@" NetType/%@", netType];
        [ua appendFormat:@" (%@ %@ %@)", appName, marketingVersionNumber, [SSCommon OSVersion]];
        /// 如果加了 Channel/_test  百度知道访问会出问题.所以统一不加了
        //    [ua appendFormat:@" Channel/%@", getCurrentChannel()];
        
        return ua;
    }
    else
    {
        return s_oldAgent;
    }
}

@end
