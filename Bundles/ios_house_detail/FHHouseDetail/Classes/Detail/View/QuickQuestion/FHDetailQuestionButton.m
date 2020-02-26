//
//  FHDetailQuestionButton.m
//  FHBAccount
//
//  Created by 张静 on 2019/10/14.
//

#import "FHDetailQuestionButton.h"
#import <TTBaseLib/UIViewAdditions.h>
#import <FHHouseBase/UIImage+FIconFont.h>
#import <FHCommonUI/UIColor+Theme.h>
#import <FHCommonUI/FHRoundShadowView.h>
#import <FHCommonUI/UIFont+House.h>
#import "Masonry.h"


@implementation FHDetailQuestionInternalButton

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.isFold = NO;
    }
    return self;
}

- (BOOL)isHighlighted
{
    return NO;
}

- (void)setIsFold:(BOOL)isFold
{
    _isFold = isFold;
    if (isFold) {
        [self setImage:self.foldImage forState:UIControlStateNormal];
    } else {
        [self setImage:self.unfoldImage forState:UIControlStateNormal];
    }
}


- (UIImage *)foldImage
{
    if (!_foldImage) {
        _foldImage = ICON_FONT_IMG(14, @"\U0000e67f", [UIColor themeRed1]);
    }
    return _foldImage;
}

- (UIImage *)unfoldImage
{
    if (!_unfoldImage) {
        _unfoldImage = ICON_FONT_IMG(14, @"\U0000e677", [UIColor themeRed1]);
    }
    return _unfoldImage;
}


@end

@interface FHDetailQuestionButton ()

@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) FHRoundShadowView *roundShadow;

@end

@implementation FHDetailQuestionButton

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI
{
    [self addSubview:self.roundShadow];
    [self addSubview:self.containerView];
    [self.containerView addSubview:self.btn];
    self.isFold = NO;
    self.btn.titleLabel.font = [UIFont themeFontSemibold:14];
    [self.btn setTitleColor:[UIColor themeGray1] forState:UIControlStateNormal];
    [self.btn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(10);
        make.centerY.mas_equalTo(self);
        make.right.mas_equalTo(-10);
        make.height.mas_equalTo(36);
    }];
    [self.roundShadow mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.containerView);
    }];
    [self.containerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.mas_equalTo(2);
        make.right.bottom.mas_equalTo(-2);
    }];
}

- (void)setIsFold:(BOOL)isFold
{
    _isFold = isFold;
    self.btn.isFold = isFold;
}

- (void)updateTitle:(NSString *)title
{
    [self.btn setTitle:title forState:UIControlStateNormal];
    [self.btn sizeToFit];
    
}

- (CGFloat)totalWidth
{
    return 20 + self.btn.width + 4;
}

- (FHDetailQuestionInternalButton *)btn
{
    if (!_btn) {
        _btn = [[FHDetailQuestionInternalButton alloc]init];
    }
    return _btn;
}

- (UIView *)containerView
{
    if (!_containerView) {
        _containerView = [[UIView alloc]init];
        _containerView.layer.borderWidth = 0.5;
        _containerView.layer.borderColor = [UIColor themeGray6].CGColor;
        _containerView.layer.cornerRadius = 4;
        _containerView.layer.masksToBounds = YES;
    }
    return _containerView;
}

- (FHRoundShadowView *)roundShadow
{
    if (!_roundShadow) {
        _roundShadow = [[FHRoundShadowView alloc] initWithFrame:CGRectZero];
        _roundShadow.layer.shadowColor = [[UIColor colorWithHexString:@"#000000" alpha:0.1] CGColor];
    }
    return _roundShadow;
}

@end
