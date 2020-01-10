//
//  FHStashModel.h
//  FHHouseBase
//
//  Created by 春晖 on 2020/1/7.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@class UNUserNotificationCenter;
@class UNNotificationResponse;

@interface FHOpenUrlStashItem : NSObject

@property(nonatomic , strong) UIApplication *application;
@property(nonatomic , strong) NSURL *openUrl;
@property(nonatomic , copy)   NSString *sourceApplication;
@property(nonatomic , strong) id annotation;

@end

@interface FHContinueActivityStashItem : NSObject

@property(nonatomic , strong) UIApplication *application;
@property(nonatomic , strong) NSUserActivity *activity;
@property(nonatomic , copy) void(^restorationHandler)(NSArray *restorableObjects);

@end

@interface FHRemoteNotificationStashItem : NSObject

@property(nonatomic , strong) UIApplication *application;
@property(nonatomic , copy)   NSDictionary *userInfo;

@end

@interface FHUNRemoteNOficationStashItem : NSObject

@property(nonatomic , strong) UNUserNotificationCenter *center;
@property(nonatomic , strong) UNNotificationResponse *response;
@property(nonatomic , copy)  void (^completionHandler)();

@end

@interface FHStashModel : NSObject


-(void)addOpenUrlItem:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation;

-(FHOpenUrlStashItem *)stashOpenUrlItem;

-(void)addContinueActivity:(UIApplication *)application activity:(NSUserActivity *)activity restorationHandler:(void(^)(NSArray *restorableObjects))restorationHandler;

-(FHContinueActivityStashItem *)stashActivityItem;

-(void)addRemoteNotification:(UIApplication *)application userInfo:(NSDictionary *)userInfo;

-(FHRemoteNotificationStashItem *)notificationItem;

-(void)addUNRemoteNOtification:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)())completionHandler ;

-(FHUNRemoteNOficationStashItem *)unnotificationItem;

@end

NS_ASSUME_NONNULL_END
