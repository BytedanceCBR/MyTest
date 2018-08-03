//
//  HTSVideoPlayTrackerBridge.h
//  Pods
//
//  Created by SongLi.02 on 18/11/2016.
//
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HTSVideoPlayTrackerBridge : NSObject

//Applog3.0
+ (void)trackEvent:(NSString *)event params:(NSDictionary *)params;

+ (void)monitorEvent:(NSString *)type label:(NSString *)label duration:(float)duration needAggregate:(BOOL)needAggr;

+ (void)monitorService:(NSString *)serviceName status:(NSInteger)status extra:(NSDictionary *)extraValue;

+ (void)monitorData:(NSDictionary *)data logTypeStr:(NSString *)logType;

@end

NS_ASSUME_NONNULL_END
