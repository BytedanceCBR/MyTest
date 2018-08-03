//
//  TTTelecomLogicSettings.h
//  Article
//
//  Created by Zuopeng Liu on 8/11/16.
//
//

#import <Foundation/Foundation.h>



@interface TTTelecomLogicSettings : NSObject

/**
 * 从setting接口解析是否电信取号
 */
+ (void)parseGettingPhoneConfigsFromSettings:(NSDictionary *)settings;

/**
 *  当前条件是否满足取号要求
 */
+ (BOOL)gettingPhoneEnabled;

/** 
 *  取号失败，最多尝试次数 
 */
+ (NSInteger)maxRetryTimesWhenFailed;

@end
