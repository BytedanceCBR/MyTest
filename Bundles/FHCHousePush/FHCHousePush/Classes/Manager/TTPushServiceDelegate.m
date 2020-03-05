//
//  TTPushServiceDelegate.m
//  FHCHousePush
//
//  Created by 张静 on 2020/3/3.
//

#import "TTPushServiceDelegate.h"
#import <ByteDanceKit/NSDictionary+BTDAdditions.h>
#import <TTKitchen/TTKitchen.h>
#import <TTInstallService/TTInstallIDManager.h>
#import "ArticleAPNsManager.h"
#import "TTUserSettings/TTUserSettingsManager+Notification.h"
#import "SSAPNsAlertManager.h"
#import <TTAdSplashSDK/TTAdSplashManager.h>
#import <TTBatchItemAction/DetailActionRequestManager.h>
#import <FHPushAuthorizationManager/TTAuthorizeManager.h>
#import <TTTracker/TTTracker.h>
#import "TTLaunchOrientationHelper.h"
#import <TTMonitor/TTMonitor.h>
#import <TTPlatformBaseLib/TTTrackerWrapper.h>
#import <BDALog/BDAgileLog.h>
#import <TTService/TTDetailContainerViewController.h>
#import <TTNewsAccountBusiness/TTAccountManager.h>
#import <BDTArticle/Article.h>
#import "TTNotificationActionSyncManager.h"
#import <TTServiceProtocols/NewsBaseDelegateProtocol.h>
#import "FHCHousePushUtils.h"
#import <TTAppRuntime/NewsBaseDelegate.h>

#import <FHHouseBase/FHUserTracker.h>

static NSString *const kNotificationCategoryIdentifierArticleDetail = @"article_detail";
static NSString *const kNotificationCategoryIdentifierArticleDetailNoDislike = @"article_detail_no_dislike";
static NSString *const kNotificationActionIdentifierDislike = @"NotificationActionIdentifierDislike";
static NSString *const kNotificationActionIdentifierFavorite = @"NotificationActionIdentifierFavorite";
static NSString *const kNotificationActionIdentifierLaunch = @"NotificationActionIdentifierLaunch";

static NSString *const kFSettings = @"f_settings";
static NSString *const kUseUGPushSDKKey      = @"use_ug_push_sdk";

typedef void(^NotificationActionCompletionBlock) (void);

@interface TTPushServiceDelegate ()

@property (nonatomic, strong) DetailActionRequestManager *itemActionManager;
@property (nonatomic, copy) NotificationActionCompletionBlock completionBlock;
@property (nonatomic, strong) NSDictionary *notificationUserInfo;

@end



@implementation TTPushServiceDelegate

+ (void)registerKitchen
{
    TTRegisterKitchenMethod
    TTKitchenRegisterBlock(^{
        
        // todo zjing test
        TTKConfigFreezedDictionary(kFSettings, @"使用BDUGPushSDK", @{kUseUGPushSDKKey:@1});
    });
}

+ (BOOL)enable
{
    NSDictionary *dic = [[TTKitchenManager sharedInstance] getDictionary:kFSettings];
    return [dic btd_boolValueForKey:kUseUGPushSDKKey];
}

+ (instancetype)sharedInstance
{
    static TTPushServiceDelegate *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[TTPushServiceDelegate alloc] init];
    });
    return instance;
}

- (void)registerNotification
{
    [[TTInstallIDManager sharedInstance] observeDeviceDidRegistered:^(NSString *deviceID, NSString *installID) {
        
        // todo zjing test
        [FHUserTracker writeEvent:@"zjing_push_test" params:@{@"use_ug_push_sdk":@(1)}];
        
        BDUGRequestParam *param = [BDUGRequestParam requestParam];
        param.deviceId = deviceID;
        param.installId = installID;
        param.notice = [NSString stringWithFormat:@"%d",[TTUserSettingsManager apnsNewAlertClosed]];
        
        BDUGNotificationConfig *config = nil;
        if (@available(iOS 10.0, *)) {
            BDUGNotificationAction *actionDislike = [BDUGNotificationAction actionWithIdentifier:kNotificationActionIdentifierDislike
                                                                                           title:@"不感兴趣"
                                                                                         options:BDUGNotificationActionOptionAuthenticationRequired];
            BDUGNotificationAction *actionFavorite = [BDUGNotificationAction actionWithIdentifier:kNotificationActionIdentifierFavorite
                                                                                            title:@"收藏"
                                                                                          options:BDUGNotificationActionOptionAuthenticationRequired];
            BDUGNotificationAction *actionLaunch = [BDUGNotificationAction actionWithIdentifier:kNotificationActionIdentifierLaunch
                                                                                          title:@"打开"
                                                                                        options:BDUGNotificationActionOptionAuthenticationRequired | BDUGNotificationActionOptionForeground];
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
            BDUGNotificationCategory *category = [BDUGNotificationCategory categoryWithIdentifier:kNotificationCategoryIdentifierArticleDetail
                                                                                              actions:newsCategoryActions.copy
                                                                                    intentIdentifiers:@[]
                                                                                              options:BDUGNotificationCategoryOptionCustomDismissAction];
            BDUGNotificationCategory *categoryNoDislike = [BDUGNotificationCategory categoryWithIdentifier:kNotificationCategoryIdentifierArticleDetailNoDislike
                                                                                                       actions:newsCategoryNoDislikeActions.copy
                                                                                             intentIdentifiers:@[]
                                                                                                       options:BDUGNotificationCategoryOptionCustomDismissAction];
            config = [BDUGNotificationConfig configureNotificationWithCategories:[NSSet setWithObjects:category, categoryNoDislike, nil]
                                                                         options:BDUGAuthorizationOptionAlert | BDUGAuthorizationOptionBadge | BDUGAuthorizationOptionSound];
        }
        [BDUGPushService setNotificationDelegate:self];
        [BDUGPushService startPushServiceWithParam:param];
        [BDUGPushService registerBDUGPushSDKWith:config];
    }];
}

- (void)showRemoteNotificationAlertIfNeeded
{
    NSDictionary *remoteDict = self.notificationUserInfo;
    if (remoteDict && ![[TTAdSplashManager shareInstance] isAdShowing]) {
        [[SSAPNsAlertManager sharedManager] showRemoteNotificationAlert:remoteDict];
        self.notificationUserInfo = nil;
    }
}

//前台收到远程推送消息
- (void)showRemoteNotificationAlert:(NSDictionary *)userInfo
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:10];
    [dict setValue:[userInfo btd_stringValueForKey:@"o_url"]
            forKey:kSSAPNsAlertManagerSchemaKey];
    [dict setValue:[[userInfo btd_dictionaryValueForKey:@"aps"]
                    btd_stringValueForKey:@"alert"] forKey:kSSAPNsAlertManagerTitleKey];
    [dict setValue:@([userInfo btd_longlongValueForKey:@"id"])
            forKey:kSSAPNsAlertManagerOldApnsTypeIDKey];
    [dict setValue:[userInfo btd_stringValueForKey:@"rid"]
            forKey:kSSAPNsAlertManagerRidKey];
    [dict setValue:[userInfo btd_stringValueForKey:@"importance"]
            forKey:kSSAPNsAlertManagerImportanceKey];
    [dict setValue:[userInfo btd_stringValueForKey:@"attachment"]
            forKey:kSSAPNsAlertManagerAttachmentKey];
    dict[@"post_back"] = userInfo[@"post_back"];

    //如果有开屏广告正在显示 就滞后显示推送弹窗
    if (![[TTAdSplashManager shareInstance] isAdShowing]) {
        [[SSAPNsAlertManager sharedManager] showRemoteNotificationAlert:dict];
    }else{
        self.notificationUserInfo = dict;
    }
}

//处理消息
- (void)handleRemoteNotification:(NSDictionary *)userInfo
{
    WeakSelf;
    [TTLaunchOrientationHelper executeBlockAfterStatusbarOrientationNormal:^{
        StrongSelf;
        ((ArticleAPNsManager *)[ArticleAPNsManager sharedManager]).delegate = self;
        [[APNsManager sharedManager] handleRemoteNotification:userInfo];
    }];
}

#pragma mark - notification

- (void)splashViewDisappearAnimationDidFinished:(NSNotification *)notification
{
    [[self class] showRemoteNotificationAlertIfNeeded];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"kSplashViewDisappearAnimationDidFinished" object:nil];
}

#pragma mark - BDUGPushServiceDelegate

- (void)bdug_pushDidGrantedNotification:(BDUGBaseResponse *)response
{
    // 保证权限获取到再上报下
    [BDUGPushService uploadNotificationStatus:[NSString stringWithFormat:@"%d",[TTUserSettingsManager apnsNewAlertClosed]]];

    if ([TTAuthorizeManager sharedManager].pushObj.authorizeModel.isPushAuthorizeDetermined == NO) {
        wrapperTrackEvent(@"pop", @"push_permission_show");
        if (!response.success) {
            [TTTracker eventV3:@"push_anthorize_popup" params:@{@"is_anthorized" : @"0"}];
            wrapperTrackEvent(@"pop", @"push_permission_cancel");
        } else {
            [TTTracker eventV3:@"push_anthorize_popup" params:@{@"is_anthorized" : @"1"}];
            wrapperTrackEvent(@"pop", @"push_permission_confirm");
        }
        [TTAuthorizeManager sharedManager].pushObj.authorizeModel.isPushAuthorizeDetermined = YES;
        [[TTAuthorizeManager sharedManager].pushObj.authorizeModel saveData];
//        [[TTLocationAdapter shared] reportLocation];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"kSettingViewRegistPushNotification"
                                                            object:nil
                                                          userInfo:nil];
    }
}
- (void)bdug_pushDidRegisterForRemoteNotificationsWithDeviceToken:(NSString *)deviceToken
{
    [[TTMonitor shareManager] trackService:@"push_get_token" status:0 extra:nil];
    BDALOG_INFO(@"push_device_token = %@", deviceToken);
}

- (void)bdug_pushDidFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    NSMutableDictionary *extra = [[NSMutableDictionary alloc] initWithCapacity:2];
    [extra setValue:error.description forKey:@"error"];
    [extra setValue:@(error.code) forKey:@"error_code"];
    UIUserNotificationType userNotificationType = [[[UIApplication sharedApplication] currentUserNotificationSettings] types];
    [extra setValue:@(userNotificationType) forKey:@"type"];
    [[TTMonitor shareManager] trackService:@"push_get_token" status:99 extra:extra];
}

#pragma mark - BDUGPushNotificationDelegate

- (void)bdug_willPresentNotification:(BDUGNotificationContent *)content completionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler
API_AVAILABLE(ios(10.0))
{
    // todo zjing test
    // None：不展示横幅，Alert：展示系统横幅
    [FHUserTracker writeEvent:@"zjing_push_test" params:content.userInfo];

    NSString *importanceString = [content.userInfo btd_stringValueForKey:@"importance"];
    if (importanceString && [importanceString isEqualToString:@"important"]) {
        [self showRemoteNotificationAlert:content.userInfo];
        !completionHandler ?: completionHandler(UNNotificationPresentationOptionNone);
    } else {
        !completionHandler ?: completionHandler(UNNotificationPresentationOptionAlert);
    }
}

- (void)bdug_handleRemoteNotification:(BDUGNotificationContent *)content withCompletionHandler:(void (^)(void))completionHandler
{
    if (content.userInfo != nil) {
        [TTAdSplashManager shareInstance].splashADShowType = TTAdSplashShowTypeHide;
    }
    // todo zjing badge & coldLaunch
    [SharedAppDelegate setIsColdLaunch:NO];
    [UIApplication sharedApplication].applicationIconBadgeNumber = [[content.userInfo objectForKey:@"badge"] integerValue];

    if (@available(iOS 10.0, *)) {
        if ([content.actionIdentifier isEqualToString:UNNotificationDefaultActionIdentifier]) {
            wrapperTrackEvent(@"apn", @"click_notification");
            [self handleRemoteNotification:content.userInfo];
            !completionHandler ?: completionHandler();
        } else if ([content.actionIdentifier isEqualToString:UNNotificationDismissActionIdentifier]) {
            !completionHandler ?: completionHandler();
        } else {
            if ([content.categoryIdentifier isEqualToString:kNotificationCategoryIdentifierArticleDetail] || [content.categoryIdentifier isEqualToString:kNotificationCategoryIdentifierArticleDetailNoDislike]) {
                
                NSString *groupID = [content.userInfo objectForKey:@"group_id"];
                TTGroupModel *groupModel = [[TTGroupModel alloc] initWithGroupID:groupID];
                
                if ([content.actionIdentifier isEqualToString:kNotificationActionIdentifierDislike]) {
                    wrapperTrackEvent(@"apn", @"click_dislike");
                    
                    TTDetailActionReuestContext *context = [TTDetailActionReuestContext new];
                    context.groupModel = groupModel;
                    [self.itemActionManager setContext:context];
                    [self.itemActionManager startItemActionByType:DetailActionTypeNewVersionDislike actionSource:DetailActionSourceNotification];
                    self.completionBlock = completionHandler;
                } else if ([content.actionIdentifier isEqualToString:kNotificationActionIdentifierFavorite]) {
                    wrapperTrackEvent(@"apn", @"click_favorite");
                    
                    TTDetailActionReuestContext *context = [TTDetailActionReuestContext new];
                    context.groupModel = groupModel;
                    [self.itemActionManager setContext:context];
                    [self.itemActionManager startItemActionByType:DetailActionTypeFavourite actionSource:DetailActionSourceNotification];
                    self.completionBlock = completionHandler;
                } else {
                    wrapperTrackEvent(@"apn", @"click_launch");
                    [self handleRemoteNotification:content.userInfo];
                    !completionHandler ?: completionHandler();
                }
            } else {
                !completionHandler ?: completionHandler();
            }
        }
    } else {
        if ([[UIApplication sharedApplication] applicationState] != UIApplicationStateActive) {
            [self handleRemoteNotification:content.userInfo];
            !completionHandler ?: completionHandler();
        } else {
            [self showRemoteNotificationAlert:content.userInfo];
            !completionHandler ?: completionHandler();
        }
    }
}

#pragma mark - APNsManagerDelegate

- (BOOL)apnsManager:(ArticleAPNsManager *)manager canPresentViewControllerToUserID:(NSString *)userID
{
    BOOL ret = NO;
    if (!userID || ([TTAccountManager isLogin] && [[NSString stringWithFormat:@"%@", [TTAccountManager userID]] isEqualToString:userID])) {
        ret = YES;
    } else {
        [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:@"消息接收用户未登录" indicatorImage:[UIImage themedImageNamed:@"close_popup_textpage"] autoDismiss:YES dismissHandler:nil];
    }
    return ret;
}

- (void)apnsManager:(ArticleAPNsManager *)manager handleUserInfoContainsID:(NSString *)groupID
{
    NSString * fixedGroupIDString = [FHCHousePushUtils fixStringTypeGroupID:groupID];

    [TTTrackerWrapper eventData:[NSDictionary dictionaryWithObjectsAndKeys:
                                 @"notice", @"category",
                                 @"load", @"tag",
                                 @"", @"label",
                                 fixedGroupIDString, @"value", nil]];
    
    NSNumber *uniqueID = [NSNumber numberWithLongLong:[fixedGroupIDString longLongValue]];
    NSString *primaryID = [Article primaryIDByUniqueID:[fixedGroupIDString longLongValue] itemID:@"" adID:@""];
    Article *article = [Article objectForPrimaryKey:primaryID];
    if (!article) {
        article = [Article objectWithDictionary:@{@"uniqueID":uniqueID}];
        [article save];
    }
    
    if ([[[UIApplication sharedApplication] delegate] respondsToSelector:@selector(appTopNavigationController)]) {
        UINavigationController *nav = [(id<NewsBaseDelegateProtocol>)[[UIApplication sharedApplication] delegate] appTopNavigationController];
        [nav popViewControllerAnimated:NO];
        TTDetailContainerViewController *detailController = [[TTDetailContainerViewController alloc] initWithArticle:article
                                                                                                              source:NewsGoDetailFromSourceAPNS
                                                                                                           condition:nil];
        [nav pushViewController:detailController animated:YES];
    }

}

#pragma mark - UIApplicationDelegate

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    if (@available(iOS 10.0, *)) {
        dispatch_queue_t queue = dispatch_queue_create(nil, DISPATCH_QUEUE_SERIAL);
        dispatch_async(queue, ^{
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

#pragma mark - getter

- (DetailActionRequestManager *)itemActionManager
{
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
