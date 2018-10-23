//
//  TTAdApointAlertView.m
//  Article
//
//  Created by yin on 16/9/21.
//
//

#import "TTAdAppointAlertView.h"

#import "ExploreMovieView.h"
#import "NetworkUtilities.h"
#import "TTAdMonitorManager.h"
#import "TTDeviceHelper.h"
#import "TTImageLoadingView.h"
#import "TTIndicatorView.h"
#import "TTKeyboardListener.h"
#import "UIView+Refresh_ErrorHandler.h"
#import <objc/runtime.h>
#import "TTModuleBridge.h"
#import "TTRoute.h"

#define kLoadingViewSize CGSizeMake([TTDeviceUIUtils tt_newPadding:44], [TTDeviceUIUtils tt_newPadding:44])

#define kCenterViewSizeWidth  [TTDeviceUIUtils tt_newPadding:650]
#define kCenterViewSizeHeight [TTDeviceUIUtils tt_newPadding:908]

#define kCenterViewWidthMargin  [TTDeviceUIUtils tt_newPadding:325]
#define kCenterViewHeightMargin [TTDeviceUIUtils tt_newPadding:332]

#define kCancelButtonSize  CGSizeMake([TTDeviceUIUtils tt_newPadding:44], [TTDeviceUIUtils tt_newPadding:44])
#define kImageViewPadding [TTDeviceUIUtils tt_newPadding:10]

NSString* const TTAdAppointAlertViewShowKey = @"TTAdAppointAlertViewShowKey";
NSString* const TTAdAppointAlertViewCloseKey = @"TTAdAppointAlertViewCloseKey";

@implementation TTAdLoadingCicle

- (SSThemedImageView *)animationView
{
    if (!_animationView) {
        _animationView = [[SSThemedImageView alloc] initWithFrame:self.bounds];
        [_animationView setImageName:@"refresh_ad_popup"];
        _animationView.center = CGPointMake(self.width / 2.f, self.height / 2.f);
        [self addSubview:_animationView];
    }
    
    return _animationView;
}

#pragma mark -- Animation

- (void)startAnimating
{
    CABasicAnimation *rotateAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotateAnimation.duration = 1.0f;
    rotateAnimation.repeatCount = HUGE_VAL;
    rotateAnimation.toValue = @(M_PI * 2);
    [self.animationView.layer addAnimation:rotateAnimation forKey:@"rotateAnimation"];
    
}

- (void)stopAnimating
{
    [self.animationView.layer removeAllAnimations];
    [self.animationView removeFromSuperview];
    self.animationView = nil;
    
}

@end

@implementation TTAdLoadingView

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setSubViews];
    }
    return self;
}

- (void)setSubViews
{
    self.loadingCicle = [[TTAdLoadingCicle alloc] init];
    [self addSubview:self.loadingCicle];
    WeakSelf;
    [self.loadingCicle mas_makeConstraints:^(MASConstraintMaker *make) {
        StrongSelf;
        make.top.centerX.equalTo(self);
        make.size.mas_equalTo(kLoadingViewSize);
    }];
    
    SSThemedLabel* loadingLabel = [[SSThemedLabel alloc] init];
    loadingLabel.text = @"加载中...";
    loadingLabel.textColorThemeKey = kColorText1;
    loadingLabel.font = [UIFont systemFontOfSize:16.0f];
    loadingLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:loadingLabel];
    [loadingLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        StrongSelf;
        make.centerX.equalTo(self);
        make.top.equalTo(self.loadingCicle.mas_bottom).offset([TTDeviceUIUtils tt_newPadding:15]);
    }];
    [self mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.width.equalTo(loadingLabel);
    }];
}

- (void)startAnimating
{
    [self.loadingCicle startAnimating];
}

- (void)stopAnimating
{
    [self.loadingCicle stopAnimating];
}

@end

@implementation TTAdRetryView

- (instancetype)initWithBlock:(TTAdActionBlock)block
{
    self = [super init];
    if (self) {
        
        self.block = [block copy];
        [self setSubViews];
    }
    return self;
}

- (void)setSubViews
{
    SSThemedButton* bgButton = [[SSThemedButton alloc] init];
    bgButton.backgroundColor = [UIColor clearColor];
    [self addSubview:bgButton];
    WeakSelf;
    [bgButton mas_makeConstraints:^(MASConstraintMaker *make) {
        StrongSelf;
        make.edges.equalTo(self);
    }];
    [bgButton addTarget:self action:@selector(retryButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
    
    self.retryCicle = [[SSThemedButton alloc] init];
    [self.retryCicle setImageName:@"retry_ad_popup"];
    [self.retryCicle addTarget:self action:@selector(retryButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.retryCicle];
    
    [self.retryCicle mas_makeConstraints:^(MASConstraintMaker *make) {
        StrongSelf;
        make.top.centerX.equalTo(self);
        make.size.mas_equalTo(kLoadingViewSize);
    }];
    
    self.loadingLabel = [[SSThemedLabel alloc] init];
    self.loadingLabel.text = @"加载失败，请重试";
    self.loadingLabel.textColorThemeKey = kColorText1;
    self.loadingLabel.font = [UIFont systemFontOfSize:16.0f];
    self.loadingLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:self.loadingLabel];
    [self.loadingLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        StrongSelf;
        make.centerX.equalTo(self);
        make.top.equalTo(self.retryCicle.mas_bottom).offset(15);
    }];
    [self mas_updateConstraints:^(MASConstraintMaker *make) {
        StrongSelf;
        make.bottom.width.equalTo(self.loadingLabel);
    }];
}

- (void)retryButtonTouched:(UIButton*)button
{
    if (self.block) {
        self.block();
    }
}

- (void)netWorkFail
{
    self.loadingLabel.text = @"网络不给力呀，请重试";
}

@end

@interface TTAdAppointAlertView()

@property (nonatomic,strong) SSThemedView * centerView;
@property (nonatomic,strong) SSThemedButton * cancelButton;
@property (nonatomic,strong) SSThemedImageView * cancelImageView;
@property (nonatomic,assign) TTAdApointFromSource fromSource;
@property (nonatomic,strong) TTAdAppointAlertModel* appointModel;
@property (nonatomic,strong) SSJSBridgeWebView* webview;


@property (nonatomic,strong) TTAdLoadingView* loadingView;
@property (nonatomic,strong) TTAdRetryView* retryView;

@property (nonatomic,assign) NSInteger centerWidth;
@property (nonatomic,assign) NSInteger centerHeight;

@property (nonatomic,strong) NSURLRequest *request;

@property (nonatomic, assign) BOOL needCheckFail;

@property (nonatomic, assign) BOOL keyBoardShow;

@end

@implementation TTAdAppointAlertView

- (TTAdAppointAlertView*)initWithModel:(id)appointModel fromSource:(TTAdApointFromSource)fromSource
{
    self = [super init];
    if (self) {
        self.fromSource = fromSource;
        self.appointModel = appointModel;
        self.needCheckFail = YES;
        self.keyBoardShow = NO;
        self.centerWidth = kCenterViewSizeWidth/2;
        self.centerHeight = kCenterViewSizeHeight/2;
        [self setSubViews];
        
    }
    return self;
}

- (void)setSubViews
{
    [self setBackgroundColor:[UIColor colorWithWhite:0.0f alpha:0.5f]];
    [self setTintColor:[UIColor clearColor]];
    
    if (self.appointModel.formWidth&&self.appointModel.formHeight&&self.appointModel.formWidth.longValue!=0&&self.appointModel.formHeight.longValue!=0) {
        self.centerWidth = [TTDeviceUIUtils tt_newPadding:self.appointModel.formWidth.integerValue]/2;
        self.centerHeight = [TTDeviceUIUtils tt_newPadding:self.appointModel.formHeight.integerValue]/2;
    }
    else
    {
        self.centerWidth = kCenterViewSizeWidth/2;
        self.centerHeight = kCenterViewSizeHeight/2;
    }
    NSInteger screenWidth = [UIScreen mainScreen].bounds.size.width;
    NSInteger screenHeight = [UIScreen mainScreen].bounds.size.height;
    
    if (self.appointModel.formSizeValid&&self.appointModel.formSizeValid.boolValue == YES) {
        NSInteger width = [TTDeviceUIUtils tt_newPadding:self.appointModel.formWidth.integerValue];
        NSInteger height = [TTDeviceUIUtils tt_newPadding:self.appointModel.formHeight.integerValue];
        CGFloat rate = (CGFloat)width/height;
        if (width < kCenterViewWidthMargin||width>screenWidth*2||height < kCenterViewHeightMargin||height>screenHeight*2) {
            self.centerWidth = kCenterViewSizeWidth/2;
            self.centerHeight = kCenterViewSizeHeight/2;
        }
        else if (rate<1/2&&rate>1)
        {
            self.centerWidth = kCenterViewSizeWidth/2;
            self.centerHeight = kCenterViewSizeHeight/2;
        }
    }
    
    self.centerView = [[SSThemedView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.centerWidth, self.centerHeight)];
    self.centerView.layer.cornerRadius = 12.0f;
    self.centerView.backgroundColorThemeKey = kColorBackground4;
    self.centerView.clipsToBounds = YES;
    self.centerView.center = self.center;
    [self addSubview:self.centerView];
    
    self.webview = [[SSJSBridgeWebView alloc] initWithFrame:self.centerView.bounds];
    [self.webview addDelegate:self];
    self.webview.scrollView.delegate = self;
    self.webview.scrollView.showsVerticalScrollIndicator = NO;
    self.webview.scrollView.scrollEnabled = NO;
    [self.centerView addSubview:self.webview];
    [SSWebViewUtil registerUserAgent:YES];
    
    self.request = [self formUrlRequest];
    [self.webview loadRequest:self.request];
    [TTAdMonitorManager beginTrackIntervalService:@"ad_form_load"];
    WeakSelf;
    [self.webview.ttr_staticPlugin registerHandlerBlock:^(NSDictionary *result, TTRJSBResponse callback) {
        StrongSelf;
        TTAdApointCompleteType submit_result =([result[@"submit_result"] boolValue] == 1)?TTAdApointCompleteTypeSubmitSuccess:TTAdApointCompleteTypeSubmitFail;
        if (submit_result == TTAdApointCompleteTypeSubmitSuccess) {
            [self hideWithBlock:^{
                StrongSelf;
                [self completeWithType:submit_result];
            }];
        }
        else if (submit_result == TTAdApointCompleteTypeSubmitFail)
        {
            [self completeWithType:submit_result];
        }
        TTR_CALLBACK_SUCCESS
    } forMethodName:@"formDialogClose"];
    
    
    [self.webview.ttr_staticPlugin registerHandlerBlock:^(NSDictionary *result, TTRJSBResponse callback) {
        StrongSelf;
        NSNumber *cid = [NSNumber numberWithDouble:[self.appointModel.ad_id doubleValue]];
        NSString *adLogExtra = !isEmptyString(self.appointModel.log_extra) ? self.appointModel.log_extra : @"";
        NSDictionary *dic = @{@"cid":cid,
                              @"log_extra":adLogExtra};
        if (callback) {
            callback(TTRJSBMsgSuccess, [dic copy]);
        }
    } forMethodName:@"adInfo"];
    
    [self.webview.ttr_staticPlugin registerHandlerBlock:^(NSDictionary *result, TTRJSBResponse callback) {
        StrongSelf;
        NSURL *url = [NSURL URLWithString:[result tt_stringValueForKey:@"coupon_addition_url"]];
        if ([[TTRoute sharedRoute] canOpenURL:url]) {
            [self cancelTouched];
            [[TTRoute sharedRoute] openURLByPushViewController:url];
        }
        TTR_CALLBACK_SUCCESS
    } forMethodName:@"useCoupon"];
    
    self.cancelButton = [[SSThemedButton alloc]init];
    [self.cancelButton addTarget:self action:@selector(cancelTouched) forControlEvents:UIControlEventTouchUpInside];
    [self.centerView addSubview:self.cancelButton];
    self.cancelButton.size = kCancelButtonSize;
    self.cancelButton.top = 0;
    self.cancelButton.right = self.centerView.width;
    
    self.cancelImageView = [[SSThemedImageView alloc]init];
    self.cancelImageView.imageName = @"popup_newclose";
    self.cancelImageView.enableNightCover = NO;
    self.cancelImageView.userInteractionEnabled = YES;
    [self.centerView addSubview:self.cancelImageView];
    [self.cancelImageView sizeToFit];
    self.cancelImageView.right = self.centerView.width - kImageViewPadding;
    self.cancelImageView.top = kImageViewPadding;
    
    UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cancelTouched)];
    [self.cancelImageView addGestureRecognizer:tap];
    
    self.loadingView = [[TTAdLoadingView alloc] init];
    [self.centerView addSubview:self.loadingView];
    [self.loadingView mas_makeConstraints:^(MASConstraintMaker *make) {
        StrongSelf;
        make.center.equalTo(self.centerView);
    }];
    self.loadingView.hidden = YES;
    
    self.retryView = [[TTAdRetryView alloc] initWithBlock:^{
        StrongSelf;
        self.retryView.hidden = YES;
        [self.webview loadRequest:self.request];
    }];
    
    [self.centerView addSubview:self.retryView];
    
    [self.retryView mas_makeConstraints:^(MASConstraintMaker *make) {
        StrongSelf;
        make.center.equalTo(self.centerView);
    }];
    self.retryView.hidden = YES;
    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(keyboardWillShow:) name: UIKeyboardWillShowNotification object:nil];
    [nc addObserver:self selector:@selector(keyboardWillHide:) name: UIKeyboardWillHideNotification object:nil];
    
}

- (NSURLRequest *)formUrlRequest
{
    if (!self.appointModel.formUrl || !self.appointModel.formUrl.length) {
        return nil;
    }
    NSMutableDictionary* params = [NSMutableDictionary dictionary];
    [params setValue:@"dialog" forKey:@"revealType"];
    BOOL isDayMode = [[TTThemeManager sharedInstance_tt] currentThemeMode] == TTThemeModeDay;
    [params setValue:isDayMode? @"1":@"0" forKey:@"dayMode"];
    
    NSString *urlString = [[TTAdAppointAlertView urlAppendParams:[self.appointModel.formUrl copy] params:params] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString] cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:5.0];
    return request;
}

- (void)completeWithType:(TTAdApointCompleteType)type
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(appointAlertViewCompleteType:)]) {
        [self.delegate appointAlertViewCompleteType:type];
    }
}


#pragma mark --WebviewDelegate

- (BOOL)webView:(YSWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(YSWebViewNavigationType)navigationType
{
    
    if(!TTNetworkConnected())
    {
        [self.loadingView stopAnimating];
        self.loadingView.hidden = YES;
        self.retryView.hidden = NO;
        [self.retryView netWorkFail];
        return NO;
    }
    if (self.needCheckFail == YES) {
        NSURLConnection* connection = [NSURLConnection connectionWithRequest:request delegate:self];
        if (connection) {
            self.loadingView.hidden = NO;
            [self.loadingView startAnimating];
            return NO;
        }
    }
    return YES;
}


- (void)webViewDidFinishLoad:(YSWebView *)webView
{
    [self.loadingView stopAnimating];
    self.loadingView.hidden = YES;
    [TTAdMonitorManager endTrackIntervalService:@"ad_form_load" extra:nil]; //调用多次
}


- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        NSInteger status = [httpResponse statusCode];
        
        BOOL shuldLoadWeb = YES;
        if (status >= 400) {
            shuldLoadWeb = NO;
            self.needCheckFail = YES;
            
            [self.loadingView stopAnimating];
            self.loadingView.hidden = YES;
            self.retryView.hidden = NO;
            [self completeWithType:TTAdApointCompleteTypeLoadFail];
        }
        else {
            [self completeWithType:TTAdApointCompleteTypeLoadSuccess];
            shuldLoadWeb = YES;
        }
        [connection cancel];
        
        if (shuldLoadWeb) {
            self.needCheckFail = NO;
            [self.webview loadRequest:self.request];
        }
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    LOGD(@"[TTAdAppointAlertView]connection:didFailWithError - %@", error);
    [self.loadingView stopAnimating];
    self.loadingView.hidden = YES;
    self.retryView.hidden = NO;
    [connection cancel];
    [self completeWithType:TTAdApointCompleteTypeLoadFail];
    
    NSMutableDictionary *extra = [NSMutableDictionary dictionaryWithCapacity:2];
    [extra setValue:error.localizedDescription forKey:@"error"];
    [TTAdMonitorManager trackService:@"ad_form_loadfail" status:1 extra:nil];
}


- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self.webview.scrollView setContentOffset:CGPointMake(0, 0) animated:NO];
}

#pragma mark -- Alert布局显示相关

- (void)layoutSubviews {
    [super layoutSubviews];
    self.frame = self.superview.bounds;
    [self doLayOut];
}

- (void)doLayOut
{
    CGFloat keyboardTop = self.frame.size.height - [TTKeyboardListener sharedInstance].keyboardHeight;
    CGPoint center = CGPointMake(self.frame.size.width/2.0f,  keyboardTop/2);
    _centerView.center = center;
    
    if (self.keyBoardShow == YES) {
        if ([TTDeviceHelper is480Screen]||[TTDeviceHelper is568Screen]||[TTDeviceHelper isPadDevice]) {
            _centerView.origin = CGPointMake(_centerView.origin.x, 20);
        }
    }
}

- (void)show
{
    UIWindow *window = nil;
    if ([[UIApplication sharedApplication].delegate respondsToSelector:@selector(window)]) {
        window = [UIApplication sharedApplication].delegate.window;
    }
    if (!window) {
        window = [UIApplication sharedApplication].keyWindow;
    }
    
    self.alpha = 0.0f;
    UIViewController *vc = window.rootViewController;
    while (vc.presentedViewController) {
        vc = vc.presentedViewController;
    }
    [vc.view addSubview:self];
    
    if ([[TTKeyboardListener sharedInstance] isVisible]) {
        CGFloat keyboardTop = self.frame.size.height - [TTKeyboardListener sharedInstance].keyboardHeight;
        CGPoint center = CGPointMake(_centerView.center.x,  keyboardTop/2);
        _centerView.center = center;
        
    }
    
    self.centerView.transform = CGAffineTransformMakeScale(0.9, 0.9);
    WeakSelf;
    [UIView animateWithDuration:0.13 animations:^{
        StrongSelf;
        self.alpha = 1.0f;
        self.centerView.transform = CGAffineTransformMakeScale(1.03, 1.03);
    } completion:^(BOOL finished) {
        
        [UIView animateWithDuration:0.07 animations:^{
            StrongSelf;
            self.centerView.transform = CGAffineTransformIdentity;
        } completion:^(BOOL finished) {
            
        }];
    }];
}

- (void)hideWithBlock:(TTAdApointHideBlock)block
{
    WeakSelf;
    [UIView animateWithDuration:0.1 animations:^{
        StrongSelf;
        self.alpha = 0.0f;
        self.centerView.transform = CGAffineTransformMakeScale(0.9, 0.9);
    } completion:^(BOOL finished) {
        StrongSelf;
        [self removeFromSuperview];
        if (block) {
            block();
        }
    }];
}

+ (NSString*)urlAppendParams:(NSString*)url params:(NSDictionary*)params
{
    NSString* totalUrl = nil;
    
    if ([url rangeOfString:@"?"].location != NSNotFound && ([url rangeOfString:@"?"].location + [url rangeOfString:@"?"].length == url.length)) {
        url = [url stringByReplacingOccurrencesOfString:@"?" withString:@""];
    }
    
    NSMutableString* appendStr = [[NSMutableString alloc] init];
    [params enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        NSString* realKey = (NSString*)key;
        NSString* realObj = (NSString*)obj;
        if (!isEmptyString(realKey)&&!isEmptyString(realObj)) {
            [appendStr appendFormat:@"%@=%@&", realKey, realObj];
        }
    }];
    
    NSRange range = NSMakeRange(appendStr.length-1, 1);
    NSString* lastStr = [appendStr substringWithRange:range];
    if (!isEmptyString(lastStr)&&[lastStr isEqualToString:@"&"]) {
        [appendStr deleteCharactersInRange:range];
    }
    
    if ([url rangeOfString:@"?"].location == NSNotFound) {
        totalUrl = [NSString stringWithFormat:
                    @"%@?%@", url, appendStr];
    } else {
        totalUrl = [NSString stringWithFormat:
                    @"%@&%@", url, appendStr];
    }
    
    totalUrl = [totalUrl stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    return [totalUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}


#pragma mark  keyboard observer

- (void)keyboardWillShow:(NSNotification *)notification
{
    self.keyBoardShow = YES;
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.25f];
    _centerView.origin = CGPointMake(_centerView.origin.x, 20);
    [UIView commitAnimations];
}


- (void)keyboardWillHide:(NSNotification *)notification
{
    self.keyBoardShow = NO;
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.25f];
    _centerView.center = self.center;
    [UIView commitAnimations];
    
}

#pragma mark --TTGuideProtocol

- (TTGuidePriority)priority {
    return kTTGuidePriorityHigh;
}

- (BOOL)shouldDisplay:(id)context {
    
    return YES;
}

- (void)showWithContext:(id)context {
    [self show];
}

- (id)context {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setContext:(id)context {
    objc_setAssociatedObject(self, @selector(context), context, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)cancelTouched
{
    [self.webview endEditing:YES];
    WeakSelf;
    [self hideWithBlock:^{
        StrongSelf;
        [self completeWithType:TTAdApointCompleteTypeCloseForm];
        [[NSNotificationCenter defaultCenter] postNotificationName:TTAdAppointAlertViewCloseKey object:nil];
    }];
    
}


- (void)dealloc
{
    [self.webview removeDelegate:self];
    self.webview.scrollView.delegate = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


@end

@interface TTAdFormHandler ()<TTAdAppointDelegate>

@property (nonatomic, strong) TTAdAppointAlertView* alertView;

@end

@implementation TTAdFormHandler

+ (void)load {
    [[TTModuleBridge sharedInstance_tt] registerAction:@"TTAd_action_form" withBlock:^id _Nullable(id  _Nullable object, NSDictionary  * _Nullable params) {
        
        TTAdAppointAlertModel *model = [TTAdAppointAlertModel new];
        model.ad_id = params[@"ad_id"];
        model.log_extra = params[@"log_extra"];
        model.formUrl = params[@"form_url"];
        model.formWidth = params[@"form_width"];
        model.formHeight = params[@"form_height"];
        model.formSizeValid = params[@"use_size_validation"];
        TTAdApointCompleteBlock completeBlock = params[@"completeBlock"];
        BOOL result = [[self sharedInstance] handleFormModel:model fromSource:TTAdApointFromSourceDetail completeBlock:completeBlock];
        return @(result);
    }];
}

+ (instancetype)sharedInstance{
    static TTAdFormHandler *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[self alloc] init];
        
    });
    return _sharedInstance;
}

- (BOOL)handleFormModel:(id<TTAdFormAction>)model fromSource:(TTAdApointFromSource)fromSource completeBlock:(TTAdApointCompleteBlock)block
{
    if (!block || isEmptyString(model.formUrl)) {
        return NO;
    }
    self.completeBlock = block;
    self.alertView = [[TTAdAppointAlertView alloc] initWithModel:model fromSource:fromSource];
    self.alertView.delegate = self;
    [[TTGuideDispatchManager sharedInstance_tt] addGuideViewItem:self.alertView withContext:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:TTAdAppointAlertViewShowKey object:nil];
    return YES;
}

- (void)appointAlertViewCompleteType:(TTAdApointCompleteType)type
{
    switch (type) {
            case TTAdApointCompleteTypeSubmitSuccess:
        {
            [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:@"提交成功" indicatorImage:[UIImage themedImageNamed:@"doneicon_popup_textpage.png"] autoDismiss:YES dismissHandler:nil];
            [[TTGuideDispatchManager sharedInstance_tt] removeGuideViewItem:self.alertView];
            self.alertView = nil;
            [[NSNotificationCenter defaultCenter] postNotificationName:TTAdAppointAlertViewCloseKey object:nil];
        }
            break;
            case TTAdApointCompleteTypeSubmitFail:
        {
            //失败不做处理
        }
            break;
            case TTAdApointCompleteTypeCloseForm:
        {
            [[TTGuideDispatchManager sharedInstance_tt] removeGuideViewItem:self.alertView];
            self.alertView = nil;
        }
            break;
            case TTAdApointCompleteTypeLoadFail:
        {
            
        }
            break;
        case TTAdApointCompleteTypeLoadSuccess:
        {
            
        }
            break;
        default:
            break;
    }
    if (self.completeBlock) {
        self.completeBlock(type);
    }
}

@end

@implementation TTAdAppointAlertModel

- (instancetype)initWithFormUrl:(NSString *)url width:(NSNumber *)width height:(NSNumber *)height sizeValid:(NSNumber *)sizeValid
{
    return [self initWithAdId:nil logExtra:nil formUrl:url width:width height:height sizeValid:sizeValid];
}

- (instancetype)initWithAdId:(NSString *)ad_id logExtra:(NSString *)log_extra formUrl:(NSString *)url width:(NSNumber *)width height:(NSNumber *)height sizeValid:(NSNumber *)sizeValid
{
    if (self = [super init]) {
        self.ad_id = ad_id;
        self.log_extra = log_extra;
        self.formUrl = url;
        self.formWidth = width;
        self.formHeight = height;
        self.formSizeValid = sizeValid;
    }
    return self;
}

@end
