//
//  ArticleFetchSettingsManager.m
//  Article
//
//  Created by Zhang Leonardo on 13-5-23.
//
//
#import "TTArticleTabBarController.h"
#import "ArticleFetchSettingsManager.h"
#import "NewsLogicSetting.h"
#import "NewsUserSettingManager.h"
#import "NewsFetchArticleDetailManager.h"
#import "NewsListLogicManager.h"
#import "ExploreListHelper.h"
#import "TTReportManager.h"
#import "SSUpdateListNotifyManager.h"
#import "SSAPNsAlertManager.h"
#import "NewsDetailLogicManager.h"
#import "ArticleJSManager.h"
#import "NewsListLogicManager.h"
#import "ExploreExtenstionDataHelper.h"
#import "ExploreMovieManager.h"
#import "SSMoviePlayerLogConfig.h"
#import "TTAuthorizeManager.h"
#import "WDSettingHelper.h"
#import "ExploreCellHelper.h"
#import "ArticleWebViewToAppStoreManager.h"
#import "TTABHelper.h"
#import "TTUISettingHelper.h"
#import "TTLCSServerConfig.h"
#import "TTTabBarManager.h"
#import "TTTopBarManager.h"
#import "TTWebviewAntiHijackServerConfig.h"
#import "TTPlatformSwitcher.h"
//#import "TTContactsUserDefaults.h"
//#import "TTTelecomLogicSettings.h"
#import "WDCommonLogic.h"
//#import "TTRNBundleManager.h"
#import "TTDeviceHelper.h"
//#import "TTFantasy.h"
#import "TTRNCommonABTest.h"
#import "TTCookieManager.h"
#import "NewsBaseDelegate.h"
#import "TTDebugRealMonitorManager.h"
#import "TTCanvasBundleManager.h"
#import "TTTrackerWrapper.h"
#import <TTUserSettings/TTUserSettingsManager+FontSettings.h>
#import <TTUserSettings/TTUserSettingsManager+NetworkTraffic.h>
#import <TTReachability/TTReachability.h>
#import "TTLoginDialogStrategyManager.h"
#import "TTInfiniteLoopFetchNewsListRefreshTipManager.h"
#import <TTServiceKit/TTServiceCenter.h>
#import "TTAdManagerProtocol.h"
#import "TTFlowStatisticsManager.h"
#import "TTFreeFlowTipManager.h"
//#import "TTContactsGuideManager.h"
#import "TTFeedGuideView.h"
#import "TTBubbleViewManager.h"
#import "TTPushGuideSettings.h"
#import "TTInAppPushSettings.h"
#import "TTAccountTestSettings.h"
#import <AKWebViewBundlePlugin/TTDetailWebviewGIFManager.h>
#import "TTKitchenMgr.h"
#import "TTSettingsManager+SaveSettings.h"
#import <AKWebViewBundlePlugin/TTDetailWebViewContainerConfig.h>
#import <TTRexxar/TTRPackageManager.h>
#import "TTLocalResourceDownloader.h"
#import "TTVSettingsConfiguration.h"
#import "TTAppStoreStarManager.h"
#import "TTAdSplashMediator.h"
#import "TTUGCEmojiParser.h"
//#import "TTSFResourcesManager.h"
//#import "TTToutiaoFantasyManager.h"
#import "TTASettingConfiguration.h"
#import "AKTaskSettingHelper.h"
#define SSFetchSettingsManagerFetchedDateKey @"SSFetchSettingsManagerFetchedDateKey"
#define kFetchTimeInterval (3 * 60 * 60)

@implementation ArticleFetchSettingsManager

- (instancetype)init {
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(applicationWillEnterForeground)
                                                     name:UIApplicationWillEnterForegroundNotification
                                                   object:nil];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)dealDefaultSettingsResult:(NSDictionary *)dSettings
{
    [super dealDefaultSettingsResult:dSettings];
    
    //列表模式
    if ([[dSettings allKeys] containsObject:@"list_mode"]) {
        int defaultValue = [[dSettings objectForKey:@"list_mode"] intValue];
        [self refreshListMode:defaultValue];
    }
    
    //    //列表页刷新
    //    if ([[dSettings allKeys] containsObject:@"refresh_mode"]) {
    //        int defaultValue = [[dSettings objectForKey:@"refresh_mode"] intValue];
    //        [self refreshListRefresh:defaultValue];
    //    }
    
    //图片加载
    if ([[dSettings allKeys] containsObject:@"image_mode"]) {
        int defaultValue = [[dSettings objectForKey:@"image_mode"] intValue];
        [self refreshImageMode:defaultValue];
    }
    
    //字体
    
    if ([[dSettings allKeys] containsObject:@"font_size"]) {
        int defaultValue = [[dSettings objectForKey:@"font_size"] intValue];
        [self refreshFontsize:defaultValue];
    }
}

//字体
- (void)refreshFontsize:(NSUInteger)defaultValue
{
    NSUInteger settedValue = (NSUInteger)[TTUserSettingsManager settingFontSize];
    if ([TTDeviceHelper isPadDevice]) {
        if (settedValue == 2) {
            if (defaultValue == 1) {//小号
                [TTUserSettingsManager setSettingFontSize:0];
            }
            else if(defaultValue == 0) {//中号
                [TTUserSettingsManager setSettingFontSize:1];
            }
            //            else if (defaultValue == 2) {//大号
            //                [TTUserSettingsManager setSettingFontSize:2];
            //            }
            else if (defaultValue == 3) {//特大
                [TTUserSettingsManager setSettingFontSize:3];
            }
        }
    }
    else {
        if (settedValue == 1) {//本地中号字体， 保存为1
            if (defaultValue == 1) {//小号
                [TTUserSettingsManager setSettingFontSize:0];
            }
            else if (defaultValue == 2) {//大号
                [TTUserSettingsManager setSettingFontSize:2];
            }
            else if (defaultValue == 3) {//特大
                [TTUserSettingsManager setSettingFontSize:3];
            }
        }
    }
}

//图片加载
- (void)refreshImageMode:(NSUInteger)defaultValue
{
    int settedValue = [TTUserSettingsManager networkTrafficSetting];
    if (settedValue == TTNetworkTrafficOptimum) {
        if (defaultValue == 1) {
            [TTUserSettingsManager setNetworkTrafficSetting:TTNetworkTrafficMedium];
        }
        else if (defaultValue == 2) {
            [TTUserSettingsManager setNetworkTrafficSetting:TTNetworkTrafficSave];
        }
    }
}

////列表页刷新
//- (void)refreshListRefresh:(NSUInteger)defaultValue
//{
//    int settedValue = [NewsUserSettingManager autoRefreshType];
//    if (settedValue == AutoRefreshOnlyWifi) {
//        if (defaultValue == 1) {
//            [NewsUserSettingManager setAutoRefreshType:AutoRefreshAuto];
//        }
//        else if (defaultValue == 2) {
//            [NewsUserSettingManager setAutoRefreshType:AutoRefreshManually];
//        }
//    }
//}


//列表模式
- (void)refreshListMode:(NSUInteger)defaultValue
{
    if ([TTDeviceHelper isPadDevice]) {
        if ([NewsLogicSetting userSetReadMode] == ReadModeAbstract) {
            if (defaultValue == 0) {
                [NewsLogicSetting setReadMode:ReadModeTitle];
            }
        }
    }
    else {
        if ([NewsLogicSetting userSetReadMode] == ReadModeTitle) {
            if (defaultValue == 1) {
                [NewsLogicSetting setReadMode:ReadModeAbstract];
            }
        }
    }
}

- (void)dealAppSettingResult:(NSDictionary *)dSettings
{
    [super dealAppSettingResult:dSettings];
    
    [[TTSettingsManager sharedManager] saveSettings:dSettings];
    
    [[NSUserDefaults standardUserDefaults] setDouble:[[NSDate date] timeIntervalSince1970] forKey:SSFetchSettingsManagerFetchedDateKey];
    
    NSArray * detailCotentHosts = [dSettings objectForKey:@"article_content_host_list"];
    NSArray * detailFullContentHosts = [dSettings objectForKey:@"article_host_list"];
    
    if ([detailFullContentHosts isKindOfClass:[NSArray class]]) {
        [NewsFetchArticleDetailManager saveArticleDetailURLHosts:detailFullContentHosts isFull:YES];
    }
    
    if ([detailCotentHosts isKindOfClass:[NSArray class]]) {
        [NewsFetchArticleDetailManager saveArticleDetailURLHosts:detailCotentHosts isFull:NO];
    }
    
    NSArray * temaiUrls = [dSettings objectForKey:@"temai_url_list"];
    if ([temaiUrls isKindOfClass:[NSArray class]]) {
        [SSCommonLogic saveTeMaiURLs:temaiUrls];
    }
    
    if ([[dSettings allKeys] containsObject:@"category_refresh_interval"]) {
        NSTimeInterval timeInterval = [[dSettings objectForKey:@"category_refresh_interval"] doubleValue];
        [NewsListLogicManager saveListAutoReloadInterval:timeInterval];
    }
    
    if ([[dSettings allKeys] containsObject:@"tt_ios_platformation_service_switch"]) {
        [[TTPlatformSwitcher sharedInstance] setABConfigDic:[dSettings objectForKey:@"tt_ios_platformation_service_switch"]];
    }
    
    if ([[dSettings allKeys] containsObject:@"category_tip_interval"]) {
        NSTimeInterval timeInterval = [[dSettings objectForKey:@"category_tip_interval"] doubleValue];
        [NewsListLogicManager saveListTipRefreshInterval:timeInterval];
    }
    
    if ([[dSettings allKeys] containsObject:@"category_force_stream_interval"]) {
        NSTimeInterval timeInterval = [[dSettings objectForKey:@"category_force_stream_interval"] doubleValue];
        [NewsListLogicManager saveSwitchToRecommendChannelInterval:timeInterval];
    }
    
    if ([[dSettings allKeys] containsObject:@"category_tip_duration"]) {
        NSTimeInterval timeInterval = [[dSettings objectForKey:@"category_tip_duration"] doubleValue];
        [NewsListLogicManager saveListTipDisplayInterval:timeInterval];
    }
    
    if ([[dSettings allKeys] containsObject:@"preload_count_max"]) {
        NSUInteger count = (NSUInteger)[[dSettings objectForKey:@"preload_count_max"] longLongValue];
        [ExploreListHelper setPreloadCount:count userSettingStatus:TTNetworkTrafficOptimum];
    }
    
    if ([[dSettings allKeys] containsObject:@"preload_count_normal"]) {
        NSUInteger count = (NSUInteger)[[dSettings objectForKey:@"preload_count_normal"] longLongValue];
        [ExploreListHelper setPreloadCount:count userSettingStatus:TTNetworkTrafficMedium];
    }
    
    if ([[dSettings allKeys] containsObject:@"preload_count_min"]) {
        NSUInteger count = (NSUInteger)[[dSettings objectForKey:@"preload_count_min"] longLongValue];
        [ExploreListHelper setPreloadCount:count userSettingStatus:TTNetworkTrafficSave];
    }
    
    if ([[dSettings allKeys] containsObject:@"report_send_html"]) {
        [TTReportManager setNeedPostArticleHTML:[[dSettings objectForKey:@"report_send_html"] boolValue]];
    }
    
    if ([[dSettings allKeys] containsObject:@"report_options"]) {
        [TTReportManager updateReportArticleOptions:[dSettings tt_arrayValueForKey:@"report_options"]];
    }
    
    if ([[dSettings allKeys] containsObject:@"report_ad_options"]) {
        [TTReportManager updateReportADOptions:[dSettings tt_arrayValueForKey:@"report_ad_options"]];
    }
    
    if([[dSettings allKeys] containsObject:@"detail_report_text"] && [[dSettings allKeys] containsObject:@"detail_report_type"])
    {
        [TTReportManager setDetailReport:@{@"text" : dSettings[@"detail_report_text"], @"type" : [NSString stringWithFormat:@"%@", dSettings[@"detail_report_type"]]}];
    }
    
    if ([[dSettings allKeys] containsObject:@"user_report_options"]) {
        [TTReportManager updateReportUserOptions:[dSettings objectForKey:@"user_report_options"]];
    }
    
    if ([[dSettings allKeys] containsObject:@"video_report_options"]) {
        [TTReportManager updateReportVideoOptions:[dSettings objectForKey:@"video_report_options"]];
    }
    
    if ([[dSettings allKeys] containsObject:@"essay_report_options"]) {
        [TTReportManager updateReportEssayOptions:[dSettings objectForKey:@"essay_report_options"]];
    }
    
    if ([[dSettings allKeys] containsObject:@"update_refresh_interval"]) {
        [SSUpdateListNotifyManager saveAutoRefreshUpdateListTimeinterval:[[dSettings objectForKey:@"update_refresh_interval"] doubleValue]];
    }
    
    if ([[dSettings allKeys] containsObject:@"close_active_push_alert"]) {
        [SSAPNsAlertManager setCouldShowActivePushAlert:![[dSettings objectForKey:@"close_active_push_alert"] boolValue]];
    }
    
    if ([[dSettings allKeys] containsObject:@"tt_apns_push_new_alert_style_settings"]) {
        [TTInAppPushSettings parseInAppPushSettings:dSettings];
    }
    
    if ([[dSettings allKeys] containsObject:@"tt_aikan_fe_article_assets"]) {
        NSString *url = [dSettings tt_stringValueForKey:@"tt_aikan_fe_article_assets"];
        [ArticleJSManager downloadAssetsWithUrl:url];
    }
    
    if ([[dSettings allKeys] containsObject:@"tt_local_image_download_setting"]) {
        NSDictionary *download_setting = [dSettings tt_dictionaryValueForKey:@"tt_local_image_download_setting"];
        [TTLocalResourceDownloader setLocalResourceNewVersion:[download_setting tt_intValueForKey:@"version"]];
        //根据不同的分辨率选择性存储2x或者3x图地址
        if ([TTDeviceHelper screenScale] >= 3.0) {
            [TTLocalResourceDownloader setLocalResourceMd5:[download_setting tt_stringValueForKey:@"md5_for_three"]];
            [TTLocalResourceDownloader setLocalResourceDownloadURL:[download_setting tt_stringValueForKey:@"zip_url_for_three"]];
            [TTLocalResourceDownloader setDynamicWebURL:[download_setting tt_stringValueForKey:@"web_url_prefix_for_three"]];
        }
        else {
            [TTLocalResourceDownloader setLocalResourceMd5:[download_setting tt_stringValueForKey:@"md5_for_two"]];
            [TTLocalResourceDownloader setLocalResourceDownloadURL:[download_setting tt_stringValueForKey:@"zip_url_for_two"]];
            [TTLocalResourceDownloader setDynamicWebURL:[download_setting tt_stringValueForKey:@"web_url_prefix_for_two"]];
        }
        [TTLocalResourceDownloader checkAndDownloadIfNeed];
    }
    
    NSDictionary *reactSettings = [dSettings tt_dictionaryValueForKey:@"react_setting"];
    if (reactSettings) {
        NSUInteger profileRNEnabled = [reactSettings tt_intValueForKey:@"profile"];
        [TTRNCommonABTest setRNEnabledOfPage:kTTRNPageEnabledTypeProfile forValue:profileRNEnabled];
        
        if ([[reactSettings allKeys] containsObject:@"version"] &&
            [[reactSettings allKeys] containsObject:@"md5"] &&
            [[reactSettings allKeys] containsObject:@"url"]) {
            NSString *version = [NSString stringWithFormat:@"%@",[reactSettings objectForKey:@"version"]];
            NSString *md5 = [reactSettings objectForKey:@"md5"];
            NSString *url = [reactSettings objectForKey:@"url"];
//            [[TTRNBundleManager sharedManager] updateBundleForModuleName:@"Profile"
//                                                              bundleInfo:^(TTRNBundleInfoBuilder * _Nonnull builder) {
//                                                                  builder.bundleUrl = url;
//                                                                  builder.version = version;
//                                                                  builder.md5 = md5;
//                                                              }
//                                                            updatePolicy:TTRNBundleUseBundleInAppIfVersionLow
//                                                              completion:NULL];
        }
        
        // pgc work library rn entry
        if ([[reactSettings allKeys] containsObject:@"pgcRNParams"]) {
            [[NSUserDefaults standardUserDefaults] setValue:[reactSettings tta_stringForKey:@"pgcRNParams"]
                                                     forKey:kPGCWorkLibraryRNParams];
        } else {
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:kPGCWorkLibraryRNParams];
        }
    }
    
    NSDictionary *canvasRNSettings = [dSettings tt_dictionaryValueForKey:@"ad_react_setting"];
    if (canvasRNSettings) {
        if ([[canvasRNSettings allKeys] containsObject:@"version"] &&
            [[canvasRNSettings allKeys] containsObject:@"md5"] &&
            [[canvasRNSettings allKeys] containsObject:@"url"]) {
            NSString *version = [NSString stringWithFormat:@"%@",[canvasRNSettings objectForKey:@"version"]];
            NSString *md5 = [canvasRNSettings objectForKey:@"md5"];
            NSString *url = [canvasRNSettings objectForKey:@"url"];
            [TTCanvasBundleManager downloadIfNeeded:url version:version md5:md5];
        }
    }
    
    BOOL concernRNEnabled = [dSettings tt_boolValueForKey:@"tt_concern_react_enabled"];
    [TTRNCommonABTest setRNEnabledOfPage:kTTRNPageEnabledTypeConcern forValue:concernRNEnabled];
    
    
    void (^widgetHandle)() = ^{
        NSDictionary *widgetRNWidgetSettings = [dSettings tt_dictionaryValueForKey:@"tt_widget_react_setting"];
        if (widgetRNWidgetSettings) {
            if ([[widgetRNWidgetSettings allKeys] containsObject:@"version"] &&
                [[widgetRNWidgetSettings allKeys] containsObject:@"md5"] &&
                [[widgetRNWidgetSettings allKeys] containsObject:@"url"]) {
                NSString *version = [NSString stringWithFormat:@"%@",[widgetRNWidgetSettings objectForKey:@"version"]];
                NSString *md5 = [widgetRNWidgetSettings objectForKey:@"md5"];
                NSString *url = [widgetRNWidgetSettings objectForKey:@"url"];
                NSString *bitmask = [NSString stringWithFormat:@"%@",[widgetRNWidgetSettings objectForKey:@"bitmask"]];
                NSString *patch_url = nil;
                if ([[widgetRNWidgetSettings allKeys] containsObject:@"patch_url"]) {
                    patch_url = [widgetRNWidgetSettings objectForKey:@"patch_url"];
                }
                NSString *patch_MD5 = nil;
                if ([[widgetRNWidgetSettings allKeys] containsObject:@"patch_md5"]) {
                    patch_MD5 = [widgetRNWidgetSettings objectForKey:@"patch_md5"];
                }
//                [[TTRNBundleManager sharedManager] updateBundleForModuleName:TTRNWidgetBundleName
//                                                                  bundleInfo:^(TTRNBundleInfoBuilder * _Nonnull builder) {
//                                                                      builder.bundleUrl = url;
//                                                                      builder.version = version;
//                                                                      builder.md5 = md5;
//                                                                      builder.bitmask = bitmask;
//                                                                      builder.patchUrl = patch_url;
//                                                                      builder.patchMD5 = patch_MD5;
//                                                                  }
//                                                                updatePolicy:TTRNBundleUseBundleInAppIfVersionLow
//                                                                  completion:NULL];
            }
        }
    };
    
    NSDictionary *commonRNSettings = [dSettings tt_dictionaryValueForKey:@"tt_common_react_setting"];
    if (commonRNSettings) {
        if ([[commonRNSettings allKeys] containsObject:@"version"] &&
            [[commonRNSettings allKeys] containsObject:@"md5"] &&
            [[commonRNSettings allKeys] containsObject:@"url"])
        {
            
            NSString *version = [NSString stringWithFormat:@"%@",[commonRNSettings objectForKey:@"version"]];
            NSString *md5 = [commonRNSettings objectForKey:@"md5"];
            NSString *url = [commonRNSettings objectForKey:@"url"];
//            [[TTRNBundleManager sharedManager] updateBundleForModuleName:TTRNCommonBundleName
//                                                              bundleInfo:^(TTRNBundleInfoBuilder * _Nonnull builder) {
//                                                                  builder.bundleUrl = url;
//                                                                  builder.version = version;
//                                                                  builder.md5 = md5;
//                                                              }
//                                                            updatePolicy:TTRNBundleUpdateDefaultPolicy
//                                                              completion:^(NSURL * _Nullable localBundleURL, BOOL update, NSError * _Nullable error) {
//                                                                  widgetHandle();
//                                                              }];
        }
    }else{
        widgetHandle();
    }
    
    if([dSettings objectForKey:@"update_badge_interval"])
    {
        [SSUpdateListNotifyManager setUpdateBadgeRefreshInterval:[[dSettings objectForKey:@"update_badge_interval"] doubleValue]];
    }
    
    if ([dSettings valueForKey:@"taobao_sdk_disable"]) {
        [SSCommonLogic setDisabledTBUFP:[[dSettings valueForKey:@"taobao_sdk_disable"] boolValue]];
    }
    if ([dSettings valueForKey:@"taobao_sdk_refresh_interval"]) {
        [SSCommonLogic setMinimumTimeInterval:[[dSettings valueForKey:@"taobao_sdk_refresh_interval"] intValue]];
    }
    if ([dSettings valueForKey:@"taobao_sdk_tags"]) {
        [SSCommonLogic setToken:[dSettings valueForKey:@"taobao_sdk_tags"]];
    }
    if ([dSettings valueForKey:@"lbs_sync_interval"]) {
        [SSCommonLogic setMinimumLocationUploadTimeInterval:[dSettings[@"lbs_sync_interval"] doubleValue]];
    }
    
    if ([dSettings valueForKey:@"large_image_dialog_repeat_enabled"]) {
        [SSCommonLogic setEnabledShowAlwaysOriginImageAlertRepeatly:[dSettings[@"large_image_dialog_repeat_enabled"] boolValue]];
    }
    
    if ([dSettings valueForKey:@"lbs_timeout_interval"]) {
        [SSCommonLogic setLocateTimeoutInterval:[dSettings[@"lbs_timeout_interval"] doubleValue]];
    }
    
    if ([dSettings valueForKey:@"lbs_alert_interval"]) {
        [SSCommonLogic setMinimumLocationAlertTimeInterval:[dSettings[@"lbs_alert_interval"] doubleValue]];
    }
    [SSCommonLogic setBaiduMapKey:[dSettings tt_stringValueForKey:@"lbs_baidu_key"]];
    
    [SSCommonLogic setAmapKey:[dSettings tt_stringValueForKey:@"lbs_amap_key"]];
    
    if ([dSettings objectForKey:@"use_dns_mapping"]) {
        [SSCommonLogic setEnabledDNSMapping:[[dSettings valueForKey:@"use_dns_mapping"] integerValue]];
    }
    
    //分享到微信后是用h5打开 还是直接打开app（若未安装打开AppStore）
    BOOL weixinSharedExtendedObjectEnabled = [[dSettings valueForKey:@"shared_extended_object_enabled"] boolValue];
    [SSCommonLogic setWeixinSharedExtendedObjectEnabled:weixinSharedExtendedObjectEnabled];
    
    BOOL ttAlertControllerEnabled = [[dSettings valueForKey:@"ttalertcontroller_enabled"] boolValue];
    [SSCommonLogic setTTAlertControllerEnabled:ttAlertControllerEnabled];
    
    BOOL disabled = [[dSettings valueForKey:@"disable_web_transform"] boolValue];
    [SSCommonLogic setWebContentArticleProtectionTimeoutDisabled:disabled];
    NSTimeInterval webContentTimeoutInterval = [[dSettings valueForKey:@"web_transform_delay_sec_float"] doubleValue];
    [SSCommonLogic setWebContentArticleProtectionTimeoutInterval:webContentTimeoutInterval];
    
    NSString *toolbarPlaceholderString = [dSettings valueForKey:@"write_comment_hint"];
    [SSCommonLogic setExploreDetailToolBarWriteCommentPlaceholderText:toolbarPlaceholderString];
    
    NSArray *taobaoSlotIDs = [dSettings valueForKey:@"slot_ids"];
    [SSCommonLogic setTaobaoSlotIDs:taobaoSlotIDs];
    
    NSArray *jsSafeDomainList = [dSettings valueForKey:@"tt_safe_domain_list"];
    [SSCommonLogic setJsSafeDomainList:jsSafeDomainList];
    
    NSString *jsActLogURLString = [dSettings valueForKey:@"js_actlog_url"];
    [SSCommonLogic setJsActLogURLString:jsActLogURLString];
    
    if ([dSettings objectForKey:@"last_read_refresh"]) {
        BOOL lastReadRefreshEnabled = [[dSettings valueForKey:@"last_read_refresh"] boolValue];
        [SSCommonLogic setLastReadRefreshEnabled:lastReadRefreshEnabled];
    }
    
    if ([dSettings objectForKey:@"last_read_style"]) {
        [SSCommonLogic setLastReadStyle:[dSettings tt_integerValueForKey:@"last_read_style"]];
    }
    
    if ([dSettings objectForKey:@"show_floating_refresh_btn"]) {
        [SSCommonLogic setShowFloatingRefreshBtn:[dSettings tt_boolValueForKey:@"show_floating_refresh_btn"]];
    }
    
    if ([dSettings objectForKey:@"auto_floating_refresh_btn_interval"]) {
        [SSCommonLogic setAutoFloatingRefreshBtnInterval:[dSettings tt_integerValueForKey:@"auto_floating_refresh_btn_interval"]];
    }
    
    if ([dSettings objectForKey:@"tt_enable_feed_show_scene"]) {
        BOOL res = [dSettings tt_boolValueForKey:@"tt_enable_feed_show_scene"];
        [SSCommonLogic setShowWithScensEnabled:res];
    }
    
    if ([dSettings objectForKey:@"tt_enable_article_FLAnimatedImageView"]) {
        BOOL res = [dSettings tt_boolValueForKey:@"tt_enable_article_FLAnimatedImageView"];
        [SSCommonLogic setArticleFLAnimatedImageViewEnabled:res];
    }
    
    
    BOOL reportInWapPageEnabled = [[dSettings valueForKey:@"enable_wap_report"] boolValue];
    [SSCommonLogic setReportInWapPageEnabled:reportInWapPageEnabled];
    
    BOOL essayCommentDetailEnabled = [[dSettings valueForKey:@"essay_comment_detail_enabled"] boolValue];
    [SSCommonLogic setEssayCommentDetailEnabled:essayCommentDetailEnabled];
    
    NSDictionary *ugcCellLineNumber = [dSettings valueForKey:@"feed_text_max_line"];
    [SSCommonLogic setUgcCellLineNumber: ugcCellLineNumber];
    
    if ([dSettings valueForKey:@"use_tab_tip"]) {
        [NewsListLogicManager setTipListUpdateUseTabbar:[[dSettings objectForKey:@"use_tab_tip"] boolValue]];
    }
    
    if ([[dSettings allKeys] containsObject:@"widget_default_no_img_mode"]) {
        [ExploreExtenstionDataHelper saveUserSetNoImgMode:[[dSettings objectForKey:@"widget_default_no_img_mode"] boolValue]];
    }
    
    if ([[dSettings allKeys] containsObject:@"widget_requett_min_interval"]) {
        [ExploreExtenstionDataHelper saveFetchWidgetMinInterval:[[dSettings objectForKey:@"widget_requett_min_interval"] intValue]];
    }
    
    //    key_sell_entry
    if ([dSettings objectForKey:@"key_sell_entry"]) {
        [[self class] setShowMallCellEntry:[dSettings[@"key_sell_entry"] boolValue]];
    }
    
    if([dSettings objectForKey:@"mine_sell_introduce"])
    {
        [ArticleFetchSettingsManager setMineTabSellIntroduce:[dSettings objectForKey:@"mine_sell_introduce"]];
    }
    
    if ([dSettings objectForKey:@"letv_user_key"]) {
        [ExploreMovieManager saveleTVUserKey:[dSettings objectForKey:@"letv_user_key"]];
    }
    
    if ([dSettings objectForKey:@"letv_secret_key"]) {
        [ExploreMovieManager saveLeTVSecretKey:[dSettings objectForKey:@"letv_secret_key"]];
    }
    
    if ([dSettings objectForKey:@"toutiao_video_user_key"]) {
        [ExploreMovieManager saveToutiaoVideoUserKey:[dSettings objectForKey:@"toutiao_video_user_key"]];
    }
    
    if ([dSettings objectForKey:@"toutiao_video_secret_key"]) {
        [ExploreMovieManager saveToutiaoVideoSecretKey:[dSettings objectForKey:@"toutiao_video_secret_key"]];
    }
    
    if ([[dSettings allKeys] containsObject:@"video_statistics_flag"]) {
        long long flag = [[dSettings objectForKey:@"video_statistics_flag"] longLongValue];
        [SSMoviePlayerLogConfig setFetchDNSInfo:((flag & 0x1) > 0)];
        [SSMoviePlayerLogConfig setFetchServerIPFromHead:((flag & 0x4) > 0)];
    }
    
    if ([[dSettings allKeys] containsObject:@"video_play_retry_interval"]) {
        NSInteger retryInterval = [[dSettings objectForKey:@"video_play_retry_interval"] integerValue];
        [ExploreMovieManager saveVideoPlayRetryInterval:retryInterval];
    }
    
    if ([[dSettings allKeys] containsObject:@"video_play_retry_policy"]) {
        NSInteger policy = [[dSettings objectForKey:@"video_play_retry_policy"] integerValue];
        [ExploreMovieManager saveVideoPlayRetryPolicy:policy];
    }
    
    if ([[dSettings allKeys] containsObject:@"video_api_retry_timeout"]) {
        NSInteger timeoutInterval = [[dSettings objectForKey:@"video_api_retry_timeout"] integerValue];
        [ExploreMovieManager saveVideoPlayTimeoutInterval:timeoutInterval];
    }
    
    if ([[dSettings allKeys] containsObject:@"video_retry_load_when_failed"]) {
        BOOL retry = [dSettings tt_boolValueForKey:@"video_retry_load_when_failed"];
        [ExploreMovieManager setRetryLoadWhenFailed:retry];
    }
    
    if ([dSettings objectForKey:@"afnetworking_switch"]) {
        [SSCommonLogic setEnabledAFNetworking:[[dSettings objectForKey:@"afnetworking_switch"] boolValue]];
    }
    
    if ([dSettings objectForKey:@"enable_crash_monitor"]) {
        [SSCommonLogic setEnableCrashMonitor:[[dSettings objectForKey:@"enable_crash_monitor"] boolValue]];
    }
    
    if ([dSettings objectForKey:@"enable_debug_real"]) {
        [SSCommonLogic setEnableDebugRealMonitor:[[dSettings objectForKey:@"enable_debug_real"] boolValue]];
    }
    
    if ([dSettings objectForKey:@"enable_jsonmodel_monitor"]) {
        [SSCommonLogic setEnableJSONModelMonitor:[[dSettings objectForKey:@"enable_jsonmodel_monitor"] boolValue]];
    }
    
    if ([dSettings objectForKey:@"mytab_search_enabled"]) {
        [SSCommonLogic setMineTabSearchEnabled:[[dSettings objectForKey:@"mytab_search_enabled"] boolValue]];
    }
    
    if ([dSettings valueForKey:@"monitor_white_web"]) {
        [SSCommonLogic setEnabledWhitePageMonitor:[[dSettings valueForKey:@"monitor_white_web"] boolValue]];
    }
    
    if ([dSettings valueForKey:@"webview_https_enable"]) {
        [SSCommonLogic setEnableWebViewHttps:[dSettings tt_boolValueForKey:@"webview_https_enable"]];
    }
    
    if ([dSettings valueForKey:@"save_forword_status_enable"]) {
        [SSCommonLogic setSaveForwordStatusEnabled:[dSettings tt_boolValueForKey:@"save_forword_status_enable"]];
    }
    
    [SSCommonLogic setWebviewRedirectReportType:[dSettings tt_integerValueForKey:@"report_html_traffic"]];
    
    if ([[dSettings allKeys] containsObject:@"forum_refresh_interval"]) {
        [SSCommonLogic setForumRefreshTimeInterval:[[dSettings objectForKey:@"forum_refresh_interval"] intValue]];
    }
    if ([dSettings objectForKey:@"ab_version"]) {
        [[TTABHelper sharedInstance_tt] saveABVersion:[dSettings objectForKey:@"ab_version"]];
    }
    
    if ([[dSettings allKeys] containsObject:@"ab_settings"]) {
        [[TTABHelper sharedInstance_tt] saveServerSettings:[dSettings objectForKey:@"ab_settings"]];
    }
    
    if ([dSettings objectForKey:@"iar"]) {
        [SSCommonLogic setIar:[[dSettings objectForKey:@"iar"] boolValue]];
    }
    
    if ([dSettings objectForKey:@"tip_showgesture"]) {
        [SSCommonLogic setShowGestureTip:[[dSettings objectForKey:@"tip_showgesture"] boolValue]];
    }
    
    //账号绑定使用新版本开关
    if ([dSettings objectForKey:@"enable_account_v2"]) {
        [SSCommonLogic setAccountABVersionEnabled:[[dSettings objectForKey:@"enable_account_v2"] boolValue]];
    }
    
    // 账号相关开关
    [TTAccountTestSettings parseAccountConfFromSettings:dSettings];
    
    //WKWebview开关
    if ([dSettings objectForKey:@"wkwebview_enable"]) {
        [SSCommonLogic setWKWebViewEnabledEnabled:[[dSettings objectForKey:@"wkwebview_enable"] boolValue]];
    }
    
//    /**
//     *  老用户上传通讯录弹窗【deprecated from 电信取号二期】
//     *  0: 关闭 1:开启
//     *
//     *  新的配置统一控制新用户和老用户
//     */
//    [TTContactsUserDefaults parseContactConfigsFromSettings:dSettings];
//
//    // 解析通讯录红包配置参数
//    [TTContactsUserDefaults parseContactRedPacketConfigurationsFromSettings:dSettings];
    
    //频道引导滑动出现次数
    if ([dSettings valueForKey:@"category_slide_count"]) {
        [SSCommonLogic setCagetoryGuideCount:[[dSettings valueForKey:@"category_slide_count"] intValue]];
    }
    
    if ([dSettings objectForKey:@"tt_aikan_login_conf"]) {
        NSDictionary *login_conf = [dSettings objectForKey:@"tt_aikan_login_conf"];
        [SSCommonLogic setDialogTitles:[login_conf tt_dictionaryValueForKey:@"dialog_title"]];
        [SSCommonLogic setLoginAlertTitles:[login_conf tt_dictionaryValueForKey:@"quick_dialog_title"]];
        [SSCommonLogic setQuickRegisterPageTitle:[login_conf tt_stringValueForKey:@"register_page_title"]];
        [SSCommonLogic setQuickRegisterButtonText:[login_conf tt_stringValueForKey:@"register_button_text"]];
        [SSCommonLogic setLoginEntryList:[login_conf tt_arrayValueForKey:@"login_entry_list"]];
    }
    
//    if ([dSettings objectForKey:@"login_page_title"]) {
//        NSDictionary *titles = [dSettings tt_dictionaryValueForKey:@"login_page_title"];
//        [SSCommonLogic setDialogTitles:[titles tt_dictionaryValueForKey:@"dialog_title"]];
//        [SSCommonLogic setLoginAlertTitles:[titles tt_dictionaryValueForKey:@"quick_dialog_title"]];
//    }
    
    if([dSettings objectForKey:@"tt_boot_login_dialog_strategy"]) {
        
        [SSCommonLogic setAppBootEnable:[dSettings tt_boolValueForKey:@"tt_boot_login_dialog_strategy"]];
    }
    
    if([dSettings objectForKey:@"tt_dislike_login_dialog_strategy"]) {
        [SSCommonLogic setDislikeEnable:[dSettings tt_boolValueForKey:@"tt_dislike_login_dialog_strategy"]];
    }
    
    
    // 订阅弹出快捷登录小弹窗
    if ([dSettings objectForKey:@"login_dialog_strategy"]) {
        NSDictionary *login_dialog_strategy = [dSettings tt_dictionaryValueForKey:@"login_dialog_strategy"];
        [[TTLoginDialogStrategyManager sharedInstance] setLoginDialogData:login_dialog_strategy];
        NSDictionary *pgc_like = [login_dialog_strategy tt_dictionaryValueForKey:@"pgc_like"];
        NSDictionary *pgc_like_detail = [pgc_like tt_dictionaryValueForKey:@"detail"];
        // 将pgc_like_detail的action_type的值进行保存
        [SSCommonLogic setDetailActionType:[pgc_like_detail tt_integerValueForKey:@"action_type"]];
        // 将pgc_like_detail的action_tick的值进行保存
        [SSCommonLogic setDetailActionTick:[pgc_like_detail tt_arrayValueForKey:@"action_tick"]];
        
        NSDictionary *article_favor = [login_dialog_strategy tt_dictionaryValueForKey:@"favor"];
        NSDictionary *article_favor_detail = [article_favor tt_dictionaryValueForKey:@"detail"];
        // 将article_favor_detail的action_type的值进行保存
        [SSCommonLogic setFavorDetailActionType:[article_favor_detail tt_integerValueForKey:@"action_type"]];
        // 将article_favor_detail的action_tick的值进行保存
        [SSCommonLogic setFavorDetailActionTick:[article_favor_detail tt_arrayValueForKey:@"action_tick"]];
        // 将article_favor_detail的dialog_order（仅用于控制非强制登录弹窗的时机）的值进行保存
        [SSCommonLogic setFavorDetailDialogOrder:[article_favor_detail tt_integerValueForKey:@"dialog_order"]];
        
    }
    
    if([dSettings objectForKey:@"tt_free_flow_settings"]) {
        [[TTFlowStatisticsManager sharedInstance] setFlowStatisticsOptions:[dSettings objectForKey:@"tt_free_flow_settings"]];
        [[TTFlowStatisticsManager sharedInstance] registerMonitorFlowChangeWithCompletion:^(BOOL isRegister) {
            [[TTFreeFlowTipManager sharedInstance] showHomeFlowAlert]; //流量弹窗
        }];
    }
    
    if([dSettings objectForKey:@"tt_commonweal_settings"]) {
        [SSCommonLogic setCommonwealInfo:[dSettings objectForKey:@"tt_commonweal_settings"]];
    }
    
    if ([dSettings valueForKey:@"login_guide_page_strategy"]) {
        NSDictionary *pushHistoryDict = [[dSettings tt_dictionaryValueForKey:@"login_guide_page_strategy"] tt_dictionaryValueForKey:@"push_history"];
        NSNumber *pushHistoryEnable = [pushHistoryDict tt_objectForKey:@"page_type"];
        [[TTLoginDialogStrategyManager sharedInstance] setPushHistoryEnable:pushHistoryEnable];
        
        NSDictionary *myFavorDict = [[dSettings tt_dictionaryValueForKey:@"login_guide_page_strategy"] tt_dictionaryValueForKey:@"my_favor"];
        NSNumber *myFavorEnable = [myFavorDict tt_objectForKey:@"page_type"];
        [[TTLoginDialogStrategyManager sharedInstance] setMyFavorEnable:myFavorEnable];
    }
    
    if ([dSettings valueForKey:@"enable_sdwebimage_monitor"]) {
        [SSCommonLogic setEnableSdWebImageMonitor:[[dSettings valueForKey:@"enable_sdwebimage_monitor"] boolValue]];
    }
    
    //    if ([dSettings valueForKey:@"use_encrypt_applog"]) {
    //        [SSCommonLogic setUseEncrypt:[[dSettings valueForKey:@"use_encrypt_applog"] boolValue]];
    //    }
    /*
     权限提醒间隔时间相关设置
     contact_dlg_show_max_add ：添加好友弹通讯录权限次数
     contact_dlg_show_max_update：动态页弹通讯录权限次数
     contact_dlg_show_max_follow：关注后弹通讯录权限次数
     contact_dlg_show_interval：通讯录弹窗间隔天数
     login_dlg_show_max_favor：收藏弹登录引导次数
     login_dlg_show_max_coment：看评论弹登录引导次数
     login_dlg_show_interval：登录引导弹出间隔天数
     location_dlg_show_max：定位权限弹窗次数
     location_dlg_show_interval：定位权限弹窗间隔天数
     push_dlg_show_max：推送开关引导次数
     push_dlg_show_interval：推送开关弹窗间隔天数
     per_dlg_show_interval：任何类型的权限弹窗间隔天数
     */
    if ([dSettings objectForKey:@"contact_dlg_show_max_add"]) {
        NSInteger maxTimes = [[dSettings objectForKey:@"contact_dlg_show_max_add"] integerValue];
        [TTAuthorizeManager sharedManager].authorizeModel.showAddressBookMaxTimesAddFriendPage = maxTimes;
    }
    if ([dSettings objectForKey:@"contact_dlg_show_max_update"]) {
        NSInteger maxTimes = [[dSettings objectForKey:@"contact_dlg_show_max_update"] integerValue];
        [TTAuthorizeManager sharedManager].authorizeModel.showAddressBookMaxTimesMomentPage = maxTimes;
    }
    if ([dSettings objectForKey:@"contact_dlg_show_max_follow"]) {
        NSInteger maxTimes = [[dSettings objectForKey:@"contact_dlg_show_max_follow"] integerValue];
        [TTAuthorizeManager sharedManager].authorizeModel.showAddressBookMaxTimesAddFriendAction = maxTimes;
    }
    if ([dSettings objectForKey:@"contact_dlg_show_interval"]) {
        NSInteger interval = [[dSettings objectForKey:@"contact_dlg_show_interval"] integerValue];
        [TTAuthorizeManager sharedManager].authorizeModel.showAddressBookTimeInterval = interval;
    }
    if ([dSettings objectForKey:@"login_dlg_show_max_favor"]) {
        NSInteger maxTimes = [[dSettings objectForKey:@"login_dlg_show_max_favor"] integerValue];
        [TTAuthorizeManager sharedManager].authorizeModel.showLoginMaxTimesDetailFavorite = maxTimes;
    }
    if ([dSettings objectForKey:@"login_dlg_show_max_coment"]) {
        NSInteger maxTimes = [[dSettings objectForKey:@"login_dlg_show_max_coment"] integerValue];
        [TTAuthorizeManager sharedManager].authorizeModel.showLoginMaxTimesDetailComment = maxTimes;
    }
    if ([dSettings objectForKey:@"login_dlg_show_interval"]) {
        NSInteger interval = [[dSettings objectForKey:@"login_dlg_show_interval"] integerValue];
        [TTAuthorizeManager sharedManager].authorizeModel.showLoginTimeInterval = interval;
    }
    if ([dSettings objectForKey:@"location_dlg_show_max"]) {
        NSInteger maxTimes = [[dSettings objectForKey:@"location_dlg_show_max"] integerValue];
        [TTAuthorizeManager sharedManager].authorizeModel.showLocationMaxTimesLocalCategory = maxTimes;
    }
    if ([dSettings objectForKey:@"location_dlg_show_interval"]) {
        NSInteger interval = [[dSettings objectForKey:@"location_dlg_show_interval"] integerValue];
        [TTAuthorizeManager sharedManager].authorizeModel.showLocationTimeInterval = interval;
    }
    if ([dSettings objectForKey:@"push_dlg_show_max"]) {
        NSInteger maxTimes = [[dSettings objectForKey:@"push_dlg_show_max"] integerValue];
        [TTAuthorizeManager sharedManager].authorizeModel.showPushMaxTimes = maxTimes;
    }
    if ([dSettings objectForKey:@"push_dlg_show_interval"]) {
        NSInteger interval = [[dSettings objectForKey:@"push_dlg_show_interval"] integerValue];
        [TTAuthorizeManager sharedManager].authorizeModel.showPushTimeInterval = interval;
    }
    if ([dSettings objectForKey:@"per_dlg_show_interval"]) {
        NSInteger interval = [[dSettings objectForKey:@"per_dlg_show_interval"] integerValue];
        [TTAuthorizeManager sharedManager].authorizeModel.showAlertInterval = interval;
    }
    
    if ([dSettings objectForKey:@"tt_package_app_config"]) {
        NSArray *configs = [dSettings tt_arrayValueForKey:@"tt_package_app_config"];
        NSArray<TTRPackageModel *> *models = [TTRPackageModel arrayModelsFromArrayDictionaries:configs];
        [[TTRPackageManager sharedManager] syncPackages:models];
        [TTRPackageManager sharedManager].enable = models.count > 0;
    }
    // 解析通知权限引导弹窗
    [TTPushGuideSettings parsePushGuideConfigFromSettings:dSettings];
    
    // 是否显示刷新按钮设置项
    if ([dSettings objectForKey:@"refresh_button_setting_enabled"]) {
        [SSCommonLogic setRefreshButtonSettingEnabled:[[dSettings objectForKey:@"refresh_button_setting_enabled"] boolValue]];
        [[NSNotificationCenter defaultCenter] postNotificationName:kFeedRefreshButtonSettingEnabledNotification object:nil];
    }
    
    // 控制开机授权界面的显示时机
    if ([dSettings objectForKey:@"launch_show_count"]) {
        
        if (![[NSUserDefaults standardUserDefaults] boolForKey:kHasShownIntroductionKey]) {
            if (![[NSUserDefaults standardUserDefaults] valueForKey:SSCommonLogicLaunchedTimes4ShowIntroductionViewKey]) {
                [SSCommonLogic setLaunchedTimes4ShowIntroductionView:[[dSettings objectForKey:@"launch_show_count"] integerValue]];
                [TTSandBoxHelper resetAppLaunchedTimes];
            }
        }
        
        /*
         [SSCommonLogic setLaunchedTimes4ShowIntroductionView:[[dSettings objectForKey:@"launch_show_count"] integerValue]];
         [TTDeviceHelper resetAppLaunchedTimes];
         */
    }
    
    ///...
    // 下拉刷新广告位是否显示
    if ([dSettings objectForKey:@"refresh_ad_disable"]) {
        [SSCommonLogic setFeedRefreshADDisable:[[dSettings objectForKey:@"refresh_ad_disable"] boolValue]];
    }
    // 下拉刷新广告资源请求间隔
    if ([dSettings objectForKey:@"refresh_ad_expire_sec"]) {
        [SSCommonLogic setFeedRefreshADExpireInterval:[[dSettings objectForKey:@"refresh_ad_expire_sec"] doubleValue]];
    }
    
    if ([dSettings objectForKey:@"ad_refresh_disable"]) {
        [SSCommonLogic setAdResPreloadEnable:[[dSettings objectForKey:@"ad_refresh_disable"] boolValue]];
    }
    
    if ([dSettings objectForKey:@"tt_ad_new_refresh_disable"]) {
        [SSCommonLogic setRefreshADDisable:[[dSettings objectForKey:@"tt_ad_new_refresh_disable"] boolValue]];
    }
    
    //图集广告重构开关
    if ([dSettings objectForKey:@"tt_refector_adphotoalbum_enable"]) {
        [SSCommonLogic setRefacorPhotoAlbumControlAble:[[dSettings objectForKey:@"tt_refector_adphotoalbum_enable"] boolValue]];
    }
    
    // 新浪微博分享过期提醒间隔时间
    if ([[dSettings allKeys] containsObject:@"notify_platform_expired_period"]) {
        NSNumber *seconds = [NSNumber numberWithLongLong:([[dSettings valueForKey:@"notify_platform_expired_period"] intValue] * 24 * 3600)];
        [[NSUserDefaults standardUserDefaults] setValue:seconds forKey:@"weiboExpiredShowInterval"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    
    [[TTAuthorizeManager sharedManager].authorizeModel saveData];
    
    // 视频出顶踩全局控制
    if ([dSettings objectForKey:@"show_list_digg"]) {
        [ExploreCellHelper setShowListDig:[[dSettings objectForKey:@"show_list_digg"] intValue]];
    }
    
    // 视频tab 气泡tip控制
    if ([dSettings objectForKey:@"enable_video_tab_bubble"]) {
        [SSCommonLogic setVideoTipServerEnabled:[[dSettings objectForKey:@"enable_video_tab_bubble"] boolValue]];
    }
    
    if ([dSettings objectForKey:@"video_tab_bubble_interval"]) {
        [SSCommonLogic setVideoTipServerInterval:[[dSettings objectForKey:@"video_tab_bubble_interval"] doubleValue]];
    }
    
    if ([dSettings objectForKey:@"video_redspot_flag"]) {
        [SSCommonLogic setVideoTabSpotServerEnabled:[[dSettings objectForKey:@"video_redspot_flag"] boolValue]];
    }
    
    if ([dSettings objectForKey:@"video_redspot_version"]) {
        BOOL shouldShowVideoSpot = [SSCommonLogic shouldShowVideoTabSpotForVersion:[[dSettings objectForKey:@"video_redspot_version"] integerValue]];
        if (shouldShowVideoSpot) {
            NSNotification *noti = [NSNotification notificationWithName:kChangeExploreTabBarBadgeNumberNotification object:nil userInfo:@{kExploreTabBarItemIndentifierKey:kTTTabVideoTabKey, kExploreTabBarDisplayRedPointKey:@(YES)}];
            [[NSNotificationQueue defaultQueue] enqueueNotification:noti postingStyle:NSPostWhenIdle];
        }
    }
    
//    if ([dSettings objectForKey:@"register_page_title"]) {
//        [SSCommonLogic setQuickRegisterPageTitle:[dSettings tt_stringValueForKey:@"register_page_title"]];
//    }
//    
//    if ([dSettings objectForKey:@"register_button_text"]) {
//        [SSCommonLogic setQuickRegisterButtonText:[dSettings tt_stringValueForKey:@"register_button_text"]];
//    }
    
    //    5.7版本注释掉 大弹窗直接进入账户密码页面，不受服务端控制
    //    if ([dSettings objectForKey:@"quick_login"]) {
    //        [SSCommonLogic setQuickLoginSwitch:[dSettings tt_boolValueForKey:@"quick_login"]];
    //    }
    
    // 搜索框提示语
    if ([dSettings objectForKey:@"top_search_bar_tips_style"]) {
        [SSCommonLogic setSearchBarTipForNormal:[dSettings tt_stringValueForKey:@"top_search_bar_tips_style"]];
    }
    
    // 详情页顶部搜索
    if ([dSettings objectForKey:@"detail_search_tab_style"]) {
        [SSCommonLogic enableSearchInDetailNavBar:[dSettings tt_intValueForKey:@"detail_search_tab_style"]];
    }
    
    if ([dSettings objectForKey:@"is_web_view_common_query_enable"]) {
        [SSCommonLogic enableWebViewQueryString:[dSettings tt_boolValueForKey:@"is_web_view_common_query_enable"]];
    }
    
    if ([dSettings objectForKey:@"web_view_common_query_host_list"]) {
        [SSCommonLogic setWebViewQueryEnableHostList:[dSettings arrayValueForKey:@"web_view_common_query_host_list" defaultValue:nil]];
    }
    
    // 关注TAB Tips提醒，如果没有或为空则不显示
    if ([dSettings objectForKey:@"follow_tab_tips"]) {
        NSString *tips = [dSettings tt_stringValueForKey:@"follow_tab_tips"];
        if (!isEmptyString(tips)) {
            [SSCommonLogic setFollowTabTipsEnable:YES];
            [SSCommonLogic setFollowTabTipsString:tips];
        }
        else {
            [SSCommonLogic setFollowTabTipsEnable:NO];
        }
    }
    else{
        [SSCommonLogic setFollowTabTipsEnable:NO];
    }
    
    // 是否预加载关注页面     0不预加载，1预加载
    if ([dSettings objectForKey:@"is_follow_preload"]) {
        [SSCommonLogic setPreloadFollowEnable:[dSettings tt_boolValueForKey:@"is_follow_preload"]];
    }
    
    [WDSettingHelper saveWendaAppInfoDict:[dSettings objectForKey:@"wenda_settings"]];
        
    //列表页UI设置
    [TTUISettingHelper saveCellViewUISettingInfoDict:[dSettings objectForKey:@"list_ui_option"]];
    //详情页UI设置
    [TTUISettingHelper saveDetailViewUISettingInfoDict:[dSettings objectForKey:@"detail_ui_option"]];
    //频道导航UI设置
    [TTUISettingHelper saveCategoryViewUISettingInfoDict:[dSettings objectForKey:@"category_ui_option"]];
    //tabbarUI设置
    [TTUISettingHelper saveTabBarViewUISettingInfoDict:[dSettings objectForKey:@"tab_ui_option"]];
    
    [[ArticleWebViewToAppStoreManager sharedManager] refreshWithSettingsDict:dSettings];
    
    if ([dSettings objectForKey:@"new_detail_style"]) {
        [SSCommonLogic setPGCAuthorSelfRecommendAllowed:[dSettings tt_boolValueForKey:@"new_detail_style"]];
    }
    
    if ([dSettings objectForKey:@"is_recommend_self_allowed"]) {
        [SSCommonLogic setPGCAuthorSelfRecommendAllowed:[dSettings tt_boolValueForKey:@"is_recommend_self_allowed"]];
    }
    
    if ([dSettings objectForKey:@"home_page_ui_config"]) {
        NSDictionary *homepageSettings = [dSettings tt_dictionaryValueForKey:@"home_page_ui_config"];
        //是否同时生效
        if([homepageSettings objectForKey:@"is_single_valid"]) {
            [SSCommonLogic setHomepageUIConfigSimultaneouslyValid:![homepageSettings tt_boolValueForKey:@"is_single_valid"]];
        } else {
            [SSCommonLogic removeHomepageUIConfigSimultaneousKey];
        }
//        //tabBar文案
//        if ([homepageSettings objectForKey:@"tab_config"]) {
//            [[TTTabBarManager sharedTTTabBarManager] setTabBarSettingsDict:[homepageSettings tt_dictionaryValueForKey:@"tab_config"]];
//        }
        //topBar自定义图片配置
        if ([homepageSettings objectForKey:@"top_bar_config"]) {
            [[TTTopBarManager sharedInstance_tt] setTopBarSettingsDict:[homepageSettings tt_dictionaryValueForKey:@"top_bar_config"]];
        }
    }
    
    if ([dSettings objectForKey:@"is_detail_quick_exit"]) {
        [SSCommonLogic setDetailQuickExitEnabled:[dSettings tt_boolValueForKey:@"is_detail_quick_exit"]];
    }
    
    // [[TTLCSServerConfig sharedTTLCSServerConfig] updateEnabledFlag:dSettings];
    [[TTLCSServerConfig sharedInstance] resetServerConfigEnabled:[dSettings tt_boolValueForKey:kTTLCSServerConfigEnabledKey]];
    
    [[TTWebviewAntiHijackServerConfig sharedTTWebviewAntiHijackServerConfig] updateServerConfig:dSettings];
    
    if ([dSettings objectForKey:@"detail_speedup_enable"]) {
        [SSCommonLogic setDetailSharedWebViewEnabled:[dSettings tt_boolValueForKey:@"detail_speedup_enable"]];
    }
    
    if ([dSettings objectForKey:@"tt_detail_layout_optimize"]) {
        [SSCommonLogic setDetailNewLayoutEnabled:[dSettings tt_boolValueForKey:@"tt_detail_layout_optimize"]];
    }
    
    if ([dSettings objectForKey:@"tt_cdn_block_enable"]) {
        [SSCommonLogic setCDNBlockEnabled:[dSettings tt_boolValueForKey:@"tt_cdn_block_enable"]];
    }
    
    if ([dSettings objectForKey:@"tt_user_interactive_action_guide_enable"]) {
        [SSCommonLogic setToolbarLabelEnabled:[dSettings tt_boolValueForKey:@"tt_user_interactive_action_guide_enable"]];
    }
    
    if ([dSettings objectForKey:@"tt_share_icon_type"]) {
        [SSCommonLogic setShareIconStyle:[dSettings tt_integerValueForKey:@"tt_share_icon_type"]];
    }
    
    if ([dSettings objectForKey:@"new_natant_style"]) {
        BOOL res = [dSettings tt_boolValueForKey:@"new_natant_style"];
        [SSCommonLogic setNewNatantStyleEnabled:res];
    }
    
    [SSCommonLogic setNewNatantStyleInADEnabled:[dSettings tt_boolValueForKey:@"ad_detail_natant_style"]];
    
    [SSCommonLogic setDetailWKEnabled:[dSettings tt_boolValueForKey:@"detail_wk_enable"]];
    
    if ([dSettings objectForKey:@"channel_control_conf"]) {
        NSDictionary *conf = [dSettings tt_dictionaryValueForKey:@"channel_control_conf"];
        [SSCommonLogic setChannelControlDict:conf];
    }
    
    if ([dSettings objectForKey:@"image_display_mode"]) {
        int imageMode = [dSettings tt_intValueForKey:@"image_display_mode"];
        TTNetworkTrafficSetting settingType = imageMode == 0 ? TTNetworkTrafficOptimum : (imageMode == 1 ? TTNetworkTrafficMedium : TTNetworkTrafficSave);
        [TTUserSettingsManager setNetworkTrafficSetting:settingType];
    }
    
    if ([dSettings objectForKey:@"3g_image_display_mode"]) {
        [SSCommonLogic setImageDisplayModeFor3GIsSameAs2GEnable:[dSettings tt_boolValueForKey:@"3g_image_display_mode"]];
    }
    
    //阅读位置默认开启
    [SSCommonLogic setArticleReadPositionEnable:!![dSettings integerValueForKey:@"article_read_position_enable" defaultValue:1]];
    if ([dSettings objectForKey:@"albb_link_enable"]) {
        [SSCommonLogic setTBSDKEnable:[dSettings tt_boolValueForKey:@"albb_link_enable"]];
    }
    
    if ([dSettings objectForKey:@"jd_kepler_enable"]) {
        [SSCommonLogic setKeplerEnable:[dSettings tt_boolValueForKey:@"jd_kepler_enable"]];
    }
    
    // 电信取号下发设置开关
//    [TTTelecomLogicSettings parseGettingPhoneConfigsFromSettings:dSettings];
    
    
    // 由服务端下发登录入口
//    NSArray *loginEntries = [dSettings objectForKey:@"login_entry_list"];
//    [SSCommonLogic setLoginEntryList:loginEntries];
    
    if ([dSettings objectForKey:@"poster_ad_click_enabled"]) {
        [SSCommonLogic setPosterADClickEnabled:[dSettings tt_boolValueForKey:@"poster_ad_click_enabled"]];
    }
    
    if ([dSettings objectForKey:@"should_optimize_launch"]) {
        [SSCommonLogic setShouldUseOptimisedLaunch:[[dSettings objectForKey:@"should_optimize_launch"] boolValue]];
    }
    //是否用重构后的导航栏
    if([dSettings objectForKey:@"refactor_navi_enable"]) {
        [SSCommonLogic setRefactorNaviEnabled:[dSettings tt_boolValueForKey:@"refactor_navi_enable"]];
    }
    if ([dSettings objectForKey:@"should_use_albbservice"]) {
        [SSCommonLogic setShouldUseALBBService:[[dSettings objectForKey:@"should_use_albbservice"] boolValue]];
    }
    
    if ([dSettings valueForKey:@"max_url_cache_capacity"]) {
        [SSCommonLogic setMaxNSUrlCache:[[dSettings valueForKey:@"max_url_cache_capacity"] floatValue]];
    }
    
    //新用户第一次启动刷新tip提示，默认10秒
    if (![dSettings objectForKey:@"first_refresh_tips"] || [dSettings tt_boolValueForKey:@"first_refresh_tips"])
    {
        if (![ExploreLogicSetting isUpgradeUser] && ![[NSUserDefaults standardUserDefaults] objectForKey:@"first_refresh_tips_done"]) {
            [[NSUserDefaults standardUserDefaults] setObject:@YES forKey:@"first_refresh_tips_done"];
            
            double delay = (![dSettings objectForKey:@"first_refresh_tips"] ? 10 : [dSettings doubleValueForKey:@"first_refresh_tips_interval" defaultValue:10]);
            
            NSDictionary *userInfo = @{@"delaySceonds":@(delay)};
            TTAdSplashMediator *mediator = [TTAdSplashMediator shareInstance];
            if (mediator.adWillShow && [SSCommonLogic shouldUseOptimisedLaunch]) {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.65 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [[NSNotificationCenter defaultCenter] postNotificationName:kFirstRefreshTipsSettingEnabledNotification object:nil userInfo:userInfo];
                });
            }else{
                [[NSNotificationCenter defaultCenter] postNotificationName:kFirstRefreshTipsSettingEnabledNotification object:nil userInfo:userInfo];
            }
        }
    }
    
    //iOS10适配采用新的impression统计开关
    if ([dSettings objectForKey:@"new_feed_impression"]) {
        [SSCommonLogic setNewFeedImpressionEnabled:[dSettings tt_boolValueForKey:@"new_feed_impression"]];
    }
    
    if ([dSettings objectForKey:@"tt_article_api_cdn_version"]) {
        [SSCommonLogic setDetailCDNVersion:[dSettings tt_integerValueForKey:@"tt_article_api_cdn_version"]];
    }
    
    //是否使用严格的详情页类型区分
    if ([dSettings objectForKey:@"strict_detail_judgement"]) {
        [SSCommonLogic setStrictDetailJudgementEnabled:[dSettings tt_boolValueForKey:@"strict_detail_judgement"]];
    }
    
    if ([dSettings objectForKey:@"disable_search_optimize"]) {
        [SSCommonLogic disableSearchOptimize:[dSettings tt_boolValueForKey:@"disable_search_optimize"]];
    }
    
    //头条号强化
    if ([dSettings objectForKey:@"h5_settings"]) {
        [SSCommonLogic setH5SettingsForAuthor:[dSettings tt_dictionaryValueForKey:@"h5_settings"]];
    }
    
    //是否使用严格的详情页类型区分
    if ([dSettings objectForKey:@"strict_detail_judgement"]) {
        [SSCommonLogic setStrictDetailJudgementEnabled:[dSettings tt_boolValueForKey:@"strict_detail_judgement"]];
        
        if ([dSettings objectForKey:@"disable_search_optimize"]) {
            [SSCommonLogic disableSearchOptimize:[dSettings tt_boolValueForKey:@"disable_search_optimize"]];
        }
        
    }
    //8,9,10系统打开
    if ([dSettings objectForKey:@"video_own_player"]) {
        [SSCommonLogic setVideoOwnPlayerEnabled:[dSettings tt_boolValueForKey:@"video_own_player"]];
    }
    
    //第三个tab是否开放小流量实验
    if ([dSettings objectForKey:@"third_tab_switch"]) {
        [SSCommonLogic setThirdTabWeitoutiaoEnabled:[dSettings tt_boolValueForKey:@"third_tab_switch"]];
    }
    
    [KitchenMgr parseSettings:dSettings];
    
    //头条认证展现配置
    if ([dSettings valueForKey:@"user_verify_info_conf"]) {
        [SSCommonLogic setUserVerifyConfigs:[dSettings tt_dictionaryValueForKey:@"user_verify_info_conf"]];
    }
    
    //微头条tab列表更新tips展示类型
    if ([dSettings objectForKey:@"toutiaoquan_tab_tips"]) {
        NSNumber * type = [dSettings objectForKey:@"toutiaoquan_tab_tips"];
        if ([type isKindOfClass:[NSNumber class]]) {
            [SSCommonLogic setWeitoutiaoTabListUpdateTipType:type.unsignedIntegerValue];
        }
    }
    
    if ([dSettings objectForKey:@"ugc_user_medal"]) {
        [WDCommonLogic setUGCMedalsWithDictionay:[dSettings tt_dictionaryValueForKey:@"ugc_user_medal"]];
    }
    
    if ([dSettings objectForKey:@"tt_follow_button_template"]) {
        [SSCommonLogic setFollowButtonColorTemplate:[dSettings tt_dictionaryValueForKey:@"tt_follow_button_template"]];
    }
    
    //转发源内容状态文案
    if ([dSettings valueForKey:@"repost_review_hint"]) {
        [SSCommonLogic setRepostOriginalReviewHint:[dSettings tt_stringValueForKey:@"repost_review_hint"]];
    }
    
    //是否收集用户的diskSpace等数据
    if ([dSettings objectForKey:@"collect_free_space"]) {
        [SSCommonLogic setCollectDiskSpaceEnable:[dSettings tt_boolValueForKey:@"collect_free_space"]];
    }
    
    if ([dSettings objectForKey:@"live_use_own_player"]) {
        [SSCommonLogic setLiveUseOwnPlayerEnabled:[dSettings tt_boolValueForKey:@"live_use_own_player"]];
    }
    
    if ([dSettings objectForKey:@"enable_search_initial_page_wap"]) {
        [SSCommonLogic enableSearchInitialPageWap:[dSettings tt_boolValueForKey:@"enable_search_initial_page_wap"]];
    }
    
    if ([dSettings valueForKey:@"tt_upload_debugreal"]) {
        id value = [dSettings valueForKey:@"tt_upload_debugreal"];
        if ([value isKindOfClass:[NSDictionary class]]) {
            [TTDebugRealMonitorManager sendOldDebugRealDataWithConfigs:[dSettings valueForKey:@"tt_upload_debugreal"]];
        }
        [[TTMonitor shareManager] trackService:@"upload_debugreal_data" status:1 extra:nil];
    }
    
    if ([SSCommonLogic enableDebugRealMonitor]) {
        [TTDebugRealMonitorManager cacheAppSettings:dSettings];
    }
    
    if ([dSettings objectForKey:@"applog_v1_to_v3_switch"]) {
        [SSCommonLogic setV3LogFormatEnabled:![dSettings tt_boolValueForKey:@"applog_v1_to_v3_switch"]];//0生效 大于0不生效
    }
    
    if ([dSettings objectForKey:@"refactor_get_domains"]) {
        [SSCommonLogic setRefactorGetDomainsEnabled:[dSettings tt_boolValueForKey:@"refactor_get_domains"]];
    }
    
    if ([dSettings valueForKey:@"stop_monitor_service"]){
        [TTMonitor shareManager].stopMonitor = [dSettings tt_boolValueForKey:@"stop_monitor_service"];
    }
    
    // 缓存目录大小上报
    if ([dSettings objectForKey:@"is_splash_first_refresh_enabled"]) {
        [SSCommonLogic setFirstSplashEnable:[dSettings tt_boolValueForKey:@"is_splash_first_refresh_enabled"]];
    }
    
    if ([dSettings objectForKey:@"tt_ad_landing_page_config"]) {
        NSDictionary *dict = [dSettings tt_dictionaryValueForKey:@"tt_ad_landing_page_config"];
        if ([dict objectForKey:@"tt_ad_landing_page_auto_jump_control_enabled"]) {
            [SSCommonLogic setShouldAutoJumpControlEnabled:[dict tt_boolValueForKey:@"tt_ad_landing_page_auto_jump_control_enabled"]];
        }
        if ([dict objectForKey:@"tt_ad_landing_page_auto_jump_allow_list"]) {
            [SSCommonLogic setWhiteListForAutoJump:[dict tt_arrayValueForKey:@"tt_ad_landing_page_auto_jump_allow_list"]];
        }
        if ([dict objectForKey:@"tt_ad_landing_page_click_jump_control_enabled"]) {
            [SSCommonLogic setShouldClickJumpControlEnabled:[dict tt_boolValueForKey:@"tt_ad_landing_page_click_jump_control_enabled"]];
        }
        if ([dict objectForKey:@"tt_ad_landing_page_click_jump_interval"]) {
            [SSCommonLogic setClickJumpTimeInterval:[dict tt_doubleValueForKey:@"tt_ad_landing_page_click_jump_interval"]];
        }
        if ([dict objectForKey:@"tt_ad_landing_page_click_jump_intercept_list"]) {
            [SSCommonLogic setBlackListForClickJump:[dict tt_arrayValueForKey:@"tt_ad_landing_page_click_jump_intercept_list"]];
        }
        if ([dict objectForKey:@"tt_ad_landing_page_click_jump_intercept_tips"]) {
            [SSCommonLogic setFrobidClickJumpTips:[dict tt_stringValueForKey:@"tt_ad_landing_page_click_jump_intercept_tips"]];
        }
        if ([dict objectForKey:@"tt_should_intercept_ad_jump"]) {
            [SSCommonLogic setShouldInterceptAdJump:[dict tt_boolValueForKey:@"tt_should_intercept_ad_jump"]];
        }
    }
    
    if ([dSettings objectForKey:@"tt_ad_gifimageview_enabled"]) {
        [SSCommonLogic setFirstSplashEnable:[dSettings tt_boolValueForKey:@"tt_ad_gifimageview_enabled"]];
    }
    
    if ([dSettings objectForKey:@"tt_temail_tracker_enabled"]) {
        [SSCommonLogic setTemailTrackerEnable:[dSettings tt_boolValueForKey:@"tt_temail_tracker_enabled"]];
    }
    
    if ([dSettings objectForKey:@"track_ad_impression_enabled"]) {
        [SSCommonLogic setAdImpressionTrack:[dSettings tt_boolValueForKey:@"track_ad_impression_enabled"]];
    }
    
    //feed三方广告预加载开关
    if ([dSettings objectForKey:@"is_ad_preload"]) {
        [SSCommonLogic setAdResPreloadEnable:[dSettings tt_boolValueForKey:@"is_ad_preload"]];
    }
    
    //feed视频播放器重构开关
    if ([dSettings objectForKey:@"tt_feed_new_player_enable"]) {
        [SSCommonLogic setFeedNewPlayerEnabled:[dSettings tt_boolValueForKey:@"tt_feed_new_player_enable"]];
    }
    
    //视频可见性需求
    if ([dSettings objectForKey:@"tt_video_visible_enable"]) {
        
        if ([[dSettings objectForKey:@"tt_video_visible_enable"] isKindOfClass:[NSDictionary class]]) {
            NSDictionary *feedVideoConfig = [dSettings tt_dictionaryValueForKey:@"tt_video_visible_enable"];
            //视频可见性需求
            if ([feedVideoConfig objectForKey:@"tt_ad_video_visible_enable"]) {
                [SSCommonLogic setVideoVisibleEnabled:[feedVideoConfig tt_boolValueForKey:@"tt_ad_video_visible_enable"]];
            }
            //feed视频进详情页停止播放开关
            if ([feedVideoConfig objectForKey:@"tt_video_feed_enterback_enable"]) {
                [SSCommonLogic setFeedVideoEnterBackEnabled:[feedVideoConfig tt_boolValueForKey:@"tt_video_feed_enterback_enable"]];
            }
        } else {
            [SSCommonLogic setVideoVisibleEnabled:[dSettings tt_boolValueForKey:@"tt_video_visible_enable"]];
        }
    }
    
    //feed 资源预加载 采用v2版本预加载
    if ([dSettings objectForKey:@"tt_ad_preloadv2_enable"]) {
        [SSCommonLogic setAdUseV2PreloadEnable:[dSettings tt_boolValueForKey:@"tt_ad_preloadv2_enable"]];
    }
    
    //沉浸式广告开关
    if ([dSettings objectForKey:@"is_canvas_enabled"]) {
        [SSCommonLogic setCanvasEnable:[dSettings tt_boolValueForKey:@"is_canvas_enabled"]];
    }
    
    //沉浸式native开关
    if ([dSettings objectForKey:@"is_nativecanvas_enabled"]) {
        [SSCommonLogic setCanvasNativeEnable:[dSettings tt_boolValueForKey:@"is_nativecanvas_enabled"]];
    }
    
    //沉浸式打开策略
    if ([dSettings objectForKey:@"ad_preload_resources"]) {
        [SSCommonLogic setCanvasPreloadStrategy:[dSettings tt_dictionaryValueForKey:@"ad_preload_resources"]];
    }
    
    //Feed广告数据源控制开关
    if ([dSettings objectForKey:@"tt_ad_rawdataenable"]) {
        [SSCommonLogic setRawAdDataEnable:[dSettings tt_boolValueForKey:@"tt_ad_rawdataenable"]];
    }
    
    //TTUrlTracker服务开关
    if ([dSettings objectForKey:@"is_urltracker_enabled"]) {
        [SSCommonLogic setUrlTrackerEnable:[dSettings tt_boolValueForKey:@"is_urltracker_enabled"]];
    }
    
    //下载广告预加载开关
    if ([dSettings objectForKey:@"is_app_preload_enabled"]) {
        [SSCommonLogic setAppPreloadEnable:[dSettings tt_boolValueForKey:@"is_app_preload_enabled"]];
    }
    //广告落地页dom_complete开关
    if ([dSettings objectForKey:@"dom_complete_enabled"]) {
        [SSCommonLogic setWebDomCompleteEnable:[dSettings tt_boolValueForKey:@"dom_complete_enabled"]];
    }
    
    //接入秒针视频可见性sdk开关
    if ([dSettings objectForKey:@"mz_sdk_enabled"]) {
        [SSCommonLogic setMZSDKEnable:[dSettings tt_boolValueForKey:@"mz_sdk_enabled"]];
    }
    
    //app_log header插入ua原值开关
    if ([dSettings objectForKey:@"ad_ua_enabled"]) {
        [SSCommonLogic setUAEnable:[dSettings tt_boolValueForKey:@"ad_ua_enabled"]];
    }
    
    //延迟打开SDK的开关
    if ([dSettings objectForKey:@"sdk_delay_enabled"]) {
        [SSCommonLogic setSDKDelayEnable:[dSettings tt_boolValueForKey:@"sdk_delay_enabled"]];
    }
    
    //开启RN性能监控
    if ([dSettings objectForKey:@"rn_monitor_enabled"]) {
        [SSCommonLogic setRNMonitorEnable:[dSettings tt_boolValueForKey:@"rn_monitor_enabled"]];
    }
    //开启skController bugfix开关
    if ([dSettings objectForKey:@"skvc_bugfix_enabled"]) {
        [SSCommonLogic setSKVCBugFixEnable:[dSettings tt_boolValueForKey:@"skvc_bugfix_enabled"]];
    }
    
    //开启ios11 SKVC预加载修复的问题
    if ([dSettings objectForKey:@"skvc_load_enabled"]) {
        [SSCommonLogic setSKVCLoadEnable:[dSettings tt_boolValueForKey:@"skvc_load_enabled"]];
    }
    
    //广告相关配置项
    if (!SSIsEmptyDictionary([dSettings tt_dictionaryValueForKey:@"tt_ios_ad_config"])) {
        [TTASettingConfiguration setAdConfiguration:[dSettings tt_dictionaryValueForKey:@"tt_ios_ad_config"]];
    }

    if ([dSettings valueForKey:@"ios_video_compress_refactor_enabled"]) {
        [SSCommonLogic setVideoCompressRefactorEnabled:[dSettings tt_boolValueForKey:@"ios_video_compress_refactor_enabled"]];
    }
    
    [SSCommonLogic setCustomSDDownloaderOperationEnable:[dSettings tt_boolValueForKey:@"enable_custom_sdoperation"]];
    
    [SSCommonLogic setUseImageOptimizeStrategyEnable:[dSettings tt_boolValueForKey:@"tt_use_sdwebimage_optimize"]];
    
    [SSCommonLogic setMonitorFirstHostSuccessRateEnable:[dSettings tt_boolValueForKey:@"tt_monitor_firsthost"]];
    
    if ([dSettings valueForKey:@"tt_sddownloader_bugfix_enable"]) {
        [SSCommonLogic setBugfixSDWebImageDownloaderEnable:[dSettings tt_boolValueForKey:@"tt_sddownloader_bugfix_enable"]];
    }
    
    [SSCommonLogic setEnableCacheSizeReport:[dSettings intValueForKey:@"cache_size_report" defaultValue:1] != 0];
    
    
    double fetchTimeInterval = [dSettings doubleValueForKey:@"settings_fetch_interval" defaultValue:kFetchTimeInterval];
    [SSCommonLogic setFetchSettingTimeInterval:fetchTimeInterval];
    
    BOOL enableFetchWhenEnterForeground = ([dSettings intValueForKey:@"settings_fetch_foreground_enable" defaultValue:1] != 0);
    [SSCommonLogic setFetchSettingWhenEnterForegroundEnable:enableFetchWhenEnterForeground];
    
    BOOL enableGetRemoteCheckNetwork = ([dSettings intValueForKey:@"get_remote_check_net" defaultValue:0] != 0);
    [SSCommonLogic setGetRemoteCheckNetworkEnable:enableGetRemoteCheckNetwork];
    
    NSDictionary *screenshotSetting = [dSettings tt_dictionaryValueForKey:@"screenshot_setting"];
    if (screenshotSetting && screenshotSetting.count > 0){
        BOOL enableScreenshot = [screenshotSetting tt_boolValueForKey:@"is_enable_screenshot"];
        [SSCommonLogic setScreenshotEnable:enableScreenshot];
        
        NSString *screenshotText = [screenshotSetting tt_stringValueForKey:@"screenshot_text"];
        if (isEmptyString(screenshotText)){
            screenshotText = @"";
        }
        [SSCommonLogic setShareTextWithText:screenshotText];
        
        NSString *screenshotShareQRURL = [screenshotSetting tt_stringValueForKey:@"screenshot_share_download_url"];
        if (isEmptyString(screenshotShareQRURL)){
            screenshotShareQRURL = @"";
        }
        [SSCommonLogic setScreenshotShareQR:screenshotShareQRURL];
        
        BOOL makeScreenshotMethodBEnable = [screenshotSetting tt_boolValueForKey:@"make_screenshot_method_b"];
        [SSCommonLogic setMakeScreenshotForMethodBEnable:makeScreenshotMethodBEnable];
    }else{
        [SSCommonLogic setScreenshotEnable:NO];
    }
    
    // 个人主页模板url
    NSString *key = @"user_homepage_template_url";
    NSString *templateUrl = [dSettings tt_stringValueForKey:key];
    [SSCommonLogic setObject:templateUrl forKey:key];
    
    if ([dSettings objectForKey:@"new_pull_refresh"]) {
        [SSCommonLogic setNewPullRefreshEnabled:[dSettings tt_boolValueForKey:@"new_pull_refresh"]];
    }
    
    if ([dSettings objectForKey:@"realname_auth_encrypt_disabled"]) {
        [SSCommonLogic setRealnameAuthEncryptDisabled:[dSettings tt_boolValueForKey:@"realname_auth_encrypt_disabled"]];
    }
    
    [SSCommonLogic transitionAnimationEnable];//确保在设置之前获取一次值，当次设置，下次生效
    if ([dSettings objectForKey:@"transition_animation_enabled"]) {
        [SSCommonLogic setTransitionAnimationEnable:[dSettings tt_boolValueForKey:@"transition_animation_enabled"]];
    }
    
    [SSCommonLogic imageTransitionAnimationEnable];
    if ([dSettings objectForKey:@"tt_image_transition_animation_enabled"]){
        [SSCommonLogic setImageTransitionAnimationEnable:[dSettings tt_boolValueForKey:@"tt_image_transition_animation_enabled"]];
    }
    
    if ([dSettings objectForKey:@"tt_search_transition_animation_enabled"]){
        [SSCommonLogic setSearchTransitionEnabled:[dSettings tt_boolValueForKey:@"tt_search_transition_animation_enabled"]];
    }
    
    if ([dSettings objectForKey:@"tt_video_feed_cellui_height_adjust"]){
        [SSCommonLogic setVideoFeedCellHeightAjust:[dSettings tt_integerValueForKey:@"tt_video_feed_cellui_height_adjust"]];
    }
    
    if ([dSettings objectForKey:@"tt_video_autoplayad_halfshow"]){
        [SSCommonLogic setVideoAdAutoPlayedWhenHalfShow:[dSettings tt_boolValueForKey:@"tt_video_autoplayad_halfshow"]];
    }
    
    if ([dSettings objectForKey:@"tt_video_business_refactor"]) {
        [TTVSettingsConfiguration setTitanVideoBusiness:[dSettings tt_boolValueForKey:@"tt_video_business_refactor"]];
    }
    
    if ([dSettings objectForKey:@"video_ad_replay_btn_enabled"]) {
        
        [SSCommonLogic setVideoADReplayBtnEnabled:[dSettings tt_boolValueForKey:@"video_ad_replay_btn_enabled"]];
    }
    
    if([dSettings objectForKey:@"tt_push_sdk_upload_enable"]) {
        [SSCommonLogic setPushSDKEnable:[dSettings tt_boolValueForKey:@"tt_push_sdk_upload_enable"]];
    }
    
    if([dSettings objectForKey:@"tt_personal_home_media_type_three_enable"]) {
        [SSCommonLogic setPersonalHomeMediaTypeThreeEnable:[dSettings tt_boolValueForKey:@"tt_personal_home_media_type_three_enable"]];
    }
    
    // 禁用数据库后台自动清理
    [SSCommonLogic setObject:@([dSettings tt_boolValueForKey:@"db_autoclean_disable"]) forKey:@"db_autoclean_disable"];
    
    key = @"db_clean_size";
    if ([dSettings objectForKey:key]) {
        [SSCommonLogic setObject:@([dSettings tt_floatValueForKey:key]) forKey:key];
    }
    
    //举报错别字是否弹框
    if ([dSettings objectForKey:@"article_report_alert_enable"]) {
        [SSCommonLogic setReportTyposEnabled:[dSettings tt_boolValueForKey:@"article_report_alert_enable"]];
    }
    
    if ([dSettings objectForKey:@"app_log_send_optimize"]) {
        [SSCommonLogic setAppLogSendOptimizeEnabled:[dSettings tt_boolValueForKey:@"app_log_send_optimize"]];
    }
    //文章详情页Dislike重构开关
    if ([dSettings objectForKey:kTTArticleDislikeRefactor]) {
        [SSCommonLogic setDislikeRefactorEnabled:[dSettings tt_boolValueForKey:kTTArticleDislikeRefactor]];
    }
    //Feed流Dislike重构开关
    if ([dSettings objectForKey:kTTArticleFeedDislikeRefactor]) {
        [SSCommonLogic setFeedDislikeRefactorEnabled:[dSettings tt_boolValueForKey:kTTArticleFeedDislikeRefactor]];
    }
    
    if ([dSettings objectForKey:@"tt_refresh_by_click_category"]) {
        [SSCommonLogic setObject:[dSettings objectForKey:@"tt_refresh_by_click_category"] forKey:@"tt_refresh_by_click_category"];
    }
    
    if ([dSettings objectForKey:@"tt_play_image_enhancement"]) {
        [SSCommonLogic setPlayerImageEnhancementEnabel:[dSettings tt_boolValueForKey:@"tt_play_image_enhancement"]];
    }
    
    ///第四个tab为火山
    if ([dSettings objectForKey:@"tt_huoshan_tab_switch"]){
        [SSCommonLogic setHTSTabSwitch:[dSettings tt_integerValueForKey:@"tt_huoshan_tab_switch"]];
    }
    
    if ([dSettings objectForKey:@"tt_huoshan_tab_default_index"]) {
        [SSCommonLogic setForthTabInitialVisibleCategoryIndex:[dSettings tt_integerValueForKey:@"tt_huoshan_tab_default_index"]];
    }
    
    [SSCommonLogic isLaunchHuoShanAppEnabled];
    if ([dSettings objectForKey:@"tt_launch_huoshan_switch"]) {
        [SSCommonLogic setLaunchHuoShanAppEnabled:[dSettings tt_boolValueForKey:@"tt_launch_huoshan_switch"]];
    }
    if ([dSettings objectForKey:@"tt_mine_icon_url"]) {
        [SSCommonLogic setHTSTabMineIconURL:[dSettings tt_stringValueForKey:@"tt_mine_icon_url"]];
    }
    
    if ([dSettings objectForKey:@"tt_huoshan_tab_banner_info"]) {
        [SSCommonLogic setHTSTabBannerInfoDict:[dSettings tt_dictionaryValueForKey:@"tt_huoshan_tab_banner_info"]];
    }
    
    if ([dSettings objectForKey:@"tt_huoshan_app_download_info"]) {
        [SSCommonLogic setHTSAppDownloadInfoDict:[dSettings tt_dictionaryValueForKey:@"tt_huoshan_app_download_info"]];
    }
    
    if ([dSettings objectForKey:@"tt_short_video_ios_player_type"]) {
        [SSCommonLogic setHTSVideoPlayerType:[dSettings tt_integerValueForKey:@"tt_short_video_ios_player_type"]];
    }
    
    if ([dSettings objectForKey:@"tt_huoshan_first_frame"]) {
        [SSCommonLogic setAWEVideoDetailFirstFrame:[dSettings objectForKey:@"tt_huoshan_first_frame"]];
    }
    
    [TTBubbleViewManager shareManager];
    if ([dSettings objectForKey:@"tab_show_tips"]) {
        NSDictionary *dict = [dSettings dictionaryValueForKey:@"tab_show_tips" defalutValue:nil];
        [[TTBubbleViewManager shareManager] saveShowTips:dict];
    }
    // 视频详情页播放上一个UI样式开关
    if ([dSettings objectForKey:@"tt_video_detail_playlast_showtext"]) {
        [SSCommonLogic setVideoDetailPlayLastShowText:[dSettings tt_boolValueForKey:@"tt_video_detail_playlast_showtext"]];
    }
    
    // ugc的图片上传是否采用webp压缩
    if ([dSettings objectForKey:@"ugc_image_post_encodewebp"]) {
        [SSCommonLogic setUGCThreadPostImageWebP:[dSettings tt_boolValueForKey:@"ugc_image_post_encodewebp"]];
    }
    
    if ([dSettings objectForKey:@"tt_ios_launch_optimize_enabled"]) {
        [SSCommonLogic setNewLaunchOptimizeEnabled:[dSettings tt_boolValueForKey:@"tt_ios_launch_optimize_enabled"]];
    }
    
    // 常用表情选择
    if ([dSettings objectForKey:@"tt_user_expression_style"]) {
        [SSCommonLogic setUGCEmojiQuickInputEnabled:[dSettings tt_boolValueForKey:@"tt_user_expression_style"]];
    }
    
    // 表情排序接口请求间隔时间
    if ([dSettings objectForKey:@"tt_user_expression_config_interval"]) {
        NSTimeInterval timeInterval = [[dSettings objectForKey:@"tt_user_expression_config_interval"] doubleValue];
        [TTUGCEmojiParser setUserExpressionConfigTimeInterval:timeInterval];
    }
    
    if ([dSettings objectForKey:@"tt_chatroom_handle_interrupt"]) {
        [SSCommonLogic setHandleInterruptTrickMethodEnable:[dSettings tt_boolValueForKey:@"tt_chatroom_handle_interrupt"]];
    }
    
    if ([dSettings objectForKey:@"tt_network_connect_optimize_enabled"]) {
        BOOL enabled = [dSettings tt_boolValueForKey:@"tt_network_connect_optimize_enabled"];
        [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:@"kTTNetworkConnectOptimize"];
    }
    
    if ([dSettings objectForKey:@"tt_reachability_detect_optimize_enabled"]) {
        BOOL enabled = [dSettings tt_boolValueForKey:@"tt_reachability_detect_optimize_enabled"];
        [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:TTReachabilityDetectOptimizeKey];
    }
    
    if ([dSettings objectForKey:@"tt_clear_badge_bugfix_rollback"]) {
        BOOL rollback = [dSettings tt_boolValueForKey:@"tt_clear_badge_bugfix_rollback"];
        [[NSUserDefaults standardUserDefaults] setBool:rollback
                                                forKey:@"kTTClearBadgeBugfixRollback"];
    }
    
    if ([dSettings objectForKey:@"tt_third_party_url_white_list"]) {
        [TTCookieManager setLocationCookieDomains:[dSettings tt_arrayValueForKey:@"tt_third_party_url_white_list"]];
    }
    
    if ([dSettings objectForKey:@"tt_message_in_follow_channel"]) {
        BOOL enabled = [dSettings tt_boolValueForKey:@"tt_message_in_follow_channel"];
        [SSCommonLogic setFollowChannelMessageEnable:enabled];
    }
    
    if ([dSettings objectForKey:@"tt_follow_channel_cold_start"]) {
        BOOL enabled = [dSettings tt_boolValueForKey:@"tt_follow_channel_cold_start"];
        [SSCommonLogic setFollowChannelColdStartEnable:enabled];
    }
    
    if ([dSettings objectForKey:@"tt_follow_channel_upload_contacts"]) {
        BOOL enabled = [dSettings tt_boolValueForKey:@"tt_follow_channel_upload_contacts"];
        [SSCommonLogic setFollowChannelUploadContactsEnable:enabled];
    }
    
    if ([dSettings objectForKey:@"tt_follow_channel_upload_contacts_text"]) {
        NSString * text = [dSettings tt_stringValueForKey:@"tt_follow_channel_upload_contacts_text"];
        [SSCommonLogic setFollowChannelUploadContactsText:text];
    }
    
    if ([dSettings objectForKey:@"tt_weibo_expiration_enable"]) {
        [SSCommonLogic setWeiboExpirationDetectEnable:[dSettings tt_boolValueForKey:@"tt_weibo_expiration_enable"]];
    }else{
        [SSCommonLogic setWeiboExpirationDetectEnable:YES];
    }
    
    if ([dSettings objectForKey:@"tt_feed_detail_share_image_style"]) {
        [SSCommonLogic setFeedDetailShareImageStyle:[dSettings tt_integerValueForKey:@"tt_feed_detail_share_image_style"]];
    }else{
        [SSCommonLogic setFeedDetailShareImageStyle:0];
    }
    
    if ([dSettings objectForKey:@"tt_home_click_refresh_setting"]) {
        [SSCommonLogic setFeedHomeClickRefreshSetting:[dSettings tt_dictionaryValueForKey:@"tt_home_click_refresh_setting"]];
    }else{
        [SSCommonLogic setFeedHomeClickRefreshSetting:nil];
    }
    
    if ([dSettings objectForKey:@"f_category_settings"]) {
        [SSCommonLogic setFeedStartCategoryConfig:[dSettings tt_dictionaryValueForKey:@"f_category_settings"]];
    }else{
        [SSCommonLogic setFeedStartCategoryConfig:nil];
    }
    
    if ([dSettings objectForKey:@"tt_start_tab_config"]) {
        [SSCommonLogic setFeedStartTabConfig:[dSettings tt_dictionaryValueForKey:@"tt_start_tab_config"]];
    }else{
        [SSCommonLogic setFeedStartTabConfig:nil];
    }
    
    if ([dSettings objectForKey:@"tt_tactics_config"]) {
        [SSCommonLogic setCategoryTabAllConfig:[dSettings tt_dictionaryValueForKey:@"tt_tactics_config"]];
    }else{
        [SSCommonLogic setCategoryTabAllConfig:nil];
    }
    
    if ([dSettings objectForKey:@"tt_feed_load_local_strategy"]) {
        [SSCommonLogic setFeedLoadLocalStrategy:[dSettings tt_dictionaryValueForKey:@"tt_feed_load_local_strategy"]];
    }else{
        [SSCommonLogic setFeedLoadLocalStrategy:nil];
    }
    
    if ([dSettings objectForKey:@"tt_search_hint_homepage_suggest"]) {
        [SSCommonLogic setSearchHintSuggestEnable:[dSettings tt_boolValueForKey:@"tt_search_hint_homepage_suggest"]];
    }else{
        [SSCommonLogic setSearchHintSuggestEnable:NO];
    }
    
    if ([dSettings objectForKey:@"tt_feed_category_add_hidden"]) {
        [SSCommonLogic setFeedCaregoryAddHiddenEnable:[dSettings tt_boolValueForKey:@"tt_feed_category_add_hidden"]];
    }else{
        [SSCommonLogic setFeedCaregoryAddHiddenEnable:NO];
    }
    
    if ([dSettings objectForKey:@"tt_feed_search_entry_enable"]) {
        [SSCommonLogic setFeedSearchEntryEnable:[dSettings tt_boolValueForKey:@"tt_feed_search_entry_enable"]];
    }else{
        [SSCommonLogic setFeedSearchEntryEnable:NO];
    }
    
    if ([dSettings objectForKey:@"tt_pre_load_more_out_screen_number"]) {
        [SSCommonLogic setPreloadmoreOutScreenNumber:[dSettings tt_integerValueForKey:@"tt_pre_load_more_out_screen_number"]];
    }else{
        [SSCommonLogic setPreloadmoreOutScreenNumber:100];
    }
    
    if ([dSettings objectForKey:@"tt_feed_tips_show_strategy"]) {
        [SSCommonLogic setFeedTipsShowStrategyDict:[dSettings tt_dictionaryValueForKey:@"tt_feed_tips_show_strategy"]];
    }else{
        [SSCommonLogic setFeedTipsShowStrategyDict:nil];
    }
    
    if ([dSettings objectForKey:@"tt_feed_fantasy_local_settings"]) {
        [SSCommonLogic setFeedFantasyLocalSettings:[dSettings tt_dictionaryValueForKey:@"tt_feed_fantasy_local_settings"]];
    }else{
        [SSCommonLogic setFeedFantasyLocalSettings:nil];
    }
    
    if ([dSettings objectForKey:@"tt_feed_refresh_settings"]) {
        [SSCommonLogic setFeedRefreshStrategyDict:[dSettings tt_dictionaryValueForKey:@"tt_feed_refresh_settings"]];
    }else{
        [SSCommonLogic setFeedRefreshStrategyDict:nil];
    }
    
    if ([dSettings objectForKey:@"tt_detail_push_tips_enable"]) {
        [SSCommonLogic setDetailPushTipsEnable:[dSettings tt_boolValueForKey:@"tt_detail_push_tips_enable"]];
    }else{
        [SSCommonLogic setDetailPushTipsEnable:NO];
    }
    
    if ([dSettings objectForKey:@"tt_feed_auto_insert_setting"]) {
        [SSCommonLogic setFeedAutoInsertDict:[dSettings tt_dictionaryValueForKey:@"tt_feed_auto_insert_setting"]];
    }else{
        [SSCommonLogic setFeedAutoInsertDict:nil];
    }
    
    if ([dSettings objectForKey:@"tt_repeated_ad_disable"]) {
        [SSCommonLogic setRepeatedAdDisable:[dSettings tt_boolValueForKey:@"tt_repeated_ad_disable"]];
    }
    
    if ([dSettings objectForKey:@"tt_new_player"]) {
        [TTVSettingsConfiguration setNewPlayerEnabled:[dSettings tt_boolValueForKey:@"tt_new_player"]];
    }
    
    if ([dSettings objectForKey:@"tt_miniprogram_share_setting"]){
        NSDictionary *dict = [dSettings tt_dictionaryValueForKey:@"tt_miniprogram_share_setting"];
        NSString *programID = [dict tt_stringValueForKey:@"id"];
        NSString *pathTemplate = [dict tt_stringValueForKey:@"path_template"];
        [SSCommonLogic setMiniProgramID:programID];
        [SSCommonLogic setMiniProgramPathTemplate:pathTemplate];
    }else{
        [SSCommonLogic setMiniProgramID:@""];
        [SSCommonLogic setMiniProgramPathTemplate:@""];
    }
    if ([dSettings objectForKey:@"tt_openinsafari_setting"]){
        [SSCommonLogic setOpenInSafariWindowEnable:[dSettings tt_boolValueForKey:@"tt_openinsafari_setting"]];
    }
    
    if ([dSettings objectForKey:@"tt_video_detail_relate_style"]){
        [SSCommonLogic setVideoDetailRelatedStyle:[dSettings tt_integerValueForKey:@"tt_video_detail_relate_style"]];
    }
    
    if ([dSettings objectForKey:@"tt_channel_tip_polling_interval"]) {
        [[TTInfiniteLoopFetchNewsListRefreshTipManager sharedManager] setChannelTipPollingInterval:[dSettings tt_arrayValueForKey:@"tt_channel_tip_polling_interval"]];
    }
    
    if ([dSettings objectForKey:@"tt_three_top_bar"]){
        [SSCommonLogic setThreeTopBarEnable:[dSettings tt_boolValueForKey:@"tt_three_top_bar"]];
    }
    
//    if ([dSettings objectForKey:@"tt_contacts_collect_interval"]) {
//        [SSCommonLogic setAutoUploadContactsInterval:[dSettings objectForKey:@"tt_contacts_collect_interval"]];
//        [TTContactsGuideManager autoUploadContactsIfNeeded]; // settings 更新之后再判断一次是否上传
//    }
    
    if ([dSettings objectForKey:@"tt_feed_guide_config"]) {
        [TTFeedGuideView configFromSettings:dSettings];
    }
    
    if ([dSettings objectForKey:@"tt_log_v3_double_send_enabled"]) {
        NSDictionary *conf = [dSettings tt_dictionaryValueForKey:@"tt_log_v3_double_send_enabled"];
        [TTTrackerWrapper setV3DoubleSendingEnable:[conf tt_boolValueForKey:@"is_send_v3"]];
        [TTTrackerWrapper setOnlyV3SendingEnable:[conf tt_boolValueForKey:@"is_only_send_v3"]];
    }
    
    if ([dSettings objectForKey:@"tt_huoshan_detail_scroll_direction"]){
        [SSCommonLogic setShortVideoScrollDirection:[dSettings objectForKey:@"tt_huoshan_detail_scroll_direction"]];
    }
    
    if ([dSettings objectForKey:@"tt_huoshan_swipe_prompt"]){
        [SSCommonLogic setShortVideoFirstUsePromptType:[dSettings objectForKey:@"tt_huoshan_swipe_prompt"]];
    }
    
    if ([dSettings objectForKey:@"tt_huoshan_detail_infinite_scrolling"]) {
        [SSCommonLogic setShortVideoDetailInfiniteScrollEnable:[dSettings tt_boolValueForKey:@"tt_huoshan_detail_infinite_scrolling"]];
    }
    
    if ([dSettings objectForKey:@"tt_monitor_vc_hierarchy"]) {
        [SSCommonLogic setShouldMonitorMemoryWarningHierarchy:[dSettings tt_boolValueForKey:@"tt_monitor_vc_hierarchy"]];
    }
    
    if ([dSettings objectForKey:@"tt_inhouse_settings"]) {
        NSDictionary *settingsDict = [dSettings objectForKey:@"tt_inhouse_settings"];
        [SSCommonLogic setInHouseSetting:settingsDict];
    }
    
    if ([dSettings objectForKey:@"tt_multi_digg"]){
        NSDictionary *settingDict = [dSettings objectForKey:@"tt_multi_digg"];
        [SSCommonLogic setMultiDiggEnable:[settingDict tt_boolValueForKey:@"enable"]];
    }
    
    if ([dSettings objectForKey:@"tt_nav_bar_show_fans"]){
        NSDictionary *settingsDict = [dSettings objectForKey:@"tt_nav_bar_show_fans"];
        [SSCommonLogic setArticleNavBarShowFansNumEnable:[settingsDict tt_boolValueForKey:@"article_show_fans_enable"]];
        [SSCommonLogic setNavBarShowFansMinNum:[settingsDict tt_integerValueForKey:@"nav_bar_show_fans_min_num"]];
    }
    // 顶部搜索栏右侧是否显示天气
    if ([dSettings objectForKey:@"tt_top_searchbar_weather_setting"]) {
        [SSCommonLogic setObject:[dSettings objectForKey:@"tt_top_searchbar_weather_setting"] forKey:@"tt_top_searchbar_weather_setting"];
    }
    
    if ([dSettings objectForKey:@"tt_detail_gif_native_play"]) {
        [TTDetailWebviewGIFManager setDetailViewGifNativeEnabled:[dSettings tt_boolValueForKey:@"tt_detail_gif_native_play"]];
    }
    
    if ([dSettings objectForKey:@"tt_detail_webp"]) {
        [TTDetailWebViewContainerConfig setEnabledWebPImage:[dSettings tt_boolValueForKey:@"tt_detail_webp"]];
    }
    
    if ([dSettings objectForKey:@"tt_track_images_usage"]) {
        [SSCommonLogic setShouldTrackLocalImage:[dSettings tt_boolValueForKey:@"tt_track_images_usage"]];
    }
    
    //是否显示引导评分视图
    if ([dSettings objectForKey:@"tt_app_store_star_config"]) {
        NSDictionary *config = [dSettings tt_dictionaryValueForKey:@"tt_app_store_star_config"];
        if (config && config.allKeys.count > 0) {
            BOOL validUser = [config tt_boolValueForKey:@"tt_app_store_star_valid_user"];
            double interval = [config tt_doubleValueForKey:@"tt_app_store_star_show_interval"];
            BOOL greenChannel = [config tt_boolValueForKey:@"tt_app_store_star_green_channel"];
            
            [[TTAppStoreStarManager sharedInstance] setValidUser:validUser showTimeInterval:interval isGreenChannel:greenChannel];
        }
    }
    
    if ([dSettings objectForKey:@"tt_ugc_mediamaker_max_duration"]) {
        [SSCommonLogic setRecorderMaxLength:[dSettings tt_doubleValueForKey:@"tt_ugc_mediamaker_max_duration"]];
    }
    
//    if ([dSettings objectForKey:@"tt_live_TTVideoLive_enable"]) {
//        [SSCommonLogic setChatroomVideoLiveSDKEnable:[dSettings tt_boolValueForKey:@"tt_live_TTVideoLive_enable"]];
//    }
    
    if ([dSettings objectForKey:@"tt_share_with_pgcname_enable"]) {
        [SSCommonLogic setArticleShareWithPGCName:[dSettings tt_boolValueForKey:@"tt_share_with_pgcname_enable"]];
    }
    
//    if ([dSettings tt_dictionaryValueForKey:@"rp_config"]) {
//        if ([[dSettings tt_dictionaryValueForKey:@"rp_config"] tt_dictionaryValueForKey:@"rp_network_settings"]) {
//            [SSCommonLogic setSFNetworkSettings:[[dSettings tt_dictionaryValueForKey:@"rp_config"] tt_dictionaryValueForKey:@"rp_network_settings"]];
//        }
//
//        if ([[dSettings tt_dictionaryValueForKey:@"rp_config"] tt_dictionaryValueForKey:@"rp_tab_config"]) {
//            [SSCommonLogic setTTSFActivitySetting:[[dSettings tt_dictionaryValueForKey:@"rp_config"] tt_dictionaryValueForKey:@"rp_tab_config"]];
//        }
//
//        if ([[dSettings tt_dictionaryValueForKey:@"rp_config"] tt_dictionaryValueForKey:@"rp_resources_settings"]) {
//            [SSCommonLogic setTTSFResourcesSetting:[[dSettings tt_dictionaryValueForKey:@"rp_config"] tt_dictionaryValueForKey:@"rp_resources_settings"]];
//        }
//
//        if ([[dSettings tt_dictionaryValueForKey:@"rp_config"] objectForKey:@"rp_resources_available"]) {
//            BOOL canBeUsed = [[dSettings tt_dictionaryValueForKey:@"rp_config"] tt_boolValueForKey:@"rp_resources_available"];
//            [TTSFResourcesManager setResourceCanBeUsed:canBeUsed];
//        }
//    }
    
//    //fantasy settings
//    if ([dSettings objectForKey:@"hproject_settings"]) {
//        [TTFantasy ttf_updateSettings:[dSettings tt_dictionaryValueForKey:@"hproject_settings"]];
//        [[TTToutiaoFantasyManager sharedManager] updateHProjectSettings:[dSettings tt_dictionaryValueForKey:@"hproject_settings"]];
//    }
    
    //article title logo
    if ([dSettings objectForKey:@"tt_enable_detail_title_logo"]) {
        [SSCommonLogic setArticleTitleLogoEnbale:[dSettings tt_boolValueForKey:@"tt_enable_detail_title_logo"]];
    }
    
    //mine tab auth entry
    if ([dSettings objectForKey:@"my_homepage_auth_control"]) {
        NSDictionary *settingsDict = [dSettings tt_dictionaryValueForKey:@"my_homepage_auth_control"];
        if ([settingsDict objectForKey:@"apply_auth"]) {
            [SSCommonLogic setHomePageAddAuthSettings:[settingsDict tt_dictionaryValueForKey:@"apply_auth"]];
        }
        if ([settingsDict objectForKey:@"apply_verify"]) {
            [SSCommonLogic setHomePageAddVSettings:[settingsDict tt_dictionaryValueForKey:@"apply_verify"]];
        }
    }
    
    //search cancel action change
    if ([dSettings objectForKey:@"tt_search_cancel_click_action_change_enable"]) {
        [SSCommonLogic setSearchCancelClickActionChangeEnable:[dSettings tt_boolValueForKey:@"tt_search_cancel_click_action_change_enable"]];
    }else{
        [SSCommonLogic setSearchCancelClickActionChangeEnable:NO];
    }
    
    //本地固定频道名称配置
    if ([dSettings objectForKey:@"tt_category_name_config"]) {
        NSDictionary *tmpDict = [dSettings tt_dictionaryValueForKey:@"tt_category_name_config"];
        [SSCommonLogic setCategoryNameConfigDict:tmpDict];
    }else{
        [SSCommonLogic setCategoryNameConfigDict:nil];
    }
    
    //local data cache settings
    if ([dSettings objectForKey:@"tt_feed_disable_load_local"]) {
        [SSCommonLogic setGetLocalDataDisable:[dSettings tt_boolValueForKey:@"tt_feed_disable_load_local"]];
    }
    
    if ([dSettings objectForKey:@"tt_force_clean_category_list"]) {
        NSDictionary *config = [dSettings tt_dictionaryValueForKey:@"tt_force_clean_category_list"];
        NSArray *list = [config tt_arrayValueForKey:@"category_list"];
        [SSCommonLogic setClearLocalFeedDataList:list];
    }
    
    //wechat share config
    if ([dSettings objectForKey:@"tt_wechat_oldshare_callback_enable"]) {
        [SSCommonLogic setEnableWXShareCallback:[dSettings tt_boolValueForKey:@"tt_wechat_oldshare_callback_enable"]];
    }
    [[AKTaskSettingHelper shareInstance] updateBenefitValue];
}

static NSString *const kShowMallUserDefaultsKey = @"kShowMallUserDefaultsKey";
+ (void)setShowMallCellEntry:(BOOL)show {
    [[NSUserDefaults standardUserDefaults] setValue:@(show) forKey:kShowMallUserDefaultsKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (BOOL)isShowMallCellEntry {
    if ([[NSUserDefaults standardUserDefaults] valueForKey:kShowMallUserDefaultsKey]) {
        return [[[NSUserDefaults standardUserDefaults] valueForKey:kShowMallUserDefaultsKey] boolValue];
    }
    return YES;
}

static NSString *const kMineTabSellIntroduceStorageKey = @"kMineTabSellIntroduceStorageKey";
+ (NSString*)mineTabSellIntroduce
{
    NSString *ret = [[NSUserDefaults standardUserDefaults] stringForKey:kMineTabSellIntroduceStorageKey];
    if(isEmptyString(ret))
    {
        ret = NSLocalizedString(@"特卖、头彩、电影票", @"");
    }
    
    return ret;
}


+ (void)setMineTabSellIntroduce:(NSString*)introduce
{
    [[NSUserDefaults standardUserDefaults] setObject:introduce forKey:kMineTabSellIntroduceStorageKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}


- (void)applicationWillEnterForeground {
    [self fetchSettingsIfNeeded];
}

- (void)fetchSettingsIfNeeded {
    if (![SSCommonLogic isFetchSettingWhenEnterForegroundEnabled]) {
        return;
    }
    
    NSTimeInterval lastDate = [[NSUserDefaults standardUserDefaults] doubleForKey:SSFetchSettingsManagerFetchedDateKey];
    NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
    NSTimeInterval interval = [SSCommonLogic fetchSettingTimeInterval];
    
    if (now - lastDate > interval) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [ArticleFetchSettingsManager shareInstance].from = @"active";
            [ArticleFetchSettingsManager startFetchDefaultInfoIfNeed];
        });
    }
}

@end

