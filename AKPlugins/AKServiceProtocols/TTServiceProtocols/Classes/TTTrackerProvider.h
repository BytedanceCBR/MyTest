//
//  TTTrackerProvider.h
//  Pods
//
//  Created by fengyadong on 2017/3/15.
//
//

#import <Foundation/Foundation.h>

@protocol TTTrackerProvider <NSObject>

@required
/**
 只有event和label两个参数的日志上报

 @param event 事件
 @param label 标签
 */
- (void)event:(nonnull NSString*)event label:(nonnull NSString*)label;

/**
 支持多种参数的日志上报

 @param event 事件
 @param label 标签
 @param value 值
 @param source 来源
 @param extraDic 额外参数
 */
- (void)ttTrackEventWithCustomKeys:(nonnull NSString *)event label:(nonnull NSString *)label value:(nullable NSString *)value source:(nullable NSString *)source extraDic:(nullable NSDictionary *)extraDic;

/**
 v3格式日志打点
 @param event 事件名称
 @param params 额外参数
 */
- (void)eventV3:(NSString *_Nonnull)event params:(NSDictionary *_Nullable)params;


/**
 获取app_log接口的post参数

 @return post参数
 */
- (NSDictionary *_Nonnull)onTheFlyParameter;


/**
 添加impressions到发送队列

 @param impressions 待上报的impressions数据
 */
- (void)appendImpressions:(NSArray *)impressions;

@end
