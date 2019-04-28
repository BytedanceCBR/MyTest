//
//  NewsLogicSetting.m
//  Article
//
//  Created by Hu Dianwei on 6/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NewsLogicSetting.h"
#import "NewsUserSettingManager.h"
#import "FriendDataManager.h"
#import "SSFeedbackManager.h"
#import "TTUserSettingsReporter.h"
#import "ExploreLogicSetting.h"
#import <TTUserSettings/TTUserSettingsHeader.h>

#define kUserSetFontTypeKey             @"kUserSetFontTypeKey"
#define kUserSetReadModeKey             @"kUserSetReadModeKey"
#define kHasSetReadModeForPadKey        @"kHasSetReadModeForPadKey"
#define kHasSetReadModeForPadKey        @"kHasSetReadModeForPadKey"
#define kHasDisplayLeftDrawerGuideKey   @"kHasDisplayLeftDrawerGuideKey"
#define kHasDisplayChannelGuideKey      @"kHasDisplayChannelGuideKey"



@implementation NewsLogicSetting

+ (ReadMode)userSetReadMode
{
    return [[[NSUserDefaults standardUserDefaults] objectForKey:kUserSetReadModeKey] intValue];
}

+ (void)setReadMode:(ReadMode)mode
{
    ReadMode oldMode = [NewsLogicSetting userSetReadMode];
    
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:mode] forKey:kUserSetReadModeKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    NSNumber * value = @0;
    if (mode == ReadModeAbstract) {
        value = @1;
    }
    else if (mode == ReadModeTitle) {
        value = @0;
    }
    [[TTUserSettingsReporter sharedInstance] addConfigurationValue:value key:kArticleConfigListMode];

    if (oldMode != mode) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kClearCacheHeightNotification object:nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:kReadModeChangeNotification object:self userInfo:nil];
    }
}

+ (BOOL)hasSetReadModeForPad
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:kHasSetReadModeForPadKey];
}

+ (void)setHasSetReadModeForPad:(BOOL)value
{
    [[NSUserDefaults standardUserDefaults] setBool:value forKey:kHasSetReadModeForPadKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}


+ (BOOL)shouldDisplayNewIndicator
{
    return ![NewsUserSettingManager hasShownNightMode] ||  /*![NewsUserSettingManager hasShownReadMode] ||*/ [SSFeedbackManager hasNewFeedback] /*|| [[NewVersionAlertManager alertManager] hasNewVersion] || [FriendDataManager hasNewFriendCount]*/;
}

+ (BOOL)shouldDisplayNewIndicatorForPad
{
    return [SSFeedbackManager hasNewFeedback] /*|| [[NewVersionAlertManager alertManager] hasNewVersion]*/;
}

+ (BOOL)hasDisplayChannelGuide
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:kHasDisplayChannelGuideKey];
}

+ (void)setHasDisplayChannelGuide:(BOOL)has
{
    [[NSUserDefaults standardUserDefaults] setBool:has forKey:kHasDisplayChannelGuideKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}


@end
