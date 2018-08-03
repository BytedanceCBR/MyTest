//
//  TTBusinessManager+StringUtils.h
//  Article
//
//  Created by zhaoqin on 8/11/16.
//
//

#import "TTBusinessManager.h"

typedef enum TTTimeFormatterType {
    TTTimeFormatterNoTime,//MM-dd
    TTTimeFormatterNormal,//yyyy-MM-dd HH:mm:ss
    TTTimeFormatterSimple,//MM-dd HH:mm
    TTTimeFormatterNoDate,//HH:mm
    TTTimeFormatterWordNoTimeNoYear,//MM月dd日
    TTTimeFormatterWordNoTime,//xxxx年MM月dd日
    TTTimeFormatterOnlyTime,
    TTTimeFormatterNormalNoTime,
}TTTimeFormatterType;

@interface TTBusinessManager (StringUtils)

+ (nonnull NSString *)digFormatCommentCount:(long long)commentCount;

/**
 *  将评论数转换为字符串
 *
 *  @param commentCount commentCount
 *
 *  @return 转换后的字符串
 */
+ (nullable NSString *)formatCommentCount:(long long) commentCount;

/**
 *  将点击数转换为字符串
 *
 *  @param playCount playCount
 *
 *  @return 转换后的字符串
 */
+ (nullable NSString *)formatPlayCount:(long long)playCount;

/**
 *  将NSTimeInterval转换为NSString
 *
 *  @param timeInterval timeInterval
 *
 *  @return 转换后的字符串
 */
+ (nullable NSString*)dateStringSince:(NSTimeInterval)timeInterval;

/**
 *  将NSTimeInterval转换为NSString，格式为MM-dd
 *
 *  @param timeInterval timeInterval
 *
 *  @return 转换后的字符串
 */
+ (nullable NSString *)noTimeStringSince:(NSTimeInterval)timeInterval;

/**
 *  将NSTimeInterval转换为NSString，格式为yyyy-MM-dd HH:mm
 *
 *  @param timerInterval timerInterval
 *
 *  @return 转换后的字符串
 */
+ (nullable NSString*)simpleDateStringSince:(NSTimeInterval)timerInterval;

/**
 *  将NSTimeInterval转换为NSString，格式为yyyy-MM-dd
 *
 *  @param timerInterval timerInterval
 *
 *  @return 转换后的字符串
 */
+ (nullable NSString*)onlyDateStringSince:(NSTimeInterval)timerInterval;

/**
 *  将NSTimeInterval转换为NSString，格式为yyyy年MM月dd日
 *
 *  @param timerInterval timerInterval
 *
 *  @return 转换后的字符串
 */
+ (nullable NSString*)wordDateStringSince:(NSTimeInterval)timerInterval;

/**
 *  将NSTimeInterval转换为NSString，小于1天的，格式为：x hour/mintue age
 *                                大于1天的，格式为：yyyy-MM-dd
 *
 *  @param timeInterval timeInterval
 *
 *  @return 转换后的字符串
 */
+ (nullable NSString*)customtimeStringSince1970:(NSTimeInterval)timeInterval;

/**
 *  将NSTimerInterval转换为NSString，包含中间时间
 *
 *  @param timeInterval timeInterval
 *  @param midInterval midInterval
 *  
 *  @return 转换后的字符串
 */
+ (nullable NSString*)customtimeStringSince1970:(NSTimeInterval)timeInterval midnightInterval:(NSTimeInterval)midInterval;

/**
 *  将NSTimerInterval转换为NSString，根据传入的枚举量
 *
 *  @param timeInterval timeInterval
 *  @param midInterval midInterval
 *  @param type type
 *
 *  @return 转换后的字符串
 */
+ (nullable NSString*)customtimeStringSince1970:(NSTimeInterval)timeInterval midnightInterval:(NSTimeInterval)midInterval formateType:(TTTimeFormatterType)type;
/**
 *  将NSTimerInterval转换为NSString，包含中间时间
 *
 *  @param timeInterval timeInterval
 *
 *  @return 转换后的字符串
 */
+ (nullable NSString*)customtimeAndCustomdateStringSince1970:(NSTimeInterval)timeInterval;

/**
 *  将NSTimerInterval转换为NSString，格式为MM-dd
 *
 *  @param timeInterval timeInterval
 *
 *  @return 转换后的字符串
 */
+ (nullable NSString *)noTimeStringSince1970:(NSTimeInterval)timeInterval;

/**
 *  获取时间间隔，精确到毫秒
 *
 *  @param startTime startTime
 *  @param endTime endTime
 *
 *  @return 时间间隔
 */
+ (CFTimeInterval)timeIntervalFromStartTime:(struct timeval)startTime toEndTime:(struct timeval)endTime;

+ (nullable NSString *)stringChineseMMDDFormWithDate:(nonnull NSDate *)date;

+ (nullable NSString *)stringHHMMFormWithDate:(nonnull NSDate *)date;


@end
