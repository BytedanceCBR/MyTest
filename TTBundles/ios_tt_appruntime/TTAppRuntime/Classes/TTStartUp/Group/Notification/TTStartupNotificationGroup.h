//
//  TTStartupNotificationGroup.h
//  Article
//
//  Created by fengyadong on 17/1/18.
//
//

#import "TTStartupGroup.h"

@interface TTStartupNotificationGroup : TTStartupGroup

typedef NS_ENUM(NSUInteger, TTNotificationStartupType) {
    TTNotificationStartupTypeNotification = 0, //广告展示
};

+ (TTStartupNotificationGroup *)notificationGroup;

@end
