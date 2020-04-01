//
//  FHAppStoreCustomAlertView.m
//  Pods
//
//  Created by 张静 on 2019/10/28.
//

#import "FHAppStoreCustomAlertView.h"
#import <FHCommonUI/UIColor+Theme.h>
#import <FHCommonUI/UIFont+House.h>
#import <FHCommonUI/UIView+House.h>
#import "Masonry.h"
#import "UIImage+FIconFont.h"

@interface FHAppStoreCustomAlertView ()

@property(nonatomic , strong) UIView *bgView;
@property(nonatomic , strong) UIView *contentView;
@property(nonatomic , strong) UILabel *titleLabel;
@property(nonatomic , strong) UILabel *subtitleLabel;
@property(nonatomic , strong) UIButton *closeBtn;
@property(nonatomic , strong) UIButton *leftBtn;
@property(nonatomic , strong) UIButton *submitBtn;
@property(nonatomic , strong) NSArray *btnTitles;
@property(nonatomic , copy) void(^tapBlock)(NSInteger index);

@end

@implementation FHAppStoreCustomAlertView

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
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(self);
        make.width.mas_equalTo(width);
        
    }];
    
    self.bgView.alpha = 0;
    self.contentView.alpha = 0;
    
//    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(closeBtnDidClick)];
//    self.bgView.userInteractionEnabled = YES;
//    [self.bgView addGestureRecognizer:tap];
    
    [self.contentView addSubview:self.closeBtn];
    [self.contentView addSubview:self.titleLabel];
    [self.contentView addSubview:self.subtitleLabel];
    [self.contentView addSubview:self.submitBtn];
    [self.contentView addSubview:self.leftBtn];
    
    self.closeBtn.tag = 100;
    self.submitBtn.tag = 101;
    self.leftBtn.tag = 102;

    [self.closeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(24);
        make.right.mas_equalTo(self.contentView).mas_offset(-6);
        make.top.mas_equalTo(self.contentView).mas_offset(6);
    }];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.contentView).mas_offset(30);
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
    [self.leftBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(40);
        make.top.mas_equalTo(self.subtitleLabel.mas_bottom).mas_offset(18);
        make.left.mas_equalTo(20);
        make.width.mas_equalTo(0);
    }];
    [self.submitBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(40);
        make.top.mas_equalTo(self.subtitleLabel.mas_bottom).mas_offset(18);
        make.width.mas_equalTo(0);
        make.right.mas_equalTo(-20);
        make.bottom.mas_equalTo(-20);
    }];
    [self.closeBtn addTarget:self action:@selector(btnDidClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.submitBtn addTarget:self action:@selector(btnDidClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.leftBtn addTarget:self action:@selector(btnDidClick:) forControlEvents:UIControlEventTouchUpInside];
}

+ (FHAppStoreCustomAlertView *)alertWithTitle:(NSString *)title message:(NSString *)message buttons:(NSArray<NSString *>*)buttons tapBlock:(void(^)(NSInteger index))tapBlock
{
    FHAppStoreCustomAlertView *alert = [[FHAppStoreCustomAlertView alloc]init];
    alert.titleLabel.text = title;
    alert.subtitleLabel.text = message;
    alert.tapBlock = tapBlock;
    CGFloat itemWidth = 0;
    CGFloat leftWidth = 0;
    BOOL showLeftBtn = NO;
    if (buttons.count > 0) {
        NSString *btnTitle = buttons[0];
        [alert.submitBtn setTitle:btnTitle forState:UIControlStateNormal];
        [alert.submitBtn setTitle:btnTitle forState:UIControlStateHighlighted];
        itemWidth = [UIScreen mainScreen].bounds.size.width - 38 * 2 - 20 * 2;
    }
    if (buttons.count > 1) {
        NSString *btnTitle = buttons[0];
        [alert.submitBtn setTitle:btnTitle forState:UIControlStateNormal];
        [alert.submitBtn setTitle:btnTitle forState:UIControlStateHighlighted];
        NSString *leftTitle = buttons[1];
        [alert.leftBtn setTitle:leftTitle forState:UIControlStateNormal];
        [alert.leftBtn setTitle:leftTitle forState:UIControlStateHighlighted];
        itemWidth = ([UIScreen mainScreen].bounds.size.width - 38 * 2 - 20 * 2 - 10) / 2;
        leftWidth = itemWidth;
        showLeftBtn = YES;
    }
    alert.leftBtn.hidden = !showLeftBtn;
    [alert.leftBtn mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(leftWidth);
    }];
    [alert.submitBtn mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(itemWidth);
    }];
    return alert;
}

- (void)btnDidClick:(UIButton *)btn
{
    if (self.tapBlock) {
        self.tapBlock(btn.tag - 100);
    }
    [self dismiss];
}


//- (void)closeBtnDidClick
//{
//    if (self.tapBlock) {
//        self.tapBlock(0);
//    }
//    [self dismiss];
//}

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
        _contentView.layer.cornerRadius = 4;
        _contentView.clipsToBounds = YES;
        
    }
    return _contentView;
}

- (UILabel *)titleLabel
{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc]init];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.font = [UIFont themeFontSemibold:21];
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
        _subtitleLabel.textAlignment = NSTextAlignmentCenter;
        _subtitleLabel.font = [UIFont themeFontRegular:14];
        _subtitleLabel.textColor = [UIColor themeGray3];
        _subtitleLabel.numberOfLines = 0;
        _subtitleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    }
    return _subtitleLabel;
}

- (UIButton *)closeBtn
{
    if (!_closeBtn) {
        _closeBtn = [[UIButton alloc]init];
        UIImage *img = ICON_FONT_IMG(22, @"\U0000e673", nil);
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
        _submitBtn.layer.cornerRadius = 20; //4;
        _submitBtn.backgroundColor = [UIColor themeOrange4];
    }
    return _submitBtn;
}

- (UIButton *)leftBtn
{
    if (!_leftBtn) {
        _leftBtn = [[UIButton alloc]init];
        [_leftBtn setTitleColor:[UIColor themeGray3] forState:UIControlStateNormal];
        [_leftBtn setTitleColor:[UIColor themeGray3] forState:UIControlStateHighlighted];
        _leftBtn.titleLabel.font = [UIFont themeFontRegular:16];
        _leftBtn.layer.cornerRadius = 20; //4;
        _leftBtn.backgroundColor = [UIColor themeGray7];
    }
    return _leftBtn;
}


@end
