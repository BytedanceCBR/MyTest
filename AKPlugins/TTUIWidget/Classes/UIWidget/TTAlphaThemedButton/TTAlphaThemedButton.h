//
//  TTAlphaThemedButton.h
//  Article
//
//  Created by 王双华 on 15/10/22.
//
//

#import "SSThemed.h"

@interface TTAlphaThemedButton : SSThemedButton

/**
 *  YES开启夜间模式下遮罩，default NO
 */
@property (nonatomic) BOOL enableNightMask;

/**
 *  YES button image 切为圆形，default NO，应该在设置enableNightMask之前设置
 */
@property (nonatomic) BOOL enableRounded;

/**
 *  YES点击时有个alpha动画，default YES
 */
@property (nonatomic) BOOL enableHighlightAnim;

@property (nonatomic) CGFloat borderWidth;

@end
