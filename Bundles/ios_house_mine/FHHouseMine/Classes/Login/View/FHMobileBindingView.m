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

@end

@implementation FHMobileBindingView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        UILabel *titleLabel = [[UILabel alloc] init];
        titleLabel.font = [UIFont themeFontRegular:30];
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
//        mobileTextField.delegate = self;
        [mobileTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
        [self addSubview:mobileTextField];
        self.mobileTextField = mobileTextField;
        [self.mobileTextField mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(subTitleLabel.mas_bottom).offset(40);
            make.left.mas_equalTo(titleLabel.mas_left);
            make.right.mas_equalTo(-30);
            make.height.mas_equalTo(56);
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

- (void)confirmButtonAction {
    if (self.mobileTextField.text.length < 11) {
        return;
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(sendVerifyCode:needPush:isForBindMobile:)]) {
        [self.delegate sendVerifyCode:self.mobileTextField.text needPush:YES isForBindMobile:YES];
    }
}

@end
