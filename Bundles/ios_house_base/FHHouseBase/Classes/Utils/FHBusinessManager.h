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
 *  @param timeInterval timeInterval
 *
 *  @return 转换后的字符串
 */
+ (nullable NSString*)ugcCustomtimeAndCustomdateStringSince1970:(NSTimeInterval)timeInterval;

@end

NS_ASSUME_NONNULL_END
