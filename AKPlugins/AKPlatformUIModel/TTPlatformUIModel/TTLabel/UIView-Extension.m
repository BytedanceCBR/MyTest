//
//  UIView-Extension.m
//  Article
//
//  Created by 杨心雨 on 16/9/20.
//
//

#import "UIView-Extension.h"
#import "TTThemeManager.h"

#pragma mark - Theme 模式相关
@implementation UIView (Theme)

- (void)tt_addThemeNotification {
    if ([NSThread isMainThread]) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tt_selfThemeChanged:) name:TTThemeManagerThemeModeChangedNotification object:nil];
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tt_selfThemeChanged:) name:TTThemeManagerThemeModeChangedNotification object:nil];
        });
    }
}

- (void)tt_removeThemeNotification {
    if ([NSThread isMainThread]) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:TTThemeManagerThemeModeChangedNotification object:nil];
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] removeObserver:self name:TTThemeManagerThemeModeChangedNotification object:nil];
        });
    }
}

- (void)tt_selfThemeChanged:(NSNotification *)notification {}

- (void)themeChanged:(NSNotification *)notification {}

@end
