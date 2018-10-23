//
//  SSDebugViewController.m
//  Article
//
//  Created by SunJiangting on 15-2-27.
//
//

#if INHOUSE

#import "SSDebugViewController.h"
#import "SSQRCodeScanViewController.h"
#import "SSWebViewController.h"
#import "SSLocationPickerController.h"
#import "TTArticleCategoryManager.h"
#import "MBProgressHUD.h"
#import "SSDebugPingViewController.h"
#import "SSDebugDNSViewController.h"
#import "DebugUmengIndicator.h"
#import "SSDebugUserDefaultsViewController.h"
#import "TTInstallIDManager.h"
#import "TTIndicatorView.h"
#import "TTThemedAlertController.h"
#import "TTLocationManager.h"
#import "TTNetworkManager.h"
#import "TTLocationManager.h"
#import "NewsUserSettingManager.h"
#import "FLEXManager.h"
#import "TTMemoryMonitor.h"
#import "TTTrackerWrapper.h"
#import "TTRoute.h"
#import "TTSandBoxHelper.h"
#import "TSVDebugViewController.h"
#import "TADDebugViewController.h"
//#import <TTLiveMainUI/TTLiveMainViewController.h>
//#import "TTFantasyWindowManager.h"

#import "ArticleMobileSettingViewController.h"
#import "TTPersistence.h"
#import "TTURLUtils.h"
#import "WDCommonLogic.h"

#import "ExploreCellHelper.h"
#import "TTStringHelper.h"

#import "TTVideoTip.h"
#import "TTLogServer.h"
#import "TTUserSettings/TTUserSettingsManager+FontSettings.h"
#import <TTAccountBusiness.h>

//#import "TTABAuthorizationManager.h"
#import "TTCanvasBundleManager.h"
#import <TTServiceKit/TTServiceCenter.h>
#import "TTAdManagerProtocol.h"
#import "SSInHouseDebugViewController.h"
//#import "TTContactsUserDefaults.h"
#import "TTSettingsBrowserViewController.h"
#if INHOUSE
#import "TTDebugAssistant.h"
#import <TTDebugAssistant/JIRAScreenshotManager.h>
#endif
#import "TTRNBundleManager.h"
#import <TTSettingsManager/TTSettingsManager+SaveSettings.h>
#import <AKWebViewBundlePlugin/TTDetailWebContainerDebugger.h>
#import "TTVSettingsConfiguration.h"
#import "SSFetchSettingsManager.h"
#import "TTAppStoreStarManager.h"
#import "TTClientABTestBrowserViewController.h"
//#import "TTFDashboardViewController.h"

//#import "TTXiguaLiveManager.h"
extern BOOL ttvs_isVideoNewRotateEnabled(void);
extern void ttvs_setIsVideoNewRotateEnabled(BOOL enabled);
extern BOOL ttvs_isVideoDetailPlayLastEnabled(void);
extern NSDictionary *ttvs_videoMidInsertADDict(void);
extern NSInteger ttvs_getVideoMidInsertADReqStartTime(void);
extern NSInteger ttvs_getVideoMidInsertADReqEndTime(void);


@interface SSDebugViewController () {
    
}

@property(nonatomic, weak)   STTableViewCellItem *itemAB;
@property(nonatomic, weak)   STTableViewCellItem *itemSourceImg;

@property(nonatomic, weak)   STTableViewCellItem *item01;
@property(nonatomic, weak)   STTableViewCellItem *item10;
@property(nonatomic, weak)   STTableViewCellItem *item11;
@property(nonatomic, weak)   STTableViewSectionItem *section1;

@property(nonatomic, weak)   STTableViewCellItem *item41;
@property(nonatomic, weak)   STTableViewCellItem *itemFacebook;
@property(nonatomic, weak)   STTableViewCellItem *itemOwnPlayer;
@property(nonatomic, weak)   STTableViewCellItem *item50;
@property(nonatomic, weak)   STTableViewCellItem *item51;
@property(nonatomic, weak)   STTableViewCellItem *item52;
@property(nonatomic, weak)   STTableViewCellItem *item53;
@property(nonatomic, weak)   STTableViewCellItem *item54;

@end

@implementation SSDebugViewController

- (NSArray <STTableViewSectionItem *>*)_constructDataSource
{
    NSMutableArray *dataSource = [NSMutableArray arrayWithCapacity:2];
    
    if ([SSDebugViewController supportDebugSubitem:SSDebugSubitemFlex]) {
        
        NSMutableArray *itemArray = [NSMutableArray array];

        STTableViewCellItem *shortVideoDebugItem = [[STTableViewCellItem alloc] initWithTitle:@"小视频调试选项点这里" target:self action:@selector(_openShortVideoDebug)];
        shortVideoDebugItem.switchStyle = NO;
        [itemArray addObject:shortVideoDebugItem];
        
        STTableViewCellItem *adDebugItem = [[STTableViewCellItem alloc] initWithTitle:@"商业化选项点这里" target:self action:@selector(_openAdDebug)];
        shortVideoDebugItem.switchStyle = NO;
        [itemArray addObject:adDebugItem];
        
        STTableViewCellItem *item_00 = [[STTableViewCellItem alloc] initWithTitle:@"内测功能调试选项" target:self action:@selector(_openInHouseDebug)];
        item_00.switchStyle = NO;
        item_00.checked = [ExploreCellHelper getFeedUGCTest];
        self.itemAB = item_00;
        [itemArray addObject:item_00];
        
        STTableViewCellItem *item_001 = [[STTableViewCellItem alloc] initWithTitle:@"Settings调试选项" target:self action:@selector(_openSettingsBrowserVC)];
        [itemArray addObject:item_001];
        
        STTableViewCellItem *item_002 = [[STTableViewCellItem alloc] initWithTitle:@"客户端ABTest试验详情" target:self action:@selector(_openClientABTestVC)];
        
        
        STTableViewCellItem *settingRefreshItem = [[STTableViewCellItem alloc] initWithTitle:@"强制刷新 settings" target:self action:@selector(forceRefreshSettings)];
        [itemArray addObject:settingRefreshItem];
        
        STTableViewCellItem *item_01 = [[STTableViewCellItem alloc] initWithTitle:@"UGC新Feed" target:self action:NULL];
        item_01.switchStyle = YES;
        item_01.switchAction = @selector(_abActionFired:);
        item_01.checked = [ExploreCellHelper getFeedUGCTest];
        self.itemAB = item_01;
        [itemArray addObject:item_01];
        
        STTableViewCellItem *item_11 = [[STTableViewCellItem alloc] initWithTitle:@"下方头像露出" target:self action:NULL];
        item_11.switchStyle = YES;
        item_11.switchAction = @selector(_sourceImgActionFired:);
        item_11.checked = [ExploreCellHelper getSourceImgTest];
        self.itemSourceImg = item_11;
        [itemArray addObject:item_11];
        
        //            STTableViewCellItem *item_12 = [[STTableViewCellItem alloc] initWithTitle:@"详情页AB测" target:self action:NULL];
        //            item_12.switchStyle = YES;
        //            item_12.switchAction = @selector(_detailViewABSettingActionFired:);
        //            item_12.checked = [SSCommonLogic detailViewABEnabled];
        
        STTableViewCellItem *item_13 = [[STTableViewCellItem alloc] initWithTitle:@"淘宝广告升级" target:self action:NULL];
        item_13.switchStyle = YES;
        item_13.switchAction = @selector(_taobaosdkActionFired:);
        item_13.checked = [SSCommonLogic shouldUseALBBService];
        [itemArray addObject:item_13];
        
        STTableViewCellItem *item_14 = [[STTableViewCellItem alloc] initWithTitle:@"贴片广告点击AB测" target:self action:NULL];
        item_14.switchStyle = YES;
        item_14.switchAction = @selector(_posterADActionFired:);
        item_14.checked = [SSCommonLogic isPosterADClickEnabled];
        [itemArray addObject:item_14];
        
        STTableViewCellItem *item_15 = [[STTableViewCellItem alloc] initWithTitle:@"图集上下滑退出" target:self action:NULL];
        item_15.switchStyle = YES;
        item_15.switchAction = @selector(picturesSlideOutActionFired:);
        item_15.checked = [SSCommonLogic appGallerySlideOutSwitchOn];
        [itemArray addObject:item_15];
        
        STTableViewCellItem *item_16 = [[STTableViewCellItem alloc] initWithTitle:@"日志加密" target:self action:NULL];
        item_16.switchStyle = YES;
        item_16.switchAction = @selector(_encryActionFired:);
        item_16.checked = [SSCommonLogic useEncrypt];
        [itemArray addObject:item_16];
        
        STTableViewCellItem *item_17 = [[STTableViewCellItem alloc] initWithTitle:@"appStore评分视图" target:self action:NULL];
        item_17.switchStyle = YES;
        item_17.switchAction = @selector(_appStoreStarFired:);
        item_17.checked =  [[TTAppStoreStarManager sharedInstance] advancedDebug];
        [itemArray addObject:item_17];
        
        STTableViewCellItem *item_18 = [[STTableViewCellItem alloc] initWithTitle:@"统计展示V3开关" target:self action:NULL];
        item_18.switchStyle = YES;
        item_18.switchAction = @selector(_trackV3Fired:);
        item_18.checked =  [[NSUserDefaults standardUserDefaults] boolForKey:@"kTTTrackerOnlyV3SendingEnableKey"];
        
        STTableViewCellItem *item_19 = [[STTableViewCellItem alloc] initWithTitle:@"测试Crash" target:self action:@selector(_crashActionFired)];
        [itemArray addObject:item_19];
        
        STTableViewCellItem *item_22 = [[STTableViewCellItem alloc] initWithTitle:@"使用4G" target:self action:NULL];
        item_22.switchStyle = YES;
        item_22.switchAction = @selector(_switchTo4G:);
        item_22.checked = [SSCommonLogic isNetWorkDebugEnable];
        [itemArray addObject:item_22];
        
        STTableViewCellItem *item_23 = [[STTableViewCellItem alloc] initWithTitle:@"详情页使用SharedWebView" target:self action:NULL];
        item_23.switchStyle = YES;
        item_23.switchAction = @selector(_switchSharedWebView:);
        item_23.checked = [SSCommonLogic detailSharedWebViewEnabled];
        [itemArray addObject:item_23];
        
        STTableViewCellItem *item_24 = [[STTableViewCellItem alloc] initWithTitle:@"下拉刷新交互" target:self action:NULL];
        item_24.switchStyle = YES;
        item_24.switchAction = @selector(_switchToNewPullRefresh:);
        item_24.checked = [SSCommonLogic isNewPullRefreshEnabled];
        [itemArray addObject:item_24];
        
        STTableViewCellItem *item_25 = [[STTableViewCellItem alloc] initWithTitle:@"使用新版转场动画" target:self action:NULL];
        item_25.switchStyle = YES;
        item_25.switchAction = @selector(_switchTransitionAnimation:);
        item_25.checked = [SSCommonLogic transitionAnimationEnable];
        [itemArray addObject:item_25];
        
        STTableViewCellItem *item_27 = [[STTableViewCellItem alloc] initWithTitle:@"开启跳转到火山app" target:self action:NULL];
        item_27.switchStyle = YES;
        item_27.switchAction = @selector(_switchLaunchHuoShanAppEnabled:);
        item_27.checked = [SSCommonLogic isLaunchHuoShanAppEnabled];
        [itemArray addObject:item_27];
        
        STTableViewCellItem *item_30 = [[STTableViewCellItem alloc] initWithTitle:@"图集开启随手拖动动画" target:self action:NULL];
        item_30.switchStyle = YES;
        item_30.switchAction = @selector(_switchImageTransitionAnimation:);
        item_30.checked = [SSCommonLogic imageTransitionAnimationEnable];
        [itemArray addObject:item_30];
        
        STTableViewCellItem *item_31 = [[STTableViewCellItem alloc] initWithTitle:@"视频详情播放上一个" target:self action:NULL];
        item_31.switchStyle = YES;
        item_31.switchAction = @selector(videoDetailPlayLastBtnEnableActionFired:);
        item_31.checked = ttvs_isVideoDetailPlayLastEnabled();
        [itemArray addObject:item_31];
        
        STTableViewCellItem *item_32 = [[STTableViewCellItem alloc] initWithTitle:@"播放上一个按钮样式" target:self action:NULL];
        item_32.switchStyle = YES;
        item_32.switchAction = @selector(videoDetailPlayLastShowTextActionFired:);
        item_32.checked = [SSCommonLogic isVideoDetailPlayLastShowText];
        [itemArray addObject:item_32];
    
        
        STTableViewCellItem *item_35 = [[STTableViewCellItem alloc] initWithTitle:@"重置上传通讯录状态" target:self action:@selector(_resetContactsActionFired)];
        [itemArray addObject:item_35];
    
        
        STTableViewCellItem *item_41 = [[STTableViewCellItem alloc] initWithTitle:@"详情页vConsole" target:self action:@selector(_switchToDetailvConsole)];
        item_41.switchStyle = YES;
        item_41.switchAction = @selector(_switchToDetailvConsole:);
        item_41.checked = [TTDetailWebContainerDebugger isvConsoleEnable];
        [itemArray addObject:item_41];

        STTableViewCellItem *item_42 = [[STTableViewCellItem alloc] initWithTitle:@"JSBridge功能回归测试" target:self action:@selector(jsBridgeTest)];
        [itemArray addObject:item_42];
        
//        STTableViewCellItem *item_43 = [[STTableViewCellItem alloc] initWithTitle:@"开西瓜直播入口" target:self action:@selector(xiguaLiveTest)];
//        [itemArray addObject:item_43];
        
//        STTableViewCellItem *item_44 = [[STTableViewCellItem alloc] initWithTitle:@"百万英雄入口" target:self action:@selector(millionHeroTest)];
//        [itemArray addObject:item_44];
        
        STTableViewSectionItem *section0 = [[STTableViewSectionItem alloc] initWithSectionTitle:@"AB测试" items:itemArray];
        
        [dataSource addObject:section0];
    }
    
    if ([SSDebugViewController supportDebugSubitem:SSDebugSubitemFlex]) {
        STTableViewCellItem *item_00 = [[STTableViewCellItem alloc] initWithTitle:@"FLEX" target:self action:@selector(_openFlexActionFired)];
        STTableViewCellItem *item_01 = [[STTableViewCellItem alloc] initWithTitle:@"假数据" target:self action:@selector(_openNetworkStubActionFired)];
        STTableViewCellItem *item_02 = [[STTableViewCellItem alloc] initWithTitle:@"拨打电话测试页" target:self action:@selector(_openCallNativePhoneWebPage)];
        
        STTableViewCellItem *item_03 = [[STTableViewCellItem alloc] initWithTitle:@"内存泄漏及UIKit主线程检测" target:self action:NULL];
        item_03.switchStyle = YES;
        item_03.switchAction = @selector(_leakFinderAndMainThreadGuardActionFired:);
        item_03.checked = [[NSUserDefaults standardUserDefaults] boolForKey:@"KTTMLeaksFinderEnableAlertKey"] && [[NSUserDefaults standardUserDefaults] boolForKey:@"kTTUIKitMainThreadGuardKey"];
        
        STTableViewCellItem *item_04 = [[STTableViewCellItem alloc] initWithTitle:@"重置观看视频次数(清除UserDefaults数据)" target:self action:@selector(resetUserWatchVideo)];
        
        STTableViewCellItem *item_05 = [[STTableViewCellItem alloc] initWithTitle:@"达人视频测试入口" target:self action:@selector(_openHTSVideoDetail)];
        
        STTableViewCellItem *item_06 = [[STTableViewCellItem alloc] initWithTitle:@"性能检测&JIRA" target:self action:NULL];
        item_06.switchStyle = YES;
        item_06.switchAction = @selector(_appMemoryMonitorActionFired:);
        item_06.checked = [[NSUserDefaults standardUserDefaults] boolForKey:@"kTTAppMemoryMonitorKey"];
        
        STTableViewCellItem *item_07 = [[STTableViewCellItem alloc] initWithTitle:@"截图分享测试" target:self action:@selector(screenshotShare)];
        
//        STTableViewCellItem *item_08 = [[STTableViewCellItem alloc] initWithTitle:@"JIRA 创建问题" target:self action:NULL];
//        item_08.switchStyle = YES;
//        item_08.switchAction = @selector(_appScreenshotJIRACreateIssueFired:);
//        item_08.checked = [[JIRAScreenshotManager sharedJIRAScreenshotManager] screenshotEnabled];
        
        STTableViewSectionItem *section0 = [[STTableViewSectionItem alloc] initWithSectionTitle:@"调试工具" items:@[item_00, item_01, item_02, item_03, item_04, item_05, item_06, item_07]];
        [dataSource addObject:section0];
    }
    
    if ([SSDebugViewController supportDebugSubitem:SSDebugSubitemLogging]) {
        STTableViewCellItem *item00 = [[STTableViewCellItem alloc] initWithTitle:@"连接日志服务器" target:self action:@selector(_connectLogServerActionFired)];
        
        STTableViewCellItem *item01 = [[STTableViewCellItem alloc] initWithTitle:@"显示Umeng日志" target:self action:NULL];
        item01.switchStyle = YES;
        item01.switchAction = @selector(_logUmengActionFired:);
        item01.checked = [DebugUmengIndicator displayUmengISOn];
        self.item01 = item01;
        
        STTableViewCellItem *item02 = [[STTableViewCellItem alloc] initWithTitle:@"把Applog请求数据写入文件" target:self action:NULL];
        item02.switchStyle = YES;
        item02.switchAction = @selector(_setShouldSaveApplog:);
        item02.checked = [self _shouldSaveApplog];
        
        STTableViewSectionItem *section0 = [[STTableViewSectionItem alloc] initWithSectionTitle:@"统计日志" items:@[item00, item01,item02]];
        [dataSource addObject:section0];
    }
    
    if ([SSDebugViewController supportDebugSubitem:SSDebugSubitemFakeLocation]) {
        STTableViewCellItem *item10 = [[STTableViewCellItem alloc] initWithTitle:@"是否手动选择过城市" target:self action:NULL];
        item10.switchStyle = YES;
        item10.checked = [self _shouldAutomaticallyChangeCity];
        item10.switchAction = @selector(_userSelectActionFired:);
        STTableViewCellItem *item11 = [[STTableViewCellItem alloc] initWithTitle:@"模拟用户位置" target:self action:@selector(_fakeUserLocationActionFired)];
        self.item11 = item11;
        STTableViewSectionItem *section1 = [[STTableViewSectionItem alloc] initWithSectionTitle:@"用户位置测试" items:@[item10, item11]];
        [dataSource addObject:section1];
        self.section1 = section1;
        self.item10 = item10;
    }
    if ([SSDebugViewController supportDebugSubitem:SSDebugSubitemIPConfig]) {
        STTableViewCellItem *item30 = [[STTableViewCellItem alloc] initWithTitle:@"Ping测试" target:self action:@selector(_testPingActionFired)];
        STTableViewCellItem *item32 = [[STTableViewCellItem alloc] initWithTitle:@"DNS服务器" target:self action:@selector(_testDNSActionFired)];
        STTableViewSectionItem *section3 = [[STTableViewSectionItem alloc] initWithSectionTitle:@"网络状态测试" items:@[item30, item32]];
        [dataSource addObject:section3];
    }
    if ([SSDebugViewController supportDebugSubitem:SSDebugSubitemUserDefaults]) {
        STTableViewCellItem *item40 = [[STTableViewCellItem alloc] initWithTitle:@"NSUserDefaults" target:self action:@selector(_readUserDefaultsActionFired)];
        STTableViewCellItem *item41 = [[STTableViewCellItem alloc] initWithTitle:@"测试图片专题" target:self action:nil];
        item41.switchStyle = YES;
        item41.switchAction = @selector(_testImageSubjectActionFired:);
        
        STTableViewCellItem *itemfb = [[STTableViewCellItem alloc] initWithTitle:@"测试Facebook浮层" target:self action:nil];
        itemfb.switchStyle = YES;
        itemfb.switchAction = @selector(_testVideoFacebookActionFired:);
        self.itemFacebook = itemfb;
        
        STTableViewSectionItem *section4 = [[STTableViewSectionItem alloc] initWithSectionTitle:@"读取用户设置" items:@[item40, item41 ,itemfb]];
        [dataSource addObject:section4];
        self.item41 = item41;
    }
    
    if ([TTDeviceHelper OSVersionNumber] > 7.0f) {
        STTableViewCellItem *item60 = [[STTableViewCellItem alloc] initWithTitle:@"使用WKWebView" target:self action:NULL];
        item60.switchStyle = YES;
        item60.checked = [self _shouldAllowWKWebView];
        item60.switchAction = @selector(_wkwebviewSettingActionFired:);
        STTableViewSectionItem *section6 = [[STTableViewSectionItem alloc] initWithSectionTitle:@"WKWebView 开关" items:@[item60]];
        
        [dataSource addObject:section6];
        
    }
    
    if (YES) {
        STTableViewCellItem *item71 = [[STTableViewCellItem alloc] initWithTitle:@"使用Https" target:self action:NULL];
        item71.switchStyle = YES;
        item71.checked = [self _shouldAllowHttps];
        item71.switchAction = @selector(_httpsSettingActionFired:);
        STTableViewSectionItem *section7 = [[STTableViewSectionItem alloc] initWithSectionTitle:@"Https 开关" items:@[item71]];
        
        [dataSource addObject:section7];
    }
    
    if(YES) {
        
        STTableViewCellItem *item4 = [[STTableViewCellItem alloc] initWithTitle:@"视频cell显示分享按钮" target:self action:NULL];
        item4.switchStyle = YES;
        item4.checked = [[[TTSettingsManager sharedManager] settingForKey:@"video_cell_show_share" defaultValue:@NO freeze:NO] boolValue];;
        item4.switchAction = @selector(videoCellShowShareButton:);
        
        STTableViewCellItem *item5 = [[STTableViewCellItem alloc] initWithTitle:@"开启新转屏" target:self action:NULL];
        item5.switchStyle = YES;
        item5.checked = ttvs_isVideoNewRotateEnabled();
        item5.switchAction = @selector(videoNewRotate:);
        
        STTableViewCellItem *item7 = [[STTableViewCellItem alloc] initWithTitle:@"视频列表广告cell dislike" target:self action:NULL];
        item7.switchStyle = YES;
        BOOL isVideoAdCellDislikeEnabled = [[[TTSettingsManager sharedManager] settingForKey:@"video_ad_cell_dislike" defaultValue:@NO freeze:NO] boolValue];
        item7.checked = isVideoAdCellDislikeEnabled;
        item7.switchAction = @selector(videoAdCellDislike:);
        
        STTableViewCellItem *item9 = [[STTableViewCellItem alloc] initWithTitle:@"视频自动播放" target:self action:NULL];
        item9.switchStyle = YES;
        item9.checked = [[NSUserDefaults standardUserDefaults] boolForKey:@"video_auto_play_test"];
        item9.switchAction = @selector(videoAutoPlay:);
        
        STTableViewCellItem *item10 = [[STTableViewCellItem alloc] initWithTitle:@"新转屏测试提示" target:self action:NULL];
        item10.switchStyle = YES;
        item10.checked = [SSCommonLogic isRotateTipEnabled];
        item10.switchAction = @selector(videoNewRotateTip:);
        STTableViewCellItem *item11 = [[STTableViewCellItem alloc] initWithTitle:@"点播SDK" target:self action:NULL];
        item11.switchStyle = YES;
        item11.checked = [TTVSettingsConfiguration isNewPlayerEnabled];
        item11.switchAction = @selector(videoNewPlayer:);
        
        STTableViewCellItem *item13 = [[STTableViewCellItem alloc] initWithTitle:@"视频业务重构" target:self action:NULL];
        item13.switchStyle = YES;
        item13.checked = ttvs_isTitanVideoBusiness();
        item13.switchAction = @selector(videoTitanBusiness:);
        
        STTableViewSectionItem *section8 = [[STTableViewSectionItem alloc] initWithSectionTitle:@"视频" items:@[item4, item5, item7,item9,item10,item11 ,item13]];
        [dataSource addObject:section8];
    }
    
    if (YES) {
        STTableViewCellItem *item1 = [[STTableViewCellItem alloc] initWithTitle:@"相关视频样式（0/1/2）" target:self action:nil];
        item1.textFieldStyle = YES;
        item1.textFieldAction = @selector(videoDetailRelatedStyleChange:);
        item1.textFieldContent = [NSString stringWithFormat:@"%ld", [SSCommonLogic videoDetailRelatedStyle]];
        STTableViewSectionItem *relatedVideoSection = [[STTableViewSectionItem alloc] initWithSectionTitle:@"相关视频" items:@[item1]];
        
        [dataSource addObject:relatedVideoSection];
    }
    
    if (YES) {
        STTableViewCellItem *item1 = [[STTableViewCellItem alloc] initWithTitle:@"接口请求开始时间(毫秒)" target:self action:nil];
        item1.textFieldStyle = YES;
        item1.textFieldAction = @selector(videoMidInsertADReqStartTimeChange:);
        item1.textFieldContent = [NSString stringWithFormat:@"%ld", ttvs_getVideoMidInsertADReqStartTime()];
        
        STTableViewCellItem *item2 = [[STTableViewCellItem alloc] initWithTitle:@"接口请求开始结束(毫秒)" target:self action:nil];
        item2.textFieldStyle = YES;
        item2.textFieldAction = @selector(videoMidInsertADReqEndTimeChange:);
        item2.textFieldContent = [NSString stringWithFormat:@"%ld", ttvs_getVideoMidInsertADReqEndTime()];
        
        STTableViewCellItem *item3 = [[STTableViewCellItem alloc] initWithTitle:@"接口请求开关" target:self action:nil];
        item3.switchStyle = YES;
        item3.checked = [SSCommonLogic isRefactorGetDomainsEnabled];
        item3.switchAction = @selector(videoMidInsertADReqActionFired:);
        
        STTableViewSectionItem *relatedVideoSection = [[STTableViewSectionItem alloc] initWithSectionTitle:@"中插广告" items:@[item1, item2, item3]];
        
        [dataSource addObject:relatedVideoSection];
    }
    
    
    if (YES) {
        STTableViewCellItem *item = [[STTableViewCellItem alloc] initWithTitle:@"支持水印" target:self action:NULL];
        item.switchStyle = YES;
        item.checked = [[NSUserDefaults standardUserDefaults] boolForKey:@"_TTWaterMasterEnabled_"];
        item.switchAction = @selector(_waterMasterActionFired:);
        STTableViewSectionItem *section9 = [[STTableViewSectionItem alloc] initWithSectionTitle:@"视频Cell水印开关" items:@[item]];
        [dataSource addObject:section9];
    }
    
    if (YES) {
        STTableViewCellItem *item1 = [[STTableViewCellItem alloc] initWithTitle:@"私信长短链接切换策略（0/1/2）" target:self action:nil];
        item1.textFieldStyle = YES;
        item1.textFieldAction = @selector(_imCommunicateStrategy:);
        item1.textFieldContent = [NSString stringWithFormat:@"%ld", [SSCommonLogic imCommunicateStrategy]];
        STTableViewSectionItem *section10 = [[STTableViewSectionItem alloc] initWithSectionTitle:@"私信" items:@[item1]];
        
        [dataSource addObject:section10];
    }
    
    if (YES) {
        STTableViewCellItem *item = [[STTableViewCellItem alloc] initWithTitle:@"设置为新用户" target:self action:@selector(_newUserSettingActionFired)];
        STTableViewSectionItem *section11 = [[STTableViewSectionItem alloc] initWithSectionTitle:@"新用户" items:@[item]];
        
        [dataSource addObject:section11];
    }
    
    if(YES){
        NSString *title;
        NSString *value;
        NSInteger count = 5;
        NSMutableArray *array = [NSMutableArray arrayWithCapacity:count];
        for (NSInteger i = 1 ; i <= count ; i++){
            title = [SSCommonLogic commonParameterNameWithIndex:i];
            value = [SSCommonLogic commonParameterValueWithIndex:i];
            STTableViewCellItem *item = [[STTableViewCellItem alloc] initWithTitle:title target:self action:nil];
            item.textFieldStyle = YES;
            item.tag = i;
            item.textFieldAction = @selector(commonParameterHandle:);
            item.textFieldContent = value;
            [array addObject:item];
        }
        STTableViewSectionItem *section13 = [[STTableViewSectionItem alloc] initWithSectionTitle:@"通用参数配置" items:array];
        [dataSource addObject:section13];
    }
    
    if (YES) {
        STTableViewCellItem *item1 = [[STTableViewCellItem alloc] initWithTitle:@"贴片广告重播按钮开关" target:self action:NULL];
        item1.switchStyle = YES;
        item1.checked = [SSCommonLogic isVideoADReplayBtnEnabled];
        item1.switchAction = @selector(VideoADReplayBtnEnabledActionFired:);
        STTableViewSectionItem *sectionVideoAD = [[STTableViewSectionItem alloc] initWithSectionTitle:@"QA_video_AD" items:@[item1]];
        
        [dataSource addObject:sectionVideoAD];
    }
    if (YES) {
        STTableViewCellItem *item1 = [[STTableViewCellItem alloc] initWithTitle:@"跳转到详情gid" target:self action:nil];
        item1.textFieldStyle = YES;
        item1.textFieldAction = @selector(_goToDetail:);
        item1.textFieldContent = @"";
        
        STTableViewSectionItem *section13 = [[STTableViewSectionItem alloc] initWithSectionTitle:@"文章相关：" items:@[item1]];
        [dataSource addObject:section13];
    }
    if (YES) {
        
        STTableViewCellItem *item0 = [[STTableViewCellItem alloc] initWithTitle:@"联机调试开关" target:self action:nil];
        item0.switchStyle = YES;
        item0.switchAction = @selector(toggleRNDevEnable:);
        item0.checked = [TTRNBundleManager sharedManager].devEnable;
        
        STTableViewCellItem *item1 = [[STTableViewCellItem alloc] initWithTitle:@"调试host" target:self action:nil];
        item1.textFieldStyle = YES;
        item1.textFieldAction = @selector(setRNDevHost:);
        item1.textFieldContent = [TTRNBundleManager sharedManager].devHost;
        
        STTableViewCellItem *item2 = [[STTableViewCellItem alloc] initWithTitle:@"跳转Bundle(ReactDemo)" target:self action:@selector(goToRNPage)];
        
        STTableViewSectionItem *section14 = [[STTableViewSectionItem alloc] initWithSectionTitle:@"ReactNative相关：" items:@[item0, item1, item2]];
        
        [dataSource addObject:section14];
    }
    
    
    //    if (YES) {
    //        STTableViewCellItem *item1 = [[STTableViewCellItem alloc] initWithTitle:@"是否开启iCloud相册" target:self action:NULL];
    //        item1.switchStyle = YES;
    //        item1.checked = [SSCommonLogic isIcloudEabled];
    //        item1.switchAction = @selector(iCloudEableAction:);
    //        STTableViewSectionItem *sectionVideoAD = [[STTableViewSectionItem alloc] initWithSectionTitle:@"iCloud" items:@[item1]];
    //
    //        [dataSource addObject:sectionVideoAD];
    //    }
    
    return dataSource;
}

-(void)makeACrash {
    NSArray * array = [NSArray array];
    NSLog(@"array=%@", array[3]);
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.title = @"高级调试";
    self.statusBarStyle = SSViewControllerStatsBarDayWhiteNightBlackStyle;
    
    self.dataSource = [self _constructDataSource];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"关闭" style:UIBarButtonItemStylePlain target:self action:@selector(_cancelActionFired:)];
    [self _reloadRightBarItem];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self reloadData];
}

- (void)reloadData {
    self.itemAB.checked = [ExploreCellHelper getFeedUGCTest];
    self.itemSourceImg.checked = [ExploreCellHelper getSourceImgTest];
    self.item01.checked = [DebugUmengIndicator displayUmengISOn];
    self.item10.checked = [self _shouldAutomaticallyChangeCity];
    TTPlacemarkItem *item = [TTLocationManager sharedManager].placemarks.firstObject;
    if (isEmptyString(item.city) && [TTLocationManager sharedManager].placemarks.count > 1) {
        item = [TTLocationManager sharedManager].placemarks[1];
    }
    if (!isEmptyString(item.city)) {
        self.section1.footerTitle = [NSString stringWithFormat:@"%@", item.address];
        self.item11.detail = item.city;
    } else {
        self.section1.footerTitle = nil;
        self.item11.detail = nil;
    }
    self.item41.checked = [[self class] supportTestImageSubject];
    self.itemFacebook.checked = [[self class] supportTestVideoFacebook];
    self.itemOwnPlayer.checked = [[self class] supportTestVideoOwnPlayer];
    [self.tableView reloadData];
}

- (void)_switchToScrollDirectionVertical:(UISwitch *)uiswitch
{
    if (uiswitch.isOn) {
        [SSCommonLogic setShortVideoScrollDirection:@(2)];
    } else {
        [SSCommonLogic setShortVideoScrollDirection:@(1)];
    }
}

- (void)_reloadRightBarItem {
    if ([TTLogServer logEnable]) {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"设备信息" style:UIBarButtonItemStylePlain target:self action:@selector(_sendDeviceActionFired:)];
    }
}

- (void)_sendDeviceActionFired:(id)sender {
    NSString *deviceToken = [[NSUserDefaults standardUserDefaults] valueForKey:@"ArticleDeviceToken"];
    NSString *userId = [TTAccountManager userID];
    NSString *deviceId = [[TTInstallIDManager sharedInstance] deviceID];
    NSMutableDictionary *logs = [NSMutableDictionary dictionaryWithCapacity:2];
    [logs setValue:deviceToken forKey:@"deviceToken"];
    [logs setValue:userId forKey:@"userId"];
    [logs setValue:deviceId forKey:@"deviceId"];
    
    [TTLogServer sendValueToLogServer:logs parameters:@{@"font":@(16)}];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)_openInHouseDebug
{
    SSInHouseDebugViewController *inHouseDebugVC = [[SSInHouseDebugViewController alloc] init];
    [self.navigationController pushViewController:inHouseDebugVC animated:YES];
}

- (void)_openSettingsBrowserVC
{
    [TTSettingsBrowserViewController showBrowserViewControllerInViewController:self];
}

- (void)_openClientABTestVC
{
    TTClientABTestBrowserViewController *clientABVC = [TTClientABTestBrowserViewController new];
    [self.navigationController pushViewController:clientABVC animated:YES];
}

- (void)_openShortVideoDebug
{
    [self.navigationController pushViewController:[[TSVDebugViewController alloc] init]
                                         animated:YES];
}

- (void)_openAdDebug
{
    [self.navigationController pushViewController:[[TADDebugViewController alloc] init]
                                         animated:YES];
}

- (void)_abActionFired:(UISwitch *)uiswitch {
    [ExploreCellHelper setFeedUGCTest:uiswitch.on];
}

- (void)_sourceImgActionFired:(UISwitch *)uiswitch {
    [ExploreCellHelper setSourceImgTest:uiswitch.on];
}

- (void)_userSelectActionFired:(UISwitch *)uiswitch {
    if (!uiswitch.on && [self _shouldAutomaticallyChangeCity]) {
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithCapacity:2];
        [parameters setValue:[TTAccountManager userID] forKey:@"user_id"];
        [parameters setValue:[[TTInstallIDManager sharedInstance] deviceID] forKey:@"device_id"];
        [[TTNetworkManager shareInstance] requestForJSONWithURL:@"http://ic.snssdk.com/location/rmlbsmhxzkhlinfo/" params:parameters method:@"GET" needCommonParams:NO callback:^(NSError *error, id jsonObj) {
            if (!error) {
                [self _setShouldAutomaticallyChangeCity:uiswitch.on];
            }
        }];
    } else {
        [self _setShouldAutomaticallyChangeCity:uiswitch.on];
    }
    
}

- (void)_setShouldSaveApplog:(UISwitch *)uiswitch {
    [[NSUserDefaults standardUserDefaults] setBool:uiswitch.isOn forKey:@"kShouldSaveApplogKey"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (BOOL)_shouldSaveApplog {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"kShouldSaveApplogKey"];
}

- (void)_logUmengActionFired:(UISwitch *)uiswitch {
    [DebugUmengIndicator setDisplayUmengIsOn:uiswitch.isOn];
    if(uiswitch.isOn) {
        [[DebugUmengIndicator sharedIndicator] startDisplay];
    } else {
        [[DebugUmengIndicator sharedIndicator] stopDisplay];
    }
    [self reloadData];
}

- (void)_openMessageNotificationActionFired:(UITextField *)textField
{
    NSString *testHost = textField.text;
    [[NSUserDefaults standardUserDefaults] setObject:testHost forKey:@"message_notification_test_host"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)_openFlexActionFired
{
    #if INHOUSE
    [[FLEXManager sharedManager] showExplorer];
    #endif
}

-(void)_switchTo4G:(UISwitch *)uiswitch{
    [SSCommonLogic setIsNetWorkDebugEnable:uiswitch.isOn];
}

- (void)_switchToNewPullRefresh:(UISwitch *)uiswitch {
    [SSCommonLogic setNewPullRefreshEnabled:uiswitch.isOn];
}

- (void)_switchSharedWebView:(UISwitch *)uiswitch {
    [SSCommonLogic setDetailSharedWebViewEnabled:uiswitch.isOn];
}

- (void)_switchTransitionAnimation:(UISwitch *)uiswitch {
    [[TTSettingsManager sharedManager] updateSetting:@(uiswitch.isOn) forKey:@"transition_animation_enabled"];
}

- (void)_switchLaunchHuoShanAppEnabled:(UISwitch *)uiswitch {
    [SSCommonLogic setLaunchHuoShanAppEnabled:uiswitch.isOn];
}

- (void)_switchImageTransitionAnimation:(UISwitch *)uiswitch {
    [SSCommonLogic setImageTransitionAnimationEnable:uiswitch.isOn];
}

- (void)_resetContactsActionFired {
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"kTTContactsCheckResultKey"];
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"TTContactsGuideTimestampKey"];
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"kTTContactsCheckTimestampKey"];
    [[NSUserDefaults standardUserDefaults] setObject:@NO forKey:@"TTHasUploadedContactsFlagKey"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)_openNetworkStubActionFired
{
    Class class = NSClassFromString(@"TTNetworkStubSwitchViewController");
    if (class) {
        UIViewController *viewController = [[class alloc] init];
        viewController.title = @"请求本地数据";
        [self.navigationController pushViewController:viewController animated:YES];
    }
}

- (void)_openCallNativePhoneWebPage
{
    NSDictionary *params = @{@"url":@"http://ad.toutiao.com/tetris/page/6927396748/"};
    NSURL *url = [TTURLUtils URLWithString:@"sslocal://webview" queryItems:params];
    if ([[TTRoute sharedRoute] canOpenURL:url]) {
        [[TTRoute sharedRoute] openURLByPushViewController:url];
    }
    return;
}

- (void)_openHTSVideoDetail
{
    [[TTRoute sharedRoute] openURLByPushViewController:[NSURL URLWithString:@"sslocal://huoshanvideo?video_id=6354295170023820546"]];
}

- (void)_connectLogServerActionFired {
#if TARGET_OS_SIMULATOR
    NSString *result = @"http://127.0.0.1:10304/bytedance/log";
    
    NSString *currentUrl = [[NSUserDefaults standardUserDefaults] valueForKey:@"TTTrackRemoteServerCacheKey"];
    NSString *title;
    if (isEmptyString(currentUrl)) {
        title = @"已连接到本地统计服务器";
        [[TTTracker sharedInstance] setDebugLogServerAddress:result];
    } else {
        title = @"已断开本地统计服务器链接";
        [TTLogServer clearLogServer];
        [TTLogServer stopLogger];
    }
    
    TTThemedAlertController *alert = [[TTThemedAlertController alloc] initWithTitle:title message:nil preferredType:TTThemedAlertControllerTypeAlert];
    [alert addActionWithTitle:NSLocalizedString(@"确定", nil) actionType:TTThemedAlertActionTypeCancel actionBlock:nil];
    [alert showFrom:self animated:YES];
    return;
#endif
    
    SSQRCodeScanViewController *viewController = SSQRCodeScanViewController.new;
    viewController.continueWhenScaned = YES;
    if (viewController) {
        viewController.scanCompletionHandler = ^(SSQRCodeScanViewController *vc, NSString *result, NSError *error) {
            NSURL *requestURL = [TTStringHelper URLWithURLString:result];
            if (requestURL.port.intValue > 10000) {
                // 打印Log的服务器               // ip:port/bytedance/log/track  ip:port/bytedance/close/
                if (requestURL.path.length > 0 && [requestURL.path rangeOfString:@"bytedance"].location != NSNotFound) {
                    NSString *title = nil;
                    if ([requestURL.path rangeOfString:@"close"].location != NSNotFound) {
                        // 断开连接
                        requestURL = nil;
                        title = @"已断开测试统计服务器链接";
                    } else {
                        title = @"已连接到测试统计服务器";
                    }
                    TTThemedAlertController *alert = [[TTThemedAlertController alloc] initWithTitle:title message:nil preferredType:TTThemedAlertControllerTypeAlert];
                    [alert addActionWithTitle:NSLocalizedString(@"确定", nil) actionType:TTThemedAlertActionTypeCancel actionBlock:nil];
                    [alert showFrom:self animated:YES];
                    
                    if (requestURL) {
                        [[TTTracker sharedInstance] setDebugLogServerAddress:result];
                        
                    } else {
                        [TTLogServer clearLogServer];
                    }
                    [vc dismissAnimated:YES];
                    [self _reloadRightBarItem];
                }
            } else {
                if (requestURL) {
                    [vc dismissAnimated:YES];
                    // 增加扫描到网页直接打开的功能
                    NSString *URLString = requestURL.absoluteString;
                    TTThemedAlertController *alert = [[TTThemedAlertController alloc] initWithTitle:@"使用WebView打开链接？" message:URLString preferredType:TTThemedAlertControllerTypeAlert];
                    [alert addActionWithTitle:NSLocalizedString(@"取消", nil) actionType:TTThemedAlertActionTypeCancel actionBlock:nil];
                    [alert addActionWithTitle:NSLocalizedString(@"确定", nil) actionType:TTThemedAlertActionTypeNormal actionBlock:^{
                        SSWebViewController *webViewController = [[SSWebViewController alloc] initWithSupportIPhoneRotate:NO];
                        webViewController.adID = @"97676901";
                        [webViewController requestWithURL:requestURL];
                        if (self.navigationController) {
                            [self.navigationController pushViewController:webViewController animated:YES];
                        } else {
                            UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:webViewController];
                            navigationController.navigationBarHidden = YES;
                            [self presentViewController:navigationController animated:YES completion:NULL];
                        }
                    }];
                    [alert showFrom:self animated:YES];
                    
                }
            }
            
        };
        [self presentViewController:viewController animated:YES completion:NULL];
    }
}

- (void)_fakeUserLocationActionFired {
    SSLocationPickerController *pickerController = [[SSLocationPickerController alloc] init];
    [self.navigationController pushViewController:pickerController animated:YES];
    UIWindow *window = self.view.window;
    pickerController.completionHandler = ^(SSLocationPickerController *pickerViewController){
        // reverse 城市
        if ([SSLocationPickerController cachedFakeLocationCoordinate].longitude * [SSLocationPickerController cachedFakeLocationCoordinate].latitude > 0) {
            TTIndicatorView *indicator = [[TTIndicatorView alloc] initWithIndicatorStyle:TTIndicatorViewStyleWaitingView indicatorText:nil indicatorImage:nil dismissHandler:nil];
            indicator.showDismissButton = NO;
            indicator.autoDismiss = NO;
            [indicator showFromParentView:window];
            [[TTLocationManager sharedManager] regeocodeWithCompletionHandler:^(NSArray *placemarks) {
                [self.tableView reloadData];
                [indicator dismissFromParentView];
                [pickerViewController.navigationController popViewControllerAnimated:YES];
            }];
        } else {
            [pickerViewController.navigationController popViewControllerAnimated:YES];
        }
    };
}

- (void)_testPingActionFired {
    SSDebugPingViewController *pingViewController = [[SSDebugPingViewController alloc] init];
    [self.navigationController pushViewController:pingViewController animated:YES];
}

- (void)_testTracerouteActionFired {
}

- (void)_testDNSActionFired {
    SSDebugDNSViewController *viewController = [[SSDebugDNSViewController alloc] init];
    [self.navigationController pushViewController:viewController animated:YES];
}

- (void)_readUserDefaultsActionFired {
    SSDebugUserDefaultsViewController *userDefaults = [[SSDebugUserDefaultsViewController alloc] init];
    [self.navigationController pushViewController:userDefaults animated:YES];
}

- (void)_testImageSubjectActionFired:(UISwitch *)uiswitch {
    [[NSUserDefaults standardUserDefaults] setValue:@(uiswitch.isOn) forKey:@"TTTestImageSubject"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self reloadData];
    
}

- (void)_testVideoFacebookActionFired:(UISwitch *)uiswitch {
    [[NSUserDefaults standardUserDefaults] setValue:@(uiswitch.isOn) forKey:@"TTTestVideoFacebook"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self reloadData];
}

- (void)_setShouldAutomaticallyChangeCity:(BOOL)shouldChange {
    [[NSUserDefaults standardUserDefaults] setBool:shouldChange forKey:@"kArticleCategoryManagerUserSelectedLocalCityKey"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (BOOL)_shouldAutomaticallyChangeCity {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"kArticleCategoryManagerUserSelectedLocalCityKey"];
}

- (BOOL)_shouldAllowWKWebView
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"kWKWebViewSettingSwitchKey"];
}

- (BOOL)_shouldAllowHttps
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"kHttpsSettingSwitchKey"];
}

- (NSInteger)_fontSizeForCellTitle
{
    return [[NSUserDefaults standardUserDefaults] integerForKey:@"cellTitleFontSize"];
}

- (NSInteger)_fontSizeForCellSubtitle
{
    return [[NSUserDefaults standardUserDefaults] integerForKey:@"cellSubtitleFontSize"];
}

#pragma mark - WKWebView switch setting

- (void)_wkwebviewSettingActionFired:(UISwitch *)uiswitch {
    if (uiswitch.isOn) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"kWKWebViewSettingSwitchKey"];
    }
    else{
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"kWKWebViewSettingSwitchKey"];
    }
}

//#pragma mark - 详情页AB测 switch setting
//
//- (void)_detailViewABSettingActionFired:(UISwitch *)uiswitch {
//    [SSCommonLogic setDetailViewABEnabled:uiswitch.isOn];
//}

- (void)_taobaosdkActionFired:(UISwitch *)uiswitch{
    [SSCommonLogic setShouldUseALBBService:uiswitch.isOn];
}

- (void)_encryActionFired:(UISwitch *)uiswitch{
    [SSCommonLogic setUseEncrypt:uiswitch.isOn];
}

- (void)_appStoreStarFired:(UISwitch *)uiswitch
{
    [[TTAppStoreStarManager sharedInstance] setAdvancedDebug:uiswitch.isOn];
}

- (void)_trackV3Fired:(UISwitch *)uiswitch
{
    [TTTrackerWrapper setV3DoubleSendingEnable:uiswitch.isOn];
}

- (void)_posterADActionFired:(UISwitch *)uiswitch
{
    [SSCommonLogic setPosterADClickEnabled:uiswitch.isOn];
}

- (void)picturesSlideOutActionFired:(UISwitch *)uiswitch
{
    [SSCommonLogic setGallerySlideOutSwitch:@(uiswitch.isOn)];
}

-(void)_crashActionFired{
    NSArray * array = [NSArray array];
    NSLog(@"array=%@", array[3]);
}

- (void)jsBridgeTest
{
    [[TTRoute sharedRoute] openURLByPushViewController:[NSURL URLWithString:@"sslocal://webview?url=http%3A%2F%2Fci.byted.org%2Fbuild%2FTTJSBridgeTest.html"]];
}

//- (void)xiguaLiveTest
//{
//    NSMutableDictionary *extraDic = [NSMutableDictionary dictionary];
//    [extraDic setValue:@"publisher_enter" forKey:@"category_name"];
//    [extraDic setValue:@"click_other" forKey:@"enter_from"];
//    UIViewController *broadcastVC = [[TTXiguaLiveManager sharedManager] boadCastRoomWithExtraInfo:extraDic];
//    [self.navigationController presentViewController:broadcastVC animated:YES completion:nil];
//}

//- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
//    if (1 == buttonIndex) {
//        int64_t activityID = [alertView textFieldAtIndex:0].text.longLongValue;
//        [TTFantasy enterFantasyFromViewController:self.navigationController
//                                       activityID:activityID];
//    }
//}

//- (void)millionHeroTest{
//    [TTFantasy ttf_configureTestEnv:YES];
//    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Fantasy"
//                                                        message:@"请输入房间号"
//                                                           delegate:self
//                                                  cancelButtonTitle:@"取消"
//                                                  otherButtonTitles:@"确认", nil];
//    alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
//    [alertView show];
//}

-(void)_fireSpalshAd {
    id<TTAdManagerProtocol> adManagerInstance = [[TTServiceCenter sharedInstance] getServiceByProtocol:@protocol(TTAdManagerProtocol)];
    
    [[adManagerInstance class] performSelector:@selector(clearSSADRecentlyEnterBackgroundTime)];
    [[adManagerInstance class] performSelector:@selector(clearSSADRecentlyShowSplashTime)];
    [adManagerInstance applicationDidBecomeActiveShowOnWindow:[UIApplication sharedApplication].keyWindow splashShowType:SSSplashADShowTypeShow];
}

- (NSDictionary *)changeEnableWirhDict:(NSDictionary *)dict key:(NSString *)key
{
    NSDictionary *originalDict = [dict tt_dictionaryValueForKey:key];
    NSMutableDictionary *mutDict = [NSMutableDictionary dictionary];
    [mutDict addEntriesFromDictionary:originalDict];
    [mutDict setValue:@(![mutDict tt_boolValueForKey:@"enable"]) forKey:@"enable"];
    return [mutDict copy];
    
}

#pragma mark - 内存泄漏及UIKit多线程检测
- (void)_leakFinderAndMainThreadGuardActionFired:(UISwitch *)uiswitch {
    [[NSUserDefaults standardUserDefaults] setBool:uiswitch.isOn forKey:@"KTTMLeaksFinderEnableAlertKey"];
    [[NSUserDefaults standardUserDefaults] setBool:uiswitch.isOn forKey:@"kTTUIKitMainThreadGuardKey"];
}

#pragma mark - 应用内存使用量监测
- (void)_appMemoryMonitorActionFired:(UISwitch *)uiswitch {
    [[NSUserDefaults standardUserDefaults] setBool:uiswitch.on forKey:@"kTTAppMemoryMonitorKey"];
    
    if (uiswitch.isOn) {
#if INHOUSE
        [TTDebugAssistant show];
#endif
        //  [TTMemoryMonitor showMemoryMonitor];
        
    }
    else {
#if INHOUSE
        [TTDebugAssistant hide];
#endif
        //  [TTMemoryMonitor hideMemoryMonitor];
    }
}

#pragma mark - JIRA 创建问题
- (void)_appScreenshotJIRACreateIssueFired:(UISwitch *)uiswitch {
//#if INHOUSE
//    [[JIRAScreenshotManager sharedJIRAScreenshotManager] setScreenshotEnabled:uiswitch.isOn];
//#endif
}

#pragma mark - 截图分享
- (void)screenshotShare{
    [[NSNotificationCenter defaultCenter]postNotificationName:UIApplicationUserDidTakeScreenshotNotification object:nil];
}

#pragma mark - Https switch setting

- (void)_httpsSettingActionFired:(UISwitch *)uiswitch {
    if (uiswitch.isOn) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"kHttpsSettingSwitchKey"];
    }
    else{
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"kHttpsSettingSwitchKey"];
    }
}

#pragma mark - 视频多清晰度setting
- (void)_multiResolutionActionFired:(UISwitch *)uiswitch
{
    [[TTSettingsManager sharedManager] updateSetting:@(uiswitch.isOn) forKey:@"video_multi_resolution_enabled"];
}

- (void)videoNewRotateTip:(UISwitch *)uiswich
{
    if (uiswich.on) {
        [SSCommonLogic setVideoNewRotateTipEnabled:YES];
    } else {
        [SSCommonLogic setVideoNewRotateTipEnabled:NO];
    }
}

- (void)videoTitanBusiness:(UISwitch *)uiswich
{
    if (uiswich.on) {
        [TTVSettingsConfiguration setManualSwitchTitanVideoBusiness:YES];
    } else {
        [TTVSettingsConfiguration setManualSwitchTitanVideoBusiness:NO];
    }
}

- (void)videoNewPlayer:(UISwitch *)uiswich
{
    if (uiswich.on) {
        [TTVSettingsConfiguration setNewPlayerEnabled:YES];
    } else {
        [TTVSettingsConfiguration setNewPlayerEnabled:NO];
    }
}

- (void)videoNewRotate:(UISwitch *)uiswich
{
    ttvs_setIsVideoNewRotateEnabled(uiswich.on);
}

- (void)videoAdCellDislike:(UISwitch *)uiswitch
{
    [[TTSettingsManager sharedManager] updateSetting:@(uiswitch.isOn) forKey:@"video_ad_cell_dislike"];
}

- (void)videoAutoPlay:(UISwitch *)uiswitch
{
    return [[NSUserDefaults standardUserDefaults] setBool:uiswitch.on forKey:@"video_auto_play_test"];
}

- (void)videoCellShowShareButton:(UISwitch *)uiswitch
{
    [[TTSettingsManager sharedManager] updateSetting:@(uiswitch.isOn) forKey:@"video_cell_show_share"];
}

- (void)VideoADReplayBtnEnabledActionFired:(UISwitch *)uiswitch
{
    if (uiswitch.isOn) {
        [SSCommonLogic setVideoADReplayBtnEnabled:YES];
    }
    else {
        [SSCommonLogic setVideoADReplayBtnEnabled:NO];
    }
}
- (void)iCloudEableAction:(UISwitch *)uiswitch
{
    [SSCommonLogic setIcloudBtnEnabled:uiswitch.isOn];
}

- (void)videoDetailPlayLastBtnEnableActionFired:(UISwitch *)uiswitch {
    [[TTSettingsManager sharedManager] updateSetting:@(uiswitch.isOn) forKey:@"tt_video_detail_playlast_enable"];
}

- (void)videoDetailPlayLastShowTextActionFired:(UISwitch *)uiswitch {
    
    if (uiswitch.isOn) {
        [SSCommonLogic setVideoDetailPlayLastShowText:YES];
    }
    else {
        [SSCommonLogic setVideoDetailPlayLastShowText:NO];
    }
}

- (void)videoDetailRelatedStyleChange:(UITextField *)field{
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    NSNumber *result = [formatter numberFromString:field.text];
    if (result) {
        [SSCommonLogic setVideoDetailRelatedStyle:[result integerValue]];
    }
}

- (void)videoMidInsertADReqStartTimeChange:(UITextField *)field {
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    NSNumber *result = [formatter numberFromString:field.text];
    if (result) {
        NSMutableDictionary *videoMidInsertADMutableDict = [ttvs_videoMidInsertADDict() mutableCopy];
        [videoMidInsertADMutableDict setObject:result forKey:@"tt_video_midpatch_req_start"];
        [[TTSettingsManager sharedManager] updateSetting:[videoMidInsertADMutableDict copy] forKey:@"tt_video_midpatch_settings"];
    }
}

- (void)videoMidInsertADReqEndTimeChange:(UITextField *)field {
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    NSNumber *result = [formatter numberFromString:field.text];
    if (result) {
        NSMutableDictionary *videoMidInsertADMutableDict = [ttvs_videoMidInsertADDict() mutableCopy];
        [videoMidInsertADMutableDict setObject:result forKey:@"tt_video_midpatch_req_end"];
        [[TTSettingsManager sharedManager] updateSetting:[videoMidInsertADMutableDict copy] forKey:@"tt_video_midpatch_settings"];
    }
}

- (void)videoMidInsertADReqActionFired:(UISwitch *)uiswitch {
    NSMutableDictionary *videoMidInsertADMutableDict = [ttvs_videoMidInsertADDict() mutableCopy];
    [videoMidInsertADMutableDict setObject:@(uiswitch.isOn) forKey:@"tt_video_midpatch_req_not_ad"];
    [[TTSettingsManager sharedManager] updateSetting:[videoMidInsertADMutableDict copy] forKey:@"tt_video_midpatch_settings"];
}

- (void)forceRefreshSettings
{
    [[SSFetchSettingsManager shareInstance] startFetchDefaultSettingsWithDefaultInfo:NO forceRefresh:YES];
    [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage
                              indicatorText:@"已刷新 settings"
                             indicatorImage:nil
                                autoDismiss:YES
                             dismissHandler:nil];
}

//qaswitchmanage
#pragma mark - 使用水印开关
- (void)_waterMasterActionFired:(UISwitch *)uiswtich
{
    if (uiswtich.isOn) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"_TTWaterMasterEnabled_"];
    } else {
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"_TTWaterMasterEnabled_"];
    }
}

#pragma mark - 私信相关
- (void)_imCommunicateStrategy:(UITextField *)field{
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    NSNumber *result = [formatter numberFromString:field.text];
    if (result) {
        [SSCommonLogic setimCommunicateStrategy:[result integerValue]];
    }
    NSLog(@"set imCommunicateStrategy:%@",field.text);
}

- (void)commonParameterHandle:(UITextField *)field
{
    NSString *content = field.text;
    if (isEmptyString(content)){
        return;
    }
    [SSCommonLogic setCommonParameterWithValue:content index:field.tag];
}

#pragma mark - 文章相关
- (void)_goToDetail:(UITextField *)field
{
    if (isEmptyString(field.text)) {
        return;
    }
    NSString *url = [@"sslocal://detail?group_id=" stringByAppendingString:field.text];
    
    [self dismissViewControllerAnimated:NO completion:^{
        [[TTRoute sharedRoute] openURLByPushViewController:[NSURL URLWithString:url]];
    }];
}

- (void)_switchToDetailvConsole:(UISwitch *)switcher {
    [TTDetailWebContainerDebugger vConsoleEnable:switcher.on];
}

#pragma mark - 模拟新用户开关
- (void)_newUserSettingActionFired{
    [ExploreLogicSetting setIsUpgradeUser:NO];
    //目前模拟新用户的方式只针对新用户刷新引导的需求有效
    [self clearUserCachedData];
}

- (void)clearUserCachedData{
    [[NSUserDefaults standardUserDefaults] setDouble:0 forKey:@"kVideoTipLastShowDateKey"];
    [TTVideoTip setHasShownVideoTip:NO];
    [TTVideoTip setCanShowVideoTip:NO];
}

#pragma mark - 重置观看视频次数
- (void)resetUserWatchVideo {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:NO forKey:kVideoTipCanShowKey];
    [defaults setDouble:0 forKey:kVideoTipLastShowDateKey];
    [defaults setBool:NO forKey:@"kVideoTipHasShownKey"];
    [defaults synchronize];
}

#pragma mark - React Native调试
- (void)toggleRNDevEnable:(UISwitch *)sw {
    [TTRNBundleManager sharedManager].devEnable = sw.on;
}

- (void)setRNDevHost:(UITextField *)textField {
    [TTRNBundleManager sharedManager].devHost = textField.text;
}

- (void)goToRNPage {
    NSString *url = [@"sslocal://react?moduleName=" stringByAppendingString:@"ReactDemo"];
    [[TTRoute sharedRoute] openURLByPushViewController:[NSURL URLWithString:url]];
}

- (void)_cancelActionFired:(id)sender {
    [self.navigationController dismissViewControllerAnimated:YES completion:NULL];
}

+ (BOOL)supportTestImageSubject {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"TTTestImageSubject"];
}

+ (BOOL)supportTestVideoFacebook {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"TTTestVideoFacebook"];
}

+ (BOOL)supportTestVideoOwnPlayer {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"video_own_player"];
}

+ (BOOL)supportWKWebView {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"kWKWebViewSettingSwitchKey"];
}

+ (BOOL)supportHttps {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"kHttpsSettingSwitchKey"];
}

static SSDebugItems _supportedItems = SSDebugItemController;
+ (BOOL)supportDebugItem:(SSDebugItems)debugItem {
#if INHOUSE
    NSString *channel = [TTSandBoxHelper getCurrentChannel];
    if ([channel isEqualToString:@"local_test"] || [channel isEqualToString:@"dev"]) {
        return _supportedItems & debugItem;
    }
    
#warning TODO 上线前删除
    if ([channel isEqualToString:@"App Store"]) {
        return _supportedItems & debugItem;
    }
#endif
    return NO;
}

static SSDebugSubitems _suppertedSubitems = SSDebugSubitemAll;
+ (BOOL)supportDebugSubitem:(SSDebugSubitems)debugItem {
#if INHOUSE
    NSString *channel = [TTSandBoxHelper getCurrentChannel];
    if ([[[TTSandBoxHelper bundleIdentifier] lowercaseString] rangeOfString:@"inhouse"].location != NSNotFound || [channel isEqualToString:@"local_test"] || [channel isEqualToString:@"dev"]) {
        return _suppertedSubitems & debugItem;
    }
#warning TODO 上线前删除
    if ([channel isEqualToString:@"App Store"]) {
        return _suppertedSubitems & debugItem;
    }
#endif
    return NO;
}

@end


#if TARGET_OS_SIMULATOR
#if INHOUSE
#import <FLEX/FLEXManager.h>
#import "ExploreCellHelper.h"

#import "TTStringHelper.h"
@implementation SSDebugViewController (DebugThemedChanged)

+(void) load
{
    void (^notiBlock)(void) = ^{
        
        TTThemeMode mode = [[TTThemeManager sharedInstance_tt] currentThemeMode];
        mode = (mode == TTThemeModeDay) ? TTThemeModeNight : TTThemeModeDay;
        [[TTThemeManager sharedInstance_tt] switchThemeModeto:mode];
    };
    
    [[FLEXManager sharedManager] registerSimulatorShortcutWithKey:@"t" modifiers:0 action:notiBlock description:@"Post Themed Change Notification"];
    
}

@end
#endif
#endif

#endif
