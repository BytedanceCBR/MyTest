//
// Created by zhulijun on 2019-06-25.
//

#import <FHCommonUI/UIColor+Theme.h>
#import <Masonry/View+MASAdditions.h>
#import "FHCommunitySuggestionBubble.h"
#import "WDDefines.h"
#import "BDWebImage.h"


@interface FHCommunitySuggestionBubble ()
@property(nonatomic, strong) UIImageView *iconView;
@property(nonatomic, strong) UILabel *label;
@property(nonatomic, strong) UIView *backView;
@end

@implementation FHCommunitySuggestionBubble

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
    _iconView = [[UIImageView alloc] init];
    _iconView.layer.cornerRadius = 7.0f;
    _iconView.layer.borderWidth = 0.5f;
    _iconView.layer.borderColor = [UIColor themeRed3].CGColor;
    _iconView.clipsToBounds = YES;

    _label = [[UILabel alloc] init];
    _label.textColor = [UIColor themeRed1];
    _label.backgroundColor = [UIColor clearColor];
    _label.font = [UIFont systemFontOfSize:10.0f];
    _label.numberOfLines = 1;

    [self addSubview:_iconView];
    [self addSubview:_label];
}

- (void)initConstraints {
    [_iconView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self).offset(4);
        make.centerY.mas_equalTo(self);
        make.width.height.mas_equalTo(14);
    }];

    [_label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(_iconView.mas_right).offset(2);
        make.centerY.mas_equalTo(self);
        make.height.mas_equalTo(14);
        make.right.mas_equalTo(self).offset(-4);
    }];
}

- (void)refreshWithAvatar:(NSString *)icon title:(NSString *)title {
    if (isEmptyString(icon) || isEmptyString(title)) {
        return;
    }

    [self.iconView bd_setImageWithURL:[NSURL URLWithString:icon]];
    self.label.text = title;
    CGSize preferSize = [self.label sizeThatFits:CGSizeMake(140, 14)];
    CGFloat size = fminf(140, preferSize.width);
    [self.label mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(size);
    }];
}
@end
