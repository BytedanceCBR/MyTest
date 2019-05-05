//
//  SSUpdateListNotifyManager.h
//  Article
//
//  Created by Zhang Leonardo on 12-11-8.
//
//

#import <Foundation/Foundation.h>
//新动态更新的数量

#define kStartGetUpdateCountMinCreateTime   @"kStartGetUpdateCountMinCreateTime"
#define kStartGetUpdateCountTag             @"kStartGetUpdateCountTag"//不强制要求，根据业务需要传递，不传则返回全部

#define kUpdateCountFetchedNotification @"kUpdateCountFetchedNotification"



@interface SSUpdateListNotifyManager : NSObject

+ (SSUpdateListNotifyManager *)shareInstance;
- (void)startGetUpdateCount:(NSDictionary *)conditions;

//如果请求的condition中没有指定tag

+ (void)resetUpdateCount:(NSString *)tag;
+ (NSInteger)getUpdateCount:(NSString *)tag;


//用户消息min create time
+ (long)getUserUpdateNotificationFirstItemMinCreateTime;
+ (void)setUserUpdateNotificationFirstItemMinCreateTime:(long)minCreteTime;

+ (void)saveAutoRefreshUpdateListTimeinterval:(NSTimeInterval)interval;
+ (NSTimeInterval)refreshUpdateListTimeinterval;

+ (void)setUpdateBadgeRefreshInterval:(NSTimeInterval)interval;
+ (NSTimeInterval)updateBadgeRefreshInterval;

@end
