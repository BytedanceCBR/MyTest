//
//  TTTopTabViewConfig.m
//  Article
//
//  Created by fengyadong on 16/4/12.
//
//

#import "TTTopTabViewConfig.h"

@implementation TTTopTabViewConfig

- (instancetype)init
{
    if (self = [super init])
    {
        self.height = 44.f;
        self.width = CGFLOAT_MIN;
        self.titleFont = 13.f;
        self.indicatorLineHeight = 1.f / [UIScreen mainScreen].scale;
        self.backgroundColorThemeKey = kColorBackground4;
        self.titleNormalColorThemeKey = kColorText1;
        self.titleHightLightColorThemeKey = kColorText4;
        self.indicatorBackgroundThemeKey = kColorText4;
        self.bottomLineBackgroundThemeKey = kColorLine1;
        self.indicatorLineMargin = 0;
        self.alignment = TTTopTabViewAlignmentCenter;
    }
    return self;
}

@end
