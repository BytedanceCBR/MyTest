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
#import "TTUIResponderHelper.h"
#import "UIView+House.h"

@interface FHDetailNoticeAlertView () <UITextFieldDelegate>

@property(nonatomic , strong) UIView *bgView;
@property(nonatomic , strong) UIView *contentView;
@property(nonatomic , strong) UILabel *titleLabel;
@property(nonatomic , strong) UILabel *subtitleLabel;
@property(nonatomic , strong) UIButton *closeBtn;
@property(nonatomic , strong) UITextField *phoneTextField;
@property(nonatomic , strong) UIView *seperateLine;
@property(nonatomic , strong) UILabel *errorTextLabel;
@property(nonatomic , strong) UIButton *leftBtn;
@property(nonatomic , strong) UIButton *submitBtn;
@property(nonatomic , strong) UILabel *tipLabel;
@property(nonatomic , copy) NSString *originPhoneNumber;

@end


@implementation FHDetailNoticeAlertView

- (instancetype)initWithTitle:(NSString *)title subtitle:(NSString *)subtitle btnTitle:(NSString *)btnTitle
{
    self = [self initWithFrame:[UIScreen mainScreen].bounds];
    if (self) {
        [self setupUI];
        self.titleLabel.text = title;
        self.subtitleLabel.text = subtitle;
        [self.submitBtn setTitle:btnTitle forState:UIControlStateNormal];
        [self.submitBtn setTitle:btnTitle forState:UIControlStateHighlighted];
        [self.submitBtn addTarget:self action:@selector(submitBtnDidClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

- (instancetype)initWithTitle:(NSString *)title subtitle:(NSString *)subtitle btnTitle:(NSString *)btnTitle leftBtnTitle:(NSString *)leftBtnTitle
{
    self = [self initWithFrame:[UIScreen mainScreen].bounds];
    if (self) {
        [self setupUI];
        self.titleLabel.text = title;
        self.subtitleLabel.text = subtitle;
        [self.submitBtn setTitle:btnTitle forState:UIControlStateNormal];
        [self.submitBtn setTitle:btnTitle forState:UIControlStateHighlighted];
        if (leftBtnTitle.length > 0) {
            
            [self.leftBtn setTitle:leftBtnTitle forState:UIControlStateNormal];
            [self.leftBtn setTitle:leftBtnTitle forState:UIControlStateHighlighted];
            [self.leftBtn mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.mas_equalTo(20);
                make.width.height.centerY.mas_equalTo(self.submitBtn);
            }];
            [self.submitBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.height.mas_equalTo(40);
                make.top.mas_equalTo(self.seperateLine.mas_bottom).mas_offset(20.5);
                make.left.mas_equalTo(self.leftBtn.mas_right).mas_offset(10);
                make.right.mas_equalTo(-20);
            }];
            [self.submitBtn addTarget:self action:@selector(rightBtnDidClick:) forControlEvents:UIControlEventTouchUpInside];
        } else {
            [self.submitBtn addTarget:self action:@selector(submitBtnDidClick:) forControlEvents:UIControlEventTouchUpInside];
        }
    }
    return self;
}

- (void)setPhoneNum:(NSString *)phoneNum
{
    _phoneNum = phoneNum;
    if (phoneNum.length > 0) {
        // 显示 151*****010
        NSString *tempPhone = phoneNum;
        if (phoneNum.length == 11) {
            tempPhone = [NSString stringWithFormat:@"%@*****%@",[phoneNum substringToIndex:3],[phoneNum substringFromIndex:7]];
            self.originPhoneNumber = phoneNum;
        }
        self.phoneTextField.text = tempPhone;
        if (self.phoneTextField.text.length > 0) {
            [self refreshBtnState:YES];
        }else {
            [self refreshBtnState:NO];
        }
    }
    // 有手机号，不弹出弹窗
    if (self.originPhoneNumber.length < 1) {
        
        //需要在下一个loop唤醒键盘
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.phoneTextField becomeFirstResponder];
            });
        });
        
    }
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
    
    self.bgView.alpha = 0;
    self.contentView.alpha = 0;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(dismiss)];
    self.bgView.userInteractionEnabled = YES;
    [self.bgView addGestureRecognizer:tap];
    
    [self.contentView addSubview:self.closeBtn];
    [self.contentView addSubview:self.titleLabel];
    [self.contentView addSubview:self.subtitleLabel];
    [self.contentView addSubview:self.phoneTextField];
    [self.contentView addSubview:self.seperateLine];
    [self.contentView addSubview:self.errorTextLabel];
    [self.contentView addSubview:self.leftBtn];
    [self.contentView addSubview:self.submitBtn];
    [self.contentView addSubview:self.tipLabel];
    
    [self.closeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(34);
        make.right.mas_equalTo(self.contentView).mas_offset(-5);
        make.top.mas_equalTo(self.contentView).mas_offset(5);
    }];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.contentView).mas_offset(40);
        make.left.mas_equalTo(self.contentView).mas_offset(20);
        make.right.mas_equalTo(-20);
    }];
    [self.subtitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.titleLabel.mas_bottom).mas_offset(10);
        make.left.mas_equalTo(self.titleLabel);
        make.right.mas_equalTo(-20);
    }];
    [self.phoneTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(24);
        make.top.mas_equalTo(self.subtitleLabel.mas_bottom).mas_offset(30);
        make.left.mas_equalTo(self.titleLabel);
        make.right.mas_equalTo(-20);
    }];
    [self.errorTextLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(24);
        make.centerY.mas_equalTo(self.phoneTextField);
        make.right.mas_equalTo(self.contentView).mas_offset(-20);
    }];
    [self.seperateLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(0.5);
        make.top.mas_equalTo(self.phoneTextField.mas_bottom).mas_offset(10);
        make.left.mas_equalTo(self.titleLabel);
        make.right.mas_equalTo(self.contentView).mas_offset(-20);
    }];
    [self.submitBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(40);
        make.top.mas_equalTo(self.seperateLine.mas_bottom).mas_offset(20.5);
        make.left.mas_equalTo(self.titleLabel);
        make.right.mas_equalTo(-20);
    }];
    [self.tipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(14);
        make.top.mas_equalTo(self.submitBtn.mas_bottom).mas_offset(13);
        make.bottom.mas_equalTo(self.contentView).mas_offset(-13);
        make.centerX.mas_equalTo(self.contentView);
    }];
    [self.closeBtn addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
    [self.leftBtn addTarget:self action:@selector(leftBtnDidClick:) forControlEvents:UIControlEventTouchUpInside];

    UITapGestureRecognizer *tipTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tipBtnDidClick)];
    self.tipLabel.userInteractionEnabled = YES;
    [self.tipLabel addGestureRecognizer:tipTap];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(textFieldDidChange:) name:UITextFieldTextDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardFrameWillChange:) name:UIKeyboardWillChangeFrameNotification object:nil];


}

- (void)keyboardFrameWillChange:(NSNotification *)noti
{
    NSDictionary *userInfo = noti.userInfo;
    CGRect keyBoardBounds = [userInfo[UIKeyboardFrameEndUserInfoKey]CGRectValue];
    CGFloat duration = [userInfo[UIKeyboardAnimationDurationUserInfoKey]doubleValue];
    UIViewAnimationCurve animationCurve = [[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] unsignedIntegerValue];
    UIViewAnimationOptions options = UIViewAnimationCurveEaseIn | UIViewAnimationCurveEaseOut | UIViewAnimationCurveLinear;
    switch (animationCurve) {
        case UIViewAnimationCurveEaseInOut:
            options = UIViewAnimationOptionCurveEaseInOut;
            break;
        case UIViewAnimationCurveEaseIn:
            options = UIViewAnimationOptionCurveEaseIn;
            break;
        case UIViewAnimationCurveEaseOut:
            options = UIViewAnimationOptionCurveEaseOut;
            break;
        case UIViewAnimationCurveLinear:
            options = UIViewAnimationOptionCurveLinear;
            break;
        default:
            options = animationCurve << 16;
            break;
    }
    CGFloat contentViewHeight = self.contentView.height;
    CGFloat tempOffset = [UIScreen mainScreen].bounds.size.height - keyBoardBounds.origin.y;
    CGFloat offset = 0;
    BOOL isDismissing = CGRectGetMinY(keyBoardBounds) >= [[[UIApplication sharedApplication] delegate] window].bounds.size.height;
    if (isDismissing) {
        offset = ([UIScreen mainScreen].bounds.size.height - ([UIScreen mainScreen].bounds.size.height - keyBoardBounds.origin.y) - contentViewHeight) / 2;
    }else {
        if (tempOffset > 0) {
            CGFloat offsetKeybord = 30;
            offset = ([UIScreen mainScreen].bounds.size.height - ([UIScreen mainScreen].bounds.size.height - keyBoardBounds.origin.y) - contentViewHeight) - offsetKeybord;
        }else {
            offset = ([UIScreen mainScreen].bounds.size.height - ([UIScreen mainScreen].bounds.size.height - keyBoardBounds.origin.y) - contentViewHeight) / 2;
        }
    }
    [UIView animateWithDuration:duration delay:0 options:options animations:^{
        self.contentView.top = offset;
    } completion:^(BOOL finished) {

    }];
}

- (void)textFieldDidChange:(NSNotification *)noti
{
    if (self.phoneTextField.text.length > 11) {
        self.phoneTextField.text = [self.phoneTextField.text substringToIndex:11];
    }
    if (self.phoneTextField.text.length > 0) {
        self.errorTextLabel.hidden = YES;
        self.seperateLine.backgroundColor = [UIColor themeGray6];
        [self refreshBtnState:YES];
    }else {
        [self refreshBtnState:NO];
    }
}

- (void)refreshBtnState:(BOOL)isEnabled
{
    self.submitBtn.enabled = YES;
    self.submitBtn.alpha = 1;
    self.leftBtn.enabled = YES;
    self.leftBtn.alpha = 1;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSString *destString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    if(destString.length > 11){
        return NO;
    }
    return YES;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    // 有手机号，显示原来的手机号
    if (self.originPhoneNumber.length > 0) {
        self.phoneTextField.text = self.originPhoneNumber;
        self.originPhoneNumber = nil;
    }
    return YES;
}

- (void)showFrom:(UIView *)parentView
{
    if (!parentView) {
        parentView = [TTUIResponderHelper topmostViewController].view;
    }
    [parentView addSubview:self];
    [UIView animateWithDuration:0.25 animations:^{
        self.bgView.alpha = 1;
        self.contentView.alpha = 1;
    }];
}

// 当前输入手机号(有*号的特殊处理)
- (NSString *)currentInputPhoneNumber
{
    if (self.originPhoneNumber.length > 0) {
        return self.originPhoneNumber;
    }
    return self.phoneTextField.text;
}

- (void)submitBtnDidClick:(UIButton *)btn
{
    NSString *phoneNum = [self currentInputPhoneNumber];
    if (phoneNum.length == 11 && [phoneNum hasPrefix:@"1"] && [self isPureInt:phoneNum]) {
        if (self.confirmClickBlock) {
            self.confirmClickBlock(phoneNum,self);
        }
    }else {
        [self showErrorText];
    }
}

- (void)leftBtnDidClick:(UIButton *)btn
{
    NSString *phoneNum = [self currentInputPhoneNumber];
    if (phoneNum.length == 11 && [phoneNum hasPrefix:@"1"] && [self isPureInt:phoneNum]) {
        if (self.leftClickBlock) {
            self.leftClickBlock(phoneNum,self);
        }
    }else {
        [self showErrorText];
    }
}

- (void)rightBtnDidClick:(UIButton *)btn

{    NSString *phoneNum = [self currentInputPhoneNumber];
    if (self.confirmClickBlock) {
        self.confirmClickBlock(phoneNum,self);
    }
}

- (BOOL)isPureInt:(NSString*)string{
    NSScanner* scan = [NSScanner scannerWithString:string];
    int val;
    return[scan scanInt:&val] && [scan isAtEnd];
}

- (void)showErrorText
{
    self.errorTextLabel.hidden = NO;
    self.seperateLine.backgroundColor = [UIColor themeRed1];
}

- (void)tipBtnDidClick
{
    [self.phoneTextField resignFirstResponder];
    if (self.tipClickBlock) {
        self.tipClickBlock();
    }
}

- (void)dismiss
{
    [self endEditing:YES];
    [UIView animateWithDuration:0.25 animations:^{
        self.bgView.alpha = 0;
        self.contentView.alpha = 0;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
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
        _titleLabel.font = [UIFont themeFontMedium:24];
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
        _phoneTextField.textColor = [UIColor themeGray1];
        _phoneTextField.placeholder = @"请输入您的手机号";
        _phoneTextField.delegate = self;
    }
    return _phoneTextField;
}

- (UIView *)seperateLine
{
    if (!_seperateLine) {
        _seperateLine = [[UIView alloc]init];
        _seperateLine.backgroundColor = [UIColor themeGray6];
    }
    return _seperateLine;
}

- (UILabel *)errorTextLabel
{
    if (!_errorTextLabel) {
        _errorTextLabel = [[UILabel alloc]init];
        _errorTextLabel.font = [UIFont themeFontRegular:12];
        _errorTextLabel.textColor = [UIColor themeRed1];
        _errorTextLabel.text = @"手机格式错误";
        _errorTextLabel.hidden = YES;
    }
    return _errorTextLabel;
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
        _submitBtn.layer.cornerRadius = 4;
        _submitBtn.backgroundColor = [UIColor themeRed1];
    }
    return _submitBtn;
}

- (UIButton *)leftBtn
{
    if (!_leftBtn) {
        _leftBtn = [[UIButton alloc]init];
        [_leftBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_leftBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
        _leftBtn.titleLabel.font = [UIFont themeFontRegular:16];
        _leftBtn.layer.cornerRadius = 4;
        _leftBtn.backgroundColor = [UIColor themeRed3];
    }
    return _leftBtn;
}

- (UILabel *)tipLabel
{
    if (!_tipLabel) {
        _tipLabel = [[UILabel alloc]init];
        _tipLabel.font = [UIFont themeFontRegular:10];
        _tipLabel.textColor = [UIColor themeGray4];
        _tipLabel.text = @"提交即视为同意《个人信息保护声明》";
    }
    return _tipLabel;
}

@end
