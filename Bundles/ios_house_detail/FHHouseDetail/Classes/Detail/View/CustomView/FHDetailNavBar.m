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
@property(nonatomic , strong) UIButton *messageBtn;
@property(nonatomic , strong) UIImageView *messageDot;
@property(nonatomic , strong) UIView *gradientView;

@property(nonatomic , assign) CGFloat subAlpha;
@property(nonatomic , assign) BOOL followStatus;

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
    gradientLayer.colors = @[(__bridge id)[UIColor colorWithRed:0 green:0 blue:0 alpha:0.3].CGColor,(__bridge id)[UIColor colorWithRed:0 green:0 blue:0 alpha:0].CGColor];
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
    
    _messageBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_messageBtn setImage:[UIImage imageNamed:@"detail_message_white"] forState:UIControlStateNormal];
    [_messageBtn setImage:[UIImage imageNamed:@"detail_message_white"] forState:UIControlStateHighlighted];
    [_messageBtn addTarget:self action:@selector(messageAction:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_messageBtn];

    _shareBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_shareBtn setImage:[UIImage imageNamed:@"detail_share_white"] forState:UIControlStateNormal];
    [_shareBtn setImage:[UIImage imageNamed:@"detail_share_white"] forState:UIControlStateHighlighted];
    [_shareBtn addTarget:self action:@selector(shareAction:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_shareBtn];
    
    _messageDot = [[UIImageView alloc] init];
    _messageDot.hidden = YES;
    [_messageDot setImage:[UIImage imageNamed:@"detail_message_dot"]];
    [self addSubview:_messageDot];

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
    [_messageBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.shareBtn.mas_left).mas_offset(-12);
        make.height.mas_equalTo(44);
        make.width.mas_equalTo(40);
        make.bottom.mas_equalTo(self);
    }];
    [_collectBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.messageBtn.mas_left).mas_offset(-12);
        make.height.mas_equalTo(44);
        make.width.mas_equalTo(40);
        make.bottom.mas_equalTo(self);
    }];
    [_messageDot mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.messageBtn).offset(-5);
        make.height.mas_equalTo(10);
        make.width.mas_equalTo(10);
        make.top.mas_equalTo(self.messageBtn).offset(10);
    }];
}

- (void)refreshAlpha:(CGFloat)alpha
{
    _subAlpha = alpha;
    _bgView.backgroundColor = [UIColor colorWithWhite:1 alpha:alpha];
    if (alpha > 0) {
        _gradientView.alpha = 0;
        UIImage *image = [UIImage imageNamed:@"detail_collect_black"];
        image = self.followStatus ? [UIImage imageNamed:@"detail_collect_yellow"] : image;
        [_backBtn setImage:[UIImage imageNamed:@"detail_back_black"] forState:UIControlStateNormal];
        [_backBtn setImage:[UIImage imageNamed:@"detail_back_black"] forState:UIControlStateHighlighted];
        [_collectBtn setImage:image forState:UIControlStateNormal];
        [_collectBtn setImage:image forState:UIControlStateHighlighted];
        [_messageBtn setImage:[UIImage imageNamed:@"detail_message_black"] forState:UIControlStateNormal];
        [_messageBtn setImage:[UIImage imageNamed:@"detail_message_black"] forState:UIControlStateHighlighted];
        [_shareBtn setImage:[UIImage imageNamed:@"detail_share_black"] forState:UIControlStateNormal];
        [_shareBtn setImage:[UIImage imageNamed:@"detail_share_black"] forState:UIControlStateHighlighted];
    }else {
        _gradientView.alpha = 1;
        UIImage *image = [UIImage imageNamed:@"detail_collect_white"];
        image = self.followStatus ? [UIImage imageNamed:@"detail_collect_yellow"] : image;
        [_backBtn setImage:[UIImage imageNamed:@"detail_back_white"] forState:UIControlStateNormal];
        [_backBtn setImage:[UIImage imageNamed:@"detail_back_white"] forState:UIControlStateHighlighted];
        [_collectBtn setImage:image forState:UIControlStateNormal];
        [_collectBtn setImage:image forState:UIControlStateHighlighted];
        [_messageBtn setImage:[UIImage imageNamed:@"detail_message_white"] forState:UIControlStateNormal];
        [_messageBtn setImage:[UIImage imageNamed:@"detail_message_white"] forState:UIControlStateHighlighted];
        [_shareBtn setImage:[UIImage imageNamed:@"detail_share_white"] forState:UIControlStateNormal];
        [_shareBtn setImage:[UIImage imageNamed:@"detail_share_white"] forState:UIControlStateHighlighted];
    }
}

- (void)setFollowStatus:(BOOL)followStatus
{
    _followStatus = followStatus;
    if (self.subAlpha > 0) {
        UIImage *image = [UIImage imageNamed:@"detail_collect_black"];
        image = followStatus ? [UIImage imageNamed:@"detail_collect_yellow"] : image;
        [_collectBtn setImage:image forState:UIControlStateNormal];
        [_collectBtn setImage:image forState:UIControlStateHighlighted];
    }else {
        UIImage *image = [UIImage imageNamed:@"detail_collect_white"];
        image = followStatus ? [UIImage imageNamed:@"detail_collect_yellow"] : image;
        [_collectBtn setImage:image forState:UIControlStateNormal];
        [_collectBtn setImage:image forState:UIControlStateHighlighted];
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
        self.collectActionBlock(self.followStatus);
    }
}

- (void)messageAction:(UIButton *)sender
{
    if (self.messageActionBlock) {
        self.messageActionBlock();
    }
}

- (void)shareAction:(UIButton *)sender
{
    if (self.shareActionBlock) {
        self.shareActionBlock();
    }
}

- (void)displayMessageDot:(BOOL)show {
    self.messageDot.hidden = !show;
}

@end
