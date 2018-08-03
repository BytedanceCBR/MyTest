//
//  SSCookieManager.m
//  Article
//
//  Created by Dianwei on 13-5-12.
//
//

#import "SSCookieManager.h"
#import "TTBaseMacro.h"


@implementation SSCookieManager

+ (void)setSessionIDToCookie:(NSString *)sessionID
{
#if SS_IS_I18N // 国际版
    NSArray<NSString *> *supportedCookieDomains = @[@".gsnssdk.com"];
#else
    NSArray<NSString *> *supportedCookieDomains = @[
                                                    @".snssdk.com",
                                                    @".toutiao.com",
                                                    @".wukong.com"
                                                    ];
#endif
    
    if (!isEmptyString(sessionID)) {
        for (NSString *cookieDomain in supportedCookieDomains) {
            if ([cookieDomain length] > 0) {
                NSMutableDictionary *cookieProperty = [NSMutableDictionary dictionaryWithCapacity:5];
                [cookieProperty setObject:cookieDomain forKey:NSHTTPCookieDomain];
                [cookieProperty setObject:@"7776000" forKey:NSHTTPCookieMaximumAge];
                [cookieProperty setObject:[[NSDate date] dateByAddingTimeInterval:2678399] forKey:NSHTTPCookieExpires];
                [cookieProperty setObject:@"sessionid" forKey:NSHTTPCookieName];
                [cookieProperty setObject:sessionID forKey:NSHTTPCookieValue];
                [cookieProperty setObject:@"/" forKey:NSHTTPCookiePath];
                NSHTTPCookie *cookie = [NSHTTPCookie cookieWithProperties:cookieProperty];
                [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookie];
            }
        }
    } else {
        NSArray *cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies];
        for (NSHTTPCookie *cookie in cookies){
            NSString *curCookieDomain = cookie.domain;
            if ([cookie.name isEqualToString:@"sessionid"] &&
                ([curCookieDomain length] > 0 && [supportedCookieDomains containsObject:curCookieDomain])) {
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
