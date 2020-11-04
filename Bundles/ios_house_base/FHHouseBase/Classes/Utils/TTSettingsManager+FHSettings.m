//
//  TTSettingsManager+FHSettings.m
//  FHHouseBase
//
//  Created by bytedance on 2020/10/22.
//

#import "TTSettingsManager+FHSettings.h"

@implementation TTSettingsManager(FHSettings)

+ (NSDictionary *)fSettings {
    return [[TTSettingsManager sharedManager] settingForKey:@"f_settings" defaultValue:@{} freeze:YES];
}

@end
