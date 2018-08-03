//
//  TTNewDetailWebviewContainer.m
//  Article
//
//  Created by muhuai on 11/10/2016.
//
//

#import "TTNewDetailWebviewContainer.h"
#import "TTNewDetailWebviewContainer+JSBridge.h"
#import "TTDetailWebviewContainer+JSImageVideoLogic.h"
#import "TTDetailWebViewRequestProcessor.h"
#import "TTArticleDetailDefine.h"

#import "UnitStayTimeAccumulator.h"
#import "SSImpressionGroup.h"
#import "TTTrackerWrapperSessionHandler.h"

#import "ExploreDetailMixedVideoADView.h"

#import "SSWebViewUtil.h"
#import "H5WebKitBugsManager.h"
#import "SSJSBridgeWebViewDelegate.h"
#import "TTNetworkManager.h"
#import "NSObject+MultiDelegates.h"
#import <KVOController/KVOController.h>
#import "TTFirstConcernManager.h"
#import "TTThemeManager.h"
#import "TTURLUtils.h"
#import "TTUIResponderHelper.h"
#import "TTKeyboardListener.h"
#import "TTProfileFillManager.h"

#define kFooterDivKey @"toutiao_ios_footer_div"

#define kFooterDisplayNotManualCloseDistance -30    //点击按钮打开浮层，下啦该距离收起
#define kInsertFooterOpenDistance 20                //insert类型浮层， 滑倒webview底部，上啦该距离打开浮层

#define UnitHeightScaleFactor 1

#define kScrollDistance 1200

#define kMinWebContentHeight 22

static CGFloat kProfileFillBubbleHeight = 66.f;

// 非强制登录的策略下，未登录状态下的点击订阅次数值
//static NSInteger subscribeCount = 0;

@interface TTNewDetailWebviewContainer () <UIScrollViewDelegate>
{
    CGFloat _currentMaxOffsetY;
    CGFloat _unitHeight;
    CGFloat _webViewOffsetY;
    CGFloat _footerScrollViewOffsetY; //用于记录阅读位置 @zengruihuan
    BOOL _hasFirstCommentShown;
    BOOL _hasWebViewDidFinishCalled;
    BOOL _isObserving;
    BOOL _isObservingContentSize;
    BOOL _isStickyFooter;
    BOOL _isOpenFooterByManual; //我也不想加这么多标记位......
}
@property (nonatomic, strong, readwrite) ArticleJSBridgeWebView * webView;
@property (nonatomic, strong) SSThemedView * contentFooterView;
@property (nonatomic, strong) UIButton *placeHolderView; //用于拦截滚动时的手势, 防止误触
@property (nonatomic, assign, readwrite) TTDetailWebViewFooterStatus footerStatus;
@property (nonatomic, strong) UIView<TTDetailFooterViewProtocol> * footerView;

@property (nonatomic, assign) BOOL isShowingNatantOnClick;    //是否是点击评论按钮打开的浮层 这种情况下浮层的superView是self 而不是webview的scrollview 加这个属性是因为 如果用户主动点开了评论浮层 footerStatus 的一些计算会出问题，可能把状态改成TTDetailWebViewFooterStatusDisplayNotManual 之外的，然后由于现在insertDiv 依赖这个条件，可能导致 浮层的superveiw发生变化

@property (nonatomic, strong) UIScrollView * footScrollView;
@property (nonatomic, strong) UIView * coverView; //夜间模式的cover

//统计用计时器
@property (nonatomic ,strong) UnitStayTimeAccumulator * unitStayTimeAccumulator;
//webview request 的处理单元
@property (nonatomic ,strong) TTDetailWebViewRequestProcessor * requestProcessor;

@end


@implementation TTNewDetailWebviewContainer
@synthesize webView = _webView, footerStatus = _footerStatus, delegate = _delegate, webViewContentHeight = _webViewContentHeight, movieView = _movieView, needCover = _needCover, natantStyle = _natantStyle, containerScrollView = _containerScrollView;

- (void)dealloc {

//    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    self.containerScrollView.delegate = nil;
    _webView.scrollView.delegate = nil;
    [_webView removeDelegate:self];
    void (^removeKVO)(id, NSString *) = ^void(id Observed, NSString *keyPath) {
        @try {
            [Observed removeObserver:self forKeyPath:keyPath];
        } @catch (NSException *exception) {
            SSLog(@"opps, kvo dealloc crashed");
        }
    };
    removeKVO(self.footerView, NSStringFromSelector(@selector(footerScrollView)));
    
    self.footerView = nil;
    self.contentFooterView = nil;
    [self.placeHolderView removeFromSuperview];
    self.downloadManager.delegate = nil;
    [self.downloadManager cancelAll];
    
    [self.movieView stopMovie];
    [self.movieView removeFromSuperview];
}

- (nullable id)initWithFrame:(CGRect)frame disableWKWebView:(BOOL)disableWKWebView ignoreGlobalSwitchKey:(BOOL)ignore hiddenWebView:(ArticleJSBridgeWebView * _Nullable)hiddenWebView webViewDelegate:(SSJSBridgeWebViewDelegate * _Nullable)jsBridgeDelegate {
    
    self = [super initWithFrame:frame];
    if (self) {
        [H5WebKitBugsManager fixAllBugs];
        _isOpenFooterByManual = YES;
        self.requestProcessor = [[TTDetailWebViewRequestProcessor alloc] init];
        
        if (hiddenWebView) {
            // 存在针对移动建站落地页的预加载的webview
            self.webView = hiddenWebView;
            self.webView.frame = self.bounds;
            self.webView.layer.opacity = 1.0;
            // 修正self.webView的delegate
            if (jsBridgeDelegate) {
                self.webView.delegate = jsBridgeDelegate;
            }
        } else {
            //基础JSBridgeWebView
            // 原来的流程
            self.webView = [[ArticleJSBridgeWebView alloc] initWithFrame:self.bounds disableWKWebView:disableWKWebView ignoreGlobalSwitchKey:ignore];
        }
        _webView.height = ceil(_webView.height);
        _webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [_webView addDelegate:self];
        _webView.scrollView.scrollsToTop = NO;
        _webView.scrollView.bounces = NO;
        _webView.scrollView.scrollEnabled = NO;
        _webView.scrollView.delegate = self;
        //        [self addSubview:_webView];
        [_webView addSubview:self.placeHolderView];
        
        _containerScrollView = ({
            SSThemedScrollView *scrollView = [[SSThemedScrollView alloc] initWithFrame:self.bounds];
            scrollView.height = ceil(scrollView.height);
            scrollView.contentSize = scrollView.frame.size;
            scrollView.bounces = YES;
            scrollView.delegate = self;
            scrollView.backgroundColorThemeKey = kColorBackground4;
            scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            scrollView;
        });
        [_containerScrollView addSubview:_webView];
        [self addSubview:_containerScrollView];
        [self addWebViewKVOController];
        if ([TTDeviceHelper isPadDevice]) {
            _webView.scrollView.showsVerticalScrollIndicator = NO;
        }
        
        //初始化footerView底下的展位view
        self.contentFooterView = [[SSThemedView alloc] initWithFrame:self.bounds];
        self.contentFooterView.backgroundColorThemeKey = kColorBackground4;
        _contentFooterView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        //渲染日夜间遮罩
        
        [self reloadThemeUI];
        
        //添加observers
        [self p_addWebViewVideoObservers];
        _isObserving = YES;
        _isObservingContentSize = YES;
        
        //添加订阅相关逻辑
        [self registerSubscribJS];
        
        [self initTracker];
        
        //监听前后台变化 主要用来做统计
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(didEnterBackground:) name:UIApplicationDidEnterBackgroundNotification
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(willEnterForeground:) name:UIApplicationWillEnterForegroundNotification
                                                   object:nil];
    }
    return self;
}

- (void)initTracker {
    
    CGFloat screenHeight = 0;
    if ([TTDeviceHelper isPadDevice] && UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation)) {
        screenHeight = [TTUIResponderHelper screenSize].width;
    } else {
        screenHeight = [TTUIResponderHelper screenSize].height;
    }
    _unitHeight = screenHeight * UnitHeightScaleFactor;
    self.unitStayTimeAccumulator = [[UnitStayTimeAccumulator alloc] initWithUnitHeight:_unitHeight];
    _unitStayTimeAccumulator.maxOffset = _webView.scrollView.contentSize.height;
    
}

- (void)setDelegate:(id<TTDetailWebviewDelegate,TTDetailWebViewRequestProcessorDelegate>)delegate{
    _delegate = delegate;
    self.requestProcessor.delegate = _delegate;
}

#pragma mark life cycle
- (void)willAppear {
    [super willAppear];
    
    [self themeChanged:nil];
    
}

- (void)didDisappear
{
    if (self.movieView) {
        [self.movieView pauseMovie];
        [ExploreMovieView removeAllExploreMovieView];
    }
    
    //关闭音频播放
    [self.webView.bridge invokeJSWithFunctionName:@"on_page_disappear" parameters:nil finishBlock:nil];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self p_layoutMovieViewsIfNeeded];
}

- (void)p_layoutMovieViewsIfNeeded
{
    if ([TTDeviceHelper isPadDevice] && self.movieView) {
        __block CGRect frame = CGRectZero;
        NSString *vid = _movieView.playVID;
        if (!isEmptyString(vid)) {
            NSString *js = [NSString stringWithFormat:@"getVideoFrame('%@')", vid];
            __weak typeof(self) weakSelf = self;
            [self.webView stringByEvaluatingJavaScriptFromString:js completionHandler:^(id _Nullable result, NSError * _Nullable error) {
                frame = [weakSelf p_frameFromObject:result];
                if (!CGRectEqualToRect(frame, CGRectZero)) {
                    if (weakSelf.movieView.isMovieFullScreen) {
                        [weakSelf.movieView updateMovieInFatherViewFrame:frame];
                    }
                    else {
                        weakSelf.movieView.frame = frame;
                    }
                }
                else {
                    [weakSelf.movieView exitFullScreenIfNeed:NO];
                    [weakSelf.movieView removeFromSuperview];
                    [weakSelf.movieView stopMovie];
                    weakSelf.movieView = nil;
                }
            }];
        }
    }
}

- (void)didAppear
{
    if ([self _isWebViewVisible]) {
        [self webViewDidAppear];
    }
}

- (void)willDisappear
{
    if ([self _isWebViewVisible]) {
        [self webViewWillDisappear];
    }
}

- (void)webViewDidAppear
{
    _unitStayTimeAccumulator.currentOffset = _webView.scrollView.contentOffset.y;
}

- (void)webViewWillDisappear
{
    [_unitStayTimeAccumulator suspendAccumulating];
}

- (BOOL)isNewWebviewContainer {
    return YES;
}

#pragma mark -- Notifications for "EnterBackground" & "EnterForeground"

- (void)didEnterBackground:(NSNotification *)notification
{
    [self willDisappear];
}

- (void)willEnterForeground:(NSNotification *)notification
{
    [self didAppear];
}

#pragma mark theme changed

- (void)setNeedCover:(BOOL)needCover
{
    _needCover = needCover;
    [self refreshCoverView];
}

- (void)refreshCoverView
{
    if (self.needCover) {
        if ([[TTThemeManager sharedInstance_tt] currentThemeMode] == TTThemeModeNight) {
            if (!_coverView) {
                self.coverView = [[UIView alloc] initWithFrame:self.bounds];
                _coverView.userInteractionEnabled = NO;
                _coverView.backgroundColor = [UIColor blackColor];
                _coverView.alpha = 0.6f;
                _coverView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
            }
            [self addSubview:_coverView];
        }
        else {
            [_coverView removeFromSuperview];
        }
    }
}

#pragma mark footer natant and comment view status func

- (BOOL)isNatantViewVisible
{
    return (_footerStatus == TTDetailWebViewFooterStatusDisplayTotal ||
            _footerStatus == TTDetailWebViewFooterStatusDisplayNotManual ||
            _footerStatus == TTDetailWebViewFooterStatusDisplayHalf);
}

- (BOOL)isCommentVisible
{
    return (_footerStatus == TTDetailWebViewFooterStatusDisplayTotal ||
            _footerStatus == TTDetailWebViewFooterStatusDisplayNotManual);
}

- (BOOL)isNatantViewOnOpenStatus
{
    BOOL isDisplayTotal = _footerStatus == TTDetailWebViewFooterStatusDisplayTotal || _footerStatus == TTDetailWebViewFooterStatusDisplayNotManual;
    
    //浮层处于half状态 并且滚动到底了
    BOOL isContainerScrollToBottomWhenDisplayHalf = (_footerStatus == TTDetailWebViewFooterStatusDisplayHalf) && [self _isContainerScrollToBottom];
    
    return isDisplayTotal || isContainerScrollToBottomWhenDisplayHalf;
}

- (BOOL)isManualPullFooter {
    return _isOpenFooterByManual;
}

- (BOOL)_isFooterScrollToBottom {
    return (self.footScrollView.contentOffset.y + self.footScrollView.height) >= self.footScrollView.contentSize.height;
}

- (BOOL)_isContainerScrollToBottom {
    return (self.containerScrollView.contentOffset.y + self.containerScrollView.height) >= self.containerScrollView.contentSize.height;
}

- (BOOL)_isWebViewVisible {
    return self.footerStatus == TTDetailWebViewFooterStatusNoDisplay || self.footerStatus == TTDetailWebViewFooterStatusDisplayHalf;
}
#pragma mark footer operation

- (void)addFooterView:(UIView<TTDetailFooterViewProtocol> *)footerView
  detailFooterAddType:(TTDetailNatantStyle)natantStyle
{
    void (^removeKVO)(id, NSString *) = ^void(id Observed, NSString *keyPath) {
        @try {
            [Observed removeObserver:self forKeyPath:keyPath];
        } @catch (NSException *exception) {
            SSLog(@"opps, kvo dealloc crashed");
        }
    };
    //remove之前的KVO, @zengruihuan
    if (self.footerView) {
        removeKVO(self.footerView, @"footerScrollView");
    }
    [self.KVOController unobserve:self.footScrollView];
    
    self.natantStyle = natantStyle;
    
    self.footerView = footerView;
    
    [self.footerView addObserver:self forKeyPath:@"footerScrollView" options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew context:nil];
    
    
    [[self.footerView footerScrollView] tt_addDelegate:self asMainDelegate:NO];
    self.footScrollView = self.footerView.footerScrollView;
    self.footScrollView.scrollEnabled = NO;
    self.footScrollView.scrollsToTop = NO;
    self.footerView.frame = self.bounds;
    //footerScrollView被赋值后，刷新scrollEnable和scrollToTop的状态；
    self.footerStatus = self.footerStatus;
    
    [self addFooterKVOController];
    
    self.footerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    [self addFooterView];
}

- (void)addFooterView
{
    [self.contentFooterView addSubview:self.footerView];
}

- (void)insertDivToWebViewIfNeed
{
    if (!_hasWebViewDidFinishCalled) {
        return;
    }
    //应为body会撑大到frame高度...所以插个div来确定页面底部..
    //并且监听页面高度变化.
    if (self.natantStyle == TTDetailNatantStyleAppend || self.natantStyle == TTDetailNatantStyleInsert) {
        [self.webView evaluateJavaScriptFromString:[NSString stringWithFormat:@";(function(body, callback) {"
                                                    "if (document.querySelector('#%@')) {"
                                                    "return;"
                                                    "}"
                                                    "var el = document.createElement('div');"
                                                    "el.id='%@';"
                                                    "body.appendChild(el);"
                                                    "var oldHeight = Math.ceil(el.offsetHeight + el.offsetTop);"
                                                    "var newHeight;"
                                                    "if (oldHeight) {"
                                                    "    callback(oldHeight);"
                                                    "}"
                                                    "var timer = setInterval(function() {"
                                                    "if (!el.parentElement) {"
                                                    "clearInterval(timer);"
                                                    "return;"
                                                    "}"
                                                    "newHeight = Math.ceil(el.offsetHeight + el.offsetTop);"
                                                    "if (newHeight != oldHeight) {"
                                                    "callback(newHeight);"
                                                    "}"
                                                    "oldHeight = newHeight"
                                                    "}, 16);"
                                                    "})(document.body,"
                                                    "function(height) {"
                                                    "setTimeout(function() {"
                                                        "var iframe = document.createElement('iframe');"
                                                        "iframe.setAttribute('frameborder', '0');"
                                                        "iframe.style.cssText = 'width:0;height:0;border:0;display:none;';"
                                                        "iframe.setAttribute('src', 'bytedance://contentHeightHasChanged?height=' + height);"
                                                        "document.body.appendChild(iframe);"
                                                        "setTimeout(function() {"
                                                            "document.body.removeChild(iframe);"
                                                        "}, 500)"
                                                    "}, 5)"
                                                    "});", kFooterDivKey, kFooterDivKey] completionBlock:nil];
    }
}

- (void)addFooterToContainerIfNeed {
    if (_contentFooterView.superview) {
        return;
    }
    
    if (self.natantStyle == TTDetailNatantStyleAppend || self.natantStyle == TTDetailNatantStyleInsert) {
        _contentFooterView.top = _webViewContentHeight;
        CGFloat footerHeight = MAX(_contentFooterView.height, _footScrollView.contentSize.height);
        _containerScrollView.contentSize = CGSizeMake(_containerScrollView.contentSize.width, _webViewContentHeight + footerHeight);
        [_containerScrollView addSubview:_contentFooterView];
    }
}

//info下发natant_level发生变化时，更新div
- (void)removeDivFromWebViewIfNeeded
{
    if (_contentFooterView.superview == _containerScrollView) {
        [_contentFooterView removeFromSuperview];
        self.containerScrollView.contentSize = self.webView.scrollView.contentSize;
    }
    
    if (!_hasWebViewDidFinishCalled) {
        return;
    }
    
    [_webView evaluateJavaScriptFromString:[NSString stringWithFormat:@" \
                                            var customDiv = document.querySelector(\"#%@\"); \
                                            if (customDiv) {\
                                            var ele = document.getElementById('%@'); \
                                            document.body.removeChild(ele);\
                                            }", kFooterDivKey, kFooterDivKey]completionBlock:nil];
}

#pragma mark WebView Delegate

- (void)webViewDidStartLoad:(nullable YSWebView *)webView {
    
    if ([self.delegate respondsToSelector:_cmd]) {
        [self.delegate webViewDidStartLoad:webView];
    }
}


- (void)webViewDidFinishLoad:(nullable YSWebView *)webView {
    if ([self.delegate respondsToSelector:_cmd]) {
        [self.delegate webViewDidFinishLoad:webView];
    }
    _hasWebViewDidFinishCalled = YES;
    [self insertDivToWebViewIfNeed];
    
}

- (void)webviewDidLayoutSubviews:(nullable YSWebView *)webview {
    [self p_layoutMovieViewsIfNeeded];
}

- (void)webView:(nullable YSWebView *)webView didFailLoadWithError:(nullable NSError *)error {
    
    if ([self.delegate respondsToSelector:_cmd]) {
        [self.delegate webView:webView didFailLoadWithError:error];
    }
}


/*
 *  这里的判断略微复杂，
 *  首先1 给业务层来判断是否支持requestload
 *  然后2 根据SSWebViewUtil 来判断是否命中settings下发的拦截url list
 *  然后3 由RequestProcessor处理一些通用的local逻辑
 *  然后4 处理local 的image 加载相关逻辑 （4和3 之前是在一起处理的，重构拆开）
 *  然后5 如果local处理不了，又不是转码页 而是web 就return YES 打开该链接
 *  然后6 如果local处理不了，又是转码页, request长度大于0 就在新页面用webview打开
 */


- (BOOL)webView:(nullable YSWebView *)webView shouldStartLoadWithRequest:(nullable NSURLRequest *)request navigationType:(YSWebViewNavigationType)navigationType {
    
    
    [self DOMContentHeightHasChangedWithRequset:request.URL];
    //1 交给 外层业务逻辑处理
    BOOL resultByBusiness = YES;
    if ([self.delegate respondsToSelector:_cmd]) {
        resultByBusiness = [self.delegate webView:webView shouldStartLoadWithRequest:request navigationType:navigationType];
    }
    if (!resultByBusiness) {
        return NO;
    }
    
    //2 处理settings 下发的拦截url
    BOOL resultByUtil = [SSWebViewUtil webView:webView shouldStartLoadWithRequest:request navigationType:navigationType];
    if (!resultByUtil) {
        return NO;
    }
    
    //3 由RequestProcessor处理一些通用的local逻辑
    BOOL resultByProcessor = [self.requestProcessor webView:webView shouldStartLoadWithRequest:request navigationType:navigationType];
    if (!resultByProcessor) {
        return NO;
    }
    
    //4 处理local 的image 加载相关逻辑
    BOOL resultShowImage = YES;
    if([self redirectRequestCanOpen:request])
    {
        resultShowImage = [self redirectLocalRequest:request.URL];
    }
    if (!resultShowImage) {
        return NO;
    }
    
    //5 如果不是转码页 而是web 就return YES 开始loadrequest
    BOOL isWeb = YES;
    if ([self.delegate respondsToSelector:@selector(webViewContentIsNativeType)]){
        isWeb = ![self.delegate webViewContentIsNativeType];
    }
    if (isWeb) {
        return YES;
    }
    
    
    //6 如果request 长度大于0 就用webview打开
    if ([request.URL.host length] > 0) {
        [self redirectRequest:request.URL navigationType:navigationType];
        return NO;
    }
    
    
    return YES;
}



- (void)redirectRequest:(NSURL*)requestURL navigationType:(YSWebViewNavigationType)navigationType
{
    if (navigationType == YSWebViewNavigationTypeLinkClicked) {
        if (_delegate && [_delegate respondsToSelector:@selector(processRequestOpenWebViewUseURL:supportRotate:)]) {
            [_delegate processRequestOpenWebViewUseURL:requestURL supportRotate:NO];
        }
    }
    wrapperTrackEvent(@"detail", @"open_url");
}

- (void)DOMContentHeightHasChangedWithRequset:(NSURL *)requestURL {

    if (self.natantStyle == TTDetailNatantStyleDisabled || self.natantStyle == TTDetailNatantStyleOnlyClick) {
        return;
    }
    
    if (![requestURL.scheme isEqualToString:@"bytedance"] || ![requestURL.host isEqualToString:@"contentHeightHasChanged"]) {
        return;
    }
    
    if (ceil(_webView.scrollView.contentSize.height) > ceil(_webView.scrollView.height)) {
        //为了确保最大的兼容性. 当contentSize大于frame时 dom高度的监听走contentsize的KVO @muhuai
        [self.webView.scrollView willChangeValueForKey:@"contentSize"];
        [self.webView.scrollView didChangeValueForKey:@"contentSize"];
        return;
    }
    NSDictionary *querys = [TTURLUtils queryItemsForURL:requestURL];
    _webViewContentHeight = [querys[@"height"] integerValue];
    
    [self demotedNatantLevelIfNeed];
    
    //有可能被demotedNatantLevelIfNeed 降级了, 需要再次判断
    if (self.natantStyle == TTDetailNatantStyleDisabled || self.natantStyle == TTDetailNatantStyleOnlyClick) {
        return;
    }
    
    _containerScrollView.contentSize = CGSizeMake(_containerScrollView.contentSize.width, _webViewContentHeight + _footScrollView.contentSize.height);
    
    //兼容一下短文章. 插浮层延迟0.2s 防闪烁 @zengruihuan
    if (self.contentFooterView.superview) {
        [self refreshHeaderAndFooterFrame];
    } else {
        __weak __typeof(self)weakSelf = self;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.12f * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            [weakSelf addFooterToContainerIfNeed];
            [weakSelf refreshHeaderAndFooterFrame];
        });
    }
}

- (void)demotedNatantLevelIfNeed {
    if (!self.needAutoDemoted) {
        return;
    }
    
    if (_webViewContentHeight > kMinWebContentHeight) {
        return;
    }
    
    //onClick和Disable不需要降级
    if (self.natantStyle == TTDetailNatantStyleOnlyClick || self.natantStyle == TTDetailNatantStyleDisabled) {
        return;
    }
    
    self.natantStyle = TTDetailNatantStyleOnlyClick;
}

#pragma mark UIScrollView Delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    TTDetailWebViewFooterStatus originStatus = _footerStatus;
    if (scrollView == _containerScrollView) {
        self.placeHolderView.enabled = YES;
        [self refreshHeaderAndFooterFrame];
        if (_footerStatus == TTDetailWebViewFooterStatusDisplayHalf) {
            [_webView ttr_fireEvent:@"webviewScrollEvent" data:@{@"rect": [NSString stringWithFormat:@"(%.0f,%.0f,%.0f,%.0f)", _containerScrollView.contentOffset.x, _containerScrollView.contentOffset.y - _webView.top, _webView.width, _webView.height]}];
        }
    } else if (scrollView == _webView.scrollView) {
        if (scrollView.contentOffset.y > _currentMaxOffsetY) {
            _currentMaxOffsetY = scrollView.contentOffset.y;
        }
    }
    
    if (originStatus != _footerStatus) {
        if (_footerStatus == TTDetailWebViewFooterStatusDisplayHalf && originStatus == TTDetailWebViewFooterStatusNoDisplay) {
            wrapperTrackEvent(@"detail", @"pull_open_drawer");
        }
        else if (_footerStatus == TTDetailWebViewFooterStatusNoDisplay && originStatus == TTDetailWebViewFooterStatusDisplayHalf) {
            wrapperTrackEvent(@"detail", @"pull_close_drawer");
        }
    }
    
    // 统计 unitStayTime
    if ([self _isWebViewVisible] && (scrollView == _webView.scrollView)) {
        _unitStayTimeAccumulator.currentOffset = scrollView.contentOffset.y;
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(webView:scrollViewDidScroll:)]) {
        [self.delegate webView:self scrollViewDidScroll:scrollView];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (scrollView == _footScrollView) {
        if (_footerStatus == TTDetailWebViewFooterStatusDisplayNotManual && scrollView.contentOffset.y < kFooterDisplayNotManualCloseDistance) {
            [self closeFooterView];
        }
    }
    else if (scrollView == _containerScrollView) {
        if (_footerStatus == TTDetailWebViewFooterStatusDisplayHalf) {
            if ((scrollView.contentOffset.y + scrollView.frame.size.height) > (MAX(scrollView.contentSize.height, scrollView.frame.size.height) + kInsertFooterOpenDistance)) {
                [self openFooterView:NO];
            }
        }
        if (!decelerate) {
            [self scrollviewDidEndScrolling:scrollView];
        }
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (scrollView == self.containerScrollView) {
        [self scrollviewDidEndScrolling:scrollView];
    }
    
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    if (scrollView == self.containerScrollView) {
        [self scrollviewDidEndScrolling:scrollView];
    }
}
- (void)scrollviewDidEndScrolling:(UIScrollView *)scrollView {
    if (scrollView != _containerScrollView) {
        return;
    }
    _isObservingContentSize = YES;
    self.placeHolderView.enabled = NO;
    [self.webView.scrollView willChangeValueForKey:@"contentSize"];
    [self.webView.scrollView didChangeValueForKey:@"contentSize"];
}

- (void)scrollViewDidScrollToTop:(UIScrollView *)scrollView {
    if (scrollView == _containerScrollView) {
        self.placeHolderView.enabled = NO;
    }
}

#pragma mark -- Footer Status Change

- (CGFloat)originYForFooterView
{
    CGFloat originY = 0;
    if (self.natantStyle == TTDetailNatantStyleAppend) {
        originY = _webViewContentHeight;
    }
    else if (self.natantStyle == TTDetailNatantStyleInsert) {
        if (_footerStatus == TTDetailWebViewFooterStatusDisplayNotManual) {
            originY = 0;
        }
        else {
            originY = _webViewContentHeight;
        }
    }
    originY = MAX(originY, 0);
    return originY;
}

- (void)refreshFooterStatusWithChange:(NSDictionary *)change
{
    if (self.natantStyle == TTDetailNatantStyleDisabled) {
        [self changeFooterStatus:TTDetailWebViewFooterStatusNoDisplay];
    }
    else if (_containerScrollView.contentOffset.y >= _webViewContentHeight) {
        [self changeFooterStatus:TTDetailWebViewFooterStatusDisplayTotal];
    }
    else if(_containerScrollView.contentOffset.y + _webView.height <= _webViewContentHeight) {
        [self changeFooterStatus:TTDetailWebViewFooterStatusNoDisplay];
    }
    else {
        [self changeFooterStatus:TTDetailWebViewFooterStatusDisplayHalf];
    }
    
    //展示第一条评论时container的offset
    CGFloat offset = _webViewContentHeight + ((UITableView *)self.footerView.footerScrollView).tableHeaderView.height - _containerScrollView.height;
    if (!_hasFirstCommentShown) {
        if (_containerScrollView.contentOffset.y >= 0 &&
            screenAdaptiveForFloatValue(_containerScrollView.contentOffset.y) >= offset) {
            if (_delegate && [_delegate respondsToSelector:@selector(webViewContainerWillShowFirstCommentCellByScrolling)]) {
                [_delegate webViewContainerWillShowFirstCommentCellByScrolling];
            }
            _hasFirstCommentShown = YES;
        }
    }
    
    if (self.footerStatus == TTDetailWebViewFooterStatusDisplayHalf) {
        if (_delegate && [_delegate respondsToSelector:@selector(webViewContainerInFooterHalfShowStatusWithScrollOffset:)]) {
            if (screenAdaptiveForFloatValue(_containerScrollView.contentOffset.y) >= offset) {
                //展示的评论发送recording impression
                CGFloat halfStatusBeginOrinY = offset;
                CGFloat relativeOffset = MAX(_containerScrollView.contentOffset.y - halfStatusBeginOrinY, 0);
                [_delegate webViewContainerInFooterHalfShowStatusWithScrollOffset:relativeOffset];
            }
            else {
                //footerStatus切换到noDisplay时首条评论发送end impression
                CGFloat leaveHalfStatusOffset = -1;
                [_delegate webViewContainerInFooterHalfShowStatusWithScrollOffset:leaveHalfStatusOffset];
            }
        }
    }
}

- (void)changeFooterStatus:(TTDetailWebViewFooterStatus)status
{
    if (_footerStatus != status && !self.isShowingNatantOnClick) {
        self.footerStatus = status;
    }
}

- (void)setFooterStatus:(TTDetailWebViewFooterStatus)footerStatus {
    if (footerStatus == TTDetailWebViewFooterStatusDisplayHalf && (_footerStatus == TTDetailWebViewFooterStatusDisplayTotal || _footerStatus == TTDetailWebViewFooterStatusDisplayNotManual)) {
        _isOpenFooterByManual = NO;
    }
    
    if (_footerStatus == footerStatus) {
        return;
    }
    
    _footerStatus = footerStatus;
    switch (footerStatus) {
        case TTDetailWebViewFooterStatusDisplayTotal:
        case TTDetailWebViewFooterStatusDisplayNotManual:
            _isStickyFooter = YES;
            [self webViewWillDisappear];
            break;
            
        default:
            _isStickyFooter = NO;
            [self webViewDidAppear];
            break;
    }
}
#pragma mark -- kvo observer
- (void)addWebViewKVOController {
    
    //TODO: 区分natantStyle来添加不同的KVO
    __weak __typeof(self)weakSelf = self;
    [self.KVOController observe:self.webView.scrollView keyPath:@"contentSize" options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew block:^(id  _Nullable observer, id  _Nonnull object, NSDictionary<NSString *,id> * _Nonnull change) {
        [weakSelf webviewContentSizeOnChange:change];
    }];
    
    [self.KVOController observe:self.webView.scrollView keyPath:@"contentOffset" options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew block:^(id  _Nullable observer, id  _Nonnull object, NSDictionary<NSString *,id> * _Nonnull change) {
        [weakSelf scrollViewContentOffsetOnChange:change];
    }];
    
//    [self.KVOController observe:self.webView.scrollView keyPath:@"contentSize" options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionOld block:^(id  _Nullable observer, id  _Nonnull object, NSDictionary<NSString *,id> * _Nonnull change) {
//        
//    }];
    
}

- (void)addFooterKVOController {
    if (self.natantStyle != TTDetailNatantStyleAppend) {
        return;
    }
    __weak __typeof(self)weakSelf = self;
    [self.KVOController observe:self.footScrollView keyPath:@"contentSize" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld block:^(id  _Nullable observer, id  _Nonnull object, NSDictionary<NSString *,id> * _Nonnull change) {
        [weakSelf footerConentSizeOnChange:change];
    }];
    [self.KVOController observe:self.footScrollView keyPath:@"contentOffset" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld block:^(id  _Nullable observer, id  _Nonnull object, NSDictionary<NSString *,id> * _Nonnull change) {
        [weakSelf scrollViewContentOffsetOnChange:change];
    }];
    
    [self.KVOController observe:self.footScrollView keyPath:@"contentInset" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld block:^(id  _Nullable observer, id  _Nonnull object, NSDictionary<NSString *,id> * _Nonnull change) {
        [weakSelf footerContentInsetOnChange:change];
    }];
}

- (void)webviewContentSizeOnChange:(NSDictionary *)change {
    if (!_isObservingContentSize) {
        return;
    }
    
        //只有页面大于一屏时才走这里. @zengruihuan
    if (ceil(_webView.scrollView.contentSize.height) > ceil(_webView.scrollView.height)) {
        _webViewContentHeight = self.webView.scrollView.contentSize.height;
        [self addFooterToContainerIfNeed];
    }
    
    if (self.natantStyle == TTDetailNatantStyleAppend && self.contentFooterView.superview) {
        self.containerScrollView.contentSize = CGSizeMake(self.containerScrollView.width, _webViewContentHeight + self.footScrollView.contentSize.height);
    } else {
        self.containerScrollView.contentSize = self.webView.scrollView.contentSize;
    }
    
    //insert形式的浮层如果已经显示出来,就不再重置浮层位置 @zengruihuan
    if ((self.natantStyle == TTDetailNatantStyleInsert || self.natantStyle == TTDetailNatantStyleOnlyClick) && (self.footerStatus == TTDetailWebViewFooterStatusDisplayNotManual || self.footerStatus == TTDetailWebViewFooterStatusDisplayTotal)) {
        return;
    }
    
    if (_isStickyFooter) { //stickyFooter状态时 确保footer.top相对屏幕保持不变 @zengruihuan
        [self scrollView:self.containerScrollView setContentOffset:CGPointMake(self.containerScrollView.contentOffset.x, _webViewContentHeight + self.footScrollView.contentOffset.y)];
    }
    [self refreshHeaderAndFooterFrame];
    _unitStayTimeAccumulator.maxOffset = _webView.scrollView.contentSize.height;
    
    CGSize  old = [change[NSKeyValueChangeOldKey] CGSizeValue];
    CGSize  new = [change[NSKeyValueChangeNewKey] CGSizeValue];
    BOOL isChange = !CGSizeEqualToSize(old, new);
    
    if (isChange && [self.delegate respondsToSelector:@selector(webViewDidChangeContentSize)]) {
        [self.delegate webViewDidChangeContentSize];
    }
    
}


- (void)scrollViewContentOffsetOnChange:(NSDictionary *)change {
    //需要oldValue 所以采用KVO @zengruihuan
    if (!_isObserving) {
        return;
    }
    CGPoint  old = [change[NSKeyValueChangeOldKey] CGPointValue];
    CGPoint  new = [change[NSKeyValueChangeNewKey] CGPointValue];
    CGFloat diff = new.y - old.y;
    if (!diff) {
        return;
    }
    self.containerScrollView.contentOffset = CGPointMake(self.containerScrollView.contentOffset.x, self.containerScrollView.contentOffset.y + diff);
}

- (void)footerConentSizeOnChange:(NSDictionary *)change {
    if (!_isObservingContentSize) {
        return;
    }
    
    if (self.natantStyle == TTDetailNatantStyleAppend && self.contentFooterView.superview) {
        self.containerScrollView.contentSize = CGSizeMake(self.containerScrollView.width, _webViewContentHeight + self.footScrollView.contentSize.height);
    }
    
    [self refreshHeaderAndFooterFrame];
}

- (void)footerContentInsetOnChange:(NSDictionary *)change {
    UIEdgeInsets inset = _containerScrollView.contentInset;
    inset.bottom = _footScrollView.contentInset.bottom;
    _containerScrollView.contentInset = inset;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"footerScrollView"]) {
        
        if (![self.footScrollView isEqual:[change objectForKey:@"new"]]) {
            
            [self.footScrollView tt_removeDelegate:self];
            
            [[self.footerView footerScrollView] tt_addDelegate:self asMainDelegate:NO];
            self.footScrollView = self.footerView.footerScrollView;
            
            [self refreshFooterStatusWithChange:nil];
        }
    }
    
}

- (void)scrollView:(UIScrollView*)scrollView setContentOffset:(CGPoint)offset
{
    _isObserving = NO;
    scrollView.contentOffset = offset;
    _isObserving = YES;
}

- (void)setWebContentOffset:(CGPoint)offset {
    [self.containerScrollView setContentOffset:offset];
    self.placeHolderView.enabled = NO;
}

- (void)refreshHeaderAndFooterFrame {
    CGFloat maxHeaderOffset = MAX(_webViewContentHeight - self.webView.height, 0);
    
    //区域 [0,maxHeaderOffset]
    CGFloat webViewOffsetY = MIN(MAX(self.containerScrollView.contentOffset.y, 0), maxHeaderOffset);
    
    if (webViewOffsetY != self.webView.scrollView.contentOffset.y) {
        [self scrollView:self.webView.scrollView setContentOffset:CGPointMake(0, webViewOffsetY)];
        [self.webView stringByEvaluatingJavaScriptFromString:@";window.dispatchEvent(new Event('scroll'));document.dispatchEvent(new Event('scroll'))" completionHandler:nil]; //手动触发前端滚动事件 用于图片懒加载.
    }
    self.webView.top = MIN(maxHeaderOffset, webViewOffsetY);
    
    if (self.contentFooterView.superview != self.containerScrollView) {
        return;
    }
    
    CGFloat minContentOffset = 0;
    CGFloat contentViewOffset = MAX(minContentOffset, self.containerScrollView.contentOffset.y - _webViewContentHeight);
    self.contentFooterView.top = MAX(_webViewContentHeight, self.containerScrollView.contentOffset.y);
    [self scrollView:self.footScrollView setContentOffset:CGPointMake(0, contentViewOffset)];
    [self refreshFooterStatusWithChange:nil];
}

#pragma Open/Close FooterView

- (void)openFooterView:(BOOL)isSendComment
{
    _isOpenFooterByManual = NO;
    if (self.natantStyle == TTDetailNatantStyleInsert || self.natantStyle == TTDetailNatantStyleOnlyClick) {
        if (_footerStatus != TTDetailWebViewFooterStatusDisplayNotManual) {
            [self changeFooterStatus:TTDetailWebViewFooterStatusDisplayNotManual];
            CGFloat originY = _contentFooterView.superview == nil ? CGRectGetHeight(_webView.frame) : [self convertPoint:CGPointMake(0, self.contentFooterView.top) fromView:self.containerScrollView].y;
            [self _openFooterNotManualOriginY:originY];
        }
    }
    else if (self.natantStyle == TTDetailNatantStyleAppend) {
        _isObservingContentSize = NO;
        _webViewOffsetY = self.webView.scrollView.contentOffset.y;
        
        if ([self.footScrollView isKindOfClass:[UITableView class]] && !_footerScrollViewOffsetY) {
            UITableView *tableView = (UITableView *)self.footScrollView;
            if (tableView.numberOfSections && [tableView numberOfRowsInSection:0]) {
                CGRect rect = [tableView rectForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
                _footerScrollViewOffsetY = rect.origin.y;
            }
        }
        
        CGFloat jumpToOffsetY = MAX(_webViewContentHeight + _footerScrollViewOffsetY - kScrollDistance, self.containerScrollView.contentOffset.y); //先跳一段距离再动画,减少闪烁感 @zengruihuan
        CGFloat destinationOffsetY = MAX(0, MIN(_webViewContentHeight + _footerScrollViewOffsetY, self.containerScrollView.contentSize.height - self.containerScrollView.height));
        if (destinationOffsetY == self.containerScrollView.contentOffset.y) {
            _isObservingContentSize = YES; //如果没有滚动,不会触发didScroll回调 需要在这置为YES @zengruihuan
        }
        self.containerScrollView.contentOffset = CGPointMake(self.containerScrollView.contentOffset.x, jumpToOffsetY);
        
        if ([TTProfileFillManager manager].isCommentFlag && [TTProfileFillManager manager].isShowProfileFill && isSendComment) {
            destinationOffsetY -= kProfileFillBubbleHeight;
        }
        
        [self.containerScrollView setContentOffset:CGPointMake(self.containerScrollView.contentOffset.x, destinationOffsetY) animated:YES]; //滚动距离不能越界 @zengruihuan
    }
}

- (void)_openFooterNotManualOriginY:(CGFloat)originY
{
    [_contentFooterView removeFromSuperview];
    _footScrollView.scrollEnabled = YES;
    CGRect contentFooterViewFrame = _contentFooterView.frame;
    contentFooterViewFrame.origin.y = originY;
    _contentFooterView.frame = contentFooterViewFrame;
    [self addSubview:_contentFooterView];
    
    CGRect targetFrame = _contentFooterView.frame;
    targetFrame.origin.y = 0;
    contentFooterViewFrame = targetFrame;
    
    [self changeFooterStatus:TTDetailWebViewFooterStatusDisplayNotManual];
    self.isShowingNatantOnClick = YES;
    
    
    [UIView animateWithDuration:0.25 animations:^{
        _contentFooterView.frame = contentFooterViewFrame;
        UITableView *commentTableView = (UITableView *)[_footerView footerScrollView];
        CGFloat contentHeight = commentTableView.contentSize.height - commentTableView.tableHeaderView.frame.size.height;
        if ([commentTableView isKindOfClass:[UITableView class]] &&
            [commentTableView numberOfSections] &&
            [commentTableView numberOfRowsInSection:0] &&
            contentHeight < commentTableView.frame.size.height) {
            //少评论文章重新定位至评论开始处
            [commentTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
        }
    } completion:^(BOOL finished) {
        _contentFooterView.frame = contentFooterViewFrame;
    }];
    
}

- (void)openFirstCommentIfNeed {
    //本想写成传入contentOffset的方法..这样通用一些..
    //不过这样损失了易用性, 详情页这么定制的地方感觉还是 易用性比较重要..  @zengruihuan
    if ([self.footScrollView isKindOfClass:[UITableView class]]) {
        UITableView *tableView = (UITableView *)self.footScrollView;
        if (tableView.numberOfSections && [tableView numberOfRowsInSection:0]) {
            CGRect rect = [tableView rectForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
            _footerScrollViewOffsetY = rect.origin.y;
        }
    }
    [self openFooterView:YES];
}

- (void)closeFooterView
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kDetailVideoADDisappearNotification object:nil];
    _footScrollView.scrollEnabled = NO;
    if (_natantStyle == TTDetailNatantStyleAppend) {
        
        _footerScrollViewOffsetY = self.footScrollView.contentOffset.y;
        CGFloat jumpToOffsetY = MIN(_webViewOffsetY + kScrollDistance, self.containerScrollView.contentOffset.y);
        self.containerScrollView.contentOffset = CGPointMake(self.containerScrollView.contentOffset.x, jumpToOffsetY);
        [self.containerScrollView setContentOffset:CGPointMake(self.containerScrollView.contentOffset.x, _webViewOffsetY) animated:YES];
        
    } else if (_natantStyle == TTDetailNatantStyleInsert || _natantStyle == TTDetailNatantStyleOnlyClick) {
        self.isShowingNatantOnClick = NO;
        
        [self footerScrollViewShowTopRectAnimated:NO];
        CGRect contentFooterViewFrame = _contentFooterView.frame;
        contentFooterViewFrame.origin.y = CGRectGetHeight(self.frame);
        [UIView animateWithDuration:0.25 animations:^{
            _contentFooterView.frame = contentFooterViewFrame;
        } completion:^(BOOL finished) {
            [self changeFooterStatus:TTDetailWebViewFooterStatusNoDisplay];
            [self footerScrollViewShowTopRectAnimated:NO];
            [_contentFooterView removeFromSuperview];
            if (_natantStyle == TTDetailNatantStyleInsert) {
                _contentFooterView.top = [self originYForFooterView];
                [_containerScrollView addSubview:_contentFooterView];
            }
        }];
        if (_delegate && [_delegate respondsToSelector:@selector(webViewWillCloseFooter)]) {
            [_delegate webViewWillCloseFooter];
        }
    }
}


#pragma mark --Scroll FooterView to Specific Status

- (void)scrollWebViewContentOffset:(CGPoint)point animated:(BOOL)animated
{
    [_webView.scrollView setContentOffset:point animated:animated];
}

/**
 *  footer 中如果有scrollview， 将scroll view 显示顶部
 *
 *  @param animated 是否显示动画
 */
- (void)footerScrollViewShowTopRectAnimated:(BOOL)animated
{
    [[_footerView footerScrollView] setContentOffset:CGPointMake(0, 0) animated:animated];
}


#pragma mark --- Track Stuff
- (NSInteger)pageCount
{
    NSInteger pageCount = 0; //页数
    
    float onePageHeight = _webView.scrollView.frame.size.height;
    
    if (onePageHeight == 0 || _webViewContentHeight == 0) {
        return 0;
    }
    pageCount = (NSInteger)ceilf(_webViewContentHeight / onePageHeight);
    return pageCount;
    
}

- (float)readPCTValue
{
    if (_webViewContentHeight == 0) {
        return 0;
    }
    CGFloat pct = (_currentMaxOffsetY + _webView.height) / _webViewContentHeight;
    pct = MIN(1, pct);
    return pct;
    
}

- (NSMutableDictionary *)readUnitStayTimeImpressionGroup
{
    [_unitStayTimeAccumulator stopAccumulating];
    
    NSMutableDictionary * impressionGroup = [NSMutableDictionary dictionaryWithCapacity:5];
    NSMutableArray * impressions = [NSMutableArray arrayWithCapacity:10];
    
    [impressionGroup setValue:@(SSImpressionGroupTypeExploreDetail) forKey:@"list_type"];
    NSString * sID = [[TTTrackerWrapperSessionHandler sharedHandler] sessionID];
    [impressionGroup setValue:sID forKey:@"session_id"];
    
    for (NSUInteger i = 0; i < [_unitStayTimeAccumulator.totalStayTimes count]; ++i) {
        NSDictionary * impression = @{ @"id" : @(i),
                                       @"type" : @(SSImpressionModelTypeExploreDetail),
                                       @"time" : _unitStayTimeAccumulator.recordTimes[i],
                                       @"duration" : _unitStayTimeAccumulator.totalStayTimes[i],
                                       @"max_duration" : _unitStayTimeAccumulator.maxStayTimes[i]};
        [impressions addObject:impression];
    }
    
    [impressionGroup setValue:impressions forKey:@"impression"];
    
    return impressionGroup;
}

- (void)setNatantStyle:(TTDetailNatantStyle)natantStyle {
    if (_natantStyle == natantStyle) {
        return;
    }
    _natantStyle = natantStyle;
    [self.KVOController unobserve:self.footScrollView];
    [self addFooterKVOController];
    [self removeDivFromWebViewIfNeeded];
    [self insertDivToWebViewIfNeed];
}

- (UIButton *)placeHolderView {
    if (!_placeHolderView) {
        _placeHolderView = [[UIButton alloc] initWithFrame:self.webView.bounds];
        _placeHolderView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _placeHolderView.enabled = NO;
    }
    return _placeHolderView;
}
@end

