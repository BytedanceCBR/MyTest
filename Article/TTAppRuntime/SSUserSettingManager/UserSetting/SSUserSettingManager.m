//
//  SSUserSettingManager.m
//  Article
//
//  Created by Yu Tianhang on 13-2-22.
//
//

#import "SSUserSettingManager.h"
#import "NetworkUtilities.h"

#import "TTUserSettingsReporter.h"
#import <TTAccountBusiness.h>
#import <TTUserSettings/TTUserSettingsManager+FontSettings.h>
#import "SSCommonLogic.h"
#import "TTUISettingHelper.h"
#import "TTDeviceHelper.h"
#import "TTDeviceUIUtils.h"

#define kAutoLoadImageOnlyFor2G             @"kAutoLoadImageOnlyFor2G"
#define kNetworkTrafficSettingStorageKey    @"kNetworkTrafficSettingStorageKey"
#define kHasShownNightMode                  @"kHasShownNightMode"
#define kHasSetNetworkTrafficSetting        @"kHasSetNetworkTrafficSetting"

NSString * const kHasShownIntroductionKey = @"kHasShownIntroductionKey";

NSInteger tt_ssusersettingsManager_fontSettingIndex(void) {
    return [SSUserSettingManager fontSettingIndex];
}

float tt_ssusersettingsManager_detailRelateReadFontSize(void) {
    return [SSUserSettingManager detailRelateReadFontSize];
}

float tt_ssusersettingsManager_detailVideoTitleFontSize(void) {
    return [SSUserSettingManager detailVideoTitleFontSize];
}

float tt_ssusersettingsManager_detailVideoContentFontSize(void) {
    return [SSUserSettingManager detailVideoContentFontSize];
}

@implementation SSUserSettingManager

static SSUserSettingManager *s_manager;

+(id)sharedManager
{
    @synchronized(self)
    {
        if(!s_manager)
        {
            s_manager = [[SSUserSettingManager alloc] init];
        }
        
        return s_manager;
    }
}

#pragma mark image settings
+ (NSArray*)networkTrafficSettings
{
    return [NSArray arrayWithObjects:NSLocalizedString(@"最佳效果(下载大图)", nil), NSLocalizedString(@"较省流量(智能下图)", nil), NSLocalizedString(@"极省流量(不下载图)", nil), nil];
}

#pragma mark -- font size setting

+ (NSInteger)fontSettingIndex
{
    return (NSInteger)[TTUserSettingsManager settingFontSize];
}

+ (float)detailVideoTitleFontSize
{
    float fontSize = 18.f;
    
    BOOL isPad = [TTDeviceHelper isPadDevice];
    
    if (!isPad) {
        return fontSize;
    }
    
    NSInteger selectedIndex = [SSUserSettingManager fontSettingIndex];
    switch (selectedIndex) {
        case 0:
            fontSize = 20;
            break;
        case 1:
            fontSize = 22;
            break;
        case 2:
            fontSize = 24;
            break;
        case 3:
            fontSize = 27;
        default:
            break;
    }
    return fontSize;
}

+ (float)detailVideoTitleLineHeight
{
    float lineHeight = 21.f;
    
    BOOL isPad = [TTDeviceHelper isPadDevice];
    
    if (!isPad) {
        return lineHeight;
    }
    
    NSInteger selectedIndex = [SSUserSettingManager fontSettingIndex];
    switch (selectedIndex) {
        case 0:
            lineHeight = 28;
            break;
        case 1:
            lineHeight = 30;
            break;
        case 2:
            lineHeight = 32;
            break;
        case 3:
            lineHeight = 35;
        default:
            break;
    }
    return lineHeight;
}

+ (float)detailVideoContentFontSize
{
    float fontSize = 12.f;
    
    BOOL isPad = [TTDeviceHelper isPadDevice];
    
    if (!isPad) {
        return fontSize;
    }
    
    NSInteger selectedIndex = [SSUserSettingManager fontSettingIndex];
    switch (selectedIndex) {
        case 0:
            fontSize = 12;
            break;
        case 1:
            fontSize = 14;
            break;
        case 2:
            fontSize = 16;
            break;
        case 3:
            fontSize = 19;
        default:
            break;
    }
    return fontSize;
}

+ (float)detailVideoContentLineHeight
{
    float lineHeight = 0;
    
    if ([TTDeviceHelper isScreenWidthLarge320]) {
        lineHeight = 19.f;
    } else {
        lineHeight = 17.f;
    }
    
    BOOL isPad = [TTDeviceHelper isPadDevice];
    
    if (!isPad) {
        return lineHeight;
    }
    
    NSInteger selectedIndex = [SSUserSettingManager fontSettingIndex];
    switch (selectedIndex) {
        case 0:
            lineHeight = 18;
            break;
        case 1:
            lineHeight = 21;
            break;
        case 2:
            lineHeight = 24;
            break;
        case 3:
            lineHeight = 27;
        default:
            break;
    }
    return lineHeight;
}

+ (float)detailRelateReadFontSize
{
    BOOL isPad = [TTDeviceHelper isPadDevice];
    float fontSize = 15;
    NSInteger selectedIndex = [SSUserSettingManager fontSettingIndex];
    switch (selectedIndex) {
        case 0:
            fontSize = isPad ? 14 : 13;
            break;
        case 1:
            fontSize = isPad ? 16 : 15;
            break;
        case 2:
            fontSize = isPad ? 18 : 17;
            break;
        case 3:
            fontSize = isPad ? 21 : 20;
        default:
            break;
    }
    return fontSize;
}

+ (float)newDetailRelateReadFontSize
{
    if ([TTUISettingHelper detailViewNatantFontSizeControllable]) {
        return [TTUISettingHelper detailViewNatantFontSize];
    }
    float fontSize = 17;
    NSInteger selectedIndex = [SSUserSettingManager fontSettingIndex];
    switch (selectedIndex) {
        case 0:
            fontSize = [TTDeviceUIUtils tt_fontSize: 15];
            break;
        case 1:
            fontSize = [TTDeviceUIUtils tt_fontSize: 17];
            break;
        case 2:
            fontSize = [TTDeviceUIUtils tt_fontSize: 19];
            break;
        case 3:
            fontSize = [TTDeviceUIUtils tt_fontSize: 22];
        default:
            break;
    }
    return fontSize;
}

+ (float)commentFontSize
{
    BOOL isPad = [TTDeviceHelper isPadDevice];
    float fontSize = 18;
    NSInteger selectedIndex = [SSUserSettingManager fontSettingIndex];
    switch (selectedIndex) {
        case 0:
            fontSize = isPad ? 16 : 14;
            break;
        case 1:
            fontSize = isPad ? 18 : 16;
            break;
        case 2:
            fontSize = isPad ? 20 : 18;
            break;
        case 3:
            fontSize = isPad ? 22 : 21;
        default:
            break;
    }
    return fontSize;
}

+ (float)replyFontSize
{
    if ([TTUISettingHelper detailViewCommentFontSizeControllable]) {
        return [TTUISettingHelper detailViewCommentReplyUserNameFontSize];
    }
    return 15.f;
}

+ (float)commentLineHeight
{
    BOOL isPad = [TTDeviceHelper isPadDevice];
    float lineHeight = 18;
    NSInteger selectedIndex = [SSUserSettingManager fontSettingIndex];
    switch (selectedIndex) {
        case 0:
            lineHeight = isPad ? 25 : 23;
            break;
        case 1:
            lineHeight = isPad ? 28 : 26;
            break;
        case 2:
            lineHeight = isPad ? 31 : 29;
            break;
        case 3:
            lineHeight = isPad ? 34 : 32;
        default:
            break;
    }
    return lineHeight;
}

+ (float)settedCommentViewFontDeltaSize
{
    float delta = 0;
    NSInteger selectedIndex = [SSUserSettingManager fontSettingIndex];
    switch (selectedIndex) {
        case 0:
            delta = -2;
            break;
        case 1:
            delta = 0;
            break;
        case 2:
            delta = 2;
            break;
        case 3:
            delta = 5;
        default:
            break;
    }
    return delta;
}

+ (CGFloat)sizeWithFontDefaultSetting:(CGFloat)normalSize {  //TOD§O:名字起得不好...
    switch ([SSUserSettingManager fontSettingIndex]) {
        case 0:
            return normalSize - 2.f;
            break;
        case 1:
            return normalSize;
            break;
        case 2:
            return normalSize + 2.f;
            break;
        case 3:
            return normalSize + 5.f;
            break;
        default:
            return normalSize;
            break;
    }
}

/*
 * 夜间模式是否已经设置过
 */
+ (BOOL)hasShownNightMode
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:kHasShownNightMode];
}

+ (void)setHasShownNightMode:(BOOL)shown
{
    [[NSUserDefaults standardUserDefaults] setBool:shown forKey:kHasShownNightMode];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (BOOL)shouldShowIntroductionView {
    if ([TTAccountManager isLogin]) {
        return NO;
    }
    /// 如果是第一次启动, 并且已经出国引导页面的话(说明是老用户升级的)
    if ([TTSandBoxHelper isAPPFirstLaunch] && [[NSUserDefaults standardUserDefaults] boolForKey:kHasShownIntroductionKey]) {
        return YES;
    }
    
    return [TTSandBoxHelper appLaunchedTimes] == [SSCommonLogic launchedTimes4ShowIntroductionView];
}

+ (void)setShouldShowIntroductionView:(BOOL)should {
    [[NSUserDefaults standardUserDefaults] setBool:should forKey:kHasShownIntroductionKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
