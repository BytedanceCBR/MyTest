//
//  FHDetailNavBar.m
//  Pods
//
//  Created by 张静 on 2019/2/12.
//

#import "FHDetailNavBar.h"
#import "UIColor+Theme.h"
#import "Masonry.h"
#import "TTDeviceHelper.h"

@interface FHDetailNavBar ()

@property(nonatomic , strong) UIView *bgView;
@property(nonatomic , strong) UIButton *backBtn;
@property(nonatomic , strong) UIButton *collectBtn;
@property(nonatomic , strong) UIButton *shareBtn;
@property(nonatomic , strong) UIView *gradientView;
@property(nonatomic , strong) UIView *bottomLine;

@property(nonatomic , assign) CGFloat subAlpha;
@property(nonatomic , assign) NSInteger followStatus;

@property(nonatomic , strong) UIImage *collectBlackImage;
@property(nonatomic , strong) UIImage *collectWhiteImage;
@property(nonatomic , strong) UIImage *collectYellowImage;
@property(nonatomic , strong) UIImage *backBlackImage;
@property(nonatomic , strong) UIImage *backWhiteImage;
@property(nonatomic , strong) UIImage *shareBlackImage;
@property(nonatomic , strong) UIImage *shareWhiteImage;
@end

@implementation FHDetailNavBar

- (instancetype)initWithType:(FHDetailNavBarType)type
{
    CGRect screenBounds = [UIScreen mainScreen].bounds;
    CGFloat navBarHeight = [TTDeviceHelper isIPhoneXDevice] ? 44 : 20;
    CGRect frame = CGRectMake(0, 0, screenBounds.size.width, navBarHeight + 44);
    _type = type;
    self = [self initWithFrame:frame];
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)setType:(FHDetailNavBarType)type
{
    _type = type;
    if (_type == FHDetailNavBarTypeDefault) {
        [_shareBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(-12);
            make.height.mas_equalTo(44);
            make.width.mas_equalTo(40);
            make.bottom.mas_equalTo(self);
        }];
        [_collectBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(self.shareBtn.mas_left).mas_offset(-14);
            make.height.mas_equalTo(44);
            make.width.mas_equalTo(40);
            make.bottom.mas_equalTo(self);
        }];
        _shareBtn.hidden = NO;
    }else {
        [_collectBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(-12);
            make.height.mas_equalTo(44);
            make.width.mas_equalTo(40);
            make.bottom.mas_equalTo(self);
        }];
        _shareBtn.hidden = YES;
    }
}

- (void)hideFollowBtn
{
    self.collectBtn.hidden = YES;
}

- (void)removeBottomLine
{
    _bottomLine.hidden = YES;
    [_bottomLine removeFromSuperview];
}

- (void)setupUI
{
    _bgView = [[UIView alloc]initWithFrame:self.bounds];
    _bgView.backgroundColor = [UIColor colorWithWhite:1 alpha:0];
    [self addSubview:_bgView];
    
    _bottomLine = [[UIView alloc]init];
    _bottomLine.backgroundColor = [UIColor themeGray6];
    [_bgView addSubview:_bottomLine];
    _bottomLine.hidden = YES;

    _gradientView = [[UIView alloc]initWithFrame:self.bounds];
    [self addSubview:_gradientView];
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.frame = _gradientView.bounds;
    gradientLayer.colors = @[(__bridge id)[UIColor colorWithRed:0 green:0 blue:0 alpha:0.3].CGColor,(__bridge id)[UIColor colorWithRed:0 green:0 blue:0 alpha:0].CGColor];
    gradientLayer.startPoint = CGPointMake(0, 0);
    gradientLayer.endPoint = CGPointMake(0, 1);
    [_gradientView.layer addSublayer:gradientLayer];

    _backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_backBtn setImage:self.backWhiteImage forState:UIControlStateNormal];
    [_backBtn setImage:self.backWhiteImage forState:UIControlStateHighlighted];
    [_backBtn addTarget:self action:@selector(backAction:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_backBtn];

    _collectBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_collectBtn setImage:self.collectWhiteImage forState:UIControlStateNormal];
    [_collectBtn setImage:self.collectWhiteImage forState:UIControlStateHighlighted];
    [_collectBtn addTarget:self action:@selector(collectAction:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_collectBtn];

    [_backBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(12);
        make.height.mas_equalTo(44);
        make.width.mas_equalTo(40);
        make.bottom.mas_equalTo(self);
    }];
    if (_type == FHDetailNavBarTypeDefault) {
        [self addSubview:self.shareBtn];
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
    }else {
        [_collectBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(-12);
            make.height.mas_equalTo(44);
            make.width.mas_equalTo(40);
            make.bottom.mas_equalTo(self);
        }];
    }

    [_bottomLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.mas_equalTo(0);
        make.height.mas_equalTo(0.5);
    }];
}

- (void)refreshAlpha:(CGFloat)alpha
{
    _bgView.backgroundColor = [UIColor colorWithWhite:1 alpha:alpha];
    _subAlpha = alpha;
    if (alpha > 0) {
        _gradientView.alpha = 0;
        UIImage *image = self.followStatus ? self.collectYellowImage : self.collectBlackImage;
        [_backBtn setImage:self.backBlackImage forState:UIControlStateNormal];
        [_backBtn setImage:self.backBlackImage forState:UIControlStateHighlighted];
        [_collectBtn setImage:image forState:UIControlStateNormal];
        [_collectBtn setImage:image forState:UIControlStateHighlighted];
        [_shareBtn setImage:self.shareBlackImage forState:UIControlStateNormal];
        [_shareBtn setImage:self.shareBlackImage forState:UIControlStateHighlighted];
    }else {
        _gradientView.alpha = 1;
        UIImage *image = self.followStatus ? self.collectYellowImage : self.collectWhiteImage;
        [_backBtn setImage:self.backWhiteImage forState:UIControlStateNormal];
        [_backBtn setImage:self.backWhiteImage forState:UIControlStateHighlighted];
        [_collectBtn setImage:image forState:UIControlStateNormal];
        [_collectBtn setImage:image forState:UIControlStateHighlighted];
        [_shareBtn setImage:self.shareWhiteImage forState:UIControlStateNormal];
        [_shareBtn setImage:self.shareWhiteImage forState:UIControlStateHighlighted];
    }
    if (alpha >= 1) {
        _bottomLine.hidden = NO;
    }else {
        _bottomLine.hidden = YES;
    }
}


- (void)setFollowStatus:(NSInteger)followStatus
{
    _followStatus = followStatus;
    if (self.subAlpha > 0) {
        UIImage *image = self.collectBlackImage;
        image = followStatus != 0 ? self.collectYellowImage : image;
        [_collectBtn setImage:image forState:UIControlStateNormal];
        [_collectBtn setImage:image forState:UIControlStateHighlighted];
    }else {
        UIImage *image = self.collectWhiteImage;
        image = followStatus != 0 ? self.collectYellowImage : image;
        [_collectBtn setImage:image forState:UIControlStateNormal];
        [_collectBtn setImage:image forState:UIControlStateHighlighted];
    }
}

- (void)showRightItems:(BOOL)showItem
{
    self.shareBtn.hidden = !showItem;
    self.collectBtn.hidden = !showItem;
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

- (void)shareAction:(UIButton *)sender
{
    if (self.shareActionBlock) {
        self.shareActionBlock();
    }
}

- (UIButton *)shareBtn
{
    if (!_shareBtn) {
        _shareBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_shareBtn setImage:self.shareWhiteImage forState:UIControlStateNormal];
        [_shareBtn setImage:self.shareWhiteImage forState:UIControlStateHighlighted];
        [_shareBtn addTarget:self action:@selector(shareAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _shareBtn;
}

- (UIImage *)collectBlackImage
{
    if (!_collectBlackImage) {
        _collectBlackImage = [UIImage imageNamed:@"detail_collect_black"];
    }
    return _collectBlackImage;
}
- (UIImage *)collectWhiteImage
{
    if (!_collectWhiteImage) {
        _collectWhiteImage = [UIImage imageNamed:@"detail_collect_white"];
    }
    return _collectWhiteImage;
}
- (UIImage *)collectYellowImage
{
    if (!_collectYellowImage) {
        _collectYellowImage = [UIImage imageNamed:@"detail_collect_yellow"];
    }
    return _collectYellowImage;
}
- (UIImage *)backBlackImage
{
    if (!_backBlackImage) {
        _backBlackImage = [UIImage imageNamed:@"detail_back_black"];
    }
    return _backBlackImage;
}
- (UIImage *)backWhiteImage
{
    if (!_backWhiteImage) {
        _backWhiteImage = [UIImage imageNamed:@"detail_back_white"];
    }
    return _backWhiteImage;
}
- (UIImage *)shareBlackImage
{
    if (!_shareBlackImage) {
        _shareBlackImage = [UIImage imageNamed:@"detail_share_black"];
    }
    return _shareBlackImage;
}
- (UIImage *)shareWhiteImage
{
    if (!_shareWhiteImage) {
        _shareWhiteImage = [UIImage imageNamed:@"detail_share_white"];
    }
    return _shareWhiteImage;
}
@end
