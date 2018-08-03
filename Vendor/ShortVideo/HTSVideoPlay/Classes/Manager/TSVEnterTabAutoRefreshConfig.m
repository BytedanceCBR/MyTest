//
//  TSVEnterTabAutoRefreshConfig.m
//  HTSVideoPlay
//
//  Created by 邱鑫玥 on 2017/12/27.
//

#import "TSVEnterTabAutoRefreshConfig.h"
#import "TTSettingsManager.h"

@implementation TSVEnterTabAutoRefreshConfig

+ (BOOL)shouldAutoRefreshWhenEnterTab
{
    return [[[TTSettingsManager sharedManager] settingForKey:@"tt_short_video_tab_auto_refresh" defaultValue:@0 freeze:YES] boolValue];
}

@end
