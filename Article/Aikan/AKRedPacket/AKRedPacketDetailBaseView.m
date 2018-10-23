//
//  AKRedPacketDetailBaseView.m
//  Article
//
//  Created by 冯靖君 on 2018/3/8.
//

#import "AKRedPacketDetailBaseView.h"
#import "AKRedPacketOptionalLoginView.h"

#import <TTRoute.h>
#import <TTNavigationController.h>
#import <TTDeviceHelper.h>
#import <UIViewAdditions.h>
#import <TTDeviceUIUtils.h>
#import <TTThemeManager.h>
#import <TTAccountManager.h>
#import "AKShareManager.h"
#import "AKRedPacketManager.h"
#import "AKProfileLoginButton.h"
#import "AKHelper.h"

#define kAKRedPacketNavBarHeight       44
#define kAKRedPacketContentViewWidth   [TTDeviceUIUtils tt_newPadding:240]
#define kAKRedPacketContentViewHeight  [TTDeviceUIUtils tt_newPadding:300]
#define kAKAvatarViewSize              [TTDeviceUIUtils tt_newPadding:66]
#define kRadiuoCurveLayer              [TTDeviceUIUtils tt_newPadding:38.f]

@implementation AKRedPacketDetailBaseViewModel
@end

@interface AKRedPacketDetailBaseView () <AKRedPacketOptionalLoginViewDelegate>

@property (nonatomic, strong) AKRedPacketDetailBaseViewModel *viewModel;
@property (nonatomic, assign) BOOL shouldGotRedPacket;

@end

static CGFloat kAKRedPacketStatusBarHeight() {
    if ([TTDeviceHelper isIPhoneXDevice]) {
        return 44;
    } else {
        return 20;
    }
}

@implementation AKRedPacketDetailBaseView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor whiteColor];
        self.scrollView.backgroundColor = [UIColor whiteColor];
        if (@available(iOS 11.0, *)) {
            self.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
        self.curveView.hidden = YES;
        
        [self.scrollView addSubview:self.curveView];
        [self.scrollView addSubview:self.logoImageView];
        [self.scrollView addSubview:self.contentView];
        [self.scrollView addSubview:self.curveBackView];
        [self.scrollView sendSubviewToBack:self.curveBackView];
        [self.scrollView addSubview:self.bottomLoginView];
        
        [self.contentView addSubview:self.nameLabel];
        [self.contentView addSubview:self.moneyLabel];
        [self.contentView addSubview:self.tipLabel];
        [self.contentView addSubview:self.openURLButton];
        [self.contentView addSubview:self.wechatLoginButton];
        
        self.scrollView.contentSize = CGSizeMake(self.width, kAKRedPacketContentViewHeight);
        [self addSubview:self.scrollView];
        
        [self addSubview:self.navBar];
        [self bringSubviewToFront:self.navBar];
        [self.navBar addSubview:self.navBarLeftButton];
        [self.navBar addSubview:self.navBarTitleLabel];
    }
    
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    // 顶部弧形layer的中间顶点高度
    self.logoImageView.centerY = self.width * 142.f/375.f - self.navBar.bottom;
    self.logoImageView.centerX = self.scrollView.width/2;
    self.contentView.top = self.logoImageView.bottom + [TTDeviceUIUtils tt_newPadding:24.f];
    
    // 各UI控件布局
    if (hasLoginWeChat()) {
        
        [self.nameLabel sizeToFit];
        self.nameLabel.top = 0;
        self.nameLabel.centerX = self.contentView.width/2;
        
        self.nameLabel.text = self.shouldGotRedPacket ? @"恭喜您获得" : @"您已经领取过了";
        
        [self.moneyLabel sizeToFit];

        self.moneyLabel.top = self.nameLabel.bottom + [TTDeviceUIUtils tt_newPadding:24.f];
        self.moneyLabel.centerX = self.contentView.width/2;
        
        self.tipLabel.text = self.shouldGotRedPacket ? [NSString stringWithFormat:@"已存入我的钱包，提现额度最低%ld元",self.viewModel.withdrawMinAmount/100] : @"请在我的-零钱查看红包余额";
        [self.tipLabel sizeToFit];
        self.tipLabel.top = (self.shouldGotRedPacket ? self.moneyLabel.bottom : self.nameLabel.bottom) + [TTDeviceUIUtils tt_newPadding:24.f];
        self.tipLabel.centerX = self.contentView.width/2;
        
        self.openURLButton.top = self.tipLabel.bottom + [TTDeviceUIUtils tt_newPadding:54.f];
        self.openURLButton.centerX = self.contentView.width/2;
        
        self.shareView.top = self.height - self.shareView.height - [TTDeviceUIUtils tt_newPadding:27.f];
        self.shareView.centerX = self.width/2;
        
        self.nameLabel.hidden = NO;
        self.wechatLoginButton.hidden = YES;
        self.openURLButton.hidden = NO;
        self.moneyLabel.hidden = self.shouldGotRedPacket ? NO : YES;
        self.shareView.hidden = NO;
    } else {
        self.wechatLoginButton.top = [TTDeviceUIUtils tt_newPadding:48.f];
        self.wechatLoginButton.centerX = self.contentView.width/2;
        
        self.tipLabel.text = @"登录后可通过微信提现";
        [self.tipLabel sizeToFit];
        self.tipLabel.top = self.wechatLoginButton.bottom + [TTDeviceUIUtils tt_newPadding:12.f];
        self.tipLabel.centerX = self.contentView.width/2;
        
        self.nameLabel.hidden = YES;
        self.wechatLoginButton.hidden = NO;
        self.openURLButton.hidden = YES;
        self.moneyLabel.hidden = YES;
        self.shareView.hidden = YES;
    }
    
    self.scrollView.frame = self.bounds;
    self.scrollView.contentInset = UIEdgeInsetsMake(self.navBar.height, 0, 0, 0);
    self.curveBackView.top = -self.navBar.height;
    
    CGFloat bottomInset = 30;
    if ([TTDeviceHelper isIPhoneXDevice]) {
        bottomInset = 60;
    }
    self.bottomLoginView.hidden = [TTAccount sharedAccount].isLogin;
    CGPoint position = CGPointMake(self.width / 2, self.height - bottomInset - self.bottomLoginView.height / 2);
    position = [self.scrollView convertPoint:position fromView:nil];
    self.bottomLoginView.center = position;
}

- (void)backAction:(id)sender {
    [self.viewController dismissViewControllerAnimated:YES completion:^{
        if (self.dismissBlock) {
            self.dismissBlock();
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:@"TTCloseRedPackertNotification" object:nil userInfo:nil];
    }];
}

- (void)configWithViewModel:(AKRedPacketDetailBaseViewModel *)viewModel {
    _viewModel = viewModel;
    self.navBarTitleLabel.text = @"收到的红包";
    
//    self.nameLabel.text = @"恭喜您获得";
    self.moneyLabel.attributedText = [self moneyLabelAttributedText:viewModel.amount];
    
    [self createShareViewIfCould];
}

- (void)fetchShareInfoIfNeed
{
    if (self.viewModel.shareInfo != nil) {
        return;
    }
    
    [[AKShareManager sharedManager] startFetchShareInfoWithTaskID:kAKNewbeeRedPacketShareInfoTaskID completionBlock:^(NSDictionary *shareInfo) {
        self.viewModel.shareInfo = [shareInfo copy];
        [self createShareViewIfCould];
    }];
}

- (void)createShareViewIfCould
{
    if (!self.shareView && self.viewModel.shareInfo != nil) {
        self.shareView = [[AKShareView alloc] initWithShareBlock:nil viewWidth:-1 shareInfo:self.viewModel.shareInfo disableTip:NO];
        self.shareView.tipTitle = [[NSAttributedString alloc] initWithString:@"快跟好友炫耀一下"];
        self.shareView.disablePlatform = AKShareSupportPlatformQQ;
        [self.shareView sizeToFit];
        [self addSubview:self.shareView];
        [self layoutSubviews];
    }
}

- (void)loginWithWechatThroughSSO
{
    WeakSelf;
    [TTAccount requestLoginForPlatform:TTAccountAuthTypeWeChat completion:^(BOOL success, NSError *error) {
        if (success && !error) {
            [[AKRedPacketManager sharedManager] notifyNewbeeRedPacketUserGotWithCompletion:^(BOOL shouldGot) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    wself.shouldGotRedPacket = shouldGot;
                    [self layoutSubviews];
                    [self fetchShareInfoIfNeed];
                });
            }];
        }
    }];
}

#pragma mark - setter and getter

- (SSThemedView *)navBar {
    if (!_navBar) {
        _navBar = [[SSThemedView alloc] initWithFrame:CGRectMake(0, 0, self.width, kAKRedPacketStatusBarHeight() + kAKRedPacketNavBarHeight)];
        NSString *hexString = [[TTThemeManager sharedInstance_tt] currentThemeMode] == TTThemeModeNight ? @"8A3B37" : @"EF514A";
        _navBar.backgroundColor = [UIColor colorWithHexString:hexString];
    }
    
    return _navBar;
}

- (SSThemedButton *)navBarLeftButton {
    if (!_navBarLeftButton) {
        _navBarLeftButton = [SSThemedButton buttonWithType:UIButtonTypeCustom];
        [_navBarLeftButton setTitle:@"关闭" forState:UIControlStateNormal];
        _navBarLeftButton.backgroundColor = [UIColor clearColor];
        _navBarLeftButton.titleLabel.font = [UIFont systemFontOfSize:[TTDeviceUIUtils tt_newFontSize:16]];
        _navBarLeftButton.titleColorThemeKey = kColorText12;
        [_navBarLeftButton addTarget:self action:@selector(backAction:) forControlEvents:UIControlEventTouchUpInside];
        [_navBarLeftButton sizeToFit];
        [_navBarLeftButton setHitTestEdgeInsets:UIEdgeInsetsMake(-8.f, -12.f, -8.f, -12.f)];
        _navBarLeftButton.origin = CGPointMake([TTDeviceUIUtils tt_newPadding:20], kAKRedPacketStatusBarHeight() + (kAKRedPacketNavBarHeight - _navBarLeftButton.height) / 2);
    }
    
    return _navBarLeftButton;
}

- (SSThemedLabel *)navBarTitleLabel {
    if (!_navBarTitleLabel) {
        _navBarTitleLabel = [[SSThemedLabel alloc] initWithFrame:CGRectMake((self.width - [TTDeviceUIUtils tt_newPadding:200]) / 2, kAKRedPacketStatusBarHeight(), [TTDeviceUIUtils tt_newPadding:200], kAKRedPacketNavBarHeight)];
        _navBarTitleLabel.text = @"头条红包";
        _navBarTitleLabel.textColorThemeKey = kColorText12;
        _navBarTitleLabel.textAlignment = NSTextAlignmentCenter;
        _navBarTitleLabel.font = [UIFont systemFontOfSize:[TTDeviceUIUtils tt_newFontSize:17]];
    }
    
    return _navBarTitleLabel;
}

- (UIScrollView *)scrollView {
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, self.navBar.bottom, self.width, self.height - self.navBar.height)];
        _scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _scrollView.bounces = NO;
    }
    
    return _scrollView;
}

- (CAGradientLayer *)curveLayer
{
    if (_curveLayer == nil) {
        _curveLayer = [CAGradientLayer layer];
        CGFloat curveLayerHeight = self.width * 142.f/375.f;
        _curveLayer.frame = CGRectMake(0, 0, self.width, curveLayerHeight + 70.f);
        [_curveLayer setColors:@[
                                 (id) [UIColor colorWithHexString:@"EF514A"].CGColor,
                                 (id) [UIColor colorWithHexString:@"EF514A"].CGColor
                                 ]];
        [_curveLayer setLocations:@[@(0),@(1)]];
        [_curveLayer setStartPoint:CGPointMake(.5, 0)];
        [_curveLayer setEndPoint:CGPointMake(.5, 1)];
        _curveLayer.zPosition = -1;
        CGFloat maskLayerWidth = self.width;
        CGFloat maskLayerHeight = curveLayerHeight - kRadiuoCurveLayer;
        
        UIBezierPath *strokePath = [UIBezierPath bezierPath];
        [strokePath moveToPoint:CGPointMake(maskLayerWidth, 0)];
        [strokePath addLineToPoint:CGPointMake(0, 0)];
        [strokePath addLineToPoint:CGPointMake(0, maskLayerHeight)];
        [strokePath addQuadCurveToPoint:CGPointMake(maskLayerWidth, maskLayerHeight) controlPoint:CGPointMake(maskLayerWidth / 2, curveLayerHeight + 45.f)]; // 控制点是切线焦点
        [strokePath closePath];
        CAShapeLayer *maskLayer = [CAShapeLayer layer];
        maskLayer.path = strokePath.CGPath;
        _curveLayer.mask = maskLayer;
    }
    return _curveLayer;
}

- (UIView *)curveBackView
{
    if (_curveBackView == nil) {
        _curveBackView = [[SSThemedView alloc] init];
        _curveBackView.frame = CGRectMake(0, 0, self.width, self.height);
        _curveBackView.userInteractionEnabled = NO;
        [_curveBackView.layer addSublayer:self.curveLayer];
    }
    return _curveBackView;
}

- (SSThemedView *)curveView {
    if (!_curveView) {
        _curveView = [[SSThemedView alloc] initWithFrame:CGRectMake(0, -2, self.width, [TTDeviceUIUtils tt_newPadding:84])];
        NSString *hexString = [[TTThemeManager sharedInstance_tt] currentThemeMode] == TTThemeModeNight ? @"8A3B37" : @"EF514A";
        _curveView.backgroundColor = [UIColor colorWithHexString:hexString];
        
        CGFloat maskLayerWidth = self.width;
        CGFloat maskLayerHeight = [TTDeviceUIUtils tt_newPadding:45];
        
        UIBezierPath *strokePath = [UIBezierPath bezierPath];
        [strokePath moveToPoint:CGPointMake(maskLayerWidth, 0)];
        [strokePath addLineToPoint:CGPointMake(0, 0)];
        [strokePath addLineToPoint:CGPointMake(0, maskLayerHeight)];
        [strokePath addQuadCurveToPoint:CGPointMake(maskLayerWidth, maskLayerHeight) controlPoint:CGPointMake(maskLayerWidth / 2, [TTDeviceUIUtils tt_newPadding:84] + 35)]; // 控制点是切线焦点
        [strokePath closePath];
        
        CAShapeLayer *maskLayer = [CAShapeLayer layer];
        maskLayer.path = strokePath.CGPath;
        _curveView.layer.mask = maskLayer;
    }
    
    return _curveView;
}

- (UIImageView *)logoImageView {
    if (!_logoImageView) {
        _logoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kAKAvatarViewSize, kAKAvatarViewSize)];
        _logoImageView.image = [UIImage imageNamed:@"red_detail_logo"];
        _logoImageView.layer.borderWidth = 0;
        _logoImageView.contentMode = UIViewContentModeScaleAspectFill;
        _logoImageView.layer.cornerRadius = kAKAvatarViewSize / 2;
        _logoImageView.layer.masksToBounds = YES;
        _logoImageView.userInteractionEnabled = NO;
    }
    
    return _logoImageView;
}

- (SSThemedView *)contentView {
    if (!_contentView) {
        _contentView = [[SSThemedView alloc] initWithFrame:CGRectMake((self.width - kAKRedPacketContentViewWidth) / 2, self.logoImageView.bottom + [TTDeviceUIUtils tt_newPadding:12], kAKRedPacketContentViewWidth, kAKRedPacketContentViewHeight)];
    }
    
    return _contentView;
}

- (SSThemedLabel *)nameLabel {
    if (!_nameLabel) {
        _nameLabel = [[SSThemedLabel alloc] initWithFrame:CGRectMake(0, 0, kAKRedPacketContentViewWidth, [TTDeviceUIUtils tt_newPadding:26])];
        _nameLabel.font = [UIFont systemFontOfSize:[TTDeviceUIUtils tt_newFontSize:18]];
        _nameLabel.textAlignment = NSTextAlignmentCenter;
        _nameLabel.textColor = [UIColor colorWithHexString:@"0x1a1a1a"];
    }
    
    return _nameLabel;
}

- (SSThemedLabel *)moneyLabel {
    if (!_moneyLabel) {
        _moneyLabel = [[SSThemedLabel alloc] initWithFrame:CGRectMake(0, self.nameLabel.bottom + [TTDeviceUIUtils tt_newPadding:25], kAKRedPacketContentViewWidth, [TTDeviceUIUtils tt_newPadding:57])];
        _moneyLabel.textAlignment = NSTextAlignmentCenter;
        _moneyLabel.textColor = [UIColor colorWithHexString:@"0xef5841"];
    }
    
    return _moneyLabel;
}

- (NSAttributedString *)moneyLabelAttributedText:(NSString *)money {
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:money attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:[TTDeviceUIUtils tt_newFontSize:60]]}];
    [attributedString appendAttributedString:[[NSMutableAttributedString alloc] initWithString:@" 元" attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:[TTDeviceUIUtils tt_newFontSize:14]]}]];
    
    return [attributedString copy];
}

- (UILabel *)tipLabel {
    if (!_tipLabel) {
        _tipLabel = [[SSThemedLabel alloc] init];
        _tipLabel.font = [UIFont systemFontOfSize:[TTDeviceUIUtils tt_newFontSize:12]];
        _tipLabel.textAlignment = NSTextAlignmentCenter;
        _tipLabel.textColor = [UIColor colorWithHexString:@"0x999999"];
    }
    
    return _tipLabel;
}

- (UIButton *)wechatLoginButton
{
    if (!_wechatLoginButton) {
//        _wechatLoginButton = [UIButton buttonWithType:UIButtonTypeCustom];
//        _wechatLoginButton.size = CGSizeMake(283.f, 42.f);
//        _wechatLoginButton.layer.cornerRadius = _wechatLoginButton.height/2;
//        _wechatLoginButton.backgroundColor = [UIColor colorWithHexString:@"0x6cc22a"];
//        [_wechatLoginButton setTitle:@"微信一键登录" forState:UIControlStateNormal];
//        [_wechatLoginButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//        _wechatLoginButton.titleLabel.font = [UIFont systemFontOfSize:[TTDeviceUIUtils tt_fontSize:16.f]];
//        [_wechatLoginButton addTarget:self action:@selector(loginWithWechatThroughSSO) forControlEvents:UIControlEventTouchUpInside];
        WeakSelf;
        _wechatLoginButton = [AKProfileLoginButton weiXinButtonWithTarget:self buttonClicked:^(AKProfileLoginButton *button) {
            [wself loginWithWechatThroughSSO];
        }];
    }
    return _wechatLoginButton;
}

- (UIButton *)openURLButton
{
    if (!_openURLButton) {
        _openURLButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _openURLButton.size = CGSizeMake(283.f, 44.f);
        _openURLButton.layer.cornerRadius = _openURLButton.height/2;
        _openURLButton.backgroundColor = [UIColor colorWithHexString:@"0xef514a"];
        [_openURLButton setTitle:@"赚更多的钱" forState:UIControlStateNormal];
        [_openURLButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _openURLButton.titleLabel.font = [UIFont systemFontOfSize:[TTDeviceUIUtils tt_fontSize:16.f]];
        [_openURLButton addTarget:self action:@selector(openURLButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    }
    return _openURLButton;
}

- (AKRedPacketOptionalLoginView *)bottomLoginView
{
    if (_bottomLoginView == nil) {
        _bottomLoginView = [[AKRedPacketOptionalLoginView alloc] initWithSupportPlatforms:@[PLATFORM_PHONE] delegate:self];
        [_bottomLoginView hiddenLoginButton];
    }
    return _bottomLoginView;
}

- (void)openURLButtonClicked
{
    [self.viewController dismissViewControllerAnimated:YES completion:^{
        if (self.dismissBlock) {
            self.dismissBlock();
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"TTCloseRedPackertNotification" object:nil userInfo:nil];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"TTArticleTabBarControllerChangeSelectedIndexNotification" object:nil userInfo:@{@"tag":@"tab_ak_activity"}];
    }];
}

#pragma AKRedPacketOptionalLoginViewDelegate

- (void)loginButtonClicked:(UIButton *)button withPlatform:(NSString *)platform
{
    if ([platform isEqualToString:PLATFORM_PHONE]) {
        [TTAccountManager presentQuickLoginFromVC:self.viewController type:TTAccountLoginDialogTitleTypeDefault source:nil completion:^(TTAccountLoginState state) {
            if (state == TTAccountLoginStateLogin) {
                WeakSelf;
                [[AKRedPacketManager sharedManager] notifyNewbeeRedPacketUserGotWithCompletion:^(BOOL shouldGot) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        wself.shouldGotRedPacket = shouldGot;
                        [self layoutSubviews];
                        [self fetchShareInfoIfNeed];
                    });
                }];
            }
        }];
    }
}

@end
