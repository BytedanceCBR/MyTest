//
//  TTVFlowStatisticsManager.h
//  Article
//
//  Created by wangdi on 2017/6/29.
//
//

#import <Foundation/Foundation.h>

//流量超量通知
extern NSString * const ttv_kExcessFlowNotification;
//流量订阅完成通知
extern NSString * const ttv_kFreeFlowOrderFinishedNotification;

@interface TTVFlowStatisticsManager : NSObject

+ (instancetype)sharedInstance;
/**
 订购入口按钮的title
 
 @return 返回 订购入口按钮的title
 */
- (NSString *)orderButtonTitle;

/**
 订购入口title
 
 @return 返回订购入口title
 */
- (NSString *)flowReminderTitle;
/**
 是否支持免流量
 
 @return 是返回YES,否则返回NO
 */
- (BOOL)isSupportFreeFlow;

/**
 是否开通免流量
 
 @return 是返回YES,否则返回NO
 */
- (BOOL)isOpenFreeFlow;
/**
 流量是否超量
 
 @return 超量返回YES,否则返回NO
 */
- (BOOL)isExcessFlow;

/**
 添加size大小的流量之后是否超量
 
 @param size 要添加的大小，可以是一个视频的大小,单位kb
 @return  超量返回YES,否则返回NO
 */
- (BOOL)isExcessFlowWithSize:(double)size;

/**
 流量是否超过临界值
 
 @param criticalValue 临界值
 @return 超量返回YES,否则返回NO
 */
- (BOOL)isExcessCriticalValueFlow:(double)criticalValue;

/**
 添加size大小的流量之后是否超过临界值
 
 @param criticalValue 临界值
 @param size 要添加的大小，可以是一个视频的大小,单位kb
 @return 超量返回YES,否则返回NO
 */
- (BOOL)isExcessCriticalValueFlow:(double)criticalValue withSize:(double)size;

/**
 启动的时候注册对流量的定时监听
 */
- (void)registerMonitorFlowChangeWithCompletion:(void (^)(BOOL isRegister))completion;

/**
 开通之后设置数据
 
 @param data 数据字典
 */
- (void)setFlowData:(NSDictionary *)data;

/**
 返回免流开通入口的url
 
 @return url
 */
- (NSString *)freeFlowEntranceURL;

- (NSDate *)recentUpdateDataTime;

/*
 setting开关配置，因为要沉库，所以暂时写到这里
 */
//是否显示流量提示，总开关
- (void)setFlowStatisticsEnable:(BOOL)isEnable;
- (BOOL)flowStatisticsEnable;
//是否显示订阅入口
- (void)setFlowOrderEntranceIsEnable:(BOOL)isEnable;
- (BOOL)flowOrderEntranceEnable;
//定时检查的时间间隔
- (void)setFlowStatisticsRequestInterval:(int64_t)interval;
- (int64_t)flowStatisticsRequestInterval;
//还剩多少m流量提示
- (void)setFlowStatisticsRemainTipValue:(int64_t)remainTipValue;
- (int64_t)flowStatisticsRemainTipValue;
//默认的校准时间
- (void)setFlowDefaultCheckTimeInterval:(int64_t)checkTimeInterval;
- (int64_t)flowDefaultCheckTimeInterval;
- (void)setFlowStatisticsOptions:(NSDictionary *)dict;
- (NSDictionary *)flowStatisticsOptions;

@end
