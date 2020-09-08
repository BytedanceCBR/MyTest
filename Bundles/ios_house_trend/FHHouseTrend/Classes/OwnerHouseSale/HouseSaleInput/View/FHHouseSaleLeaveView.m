//
//  FHHouseSaleLeaveView.m
//  FHHouseTrend
//
//  Created by 谢思铭 on 2020/9/8.
//

#import "FHHouseSaleLeaveView.h"
#import "UIColor+Theme.h"
#import "UIFont+House.h"
#import <Masonry.h>
#import "UIViewAdditions.h"

@interface FHHouseSaleLeaveView ()

@property(nonatomic, strong) UIView *contentView;
@property(nonatomic, strong) UIButton *rightCloseBtn;
@property(nonatomic, strong) UILabel *titleLabel;
@property(nonatomic, strong) UILabel *descLabel;
@property(nonatomic, strong) UIButton *closeBtn;
@property(nonatomic, strong) UIButton *continueBtn;

@end

@implementation FHHouseSaleLeaveView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if(self){
        self.backgroundColor = [[UIColor themeGray1] colorWithAlphaComponent:0.4];
        [self initViews];
        [self initConstraints];
    }
    return self;
}

- (void)initViews {
    self.contentView = [[UIView alloc] init];
    _contentView.backgroundColor = [UIColor whiteColor];
    _contentView.layer.masksToBounds = YES;
    _contentView.layer.cornerRadius = 10;
    [self addSubview:_contentView];
    
    self.rightCloseBtn = [[UIButton alloc] init];
    [_rightCloseBtn setImage:[UIImage imageNamed:@"house_sale_leave_close"] forState:UIControlStateNormal];
    _rightCloseBtn.hitTestEdgeInsets = UIEdgeInsetsMake(-15, -15, -15, -15);
    [_rightCloseBtn addTarget:self action:@selector(close) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:_rightCloseBtn];
    
    self.titleLabel = [self LabelWithFont:[UIFont themeFontMedium:24] textColor:[UIColor themeGray1]];
    _titleLabel.text = @"还未发布成功";
    [self addSubview:_titleLabel];
    
    self.descLabel = [self LabelWithFont:[UIFont themeFontMedium:14] textColor:[UIColor themeGray1]];
    _descLabel.text = @"现在提交卖房信息将享受专业顾问为您提供1对1专享服务。幸福里专业平台，海量购房用户，让卖房更轻松";
    _descLabel.numberOfLines = 0;
    [self addSubview:_descLabel];
    
    self.closeBtn = [[UIButton alloc] init];
    [_closeBtn setTitle:@"退出" forState:UIControlStateNormal];
    [_closeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _closeBtn.titleLabel.font = [UIFont themeFontRegular:16];
    _closeBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
    _closeBtn.backgroundColor = [UIColor themeOrange4];
    _closeBtn.layer.masksToBounds = YES;
    _closeBtn.layer.cornerRadius = 20;
    [_closeBtn addTarget:self action:@selector(quit) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:_closeBtn];
    
    self.continueBtn = [[UIButton alloc] init];
    [_continueBtn setTitle:@"继续录入" forState:UIControlStateNormal];
    [_continueBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _continueBtn.titleLabel.font = [UIFont themeFontRegular:16];
    _continueBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
    _continueBtn.backgroundColor = [UIColor themeOrange1];
    _continueBtn.layer.masksToBounds = YES;
    _continueBtn.layer.cornerRadius = 20;
    [_continueBtn addTarget:self action:@selector(close) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:_continueBtn];
}

- (void)initConstraints {
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(self);
        make.width.mas_equalTo(279);
        make.height.mas_equalTo(269);
    }];
    
    [self.rightCloseBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.contentView).offset(15);
        make.right.mas_equalTo(self.contentView).offset(-15);
        make.width.height.mas_equalTo(24);
    }];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.contentView).offset(60);
        make.left.mas_equalTo(self.contentView).offset(20);
        make.right.mas_equalTo(self.contentView).offset(-20);
        make.height.mas_equalTo(33);
    }];
    
    [self.descLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.titleLabel.mas_bottom).offset(16);
        make.left.mas_equalTo(self.contentView).offset(20);
        make.right.mas_equalTo(self.contentView).offset(-20);
        make.height.mas_equalTo(60);
    }];
    
    [self.closeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.descLabel.mas_bottom).offset(20);
        make.left.mas_equalTo(self.contentView).offset(24);
        make.width.mas_equalTo(107);
        make.height.mas_equalTo(40);
    }];
    
    [self.continueBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.descLabel.mas_bottom).offset(20);
        make.right.mas_equalTo(self.contentView).offset(-24);
        make.width.mas_equalTo(107);
        make.height.mas_equalTo(40);
    }];
}

- (UILabel *)LabelWithFont:(UIFont *)font textColor:(UIColor *)textColor {
    UILabel *label = [[UILabel alloc] init];
    label.font = font;
    label.textColor = textColor;
    return label;
}

- (void)handleSingleTap:(UITapGestureRecognizer *)sender {
    [self close];
}

- (void)show {
    [UIView animateWithDuration:0.2f animations:^{
        self.alpha = 1.0f;
    }];
}

- (void)close {
    [UIView animateWithDuration:0.2f animations:^{
        self.alpha = 0.f;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

- (void)quit {
    [self close];
    if(self.quitBlock){
        self.quitBlock();
    }
}

@end
