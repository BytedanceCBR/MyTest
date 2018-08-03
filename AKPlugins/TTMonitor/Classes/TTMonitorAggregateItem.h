//
//  TTMonitorAggregateItem.h
//  TTMonitor
//
//  Created by ZhangLeonardo on 16/3/3.
//  Copyright © 2016年 ZhangLeonardo. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, TTMonitorAggregateItemType){
    TTMonitorAggregateItemTypeTimeNotAssign,
    TTMonitorAggregateItemTypeTime,
    TTMonitorAggregateItemTypeCount,
};

@interface TTMonitorAggregateItem : NSObject<NSCoding, NSCopying>

@property(nonatomic, assign)NSInteger retryCount;

@property(nonatomic, assign, readonly)TTMonitorAggregateItemType type;


- (id)initWithType:(TTMonitorAggregateItemType)type;

- (void)event:(NSString *)type label:(NSString *)label attribute:(float)attribute needAggregate:(BOOL)needAggr;
- (BOOL)isEmpty;

/**
 *  pool格式如下：
 *  {
 *      event:{
 *      label:[@(1), @(2)...],
 *      ...
 *      },
 *      ...
 *   }
 *
 *  @return nil
 */
- (NSDictionary *)currentPool;

/**
 *  清除
 */
- (void)clear;

/**
 *  聚合所有数据， 耗时操作
 */
- (void)aggregateAllData;

@end
