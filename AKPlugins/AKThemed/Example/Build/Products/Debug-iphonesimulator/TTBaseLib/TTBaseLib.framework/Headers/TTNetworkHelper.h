//
//  TTNetworkHelper.h
//  Pods
//
//  Created by 冯靖君 on 17/2/15.
//
//

#import <Foundation/Foundation.h>

@interface TTNetworkHelper : NSObject

/**
 *  返回网络连接状态的字符串描述
 *
 *  @return
 */
+ (nullable NSString*)connectMethodName;

/**
 *  获取carrierName
 *
 *  @return
 */
+ (nullable NSString*)carrierName;

/**
 *  获取mobileCountryCode
 *
 *  @return
 */
+ (nullable NSString*)carrierMCC;

/**
 *  获取mobileNetworkCode
 *
 *  @return
 */
+ (nullable NSString*)carrierMNC;

/**
 *  获取IP地址
 *
 *  @return
 */
+ (nullable NSDictionary *)getIPAddresses;

/**
 *  获取Host地址
 *
 *  @param host
 *
 *  @return
 */
+ (nullable NSString*)addressOfHost:(nullable NSString*)host;

@end
