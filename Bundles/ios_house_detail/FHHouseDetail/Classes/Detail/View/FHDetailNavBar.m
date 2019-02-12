//
//  FHDetailNavBar.m
//  Pods
//
//  Created by 张静 on 2019/2/12.
//

#import "FHDetailNavBar.h"
#import "UIColor+Theme.h"
#import "Masonry.h"

@interface FHDetailNavBar ()

@property(nonatomic , strong) UIView *bgView;
@property(nonatomic , strong) UIButton *backBtn;
@property(nonatomic , strong) UIButton *collectBtn;
@property(nonatomic , strong) UIButton *shareBtn;
@property(nonatomic , strong) UIView *gradientView;

@end

@implementation FHDetailNavBar

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
    _bgView = [[UIView alloc]initWithFrame:self.bounds];
    _bgView.backgroundColor = [UIColor colorWithWhite:1 alpha:0];
    [self addSubview:_bgView];
    
    _gradientView = [[UIView alloc]initWithFrame:self.bounds];
    [self addSubview:_gradientView];
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.frame = _gradientView.bounds;
    gradientLayer.colors = @[(__bridge id)[UIColor colorWithRed:0 green:0 blue:0 alpha:1].CGColor,(__bridge id)[UIColor colorWithRed:0 green:0 blue:0 alpha:0].CGColor];
    gradientLayer.startPoint = CGPointMake(0, 0);
    gradientLayer.endPoint = CGPointMake(0, 1);
    [_gradientView.layer addSublayer:gradientLayer];

    _backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_backBtn setImage:[UIImage imageNamed:@"detail_back_white"] forState:UIControlStateNormal];
    [_backBtn setImage:[UIImage imageNamed:@"detail_back_white"] forState:UIControlStateHighlighted];
    [_backBtn addTarget:self action:@selector(backAction:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_backBtn];

    _collectBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_collectBtn setImage:[UIImage imageNamed:@"detail_collect_white"] forState:UIControlStateNormal];
    [_collectBtn setImage:[UIImage imageNamed:@"detail_collect_white"] forState:UIControlStateHighlighted];
    [_collectBtn addTarget:self action:@selector(collectAction:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_collectBtn];

    _shareBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_shareBtn setImage:[UIImage imageNamed:@"detail_share_white"] forState:UIControlStateNormal];
    [_shareBtn setImage:[UIImage imageNamed:@"detail_share_white"] forState:UIControlStateHighlighted];
    [_shareBtn addTarget:self action:@selector(shareAction:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_shareBtn];

    [_backBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(12);
        make.height.mas_equalTo(44);
        make.width.mas_equalTo(40);
        make.bottom.mas_equalTo(self);
    }];
    [_shareBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-12);
        make.height.mas_equalTo(44);
        make.width.mas_equalTo(40);
        make.bottom.mas_equalTo(self);
    }];
    [_collectBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.shareBtn.mas_left).mas_offset(-14);
        make.height.mas_equalTo(44);
        make.width.mas_equalTo(40);
        make.bottom.mas_equalTo(self);
    }];
}

- (void)refreshAlpha:(CGFloat)alpha
{
    _bgView.backgroundColor = [UIColor colorWithWhite:1 alpha:alpha];
    if (alpha > 0) {
        _gradientView.alpha = 0;
        UIImage *image = [UIImage imageNamed:@"detail_back_black"];
        [_backBtn setImage:[UIImage imageNamed:@"detail_back_black"] forState:UIControlStateNormal];
        [_backBtn setImage:[UIImage imageNamed:@"detail_back_black"] forState:UIControlStateHighlighted];
        [_collectBtn setImage:[UIImage imageNamed:@"detail_collect_black"] forState:UIControlStateNormal];
        [_collectBtn setImage:[UIImage imageNamed:@"detail_collect_black"] forState:UIControlStateHighlighted];
        [_shareBtn setImage:[UIImage imageNamed:@"detail_share_black"] forState:UIControlStateNormal];
        [_shareBtn setImage:[UIImage imageNamed:@"detail_share_black"] forState:UIControlStateHighlighted];
    }else {
        _gradientView.alpha = 1;
        [_backBtn setImage:[UIImage imageNamed:@"detail_back_white"] forState:UIControlStateNormal];
        [_backBtn setImage:[UIImage imageNamed:@"detail_back_white"] forState:UIControlStateHighlighted];
        [_collectBtn setImage:[UIImage imageNamed:@"detail_collect_white"] forState:UIControlStateNormal];
        [_collectBtn setImage:[UIImage imageNamed:@"detail_collect_white"] forState:UIControlStateHighlighted];
        [_shareBtn setImage:[UIImage imageNamed:@"detail_share_white"] forState:UIControlStateNormal];
        [_shareBtn setImage:[UIImage imageNamed:@"detail_share_white"] forState:UIControlStateHighlighted];
    }
}

- (void)backAction:(UIButton *)sender
{
    if (self.backActionBlock) {
        self.backActionBlock();
    }
}

- (void)collectAction:(UIButton *)sender
{
    if (self.collectActionBlock) {
        self.collectActionBlock();
    }
}

- (void)shareAction:(UIButton *)sender
{
    if (self.shareActionBlock) {
        self.shareActionBlock();
    }
}

@end
