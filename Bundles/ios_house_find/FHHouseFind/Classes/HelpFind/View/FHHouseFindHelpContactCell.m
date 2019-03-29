//
//  FHHouseFindHelpContactCell.m
//  FHHouseFind
//
//  Created by 张静 on 2019/3/27.
//

#import "FHHouseFindHelpContactCell.h"

#import <FHCommonUI/UIFont+House.h>
#import <FHCommonUI/UIColor+Theme.h>
#import <Masonry.h>
#import <TTBaseLib/TTDeviceHelper.h>

@interface FHHouseFindHelpContactCell()

@property(nonatomic, strong, readwrite) UITextField *phoneInput;
@property(nonatomic, strong, readwrite) UITextField *varifyCodeInput;
@property(nonatomic, strong) UIView *singleLine;
@property(nonatomic, strong) UIView *singleLine2;
@property(nonatomic, strong) UILabel *tipLabel;

@end

@implementation FHHouseFindHelpContactCell

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
    [self.contentView addSubview:self.phoneInput];
    [self.contentView addSubview:self.varifyCodeInput];
    [self.contentView addSubview:self.sendVerifyCodeBtn];
    [self.contentView addSubview:self.singleLine];
    [self.contentView addSubview:self.singleLine2];
    [self.contentView addSubview:self.tipLabel];
    [self.sendVerifyCodeBtn addTarget:self action:@selector(sendVerifyCode) forControlEvents:UIControlEventTouchUpInside];
    [self.phoneInput mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(5);
        make.left.mas_equalTo(20);
        make.right.mas_equalTo(-20);
        make.height.mas_equalTo(20);
    }];
    
    [self.singleLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.phoneInput.mas_bottom).offset(11);
        make.left.mas_equalTo(self.phoneInput);
        make.right.mas_equalTo(self.phoneInput);
        make.height.mas_equalTo(TTDeviceHelper.ssOnePixel);
    }];
    
    [self.varifyCodeInput mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.phoneInput.mas_bottom).offset(43);
        make.left.mas_equalTo(self.phoneInput);
        make.right.mas_equalTo(self.phoneInput);
        make.height.mas_equalTo(20);
    }];
    
    [self.singleLine2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.varifyCodeInput.mas_bottom).offset(11);
        make.left.mas_equalTo(self.phoneInput);
        make.right.mas_equalTo(self.phoneInput);
        make.height.mas_equalTo(TTDeviceHelper.ssOnePixel);
    }];
    
    [self.sendVerifyCodeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.phoneInput);
        make.right.mas_equalTo(self.phoneInput);
        make.height.mas_equalTo(30);
    }];
    
    [self.tipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(self.phoneInput);
        make.top.mas_equalTo(self.singleLine2.mas_bottom).mas_offset(20);
//        make.bottom.mas_equalTo(-20);
    }];
}

- (void)sendVerifyCode {
    if (self.delegate && [self.delegate respondsToSelector:@selector(sendVerifyCode)]) {
        [self.delegate sendVerifyCode];
    }
}

- (void)enableSendVerifyCodeBtn:(BOOL)enabled
{
    self.sendVerifyCodeBtn.enabled = enabled;
}

- (UITextField *)phoneInput
{
    if (!_phoneInput) {
        _phoneInput = [[UITextField alloc] init];
        _phoneInput.font = [UIFont themeFontRegular:14];
        _phoneInput.placeholder = @"请输入手机号";
        [_phoneInput setValue:[UIColor themeGray3] forKeyPath:@"_placeholderLabel.textColor"];
        _phoneInput.keyboardType = UIKeyboardTypePhonePad;
        _phoneInput.returnKeyType = UIReturnKeyDone;
    }
    return _phoneInput;
}

- (UITextField *)varifyCodeInput
{
    if (!_varifyCodeInput) {
        _varifyCodeInput = [[UITextField alloc] init];
        _varifyCodeInput.font = [UIFont themeFontRegular:14];
        _varifyCodeInput.placeholder = @"请输入验证码";
        [_varifyCodeInput setValue:[UIColor themeGray3] forKeyPath:@"_placeholderLabel.textColor"];
        _varifyCodeInput.keyboardType = UIKeyboardTypePhonePad;
        _varifyCodeInput.returnKeyType = UIReturnKeyGo;
    }
    return _varifyCodeInput;
}

- (UIButton *)sendVerifyCodeBtn
{
    if (!_sendVerifyCodeBtn) {
        _sendVerifyCodeBtn = [[UIButton alloc] init];
        _sendVerifyCodeBtn.titleLabel.font = [UIFont themeFontRegular:14];
        [_sendVerifyCodeBtn setTitle:@"获取验证码" forState:UIControlStateNormal];
        [_sendVerifyCodeBtn setTitle:@"获取验证码" forState:UIControlStateHighlighted];
        [_sendVerifyCodeBtn setTitleColor:[UIColor themeGray1] forState:UIControlStateNormal];
        [_sendVerifyCodeBtn setTitleColor:[UIColor themeGray1] forState:UIControlStateHighlighted];
        [_sendVerifyCodeBtn setTitleColor:[UIColor themeGray3] forState:UIControlStateDisabled];
    }
    return _sendVerifyCodeBtn;
}

- (UIView *)singleLine
{
    if (!_singleLine) {
        _singleLine = [[UIView alloc] init];
        _singleLine.backgroundColor = [UIColor themeGray6];
    }
    return _singleLine;
}

- (UIView *)singleLine2
{
    if (!_singleLine2) {
        _singleLine2 = [[UIView alloc] init];
        _singleLine2.backgroundColor = [UIColor themeGray6];
    }
    return _singleLine2;
}

- (UILabel *)tipLabel
{
    if (!_tipLabel) {
        _tipLabel = [[UILabel alloc] init];
        _tipLabel.text = @"温馨提示：\n提交购房需求后将由幸福里及其授权的优质服务商为您提供专业服务";
        _tipLabel.numberOfLines = 0;
        _tipLabel.lineBreakMode = NSLineBreakByWordWrapping;
        _tipLabel.textColor = [UIColor themeGray3];
        _tipLabel.font = [UIFont themeFontRegular:10];
    }
    return _tipLabel;
}

@end
