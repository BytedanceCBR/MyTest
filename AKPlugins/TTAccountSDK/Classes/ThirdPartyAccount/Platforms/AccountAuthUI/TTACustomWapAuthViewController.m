//
//  TTACustomWapAuthViewController.m
//  TTAccountSDK
//
//  Created by liuzuopeng on 3/21/17.
//
//

#import "TTACustomWapAuthViewController.h"
#import <QuartzCore/CAGradientLayer.h>
#import "TTAWapNavigationBar.h"
#import "NSString+TTAccountUtils.h"
#import "NSBundle+TTAResources.h"
#import "TTAccountURLSetting+Platform.h"
#import "TTAccountUserEntity_Priv.h"
#import "TTAccount.h"
#import "TTAccountConfiguration_Priv.h"
#import "TTAccountAuthRespModel.h"
#import "TTAccountJSONResponseSerializer.h"
#import "TTAccountAuthCallbackTask.h"
#import "TTAccountLogDispatcher+ThirdPartyAccount.h"
#import "TTAWapNavigationBar.h"



/**
 *  这个宏是为了兼容头条iPad版
 */
#define TTAccountToutiaoCompatibility   (1)

#define TTAccountSNSBottomBarViewHeight (40.f)
#define TTAccountPadWidth               (540.f)



@interface _TTA_WapBottomBarView_ : UIView
@property (nonatomic, assign) BOOL checkboxSelected;
@property (nonatomic, assign) TTAccountAuthType platformType;
@property (nonatomic,   copy) NSString *snsText;

@property (nonatomic, strong) UIImageView *bgImageView;
@property (nonatomic, strong) UILabel     *sendSNSLabel;
@property (nonatomic, strong) UIButton    *checkBoxButton;
@property (nonatomic, strong) CAGradientLayer *bottomGradientLayer;
@property (nonatomic, assign) CGFloat additionalSafeInsetBottom; /** iPhoneX适配 */
@end

@implementation _TTA_WapBottomBarView_

- (instancetype)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame])) {
        [self __tta_wapCustomInit__];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [super initWithCoder:aDecoder])) {
        [self __tta_wapCustomInit__];
    }
    return self;
}

- (void)__tta_wapCustomInit__
{
    {
        _checkboxSelected = NO;
        _additionalSafeInsetBottom = 0;
    }
    
    [self.layer insertSublayer:self.bottomGradientLayer atIndex:0];
    
    [self addSubview:self.bgImageView];
    [self addSubview:self.checkBoxButton];
    [self addSubview:self.sendSNSLabel];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    {
        [CATransaction begin];
        [CATransaction setDisableActions:YES];
        _bottomGradientLayer.frame = CGRectMake(0, -4, CGRectGetWidth(self.frame), 4.f);
        [CATransaction commit];
    }
    
    {
        _bgImageView.frame = self.bounds;
    }
    
    {
        _checkBoxButton.frame = CGRectMake(0.f,
                                           (CGRectGetHeight(self.frame) - _additionalSafeInsetBottom - CGRectGetHeight(_checkBoxButton.frame)) / 2.f,
                                           CGRectGetWidth(_checkBoxButton.frame),
                                           CGRectGetHeight(_checkBoxButton.frame));
    }
    
    {
        _sendSNSLabel.frame = CGRectMake(44.f,
                                         (CGRectGetHeight(self.frame) - _additionalSafeInsetBottom - CGRectGetHeight(_sendSNSLabel.frame)) / 2,
                                         CGRectGetWidth(_sendSNSLabel.frame),
                                         CGRectGetHeight(_sendSNSLabel.frame));
    }
}


#pragma mark - events

- (void)actionDidTapCheckboxButton:(UIButton *)sender
{
    self.checkboxSelected = !_checkboxSelected;
    
    // logger
    [TTAccountLogDispatcher dispatchDidTapCustomWapSNSBarWithChecked:_checkboxSelected
                                                         forPlatform:_platformType];
}


#pragma mark - setter/getter

- (void)setCheckboxSelected:(BOOL)checkboxSelected
{
    if (_checkboxSelected != checkboxSelected) {
        _checkboxSelected = checkboxSelected;
        
        [self.checkBoxButton setSelected:_checkboxSelected];
    }
}

- (void)setSnsText:(NSString *)snsText
{
    if (![snsText isEqualToString:_snsText]) {
        _snsText = snsText;
        
        self.sendSNSLabel.text = snsText;
        [self.sendSNSLabel sizeToFit];
    }
}

- (UIButton *)checkBoxButton
{
    if (!_checkBoxButton) {
        _checkBoxButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 44.f, 44.f)];
        [_checkBoxButton setImage:[UIImage tta_imageNamed:@"tta_checkbox_press"]
                         forState:UIControlStateHighlighted];
        [_checkBoxButton setImage:[UIImage tta_imageNamed:@"tta_checkbox_normal"]
                         forState:UIControlStateNormal];
        [_checkBoxButton setImage:[UIImage tta_imageNamed:@"tta_checkbox_select"]
                         forState:UIControlStateSelected];
        [_checkBoxButton setSelected:_checkboxSelected];
        [_checkBoxButton addTarget:self
                            action:@selector(actionDidTapCheckboxButton:)
                  forControlEvents:UIControlEventTouchUpInside];
    }
    return _checkBoxButton;
}

- (UILabel *)sendSNSLabel
{
    if (!_sendSNSLabel) {
        _sendSNSLabel = [UILabel new];
        _sendSNSLabel.backgroundColor = [UIColor clearColor];
        _sendSNSLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        _sendSNSLabel.font = [UIFont systemFontOfSize:15.f];
        _sendSNSLabel.textColor     = TTAccountUIColorFromHexRGB(0x4d4d4d);
        _sendSNSLabel.shadowColor   = [UIColor whiteColor];
        _sendSNSLabel.shadowOffset  = CGSizeMake(0, 1.f);
    }
    return _sendSNSLabel;
}

- (UIImageView *)bgImageView
{
    if (!_bgImageView) {
        UIImage *image = [UIImage tta_imageNamed:@"tta_empower_bar"];
        _bgImageView   = [[UIImageView alloc] initWithImage:image];
    }
    return _bgImageView;
}

- (CAGradientLayer *)bottomGradientLayer
{
    if (!_bottomGradientLayer) {
        CGColorRef darkColor  = TTAccountUIColorFromHexRGBA(0x00000026).CGColor;
        CGColorRef lightColor = [UIColor clearColor].CGColor;
        _bottomGradientLayer  = [[CAGradientLayer alloc] init];
        _bottomGradientLayer.frame  = CGRectMake(0, -4, CGRectGetWidth(self.frame), 4.f);
        _bottomGradientLayer.colors = [NSArray arrayWithObjects:(__bridge id)(lightColor),
                                       (__bridge id)darkColor, nil];
    }
    return _bottomGradientLayer;
}

@end



#pragma mark - TTACustomWapAuthViewController

@interface TTACustomWapAuthViewController ()
<
UIWebViewDelegate,
NSURLSessionTaskDelegate
> {
    BOOL _slidingBack; /** YES: 滑动返回; NO: 其它返回方式 (调用函数Dismiss Or Pop等) */
    NSInteger _numberOfRequests;
}
@property(nonatomic, assign) UIStatusBarStyle originalStatusBarStyle;
@property(nonatomic, assign) BOOL originalStatusBarHidden;

@property (nonatomic, strong) UIWebView *webView;
@property (nonatomic, strong) UIActivityIndicatorView *indicatorView;
@property (nonatomic, strong) _TTA_WapBottomBarView_  *snsBottomBarView;

/** 成功在第三方平台授权后，返回给客户端的授权码 */
@property (nonatomic,   copy) NSString *code;
/** 客户端到第三方平台授权时带过去的State，由第三方平台授权后回传给客户端，用于后面验证防CSRF攻击的唯一标识 */
@property (nonatomic,   copy) NSString *passBackState;

/** iPhoneX适配 */
@property (nonatomic, assign) CGFloat additionalSafeInsetBottom;
@end

@implementation TTACustomWapAuthViewController

- (instancetype)init
{
    if ((self = [super init])) {
        [self __tta_customInit__];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [super initWithCoder:aDecoder])) {
        [self __tta_customInit__];
    }
    return self;
}

- (instancetype)initWithURL:(NSURL *)url
{
    if ((self = [self init])) {
        _url = url;
    }
    return self;
}

- (void)__tta_customInit__
{
    _slidingBack      = YES;
    _snsBarHidden     = NO;
    _numberOfRequests = 0;
    _schemePrefix     = @"snssdk35";
    _additionalSafeInsetBottom = 0;
}

- (void)dealloc
{
    if (_slidingBack) {
        if ([_delegate respondsToSelector:@selector(wapLoginViewController:didBackManuallyByDismiss:)]) {
            BOOL byDismiss = [self __tta_beingPresentedModally__];
            [_delegate wapLoginViewController:self didBackManuallyByDismiss:byDismiss];
        }
    }
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    {
        self.view.backgroundColor = [UIColor whiteColor];
        
        _originalStatusBarStyle = [UIApplication sharedApplication].statusBarStyle;
        _originalStatusBarHidden= [UIApplication sharedApplication].statusBarHidden;
        
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
        [[UIApplication sharedApplication] setStatusBarHidden:NO
                                                withAnimation:UIStatusBarAnimationNone];
    }
    
    [self __tta_setupNavigationBar__];
    [self __tta_setupWapView__];
    [self __tta_setupSNSBottomBar__];
    
    if (!_url) {
        _url = [NSURL URLWithString:[NSString stringWithFormat:@"%@?platform=%@",
                                     [TTAccountURLSetting TTACustomWAPLoginURLString], _authPlatformName]];
    }
    
    [self startRequest];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(shouldRefreshAccountStatusBarDidAppBeActive:) name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
}

- (void)shouldRefreshAccountStatusBarDidAppBeActive:(NSNotification *)notification
{
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    [[UIApplication sharedApplication] setStatusBarHidden:NO
                                            withAnimation:UIStatusBarAnimationNone];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (!self.navigationController) {
        [self __tta_fixNavigationBar__];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[UIApplication sharedApplication] setStatusBarStyle:_originalStatusBarStyle];
    [[UIApplication sharedApplication] setStatusBarHidden:NO
                                            withAnimation:_originalStatusBarHidden];
}

#pragma mark - setup

- (void)__tta_setupNavigationBar__
{
    {
        self.navigationItem.titleView = [UIBarButtonItem tta_barTitleViewWithTitle:self.title];
    }
    
    {
        UIBarButtonItem *refreshBarButtonItem =
        [UIBarButtonItem tta_refreshBarButtonItemWithTarget:self
                                                     action:@selector(__tta_refresh__)];
        self.navigationItem.rightBarButtonItem = refreshBarButtonItem;
    }
    
    if ([self __tta_beingPresentedModally__]) {
        // present
        if (!TTACCOUNT_IS_IPAD) {
            UIBarButtonItem *leftBarButtonItem =
            [UIBarButtonItem tta_backBarButtonItemWithText:NSLocalizedString(@"返回", nil)
                                                arrowImage:YES
                                                    target:self
                                                    action:@selector(__tta_actionForDismissSelf__)];
            self.navigationItem.leftBarButtonItem = leftBarButtonItem;
        } else {
            UIBarButtonItem *leftBarButtonItem =
            [UIBarButtonItem tta_backBarButtonItemWithText:NSLocalizedString(@"取消", nil)
                                                arrowImage:NO
                                                    target:self
                                                    action:@selector(__tta_actionForDismissSelf__)];
            self.navigationItem.leftBarButtonItem = leftBarButtonItem;
            
        }
    } else {
        // push
        UIBarButtonItem *leftBarButtonItem =
        [UIBarButtonItem tta_backBarButtonItemWithText:NSLocalizedString(@"返回", nil)
                                            arrowImage:YES
                                                target:self
                                                action:@selector(__tta_actionForDismissSelf__)];
        self.navigationItem.leftBarButtonItem = leftBarButtonItem;
    }
}

- (void)__tta_setupWapView__
{
    [self.view addSubview:self.webView];
}

- (void)__tta_setupSNSBottomBar__
{
    [self.view addSubview:self.snsBottomBarView];
    self.snsBottomBarView.platformType = _authPlatformType;
    
    BOOL checkboxDefaultSelected = YES;
    if (TTAccountAuthTypeTencentQQ == _authPlatformType) {
        //为了审核， qq空间默认不勾选
        checkboxDefaultSelected = NO;
    }
    
    {
        self.snsBottomBarView.checkboxSelected = checkboxDefaultSelected;
        [self.snsBottomBarView setSnsText:[self __SNSText__]];
    }
    
    if ([self.class isAppHasSharedToSNSPlatform:_authPlatformName]) {
        _snsBarHidden = YES;
    }
    
    {
        self.snsBottomBarView.hidden = _snsBarHidden;
    }
}

- (void)__tta_fixNavigationBar__
{
    if (!self.navigationController.navigationBar && !self.tta_wapNavigationBar) {
        TTAWapNavigationBar *wapNavBar =
        [[TTAWapNavigationBar alloc] initWithFrame:CGRectMake(0,
                                                              20,
                                                              CGRectGetWidth(self.view.bounds),
                                                              40)];
        [wapNavBar pushNavigationItem:self.navigationItem animated:NO];
        self.tta_wapNavigationBar = wapNavBar;
        [self.view addSubview:wapNavBar];
    }
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    {
        CGFloat insetTop      = CGRectGetMinX(self.view.frame) != 0 ? 64 : 0;
        CGFloat insetBottom   = (TTACCOUNT_IS_IPAD || _snsBarHidden) ? 0 : TTAccountSNSBottomBarViewHeight;
        CGRect  webViewFrame  = self.view.bounds;
        webViewFrame.origin.y = insetTop;
        webViewFrame.size.height = webViewFrame.size.height - insetTop - insetBottom - _additionalSafeInsetBottom;
        
        _webView.frame = webViewFrame;
    }
    
    {
        _snsBottomBarView.frame = CGRectMake(0,
                                             CGRectGetHeight(self.view.bounds) - TTAccountSNSBottomBarViewHeight - _additionalSafeInsetBottom,
                                             CGRectGetWidth(self.view.bounds),
                                             TTAccountSNSBottomBarViewHeight + _additionalSafeInsetBottom);
    }
}

- (void)viewSafeAreaInsetsDidChange
{
    [super viewSafeAreaInsetsDidChange];

    UIEdgeInsets safeInset = self.view.safeAreaInsets;
    _additionalSafeInsetBottom = safeInset.bottom;
    _snsBottomBarView.additionalSafeInsetBottom = _additionalSafeInsetBottom;
}

#pragma mark - status bar

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleDefault;
}

- (BOOL)prefersStatusBarHidden
{
    return NO;
}

- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation
{
    return UIStatusBarAnimationNone;
}


#pragma mark - Dismiss

- (void)__tta_actionForDismissSelf__
{
    if ([_delegate respondsToSelector:@selector(wapLoginViewController:didBackManuallyByDismiss:)]) {
        BOOL byDismiss = [self __tta_beingPresentedModally__];
        [_delegate wapLoginViewController:self didBackManuallyByDismiss:byDismiss];
    }
    
    [self __tta_dismissSelf__];
}

- (void)__tta_dismissSelf__
{
    [self onBackWithCompletion:^(BOOL dismissOrPop) {
        
    }];
}

- (void)onBackWithCompletion:(void (^)(BOOL dismissOrPop))completion
{
    {
        _slidingBack = NO;
    }
    
    if ([self __tta_beingPresentedModally__]) {
        [self dismissViewControllerAnimated:YES completion:^{
            if (completion) completion(YES);
        }];
    } else {
        [CATransaction begin];
        [self.navigationController popViewControllerAnimated:YES];
        [CATransaction setCompletionBlock:^{
            if (completion) completion(NO);
        }];
        [CATransaction commit];
    }
}

- (void)__tta_refresh__
{
    [self startRequest];
}


#pragma mark - load request

- (void)startRequest
{
    {
        _code = nil;
        _passBackState = nil;
    }
    
    NSMutableDictionary *getParams = [[[TTAccount accountConf] tta_commonNetworkParameters] mutableCopy];
    BOOL isLogin = [[TTAccount sharedAccount] isLogin];
    [getParams addEntriesFromDictionary:@{@"uid_type": isLogin ? @"12" : @"14"}];
    
    NSString *requestURLString = [_url.absoluteString copy];
    NSURL *requestURL = [requestURLString tta_URLByAppendQueryItems:getParams];
    
    @try {
        [_webView loadRequest:[NSURLRequest requestWithURL:requestURL]];
    } @catch (NSException *ne) {
    } @finally {
    }
}

- (void)setUrl:(NSURL *)url
{
    if ([_url.absoluteString isEqualToString:url.absoluteString]) {
        _url = url;
        if ([self isViewLoaded]) {
            [self startRequest];
        }
    }
}


#pragma mark - device相关

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    if (TTACCOUNT_IS_IPHONE) {
        return UIInterfaceOrientationMaskPortrait;
    } else if (TTACCOUNT_IS_IPAD) {
        return UIInterfaceOrientationMaskAll;
    }
    return [super supportedInterfaceOrientations];
}

- (BOOL)shouldAutorotate
{
    if (TTACCOUNT_IS_IPAD) {
        return YES;
    } else if (TTACCOUNT_IS_IPHONE) {
        return NO;
    }
    return [super shouldAutorotate];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    if (TTACCOUNT_IS_IPAD) {
        return YES;
    } else {
        return (interfaceOrientation == UIInterfaceOrientationPortrait);
    }
}


#pragma mark - helper

- (BOOL)__tta_beingPresentedModally__
{
    // Check if we have a parent navigation controller, it's being presented modally,
    // and if it is, that we are its root view controller
    if (self.navigationController && self.navigationController.presentingViewController)
        return ([self.navigationController.viewControllers indexOfObject:self] == 0);
    else // Check if we're being presented modally directly
        return ([self presentingViewController] != nil);
    return NO;
}

- (NSString *)__default_followSNSText__
{
    if (TTAccountAuthTypeSinaWeibo != _authPlatformType) {
        return [NSString stringWithFormat:@"推荐给好友并关注%@官方主页", [self.class __appDisplayName__]];
    } else {
        return [NSString stringWithFormat:@"推荐给好友并关注%@官方微博", [self.class __appDisplayName__]];
    }
}

+ (NSString *)__appDisplayName__
{
    static NSString *appName = nil;
    if (!appName) {
        appName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"];
        if (!appName) appName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleName"];
    }
    return appName ? : @"幸福里";
}

- (NSString *)__SNSText__
{
    return _snsText ? : [self __default_followSNSText__];
}


#pragma mark - 兼容头条

- (CGFloat)__tta_padHeight__
{
    CGFloat height = 660.f;
    if ([self __tta_isSmallSplit__]) {
        height = CGRectGetHeight(self.view.frame);
    }
    return height;
}

- (BOOL)__tta_isSmallSplit__
{
    return (TTAccountPadWidth > CGRectGetWidth(self.view.frame));
}

- (CGFloat)__tta_padWidth__
{
    if ([self __tta_isSmallSplit__]) {
        return CGRectGetWidth(self.view.frame);
    }
    return TTAccountPadWidth;
}


#pragma mark - parse <snssdk** callback>

- (void)__parseCustomWapAuthCallbackWithURL__:(NSURL *)url withContextInfo:(NSDictionary *)extraParams
{
    TTACustomWapAuthCallbackRespModel *wapClkRespMdl = [[TTACustomWapAuthCallbackRespModel alloc] initWithWapAuthCallbackURL:url];
    wapClkRespMdl.data.code  = _code;
    wapClkRespMdl.data.state = _passBackState;
    NSDictionary *wapClkDict = [wapClkRespMdl toDictionary];
    
    NSError *error = nil;
    [TTAccountJSONResponseSerializer handleResponseResult:wapClkDict
                                            responseError:nil
                                              resultError:&error
                                              originalURL:url];
    
    // logger
    [TTAccountLogDispatcher dispatchCustomWapAuthCallbackAndRedirectToURL:url.absoluteString
                                                              forPlatform:_authPlatformType
                                                                    error:error
                                                                  context:extraParams];
    
    
    if (error && (TTAccountAuthSuccess != error.code)) {
        
        if (TTACCOUNT_DEVICE_SYS_VERSION < 8.0) {
            __weak typeof(self) weakSelf = self;
            [self onBackWithCompletion:^(BOOL dismissOrPop) {
                if (!weakSelf) return;
                __strong typeof(weakSelf) strongSelf = weakSelf;
                if ([strongSelf.delegate respondsToSelector:@selector(wapLoginViewController:didFailWithError:)]) {
                    [strongSelf.delegate wapLoginViewController:strongSelf didFailWithError:error];
                }
            }];
        } else {
            [self __tta_dismissSelf__];
            
            if ([_delegate respondsToSelector:@selector(wapLoginViewController:didFailWithError:)]) {
                [_delegate wapLoginViewController:self didFailWithError:error];
            }
        }
    } else {
        if (self.snsBottomBarView.checkboxSelected && ![self.class isAppHasSharedToSNSPlatform:_authPlatformName]) {
            [[self class] shareAppToSNSPlatform:_authPlatformName];
        }
        
        if (TTACCOUNT_DEVICE_SYS_VERSION < 8.0) {
            __weak typeof(self) weakSelf = self;
            [self onBackWithCompletion:^(BOOL dismissOrPop) {
                if (!weakSelf) return;
                __strong typeof(weakSelf) strongSelf = weakSelf;
                if ([strongSelf.delegate respondsToSelector:@selector(wapLoginViewController:didFinishWithResult:)]) {
                    [strongSelf.delegate wapLoginViewController:strongSelf didFinishWithResult:wapClkDict];
                }
            }];
        } else {
            [self __tta_dismissSelf__];
            
            if ([_delegate respondsToSelector:@selector(wapLoginViewController:didFinishWithResult:)]) {
                [_delegate wapLoginViewController:self didFinishWithResult:wapClkDict];
            }
        }
    }
}

#pragma mark -  UIWebViewDelegate

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    _numberOfRequests++;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    {
        _numberOfRequests--;
    }
    
    if ([_indicatorView isAnimating] && _numberOfRequests == 0) {
        [_indicatorView stopAnimating];
    }
    
    {
        // 调整UI
        if (TTACCOUNT_IS_IPHONE && TTACCOUNT_DEVICE_SYS_VERSION >= 5.0f) {
            CGSize contentSize = self.webView.scrollView.contentSize;
            
#if TTAccountToutiaoCompatibility == 1
            if (contentSize.width > [self __tta_padWidth__]) {
                self.webView.scrollView.contentOffset = CGPointMake((contentSize.width - [self __tta_padWidth__]) / 2.f, 0);
            }
#else
            if (contentSize.width > CGRectGetWidth(self.view.bounds)) {
                self.webView.scrollView.contentOffset = CGPointMake((contentSize.width - CGRectGetWidth(self.view.bounds)) / 2.f, 0);
            }
#endif
        }
    }
    
    {
        [self.view bringSubviewToFront:self.snsBottomBarView];
    }
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    _numberOfRequests--;
    
    if ([_indicatorView isAnimating] && _numberOfRequests == 0) {
        [_indicatorView stopAnimating];
    }
}

/**
 *  点击登录按钮登录第三方平台，第三方平台重定向到到配置的回调地址[http:// ****** /auth/login_success]
 */
static NSString * const kTTOAuthCustomWapLoginSuccessPathKey = @"/auth/login_success";
static NSString * const kTTOAuthCustomWapLoginPlatformKey    = @"platform";
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    BOOL shouldStart    = YES;
    NSURL *requestURL   = request.URL;
    NSString *urlPath   = requestURL.path;
    NSString *urlScheme = requestURL.scheme;
    
    if(urlPath && [urlPath compare:kTTOAuthCustomWapLoginSuccessPathKey options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        
        NSDictionary *queryDictionary = [requestURL tta_queryDictionary];
        if ([queryDictionary valueForKey:@"code"]) {
            _code = queryDictionary[@"code"];
        }
        if ([queryDictionary valueForKey:@"state"]) {
            _passBackState = queryDictionary[@"state"];
        }
        
        NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]
                                                              delegate:self
                                                         delegateQueue:nil];
        NSURLSessionTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * __nullable data, NSURLResponse * __nullable response, NSError * __nullable error) {
            
        }];
        [task resume];
        
        {
            shouldStart = NO;
        }
        
        return shouldStart;
    }
    
    if(_schemePrefix && [urlScheme hasPrefix:_schemePrefix]) {
        {
            shouldStart = NO;
        }
        
        [self __parseCustomWapAuthCallbackWithURL__:requestURL
                                    withContextInfo:@{@"context_source": @(1)}];
        
        [self.indicatorView stopAnimating];
    } else {
        [self.indicatorView startAnimating];
    }
    
    return shouldStart;
}


#pragma mark - NSURLSessionDataDelegate

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task willPerformHTTPRedirection:(NSHTTPURLResponse *)response newRequest:(NSURLRequest *)request completionHandler:(void (^)(NSURLRequest * __nullable))completionHandler
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (response) {
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
            NSDictionary *respHeaderFields  = httpResponse.allHeaderFields;
            
            if([respHeaderFields isKindOfClass:[NSDictionary class]] &&
               [respHeaderFields objectForKey:@"X-SS-Set-Cookie"]) {
                NSDictionary *cookieDict = [NSDictionary dictionaryWithObject:[respHeaderFields objectForKey:@"X-SS-Set-Cookie"]
                                                                       forKey:@"Set-Cookie"];
                NSArray *newCookies = [NSHTTPCookie cookiesWithResponseHeaderFields:cookieDict
                                                                             forURL:response.URL];
                [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookies:newCookies
                                                                   forURL:response.URL
                                                          mainDocumentURL:nil];
            }
            
            if(_schemePrefix && [[request.URL scheme] hasPrefix:_schemePrefix]) {
                [self __parseCustomWapAuthCallbackWithURL__:request.URL
                                            withContextInfo:@{@"context_source": @(2)}];
                
                [self.indicatorView stopAnimating];
            } else {
                [self.indicatorView startAnimating];
            }
        }
    });
}


#pragma mark - setter/getter

- (UIWebView *)webView
{
    if (!_webView) {
        _webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
        _webView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.7];
        _webView.delegate = self;
    }
    return _webView;
}

- (_TTA_WapBottomBarView_ *)snsBottomBarView
{
    if (!_snsBottomBarView) {
        _snsBottomBarView =
        [[_TTA_WapBottomBarView_ alloc] initWithFrame:CGRectMake(0,
                                                                 0,
                                                                 CGRectGetWidth(self.view.bounds),
                                                                 TTAccountSNSBottomBarViewHeight)];
    }
    return _snsBottomBarView;
}

- (UIActivityIndicatorView *)indicatorView
{
    if (!_indicatorView) {
        _indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        _indicatorView.center = CGPointMake(CGRectGetWidth(self.view.frame)/2,
                                            CGRectGetHeight(self.view.frame)/2);
        [_indicatorView setHidesWhenStopped:YES];
        [self.view addSubview:_indicatorView];
    }
    [self.view bringSubviewToFront:_indicatorView];
    
    return _indicatorView;
}


#pragma mark - share app to SNS platform

+ (void)shareAppToSNSPlatform:(NSString *)platformString
{
    if (TTAccountIsEmptyString(platformString)) return;
    
    static NSMutableDictionary<NSString*, id<TTAccountSessionTask>> *shareTasks;
    if (!shareTasks) {
        shareTasks = [NSMutableDictionary dictionaryWithCapacity:3];
    }
    
    id<TTAccountSessionTask> shareAppTask = [shareTasks objectForKey:platformString];
    if (shareAppTask) [shareAppTask cancel];
    
    shareAppTask = [TTAccountAuthCallbackTask shareAppToSNSPlatform:platformString completedBlock:^(BOOL success, NSError *error) {
        if (success && !error) {
            [self.class setAppHasSharedToSNSPlatform:platformString];
        }
    }];
    
    if (shareAppTask) {
        [shareTasks setObject:shareAppTask forKey:platformString];
    }
}

+ (BOOL)isAppHasSharedToSNSPlatform:(NSString *)platformName
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    BOOL isShared = [[userDefaults objectForKey:[NSString stringWithFormat:@"TTAccount_AppHasSharedToSNSPlatform_%@", platformName]] boolValue];
    return isShared;
}

+ (void)setAppHasSharedToSNSPlatform:(NSString *)platformName
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:[NSNumber numberWithBool:YES] forKey:[NSString stringWithFormat:@"TTAccount_AppHasSharedToSNSPlatform_%@", platformName]];
    [userDefaults synchronize];
}

@end



@implementation UINavigationController (CustomWapAuthInit)

- (instancetype)initWithWapAuthViewController:(TTACustomWapAuthViewController *)wapAuthVC
{
    self = [self initWithNavigationBarClass:[TTAWapNavigationBar class] toolbarClass:nil];
    if (self) {
        if (wapAuthVC) self.viewControllers = @[wapAuthVC];
    }
    return self;
}

@end
