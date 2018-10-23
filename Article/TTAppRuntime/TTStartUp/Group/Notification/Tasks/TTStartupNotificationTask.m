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
#import <TTIndicatorView.h>
#import "TTUserSettingsReporter.h"

#import "AccountKeyChainManager.h"
#import <TTAccountBusiness.h>
#import "TTAccountLoginViewControllerGuide.h"

#import "NewFeedbackAlertManager.h"
#import "TTLocationManager.h"
#import "SSFeedbackManager.h"
#import "ExploreExtenstionDataHelper.h"
#import "SSUserSettingManager.h"
//#import "TTContactsUserDefaults.h"
#import "SSIntroduceViewController.h"
//#import "SSADManager.h"
#import "TTAdSplashMediator.h"
#import "NewsBaseDelegate.h"
#import "TTRoute.h"
#import "TTCookieManager.h"
#import "TouTiaoPushSDK.h"
#import "TTUserSettingsManager+Notification.h"
//#import "TTCommonwealManager.h"
#import "TTUserInfoStartupTask.h"
#import "TTAppStoreStarManager.h"
#import <TTDialogDirector/TTDialogDirector.h>

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
    [self uploadDeviceID];
    
    //公益项目开始计时
//    [[TTCommonwealManager sharedInstance] startMonitor];
}

- (void)uploadDeviceID
{
    [[TTInstallIDManager sharedInstance] setDidRegisterBlock:^(NSString *deviceID, NSString *installID) {
        TTChannelRequestParam *param = [TTChannelRequestParam requestParam];
        param.notice = [NSString stringWithFormat:@"%d",[TTUserSettingsManager apnsNewAlertClosed]];
        [TouTiaoPushSDK sendRequestWithParam:param completionHandler:^(TTBaseResponse *response) {
            
        }];
        
    }];
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
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(connectionChanged:) name:kReachabilityChangedNotification object:nil];
    
    //监听显示苹果商店评分系统显示时机的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appStoreStarScoreView:) name:TTAppStoreStarManagerShowNotice object:nil];
}

#pragma mark - TTAccountMulticastProtocol

- (void)onAccountStatusChanged:(TTAccountStatusChangedReasonType)reasonType platform:(NSString *)platformName
{
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
    NSString *expirationText = [[error userInfo] objectForKey:kErrorDisplayMessageKey];
    if (!expirationText) expirationText = [error.userInfo objectForKey:TTAccountErrMsgKey];
    if (!expirationText) expirationText = [error.userInfo objectForKey:@"message"];
    [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:expirationText indicatorImage:[UIImage themedImageNamed:@"close_popup_textpage"] autoDismiss:YES dismissHandler:nil];
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
    [NewsBaseDelegate startRegisterRemoteNotificationAfterDelay:5];
}

- (void)shareToPlatformNeedEnterBackground:(NSNotification *)notification {
    isShareToPlatformEnterBackground = YES;
}

- (void)connectionChanged:(NSNotification *)notification {
    static BOOL isAppLaunching = YES; // 第一次APP启动会发送kReachabilityChangedNotification通知，过滤掉请求用户信息
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
    if ([SSUserSettingManager shouldShowIntroductionView]) {
        wrapperTrackEvent(@"guide", @"show");
    }
    
    if ([SSCommonLogic accountABVersionEnabled]) {
        TTAccountLoginViewControllerGuide *loginVCGuide = [TTAccountLoginViewControllerGuide new];
        [[TTGuideDispatchManager sharedInstance_tt] addGuideViewItem:loginVCGuide withContext:self];
    }
    else {
        NSString * className = TTLogicString(@"IntroduceViewController", @"SSIntroduceViewController");
        Class cls = NSClassFromString(className);
        if (!cls) {
            cls = [SSIntroduceViewController class];
        }
        UIViewController<TTGuideProtocol> * introduceViewController = [[cls alloc] init];
        if ([introduceViewController isKindOfClass:[SSIntroduceViewController class]]) {
            [[TTGuideDispatchManager sharedInstance_tt] addGuideViewItem:introduceViewController withContext:SharedAppDelegate];
        }
    }
}

- (void)appStoreStarScoreView:(NSNotification *)notice
{
    //通用点赞动画需要特殊处理,有点赞动画的时候不执行
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] initWithDictionary:[notice userInfo]];
    BOOL isDelay = NO;
    BOOL isLike = NO;
    if ([dic objectForKey:@"isDelay"]) {
        isDelay = [dic tt_boolValueForKey:@"isDelay"];
    }
    if ([dic objectForKey:@"trigger"]) {
        isLike = [[dic tt_stringValueForKey:@"trigger"] isEqualToString:@"like"];
    }
    
    //弹窗管理器
//    [TTDialogDirector showInstantlyDialog:@"TTAppStoreStarManager" shouldShowMe:^BOOL(BOOL * _Nullable keepAlive) {
//        return [[TTAppStoreStarManager sharedInstance] meetOpenCondition];
//    } showMe:^(id  _Nonnull dialogInst) {
//
//        //原来的调起语句
//        [[TTAppStoreStarManager sharedInstance] showViewFromNotice:notice];
//
//    } hideForcedlyMe:^(id  _Nonnull dialogInst) {
//
//        //原来的关闭语句
//        [[TTAppStoreStarManager sharedInstance] dismissView];
//    }];
    
    //fixed: 应用内评分空闲时弹出即可，无需强制弹出
    [TTDialogDirector enqueueShowDialog:@"TTAppStoreStarManager" shouldShowMe:^BOOL(BOOL * _Nullable keepAlive) {
        return [[TTAppStoreStarManager sharedInstance] meetOpenCondition];
    } showMe:^(id  _Nonnull dialogInst) {
        //原来的调起语句
        [[TTAppStoreStarManager sharedInstance] showViewFromNotice:notice];
    } hideForcedlyMe:^(id  _Nonnull dialogInst) {
        //原来的关闭语句
        [[TTAppStoreStarManager sharedInstance] dismissView];
    }];
    
    //设置主动关闭执行的回调
    [[TTAppStoreStarManager sharedInstance] setDismissFinishedBlock:^{
        //关闭完成，显示下一个弹窗
        [TTDialogDirector dequeueDialog:@"TTAppStoreStarManager"];
    }];
    
}

- (void)appStoreStarScoreViewFromDiggAnimation:(NSNotification *)notice
{
    NSNotification *noticeTemp = [[NSNotification alloc] initWithName:notice.name object:nil userInfo:@{@"trigger":@"like",@"isDelay":@(1)}];
    [self appStoreStarScoreView:noticeTemp];
}
@end
