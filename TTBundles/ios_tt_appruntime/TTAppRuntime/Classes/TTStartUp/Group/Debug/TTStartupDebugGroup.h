//
//  TTStartupDebugGroup.h
//  Article
//
//  Created by fengyadong on 17/1/17.
//
//
#if INHOUSE
#import "TTStartupGroup.h"

typedef NS_ENUM(NSUInteger, TTDebugStartupType) {
    TTDebugStartupTypeNetworkStub = 0,
    TTDebugStartupTypeMemoryMonitor,//内存监控
};

@interface TTStartupDebugGroup : TTStartupGroup

+ (TTStartupDebugGroup *)debugGroup;
+ (void)checkShouldSimulateStartCrash;
@end
#endif
