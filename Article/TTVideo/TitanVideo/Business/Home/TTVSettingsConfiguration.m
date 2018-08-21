//
//  TTVSettingsConfiguration.m
//  Article
//
//  Created by pei yun on 2017/9/14.
//
//

#import "TTVSettingsConfiguration.h"
#import <TTSettingsManager/TTSettingsManager.h>
#import <TTSettingsManager/TTSettingsManager+SaveSettings.h>
#import "NetworkUtilities.h"

static NSNumber *isBusinessRefactor = nil;
static NSMutableDictionary *ttv_video_settings_dic = nil;
static NSString *const kTTVTitanBusinessManualSwitchKey = @"kTTVTitanBusinessManualSwitchKey";

BOOL ttvs_isTitanVideoBusiness(void)
{
    if (!isBusinessRefactor) {
        if (![[[[NSUserDefaults standardUserDefaults] dictionaryRepresentation] allKeys] containsObject:@"tt_video_business_refactor"]) {
            isBusinessRefactor = @(YES);
        }else{
            isBusinessRefactor = [NSNumber numberWithBool:[[NSUserDefaults standardUserDefaults] boolForKey:@"tt_video_business_refactor"]];
        }
    }
    if ([isBusinessRefactor boolValue]) {
        [[TTVSettingsConfiguration ttv_video_settings] setValue:@"refactor" forKey:@"ttv_isRefactor_settings"];
    }else{
        [[TTVSettingsConfiguration ttv_video_settings] setValue:@"noRefactor" forKey:@"ttv_isRefactor_settings"];
    }
    [[NSUserDefaults standardUserDefaults] setValue:[TTVSettingsConfiguration ttv_video_settings] forKey:@"ttv_video_settings"];
    return [isBusinessRefactor boolValue];
}

BOOL ttvs_isVideoNewRotateEnabled(void)
{
    NSDictionary *dict = [[TTSettingsManager sharedManager] settingForKey:@"tt_video_new_rotate" defaultValue:@{} freeze:YES];
    BOOL isEnabled = [dict tt_boolValueForKey:@"tt_video_new_rotate_4"];
    BOOL osVersionGreaterThan9 = [TTDeviceHelper OSVersionNumber] >= 9;
    return isEnabled && osVersionGreaterThan9;
}

void ttvs_setIsVideoNewRotateEnabled(BOOL enabled)
{
    NSMutableDictionary *dict = [[[TTSettingsManager sharedManager] settingForKey:@"tt_video_new_rotate" defaultValue:@{} freeze:YES] mutableCopy];
    [dict setValue:@(enabled) forKey:@"tt_video_new_rotate_4"];
    [[TTSettingsManager sharedManager] updateSetting:[dict copy] forKey:@"tt_video_new_rotate"];
}

NSInteger ttvs_isVideoFeedCellHeightAjust(void)
{
    return [TTDeviceHelper isPadDevice] ? 0 : [[[TTSettingsManager sharedManager] settingForKey:@"tt_video_feed_cellui_height_adjust" defaultValue:@0 freeze:NO] integerValue];
}

NSInteger ttvs_autoPlayModeServerSetting(void)
{
    BOOL autoPlayServerSettingEnabled = [[[TTSettingsManager sharedManager] settingForKey:@"video_auto_play_flag" defaultValue:@0 freeze:NO] boolValue];
    return autoPlayServerSettingEnabled ? [[[TTSettingsManager sharedManager] settingForKey:@"video_auto_play_mode" defaultValue:@(TTAutoPlaySettingModeWifi) freeze:NO] integerValue] : TTAutoPlaySettingModeWifi;
}

CGFloat ttvs_listVideoMaxHeight(void)
{
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
    NSNumber *result = [[TTSettingsManager sharedManager] settingForKey:@"list_player_max_height_percent" defaultValue:@0 freeze:NO];
    if ([result doubleValue] != 0) {
        return ceilf([result doubleValue] * screenHeight);
    }
    if ([TTDeviceHelper is480Screen]) {
        return ceilf(screenHeight * 2.f/3.f);
    }
    return ceilf(screenHeight * 3.f/5.f);
}

CGFloat ttvs_detailVideoMaxHeight(void)
{
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
    NSNumber *result = [[TTSettingsManager sharedManager] settingForKey:@"detail_player_max_height_percent" defaultValue:@0 freeze:NO];
    if ([result doubleValue] != 0) {
        return ceilf([result doubleValue] * screenHeight);
    }
    if ([TTDeviceHelper is480Screen]) {
        return ceilf(screenHeight * 2.f/3.f);
    }
    return ceilf(screenHeight * 3.f/5.f);
}

BOOL ttvs_isVideoCellShowShareEnabled(void)
{
    return [[[TTSettingsManager sharedManager] settingForKey:@"video_cell_show_share" defaultValue:@NO freeze:NO] boolValue];
}

/**
 0:simple 1:red 2:image icon 3:app icon
 ("only_title", "查看更多", ),
 ("change_colour", "立即下载", ),
 ("with_icon", "立即下载", ),
 ("with_picture", "立即下载", ),
 文案做成可配置：查看更多和立即下载，做成更明确的下载提示
 四种样式：banner_type: only_title, change_colour, with_icon, with_picture
 */
extern NSString * ttvs_playerFinishedRelatedType(void)
{
    NSDictionary *dic = (NSDictionary *)[[TTSettingsManager sharedManager] settingForKey:@"video_finish_download" defaultValue:@{} freeze:NO];
    return [dic valueForKey:@"style"];
}

BOOL ttvs_isVideoDetailPlayLastEnabled(void)
{
#if INHOUSE
    return YES;
#else
    return [[[TTSettingsManager sharedManager] settingForKey:@"tt_video_detail_playlast_enable" defaultValue:@NO freeze:NO] boolValue];
#endif
}

NSDictionary *ttvs_videoMidInsertADDict(void) {
    return [[TTSettingsManager sharedManager] settingForKey:@"tt_video_midpatch_settings" defaultValue:@{} freeze:NO];
}

BOOL ttvs_videoMidInsertADEnable(void) {
    return [ttvs_videoMidInsertADDict() tta_boolForKey:@"tt_video_midpatch_req_not_ad"];
}

NSInteger ttvs_getVideoMidInsertADReqStartTime(void) {
    return [ttvs_videoMidInsertADDict() integerValueForKey:@"tt_video_midpatch_req_start" defaultValue:15000];
}

NSInteger ttvs_getVideoMidInsertADReqEndTime(void) {
    return [ttvs_videoMidInsertADDict() integerValueForKey:@"tt_video_midpatch_req_end" defaultValue:50000];
}

//播放器内增加分享、更多入口 0:无 1:全屏右上角显示分享按钮 2:全屏右上角展示更多按钮
//只要不是0，视频详情页小窗播放／播放结束 都会展示更多按钮
NSInteger ttvs_isVideoShowOptimizeShare(void)
{
    return [TTDeviceHelper isPadDevice] ? 0 : [[[TTSettingsManager sharedManager] settingForKey:@"tt_video_show_optimize_share" defaultValue:@0 freeze:NO] integerValue];
}

//播放器内以及详情页中部，外露具体分享渠道 0:无，1:播放结束外露分享渠道 2：详情页中部外露分享渠道 3: 1&2
NSInteger ttvs_isVideoShowDirectShare(void)
{
    return [TTDeviceHelper isPadDevice] ? 0 : [[[TTSettingsManager sharedManager] settingForKey:@"tt_video_show_direct_share" defaultValue:@0 freeze:NO] integerValue];
}

BOOL ttvs_isVideoDetailCenterStrongShare(void)
{
    return [TTDeviceHelper isPadDevice] ? 0 : [[[TTSettingsManager sharedManager] settingForKey:@"tt_video_detail_share_strong" defaultValue:@NO freeze:NO] boolValue];
}

BOOL ttvs_isVideoFeedshowDirectShare(void)
{
    return [TTDeviceHelper isPadDevice] ? 0 : [[[TTSettingsManager sharedManager] settingForKey:@"tt_share_video_feed_enable" defaultValue:@NO freeze:NO] boolValue];
}

extern BOOL ttvs_isPlayerShowRelated(void)
{
    if ([ttvs_playerFinishedRelatedType() isEqualToString:@"only_title"] ||
        [ttvs_playerFinishedRelatedType() isEqualToString:@"change_colour"] ||
        [ttvs_playerFinishedRelatedType() isEqualToString:@"with_icon"] ||
        [ttvs_playerFinishedRelatedType() isEqualToString:@"with_picture"]) {
        return YES;
    }
    return NO;
}

BOOL ttvs_isVideoPlayFullScreenShowDirectShare(void)
{
    return [TTDeviceHelper isPadDevice] ? 0 : [[[TTSettingsManager sharedManager] settingForKey:@"tt_video_fullscreen_share_enable" defaultValue:@NO freeze:NO] boolValue];
}

BOOL ttvs_enabledVideoRecommend(void)
{
    NSNumber *recommendNumber = [[[TTSettingsManager sharedManager] settingForKey:@"h5_settings" defaultValue:@{} freeze:NO] objectForKey:@"pgc_recommend_connect"];
    if (recommendNumber != nil && [recommendNumber isKindOfClass:[NSNumber class]]) {
        return [recommendNumber boolValue];
    } else {
        return [[[TTSettingsManager sharedManager] settingForKey:@"tt_video_commodity_recommand" defaultValue:@NO freeze:NO] boolValue];
    }
}

BOOL ttvs_enabledVideoNewButton(void)
{
    NSNumber *recommendNumber = [[[TTSettingsManager sharedManager] settingForKey:@"h5_settings" defaultValue:@{} freeze:NO] objectForKey:@"pgc_new_follow_button"];
    if (recommendNumber != nil && [recommendNumber isKindOfClass:[NSNumber class]]) {
        return [recommendNumber boolValue];
    } else {
        return NO;
    }
}

BOOL ttvs_playerImageScaleEnable(void)
{
    return [[[TTSettingsManager sharedManager] settingForKey:@"tt_play_image_scale" defaultValue:@NO freeze:NO] boolValue] && [TTDeviceHelper OSVersionNumber] >= 9;
}

BOOL ttvs_threeTopBarEnable(void)
{
    return [[[TTSettingsManager sharedManager] settingForKey:@"tt_three_top_bar" defaultValue:@YES freeze:YES] boolValue];
}

BOOL ttvs_isShareIndividuatioEnable(void)
{
    return [TTDeviceHelper isPadDevice] ? NO : [[[TTSettingsManager sharedManager] settingForKey:@"tt_share_individuation_enable" defaultValue:@NO freeze:NO] integerValue];
}

//朋友圈分享样式优化，0:线上，1:无icon，2:三角形icon，3:无icon，title修改。
//【1，2，3】标题颜色都是黑色
NSInteger ttvs_isShareTimelineOptimize(void)
{
    return [TTDeviceHelper isPadDevice] ? 0 : [[[TTSettingsManager sharedManager] settingForKey:@"tt_share_weixin_timeline_optimize" defaultValue:@0 freeze:NO] integerValue];
}

BOOL ttvs_isVideoFeedURLEnabled(void)
{
    return [[[TTSettingsManager sharedManager] settingForKey:@"video_feed_url" defaultValue:@NO freeze:NO] boolValue];
}

BOOL ttvs_isDoubleTapForDiggEnabled(void)
{
    return [[[TTSettingsManager sharedManager] settingForKey:@"tt_video_doubleTapForDigg_enable" defaultValue:@NO freeze:NO] boolValue];
}

BOOL ttvs_isEnhancePlayerTitleFont(void)
{
    return [TTDeviceHelper isPadDevice] ? NO : [[[TTSettingsManager sharedManager] settingForKey:@"tt_feed_title_enhance_style" defaultValue:@NO freeze:NO] integerValue];
}

@implementation TTVSettingsConfiguration
+ (void)setTitanVideoBusiness:(BOOL)enabled
{
    [self setTitanVideoBusiness:enabled manualSwitch:NO];
}

+ (void)setTitanVideoBusiness:(BOOL)enabled manualSwitch:(BOOL)manual {
    if (!manual && [[NSUserDefaults standardUserDefaults] objectForKey:kTTVTitanBusinessManualSwitchKey]) {
        return;
    }
    [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:@"tt_video_business_refactor"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (void)setManualSwitchTitanVideoBusiness:(BOOL)enabled {
    [self setTitanVideoBusiness:enabled manualSwitch:YES];
    [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:kTTVTitanBusinessManualSwitchKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSMutableDictionary *)ttv_video_settings
{
    if (ttv_video_settings_dic) {
        return ttv_video_settings_dic;
    }
    ttv_video_settings_dic = [[NSUserDefaults standardUserDefaults] valueForKey:@"ttv_video_settings"];
    if (![ttv_video_settings_dic isMemberOfClass:[NSMutableDictionary class]]) {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"ttv_video_settings"];
        ttv_video_settings_dic = [[NSMutableDictionary alloc] init];
        [[NSUserDefaults standardUserDefaults] setValue:ttv_video_settings_dic forKey:@"ttv_video_settings"];
    };
    return ttv_video_settings_dic;
}

+ (void)setNewPlayerEnabled:(BOOL)enabled {
    if (enabled) {
        [[self ttv_video_settings] setValue:@"newplayer" forKey:@"ttv_is_new_player"];
    }else{
        [[self ttv_video_settings] setValue:@"oldplayer" forKey:@"ttv_is_new_player"];
    }
    [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:@"tt_new_player"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (BOOL)isNewPlayerEnabled
{
    BOOL isEnabled = [[NSUserDefaults standardUserDefaults] boolForKey:@"tt_new_player"];
    return isEnabled;
}

@end
