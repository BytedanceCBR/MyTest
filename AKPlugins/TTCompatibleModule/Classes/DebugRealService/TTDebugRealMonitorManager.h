//
//  TTDebugRealMonitorManager.h
//  Article
//
//  Created by 苏瑞强 on 16/11/24.
//
//

#import <Foundation/Foundation.h>
#import "TTDebugRealNetworkStoreItem.h"

@interface TTDebugRealMonitorManager : NSObject

@property (nonatomic, assign) BOOL enabled;

+ (instancetype)sharedManager;

- (void)start;

+ (void)cacheSStrackItemlog:(NSDictionary *)applogData;

+ (void)cacheAppSettings:(NSDictionary *)settingsData;

+ (void)cacheNetworkItem:(TTDebugRealNetworkStoreItem *)manager;

+ (NSString *)cacheDevLogWithEventName:(NSString *)eventName params:(NSDictionary *)params;

+ (void)removeEventById:(NSString *)eventId;

+ (void)sendDebugRealDataIfNeeded;
//和上一个函数的区别是本函数不包含本次的数据。
+ (void)sendOldDebugRealDataWithConfigs:(NSDictionary *)params;

+ (void)logEnterEvent:(NSDictionary *)willAppearItem;

+ (void)logLeaveEvent:(NSDictionary *)willDisAppearItem;

+ (void)handleException:(NSString *)execeptionInfo;

@end
