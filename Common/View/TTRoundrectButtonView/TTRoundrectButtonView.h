//
//  TTRoundrectButtonView.h
//  Article
//
//  Created by 冯靖君 on 15/6/10.
//
//
#import "SSThemed.h"

@interface TTRoundrectButtonView : SSViewBase

- (instancetype)initWithFrame:(CGRect)frame text:(NSString *)text image:(UIImage *)image;
- (CGFloat)imageViewLeft;

- (void)addAction:(SEL)action forTarget:(id)target;
- (UILabel *)getLabel;
- (UIImageView *)getImageView;
- (void)refreshLabelWithText:(NSString *)text;
- (void)refreshLabelWithTextColorString:(NSString *)newTextColorKey;
- (void)refreshLabelWithTextColor:(UIColor *)newTextColor;
- (void)refreshImageViewWithImage:(UIImage *)image;

@end