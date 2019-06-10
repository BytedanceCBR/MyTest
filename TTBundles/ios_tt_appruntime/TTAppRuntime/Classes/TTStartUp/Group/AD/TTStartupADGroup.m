//
//  TTStartupADGroup.m
//  Article
//
//  Created by fengyadong on 17/1/19.
//
//

#import "TTStartupADGroup.h"
#import "TTShowADTask.h"
//#import "TTRequestRefreshADTask.h"

@implementation TTStartupADGroup

- (BOOL)isConcurrent {
    return NO;
}

+ (TTStartupADGroup *)ADGroup {
    TTStartupADGroup *group = [[TTStartupADGroup alloc] init];
    
    [group.tasks addObject:[[self class] ADStartupForType:TTADStartupTypeShowAD]];
//    [group.tasks addObject:[[self class] ADStartupForType:TTADStartupTypeActivateSDK]];
//    [group.tasks addObject:[[self class] ADStartupForType:TTADStartupTypeShowAD]];
//    [group.tasks addObject:[[self class] ADStartupForType:TTADStartupTypeRequestRefreshAD]];
    
    return group;
}

+ (TTStartupTask *)ADStartupForType:(TTADStartupType)type {
    switch (type) {
        case TTADStartupTypeShowAD:
            return [[TTShowADTask alloc] init];
            break;
//        case TTADStartupTypeRequestRefreshAD:
//            return [[TTRequestRefreshADTask alloc] init];
//            break;
        default:
            return [[TTStartupTask alloc] init];
            break;
    }
    
    return [[TTStartupTask alloc] init];
}

@end
