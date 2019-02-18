//
//  TTColorAsFollowButton.m
//  Article
//
//  Created by lipeilun on 2017/8/1.
//
//

#import "TTColorAsFollowButton.h"
#import <TTUGCAttributedLabel.h>
#import <TTThemed/TTThemeManager.h>
#import <TTKitchen/TTKitchen.h>

@implementation TTColorAsFollowButton

- (void)setTitleColorThemeKey:(NSString *)titleColorThemeKey {
    NSString *themeKey = titleColorThemeKey;
    if ([self followButtonColorStyleIsRed]
        && ([themeKey isEqualToString:kColorText5] || [themeKey isEqualToString:kColorText6])) {
        themeKey = kColorText4;
    }
    [super setTitleColorThemeKey:themeKey];
}

- (void)setBackgroundColorThemeKey:(NSString *)backgroundColorThemeKey {
    NSString *themeKey = [self followButtonColorStyleIsRed] ? kColorBackground7 : backgroundColorThemeKey;
    [super setBackgroundColorThemeKey:themeKey];
}

- (void)setBackgroundColor:(UIColor *)backgroundColor enabled:(BOOL)enabled {
    [self setBackgroundColor:backgroundColor borderColor:nil enabled:enabled];
}

- (void)setBackgroundColor:(UIColor *)backgroundColor borderColor:(UIColor *)borderColor enabled:(BOOL)enabled {
    UIColor *finalBackgroundColor = backgroundColor;
    UIColor *finalBorderColor = borderColor;
    BOOL dayMode = [[TTThemeManager sharedInstance_tt] currentThemeMode] == TTThemeModeDay;
    if ([self followButtonColorStyleIsRed] && enabled) {
        finalBackgroundColor = dayMode ? [UIColor colorWithHexString:@"f85959"] : [UIColor colorWithHexString:@"935656"];
        finalBorderColor = finalBackgroundColor;
    } else if ([self followButtonColorStyleIsRed]) {
        finalBackgroundColor = dayMode ? [[UIColor colorWithHexString:@"f45c5d"] colorWithAlphaComponent:0.6] : [[UIColor colorWithHexString:@"935656"] colorWithAlphaComponent:0.6];
        finalBorderColor = dayMode ? [UIColor colorWithHexString:@"f45c5d"] : [UIColor colorWithHexString:@"935656"];
    }
    [super setBackgroundColor:finalBackgroundColor];
    if (finalBorderColor) {
        self.layer.borderColor = finalBorderColor.CGColor;
    }
}

- (BOOL)followButtonColorStyleIsRed {
    NSString *colorStyle = [TTKitchen getString:kTTKUGCFollowButtonColorStyle];

    return [colorStyle isEqualToString:@"red"];
}

@end
