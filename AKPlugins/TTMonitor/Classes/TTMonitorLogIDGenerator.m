//
//  TTMonitorLogIDGenerator.m
//  TTMonitor
//
//  Created by ZhangLeonardo on 16/2/29.
//  Copyright © 2016年 ZhangLeonardo. All rights reserved.
//

#import "TTMonitorLogIDGenerator.h"

static NSInteger previousID;

@implementation TTMonitorLogIDGenerator

//+ (void)initialize
//{
//    previousID = (NSInteger)([[NSDate date] timeIntervalSince1970] * 1000);
//}

+ (NSString *)generateALogID
{
//   return [[NSUUID UUID] UUIDString];
    previousID ++;
    NSInteger result = previousID;
    return [NSString stringWithFormat:@"%d",result];
}

@end
