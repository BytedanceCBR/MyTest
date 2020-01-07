//
//  FHStashModel.m
//  FHHouseBase
//
//  Created by 春晖 on 2020/1/7.
//

#import "FHStashModel.h"

@interface FHStashModel ()

@property(nonatomic , strong) FHOpenUrlStashItem *openUrlStashItem;
@property(nonatomic , strong) FHContinueActivityStashItem *activityItem;
@property(nonatomic , strong) FHRemoteNotificationStashItem *notificationItem;

@end

@implementation FHStashModel

-(void)addOpenUrlItem:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    _openUrlStashItem = [[FHOpenUrlStashItem alloc] init];
    _openUrlStashItem.application = application;
    _openUrlStashItem.openUrl = url;
    _openUrlStashItem.sourceApplication = sourceApplication;
    _openUrlStashItem.annotation = annotation;
}

-(FHOpenUrlStashItem *)stashOpenUrlItem
{
    return _openUrlStashItem;
}

-(void)addContinueActivity:(UIApplication *)application activity:(NSUserActivity *)activity restorationHandler:(void(^)(NSArray *restorableObjects))restorationHandler
{
    _activityItem = [[FHContinueActivityStashItem alloc]init];
    
    _activityItem.application = application;
    _activityItem.activity = activity;
    _activityItem.restorationHandler = restorationHandler;
}

-(FHContinueActivityStashItem *)stashActivityItem
{
    return _activityItem;
}

-(void)addRemoteNotification:(UIApplication *)application userInfo:(NSDictionary *)userInfo
{
    _notificationItem = [[FHRemoteNotificationStashItem alloc] init];
    _notificationItem.application = application;
    _notificationItem.userInfo = userInfo;
    
}

-(FHRemoteNotificationStashItem *)notificationItem
{
    return _notificationItem;
}

@end


@implementation FHOpenUrlStashItem



@end


@implementation FHContinueActivityStashItem


@end


@implementation FHRemoteNotificationStashItem


@end
