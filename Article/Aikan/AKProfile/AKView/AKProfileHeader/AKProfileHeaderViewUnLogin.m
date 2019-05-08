//
//  AKProfileHeaderViewUnLogin.m
//  Article
//
//  Created by chenjiesheng on 2018/3/2.
//

#import "AKProfileLoginButton.h"
#import "AKProfileHeaderViewUnLogin.h"
#import <UIColor+TTThemeExtension.h>

#define kPaddingProfileHeaderViewTopButtonsRegion            [TTDeviceUIUtils tt_newPadding:16.f]

@interface AKProfileHeaderViewUnLogin ()
@property (nonatomic, strong)UIView             *topRegion;
@property (nonatomic, strong)UIView             *buttonsRegion;
@property (nonatomic, strong)UILabel            *topTitleLabel;
@property (nonatomic, copy)  NSArray<AKProfileLoginButton *>    *loginButtons;
@end

@implementation AKProfileHeaderViewUnLogin

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self createComponent];
    }
    return self;
}

- (CGSize)sizeThatFits:(CGSize)size
{
    CGFloat bottomPadding = 15.f;
    return CGSizeMake(self.width > 0 ? self.width : [TTUIResponderHelper mainWindow].width, self.topRegion.height + self.buttonsRegion.height + kPaddingProfileHeaderViewTopButtonsRegion + bottomPadding);
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    CGFloat topInset = 20;
    if ([TTDeviceHelper isIPhoneXDevice]) {
        topInset = 44.f;
    }
    self.topRegion.origin = CGPointZero;
    self.topTitleLabel.centerX = self.topRegion.width / 2;
    self.topTitleLabel.top = topInset + 40;
    
    self.buttonsRegion.top = self.topRegion.bottom + kPaddingProfileHeaderViewTopButtonsRegion;
    __block CGFloat buttonTop = 0;
    [self.loginButtons enumerateObjectsUsingBlock:^(AKProfileLoginButton * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.centerX = self.buttonsRegion.width / 2;
        obj.top = buttonTop;
        buttonTop = obj.bottom + 12;
    }];
}

- (void)createComponent
{
    [self createTopRegion];
    [self createButtonsRegion];
}

- (void)createTopRegion
{
    UIView *containerView = [[UIView alloc] initWithFrame:self.bounds];
    containerView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    containerView.backgroundColor = [UIColor clearColor];
    [self addSubview:containerView];
    self.topRegion = containerView;
    
    UILabel *topTitleLabel = [[UILabel alloc] init];
    topTitleLabel.textColor = [UIColor colorWithHexString:@"444444"];
    topTitleLabel.font = [UIFont boldSystemFontOfSize:[TTDeviceUIUtils tt_newFontSize:16.f]];
    topTitleLabel.text = @"“登录后推荐更精准”";
    [topTitleLabel sizeToFit];
    [containerView addSubview:topTitleLabel];
    self.topTitleLabel = topTitleLabel;
    CGFloat containerViewHeight = 40.f + topTitleLabel.height + 20;
    if ([TTDeviceHelper isIPhoneXDevice]) {
        containerViewHeight += 24.f;
    }
    containerView.frame = CGRectMake(0, 0, self.width, containerViewHeight);
}

- (void)createButtonsRegion
{
    UIView *containerView = [[UIView alloc] initWithFrame:self.bounds];
    containerView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self addSubview:containerView];
    self.buttonsRegion = containerView;
    NSMutableArray *loginButtons = [NSMutableArray array];
    CGFloat containerViewHeight = 0;
    for (NSString *platform in [self supportLoginPlatform]) {
        if ([self checkSupportPlatform:platform]) {
            AKProfileLoginButton *button = [self createLoginButtonWith:platform];
            if (button) {
                [containerView addSubview:button];
                [loginButtons addObject:button];
                if (containerViewHeight > 0) {
                    containerViewHeight += 12;
                }
                containerViewHeight += button.height;
            }
        }
    }
    containerView.frame = CGRectMake(0, 0, self.width, containerViewHeight);
    self.loginButtons = loginButtons;
}

- (NSArray<NSString *> *)supportLoginPlatform
{
    return @[PLATFORM_WEIXIN,PLATFORM_MORE];
}

- (BOOL)checkSupportPlatform:(NSString *)platform
{
    if (isEmptyString(platform)) {
        return NO;
    }
    NSArray *supportPlatform = [self supportLoginPlatform];
    if ([platform isEqualToString:PLATFORM_WEIXIN] && ![TTAccountAuthWeChat isAppAvailable]) {
        return NO;
    }
    NSInteger index = [supportPlatform indexOfObject:platform];
    return index != NSNotFound;
}

- (AKProfileLoginButton *)createLoginButtonWith:(NSString *)platform
{
    if ([platform isEqualToString:PLATFORM_WEIXIN]) {
        return [self createLoginButtonWeiXin];
    }
    if ([platform isEqualToString:PLATFORM_MORE]) {
        return [self createLoginButtonMore];
    }
    return nil;
}

- (AKProfileLoginButton *)createLoginButtonWeiXin
{
    WeakSelf;
    AKProfileLoginButton *loginButton = [AKProfileLoginButton weiXinButtonWithTarget:self
                                                                       buttonClicked:^(AKProfileLoginButton *btn) {
        StrongSelf;
        if ([self.delegate respondsToSelector:@selector(loginButtonClicked:)]) {
            [self.delegate loginButtonClicked:btn.platform];
        }
    }];
    return loginButton;
}

- (AKProfileLoginButton *)createLoginButtonMore
{
    AKProfileLoginButton *loginButton = [AKProfileLoginButton buttonWithLoginButtonType:AKProfileLoginButtonTypeSimply platform:PLATFORM_MORE];
    [loginButton setTitle:@"其它登录方式" forState:UIControlStateNormal];
    [loginButton addTarget:self action:@selector(loginButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [loginButton sizeToFit];
    return loginButton;
}

#pragma action

- (void)loginButtonClicked:(AKProfileLoginButton *)button
{
    if ([self.delegate respondsToSelector:@selector(loginButtonClicked:)]) {
        [self.delegate loginButtonClicked:button.platform];
    }
}
@end
