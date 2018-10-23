//
//  TTMonitorLogPackagerProtocol.h
//  TTMonitor
//
//  Created by ZhangLeonardo on 16/3/7.
//  Copyright © 2016年 ZhangLeonardo. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TTMonitorTrackItem;
@class TTMonitorAggregateItem;
@class TTMonitorStoreItem;

@protocol TTMonitorLogPackagerProtocol <NSObject>

@required

+ (NSDictionary *)packageTrack:(NSArray<TTMonitorTrackItem *> * )array
             aggregateTimeItem:(TTMonitorAggregateItem *)aggregateTimeItem
            aggregateCountItem:(TTMonitorAggregateItem *)aggregateCountItem
                     storeItem:(TTMonitorStoreItem *)storeItem;


@end
