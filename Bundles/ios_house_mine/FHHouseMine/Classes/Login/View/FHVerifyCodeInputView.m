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

@interface FHVerifyCodeInputView ()<UITextFieldDelegate>

@property (nonatomic, strong) UILabel *mobileNumberLabel;

@property (nonatomic, strong) UITextField *codeTextFieldOne;
@property (nonatomic, strong) UITextField *codeTextFieldTwo;
@property (nonatomic, strong) UITextField *codeTextFieldThree;
@property (nonatomic, strong) UITextField *codeTextFieldFour;

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
        [self addSubview:changeNumberButton];
        [changeNumberButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.mobileNumberLabel.mas_right).mas_offset(6);
            make.centerY.mas_equalTo(self.mobileNumberLabel.mas_centerY);
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
        [self.sendVerifyCodeButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(self);
            make.height.mas_equalTo(46);
        }];
        
        UIStackView *stackView = [[UIStackView alloc] init];
        stackView.distribution = UIStackViewDistributionEqualSpacing;
        stackView.alignment = UIStackViewAlignmentCenter;
        stackView.axis = UILayoutConstraintAxisHorizontal;
        [self addSubview:stackView];

        CGFloat stackViewWidth = CGRectGetWidth(self.frame) - 30 * 2;

        self.codeTextFieldOne = [[UITextField alloc] init];
        [stackView addArrangedSubview:[self setupTextField:self.codeTextFieldOne]];

        self.codeTextFieldTwo = [[UITextField alloc] init];
        [stackView addArrangedSubview:[self setupTextField:self.codeTextFieldTwo]];

        self.codeTextFieldThree = [[UITextField alloc] init];
        [stackView addArrangedSubview:[self setupTextField:self.codeTextFieldThree]];

        self.codeTextFieldFour = [[UITextField alloc] init];
        [stackView addArrangedSubview:[self setupTextField:self.codeTextFieldFour]];

        [stackView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(stackViewWidth);
            make.height.mas_equalTo(62);
            make.centerX.mas_equalTo(self);
            make.top.mas_equalTo(self.mobileNumberLabel.mas_bottom).mas_offset(40);
        }];
        
    }
    return self;
}

- (UIView *)setupTextField:(UITextField *)textField{
    
    CGFloat stackViewWidth = CGRectGetWidth(self.frame) - 30 * 2;
    CGFloat itemMargin = 25;
    CGFloat itemWidth = floor((stackViewWidth - itemMargin) / 4.0);
    CGFloat itemHeight = 62;
    
    UIView *itemView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, itemWidth, itemHeight)];
    [itemView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(itemWidth, itemHeight));
    }];
    
    textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    textField.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    textField.font = [UIFont themeFontRegular:24];
    textField.textColor = [UIColor themeGray1];
    textField.keyboardType = UIKeyboardTypePhonePad;
    textField.returnKeyType = UIReturnKeyDone;
    [textField addTarget:self action:@selector(textFiledDidChange:) forControlEvents:UIControlEventEditingChanged];
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
    
}

- (void)sendVerifyCodeAction {
    
}

- (void)updateMobileNumber:(NSString *)mobileNumber {
    self.mobileNumber = mobileNumber;
    NSString *formattedMobile;
    if (self.mobileNumber.length > 11) {
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

- (void)textFiledDidChange:(UITextField *)textField {
    // 这个地方再考虑一下，可以使用一个 string 来保存 smsCode 的更改，来判断 应该哪个 textField 弹键盘
    if (textField == self.codeTextFieldOne) {
        if (self.codeTextFieldOne.text.length == 1) {
            [self.codeTextFieldTwo becomeFirstResponder];
        }
    } else if (textField == self.codeTextFieldTwo) {
        [self.codeTextFieldThree becomeFirstResponder];
    } else if (textField == self.codeTextFieldThree) {
        [self.codeTextFieldFour becomeFirstResponder];
    } else if (textField == self.codeTextFieldFour) {
        NSString *smsCode = [NSString stringWithFormat:@"%@%@%@%@",self.codeTextFieldOne.text,self.codeTextFieldTwo.text,self.codeTextFieldThree.text,self.codeTextFieldFour.text];
        if (self.delegate && [self.delegate respondsToSelector:@selector(mobileLogin:smsCode:captcha:)]) {
            [self.delegate mobileLogin:self.mobileNumber smsCode:smsCode captcha:nil];
        }
    }
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    if (textField == self.codeTextFieldOne) {
        [self.codeTextFieldTwo becomeFirstResponder];
    } else if (textField == self.codeTextFieldTwo) {
        [self.codeTextFieldThree becomeFirstResponder];
    } else if (textField == self.codeTextFieldThree) {
        [self.codeTextFieldFour becomeFirstResponder];
    }
    return YES;
}

@end
