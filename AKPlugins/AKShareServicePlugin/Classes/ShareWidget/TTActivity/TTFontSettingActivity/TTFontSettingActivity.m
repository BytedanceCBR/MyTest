//
//  TTFontSettingActivity.m
//  Article
//
//  Created by 延晋 张 on 2017/1/12.
//
//

#import "TTFontSettingActivity.h"
#import <TTTracker/TTTracker.h>
#import <TTShareManager.h>
#import "TTFontSettingController.h"
#import "SSThemed.h"


NSString * const TTActivityTypeSetFont = @"com.toutiao.UIKit.activity.SetFont";

@interface TTFontSettingActivity ()

@property(nonatomic, strong) TTFontSettingController *activityView;

@end

@implementation TTFontSettingActivity

+ (void)load
{
    [TTShareManager addUserDefinedActivity:[TTFontSettingActivity new]];
}

#pragma mark - Identifier

- (NSString *)contentItemType
{
    return TTActivityContentItemTypeFontSetting;
}

- (NSString *)activityType
{
    return TTActivityTypeSetFont;
}

#pragma mark - Display

- (NSString *)activityImageName
{
    if ([self.contentItem respondsToSelector:@selector(activityImageName)]) {
        return [self.contentItem activityImageName];
    } else {
        return @"type_allshare";
    }
}

- (NSString *)contentTitle
{
    if ([self.contentItem respondsToSelector:@selector(contentTitle)]) {
        return [self.contentItem contentTitle];
    } else {
        return @"字体设置";
    }
}

- (NSString *)shareLabel
{
    return nil;
}

#pragma mark - Action

- (void)performActivityWithCompletion:(TTActivityCompletionHandler)completion
{
    ttTrackEvent(@"detail", @"display_setting");

    [self.activityView show];

    if (completion) {
        completion(self, nil, nil);
    }
}

- (TTFontSettingController *)activityView
{
    if (!_activityView) {
        _activityView = [[TTFontSettingController alloc] init];
    }
    return _activityView;
}

@end
