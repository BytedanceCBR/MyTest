//
//  FHOneKeyBindingView.m
//  Pods
//
//  Created by bytedance on 2020/4/21.
//

#import "FHOneKeyBindingView.h"
#import "FHLoginDefine.h"
#import <Masonry/Masonry.h>
#import <FHCommonUI/UIColor+Theme.h>
#import <FHCommonUI/UIFont+House.h>
#import "YYLabel.h"
#import "NSAttributedString+YYText.h"
#import <ByteDanceKit/ByteDanceKit.h>

@interface FHOneKeyBindingView ()

@property (nonatomic, strong) UILabel *phoneNumberLabel;
@property (nonatomic, strong) UILabel *serviceLabel;
@property(nonatomic, strong) YYLabel *agreementLabel;

@end

@implementation FHOneKeyBindingView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        UILabel *titleLabel = [[UILabel alloc] init];
        titleLabel.font = [UIFont themeFontMedium:30];
        titleLabel.textColor = [UIColor themeGray1];
        titleLabel.text = @"未绑定手机号";
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
        
        self.phoneNumberLabel = [[UILabel alloc] init];
        self.phoneNumberLabel.font = [UIFont themeFontMedium:30];
        self.phoneNumberLabel.textColor = [UIColor themeGray1];
        [self addSubview:self.phoneNumberLabel];
        [self.phoneNumberLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(30);
            make.top.mas_equalTo(subTitleLabel.mas_bottom).mas_offset(40);
            make.height.mas_equalTo(61);
        }];
        
        self.serviceLabel = [[UILabel alloc] init];
        self.serviceLabel.font = [UIFont themeFontRegular:12];
        self.serviceLabel.textColor = [UIColor themeGray3];
        [self addSubview:self.serviceLabel];
        [self.serviceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(self.phoneNumberLabel.mas_centerY);
            make.right.mas_equalTo(-30);
        }];
        
        UIView *lineView = [[UIView alloc] init];
        lineView.backgroundColor = [UIColor themeGray6];
        [self addSubview:lineView];
        [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(30);
            make.right.mas_equalTo(-30);
            make.height.mas_equalTo(1.0/UIScreen.mainScreen.scale);
            make.top.mas_equalTo(self.phoneNumberLabel.mas_bottom);
        }];
        
        UIButton *confirmButton = [UIButton buttonWithType:UIButtonTypeCustom] ;
        confirmButton.backgroundColor = [UIColor themeOrange4];
        confirmButton.layer.cornerRadius = 23; //4;
        [confirmButton addTarget:self action:@selector(confirmButtonAction) forControlEvents:UIControlEventTouchUpInside];
        confirmButton.titleLabel.font = [UIFont themeFontRegular:16];
        [confirmButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [confirmButton setTitle:@"一键绑定" forState:UIControlStateNormal];
        [self addSubview:confirmButton];
        [confirmButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(lineView.mas_bottom).offset(40);
            make.left.mas_equalTo(57);
            make.right.mas_equalTo(-57);
            make.height.mas_equalTo(46);
        }];
        
        UIButton *otherLoginButton = [UIButton buttonWithType:UIButtonTypeCustom] ;
        otherLoginButton.layer.borderColor = [UIColor themeGray6].CGColor;
        otherLoginButton.layer.cornerRadius = 23; //4;
        otherLoginButton.layer.borderWidth = 1.0/UIScreen.mainScreen.scale;
        [otherLoginButton addTarget:self action:@selector(bindOtherMobileButtonAction) forControlEvents:UIControlEventTouchUpInside];
        otherLoginButton.titleLabel.font = [UIFont themeFontRegular:16];
        [otherLoginButton setTitleColor:[UIColor themeGray2] forState:UIControlStateNormal];
        [otherLoginButton setTitle:@"绑定其他手机号" forState:UIControlStateNormal];
        [self addSubview:otherLoginButton];
        [otherLoginButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(confirmButton.mas_bottom).offset(20);
            make.left.mas_equalTo(57);
            make.right.mas_equalTo(-57);
            make.height.mas_equalTo(46);
        }];
        
        self.agreementLabel = [[YYLabel alloc] init];
        self.agreementLabel.numberOfLines = 0;
        self.agreementLabel.lineBreakMode = NSLineBreakByWordWrapping;
        self.agreementLabel.textAlignment = NSTextAlignmentCenter;
        self.agreementLabel.textColor = [UIColor themeGray3];
        self.agreementLabel.font = [UIFont themeFontRegular:13];
        [self addSubview:_agreementLabel];
        [self.agreementLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(-20);
            make.left.mas_equalTo(30);
            make.right.mas_equalTo(-30);
            make.height.mas_equalTo(0);
        }];
    }
    return self;
}

#pragma mark - Action
- (void)confirmButtonAction {
    if (self.delegate && [self.delegate respondsToSelector:@selector(oneKeyBindAction)]) {
        [self.delegate oneKeyBindAction];
    }
}

- (void)bindOtherMobileButtonAction {
    if (self.delegate && [self.delegate respondsToSelector:@selector(goToMobileBind)]) {
        [self.delegate goToMobileBind];
    }
}

- (void)updateOneKeyLoginWithPhone:(NSString *)phoneNum service:(NSString *)service protocol:(NSAttributedString *)protocol{
    self.phoneNumberLabel.text = phoneNum;
    self.serviceLabel.text = service;
    
    self.agreementLabel.attributedText = protocol;
    CGFloat height = [protocol.string btd_heightWithFont:protocol.yy_font width:CGRectGetWidth(UIScreen.mainScreen.bounds) - 60];
    [self.agreementLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(height);
    }];
}


@end
