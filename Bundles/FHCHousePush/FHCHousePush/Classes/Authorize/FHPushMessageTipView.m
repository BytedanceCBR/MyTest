//
//  FHPushMessageTipView.m
//  FHCHousePush
//
//  Created by 张静 on 2019/5/23.
//

#import "FHPushMessageTipView.h"
#import <FHCommonUI/UIColor+Theme.h>
#import <FHCommonUI/UIFont+House.h>
#import <FHCommonUI/UIView+House.h>
#import <Masonry.h>

@interface FHPushMessageTipView ()

@property(nonatomic , strong) UIButton *closeBtn;
@property(nonatomic , strong) UILabel *titleLabel;
@property(nonatomic , strong) UIButton *submitBtn;
@property(nonatomic , copy) FHPushMessageTipViewComplete completed;

@end

@implementation FHPushMessageTipView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (instancetype)initAuthorizeTipWithCompleted:(FHPushMessageTipViewComplete)completed
{
    self = [self initWithFrame:CGRectZero];
    if (self) {
        _completed = completed;
    }
    return self;
}

- (void)setupUI
{
    self.backgroundColor = [UIColor colorWithHexString:@"#ffeef0"];
    [self addSubview:self.closeBtn];
    [self addSubview:self.titleLabel];
    [self addSubview:self.submitBtn];
    
    [self.closeBtn addTarget:self action:@selector(closeBtnBtnDidClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.submitBtn addTarget:self action:@selector(submitBtnBtnDidClick:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.closeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(20);
        make.height.top.mas_equalTo(self);
    }];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.closeBtn.mas_right);
        make.height.top.mas_equalTo(self);
    }];
    [self.submitBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-20);
        make.height.mas_equalTo(20);
        make.centerY.mas_equalTo(self.titleLabel);
    }];
}

- (void)closeBtnBtnDidClick:(UIButton *)btn
{
    if (self.completed) {
        self.completed(FHPushMessageTipCompleteTypeCancel);
    }
}

- (void)submitBtnBtnDidClick:(UIButton *)btn
{
    if (self.completed) {
        self.completed(FHPushMessageTipCompleteTypeDone);
    }
}

- (UILabel *)titleLabel
{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc]init];
        _titleLabel.text = @"打开系统通知，随时接受最新房源动态";
        _titleLabel.font = [UIFont themeFontRegular:14];
        _titleLabel.textColor = [UIColor themeGray2];
        _titleLabel.numberOfLines = 0;
        _titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    }
    return _titleLabel;
}

- (UIButton *)closeBtn
{
    if (!_closeBtn) {
        _closeBtn = [[UIButton alloc]init];
        [_closeBtn setImage:[UIImage imageNamed:@"push_message_close"] forState:UIControlStateNormal];
        [_closeBtn setImage:[UIImage imageNamed:@"push_message_close"] forState:UIControlStateHighlighted];
    }
    return _closeBtn;
}

- (UIButton *)submitBtn
{
    if (!_submitBtn) {
        _submitBtn = [[UIButton alloc]init];
        [_submitBtn setTitleColor:[UIColor themeRed3] forState:UIControlStateNormal];
        [_submitBtn setTitleColor:[UIColor themeRed3] forState:UIControlStateHighlighted];
        _submitBtn.titleLabel.font = [UIFont themeFontRegular:14];
        [_submitBtn setTitle:@"开启" forState:UIControlStateNormal];
        [_submitBtn setTitle:@"开启" forState:UIControlStateHighlighted];
    }
    return _submitBtn;
}

@end
