//
//  TTMonitorPersistenceStore.h
//  TTMonitor
//
//  Created by ZhangLeonardo on 16/2/28.
//  Copyright © 2016年 ZhangLeonardo. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TTMonitorTrackItem;
@class TTMonitorAggregateItem;
@class TTMonitorStoreItem;

@interface TTMonitorPersistenceStore : NSObject

#pragma mark -- archive

+ (void)archiveTrackItems:(NSArray<TTMonitorTrackItem *> *)tracks;

+ (void)archiveAggregateCounter:(TTMonitorAggregateItem *)item;

+ (void)archiveAggregateTimer:(TTMonitorAggregateItem *)item;

+ (void)archiveAggregateStorer:(TTMonitorStoreItem *)item;

#pragma mark -- unarchive

+ (NSArray<TTMonitorTrackItem *> *)unarchiveTrackers;

+ (TTMonitorAggregateItem *)unarchiveTimer;

+ (TTMonitorAggregateItem *)unarchiveCounter;

+ (TTMonitorStoreItem *)unarchiveStorer;

@end
