//
//  FHOneKeyLoginView.m
//  Pods
//
//  Created by bytedance on 2020/4/14.
//

#import "FHOneKeyLoginView.h"
#import "FHLoginDefine.h"
#import <Masonry/Masonry.h>
#import <FHCommonUI/UIColor+Theme.h>
#import <FHCommonUI/UIFont+House.h>
#import "YYLabel.h"
#import "NSAttributedString+YYText.h"
#import <ByteDanceKit/ByteDanceKit.h>

@interface FHOneKeyLoginView ()

@property (nonatomic, strong) UILabel *serviceLabel;
@property (nonatomic, strong) UILabel *phoneNumberLabel;
@property (nonatomic, strong) UIButton *confirmButton;
@property(nonatomic, strong) YYLabel *agreementLabel;

@end

@implementation FHOneKeyLoginView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        UIImageView *logoImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"login_logo_onekey"]];
        [self addSubview:logoImageView];
        [logoImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(self);
            make.top.mas_equalTo(60);
        }];
        
        self.serviceLabel = [[UILabel alloc] init];
        self.serviceLabel.font = [UIFont themeFontRegular:14];
        self.serviceLabel.textColor = [UIColor themeGray3];
        [self addSubview:self.serviceLabel];
        [self.serviceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(logoImageView.mas_bottom).mas_offset(105);
            make.centerX.mas_equalTo(self);
        }];
        
        self.phoneNumberLabel = [[UILabel alloc] init];
        self.phoneNumberLabel.font = [UIFont themeFontSemibold:30];
        self.phoneNumberLabel.textColor = [UIColor themeGray1];
        [self addSubview:self.phoneNumberLabel];
        [self.phoneNumberLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(self);
            make.top.mas_equalTo(self.serviceLabel.mas_bottom).mas_offset(4);
        }];
        
        self.confirmButton = [UIButton buttonWithType:UIButtonTypeCustom] ;
        self.confirmButton.backgroundColor = [UIColor themeOrange4];
        self.confirmButton.alpha = 0.6;
        self.confirmButton.layer.cornerRadius = 23; //4;
        [self.confirmButton addTarget:self action:@selector(confirmButtonAction) forControlEvents:UIControlEventTouchUpInside];
        self.confirmButton.titleLabel.font = [UIFont themeFontRegular:16];
        [self.confirmButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.confirmButton setTitle:@"一键登录" forState:UIControlStateNormal];
        [self addSubview:self.confirmButton];
        [self.confirmButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.phoneNumberLabel.mas_bottom).offset(30);
            make.left.mas_equalTo(57);
            make.right.mas_equalTo(-57);
            make.height.mas_equalTo(46);
        }];
        
        self.agreementLabel = [[YYLabel alloc] init];
        _agreementLabel.numberOfLines = 0;
        _agreementLabel.lineBreakMode = NSLineBreakByWordWrapping;
        _agreementLabel.textColor = [UIColor themeGray3];
        _agreementLabel.font = [UIFont themeFontRegular:13];
        [self addSubview:_agreementLabel];
        [self.agreementLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(-20);
            make.left.mas_equalTo(30);
            make.right.mas_equalTo(-30);
            make.height.mas_equalTo(0);
        }];
        
        UIStackView *stackView = [[UIStackView alloc] init];
        stackView.distribution = UIStackViewDistributionEqualSpacing;
        stackView.alignment = UIStackViewAlignmentCenter;
        stackView.axis = UILayoutConstraintAxisHorizontal;
        [self addSubview:stackView];
        
        CGFloat stackViewWidth = 0;
        
        UIButton *codeLoginButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [codeLoginButton setImage:[UIImage imageNamed:@"login_mobile_icon"] forState:UIControlStateNormal];
        [codeLoginButton addTarget:self action:@selector(codeLoginAction) forControlEvents:UIControlEventTouchUpInside];
        [codeLoginButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(38, 38));
        }];
        [stackView addArrangedSubview:codeLoginButton];
        stackViewWidth += 38;
        
        UIButton *douyinLoginButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [douyinLoginButton setImage:[UIImage imageNamed:@"douyin_login_common_icon"] forState:UIControlStateNormal];
        [douyinLoginButton addTarget:self action:@selector(douyinLoginAction) forControlEvents:UIControlEventTouchUpInside];
        [douyinLoginButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(38, 38));
        }];
        [stackView addArrangedSubview:douyinLoginButton];
        stackViewWidth += (38+20);
        
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
            make.centerX.mas_equalTo(self);
            make.bottom.mas_equalTo(self.agreementLabel.mas_top).mas_offset(-20);
        }];
    }
    return self;
}

- (void)updateOneKeyLoginWithPhone:(NSString *)phoneNum service:(NSString *)service protocol:(NSAttributedString *)protocol{
    self.phoneNumberLabel.text = phoneNum;
    self.serviceLabel.text = service;
    
    self.agreementLabel.attributedText = protocol;
    CGFloat height = [protocol.string btd_heightWithFont:protocol.yy_font width:CGRectGetWidth(UIScreen.mainScreen.bounds) - 60];
    [self.agreementLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(height);
    }];
    [self enableConfirmBtn:phoneNum.length > 0];
}

- (void)enableConfirmBtn:(BOOL)enabled {
    if (enabled) {
        self.confirmButton.alpha = 1;
    } else {
        self.confirmButton.alpha = 0.6;
    }
}

- (void)confirmButtonAction{
    if (self.delegate && [self.delegate respondsToSelector:@selector(oneKeyLoginAction)]) {
        [self.delegate oneKeyLoginAction];
    }
}

- (void)codeLoginAction {
    if (self.delegate && [self.delegate respondsToSelector:@selector(goToMobileLogin)]) {
        [self.delegate goToMobileLogin];
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

@end
