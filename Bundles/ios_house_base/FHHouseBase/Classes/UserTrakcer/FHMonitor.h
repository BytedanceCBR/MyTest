//
//  FHMonitor.h
//  Pods
//
//  Created by bytedance on 2020/8/24.
//

#import <Foundation/Foundation.h>

@interface FHMonitor : NSObject

/**
 *  监控某个service的值，并上报
 *
 *  @param serviceName NSString 类型的名称
 *  @param metric      字典必须是key-value形式，而且只有一级，是数值类型的信息，对应 Slardar 的 metric
 *  @param category    字典必须是key-value形式，而且只有一级，是维度信息，对应 Slardar 的 category
 *  @param extraValue  额外信息，方便追查问题使用，Slardar 平台不会进行展示，hive 中可以查询
 */
+ (void)hmdTrackService:(NSString *)serviceName metric:(NSDictionary <NSString *, NSNumber *> *)metric category:(NSDictionary *)category extra:(NSDictionary *)extraValue;

/**
 *  监控某个service的状态，并上报
 *
 *  @param serviceName NSString 类型的名称
 *  @param status      是一个int类型的值，可枚举的几种状态
 *  @param extraValue  额外信息，方便追查使用
 */
+ (void)hmdTrackService:(NSString *)serviceName status:(NSInteger)status extra:(NSDictionary *)extraValue;

@end
