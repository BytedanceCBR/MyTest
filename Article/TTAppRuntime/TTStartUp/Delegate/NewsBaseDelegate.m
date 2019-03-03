//
//  NewsBaseDelegate.m
//  Article
//
//  Created by Zhang Leonardo on 12-11-27.
//
//

#import "NewsBaseDelegate.h"
#import <TTWeChatShare.h>
#import <TTAccountBusiness.h>
#import "TTRoute.h"
#import "TTIndicatorView.h"
#import "SSFeedbackManager.h"
#import "NewFeedbackAlertManager.h"
#import "TTArticleCategoryManager.h"
#import "TTUserSettings/TTUserSettingsReporter.h"
#import "SSCommonLogic.h"
#import "ArticleModelUpdateHelper.h"
#import "ExploreLogicSetting.h"

#import "TTTrackerWrapper.h"

//#if GREY
//#import "TTSparkRescue.h"
//#endif

#import "TTDBCenter.h"

#import "Article.h"

#import <UserNotifications/UserNotifications.h>
#import "TTNotificationCenterDelegate.h"

#import <TTNetBusiness/TTNetworkUtilities.h>
#import "TTPostDataHttpRequestSerializer.h"

#import <DTShareKit/DTOpenKit.h>
#import "TTShareConstants.h"
#import "SSPayManager.h"

#import <TTABManager/TTABHelper.h>
#import "TTVersionHelper.h"
#import "TTDeviceHelper.h"
#import "TTURLUtils.h"
#import "NSObject+TTAdditions.h"
#import "UIDevice+TTAdditions.h"

//监控
#import "TTMonitor.h"
#import "TTMemoryMonitor.h"

#import "TTDetailContainerViewController.h"
#import "ArticleTabBarStyleNewsListViewController.h"
#import "TTNavigationController.h"
#import "TTArticleTabBarController.h"
#import "TTCategorySelectorView.h"
#import "TTAuthorizeManager.h"

#import "revision.h"
#import <TTNetBusiness/TTRouteSelectionServerConfig.h>
#import "TTOpenInSafariWindow.h"
#import "TTLauchProcessManager.h"
#import "TTStartupTask.h"
#import "NewsBaseDelegate+Serial.h"
#import "NewsBaseDelegate+UI.h"
#import "NewsBaseDelegate+AD.h"
#import "NewsBaseDelegate+Notification.h"
#import "NewsBaseDelegate+Service.h"
#import "NewsBaseDelegate+Interface.h"
#import "NewsBaseDelegate+SDKs.h"
#import "NewsBaseDelegate+Debug.h"
#import "NewsBaseDelegate+OpenURL.h"
#import "TTStartupTasksTracker.h"

#import "TTLaunchOrientationHelper.h"
#import "TTViewControllerHierarchyHelper.h"
#import "TTLocalImageTracker.h"
#import <TTDialogDirector/TTDialogDirector.h>

///...
//#import "TVLManager.h"

@import CoreSpotlight;

static NSTimeInterval startTime;
static NSTimeInterval lastTime;

//static NSString *const kTTUseWebViewLaunch = @"kTTUseWebViewLaunch";

@interface NewsBaseDelegate()<CrashlyticsDelegate, TTWeChatSharePayDelegate, TTWeChatShareRequestDelegate>{
    NSUInteger _reportTryCount;
    NSMutableDictionary * _remotoNotificationDict;
}

@property (nonatomic, copy)   NSString *deviceTokenString;
@property (nonatomic, strong) TTNavigationController *navigationController;
@property (nonatomic, copy)   NSDictionary *launchOptions;
//@property (nonatomic, assign) BOOL useWebview;//连续崩溃使用webview作为主视图
@property (nonatomic, strong) NSMutableArray<TTStartupTask *> *residentTasks;
@property (nonatomic, strong) dispatch_queue_t barrierQueue;
@property (nonatomic, assign, readwrite) BOOL userLaunchTheAppDirectly;

@end


@implementation NewsBaseDelegate

@synthesize window = _window;
@synthesize  deviceTokenString;
- (void)dealloc
{
    self.navigationController = nil;
    self.deviceTokenString = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

//- (void)setUseWebview:(BOOL)useWebview {
//    [[NSUserDefaults standardUserDefaults] setBool:useWebview forKey:kTTUseWebViewLaunch];
//    [[NSUserDefaults standardUserDefaults] synchronize];
//}
//
//- (BOOL)useWebview {
//    return [[NSUserDefaults standardUserDefaults] boolForKey:kTTUseWebViewLaunch];
//}

- (void)cleanCoreDataIfNeeded
{
    BOOL needCleanCoreData = [[NSUserDefaults standardUserDefaults] boolForKey:@"SSSafeMode"];
    if (needCleanCoreData) {
        [SSCommonLogic setNeedCleanCoreData:YES];
        [ArticleModelUpdateHelper deleteCoreDataFileIfNeed];
        [TTDBCenter deleteAllDBFiles];
        [ExploreLogicSetting tryClearCoreDataCache];
        
        // 清理与频道数据关联的UserDefalts数据，否则会导致用户频道重置为默认频道
        [TTArticleCategoryManager clearHasGotRemoteData];
        [TTArticleCategoryManager setGetCategoryVersion:nil];
        
        [[NSUserDefaults standardUserDefaults] setValue:@(NO) forKey:@"SSSafeMode"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (BOOL)application:(UIApplication *)application willFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [TTAccountVersionAdapter oldAccountUserCompatibility];

    [TTDialogDirector setQueueEnabled:NO];

    return YES;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.userLaunchTheAppDirectly = SSIsEmptyDictionary(launchOptions);
    if ([TTVersionHelper isFirstLaunchAfterUpdate]) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"ArticleDetailTitleViewTip"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithLongLong:[NSObject currentUnixTime]] forKey:@"kTrackTime_didFinishLaunch_start"];

    NSMutableDictionary *launchParams = [[NSMutableDictionary alloc] init];
    [launchParams setValue:[TTVersionHelper lastLaunchVersion] forKey:@"last_launch_version"];
    [launchParams setValue:[TTVersionHelper lastUpdateVersion] forKey:@"last_update_version"];
    [launchParams setValue:@([TTVersionHelper lastUpdateTimestamp]) forKey:@"last_update_time"];
    [launchParams setValue:[TTVersionHelper currentVersion] forKey:@"now_version"];
    [[TTStartupTasksTracker sharedTracker] cacheInitializeDevLog:@"AppLaunch" params:launchParams];
    [[TTLocalImageTracker sharedTracker] setup];
    
    self.residentTasks = [NSMutableArray array];
    self.barrierQueue = dispatch_queue_create("com.bytedance.startup", DISPATCH_QUEUE_CONCURRENT);
    
    startTime = CFAbsoluteTimeGetCurrent();
    lastTime = 0;
    //The delegate must be set before the application returns from applicationDidFinishLaunching:.
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunguarded-availability"
    [UNUserNotificationCenter currentNotificationCenter].delegate = [TTNotificationCenterDelegate sharedNotificationCenterDelegate];
#pragma clang diagnostic pop
    
    return [self application:application onlineBoundleWithOptions:launchOptions];
}
    
//正常打包，上线，走此方法
- (BOOL)application:(UIApplication *)application onlineBoundleWithOptions:(NSDictionary *)launchOptions
{
    __weak typeof(self) wself = self;
    
    //CompletionBlock:头条正常启动逻辑
    [wself trackCurrentIntervalInMainThreadWithTag:@"ContinuousCrashProtection"];
    
    //内部监控上报
    [[TTLauchProcessManager shareInstance] setReportBlock:^(NSString *key, NSDictionary *info) {
        //crash的预处理逻辑
        if ([key isEqualToString:TTLauchProcessLaunchCrash]) {
            //优先清理coredata缓存
            [[NSUserDefaults standardUserDefaults] setValue:@(YES) forKey:@"SSSafeMode"];
            [wself cleanCoreDataIfNeeded];
            
//            //连续崩溃第五次才启用安全模式，第一次发生崩溃的时候崩溃计数为0，4就是第五次
//            if([TTLauchProcessManager shareInstance].currentCrashCount >= 4) {
//                self.useWebview = YES;
//            }
            
            [[TTRouteSelectionServerConfig sharedTTRouteSelectionServerConfig] disableChromium];
            [[TTRouteSelectionServerConfig sharedTTRouteSelectionServerConfig] disableHttpDns];
            [[TTRouteSelectionServerConfig sharedTTRouteSelectionServerConfig] disableSDNetwork];
            
        }
        [[TTMonitor shareManager] trackService:key status:1 extra:info];
    }];
    
    //CompletionBlock:头条正常启动逻辑
    [[TTLauchProcessManager shareInstance] setBoolCompletionBlock:^BOOL{
        [wself trackCurrentIntervalInMainThreadWithTag:@"ContinuousCrashProtection"];
        
//        if (self.useWebview) {
//            [self didFinishWebviewLaunchingForApplication:application WithOptions:launchOptions];
//            self.useWebview = NO;
//            return YES;
//        } else {
            return [wself application:application refactorLaunchProcessWithOptions:launchOptions];
//        }
    }];
    
    //启动执行逻辑，完成后调用CompletionBlock
    return [[TTLauchProcessManager shareInstance] launchContinuousCrashProcess];
}

//refactorLaunchProcess
- (BOOL)application:(UIApplication *)application refactorLaunchProcessWithOptions:(NSDictionary *)launchOptions {
    [self trackCurrentIntervalInMainThreadWithTag:@"refactor start"];
    [self didFinishSerialLaunchingForApplication:application WithOptions:launchOptions];
    [self didFinishUILaunchingForApplication:application WithOptions:launchOptions];
    [self didFinishNotificationLaunchingForApplication:application WithOptions:launchOptions];
    [self didFinishSDKsLaunchingForApplication:application WithOptions:launchOptions];
    [self didFinishServiceLaunchingForApplication:application WithOptions:launchOptions];
    [self didFinishInterfaceLaunchingForApplication:application WithOptions:launchOptions];
    [self didFinishOpenURLLaunchingForApplication:application WithOptions:launchOptions];
    [self didFinishADLaunchingForApplication:application WithOptions:launchOptions];
#ifdef DEBUG
    [self didFinishDebugLaunchingForApplication:application WithOptions:launchOptions];
#endif
    
    uint64_t mainEndTime = [NSObject currentUnixTime];
    dispatch_barrier_sync(self.barrierQueue, ^{
        LOGD(@"startup done!!!!!!!");
    });
    uint64_t allEndTime = [NSObject currentUnixTime];
    double waitTime = [NSObject machTimeToSecs:(allEndTime - mainEndTime)] * 1000;
    [[TTStartupTasksTracker sharedTracker] cacheInitializeDevLog:@"AppLaunchFinish" params:@{@"wait_time" : @(waitTime)}];
    
    [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithLongLong:[NSObject currentUnixTime]] forKey:@"kTrackTime_didFinishLaunch_end"];

    
    return YES;
}

+ (void)startRegisterRemoteNotification
{
    [self startRegisterRemoteNotificationAfterDelay:.5];
}

+ (void)startRegisterRemoteNotificationAfterDelay:(int)secs
{
    [[TTAuthorizeManager sharedManager].pushObj filterAuthorizeStrategyWithCompletionHandler:^{
        [self startRegisterRemoteNotificationAfterAuthorizeWithDelay:secs];
    } sysAuthFlag:0]; //显示系统弹窗前显示自有弹窗的逻辑下掉，0代表直接显示系统弹窗，1代表先自有弹窗，再系统弹窗
}

+ (void)startRegisterRemoteNotificationAfterAuthorizeWithDelay:(int)secs{
    if(secs > 0)
    {
        int64_t delayInSeconds = secs;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            if ([TTDeviceHelper OSVersionNumber] >= 10.0) {
                [[TTNotificationCenterDelegate sharedNotificationCenterDelegate] registerNotificationCenter];
            }
            else if ([TTDeviceHelper OSVersionNumber] >= 8.0) {
                UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:(UIRemoteNotificationTypeBadge
                                                                                                     |UIRemoteNotificationTypeSound
                                                                                                     |UIRemoteNotificationTypeAlert) categories:nil];
                [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
                
            }
            else {
                [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge |
                                                                                       UIRemoteNotificationTypeAlert |
                                                                                       UIRemoteNotificationTypeSound)];
            }
        });
    }
    else
    {
        if ([TTDeviceHelper OSVersionNumber] >= 10.0) {
            [[TTNotificationCenterDelegate sharedNotificationCenterDelegate] registerNotificationCenter];
        }
        else if ([TTDeviceHelper OSVersionNumber] >= 8.0) {
            UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:(UIRemoteNotificationTypeBadge
                                                                                                 |UIRemoteNotificationTypeSound
                                                                                                 |UIRemoteNotificationTypeAlert) categories:nil];
            [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
            
        }
        else {
            [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge |
                                                                                   UIRemoteNotificationTypeAlert |
                                                                                   UIRemoteNotificationTypeSound)];
        }
    }
}

#pragma mark -

- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings
{
    [self.residentTasks enumerateObjectsUsingBlock:^(TTStartupTask * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj conformsToProtocol:@protocol(UIApplicationDelegate)] && [obj respondsToSelector:_cmd]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            [obj performSelector:_cmd withObject:application withObject:notificationSettings];
#pragma clang diagnostic pop
        }
    }];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    [self.residentTasks enumerateObjectsUsingBlock:^(TTStartupTask * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj conformsToProtocol:@protocol(UIApplicationDelegate)] && [obj respondsToSelector:_cmd]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            [obj performSelector:_cmd withObject:application];
#pragma clang diagnostic pop
        }
    }];
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    NSDictionary *extra = nil;
    NSMutableDictionary *value = nil;
    if ([SSCommonLogic shouldMonitorMemoryWarningHierarchy]) {
        NSString *viewHierarchy = [TTViewControllerHierarchyHelper viewControllerHierarchyString];
        if (!isEmptyString(viewHierarchy)) {
            extra = [NSDictionary dictionaryWithObjectsAndKeys:viewHierarchy, @"vc", nil];
        }
        
        value = [[NSMutableDictionary alloc] init];
        
        //当前时间距离启动时间
        int64_t load = [[[NSUserDefaults standardUserDefaults] valueForKey:@"kTrackTime_load"] longLongValue];
        int64_t now = [NSObject currentUnixTime];
        NSTimeInterval interval = [NSObject machTimeToSecs:(now - load)];
        [value setValue:@(interval) forKey:@"interval"];
        
        //设备物理内存
        int64_t physical = [[NSProcessInfo processInfo] physicalMemory];
        double physicalMBytes = (double)physical/(1024.0 * 1024.0);
        [value setValue:@(physicalMBytes) forKey:@"physical"];
        
        //memory warning时的resident
        double residentMBytes = [TTMemoryMonitor currentMemoryUsageInMBytes];
        [value setValue:@(residentMBytes) forKey:@"memory"];
        
        //memory warning时根据公示计算出的
        double formularMBytes = [TTMemoryMonitor currentMemoryUsageByAppleFormula];
        [value setValue:@(formularMBytes) forKey:@"formular_memory"];
        
        //memory warning时进程占用的内存/物理内存
        double memoryWarningProportion = formularMBytes / physicalMBytes;
        [value setValue:@(memoryWarningProportion) forKey:@"proportion"];
        
        //app状态
        UIApplicationState appState = [[UIApplication sharedApplication] applicationState];
        [value setValue:@(appState) forKey:@"status"];
    }
    [[TTMonitor shareManager] trackService:@"tt_memory_warning" value:value extra:extra];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    [self.residentTasks enumerateObjectsUsingBlock:^(TTStartupTask * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj conformsToProtocol:@protocol(UIApplicationDelegate)] && [obj respondsToSelector:_cmd]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            [obj performSelector:_cmd withObject:application];
#pragma clang diagnostic pop
        }
    }];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    [self.residentTasks enumerateObjectsUsingBlock:^(TTStartupTask * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj conformsToProtocol:@protocol(UIApplicationDelegate)] && [obj respondsToSelector:_cmd]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            [obj performSelector:_cmd withObject:application];
#pragma clang diagnostic pop
        }
    }];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    WeakSelf;
    [TTLaunchOrientationHelper executeBlockAfterStatusbarOrientationNormal:^{
        StrongSelf;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        for(TTStartupTask *task in self.residentTasks) {
            if ([task conformsToProtocol:@protocol(UIApplicationDelegate)] && [task respondsToSelector:_cmd] && [[task performSelector:_cmd withObjects:application, url, sourceApplication, annotation, nil] boolValue]) {
                return;
            }
        }
#pragma clang diagnostic pop
    }];
    
//    if ([TTAccountAuthWeibo handleOpenURL:url]) {
//        return YES;
//    }
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    [self.residentTasks enumerateObjectsUsingBlock:^(TTStartupTask * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj conformsToProtocol:@protocol(UIApplicationDelegate)] && [obj respondsToSelector:_cmd]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            [obj performSelector:_cmd withObject:application];
#pragma clang diagnostic pop
        }
    }];
    
    ///...
//    [TVLManager stopOpenGLESActivity];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    [self.residentTasks enumerateObjectsUsingBlock:^(TTStartupTask * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj conformsToProtocol:@protocol(UIApplicationDelegate)] && [obj respondsToSelector:_cmd]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            [obj performSelector:_cmd withObject:application];
#pragma clang diagnostic pop
        }
    }];
    
    ///...
//    [TVLManager startOpenGLESActivity];
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    [self.residentTasks enumerateObjectsUsingBlock:^(TTStartupTask * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj conformsToProtocol:@protocol(UIApplicationDelegate)] && [obj respondsToSelector:_cmd]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            [obj performSelector:_cmd withObject:application withObject:deviceToken];
#pragma clang diagnostic pop
        }
    }];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    [self.residentTasks enumerateObjectsUsingBlock:^(TTStartupTask * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj conformsToProtocol:@protocol(UIApplicationDelegate)] && [obj respondsToSelector:_cmd]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            [obj performSelector:_cmd withObject:application withObject:error];
#pragma clang diagnostic pop
        }
    }];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    WeakSelf;
    [TTLaunchOrientationHelper executeBlockAfterStatusbarOrientationNormal:^{
        StrongSelf;
        [self.residentTasks enumerateObjectsUsingBlock:^(TTStartupTask * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj conformsToProtocol:@protocol(UIApplicationDelegate)] && [obj respondsToSelector:_cmd]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
                [obj performSelector:_cmd withObject:application withObject:userInfo];
#pragma clang diagnostic pop
            }
        }];
    }];
}

- (UIInterfaceOrientationMask)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    for(TTStartupTask *task in self.residentTasks) {
        if ([task conformsToProtocol:@protocol(UIApplicationDelegate)] && [task respondsToSelector:_cmd]) {
            return [[task performSelector:_cmd withObjects:application, window, nil] unsignedIntegerValue];
        }
    }
#pragma clang diagnostic pop
    return UIInterfaceOrientationMaskAll;
}

- (void)application:(UIApplication *)application willChangeStatusBarOrientation:(UIInterfaceOrientation)newStatusBarOrientation duration:(NSTimeInterval)duration
{
    [self.residentTasks enumerateObjectsUsingBlock:^(TTStartupTask * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj conformsToProtocol:@protocol(UIApplicationDelegate)] && [obj respondsToSelector:_cmd]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            [obj performSelector:_cmd withObjects:application, @(newStatusBarOrientation), @(duration), nil];
#pragma clang diagnostic pop
        }
    }];
}

#ifdef __IPHONE_9_0
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunguarded-availability"
- (void)application:(UIApplication *)application performActionForShortcutItem:(UIApplicationShortcutItem *)shortcutItem completionHandler:(void (^)(BOOL))completionHandler
#pragma clang diagnostic pop
{
    [self.residentTasks enumerateObjectsUsingBlock:^(TTStartupTask * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj conformsToProtocol:@protocol(UIApplicationDelegate)] && [obj respondsToSelector:_cmd]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            [obj performSelector:_cmd withObjects:application, shortcutItem, completionHandler, nil];
#pragma clang diagnostic pop
        }
    }];
}
#endif

- (BOOL)application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void(^)(NSArray *restorableObjects))restorationHandler {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    for(TTStartupTask *task in self.residentTasks) {
        if ([task conformsToProtocol:@protocol(UIApplicationDelegate)] && [task respondsToSelector:_cmd]) {
            [[task performSelector:_cmd withObjects:application, userActivity, restorationHandler, nil] boolValue];
        }
    }
#pragma clang diagnostic pop
    return YES;
}

#pragma mark apple watch call back
- (void)application:(UIApplication *)application handleWatchKitExtensionRequest:(NSDictionary *)userInfo reply:(void(^)(NSDictionary *replyInfo))reply {
    [self.residentTasks enumerateObjectsUsingBlock:^(TTStartupTask * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj conformsToProtocol:@protocol(UIApplicationDelegate)] && [obj respondsToSelector:_cmd]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            [obj performSelector:_cmd withObjects:application, userInfo, reply, nil];
#pragma clang diagnostic pop
        }
    }];
}

- (NSString *)umengTrackAppkey
{
    SSLog(@"umeng track app key need implement in subclass");
    return nil;
}

//umeng
- (NSString *)appKey
{
    NSString *result = @"59acfc40734be44a3f000685";
    return result;
}

- (NSString *)weixinAppID
{
    SSLog(@"NewsBaseDelegate weixinAppID need sub class implement");
    return nil;
}

- (NSString *)dingtalkAppID {
    return nil;
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
    NSString * fixedGroupIDString = [SSCommonLogic fixStringTypeGroupID:groupID];
    
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
    
    [[self appTopNavigationController] popToRootViewControllerAnimated:NO];
    
    TTDetailContainerViewController *detailController = [[TTDetailContainerViewController alloc] initWithArticle:article
                                                                                                          source:NewsGoDetailFromSourceAPNS
                                                                                                       condition:nil];
    [[self appTopNavigationController] pushViewController:detailController animated:YES];
}

- (void)addFeedbackLaunchCheck
{
    [[NewFeedbackAlertManager alertManager] startAlert];
    if ([SSCommonLogic couldRequestForKey:SSCommonLogicTimeDictRequestFeedbackKey]) {
        [[SSFeedbackManager shareInstance] checkHasNewFeedback];
        [SSCommonLogic updateRequestTimeForKey:SSCommonLogicTimeDictRequestFeedbackKey];
    }
}

#pragma mark -- TTAppTopNavigationControllerDatasource

//- (UINavigationController *)appTopNavigationController
//{
//    return self.navigationController;
//}

- (UINavigationController*)appTopNavigationController {
    
    if ([TTDeviceHelper isPadDevice]) {
        _navigationController = (TTNavigationController*)(self.window.rootViewController);
    } else {
        TTArticleTabBarController * rootTabController = (TTArticleTabBarController*)self.window.rootViewController;
        if ([rootTabController isKindOfClass:[TTArticleTabBarController class]]) {
            _navigationController = (TTNavigationController*)rootTabController.selectedViewController;
        }
    }
    
    return _navigationController;
}

#pragma mark -- TTCategorySelectorView
- (TTCategorySelectorView *)categorySelectorView {
    return [self exploreMainViewController].categorySelectorView;
}

- (TTExploreMainViewController *)exploreMainViewController {
    if ([TTDeviceHelper isPadDevice]) {
        return nil;
    }
    
    TTArticleTabBarController * rootTabController = (TTArticleTabBarController*)self.window.rootViewController;
    TTNavigationController * navigationController = (TTNavigationController*)(rootTabController.viewControllers.firstObject);
    
    ArticleTabBarStyleNewsListViewController * tabbarNewsVC = navigationController.viewControllers.firstObject;
    
    return tabbarNewsVC.mainVC;
}

- (void)trackCurrentIntervalInMainThreadWithTag:(NSString *)tag {
    NSTimeInterval current = CFAbsoluteTimeGetCurrent();
    double timeInterval = lastTime == 0 ? (current - startTime) * 1000 : (current - lastTime) * 1000;
    LOGD(@"TTLaunch For %@ Total = %fms Interval = %fms", tag, (current - startTime) * 1000, timeInterval);
    lastTime = current;
    [[TTStartupTasksTracker sharedTracker] trackStartupTaskInMainThread:tag withInterval:timeInterval];
}

- (void)addResidentTaskIfNeeded:(TTStartupTask *)task {
    if (task && !isEmptyString([task taskIdentifier]) && [task isResident]) {
        [self.residentTasks addObject:task];
    }
}

- (NSTimeInterval)startTime {
    return startTime;
}

#pragma mark - TTWeChatSharePayDelegate

- (void)weChatShare:(TTWeChatShare *)weChatShare payResponse:(PayResp *)payResponse {
    [[SSPayManager sharedPayManager] handleWXPayResponse:payResponse];
}

#pragma mark - TTWeChatShareRequestDelegate
- (void)weChatShare:(TTWeChatShare *)weChatShare receiveRequest:(BaseReq *)request {
    if([request isKindOfClass:[ShowMessageFromWXReq class]]) {
        WXMediaMessage *message = ((ShowMessageFromWXReq*)request).message;
        WXAppExtendObject *media = message.mediaObject;
        NSString *extInfo = media.extInfo;
        NSData *extData = [extInfo dataUsingEncoding:NSUTF8StringEncoding];
        
        NSDictionary *extInfoDic = [NSJSONSerialization JSONObjectWithData:extData
                                                                   options:NSJSONReadingMutableContainers
                                                                     error:nil];
        NSString *schemaString = [extInfoDic tt_stringValueForKey:@"localUrl"];
        
        if (schemaString) {
            //定位到对应的文章、动态或话题详情页
            [[TTRoute sharedRoute] openURLByPushViewController:[NSURL URLWithString:schemaString]];
        }
    }
}

@end

