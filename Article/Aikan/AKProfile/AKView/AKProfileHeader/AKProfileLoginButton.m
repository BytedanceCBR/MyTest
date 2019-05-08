//
//  AKProfileLoginButton.m
//  Article
//
//  Created by chenjiesheng on 2018/3/2.
//

#import "AKProfileLoginButton.h"
#import <UIColor+TTThemeExtension.h>
@interface AKProfileLoginButton ()

@property (nonatomic, assign)AKProfileLoginButtonType loginButtonType;
@property (nonatomic, copy, readwrite)  NSString                 *platform;

@end

@implementation AKProfileLoginButton

+ (instancetype)weiXinButtonWithTarget:(id)target buttonClicked:(void (^)(AKProfileLoginButton *))clickBlock
{
    AKProfileLoginButton *loginButton = [AKProfileLoginButton buttonWithLoginButtonType:AKProfileLoginButtonTypeDefault platform:PLATFORM_WEIXIN];
    [loginButton setImage:[[UIImage imageNamed:@"profile_unlogin_weixin_icon"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    loginButton.imageView.tintColor = [UIColor whiteColor];
    loginButton.imageView.size = CGSizeMake([TTDeviceUIUtils tt_newPadding:24], [TTDeviceUIUtils tt_newPadding:20]);
    [loginButton setBackgroundColor:[UIColor colorWithHexString:@"6CC22A"]];
    [loginButton setTitle:@"微信一键登录" forState:UIControlStateNormal];
    __weak AKProfileLoginButton *weakButton = loginButton;
    [loginButton addTarget:target withActionBlock:^{
        if (clickBlock) {
            clickBlock(weakButton);
        }
    } forControlEvent:UIControlEventTouchUpInside];
    loginButton.frame = CGRectMake(0, 0, [TTDeviceUIUtils tt_newPadding:283], [TTDeviceUIUtils tt_newPadding:42]);
    return loginButton;
}

+ (instancetype)buttonWithLoginButtonType:(AKProfileLoginButtonType)buttonType platform:(NSString *)platform
{
    AKProfileLoginButton *button = [AKProfileLoginButton buttonWithType:UIButtonTypeCustom];
    button.loginButtonType = buttonType;
    button.platform = platform;
    return button;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    switch (self.loginButtonType) {
        case AKProfileLoginButtonTypeDefault:
        {
            self.layer.cornerRadius = self.frame.size.height / 2;
            self.clipsToBounds = YES;
        }
            break;
        default:
            break;
    }
}

- (void)setLoginButtonType:(AKProfileLoginButtonType)loginButtonType
{
    _loginButtonType = loginButtonType;
    switch (_loginButtonType) {
        case AKProfileLoginButtonTypeDefault:
        {
            self.layer.cornerRadius = self.frame.size.height / 2;
            self.clipsToBounds = YES;
            self.titleLabel.textColor = [UIColor whiteColor];
            self.titleLabel.font = [UIFont systemFontOfSize:[TTDeviceUIUtils tt_newPadding:16]];
            self.imageEdgeInsets = UIEdgeInsetsMake(0, -6, 0, 0);
            self.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 0, -6);
        }
            break;
        case AKProfileLoginButtonTypeSimply:
        {
            self.clipsToBounds = NO;
            [self setBackgroundColor:nil];
            [self setImage:nil forState:UIControlStateNormal];
            self.imageEdgeInsets = UIEdgeInsetsZero;
            self.titleEdgeInsets = UIEdgeInsetsZero;
            [self setTitleColor:[UIColor colorWithHexString:@"777777"] forState:UIControlStateNormal];
            self.titleLabel.font = [UIFont systemFontOfSize:[TTDeviceUIUtils tt_newPadding:12]];
        }
            break;
        default:
            break;
    }
}
@end
