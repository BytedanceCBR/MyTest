//
// Created by zhulijun on 2019-06-25.
//

#import <FHCommonUI/UIColor+Theme.h>
#import <Masonry/View+MASAdditions.h>
#import "FHCommunityUCGBubble.h"
#import "WDDefines.h"
#import "BDWebImage.h"


@interface FHCommunityUCGBubble ()
@property(nonatomic, strong) UILabel *label;
@property(nonatomic, strong) UIView *backView;
@end

@implementation FHCommunityUCGBubble

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    self.layer.cornerRadius = 10.0f;
    self.backgroundColor = [[UIColor themeRed3] colorWithAlphaComponent:0.1];
    [self initViews];
    [self initConstraints];
}

- (void)initViews {

    _label = [[UILabel alloc] init];
    _label.textColor = [UIColor colorWithHexStr:@"#9c6d43"];
    _label.backgroundColor = [UIColor clearColor];
    _label.font = [UIFont systemFontOfSize:10.0f];
    _label.numberOfLines = 1;
    _label.preferredMaxLayoutWidth = 140;
    [self addSubview:_label];
}

- (void)initConstraints {
    [_label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self).offset(4);
        make.centerY.mas_equalTo(self);
        make.height.mas_equalTo(14);
        make.right.mas_equalTo(self).offset(-4);
    }];
}

- (CGFloat)refreshWithAvatar:(NSString *)icon title:(NSString *)title color:(UIColor *)color{
    if (isEmptyString(icon) || isEmptyString(title)) {
        return 0.0f;
    }
    self.label.text = title;
    self.label.textColor = color;
    CGSize preferSize = [self.label sizeThatFits:CGSizeMake(140, 14)];
    CGFloat labelSize = fminf(140, preferSize.width);
    return labelSize;
}

- (void)setBacColor:(UIColor *)bacColor {
    self.backgroundColor = bacColor;
}
- (void)setCornerRadius:(CGFloat)cornerRadius {
    self.layer.cornerRadius = cornerRadius;
}
@end
