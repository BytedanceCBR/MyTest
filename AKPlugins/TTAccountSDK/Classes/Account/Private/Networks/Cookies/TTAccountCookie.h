//
//  TTAccountCookie.h
//  TTAccountSDK
//
//  Created by liuzuopeng on 2/27/17.
//
//

#import <Foundation/Foundation.h>



@interface TTAccountCookie : NSObject

/**
 *  清除默认（名为"sessionid"）的Cookie
 */
+ (void)clearAccountCookie;

/**
 *  清理Cookie
 */
+ (void)clearAllCookies;

/**
 *  获取当前所有的Cookie
 */
+ (NSArray<NSHTTPCookie *> *)cookies;

@end
