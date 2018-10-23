//
//  SSFetchSettingsManager.m
//  Article
//
//  Created by Zhang Leonardo on 13-5-23.
//
//

#import "SSFetchSettingsManager.h"
#import "CommonURLSetting.h"
#import "TTInstallIDManager.h"
#import "SSUserSettingManager.h"
#import "APNsManager.h"
#import "SSAPNsAlertManager.h"
#import "SSImpressionManager.h"
#import "ArticleAddressManager.h"
#import "SSWebViewUtil.h"
#import "SSIndicatorTipsManager.h"
#import "TTAccountBindingMobileViewController.h"
#import "ExploreItemActionManager.h"
#import <TTUserSettings/TTUserSettingsManager+Notification.h>
#import "TTThemeManager.h"
#import <AKWebViewBundlePlugin/TTJSBAuthManager.h>
#import <TTNetworkManager/TTNetworkManager.h>

#define SSFetchSettingsManagerFetchedDefaultInfoKey @"SSFetchSettingsManagerFetchedDefaultInfoKey"

@interface SSFetchSettingsManager()

@property(nonatomic, strong, readwrite)NSDictionary *settingsDict;

@end

static SSFetchSettingsManager * manager;

@implementation SSFetchSettingsManager

+ (void)startFetchDefaultInfoIfNeed
{
    [[self shareInstance] startFetchDefaultSettingsWithDefaultInfo:![self hasFetchedDefaultInfo]];
}

+ (SSFetchSettingsManager *)shareInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] init];
    });
    return manager;
}

- (void)dealloc
{
}

- (id)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (void)startFetchDefaultSettingsWithDefaultInfo:(BOOL)defaultInfo
{
    [self startFetchDefaultSettingsWithDefaultInfo:defaultInfo forceRefresh:NO];
}

- (void)startFetchDefaultSettingsWithDefaultInfo:(BOOL)defaultInfo forceRefresh:(BOOL)forceRefresh
{
    static NSInteger requestTimes = 0;
    if (!forceRefresh && requestTimes++>2) {
        [[TTMonitor shareManager] trackService:@"fetch_settings_error" status:1 extra:nil];
        return;
    }
    
    NSMutableDictionary * getPara = [NSMutableDictionary dictionaryWithCapacity:10];
    [getPara setValue:[[TTInstallIDManager sharedInstance] deviceID] forKey:@"device_id"];
    [getPara setValue:[TTSandBoxHelper appName] forKey:@"app_name"];
    [getPara setValue:[TTSandBoxHelper ssAppID] forKey:@"aid"];
    [getPara setValue:[[TTInstallIDManager sharedInstance] installID] forKey:@"iid"];
    if (forceRefresh) {
        [getPara setValue:@1 forKey:@"debug"];
    }
    if (defaultInfo) {
        [getPara setObject:@1 forKey:@"default"];
    }
    [getPara setObject:@1 forKey:@"app"];
    if ([TTSandBoxHelper isInHouseApp]) {
        [getPara setValue:@(1) forKey:@"inhouse"];
    }
    if (!isEmptyString(self.from)) {
        [getPara setValue:self.from forKey:@"from"];
    }
    
    WeakSelf;
    [[TTNetworkManager shareInstance] requestForJSONWithURL:[CommonURLSetting appSettingsURLString] params:getPara method:@"GET" needCommonParams:YES callback:^(NSError *error, id jsonObj) {
        StrongSelf;
        
        if (!error) {
            [SSFetchSettingsManager saveFetchedDefaultInfo];
            
            self.settingsDict = jsonObj;
            
            NSDictionary * dSettings = [[jsonObj tt_dictionaryValueForKey:@"data"] tt_dictionaryValueForKey:@"default"];
            if (dSettings) {
                [self dealDefaultSettingsResult:dSettings];
            }
            
            NSDictionary * appSettings = [[jsonObj tt_dictionaryValueForKey:@"data"] tt_dictionaryValueForKey: @"app"];
            if (appSettings) {
                [self dealAppSettingResult:appSettings];
            }
        } else {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [[self class] startFetchDefaultInfoIfNeed];
            });
        }
    }];
}


- (void)dealAppSettingResult:(NSDictionary *)dSettings
{
    NSDictionary * temp = [dSettings objectForKey:@"share_templates"];
    [SSCommonLogic saveShareTemplate:temp];
    
    // add by zjing
    NSDictionary * category = [dSettings objectForKey:@"f_category_settings"];
    [SSCommonLogic setFeedStartCategoryConfig:category];
    
    NSDictionary * settings = [dSettings objectForKey:@"f_settings"];
    [SSCommonLogic setFHSettings:settings];
    
    NSArray * urls = [dSettings objectForKey:@"intercept_urls"];
    [SSCommonLogic saveInterceptURLs:urls];
    
    NSString * string = [dSettings objectForKey:@"repost_input_hint"];
    if ([string isKindOfClass:[NSString class]]) {
        [SSCommonLogic saveCommentInputViewPlaceHolder:string];
    }
    else {
        [SSCommonLogic saveCommentInputViewPlaceHolder:nil];
    }
    
    if ([[dSettings allKeys] containsObject:@"send_install_apps_interval"]) {
        NSString* sendInstallAppsInterval = [NSString stringWithFormat:@"%@",[dSettings objectForKey:@"send_install_apps_interval"]];
        [SSCommonLogic saveInstallAppsInterval:sendInstallAppsInterval];
    } else {
        [SSCommonLogic saveInstallAppsInterval:nil];
    }
    
    if([[dSettings allKeys] containsObject:@"send_recent_apps_interval"]) {
        NSString* sendRecentAppsInterval = [NSString stringWithFormat:@"%@",[dSettings objectForKey:@"send_recent_apps_interval"]];
        [SSCommonLogic saveRecentAppsInterval:sendRecentAppsInterval];
    } else {
        [SSCommonLogic saveRecentAppsInterval:nil];
    }
    
    NSNumber *appseeSetting = [dSettings objectForKey:@"appsee_enable"];
    if ([appseeSetting isKindOfClass:[NSNumber class]]) {
        [SSCommonLogic setAppseeSampleSetting:appseeSetting];
    }
    
    NSNumber *galleryTileSwitch = [dSettings objectForKey:@"is_gallery_laied_flat"];
    if ([galleryTileSwitch isKindOfClass:[NSNumber class]]) {
        [SSCommonLogic setGalleryTileSwitch:galleryTileSwitch];
    }
    
    NSNumber *gallerySlideOutSwitch = [dSettings objectForKey:@"is_gallery_up_return"];
    if ([gallerySlideOutSwitch isKindOfClass:[NSNumber class]]) {
        [SSCommonLogic setGallerySlideOutSwitch:gallerySlideOutSwitch];
    }
    
    if ([[dSettings allKeys] containsObject:@"show_apns_alert_view"]) {
        [SSAPNsAlertManager setCouldShowAPNsAlert:[[dSettings objectForKey:@"show_apns_alert_view"] boolValue]];
    }
    
    if([[dSettings allKeys] containsObject:@"http_referer"])
    {
        [SSWebViewUtil setWebViewReferrer:[dSettings objectForKey:@"http_referer"]];
    }
    
    if ([[dSettings allKeys] containsObject:@"impression_policy"]) {
        [SSImpressionManager saveImpressionPolicy:[[dSettings objectForKey:@"impression_policy"] intValue]];
    }
    
    
    if([[dSettings allKeys] containsObject:@"mobile_regex_ios"])
    {
        if([[dSettings objectForKey:@"mobile_regex_ios"] isKindOfClass:[NSArray class]])
        {
            [ArticleAddressManager setReplaceRegularExpress:[dSettings objectForKey:@"mobile_regex_ios"]];
        }
    }
    
    if ([dSettings objectForKey:@"tt_safe_domain_list"]) {
        [[TTJSBAuthManager sharedManager] updateInnerDomainsFromRemote:[dSettings tt_arrayValueForKey:@"tt_safe_domain_list"]];
    }
    
    if([[dSettings allKeys] containsObject:@"contacts_collect_interval"])
    {
        [ArticleAddressManager setUploadInterval:[[dSettings objectForKey:@"contacts_collect_interval"] doubleValue]];
    }
        
    if([[dSettings allKeys] containsObject:@"indicator_tips"])
    {
        [[SSIndicatorTipsManager shareInstance] setIndicatorTipsWithDictionary:[dSettings objectForKey:@"indicator_tips"]];
    }
    
    if ([[dSettings allKeys] containsObject:@"gallery_detail_page_follow_button_enabled"]) {
        BOOL enable = [dSettings tt_boolValueForKey:@"gallery_detail_page_follow_button_enabled"];
        [SSCommonLogic setPicsFollowEnabled:enable];
    }
    
//    obj = [dSettings objectForKey:@"group_comment_max_text_length"];
//    if ([obj isKindOfClass:[NSNumber class]]) {
//        g_exploreDetailWriteCommentMaxCharactersLimit = [obj unsignedIntValue];
//    }
    
    if ([[dSettings allKeys] containsObject:@"im_server_enable"]) {
        BOOL enable = [dSettings tt_boolValueForKey:@"im_server_enable"];
        [SSCommonLogic setIMServerEnabled:enable];
    }

    if ([[dSettings allKeys] containsObject:@"tt_comment_bindmobile_text_settings"]) {
        NSDictionary *dic = [dSettings tt_objectForKey:@"tt_comment_bindmobile_text_settings"];
        if (dic.allKeys.count > 0 && dic) {
            NSString *title = [dic tt_stringValueForKey:@"commont_bind_mobile_title"];
            [TTAccountBindingMobileViewController setTipBindTitle:title];
            NSString *tip = [dic tt_stringValueForKey:@"commont_bind_mobile_cancel_warming"];
            [TTAccountBindingMobileViewController setTipBindCancel:tip];
        }
    }

}

- (void)dealDefaultSettingsResult:(NSDictionary *)dSettings
{
    //夜间模式
    if ([[dSettings allKeys] containsObject:@"night_mode"]) {
        int nightMode = [[dSettings objectForKey:@"night_mode"] intValue];
        [self refreshNightModelBySetting:nightMode];
    }
    
    //apn notify
    if ([[dSettings allKeys] containsObject:@"apn_notify"]) {
        int apnNotify = [[dSettings objectForKey:@"apn_notify"] intValue];
        [self refreshApnNotifyBySetting:apnNotify];
    }
    
    //repost when repin
//    if ([[dSettings allKeys] containsObject:@"repost_favor"]) {
//        int defaultValue = [[dSettings objectForKey:@"repost_favor"] intValue];
//        [self refreshRetweetWhenRepinOn:defaultValue];
//    }
    
    //设置crash log 报告者
    if([[dSettings allKeys] containsObject:@"crash_reporter"])
    {
        NSString * str = [dSettings objectForKey:@"crash_reporter"];
        [SSCommonLogic setCrashReporter:str];
    }
}

//serverValue默认为1， 为打开apns
- (void)refreshApnNotifyBySetting:(NSUInteger)serverValue
{
    if (![TTUserSettingsManager apnsNewAlertClosed]) {//默认为打开APNs
        if (serverValue == 0) {
            [TTUserSettingsManager closeAPNsNewAlert:YES];
        }
    }
}

- (void)refreshNightModelBySetting:(NSUInteger)serverSettingValue
{
    if ([[TTThemeManager sharedInstance_tt] currentThemeMode] == TTThemeModeDay) {
        if (serverSettingValue == 1) {
            [[TTThemeManager sharedInstance_tt] switchThemeModeto:TTThemeModeNight];
        }
    }
}

#pragma mark -- user default key
+ (void)saveFetchedDefaultInfo
{
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:SSFetchSettingsManagerFetchedDefaultInfoKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (BOOL)hasFetchedDefaultInfo
{
    BOOL result = [[NSUserDefaults standardUserDefaults] boolForKey:SSFetchSettingsManagerFetchedDefaultInfoKey];
    if (result) {
        NSString * shareFrom = NSLocalizedString(@"分享来自 #好多房#", nil);
        NSString * noShareURLStrings = [NSString stringWithFormat:@"【{title:50}】 (%@ )", shareFrom];
        NSString * twitterURLStrings = [NSString stringWithFormat:@"【{title:50}】{share_url} (%@ )", shareFrom];
        NSDictionary * defaultTemp =  @{
                                        @"kaixin_sns":  noShareURLStrings,
                                        @"qzone_sns":   noShareURLStrings,
                                        @"twitter":     twitterURLStrings,
                                        @"renren_sns":  noShareURLStrings,
                                        @"system":      [NSString stringWithFormat:@"%@：【{title:50}】{share_url}", NSLocalizedString(@"分享自好多房", nil)],
                                        @"weixin":      [NSString stringWithFormat:@"%@【{title:50}", NSLocalizedString(@"好多房", nil)],
                                        @"qq_weibo":    [NSString stringWithFormat:@"【{title:50}】 (%@ @headlineapp )", NSLocalizedString(@"分享来自", nil)],
                                        @"facebook":    [NSString stringWithFormat:@"【{title:50}】{share_url} (%@ )", shareFrom],
                                        @"sina_weibo":  noShareURLStrings
                                        };
        [SSCommonLogic saveShareTemplate:defaultTemp];
    }
    return result;
}

@end
