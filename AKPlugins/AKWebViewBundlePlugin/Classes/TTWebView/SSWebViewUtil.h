//
//  SSWebViewUtil.h
//  Article
//
//  Created by Zhang Leonardo on 13-8-19.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "YSWebView.h"

static NSString *const kWebViewReferrerStorageKey = @"kWebViewReferrerStorageKey";
static NSString *const kWebViewReferrerDefaultValue = @"http://nativeapp.toutiao.com";


@interface SSWebViewUtil : NSObject

/**
 *  文章导流页用
 */
+ (NSURLRequest*)requestWithURL:(NSURL*)url httpHeaderDict:(NSDictionary *)headers;
+ (NSURLRequest*)requestWithURL:(NSURL *)url httpHeaderDict:(NSDictionary *)headers cachePolicy:(NSURLRequestCachePolicy)cachePolicy timeoutInterval:(NSTimeInterval)timeoutInterval;


/// 发送WebView跳转
+ (void)trackWebViewLinksWithKey:(NSString *)trackKey URLStrings:(NSArray *)URLStrings adID:(NSString *)adid logExtra:(NSString *)logExtra;

/**
 *  注册UA
 *
 *  @param appendAppInfo 是否添加app信息
 */
+ (void)registerUserAgent:(BOOL)appendAppInfo;

+ (NSString *)userAgentString:(BOOL)appendAppInfo;


/**
 *  Refreer
 *
 */
+ (void)setWebViewReferrer:(NSString*)referrer;
+ (NSString*)webViewReferrer;


/**
 拼接fragment
 
 注意:
 1.如果传入的key存在与现有的重复, 则新传入的value会覆盖原有的value
 2.传入的key和value请自行encode


 @param fragmentDic 需要拼接的framgemnt, key value为NSString
 @param urlStr 目标url
 @return 拼接后的url
 */
+ (NSString *)jointFragmentParamsDict:(NSDictionary<NSString *, NSString *> *)fragmentDic toURL:(NSString *)urlStr;

+ (NSString *)jointFragmentParams:(NSString *)query toURL:(NSString *)urlStr;


/**
 拼接query

 注意:
 1.如果传入的key存在与现有的重复, 则新传入的value会覆盖原有的value
 2.传入的key和value请自行encode
 
 @param queryDic 需要拼接的query, key value为NSString
 @param urlStr 目标url
 @return 拼接后的url
 */
+ (NSString *)jointQueryParamsDict:(NSDictionary<NSString *, NSString *> *)queryDic toURL:(NSString *)urlStr;

+ (NSString *)jointQueryParams:(NSString *)query toURL:(NSString *)urlStr;
@end

static NSString * CFPropertyListRefToNSString(CFPropertyListRef ref) {
    if (ref == NULL) {
        return nil;
    }
    if (CFGetTypeID(ref) == CFStringGetTypeID()) {
        return (NSString *)CFBridgingRelease(ref);
    }
    return nil;
}
