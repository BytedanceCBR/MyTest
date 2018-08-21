//
//  TTNotificationCenterDelegate.m
//  Article
//
//  Created by 徐霜晴 on 16/8/25.
//
//

#import "TTNotificationCenterDelegate.h"
#import "DetailActionRequestManager.h"
#import "NewsBaseDelegate.h"
#import "TTTrackerWrapper.h"
#import "TTGroupModel.h"
#import "BatchItemActionModel.h"
#import "TTNotificationActionSyncManager.h"
#import "TTAuthorizeManager.h"
#import "SettingView.h"
#import "TTLaunchOrientationHelper.h"
#import "TTAdSplashMediator.h"

static NSString *const kNotificationCategoryIdentifierArticleDetail = @"article_detail";
static NSString *const kNotificationCategoryIdentifierArticleDetailNoDislike = @"article_detail_no_dislike";
static NSString *const kNotificationActionIdentifierDislike = @"NotificationActionIdentifierDislike";
static NSString *const kNotificationActionIdentifierFavorite = @"NotificationActionIdentifierFavorite";
static NSString *const kNotificationActionIdentifierLaunch = @"NotificationActionIdentifierLaunch";

static NSString *const kNotificationRequestIdentifierClearBadge = @"NotificationRequestIdentifierClearBadge";

typedef void(^NotificationActionCompletionBlock) (void);

@interface TTNotificationCenterDelegate ()

@property (nonatomic, strong) DetailActionRequestManager *itemActionManager;
@property (nonatomic, copy) NotificationActionCompletionBlock completionBlock;

@end

@implementation TTNotificationCenterDelegate

+ (instancetype)sharedNotificationCenterDelegate {
    static TTNotificationCenterDelegate *notificationCenterDelegate;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        notificationCenterDelegate = [[self alloc] init];
    });
    return notificationCenterDelegate;
}

- (void)registerNotificationCenter {
    
    if ([TTDeviceHelper OSVersionNumber] < 10.0) {
        return;
    }
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunguarded-availability"
    UNUserNotificationCenter *notificationCenter = [UNUserNotificationCenter currentNotificationCenter];
    [notificationCenter requestAuthorizationWithOptions:UNAuthorizationOptionAlert | UNAuthorizationOptionBadge | UNAuthorizationOptionSound
#pragma clang diagnostic pop
                                      completionHandler:^(BOOL granted, NSError * _Nullable error) {
                                          if([TTAuthorizeManager sharedManager].pushObj.authorizeModel.isPushAuthorizeDetermined == NO){
                                              wrapperTrackEvent(@"pop", @"push_permission_show");
                                              if(!granted){
                                                  wrapperTrackEvent(@"pop", @"push_permission_cancel");
                                              }
                                              else{
                                                  wrapperTrackEvent(@"pop", @"push_permission_confirm");
                                              }
                                              [TTAuthorizeManager sharedManager].pushObj.authorizeModel.isPushAuthorizeDetermined = YES;
                                              [[TTAuthorizeManager sharedManager].pushObj.authorizeModel saveData];
                                              [[NSNotificationCenter defaultCenter] postNotificationName:kSettingViewRegistPushNotification
                                                                                                  object:nil
                                                                                                userInfo:nil];
                                          }
                                          dispatch_async(dispatch_get_main_queue(), ^{
                                              [[UIApplication sharedApplication] registerForRemoteNotifications];
                                          });
                                      }];
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunguarded-availability"
    UNNotificationAction *actionDislike = [UNNotificationAction actionWithIdentifier:kNotificationActionIdentifierDislike
                                                                               title:@"不感兴趣"
                                                                             options:UNNotificationActionOptionAuthenticationRequired];
    UNNotificationAction *actionFavorite = [UNNotificationAction actionWithIdentifier:kNotificationActionIdentifierFavorite
                                                                                title:@"收藏"
                                                                              options:UNNotificationActionOptionAuthenticationRequired];
    UNNotificationAction *actionLaunch = [UNNotificationAction actionWithIdentifier:kNotificationActionIdentifierLaunch
                                                                              title:@"打开"
                                                                            options:UNNotificationActionOptionAuthenticationRequired | UNNotificationActionOptionForeground];
#pragma clang diagnostic pop

    NSMutableArray *newsCategoryActions = [NSMutableArray arrayWithCapacity:3];
    NSMutableArray *newsCategoryNoDislikeActions = [NSMutableArray arrayWithCapacity:2];
    if (actionDislike) {
        [newsCategoryActions addObject:actionDislike];
    }
    if (actionFavorite) {
        [newsCategoryActions addObject:actionFavorite];
        [newsCategoryNoDislikeActions addObject:actionFavorite];
    }
    if (actionLaunch) {
        [newsCategoryActions addObject:actionLaunch];
        [newsCategoryNoDislikeActions addObject:actionLaunch];
    }
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunguarded-availability"
    if (![UNNotificationCategory respondsToSelector:@selector(categoryWithIdentifier:actions:intentIdentifiers:options:)]) {
#pragma clang diagnostic pop
        return;
    }
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunguarded-availability"
    UNNotificationCategory *newsCategory = [UNNotificationCategory categoryWithIdentifier:kNotificationCategoryIdentifierArticleDetail
                                                                                  actions:newsCategoryActions.copy
                                                                        intentIdentifiers:@[]
                                                                                  options:UNNotificationCategoryOptionCustomDismissAction];
    UNNotificationCategory *newsCategoryNoDislike = [UNNotificationCategory categoryWithIdentifier:kNotificationCategoryIdentifierArticleDetailNoDislike
                                                                                           actions:newsCategoryNoDislikeActions.copy
                                                                                 intentIdentifiers:@[]
                                                                                           options:UNNotificationCategoryOptionCustomDismissAction];
    [[UNUserNotificationCenter currentNotificationCenter] setNotificationCategories:[NSSet setWithObjects:newsCategory, newsCategoryNoDislike, nil]];
#pragma clang diagnostic pop
}

#pragma mark - UNNotificationCenterDelegate

// iOS10 上新增的 UNNotification 框架在 App 处于前台时收到通知的回调方法
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunguarded-availability"
- (void)userNotificationCenter:(UNUserNotificationCenter *)center
       willPresentNotification:(UNNotification *)notification
         withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler
{
    // 对于清 badge 的通知，传入 UNNotificationPresentationOptionBadge
    if ([notification.request.identifier isEqualToString:kNotificationRequestIdentifierClearBadge]) {
        completionHandler(UNNotificationPresentationOptionBadge);
        return;
    }
    // 如果是云端推送通知，路由给 AppDelegate 进行处理
    if ([notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        // TODO: route to AppDelegate
        [SharedAppDelegate application:[UIApplication sharedApplication]
          didReceiveRemoteNotification:notification.request.content.userInfo];
        completionHandler(UNNotificationPresentationOptionNone);
        return;
    }
    
    // 其它通知传入 UNNotificationActionOptionNone，表现为静默不做任何事
    // 如果要额外处理需要在这里添加逻辑
    completionHandler(UNNotificationPresentationOptionNone);
}

// iOS10 上新增的 UNNotification 框架在用户点击了系统通知以后的回调方法
- (void)userNotificationCenter:(UNUserNotificationCenter *)center
didReceiveNotificationResponse:(UNNotificationResponse *)response
         withCompletionHandler:(void (^)())completionHandler {
    [TTAdSplashMediator shareInstance].splashADShowType = TTAdSplashShowTypeHide;
    NSDictionary *payload = response.notification.request.content.userInfo;
    if ([response.actionIdentifier isEqualToString:UNNotificationDefaultActionIdentifier]) {

        [TTLaunchOrientationHelper executeBlockAfterStatusbarOrientationNormal:^{
            wrapperTrackEvent(@"apn", @"click_notification");
            ((ArticleAPNsManager *)[ArticleAPNsManager sharedManager]).delegate = SharedAppDelegate;
            [[APNsManager sharedManager] handleRemoteNotification:payload];
            completionHandler();
        }];
    }
    else if ([response.actionIdentifier isEqualToString:UNNotificationDismissActionIdentifier]) {
        completionHandler();
    }
    else {
        if ([response.notification.request.content.categoryIdentifier isEqualToString:kNotificationCategoryIdentifierArticleDetail]
            || [response.notification.request.content.categoryIdentifier isEqualToString:kNotificationCategoryIdentifierArticleDetailNoDislike]) {
            
            NSString *groupID = [payload objectForKey:@"group_id"];
            
            TTGroupModel *groupModel = [[TTGroupModel alloc] initWithGroupID:groupID];
            
            if ([response.actionIdentifier isEqualToString:kNotificationActionIdentifierDislike]) {
                wrapperTrackEvent(@"apn", @"click_dislike");
                
                TTDetailActionReuestContext *context = [TTDetailActionReuestContext new];
                context.groupModel = groupModel;
                [self.itemActionManager setContext:context];
                
                [self.itemActionManager startItemActionByType:DetailActionTypeNewVersionDislike actionSource:DetailActionSourceNotification];
                self.completionBlock = completionHandler;
            }
            else if ([response.actionIdentifier isEqualToString:kNotificationActionIdentifierFavorite]) {
                wrapperTrackEvent(@"apn", @"click_favorite");
                
                TTDetailActionReuestContext *context = [TTDetailActionReuestContext new];
                context.groupModel = groupModel;
                [self.itemActionManager setContext:context];
                
                [self.itemActionManager startItemActionByType:DetailActionTypeFavourite actionSource:DetailActionSourceNotification];
                self.completionBlock = completionHandler;
            }
            else {
                [TTLaunchOrientationHelper executeBlockAfterStatusbarOrientationNormal:^{
                    wrapperTrackEvent(@"apn", @"click_launch");
                    ((ArticleAPNsManager *)[ArticleAPNsManager sharedManager]).delegate = SharedAppDelegate;
                    [[APNsManager sharedManager] handleRemoteNotification:payload];
                    completionHandler();
                }];
            }
        }
        else {
            completionHandler();
        }
    }
}
#pragma clang diagnostic pop


#pragma mark - Public

- (void)sendClearBadgeNotification
{
    if ([TTDeviceHelper OSVersionNumber] < 10.0) {
        return;
    }
    UNUserNotificationCenter *notifyCenter = [UNUserNotificationCenter currentNotificationCenter];
    // 创建通知 content
    UNMutableNotificationContent *content = [UNMutableNotificationContent new];
    content.badge = @(-1); // 0 不行
    UNNotificationRequest *clearBadgeRequest =
    [UNNotificationRequest requestWithIdentifier:kNotificationRequestIdentifierClearBadge
                                         content:content
                                         trigger:nil];
    // 这里延时0.1秒的做法是仿照网易新闻，经验证不延时也可以，但不确定是否有其它坑，故仍然保留
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [notifyCenter addNotificationRequest:clearBadgeRequest
                       withCompletionHandler:nil];
    });
}

- (void)applicationDidComeToForeground {
    
    if ([TTDeviceHelper OSVersionNumber] >= 10.0) {
        WeakSelf;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            StrongSelf;
            NSArray *items = [TTNotificationActionSyncManager fetchAndRemoveUnSynchronizedRepinFromNotification];
            
            for (BatchItemActionModel *item in items) {
                TTGroupModel *groupModel = [[TTGroupModel alloc] initWithGroupID:[NSString stringWithFormat:@"%lld", item.groupID.longLongValue]];
                
                TTDetailActionReuestContext *context = [TTDetailActionReuestContext new];
                context.groupModel = groupModel;
                
                [self.itemActionManager setContext:context];
                [self.itemActionManager startItemActionByType:DetailActionTypeFavourite actionSource:DetailActionSourceNotification];
            }
        });
    }
}

#pragma mark - accessors

- (DetailActionRequestManager *)itemActionManager {
    if (!_itemActionManager) {
        _itemActionManager = [[DetailActionRequestManager alloc] init];
        _itemActionManager.handleBlock = ^BOOL(BatchItemActionModel *item) {
            if (item.actionName == BatchItemActionTypeRepin && item.actionSource == BatchItemActionSourceNotification) {
                [TTNotificationActionSyncManager addUnSynchronizedRepinFromNotification:item];
                return YES;
            }
            return NO;
        };
        WeakSelf;
        _itemActionManager.finishBlock = ^(id userInfo, NSError *error) {
            StrongSelf;
            if (self.completionBlock) {
                self.completionBlock();
            }
        };
    }
    return _itemActionManager;
}

@end
