//
//  YSWebView.m
//
//  Created by Bogdan Hapca on 07/01/15.
//  Copyright (c) 2015 Yardi. All rights reserved.
//

#import "YSWebView.h"
#import "TTHttpsControlManager.h"
#import "TTMonitor.h"
#import "WKNavigation+TTAdditions.h"
#import "TTURLUtils.h"
#import <TTRexxar/TTRWKWebView.h>
#import <TTNetworkUtilities.h>
#import <Masonry/Masonry.h>

#define DESTROY_UIWEBVIEW_ARC(__WEBVIEW)   { __WEBVIEW.delegate = nil; [__WEBVIEW stopLoading]; __WEBVIEW = nil; }
#define DESTROY_WKWEBVIEW_ARC(__WEBVIEW)   { __WEBVIEW.navigationDelegate = nil; __WEBVIEW.scrollView.delegate = nil; [__WEBVIEW stopLoading]; __WEBVIEW = nil; }
#ifndef dispatch_main_async_safe
#define dispatch_main_async_safe(block)\
    if (strcmp(dispatch_queue_get_label(DISPATCH_CURRENT_QUEUE_LABEL), dispatch_queue_get_label(dispatch_get_main_queue())) == 0) {\
        block();\
    } else {\
        dispatch_async(dispatch_get_main_queue(), block);\
    }
#endif

YSWebViewNavigationType mapWKNavigationTypeToYSWebViewNavigationType(WKNavigationType navigationType);
YSWebViewNavigationType mapUIWebViewNavigationTypeToYSWebViewNavigationType(UIWebViewNavigationType navigationType);


@interface TTUIWebView : UIWebView
@property (nonatomic, assign) BOOL overridecanBecomeFirstResponder;
@end

@implementation TTUIWebView


- (BOOL)canBecomeFirstResponder {
    if(self.overridecanBecomeFirstResponder)
        return YES;
    else
        return [super canBecomeFirstResponder];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if ([self.delegate respondsToSelector:@selector(webviewDidLayoutSubviews:)]) {
        [self.delegate performSelector:@selector(webviewDidLayoutSubviews:) withObject:self];
    }
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {
    if (action == @selector(copy:) || action == @selector(selectAll:)) {
        return YES;
    }
//    return [super canPerformAction:action withSender:sender];
    return NO;
}

@end

@interface TTWKWebView : TTRWKWebView
@property (nonatomic, assign) BOOL overridecanBecomeFirstResponder;
@end

@implementation TTWKWebView

- (BOOL)canBecomeFirstResponder {
    if(self.overridecanBecomeFirstResponder)
        return YES;
    else
        return [super canBecomeFirstResponder];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if ([self.navigationDelegate respondsToSelector:@selector(webviewDidLayoutSubviews:)]) {
        [self.navigationDelegate performSelector:@selector(webviewDidLayoutSubviews:) withObject:self];
    }
}

@end

@interface YSWebView () <WKScriptMessageHandler>

@property (nonatomic, strong) TTUIWebView *webView;
@property (nonatomic, strong) TTWKWebView *webViewWK;
@property (nonatomic, strong) NSTimer *guardTimer;
@property (nullable, nonatomic, readwrite, strong) NSURLRequest *request;
@property (nullable, nonatomic, readwrite, strong) NSURL *currentURL;
@property (nonatomic, strong) NSURLRequest *origRequest;
@property (nonatomic, strong) YSInnerWebViewDelegate *innerWebViewDelegate;
@property (nonatomic, copy, nullable) WebViewLogHandler logHandler;
@property (nonatomic, assign) BOOL disableWKWebView;

@end


@implementation YSWebView

@synthesize scalesPageToFit = _scalesPageToFit;

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self doInit:NO];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        [self doInit:NO];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame disableWKWebView:(BOOL)disableWKWebView {
    self = [super initWithFrame:frame];
    if (self) {
        
        self.disableWKWebView = disableWKWebView;
        [self doInit:NO];
    }
    return self;
}

- (nullable instancetype)initWithFrame:(CGRect)frame disableWKWebView:(BOOL)disableWKWebView ignoreGlobalSwitchKey:(BOOL)ignore {
    self = [super initWithFrame:frame];
    if (self) {
        self.disableWKWebView = disableWKWebView;
        [self doInit:ignore];
    }
    return self;
}

- (void)doInit:(BOOL)ignoreWKSwitchKey {
    
    //文档说 默认的isAccessibilityElement 是YES，但是实际不是
    self.isAccessibilityElement = YES;

    self.innerWebViewDelegate = [[YSInnerWebViewDelegate alloc] init];
    self.innerWebViewDelegate.ysWebView = self;
    __weak __typeof(self)weakSelf = self;
    self.logHandler = ^(NSString * _Nullable msg) {
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:msg]];
        
        if (!request.URL) {
            return;
        }
        dispatch_main_async_safe(^{
            if (!strongSelf) {
                return;
            }
            [strongSelf.delegate webView:strongSelf shouldStartLoadWithRequest:request navigationType:YSWebViewNavigationTypeOther];
        });
        
    };
    BOOL supportWKWebView = [[NSUserDefaults standardUserDefaults] boolForKey:@"kWKWebViewSettingSwitchKey"] || ignoreWKSwitchKey;
    if ((NSClassFromString(@"WKWebView") == nil || !supportWKWebView || self.disableWKWebView)) {
        _webView = [[TTUIWebView alloc] initWithFrame:self.bounds];
        _webView.delegate = self.innerWebViewDelegate;
        _webView.allowsInlineMediaPlayback = YES;
        _webView.mediaPlaybackRequiresUserAction = NO;
        _webView.dataDetectorTypes = UIDataDetectorTypeNone;
        _webView.opaque = NO;
        
        [self addSubview:_webView];
        [_webView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
    } else {
        [self configureWKWebView];
    }
}

- (void)configureWKWebView {
    _webViewWK = [[TTWKWebView alloc] initSharedConfigurationViewWithFrame:self.bounds];
    _webViewWK.configuration.allowsInlineMediaPlayback = YES;
    _webViewWK.configuration.mediaPlaybackRequiresUserAction = NO;
    _webViewWK.navigationDelegate = self.innerWebViewDelegate;
    _webViewWK.opaque = NO;
    [self addSubview:_webViewWK];
    [_webViewWK mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
}

- (void)didMoveToSuperview {
    if (self.superview) {
        [self tt_registerScriptMessageHandler];
    } else {
        [self tt_removeScriptMessageHandler];
    }
}

- (void)tt_registerScriptMessageHandler {
//    [_webViewWK.configuration.userContentController addScriptMessageHandler:self name:@"observe"];
}

- (void)tt_removeScriptMessageHandler {
//    [_webViewWK.configuration.userContentController removeScriptMessageHandlerForName:@"observe"];
}

- (void)tt_becomeFirstResponder {
    
    _webViewWK.overridecanBecomeFirstResponder = YES;
    _webView.overridecanBecomeFirstResponder = YES;
    [_webViewWK becomeFirstResponder];
    [_webView becomeFirstResponder];
}


- (BOOL)isWKWebView {
    
    return _webViewWK ? YES : NO;
}


- (void)dealloc {
    DESTROY_UIWEBVIEW_ARC(_webView);
    DESTROY_WKWEBVIEW_ARC(_webViewWK);
}

+ (BOOL)requiresConstraintBasedLayout {
    return YES;
}

- (UIScrollView*)scrollView {
    if (self.webView) {
        return self.webView.scrollView;
    } else {
        NSAssert(self.webViewWK, @"sanity check");
        return self.webViewWK.scrollView;
    }
}

- (id)innerWebView {
    if (self.webView) {
        return self.webView;
    } else {
        return self.webViewWK;
    }
}

- (id)tt_webViewInUse
{
    return [self innerWebView];
}

- (void)loadRequest:(NSURLRequest *)request {
    [self loadRequest:request shouldTransferedHttps:YES shouldAppendQuery:YES];
}

- (void)loadRequest:(NSURLRequest *)request shouldTransferedHttps:(BOOL)shouldTransfered shouldAppendQuery:(BOOL)shouldAppendQuery {
//    CLS_LOG(@"URL:%@", request.URL.absoluteString);
    self.origRequest = [request copy];
    NSURLRequest *realRequest = request;
    
    if (shouldAppendQuery && [self.class shouldAppendQueryStirngWithUrl:[request URL]]) {
        realRequest = [YSWebView custRequestWithRequst:request];
    }
    
    BOOL hasTransferedHttps = [self _hasMarkedTransfer:realRequest.URL];
    BOOL isHttpsRequest = [self _isHttpsURL:self.origRequest.URL];
    
    if (shouldTransfered && [[[NSUserDefaults standardUserDefaults] objectForKey:@"SSCommonLogicSettingWebViewHttpsSwitchKey"] boolValue] && !hasTransferedHttps && !isHttpsRequest) {
        realRequest = [NSURLRequest requestWithURL:[[TTHttpsControlManager sharedInstance_tt] transferedURLFrom:realRequest.URL]];
        if ([self _isHttpsURL:realRequest.URL]) { //transfer成功后再打标
            realRequest = [self _markHadTransferIfNeed:realRequest];
        }
    }
    
    [self.webView loadRequest:realRequest];
    [self.webViewWK ttr_loadRequest:realRequest];
    self.request = realRequest;
    
    if ([self _isHttpsURL:realRequest.URL]) {
        //didFinish有可能会被调用多次. 所以只能在load时打点 @zengruihuan
        [[TTMonitor shareManager] trackService:@"webview_https_total" status:1 extra:nil];
    }
}

- (void)loadRequest:(NSURLRequest *)request timeOut:(NSTimeInterval)timeOut {
    
    [self loadRequest:request];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.guardTimer invalidate];
        self.guardTimer = [NSTimer scheduledTimerWithTimeInterval:timeOut target:self selector:@selector(guardTimerExceeded:) userInfo:nil repeats:NO];
    });
}

- (void)loadFileURL:(NSURL *)URL allowingReadAccessToURL:(NSURL *)readAccessURL {
    [self.webViewWK loadFileURL:URL allowingReadAccessToURL:readAccessURL];
}

- (void)stopLoading {
    [self.webView stopLoading];
    [self.webViewWK stopLoading];
}

- (void)loadHTMLString:(NSString *)string baseURL:(NSURL *)baseURL {
    if (!string) {
        string = @"";
    }
//    CLS_LOG(@"baseURL:%@", baseURL.absoluteString);
    [self.webView loadHTMLString:string baseURL:baseURL];
    [self.webViewWK loadHTMLString:string baseURL:baseURL];
}

- (void)loadHTMLString:(NSString *)string baseURL:(NSURL *)baseURL timeOut:(NSTimeInterval)timeOut {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.guardTimer invalidate];
        self.guardTimer = [NSTimer scheduledTimerWithTimeInterval:timeOut target:self selector:@selector(guardTimerExceeded:) userInfo:nil repeats:NO];
    });
    if (!string) {
        string = @"";
    }
    [self loadHTMLString:string baseURL:baseURL];
}

- (void)guardTimerExceeded:(NSTimer*)timer {
    NSAssert(timer == self.guardTimer, @"sanity check");
    [self stopLoading];
    [self handleError:[NSError errorWithDomain:NSURLErrorDomain code:kCFURLErrorTimedOut userInfo:nil]];
}

- (void)evaluateJavaScriptFromString:(NSString *)script completionBlock:(JavaScriptCompletionBlock)block {
    if (self.webView) {
        NSString *jsResult = [self.webView stringByEvaluatingJavaScriptFromString:script];
        if (block) {
            block(jsResult, nil);
        }
    } else {
        NSAssert(self.webViewWK, @"sanity check");
        [self.webViewWK evaluateJavaScript:script completionHandler:^(id result, NSError *error) {
            NSString *jsResult = nil;
            if (!error) {
                if ([result isKindOfClass:[NSString class]]) {
                    jsResult = result;
                } else {
                    jsResult = [NSString stringWithFormat:@"%@", result];
                }
            } else {
                NSLog(@"%@", error);
            }
            if (block) {
                block(jsResult, error);
            }
        }];
    }
}

- (NSString *)stringByEvaluatingJavaScriptFromString:(NSString *)javaScriptString completionHandler:(void (^ __nullable)(__nullable id instance, NSError * __nullable error))completionHandler
{
    if (isEmptyString(javaScriptString)) {
        if (completionHandler) {
            completionHandler(nil, nil);
        }
        return nil;
    }
    
    if(self.webView)
    {
    //前后加;;保护 @zengruihuan
        NSString* result = [self.webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@";%@;", javaScriptString]];
        if (completionHandler) {
            completionHandler(result,nil);
        }
        return result;
    }
    else if (self.webViewWK)
    {
        [self.webViewWK evaluateJavaScript:javaScriptString completionHandler:completionHandler];
        return nil;
    }
    
    return nil;
}

- (JSContext *)jsContext {
    if (self.webView) {
        JSContext *ctx = [self.webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
        return ctx;
    }
    
    // WKWebView不支持JavaScriptCore
    return nil;
}

- (void)retryHttpIfNeedWithError:(NSError *)error {
    if (![[[NSUserDefaults standardUserDefaults] objectForKey:@"SSCommonLogicSettingWebViewHttpsSwitchKey"] boolValue]) {
        return;
    }
    
    NSString *errorURLStr = error.userInfo[NSURLErrorFailingURLStringErrorKey];
    
    if (![self.request.URL.absoluteString isEqualToString:errorURLStr]) {
        return;
    }
    
    TTHttpRequest *ttHttpRequest = [[TTHttpRequest alloc] init];
    ttHttpRequest.URL = self.request.URL;
    ttHttpRequest.allHTTPHeaderFields = self.request.allHTTPHeaderFields;
    ttHttpRequest.timeoutInterval = self.request.timeoutInterval;
    ttHttpRequest.HTTPBody = self.request.HTTPBody;
    ttHttpRequest.HTTPMethod = self.request.HTTPMethod;
    
    BOOL isHttpsFailed = [[TTHttpsControlManager sharedInstance_tt] checkHTTPsFailedWithURLResponse:nil responseError:error trackInfoList:nil forRequest:ttHttpRequest];
    if (!isHttpsFailed) {
        return;
    }
    
    BOOL hasTransfered = [self _hasMarkedTransfer:[NSURL URLWithString:errorURLStr]];
    if (hasTransfered) { //只对transfer过的URL进行fallback
        NSURLRequest *fallBackRequest = [NSURLRequest requestWithURL:[self _fallbackHttpIfNeed:self.origRequest.URL]];
        [self loadRequest:fallBackRequest shouldTransferedHttps:NO shouldAppendQuery:YES];
    }
    
    [[TTMonitor shareManager] trackService:@"webview_https_failure" status:1 extra:nil];
}

- (void)handleStartLoad {
    if ([self.delegate respondsToSelector:@selector(webViewDidStartLoad:)]) {
        [self.delegate webViewDidStartLoad:self];
    }
}

- (void)handleFinishLoad {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.guardTimer invalidate];
    });
    
    // 每次load完成后重新设置一下当前页面的consoleLogHandler
    JSContext *ctx = self.jsContext;
    if (ctx && self.logHandler) {//console.log? what the fuck?
        ctx[@"console"][@"log"] = self.logHandler;
    }
    
    if (self.webView) {
        self.currentURL = self.webView.request.URL;
    } else {
        self.currentURL = self.webViewWK.URL;
    }
    
    if ([self.delegate respondsToSelector:@selector(webViewDidFinishLoad:)]) {
        [self.delegate webViewDidFinishLoad:self];
    }
}

- (void)handleLayoutSubviews {
    if ([self.delegate respondsToSelector:@selector(webviewDidLayoutSubviews:)]) {
        [self.delegate webviewDidLayoutSubviews:self];
    }
}

- (void)handleError:(NSError*)error {
    //屏蔽调无人响应的bytedance://private/setresult/
    if ([error.domain isEqualToString:@"WebKitErrorDomain"] && error.code == 101 && [error.userInfo[NSURLErrorFailingURLStringErrorKey] hasPrefix:@"bytedance://private/setresult/"]) {
        return;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.guardTimer invalidate];
    });
    
    if ([self.delegate respondsToSelector:@selector(webView:didFailLoadWithError:)]) {
        [self.delegate webView:self didFailLoadWithError:error];
    }
    [self retryHttpIfNeedWithError:error];
}

//把URL放入WK的error里...fuck...
- (void)handleError:(NSError *)error withNavigation:(WKNavigation *)navigation {
    NSError *commonError = error;
    
    if (!isEmptyString(navigation.tt_URL.absoluteString) && error.userInfo) {
        NSMutableDictionary *mutabUserInfo = [[NSMutableDictionary alloc] initWithDictionary:error.userInfo];
        mutabUserInfo[NSURLErrorFailingURLStringErrorKey] = navigation.tt_URL.absoluteString;
        commonError = [NSError errorWithDomain:error.domain code:error.code userInfo:mutabUserInfo];
    }
    
    [self handleError:commonError];
}

- (void)setOpaque:(BOOL)opaque {
    [super setOpaque:opaque];
    self.webView.opaque = opaque;
    self.webViewWK.opaque = opaque;
}

- (void)setBackgroundColor:(UIColor *)backgroundColor {
    [super setBackgroundColor:backgroundColor];
    [self.webView setBackgroundColor:backgroundColor];
    [self.webViewWK setBackgroundColor:backgroundColor];
}

- (void)reload {
    if (self.webView) {
        [self.webView reload];
    } else if (self.webViewWK) {
        [self.webViewWK reload];
    }
}

-(BOOL)isLoading
{
    if (self.webView) {
        return [self.webView isLoading];
    } else if (self.webViewWK) {
        return [self.webViewWK isLoading];
    }
    return NO;
}

-(BOOL)canGoBack
{
    if (self.webView) {
        return [self.webView canGoBack];
    } else if (self.webViewWK) {
        return [self.webViewWK canGoBack];
    }
    return NO;
}

-(BOOL)canGoForward
{
    if (self.webView) {
        return [self.webView canGoForward];
    } else if (self.webViewWK) {
        return [self.webViewWK canGoForward];
    }
    return NO;
}

- (void)goBack
{
    if (self.webView) {
        [self.webView goBack];
    } else if (self.webViewWK) {
        [self.webViewWK goBack];
    }
}

- (void)goForward
{
    if (self.webView) {
        [self.webView goForward];
    } else if (self.webViewWK) {
        [self.webViewWK goForward];
    }
}

- (void)setScalesPageToFit:(BOOL)scalesPageToFit
{
    if(self.webView)
    {
        self.webView.scalesPageToFit = scalesPageToFit;
    }
    else if (self.webViewWK)
    {
        _scalesPageToFit = scalesPageToFit;
    }
}

- (BOOL)scalesPageToFit
{
    if(self.webView)
    {
        return [self.webView scalesPageToFit];
    }
    else
    {
        return _scalesPageToFit;
    }
}

- (UIDataDetectorTypes)dataDetectorTypes {
    if (self.webView) {
        return self.webView.dataDetectorTypes;
    } else if (self.webViewWK) {
        return UIDataDetectorTypeNone;
    }
    return UIDataDetectorTypeNone;
}

- (void)setDataDetectorTypes:(UIDataDetectorTypes)dataDetectorTypes
{
    if (self.webView) {
        [self.webView setDataDetectorTypes:dataDetectorTypes];
    } else if (self.webViewWK) {
        return;
    }
}

- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message
{
    //NSLog(@"%@", message.body);
    if (self.logHandler && [message.body isKindOfClass:[NSString class]]) {
        self.logHandler(message.body);
    }
}
#pragma mark - Accessibility
-(NSString*)accessibilityLabel{
    
    //Fetch web view content, convert html into plain text and use it.
    NSString *html = [self stringByEvaluatingJavaScriptFromString:@"document.body.innerHTML" completionHandler:nil];
    
    if (isEmptyString(html)) {
        return @"";
    }
    
    NSString *plainText=[self convertHTMLIntoPlainText:html];
    
    return plainText;
}


-(NSString *)convertHTMLIntoPlainText:(NSString *)html{
    
    //正则匹配 1.过滤scrpit脚本 2.过滤html标签 3.过滤&amp &nbsp等字符
    NSError *error;
    NSRegularExpression *regular = [NSRegularExpression regularExpressionWithPattern:@"(<script[^>]*?>.*?</script>)|(<[^>]*>)|(&[a-zA-Z]{1,10};)" options:NSRegularExpressionCaseInsensitive error:&error];
    
    //将正则匹配到的都替换成@""
    html  = [regular stringByReplacingMatchesInString:html options:0 range:NSMakeRange(0, html.length) withTemplate:@""];
    
    html = [html stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    return html;
}

#pragma mark - Util Methods

+ (NSURLRequest *)custRequestWithRequst:(NSURLRequest *)request
{
    NSURL *originUrl = [request URL];
    
    // 在iOS7上originUrl.path会把(http://is.snssdk.com/2/wap/search/?iid=xxx)
    // wap/search/最后面的/去掉，为了不改变原始url不使用下面拼url的方式
    //NSString *urlString = [NSString stringWithFormat:@"%@://%@%@", originUrl.scheme, originUrl.host, originUrl.path];
    
    NSString *urlString = originUrl.absoluteString;
    
    NSRange range = [urlString rangeOfString:@"#"];
    if (range.location != NSNotFound) {
        urlString = [urlString substringToIndex:range.location];
    }
    
    urlString = [TTNetworkUtilities customURLStringFromString:urlString];
    
    NSString *fragment = originUrl.fragment;
    if (fragment) {
        urlString = [NSString stringWithFormat:@"%@#%@", urlString, fragment];
    }
    
    NSMutableURLRequest *mutableRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    NSMutableDictionary *httpHeaders = @{}.mutableCopy;
    [httpHeaders setValuesForKeysWithDictionary:request.allHTTPHeaderFields];
    [httpHeaders enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        [mutableRequest setValue:obj forHTTPHeaderField:key];
    }];
    return [mutableRequest copy];
}

#pragma mark - private

// URL打标, 用于标记是否被transfer到https
- (NSURLRequest *)_markHadTransferIfNeed:(NSURLRequest *)origRequest {
    if (![origRequest isKindOfClass:[NSURLRequest class]]) {
        return nil;
    }
    
    if ([self _hasMarkedTransfer:origRequest.URL]) {
        return origRequest;
    }
    
    NSURLComponents *urlComponents = [NSURLComponents componentsWithString:origRequest.URL.absoluteString];
    if (isEmptyString(urlComponents.query)) {
        urlComponents.query = @"tt_transferHttps=1";
    } else {
        urlComponents.query = [urlComponents.query stringByAppendingString:@"&tt_transferHttps=1"];
    }
    
    return [NSURLRequest requestWithURL:urlComponents.URL];
}

// 判断是否有transfer的标记
- (BOOL)_hasMarkedTransfer:(NSURL *)url {
    if (![url isKindOfClass:[NSURL class]]) {
        return NO;
    }
    
    //url.query不存在 或者 标记没找到都算 未标记 @zengruihuan
    if (!url.query || [url.query rangeOfString:@"tt_transferHttps=1"].location == NSNotFound) {
        return NO;
    } else {
        return YES;
    }
}

- (NSURL *)_fallbackHttpIfNeed:(NSURL *)url {

    NSURL *destiURL = url;
    NSURLComponents *urlComponents = [NSURLComponents componentsWithURL:url resolvingAgainstBaseURL:NO];
    if ([urlComponents.scheme.lowercaseString isEqualToString:@"https"]) {
        urlComponents.scheme = @"http";
        destiURL = [urlComponents URL];
    }
    return destiURL;
}

- (BOOL)_isHttpsURL:(NSURL *)url {
    if (![url isKindOfClass:[NSURL class]]) {
        return NO;
    }
    
    if ([url.scheme.lowercaseString isEqualToString:@"https"]) {
        return YES;
    } else {
        return NO;
    }
}

+ (BOOL)shouldAppendQueryStirngWithUrl:(NSURL *)url
{
    BOOL enable = [[NSUserDefaults standardUserDefaults] boolForKey:@"SSCommonLogicSettingWebViewQueryStringEnableKey"];
    if (enable) {
        NSArray *hostList = [[NSUserDefaults standardUserDefaults] objectForKey:@"SSCommonLogicSettingWebViewQueryStringListKey"];
        for (NSString *host in hostList) {
            if ([url.host rangeOfString:host].length > 0) {
                return YES;
            }
        }
    }
    
    return NO;
}
@end

@implementation YSInnerWebViewDelegate

#pragma mark UIWebViewDelegate methods
- (void)webViewDidStartLoad:(UIWebView *)webView {
    [self.ysWebView handleStartLoad];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [self.ysWebView handleFinishLoad];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    [self.ysWebView handleError:error];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    if ([self.ysWebView.delegate respondsToSelector:@selector(webView:shouldStartLoadWithRequest:navigationType:)]) {
        return [self.ysWebView.delegate webView:self.ysWebView shouldStartLoadWithRequest:request navigationType:mapUIWebViewNavigationTypeToYSWebViewNavigationType(navigationType)];
    } else {
        return YES;
    }
}

#pragma mark WKNavigationDelegate methods
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
    navigation.tt_URL = [webView.URL copy];
    [self.ysWebView handleStartLoad];
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    [self.ysWebView handleFinishLoad];
   // [self.ysWebView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"TouTiao.setDayMode(0)"] completionHandler:nil];
}

- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    [self.ysWebView handleError:error withNavigation:navigation];
}

- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    [self.ysWebView handleError:error withNavigation:navigation];
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    //NSURL *url = navigationAction.request.URL;
    if ([self.ysWebView.delegate respondsToSelector:@selector(webView:shouldStartLoadWithRequest:navigationType:)]) {
        if ([self.ysWebView.delegate webView:self.ysWebView shouldStartLoadWithRequest:navigationAction.request navigationType:mapWKNavigationTypeToYSWebViewNavigationType(navigationAction.navigationType)]) {
            decisionHandler(WKNavigationActionPolicyAllow);
        } else {
            decisionHandler(WKNavigationActionPolicyCancel);
        }
    } else {
        decisionHandler(WKNavigationActionPolicyAllow);
    }
}

- (void)webviewDidLayoutSubviews:(nullable id)webview {
    [self.ysWebView handleLayoutSubviews];
}

@end

YSWebViewNavigationType mapWKNavigationTypeToYSWebViewNavigationType(WKNavigationType navigationType) {
    switch (navigationType) {
        case WKNavigationTypeLinkActivated: {return YSWebViewNavigationTypeLinkClicked; break;}
        case WKNavigationTypeFormSubmitted: {return YSWebViewNavigationTypeFormSubmitted; break;}
        case WKNavigationTypeBackForward: {return YSWebViewNavigationTypeBackForward; break;}
        case WKNavigationTypeReload: {return YSWebViewNavigationTypeReload; break;}
        case WKNavigationTypeFormResubmitted: {return YSWebViewNavigationTypeFormResubmitted; break;}
        case WKNavigationTypeOther: {return YSWebViewNavigationTypeOther; break;}
    }
}

YSWebViewNavigationType mapUIWebViewNavigationTypeToYSWebViewNavigationType(UIWebViewNavigationType navigationType) {
    switch (navigationType) {
        case UIWebViewNavigationTypeLinkClicked:    {return YSWebViewNavigationTypeLinkClicked; break;}
        case UIWebViewNavigationTypeFormSubmitted:  {return YSWebViewNavigationTypeFormSubmitted; break;}
        case UIWebViewNavigationTypeBackForward:    {return YSWebViewNavigationTypeBackForward; break;}
        case UIWebViewNavigationTypeReload:         {return YSWebViewNavigationTypeReload; break;}
        case UIWebViewNavigationTypeFormResubmitted:{return YSWebViewNavigationTypeFormResubmitted; break;}
        case UIWebViewNavigationTypeOther:          {return YSWebViewNavigationTypeOther; break;}
    }
}
