//
//  TTIMDateFormatter.m
//  EyeU
//
//  Created by matrixzk on 11/2/16.
//  Copyright © 2016 Toutiao.EyeU. All rights reserved.
//

#import "TTIMDateFormatter.h"

static NSCalendarUnit kCalUnitHourMinute = NSCalendarUnitHour | NSCalendarUnitMinute;
static NSCalendarUnit kCalUnitMonthDay   = NSCalendarUnitMonth | NSCalendarUnitDay;
static NSTimeInterval kThresholdTimeInterval = 300; // 5min

NS_INLINE NSString * FormattedNumber(NSInteger number) {
    return [NSString stringWithFormat:@"%@%@", (number < 10 ? @"0" : @""), @(number)];
}

@implementation TTIMDateFormatter {
    NSCalendar *_calendar;
}

+ (instancetype)sharedInstance {
    static TTIMDateFormatter *_sharedFormatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedFormatter = [[self alloc] init];
    });
    return _sharedFormatter;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _calendar = [[NSLocale currentLocale] objectForKey:NSLocaleCalendar];
    }
    return self;
}

+ (NSString *)formattedDate4ChatCenter:(NSDate *)aDate
{
    return [[[self class] sharedInstance] formattedDateWithSourceDate:aDate showTime:NO];
}

/* 日期规则
 ~~~~~~~~~~~~~~~~~~~~~
 showTime = YES :
 
 ** 信息发送时间 **       ** 标准（24时制）**    ** 举例 **
 本年度1月1日00:00之前     年份+日期+时间        2015-12-12 16:08
 今日00:00之前            日期+时间             12-12 16:08
 今日00:00至今            时间                 16:08
 
 ~~~~~~~~~~~~~~~~~~~~~
 showTime = NO :
 
 ** 信息发送时间 **       ** 标准（24时制）**    ** 举例 **
 本年度1月1日00:00之前     年份+日期             2015-12-12
 今日00:00之前            日期                 12-12
 今日00:00至今            时间                 16:08
 */

- (NSString *)formattedDateWithSourceDate:(NSDate *)aDate showTime:(BOOL)showTime {
    NSDate *nowDate = [NSDate date];
    
    NSDateComponents *comps = [_calendar components:NSCalendarUnitYear | kCalUnitMonthDay fromDate:nowDate];
    NSDate *todayDate = [_calendar dateFromComponents:comps];
    
    // 今天
    if ([aDate compare:todayDate] != NSOrderedAscending) {
        comps = [_calendar components:kCalUnitHourMinute fromDate:aDate];
        return [NSString stringWithFormat:@"%@:%@", FormattedNumber(comps.hour), FormattedNumber(comps.minute)];
    }
    
    NSString *datePrefix;
    comps = [_calendar components:NSCalendarUnitYear fromDate:nowDate];
    NSDate *thisYearDate = [_calendar dateFromComponents:comps];

    // 今年
    if ([aDate compare:thisYearDate] != NSOrderedAscending) {
        comps = [_calendar components:kCalUnitMonthDay | (showTime ? kCalUnitHourMinute : 1) fromDate:aDate];
        datePrefix = [NSString stringWithFormat:@"%@-%@", FormattedNumber(comps.month), FormattedNumber(comps.day)];
    } else { // 去年及以前
        comps = [_calendar components:NSCalendarUnitYear | kCalUnitMonthDay | (showTime ? kCalUnitHourMinute : 1) fromDate:aDate];
        datePrefix = [NSString stringWithFormat:@"%@-%@-%@", @(comps.year), FormattedNumber(comps.month), FormattedNumber(comps.day)];
    }
    
    if (!showTime) { return datePrefix; }
    
    return [self formattedDateWithPrefix:datePrefix dateComponents:comps];
}

- (NSString *)formattedDateWithPrefix:(NSString *)prefix dateComponents:(NSDateComponents *)dateComponents {
    return [NSString stringWithFormat:@"%@ %@:%@", prefix, FormattedNumber(dateComponents.hour), FormattedNumber(dateComponents.minute)];
}


@end
