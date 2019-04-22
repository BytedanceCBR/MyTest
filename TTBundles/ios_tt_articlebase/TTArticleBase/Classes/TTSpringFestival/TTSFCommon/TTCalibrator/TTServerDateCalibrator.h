//
//  TTServerDateCalibrator.h
//  Article
//
//  Created by 冯靖君 on 2017/11/23.
//

#import <Foundation/Foundation.h>
#import <TTBaseLib/Singleton.h>

// 校准精度
#define TTDispatchTimerUpdateInterval   0.5
// 任务持久化频控
#define TTTriggerTasksPersistenceMinTimeInterval    (5 * 60)

#define TTTriggeredTaskPassedIntervalKey    @"TTTriggeredTaskPassedIntervalKey"

@protocol TTOnDateTaskTrigger <NSObject>

@required

/**
 *  触发定时任务, 不保证在主线程，UI任务应dispatch到main thread
 *  @param  taskInfo    任务信息，可扩展。目前只有距任务触发时钟的时间跨度
                        @{TTTriggeredTaskPassedIntervalKey, seconds}
 */
- (void)didTriggerWithTaskInfo:(NSDictionary *)taskInfo;

@optional

/**
 *  任务业务上下文参数，注册任务时指定，管理器透传
 */
- (instancetype)initWithDictionary:(NSDictionary *)dict;

/**
 *  任务触发时钟
 */
- (NSDate *)triggerDate;

/**
 *  任务过期时钟,返回nil则永久有效
 */
- (NSDate *)expireDate;

/**
 *  业务层触发条件。不保证在主线程，要求同步返回
 */
- (BOOL)shouldTrigger;

/**
 *  任务是否只执行一次
 */
- (BOOL)triggerOnce;

@end

@interface TTServerDateCalibrator : NSObject

+ (instancetype)sharedCalibrator;

/**
 *  校准器是否可用
 */
- (BOOL)isAvailable;

/**
 *  获取当前云端时钟。如果时钟不可用，返回nil
 */
- (NSDate *)accurateCurrentServerDate;

/**
 *  校准客户端时钟，serverTimeInterval传入云端返回的时钟
 */
- (void)calibrateLocalDateWithServerTimeInterval:(NSTimeInterval)serverTimeInterval;

@end

@interface TTServerDateCalibrator (OnDateTaskTrigger)

/**
 *  注册定时触发任务
 *  @param taskClass   实现任务的类
 *  @param triggerDate 任务触发时钟初值，可在triggerDate协议方法中动态更新
 *  @param expireDate  任务过期时钟初值，可在expireDate协议方法中动态更新。传nil表示永久有效
 *  @param persistent  任务是否持久化，否则只在本次app生命周期有效
 *  @param extra       任务的业务上下文参数，用于持久化
 */
+ (void)registerTriggerTask:(Class<TTOnDateTaskTrigger>)taskClass
                     onDate:(NSDate *)triggerDate
                 expireDate:(NSDate *)expireDate
           shouldPersistent:(BOOL)persistent
                      extra:(NSDictionary *)extra;

/**
 *  取消定时任务
 */
+ (void)unregisterTriggerTask:(Class<TTOnDateTaskTrigger>)taskClass;

@end

@interface TTServerDateCalibrator (Helper)

/**
 *  默认时间格式 yyyy-MM-ddTHH:mm:ssZ，必须严格按照此格式指定时间，否则无法正确识别
 *  eg: @"2017-12-08T21:30:00+0800"
 */
+ (NSDate *)dateWithString:(NSString *)dateString;
+ (NSDate *)dateWithString:(NSString *)dateString formatterString:(NSString *)formatterString;
+ (NSDate *)dateWithTimeInterval:(NSTimeInterval)interval;

@end
