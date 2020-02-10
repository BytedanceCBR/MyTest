//
//  TTBusinessManager+House.h
//  FHHouseBase
//
//  Created by 张静 on 2019/7/11.
//

#import <TTBaseLib/TTBusinessManager.h>

NS_ASSUME_NONNULL_BEGIN

@interface FHBusinessManager: NSObject

/**
 *  ugc模块使用，将NSTimerInterval转换为NSString，包含中间时间
 *
 *  @param timeInterval
 *
 *  @return 转换后的字符串
 */
+ (nullable NSString*)ugcCustomtimeAndCustomdateStringSince1970:(NSTimeInterval)timeInterval;
/**
 *  ugc模块使用，将NSTimerInterval转换为NSString，包含中间时间
 *
 *  @param timeInterval type为时间显示的类型，目前给文章使用 值为onlyDate
 *
 *  @return 转换后的字符串
 */
+ (NSString*)ugcCustomtimeAndCustomdateStringSince1970:(NSTimeInterval)timeInterval type:(NSString *)type;

@end

NS_ASSUME_NONNULL_END
