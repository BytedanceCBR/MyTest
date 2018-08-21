//
//  NewsBaseDelegate.h
//  Article
//
//  Created by Zhang Leonardo on 12-11-27.
//
//

#import <Foundation/Foundation.h>
#import "ArticleAPNsManager.h"

#import "TTExploreMainViewController.h"

#import <TTBaseLib/TTUIResponderHelper.h>

@class TTCategorySelectorView;
@class TTStartupTask;

#define SharedAppDelegate ((NewsBaseDelegate *)[UIApplication sharedApplication].delegate)

@interface NewsBaseDelegate : UIResponder<UIApplicationDelegate, ArticleAPNsManagerDelegate, TTAppTopNavigationControllerDatasource>

@property(nonatomic, assign)BOOL mainViewDidShow;
@property(nonatomic, strong, readonly) dispatch_queue_t barrierQueue;
@property (nonatomic, assign, readonly, getter=isUserLaunchTheAppDirectly) BOOL userLaunchTheAppDirectly;
@property (nonatomic, assign) BOOL isColdLaunch;

//protected
- (NSString *)umengTrackAppkey; //umeng track key
- (NSString*)appKey;            //umeng key, appKey名字为umeng的回调， 不要修改
- (NSString*)weixinAppID;       //weixin ID
- (NSString *)dingtalkAppID;    //ding talk ID
+ (void)startRegisterRemoteNotificationAfterDelay:(int)secs;
+ (void)startRegisterRemoteNotification;
// 注意  艾德思奇 的key 在 main.h中设置

- (TTCategorySelectorView *)categorySelectorView;

- (TTExploreMainViewController *)exploreMainViewController;

- (UINavigationController *)appTopNavigationController;

- (void)trackCurrentIntervalInMainThreadWithTag:(NSString *)tag;

- (void)addResidentTaskIfNeeded:(TTStartupTask *)task;

- (NSTimeInterval)startTime;

@end
