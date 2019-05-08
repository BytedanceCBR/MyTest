//
//  TTAdMonitorManager.h
//  Article
//
//  Created by yin on 2016/11/18.
//
//

#import <Foundation/Foundation.h>
#import "TTMonitor.h"
#import <TTAdModule/TTAdSingletonManager.h>
#import <TTAdModule/SSAppStore.h>

//具体打点汇总见doc: https://docs.google.com/spreadsheets/d/1Rtgn6G-91ojV2T_seSyu1vl_mx6sL2BNh73O275Udxw/edit#gid=0
/**
 *  Advice One:
 *  ad monitor template likes ad_{param1}_{param2}.
 *  @param1 module
 *  @param2 issue
 *  
 *  Advice Two：
 *  extra include:  ad_id => ad id or  cid => creative id
 */

@interface TTAdMonitorManager : NSObject

Singleton_Interface(TTAdMonitorManager)

+ (void)trackService:(NSString *)serviceName value:(id)value extra:(NSDictionary *)extra;

+ (void)trackService:(NSString *)serviceName status:(NSUInteger)status extra:(NSDictionary *)extra;

+ (void)trackAdException:(NSDictionary*)dict;

+ (void)beginTrackIntervalService:(NSString *)serviceName;
+ (void)endTrackIntervalService:(NSString *)serviceName extra:(NSDictionary *)extra;

/**
 统计广告数量点

 @param serviceName 不同位置、类型广告及行为标识 eg:feed下载广告展现量   feed_app_show
 @param adId 广告id
 @param log_extra log_extra
 @param extValue 附加信息 可为nil
 */
+ (void)trackServiceCount:(NSString *)serviceName adId:(NSString *)adId logExtra:(NSString *)log_extra
                 extValue:(NSDictionary*)extValue;
@end
