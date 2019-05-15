
//  TTProfileHeaderView.m
//  Article
//
//  Created by yuxin on 7/17/15.
//
//

#import "TTProfileHeaderView.h"
#import "TTImageView.h"
#import "UIImageView+WebCache.h"
#import "SSMyUserModel.h"
#import "TTThemeConst.h"
#import "UIButton+TTAdditions.h"
#import "TTDeviceHelper.h"
#import "TTDeviceUIUtils.h"
#import "UIImageAdditions.h"
#import "UIViewAdditions.h"
#import "TTVerifyIconImageView.h"
#import "TTProfileThemeConstants.h"
#import "TTProfileHeaderVisitorView.h"
#import "TTProfileNameContainerView.h"
#import "TTProfileViewController+VisitorFunction.h"
#import "ArticleMomentProfileViewController.h"
//#import "TTCommonwealUnLoginEntranceView.h"
//#import "TTCommonwealHasLoginEntranceView.h"
//#import "TTCommonwealManager.h"
#import "TTURLUtils.h"
#import "TTRoute.h"
#import "TTTabBarProvider.h"
#import "UIView+CustomTimingFunction.h"
#import <TTAccountBusiness.h>
#import <BDWebImage/SDWebImageAdapter.h>

#define loginButtonWidth ceilf([TTDeviceUIUtils tt_newPadding:66.f])
#define moreLoginButtonHorPadding ceilf([TTDeviceUIUtils tt_newPadding:17.5f])
#define moreLoginButtonVerPadding ceilf([TTDeviceUIUtils tt_newPadding:7.f])
#define kSmallPhoneHeight 182
#define kBigPhoneHeight 200

@interface TTProfileHeaderView ()
@property (nonatomic, strong) UIView *maskView;
// user info
@property (nonatomic, strong) UIView *avatarView; // 头像框
@property (nonatomic, strong) SSThemedImageView *avatarImageView; // 头像圆角
@property (nonatomic, strong) TTVerifyIconImageView *avatarVerifyView; // 头像认证图标
@property (nonatomic, strong) TTNameContainerView *nameContainerView;
@property (nonatomic, strong) TTProfileHeaderVisitorView *visitorContainerView;

// login button
@property (nonatomic, strong) SSThemedView   *loginBtnPanel;
@property (nonatomic, strong) TTAlphaThemedButton *qqButton;
@property (nonatomic, strong) TTAlphaThemedButton *phoneButton;
@property (nonatomic, strong) TTAlphaThemedButton *huoshanLoginButton;
@property (nonatomic, strong) TTAlphaThemedButton *douyinLoginButton;
@property (nonatomic, strong) TTAlphaThemedButton *sinaButton;
@property (nonatomic, strong) TTAlphaThemedButton *weixinButton;
@property (nonatomic, strong) TTAlphaThemedButton *moreLoginButton;
@property (nonatomic, strong) TTAlphaThemedButton *moreProfileButton;
//@property (nonatomic, strong) TTCommonwealUnLoginEntranceView *commonwealUnloginEntranceView;
//@property (nonatomic, strong) TTCommonwealHasLoginEntranceView *commonHasLoginEntranceView;

@property (nonatomic, strong) SSThemedButton *arrowBtn;
@property (nonatomic, strong) SSThemedLabel *loginRecommendLabel;

@property (nonatomic, assign) CGFloat currentViewHeight;
@property (nonatomic, assign) BOOL wealEntranceEnable;

@property (nonatomic, assign) CGFloat fansViewHeight;
@property (nonatomic, assign) BOOL canAnimate;
@property (nonatomic, assign) BOOL notAutoExpandFansView;

// 适配iPhoneX `刘海` 丑 */
@property (nonatomic, assign) CGFloat additionalSafeInsetTop;

// 为适配iOS11, 在iOS11中observeValueForKeyPath调用完成后→又会调用layoutSubviews
@property (nonatomic, assign) BOOL isFirstBackgroundImageNotEqualToView;
@end

@implementation TTProfileHeaderView

- (void)dealloc
{
    [self.tableView removeObserver:self forKeyPath:@"contentOffset"];
}

- (void)willMoveToSuperview:(UIView *)newSuperview
{
    if (self.superview && newSuperview == nil) {
        [self.superview removeObserver:self forKeyPath:@"contentOffset"];
    }
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    if (self.wealEntranceEnable) {
        if ([TTDeviceHelper is480Screen] || [TTDeviceHelper is568Screen]) {
            self.imageRatio = kSmallPhoneHeight / SSScreenWidth;
        } else {
            self.imageRatio = kBigPhoneHeight / SSScreenWidth;
        }
    } else {
        self.imageRatio = 38.f/75.f; // default 宽375 高190
    }
    
    [self.tableView addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:nil];
    
    {
        [self.userInfoView addSubview:self.avatarView];
        [self.userInfoView addSubview:self.nameContainerView];
        [self.userInfoView addSubview:self.visitorContainerView];
        [self.userInfoView addSubview:self.appFansView];
//        [self.userInfoView addSubview:self.commonHasLoginEntranceView];
        [self setupMoreProfileButton];
    }
    
    {
        [self initBackgroundImageView];
    }
    
    {
        [self initLoginPanel];
    }
    
    [self.loginView addSubview:self.arrowBtn];
    [self.loginView addSubview:self.loginRecommendLabel];
//    [self setupCommonwealShowIfNeeded];
    
    self.fansViewHeight = 0;
    // self.clipsToBounds = YES;
}

#pragma mark - init subviews

- (void)initBackgroundImageView
{
    if (!_backgoundImageView) {
        if ([TTDeviceHelper isPadDevice]) {
            self.backgoundImageView = [[SSThemedImageView alloc] initWithFrame:CGRectMake(0, -self.tableView.contentInset.top, self.bounds.size.width, 370 + self.additionalSafeInsetTop)];
        } else {
            self.backgoundImageView = [[SSThemedImageView alloc] initWithFrame:CGRectMake(0, -self.tableView.contentInset.top, self.bounds.size.width, self.frame.size.width * self.imageRatio + self.additionalSafeInsetTop)];
        }
        self.backgoundImageView.clipsToBounds = YES;
        self.backgoundImageView.contentMode = UIViewContentModeScaleAspectFill;
        self.backgoundImageView.imageName = @"default_profile_background_image";
        [self insertSubview:self.backgoundImageView atIndex:0];
    }
}

- (void)initLoginPanel
{
    self.loginBtnPanel = [[SSThemedView alloc] initWithFrame:CGRectZero];
    self.loginBtnPanel.clipsToBounds = YES;
    [self.loginView addSubview: self.loginBtnPanel];
    
    [self.loginBtnPanel addSubview:self.phoneButton];
    
    // 配置第三方平台账号
    [self setupPlatformButtons];
    
    [self setupMoreLoginButton];
    
//    [self.loginView addSubview:self.commonwealUnloginEntranceView];
    
    UIInterpolatingMotionEffect *motionEffectX = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.x" type:UIInterpolatingMotionEffectTypeTiltAlongHorizontalAxis];
    motionEffectX.minimumRelativeValue = @(-20);
    motionEffectX.maximumRelativeValue = @(20);
    [self.loginBtnPanel addMotionEffect:motionEffectX];
}

- (void)setupPlatformButtons
{
//    if ([TTAccountAuthHuoShan isAppAvailable] && [self.class isConfSupportedOfPlatform:PLATFORM_HUOSHAN]) {
//        if (!_huoshanLoginButton.superview) {
//            [self.loginBtnPanel addSubview:self.huoshanLoginButton];
//        }
//    } else {
//        [_huoshanLoginButton removeFromSuperview];
//    }
//
//    if ([TTAccountAuthDouYin isAppAvailable] && [self.class isConfSupportedOfPlatform:PLATFORM_DOUYIN]) {
//        if (!_douyinLoginButton.superview) {
//            [self.loginBtnPanel addSubview:self.douyinLoginButton];
//        }
//    } else {
//        [_douyinLoginButton removeFromSuperview];
//    }
    
    if ([TTAccountAuthWeChat isAppAvailable] && [self.class isConfSupportedOfPlatform:PLATFORM_WEIXIN]) {
        if (!_weixinButton.superview) {
            [self.loginBtnPanel addSubview:self.weixinButton];
        }
    } else {
        [_weixinButton removeFromSuperview];
    }
    
    if ([self.class isConfSupportedOfPlatform:PLATFORM_QZONE]) {
        if (!_qqButton.superview) {
            [self.loginBtnPanel addSubview:self.qqButton];
        }
    } else {
        [_qqButton removeFromSuperview];
    }
    
    if ([self.class isConfSupportedOfPlatform:PLATFORM_SINA_WEIBO]) {
        if (!_sinaButton.superview) {
            [self.loginBtnPanel addSubview:self.sinaButton];
        }
    } else {
        [_sinaButton removeFromSuperview];
    }
}

- (void)setupMoreLoginButton
{
    _moreLoginButton = [[TTAlphaThemedButton alloc] initWithFrame:CGRectZero];
    _moreLoginButton.imageName = @"morelogin_arrow";
    _moreLoginButton.enableHighlightAnim = YES;
    UIImage *more_arrow = [UIImage imageNamed:@"morelogin_arrow"];
    CGSize titleLabelSize = [@"更多登录方式" boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)
                                                    options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                                 attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:[TTDeviceUIUtils tt_fontSize:14.f]]} context:nil].size;
    [_moreLoginButton setTitle:@"更多登录方式" forState:UIControlStateNormal];
    _moreLoginButton.titleLabel.font = [UIFont systemFontOfSize:[TTDeviceUIUtils tt_fontSize:14.f]];
    _moreLoginButton.titleColorThemeKey = kColorText9;
    CGFloat space = [TTDeviceUIUtils tt_newPadding:7.f];
    _moreLoginButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    _moreLoginButton.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    if ([TTThemeManager sharedInstance_tt].currentThemeMode == TTThemeModeDay){
        self.moreLoginButton.backgroundColor = UIColorWithRGBA(0, 0, 0, .2f);
    } else {
        self.moreLoginButton.backgroundColor = UIColorWithRGBA(112, 112, 112, .2f);
    }
    _moreLoginButton.titleEdgeInsets = UIEdgeInsetsMake(0, -more_arrow.size.width - space/2, 0, more_arrow.size.width + space/2);
    _moreLoginButton.imageEdgeInsets = UIEdgeInsetsMake(0, titleLabelSize.width + space/2, 0, -titleLabelSize.width - space/2);
    _moreLoginButton.width = more_arrow.size.width + titleLabelSize.width + space + 2 * moreLoginButtonHorPadding;
    _moreLoginButton.height = fmax(more_arrow.size.height, _moreLoginButton.height) + 2 * moreLoginButtonVerPadding;
    _moreLoginButton.layer.cornerRadius = _moreLoginButton.height / 2;
    [_moreLoginButton setHitTestEdgeInsets: UIEdgeInsetsMake(-20, -20, -20, -15)];
    _moreLoginButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    [_moreLoginButton addTarget:self action:@selector(moreButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.loginView addSubview:_moreLoginButton];
}

- (void)setupMoreProfileButton
{
    _moreProfileButton = [[TTAlphaThemedButton alloc] initWithFrame:CGRectZero];
    _moreProfileButton.imageName = @"morelogin_arrow";
    _moreProfileButton.enableHighlightAnim = YES;
    UIImage *more_arrow = [UIImage imageNamed:@"morelogin_arrow"];
    _moreProfileButton.width = more_arrow.size.width;
    _moreProfileButton.height = more_arrow.size.height;
    [_moreProfileButton setHitTestEdgeInsets: UIEdgeInsetsMake(-20, -20, -20, -15)];
    _moreProfileButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    [_moreProfileButton addTarget:self action:@selector(moreButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    if ([TTTabBarProvider isMineTabOnTabBar]) {
        [self.userInfoView addSubview:_moreProfileButton];
    }
}

//- (void)setupCommonwealShowIfNeeded
//{
//    if (self.wealEntranceEnable) {
//        self.commonHasLoginEntranceView.hidden = NO;
//        self.commonwealUnloginEntranceView.hidden = NO;
//        self.arrowBtn.hidden = NO;
//        self.loginRecommendLabel.hidden = NO;
//        self.moreProfileButton.hidden = YES;
//        self.moreLoginButton.hidden = YES;
//    } else {
//        self.commonHasLoginEntranceView.hidden = YES;
//        self.commonwealUnloginEntranceView.hidden = YES;
//        self.arrowBtn.hidden = YES;
//        self.loginRecommendLabel.hidden = YES;
//        self.moreProfileButton.hidden = NO;
//        self.moreLoginButton.hidden = NO;
//    }
//}

#pragma mark - Account Dynamic Conf (服务端下发) Helper

+ (BOOL)isConfSupportedOfPlatform:(NSString *)controlledName
{
    if ([controlledName length] <= 0) return NO;
    
    NSArray *controlledList = [[TTAccountLoginConfLogic loginPlatformEntryList] copy];
    if ([controlledList isKindOfClass:[NSArray class]] && [controlledList count] > 0
        && [controlledList containsObject:controlledName]) {
        return YES;
    }
    
    // 不下发以默认为准
    if ([controlledList count] == 0) {
        static NSArray *defaultPlatformList = nil;
        if (!defaultPlatformList) {
            defaultPlatformList = @[
                                    PLATFORM_HUOSHAN,
                                    PLATFORM_DOUYIN,
                                    PLATFORM_WEIXIN,
                                    PLATFORM_QZONE,
                                    // TT_LOGIN_PLATFORM_SINAWEIBO, /** 微博默认下掉 */
                                    ];
            
        }
        return [defaultPlatformList containsObject:controlledName];
    }
    return NO;
}

#pragma mark - setter/getter

- (TTAlphaThemedButton *)phoneButton
{
    if (!_phoneButton)  {
        _phoneButton = [[TTAlphaThemedButton alloc] initWithFrame:CGRectMake(0, 0, loginButtonWidth, loginButtonWidth)];
        _phoneButton.enableHighlightAnim = YES;
        _phoneButton.layer.edgeAntialiasingMask = YES;
        _phoneButton.imageName = @"cellphoneicon_login_profile";
        [_phoneButton addTarget:self action:@selector(phoneButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _phoneButton;
}

- (SSThemedButton *)huoshanLoginButton
{
    if (!_huoshanLoginButton) {
        _huoshanLoginButton = [[TTAlphaThemedButton alloc] initWithFrame:CGRectMake(0, 0, loginButtonWidth, loginButtonWidth)];
        _huoshanLoginButton.enableHighlightAnim = YES;
        _huoshanLoginButton.layer.edgeAntialiasingMask = YES;
        _huoshanLoginButton.imageName = @"huoshan_login";
        [_huoshanLoginButton addTarget:self action:@selector(huoshanButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _huoshanLoginButton;
}

- (SSThemedButton *)douyinLoginButton
{
    if (!_douyinLoginButton) {
        _douyinLoginButton = [[TTAlphaThemedButton alloc] initWithFrame:CGRectMake(0, 0, loginButtonWidth, loginButtonWidth)];
        _douyinLoginButton.enableHighlightAnim = YES;
        _douyinLoginButton.layer.edgeAntialiasingMask = YES;
        _douyinLoginButton.imageName = @"douyin_login";
        [_douyinLoginButton addTarget:self action:@selector(douyinButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _douyinLoginButton;
}

- (TTAlphaThemedButton *)qqButton
{
    if (!_qqButton) {
        _qqButton = [[TTAlphaThemedButton alloc] initWithFrame:CGRectMake(0, 0, loginButtonWidth, loginButtonWidth)];
        _qqButton.enableHighlightAnim = YES;
        _qqButton.layer.edgeAntialiasingMask = YES;
        _qqButton.imageName = @"qqicon_login_profile";
        [_qqButton addTarget:self action:@selector(qqButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _qqButton;
}

- (SSThemedButton *)weixinButton
{
    if (!_weixinButton) {
        _weixinButton = [[TTAlphaThemedButton alloc] initWithFrame:CGRectMake(0, 0, loginButtonWidth, loginButtonWidth)];
        _weixinButton.enableHighlightAnim = YES;
        _weixinButton.layer.edgeAntialiasingMask = YES;
        _weixinButton.imageName = @"weixinicon_login_profile";
        [_weixinButton addTarget:self action:@selector(weixinButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _weixinButton;
}

- (SSThemedButton *)sinaButton
{
    if (!_sinaButton) {
        _sinaButton = [[TTAlphaThemedButton alloc] initWithFrame:CGRectMake(0, 0, loginButtonWidth, loginButtonWidth)];
        _sinaButton.enableHighlightAnim = YES;
        _sinaButton.layer.edgeAntialiasingMask = YES;
        _sinaButton.imageName = @"sinaicon_login_profile";
        [_sinaButton addTarget:self action:@selector(sinaButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _sinaButton;
}

//- (TTCommonwealUnLoginEntranceView *)commonwealUnloginEntranceView
//{
//    if (!_commonwealUnloginEntranceView) {
//        _commonwealUnloginEntranceView = [[TTCommonwealUnLoginEntranceView alloc] init];
//        [_commonwealUnloginEntranceView addTarget:self action:@selector(commonwealSkip) forControlEvents:UIControlEventTouchUpInside];
//    }
//    return _commonwealUnloginEntranceView;
//}
//
//- (TTCommonwealHasLoginEntranceView *)commonHasLoginEntranceView
//{
//    if (!_commonHasLoginEntranceView) {
//        _commonHasLoginEntranceView = [[TTCommonwealHasLoginEntranceView alloc] init];
//        [_commonHasLoginEntranceView addTarget:self action:@selector(commonwealSkip) forControlEvents:UIControlEventTouchUpInside];
//    }
//    return _commonHasLoginEntranceView;
//}

- (SSThemedButton *)arrowBtn
{
    if (!_arrowBtn) {
        _arrowBtn = [SSThemedButton buttonWithType:UIButtonTypeCustom];
        _arrowBtn.imageName = @"commonweal_morelogin_arrow";
        [_arrowBtn addTarget:self action:@selector(moreButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        return _arrowBtn;
    }
    return _arrowBtn;
}

- (SSThemedLabel *)loginRecommendLabel
{
    if (!_loginRecommendLabel) {
        _loginRecommendLabel = [[SSThemedLabel alloc] init];
        _loginRecommendLabel.font = [UIFont systemFontOfSize:[TTDeviceUIUtils tt_newPadding:15]];
        _loginRecommendLabel.textColorThemeKey = kColorText10;
        _loginRecommendLabel.text = @"登录推荐更精准";
    }
    return _loginRecommendLabel;
}

- (BOOL)wealEntranceEnable
{
    return NO;
//    _wealEntranceEnable = [SSCommonLogic commonwealEntranceEnable];
//    return _wealEntranceEnable;
}

#pragma mark - refresh

- (void)refreshUserinfo
{
    if ([TTAccountManager isLogin]) {
        // show user info container
        self.loginView.hidden = YES;
        self.maskView.hidden = YES;
        self.userInfoView.hidden = NO;
        
        [self.avatarImageView sda_setImageWithURL:[NSURL URLWithString:[TTAccountManager avatarURLString]] placeholderImage:[UIImage imageNamed:@"default_avatar"]];
        UIImage *defaultBgImage = [UIImage themedImageNamed:@"default_profile_background_image"];
        self.backgoundImageView.enableNightCover = YES;
        [self.backgoundImageView sda_setImageWithURL:[NSURL URLWithString:[TTAccountManager currentUser].bgImgURL] placeholderImage:self.backgoundImageView.image ? self.backgoundImageView.image : defaultBgImage];
        [self.nameContainerView refreshContainerView];
        // show avatar verify view
        NSString *userAuthInfo = [TTAccountManager userAuthInfo];
        if ([TTVerifyIconHelper isVerifiedOfVerifyInfo:userAuthInfo]) {
            self.avatarVerifyView.hidden = NO;
            [self.avatarVerifyView updateWithVerifyInfo:userAuthInfo extraConfig:nil];
        } else {
            self.avatarVerifyView.hidden = YES;
        }
        
        self.decorationView.decoratorInfoString = [[[TTAccount sharedAccount] user] userDecoration];
        self.decorationView.userID = [TTAccountManager userID];
        [self.decorationView showAvatarDecorator];
        
        [self tt_performSelector:@selector(refreshUserHistoryInfo) onlyOnceInSelector:_cmd];
    } else {
        // show login container
        self.loginView.hidden = NO;
        self.maskView.hidden  = YES;
        self.userInfoView.hidden = YES;
        self.backgoundImageView.enableNightCover = YES;
        self.backgoundImageView.imageName = @"default_profile_background_image";
        self.fansViewHeight = 0;
    }
    // [self setupCommonwealShowIfNeeded];
    
    self.appFansView.appInfos = self.fansInfoArray;
    [self setNeedsLayout];
    [self layoutIfNeeded];
}

//- (void)refreshCommonwealInfoWithTitle:(NSString *)title subTitle:(NSString *)subTitle isEnableGetMoney:(BOOL)enable
//{
//    if ([TTAccountManager isLogin]) {
//        if (self.wealEntranceEnable) {
//            [self.commonHasLoginEntranceView setTopTitle:title bottomTitle:subTitle isSelected:enable];
//            // [self layoutCommonwealHasLoginEntranceView];
//        }
//    } else {
//        if (self.wealEntranceEnable) {
//            [self.commonwealUnloginEntranceView setTipsTitle:title isSelected:enable];
//            [self layoutCommonwealUnloginEntranceView];
//        }
//    }
//}

- (void)refreshUserHistoryInfo
{
    self.visitorContainerView.hidden = NO;
    NSArray<TTProfileHeaderVisitorModel *> *models =
    [TTProfileHeaderVisitorModel modelsWithMoments:[TTAccountManager currentUser].momentsCount
                                        followings:[TTAccountManager currentUser].followingsCount
                                         followers:[TTAccountManager currentUser].followersCount
                                          visitors:[TTAccountManager currentUser].visitCountRecent];
    [self.visitorContainerView reloadModels:models];
    self.moreProfileButton.hidden = NO;
    
    if (self.wealEntranceEnable) {
        self.moreProfileButton.hidden = YES;
    }
    
    if ([SSCommonLogic showMyAppFansView]) {
        if (self.appFansView.appInfos.count > 0 && self.fansViewHeight < 0.5 && !self.notAutoExpandFansView) {
            if (self.appFansView.appInfos.count > 2) {
                self.fansViewHeight = 85;
            } else if (self.appFansView.appInfos.count == 2) {
                self.fansViewHeight = 56;
            } else {
                self.fansViewHeight = 0;
            }
            self.appFansView.height = self.fansViewHeight;
            [[NSNotificationCenter defaultCenter] postNotificationName:@"kAppFansViewExpand" object:@"" userInfo:@{@"expand": @(YES)}];
            self.notAutoExpandFansView = YES;
        } else {
            if (self.fansViewHeight > 0.5) {
                if (self.appFansView.appInfos.count > 2) {
                    self.fansViewHeight = 85;
                } else if (self.appFansView.appInfos.count == 2) {
                    self.fansViewHeight = 56;
                } else {
                    self.fansViewHeight = 0;
                }
                self.appFansView.height = self.fansViewHeight;
                
                if (self.fansViewHeight > 0) {
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"kAppFansViewExpand" object:@"" userInfo:@{@"expand": @(YES)}];
                }
            }
        }
    } else {
        if (self.fansViewHeight > 0.5) {
            if (self.appFansView.appInfos.count > 2) {
                self.fansViewHeight = 85;
            } else if (self.appFansView.appInfos.count == 2) {
                self.fansViewHeight = 56;
            } else {
                self.fansViewHeight = 0;
            }
            self.appFansView.height = self.fansViewHeight;
            
            if (self.fansViewHeight > 0) {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"kAppFansViewExpand" object:@"" userInfo:@{@"expand": @(YES)}];
            }
        }
    }
}

#pragma mark - layout

- (void)layoutSubviews
{
    CGRect originalFrame = self.frame;
    
    if ([TTDeviceHelper isIPhoneXDevice]) {
        CGFloat exceptNavBarInsetTop = self.tableView.tt_safeAreaInsets.top - 44 /** 导航栏高度 */; // 坑爹pushViewControler的时候safeAreaInsets会变化
        self.additionalSafeInsetTop = MAX(0, (exceptNavBarInsetTop > 0 ? exceptNavBarInsetTop : self.tableView.tt_safeAreaInsets.top) - 24);
    }
    
    if ([TTDeviceHelper isPadDevice]) {
        self.frame = CGRectIntegral(CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, 370.f + self.additionalSafeInsetTop));
    } else {
        if (self.wealEntranceEnable) {
            CGFloat height = 0;
            if ([TTDeviceHelper is568Screen] || [TTDeviceHelper is480Screen]) {
                height = kSmallPhoneHeight;
            } else {
                height = kBigPhoneHeight;
            }
            self.frame = CGRectIntegral(CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, height + self.additionalSafeInsetTop + self.fansViewHeight));
        } else {
            self.frame = CGRectIntegral(CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, self.frame.size.width * self.imageRatio + self.additionalSafeInsetTop + self.fansViewHeight));
        }
    }
    self.currentViewHeight = self.frame.size.height - self.fansViewHeight;
    self.imageWidth  = self.frame.size.width;
    self.imageHeight = self.frame.size.height - self.fansViewHeight;
    
    CGRect theFrame = self.frame;
    if (self.canAnimate) {
        self.frame = originalFrame;
        [UIView animateWithDuration:0.2 customTimingFunction:CustomTimingFunctionSineOut animation:^{
            [self.tableView beginUpdates];
            [self.tableView setTableHeaderView:self]; //关键
            self.frame = theFrame;
            [self.tableView endUpdates];
            self.canAnimate = NO;
        } completion:^(BOOL finished) {
        }];
        
        if (self.appFansView.height > 1) {
            self.appFansView.height = 0;
            [UIView animateWithDuration:0.2 customTimingFunction:CustomTimingFunctionSineOut animation:^{
                if (self.appFansView.appInfos.count > 2) {
                    self.appFansView.height = 85;
                } else if (self.appFansView.appInfos.count == 2) {
                    self.appFansView.height = 56;
                } else {
                    self.appFansView.height = 0;
                }
            } completion:^(BOOL finished) {
            }];
            
        } else {
            if (self.appFansView.appInfos.count > 2) {
                self.appFansView.height = 85;
            } else if (self.appFansView.appInfos.count == 2) {
                self.appFansView.height = 56;
            } else {
                self.appFansView.height = 0;
            }
            [UIView animateWithDuration:0.2 customTimingFunction:CustomTimingFunctionSineOut animation:^{
                self.appFansView.height = 0;
            } completion:^(BOOL finished) {
            }];
        }
    } else {
        self.tableView.tableHeaderView = self;
    }
    
    /**
     * resolve ios7 上crash
     * 在iOS7上，有自动布局的使用的情况下，如果在[super layoutSubviews]之后设置self.frame将导致再次调用autolayout,从而crash
     */
    [super layoutSubviews];
    [self layoutProfileHeaderView];
}

- (void)layoutProfileHeaderView
{
    if ([TTDeviceHelper OSVersionNumber] < 11.0 || self.tableView.contentOffset.y >= 0){
        [self layoutBackgroudImageView];
    }
    
    [self layoutUserInfoViews];
    [self layoutMoreLoginButton];
    [self layoutLoginButtons];
    [self layoutArrowBtn];
    [self layoutLoginRecommendLabel];
#if INHOUSE
    if ([SSCommonLogic isLoginPlatformPhoneOnly]) {
        [self.loginBtnPanel.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (obj != self.phoneButton) {
                obj.hidden = YES;
            }
        }];
        self.phoneButton.center = CGPointMake(self.loginBtnPanel.width / 2, self.loginBtnPanel.height / 2);
        self.moreLoginButton.hidden = YES;
    }
#endif
}

- (void)layoutArrowBtn
{
    self.arrowBtn.size = self.arrowBtn.currentImage.size;
    self.arrowBtn.right = self.loginView.width - [TTDeviceUIUtils tt_newPadding:4];
    self.arrowBtn.centerY = self.loginBtnPanel.centerY;
}

- (void)layoutLoginRecommendLabel
{
    CGSize loginRecommendLabelSize = [self.loginRecommendLabel.text sizeWithAttributes:@{NSFontAttributeName : self.loginRecommendLabel.font}];
    self.loginRecommendLabel.size = loginRecommendLabelSize;
    self.loginRecommendLabel.centerX = self.loginView.width * 0.5;
    self.loginRecommendLabel.top = 32 - self.loginView.origin.y + self.additionalSafeInsetTop /* 适配`刘海` */;
}

- (void)layoutBackgroudImageView
{
    self.backgoundImageView.frame = CGRectMake((self.frame.size.width - self.imageWidth)/2, (self.frame.size.height - self.imageHeight)/2, self.imageWidth, self.imageHeight);
    self.backgoundImageView.center = CGPointMake(self.center.x, self.center.y - (self.imageHeight - self.frame.size.height)/2 - self.fansViewHeight);
}

- (void)layoutUserInfoViews
{
    //各种居中
    self.visitorContainerView.width = self.userInfoView.width;
    self.visitorContainerView.centerX = self.userInfoView.width / 2;
    
    if (![TTTabBarProvider isMineTabOnTabBar]) {
        self.visitorContainerView.height = 23;
        if ([TTDeviceHelper isScreenWidthLarge320]) {
            self.visitorContainerView.bottom = self.userInfoView.height - 11;
            
            if (self.wealEntranceEnable) {
                self.avatarView.bottom = self.visitorContainerView.top - [self heightOffsetWithCurrentDevice] - 20.5;
            } else {
                self.avatarView.bottom = self.visitorContainerView.top - 20.5;
            }
        } else {
            self.visitorContainerView.bottom = self.userInfoView.height - 8;
            if (self.wealEntranceEnable) {
                self.avatarView.bottom = self.visitorContainerView.top - [self heightOffsetWithCurrentDevice] - 10;
            } else {
                self.avatarView.bottom = self.visitorContainerView.top - 10;
            }
        }
    } else {
        self.visitorContainerView.height = [TTDeviceUIUtils tt_padding:kTTProfileLineHeight];
        self.visitorContainerView.bottom = self.userInfoView.height - [TTDeviceUIUtils tt_padding:kTTProfileVisitorInsetBotttom];
        if (self.wealEntranceEnable) {
            self.avatarView.bottom = self.visitorContainerView.top - [self heightOffsetWithCurrentDevice] - kTTProfileAvatarBottomMargin;
        } else {
            self.avatarView.bottom = self.visitorContainerView.top - kTTProfileAvatarBottomMargin;
        }
    }
    
    self.avatarView.bottom -= self.fansViewHeight;
    self.visitorContainerView.bottom -= self.fansViewHeight;

    if (![TTTabBarProvider isMineTabOnTabBar]) {
        if ([TTDeviceHelper isScreenWidthLarge320]) {
            self.appFansView.top = self.visitorContainerView.bottom + 11;
        } else {
            self.appFansView.top = self.visitorContainerView.bottom + 8;
        }
    } else {
        self.appFansView.top = self.visitorContainerView.bottom + [TTDeviceUIUtils tt_padding:kTTProfileVisitorInsetBotttom];
    }
    self.visitorContainerView.showUpDownArrow = self.fansInfoArray.count > 1           ;
    
    self.avatarView.left = self.userInfoView.left + kTTProfileAvatarLeftMargin;
    
    self.nameContainerView.centerY = self.avatarView.centerY;
    self.nameContainerView.left = self.avatarView.right + kTTProfileNameContainerLeftMargin;
//    [self layoutCommonwealHasLoginEntranceView];
}

//- (void)layoutCommonwealUnloginEntranceView
//{
//    self.commonwealUnloginEntranceView.centerX = self.centerX;
//    self.commonwealUnloginEntranceView.height = kCommonwealUnloginEntranceViewH;
//    self.commonwealUnloginEntranceView.bottom = self.loginView.bottom - self.loginView.origin.y - [TTDeviceUIUtils tt_padding:20];
//}
//
//- (void)layoutCommonwealHasLoginEntranceView
//{
//    self.commonHasLoginEntranceView.layer.masksToBounds = YES;
//    self.commonHasLoginEntranceView.layer.cornerRadius = kCommonwealHasLoginEntranceViewH * 0.5;
//    self.commonHasLoginEntranceView.width = kCommonwealHasLoginEntranceViewW + kCommonwealHasLoginEntranceViewH * 0.5;
//    self.commonHasLoginEntranceView.left = self.userInfoView.width - kCommonwealHasLoginEntranceViewW;
//    self.commonHasLoginEntranceView.height = kCommonwealHasLoginEntranceViewH;
//    self.commonHasLoginEntranceView.centerY = self.avatarView.centerY;
//}

- (void)layoutLoginButtons
{
    // refresh第三方登录账号按钮
    [self setupPlatformButtons];
    
    // layout login buttons
//    [self layoutCommonwealUnloginEntranceView];
    
    NSArray<UIView *> *platformButtons = [self.loginBtnPanel.subviews copy];
    CGFloat iconWidth = loginButtonWidth;
    CGFloat iconCount = [platformButtons count];
    NSUInteger maxNumberOfIcon = 4; // 最大可显示按钮个数
    CGFloat margin = 0;
    
    iconCount = MIN(iconCount, maxNumberOfIcon);
    if (self.wealEntranceEnable) {
        if (iconCount == 3) {
            margin = 36;
        } else {
            if ([TTDeviceHelper is480Screen] || [TTDeviceHelper is568Screen]) {
                margin = 8;
            } else {
                margin = [TTDeviceUIUtils tt_newPadding:13];
            }
        }
    } else {
        margin = (iconCount == 3 ? 36.f : 18.f);
    }
    CGFloat width = self.bounds.size.width;
    if (!self.wealEntranceEnable || iconCount == 3) {
        margin = ceilf((margin/375.f)*width);//6上间距标注为72px，UE说要等比例放大
    }
    
    if (iconCount > 1) {
        // 间距适配(各种类型的设备都测试过)，目的为了看起来舒服 <自己调整的没有参考android的>
        CGFloat ratio = ([TTDeviceHelper isPadDevice] ? 0.65 : 0.95);
        CGFloat adaptedMargin = (MIN(width * ratio * (iconCount / maxNumberOfIcon), width - [TTDeviceUIUtils tt_newPadding:70]) - (iconCount * iconWidth)) / (iconCount - 1);
        margin = MAX(margin, adaptedMargin);
    }
    
    CGFloat loginBtnPanelWidth = iconWidth * iconCount + margin * (iconCount - 1);
    
    self.loginBtnPanel.frame = CGRectMake((width - loginBtnPanelWidth)/2, 0, ceilf(loginBtnPanelWidth), iconWidth);
    if (self.wealEntranceEnable) {
//        self.loginBtnPanel.bottom = self.commonwealUnloginEntranceView.top - [TTDeviceUIUtils tt_newPadding:16];
    } else {
        self.loginBtnPanel.bottom = self.moreLoginButton.top - kTTProfileLoginButtonOffset;
        if (![TTTabBarProvider isMineTabOnTabBar]){
            // 为了火山接头条专门调整的
            if ([TTDeviceHelper is480Screen] || [TTDeviceHelper is568Screen]) {
                self.loginBtnPanel.bottom = self.moreLoginButton.top - 9;
            } else if ([TTDeviceHelper is667Screen] || [TTDeviceHelper isIPhoneXDevice]) {
                self.loginBtnPanel.bottom = self.moreLoginButton.top - 12;
            }
        }
    }
    
    NSUInteger index = 0;
    for (UIView *aButton in platformButtons) {
        aButton.frame =  CGRectMake((iconWidth + margin) * (index++), 0, iconWidth, iconWidth);
        if (index > maxNumberOfIcon) {
            aButton.hidden = YES;
        } else {
            aButton.hidden = NO;
        }
    }

    if (!self.wealEntranceEnable) {
        self.moreProfileButton.centerY = self.avatarView.centerY;
        self.moreProfileButton.right = self.userInfoView.right - kTTProfileMoreButtonRightMargin;//6上间距标注为30px，UE说要等比例放大;
    }
}

- (void)layoutMoreLoginButton
{
    self.moreLoginButton.centerX = self.centerX;
    self.moreLoginButton.bottom = self.loginView.bottom - self.loginView.origin.y - [TTDeviceUIUtils tt_padding:kTTProfileHintLabelOffset];
    if (![TTTabBarProvider isMineTabOnTabBar]) {
        //为了火山接头条专门调整的
        if ([TTDeviceHelper is480Screen] || [TTDeviceHelper is568Screen]) {
            self.moreLoginButton.bottom = self.loginView.bottom - self.loginView.origin.y - 8;
        } else if ([TTDeviceHelper is667Screen] || [TTDeviceHelper isIPhoneXDevice]){
            self.moreLoginButton.bottom = self.loginView.bottom - self.loginView.origin.y - 14;
        }
    }
}

- (void)layoutForAdjustingContentoffset
{
    [self layoutBackgroudImageView];
    //不注释掉会抖动
    //    [self layoutUserInfoViews];
    //    [self layoutLoginPanel];
}

- (CGFloat)heightOffsetWithCurrentDevice
{
    if (![TTTabBarProvider isMineTabOnTabBar]) {
        if ([TTDeviceHelper is480Screen] || [TTDeviceHelper is568Screen]) {
            return 20;
        } else {
            return 10;
        }
    } else {
        if ([TTDeviceHelper is480Screen] || [TTDeviceHelper is568Screen]) {
            return 10;
        } else {
            return 0;
        }
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqual:@"contentOffset"]) {
        if (!self.canAnimate) {
            CGPoint point = [[change valueForKey:NSKeyValueChangeNewKey] CGPointValue];
            self.imageHeight = MAX(self.currentViewHeight - point.y, self.currentViewHeight + self.tableView.contentInset.top);
            if ([TTDeviceHelper isPadDevice]) {
                self.imageWidth = MAX(self.frame.size.width, self.frame.size.width - point.y);
            } else {
                self.imageWidth = self.imageHeight / self.imageRatio;
            }
            
            [self layoutForAdjustingContentoffset];
        }
    }
}

#pragma mark - events of clicking login buttons

- (void)phoneButtonClicked:(id)sender
{
    if ([self.delegate respondsToSelector:_cmd]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        
        [self.delegate performSelector:_cmd withObject:sender];
#pragma clang diagnostic pop
    }
}

- (void)huoshanButtonClicked:(id)sender
{
    if ([self.delegate respondsToSelector:_cmd]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        
        [self.delegate performSelector:_cmd withObject:sender];
#pragma clang diagnostic pop
    }
}

- (void)douyinButtonClicked:(id)sender
{
    if ([self.delegate respondsToSelector:_cmd]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        
        [self.delegate performSelector:_cmd withObject:sender];
#pragma clang diagnostic pop
    }
}

- (void)weixinButtonClicked:(id)sender
{
    if ([self.delegate respondsToSelector:_cmd]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        
        [self.delegate performSelector:_cmd withObject:sender];
#pragma clang diagnostic pop
    }
}

- (IBAction)qqButtonClicked:(id)sender
{
    if ([self.delegate respondsToSelector:_cmd]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        
        [self.delegate performSelector:_cmd withObject:sender];
#pragma clang diagnostic pop
    }
}

- (IBAction)sinaButtonClicked:(id)sender
{
    if ([self.delegate respondsToSelector:_cmd]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        
        [self.delegate performSelector:_cmd withObject:sender];
#pragma clang diagnostic pop
    }
}

- (IBAction)moreButtonClicked:(id)sender
{
    if ([self.delegate respondsToSelector:_cmd]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        
        [self.delegate performSelector:_cmd withObject:sender];
#pragma clang diagnostic pop
    }
}

- (void)themeChanged:(NSNotification *)notification
{
    [super themeChanged:notification];
    self.avatarImageView.layer.borderColor = [UIColor tt_themedColorForKey:kColorBackground4].CGColor;
    if ([TTThemeManager sharedInstance_tt].currentThemeMode == TTThemeModeDay) {
        self.moreLoginButton.backgroundColor = UIColorWithRGBA(0, 0, 0, .2f);
    } else {
        self.moreLoginButton.backgroundColor = UIColorWithRGBA(112, 112, 112, .2f);
    }
}

#pragma mark - properties

- (UIView *)avatarView
{
    if (!_avatarView) {
        _avatarView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kTTProfileUserAvatarWidth, kTTProfileUserAvatarHeight)];
        _avatarView.userInteractionEnabled = YES;
        UITapGestureRecognizer *avartartTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapAvatarView)];
        [_avatarView addGestureRecognizer:avartartTap];
    }
    return _avatarView;
}

- (SSThemedImageView *)avatarImageView
{
    if (!_avatarImageView) {
        _avatarImageView = [[SSThemedImageView alloc] initWithFrame:CGRectMake(0, 0, self.avatarView.width, self.avatarView.height)];
        _avatarImageView.enableNightCover = YES;
        _avatarImageView.contentMode = UIViewContentModeScaleAspectFill;
        _avatarImageView.layer.cornerRadius = self.avatarView.frame.size.width/2;
        _avatarImageView.layer.masksToBounds = YES;
        _avatarImageView.layer.borderWidth = 1;
        _avatarImageView.layer.borderColor = [UIColor tt_themedColorForKey:kColorBackground4].CGColor;
        [self.avatarView addSubview:_avatarImageView];
    }
    return _avatarImageView;
}

- (TTVerifyIconImageView *)avatarVerifyView
{
    if (!_avatarVerifyView) {
        CGSize verifyIconSize = CGSizeMake(2 * kTTVerifyAvatarVerifyIconBorderWidth + [TTDeviceUIUtils tt_newPadding:kTTVerifyAvatarVerifyIconSizeBig.width], 2 * kTTVerifyAvatarVerifyIconBorderWidth + [TTDeviceUIUtils tt_newPadding:kTTVerifyAvatarVerifyIconSizeBig.height]);
        _avatarVerifyView = [[TTVerifyIconImageView alloc] initWithFrame:CGRectMake(self.avatarView.width - verifyIconSize.width, self.avatarView.height - verifyIconSize.height, verifyIconSize.width, verifyIconSize.height)];
        _avatarVerifyView.hidden = YES;
        [self.avatarView addSubview:_avatarVerifyView];
    }
    return _avatarVerifyView;
}

- (TTNameContainerView *)nameContainerView
{
    if (!_nameContainerView) {
        _nameContainerView = [TTNameContainerView new];
        _nameContainerView.backgroundColor = [UIColor clearColor];
        [_nameContainerView refreshContainerView];
    }
    return _nameContainerView;
}

- (TTProfileHeaderVisitorView *)visitorContainerView
{
    if (!_visitorContainerView) {
        _visitorContainerView = [[TTProfileHeaderVisitorView alloc] initWithModels:nil];
        _visitorContainerView.backgroundColor = [UIColor clearColor];
        __weak typeof(self) wself = self;
        _visitorContainerView.didTapButtonCallback = ^(TTProfileHeaderVisitorView *visitorView, NSUInteger selectedIndex) {
            __strong typeof(wself) self = wself;
            TTProfileHeaderVisitorModel *model = [visitorView.models objectAtIndex:selectedIndex];
            if ([model.text isEqualToString:@"粉丝"] && self.appFansView.appInfos.count >= 2) {
                self.canAnimate = YES;
                if (self.fansViewHeight > 0) {
                    self.fansViewHeight = 0;
                } else {
                    if (self.appFansView.appInfos.count > 2) {
                        self.fansViewHeight = 85;
                    } else if (self.appFansView.appInfos.count == 2) {
                        self.fansViewHeight = 56;
                    } else {
                        self.fansViewHeight = 0;
                    }
                    
                    if (self.appFansView.appInfos.count >= 2) {
                        [TTTrackerWrapper eventV3:@"followers_show" params:@{@"position":@"mine"}];
                    }
                }
                
                self.appFansView.height = self.fansViewHeight;
                [self setNeedsLayout];
            } else {
                if ([self.delegate respondsToSelector:@selector(visitorView:didSelectButtonAtIndex:)]) {
                    [self.delegate visitorView:visitorView didSelectButtonAtIndex:selectedIndex];
                }
            }
        };
    }
    return _visitorContainerView;
}

- (TTAvatarDecoratorView *)decorationView {
    if (!_decorationView) {
        _decorationView = [[TTAvatarDecoratorView alloc] initWithFrame:CGRectMake(kDecoratorOriginFactor * self.avatarView.width, kDecoratorOriginFactor * self.avatarView.height, kDecoratorSizeFactor * self.avatarView.width, kDecoratorSizeFactor * self.avatarView.height)];
        [self.avatarView addSubview:_decorationView];
    }
    return _decorationView;
}

- (UIView *)appFansView
{
    if (!_appFansView) {
        _appFansView = [[TTProfileHeaderAppFansView alloc] initWithFrame:CGRectMake(0, 90, [UIScreen mainScreen].bounds.size.height, self.fansViewHeight)];
        if ([[TTThemeManager sharedInstance_tt] currentThemeMode] == TTThemeModeNight) {
        } else {
        }
        _appFansView.clipsToBounds = YES;
        _appFansView.appInfos = nil;
    }
    return _appFansView;
}

- (void)didTapAvatarView
{
    wrapperTrackEventWithCustomKeys(@"mine_tab", @"enter_mine_profile", nil, @"avatar", nil);
    
    ArticleMomentProfileViewController *vc = [[ArticleMomentProfileViewController alloc] initWithUserID:[TTAccountManager userID]];
    vc.categoryName = @"mine_tab";
    vc.fromPage = @"self_head_image";
    [self.navigationController pushViewController:vc animated:YES];
}

//- (void)commonwealSkip
//{
//    NSString *url = [[TTCommonwealManager sharedInstance] commonwealSkipURL];
//    NSString *paramString = [NSString stringWithFormat:@"%.0lf",[[TTCommonwealManager sharedInstance] todayUsingTime]];
//    NSString *encodingParamString = [TTURLUtils queryItemAddingPercentEscapes:paramString];
//    url = [NSString stringWithFormat:@"%@%@",url,encodingParamString];
//    [[TTRoute sharedRoute] openURLByPushViewController:[TTStringHelper URLWithURLString:url]];
//    [[TTCommonwealManager sharedInstance] trackerWithSource:@"mine"];
//}

@end
