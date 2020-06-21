//
//  TTABManagerUtil.h
//  ABTest
//
//  Created by ZhangLeonardo on 16/1/24.
//  Copyright © 2016年 ZhangLeonardo. All rights reserved.
//
//  客户端AB测试框架工具类

#import <Foundation/Foundation.h>
#import "TTABDefine.h"

/**
 *  客户端AB测试框架工具类
 */
@interface TTABManagerUtil : NSObject

/**
 *  生成一个0-999的随机数
 *
 *  @return 0-999的随机数
 */
+ (NSInteger)genARandomNumber;

/**
 *  读取ab.json文件
 *
 *  @return 读取到的ab.json文件
 */
+ (NSDictionary *)readABJSON;

/**
 *  应用的版本
 *
 *  @return 应用的版本
 */
+ (NSString *)appVersion;

/**
 *  应用的渠道
 *
 *  @return 应用的渠道
 */
+ (NSString *)channelName;

/**
 *  版本号比较
 *
 *  @param leftVersion  要比较的版本号
 *  @param rightVersion 被比较的版本号
 *
 *  @return TTABVersionCompareTypeLessThan : leftVersion<rightVersion; 其他类推
 */
+ (TTABVersionCompareType)compareVersion:(NSString *)leftVersion toVersion:(NSString *)rightVersion;

/**
 *  新旧架构	a1表示新架构；a2表示旧架构	5.1
 *  是否为5.1以及5.1之后版本的新用户
 *      b1表示是5.1及之后版本的新用户；
 *      b2表示是5.1之前的版本升级到5.1及之后版本的用户； 5.1
 *  是否是5.4以及5.4之后版本的新用户
 *      b7表示是5.4及之后版本的新用户
 *      b8表示是5.4之前的版本升级到5.4及之后版本的用户
 *  视频or发现	e1【视频】；e2【发现】； 	5.1
 *  关心or话题	f1【话题】；f2【关心】； 	5.1
 *
 *  @return 拼接后的值
 */
+ (nonnull NSString *)ABTestClient;

@end
