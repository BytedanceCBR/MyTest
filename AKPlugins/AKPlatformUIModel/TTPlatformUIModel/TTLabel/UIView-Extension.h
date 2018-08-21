//
//  UIView-Extension.h
//  Article
//
//  Created by 杨心雨 on 16/9/20.
//
//

#import <UIKit/UIKit.h>

#pragma mark - Theme 模式相关
/** 模式相关 */
@interface UIView (Theme)

/** 添加通知 */
- (void)tt_addThemeNotification;

/** 移除通知 */
- (void)tt_removeThemeNotification;

/** 切换模式事件 */
- (void)tt_selfThemeChanged:(NSNotification * _Nullable)notification;

/** 切换模式额外事件 */
- (void)themeChanged:(NSNotification * _Nullable)notification;

@end
