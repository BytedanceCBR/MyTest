//
//  TTMonitorAggregater.m
//  TTMonitor
//
//  Created by ZhangLeonardo on 16/3/2.
//  Copyright © 2016年 ZhangLeonardo. All rights reserved.
//

#import "TTMonitorAggregater.h"
#import "TTMonitorAggregateItem.h"
#import <UIKit/UIKit.h>
#import "TTMonitorPersistenceStore.h"
#import "TTMonitorStoreItem.h"

@interface TTMonitorAggregater()

@property(nonatomic, strong, readwrite)TTMonitorStoreItem * storeItem;
@property(nonatomic, strong, readwrite)TTMonitorAggregateItem * timerItem;
@property(nonatomic, strong, readwrite)TTMonitorAggregateItem * counterItem;

@end

@implementation TTMonitorAggregater

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (id)init
{
    self = [super init];
    if (self) {
        
        TTMonitorAggregateItem * counter = [TTMonitorPersistenceStore unarchiveCounter];
        if (!counter || [counter isEmpty]) {
            self.counterItem = [[TTMonitorAggregateItem alloc] initWithType:TTMonitorAggregateItemTypeCount];
        }
        else {
            self.counterItem = [counter copy];
        }
        
        TTMonitorAggregateItem * timer = [TTMonitorPersistenceStore unarchiveTimer];
        if (!timer || [timer isEmpty]) {
            self.timerItem = [[TTMonitorAggregateItem alloc] initWithType:TTMonitorAggregateItemTypeTime];
        }
        else {
            self.timerItem = [timer copy];
        }
        
        TTMonitorStoreItem * storer = [TTMonitorPersistenceStore unarchiveStorer];
        if (!storer || [storer isEmpty]) {
            self.storeItem = [[TTMonitorStoreItem alloc] init];
        }
        else {
            self.storeItem = [storer copy];
        }
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillTerminate:) name:UIApplicationWillTerminateNotification object:nil];
        
    }
    return self;
}

- (void)event:(NSString *)type label:(NSString *)label count:(NSUInteger)count needAggregate:(BOOL)needAggr
{
    [_counterItem event:type label:label attribute:count needAggregate:needAggr];
}

- (void)event:(NSString *)type label:(NSString *)label needAggregate:(BOOL)needAggr
{
    [self event:type label:label count:1 needAggregate:needAggr];
}

- (void)event:(NSString *)type label:(NSString *)label duration:(float)duration needAggregate:(BOOL)needAggr
{
    [_timerItem event:type label:label attribute:duration needAggregate:needAggr];
}

- (void)storeEvent:(NSString *)type label:(NSString *)label value:(float)value
{
    [_storeItem event:type label:label attribute:value];
}


#pragma mark -- receiveNotification

- (void)applicationWillTerminate:(NSNotification *)notification
{
    [TTMonitorPersistenceStore archiveAggregateCounter:_counterItem];
    [TTMonitorPersistenceStore archiveAggregateTimer:_timerItem];
}


- (void)clear
{
    [_storeItem clear];
    [_timerItem clear];
    [_counterItem clear];
}
@end
