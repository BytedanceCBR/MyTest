//
//  FHMobileBindingView.m
//  Pods
//
//  Created by bytedance on 2020/4/21.
//

#import "FHMobileBindingView.h"
#import "FHLoginDefine.h"
#import <Masonry/Masonry.h>
#import <FHCommonUI/UIColor+Theme.h>
#import <FHCommonUI/UIFont+House.h>
#import "YYLabel.h"
#import "NSAttributedString+YYText.h"
#import <ByteDanceKit/ByteDanceKit.h>

@interface FHMobileBindingView ()

@property (nonatomic, strong) UIButton *confirmButton;

@property (nonatomic, assign) NSUInteger textNumber;

@end

@implementation FHMobileBindingView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        UILabel *titleLabel = [[UILabel alloc] init];
        titleLabel.font = [UIFont themeFontMedium:30];
        titleLabel.textColor = [UIColor themeGray1];
        titleLabel.text = @"绑定手机号";
        [self addSubview:titleLabel];
        [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(30);
            make.left.mas_equalTo(30);
            make.height.mas_equalTo(42);
        }];
        
        UILabel *subTitleLabel = [[UILabel alloc] init];
        subTitleLabel.font = [UIFont themeFontRegular:14];
        subTitleLabel.textColor = [UIColor themeGray3];
        subTitleLabel.numberOfLines = 0;
        subTitleLabel.text = @"为了你的账号安全，请先绑定手机，我们会严格保护你的手机号信息";
        [self addSubview:subTitleLabel];
        [subTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
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
            make.top.mas_equalTo(subTitleLabel.mas_bottom).offset(40);
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

- (void)confirmButtonAction {
    if (self.mobileTextField.text.length < 11) {
        return;
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(sendVerifyCode:needPush:isForBindMobile:)]) {
        [self.delegate sendVerifyCode:self.mobileTextField.text needPush:YES isForBindMobile:YES];
    }
}

@end
