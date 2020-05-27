//
//  FHVerifyCodeInputView.m
//  Pods
//
//  Created by bytedance on 2020/4/14.
//

#import "FHVerifyCodeInputView.h"
#import "FHLoginDefine.h"
#import <Masonry/Masonry.h>
#import <FHCommonUI/UIColor+Theme.h>
#import <FHCommonUI/UIFont+House.h>
#import "FHLoginVerifyCodeTextField.h"

@interface FHVerifyCodeInputView ()<UITextFieldDelegate,FHVerifyCodeTextFieldDeleteDelegate>

@property (nonatomic, strong) UILabel *mobileNumberLabel;

@property (nonatomic, weak) FHLoginVerifyCodeTextField *codeTextFieldOne;
@property (nonatomic, weak) FHLoginVerifyCodeTextField *codeTextFieldTwo;
@property (nonatomic, weak) FHLoginVerifyCodeTextField *codeTextFieldThree;
@property (nonatomic, weak) FHLoginVerifyCodeTextField *codeTextFieldFour;

@property (nonatomic, strong) UIButton *sendVerifyCodeButton;

@property (nonatomic, copy) NSString *mobileNumber;
@end

@implementation FHVerifyCodeInputView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        UILabel *titleLabel = [[UILabel alloc] init];
        titleLabel.font = [UIFont themeFontRegular:30];
        titleLabel.textColor = [UIColor themeGray1];
        titleLabel.text = @"获取验证码";
        [self addSubview:titleLabel];
        [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(30);
            make.left.mas_equalTo(30);
            make.height.mas_equalTo(42);
        }];
        
        self.mobileNumberLabel = [[UILabel alloc] init];
        _mobileNumberLabel.font = [UIFont themeFontRegular:14];
        _mobileNumberLabel.textColor = [UIColor themeGray3];
        [self addSubview:_mobileNumberLabel];
        [self.mobileNumberLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(titleLabel.mas_bottom).mas_offset(4);
            make.left.mas_equalTo(titleLabel.mas_left);
            make.height.mas_equalTo(20);
        }];
        
        UIButton *changeNumberButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [changeNumberButton setImage:[UIImage imageNamed:@"login_change_phote_button"] forState:UIControlStateNormal];
        [changeNumberButton setTitle:@"修改" forState:UIControlStateNormal];
        [changeNumberButton setTitleColor:[UIColor themeGray2] forState:UIControlStateNormal];
        changeNumberButton.titleLabel.font = [UIFont themeFontRegular:14];
        [changeNumberButton addTarget:self action:@selector(changeNumberAction) forControlEvents:UIControlEventTouchUpInside];
        changeNumberButton.titleEdgeInsets = UIEdgeInsetsMake(0, 4, 0, 0);
        [self addSubview:changeNumberButton];
        [changeNumberButton sizeToFit];
        [changeNumberButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.mobileNumberLabel.mas_right).mas_offset(6);
            make.centerY.mas_equalTo(self.mobileNumberLabel.mas_centerY);
            make.width.mas_equalTo(changeNumberButton.frame.size.width + 4);
        }];
        
        self.sendVerifyCodeButton = [UIButton buttonWithType:UIButtonTypeCustom] ;
//        self.sendVerifyCodeButton.backgroundColor = [UIColor themeOrange4];
        self.sendVerifyCodeButton.backgroundColor = [UIColor themeGray7];
//        self.sendVerifyCodeButton.alpha = 0.3;
        [self.sendVerifyCodeButton addTarget:self action:@selector(sendVerifyCodeAction) forControlEvents:UIControlEventTouchUpInside];
        self.sendVerifyCodeButton.titleLabel.font = [UIFont themeFontRegular:16];
        [self.sendVerifyCodeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.sendVerifyCodeButton setTitleColor:[UIColor themeGray3] forState:UIControlStateDisabled];
        [self.sendVerifyCodeButton setTitle:@"发送验证码" forState:UIControlStateNormal];
        self.sendVerifyCodeButton.enabled = NO;
        [self.sendVerifyCodeButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(self);
            make.height.mas_equalTo(46);
        }];
        
        UIStackView *stackView = [[UIStackView alloc] init];
        stackView.distribution = UIStackViewDistributionEqualSpacing;
        stackView.alignment = UIStackViewAlignmentCenter;
        stackView.axis = UILayoutConstraintAxisHorizontal;
        [self addSubview:stackView];

        CGFloat stackViewWidth = 62 * 4 + 25 * 3;//CGRectGetWidth(self.frame) - 30 * 2;

        FHLoginVerifyCodeTextField *codeTextFieldOne = [[FHLoginVerifyCodeTextField alloc] init];
        [stackView addArrangedSubview:[self setupTextField:codeTextFieldOne]];

        FHLoginVerifyCodeTextField *codeTextFieldTwo = [[FHLoginVerifyCodeTextField alloc] init];
        [stackView addArrangedSubview:[self setupTextField:codeTextFieldTwo]];

        FHLoginVerifyCodeTextField *codeTextFieldThree = [[FHLoginVerifyCodeTextField alloc] init];
        [stackView addArrangedSubview:[self setupTextField:codeTextFieldThree]];

        FHLoginVerifyCodeTextField *codeTextFieldFour = [[FHLoginVerifyCodeTextField alloc] init];
        [stackView addArrangedSubview:[self setupTextField:codeTextFieldFour]];

        [stackView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(stackViewWidth);
            make.height.mas_equalTo(62);
            make.centerX.mas_equalTo(self);
            make.top.mas_equalTo(self.mobileNumberLabel.mas_bottom).mas_offset(40);
        }];

        self.codeTextFieldOne = codeTextFieldOne;
        self.codeTextFieldTwo = codeTextFieldTwo;
        self.codeTextFieldThree = codeTextFieldThree;
        self.codeTextFieldFour = codeTextFieldFour;
        self.textFieldArray = @[codeTextFieldOne, codeTextFieldTwo, codeTextFieldThree, codeTextFieldFour];
    }
    return self;
}

- (UIView *)setupTextField:(FHLoginVerifyCodeTextField *)textField{
    
    CGFloat stackViewWidth = 62 * 4 + 25 * 3;//CGRectGetWidth(self.frame) - 30 * 2;
    CGFloat itemMargin = 25;
    CGFloat itemWidth = 62;//floor((stackViewWidth - itemMargin) / 4.0);
    CGFloat itemHeight = 62;
    
    UIView *itemView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, itemWidth, itemHeight)];
    [itemView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(itemWidth, itemHeight));
    }];
    
    textField.textAlignment = NSTextAlignmentCenter;
//    textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
//    textField.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    textField.font = [UIFont themeFontRegular:24];
    textField.textColor = [UIColor themeGray1];
    textField.keyboardType = UIKeyboardTypeNumberPad;
    textField.returnKeyType = UIReturnKeyDone;
    if (@available(iOS 12.0, *)) {
        textField.textContentType = UITextContentTypeOneTimeCode;
    }
    textField.deleteDelegate = self;
    textField.delegate = self;
//    [textField addTarget:self action:@selector(textFiledDidChange:) forControlEvents:UIControlEventEditingChanged];
    
    textField.inputAccessoryView = self.sendVerifyCodeButton;
    [itemView addSubview:textField];
    [textField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsZero);
    }];

    [self addLineOnItemView:itemView];
    
    return itemView;
}

- (void)addLineOnItemView:(UIView *)itemView {
    UIView *lineView = [[UIView alloc] init];
    lineView.backgroundColor = [UIColor themeGray6];
    [itemView addSubview:lineView];
    [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.right.mas_equalTo(0);
        make.height.mas_equalTo(1.0/UIScreen.mainScreen.scale);
        make.bottom.mas_equalTo(0);
    }];
}

- (void)changeNumberAction {
    if (self.delegate && [self.delegate respondsToSelector:@selector(popLastViewController)]) {
        [self.delegate popLastViewController];
    }
}

- (void)sendVerifyCodeAction {
    for (UITextField *textField in self.textFieldArray) {
        textField.text = @"";
        if (textField.isFirstResponder) {
            [textField resignFirstResponder];
        }
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(sendVerifyCode:needPush:isForBindMobile:)]) {
        [self.delegate sendVerifyCode:self.mobileNumber needPush:NO isForBindMobile:self.isForBindMobile];
    }
    
    [self.textFieldArray.firstObject becomeFirstResponder];
}

- (void)updateMobileNumber:(NSString *)mobileNumber {
    self.mobileNumber = mobileNumber;
    NSString *formattedMobile;
    if (self.mobileNumber.length == 11) {
        formattedMobile = [NSString stringWithFormat:@"%@ %@ %@",[self.mobileNumber substringWithRange:NSMakeRange(0, 3)],[self.mobileNumber substringWithRange:NSMakeRange(3, 4)],[self.mobileNumber substringWithRange:NSMakeRange(7, 4)]];
    }
    self.mobileNumberLabel.text = [NSString stringWithFormat:@"验证码已发送至 %@",formattedMobile];
}

- (void)updateTimeCountDownValue:(NSInteger )countdownSeconds{
    if (countdownSeconds == 0) {
        self.sendVerifyCodeButton.enabled = YES;
        self.sendVerifyCodeButton.backgroundColor = [UIColor themeOrange4];
        [self.sendVerifyCodeButton setTitle:@"重新发送" forState:UIControlStateNormal];
    } else {
        self.sendVerifyCodeButton.enabled = NO;
        self.sendVerifyCodeButton.backgroundColor = [UIColor themeGray7];
        [self.sendVerifyCodeButton setTitle:[NSString stringWithFormat:@"重新发送(%lis)", (long) countdownSeconds] forState:UIControlStateDisabled];
    }
}

- (void)clearTextFieldText {
    for (UITextField *textField in self.textFieldArray) {
        if (textField.isFirstResponder) {
            [textField resignFirstResponder];
        }
        textField.text = @"";
    }
    [self.textFieldArray.firstObject becomeFirstResponder];
}

//- (void)textFiledDidChange:(UITextField *)textField {
//    // 这个地方再考虑一下，可以使用一个 string 来保存 smsCode 的更改，来判断 应该哪个 textField 弹键盘
//    if (textField == self.codeTextFieldOne) {
//        if (self.codeTextFieldOne.text.length == 1) {
//            [self.codeTextFieldTwo becomeFirstResponder];
//        }
//    } else if (textField == self.codeTextFieldTwo) {
//        [self.codeTextFieldThree becomeFirstResponder];
//    } else if (textField == self.codeTextFieldThree) {
//        [self.codeTextFieldFour becomeFirstResponder];
//    } else if (textField == self.codeTextFieldFour) {
//        NSString *smsCode = [NSString stringWithFormat:@"%@%@%@%@",self.codeTextFieldOne.text,self.codeTextFieldTwo.text,self.codeTextFieldThree.text,self.codeTextFieldFour.text];
//        if (self.delegate && [self.delegate respondsToSelector:@selector(mobileLogin:smsCode:captcha:)]) {
//            [self.delegate mobileLogin:self.mobileNumber smsCode:smsCode captcha:nil];
//        }
//    }
//}

- (void)beginLoginWithMobile {
    NSMutableString *smsCode = [NSMutableString string];
    for (UITextField *tf in self.textFieldArray) {
        [smsCode appendString:tf.text?:@""];
    }
    if (self.isForBindMobile) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(mobileBind:smsCode:captcha:)]) {
            [self.delegate mobileBind:self.mobileNumber smsCode:smsCode captcha:nil];
        }
    } else {
        if (self.delegate && [self.delegate respondsToSelector:@selector(mobileLogin:smsCode:captcha:)]) {
            [self.delegate mobileLogin:self.mobileNumber smsCode:smsCode captcha:nil];
        }
    }
}

#pragma mark - FHVerifyCodeTextFieldDeleteDelegate
- (void)didClickBackWard {
    for (NSUInteger i = 1; i < self.textFieldArray.count; i++) {
        if (!self.textFieldArray[i].isFirstResponder) {
            continue;
        }
        [self.textFieldArray[i] resignFirstResponder];
        [self.textFieldArray[i - 1] becomeFirstResponder];
        self.textFieldArray[i - 1].text = @"";
    }
}

#pragma mark - UITextFieldDelegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if (!textField.text.length) {
        //用户输入
        if (string.length == 1) {
            NSUInteger index = [self.textFieldArray indexOfObject:textField];
            [textField resignFirstResponder];
            
            if (index == self.textFieldArray.count - 1) {
                self.textFieldArray[index].text = string;
                [self beginLoginWithMobile];
                return NO;
            }
            self.textFieldArray[index].text = string;
            [self.textFieldArray[index + 1] becomeFirstResponder];
        }
    }
        //来自键盘的快捷提示
//        if (string.length >= 4) {
//            return NO;
//            //放到外面，延迟设置
//            for (NSUInteger i = 0; i < self.textFieldArray.count; i++) {
//                NSString *number = [string substringWithRange:NSMakeRange(i, 1)];
//                UITextField *tf = self.textFieldArray[i];
//                tf.delegate = nil;
//                tf.text = number;
//                tf.delegate = self;
//                if (tf.isFirstResponder) {
//                    [tf resignFirstResponder];
//                }
//            }
//            [self.textFieldArray[self.textFieldArray.count - 1] becomeFirstResponder];
//            [self beginLoginWithMobile];
//            return NO;
//        }
    return NO;
}

@end
