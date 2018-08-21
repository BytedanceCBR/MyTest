//
//  SSThemed.h
//  Article

//  Created by 苏瑞强 on 17/3/10.
//  Copyright © 2017年 苏瑞强. All rights reserved.
//


#import <UIKit/UIKit.h>
#import "SSViewBase.h"


//nick add for comom lib

#import "TTBaseMacro.h"
#import "TTThemeConst.h"
#import "UIColor+TTThemeExtension.h"

extern UIWindow *SSGetMainWindow(void);
/// 第一个日间，第二个夜间
#define SSThemedColors(color1, color2) @[ [UIColor colorWithHexString:color1], [UIColor colorWithHexString:color2] ];

//与UIColor重复
extern UIColor *SSGetThemedColorInArray(NSArray *themeArray);
extern UIColor *SSGetThemedColorWithKey(NSString *key);

extern UIColor *SSGetThemedColorUsingArrayOrKey(NSArray *themeArray, NSString *key);

/// PS. colors 中保存日间+夜间的颜色， themeKey 会根据日间和夜间去读取配置文件中的颜色, 如果同时设置，则 数组中的优先

typedef NS_ENUM(NSUInteger, SSThemeMode) {
    SSThemeModeNone,//跟随系统日夜间模式自动变化
    SSThemeModeAlwaysDay,//日夜间模式永远是日间
    SSThemeModeAlwaysNight,//日夜间模式永远是夜间
};

@interface SSThemedView : SSViewBase

@property(nonatomic, copy) NSArray *backgroundColors;
@property(nonatomic, copy) IBInspectable NSString *backgroundColorThemeKey;
@property(nonatomic, copy) IBInspectable NSString *borderColorThemeKey;
@property(nonatomic, assign) IBInspectable BOOL separatorAtTOP;
@property(nonatomic, assign) IBInspectable BOOL separatorAtBottom;
@property(nonatomic, assign) IBInspectable BOOL separatorAtLeft;
@property(nonatomic, assign) IBInspectable BOOL separatorAtRight;
@property(nonatomic, assign) BOOL needMargin;
@property(nonatomic, assign) SSThemeMode themeMode;

@end

@interface SSThemedScrollView : UIScrollView

@property(nonatomic, copy) IBInspectable NSString *backgroundColorThemeKey;

@end

@interface SSThemedImageView : UIImageView

@property(nonatomic, copy) IBInspectable NSString *imageName;
@property(nonatomic, copy) IBInspectable NSString *highlightedImageName;
@property(nonatomic, copy) IBInspectable NSString *tintColorThemeKey;
@property(nonatomic, copy) IBInspectable NSString *hightlightedTintColorThemeKey;
@property(nonatomic, assign) IBInspectable BOOL enableNightCover;
@property(nonatomic) CGSize preferredContentSize;

@end

@interface SSThemedTextField : UITextField

@property(nonatomic, copy) IBInspectable NSString *textColorThemeKey;
@property(nonatomic, copy) IBInspectable NSString *placeholderColorThemeKey;
@property(nonatomic, copy) IBInspectable NSString *borderColorThemeKey;
@property(nonatomic, copy) IBInspectable NSString *backgroundColorThemeKey;
@property(nonatomic, copy) IBInspectable NSDictionary *placeholderAttributedDict;

@property (nonatomic, assign) UIEdgeInsets edgeInsets;

@end

@interface SSThemedTextView : UITextView
@property(nonatomic, copy) IBInspectable NSString *borderColorThemeKey;
@property(nonatomic, copy) IBInspectable NSString *textColorThemeKey;
@property(nonatomic, copy) IBInspectable NSString *placeholderColorThemeKey;
@property(nonatomic, copy) IBInspectable NSString *backgroundColorThemeKey;
@end

typedef enum {
    ArticleVerticalAlignmentTop,
    ArticleVerticalAlignmentMiddle, // default
    ArticleVerticalAlignmentBottom,
} ArticleVerticalAlignment;

extern NSString * const kSSThemedLabelText;
@interface SSThemedLabel : UILabel

/// 垂直方向上的对其方式
@property(nonatomic, assign) ArticleVerticalAlignment verticalAlignment;
/// 第一个日间，第二个夜间, must be colors
@property(nonatomic, copy) NSArray *textColors;
@property(nonatomic, copy) NSArray *backgroundColors;
@property(nonatomic, copy) NSArray *borderColors;
@property(nonatomic, assign) UIEdgeInsets contentInset;
@property(nonatomic, copy) IBInspectable NSString *textColorThemeKey;
@property(nonatomic, copy) IBInspectable NSString *backgroundColorThemeKey;
@property(nonatomic, copy) IBInspectable NSString *borderColorThemeKey;
/*
 支持 UILabel 的 attributedText 随主题变化，
 attributedTextInfo 结构如下：
 
 @{kSSThemedLabelText : @"titleBalabalabala",
 @"[2, 3]" :          kColorText5,
 @"[7, 2]" :          kColorText2
 }
 其中 kSSThemedLabelText 可以穿入NSAttributedString
 */
@property (nonatomic, copy) NSDictionary *attributedTextInfo;

@end

@interface SSThemedButton : UIButton

@property(nonatomic, copy) NSArray *titleColors;
@property(nonatomic, copy) NSArray *highlightedTitleColors;

@property(nonatomic, copy) IBInspectable NSString *titleColorThemeKey;
@property(nonatomic, copy) IBInspectable NSString *highlightedTitleColorThemeKey;
@property(nonatomic, copy) IBInspectable NSString *selectedTitleColorThemeKey;
@property(nonatomic, copy) IBInspectable NSString *disabledTitleColorThemeKey;
@property(nonatomic, copy) NSArray *borderColors;
@property(nonatomic, copy) NSArray *highlightedBorderColors;
@property(nonatomic, copy) IBInspectable NSString *borderColorThemeKey;
@property(nonatomic, copy) IBInspectable NSString *disabledBorderColorThemeKey;
@property(nonatomic, copy) IBInspectable NSString *highlightedBorderColorThemeKey;
@property(nonatomic, copy) NSArray *backgroundColors;
@property(nonatomic, copy) NSArray *disabledBackgroundColors;
@property(nonatomic, copy) NSArray *highlightedBackgroundColors;
@property(nonatomic, copy) IBInspectable NSString *backgroundColorThemeKey;
@property(nonatomic, copy) IBInspectable NSString *disabledBackgroundColorThemeKey;
@property(nonatomic, copy) IBInspectable NSString *highlightedBackgroundColorThemeKey;
@property(nonatomic, copy) IBInspectable NSString *imageName;
@property(nonatomic, copy) IBInspectable NSString *selectedImageName;
@property(nonatomic, copy) IBInspectable NSString *highlightedImageName;
@property(nonatomic, copy) IBInspectable NSString *backgroundImageName;
@property(nonatomic, copy) IBInspectable NSString *highlightedBackgroundImageName;
@property(nonatomic, copy) IBInspectable NSString *tintColorThemeKey;
@property(nonatomic, copy) IBInspectable NSString *highlightedTintColorThemeKey;
@property(nonatomic, copy) IBInspectable NSString *selectedTintColorThemeKey;

@end

@interface SSThemedTableView : UITableView

@property(nonatomic, copy) NSArray *backgroundColors;
@property(nonatomic, copy) IBInspectable NSString *backgroundColorThemeKey;
@property(nonatomic, copy) IBInspectable NSString *separatorColorThemeKey;
@property(nonatomic, copy) IBInspectable NSString *separatorSecondColorThemeKey;
@property(nonatomic, assign) IBInspectable CGFloat separatorInsetLeft;

@property(nonatomic, assign) IBInspectable BOOL enableTTStyledSeparator;
@property(nonatomic, assign) IBInspectable BOOL disableTTStyledSeparatorEdge;//去掉每个section尾部以及头部的分割线
@end

@interface TTThemedSplitView : SSViewBase
// 子view都放在contentView上,contentView在iPad上会留白.
@property (nonatomic, strong) SSThemedView *contentView;
@property (nonatomic, assign) BOOL needMargin;
@end

@interface SSThemedTableViewCell : UITableViewCell

@property(nonatomic, copy) IBInspectable NSString *backgroundColorThemeKey;
@property(nonatomic, copy) IBInspectable NSString *backgroundSelectedColorThemeKey;
@property(nonatomic, copy) IBInspectable NSString *separatorColorThemeKey;
@property(nonatomic, assign) IBInspectable CGFloat separatorThemeInsetLeft;
@property(nonatomic, assign) IBInspectable CGFloat separatorThemeInsetRight;
@property(nonatomic, assign) IBInspectable BOOL separatorAtTOP;
@property(nonatomic, assign) IBInspectable BOOL separatorAtBottom;

@property(nonatomic, strong) NSIndexPath * cellIndex;
@property(nonatomic, weak) IBInspectable SSThemedTableView * tableView;

@property(nonatomic, assign) IBInspectable BOOL needMargin;
- (void)themeChanged:(NSNotification*)notification;

@end

@interface UIResponder (SSNextResponder)

/**
 * @abstract 递归查找view的nextResponder，直到找到类型为class的Responder
 *
 * @param aClass nextResponder 的 class
 * @return       第一个满足类型为class的UIResponder
 */
- (UIResponder *)ss_nextResponderWithClass:(Class)aClass;

@end
