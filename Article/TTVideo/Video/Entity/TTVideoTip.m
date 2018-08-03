//
//  TTVideoTip.m
//  Article
//
//  Created by panxiang on 16/12/20.
//
//

#import "TTVideoTip.h"
#import "ExploreItemActionManager.h"

static NSString * const kVideoTipHasShownKey = @"kVideoTipHasShownKey";

@implementation TTVideoTip

#pragma mark -
#pragma mark Video tip

+ (BOOL)shouldShowVideoTip
{
    BOOL serverEnabled = [SSCommonLogic videoTipServerSettingEnabled];
    //只要用户没有展示过tip就展示，并且只展示一次
    //!([self lastVideoTipShowDate] > 0) 针对老用户非升级用户来判断
    if (serverEnabled && [self canShowVideoTip] && !([self lastVideoTipShowDate] > 0) && ![self hasShownVideoTip]) {
        return YES;
    }
    return NO;
}

+ (NSTimeInterval)intervalFromLastShow
{
    return [NSDate date].timeIntervalSince1970 - [self lastVideoTipShowDate];
}

+ (void)saveVideoTipShowDate
{
    NSDate *date = [NSDate date];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setDouble:date.timeIntervalSince1970 forKey:kVideoTipLastShowDateKey];
    [defaults synchronize];
}

+ (NSTimeInterval)lastVideoTipShowDate
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults doubleForKey:kVideoTipLastShowDateKey];
}

+ (void)setHasShownVideoTip:(BOOL)hasShown{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:hasShown forKey:kVideoTipHasShownKey];
    [defaults synchronize];

}

+ (BOOL)hasShownVideoTip{
    if([[NSUserDefaults standardUserDefaults] objectForKey:kVideoTipHasShownKey]){
        return [[NSUserDefaults standardUserDefaults] boolForKey:kVideoTipHasShownKey];
    }
    return NO;
}

+ (void)setCanShowVideoTip:(BOOL)canShow
{
    if ([self canShowVideoTip] == canShow) {
        return;
    }
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:canShow forKey:kVideoTipCanShowKey];
    [defaults synchronize];
}

+ (BOOL)canShowVideoTip
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults boolForKey:kVideoTipCanShowKey];
}

+ (void)setHasTipFavLoginUserDefaultKey:(BOOL)hasTip
{
    [[NSUserDefaults standardUserDefaults] setBool:hasTip forKey:kHasTipFavLoginUserDefaultKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (BOOL)hasTipFavLoginUserDefaultKey
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:kHasTipFavLoginUserDefaultKey];
}

@end
