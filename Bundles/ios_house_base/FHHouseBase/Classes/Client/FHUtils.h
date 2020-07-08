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

//字典转json字符串
+ (NSString *)getJsonStrFrom:(NSDictionary *)dic;

//字典转json字符串
+ (NSString *)getJsonStrFromNoEncode:(NSDictionary *)dic;

//字典转key=value字符串
+ (NSString *)getUrlFormStrFromDict:(NSDictionary *)dic andFirstChar:(BOOL)withFirst;

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

+ (NSString *)stringFromNSDateDay:(NSDate *)date;

+ (NSString *)stringFromNSDate:(NSDate *)date;

/*
 周边加阴影，并且同时圆角，注意这个方法必须在view已经布局完成能够获得frame的情况下使用
 */
+ (void)addShadowToView:(UIView *)view
            withOpacity:(float)shadowOpacity
            shadowColor:(UIColor *)shadowColor
           shadowOffset:(CGSize)shadowOffset
           shadowRadius:(CGFloat)shadowRadius
        andCornerRadius:(CGFloat)cornerRadius;

+ (UIImage*)createImageWithColor:(UIColor*)color;

+ (BOOL)getSettingEnableBooleanForKey:(NSString *)key;

@end

NS_ASSUME_NONNULL_END
