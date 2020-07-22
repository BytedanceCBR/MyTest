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
#import <TTKitchen/TTKitchen.h>

#import "TTPersistence.h"
#import "TTURLUtils.h"
#import "WDCommonLogic.h"

#import "ExploreCellHelper.h"
#import "TTStringHelper.h"

#import "TTVideoTip.h"
#import "TTLogServer.h"
#import "TTUserSettings/TTUserSettingsManager+FontSettings.h"
#import "TTAccountBusiness.h"

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
//#import "TTRNBundleManager.h"
#import <TTSettingsManager/TTSettingsManager+SaveSettings.h>
#import <AKWebViewBundlePlugin/TTDetailWebContainerDebugger.h>
#import "TTVSettingsConfiguration.h"
#import "SSFetchSettingsManager.h"
#import "TTAppStoreStarManager.h"
#import "TTClientABTestBrowserViewController.h"
#import "FHUtils.h"
#import "FHClientABTestDebugViewController.h"
#import "LogViewerSettingViewController.h"
//#import "TTFDashboardViewController.h"
#import <TTArticleBase/SSCommonLogic.h>
#import <TTArticleBase/ExploreLogicSetting.h>

#import "TTRNKitHelper.h"
#import "TTRNKit.h"
#import "TTRNKitMacro.h"
#import "FHRNDebugViewController.h"
#import "BDSSOAuthManager.h"
#import "ToastManager.h"
#import <ByteDanceKit/NSDictionary+BTDAdditions.h>
#import <TTInstallService/TTInstallUtil.h>
#import <MLeaksFinder/MLeaksFinder.h>
//#import <MLeaksFinder/NSObject+UseCount.h>
#import <TTRoute/TTRoute.h>
#import <Heimdallr/HMDExceptionTracker.h>
#import <Heimdallr/HMDUserExceptionTracker.h>


#import <BDMobileRuntime/BDServiceManager.h>
#import <TTLocationManager/TTDebugLocationPickerController.h>
//#import <BDNetworkDevMonitor/BDNetworkDevMonitor.h>

#import "TTInstallResetDevicePage.h"
#import "BDAgileLog.h"
//#import <TTBaseLib/UIAlertController+TTAdditions.h>
#import "UIAlertController+TTAdditions.h"
#import "HMDSRWTESTEnvironment.h"
#import "BDTFPSBar.h"
#import <FHPopupViewCenter/FHPopupViewManager.h>
#import "IMManager.h"
#import "FHLynxScanVC.h"
#import "FHLynxDebugVC.h"
#import "IMManager.h"

#import "FHHouseErrorHubDebugVC.h"

extern BOOL ttvs_isVideoNewRotateEnabled(void);
extern void ttvs_setIsVideoNewRotateEnabled(BOOL enabled);

extern NSDictionary *ttvs_videoMidInsertADDict(void);
extern NSInteger ttvs_getVideoMidInsertADReqStartTime(void);
extern NSInteger ttvs_getVideoMidInsertADReqEndTime(void);
extern NSString *const BOE_OPEN_KEY ;

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
@property (nonatomic, strong) TTRNKit *ttRNKit;
@property(nonatomic, strong) UIView *tableViewHeaderView;

@end

@implementation SSDebugViewController

+ (void)registerRoute {
    if ([TTSandBoxHelper isInHouseApp]) {
        TTRegisterRouteMethod
        RegisterRouteObjWithEntryName(@"debug");
    }
}

+ (void)registerKitchen {
    TTRegisterKitchenMethod
    if ([TTSandBoxHelper isInHouseApp]) {
        TTKConfigBOOL(@"tt_bridge_auth_enabled", @"是否打开新版 bridge 鉴权", YES);
        TTKConfigBOOL(@"tt_rexxar_auth_enabled", @"是否打开旧版 jsb 鉴权", YES);
    }
}

//TTAppDidFinishLaunchingFunction() {
//    if ([TTSandBoxHelper isInHouseApp]) {
//        [TTBridgeAuthManager sharedManager].authEnabled = [TTKitchen getBOOL:@"tt_bridge_auth_enabled"];
//        [TTJSBAuthManager sharedManager].isIgnoreJSBridgeAuthCheck = ![TTKitchen getBOOL:@"tt_rexxar_auth_enabled"];
//    }
//}

- (NSArray <STTableViewSectionItem *>*)_constructDataSource
{
    NSMutableArray *dataSource = [NSMutableArray arrayWithCapacity:2];
    
    if ([SSDebugViewController supportDebugSubitem:SSDebugSubitemFlex]) {
        
        NSMutableArray *itemArray = [NSMutableArray array];

        STTableViewCellItem *htmlBridgeDebugItem = [[STTableViewCellItem alloc] initWithTitle:@"Schema（H5）页面跳转" target:self action:@selector(_openHtmlBridge)];
        htmlBridgeDebugItem.switchStyle = NO;
        [itemArray addObject:htmlBridgeDebugItem];
        
        STTableViewCellItem *logViewItem = [[STTableViewCellItem alloc] initWithTitle:@"埋点验证" target:self action:@selector(_openLogViewSetting)];
        logViewItem.switchStyle = NO;
        [itemArray addObject:logViewItem];
    
        STTableViewCellItem *clientABDebugItem = [[STTableViewCellItem alloc] initWithTitle:@"😘F项目客户端AB实验调试选项点这里😘" target:self action:@selector(_openABTestSDKClientABTestVC)];
        clientABDebugItem.switchStyle = NO;
        [itemArray addObject:clientABDebugItem];
        
        STTableViewCellItem *rnBridgeDebugItem = [[STTableViewCellItem alloc] initWithTitle:@"RN_Debug" target:self action:@selector(_openRNBridge)];
        rnBridgeDebugItem.switchStyle = NO;
        [itemArray addObject:rnBridgeDebugItem];
        
        STTableViewCellItem *lynxDebugItem = [[STTableViewCellItem alloc] initWithTitle:@"Lynx_Debug" target:self action:@selector(_openLynxBridge)];
               lynxDebugItem.switchStyle = NO;
        [itemArray addObject:lynxDebugItem];
        
        STTableViewCellItem *ssoDebugItem = [[STTableViewCellItem alloc] initWithTitle:@"SSO重新验证测试" target:self action:@selector(_ssoDebugClick)];
        ssoDebugItem.switchStyle = NO;
        [itemArray addObject:ssoDebugItem];

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
        // todo zjing test
//        {
//            BridgeProxy *proxy = [BridgeProxy sharedInstance];
//            NSString *ip = getBridgeProxyIPAddress();
//            proxy.delegate = [[BridgeProxyTTRDelegate alloc] init];
//            NSString *title = [NSString stringWithFormat:@"BridgeProxy at ws://%@:%d", ip, BRIDGE_PROXY_PORT];
//            STTableViewCellItem *item = [[STTableViewCellItem alloc] initWithTitle:title target:self action:@selector(_openBridgeProxy)];
//            item.switchStyle = NO;
//            [itemArray addObject:item];
//        }
        
//        STTableViewCellItem *checkRuntimeServieItem = [[STTableViewCellItem alloc] initWithTitle:@"全局检测注册Service的状态" target:self action:@selector(_checkRuntimeServie)];
//        checkRuntimeServieItem.switchStyle = NO;
//        [itemArray addObject:checkRuntimeServieItem];
        
        
        STTableViewCellItem *articleDebugItem = [[STTableViewCellItem alloc] initWithTitle:@"详情页 & WebView 调试选项点这里" target:self action:@selector(_openArticleDebug)];
        articleDebugItem.switchStyle = NO;
        [itemArray addObject:articleDebugItem];
        
        STTableViewCellItem *fixLaunchImageItem = [[STTableViewCellItem alloc] initWithTitle:@"修复启动图" target:self action:@selector(fixLaunchImage)];
        [itemArray addObject:fixLaunchImageItem];
        
        STTableViewCellItem *destoryLaunchImageItem = [[STTableViewCellItem alloc] initWithTitle:@"损坏启动图" target:self action:@selector(destroyLaunchImage)];
        [itemArray addObject:destoryLaunchImageItem];
        {
//            STTableViewCellItem *item_netMonitor = [[STTableViewCellItem alloc] initWithTitle:@"📽 查看网络请求" target:self action:@selector(_openNetworkDevMonitor)];
//            [itemArray addObject:item_netMonitor];
            
//            STTableViewCellItem *item_netMonitorSwitch = [[STTableViewCellItem alloc] initWithTitle:@"App 启动时开启网络监控" target:self action:nil];
//            item_netMonitorSwitch.switchStyle = YES;
//            item_netMonitorSwitch.switchAction = @selector(_networkDevMonitorSwitchAction:);
//            item_netMonitorSwitch.checked = [self networkDevMonitorLaunchOnStartupOn];
//            [itemArray addObject:item_netMonitorSwitch];
            
            // TTTracker 在 Inhouse 模式下有比较多的网络请求用于验证埋点，这块会干扰其他网络请求，这边提供一个开关用于关闭 TTTracker 的 Inhouse 模式。默认仍为开启
            STTableViewCellItem *item_ttrackerInhouse = [[STTableViewCellItem alloc] initWithTitle:@"TTTracker Inhouse Version" target:self action:nil];
            item_ttrackerInhouse.switchStyle = YES;
            item_ttrackerInhouse.switchAction = @selector(_tttrackerInhouseSwitchAction:);
            item_ttrackerInhouse.checked = [self tttrackerInhouseVersion];
            [itemArray addObject:item_ttrackerInhouse];
            
            STTableViewCellItem *item_Inhouse_clearDid = [[STTableViewCellItem alloc] initWithTitle:@"LogSDK冷启动清空did开关" target:self action:nil];
            item_Inhouse_clearDid.switchStyle = YES;
            item_Inhouse_clearDid.switchAction = @selector(_applogInhouseClearDidAction:);
            item_Inhouse_clearDid.checked = [self applogInhouseClearDidAction];
            [itemArray addObject:item_Inhouse_clearDid];
        }

//        STTableViewCellItem *item_001 = [[STTableViewCellItem alloc] initWithTitle:@"Settings调试选项" target:self action:@selector(_openSettingsBrowserVC)];
//        [itemArray addObject:item_001];
        
        STTableViewCellItem *item_002 = [[STTableViewCellItem alloc] initWithTitle:@"客户端ABTest试验详情" target:self action:@selector(_openClientABTestVC)];
        
        
        STTableViewCellItem *settingRefreshItem = [[STTableViewCellItem alloc] initWithTitle:@"强制刷新 settings" target:self action:@selector(forceRefreshSettings)];
        [itemArray addObject:settingRefreshItem];
        
        STTableViewCellItem *item_01 = [[STTableViewCellItem alloc] initWithTitle:@"UGC新Feed" target:self action:NULL];
        item_01.switchStyle = YES;
        item_01.switchAction = @selector(_abActionFired:);
        item_01.checked = [ExploreCellHelper getFeedUGCTest];
        self.itemAB = item_01;
        [itemArray addObject:item_01];
        
        STTableViewCellItem *ugcDebugItem = [[STTableViewCellItem alloc] initWithTitle:@"ugc模块测试" target:self action:NULL];
        ugcDebugItem.switchStyle = YES;
        ugcDebugItem.switchAction = @selector(_ugcDebugTest:);
        ugcDebugItem.checked = [self _shouldUGCDebug];
        [itemArray addObject:ugcDebugItem];
        
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
        
        STTableViewCellItem *item_16 = [[STTableViewCellItem alloc] initWithTitle:@"日志加密" target:self action:NULL];
        item_16.switchStyle = YES;
        item_16.switchAction = @selector(_encryActionFired:);
        item_16.checked = [SSCommonLogic useEncrypt];
        [itemArray addObject:item_16];
        
        STTableViewCellItem *item_17 = [[STTableViewCellItem alloc] initWithTitle:@"appStore评分视图" target:self action:NULL];
        item_17.switchStyle = YES;
        item_17.switchAction = @selector(_appStoreStarFired:);
        item_17.checked =  [[TTAppStoreStarManager sharedInstance] isDebug];
        [itemArray addObject:item_17];
        
        STTableViewCellItem *item_18 = [[STTableViewCellItem alloc] initWithTitle:@"统计展示V3开关" target:self action:NULL];
        item_18.switchStyle = YES;
        item_18.switchAction = @selector(_trackV3Fired:);
        item_18.checked =  [[NSUserDefaults standardUserDefaults] boolForKey:@"kTTTrackerOnlyV3SendingEnableKey"];
        
        STTableViewCellItem *item_19 = [[STTableViewCellItem alloc] initWithTitle:@"测试Crash" target:self action:@selector(_crashActionFired)];
        [itemArray addObject:item_19];
        
        STTableViewCellItem *itemStartCrash = [[STTableViewCellItem alloc] initWithTitle:@"启动Crash" target:self action:NULL];
        itemStartCrash.switchAction = @selector(_switchStartCrash:);
        itemStartCrash.switchStyle = YES;
        NSDictionary *dic = [[NSUserDefaults standardUserDefaults] objectForKey:@"kTTShouldSimulateStartCrashKey"];
        BOOL shouldCrash = NO;
        if (dic) {
            shouldCrash = [dic btd_boolValueForKey:@"shouldCrash"];
        }
        itemStartCrash.checked = shouldCrash;
        [itemArray addObject:itemStartCrash];
        
        STTableViewCellItem *item_heimdallr = [[STTableViewCellItem alloc] initWithTitle:@"测试Heimdallr所有功能" target:self action:@selector(heimdallrTestFired)];
        [itemArray addObject:item_heimdallr];
        
        STTableViewCellItem *item_20 = [[STTableViewCellItem alloc] initWithTitle:@"测试卡死" target:self action:@selector(_waitActionFired)];
        [itemArray addObject:item_20];
        
        STTableViewCellItem *item_21 = [[STTableViewCellItem alloc] initWithTitle:@"测试OOM" target:self action:@selector(_oomActionFired)];
        [itemArray addObject:item_21];
        
        STTableViewCellItem *item_26 = [[STTableViewCellItem alloc] initWithTitle:@"测试自定义异常" target:self action:@selector(_customExceptionFired)];
        [itemArray addObject:item_26];
        
        STTableViewCellItem *item_22 = [[STTableViewCellItem alloc] initWithTitle:@"使用4G" target:self action:NULL];
        item_22.switchStyle = YES;
        item_22.switchAction = @selector(_switchTo4G:);
        item_22.checked = [[NSUserDefaults standardUserDefaults] boolForKey:@"debug_disable_network"];
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
        
        STTableViewCellItem *item_30 = [[STTableViewCellItem alloc] initWithTitle:@"图集开启随手拖动动画" target:self action:NULL];
        item_30.switchStyle = YES;
        item_30.switchAction = @selector(_switchImageTransitionAnimation:);
        item_30.checked = [SSCommonLogic imageTransitionAnimationEnable];
        [itemArray addObject:item_30];

        STTableViewCellItem *item_35 = [[STTableViewCellItem alloc] initWithTitle:@"重置上传通讯录状态" target:self action:@selector(_resetContactsActionFired)];
        [itemArray addObject:item_35];
    
        
        STTableViewCellItem *item_41 = [[STTableViewCellItem alloc] initWithTitle:@"详情页vConsole" target:self action:@selector(_switchToDetailvConsole)];
        item_41.switchStyle = YES;
        item_41.switchAction = @selector(_switchToDetailvConsole:);
        item_41.checked = [TTDetailWebContainerDebugger isvConsoleEnable];
        [itemArray addObject:item_41];
        
        STTableViewCellItem *item_42 = [[STTableViewCellItem alloc] initWithTitle:@"local_test异常" target:self action:@selector(_openLocalTestDebugViewController)];
        item_42.switchStyle = NO;
        [itemArray addObject:item_42];

        // todo zjing test
//        STTableViewCellItem *item_42 = [[STTableViewCellItem alloc] initWithTitle:@"JSBridge功能回归测试" target:self action:@selector(jsBridgeTest)];
//        [itemArray addObject:item_42];
//
//        STTableViewCellItem *item_JSBridgeDocumentor = [[STTableViewCellItem alloc] initWithTitle:@"开启 Bridge 文档化" target:self action:NULL];
//        item_JSBridgeDocumentor.switchStyle = YES;
//        item_JSBridgeDocumentor.checked = [TTKitchen getBOOL:@"tt_bridge_config.documentor_enabled"];
//        item_JSBridgeDocumentor.switchAction = @selector(_switchJSBridgeDocumentor:);
//        [itemArray addObject:item_JSBridgeDocumentor];
//
//        STTableViewCellItem *item_JSBridgeDocs = [[STTableViewCellItem alloc] initWithTitle:@"已注册的Bridge列表" target:self action:@selector(_showJSBridgeDocs)];
//        [itemArray addObject:item_JSBridgeDocs];
        
//        STTableViewCellItem *item_JSBridge = [[STTableViewCellItem alloc] initWithTitle:@"绕过JSBridge权限校验" target:self action:NULL];
//        item_JSBridge.switchStyle = YES;
//        item_JSBridge.checked = [TTJSBAuthManager sharedManager].isIgnoreJSBridgeAuthCheck;
//        item_JSBridge.switchAction = @selector(_switchJSBridgeAuth:);
//        [itemArray addObject:item_JSBridge];
//
//        STTableViewCellItem *item_Bridge = [[STTableViewCellItem alloc] initWithTitle:@"绕过新版Bridge权限校验" target:self action:NULL];
//        item_Bridge.switchStyle = YES;
//        item_Bridge.checked = ![TTBridgeAuthManager sharedManager].authEnabled;
//        item_Bridge.switchAction = @selector(_switchBridgeAuth:);
//        [itemArray addObject:item_Bridge];
        
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
        
        
        STTableViewCellItem *item_09 = [[STTableViewCellItem alloc] initWithTitle:@"FPS监测" target:self action:NULL];
        item_09.switchStyle = YES;
        item_09.switchAction = @selector(_appFPSMonitorActionFired:);
        item_09.checked = [[NSUserDefaults standardUserDefaults] boolForKey:@"kTTAppFPSMonitorKey"];
        
        STTableViewCellItem *item_10 = [[STTableViewCellItem alloc] initWithTitle:@"展示AB实验面板" target:self action:@selector(ABTestPanelFired)];
        STTableViewCellItem *item_11 = [[STTableViewCellItem alloc] initWithTitle:@"schema跳转:Push" target:self action:@selector(_jumpPageBySchemaActionPush)];

        NSArray *debugItems = @[item_00, item_02, item_03, item_04, item_05, item_06, item_07, item_09, item_10, item_11];
        STTableViewSectionItem *section0 = [[STTableViewSectionItem alloc] initWithSectionTitle:@"调试工具" items:debugItems];
        [dataSource addObject:section0];
    }
    
    if ([SSDebugViewController supportDebugSubitem:SSDebugSubitemLogging]) {
        
        STTableViewCellItem *item = [[STTableViewCellItem alloc] initWithTitle:@"导出日志" target:self action:@selector(_exportLog)];

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
        
        STTableViewSectionItem *section0 = [[STTableViewSectionItem alloc] initWithSectionTitle:@"统计日志" items:@[item,item00, item01,item02]];
        [dataSource addObject:section0];
    }
    
    if ([SSDebugViewController supportDebugSubitem:SSDebugSubitemFakeLocation]) {
        STTableViewCellItem *item10 = [[STTableViewCellItem alloc] initWithTitle:@"是否开启模拟定位" target:self action:NULL];
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
        
        STTableViewCellItem *item42 = [[STTableViewCellItem alloc] initWithTitle:@"清除所有NSUserDefaults" target:self action:@selector(_clearAllNSUserDefaults)];
        
        STTableViewSectionItem *section4 = [[STTableViewSectionItem alloc] initWithSectionTitle:@"读取用户设置" items:@[item40,item42,item41,itemfb]];
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
        
        STTableViewCellItem *item72 = [[STTableViewCellItem alloc] initWithTitle:@"BOE开关" target:self action:@selector(switchBOEAction)];
        item72.switchStyle = YES;
        item72.checked = [self.class isBOEOn];
        item72.switchAction = @selector(switchBOE:);
        
        STTableViewSectionItem *section7 = [[STTableViewSectionItem alloc] initWithSectionTitle:@"网络 开关" items:@[item71,item72]];
        
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
    
//    if (YES) {
//        STTableViewCellItem *item1 = [[STTableViewCellItem alloc] initWithTitle:@"接口请求开始时间(毫秒)" target:self action:nil];
//        item1.textFieldStyle = YES;
//        item1.textFieldAction = @selector(videoMidInsertADReqStartTimeChange:);
//        item1.textFieldContent = [NSString stringWithFormat:@"%ld", ttvs_getVideoMidInsertADReqStartTime()];
//
//        STTableViewCellItem *item2 = [[STTableViewCellItem alloc] initWithTitle:@"接口请求开始结束(毫秒)" target:self action:nil];
//        item2.textFieldStyle = YES;
//        item2.textFieldAction = @selector(videoMidInsertADReqEndTimeChange:);
//        item2.textFieldContent = [NSString stringWithFormat:@"%ld", ttvs_getVideoMidInsertADReqEndTime()];
//
//        STTableViewCellItem *item3 = [[STTableViewCellItem alloc] initWithTitle:@"接口请求开关" target:self action:nil];
//        item3.switchStyle = YES;
//        item3.checked = [SSCommonLogic isRefactorGetDomainsEnabled];
//        item3.switchAction = @selector(videoMidInsertADReqActionFired:);
//
//        STTableViewSectionItem *relatedVideoSection = [[STTableViewSectionItem alloc] initWithSectionTitle:@"中插广告" items:@[item1, item2, item3]];
//
//        [dataSource addObject:relatedVideoSection];
//    }
    
    
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
    
    
    {
        STTableViewCellItem *item = [[STTableViewCellItem alloc] initWithTitle:@"Mock新设备ID" target:self action:nil];
        item.switchStyle = YES;
        item.checked = [TTInstallUtil isResetMode];
        item.switchAction = @selector(_newUserSwitch:);
        item.detail = @"点击开关，生成新设备ID，关闭后恢复真实设备ID";
        STTableViewCellItem *item1 = [[STTableViewCellItem alloc] initWithTitle:@"新用户风格" target:self action:nil];
        item1.textFieldStyle = YES;
        item1.textFieldAction = @selector(_changeDebugStyle:);
        item1.textFieldContent = [[NSUserDefaults standardUserDefaults] stringForKey:@"kTTNewUserDebugStyleKey"];
        item1.detail = @"Mock新设备ID开启时，才会生效";
        STTableViewSectionItem *section11 = [[STTableViewSectionItem alloc] initWithSectionTitle:@"新用户" items:@[item,item1]];
        
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
//        item0.checked = [TTRNBundleManager sharedManager].devEnable;
        
        STTableViewCellItem *item1 = [[STTableViewCellItem alloc] initWithTitle:@"调试host" target:self action:nil];
        item1.textFieldStyle = YES;
        item1.textFieldAction = @selector(setRNDevHost:);
//        item1.textFieldContent = [TTRNBundleManager sharedManager].devHost;
        
        STTableViewCellItem *item2 = [[STTableViewCellItem alloc] initWithTitle:@"跳转Bundle(ReactDemo)" target:self action:@selector(goToRNPage)];
        
        STTableViewSectionItem *section14 = [[STTableViewSectionItem alloc] initWithSectionTitle:@"ReactNative相关：" items:@[item0, item1, item2]];
        
        [dataSource addObject:section14];
    }
    {
        STTableViewCellItem *item0 = [[STTableViewCellItem alloc] initWithTitle:@"关闭MLeaksFinder的全部功能"
                                                                         target:self
                                                                         action:nil];
        item0.switchStyle = YES;
        item0.switchAction = @selector(closeMLeaksFinder:);
        item0.checked = [[NSUserDefaults standardUserDefaults] boolForKey:@"kMLeaksClosedByDebuggingSettings"];
        
        STTableViewSectionItem *section15 = [[STTableViewSectionItem alloc] initWithSectionTitle:@"OOM相关:"
                                                                                           items:@[item0]];
        [dataSource addObject:section15];
    }
    { // Heimdallr 安全气垫相关
        STTableViewCellItem *hmdItem = [[STTableViewCellItem alloc] initWithTitle:@"关闭Heimdallr安全气垫功能"
                                                                           target:self
                                                                           action:nil];
        hmdItem.switchStyle = YES;
        hmdItem.checked = YES;
        hmdItem.switchAction = @selector(closeHMDException:);
        
        STTableViewSectionItem *hmdSection = [[STTableViewSectionItem alloc] initWithSectionTitle:@"安全气垫开关" items:@[hmdItem]];
        [dataSource addObject:hmdSection];
    }
    
    { // 模拟新用户配置
        STTableViewCellItem *newUserItem = [[STTableViewCellItem alloc] initWithTitle:@"模拟新用户首次启动配置" target:self action:@selector(_newUserLaunchAction)];
        STTableViewSectionItem *section16 = [[STTableViewSectionItem alloc] initWithSectionTitle:@"设置为新用户启动" items:@[newUserItem]];
        [dataSource addObject:section16];
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
    
    {
        // im相关调试选项
        STTableViewCellItem *toggleIMConnectionItem = [[STTableViewCellItem alloc] initWithTitle:@"IM走短连接(重启生效)" target:self action:nil];
        toggleIMConnectionItem.switchStyle = YES;
        toggleIMConnectionItem.checked = [[NSUserDefaults standardUserDefaults] boolForKey:@"_IM_ShortConnection_Enable_"];
        toggleIMConnectionItem.switchAction = @selector(toggleIMConnection);
        toggleIMConnectionItem.detail = [NSString stringWithFormat:@"https抓包 /message/send  请求，验证是否生效"];
        
        STTableViewCellItem *toggleIMReadReceiptRequestItem = [[STTableViewCellItem alloc] initWithTitle:@"IM已读回执请求轮询关闭" target:self action:nil];
        toggleIMReadReceiptRequestItem.switchStyle = YES;
        toggleIMReadReceiptRequestItem.checked = [self isIMReadReceiptRequestClosed];
        toggleIMReadReceiptRequestItem.switchAction = @selector(toggleIMReadReceiptRequest);
        
        STTableViewCellItem *toggleIMFakeTokenItem = [[STTableViewCellItem alloc] initWithTitle:@"模拟IM服务端返回失效Token" target:self action:nil];
        toggleIMFakeTokenItem.switchStyle = YES;
        toggleIMFakeTokenItem.checked = [[NSUserDefaults standardUserDefaults] boolForKey:@"_IM_Fake_Token_Enable_"];
        toggleIMFakeTokenItem.switchAction = @selector(toggleIMFakeToken);
        
        STTableViewCellItem *invalidIMToken = [[STTableViewCellItem alloc] initWithTitle:@"IM手动触发token失效更新" target:self action:@selector(triggerIMTokenInvalide)];
        
        STTableViewCellItem *frequenceControlDisable = [[STTableViewCellItem alloc] initWithTitle:@"IM房源卡片自动文本频控关闭" target:self action:nil];
        frequenceControlDisable.switchStyle = YES;
        frequenceControlDisable.checked = [[NSUserDefaults standardUserDefaults] boolForKey:@"_IM_Frequenct_Control_Disable_"];
        frequenceControlDisable.switchAction = @selector(toggleIMFrequencyControlDisable);
        
        STTableViewSectionItem *section = [[STTableViewSectionItem alloc] initWithSectionTitle:@"IM相关调试选项" items:@[toggleIMConnectionItem, toggleIMReadReceiptRequestItem, toggleIMFakeTokenItem, invalidIMToken, frequenceControlDisable]];
        
        [dataSource addObject:section];
    }
    
    
    return dataSource;
}

- (void)toggleIMConnection {
    BOOL isShortConnectEnable = [[NSUserDefaults standardUserDefaults] boolForKey:@"_IM_ShortConnection_Enable_"];
    [[NSUserDefaults standardUserDefaults] setBool:!isShortConnectEnable forKey:@"_IM_ShortConnection_Enable_"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)toggleIMFakeToken {
    BOOL isFakeTokenEnable = [[NSUserDefaults standardUserDefaults] boolForKey:@"_IM_Fake_Token_Enable_"];
    [[NSUserDefaults standardUserDefaults] setBool:!isFakeTokenEnable forKey:@"_IM_Fake_Token_Enable_"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    if(!isFakeTokenEnable) {
        [self triggerIMTokenInvalide];
    }
}

- (void)toggleIMFrequencyControlDisable {
    BOOL isDisableIMFrequenceControl = [[NSUserDefaults standardUserDefaults] boolForKey:@"_IM_Frequenct_Control_Disable_"];
    [[NSUserDefaults standardUserDefaults] setBool:!isDisableIMFrequenceControl forKey:@"_IM_Frequenct_Control_Disable_"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
- (void)triggerIMTokenInvalide {
    [[IMManager shareInstance] invalidTokenForDebug];
}

- (BOOL)isIMReadReceiptRequestClosed {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"_IM_Read_Receipt_Request_Close_"];
}

- (void)toggleIMReadReceiptRequest {
    
    BOOL isCloseReadReceiptReq = [[NSUserDefaults standardUserDefaults] boolForKey:@"_IM_Read_Receipt_Request_Close_"];
    [[NSUserDefaults standardUserDefaults] setBool:!isCloseReadReceiptReq forKey:@"_IM_Read_Receipt_Request_Close_"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self.tableView reloadData];
}

-(void)makeACrash {
    NSArray * array = [NSArray array];
    NSLog(@"array=%@", array[3]);
}

- (void)closeMLeaksFinder:(UISwitch*)uiswitch {
    [[NSUserDefaults standardUserDefaults] setBool:uiswitch.on forKey:@"kMLeaksClosedByDebuggingSettings"];
    [TTMLeaksFinder stopDetectMemoryLeak];
    // todo zjing test
//    [NSObject stopMonitor];
}

- (void)closeHMDException:(UISwitch*)uiswitch {
    if (uiswitch.on) {
        [[HMDExceptionTracker sharedTracker] start];
    } else {
        [[HMDExceptionTracker sharedTracker] stop];
    }
}

- (void)_newUserLaunchAction {
    // todo zjing test
    // 清空磁盘和UserDefault数据
//    [BDDiskRecoverManager recoverAllDiskAndDeleteUserDefault];
    
    // 清理 新用户 kitchen
    NSMutableDictionary *searchDictionary = [[NSMutableDictionary alloc] init];
    //指定item的类型为GenericPassword
    [searchDictionary setObject:(id)kSecClassGenericPassword forKey:(id)kSecClass];
    
    // 类型为GenericPassword的信息必须提供以下两条属性作为unique identifier
    [searchDictionary setObject:@"kTTFirstLaunchAccount" forKey:(id)kSecAttrAccount];
    [searchDictionary setObject:@"kTTFirstLaunchService" forKey:(id)kSecAttrService];
    SecItemDelete((CFDictionaryRef)searchDictionary);
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
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:[SSNavigationBar navigationButtonOfOrientation:SSNavigationButtonOrientationOfLeft withTitle:@"关闭" target:self action:@selector(_cancelActionFired:)]];
    
    [self _reloadRightBarItem];
    
    self.tableView.tableHeaderView = self.tableViewHeaderView;

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
//    self.itemOwnPlayer.checked = [[self class] supportTestVideoOwnPlayer];
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
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:[SSNavigationBar navigationButtonOfOrientation:SSNavigationButtonOrientationOfRight withTitle:@"设备信息" target:self action:@selector(_sendDeviceActionFired:)]];
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

//- (void)_checkRuntimeServie {
//    [[BDServiceManager sharedInstance] scanAndCheckAllServices];
//}

//-(void)_openBridgeProxy{
//    BridgeProxyViewController *vc = [[BridgeProxyViewController alloc] init];
//    BridgeProxy *proxy = [BridgeProxy sharedInstance];
//    proxy.vc = vc;
//    [proxy setUserAgentString:[SSWebViewUtil optimisedUserAgentString:YES]];
//    [proxy start];
//    [self.navigationController pushViewController:vc animated:YES];
//}

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

- (void)_openABTestSDKClientABTestVC
{
    FHClientABTestDebugViewController *clientABVC = [FHClientABTestDebugViewController new];
    [self.navigationController pushViewController:clientABVC animated:YES];
}

- (void)_openShortVideoDebug
{
    [self.navigationController pushViewController:[[TSVDebugViewController alloc] init]
                                         animated:YES];
}

- (void)_openLogViewSetting {
    NSLog(@"_openLogViewSetting");
    LogViewerSettingViewController* controller = [[LogViewerSettingViewController alloc] init];
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)_openRNBridge
{
    self.ttRNKit = [[TTRNKit alloc] initWithGeckoParams:[TTRNKitStartUpSetting startUpParameterForKey:TTRNKitInitGeckoParams] ?: @{}
                                        animationParams:[TTRNKitStartUpSetting startUpParameterForKey:TTRNKitInitAnimationParams] ?: @{}];
    self.ttRNKit.delegate = self;
    FHRNDebugViewController *vc = [[FHRNDebugViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)_openLynxBridge
{
    FHLynxScanVC* scanVC = [FHLynxScanVC new];
    [self.navigationController pushViewController:scanVC animated:YES];
}

- (void)_ugcDebugTest:(UISwitch *)uiswitch {
    [[NSUserDefaults standardUserDefaults] setBool:uiswitch.isOn forKey:@"kUGCDebugConfigKey"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)_ssoDebugClick {
#if !DEBUG && !TARGET_IPHONE_SIMULATOR
    [[BDSSOAuthManager sharedInstance] resetAuthInfo];
    [[ToastManager manager] showToast:@"SSO缓存已清除，请重进App"];
#endif
}

- (void)_gotoHtmlBridge:(NSString *)urlStrInput {
    NSString *stringToSave = [NSString stringWithString:urlStrInput];
    
    NSString *unencodedString = urlStrInput;
    NSString *encodedString = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                                                                    (CFStringRef)unencodedString,
                                                                                                    NULL,
                                                                                                    (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                                                                    kCFStringEncodingUTF8));
    NSString *urlStr = [NSString stringWithFormat:@"sslocal://webview?url=%@",encodedString];
    
    [FHUtils setContent:stringToSave forKey:@"k_fh_debug_h5_bridge_test"];
    
    NSURL *url = [TTURLUtils URLWithString:urlStr];
    [[TTRoute sharedRoute] openURLByPushViewController:url];
}

- (void)_openHtmlBridge
{
    NSString *tempUrl = [UIPasteboard generalPasteboard].string;
    if (tempUrl.length > 0 && [tempUrl hasPrefix:@"http"]) {
        [self _gotoHtmlBridge:tempUrl];
        [UIPasteboard generalPasteboard].string = @"";
        return;
    }
    
    TTThemedAlertController *alertVC = [[TTThemedAlertController alloc] initWithTitle:@"请输入调试地址" message:nil preferredType:TTThemedAlertControllerTypeAlert];
    
//    [alertVC addTextFieldWithConfigurationHandler:^(UITextField *textField) {
//        textField.placeholder = @"请输入调试地址";
//    }];
    
    [alertVC addTextViewWithConfigurationHandler:^(UITextView *textView) {
        
    }];
    
    if ([[FHUtils contentForKey:@"k_fh_debug_h5_bridge_test"] isKindOfClass:[NSString class]]) {
        [alertVC uniqueTextView].text = [FHUtils contentForKey:@"k_fh_debug_h5_bridge_test"];
    }
    
    alertVC.title = @"请输入调试地址";
    
    [alertVC addActionWithTitle:@"取消" actionType:TTThemedAlertActionTypeCancel actionBlock:^{
        
    }];
    
    __block TTThemedAlertController *alertVCWeak = alertVC;
    [alertVC addActionWithTitle:@"前往" actionType:TTThemedAlertActionTypeNormal actionBlock:^{
        
        NSString *urlStrInput = [alertVCWeak uniqueTextView].text;
        if (!urlStrInput || urlStrInput.length == 0) {
            return ;
        }
        
        if([urlStrInput containsString:@"sslocal://"]){
            NSString *stringToSave = [NSString stringWithString:urlStrInput];
             [FHUtils setContent:stringToSave forKey:@"k_fh_debug_h5_bridge_test"];
             
             NSURL *url = [TTURLUtils URLWithString:urlStrInput];
             [[TTRoute sharedRoute] openURLByPushViewController:url];
        }else
        {
            NSString *stringToSave = [NSString stringWithString:urlStrInput];
             
             NSString *unencodedString = urlStrInput;
             NSString *encodedString = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                                                                             (CFStringRef)unencodedString,
                                                                                                             NULL,
                                                                                                             (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                                                                             kCFStringEncodingUTF8));
             NSString *urlStr = [NSString stringWithFormat:@"sslocal://webview?url=%@",encodedString];
             
             [FHUtils setContent:stringToSave forKey:@"k_fh_debug_h5_bridge_test"];
             
             NSURL *url = [TTURLUtils URLWithString:urlStr];
             [[TTRoute sharedRoute] openURLByPushViewController:url];
        }
 
        
        alertVCWeak = nil;
    }];
    
    UIViewController *topVC = [TTUIResponderHelper topmostViewController];
    if (topVC) {
        [alertVC showFrom:topVC animated:YES];
    }
}

- (void)_openAdDebug
{
    [self.navigationController pushViewController:[[TADDebugViewController alloc] init]
                                         animated:YES];
}

- (void)_openLocalTestDebugViewController
{
    [self.navigationController pushViewController:[[FHHouseErrorHubDebugVC alloc] init]
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
        [self _setShouldAutomaticallyChangeCity:uiswitch.on];
       
//        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
//        NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithCapacity:2];
//        [parameters setValue:[TTAccountManager userID] forKey:@"user_id"];
//        [parameters setValue:[[TTInstallIDManager sharedInstance] deviceID] forKey:@"device_id"];
//        [[TTNetworkManager shareInstance] requestForJSONWithURL:@"http://ic.snssdk.com/location/rmlbsmhxzkhlinfo/" params:parameters method:@"GET" needCommonParams:NO callback:^(NSError *error, id jsonObj) {
//            if (!error) {
//                [self _setShouldAutomaticallyChangeCity:uiswitch.on];
//            }
//        }];
    } else {
        
     
//        [self _setShouldAutomaticallyChangeCity:uiswitch.on];
    }
    
}

- (void)_fakeUserLocationActionFired {
    
    TTThemedAlertController *alertVC = [[TTThemedAlertController alloc] initWithTitle:@"请输入调试地址" message:nil preferredType:TTThemedAlertControllerTypeAlert];
    
    //    [alertVC addTextFieldWithConfigurationHandler:^(UITextField *textField) {
    //        textField.placeholder = @"请输入调试地址";
    //    }];
    
    [alertVC addTextViewWithConfigurationHandler:^(UITextView *textView) {

    }];

    
    if ([[FHUtils contentForKey:@"k_fh_debug_lat"] isKindOfClass:[NSString class]]) {
        [alertVC uniqueTextView].text = [FHUtils contentForKey:@"k_fh_debug_lat"];
    }
    
    alertVC.title = @"请输入经纬度";
    
    [alertVC addActionWithTitle:@"取消" actionType:TTThemedAlertActionTypeCancel actionBlock:^{
        
    }];
    
    __block TTThemedAlertController *alertVCWeak = alertVC;
    [alertVC addActionWithTitle:@"开始模拟" actionType:TTThemedAlertActionTypeNormal actionBlock:^{
        UITextView *textView = [alertVC uniqueTextView];
        NSLog(@"text view = %@",textView.text);
        NSArray *paramsArrary = [textView.text componentsSeparatedByString:@","];
        NSLog(@"paramsArrary = %@",paramsArrary);

        [FHUtils setContent:@"" forKey:@"k_fh_debug_lat"];
        
    }];
    
    UIViewController *topVC = [TTUIResponderHelper topmostViewController];
    if (topVC) {
        [alertVC showFrom:topVC animated:YES];
    }
    
    //    SSLocationPickerController *pickerController = [[SSLocationPickerController alloc] init];
    //    [self.navigationController pushViewController:pickerController animated:YES];
    //    UIWindow *window = self.view.window;
    //    pickerController.completionHandler = ^(SSLocationPickerController *pickerViewController){
    //        // reverse 城市
    //        if ([SSLocationPickerController cachedFakeLocationCoordinate].longitude * [SSLocationPickerController cachedFakeLocationCoordinate].latitude > 0) {
    //            TTIndicatorView *indicator = [[TTIndicatorView alloc] initWithIndicatorStyle:TTIndicatorViewStyleWaitingView indicatorText:nil indicatorImage:nil dismissHandler:nil];
    //            indicator.showDismissButton = NO;
    //            indicator.autoDismiss = NO;
    //            [indicator showFromParentView:window];
    ////            [[TTLocationManager sharedManager] regeocodeWithCompletionHandler:^(NSArray *placemarks) {
    ////                [self.tableView reloadData];
    ////                [indicator dismissFromParentView];
    ////                [pickerViewController.navigationController popViewControllerAnimated:YES];
    ////            }];
    //        } else {
    //            [pickerViewController.navigationController popViewControllerAnimated:YES];
    //        }
    //    };
}


- (void)_setShouldSaveApplog:(UISwitch *)uiswitch {
    [[NSUserDefaults standardUserDefaults] setBool:uiswitch.isOn forKey:@"kShouldSaveApplogKey"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (BOOL)_shouldSaveApplog {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"kShouldSaveApplogKey"];
}

- (BOOL)_shouldUGCDebug {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"kUGCDebugConfigKey"];
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
    [[NSUserDefaults standardUserDefaults] setBool:uiswitch.isOn forKey:@"debug_disable_network"];
}

//- (void)_switchJSBridgeDocumentor:(UISwitch *)uiswitch {
//    [TTKitchen setBOOL:uiswitch.isOn forKey:@"tt_bridge_config.documentor_enabled"];
//}
//
//- (void)_showJSBridgeDocs {
//    [TTBridgeDocumentsViewController showInViewController:self];
//}
//
//- (void)_switchJSBridgeAuth:(UISwitch *)uiswitch {
//    [TTKitchen setBOOL:!uiswitch.isOn forKey:@"tt_rexxar_auth_enabled"];
//    [TTJSBAuthManager sharedManager].isIgnoreJSBridgeAuthCheck = uiswitch.isOn;
//}
//
//- (void)_switchBridgeAuth:(UISwitch *)uiswitch {
//    [TTKitchen setBOOL:!uiswitch.isOn forKey:@"tt_bridge_auth_enabled"];
//    [TTBridgeAuthManager sharedManager].authEnabled = !uiswitch.isOn;
//}

- (void)_switchToNewPullRefresh:(UISwitch *)uiswitch {
    [SSCommonLogic setNewPullRefreshEnabled:uiswitch.isOn];
}

- (void)_switchSharedWebView:(UISwitch *)uiswitch {
    [SSCommonLogic setDetailSharedWebViewEnabled:uiswitch.isOn];
}

- (void)_switchTransitionAnimation:(UISwitch *)uiswitch {
    [[TTSettingsManager sharedManager] updateSetting:@(uiswitch.isOn) forKey:@"transition_animation_enabled"];
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

// 导出log
- (void)_exportLog {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"导出log" message:nil preferredStyle:UIAlertControllerStyleActionSheet sourceView:self.view];
    NSString *directory = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) firstObject];
    NSString *path = [directory stringByAppendingPathComponent:@"alog"];
    NSArray *array = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:nil];
    WeakSelf;
    for (NSString *item in array) {
        if (![item hasSuffix:@".alog"]) {
            continue;
        }

        [alertController addAction:[UIAlertAction actionWithTitle:item style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            StrongSelf;
            NSString *filePath = [path stringByAppendingPathComponent:item];
            [self _shareLog:filePath];
        }]];
    }

    [alertController addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];

    [self presentViewController:alertController animated:YES completion:nil];
}

// 分享log
- (void)_shareLog:(NSString*)filePath {
    NSURL *url = [NSURL fileURLWithPath:filePath];
    UIActivityViewController *controller = [[UIActivityViewController alloc] initWithActivityItems:@[url] applicationActivities:nil];
    controller.excludedActivityTypes = @[UIActivityTypePostToTwitter, UIActivityTypePostToFacebook, UIActivityTypeMessage, UIActivityTypeMail, UIActivityTypePrint, UIActivityTypeCopyToPasteboard, UIActivityTypeAssignToContact, UIActivityTypeSaveToCameraRoll, UIActivityTypeAddToReadingList, UIActivityTypePostToFlickr, UIActivityTypePostToVimeo, UIActivityTypePostToTencentWeibo, UIActivityTypePostToWeibo];
    [self presentViewController:controller animated:YES completion:nil];
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

//- (void)_fakeUserLocationActionFired {
//    TTDebugLocationPickerController *pickerController = [[TTDebugLocationPickerController alloc] init];
//    [self.navigationController pushViewController:pickerController animated:YES];
//    UIWindow *window = self.view.window;
//    pickerController.completionHandler = ^(TTDebugLocationPickerController *pickerViewController){
//        // reverse 城市
//        if ([TTDebugLocationPickerController cachedFakeLocationCoordinate].longitude * [TTDebugLocationPickerController cachedFakeLocationCoordinate].latitude > 0) {
//            TTIndicatorView *indicator = [[TTIndicatorView alloc] initWithIndicatorStyle:TTIndicatorViewStyleWaitingView indicatorText:nil indicatorImage:nil dismissHandler:nil];
//            indicator.showDismissButton = NO;
//            indicator.autoDismiss = NO;
//            [indicator showFromParentView:window];
//            [[TTLocationManager sharedManager] startGeolocatingWithCompletionHandler:^(NSArray *placemarks) {
//                [self.tableView reloadData];
//                [indicator dismissFromParentView];
//                [pickerViewController.navigationController popViewControllerAnimated:YES];
//            }];
//        } else {
//            [pickerViewController.navigationController popViewControllerAnimated:YES];
//        }
//    };
//}

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


- (void)_clearAllNSUserDefaults {
    NSString *appDomainStr = [[NSBundle mainBundle] bundleIdentifier];
    [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:appDomainStr];
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
    [[TTAppStoreStarManager sharedInstance] setDebug:uiswitch.isOn];
}

- (void)_trackV3Fired:(UISwitch *)uiswitch
{
    [TTTrackerWrapper setV3DoubleSendingEnable:uiswitch.isOn];
}

//制造一个无限等待的卡死
- (void)_waitActionFired {
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
}

- (void)_oomActionFired {
    NSMutableArray *dataArray = [[NSMutableArray alloc] init];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        for (int i = 0; i < 1000; i++) {
            NSString *path = [[NSBundle mainBundle] pathForResource:@"Assets" ofType:@"car"];
            NSData *data = [NSData dataWithContentsOfFile:path];
            [dataArray addObject:data?:@""];
        }
    });
}

- (void)_posterADActionFired:(UISwitch *)uiswitch
{
    [SSCommonLogic setPosterADClickEnabled:uiswitch.isOn];
}

-(void)_crashActionFired{
    NSArray * array = [NSArray array];
    BDALOG_INFO(@"array=%@", array[3]);
}

- (void)_switchStartCrash:(UISwitch *)sender {
    NSDictionary *dic = @{@"shouldCrash":@(sender.on),@"times":@0};
    [[NSUserDefaults standardUserDefaults] setValue:[dic copy] forKey:@"kTTShouldSimulateStartCrashKey"];
}

-(void)heimdallrTestFired{
    [self.navigationController pushViewController:[HMDSRWTESTEnvironment new] animated:YES];
}

- (void)_customExceptionFired {
    [[HMDUserExceptionTracker sharedTracker] trackCurrentThreadLogExceptionType:@"assert" skippedDepth:0 customParams:nil filters:nil callback:^(NSError * _Nullable error) {
        
    }];
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

- (void)_appFPSMonitorActionFired:(UISwitch *)uiswitch {
    [[NSUserDefaults standardUserDefaults] setBool:uiswitch.on forKey:@"kTTAppFPSMonitorKey"];
    [BDTFPSBar sharedInstance].hidden = !uiswitch.on;
}

//- (void)_defenseTest:(UISwitch *)uiswitch {
//    [[NSUserDefaults standardUserDefaults] setBool:uiswitch.on forKey:kDefenseTest];
//    TTDefenseTest.shared.on = uiswitch.on;
//}

// todo zjing test
//- (void)_openNetworkDevMonitor {
//    [self dismissViewControllerAnimated:YES completion:^{
//        [BDNetworkDevMonitor showRecordsView];
//    }];
//}
//
//- (void)_networkDevMonitorSwitchAction:(UISwitch *)uiswitch {
//    [[NSUserDefaults standardUserDefaults] setBool:uiswitch.on forKey:@"kTTNetworkDevMonitorStartOnLaunchKey"];
//
//    if (uiswitch.on) {
//        [BDNetworkDevMonitor start];
//    } else {
//        [BDNetworkDevMonitor stop];
//    }
//}

- (BOOL)networkDevMonitorLaunchOnStartupOn {
    BOOL launchOnStartup = [[NSUserDefaults standardUserDefaults] boolForKey:@"kTTNetworkDevMonitorStartOnLaunchKey"];
    return launchOnStartup;
}

- (void)_tttrackerInhouseSwitchAction:(UISwitch *)uiswitch {
    BOOL shouldOn = uiswitch.on;
    if (shouldOn) {
        if ([TTSandBoxHelper isInHouseApp]) {
            [[TTTracker sharedInstance] setIsInHouseVersion:YES]; // will change kTTTrackerInHouseVersion in UserDefault
        }
    } else {
        [[TTTracker sharedInstance] setIsInHouseVersion:NO];
    }
}
- (BOOL)tttrackerInhouseVersion {
    BOOL inhouse = [[NSUserDefaults standardUserDefaults] boolForKey:@"kTTTrackerInHouseVersion"];
    return inhouse;
}
- (void)_applogInhouseClearDidAction:(UISwitch *)uiswitch {
    BOOL shouldOn = uiswitch.on;
    [[NSUserDefaults standardUserDefaults] setBool:shouldOn forKey:@"AppLogClearDidInhouse"];
}

- (BOOL)applogInhouseClearDidAction {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"AppLogClearDidInhouse"];
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

- (void)iCloudEableAction:(UISwitch *)uiswitch
{
    [SSCommonLogic setIcloudBtnEnabled:uiswitch.isOn];
}

- (void)videoDetailRelatedStyleChange:(UITextField *)field{
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    NSNumber *result = [formatter numberFromString:field.text];
    if (result) {
        [SSCommonLogic setVideoDetailRelatedStyle:[result integerValue]];
    }
}

//- (void)videoMidInsertADReqStartTimeChange:(UITextField *)field {
//    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
//    NSNumber *result = [formatter numberFromString:field.text];
//    if (result) {
//        NSMutableDictionary *videoMidInsertADMutableDict = [ttvs_videoMidInsertADDict() mutableCopy];
//        [videoMidInsertADMutableDict setObject:result forKey:@"tt_video_midpatch_req_start"];
//        [[TTSettingsManager sharedManager] updateSetting:[videoMidInsertADMutableDict copy] forKey:@"tt_video_midpatch_settings"];
//    }
//}
//
//- (void)videoMidInsertADReqEndTimeChange:(UITextField *)field {
//    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
//    NSNumber *result = [formatter numberFromString:field.text];
//    if (result) {
//        NSMutableDictionary *videoMidInsertADMutableDict = [ttvs_videoMidInsertADDict() mutableCopy];
//        [videoMidInsertADMutableDict setObject:result forKey:@"tt_video_midpatch_req_end"];
//        [[TTSettingsManager sharedManager] updateSetting:[videoMidInsertADMutableDict copy] forKey:@"tt_video_midpatch_settings"];
//    }
//}
//
//- (void)videoMidInsertADReqActionFired:(UISwitch *)uiswitch {
//    NSMutableDictionary *videoMidInsertADMutableDict = [ttvs_videoMidInsertADDict() mutableCopy];
//    [videoMidInsertADMutableDict setObject:@(uiswitch.isOn) forKey:@"tt_video_midpatch_req_not_ad"];
//    [[TTSettingsManager sharedManager] updateSetting:[videoMidInsertADMutableDict copy] forKey:@"tt_video_midpatch_settings"];
//}

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
- (void)_newUserSwitch:(UISwitch *)sender
{
    if (sender.on) {
        TTInstallResetDevicePage *resetPage = [[TTInstallResetDevicePage alloc] init];
        @weakify(self)
        resetPage.okButtonDidClicked = ^(NSString * _Nonnull gender, NSString * _Nonnull ageLevel, BOOL isAutoReset) {
            @strongify(self)
            [[TTInstallIDManager sharedInstance] setIsInHouseVersion:YES];
            [TTInstallUtil setAutoReset:isAutoReset];
            [TTInstallUtil setResetMode:YES];
            [[NSUserDefaults standardUserDefaults] setObject:gender forKey:@"TTInstallGenderKey"];
            [[NSUserDefaults standardUserDefaults] setObject:ageLevel forKey:@"TTInstallAgeLevelKey"];
            UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"新设备ID重置成功" message:@"请杀死App后，重新冷启动即可生效" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:nil];
            [alertVC addAction:okAction];
            [self presentViewController:alertVC animated:YES completion:nil];
        };
        resetPage.cancelButtonDidClicked = ^{
            sender.on = NO;
        };
        [self presentViewController:resetPage animated:YES completion:nil];
    } else {
        [[TTInstallIDManager sharedInstance] setIsInHouseVersion:YES];
        [TTInstallUtil setResetMode:NO];
        UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"已关闭Mock新设备ID" message:@"如需再次生成新设备ID，请再次点击开关进行重置" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:nil];
        [alertVC addAction:okAction];
        [self presentViewController:alertVC animated:YES completion:nil];
    }
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

#pragma mark - header
- (UIView *)tableViewHeaderView {
    if (_tableViewHeaderView == nil) {
        _tableViewHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.width, 40)];
        WeakSelf;
//        UIButton *kitchenBtn = [_tableViewHeaderView ugc_addSubviewWithClass:[SSThemedButton class] themePath:@"#KitchenHeaderButton"];
//        [kitchenBtn setTitle:@"Kitchen" forState:UIControlStateNormal];
//        [kitchenBtn addTarget:self withActionBlock:^{
//            StrongSelf;
//            [TTKitchenBrowserViewController showInViewController:self];
//        } forControlEvent:(UIControlEventTouchUpInside)];
//
//        UIButton *flexBtn = [_tableViewHeaderView ugc_addSubviewWithClass:[SSThemedButton class] themePath:@"#KitchenHeaderButton"];
//        [flexBtn setTitle:@"FLEX" forState:UIControlStateNormal];
//        [flexBtn addTarget:self withActionBlock:^{
//            [[FLEXManager sharedManager] showExplorer];
//        } forControlEvent:(UIControlEventTouchUpInside)];
//
//        UIButton *fpsBtn = [_tableViewHeaderView ugc_addSubviewWithClass:[SSThemedButton class] themePath:@"#KitchenHeaderButton"];
//        [fpsBtn setTitle:@"FPS" forState:UIControlStateNormal];
//        [fpsBtn addTarget:self withActionBlock:^{
//            [TTDebugAssistant show];
//            [TTSystemInfoManager sharedInstance].sysInfoFlags = TTTopBarShowSysInfoFPS | TTTopBarShowSysInfoMemory | TTTopBarShowSysInfoCPU;
//        } forControlEvent:(UIControlEventTouchUpInside)];
//
//        [kitchenBtn mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.width.equalTo(_tableViewHeaderView.mas_width).multipliedBy(0.25);
//            make.height.equalTo(@(40.0));
//            make.left.equalTo(_tableViewHeaderView.mas_left);
//            make.top.equalTo(_tableViewHeaderView.mas_top);
//        }];
//
//        [flexBtn mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.width.equalTo(kitchenBtn.mas_width);
//            make.height.equalTo(kitchenBtn.mas_height);
//            make.left.equalTo(kitchenBtn.mas_right);
//            make.top.equalTo(kitchenBtn.mas_top);
//        }];
//
//        [fpsBtn mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.width.equalTo(kitchenBtn.mas_width);
//            make.height.equalTo(kitchenBtn.mas_height);
//            make.left.equalTo(flexBtn.mas_right);
//            make.top.equalTo(kitchenBtn.mas_top);
//        }];
    }
    return _tableViewHeaderView;
}

- (void)fixLaunchImage {
    // todo zjing test
//    fixLaunchImage(^UIImage *(BOOL destory) {
//        if (destory) {
//            UIStoryboard *sb = [UIStoryboard storyboardWithName:@"StartLogo" bundle:nil];
//            UIViewController *vc = [sb instantiateInitialViewController];
//            UIWindow *window = [[UIWindow alloc] initWithFrame:UIScreen.mainScreen.bounds];
//            window.rootViewController = vc;
//            window.windowLevel = UIWindowLevelNormal - 1;
//            [window makeKeyAndVisible];
//
//            return [self.class imageWithView:window];
//        }
//        return nil;
//    }, ^(BOOL fixed) {
//        [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage
//                                  indicatorText:@"已修复启动图"
//                                 indicatorImage:nil
//                                    autoDismiss:YES
//                                 dismissHandler:nil];
//    });
}

- (void)destroyLaunchImage {
    
    // todo zjing test
//    fixLaunchImage(^(BOOL destory) {
//        CGSize screenSize = UIScreen.mainScreen.bounds.size;
//        CGSize size = CGSizeMake(screenSize.width * UIScreen.mainScreen.scale, screenSize.height * UIScreen.mainScreen.scale);
//        UIImage *image = [UIImage imageWithColor:UIColor.blackColor
//                                            size:size];
//        return image;
//    }, ^(BOOL fixed) {
//        [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage
//                                  indicatorText:@"已损坏启动图"
//                                 indicatorImage:nil
//                                    autoDismiss:YES
//                                 dismissHandler:nil];
//    });
}

+ (UIImage *)imageWithView:(UIView *)view {
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, view.opaque, 0.0);
    [view drawViewHierarchyInRect:view.bounds afterScreenUpdates:YES];
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}
#pragma mark - React Native调试
- (void)toggleRNDevEnable:(UISwitch *)sw {
//    [TTRNBundleManager sharedManager].devEnable = sw.on;
}

- (void)setRNDevHost:(UITextField *)textField {
//    [TTRNBundleManager sharedManager].devHost = textField.text;
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

-(void)switchBOEAction {
    [self switchBOE:nil];
    [self.tableView reloadData];
}

-(void)switchBOE:(UISwitch *)sw
{
    BOOL isOn = [self.class isBOEOn];
    [[NSUserDefaults standardUserDefaults] setBool:!isOn forKey:BOE_OPEN_KEY];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+(BOOL)isBOEOn
{
    return [[NSUserDefaults standardUserDefaults]boolForKey:BOE_OPEN_KEY];
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

NSString *const BOE_OPEN_KEY = @"BOE_OPEN_KEY";
