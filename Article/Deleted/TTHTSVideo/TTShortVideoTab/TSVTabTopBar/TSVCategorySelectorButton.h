//
//  TSVCategorySelectorButton.h
//  Article
//
//  Created by 王双华 on 2017/10/27.
//

#import <UIKit/UIKit.h>
#import <TTPlatformUIModel/TTCategory.h>
#import "TTGlowLabel.h"

typedef void(^TSVCategorySelectorButtonTapBlock)();

@interface TSVCategorySelectorButton : UIView

@property (nonatomic, strong) TTGlowLabel *titleLabel;
@property (nonatomic, strong) TTGlowLabel *maskTitleLabel;
@property (nonatomic, copy) TSVCategorySelectorButtonTapBlock tapBlock;

- (void)setSelected:(BOOL)selected animated:(BOOL)animated;

- (instancetype)initWithFrame:(CGRect)frame
                   textColors:(NSArray<NSString *> *)textColors
               textGlowColors:(NSArray<NSString *> *)textGlowColors
                 textGlowSize:(CGFloat)glowSize;

- (void)setText:(NSString*)text;

+ (CGFloat)buttonWidthForText:(NSString *)text buttonCount:(NSInteger)buttonCount;

+ (CGFloat)channelFontSize;
+ (CGFloat)channelSelectedFontSize;

@end
