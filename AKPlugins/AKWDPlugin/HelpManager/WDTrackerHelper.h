//
//  WDTrackerHelper.h
//  Pods
//
//  Created by wangqi.kaisa on 2017/9/13.
//
//

#import <Foundation/Foundation.h>

/*
 * 9.13 埋点帮助类，做一些通用埋点操作
 */

@interface WDTrackerHelper : NSObject

+ (NSString *)schemaTrackForPersonalHomeSchema:(NSString *)schema
                                  categoryName:(NSString *)category
                                      fromPage:(NSString *)from
                                       groupId:(NSString *)group
                                 profileUserId:(NSString *)profile;

@end
