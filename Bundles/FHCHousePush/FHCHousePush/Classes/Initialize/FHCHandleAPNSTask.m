//
//  FHCHandleAPNSTask.m
//  FHCHousePush
//
//  Created by 张静 on 2019/4/10.
//

#import "FHCHandleAPNSTask.h"
#import "ArticleAPNsManager.h"
#import "TTAccountBusiness.h"
//#import "TTDetailContainerViewController.h"
#import "SSAPNsAlertManager.h"
//#import "SSADManager.h"
//#import "NewsBaseDelegate.h"
//#import "SSUserSettingManager.h"
#import "TTAuthorizeManager.h"
//#import "SettingView.h"
#import "TTNotificationCenterDelegate.h"
#import "Article.h"
//#import "TTBackgroundModeTask.h"
#import "TTRoute.h"
//#import "TTArticleTabBarController.h"
#import <TTSettingsManager/TTSettingsManager.h>
//#import "TSVPushLaunchManager.h"
#import "FHCHousePushUtils.h"
#import <TTAppRuntime/NewsBaseDelegate.h>
#import <TTService/TTDetailContainerViewController.h>
#import <TTAppRuntime/TTBackgroundModeTask.h>
#import <TTAdSplashMediator.h>
#import <TTAppRuntime/SSUserSettingManager.h>
//#import <TTAppRuntime/TTIntroduceViewTask.h>
#import <TTAppRuntime/TTStartupTasksTracker.h>
#import <TTAppRuntime/TTProjectLogicManager.h>
#import "TTLaunchDefine.h"
#import <HMDTTMonitor.h>
#import <FHIntroduceManager.h>
#import <FHHouseBase/FHEnvContext.h>

DEC_TASK_N(FHCHandleAPNSTask,FHTaskTypeSerial,TASK_PRIORITY_HIGH+12);

static NSString * const kTTAPNSRemoteNotificationDict = @"kTTAPNSRemoteNotificationDict";
static NSString * const kTTArticleDeviceToken = @"ArticleDeviceToken";

@implementation FHCHandleAPNSTask

- (void)startAndTrackWithApplication:(UIApplication *)application options:(NSDictionary *)launchOptions
{
    TTOneDevLog *devLog = [[TTStartupTasksTracker sharedTracker] cacheInitializeDevLog:[NSString stringWithFormat:@"%@_begin", [self taskIdentifier]] params:@{@"thread" : @([[[NSThread currentThread] valueForKeyPath:@"private.seqNum"] integerValue])}];
    int64_t start = [NSObject currentUnixTime];
    [self startWithApplication:application options:launchOptions];
    int64_t end = [NSObject currentUnixTime];
    double millisecond = [NSObject machTimeToSecs:(end - start)] * 1000;
    [[TTStartupTasksTracker sharedTracker] trackStartupTaskInItsThread:[self taskIdentifier] withInterval:millisecond];
    [[TTStartupTasksTracker sharedTracker] removeInitializeDevLog:devLog];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (BOOL)shouldExecuteForApplication:(UIApplication *)application options:(NSDictionary *)launchOptions {
    return YES;
}

- (BOOL)isNormal {
    return YES;
    //    //修复版本有一个TTSparkRescue的方法
    //    return [[NSUserDefaults standardUserDefaults] boolForKey: [TTStartupProtectPrefix stringByAppendingString:[self taskIdentifier]]];
}

- (BOOL)isResident
{
    return YES;
}

- (NSString *)taskIdentifier
{
    return @"HanleAPNS";
}

- (void)setTaskNormal:(BOOL)isNormal {
    [[NSUserDefaults standardUserDefaults] setBool:isNormal forKey:[@"TTStartupProtect" stringByAppendingString:[self taskIdentifier]]];
    if (!isNormal) {
        [[NSUserDefaults standardUserDefaults] setObject:[self taskIdentifier] forKey:@"abnormal_task_identifier"];
    } else {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"abnormal_task_identifier"];
    }
}

- (BOOL)isConcurrent {
    return NO;
}

- (void)startWithApplication:(UIApplication *)application options:(NSDictionary *)launchOptions
{
    
    [SharedAppDelegate setIsColdLaunch:YES];
    
    if (![[FHEnvContext sharedInstance] hasConfirmPermssionProtocol]) {
        return;
    }
    
    [NewsBaseDelegate startRegisterRemoteNotification];
    //如果展示开屏广告时候有弹窗延迟弹出
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(splashViewDisappearAnimationDidFinished:) name:@"kTTAdSplashShowFinish" object:nil];        
    
    if ([TTDeviceHelper OSVersionNumber] < 10.0 && [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey]) {
        double delayInSeconds = 1;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            ((ArticleAPNsManager *)[ArticleAPNsManager sharedManager]).delegate = self;
            [[ArticleAPNsManager sharedManager] handleRemoteNotification:[launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey]];
        });
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

//3.5 code
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
    [[SharedAppDelegate appTopNavigationController] popToRootViewControllerAnimated:NO];
    
    TTDetailContainerViewController *detailController = [[TTDetailContainerViewController alloc] initWithArticle:article
                                                                                                          source:NewsGoDetailFromSourceAPNS
                                                                                                       condition:nil];
    [[SharedAppDelegate appTopNavigationController] pushViewController:detailController animated:YES];
}

+ (NSString *)deviceTokenString
{
    return [[NSUserDefaults standardUserDefaults] stringForKey:kTTArticleDeviceToken];
}

#pragma mark - UIApplicationDelegate

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // in case no callbacks are invoked through notification register
    [NewsBaseDelegate startRegisterRemoteNotificationAfterDelay:5.f];
    [[TTNotificationCenterDelegate sharedNotificationCenterDelegate] applicationDidComeToForeground];
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    const unsigned *tokenBytes = [deviceToken bytes];
    NSString *deviceTokenString =nil;
    if(deviceToken.length >= 8){
        //FOR iOS 13
        deviceTokenString = [NSString stringWithFormat:@"%08x%08x%08x%08x%08x%08x%08x%08x",
                       ntohl(tokenBytes[0]), ntohl(tokenBytes[1]), ntohl(tokenBytes[2]),
                       ntohl(tokenBytes[3]), ntohl(tokenBytes[4]), ntohl(tokenBytes[5]),
                       ntohl(tokenBytes[6]), ntohl(tokenBytes[7])];
    }else{
        deviceTokenString = [[[[deviceToken description]
                               stringByReplacingOccurrencesOfString: @"<" withString: @""]
                              stringByReplacingOccurrencesOfString: @">" withString: @""]
                             stringByReplacingOccurrencesOfString: @" " withString: @""];
    }
    
    [[NSUserDefaults standardUserDefaults] setValue:deviceTokenString forKey:kTTArticleDeviceToken];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [[TTMonitor shareManager] trackService:@"push_get_token" status:0 extra:nil];
    
    NSInteger status = 0;
    if (deviceTokenString.length < 1) {
        status = -1;
    }
    [[HMDTTMonitor defaultManager] hmdTrackService:@"push_register_token_result" metric:nil category:@{@"status":@(status)} extra:nil];

    [TTBackgroundModeTask reportDeviceTokenByAppLogout];
#if DEBUG
    NSLog(@"push_device_token = %@", deviceTokenString);
#endif
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    SSLog(@"SEL: %@, error:%@", NSStringFromSelector(_cmd), error);
    
    NSMutableDictionary *extra = [[NSMutableDictionary alloc] initWithCapacity:2];
    [extra setValue:error.description forKey:@"error"];
    [extra setValue:@(error.code) forKey:@"error_code"];
    if ([TTDeviceHelper OSVersionNumber] >= 8.0) {
        UIUserNotificationType userNotificationType = [[[UIApplication sharedApplication] currentUserNotificationSettings] types];
        [extra setValue:@(userNotificationType) forKey:@"type"];
    }
    [[TTMonitor shareManager] trackService:@"push_get_token" status:99 extra:extra];
}

// iOS10以前（<iOS 10），后台点击进入APP和在前台收到推送，都会进入application:didReceiveRemoteNotification:
// iOS10之后（>=iOS 10），在前台收到推送，正常逻辑会执行userNotificationCenter:willPresentNotification:withCompletionHandler:，然后根据completion回调参数来决定系统行为，若没有userNotificationCenter:willPresentNotification:withCompletionHandler:代理方法，则直接调用application:didReceiveRemoteNotification:；而在后台收到推送并点击进入APP，会直接调用代理方法userNotificationCenter:didReceiveNotificationResponse:withCompletionHandler:
// 但是iOS10之后，为了启动清除红点，当APP处于前台收到通知进入userNotificationCenter:willPresentNotification:withCompletionHandler:逻辑后，会在completion回调中传入None来抑制调用系统通知行为，并手动调用application:didReceiveRemoteNotification:执行自定义动作
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    SSLog(@">>>>> Launch: receiveRemoteNoti: %@", userInfo);
//    if (!SSIsEmptyDictionary(userInfo)) {
//        NSString *userInfoStr = [NSString stringWithFormat:@"%@",userInfo];
//        if (!isEmptyString(userInfoStr)) {
//            [UIPasteboard generalPasteboard].string = userInfoStr;
//        }
//    }
    if (userInfo != nil) {
        [TTAdSplashMediator shareInstance].splashADShowType = TTAdSplashShowTypeHide;
    }
    [SharedAppDelegate setIsColdLaunch:NO];

    application.applicationIconBadgeNumber = [[userInfo objectForKey:@"badge"] integerValue];
    if ([[UIApplication sharedApplication] applicationState] != UIApplicationStateActive &&
        [[UIDevice currentDevice].systemVersion floatValue] < 10.0) {
        /**
         当APP启动并处于前台，APP状态是UIApplicationStateActive
         
         当弹出任何系统权限弹窗（如地理位置），此时APP状态将由UIApplicationStateActive变成UIApplicationStateInactive
         
         特殊CASE：当APP启动并马上请求弹窗系统并弹出系统弹窗时，可能导致此时APP状态为UIApplicationStateInactive或UIApplicationStateActive
         原因是APP启动并不会马上处理调用DidBecomeActive，而系统权限弹窗又会导致APP.delegate调用WillResignActive；这两个方方法的不确定性导致了此时APP状态的不确定性。
         
         1. 上述特殊CASE可能导致APP启动弹窗系统弹窗此时APP状态为UIApplicationStateInactive
         2. 正常使用中弹出系统权限弹窗
         出现这两种情况时，在iOS10以下收到推送会直接打开详情页（出现BUG，难以修复）
         */
        ((ArticleAPNsManager *)[ArticleAPNsManager sharedManager]).delegate = self;
        [[ArticleAPNsManager sharedManager] handleRemoteNotification:userInfo];
    } else {
        NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:10];
        dict[@"post_back"] = userInfo[@"post_back"];
        [dict setValue:[userInfo tt_stringValueForKey:@"o_url"]
                forKey:kSSAPNsAlertManagerSchemaKey];
        [dict setValue:[[[userInfo tt_dictionaryValueForKey:@"aps"]
                         tt_dictionaryValueForKey:@"alert"] tt_stringValueForKey:@"body"] forKey:kSSAPNsAlertManagerTitleKey];
        [dict setValue:@([userInfo tt_longlongValueForKey:@"id"])
                forKey:kSSAPNsAlertManagerOldApnsTypeIDKey];
        [dict setValue:[userInfo tt_stringValueForKey:@"rid"]
                forKey:kSSAPNsAlertManagerRidKey];
        [dict setValue:[userInfo tt_stringValueForKey:@"importance"]
                forKey:kSSAPNsAlertManagerImportanceKey];
        [dict setValue:[userInfo tt_stringValueForKey:@"attachment"]
                forKey:kSSAPNsAlertManagerAttachmentKey];
        
        //        //如果有开屏广告正在显示 就滞后显示推送弹窗, 增加一个引导页显示的条件 by xsm
        //        if(![[SSADManager shareInstance] isSplashADShowed]) {
        //            [[SSAPNsAlertManager sharedManager] showRemoteNotificationAlert:dict];
        //        } else {
        //            [[self class] setRemoteNotificationDict:dict];
        //        }
        if (![[TTAdSplashMediator shareInstance] isAdShowing] && ![FHIntroduceManager sharedInstance].isShowing) {
//#undef NSLog
//            NSLog(@"add by zjing for test---notification:%@",userInfo);
            
            [[SSAPNsAlertManager sharedManager] showRemoteNotificationAlert:dict];
        }else{
            [[self class] setRemoteNotificationDict:dict];
        }
    }
}

- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings
{
    if([TTAuthorizeManager sharedManager].pushObj.authorizeModel.isPushAuthorizeDetermined == NO){
        wrapperTrackEvent(@"pop", @"push_permission_show");
        
        if (notificationSettings.types == UIRemoteNotificationTypeNone) {
            wrapperTrackEvent(@"pop", @"push_permission_cancel");
        } else {
            wrapperTrackEvent(@"pop", @"push_permission_confirm");
        }
        [TTAuthorizeManager sharedManager].pushObj.authorizeModel.isPushAuthorizeDetermined = YES;
        [[TTAuthorizeManager sharedManager].pushObj.authorizeModel saveData];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"kSettingViewRegistPushNotification"
                                                            object:nil
                                                          userInfo:nil];
    }
    [application registerForRemoteNotifications];
}

+ (void)setRemoteNotificationDict:(NSDictionary *)dict
{
    if (dict) {
        [[NSUserDefaults standardUserDefaults] setObject:dict forKey:kTTAPNSRemoteNotificationDict];
    } else {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:kTTAPNSRemoteNotificationDict];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSDictionary *)remoteNotificationDict
{
    return [[NSUserDefaults standardUserDefaults] dictionaryForKey:kTTAPNSRemoteNotificationDict];
}

- (void)splashViewDisappearAnimationDidFinished:(NSNotification *)notification
{
    BOOL shouldShowIntroductionView = [SSUserSettingManager shouldShowIntroductionView];
    BOOL isTrying = NO;
    if (![[TTProjectLogicManager sharedInstance_tt] logicBoolForKey:@"isI18NVersion" defaultValue:NO]) {

//    if (!TTLogicBool(@"isI18NVersion", NO)) {
        isTrying = [TTAccountManager tryAssignAccountInfoFromKeychain];
    }
    
    if ((shouldShowIntroductionView && !isTrying) && [SharedAppDelegate appTopNavigationController]) {
//        [TTIntroduceViewTask showIntroductionView];
    }
    
    [[self class] showRemoteNotificationAlertIfNeeded];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"kSplashViewDisappearAnimationDidFinished" object:nil];
}

+ (void)showRemoteNotificationAlertIfNeeded
{
    NSDictionary *remoteDict = [[self class] remoteNotificationDict];

    //    if (remoteDict && ![[SSADManager shareInstance] isSplashADShowed]) {
    //        [[SSAPNsAlertManager sharedManager] showRemoteNotificationAlert:remoteDict];
    //        [self setRemoteNotificationDict:nil];
    //    }
    if (remoteDict && ![[TTAdSplashManager shareInstance] isAdShowing]) {
        [[SSAPNsAlertManager sharedManager] showRemoteNotificationAlert:remoteDict];
        [self setRemoteNotificationDict:nil];
    }
}


@end
