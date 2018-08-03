//
//  TTMonitorTracker.h
//  TTMonitor
//
//  Created by ZhangLeonardo on 16/2/29.
//  Copyright © 2016年 ZhangLeonardo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TTMonitorDefine.h"
#import "TTExtensions.h"

@class TTMonitorTrackItem;

/**
 *  负责收集tracker类的监控，内部不会调度的一个新线程，由外部管理线程
 *  初始化方法是阻塞方法， 需要在异步线程alloc
 */
@interface TTMonitorTracker : NSObject

- (NSArray<TTMonitorTrackItem *> *)monitorTrackers;

- (NSUInteger)trackItemsCount;

- (void)removeTrackItems:(NSArray<TTMonitorTrackItem *> *)trackItems;

- (void)addTrackItems:(NSArray<TTMonitorTrackItem *> *)trackItems;

- (void)trackData:(NSDictionary *)data
             type:(TTMonitorTrackerType)type;

- (void)debugRealEvent:(NSString *)event label:(NSString *)label traceCode:(NSString *)traceCode userInfo:(NSDictionary *)userInfo;

- (void)clear;

- (void)trackData:(NSDictionary *)data logType:(NSString *)logTypeStr;

- (void)addImageMonitorItems:(NSArray<TTMonitorTrackItem *> *)trackItems;
@end
