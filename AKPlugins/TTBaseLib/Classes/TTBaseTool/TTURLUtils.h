//
//  TTURLUtils.h
//  TestTab
//
//  Created by ZhangLeonardo on 15/10/16.
//  Copyright © 2015年 ZhangLeonardo. All rights reserved.
//
/**
    根据 RFC 3986 (https://www.ietf.org/rfc/rfc3986.txt), URL的保留字符有如下：
 
    reserved    = gen-delims / sub-delims
     
    gen-delims  = ":" / "/" / "?" / "#" / "[" / "]" / "@"
     
    sub-delims  = "!" / "$" / "&" / "'" / "(" / ")"
    / "*" / "+" / "," / ";" / "="
    
    
    The following are two example URIs and their component parts:

    foo://example.com:8042/over/there?name=ferret#nose
    \_/   \______________/\_________/ \_________/ \__/
    |           |            |            |        |
    scheme     authority       path        query   fragment
    |   _____________________|__
    / \ /                        \
    urn:example:animal:ferret:nose
 
 **/




#import <Foundation/Foundation.h>

#pragma mark -- 构造
/**
 *  构造、解析URL的工具类
 */
@interface TTURLUtils : NSObject

/**
 *  通过string构造URL
 *
 *  @param URLString 待构造URL的string
 *
 *  @return URL对象
 */
+ (nullable NSURL *)URLWithString:(nonnull NSString *)URLString;

+ (nullable NSURL *)URLWithString:(nonnull NSString *)URLString queryItems:(nullable NSDictionary *)queryItems;
+ (nullable NSURL *)URLWithString:(nonnull NSString *)URLString queryItems:(nullable NSDictionary *)queryItems fragment:(nullable NSString *)fragment;

+ (nullable NSString *)queryItemAddingPercentEscapes:(nonnull NSString *)queryItem;

+ (nonnull NSURL *)URLByInsertOrUpdateParameters:(nullable NSDictionary *)parameters toURL:(nonnull NSURL *)URL;

#pragma mark -- 解析

+ (nullable NSString *)hostForURL:(nonnull NSURL *)URL;

+ (nullable NSString *)pathForURL:(nonnull NSURL *)URL;

+ (nullable NSString *)fragmentForURL:(nonnull NSURL *)URL;

+ (nullable NSDictionary *)queryItemsForURL:(nonnull NSURL *)URL;

+ (nullable NSDictionary *)queryItemsWithoutDecodingForURL:(nonnull NSURL *)URL;
//

@end
