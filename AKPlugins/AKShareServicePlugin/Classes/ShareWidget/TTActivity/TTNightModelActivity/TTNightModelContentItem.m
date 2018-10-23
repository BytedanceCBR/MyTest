//
//  TTNightModelContentItem.m
//  Article
//
//  Created by 延晋 张 on 2017/1/12.
//
//

#import "TTNightModelContentItem.h"
#import <TTThemed/TTThemeManager.h>

NSString * const TTActivityContentItemTypeNightMode         =
@"com.toutiao.ActivityContentItem.NightMode";

@implementation TTNightModelContentItem

- (NSString *)contentItemType
{
    return TTActivityContentItemTypeNightMode;
}

- (NSString *)contentTitle
{
    if(([[TTThemeManager sharedInstance_tt] currentThemeMode] == TTThemeModeDay))
    {
        return NSLocalizedString(@"夜间模式", nil);
    }
    else{
        return NSLocalizedString(@"日间模式", nil);
    }
}

- (NSString *)activityImageName
{
    if(([[TTThemeManager sharedInstance_tt] currentThemeMode] == TTThemeModeDay)) {
        return @"night_allshare";
    } else {
        return @"day_allshare";
    }
}

@end
