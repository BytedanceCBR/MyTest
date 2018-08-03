//
//  TTStartupTasksTracker.h
//  Article
//
//  Created by xushuangqing on 2017/5/9.
//
//

#import <Foundation/Foundation.h>

@interface TTOneDevLog : NSObject

@property (nonatomic, copy) NSString *eventName;
@property (nonatomic, copy) NSDictionary *params;
@property (nonatomic, copy) NSString *storeID;

@end

@interface TTStartupTasksTracker : NSObject

+ (instancetype)sharedTracker;

- (TTOneDevLog *)cacheInitializeDevLog:(NSString *)eventName params:(NSDictionary *)params;
- (void)removeInitializeDevLog:(TTOneDevLog *)devLog;

- (void)trackStartupTaskInItsThread:(NSString *)taskTag withInterval:(double)interval;
- (void)trackStartupTaskInMainThread:(NSString *)taskTag withInterval:(double)interval;
- (void)sendTasksIntervalsWithStatus:(int)status;

@end
