//
//  TTMonitorTrackItem.h
//  TTMonitor
//
//  Created by ZhangLeonardo on 16/3/1.
//  Copyright © 2016年 ZhangLeonardo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TTMonitorTrackItem : NSObject<NSCoding>

@property(nonatomic, strong)NSDictionary * track;
/**
 *  重试次数
 */
@property(nonatomic, assign)NSInteger retryCount;

@end
