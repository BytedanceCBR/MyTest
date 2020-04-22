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
//        mobileTextField.delegate = self;
        [mobileTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
        [self addSubview:mobileTextField];
        self.mobileTextField = mobileTextField;
        [self.mobileTextField mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.agreementLabel.mas_bottom).offset(40);
            make.left.mas_equalTo(titleLabel.mas_left);
            make.right.mas_equalTo(-30);
            make.height.mas_equalTo(56);
        }];
        
        UILabel *otherLabel = [[UILabel alloc] init];
        otherLabel.font = [UIFont themeFontRegular:14];
        otherLabel.textColor = [UIColor themeGray3];
        otherLabel.text = @"其他登录";
        [self addSubview:otherLabel];
        [otherLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.mobileTextField.mas_bottom).mas_offset(26);
            make.left.mas_equalTo(titleLabel.mas_left);
        }];
        
        UIStackView *stackView = [[UIStackView alloc] init];
        stackView.distribution = UIStackViewDistributionEqualSpacing;
        stackView.alignment = UIStackViewAlignmentCenter;
        stackView.axis = UILayoutConstraintAxisHorizontal;
        [self addSubview:stackView];
        
        CGFloat stackViewWidth = 0;
        
        UIButton *douyinLoginButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [douyinLoginButton setImage:[UIImage imageNamed:@"douyin_login_common_icon"] forState:UIControlStateNormal];
        [douyinLoginButton addTarget:self action:@selector(douyinLoginAction) forControlEvents:UIControlEventTouchUpInside];
        [douyinLoginButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(38, 38));
        }];
        [stackView addArrangedSubview:douyinLoginButton];
        stackViewWidth += (38);
        
        if (@available(iOS 13.0, *)) {
            UIButton *appleLoginButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [appleLoginButton setImage:[UIImage imageNamed:@"apple_login_icon"] forState:UIControlStateNormal];
            [appleLoginButton addTarget:self action:@selector(appleLoginAction) forControlEvents:UIControlEventTouchUpInside];
            [appleLoginButton mas_makeConstraints:^(MASConstraintMaker *make) {
                make.size.mas_equalTo(CGSizeMake(138, 38));
            }];
            [stackView addArrangedSubview:appleLoginButton];
            stackViewWidth += (138+20);
        }
        
        [stackView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(stackViewWidth);
            make.height.mas_equalTo(40);
            make.centerY.mas_equalTo(otherLabel.mas_centerY);
            make.left.mas_equalTo(otherLabel.mas_right).mas_offset(18);
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
    }
    return self;
}

- (void)textFieldDidChange:(UITextField *)textField {
    NSString *text = textField.text;
    NSInteger limit = 11;
    if(text.length > limit){
        textField.text = [text substringToIndex:limit];
    }
    
    if (text.length >= limit) {
        self.confirmButton.alpha = 1;
    } else {
        self.confirmButton.alpha = 0.3;
    }

}

- (void)updateProtocol:(NSAttributedString *)protocol{
    self.agreementLabel.attributedText = protocol;
    CGFloat height = [protocol.string btd_heightWithFont:protocol.yy_font width:CGRectGetWidth(UIScreen.mainScreen.bounds) - 60];
    [self.agreementLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(height);
    }];

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

- (void)confirmButtonAction {
    if (self.mobileTextField.text.length < 11) {
        return;
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(sendVerifyCode:needPush:isForBindMobile:)]) {
        [self.delegate sendVerifyCode:self.mobileTextField.text needPush:YES isForBindMobile:NO];
    }
}

@end
