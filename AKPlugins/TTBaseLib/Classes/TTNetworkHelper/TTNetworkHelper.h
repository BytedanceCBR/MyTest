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
 *  @return 字符串描述
 */
+ (nullable NSString*)connectMethodName;

/**
 *  获取carrierName
 *
 *  @return carrierName
 */
+ (nullable NSString*)carrierName;

/**
 *  获取mobileCountryCode
 *
 *  @return mobileCountryCode
 */
+ (nullable NSString*)carrierMCC;

/**
 *  获取mobileNetworkCode
 *
 *  @return mobileNetworkCode
 */
+ (nullable NSString*)carrierMNC;

/**
 *  获取IP地址
 *
 *  @return IP地址
 */
+ (nullable NSDictionary *)getIPAddresses;

/**
 *  获取Host地址
 *
 *  @param host host
 *
 *  @return Host地址
 */
+ (nullable NSString*)addressOfHost:(nullable NSString*)host;

@end
