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
@property (nonatomic, strong) YYLabel *agreementLabel;
@property (nonatomic, strong) UIStackView *stackView;
@property (nonatomic, assign) BOOL isHalfLogin;
@end

@implementation FHOneKeyLoginView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [self initWithFrame:frame isHalfLogin:NO]) {
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame isHalfLogin:(BOOL)isHalfLogin {
    if(self = [super initWithFrame:frame]) {
        self.isHalfLogin = isHalfLogin;
        
        UIImageView *topImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"douyin_login_bg_top"]];
        [self addSubview:topImageView];
        [topImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.and.right.mas_equalTo(0);
        }];
        
        UIImageView *bottomImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"douyin_login_bg_bottom"]];
        [self addSubview:bottomImageView];
        [bottomImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.and.bottom.mas_equalTo(0);
        }];
        
        UIImageView *logoImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"login_logo_onekey"]];
        [self addSubview:logoImageView];
        [logoImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(self);
            make.top.mas_equalTo(self.isHalfLogin ? 80 : 94);
            if(self.isHalfLogin) {
                make.height.mas_equalTo(47);
            }
        }];
        
        self.phoneNumberLabel = [[UILabel alloc] init];
        self.phoneNumberLabel.font = [UIFont themeFontSemibold:30];
        self.phoneNumberLabel.textColor = [UIColor themeGray1];
        [self addSubview:self.phoneNumberLabel];
        [self.phoneNumberLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(self);
            make.top.mas_equalTo(logoImageView.mas_bottom).mas_offset(self.isHalfLogin ? 80 : 90);
            make.height.mas_equalTo(42);
        }];
        
        self.serviceLabel = [[UILabel alloc] init];
        self.serviceLabel.font = [UIFont themeFontRegular:12];
        self.serviceLabel.textColor = [UIColor themeGray3];
        [self addSubview:self.serviceLabel];
        [self.serviceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.phoneNumberLabel.mas_bottom).mas_offset(0);
            make.centerX.mas_equalTo(self);
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
            make.top.mas_equalTo(self.serviceLabel.mas_bottom).offset(31);
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
            make.left.mas_equalTo(20);
            make.right.mas_equalTo(-20);
            make.height.mas_equalTo(0);
        }];
    }
    return self;
}

- (void)updateOneKeyLoginWithPhone:(NSString *)phoneNum service:(NSString *)service protocol:(NSAttributedString *)protocol showDouyinIcon:(BOOL )showDouyinIcon {
    [self updateOneKeyLoginWithPhone:phoneNum service:service protocol:protocol showDouyinIcon:showDouyinIcon showCodeLoginBtn:YES];
}

- (void)updateOneKeyLoginWithPhone:(NSString *)phoneNum service:(NSString *)service protocol:(NSAttributedString *)protocol showDouyinIcon:(BOOL )showDouyinIcon showCodeLoginBtn:(BOOL)showCode {
    if (phoneNum.length >= 11) {
        self.phoneNumberLabel.text = [NSString stringWithFormat:@"%@ **** %@",[phoneNum substringWithRange:NSMakeRange(0, 3)],[phoneNum substringWithRange:NSMakeRange(7, 4)]];
    } else {
        self.phoneNumberLabel.text = phoneNum;
    }
    self.serviceLabel.text = service;
    
    self.agreementLabel.attributedText = protocol;
    CGFloat height = [protocol.string btd_heightWithFont:protocol.yy_font width:CGRectGetWidth(UIScreen.mainScreen.bounds) - 60];
    [self.agreementLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(height);
    }];
    [self enableConfirmBtn:phoneNum.length > 0];
    if (!self.stackView) {
        self.stackView = [[UIStackView alloc] init];
        self.stackView.distribution = UIStackViewDistributionEqualSpacing;
        self.stackView.alignment = UIStackViewAlignmentCenter;
        self.stackView.axis = UILayoutConstraintAxisHorizontal;
        [self addSubview:self.stackView];
        
        CGFloat stackViewWidth = 0;
        
        if(showCode) {
            UIButton *codeLoginButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [codeLoginButton setImage:[UIImage imageNamed:@"login_mobile_icon"] forState:UIControlStateNormal];
            [codeLoginButton addTarget:self action:@selector(codeLoginAction) forControlEvents:UIControlEventTouchUpInside];
            [codeLoginButton mas_makeConstraints:^(MASConstraintMaker *make) {
                make.size.mas_equalTo(CGSizeMake(38, 38));
            }];
            [self.stackView addArrangedSubview:codeLoginButton];
            stackViewWidth += 38;
        }
        
        if (showDouyinIcon) {
            
            UIButton *douyinLoginButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [douyinLoginButton setImage:[UIImage imageNamed:@"douyin_login_common_icon"] forState:UIControlStateNormal];
            [douyinLoginButton addTarget:self action:@selector(douyinLoginAction) forControlEvents:UIControlEventTouchUpInside];
            [douyinLoginButton mas_makeConstraints:^(MASConstraintMaker *make) {
                make.size.mas_equalTo(CGSizeMake(38, 38));
            }];
            [self.stackView addArrangedSubview:douyinLoginButton];
            stackViewWidth += (38+20);
            
            if (@available(iOS 13.0, *)) {
                UIButton *appleLoginButton = [UIButton buttonWithType:UIButtonTypeCustom];
                [appleLoginButton setImage:[UIImage imageNamed:@"apple_login_icon"] forState:UIControlStateNormal];
                [appleLoginButton addTarget:self action:@selector(appleLoginAction) forControlEvents:UIControlEventTouchUpInside];
                [appleLoginButton mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.size.mas_equalTo(CGSizeMake(138, 38));
                }];
                [self.stackView addArrangedSubview:appleLoginButton];
                stackViewWidth += (138+20);
            }
        }
        
        [self.stackView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(stackViewWidth);
            make.height.mas_equalTo(40);
            make.centerX.mas_equalTo(self);
            make.bottom.mas_equalTo(self.agreementLabel.mas_top).mas_offset(-20);
        }];
    }
    
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
    if (self.delegate && [self.delegate respondsToSelector:@selector(douyinLoginActionByIcon:)]) {
        [self.delegate douyinLoginActionByIcon:YES];
    }
}

- (void)appleLoginAction {
    if (self.delegate && [self.delegate respondsToSelector:@selector(appleLoginAction)]) {
        [self.delegate appleLoginAction];
    }
}

@end
