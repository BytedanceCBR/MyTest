//
//  SSCookieManager.m
//  Article
//
//  Created by Dianwei on 13-5-12.
//
//

#import "SSWidgetCookieManager.h"
#import "TTBaseMacro.h"


@implementation SSWidgetCookieManager

+ (void)setSessionIDToCookie:(NSString *)sessionID
{
    if(!isEmptyString(sessionID))
    {
        NSMutableDictionary *cookieProperty = [NSMutableDictionary dictionaryWithCapacity:5];
#if SS_IS_I18N // 国际版
        [cookieProperty setObject:@".gsnssdk.com" forKey:NSHTTPCookieDomain];
#else
        [cookieProperty setObject:@".snssdk.com" forKey:NSHTTPCookieDomain];
        [cookieProperty setObject:@".toutiao.com" forKey:NSHTTPCookieDomain];
#endif
        [cookieProperty setObject:@"2678399" forKey:NSHTTPCookieMaximumAge];
        [cookieProperty setObject:[[NSDate date] dateByAddingTimeInterval:2678399] forKey:NSHTTPCookieExpires];
        [cookieProperty setObject:@"sessionid" forKey:NSHTTPCookieName];
        [cookieProperty setObject:sessionID forKey:NSHTTPCookieValue];
        [cookieProperty setObject:@"/" forKey:NSHTTPCookiePath];
        NSHTTPCookie *cookie = [NSHTTPCookie cookieWithProperties:cookieProperty];
        [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookie];
    } else {
        NSArray *cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies];
        for (NSHTTPCookie *cookie in cookies){
            if ([cookie.name isEqualToString:@"sessionid"] && ([cookie.domain isEqualToString:@".snssdk.com"] || [cookie.domain isEqualToString:@".gsnssdk.com"] || [cookie.domain isEqualToString:@".toutiao.com"])) {
                [[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:cookie];
            }
        }
    }
    
}

+ (NSString *)sessionIDFromCookie
{
    for (NSHTTPCookie *cookie in [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies]) {
        if ([cookie.name isEqualToString:@"sessionid"]) {
            return cookie.value;
        }
    }
    
    return nil;
}

@end
