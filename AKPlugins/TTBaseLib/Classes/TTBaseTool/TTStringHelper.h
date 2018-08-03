//
//  TTStringHelper.h
//  Pods
//
//  Created by zhaoqin on 8/11/16.
//
//

#import <Foundation/Foundation.h>

@interface TTStringHelper : NSObject

/**
 *  将含有参数的NSDictionary转换为url格式--TTURLUtils做相应替换，不做encode
 *
 *  @param parameters 参数列表
 *
 *  @return urlString
 */
+ (nullable NSString *)URLQueryStringWithoutEncodeWithParameters:(nullable NSDictionary *)parameters;

/**
 *  将含有参数的NSDictionary转换为url格式--TTURLUtils做相应替换
 *
 *  @param parameters 参数列表
 *
 *  @return urlString
 */
+ (nullable NSString *)URLQueryStringWithParameters:(nullable NSDictionary *)parameters;

/**
 *  将url中的参数转换为NSDictionary
 *
 *  @param urlString urlString
 *
 *  @return 参数列表
 */
+ (nullable NSDictionary*)parametersOfURLString:(nullable NSString*)urlString;

/**
 *  根绝key值查找NSDictionary中的NSString
 *
 *  @param dict dict
 *  @param keyName keyName
 *
 *  @return 找到的NSString，如果找不到，返回nil
 */
+ (nullable NSString *)parseStringInDict:(nullable NSDictionary *)dict forKey:(nullable NSString *)keyName;

/**
 *  根绝key值查找NSDictionary中的NSNumber
 *
 *  @param dict dict
 *  @param keyName keyName
 *
 *  @return 找到的NSNumber，如果找不到，返回nil
 */
+ (nullable NSNumber *)parseNumberInDict:(nullable NSDictionary *)dict forKey:(nullable NSString *)keyName;

/**
 *  将字符串转换为Base64位格式
 *
 *  @param str str
 *
 *  @return Base64格式NSString
 */
+ (nullable NSString *)decodeStringFromBase64Str:(nullable NSString *)str;

/**
 *  使用str 生成NSURL, 如果生成不成功， 则尝试用UTF8，再不成功，则返回nil
 *
 *  @param str str
 *
 *  @return URL
 */
+ (nullable NSURL *)URLWithURLString:(nullable NSString *)str;

/**
 *  根据Base URL和关联字符串来构造URL
 *
 *  @param str 关联字符串
 *  @param url Base URL
 *
 *  @return URL
 */
+ (nullable NSURL *)URLWithString:(nullable NSString *)str relativeToURL:(nullable NSURL *)url;



@end
