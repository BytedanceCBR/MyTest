//
//  TTBadgeNumberView.h
//  Zhidao
//
//  Created by Nick Yu on 3/3/15.
//  Copyright (c) 2015 Nick Yu. All rights reserved.
//


#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, TTBadgeNumberViewStyle)
{
    TTBadgeNumberViewStyleDefault,
    TTBadgeNumberViewStyleWhite,
    TTBadgeNumberViewStyleDefaultWithBorder,
    TTBadgeNumberViewStyleProfile
};

@interface TTBadgeNumberView : UIView

@property (nonatomic, copy) NSString *badgeValue;
@property (nonatomic, assign) NSInteger badgeNumber;

@property (nonatomic, strong) IBInspectable NSString * backgroundColorThemeKey;
@property (nonatomic, strong) IBInspectable NSString * badgeTextColorThemeKey;
@property (nonatomic, strong) IBInspectable NSString * badgeBorderColorThemeKey;

@property (nonatomic, assign) IBInspectable NSUInteger badgeViewStyle;
@property (nonatomic, assign) NSUInteger lastBadgeViewStyle;//被选中之前的样式

- (void)setBadgeLabelFontSize:(CGFloat)sizeNum;

@end


extern const NSInteger TTBadgeNumberPoint;  // 显示一个无数字的提示点
extern const NSInteger TTBadgeNumberHidden; // 不显示，清楚提升点
extern const NSInteger TTBadgeNumberMore;  //显示...

// 0: nil, TTBadgeNubmerPoint: @"", 其他是啥就是啥，大于99会自动转为@"99+"
extern NSString *TTBadgeValueStringFromInteger(NSInteger number);

