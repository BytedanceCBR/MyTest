//
//  TTVFeedItem+ComputedProperties.m
//  Article
//
//  Created by pei yun on 2017/3/30.
//
//

#import "TTVFeedItem+ComputedProperties.h"
#import <TTVideoService/Common.pbobjc.h>
#import <TTVideoService/Enum.pbobjc.h>
#import "NetworkUtilities.h"
#import "TTVFeedItem+Extension.h"
#import <TTSettingsManager/TTSettingsManager.h>
#import "ExploreOrderedData.h"
#import "ExploreOrderedData_Enums.h"

extern NSInteger ttvs_autoPlayModeServerSetting(void);

@implementation TTVFeedItem (ComputedProperties)

- (BOOL)isListShowPlayVideoButton {
    if (isEmptyString(self.article.videoId)) {
        return NO;
    }
    //视频feed只有8样式
//    TTVVideoStyle style = self.article.videoStyle;
//    switch (style) {
//        case TTVVideoStyle_VideoStyle0:
//        case TTVVideoStyle_VideoStyle1:
//            return NO;
//        default:
//            return YES;
//    }
    return YES;
}

- (BOOL)isPlayInDetailView {
    return (self.cellFlag & ExploreOrderedDataCellFlagPlayInDetailView) != 0;
}

- (BOOL)isVideoPGCCard
{
    return (self.cellFlag & ExploreOrderedDataCellFlagVideoPGCCard) != 0;
}

- (BOOL)isAutoPlayFlagEnabled {
    return (self.cellFlag & ExploreOrderedDataCellFlagAutoPlay) != 0;
}

- (BOOL)autoPlayServerEnabled
{
    BOOL result = [[[TTSettingsManager sharedManager] settingForKey:@"video_auto_play_flag" defaultValue:@NO freeze:NO] boolValue];
    return result && [self isAutoPlayFlagEnabled];
}

- (BOOL)couldContinueAutoPlay
{
    BOOL result = [[[TTSettingsManager sharedManager] settingForKey:@"video_play_continue_flag" defaultValue:@YES freeze:NO] boolValue];
    return [self couldAutoPlay] && result;
}

- (BOOL)couldAutoPlay
{
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"video_auto_play_test"]) {
        return [[NSUserDefaults standardUserDefaults] boolForKey:@"video_auto_play_test"];
    }
    BOOL dataCanAutoPlay = [self autoPlayServerEnabled];
    if (!dataCanAutoPlay) return NO;
    
    BOOL isPad = [TTDeviceHelper isPadDevice];
    if (isPad) {
        return NO;
    }
    
    BOOL settingModeOn = NO;
    if (TTNetworkWifiConnected()) {
        settingModeOn = ttvs_autoPlayModeServerSetting() != TTAutoPlaySettingModeNone;
    } else if (TTNetworkConnected()) {
        settingModeOn = ttvs_autoPlayModeServerSetting() == TTAutoPlaySettingModeAll;
    }
    
    return settingModeOn;
}

- (NSDictionary *)mointerInfo {
    NSMutableDictionary *info = [NSMutableDictionary dictionaryWithCapacity:3];
    info[@"ad_id"] = [NSString stringWithFormat:@"%@", self.adID ];
    info[@"log_extra"] = self.logExtra;
    return info;
}

@end
