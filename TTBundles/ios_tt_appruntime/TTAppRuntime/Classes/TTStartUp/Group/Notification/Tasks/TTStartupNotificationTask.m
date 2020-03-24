//
//  TTStartupNotificationTask.m
//  Article
//
//  Created by fengyadong on 17/1/18.
//
//

#import "TTStartupNotificationTask.h"
#import "TTApplicationHeader.h"
#import "TTProjectLogicManager.h"
#import "TTInstallIDManager.h"
#import "TTShareConstants.h"
#import "TTReachability.h"
#import "ExploreEntryManager.h"
#import "TTIndicatorView.h"
#import "TTUserSettingsReporter.h"

#import "AccountKeyChainManager.h"
#import "TTAccountBusiness.h"
#import "TTAccountLoginViewControllerGuide.h"

#import "NewFeedbackAlertManager.h"
#import "TTLocationManager.h"
#import "SSFeedbackManager.h"
#import "ExploreExtenstionDataHelper.h"
#import "SSUserSettingManager.h"
//#import "TTContactsUserDefaults.h"
//#import "SSIntroduceViewController.h"
//#import "SSADManager.h"
#import "TTAdSplashMediator.h"
#import "NewsBaseDelegate.h"
#import "TTRoute.h"
#import "TTCookieManager.h"

#import "TTUserSettingsManager+Notification.h"
//#import "TTCommonwealManager.h"
#import "TTUserInfoStartupTask.h"
#import "TTAppStoreStarManager.h"
#import <TTDialogDirector/TTDialogDirector.h>
#import "SSCommonLogic.h"
#import <TTArticleBase/ExploreLogicSetting.h>
#import <TTBaseLib/TTSandBoxHelper.h>
#import "TTLaunchDefine.h"
#import <FHHouseBase/TTSandBoxHelper+House.h>
#import <FHCHousePush/TTPushServiceDelegate.h>

DEC_TASK("TTStartupNotificationTask",FHTaskTypeNotification,TASK_PRIORITY_HIGH);

@interface TTStartupNotificationTask ()
<
TTAccountMulticastProtocol
>
@end

@implementation TTStartupNotificationTask

- (void)dealloc
{
    [TTAccount removeMulticastDelegate:self];
}

- (NSString *)taskIdentifier {
    return @"Notification";
}

- (BOOL)isResident {
    return YES;
}

- (void)startWithApplication:(UIApplication *)application options:(NSDictionary *)launchOptions {
    [super startWithApplication:application options:launchOptions];
    if (!TTLogicBool(@"isI18NVersion", NO)) {
        [[AccountKeyChainManager sharedManager] start];
    }
    [self registerNotification];
}


- (void)registerNotification {
    
    [TTAccount addMulticastDelegate:self];
    
#warning NewAccount @zuopengliu
    //    [[NSNotificationCenter defaultCenter] addObserver:self
    //                                             selector:@selector(autoLoginFinished:)
    //                                                 name:kAutoLoginFinishedNotification
    //                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(mainViewDidShow:)
                                                 name:kApplicationMainViewDidShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(introductionViewControllerDismissed:)
                                                 name:kIntroductionViewControllerRemovedNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(shareToPlatformNeedEnterBackground:) name:kShareToPlatformNeedEnterBackground object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(connectionChanged:) name:TTReachabilityChangedNotification object:nil];
}

#pragma mark - TTAccountMulticastProtocol

- (void)onAccountStatusChanged:(TTAccountStatusChangedReasonType)reasonType platform:(NSString *)platformName
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kFHLogInAccountStatusChangedNotification object:@(reasonType)];
    // 只清理收藏和历史，清理所有orderedData可能会很慢
    [ExploreLogicSetting clearFavoriteCoreData];
    [ExploreLogicSetting clearReadHistoryCoreData];
    [ExploreLogicSetting clearPushHistoryCoreData];
    
    // 清理订阅表
    [[ExploreEntryManager sharedManager] clearAll];
    
    // 清理sqlite文件（注：删掉sqlite文件getlocal仍然有数据，怀疑是shm和wal文件的问题）
    //[ExploreLogicSetting clearCoreDataCache];
    
    // 不删除sqlite文件，为了不影响逻辑保留[ExploreLogicSetting clearCoreDataCache]里发通知的代码
    [[NSNotificationCenter defaultCenter] postNotificationName:kExploreClearedCoreDataCacheNotification
                                                        object:self
                                                      userInfo:nil];
    
    //    if (reasonType == TTAccountStatusChangedReasonTypeAutoSyncLogin) {
    //        BOOL isSplashDisplaying = [[SSADManager shareInstance] isSplashADShowed];
    //        // if auto login tried and failed and should display introduction view
    //        if([[notification userInfo] objectForKey:@"error"] && [SSUserSettingManager shouldShowIntroductionView] && !isSplashDisplaying) {
    //            [self showIntroductionView];
    //        }
    //    }
}

- (void)onAccountSessionExpired:(NSError *)error
{
//    NSString *expirationText = [[error userInfo] objectForKey:kErrorDisplayMessageKey];
//    if (!expirationText) expirationText = [error.userInfo objectForKey:TTAccountErrMsgKey];
//    if (!expirationText) expirationText = [error.userInfo objectForKey:@"message"];
//    [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:expirationText indicatorImage:[UIImage themedImageNamed:@"close_popup_textpage"] autoDismiss:YES dismissHandler:nil];
}

- (void)autoLoginFinished:(NSNotification*)notification
{
//    BOOL isSplashDisplaying = [[SSADManager shareInstance] isSplashADShowed];
    BOOL isSplashDisplaying = [TTAdSplashMediator shareInstance].isAdShowing;
    // if auto login tried and failed and should display introduction view
    if([[notification userInfo] objectForKey:@"error"] && [SSUserSettingManager shouldShowIntroductionView] && !isSplashDisplaying)
    {
        [self showIntroductionView];
    }
}

#pragma mark - Notification

- (void)mainViewDidShow:(NSNotification *)notify {
    [self addFeedbackLaunchCheck];
    
    //更新扩展的location
    TTPlacemarkItem *locationItem = [TTLocationManager sharedManager].placemarkItem;
    if (locationItem.coordinate.latitude * locationItem.coordinate.longitude > 0) {
        [ExploreExtenstionDataHelper saveSharedLatitude:locationItem.coordinate.latitude];
        [ExploreExtenstionDataHelper saveSharedLongitude:locationItem.coordinate.longitude];
    }
    [ExploreExtenstionDataHelper saveSharedUserCity:[TTLocationManager sharedManager].city];
    [[TTCookieManager sharedManager] updateLocationCookie];
}

- (void)introductionViewControllerDismissed:(NSNotification*)notification {
    [NewsBaseDelegate startRegisterRemoteNotificationAfterDelay:1];
}

- (void)shareToPlatformNeedEnterBackground:(NSNotification *)notification {
    isShareToPlatformEnterBackground = YES;
}

- (void)connectionChanged:(NSNotification *)notification {
    static BOOL isAppLaunching = YES; // 第一次APP启动会发送TTReachabilityChangedNotification通知，过滤掉请求用户信息
    if (TTNetworkConnected() && !isAppLaunching) {
        if ([UIApplication sharedApplication].applicationState == UIApplicationStateActive) {
            [TTAccountManager startGetAccountStatus:NO context:self];
        }
    }
    isAppLaunching = NO;
    
    TTReachability *reachability = (TTReachability *)notification.object;
    NetworkStatus status = [reachability currentReachabilityStatus];
    [TTDebugRealMonitorManager cacheDevLogWithEventName:@"NetworkChange" params:@{@"statis" : @(status)}];
}

- (void)addFeedbackLaunchCheck {
    [[NewFeedbackAlertManager alertManager] startAlert];
    if ([SSCommonLogic couldRequestForKey:SSCommonLogicTimeDictRequestFeedbackKey]) {
        [[SSFeedbackManager shareInstance] checkHasNewFeedback];
        [SSCommonLogic updateRequestTimeForKey:SSCommonLogicTimeDictRequestFeedbackKey];
    }
}

- (void)showIntroductionView {
    
//    if ([SSUserSettingManager shouldShowIntroductionView]) {
//        wrapperTrackEvent(@"guide", @"show");
//    }
//    
//    if ([SSCommonLogic accountABVersionEnabled]) {
//        TTAccountLoginViewControllerGuide *loginVCGuide = [TTAccountLoginViewControllerGuide new];
//        [[TTGuideDispatchManager sharedInstance_tt] addGuideViewItem:loginVCGuide withContext:self];
//    }
//    else {
//        NSString * className = TTLogicString(@"IntroduceViewController", @"SSIntroduceViewController");
//        Class cls = NSClassFromString(className);
//        if (!cls) {
//            cls = [SSIntroduceViewController class];
//        }
//        UIViewController<TTGuideProtocol> * introduceViewController = [[cls alloc] init];
//        if ([introduceViewController isKindOfClass:[SSIntroduceViewController class]]) {
//            [[TTGuideDispatchManager sharedInstance_tt] addGuideViewItem:introduceViewController withContext:SharedAppDelegate];
//        }
//    }
}

@end
