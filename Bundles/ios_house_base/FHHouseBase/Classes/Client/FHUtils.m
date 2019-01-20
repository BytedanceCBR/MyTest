//
//  FHUtils.m
//  AFgzipRequestSerializer
//
//  Created by 谢飞 on 2018/12/21.
//

#import "FHUtils.h"

@implementation FHUtils

+ (void)setContent:(id)object forKey:(NSString *)keyStr
{
    if (object && [keyStr isKindOfClass:[NSString class]]) {
        [[NSUserDefaults standardUserDefaults] setValue:object forKey:keyStr];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

+ (instancetype)contentForKey:(NSString *)keyStr
{
    if ([keyStr isKindOfClass:[NSString class]]) {
       return  [[NSUserDefaults standardUserDefaults] valueForKey:keyStr];
    }else
    {
        return nil;
    }
}

+ (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString
{
    if (jsonString == nil) {
        return nil;
    }
    
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&err];
    if(err)
    {
        NSLog(@"json解析失败：%@",err);
        return nil;
    }
    return dic;
}

/**
 * @method
 *
 * @brief 获取两个日期之间的天数
 * @param fromDate       起始日期
 * @param toDate         终止日期
 * @return    总天数
 */
+ (NSInteger)numberOfDaysWithFromDate:(NSDate *)fromDate toDate:(NSDate *)toDate{
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    
    NSDateComponents    * comp = [calendar components:NSCalendarUnitDay
                                             fromDate:fromDate
                                               toDate:toDate
                                              options:NSCalendarWrapComponents];
    return comp.day;
}

+ (NSDate *)dateFromString:(NSString *)dateStr
{
    if (dateStr == nil) {
        return nil;
    }
    
    NSDate *date = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *strDate = [dateFormatter stringFromDate:date];
    NSDate *birthdayDate = [dateFormatter dateFromString:dateStr];
    return birthdayDate;
}

+ (NSString *)stringFromNSDate:(NSDate *)date
{
    if(!date)
    {
        return nil;
    }
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *strDate = [dateFormatter stringFromDate:date];
    return strDate;
}

@end
