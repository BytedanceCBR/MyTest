//
//  TTNetworkMonitorRecorderConfigurationProtocol.h
//  TTMonitor
//
//  Created by ZhangLeonardo on 16/3/11.
//  Copyright © 2016年 ZhangLeonardo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TTNetworkMonitorTransaction.h"

@protocol TTNetworkMonitorRecorderConfigurationProtocol <NSObject>

@required

+ (NSObject<TTNetworkMonitorRecorderConfigurationProtocol> *)shareManager;

/**
 *  传递一个transaction, manager决定是否需要采样
 *
 *  @param transaction 待判断是否采样的transaction
 *
 *  @return YES：采样， NO：不采样
 */
- (BOOL)isNeedSampleURL:(TTNetworkMonitorTransaction *)transaction;

/**
 *  传递一个error的transaction, manager决定是否需要采样
 *
 *  @param transaction 待判断是否采样的transaction
 *
 *  @return YES：采样， NO：不采样
 */
- (BOOL)isNeedRecorderErrorURL:(TTNetworkMonitorTransaction *)transaction;

/**
 *  接口是否包含在黑名单里
 *
 *  @param transaction 待判断是否采样的transaction
 *
 *  @return 如果transaction里面的url在黑名单里，则不采集这条数据
 */
- (BOOL)_isContainedInBlackList:(TTNetworkMonitorTransaction *)transaction;
/**
 *  是否统计所有数据
 *
 *  @param transaction 待判断是否采样的transaction
 *
 *  @return 如果此客户端被判定要采样，则所有数据都会采集
 */
- (BOOL)isNeedMonitorAllURL:(TTNetworkMonitorTransaction *)transaction;

/**
 *  检测是不是图片请求
 *
 *  @param transaction 待判断是否采样的transaction
 *
 *  @return 会有一个名单来判断tranaction里的url是不是图片请求
 */
- (BOOL)isImageRequestUrl:(TTNetworkMonitorTransaction *)transaction;
/**
 *  是否取消上报API错误
 *
 *  @return YES：不上报， NO：上报
 */
+ (BOOL)disableReportError;

- (BOOL)isContainerInWhiteList:(TTNetworkMonitorTransaction *)transaction;

- (BOOL)debugRealItemContainedInBlackList:(TTNetworkMonitorTransaction *)transaction;
@end

