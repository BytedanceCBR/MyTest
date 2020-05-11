//
//  FHDouYinLoginView.m
//  Pods
//
//  Created by bytedance on 2020/4/14.
//

#import "FHDouYinLoginView.h"
#import "FHLoginDefine.h"
#import <Masonry/Masonry.h>
#import <FHCommonUI/UIColor+Theme.h>
#import <FHCommonUI/UIFont+House.h>
#import "YYLabel.h"
#import "NSAttributedString+YYText.h"
#import <ByteDanceKit/ByteDanceKit.h>

@interface FHDouYinLoginView ()

@property (nonatomic, strong) UIButton *douyinLoginButton;
@property (nonatomic, strong) UIButton *otherLoginButton;
@property(nonatomic, strong) YYLabel *agreementLabel;

@end

@implementation FHDouYinLoginView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
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
        
        self.douyinLoginButton = [UIButton buttonWithType:UIButtonTypeCustom] ;
        self.douyinLoginButton.backgroundColor = [UIColor themeOrange4];
//        self.douyinLoginButton.alpha = 0.6;
        self.douyinLoginButton.layer.cornerRadius = 23; //4;
        [self.douyinLoginButton addTarget:self action:@selector(douyinLoginButtonAction) forControlEvents:UIControlEventTouchUpInside];
        self.douyinLoginButton.titleLabel.font = [UIFont themeFontRegular:16];
        [self.douyinLoginButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.douyinLoginButton setTitle:@"抖音一键登录" forState:UIControlStateNormal];
        [self addSubview:self.douyinLoginButton];
        [self.douyinLoginButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(self).offset(-(10+23+12));
            make.left.mas_equalTo(57);
            make.right.mas_equalTo(-57);
            make.height.mas_equalTo(46);
        }];
        
        self.otherLoginButton = [UIButton buttonWithType:UIButtonTypeCustom] ;
        self.otherLoginButton.layer.borderColor = [UIColor themeGray6].CGColor;
        self.otherLoginButton.layer.cornerRadius = 23; //4;
        self.otherLoginButton.layer.borderWidth = 1.0/UIScreen.mainScreen.scale;
        [self.otherLoginButton addTarget:self action:@selector(otherLoginButtonAction) forControlEvents:UIControlEventTouchUpInside];
        self.otherLoginButton.titleLabel.font = [UIFont themeFontRegular:16];
        [self.otherLoginButton setTitleColor:[UIColor themeGray2] forState:UIControlStateNormal];
        [self.otherLoginButton setTitle:@"其他方式登录" forState:UIControlStateNormal];
        [self addSubview:self.otherLoginButton];
        [self.otherLoginButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.douyinLoginButton.mas_bottom).offset(20);
            make.left.mas_equalTo(57);
            make.right.mas_equalTo(-57);
            make.height.mas_equalTo(46);
        }];
        
        UIImageView *logoImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"login_logo_onekey"]];
        [self addSubview:logoImageView];
        [logoImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(self);
            make.bottom.mas_equalTo(self.douyinLoginButton.mas_top).mas_offset(-60);
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

- (void)updateProtocol:(NSAttributedString *)protocol{
    
    self.agreementLabel.attributedText = protocol;
    [self.agreementLabel sizeToFit];
    CGFloat height = [protocol.string btd_heightWithFont:protocol.yy_font width:CGRectGetWidth(UIScreen.mainScreen.bounds) - 60];
    [self.agreementLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(height);
    }];
}

- (void)douyinLoginButtonAction {
    if (self.delegate && [self.delegate respondsToSelector:@selector(douyinLoginActionByIcon:)]) {
        [self.delegate douyinLoginActionByIcon:NO];
    }
}

- (void)otherLoginButtonAction {
    if (self.delegate && [self.delegate respondsToSelector:@selector(goToOneKeyLogin)]) {
        [self.delegate goToOneKeyLogin];
    }
}

@end
