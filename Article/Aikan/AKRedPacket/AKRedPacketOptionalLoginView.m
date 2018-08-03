//
//  AKRedPacketOptionalLoginView.m
//  Article
//
//  Created by chenjiesheng on 2018/3/13.
//

#import "AKUILayout.h"
#import "AKRedPacketOptionalLoginView.h"

#import <TTAlphaThemedButton.h>
#import <TTAccountManagerDefine.h>
#import <UIColor+TTThemeExtension.h>

@interface AKRedPacketLoginButton : TTAlphaThemedButton

@property (nonatomic, copy)NSString         *platform;

+ (instancetype)buttonWithPlatform:(NSString *)platform;
@end

@implementation AKRedPacketLoginButton

- (instancetype)initWithPlatform:(NSString *)platform
{
    self = [super init];
    if (self) {
        self.platform = platform;
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    if ([self.platform isEqualToString:PLATFORM_PHONE]) {
        [self setImageName:@"ak_redpacket_login_phone"];
    } else if ([self.platform isEqualToString:PLATFORM_QZONE]) {
        [self setImageName:@"ak_redpacket_login_qq"];
    }
}

+ (instancetype)buttonWithPlatform:(NSString *)platform
{
    AKRedPacketLoginButton *btn = [[AKRedPacketLoginButton alloc] initWithPlatform:platform];
    return btn;
}

@end

@interface AKRedPacketOptionalLoginView ()

@property (nonatomic, strong, readwrite)TTAlphaThemedButton                    *arrowButton;
@property (nonatomic, strong)           UIView                                 *arrowBackLineView;
@property (nonatomic, strong)           UIView                                 *arrowContainerView;
@property (nonatomic, strong, readwrite)UILabel                                *desLabel;
@property (nonatomic, strong)           UIView                                 *topRegion;

@property (nonatomic, copy, readwrite)  NSArray<TTAlphaThemedButton *>         *loginButtons;
@property (nonatomic, copy, readwrite)  NSArray<NSString *>                    *supportPlatforms;
@property (nonatomic, strong)           UIView                                 *loginButtonsView;
@property (nonatomic, assign)           BOOL                                    loginButtonIsHidden;
@end


@implementation AKRedPacketOptionalLoginView

- (instancetype)initWithSupportPlatforms:(NSArray<NSString *> *)platfoms delegate:(NSObject<AKRedPacketOptionalLoginViewDelegate> *)delegate
{
    self = [super init];
    if (self) {
        self.supportPlatforms = platfoms;
        self.delegate = delegate;
        [self createComponent];
    }
    return self;
}

- (void)createLoginButtons {
    NSMutableArray *btns = [NSMutableArray arrayWithCapacity:self.supportPlatforms.count];
    [self.supportPlatforms enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        AKRedPacketLoginButton *button = [AKRedPacketLoginButton buttonWithPlatform:obj];
        [button addTarget:self action:@selector(loginButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [btns addObject:button];
    }];
    self.loginButtons = btns;
    UIView *btnView = [AKUILayout horizontalLayoutViewWith:btns
                                                   padding:85
                                                  viewSize:[NSValue valueWithCGSize:CGSizeMake(40, 40)]];
    self.loginButtonsView = btnView;
    [self addSubview:btnView];
}

- (void)createArrowButton
{
    _arrowBackLineView = ({
        UIView *lineView = [[UIView alloc] init];
        lineView.backgroundColor = [UIColor colorWithHexString:@"ECECEC"];
        lineView.height = 0.5;
        lineView.width = [TTDeviceUIUtils tt_newPadding:275];
        lineView;
    });
    _arrowContainerView = ({
        UIView *view = [[UIView alloc] init];
        view.backgroundColor = [UIColor clearColor];
        view;
    });
    _arrowButton = ({
        TTAlphaThemedButton *btn = [TTAlphaThemedButton buttonWithType:UIButtonTypeCustom];
        [btn setImageName:@"ak_readpacket_login_arrow"];
        [btn sizeToFit];
        [btn addTarget:self action:@selector(arrowButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        btn;
    });
    _arrowContainerView.width = _arrowBackLineView.width;
    _arrowContainerView.height = _arrowButton.height;
    [_arrowContainerView addSubview:_arrowBackLineView];
    [_arrowContainerView addSubview:_arrowButton];
    self.arrowBackLineView.center = CGPointMake(self.arrowContainerView.width / 2, self.arrowContainerView.height / 2 );
    self.arrowButton.center = self.arrowBackLineView.center;
    
    _desLabel = ({
        UILabel *label = [[UILabel alloc] init];
        label.textColor = [UIColor colorWithHexString:@"707070"];
        label.font = [UIFont systemFontOfSize:[TTDeviceUIUtils tt_newFontSize:12.f]];
        label.text = @"其它登录方式";
        [label sizeToFit];
        label;
    });
    self.topRegion = [AKUILayout verticalLayoutViewWith:@[self.arrowContainerView,self.desLabel] padding:[TTDeviceUIUtils tt_newPadding:12.f] viewSize:nil];
    [self addSubview:self.topRegion];
}

- (void)createComponent
{
    [self createArrowButton];
    [self createLoginButtons];
    
    CGSize size = [AKUILayout sizeWithVerticalLayoutViewWith:@[self.topRegion,self.loginButtonsView] padding:[TTDeviceUIUtils tt_newPadding:30] viewSize:nil];
    self.size = size;
}

- (void)hiddenLoginButton
{
    if (self.loginButtonIsHidden) {
        return;
    }
    self.loginButtonIsHidden = YES;
    
    self.arrowButton.transform = CGAffineTransformIdentity;
    [UIView animateWithDuration:.25 animations:^{
        self.loginButtonsView.alpha = 0;
        self.topRegion.bottom = self.height;
    }];
}

- (void)showLoginButon
{
    if (!self.loginButtonIsHidden) {
        return;
    }
    self.loginButtonIsHidden = NO;
    self.arrowButton.transform = CGAffineTransformMakeRotation(M_PI);
    [UIView animateWithDuration:.25 animations:^{
        self.loginButtonsView.alpha = 1;
        self.topRegion.top = 0;
    }];
}

#pragma private

- (void)arrowButtonClicked:(UIButton *)button
{
    if (self.loginButtonIsHidden) {
        [self showLoginButon];
    } else {
        [self hiddenLoginButton];
    }
    if ([self.delegate respondsToSelector:@selector(arrowButtonClicked:)]) {
        [self.delegate arrowButtonClicked:button];
    }
}

- (void)loginButtonClicked:(AKRedPacketLoginButton *)button
{
    if ([self.delegate respondsToSelector:@selector(loginButtonClicked:withPlatform:)]) {
        [self.delegate loginButtonClicked:button withPlatform:button.platform];
    }
}
@end
