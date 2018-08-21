//
//  TSVListAutoRefreshRecorder.m
//  HTSVideoPlay
//
//  Created by 王双华 on 2017/11/17.
//

#import "TSVListAutoRefreshRecorder.h"
#import "TTSettingsManager.h"
#import <TTBaseLib/NSDictionary+TTAdditions.h>

static NSString * const kTSVListAutoRefreshRecorderLastTimeRefreshTimeKey = @"kTSVListAutoRefreshRecorderLastTimeRefreshTimeKey";

@implementation TSVListAutoRefreshRecorder

+ (BOOL)shouldAutoRefreshForCategory:(TTCategory *)category
{
    if (!category) {
        return NO;
    }
    NSDictionary *channelControlConfDict = [[TTSettingsManager sharedManager] settingForKey:@"channel_control_conf" defaultValue:
                                            @{
                                              @"hotsoon_video": @{
                                                      @"auto_refresh_interval": @"3600",
                                                      @"show_last_read": @0,
                                                      }
                                              }
                                                                                     freeze:NO];
    NSDictionary *shortVideoCategoryRefreshConfDict = [channelControlConfDict tt_dictionaryValueForKey:@"hotsoon_video"];
    NSTimeInterval shortVideoCategoryRefreshInterval = [shortVideoCategoryRefreshConfDict tt_doubleValueForKey:@"auto_refresh_interval"];
    NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
    NSTimeInterval lastTimeRefresh = [[NSUserDefaults standardUserDefaults] doubleForKey:[NSString stringWithFormat:@"%@%@", kTSVListAutoRefreshRecorderLastTimeRefreshTimeKey, category.categoryID]];
    if (shortVideoCategoryRefreshInterval > 0 && now - lastTimeRefresh > shortVideoCategoryRefreshInterval) {
        return YES;
    }
    return NO;
}

+ (void)saveLastTimeRefreshForCategory:(TTCategory *)category
{
    if (!category) {
        return;
    }
    NSTimeInterval time = [[NSDate date] timeIntervalSince1970];
    [[NSUserDefaults standardUserDefaults] setDouble:time forKey:[NSString stringWithFormat:@"%@%@", kTSVListAutoRefreshRecorderLastTimeRefreshTimeKey, category.categoryID]];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
