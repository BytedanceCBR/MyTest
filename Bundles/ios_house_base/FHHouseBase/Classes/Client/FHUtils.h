//
//  FHUtils.h
//  AFgzipRequestSerializer
//
//  Created by 谢飞 on 2018/12/21.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface FHUtils : NSObject

+ (void)setContent:(id)object forKey:(NSString *)keyStr;

+ (instancetype)contentForKey:(NSString *)keyStr;

//json 字符串转dic
+ (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString;

/**
 * @method
 *
 * @brief 获取两个日期之间的天数
 * @param fromDate       起始日期
 * @param toDate         终止日期
 * @return    总天数
 */
+ (NSInteger)numberOfDaysWithFromDate:(NSDate *)fromDate toDate:(NSDate *)toDate;


+ (NSDate *)dateFromString:(NSString *)dateStr;

+ (NSString *)stringFromNSDate:(NSDate *)date;

+ (UIImage*)createImageWithColor:(UIColor*)color;

@end

NS_ASSUME_NONNULL_END
