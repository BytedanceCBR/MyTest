//
//  SSWebViewUtil.h
//  Article
//
//  Created by Zhang Leonardo on 13-8-19.
//
//

#import <Foundation/Foundation.h>
#import "YSWebView.h"

@interface SSWebViewUtil : NSObject

+ (BOOL)webView:(YSWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(YSWebViewNavigationType)navigationType;

/**
    对于详情页无效
 */
+ (void)enableLongPressSaveImg:(BOOL)enable;
+ (BOOL)isEnableLongPressSaveImg;
+ (NSURLRequest*)requestWithURL:(NSURL*)url;

/**
 *  文章导流页用
 */
+ (NSURLRequest*)requestWithURL:(NSURL*)url httpHeaderDict:(NSDictionary *)headers;
+ (NSURLRequest*)requestWithURL:(NSURL *)url httpHeaderDict:(NSDictionary *)headers cachePolicy:(NSURLRequestCachePolicy)cachePolicy timeoutInterval:(NSTimeInterval)timeoutInterval;


/// 发送WebView跳转
+ (void)trackWebViewLinksWithKey:(NSString *)trackKey URLStrings:(NSArray *)URLStrings adID:(NSString *)adid logExtra:(NSString *)logExtra;
+ (BOOL)shouldTrackWebViewWithNavigationType:(UIWebViewNavigationType)navigationType;

/**
 *  注册UA
 *
 *  @param appendAppInfo 是否添加app信息
 */
+ (void)registerUserAgent:(BOOL)appendAppInfo;

+ (NSString *)userAgentString:(BOOL)appendAppInfo;

@end
