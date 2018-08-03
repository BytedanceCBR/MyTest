//
//  HTSVideoSwitch.m
//  Pods
//
//  Created by xushuangqing on 10/01/2018.
//

#import "HTSVideoSwitch.h"
#import <TTSettingsManager.h>
#import <NSDictionary+TTAdditions.h>

@implementation HTSVideoSwitch

+ (BOOL)shouldHideActivityTag {
    NSDictionary *activityDic = [[TTSettingsManager sharedManager] settingForKey:@"tt_short_video_activity" defaultValue:@{} freeze:NO];
    if ([activityDic isKindOfClass:[NSDictionary class]]) {
        return ![activityDic integerValueForKey:@"can_be_show" defaultValue:YES];
    }
    return NO;
}

@end
