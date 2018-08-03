//
//  TTInAppPushSettings.m
//  Article
//
//  Created by liuzuopeng on 13/07/2017.
//
//

#import "TTInAppPushSettings.h"



#define kTTDefaultWeakAlertAnimationDuration   (0.8f)
#define kTTDefaultWeakAlertAutoDismissDuration (6.f)


@implementation TTInAppPushSettings

+ (void)parseInAppPushSettings:(NSDictionary *)settings
{
    if (!settings || ![settings isKindOfClass:[NSDictionary class]]) return;
    
    NSDictionary *newAlertSettings = settings[@"tt_apns_push_new_alert_style_settings"];
    if (!newAlertSettings || ![newAlertSettings isKindOfClass:[NSDictionary class]]) {
        return;
    }
    
    /** 新的Alert样式开关 */
    // APNs推送新的Alert弹窗开关
    NSNumber *newAlertEnabledNumber = settings[@"tt_apns_push_new_alert_style_enabled"];
    if (newAlertEnabledNumber) {
        [[NSUserDefaults standardUserDefaults] setObject:newAlertEnabledNumber forKey:kTTInAppPushNewAlertStyleKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    // 动画时长
    NSNumber *duration = newAlertSettings[@"tt_push_weak_alert_animation_duration"];
    if (duration) {
        [[NSUserDefaults standardUserDefaults] setObject:duration forKey:kTTInAppPushWeakAlertAnimationDurationKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    // 自动dismiss时长
    NSNumber *autoDismissDuration = newAlertSettings[@"tt_push_weak_alert_autodismiss_duration"];
    if (autoDismissDuration) {
        [[NSUserDefaults standardUserDefaults] setObject:autoDismissDuration forKey:kTTInAppPushWeakAlertAutoDismissDurationKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    NSNumber *animationShowDirection = newAlertSettings[@"tt_push_weak_alert_slideinto_direction"];
    if (animationShowDirection) {
        [[NSUserDefaults standardUserDefaults] setObject:animationShowDirection forKey:kTTInAppPushWeakAlertAnimationShowDirectionKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    NSNumber *adjustFontFit = newAlertSettings[@"tt_push_weak_alert_adjust_font_fit_width"];
    if (adjustFontFit) {
        [[NSUserDefaults standardUserDefaults] setObject:adjustFontFit forKey:kTTInAppPushWeakAlertAdjustFontFitWidthKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    NSNumber *pageScope = newAlertSettings[@"tt_push_weak_alert_show_page_scope"];
    if (pageScope) {
        [[NSUserDefaults standardUserDefaults] setObject:pageScope forKey:kTTInAppPushWeakAlertShowPageScopeKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

static NSString * const kTTInAppPushWeakAlertAnimationDurationKey = @"kTTInAppPushWeakAlertAnimationDurationKey";

+ (NSTimeInterval)weakAlertAnimationDuration
{
    NSNumber *duration = [[NSUserDefaults standardUserDefaults] objectForKey:kTTInAppPushWeakAlertAnimationDurationKey];
    if (duration && [duration respondsToSelector:@selector(longLongValue)] && [duration longLongValue] > 0) {
        return [duration longLongValue];
    }
    return kTTDefaultWeakAlertAnimationDuration;
}

static NSString * const kTTInAppPushWeakAlertAutoDismissDurationKey = @"kTTInAppPushWeakAlertAutoDismissDurationKey";

+ (NSTimeInterval)weakAlertAutoDismissDuration
{
    NSNumber *duration = [[NSUserDefaults standardUserDefaults] objectForKey:kTTInAppPushWeakAlertAutoDismissDurationKey];
    if (duration) {
        return [duration longLongValue];
    }
    return kTTDefaultWeakAlertAutoDismissDuration;
}

static NSString * const kTTInAppPushWeakAlertAnimationShowDirectionKey = @"kTTInAppPushWeakAlertAnimationShowDirectionKey";

+ (NSInteger)weakAlertAnimationSlideIntoDirection
{
    NSNumber *direction = [[NSUserDefaults standardUserDefaults] objectForKey:kTTInAppPushWeakAlertAnimationShowDirectionKey];
    if (direction) {
        return [direction integerValue];
    }
    return 0;
}

static NSString * const kTTInAppPushNewAlertStyleKey = @"kTTInAppPushNewAlertStyleKey";

+ (BOOL)newAlertEnabled
{
    NSNumber *APNsEnabledNumber = [[NSUserDefaults standardUserDefaults] objectForKey:kTTInAppPushNewAlertStyleKey];
    if (APNsEnabledNumber && [APNsEnabledNumber respondsToSelector:@selector(boolValue)]) {
        return [APNsEnabledNumber boolValue];
    }
    return YES;
}

static NSString * const kTTInAppPushWeakAlertAdjustFontFitWidthKey = @"kTTInAppPushWeakAlertAdjustFontFitWidthKey";

+ (BOOL)weakAlertAdjustsFontSizeToFitWidth
{
    NSNumber *ajustsFontFit = [[NSUserDefaults standardUserDefaults] objectForKey:kTTInAppPushWeakAlertAdjustFontFitWidthKey];
    if (ajustsFontFit && [ajustsFontFit respondsToSelector:@selector(boolValue)]) {
        return [ajustsFontFit boolValue];
    }
    return NO;
}

static NSString * const kTTInAppPushWeakAlertShowPageScopeKey = @"kTTInAppPushWeakAlertShowPageScopeKey";

+ (NSInteger)weakAlertShowPageScope
{
    NSNumber *pageScopeNumber = [[NSUserDefaults standardUserDefaults] objectForKey:kTTInAppPushWeakAlertShowPageScopeKey];
    if (pageScopeNumber && [pageScopeNumber respondsToSelector:@selector(integerValue)]) {
        return [pageScopeNumber integerValue];
    }
    return 0;
}

@end
