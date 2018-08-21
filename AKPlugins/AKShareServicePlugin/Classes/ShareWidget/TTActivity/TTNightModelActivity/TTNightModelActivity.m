//
//  TTNightModelActivity.m
//  Article
//
//  Created by 延晋 张 on 2017/1/12.
//
//

#import "TTNightModelActivity.h"
#import <TTBaseLib/TTUIResponderHelper.h>
#import <TTThemed/TTThemeManager.h>
#import <TTShareManager.h>

NSString * const TTActivityTypeChangeNightMode = @"com.toutiao.UIKit.activity.ChangeNightMode";

@interface TTNightModelActivity ()

@end

@implementation TTNightModelActivity

+ (void)load
{
    [TTShareManager addUserDefinedActivity:[TTNightModelActivity new]];
}

#pragma mark - Identifier

- (NSString *)contentItemType
{
    return TTActivityContentItemTypeNightMode;
}

- (NSString *)activityType
{
    return TTActivityTypeChangeNightMode;
}

#pragma mark - Display

- (NSString *)activityImageName
{
    if ([self.contentItem respondsToSelector:@selector(activityImageName)]) {
        return [self.contentItem activityImageName];
    } else {
        return @"day_allshare";
    }
}

- (NSString *)contentTitle
{
    if ([self.contentItem respondsToSelector:@selector(contentTitle)]) {
        return [self.contentItem contentTitle];
    } else {
        return @"日间模式";
    }
}

- (NSString *)shareLabel
{
    return nil;
}

#pragma mark - Action

- (void)performActivityWithCompletion:(TTActivityCompletionHandler)completion
{
    BOOL isDayMode = ([[TTThemeManager sharedInstance_tt] currentThemeMode] == TTThemeModeDay);
    [[TTThemeManager sharedInstance_tt] switchThemeModeto:(isDayMode ? TTThemeModeNight : TTThemeModeDay)];
    //做一个假的动画效果 让夜间渐变
    UIViewController *controller = self.presentingViewController ?: [TTUIResponderHelper topmostViewController];
    UIView * imageScreenshot = [controller.view.window snapshotViewAfterScreenUpdates:NO];
    [controller.view.window addSubview:imageScreenshot];
    [UIView animateWithDuration:0.5f animations:^{
        imageScreenshot.alpha = 0;
    } completion:^(BOOL finished) {
        [imageScreenshot removeFromSuperview];
    }];

    completion(self, nil, nil);
}

@end
