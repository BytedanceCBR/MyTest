//
//  FHHouseDislikeTag.m
//  FHHouseHome
//
//  Created by 谢思铭 on 2019/7/23.
//

#import "FHHouseDislikeTag.h"
#import "TTThemeConst.h"
#import "UIColor+TTThemeExtension.h"
#import "TTDeviceHelper.h"
#import "TTThemeManager.h"
#import "TTDeviceUIUtils.h"
#import "UIColor+Theme.h"
#import "UIFont+House.h"
#import "UIButton+TTAdditions.h"

#define kCornerRadius 4.f

@interface FHHouseDislikeTag ()

@property(nonatomic,strong)CAShapeLayer *borderLayer;

@end

@implementation FHHouseDislikeTag

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        [self.titleLabel setFont:[UIFont themeFontRegular:[self fontSizeForTag]]];
        self.layer.cornerRadius = kCornerRadius;
        
        self.layer.borderWidth = 1.0f;
        
        self.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        
        [self setTitleColor:[UIColor themeGray3] forState:UIControlStateNormal];
        [self setTitleColor:[UIColor themeOrange1] forState:UIControlStateSelected];
        
        [self refreshBorder];
    }
    return self;
}

- (void)setDislikeWord:(FHHouseDislikeWord *)word {
    _dislikeWord = word;
    [self setTitle:word.name forState:UIControlStateNormal];
    self.selected = _dislikeWord.isSelected;
}

+ (CGFloat)tagHeight {
    return 29.0f;
}

- (CGFloat)minTagWidth {
    return 60.0f;
}

- (CGFloat)maxTagWidth {
    return [UIScreen mainScreen].bounds.size.width - 80;
}

- (CGFloat)fontSizeForTag {
    return 12.0f;
}

- (void)refreshBorder {
    if (self.isSelected) {
        self.layer.borderColor = [UIColor themeRed1].CGColor;
    } else {
        self.layer.borderColor = [UIColor colorWithHexStr:@"f2f4f5"].CGColor;
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _borderLayer.path = [UIBezierPath bezierPathWithRoundedRect:self.bounds cornerRadius:kCornerRadius].CGPath;
    _borderLayer.frame = self.bounds;
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    [self refreshBorder];
}

- (CGFloat)tagWidth {
    CGSize size = [self sizeThatFits:CGSizeMake([self maxTagWidth], [FHHouseDislikeTag tagHeight])];
    return size.width + 12;
}

@end
