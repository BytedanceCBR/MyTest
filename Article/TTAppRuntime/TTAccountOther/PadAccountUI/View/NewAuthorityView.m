//
//  ArticleAccountLoginView.m
//  Article
//
//  Created by Dianwei on 13-5-7.
//
//

#import "NewAuthorityView.h"
#import <NetworkUtilities.h>
#import <TTIndicatorView.h>
#import <TTThemeManager.h>
#import <UIImage+TTThemeExtension.h>
#import <TTDeviceHelper.h>
#import <TTUIResponderHelper.h>

#import <TTAccountBusiness.h>

#import "ArticleMobileNumberViewController.h"

#import "SSUserSettingManager.h"
#import "TTProjectLogicManager.h"
#import "TTTrackerWrapper.h"
#import "TTDeviceHelper.h"

#define kBottomPadding ([TTDeviceHelper is568Screen] ? 60 : 37)
#define kBottomPaddingHK ([TTDeviceHelper is568Screen] ? 70 : 30)
#define kIntroduceImageViewTopPadding ([TTDeviceHelper is568Screen] ? 22 : 0)

@interface NewAuthorityView()
<
TTAccountMulticastProtocol
> {
    BOOL _buttonClicked; // to approximately send umeng event
}

@property(nonatomic, retain)UIImageView *introduceImageView;
@property(nonatomic, retain)UIView * introduceImageViewBgView;
@property(nonatomic, retain)UIButton *sinaButton;
@property(nonatomic, retain)UIButton *qqButton;
@property(nonatomic, retain)UIButton *weixinButton;
@property(nonatomic, retain)UIButton *tencentButton;
@property(nonatomic, retain)UIButton *mobileButton;
@property(nonatomic, retain)UIButton *renrenButton;
@property(nonatomic, retain)UIButton *kaixinButton;
@property(nonatomic, retain)UILabel *descLabel1;
@property(nonatomic, retain)UILabel *descLabel2;
@property(nonatomic, assign)NewAuthorityViewType viewType;
@property(nonatomic, retain)UIButton *enterButton;
@property(nonatomic, retain)NSString *lastLoginPlatform;
@property(nonatomic, retain)TTIndicatorView *indicatorView;
@property(nonatomic, retain)TTIndicatorView *loginingIndicatorView;

@property (nonatomic, retain) UIView                * maskView;
@end

@implementation NewAuthorityView
@synthesize introduceImageView, sinaButton, qqButton, mobileButton, renrenButton, kaixinButton, tencentButton;

- (void)dealloc
{
    self.introduceImageView = nil;
    self.introduceImageViewBgView = nil;
    self.sinaButton = nil;
    self.qqButton = nil;
    self.mobileButton = nil;
    self.tencentButton = nil;
    self.renrenButton = nil;
    self.kaixinButton = nil;
    self.descLabel1 = nil;
    self.descLabel2 = nil;
    self.enterButton = nil;
    self.delegate = nil;
    self.lastLoginPlatform = nil;
    self.indicatorView = nil;
    self.loginingIndicatorView = nil;
    self.weixinButton = nil;
    self.maskView = nil;
    _completion = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [TTAccount removeMulticastDelegate:self];
}

- (id)initWithFrame:(CGRect)frame
{
    return [self initWithFrame:frame type:AuthorityViewNormal];
}

- (id)initWithFrame:(CGRect)frame type:(NewAuthorityViewType)type
{
    self = [super initWithFrame:frame];
    if (self) {
        _showLoginIndicator = NO;
        self.umengEventName = @"login";
        self.viewType = type;
        
        switch (type) {
            case AuthorityViewNormal:
            {
                self.backgroundColor = [UIColor tt_themedColorForKey:kColorBackground4];
                UIImage * introImage = [[UIImage themedImageNamed:@"Login_background_Introduce.png"] stretchableImageWithLeftCapWidth:10 topCapHeight:2];
                self.introduceImageView = [[UIImageView alloc] initWithFrame:self.bounds];
                introduceImageView.image = introImage;
                [self addSubview:introduceImageView];
                
                self.introduceImageViewBgView = [[UIView alloc] initWithFrame:introduceImageView.frame];
                [self addSubview:_introduceImageViewBgView];
                [self bringSubviewToFront:introduceImageView];
                
                self.descLabel1 = [[UILabel alloc] initWithFrame:CGRectZero];
                _descLabel1.textColor = [UIColor colorWithHexString:[[TTThemeManager sharedInstance_tt] selectFromDayColorName:@"828282" nightColorName:@"4a6166"]];
                _descLabel1.font = [UIFont systemFontOfSize:15];
                // bug fix (to keep descLabel1 for future use)
                _descLabel1.text = NSLocalizedString(@"", nil);
                _descLabel1.backgroundColor = [UIColor clearColor];
                [_descLabel1 sizeToFit];
                _descLabel1.left = 48;
                
                switch (_viewType) {
                    case AuthorityViewIntroduce:
                        _descLabel1.top = 40;
                        break;
                    case AuthorityViewNormal:
                    {
                        
                        {
                            CGFloat y = 20;
                            _descLabel1.top = y;
                        }
                        
                    }
                        break;
                    default:
                        break;
                }
                
                [self addSubview:_descLabel1];
                
                self.descLabel2 = [[UILabel alloc] initWithFrame:CGRectZero];
                _descLabel2.textColor = [UIColor colorWithHexString:[[TTThemeManager sharedInstance_tt] selectFromDayColorName:@"828282" nightColorName:@"4a6166"]];
                _descLabel2.font = [UIFont systemFontOfSize:15];
                _descLabel2.text = NSLocalizedString(@"登录后可查看好友评论，关注更多达人", nil);
                _descLabel2.backgroundColor = [UIColor clearColor];
                [_descLabel2 sizeToFit];
                _descLabel2.origin = CGPointMake((_descLabel1.left), (_descLabel1.bottom));
                [self addSubview:_descLabel2];
            }
                break;
            case AuthorityViewIntroduce:
            {
                
                
                BOOL needAddIcon = NO;
                
                UIImage *image = nil;
                //                image = [UIImage themedImageNamed:@"background_Introduce_top.png"];
                if([[TTSandBoxHelper bundleIdentifier] isEqualToString:@"com.ss.iphone.article.News"] || [[TTSandBoxHelper bundleIdentifier] isEqualToString:@"com.ss.iphone.InHouse.article.News"]) {
                    image = [UIImage themedImageNamed:@"background_Introduce_ordinary.png"];
                }
                else if([[TTSandBoxHelper bundleIdentifier] isEqualToString:@"com.ss.iphone.article.NewsSocial"])
                {
                    image = [UIImage themedImageNamed:@"background_Introduce_socialcontact.png"];
                }
                else if([[TTSandBoxHelper bundleIdentifier] isEqualToString:@"com.ss.iphone.article.Explore"])
                {
                    image = [UIImage themedImageNamed:@"background_Introduce_explore.png"];
                }
                else {
                    image = [UIImage themedImageNamed:@"background_Introduce_top.png"];
                    needAddIcon = YES;
                }
                self.introduceImageView = [[UIImageView alloc] initWithImage:image];
                introduceImageView.top = [TTDeviceHelper is568Screen] ? 81 : 53;
                [self addSubview:introduceImageView];
                
                if (needAddIcon) {
                    UIImageView * iconImgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Icon.png"]];
                    iconImgView.origin = CGPointMake((introduceImageView.frame.size.width - iconImgView.frame.size.width) / 2.f, 20);
                    [introduceImageView addSubview:iconImgView];
                }
                
            }
                break;
            default:
                break;
        }
        
        [self layoutButtons];
        
        self.maskView = [[UIView alloc] initWithFrame:self.bounds];
        self.maskView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.maskView.userInteractionEnabled = NO;
        self.maskView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
        [self addSubview:self.maskView];
        
        [self reloadThemeUI];
        [SSUserSettingManager setShouldShowIntroductionView:YES];
        
        [TTAccount addMulticastDelegate:self];
    }
    
    return self;
}

- (void)layoutButtons
{
    if (!TTLogicBool(@"isI18NVersion", NO)) {
        [self addLoginButtons];
    } else {
        [self addLoginButtonsHK];
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    introduceImageView.centerX = self.width / 2;
    [self layoutButtons];
}

- (void)addSinaButton
{
    if (!self.sinaButton) {
        self.sinaButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [sinaButton setImage:[UIImage themedImageNamed:@"sinabutton_Introduce.png"] forState:UIControlStateNormal];
        [sinaButton setImage:[UIImage themedImageNamed:@"sinabutton_Introduce_press.png"] forState:UIControlStateHighlighted];
        [sinaButton sizeToFit];
        [sinaButton addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
}

- (void)addTencentButton
{
    if (!self.tencentButton) {
        self.tencentButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.tencentButton setImage:[UIImage themedImageNamed:@"tencentbutton_Introduce.png"] forState:UIControlStateNormal];
        [self.tencentButton setImage:[UIImage themedImageNamed:@"tencentbutton_Introduce_press.png"] forState:UIControlStateHighlighted];
        [self.tencentButton sizeToFit];
        [self.tencentButton addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
}
- (void)addQQButton
{
    if (!self.qqButton) {
        self.qqButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.qqButton setImage:[UIImage themedImageNamed:@"qqbutton_Introduce.png"] forState:UIControlStateNormal];
        [self.qqButton setImage:[UIImage themedImageNamed:@"qqbutton_Introduce_press.png"] forState:UIControlStateHighlighted];
        [self.qqButton sizeToFit];
        [self.qqButton addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
}

- (void)addMobileButton
{
    if (!self.mobileButton) {
        self.mobileButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [mobileButton setImage:[UIImage themedImageNamed:@"cellphonebutton_Introduce"] forState:UIControlStateNormal];
        [mobileButton sizeToFit];
        [mobileButton addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
}

- (void)addWeixinButton
{
    if (!self.weixinButton) {
        self.weixinButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.weixinButton setImage:[UIImage themedImageNamed:@"weixinbutton_Introduce.png"] forState:UIControlStateNormal];
        [self.weixinButton setImage:[UIImage themedImageNamed:@"weixinbutton_Introduce_press.png"] forState:UIControlStateHighlighted];
        [self.weixinButton sizeToFit];
        [self.weixinButton addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
}

- (void)addRenrenButton
{
    if (!self.renrenButton) {
        self.renrenButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [renrenButton setImage:[UIImage themedImageNamed:@"renrenbutton_shortIntroduce.png"] forState:UIControlStateNormal];
        [renrenButton setImage:[UIImage themedImageNamed:@"renrenbutton_shortIntroduce_press.png"] forState:UIControlStateHighlighted];
        [renrenButton sizeToFit];
        [renrenButton addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
}

- (void)addKaixinButton
{
    if (!self.kaixinButton) {
        self.kaixinButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [kaixinButton setImage:[UIImage themedImageNamed:@"kaixinbutton_Introduce.png"] forState:UIControlStateNormal];
        [kaixinButton setImage:[UIImage themedImageNamed:@"kaixinbutton_Introduce_press.png"] forState:UIControlStateHighlighted];
        [kaixinButton sizeToFit];
        [kaixinButton addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
}

- (void)addEnterButton
{
    if (!self.enterButton) {
        self.enterButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_enterButton setImage:[UIImage imageNamed:@"title_Introduce.png"] forState:UIControlStateNormal];
        [_enterButton addTarget:self action:@selector(enterClicked:) forControlEvents:UIControlEventTouchUpInside];
        [_enterButton sizeToFit];
    }
}

- (void)addLoginButtons {
    float buttonOffsetY = 10;
    // 最下面的登录平台的坐标Y
    CGFloat offsetY = self.height - 220 - kBottomPadding;
    
    [self addMobileButton];
    [self addSubview:mobileButton];
    mobileButton.top = offsetY;
    mobileButton.centerX = self.width / 2;
    offsetY = (mobileButton.bottom) + buttonOffsetY;
    
    /// 如果有安装微信，则显示微信登录
    BOOL canDisplayWX = [TTAccountAuthWeChat isAppAvailable];
    if (canDisplayWX) {
        [self addWeixinButton];
        self.weixinButton.top = offsetY;
        self.weixinButton.centerX = self.width / 2;
        [self addSubview:self.weixinButton];
        offsetY = (self.weixinButton.bottom) + buttonOffsetY;
    }
    // pad 肯定有腾讯微博的展示，iPhone端如果有微信，则不展示腾讯微博登录
    if (!canDisplayWX) {
        // 腾讯微博
        [self addTencentButton];
        
        self.tencentButton.top = offsetY;
        self.tencentButton.centerX = self.width / 2;
        [self addSubview:self.tencentButton];
        offsetY = (self.tencentButton.bottom) + buttonOffsetY;
    }
    
    [self addQQButton];
    qqButton.top = offsetY;
    qqButton.centerX = self.width / 2;
    [self addSubview:qqButton];
    
    [self addSinaButton];
    
    sinaButton.top = (qqButton.bottom) + buttonOffsetY;
    sinaButton.centerX = self.width / 2;
    [self addSubview:sinaButton];
    
    
    switch (_viewType) {
        case AuthorityViewNormal:
        {
            [self addRenrenButton];
            
            renrenButton.origin = CGPointMake((sinaButton.left), (sinaButton.bottom) + buttonOffsetY);
            [self addSubview:renrenButton];
            
            [self addKaixinButton];
            kaixinButton.origin = CGPointMake((renrenButton.right) + 10, (renrenButton.bottom));
            [self addSubview:kaixinButton];
            
        }
            break;
        case AuthorityViewIntroduce:
        {
            [self addEnterButton];
            _enterButton.top = self.height - 40;
            _enterButton.centerX = sinaButton.center.x;
            
            [self addSubview:_enterButton];
        }
            break;
        default:
            break;
    }
}

- (void)addLoginButtonsHK {
    
    float buttonOffsetY = [TTDeviceHelper is568Screen] ? 20 : 18;
    [self addQQButton];
    
    qqButton.top = self.height - 220 - kBottomPaddingHK;
    qqButton.centerX = self.width / 2;
    [self addSubview:qqButton];
    
    [self addSinaButton];
    
    sinaButton.top = (qqButton.right) + buttonOffsetY;
    sinaButton.centerX = self.width / 2;
    [self addSubview:sinaButton];
    
    
    switch (_viewType) {
        case AuthorityViewNormal:
        {
            
        }
            break;
        case AuthorityViewIntroduce:
        {
            // 腾讯微博
            [self addTencentButton];
            tencentButton.top = (sinaButton.bottom) + buttonOffsetY;
            tencentButton.centerX = self.width / 2;
            
            [self addEnterButton];
            
            _enterButton.top = (tencentButton.bottom) + 30;
            _enterButton.centerX = sinaButton.centerX;
            
            [self addSubview:_enterButton];
        }
            
            break;
        default:
            break;
    }
}

- (void)enterClicked:(id)sender
{
    if(_delegate && [_delegate respondsToSelector:@selector(introduceViewLoginCancelled:)])
    {
        [_delegate introduceViewLoginCancelled:self];
    }
    else
    {
        [self dismiss];
    }
    
    wrapperTrackEvent(_umengEventName, @"skip");
}

#pragma mark - TTAccountMulticastProtocol

- (void)onAccountStatusChanged:(TTAccountStatusChangedReasonType)reasonType platform:(NSString *)platformName
{
    if(_buttonClicked)
    {
        if(reasonType != TTAccountStatusChangedReasonTypeLogout &&
           reasonType != TTAccountStatusChangedReasonTypeSessionExpiration) {
            
            if(!isEmptyString(platformName)) {
                wrapperTrackEvent(_umengEventName, [NSString stringWithFormat:@"login_%@_success", platformName]);
            }
        }
    }
    
    _buttonClicked = NO;
}

- (void)onAccountAuthPlatformStatusChanged:(TTAccountAuthPlatformStatusChangedReasonType)reasonType platform:(NSString *)platformName error:(NSError *)error
{
    if (!error) {
        if (reasonType == TTAccountAuthPlatformStatusChangedReasonTypeLogin) {
            [self successInLoginingAccountPlatform];
        }
    }
}

- (void)respondsToAccountLoginPlatform:(NSString *)platformName
                                 error:(NSError *)error
{
    if (_showLoginIndicator) {
        [self showLoginingIndicator];
    }
    
    if (error) {
        [self noticeDelegateError];
    } else {
        [self successInLoginingAccountPlatform];
    }
}

- (void)successInLoginingAccountPlatform
{
    if (_delegate != nil && [_delegate respondsToSelector:@selector(introduceViewLoginFinished:)])
    {
        [_delegate introduceViewLoginFinished:self];
    }
    else
    {
        int64_t delayInSeconds = 1;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [self dismiss];
        });
    }
    
    if([_lastLoginPlatform isEqualToString:PLATFORM_QQ_WEIBO])
    {
        wrapperTrackEvent(_umengEventName, @"recommend_login_qq_success");
    }
    else if([_lastLoginPlatform isEqualToString:PLATFORM_QZONE])
    {
        wrapperTrackEvent(_umengEventName, @"login_qzone_success");
    }
    else if([_lastLoginPlatform isEqualToString:PLATFORM_SINA_WEIBO])
    {
        wrapperTrackEvent(_umengEventName, @"login_sina_weibo_success");
    } else if ([_lastLoginPlatform isEqualToString:PLATFORM_RENREN_SNS]) {
        wrapperTrackEvent(_umengEventName, @"login_renren_success");
    } else if ([_lastLoginPlatform isEqualToString:PLATFORM_WEIXIN]) {
        wrapperTrackEvent(_umengEventName, @"login_weixin_success");
    }
    
    self.lastLoginPlatform = nil;
}

- (void)buttonClicked:(id)sender {
    if (sender == self.mobileButton && !TTLogicBool(@"isI18NVersion", NO)) {
        /////// 友盟统计
        wrapperTrackEvent(@"guide", @"login_moblie");
        ArticleMobileNumberViewController * viewController = [[ArticleMobileNumberViewController alloc] initWithMobileNumberUsingType:ArticleMobileNumberUsingTypeRegister];
        viewController.completion = self.completion;
        [self.viewController.navigationController pushViewController:viewController animated:YES];
        return;
    }
    _buttonClicked = YES;
    NSString *keyName = nil;
    if(sender == sinaButton)
    {
        keyName = PLATFORM_SINA_WEIBO;
    }
    else if(sender == qqButton)
    {
        keyName = PLATFORM_QZONE;
    }
    else if (sender == self.weixinButton) {
        keyName = PLATFORM_WEIXIN;
    }
    else if(sender == tencentButton)
    {
        keyName = PLATFORM_QQ_WEIBO;
    }
    else if(sender == renrenButton)
    {
        keyName = PLATFORM_RENREN_SNS;
    }
    else if(sender == kaixinButton)
    {
        keyName = PLATFORM_KAIXIN_SNS;
    }
    _lastLoginPlatform = keyName;
    if ([keyName isEqualToString:PLATFORM_WEIXIN]) {
        wrapperTrackEvent(_umengEventName, @"login_weixin");
    } else {
        wrapperTrackEvent(_umengEventName, [NSString stringWithFormat:@"auth_%@", keyName]);
    }
    
    [TTAccountLoginManager requestLoginPlatformByName:keyName completion:^(BOOL success, NSError *error) {
        [self respondsToAccountLoginPlatform:keyName error:error];
    }];
}

- (void)themeChanged:(NSNotification *)notification
{
    self.backgroundColor = [UIColor tt_themedColorForKey:kColorBackground4];
    _introduceImageViewBgView.backgroundColor = [UIColor clearColor];
    if (_viewType == AuthorityViewNormal) {
        UIImage * introImage = [[UIImage themedImageNamed:@"Login_background_Introduce.png"] stretchableImageWithLeftCapWidth:10 topCapHeight:2];
        if ([[TTThemeManager sharedInstance_tt] currentThemeMode] == TTThemeModeNight) {
        }
        [introduceImageView setImage:introImage];
    }
    _descLabel1.textColor = [UIColor colorWithHexString:[[TTThemeManager sharedInstance_tt] selectFromDayColorName:@"828282" nightColorName:@"4a6166"]];
    _descLabel2.textColor = [UIColor colorWithHexString:[[TTThemeManager sharedInstance_tt] selectFromDayColorName:@"828282" nightColorName:@"4a6166"]];
    
    [sinaButton setImage:[UIImage imageNamed:@"sinabutton_Introduce.png"] forState:UIControlStateNormal];
    [sinaButton setImage:[UIImage imageNamed:@"sinabutton_Introduce_press.png"] forState:UIControlStateHighlighted];
    
    [qqButton setImage:[UIImage imageNamed:@"qqbutton_Introduce.png"] forState:UIControlStateNormal];
    [qqButton setImage:[UIImage imageNamed:@"qqbutton_Introduce_press.png"] forState:UIControlStateHighlighted];
    
    [self.tencentButton setImage:[UIImage imageNamed:@"tencentbutton_Introduce"] forState:UIControlStateNormal];
    [self.tencentButton setImage:[UIImage imageNamed:@"tencentbutton_Introduce_press"] forState:UIControlStateHighlighted];
    
    NSString * buttonImage = @"cellphonebutton_Introduce";
    [mobileButton setImage:[UIImage imageNamed:buttonImage] forState:UIControlStateNormal];
    
    
    switch (_viewType) {
        case AuthorityViewNormal:
        {
            [renrenButton setImage:[UIImage imageNamed:@"renrenbutton_shortIntroduce.png"] forState:UIControlStateNormal];
            [renrenButton setImage:[UIImage imageNamed:@"renrenbutton_shortIntroduce_press.png"] forState:UIControlStateHighlighted];
            break;
        }
        case AuthorityViewIntroduce:
        {
            [renrenButton setImage:[UIImage imageNamed:@"renrenbutton_Introduce.png"] forState:UIControlStateNormal];
            [renrenButton setImage:[UIImage imageNamed:@"renrenbutton_Introduce_press.png"] forState:UIControlStateHighlighted];
            break;
        }
        default:
            break;
    }
    
    
    [kaixinButton setImage:[UIImage imageNamed:@"kaixinbutton_Introduce.png"] forState:UIControlStateNormal];
    [kaixinButton setImage:[UIImage imageNamed:@"kaixinbutton_Introduce_press.png"] forState:UIControlStateHighlighted];
    
    self.maskView.hidden = [TTThemeManager sharedInstance_tt].currentThemeMode == TTThemeModeDay;
}

-(void)didAppear{
    [super didAppear];
}

- (void)dismiss
{
    [self hideLoginIndicator];
    UIViewController *topController = [TTUIResponderHelper topViewControllerFor:self];
    if(topController.navigationController.topViewController == topController) {
        [topController.navigationController popViewControllerAnimated:YES];
        if (topController.navigationController.viewControllers.count == 1 && topController.navigationController.presentingViewController) {
            [topController.navigationController dismissViewControllerAnimated:YES completion:NULL];
        }
    }
    else {
        if (topController.navigationController && topController.navigationController.viewControllers.count == 1) {
            [topController.navigationController dismissViewControllerAnimated:YES completion:NULL];
        } else {
            [topController dismissViewControllerAnimated:YES completion:NULL];
        }
    }
    
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    
    // TODO: use better way
    
    Class newsBaseDelegateClass = NSClassFromString(@"NewsBaseDelegate");
    
    if(newsBaseDelegateClass)
    {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [newsBaseDelegateClass performSelector:NSSelectorFromString(@"startRegisterRemoteNotification")];
#pragma clang diagnostic pop
    }
}

- (void)noticeDelegateError
{
    if(_delegate && [_delegate respondsToSelector:@selector(introduceViewLoginFailed:)])
    {
        [_delegate introduceViewLoginFailed:self];
    }
    else
    {
        if(!TTNetworkConnected())
        {
            [self displayMessage:NSLocalizedString(@"网络连接失败", nil) withImage:nil duration:2];
        }
        else
        {
            [self displayMessage:NSLocalizedString(@"登录失败，请重试", nil) withImage:nil duration:2];
        }
    }
    
    self.lastLoginPlatform = nil;
}

- (void)displayMessage:(NSString*)msg withImage:(UIImage*)image duration:(float)duration
{
    _indicatorView = [[TTIndicatorView alloc] initWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:msg indicatorImage:image dismissHandler:nil];
    _indicatorView.autoDismiss = NO;
    [_indicatorView showFromParentView:self];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(duration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [_indicatorView dismissFromParentView];
    });
}

- (void)showLoginingIndicator
{
    _loginingIndicatorView = [[TTIndicatorView alloc] initWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:NSLocalizedString(@"开始推荐...", nil) indicatorImage:[UIImage themedImageNamed:@"doneicon_popup_textpage.png"] dismissHandler:nil];
    _loginingIndicatorView.autoDismiss = NO;
    [_loginingIndicatorView showFromParentView:self];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(120 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [_loginingIndicatorView dismissFromParentView];
    });
}

- (void)hideLoginIndicator
{
    [_loginingIndicatorView dismissFromParentView];
}
@end
