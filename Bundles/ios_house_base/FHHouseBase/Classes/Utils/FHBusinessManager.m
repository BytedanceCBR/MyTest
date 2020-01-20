//
//  TTBusinessManager+House.m
//  FHHouseBase
//
//  Created by 张静 on 2019/7/11.
//

#import "FHBusinessManager.h"
#import <TTBaseLib/TTBusinessManager+StringUtils.h>

//static NSDateFormatter *noTimeFormatter;
//static NSDateFormatter *formatter;
//static NSDateFormatter *normalFormatterNoTime;
//static NSDateFormatter *simpleFormatter;
//static NSDateFormatter *onlyDateFormatter;
//static NSDateFormatter *onlyTimeFormatter;
//static NSDateFormatter *onlyTimeToSecondFormatter;
//static NSDateFormatter *wordDateFormatter;
//static NSDateFormatter *singleYearWordFormatter;
//static NSDateFormatter *noYearWordDateFormatter;
//static NSDateFormatter *yearMonthWordFormatter;

static NSDateFormatter *noSecondformatter;
//static NSDateFormatter *onlyDateformatter;

static NSTimeInterval midnightInterval;//午夜时间
static NSTimeInterval midnightYDInterval;//昨天的午夜时间
static NSTimeInterval midnightDBYInterval;//前天的午夜时间
static NSTimeInterval midnightNDAInterval;//9天前的午夜时间
static NSTimeInterval midnightYYInterval;//今年1月1号0点0分0秒

@implementation FHBusinessManager

+ (void)initialize {
     noSecondformatter = [[NSDateFormatter alloc] init];
    [noSecondformatter setDateFormat:@"yyyy-MM-dd HH:mm"];
//    onlyDateformatter = [[NSDateFormatter alloc] init];
//    [onlyDateformatter setDateFormat:@"yyyy-MM-dd"];
    
    
#ifndef SS_TODAY_EXTENSTION
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshMidnightInterval) name:UIApplicationSignificantTimeChangeNotification object:nil];
#endif
}

//+ (NSString *)dateStringSince:(NSTimeInterval)timeInterval {
//    return [formatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:timeInterval]];
//}
//
//+ (NSString *)normalDateNoTimeStringSince:(NSTimeInterval)timeInterval {
//    return [normalFormatterNoTime stringFromDate:[NSDate dateWithTimeIntervalSince1970:timeInterval]];
//}
//
//+ (NSString *)noTimeStringSince:(NSTimeInterval)timeInterval {
//    return [noTimeFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:timeInterval]];
//}
//
//+ (NSString *)simpleDateStringSince:(NSTimeInterval)timerInterval {
//    return [simpleFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:timerInterval]];
//}
//
//+ (NSString *)onlyDateStringSince:(NSTimeInterval)timerInterval {
//    return [onlyDateFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:timerInterval]];
//}
//
//+ (NSString *)onlyTimeStringSince:(NSTimeInterval)timerInterval {
//    return [onlyTimeFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:timerInterval]];
//}
//
//+ (NSString *)onlyTimeToSecondStringSince:(NSTimeInterval)timerInterval {
//    return [onlyTimeToSecondFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:timerInterval]];
//}
//
//+ (NSString *)wordDateStringSince:(NSTimeInterval)timerInterval {
//    return [wordDateFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:timerInterval]];
//}
//
//+ (NSString *)noYearStringSince:(NSTimeInterval)timerInterval {
//    return [noYearWordDateFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:timerInterval]];
//}
//
//+ (NSString *)singleYearWordStringSince:(NSTimeInterval)timerInterval {
//    return [singleYearWordFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:timerInterval]];
//}
//
//+ (NSString *)yearMonthWordStringSince:(NSTimeInterval)timerInterval {
//    return [yearMonthWordFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:timerInterval]];
//}


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

//+ (NSString *)formateDateStringSince:(NSTimeInterval)timeInterval formaterType:(TTTimeFormatterType)type {
//    switch (type) {
//        case TTTimeFormatterSimple:
//            return [TTBusinessManager simpleDateStringSince:timeInterval];
//            break;
////        case TTTimeFormatterNormal:
////            return [TTBusinessManager dateStringSince:timeInterval];
////            break;
////        case TTTimeFormatterNoTime:
////            return [TTBusinessManager noTimeStringSince:timeInterval];
////            break;
////        case TTTimeFormatterOnlyTime:
////            return [TTBusinessManager onlyTimeStringSince:timeInterval];
////            break;
////        case TTTimeFormatterOnlyTimeToSecond:
////            return [TTBusinessManager onlyTimeToSecondStringSince:timeInterval];
////            break;
////        case TTTimeFormatterNormalNoTime:
////            return [TTBusinessManager normalDateNoTimeStringSince:timeInterval];
////            break;
//        case TTTimeFormatterNoDate:
//            return [TTBusinessManager onlyTimeStringSince:timeInterval];
//            break;
////        case TTTimeFormatterWordNoTimeNoYear:
////            return [TTBusinessManager noYearStringSince:timeInterval];
////            break;
////        case TTTimeFormatterWordNoTime:
////            return [TTBusinessManager wordDateStringSince:timeInterval];
////            break;
////        case TTTimeFormatterOnlyYear:
////            return [TTBusinessManager singleYearWordStringSince:timeInterval];
////            break;
////        case TTTimeFormatterYearMonth:
////            return [TTBusinessManager yearMonthWordStringSince:timeInterval];
////            break;
//        default:
//            NSLog(@"no current TTTimeFormatterType");
//            break;
//    }
//    return @"";
//}

+ (NSString*)noSecondStringSince:(NSTimeInterval)timerInterval {
    return [noSecondformatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:timerInterval]];
}

//+ (NSString*)onlyDateStringSince:(NSTimeInterval)timerInterval {
//    return [onlyDateformatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:timerInterval]];
//}

//+ (nullable NSString *)forumCustomtimeStringSince1970:(NSTimeInterval)timeInterval {
//    NSDate *eventDate = [NSDate dateWithTimeIntervalSince1970:timeInterval];
//    NSString *formatString = @"";
//    NSDate *nowDate = [NSDate date];
//    NSTimeInterval nowTime = [nowDate timeIntervalSince1970];
//    NSTimeInterval timeSinceEventTime =  [[NSDate new] timeIntervalSince1970] - timeInterval;
//
//    double oneHour = 60 * 60;
//    double oneDay = oneHour * 24;
//    double oneWeek = oneDay * 7;
//
//    if (timeSinceEventTime < oneHour) {
//        formatString = @"刚刚";
//    } else if (timeSinceEventTime < oneDay) {
//        double numOfHours = floor(timeSinceEventTime / oneHour);
//        formatString = [NSString stringWithFormat:@"%d小时前", (int)numOfHours];
//    } else if (timeSinceEventTime < oneWeek) {
//        double numOfDays = floor(timeSinceEventTime / oneDay);
//        formatString = [NSString stringWithFormat:@"%d天前", (int)numOfDays];
//    } else {
//        //事件的string；
//        NSString *eventWordStr = [wordDateFormatter stringFromDate:eventDate];
//        NSString *nowWordStr = [wordDateFormatter stringFromDate:nowDate];
//        if ([eventWordStr length] > 4
//            && [nowWordStr length] > 4
//            && [[eventWordStr substringWithRange:NSMakeRange(0, 4)] isEqualToString:[nowWordStr substringWithRange:NSMakeRange(0, 4)]]) {
//            //  年份相同
//            formatString = [noYearWordDateFormatter stringFromDate:eventDate];
//        } else {
//            formatString = eventWordStr;
//        }
//
//    }
//    return formatString;
//}


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

+ (NSString*)ugcCustomtimeAndCustomdateStringSince1970:(NSTimeInterval)timeInterval
{
    return [self ugcCustomtimeAndCustomdateStringSince1970:timeInterval type:nil];
}

+ (NSString*)ugcCustomtimeAndCustomdateStringSince1970:(NSTimeInterval)timeInterval type:(NSString *)type;
{
    NSString *retString = nil;
    if (midnightInterval == 0) {
        [FHBusinessManager refreshMidnightInterval];
    }
    if (midnightYDInterval == 0) {
        [FHBusinessManager refreshMidnightYDInterval];
    }
    if (midnightDBYInterval == 0) {
        [FHBusinessManager refreshMidnightDBYInterval];
    }
    if (midnightNDAInterval == 0) {
        [FHBusinessManager refreshMidnightNDAInterval];
    }
    if (midnightYYInterval == 0) {
        [FHBusinessManager refreshMidnightYYInterval];
    }
    
    // 时间点超过零点之后重新刷新缓存数据
    if ([[NSDate date] timeIntervalSince1970] - midnightInterval > 24 * 3600) {
        [FHBusinessManager refreshMidnightInterval];
        [FHBusinessManager refreshMidnightYDInterval];
        [FHBusinessManager refreshMidnightDBYInterval];
        [FHBusinessManager refreshMidnightNDAInterval];
        [FHBusinessManager refreshMidnightYYInterval];
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
        else{
            retString = [TTBusinessManager formateDateStringSince:timeInterval formaterType:TTTimeFormatterSimple];
        }
    }
    else{
        if([type isEqualToString:@"onlyDate"]){
            retString = [TTBusinessManager onlyDateStringSince:timeInterval];
        }else{
            retString = [FHBusinessManager noSecondStringSince:timeInterval];
        }
    }
    return retString;
}


@end
