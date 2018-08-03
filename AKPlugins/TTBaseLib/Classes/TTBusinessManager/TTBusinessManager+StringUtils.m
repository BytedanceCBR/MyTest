//
//  TTBusinessManager+StringUtils.m
//  Article
//
//  Created by zhaoqin on 8/11/16.
//
//

#import "TTBusinessManager+StringUtils.h"
#import <CoreGraphics/CoreGraphics.h>

static NSDateFormatter *noTimeFormatter;
static NSDateFormatter *formatter;
static NSDateFormatter *normalFormatterNoTime;
static NSDateFormatter *simpleFormatter;
static NSDateFormatter *onlyDateFormatter;
static NSDateFormatter *onlyTimeFormatter;
static NSDateFormatter *wordDateFormatter;
static NSDateFormatter *singleYearFormatter;
static NSDateFormatter *noYearWordDateFormatter;
static NSTimeInterval midnightInterval;//午夜时间
static NSTimeInterval midnightYDInterval;//昨天的午夜时间
static NSTimeInterval midnightDBYInterval;//前天的午夜时间
static NSTimeInterval midnightNDAInterval;//9天前的午夜时间
static NSTimeInterval midnightYYInterval;//今年1月1号0点0分0秒

@implementation TTBusinessManager (StringUtils)

+ (void)initialize {
    noTimeFormatter = [[NSDateFormatter alloc] init];
    [noTimeFormatter setDateFormat:@"MM-dd"];
    
    normalFormatterNoTime = [[NSDateFormatter alloc] init];
    [normalFormatterNoTime setDateFormat:@"yyyy-MM-dd"];
    
    formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    simpleFormatter = [[NSDateFormatter alloc] init];
    [simpleFormatter setDateFormat:@"MM-dd HH:mm"];
    
    singleYearFormatter = [[NSDateFormatter alloc] init];
    [singleYearFormatter setDateFormat:@"yyyy"];
    
    onlyDateFormatter = [[NSDateFormatter alloc] init];
    [onlyDateFormatter setDateFormat:@"yyyy-MM-dd"];
    
    onlyTimeFormatter = [[NSDateFormatter alloc] init];
    [onlyTimeFormatter setDateFormat:@" HH:mm"];
    
    wordDateFormatter = [[NSDateFormatter alloc] init];
    [wordDateFormatter setDateFormat:@"yyyy年M月d日"];
    
    noYearWordDateFormatter = [[NSDateFormatter alloc] init];
    [noYearWordDateFormatter setDateFormat:@"M月d日"];
    
#ifndef SS_TODAY_EXTENSTION
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshMidnightInterval) name:UIApplicationSignificantTimeChangeNotification object:nil];
#endif
}

+ (NSString *)digFormatCommentCount:(long long)commentCount
{
    NSString *digString = [self formatCommentCount:commentCount];
    if ([digString intValue] == 0) {
        digString = @"赞";
    }
    return digString;
}

+ (NSString *)formatCommentCount:(long long)commentCount {
    NSString *formattedString = nil;
    if (commentCount < 10000) {
        formattedString = [NSString stringWithFormat:@"%lld", commentCount];
    } else if(commentCount >= 100000000) {
        CGFloat y = ((CGFloat)commentCount) / 100000000;
        if (y < 10) {
            NSInteger g = ((NSInteger)(y * 10.0))%10;
            if (g == 0) {
                formattedString = [NSString stringWithFormat:NSLocalizedString(@"%d亿", nil) , (NSInteger)y];
            } else {
                formattedString = [NSString stringWithFormat:NSLocalizedString(@"%.1f亿", nil),floor(y*10)/10];
            }
        } else {
            formattedString = [NSString stringWithFormat:NSLocalizedString(@"%.0f亿", nil), floor(y)];
        }
    } else {
        CGFloat w = ((CGFloat)commentCount) / 10000;
        if (w < 10) {
            NSInteger g = ((NSInteger)(w * 10.0))%10;
            if (g == 0) {
                formattedString = [NSString stringWithFormat:NSLocalizedString(@"%d万", nil) , (int)w];
            } else {
                formattedString = [NSString stringWithFormat:@"%.1f万",floor(w*10)/10];
            }
        } else {
            formattedString = [NSString stringWithFormat:NSLocalizedString(@"%.0f万", nil), floor(w)];
        }
    }
    
    return formattedString;
}

+ (NSString *)formatPlayCount:(long long)playCount {
    if (playCount < 10000) {
        return [NSString stringWithFormat:@"%lld", playCount];
    }
    long long w = playCount / 10000;
    return [NSString stringWithFormat:NSLocalizedString(@"%lld万", nil), w];
}

+ (NSString*)dateStringSince:(NSTimeInterval)timeInterval {
    return [formatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:timeInterval]];
}

+ (NSString*)normalDateNoTimeStringSince:(NSTimeInterval)timeInterval {
    return [normalFormatterNoTime stringFromDate:[NSDate dateWithTimeIntervalSince1970:timeInterval]];
}

+ (NSString *)noTimeStringSince:(NSTimeInterval)timeInterval {
    return [noTimeFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:timeInterval]];
}

+ (NSString*)simpleDateStringSince:(NSTimeInterval)timerInterval {
    return [simpleFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:timerInterval]];
}

+ (NSString*)onlyDateStringSince:(NSTimeInterval)timerInterval {
    return [onlyDateFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:timerInterval]];
}

+ (NSString*)onlyTimeStringSince:(NSTimeInterval)timerInterval {
    return [onlyTimeFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:timerInterval]];
}

+ (NSString*)wordDateStringSince:(NSTimeInterval)timerInterval {
    return [wordDateFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:timerInterval]];
}

+ (NSString*)noYearStringSince:(NSTimeInterval)timerInterval {
    return [noYearWordDateFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:timerInterval]];
}


+ (NSString*)customtimeStringSince1970:(NSTimeInterval)timeInterval {
    return [TTBusinessManager customtimeStringSince1970:timeInterval formateType:TTTimeFormatterSimple];
}

+ (NSString*)customtimeStringSince1970:(NSTimeInterval)timeInterval midnightInterval:(NSTimeInterval)midInterval {
    return [TTBusinessManager customtimeStringSince1970:timeInterval midnightInterval:midInterval formateType:TTTimeFormatterSimple];
}

+ (NSString*)customtimeStringSince1970:(NSTimeInterval)timeInterval formateType:(TTTimeFormatterType)type {
    if (midnightInterval == 0 || [[NSDate date] timeIntervalSince1970] - midnightInterval > 24 * 3600) {
        [TTBusinessManager refreshMidnightInterval];
    }
    return [TTBusinessManager customtimeStringSince1970:timeInterval midnightInterval:midnightInterval formateType:type];
}

+ (void)refreshMidnightInterval {
    NSDateComponents *comp = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitYear | NSCalendarUnitMonth fromDate:[NSDate date]];
    [comp setHour:0];
    [comp setMinute:0];
    [comp setSecond:0];
    midnightInterval = [[[NSCalendar currentCalendar] dateFromComponents:comp] timeIntervalSince1970];
}

+ (void)refreshMidnightYDInterval {
    NSDate *oneDayAgo = [NSDate dateWithTimeIntervalSinceNow:- 24 * 3600];
    NSDateComponents *comp = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitYear | NSCalendarUnitMonth fromDate:oneDayAgo];
    [comp setHour:0];
    [comp setMinute:0];
    [comp setSecond:0];
    midnightYDInterval = [[[NSCalendar currentCalendar] dateFromComponents:comp] timeIntervalSince1970];
}

+ (void)refreshMidnightDBYInterval {
    NSDate *twoDayAgo = [NSDate dateWithTimeIntervalSinceNow:- 48 * 3600];
    NSDateComponents *comp = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitYear | NSCalendarUnitMonth fromDate:twoDayAgo];
    [comp setHour:0];
    [comp setMinute:0];
    [comp setSecond:0];
    midnightDBYInterval = [[[NSCalendar currentCalendar] dateFromComponents:comp] timeIntervalSince1970];
}

+ (void)refreshMidnightNDAInterval {
    NSDate *nineDayAgo = [NSDate dateWithTimeIntervalSinceNow:- 24 * 9 * 3600];
    NSDateComponents *comp = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitYear | NSCalendarUnitMonth fromDate:nineDayAgo];
    [comp setHour:0];
    [comp setMinute:0];
    [comp setSecond:0];
    midnightNDAInterval = [[[NSCalendar currentCalendar] dateFromComponents:comp] timeIntervalSince1970];
}

+ (void)refreshMidnightYYInterval {
    NSDateComponents *comp = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitYear | NSCalendarUnitMonth fromDate:[NSDate date]];
    [comp setMonth:1];
    [comp setDay:1];
    [comp setHour:0];
    [comp setMinute:0];
    [comp setSecond:0];
    midnightYYInterval = [[[NSCalendar currentCalendar] dateFromComponents:comp] timeIntervalSince1970];
}

+ (CFTimeInterval)timeIntervalFromStartTime:(struct timeval)startTime toEndTime:(struct timeval)endTime {
    return 1000 * (endTime.tv_sec - startTime.tv_sec) + (endTime.tv_usec - startTime.tv_usec) / 1000;
}

+ (NSString *)noTimeStringSince1970:(NSTimeInterval)timeInterval {
    return [TTBusinessManager customtimeStringSince1970:timeInterval formateType:TTTimeFormatterNoTime];
}

+ (NSString*)customtimeStringSince1970:(NSTimeInterval)timeInterval midnightInterval:(NSTimeInterval)midInterval formateType:(TTTimeFormatterType)type {
    NSString *retString = nil;
    if(timeInterval >= midInterval) {
        int t = [[NSDate date] timeIntervalSince1970] - timeInterval;
        if(t < 60) {
            retString = NSLocalizedString(@"刚刚", nil);
        }
        else if (t < 3600) {
            int val = t / 60;
            retString = [NSString stringWithFormat:NSLocalizedString(@"%d分钟前", nil), val];
        }
        else if(t < 24 * 3600) {
            int val = t / 3600;
            retString = [NSString stringWithFormat:NSLocalizedString(@"%d小时前", nil), val];
        }
        else {
            retString = [TTBusinessManager formateDateStringSince:timeInterval formaterType:type];
        }
    }
    else {
        retString = [TTBusinessManager formateDateStringSince:timeInterval formaterType:type];
    }
    return retString;
}

+ (NSString*)customtimeAndCustomdateStringSince1970:(NSTimeInterval)timeInterval
{
    NSString *retString = nil;
    if (midnightInterval == 0) {
        [TTBusinessManager refreshMidnightInterval];
    }
    if (midnightYDInterval == 0) {
        [TTBusinessManager refreshMidnightYDInterval];
    }
    if (midnightDBYInterval == 0) {
        [TTBusinessManager refreshMidnightDBYInterval];
    }
    if (midnightNDAInterval == 0) {
        [TTBusinessManager refreshMidnightNDAInterval];
    }
    if (midnightYYInterval == 0) {
        [TTBusinessManager refreshMidnightYYInterval];
    }

    // 时间点超过零点之后重新刷新缓存数据
    if ([[NSDate date] timeIntervalSince1970] - midnightInterval > 24 * 3600) {
        [TTBusinessManager refreshMidnightInterval];
        [TTBusinessManager refreshMidnightYDInterval];
        [TTBusinessManager refreshMidnightDBYInterval];
        [TTBusinessManager refreshMidnightNDAInterval];
        [TTBusinessManager refreshMidnightYYInterval];
    }

    if (timeInterval >= midnightYYInterval) {
        NSDate *now = [NSDate date];
        int t = [now timeIntervalSince1970] - timeInterval;
        if(t < 60) {
            retString = NSLocalizedString(@"刚刚", nil);
        }
        else if (t < 3600) {
            int val = t / 60;
            retString = [NSString stringWithFormat:NSLocalizedString(@"%d分钟前", nil), val];
        }
        else if(t < 24 * 3600) {
            int val = t / 3600;
            retString = [NSString stringWithFormat:NSLocalizedString(@"%d小时前", nil), val];
        }
        else if(timeInterval > midnightYDInterval) {
            retString = [NSString stringWithFormat:NSLocalizedString(@"昨天%@", nil),[TTBusinessManager formateDateStringSince:timeInterval formaterType:TTTimeFormatterNoDate]];
        }
        else if(timeInterval > midnightDBYInterval){
            retString = [NSString stringWithFormat:NSLocalizedString(@"前天%@", nil),[TTBusinessManager formateDateStringSince:timeInterval formaterType:TTTimeFormatterNoDate]];
        }
        else if(timeInterval > midnightNDAInterval){
            //restTime:当前时间与前一天凌晨24:00的时间差
            int restTime = [now timeIntervalSince1970] - midnightInterval;
            int val = (t - restTime) / (24 * 3600) + 1;
            retString = [NSString stringWithFormat:NSLocalizedString(@"%d天前", nil), val];
        }
        else{
            retString = [TTBusinessManager formateDateStringSince:timeInterval formaterType:TTTimeFormatterWordNoTimeNoYear];
        }
    }
    else{
        retString = [TTBusinessManager formateDateStringSince:timeInterval formaterType:TTTimeFormatterWordNoTime];
    }
    return retString;
}

+ (NSString *)formateDateStringSince:(NSTimeInterval)timeInterval formaterType:(TTTimeFormatterType)type {
    switch (type) {
        case TTTimeFormatterSimple:
            return [TTBusinessManager simpleDateStringSince:timeInterval];
            break;
        case TTTimeFormatterNormal:
            return [TTBusinessManager dateStringSince:timeInterval];
            break;
        case TTTimeFormatterNoTime:
            return [TTBusinessManager noTimeStringSince:timeInterval];
            break;
        case TTTimeFormatterOnlyTime:
            return [TTBusinessManager onlyTimeStringSince:timeInterval];
            break;
        case TTTimeFormatterNormalNoTime:
            return [TTBusinessManager normalDateNoTimeStringSince:timeInterval];
            break;
        case TTTimeFormatterNoDate:
            return [TTBusinessManager onlyTimeStringSince:timeInterval];
            break;
        case TTTimeFormatterWordNoTimeNoYear:
            return [TTBusinessManager noYearStringSince:timeInterval];
            break;
        case TTTimeFormatterWordNoTime:
            return [TTBusinessManager wordDateStringSince:timeInterval];
        default:
            NSLog(@"no current TTTimeFormatterType");
            break;
    }
    return @"";
}

+ (NSString *)stringChineseMMDDFormWithDate:(NSDate *)date {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    NSTimeZone *timeZone = [NSTimeZone localTimeZone];
    [formatter setTimeZone:timeZone];
    [formatter setDateFormat : @"MM月dd日"];
    
    NSString *str = [formatter stringFromDate:date];
    return str;
}

+ (NSString *)stringHHMMFormWithDate:(NSDate *)date {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    NSTimeZone *timeZone = [NSTimeZone localTimeZone];
    [formatter setTimeZone:timeZone];
    [formatter setDateFormat : @"HH:mm"];
    
    NSString *str = [formatter stringFromDate:date];
    return str;
}

@end
