//
//  TTStartupDebugGroup.m
//  Article
//
//  Created by fengyadong on 17/1/17.
//
//

#import "TTStartupDebugGroup.h"
#import "TTNetworkStubTask.h"
#import "TTMemoryMonitorTask.h"

@implementation TTStartupDebugGroup

- (BOOL)isConcurrent {
    return NO;
}

+ (TTStartupDebugGroup *)debugGroup {
    TTStartupDebugGroup *group = [[TTStartupDebugGroup alloc] init];
    
    [group.tasks addObject:[[self class] debugStartupForType:TTDebugStartupTypeNetworkStub]];
    [group.tasks addObject:[[self class] debugStartupForType:TTDebugStartupTypeMemoryMonitor]];
    
    return group;
}

+ (TTStartupTask *)debugStartupForType:(TTDebugStartupType)type {
    switch (type) {
        case TTDebugStartupTypeNetworkStub:
            return [[TTNetworkStubTask alloc] init];
            break;
        case TTDebugStartupTypeMemoryMonitor:
            return [[TTMemoryMonitorTask alloc] init];
            break;
        default:
            return [[TTStartupTask alloc] init];
            break;
    }
    
    return [[TTStartupTask alloc] init];
}

@end
