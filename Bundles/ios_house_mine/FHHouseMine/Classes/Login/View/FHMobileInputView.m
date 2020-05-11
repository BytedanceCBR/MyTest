//
//  FHMobileInputView.m
//  AKCommentPlugin
//
//  Created by bytedance on 2020/4/14.
//

#import "FHMobileInputView.h"
#import "FHLoginDefine.h"
#import <Masonry/Masonry.h>
#import <FHCommonUI/UIColor+Theme.h>
#import <FHCommonUI/UIFont+House.h>
#import "YYLabel.h"
#import "NSAttributedString+YYText.h"
#import <ByteDanceKit/ByteDanceKit.h>
#import "FHLoginVerifyCodeTextField.h"

@interface FHMobileInputView ()<UITextFieldDelegate>

@property (nonatomic, strong) YYLabel *agreementLabel;

@property (nonatomic, strong) UIButton *confirmButton;

@property (nonatomic, strong) UIStackView *stackView;

@property (nonatomic, assign) NSUInteger textNumber;

@end

@implementation FHMobileInputView

- (void)dealloc {
    _mobileTextField.delegate = nil;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        UILabel *titleLabel = [[UILabel alloc] init];
        titleLabel.font = [UIFont themeFontRegular:30];
        titleLabel.textColor = [UIColor themeGray1];
        titleLabel.text = @"手机快捷登录";
        [self addSubview:titleLabel];
        [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(30);
            make.left.mas_equalTo(30);
            make.height.mas_equalTo(42);
        }];
        
        self.agreementLabel = [[YYLabel alloc] init];
        _agreementLabel.numberOfLines = 0;
        _agreementLabel.lineBreakMode = NSLineBreakByWordWrapping;
        _agreementLabel.textColor = [UIColor themeGray3];
        _agreementLabel.font = [UIFont themeFontRegular:13];
        [self addSubview:_agreementLabel];
        [self.agreementLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(titleLabel.mas_bottom).mas_offset(4);
            make.left.mas_equalTo(titleLabel.mas_left);
            make.right.mas_equalTo(-30);
        }];
        
        UITextField *mobileTextField = [[UITextField alloc] init];
        mobileTextField.font = [UIFont themeFontRegular:20];
        mobileTextField.placeholder = @"请输入手机号";
        mobileTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"请输入手机号" attributes:@{NSForegroundColorAttributeName: [UIColor themeGray5]}];
        mobileTextField.keyboardType = UIKeyboardTypePhonePad;
        mobileTextField.returnKeyType = UIReturnKeyDone;
        mobileTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
//        mobileTextField.delegate = self;
        [mobileTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
        [self addSubview:mobileTextField];
        self.mobileTextField = mobileTextField;
        [self.mobileTextField mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.agreementLabel.mas_bottom).offset(40);
            make.left.mas_equalTo(30);
            make.right.mas_equalTo(-30);
            make.height.mas_equalTo(56);
        }];
        
        UIView *singleLine = [[UIView alloc] init];
        singleLine.backgroundColor = [UIColor themeGray6];
        [self addSubview:singleLine];
        [singleLine mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.mobileTextField.mas_bottom).offset(1);
            make.left.mas_equalTo(30);
            make.right.mas_equalTo(-30);
            make.height.mas_equalTo(1.0/UIScreen.mainScreen.scale);
        }];
        
        self.confirmButton = [UIButton buttonWithType:UIButtonTypeCustom] ;
        self.confirmButton.backgroundColor = [UIColor themeOrange4];
        self.confirmButton.alpha = 0.3;
        [self.confirmButton addTarget:self action:@selector(confirmButtonAction) forControlEvents:UIControlEventTouchUpInside];
        self.confirmButton.titleLabel.font = [UIFont themeFontRegular:16];
        [self.confirmButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.confirmButton setTitle:@"获取验证码" forState:UIControlStateNormal];
//        [self addSubview:self.confirmButton];
        [self.confirmButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(self);
            make.height.mas_equalTo(46);
        }];
        
        self.mobileTextField.inputAccessoryView = self.confirmButton;
        self.textNumber = 0;
    }
    return self;
}

- (void)textFieldDidChange:(UITextField *)textField {
    
    if (textField.text.length > self.textNumber) {
        if (textField.text.length == 4 || textField.text.length == 9 ) {//输入
            NSMutableString * str = [[NSMutableString alloc ] initWithString:textField.text];
            [str insertString:@" " atIndex:(textField.text.length-1)];
            textField.text = str;
        }
        if (textField.text.length >= 13 ) {//输入完成
            textField.text = [textField.text substringToIndex:13];
            self.confirmButton.alpha = 1;
        } else {
            self.confirmButton.alpha = 0.3;
        }
        self.textNumber = textField.text.length;
    } else {
        if (textField.text.length == 4 || textField.text.length == 9) {
            textField.text = [NSString stringWithFormat:@"%@",textField.text];
            textField.text = [textField.text substringToIndex:(textField.text.length-1)];
        }
        self.textNumber = textField.text.length;
        self.confirmButton.alpha = 1;
    }
}

- (void)updateProtocol:(NSAttributedString *)protocol showDouyinIcon:(BOOL )showDouyinIcon{
    self.agreementLabel.attributedText = protocol;
    CGFloat height = [protocol.string btd_heightWithFont:protocol.yy_font width:CGRectGetWidth(UIScreen.mainScreen.bounds) - 60];
    [self.agreementLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(height);
    }];

    if (showDouyinIcon && !self.stackView) {
        UILabel *otherLabel = [[UILabel alloc] init];
        otherLabel.font = [UIFont themeFontRegular:14];
        otherLabel.textColor = [UIColor themeGray3];
        otherLabel.text = @"其他登录";
        [self addSubview:otherLabel];
        [otherLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.mobileTextField.mas_bottom).mas_offset(26);
            make.left.mas_equalTo(30);
        }];
        
        self.stackView = [[UIStackView alloc] init];
        self.stackView.distribution = UIStackViewDistributionEqualSpacing;
        self.stackView.alignment = UIStackViewAlignmentCenter;
        self.stackView.axis = UILayoutConstraintAxisHorizontal;
        [self addSubview:self.stackView];
        
        CGFloat stackViewWidth = 0;
        
        UIButton *douyinLoginButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [douyinLoginButton setImage:[UIImage imageNamed:@"douyin_login_common_icon"] forState:UIControlStateNormal];
        [douyinLoginButton addTarget:self action:@selector(douyinLoginAction) forControlEvents:UIControlEventTouchUpInside];
        [douyinLoginButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(30, 30));
        }];
        [self.stackView addArrangedSubview:douyinLoginButton];
        stackViewWidth += (30);
        
        if (@available(iOS 13.0, *)) {
            UIButton *appleLoginButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [appleLoginButton setImage:[UIImage imageNamed:@"apple_login_icon_small"] forState:UIControlStateNormal];
            [appleLoginButton addTarget:self action:@selector(appleLoginAction) forControlEvents:UIControlEventTouchUpInside];
            [appleLoginButton mas_makeConstraints:^(MASConstraintMaker *make) {
                make.size.mas_equalTo(CGSizeMake(134, 30));
            }];
            [self.stackView addArrangedSubview:appleLoginButton];
            stackViewWidth += (134+20);
        }
        
        [self.stackView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(stackViewWidth);
            make.height.mas_equalTo(30);
            make.centerY.mas_equalTo(otherLabel.mas_centerY);
            make.left.mas_equalTo(otherLabel.mas_right).mas_offset(18);
        }];
    }
}

- (void)douyinLoginAction {
    if (self.delegate && [self.delegate respondsToSelector:@selector(douyinLoginAction)]) {
        [self.delegate douyinLoginAction];
    }
}

- (void)appleLoginAction {
    if (self.delegate && [self.delegate respondsToSelector:@selector(appleLoginAction)]) {
        [self.delegate appleLoginAction];
    }
}

- (void)confirmButtonAction {
    if (self.mobileTextField.text.length < 11) {
        return;
    }
    NSString *mobileNumber = [self.mobileTextField.text stringByReplacingOccurrencesOfString:@" " withString:@""];

    if (self.delegate && [self.delegate respondsToSelector:@selector(sendVerifyCode:needPush:isForBindMobile:)]) {
        [self.delegate sendVerifyCode:mobileNumber needPush:YES isForBindMobile:NO];
    }
}

@end
