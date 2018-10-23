//
//  TTColorAsFollowButton.h
//  Article
//
//  Created by lipeilun on 2017/8/1.
//
//

#import <TTUIWidget/TTAlphaThemedButton.h>


@interface TTColorAsFollowButton : TTAlphaThemedButton

- (void)setBackgroundColor:(UIColor *)backgroundColor enabled:(BOOL)enabled;


/**
 需要特殊设置颜色的，比如猛推人

 @param backgroundColor 颜色
 @param borderColor 边颜色
 @param enabled 是否enable状态(比如猛推人的选中人和选中0人)
 */
- (void)setBackgroundColor:(UIColor *)backgroundColor borderColor:(UIColor *)borderColor enabled:(BOOL)enabled;

@end
