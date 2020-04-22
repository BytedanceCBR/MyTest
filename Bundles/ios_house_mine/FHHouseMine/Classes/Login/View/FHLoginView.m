//
//  FHLoginView.m
//  FHHouseMine
//
//  Created by 谢思铭 on 2019/2/14.
//

#import "FHLoginView.h"
#import "UIFont+House.h"
#import "Masonry.h"
#import "UIColor+Theme.h"
#import "TTDeviceHelper.h"
#import "YYLabel.h"
#import "NSAttributedString+YYText.h"
#import "ToastManager.h"
#import "FHNavBarView.h"
#import <TTBaseLib/UIViewAdditions.h>
#import "FHLoginDefine.h"

@implementation FHLoginAcceptButton : UIButton
- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    CGRect bounds = self.bounds;
    UIEdgeInsets insets = self.hotAreaInsets;
    CGFloat widthDelta = insets.left + insets.right;
    CGFloat heightDelta = insets.bottom + insets.top;
    CGRect hotAreaBounds = CGRectMake(bounds.origin.x - insets.left, bounds.origin.y - insets.top, bounds.size.width + widthDelta, bounds.size.height + heightDelta);
    if (!CGRectContainsPoint(hotAreaBounds, point)) {
        insets = self.hotAreaInsets2;
        widthDelta = insets.left + insets.right;
        heightDelta = insets.bottom + insets.top;
        hotAreaBounds = CGRectMake(bounds.origin.x - insets.left, bounds.origin.y - insets.top, bounds.size.width + widthDelta, bounds.size.height + heightDelta);
        return CGRectContainsPoint(hotAreaBounds, point);
    }
    return YES;
}

@end

@interface FHLoginView ()

@property(nonatomic, strong) UILabel *titleLabel;
@property(nonatomic, strong) UILabel *serviceLabel;
@property(nonatomic, strong) UILabel *subTitleLabel;
@property(nonatomic, strong) UIView *rightView;
@property(nonatomic, strong) UIView *singleLine;
@property(nonatomic, strong) UIView *singleLine2;
@property(nonatomic, strong) UIButton *confirmBtn;
@property(nonatomic, strong) UIButton *otherLoginBtn;
@property(nonatomic, strong) YYLabel *agreementLabel;
@end

@implementation FHLoginView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];

    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        [self initViews];
    }
    return self;
}

- (void)initViews {
    self.scrollView = [[UIScrollView alloc] init];
//    _scrollView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    [self addSubview:_scrollView];
    [self.scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.left.right.mas_equalTo(self);
    }];

    self.titleLabel = [self LabelWithFont:[UIFont themeFontRegular:30] textColor:[UIColor themeGray1]];
    _titleLabel.text = @"手机快捷登录";
    [self.scrollView addSubview:_titleLabel];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.scrollView).offset(40);
        make.left.mas_equalTo(self.scrollView).offset(30);
        make.height.mas_equalTo(42);
    }];

    self.serviceLabel = [self LabelWithFont:[UIFont themeFontRegular:14] textColor:[UIColor themeGray3]];
    self.serviceLabel.hidden = YES;
    [self.scrollView addSubview:self.serviceLabel];
    [self.serviceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.singleLine);
        make.centerY.mas_equalTo(self.phoneInput);
    }];

    self.subTitleLabel = [self LabelWithFont:[UIFont themeFontRegular:14] textColor:[UIColor themeGray3]];
    _subTitleLabel.text = @"未注册手机验证后自动注册";
    [self.scrollView addSubview:_subTitleLabel];
    [self.subTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.titleLabel.mas_bottom).offset(6);
        make.left.mas_equalTo(self.scrollView).offset(30);
        make.height.mas_equalTo(20);
    }];

    self.rightView = [[UIView alloc] init];
    [self.scrollView addSubview:_rightView];
    [self.rightView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.scrollView);
        make.left.mas_equalTo(self.scrollView).offset(30);
        make.right.mas_equalTo(self).offset(-30);
        make.height.mas_equalTo(1);
    }];

    self.phoneInput = [[UITextField alloc] init];
    _phoneInput.font = [UIFont themeFontRegular:14];
    _phoneInput.placeholder = @"请输入手机号";
    _phoneInput.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"请输入手机号" attributes:@{NSForegroundColorAttributeName: [UIColor themeGray3]}];
    _phoneInput.keyboardType = UIKeyboardTypePhonePad;
    _phoneInput.returnKeyType = UIReturnKeyDone;
    [self.scrollView addSubview:_phoneInput];
    [self.phoneInput mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.subTitleLabel.mas_bottom).offset(40);
        make.left.mas_equalTo(self.titleLabel);
        make.right.mas_equalTo(self.rightView);
        make.height.mas_equalTo(20);
    }];

    self.singleLine = [[UIView alloc] init];
    _singleLine.backgroundColor = [UIColor themeGray6];
    [self.scrollView addSubview:_singleLine];
    [self.singleLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.phoneInput.mas_bottom).offset(11);
        make.left.mas_equalTo(self.titleLabel);
        make.right.mas_equalTo(self.rightView);
        make.height.mas_equalTo(TTDeviceHelper.ssOnePixel);
    }];

    self.varifyCodeInput = [[UITextField alloc] init];
    _varifyCodeInput.font = [UIFont themeFontRegular:14];
    _varifyCodeInput.placeholder = @"请输入验证码";
    _varifyCodeInput.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"请输入验证码" attributes:@{NSForegroundColorAttributeName: [UIColor themeGray3]}];
    _varifyCodeInput.keyboardType = UIKeyboardTypePhonePad;
    _varifyCodeInput.returnKeyType = UIReturnKeyGo;
    [self.scrollView addSubview:_varifyCodeInput];
    [self.varifyCodeInput mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.phoneInput.mas_bottom).offset(43);
        make.left.mas_equalTo(self.titleLabel);
        make.right.mas_equalTo(self.rightView);
        make.height.mas_equalTo(20);
    }];

    self.singleLine2 = [[UIView alloc] init];
    _singleLine2.backgroundColor = [UIColor themeGray6];
    [self.scrollView addSubview:_singleLine2];
    [self.singleLine2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.varifyCodeInput.mas_bottom).offset(11);
        make.left.mas_equalTo(self.titleLabel);
        make.right.mas_equalTo(self.rightView);
        make.height.mas_equalTo(TTDeviceHelper.ssOnePixel);
    }];

    self.sendVerifyCodeBtn = [[UIButton alloc] init];
    [self setButtonContent:@"获取验证码" font:[UIFont themeFontRegular:14] color:[UIColor themeGray1] state:UIControlStateNormal btn:_sendVerifyCodeBtn];
    [self setButtonContent:@"获取验证码" font:[UIFont themeFontRegular:14] color:[UIColor themeGray3] state:UIControlStateDisabled btn:_sendVerifyCodeBtn];
    _sendVerifyCodeBtn.enabled = NO;
    [_sendVerifyCodeBtn addTarget:self action:@selector(sendVerifyCode) forControlEvents:UIControlEventTouchUpInside];
    [self.scrollView addSubview:_sendVerifyCodeBtn];
    [self.sendVerifyCodeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.varifyCodeInput);
        make.right.mas_equalTo(self.rightView);
        make.height.mas_equalTo(30);
    }];

    self.agreementLabel = [[YYLabel alloc] init];
    _agreementLabel.numberOfLines = 0;
    _agreementLabel.lineBreakMode = NSLineBreakByWordWrapping;
    _agreementLabel.textColor = [UIColor themeGray3];
    _agreementLabel.font = [UIFont themeFontRegular:13];
    [self.scrollView addSubview:_agreementLabel];
    [self.agreementLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.titleLabel);
        make.top.mas_equalTo(self.singleLine.mas_bottom).offset(20);
        make.right.mas_equalTo(self.rightView);
        make.height.mas_equalTo(0);
    }];
    
    self.confirmBtn = [[UIButton alloc] init];
    _confirmBtn.backgroundColor = [UIColor themeOrange4];
    _confirmBtn.alpha = 0.6;
    _confirmBtn.layer.cornerRadius = 23; //4;
    [_confirmBtn addTarget:self action:@selector(confirm) forControlEvents:UIControlEventTouchUpInside];
    [self setButtonContent:@"登录" font:[UIFont themeFontRegular:16] color:[UIColor whiteColor] state:UIControlStateNormal btn:_confirmBtn];
    [self.scrollView addSubview:_confirmBtn];
    [self.confirmBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.agreementLabel.mas_bottom).offset(20);
        make.left.mas_equalTo(self.titleLabel);
        make.right.mas_equalTo(self.rightView);
        make.height.mas_equalTo(46);
    }];

    self.otherLoginBtn = [[UIButton alloc] init];
    [self setButtonContent:@"其他方式登录" font:[UIFont themeFontRegular:14] color:[UIColor themeGray2] state:UIControlStateNormal btn:self.otherLoginBtn];
    [self setButtonContent:@"其他方式登录" font:[UIFont themeFontRegular:14] color:[UIColor themeGray2] state:UIControlStateHighlighted btn:self.otherLoginBtn];
    [self.scrollView addSubview:self.otherLoginBtn];
    [self.otherLoginBtn addTarget:self action:@selector(otherLoginBtnDidClick:) forControlEvents:UIControlEventTouchUpInside];
    self.otherLoginBtn.hitTestEdgeInsets = UIEdgeInsetsMake(-5, -5, -5, -5);
    self.otherLoginBtn.hidden = YES;
    [self.otherLoginBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.confirmBtn);
        make.top.mas_equalTo(self.confirmBtn.mas_bottom).mas_offset(20);
        make.height.mas_equalTo(20);
    }];

//    self.acceptCheckBox = [[FHLoginAcceptButton alloc] init];
//    self.acceptCheckBox.hotAreaInsets = UIEdgeInsetsMake(20, 30, 0, 30);
//    self.acceptCheckBox.hotAreaInsets2 = UIEdgeInsetsMake(20, 30, 20, 0);
//    [_acceptCheckBox setImage:[UIImage imageNamed:@"login_checkbox-checked"] forState:UIControlStateSelected];
//    [_acceptCheckBox setImage:[UIImage imageNamed:@"ic-filter-normal"] forState:UIControlStateNormal];
//    [_acceptCheckBox addTarget:self action:@selector(acceptCheckBoxChange) forControlEvents:UIControlEventTouchUpInside];
//    [self.scrollView addSubview:_acceptCheckBox];
    
    UIStackView *stackView = [[UIStackView alloc] init];
//    stackView.distribution = UIStackViewDistributionEqualSpacing;
    stackView.alignment = UIStackViewAlignmentCenter;
    stackView.axis = UILayoutConstraintAxisHorizontal;
    [self.scrollView addSubview:stackView];
    [stackView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.otherLoginBtn.mas_bottom).mas_offset(20);
        make.width.mas_equalTo(40+138+20);
        make.height.mas_equalTo(40);
        make.centerX.mas_equalTo(self);
    }];
    
    UIButton *douyinLoginButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [douyinLoginButton setImage:[UIImage imageNamed:@"douyin_login_common_icon"] forState:UIControlStateNormal];
    [douyinLoginButton addTarget:self action:@selector(douyinLoginAction) forControlEvents:UIControlEventTouchUpInside];
    [douyinLoginButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(40, 40));
    }];
    [stackView addArrangedSubview:douyinLoginButton];
    
    UIButton *appleLoginButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [appleLoginButton setImage:[UIImage imageNamed:@"apple_login_icon"] forState:UIControlStateNormal];
    [appleLoginButton addTarget:self action:@selector(appleLoginAction) forControlEvents:UIControlEventTouchUpInside];
    [appleLoginButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(138, 40));
    }];
    [stackView addArrangedSubview:appleLoginButton];
    

}

- (void)showOneKeyLoginView:(BOOL)isOneKeyLogin {
    _isOneKeyLogin = isOneKeyLogin;
    if (isOneKeyLogin) {
        self.titleLabel.text = @"一键登录";
        self.subTitleLabel.text = @"登录幸福里，关注好房永不丢失";
        self.serviceLabel.hidden = NO;
        self.otherLoginBtn.hidden = NO;
//        self.acceptCheckBox.hidden = YES;
        self.varifyCodeInput.hidden = YES;
        self.singleLine2.hidden = YES;
        self.sendVerifyCodeBtn.hidden = YES;
        self.phoneInput.enabled = NO;
        [self.agreementLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.singleLine.mas_bottom).offset(20);
        }];

    } else {
        self.titleLabel.text = @"手机快捷登录";
        self.subTitleLabel.text = @"未注册手机验证后自动注册";
        self.serviceLabel.hidden = YES;
        self.otherLoginBtn.hidden = YES;
//        self.acceptCheckBox.hidden = NO;
        self.varifyCodeInput.hidden = NO;
        self.singleLine2.hidden = NO;
        self.sendVerifyCodeBtn.hidden = NO;
        self.phoneInput.enabled = YES;
        [self.agreementLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.singleLine.mas_bottom).offset(20 + 60);
        }];
    }
}

- (void)updateOneKeyLoginWithPhone:(NSString *)phoneNum service:(NSString *)service {
    self.phoneInput.text = phoneNum;
    self.serviceLabel.text = service;
    [self enableConfirmBtn:phoneNum.length > 0];
}

- (void)setAgreementContent:(NSAttributedString *)attrText showAcceptBox:(BOOL)showAcceptBox {
    self.agreementLabel.attributedText = attrText;
    CGFloat boxWidth = showAcceptBox ? 15 : 0;
    CGFloat boxOffset = showAcceptBox ? 3 : 0;
    CGFloat topOffset = !self.isOneKeyLogin ? 60 : 0;
    CGFloat width = UIScreen.mainScreen.bounds.size.width - 45 - 3 - 30;
    CGSize size = [self.agreementLabel sizeThatFits:CGSizeMake(width, 1000)];

    [self.agreementLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.titleLabel);
        make.top.mas_equalTo(self.singleLine.mas_bottom).offset(20 + topOffset);
        make.right.mas_equalTo(self.rightView);
        make.height.mas_equalTo(size.height);
    }];
}

- (NSDictionary *)commonTextStyle {
    return @{
            NSFontAttributeName: [UIFont themeFontRegular:13],
            NSForegroundColorAttributeName: [UIColor themeGray3],
    };
}

- (UILabel *)LabelWithFont:(UIFont *)font textColor:(UIColor *)textColor {
    UILabel *label = [[UILabel alloc] init];
    label.font = font;
    label.textColor = textColor;
    return label;
}

- (void)setButtonContent:(NSString *)content font:(UIFont *)font color:(UIColor *)color state:(UIControlState)state btn:(UIButton *)btn {
    NSDictionary *attributes = @{
            NSFontAttributeName: font,
            NSForegroundColorAttributeName: color,
            NSUnderlineColorAttributeName: [UIColor clearColor]
    };
    NSAttributedString *attrStr = [[NSAttributedString alloc] initWithString:content attributes:attributes];
    [btn setAttributedTitle:attrStr forState:state];
}

- (void)confirm {
//    if (self.isOneKeyLogin) {
//        if (self.delegate && [self.delegate respondsToSelector:@selector(oneKeyLoginAction)]) {
//            [self.delegate oneKeyLoginAction];
//        }
//    } else {
//        if (self.delegate && [self.delegate respondsToSelector:@selector(confirm)]) {
//            [self.delegate confirm];
//        }
//    }
}

- (void)otherLoginBtnDidClick:(UIButton *)btn {
//    if (self.delegate && [self.delegate respondsToSelector:@selector(verifyCodeLoginAction)]) {
//        [self.delegate verifyCodeLoginAction];
//    }
}

//- (void)acceptCheckBoxChange {
//    if (self.delegate && [self.delegate respondsToSelector:@selector(acceptCheckBoxChange:)]) {
//        [self.delegate acceptCheckBoxChange:self.acceptCheckBox.selected];
//    }
//}

- (void)sendVerifyCode {
//    if (self.delegate && [self.delegate respondsToSelector:@selector(sendVerifyCode:needPush:)]) {
//        [self.delegate sendVerifyCode:<#(nonnull NSString *)#> needPush:<#(BOOL)#>];
//    }
}

- (void)enableConfirmBtn:(BOOL)enabled {
    if (enabled) {
        self.confirmBtn.alpha = 1;
    } else {
        self.confirmBtn.alpha = 0.6;
    }
}

- (void)enableSendVerifyCodeBtn:(BOOL)enabled {
    self.sendVerifyCodeBtn.enabled = enabled;
}

- (void)douyinLoginAction {
    if (self.delegate && [self.delegate respondsToSelector:@selector(douyinLoginActiondouyinLoginAction)]) {
        [self.delegate douyinLoginAction];
    }
}

- (void)appleLoginAction {
    if (self.delegate && [self.delegate respondsToSelector:@selector(appleLoginAction)]) {
        [self.delegate appleLoginAction];
    }
}

@end
