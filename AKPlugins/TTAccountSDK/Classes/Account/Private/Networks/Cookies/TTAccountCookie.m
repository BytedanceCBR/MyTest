//
//  TTAccountCookie.m
//  TTAccountSDK
//
//  Created by liuzuopeng on 2/27/17.
//
//

#import "TTAccountCookie.h"



@implementation TTAccountCookie

+ (void)clearCookieForName:(NSString *)name
{
    if (!name) {
        [self clearAllCookies];
    } else {
        NSArray<NSHTTPCookie *> *cookies = [self cookies];
        
        for (NSHTTPCookie *cookie in cookies){
            if ([cookie.name isEqualToString:name]) {
                [[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:cookie];
            }
        }
    }
}

+ (void)clearAccountCookie
{
//    [self clearAllCookies];
    [self clearCookieForName:@"sessionid"];
    [self clearCookieForName:@"sid_tt"];
}

+ (void)clearAllCookies
{
    [[self cookies] enumerateObjectsUsingBlock:^(NSHTTPCookie * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:obj];
    }];
}

+ (NSArray<NSHTTPCookie *> *)cookies
{
    return [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies];
}

@end
