//
//  FHPushAuthorizeAlertView.m
//  FHCHousePush
//
//  Created by 张静 on 2019/5/22.
//

#import "FHPushAuthorizeAlertView.h"
#import <FHCommonUI/UIColor+Theme.h>
#import <FHCommonUI/UIFont+House.h>
#import <FHCommonUI/UIView+House.h>
#import "Masonry.h"
#import <FHHouseBase/UIImage+FIconFont.h>

@interface FHPushAuthorizeAlertView ()

@property(nonatomic , strong) UIView *bgView;
@property(nonatomic , strong) UIView *contentView;
@property(nonatomic , strong) UILabel *titleLabel;
@property(nonatomic , strong) UILabel *subtitleLabel;
@property(nonatomic , strong) UIButton *closeBtn;
@property(nonatomic , strong) UIImageView *imgView;
@property(nonatomic , strong) UIButton *submitBtn;
@property(nonatomic , copy) FHPushAuthorizeHintComplete completed;

@end

@implementation FHPushAuthorizeAlertView

- (instancetype)initAuthorizeHintWithImageName:(NSString *)imageName
                                         title:(NSString *)title
                                       message:(NSString *)message
                               confirmBtnTitle:(NSString *)confirmBtnTitle
                                     completed:(FHPushAuthorizeHintComplete)completed
{
    self = [self init];
    if (self) {
        _completed = completed;
        self.titleLabel.text = title;
        self.subtitleLabel.text = message;
        [self.submitBtn setTitle:confirmBtnTitle forState:UIControlStateNormal];
        [self.submitBtn setTitle:confirmBtnTitle forState:UIControlStateHighlighted];
        UIImage *image = [UIImage imageNamed:imageName];
        self.imgView.image = image;
        CGFloat ratio = 165.0 / 289.0;
        if (image.size.width > 0) {
            ratio = image.size.height / image.size.width;
        }
        CGFloat width = [UIScreen mainScreen].bounds.size.width - 38 * 2;
        [self.imgView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo((width - 10) * ratio);
        }];

    }
    return self;
}

- (instancetype)init
{
    self = [super initWithFrame:[UIScreen mainScreen].bounds];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI
{
    [self addSubview:self.bgView];
    [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self);
    }];
    
    [self addSubview:self.contentView];
    CGFloat width = [UIScreen mainScreen].bounds.size.width - 38 * 2;
//    if (![TTDeviceHelper isScreenWidthLarge320]) {
//        width = 280;
//    }
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(self);
        make.width.mas_equalTo(width);
        
    }];
    
    self.bgView.alpha = 0;
    self.contentView.alpha = 0;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(closeBtnDidClick)];
    self.bgView.userInteractionEnabled = YES;
    [self.bgView addGestureRecognizer:tap];
    
    [self.contentView addSubview:self.closeBtn];
    [self.contentView addSubview:self.titleLabel];
    [self.contentView addSubview:self.subtitleLabel];
    [self.contentView addSubview:self.imgView];
    [self.contentView addSubview:self.submitBtn];

    [self.closeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(34);
        make.right.mas_equalTo(self.contentView).mas_offset(-5);
        make.top.mas_equalTo(self.contentView).mas_offset(5);
    }];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.contentView).mas_offset(40);
        make.left.mas_equalTo(self.contentView).mas_offset(20);
        make.height.mas_equalTo(32);
        make.right.mas_equalTo(-20);
    }];
    [self.subtitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.titleLabel.mas_bottom);
        make.left.mas_equalTo(self.titleLabel);
        make.right.mas_equalTo(-20);
        make.height.mas_equalTo(20);
    }];
    CGFloat ratio = 165.0 / 289.0;
    [self.imgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.subtitleLabel.mas_bottom).mas_offset(7);
        make.centerX.mas_equalTo(self.contentView);
        make.width.mas_equalTo(width - 10);
        make.height.mas_equalTo((width - 10) * ratio);
    }];
    
    [self.submitBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(40);
        make.top.mas_equalTo(self.imgView.mas_bottom).mas_offset(18);
        make.left.mas_equalTo(20);
        make.right.mas_equalTo(-20);
        make.bottom.mas_equalTo(-20);
    }];
    [self.closeBtn addTarget:self action:@selector(closeBtnDidClick) forControlEvents:UIControlEventTouchUpInside];
    [self.submitBtn addTarget:self action:@selector(submitBtnDidClick:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)submitBtnDidClick:(UIButton *)btn
{
    if (self.completed) {
        self.completed(FHAuthorizeHintCompleteTypeDone);
    }
    [self dismiss];
}

- (void)closeBtnDidClick
{
    if (self.completed) {
        self.completed(FHAuthorizeHintCompleteTypeCancel);
    }
    [self dismiss];
}

- (void)show
{
    UIWindow *window = nil;
    if ([[UIApplication sharedApplication].delegate respondsToSelector:@selector(window)]) {
        window = [UIApplication sharedApplication].delegate.window;
    }
    if (!window) {
        window = [UIApplication sharedApplication].keyWindow;
    }
    
    self.alpha = 0.0f;
    [window addSubview:self];

    self.contentView.center = CGPointMake(self.width / 2, self.height / 2);
    self.contentView.transform = CGAffineTransformMakeScale(0.9, 0.9);
    [UIView animateWithDuration:0.13 animations:^{
        self.alpha = 1.0f;
        self.bgView.alpha = 1.0f;
        self.contentView.alpha = 1.0f;
        self.contentView.transform = CGAffineTransformMakeScale(1.03, 1.03);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.07 animations:^{
            self.contentView.transform = CGAffineTransformIdentity;
        } completion:^(BOOL finished) {
            
        }];
    }];
}

- (void)dismiss
{
    [UIView animateWithDuration:0.1 animations:^{
        self.alpha = 0.0f;
        self.contentView.transform = CGAffineTransformMakeScale(0.9, 0.9);
    } completion:^(BOOL finished) {
        
        [self removeFromSuperview];
        
    }];
}

- (UIView *)bgView
{
    if (!_bgView) {
        _bgView = [[UIView alloc]init];
        _bgView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.4];
    }
    return _bgView;
}

- (UIView *)contentView
{
    if (!_contentView) {
        _contentView = [[UIView alloc]init];
        _contentView.backgroundColor = [UIColor whiteColor];
        _contentView.layer.cornerRadius = 6;
        _contentView.clipsToBounds = YES;
        
    }
    return _contentView;
}

- (UILabel *)titleLabel
{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc]init];
        _titleLabel.font = [UIFont themeFontMedium:20];
        _titleLabel.textColor = [UIColor themeGray1];
        _titleLabel.numberOfLines = 0;
        _titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    }
    return _titleLabel;
}

- (UILabel *)subtitleLabel
{
    if (!_subtitleLabel) {
        _subtitleLabel = [[UILabel alloc]init];
        _subtitleLabel.font = [UIFont themeFontRegular:14];
        _subtitleLabel.textColor = [UIColor themeGray3];
        _subtitleLabel.numberOfLines = 0;
        _subtitleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    }
    return _subtitleLabel;
}

- (UIImageView *)imgView
{
    if (!_imgView) {
        _imgView = [[UIImageView alloc]init];
    }
    return _imgView;
}

- (UIButton *)closeBtn
{
    if (!_closeBtn) {
        _closeBtn = [[UIButton alloc]init];
        UIImage *img = ICON_FONT_IMG(12, @"\U0000e673", nil);
        [_closeBtn setImage:img forState:UIControlStateNormal];
        [_closeBtn setImage:img forState:UIControlStateHighlighted];
    }
    return _closeBtn;
}

- (UIButton *)submitBtn
{
    if (!_submitBtn) {
        _submitBtn = [[UIButton alloc]init];
        [_submitBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_submitBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
        _submitBtn.titleLabel.font = [UIFont themeFontRegular:16];
        [_submitBtn setTitle:@"打开通知" forState:UIControlStateNormal];
        [_submitBtn setTitle:@"打开通知" forState:UIControlStateHighlighted];
        _submitBtn.layer.cornerRadius = 20 ; //4;
        _submitBtn.backgroundColor = [UIColor themeOrange4];
    }
    return _submitBtn;
}


@end
