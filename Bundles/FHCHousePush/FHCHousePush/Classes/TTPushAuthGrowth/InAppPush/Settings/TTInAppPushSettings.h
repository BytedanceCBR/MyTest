//
//  TTInAppPushSettings.h
//  Article
//
//  Created by liuzuopeng on 13/07/2017.
//
//

#import <Foundation/Foundation.h>



/**
 *  @Wiki: http://settings.byted.org/static/main/index.html#/app_settings/item_detail?id=665
 *
 *  tt_apns_push_new_alert_style_settings: {
 *      tt_apns_push_new_alert_style_enabled: 是否启用新的弹窗样式，默认为YES
 *      tt_push_weak_alert_animation_duration: 弱干扰弹窗显示动画时间，默认0.8s
 *      tt_push_weak_alert_autodismiss_duration: 弱干扰弹窗正常多长时间后自动隐藏，默认6s
 *      tt_push_weak_alert_slipinto_direction: 弱干扰弹窗弹出方向
 *      tt_push_weak_alert_adjust_font_fit_width: 弱干扰弹窗是否允许调整字体适配，防止线上UI BUG
 *      tt_push_weak_alert_show_page_scope: 0 仅仅出现在feed中，1 出现在任何页面，除去视频全屏
 *  }
 */
@interface TTInAppPushSettings : NSObject

+ (void)parseInAppPushSettings:(NSDictionary *)settings;

+ (NSTimeInterval)weakAlertAnimationDuration;

+ (NSTimeInterval)weakAlertAutoDismissDuration;

+ (NSInteger)weakAlertAnimationSlideIntoDirection;

+ (BOOL)newAlertEnabled;

+ (BOOL)weakAlertAdjustsFontSizeToFitWidth;

+ (NSInteger)weakAlertShowPageScope; /** 默认是 0 */

@end
