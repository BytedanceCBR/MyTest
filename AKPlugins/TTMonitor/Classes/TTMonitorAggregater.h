//
//  TTMonitorAggregater.h
//  TTMonitor
//
//  Created by ZhangLeonardo on 16/3/2.
//  Copyright © 2016年 ZhangLeonardo. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TTMonitorAggregateItem;
@class TTMonitorStoreItem;

@interface TTMonitorAggregater : NSObject

@property(nonatomic, strong, readonly)TTMonitorAggregateItem * timerItem;
@property(nonatomic, strong, readonly)TTMonitorAggregateItem * counterItem;
@property(nonatomic, strong, readonly)TTMonitorStoreItem * storeItem;

#pragma mark -- counter
- (void)event:(NSString *)type label:(NSString *)label count:(NSUInteger)count needAggregate:(BOOL)needAggr;
- (void)event:(NSString *)type label:(NSString *)label needAggregate:(BOOL)needAggr;

#pragma mark -- timer
- (void)event:(NSString *)type label:(NSString *)label duration:(float)duration needAggregate:(BOOL)needAggr;

#pragma mark -- storer
- (void)storeEvent:(NSString *)type label:(NSString *)label value:(float)value;

- (void)clear;

@end
