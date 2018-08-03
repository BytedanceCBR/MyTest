//
//  TTStartupNotificationGroup.m
//  Article
//
//  Created by fengyadong on 17/1/18.
//
//

#import "TTStartupNotificationGroup.h"
#import "TTStartupNotificationTask.h"

@implementation TTStartupNotificationGroup

- (BOOL)isConcurrent {
    return NO;
    
}

+ (TTStartupNotificationGroup *)notificationGroup {
    TTStartupNotificationGroup *group = [[TTStartupNotificationGroup alloc] init];
    
    [group.tasks addObject:[[self class] notificationStartupForType:TTNotificationStartupTypeNotification]];
    
    return group;
}

+ (TTStartupTask *)notificationStartupForType:(TTNotificationStartupType)type {
    switch (type) {
        case TTNotificationStartupTypeNotification:
            return [[TTStartupNotificationTask alloc] init];
            break;
        default:
            return [[TTStartupTask alloc] init];
            break;
    }
    
    return [[TTStartupTask alloc] init];
}

@end
