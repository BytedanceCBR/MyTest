
//
//  SSJSBridgeWebView.m
//  Article
//
//  Created by Dianwei on 14-10-11.
//
//

#import "SSJSBridgeWebView.h"
#import "SSJSBridgeWebViewDelegate.h"
#import "TTJSBAuthManager.h"
#import "TTPlatformSwitcher.h"
#import "SSWebViewUtil.h"

#import <TTRoute/TTRoute.h>
#import <TTThemed/SSThemed.h>
#import <TTThemed/TTThemeManager.h>
#import <TTBaseLib/NSStringAdditions.h>
#import <TTBaseLib/SSWeakObject.h>
#import <TTBaseLib/TTStringHelper.h>
#import <TTBaseLib/TTUIResponderHelper.h>
#import <TTBaseLib/NSString+URLEncoding.h>
#import <TTBaseLib/NSDictionary+TTAdditions.h>
#import <TTRexxar/TTRWebViewApplication.h>
#import <TTRexxar/TTRJSBForwarding.h>
#import <TTRexxar/TTRexxarNotificationCenter.h>
#import <TTTracker/TTTracker.h>
#import <TTUsersettings/TTUserSettingsManager+FontSettings.h>
#import <TTPlatformBaseLib/TTTrackerWrapper.h>

static NSString *const kHasMessageHost = @"dispatch_message";
static NSString *const kJSBridgeScheme = @"bytedance";

NSString *const TTWebViewDidBlockRequestNotification = @"WebViewDidBlockRequest";
NSString *const TTWebViewRequestKey = @"request";

@interface SSJSBridgeWebView()<YSWebViewDelegate>
@property(nonatomic, strong)SSJSBridgeWebViewDelegate *jsBridgeDelegate;
@property(nonatomic, strong)UIView *themedMaskView;
@property(nonatomic, readwrite)BOOL isDomReady;
@property(nonatomic, assign) BOOL isVisible;
@property(nonatomic, strong) NSMutableArray<NSDictionary *> *historyTracker;
@end

@implementation SSJSBridgeWebView
@synthesize ttr_staticPlugin = _ttr_staticPlugin, ttr_authorization = _ttr_authorization;

+ (void)initialize
{
    if (self == [SSJSBridgeWebView self]) {
        [SSWebViewUtil registerUserAgent:YES];
    }
}

- (void)dealloc
{
//    CLS_LOG(@"dealloc");
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    if (_historyTracker.count) {
        [TTTracker eventV3:@"webview_history_tracker" params:({
            NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
            [params setValue:[_historyTracker copy] forKey:@"pages"];
            [params copy];
        })];
    }
}

- (instancetype)initWithFrame:(CGRect)frame
{
    return [self initWithFrame:frame disableWKWebView:NO];
}

- (instancetype)initWithFrame:(CGRect)frame disableWKWebView:(BOOL)disableWKWebView
{
//    NSTimeInterval startTime = [[NSDate date] timeIntervalSince1970];
    self = [super initWithFrame:frame disableWKWebView:disableWKWebView];
//    CLS_LOG(@"disableWKWebView");
//    NSLog(@"initOfNormalWebView cost time %.2f", [[NSDate date] timeIntervalSince1970] - startTime);
    if(self) {
        [self ssJSBridgeWebViewCommonInit];
    }
    
    return self;
}

- (nullable instancetype)initWithFrame:(CGRect)frame disableWKWebView:(BOOL)disableWKWebView ignoreGlobalSwitchKey:(BOOL)ignore {

    self = [super initWithFrame:frame disableWKWebView:disableWKWebView ignoreGlobalSwitchKey:ignore];
//    CLS_LOG(@"disableWKWebView");
    if (self) {
        [self ssJSBridgeWebViewCommonInit];
    }
    return self;
}

- (void)ssJSBridgeWebViewCommonInit {
    [[TTRexxarNotificationCenter defaultCenter] addEngine:self];
    self.ttr_staticPlugin = [[TTRStaticPlugin alloc] init];
    self.jsBridgeDelegate = [SSJSBridgeWebViewDelegate JSBridgeWebViewDelegateWithMainDelegate:self];
    self.ttr_authorization = [TTJSBAuthManager sharedManager];
    self.delegate = _jsBridgeDelegate;
    [self refreshBackgroundColor];
    self.themedMaskView = [[UIView alloc] initWithFrame:self.bounds];
    self.themedMaskView.userInteractionEnabled = NO;
    self.themedMaskView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.themedMaskView.backgroundColor = [UIColor blackColor];
    self.themedMaskView.alpha = 0;
    self.historyTracker = [[NSMutableArray alloc] init];
    [self addSubview:self.themedMaskView];
    [self registerDayAndFontNotification];
    [self themeChanged:nil];
    self.shouldInterceptUrls = YES;
}

- (void)addDelegate:(NSObject<YSWebViewDelegate> *)delegate {
    if (!self.delegate) {//修正一下MainDelegate 确保不为空 @zengruihuan
        self.delegate = self.jsBridgeDelegate;
    }
    __block SSWeakObject *object;
    [_jsBridgeDelegate.delegates enumerateObjectsUsingBlock:^(SSWeakObject * obj, NSUInteger idx, BOOL *stop) {
        if ([obj.content isEqual:delegate]) {
            object = obj;
            *stop = YES;
        }
    }];
    if (!object) {
        object = [SSWeakObject weakObjectWithContent:delegate];
        [_jsBridgeDelegate.delegates addObject:object];
    }
}

- (void)removeDelegate:(NSObject<YSWebViewDelegate> *) delegate {
    __block SSWeakObject *object;
    [_jsBridgeDelegate.delegates enumerateObjectsUsingBlock:^(SSWeakObject * obj, NSUInteger idx, BOOL *stop) {
        if ([obj.content isEqual:delegate]) {
            object = obj;
            *stop = YES;
        }
    }];
    if (object) {
        [_jsBridgeDelegate.delegates removeObject:object];
    }
}

- (void)removeAllDelegates {
    [_jsBridgeDelegate.delegates removeAllObjects];
}

- (void)loadRequest:(NSURLRequest *)request appendBizParams:(BOOL)append {
    NSString *url = request.URL.absoluteString;
    if (append) {
        url = [self _handleDayNightModeWithURL:request.URL];
    }
    NSMutableURLRequest *mutabRequest = [request mutableCopy];
    mutabRequest.URL = [NSURL URLWithString:url];
    
    [super loadRequest:mutabRequest.URL? [mutabRequest copy]: request];
}

- (BOOL)webView:(nullable YSWebView *)webView shouldStartLoadWithRequest:(nullable NSURLRequest *)request navigationType:(YSWebViewNavigationType)navigationType
{
    BOOL result = YES;
    NSURL *URL = request.URL;
    NSString *host = [URL.host copy];
    if ([URL.scheme isEqualToString:@"bytedance"] &&
        ([host isEqualToString:@"custom_event"] ||
         [host isEqualToString:@"log_event"] || [host isEqualToString:@"log_event_v3"])) {
            // 发送统计事件的拦截
            if ([host isEqualToString:@"log_event_v3"]) {
                //applog 3.0
                [self sendV3TrackDataFromQuery:URL.query];
                return NO;
            }
            [self sendTrackDataFromURLString:URL.query];
            return NO;
        }
    
    // domReady
    if ([URL.scheme isEqualToString:@"bytedance"] && [URL.host isEqualToString:@"domReady"]) {
        self.isDomReady = YES;
    }
    
    // 夜间模式去掉蒙层
    if ([URL.scheme isEqualToString:@"bytedance"] && [URL.host isEqualToString:@"disable_overlay"]) {
        self.disableThemedMask = YES;
        return NO;
    }
    
    //为特卖做一个蛋疼的兼容
    if ([URL.scheme isEqualToString:@"bytedance"] &&
        [URL.host isEqualToString:@"temai_goods_event"]) {
        [self forwardTemaiTracker:URL.query];
        return NO;
    }
    if ([request.URL.scheme isEqualToString:@"sslocal"] || [request.URL.scheme hasPrefix:@"interestingnews1206"] || [request.URL.scheme hasPrefix:@"fschema"]) {
        
        [[TTRoute sharedRoute] openURLByViewController:URL userInfo:nil];
        
        return NO;
    }
    // bridge logic
    if([request.URL.scheme isEqualToString:kJSBridgeScheme])
    {
        if([request.URL.host isEqualToString:kHasMessageHost])
        {
            
            [TTRWebViewApplication handleRequest:request withWebView:(UIView<TTRWebView> *)self viewController:nil];
            return NO;
        }
    }
    
    //拦截 跳转
    if (self.shouldInterceptUrls) {
        NSArray * ary = [[NSUserDefaults standardUserDefaults] objectForKey:@"KInterceptURLsKey"];
        for (NSString * url in ary) {
            if ([request.URL.absoluteString.lowercaseString hasPrefix:url]) {
                [[NSNotificationCenter defaultCenter] postNotificationName:TTWebViewDidBlockRequestNotification
                                                                    object:self
                                                                  userInfo:@{TTWebViewRequestKey:request}];
                return NO;
            }
        }
    }
    
    for(SSWeakObject *obj in _jsBridgeDelegate.delegates) {
        NSObject<YSWebViewDelegate> *target = (NSObject<YSWebViewDelegate> *)obj.content;
        if([target respondsToSelector:@selector(webView:shouldStartLoadWithRequest:navigationType:)]) {
            result = [target webView:webView shouldStartLoadWithRequest:request navigationType:navigationType];
            if (!result) {
                break;
            }
            
        }
    };
    
    if (result) {
        [self trackWithURL:request.URL navigationType:navigationType];
    }
    return result;
}

- (void)webViewDidFinishLoad:(YSWebView *)webView {
    self.isDomReady = YES;
    //日夜间切换JS
    BOOL isDayModel = [[TTThemeManager sharedInstance_tt] currentThemeMode] == TTThemeModeDay;
    [self stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@";window.TouTiao && window.TouTiao.setDayMode && TouTiao.setDayMode(%d);", isDayModel] completionHandler:nil];
}

- (void)didMoveToWindow {
    [super didMoveToWindow];
    NS_VALID_UNTIL_END_OF_SCOPE __strong typeof(self) strongSelf = self;
    [NSObject cancelPreviousPerformRequestsWithTarget:strongSelf];
    [strongSelf performSelector:@selector(notifyVisible) withObject:nil afterDelay:.3f];
}

- (void)notifyVisible
{
    if (self.useCustomVisibleEvent) return;
    self.isVisible = !!self.window;
}

- (void)invokeVisibleEvent {
    //NSLog(@"---#%p visible", self);
    [self ttr_fireEvent:@"visible" data:@{@"code": @1}];
}

- (void)invokeInvisibleEvent {
    //NSLog(@"---#%p invisible", self);
    [self ttr_fireEvent:@"invisible" data:@{@"code": @1}];
}

- (void)sendTrackDataFromURLString:(NSString *)queryStr {
    NSMutableDictionary *parameters = [[TTStringHelper parametersOfURLString:queryStr] mutableCopy];
    if (![parameters valueForKey:@"category"]) {
        [parameters setValue:@"umeng" forKey:@"category"];
    }
    
    NSString *extraString = [parameters tt_stringValueForKey:@"extra"];
    
    if (!isEmptyString(extraString)) {
        extraString = [extraString URLDecodedString];
        
        NSError *error = nil;
        NSDictionary *dict = [extraString JSONValue];
        if (!error && [dict isKindOfClass:[NSDictionary class]]) {
            [parameters setValue:nil forKey:@"extra"];
            [parameters addEntriesFromDictionary:dict];
        }
    }
    //添加单独为广告加的convert事件实时发送逻辑,新增标识实时事件字段:realtime_report
    if ([[parameters valueForKey:@"realtime_report"] intValue] == 1) {
        [parameters setValue:nil forKey:@"realtime_report"];
        [TTTracker eventV3:@"realtime_report" params:parameters];
    }
    else{
        [TTTracker eventData:parameters];
    }
}

- (void)sendV3TrackDataFromQuery:(NSString *)query {
    NSMutableDictionary *parameters = [[TTStringHelper parametersOfURLString:query] mutableCopy];
    
    NSString *eventName = [[parameters tt_stringValueForKey:@"event"] URLDecodedString];
    NSDictionary *params = [[[parameters tt_stringValueForKey:@"params"] URLDecodedString] JSONValue];
    BOOL isDoubleSending = [parameters tt_boolValueForKey:@"is_double_sending"];
    [TTTrackerWrapper eventV3:eventName params:params isDoubleSending:isDoubleSending];
}

#pragma mark - day & font
- (void)registerDayAndFontNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(themeChanged:) name:TTThemeManagerThemeModeChangedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fontChanged:) name:kSettingFontSizeChangedNotification object:nil];
}

- (void)themeChanged:(NSNotification*)notification
{
    [self refreshBackgroundColor];
    
    BOOL isDayModel = [[TTThemeManager sharedInstance_tt] currentThemeMode] == TTThemeModeDay;
    [self stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"window.TouTiao && TouTiao.setDayMode(%d)", isDayModel] completionHandler:nil];
    self.themedMaskView.alpha = isDayModel? 0.f: 0.5f;
}

- (void)refreshBackgroundColor
{
    NSString *colorThemeKey = [NSString stringWithFormat:@"Background%lu", self.colorKey];
    if ([UIColor tt_themedColorForKey:colorThemeKey]) {
        self.backgroundColor = [UIColor tt_themedColorForKey:colorThemeKey];
    } else {
        if (self.disableNightBackground) {
            self.backgroundColor = [UIColor whiteColor];
        } else {
            self.backgroundColor = [UIColor tt_themedColorForKey:kColorBackground4];
        }
    }
}

- (void)fontChanged:(NSNotification*)notification
{
    NSString *fontSizeType = [TTUserSettingsManager settingFontSizeString];
    [self stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"window.TouTiao && TouTiao.setFontSize(\"%@\")", fontSizeType] completionHandler:nil];
}

//处理日夜间
- (NSString *)_handleDayNightModeWithURL:(NSURL *)origURL {
    //5.9.7 紧急发版.. 不处理阳光视频.
    if ([origURL.host isEqualToString:@"m.365yg.com"] || [origURL.host isEqualToString:@"www.365yg.com"]) {
        return origURL.absoluteString;
    }
    NSString *urlString = nil;
    BOOL isDayModel = [[TTThemeManager sharedInstance_tt] currentThemeMode] == TTThemeModeDay;
    NSString *fontSizeType = [TTUserSettingsManager settingFontSizeString];
    
    urlString = [SSWebViewUtil jointFragmentParamsDict:@{@"tt_daymode": isDayModel? @"1": @"0",
                                                         @"tt_font": fontSizeType} toURL:origURL.absoluteString];
    
    return urlString;
}

- (void)forwardTemaiTracker:(NSString *)query {
    TTRJSBCommand *temaiCmd = [[TTRJSBCommand alloc] init];
    temaiCmd.fullName = @"TTRAd.temaiEvent";
    temaiCmd.params = ({
        NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
        [param setValue:query forKey:@"query"];
        [param copy];
    });
    
    [[TTRJSBForwarding sharedInstance] forwardJSBWithCommand:temaiCmd engine:self completion:nil];;
}

- (void)trackWithURL:(NSURL *)url navigationType:(YSWebViewNavigationType)navigationType {
    if (!url) {
        return;
    }
    
    if ([url.absoluteString isEqualToString:@"about:blank"]) {
        return;
    }
    
    if ([url.scheme isEqualToString:@"file"]) {
        return;
    }
    
    NSMutableDictionary *page = [[NSMutableDictionary alloc] init];
    [page setValue:url.absoluteString forKey:@"url"];
    [page setValue:navigationType == YSWebViewNavigationTypeLinkClicked? @"1": @"0" forKey:@"jump_type"];
    [page setValue:[NSString stringWithFormat:@"%.0f", [[NSDate date] timeIntervalSince1970] * 1000] forKey:@"timestamp"];
    [self.historyTracker addObject:[page copy]];
}

#pragma mark - TTRexxarEngine
- (UIViewController *)ttr_sourceController {
    return [TTUIResponderHelper topViewControllerFor:self];
}

- (NSURL *)ttr_url {
    if ([((NSObject *)self.tt_webViewInUse) isKindOfClass:[UIWebView class]]) {
        return ((UIWebView *)self.tt_webViewInUse).request.URL;
    }
    
    if ([((NSObject *)self.tt_webViewInUse) isKindOfClass:[WKWebView class]]) {
        return ((WKWebView *)self.tt_webViewInUse).URL;
    }
    
    return self.currentURL;
}
- (void)ttr_evaluateJavaScript:(NSString *)javaScriptString completionHandler:(void (^)(id, NSError *))completionHandler {
    [self evaluateJavaScriptFromString:javaScriptString completionBlock:completionHandler];
}

- (void)ttr_fireEvent:(NSString *)event data:(NSDictionary *)data {
    [TTRWebViewApplication fireEvent:event data:data withWebView:(UIView<TTRWebView> *)self];
    [self evaluateJavaScriptFromString:[NSString stringWithFormat:@"window.onNotificationReceived && onNotificationReceived(\"%@\", %@)", event, [data JSONRepresentation]? :@"{}"] completionBlock:nil];
}

- (void)setDisableThemedMask:(BOOL)disableThemedMask {
    _disableThemedMask = disableThemedMask;
    self.themedMaskView.hidden = disableThemedMask;
}

- (void)setColorKey:(NSInteger)colorKey
{
    _colorKey = colorKey;
    [self refreshBackgroundColor];
}

- (void)setDisableNightBackground:(BOOL)disableNightBackground
{
    _disableNightBackground = disableNightBackground;
    if (_disableNightBackground) {
        self.backgroundColor = [UIColor whiteColor];
    }
}

- (void)weakReload
{
    // 不改变_isVisible标记
    [self ttr_fireEvent:@"visible" data:@{@"code": @1}];
}

- (void)setIsVisible:(BOOL)isVisible {
    if (_isVisible == isVisible) {
        return;
    }
    _isVisible = isVisible;
    NSLog(@"---#%p visible:%i", self, isVisible);
    [self ttr_fireEvent:isVisible? @"visible": @"invisible" data:@{@"code": @1}];
}
@end
