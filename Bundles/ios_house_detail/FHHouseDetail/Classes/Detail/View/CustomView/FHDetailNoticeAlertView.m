//
//  FHDetailNoticeAlertView.m
//  Pods
//
//  Created by 张静 on 2019/2/15.
//

#import "FHDetailNoticeAlertView.h"
#import "UIFont+House.h"
#import "UIColor+Theme.h"
#import "Masonry.h"
#import "TTDeviceHelper.h"

@interface FHDetailNoticeAlertView ()

@property(nonatomic , strong) UIView *bgView;
@property(nonatomic , strong) UIView *contentView;
@property(nonatomic , strong) UILabel *titleLabel;
@property(nonatomic , strong) UILabel *subtitleLabel;
@property(nonatomic , strong) UIButton *closeBtn;
@property(nonatomic , strong) UITextField *phoneTextField;
@property(nonatomic , strong) UIButton *submitBtn;
@property(nonatomic , strong) UILabel *tipLabel;

@end

@implementation FHDetailNoticeAlertView

- initWithTitle:(NSString *)title subtitle:(NSString *)subtitle btnTitle:(NSString *)btnTitle
{
    self = [super init];
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
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(self);
        make.width.mas_equalTo(280 * [TTDeviceHelper scaleToScreen375]);
    }];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(dismiss)];
    self.bgView.userInteractionEnabled = YES;
    [self.bgView addGestureRecognizer:tap];
    
    [self.contentView addSubview:self.closeBtn];
    [self.contentView addSubview:self.titleLabel];
    [self.contentView addSubview:self.subtitleLabel];
    [self.contentView addSubview:self.phoneTextField];
    [self.contentView addSubview:self.submitBtn];
    [self.contentView addSubview:self.tipLabel];
    
    [self.closeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(34);
        make.right.top.mas_equalTo(self.contentView);
    }];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(32);
        make.top.mas_equalTo(self.contentView).mas_offset(40);
        make.left.mas_equalTo(self.contentView).mas_offset(20);
    }];
    [self.subtitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(20);
        make.top.mas_equalTo(self.titleLabel.mas_bottom).mas_offset(10);
        make.left.mas_equalTo(self.titleLabel);
    }];
    
    [self.closeBtn addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];

    // add by zjing for test
//    if let phonenum = EnvContext.shared.client.sendPhoneNumberCache?.object(forKey: "phonenumber") as? String
//    {
//        // 显示 151*****010
//        var tempPhone:String = phonenum
//        if tempPhone.count == 11 {
//            var temp:String = tempPhone
//            tempPhone = "\(temp.prefix(3))*****\(temp.suffix(3))"
//            self.origin_phoneNumber = phonenum
//        }
//        re.text = tempPhone
//    }
}

- (void)dismiss
{
    [self endEditing:YES];
}

- (UIView *)bgView
{
    if (!_bgView) {
        _bgView = [[UIView alloc]init];
        _bgView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.35];
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
        _titleLabel.font = [UIFont themeFontRegular:16];
        _titleLabel.textColor = [UIColor themeBlack];
    }
    return _titleLabel;
}

- (UILabel *)subtitleLabel
{
    if (!_subtitleLabel) {
        _subtitleLabel = [[UILabel alloc]init];
        _subtitleLabel.font = [UIFont themeFontRegular:16];
        _subtitleLabel.textColor = [UIColor themeBlack];
    }
    return _subtitleLabel;
}

- (UIButton *)closeBtn
{
    if (!_closeBtn) {
        _closeBtn = [[UIButton alloc]init];
        [_closeBtn setImage:[UIImage imageNamed:@"detail_alert_closed"] forState:UIControlStateNormal];
        [_closeBtn setImage:[UIImage imageNamed:@"detail_alert_closed"] forState:UIControlStateHighlighted];
    }
    return _closeBtn;
}

- (UITextField *)phoneTextField
{
    if (!_phoneTextField) {
        _phoneTextField = [[UITextField alloc]init];
        _phoneTextField.keyboardType = UIKeyboardTypePhonePad;
        _phoneTextField.font = [UIFont themeFontRegular:14];
        _phoneTextField.placeholder = @"请输入手机号";
    }
    return _phoneTextField;
}

- (UIButton *)submitBtn
{
    if (!_submitBtn) {
        _submitBtn = [[UIButton alloc]init];
        [_submitBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_submitBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
        _submitBtn.titleLabel.font = [UIFont themeFontRegular:16];
        [_submitBtn setTitle:@"提交" forState:UIControlStateNormal];
        [_submitBtn setTitle:@"提交" forState:UIControlStateHighlighted];
        _submitBtn.layer.cornerRadius = 20;
        _submitBtn.backgroundColor = [UIColor colorWithHexString:@"#299cff"];
    }
    return _submitBtn;
}

- (UILabel *)tipLabel
{
    if (!_tipLabel) {
        _tipLabel = [[UILabel alloc]init];
        _tipLabel.font = [UIFont themeFontRegular:16];
        _tipLabel.textColor = [UIColor themeBlack];
    }
    return _tipLabel;
}

@end
