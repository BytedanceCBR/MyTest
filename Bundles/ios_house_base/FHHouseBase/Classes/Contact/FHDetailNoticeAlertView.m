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
#import "TTUIResponderHelper.h"
#import "UIView+House.h"
#import "UIImage+FIconFont.h"
#import <ByteDanceKit/ByteDanceKit.h>
#import "FHUserInfoManager.h"
#import "SSCommonLogic.h"

@interface FHDetailNoticeAlertView () <UITextFieldDelegate>

@property(nonatomic , strong) UIView *bgView;
@property(nonatomic , strong) UIView *contentView;
@property(nonatomic , strong) UILabel *titleLabel;
@property(nonatomic , strong) UILabel *subtitleLabel;
@property(nonatomic , strong) UIButton *closeBtn;
@property(nonatomic , strong) UITextField *phoneTextField;
@property(nonatomic , strong) UIView *seperateLine;
@property(nonatomic , strong) UILabel *errorTextLabel;
@property(nonatomic , strong) UIButton *submitBtn;
@property(nonatomic , strong) UILabel *tipLabel;
@property(nonatomic , copy) NSString *originPhoneNumber;

@property (nonatomic, assign) BOOL isSellHouse;
@end


@implementation FHDetailNoticeAlertView

- (instancetype)initWithTitle:(NSString *)title subtitle:(NSString *)subtitle btnTitle:(NSString *)btnTitle isSellHouse:(BOOL)isSellHouse
{
    self = [self initWithFrame:[UIScreen mainScreen].bounds];
    if (self) {
        self.isSellHouse = isSellHouse;
        [self setupUI];
        self.titleLabel.text = title;
        self.subtitleLabel.text = subtitle;
        [self.submitBtn setTitle:btnTitle forState:UIControlStateNormal];
        [self.submitBtn addTarget:self action:@selector(submitBtnDidClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

- (void)setPhoneNum:(NSString *)phoneNum {
    _phoneNum = phoneNum;
    if (phoneNum.length > 0) {
        self.originPhoneNumber = phoneNum;
        self.phoneTextField.text = [FHUserInfoManager formatMaskPhoneNumber:phoneNum];
        if (self.phoneTextField.text.length > 0) {
            [self refreshBtnState:YES];
        }else {
            [self refreshBtnState:NO];
        }
    }
    // 有手机号，不弹出弹窗
    if (!self.originPhoneNumber.length) {
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
    self.bgView = [[UIView alloc]init];
    self.bgView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.35];
    [self addSubview:self.bgView];
    [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self);
    }];
    
    [self addSubview:self.contentView];
    CGFloat width = 280;
    if ([UIDevice btd_deviceWidthType] == BTDDeviceWidthMode320) {
        width = 280 * [UIScreen mainScreen].bounds.size.width / 375.0f;;
    }
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(self);
        make.width.mas_equalTo(width);
    }];
    
    self.bgView.alpha = 0;
    self.contentView.alpha = 0;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(dismiss)];
    self.bgView.userInteractionEnabled = YES;
    [self.bgView addGestureRecognizer:tap];
    
    if ([SSCommonLogic isEnableVerifyFormAssociate] && !self.isSellHouse) {
        UIImageView *bgImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"form_fill_associate_bg"]];
        bgImageView.contentMode = UIViewContentModeTopRight;
        [self.contentView addSubview:bgImageView];
        [bgImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.right.mas_equalTo(0);
        }];
        
        [self.contentView addSubview:self.closeBtn];
        [self.contentView addSubview:self.titleLabel];
        [self.contentView addSubview:self.subtitleLabel];
        [self.contentView addSubview:self.phoneTextField];
        [self.contentView addSubview:self.tipLabel];
        [self.contentView addSubview:self.submitBtn];
        
            
        [self.closeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.height.mas_equalTo(34);
            make.right.mas_equalTo(self.contentView).mas_offset(-5);
            make.top.mas_equalTo(self.contentView).mas_offset(5);
        }];
        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.contentView).mas_offset(40);
            make.left.mas_equalTo(self.contentView).mas_offset(20);
            make.height.mas_equalTo(33);
        }];
        
        self.subtitleLabel.textColor = [UIColor themeGray1];
        [self.subtitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.titleLabel.mas_bottom).mas_offset(8);
            make.left.mas_equalTo(20);
            make.right.mas_equalTo(-20);
        }];
        
        self.phoneTextField.font = [UIFont themeFontSemibold:18];
        self.phoneTextField.textColor = [UIColor themeGray1];
        self.phoneTextField.userInteractionEnabled = NO;
        self.phoneTextField.enabled = NO;
        [self.phoneTextField mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(25);
            make.top.mas_equalTo(self.subtitleLabel.mas_bottom).mas_offset(20);
            make.left.mas_equalTo(self.subtitleLabel);
            make.right.mas_equalTo(-20);
        }];
        
        [self.tipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(17);
            make.top.mas_equalTo(self.phoneTextField.mas_bottom).mas_offset(8);
            make.left.mas_equalTo(self.subtitleLabel);
            make.right.mas_equalTo(-20);
        }];

        [self.submitBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(40);
            make.top.mas_equalTo(self.tipLabel.mas_bottom).mas_offset(20);
            make.left.mas_equalTo(self.subtitleLabel);
            make.right.mas_equalTo(-20);
            make.bottom.mas_equalTo(-30);
        }];

    } else {
        [self.contentView addSubview:self.closeBtn];
        [self.contentView addSubview:self.titleLabel];
        [self.contentView addSubview:self.subtitleLabel];
        [self.contentView addSubview:self.phoneTextField];
        [self.contentView addSubview:self.seperateLine];
        [self.contentView addSubview:self.errorTextLabel];
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
        }];
        [self.subtitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.titleLabel.mas_bottom).mas_offset(10);
            make.left.mas_equalTo(20);
            make.right.mas_equalTo(-20);
        }];
        [self.phoneTextField mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(24);
            make.top.mas_equalTo(self.subtitleLabel.mas_bottom).mas_offset(20);
            make.left.mas_equalTo(self.subtitleLabel);
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
            make.left.mas_equalTo(self.subtitleLabel);
            make.right.mas_equalTo(self.contentView).mas_offset(-20);
        }];
        
        [self.submitBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(40);
            make.top.mas_equalTo(self.seperateLine.mas_bottom).mas_offset(20);
            make.left.mas_equalTo(self.subtitleLabel);
            make.right.mas_equalTo(-20);
        }];
        [self.tipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(17);
            make.top.mas_equalTo(self.submitBtn.mas_bottom).mas_offset(11);
            make.bottom.mas_equalTo(self.contentView).mas_offset(-12);
            make.centerX.mas_equalTo(self.contentView);
        }];
    }
    
    [self.closeBtn addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];

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
        self.phoneTextField.text = @"";
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
    if (phoneNum.length == 11 && [phoneNum hasPrefix:@"1"] && [FHUserInfoManager checkPureIntFormatted:phoneNum]) {
        if (self.confirmClickBlock) {
            self.confirmClickBlock(phoneNum,self);
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

- (void)showOtherDialogWithTitle:(NSString *)title subTitle:(NSString *)subTitle confirmTitle:(NSString *)confirmTitle cancelTitle:(NSString *)cancelTitle {
    [self endEditing:YES];
    
    
    [UIView animateWithDuration:0.2 animations:^{

        __weak typeof(self) weakSelf = self;
        self.tipLabel.hidden = YES;
        self.phoneTextField.hidden = YES;
        if (title.length) {
            self.titleLabel.text = title;
        }
        if (subTitle.length) {
            self.subtitleLabel.text = subTitle;
        }
        if (confirmTitle.length) {
            [self.submitBtn setTitle:confirmTitle forState:UIControlStateNormal];
        }
        [self.submitBtn removeTarget:self action:@selector(submitBtnDidClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.submitBtn btd_addActionBlock:^(__kindof UIControl * _Nonnull sender) {
            [weakSelf dismiss];
            if (weakSelf.secondConfirmBlock) {
                weakSelf.secondConfirmBlock();
            }
        } forControlEvents:UIControlEventTouchUpInside];
        
        [self.submitBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(40);
            make.top.mas_equalTo(self.subtitleLabel.mas_bottom).mas_offset(20);
            make.left.mas_equalTo(self.subtitleLabel);
            make.right.mas_equalTo(-20);
        }];
        
        UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
        cancelButton.titleLabel.font = [UIFont themeFontRegular:12];
        [cancelButton setTitleColor:[UIColor themeGray3] forState:UIControlStateNormal];
        [cancelButton btd_addActionBlock:^(__kindof UIControl * _Nonnull sender) {
            if (weakSelf.revokeAssociateDistributionBlock) {
                weakSelf.revokeAssociateDistributionBlock();
            }
        } forControlEvents:UIControlEventTouchUpInside];
        [cancelButton setTitle:cancelTitle.length ? cancelTitle : @"拒绝联系" forState:UIControlStateNormal];
        [self.contentView addSubview:cancelButton];
        [cancelButton sizeToFit];
        cancelButton.frame = CGRectMake(CGRectGetMidX(self.contentView.bounds) - cancelButton.frame.size.width/2, CGRectGetHeight(self.contentView.bounds), cancelButton.frame.size.width, cancelButton.frame.size.height);
        [cancelButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(20);
            make.top.mas_equalTo(self.submitBtn.mas_bottom).mas_offset(16);
            make.bottom.mas_equalTo(-16);
            make.centerX.mas_equalTo(self.contentView);
        }];

        [self layoutIfNeeded];
    }];
}

- (void)showAnotherView:(UIView *)anotherView {
    [self endEditing:YES];
    NSArray *subViews = self.contentView.subviews.copy;
    for (UIView *v in subViews) {
        [v removeFromSuperview];
    }
    [self.contentView addSubview:anotherView];
    [anotherView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.bottom.mas_equalTo(self.contentView);
        make.height.mas_equalTo(anotherView.height);
    }];
    [self layoutIfNeeded];
}

- (UIView *)contentView
{
    if (!_contentView) {
        _contentView = [[UIView alloc]init];
        _contentView.backgroundColor = [UIColor whiteColor];
        _contentView.layer.cornerRadius = 10;
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
        UIImage *img = ICON_FONT_IMG(20, @"\U0000e673", [UIColor colorWithHexStr:@"#d8d8d8"]);
        [_closeBtn setImage:img forState:UIControlStateNormal];
        [_closeBtn setImage:img forState:UIControlStateHighlighted];
    }
    return _closeBtn;
}

- (UITextField *)phoneTextField
{
    if (!_phoneTextField) {
        _phoneTextField = [[UITextField alloc]init];
        _phoneTextField.keyboardType = UIKeyboardTypeNumberPad;
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
        _errorTextLabel.textColor = [UIColor themeOrange1];
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
        _submitBtn.layer.cornerRadius = 20;
        _submitBtn.backgroundColor = [UIColor colorWithHexStr:@"#ff9629"];
    }
    return _submitBtn;
}

- (UILabel *)tipLabel
{
    if (!_tipLabel) {
        _tipLabel = [[UILabel alloc]init];
        _tipLabel.font = [UIFont themeFontRegular:12];
        _tipLabel.textColor = [UIColor themeGray4];
        if ([SSCommonLogic isEnableVerifyFormAssociate]) {
            NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:@"我已阅读《个人信息保护声明》"];
            [attrStr addAttribute:NSUnderlineStyleAttributeName value:@(NSUnderlineStyleSingle) range:NSMakeRange(5, @"个人信息保护声明".length)];
            _tipLabel.attributedText = attrStr;
        } else {
            NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:@"提交即视为同意《个人信息保护声明》"];
            [attrStr addAttribute:NSUnderlineStyleAttributeName value:@(NSUnderlineStyleSingle) range:NSMakeRange(8, @"个人信息保护声明".length)];
            _tipLabel.attributedText = attrStr;
        }
    }
    return _tipLabel;
}

@end
