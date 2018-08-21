//
//  TTTintThemeButton.h
//  Article
//
//  Created by 王双华 on 15/8/26.
//
//
#import "SSThemed.h"

@interface TTTintThemeButton : SSThemedButton

/**
 *  YES点击时有个alpha动画，default YES
 */
@property (nonatomic, assign) BOOL enableHighlightAnim;
/**
 *  图片日间和夜间的颜色themeKey
 */
@property (nonatomic, copy) NSString *imageColorThemeKey;
/**
 *  选取态图片日间和夜间颜色themeKey
 */
@property (nonatomic, copy) NSString *selectedImageColorThemeKey;
/**
 *  不可选取态图片日间和夜间颜色themeKey
 */
@property (nonatomic, copy) NSString *disabledImageColorThemeKey;
/**
 *  图片日间和夜间的颜色数组，仅在themeKey无法使用时设置，优先级高于themeKey
 */
@property (nonatomic, copy) NSArray *imageColors;
/**
 *  选取态图片日间和夜间的颜色数组，仅在themeKey无法使用时设置，优先级高于themeKey
 */
@property (nonatomic, copy) NSArray *selectedImageColors;
/**
 *  不可选取态图片日间和夜间颜色数组，仅在themeKey无法使用时设置，优先级高于themeKey
 */
@property (nonatomic, copy) NSArray *disabledImageColors;
@end
