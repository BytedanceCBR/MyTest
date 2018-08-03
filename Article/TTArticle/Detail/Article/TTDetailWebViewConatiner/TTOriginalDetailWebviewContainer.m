//
//  TTOriginalDetailWebviewContainer.m
//  Article
//
//  Created by muhuai on 11/10/2016.
//
//

#import "TTOriginalDetailWebviewContainer.h"
#import "TTDetailWebviewContainer.h"
#import "NSObject+MultiDelegates.h"
#import "NSDictionary+TTAdditions.h"
#import "TTArticleDetailDefine.h"
#import "TTDetailWebviewContainer+JSImageVideoLogic.h"
#import "UnitStayTimeAccumulator.h"
#import "SSImpressionGroup.h"
#import "TTTrackerWrapperSessionHandler.h"
#import "TTIndicatorView.h"
#import "TTDetailWebViewRequestProcessor.h"
#import "TTLoadMoreView.h"
#import "SSWebViewUtil.h"
#import "ExploreEntryManager.h"
//#import "ExploreEntryHelper.h"
#import "ExploreDetailMixedVideoADView.h"
#import "TTUIResponderHelper.h"

//#import "UIApplication+Addition.h"
#import "SSJSBridgeWebViewDelegate.h"

#import "TTNetworkManager.h"
#import "H5WebKitBugsManager.h"
#import "TTFirstConcernManager.h"
#import "TTThemeManager.h"
#import <TTAccountBusiness.h>
#import "FriendDataManager.h"

#define kFooterDivKey @"toutiao_ios_footer_div"

#define kFooterDisplayNotManualCloseDistance -30    //点击按钮打开浮层，下啦该距离收起
#define kInsertFooterOpenDistance 20                //insert类型浮层， 滑倒webview底部，上啦该距离打开浮层

#define UnitHeightScaleFactor 1

// 非强制登录的策略下，未登录状态下的点击订阅次数值
//static NSInteger subscribeCount = 0;

@interface TTOriginalDetailWebviewContainer () <UIScrollViewDelegate, YSWebViewDelegate>
{
    CGFloat _currentMaxOffsetY;
    CGFloat _unitHeight;
    BOOL _isWebViewVisible;
    BOOL _hasFirstCommentShown;
    BOOL _hasWebViewDidFinishCalled;
}
@property (nonatomic, strong, readwrite) ArticleJSBridgeWebView * webView;
@property (nonatomic, strong) SSThemedView * contentFooterView;
@property (nonatomic, assign, readwrite) TTDetailWebViewFooterStatus footerStatus;
@property (nonatomic, strong) UIView<TTDetailFooterViewProtocol> * footerView;
@property (nonatomic, assign) BOOL isWebViewContentSizeChanged;
@property (nonatomic, assign) BOOL hasAddNatantLoadingView;
@property (nonatomic, assign) BOOL isShowingNatantScrollView;    //是否正在评论区滚动

@property (nonatomic, assign) BOOL isShowingNatantOnClick;    //是否是点击评论按钮打开的浮层 这种情况下浮层的superView是self 而不是webview的scrollview 加这个属性是因为 如果用户主动点开了评论浮层 footerStatus 的一些计算会出问题，可能把状态改成TTDetailWebViewFooterStatusDisplayNotManual 之外的，然后由于现在insertDiv 依赖这个条件，可能导致 浮层的superveiw发生变化


@property (nonatomic, strong) UIScrollView * footScrollView;
@property (nonatomic, strong) UIView * coverView; //夜间模式的cover
@property (nonatomic, strong) TTLoadMoreView *natantLoadingView;

//统计用计时器
@property (nonatomic ,strong) UnitStayTimeAccumulator * unitStayTimeAccumulator;
//webview request 的处理单元
@property (nonatomic ,strong) TTDetailWebViewRequestProcessor * requestProcessor;

@property (nonatomic, strong) NSString *subscribeJSCallbackID;
@property (nonatomic, strong) NSString *unSubscribeJSCallbackID;

@end


@implementation TTOriginalDetailWebviewContainer

@synthesize webView = _webView, footerStatus = _footerStatus, delegate = _delegate, webViewContentHeight = _webViewContentHeight, movieView = _movieView, needCover = _needCover, natantStyle = _natantStyle;

- (void)dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    _webView.scrollView.delegate = nil;
    [_webView removeDelegate:self];
    @try {
        [self.webView.scrollView removeObserver:self forKeyPath:@"contentSize"];
        [self.webView.scrollView removeObserver:self forKeyPath:@"scrollsToTop"];
        
        [self.footerView removeObserver:self forKeyPath:@"footerScrollView"];
        
    }
    @catch (NSException *exception) {
        NSLog(@"opps, kvo dealloc crashed");
    }
    @finally {
        
    }
    
    self.footerView = nil;
    self.contentFooterView = nil;
    
    self.downloadManager.delegate = nil;
    [self.downloadManager cancelAll];
    
    [self.movieView removeFromSuperview];
    [self.movieView stopMovie];
}

- (id)initWithFrame:(CGRect)frame disableWKWebView:(BOOL)disableWKWebView ignoreGlobalSwitchKey:(BOOL)ignore hiddenWebView:(ArticleJSBridgeWebView *)hiddenWebView webViewDelegate:(SSJSBridgeWebViewDelegate *)jsBridgeDelegate {
    
    self = [super initWithFrame:frame];
    if (self) {
        [H5WebKitBugsManager fixAllBugs];
        
        //        self.webViewDayColor = [UIColor whiteColor];
        //        self.webViewNightColor = [UIColor colorWithHexString:@"252525"];
        self.requestProcessor = [[TTDetailWebViewRequestProcessor alloc] init];
        
        if (hiddenWebView) {
            // 存在针对移动建站落地页的预加载的webview
            self.webView = hiddenWebView;
            self.webView.frame = self.bounds;
            self.webView.layer.opacity = 1.0;
            // 修正self.webView的delegate
            self.webView.delegate = jsBridgeDelegate;
        } else {
            //基础JSBridgeWebView
            // 原来的流程
            self.webView = [[ArticleJSBridgeWebView alloc] initWithFrame:self.bounds disableWKWebView:disableWKWebView ignoreGlobalSwitchKey:ignore];
        }
        _webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [_webView addDelegate:self];
        _webView.scrollView.bounces = YES;
        _webView.scrollView.delegate = self;
        [self addSubview:_webView];
        
        [_webView.scrollView addObserver:self forKeyPath:@"contentSize" options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew context:nil];
        [_webView.scrollView addObserver:self forKeyPath:@"scrollsToTop" options:NSKeyValueObservingOptionNew context:nil];
        
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
    _isWebViewVisible = NO;
    
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
    if ([TTDeviceHelper isPadDevice]) {
        //        _webView.frame = self.bounds;
        //        _footerView.frame = self.bounds;
        //        CGRect frame = _contentFooterView.frame;
        //        frame.size = self.bounds.size;
        //        _contentFooterView.frame = frame;
        [self updateDivWhenWebViewDidRotate];
    }
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
    if (_isWebViewVisible) {
        [self webViewDidAppear];
    }
}

- (void)willDisappear
{
    if (_isWebViewVisible) {
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
    return NO;
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

//- (void)themeChanged:(NSNotification*)notification {
//    [self refreshCoverView];
//}

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

- (CGFloat)webViewContentHeight {
    CGFloat height = _webView.scrollView.contentSize.height;
    if (self.natantStyle == TTDetailNatantStyleAppend) {
        height -= _footerView.height;
    }
    return height;
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
    return (_footerStatus == TTDetailWebViewFooterStatusDisplayTotal || _footerStatus == TTDetailWebViewFooterStatusDisplayNotManual);
}

- (BOOL)isManualPullFooter {
    return _footerStatus != TTDetailWebViewFooterStatusDisplayNotManual;
}

#pragma mark footer operation

- (void)addFooterView:(UIView<TTDetailFooterViewProtocol> *)footerView
  detailFooterAddType:(TTDetailNatantStyle)natantStyle
{
    self.natantStyle = natantStyle;
    
    self.footerView = footerView;
    
    [self.footerView addObserver:self forKeyPath:@"footerScrollView" options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew context:nil];
    
    
    [[self.footerView footerScrollView] tt_addDelegate:self asMainDelegate:NO];
    self.footScrollView = self.footerView.footerScrollView;
    self.footerView.frame = self.bounds;
    //footerScrollView被赋值后，刷新scrollEnable和scrollToTop的状态；
    self.footerStatus = self.footerStatus;
    
    self.footerView.autoresizingMask = UIViewAutoresizingFlexibleWidth/* | UIViewAutoresizingFlexibleHeight*/;
    
    if ([self shouldOpenInsertionOptimization]) {
        [self addFooterView];
    }
    else {
        //dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self addFooterView];
        //});
    }
}

- (BOOL)shouldOpenInsertionOptimization
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(supportFooterInsertionOptimization)]) {
        if ([self.delegate supportFooterInsertionOptimization]) {
            return YES;
        }
    }
    return NO;
}

- (void)addFooterView
{
    [self removeNatantLoadingView];
    [self.contentFooterView addSubview:self.footerView];
}

- (void)removeFooterView
{
    [_footerView removeFromSuperview];
    _footerView = nil;
    [_contentFooterView removeFromSuperview];
}

- (void)refreshNatantLocation
{
    CGFloat originY = [self originYForFooterView] - CGRectGetHeight(_webView.frame);
    originY = MAX(0, originY);
    [self scrollWebViewContentOffset:CGPointMake(0, originY) animated:NO];
}

- (BOOL)willFooterShownOutsideScreenArea
{
    CGFloat contentFooterViewTop = self.webView.scrollView.contentSize.height - self.webView.height;
    return contentFooterViewTop > screenAdaptiveForFloatValue(self.webView.height);
}

- (void)insertDivToWebViewIfNeed
{
    if (_contentFooterView.superview == _webView.scrollView) {
        NSString *hasFooterDiv = [_webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"!!document.querySelector('#%@');", kFooterDivKey] completionHandler:nil];
        if ([hasFooterDiv isEqualToString:@"true"]) {
            if ([self willFooterShownOutsideScreenArea]) {
                _contentFooterView.hidden = NO;
            }
            return;
        }
    }
    
    if (self.natantStyle == TTDetailNatantStyleAppend) {
        [_webView evaluateJavaScriptFromString:[NSString stringWithFormat:@" \
                                                (function(){var customDiv = document.querySelector(\"#%@\"); \
                                                if (customDiv) {\
                                                document.body.removeChild(customDiv)\
                                                }\
                                                var ele = document.createElement('div'); \
                                                ele.setAttribute('id', '%@'); \
                                                ele.setAttribute('style', 'width: 100%%; height: %fpx; clear: both;'); \
                                                document.body.appendChild(ele);})();\
                                                ", kFooterDivKey, kFooterDivKey, _webView.frame.size.height] completionBlock:nil];
        
        //如果这时候用户手动打开了浮层 就不添加到webview的scrollview上
        if(_footerStatus != TTDetailWebViewFooterStatusDisplayNotManual) {
            [_webView.scrollView addSubview:_contentFooterView];
            _contentFooterView.hidden = YES;
            [self addNatantLoadingViewIfNeeded];
        }
        //remove后立即insertDIV不会触发contentsize的KVO 手动触发KVO @zengruihuan
        [_webView.scrollView willChangeValueForKey:@"contentSize"];
        [_webView.scrollView didChangeValueForKey:@"contentSize"];
    }
}

//info下发natant_level发生变化时，更新div
- (void)removeDivFromWebViewIfNeeded
{
    [_webView evaluateJavaScriptFromString:[NSString stringWithFormat:@" \
                                            var customDiv = document.querySelector(\"#%@\"); \
                                            if (customDiv) {\
                                            var ele = document.getElementById('%@'); \
                                            document.body.removeChild(ele);\
                                            }", kFooterDivKey, kFooterDivKey]completionBlock:nil];
    if (_contentFooterView.superview == _webView.scrollView) {
        [_contentFooterView removeFromSuperview];
    }
}

- (void)updateDivWhenWebViewDidRotate
{
    if (self.natantStyle == TTDetailNatantStyleAppend) {
        
        [_webView evaluateJavaScriptFromString:[NSString stringWithFormat:@" \
                                                var customDiv = document.querySelector(\"#%@\"); \
                                                if (customDiv) {\
                                                var ele = document.getElementById('%@'); \
                                                ele.setAttribute('style', 'width: 100%%; height: %fpx; clear: both;'); \
                                                document.body.appendChild(ele);\
                                                }", kFooterDivKey, kFooterDivKey, _webView.frame.size.height]completionBlock:nil];
    }
}

- (void)addNatantLoadingViewIfNeeded
{
    if (self.footerView || self.hasAddNatantLoadingView ||
        !self.isWebViewContentSizeChanged) {
        return;
    }
    CGRect frame = CGRectMake(0, 28.f, self.bounds.size.width, kTTPullRefreshHeight);
    self.natantLoadingView = [[TTLoadMoreView alloc] initWithFrame:frame pullDirection:PULL_DIRECTION_UP];
    self.natantLoadingView.state = PULL_REFRESH_STATE_LOADING;
    [self.contentFooterView addSubview:self.natantLoadingView];
    self.hasAddNatantLoadingView = YES;
}

- (void)removeNatantLoadingView
{
    [self.natantLoadingView removeFromSuperview];
}

#pragma mark WebView Delegate

- (void)webViewDidStartLoad:(nullable YSWebView *)webView {
    
    if ([self.delegate respondsToSelector:_cmd]) {
        [self.delegate webViewDidStartLoad:webView];
    }
}


- (void)webViewDidFinishLoad:(nullable YSWebView *)webView {
    _hasWebViewDidFinishCalled = YES;
    if ([self.delegate respondsToSelector:_cmd]) {
        [self.delegate webViewDidFinishLoad:webView];
    }
    [self insertDivToWebViewIfNeed];
}

- (void)webviewDidLayoutSubviews:(YSWebView *)webview {
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




#pragma mark UIScrollView Delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    //    if (_keyboardShowing) {
    //        return;
    //    }
    //    if (![self enableFooter]) {
    //        return;
    //    }
    
    if (scrollView != self.webView.scrollView) {
        self.isShowingNatantScrollView = YES;
        if (self.natantStyle == TTDetailNatantStyleAppend) {
            if (_footerStatus == TTDetailWebViewFooterStatusDisplayTotal) {
                if ((scrollView.contentOffset.y > MIN(30, scrollView.contentSize.height - CGRectGetHeight(scrollView.frame) - 30))) {
                    if (!scrollView.bounces) {
                        scrollView.bounces = YES;
                        //解决手动滚到评论最下面时无法上拉的bug
                        //                        _webView.scrollView.bounces = YES;
                    }
                }
                else {
                    if (scrollView.bounces) {
                        scrollView.bounces = NO;
                    }
                }
            }
        }
        else
            _webView.scrollView.bounces = YES;
    }
    else if(scrollView == _webView.scrollView) {
        //        SSLog(@"scrollView contentOffset %f", scrollView.contentOffset.y);
        //        SSLog(@"scrollView contentSize   %f", scrollView.contentSize.height);
        TTDetailWebViewFooterStatus originStatus = _footerStatus;
        if (scrollView.contentOffset.y > _currentMaxOffsetY) {
            _currentMaxOffsetY = scrollView.contentOffset.y;
        }
        
        if (_footerStatus != TTDetailWebViewFooterStatusDisplayNotManual) {
            [self refreshFooterStatusWithChange:nil];
        }
        
        if (self.natantStyle == TTDetailNatantStyleAppend) {
            if (scrollView.contentOffset.y > CGRectGetHeight(scrollView.frame) / 2) {
                if (_webView.scrollView.bounces && !_isShowingNatantScrollView) {
                    _webView.scrollView.bounces = NO;
                }
            }
            else {
                if (!_webView.scrollView.bounces) {
                    _webView.scrollView.bounces = YES;
                }
            }
        }
        else if (self.natantStyle == TTDetailNatantStyleInsert) {
            if (_footerStatus == TTDetailWebViewFooterStatusNoDisplay ||
                _footerStatus == TTDetailWebViewFooterStatusDisplayHalf) {
                CGFloat detla = (scrollView.contentOffset.y + scrollView.frame.size.height) - MAX(scrollView.contentSize.height, scrollView.frame.size.height);
                if (detla > 0) {
                    if (_contentFooterView.superview != self) {
                        [_contentFooterView removeFromSuperview];
                        [self addSubview:_contentFooterView];
                    }
                    CGRect frame = _contentFooterView.frame;
                    frame.origin.y = CGRectGetMaxY(_webView.frame) - detla;
                    _contentFooterView.frame = frame;
                    if (detla > 0) {
                        if (_footerStatus != TTDetailWebViewFooterStatusDisplayHalf) {
                            [self changeFooterStatus:TTDetailWebViewFooterStatusDisplayHalf];
                        }
                    }
                }
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
        if (_isWebViewVisible) {
            _unitStayTimeAccumulator.currentOffset = scrollView.contentOffset.y;
        }
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
    else if (scrollView == _webView.scrollView) {
        if (_footerStatus == TTDetailWebViewFooterStatusDisplayHalf) {
            if ((scrollView.contentOffset.y + scrollView.frame.size.height) > (MAX(scrollView.contentSize.height, scrollView.frame.size.height) + kInsertFooterOpenDistance)) {
                [self openFooterView:NO];
            }
        }
    }
}

#pragma mark -- Footer Status Change

- (CGFloat)originYForFooterView
{
    CGFloat originY = 0;
    if (self.natantStyle == TTDetailNatantStyleAppend) {
        originY = _webView.scrollView.contentSize.height - CGRectGetHeight(_webView.frame);
    }
    else if (self.natantStyle == TTDetailNatantStyleInsert) {
        if (_footerStatus == TTDetailWebViewFooterStatusDisplayNotManual) {
            originY = 0;
        }
        else {
            originY = _webView.scrollView.contentSize.height - CGRectGetHeight(_webView.frame);
        }
    }
    originY = MAX(originY, 0);
    return originY;
}

- (void)refreshFooterStatusWithChange:(NSDictionary *)change
{
    if (self.natantStyle == TTDetailNatantStyleAppend) {
        CGFloat originY = [self originYForFooterView];
        
        //解决在footer total状态的评论区改变字体时出现的浮层错位问题
        if (self.footerStatus == TTDetailWebViewFooterStatusDisplayTotal) {
            CGSize oldSize = [((NSValue *)[change objectForKey:@"old"]) CGSizeValue];
            CGSize newSize = [((NSValue *)[change objectForKey:@"new"]) CGSizeValue];
            if (!CGSizeEqualToSize(newSize, CGSizeZero)) {
                CGFloat offset = newSize.height - oldSize.height;
                if (offset > 0) {
                    CGPoint newOffset = CGPointMake(0, _webView.scrollView.contentOffset.y + offset);
                    [_webView.scrollView setContentOffset:newOffset];
                }
            }
        }
        
        if (_webView.scrollView.contentOffset.y > 0 &&
            screenAdaptiveForFloatValue(_webView.scrollView.contentOffset.y) >= screenAdaptiveForFloatValue(originY)) {
            [self changeFooterStatus:TTDetailWebViewFooterStatusDisplayTotal];
        }
        else if (_webView.scrollView.contentOffset.y > 0 &&
                 screenAdaptiveForFloatValue(_webView.scrollView.contentOffset.y) >= screenAdaptiveForFloatValue(originY - _webView.height))
        {
            [self changeFooterStatus:TTDetailWebViewFooterStatusDisplayHalf];
        }
        else {
            
            [self changeFooterStatus:TTDetailWebViewFooterStatusNoDisplay];
        }
        
        CGFloat offset = originY - MAX((self.webView.height - ((UITableView *)self.footerView.footerScrollView).tableHeaderView.height), 0);
        if (!_hasFirstCommentShown) {
            if (_webView.scrollView.contentOffset.y > 0 &&
                screenAdaptiveForFloatValue(_webView.scrollView.contentOffset.y) >= offset) {
                if (_delegate && [_delegate respondsToSelector:@selector(webViewContainerWillShowFirstCommentCellByScrolling)]) {
                    [_delegate webViewContainerWillShowFirstCommentCellByScrolling];
                }
                _hasFirstCommentShown = YES;
            }
        }
        
        if (self.footerStatus == TTDetailWebViewFooterStatusDisplayHalf) {
            if (_delegate && [_delegate respondsToSelector:@selector(webViewContainerInFooterHalfShowStatusWithScrollOffset:)]) {
                if (screenAdaptiveForFloatValue(_webView.scrollView.contentOffset.y) >= offset) {
                    //展示的评论发送recording impression
                    CGFloat halfStatusBeginOrinY = offset;
                    CGFloat relativeOffset = MAX(_webView.scrollView.contentOffset.y - halfStatusBeginOrinY, 0);
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
}

- (void)changeFooterStatus:(TTDetailWebViewFooterStatus)status
{
    if (_footerStatus != status && !self.isShowingNatantOnClick) {
        self.footerStatus = status;
    }
}

- (void)setFooterStatus:(TTDetailWebViewFooterStatus)footerStatus
{
    _footerStatus = footerStatus;
    _footScrollView.bounces = NO;
    
    switch (footerStatus) {
        case TTDetailWebViewFooterStatusDisplayTotal: {
            
            _footScrollView.scrollEnabled = YES;
            _footScrollView.scrollsToTop = YES;
            _webView.scrollView.scrollsToTop = NO;
            break;
        }
        case TTDetailWebViewFooterStatusDisplayNotManual: {
            
            _footScrollView.scrollEnabled = YES;
            _footScrollView.bounces = YES;
            _footScrollView.scrollsToTop = YES;
            _webView.scrollView.scrollsToTop = NO;
            break;
        }
        default: {
            
            _footScrollView.scrollEnabled = NO;
            _footScrollView.scrollsToTop = NO;
            _webView.scrollView.scrollsToTop = YES;
            self.isShowingNatantScrollView = NO;
            break;
        }
            
    }
}

#pragma mark -- kvo observer

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"contentSize"]) {
        [self refreshWebViewContentSizeChangeDict:change];
        [self refreshFootViewOriginPoint];
        [self refreshFooterStatusWithChange:change];
        [self execShowContentFooterAtLastOnceIfNeeded];
        if (_delegate && [_delegate respondsToSelector:@selector(webViewDidChangeContentSize)]) {
            [_delegate webViewDidChangeContentSize];
        }
        //tracker
        _unitStayTimeAccumulator.maxOffset = _webView.scrollView.contentSize.height;
    } else if ([keyPath isEqualToString:@"scrollsToTop"]) {
        if (_isWebViewVisible != _webView.scrollView.scrollsToTop) {
            if (_isWebViewVisible) {
                [self webViewWillDisappear];
            } else {
                [self webViewDidAppear];
            }
            _isWebViewVisible = _webView.scrollView.scrollsToTop;
        }
    }
    if ([keyPath isEqualToString:@"footerScrollView"]) {
        
        if (![self.footScrollView isEqual:[change objectForKey:@"new"]]) {
            
            [self.footScrollView tt_removeDelegate:self];
            
            [[self.footerView footerScrollView] tt_addDelegate:self asMainDelegate:NO];
            self.footScrollView = self.footerView.footerScrollView;
            
            [self refreshFooterStatusWithChange:nil];
        }
    }
}

- (void)setWebContentOffset:(CGPoint)offset {
    self.webView.scrollView.contentOffset = offset;
}

- (void)execShowContentFooterAtLastOnceIfNeeded
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(showContentFooterAtLast) object:nil];
    [self performSelector:@selector(showContentFooterAtLast) withObject:nil afterDelay:0.5];
}

- (void)showContentFooterAtLast
{
    if (self.contentFooterView.hidden) {
        self.contentFooterView.hidden = NO;
    }
}

- (void)refreshWebViewContentSizeChangeDict:(NSDictionary *)change
{
    CGSize oldSize = [((NSValue *)[change objectForKey:@"old"]) CGSizeValue];
    CGSize newSize = [((NSValue *)[change objectForKey:@"new"]) CGSizeValue];
    if (!CGSizeEqualToSize(oldSize, newSize)) {
        self.isWebViewContentSizeChanged = YES;
        //        [self insertDivToWebViewIfNeed];
    }
}

- (void)refreshFootViewOriginPoint
{
    if (_footerStatus == TTDetailWebViewFooterStatusNoDisplay ||
        _footerStatus == TTDetailWebViewFooterStatusDisplayHalf ||
        _footerStatus == TTDetailWebViewFooterStatusDisplayTotal) {
        CGRect frame = _webView.frame;
        frame.origin = CGPointMake(0, [self originYForFooterView]);
        //fix:第三方新闻查看图片浮层弹上来的bug
        if (_footerStatus == TTDetailWebViewFooterStatusNoDisplay) {
            if (frame.origin.y > 0) {
                _contentFooterView.frame = frame;
            }
        }
        else {
            _contentFooterView.frame = frame;
        }
    }
    else if (_footerStatus == TTDetailWebViewFooterStatusDisplayNotManual){
        if (_contentFooterView.superview != self) {
            [_contentFooterView removeFromSuperview];
        }
        if (_contentFooterView.superview == nil) {
            [self addSubview:_contentFooterView];
        }
        [_contentFooterView.superview bringSubviewToFront:_contentFooterView];
        CGPoint origin = self.frame.origin;
        if (origin.x != 0 || origin.y != 0) {
            _contentFooterView.origin = CGPointMake(0, 0);
        }
    }
}


#pragma Open/Close FooterView

- (void)openFooterView:(BOOL)isSendComment
{
    if (self.natantStyle == TTDetailNatantStyleInsert || self.natantStyle == TTDetailNatantStyleOnlyClick) {
        if (_footerStatus != TTDetailWebViewFooterStatusDisplayNotManual) {
            [self changeFooterStatus:TTDetailWebViewFooterStatusDisplayNotManual];
            CGFloat originY = _contentFooterView.superview == nil ? CGRectGetHeight(_webView.frame) : CGRectGetMinY(_contentFooterView.frame);
            [self _openFooterNotManualOriginY:originY];
        }
    }
    else if (self.natantStyle == TTDetailNatantStyleAppend) {
        if (_footerStatus == TTDetailWebViewFooterStatusDisplayHalf) {
            [self scrollFooterViewToDisplayStatusAnimated:YES];
        }
        else if (_footerStatus == TTDetailWebViewFooterStatusNoDisplay) {
            [self _openFooterNotManualOriginY:CGRectGetHeight(_webView.frame)];
        }
        else {
            //do nothing
        }
    }
}

- (void)_openFooterNotManualOriginY:(CGFloat)originY
{
    [_contentFooterView removeFromSuperview];
    
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


- (void)closeFooterView
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kDetailVideoADDisappearNotification object:nil];
    
    if (_footerStatus == TTDetailWebViewFooterStatusDisplayTotal) {
        [self scrollFooterViewToNoDisplayStatusAnimated:YES];
        [self footerScrollViewShowTopRectAnimated:NO];
    }
    else if (_footerStatus == TTDetailWebViewFooterStatusDisplayNotManual) {
        
        self.isShowingNatantOnClick = NO;
        
        [self footerScrollViewShowTopRectAnimated:NO];
        CGRect contentFooterViewFrame = _contentFooterView.frame;
        contentFooterViewFrame.origin.y = CGRectGetHeight(self.frame);
        [UIView animateWithDuration:0.25 animations:^{
            _contentFooterView.frame = contentFooterViewFrame;
        } completion:^(BOOL finished) {
            [self footerScrollViewShowTopRectAnimated:NO];
            [_contentFooterView removeFromSuperview];
            if (self.natantStyle == TTDetailNatantStyleAppend && _hasWebViewDidFinishCalled) {
                [_webView.scrollView addSubview:_contentFooterView];
            }
            CGRect frame = _contentFooterView.frame;
            frame.origin.y = [self originYForFooterView];
            _contentFooterView.frame = frame;
            if (self.natantStyle == TTDetailNatantStyleAppend) {
                [self refreshFooterStatusWithChange:nil];
            }
            else if (self.natantStyle == TTDetailNatantStyleInsert || self.natantStyle == TTDetailNatantStyleOnlyClick){
                [self changeFooterStatus:TTDetailWebViewFooterStatusNoDisplay];
            }
            
            //浮层relatedItem impression相关
            // ExploreSuperNatantView *superNatantView = (ExploreSuperNatantView *)_footerView;
            // [superNatantView resetAllRelatedItemsWhenNatantDisappear];
        }];
        if (_delegate && [_delegate respondsToSelector:@selector(webViewWillCloseFooter)]) {
            [_delegate webViewWillCloseFooter];
        }
    }
    else {
        // do nothing...
    }
}


#pragma mark --Scroll FooterView to Specific Status

/**
 *  滑动footer到底部打开状态
 *
 *  @param animated 是否有动画
 */
- (void)scrollFooterViewToDisplayStatusAnimated:(BOOL)animated
{
    CGFloat originY = [self originYForFooterView];
    [self scrollWebViewContentOffset:CGPointMake(0, originY) animated:animated];
    
    [self refreshFooterStatusWithChange:nil];
}
/**
 *  滑动footer到webview底部但不露出footer的位置
 *
 *  @param animated 是否有动画
 */
- (void)scrollFooterViewToNoDisplayStatusAnimated:(BOOL)animated
{
    CGFloat originY = [self originYForFooterView] - CGRectGetHeight(_webView.frame);
    
    originY = MAX(0, originY);
    [self scrollWebViewContentOffset:CGPointMake(0, originY) animated:animated];
    
    [self refreshFooterStatusWithChange:nil];
}

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
    
    CGFloat contentHeight = _webView.scrollView.contentSize.height;
    if (self.natantStyle == TTDetailNatantStyleAppend) {
        contentHeight -= _webView.scrollView.frame.size.height;
    }
    float onePageHeight = _webView.scrollView.frame.size.height;
    
    if (onePageHeight == 0 || contentHeight == 0) {
        return 0;
    }
    pageCount = (NSInteger)ceilf(contentHeight / onePageHeight);
    return pageCount;
    
}

- (float)readPCTValue
{
    CGFloat contentHeight = _webView.scrollView.contentSize.height;
    if (self.natantStyle == TTDetailNatantStyleAppend) {
        contentHeight -= _webView.scrollView.frame.size.height;
    }
    if (contentHeight == 0) {
        return 0;
    }
    CGFloat pct = (_currentMaxOffsetY + _webView.scrollView.frame.size.height) / contentHeight;
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


#pragma mark 订阅的JSBridge

- (void)registerSubscribJS {
    
    //订阅
    __weak typeof(self) wself = self;
    [self.webView.bridge registerHandlerBlock:^NSDictionary *(NSString *callbackId, NSDictionary *result, NSString *JSSDKVersion, BOOL *executeCallback) {
        if (executeCallback) {
            *executeCallback = NO;
        }
        wself.subscribeJSCallbackID = callbackId;
        
        TTAccountLoginAlertTitleType type = TTAccountLoginAlertTitleTypePGCLike;
        NSString *source = @"article_detail_pgc_like";
        NSInteger subscribeCount = [SSCommonLogic subscribeCount];
        
        if ([SSCommonLogic detailActionType] == 0) {
            // 策略0: 不需要登录
            // 订阅操作都会正常进行,进行订阅操作
            [wself subscribe:result];
        } else if ([SSCommonLogic detailActionType] == 1) {
            // 策略1: 强制登录，需要客户端判断用户的登录状态
            if ([TTAccountManager isLogin]) {
                // 如果用户已经登录，不出现弹窗，订阅操作会正常进行
                [wself subscribe:result];
            } else if (![TTAccountManager isLogin]) {
                // 用户处于未登录状态，需要进行强制登录，用户不登录的话无法使用后续功能
                [TTAccountManager showLoginAlertWithType:type source:source completion:^(TTAccountAlertCompletionEventType type, NSString *phoneNum) {
                    if (type == TTAccountAlertCompletionEventTypeDone) {
                        // 如果登录成功，后续功能会照常进行
                        // 进行订阅操作
                        [wself subscribe:result];
                    } else if (type == TTAccountAlertCompletionEventTypeCancel) {
                        // 如果退出登录，登录不成功，则后续功能不会进行
                        // 添加订阅失败的统计埋点
                        [wself p_sendSubscribeTrackWithLabel:@"pgc_subscribe_fail" concernType:[result tt_stringValueForKey:@"concern_type"]];
                        //   NSLog(@"退出登录，登录不成功，订阅操作不进行");
                    } else if (type == TTAccountAlertCompletionEventTypeTip) {
                        [TTAccountManager presentQuickLoginFromVC:[TTUIResponderHelper topNavigationControllerFor:wself] type:TTAccountLoginDialogTitleTypeDefault source:source subscribeCompletion:^(TTAccountLoginState state) {
                            if (state == TTAccountLoginStateLogin) {
                                // 如果登录成功，则进行订阅过程
//                                [wself subscribe:result];
                            } else if (state == TTAccountLoginStateCancelled) {
                                // 添加订阅失败的统计埋点
                                [wself p_sendSubscribeTrackWithLabel:@"pgc_subscribe_fail" concernType:[result tt_stringValueForKey:@"concern_type"]];
                            }
                        }];
                    }
                }];
            }
        } else if ([SSCommonLogic detailActionType] == 2) {
            // 策略2: 非强制登录，需要客户端判断用户的登录状态
            if ([TTAccountManager isLogin]) {
                // 如果用户已登录，不出现弹窗，订阅操作会正常进行
                [wself subscribe:result];
            } else if (![TTAccountManager isLogin]) {
                // 用户处于未登录状态，进行非强制登录弹窗
                // 非强制登录的逻辑，根据当前文章详情页的点击订阅的次数进行弹窗判断的逻辑
                // 得到当前文章详情页的点击订阅的次数，进行判断
                subscribeCount++;
                BOOL countEqual = NO;
                for (NSNumber *tmp in [SSCommonLogic detailActionTick]) {
                    if (subscribeCount == tmp.integerValue) {
                        countEqual = YES;
                        // 如果等于某次非强制登录弹窗的次数，则进行弹窗
                        [TTAccountManager showLoginAlertWithType:type source:source completion:^(TTAccountAlertCompletionEventType type, NSString *phoneNum) {
                            if (type == TTAccountAlertCompletionEventTypeDone) {
                                // 显示弹窗后，才进行订阅过程
                                [wself subscribe:result];
                            } else if (type == TTAccountAlertCompletionEventTypeCancel) {
                                // 显示弹窗后，才进行订阅过程
                                [wself subscribe:result];
                            } else if (type == TTAccountAlertCompletionEventTypeTip) {
                                [TTAccountManager presentQuickLoginFromVC:[TTUIResponderHelper topNavigationControllerFor:wself] type:TTAccountLoginDialogTitleTypeDefault source:source subscribeCompletion:^(TTAccountLoginState state) {
                                    if (state == TTAccountLoginStateLogin) {
                                        // 如果登录成功，则进行订阅过程
//                                        [wself subscribe:result];
                                    } else if (state == TTAccountLoginStateCancelled) {
                                        // 显示弹窗后，才进行订阅过程
                                        [wself subscribe:result];
                                    }
                                }];
                            }
                        }];
                        // 找到相等次数时，break跳出循环
                        break;
                    }
                }
                if (!countEqual) {
                    // 如果不是符合的次数，则直接进行订阅操作过程
                    [wself subscribe:result];
                }
            }
        }
        // 将点击订阅数持久化进NSUSerDefaults
        [SSCommonLogic setSubscribeCount:subscribeCount];
        
        //统计: 文章详情页点击订阅量
        [wself p_sendSubscribeTrackWithLabel:@"pgc_subscribe" concernType:[result tt_stringValueForKey:@"concern_type"]];
        
        return @{@"code": @(0)};
        
    } forJSMethod:@"do_media_like" authType:SSJSBridgeAuthPrivate];
    
    
    //取消订阅
    [self.webView.bridge registerHandlerBlock:^NSDictionary *(NSString *callbackId, NSDictionary *result, NSString *JSSDKVersion, BOOL *executeCallback) {
        if (executeCallback) {
            *executeCallback = NO;
        }
        wself.unSubscribeJSCallbackID = callbackId;
        
        ExploreEntry *entry = nil;
        NSArray *entries = nil;
        NSString *entryID = [result stringValueForKey:@"id" defaultValue:nil];
        NSString *uid = [result stringValueForKey: @"uid" defaultValue:nil];
        
        if (!isEmptyString(entryID)) {
            entries = [[ExploreEntryManager sharedManager] entryForEntryIDs:@[entryID]];
        }
        
        if(entries.count > 0) {
            entry = entries[0];
        }
        else if (!isEmptyString(entryID)) {
            NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
            [dic setValue:entryID forKey:@"id"];
            [dic setValue:@1 forKey:@"type"];
            [dic setValue:@1 forKey:@"subscribed"];
            [dic setValue:[NSNumber numberWithLongLong:entryID.longLongValue] forKey:@"media_id"];
            [dic setValue:entryID forKey:@"entry_id"];
            [dic setValue:uid forKey:@"user_id"];
            
            entry = [[ExploreEntryManager sharedManager] insertExploreEntry:dic save:YES];
        }
        
        //        NSString *userID = self.detailModel.article.mediaUserID;
        NSMutableDictionary *followDic = [NSMutableDictionary dictionary];
        [followDic setValue:uid forKey:@"id"];
        [followDic setValue:@(FriendFollowNewReasonUnknown) forKey:@"new_reason"];
        [followDic setValue:@(FriendFollowNewSourceNewsDetail) forKey:@"new_source"];
        
        //        [[ExploreEntryManager sharedManager] exploreEntry:entry
        //                                       changeToSubscribed:NO
        //                                                   notify:YES
        //                                        notifyFinishBlock:^(ExploreEntry * _Nullable entry, NSError * _Nullable error) {
        
        if (!TTNetworkConnected()) {
            [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage
                                      indicatorText:@"网络不给力，请稍后重试"
                                     indicatorImage:[UIImage themedImageNamed:@"close_popup_textpage"]
                                        autoDismiss:YES
                                     dismissHandler:nil];
            [wself.webView.bridge invokeJSWithCallbackID:wself.unSubscribeJSCallbackID parameters:@{@"code":@(0)}];
            return @{@"code": @(0)};
        }
        
        [[FriendDataManager sharedManager] unfollow:followDic completion:^(NSError * _Nullable error, NSDictionary * _Nullable result) {
            if (!wself) {
                [wself.webView.bridge invokeJSWithCallbackID:wself.unSubscribeJSCallbackID parameters:@{@"code":@(0)}];
                return;
            }
            //失败提示
            if (error) {
                if (error.code != TTNetworkErrorCodeNoNetwork) {
                    NSString *msg = @"取消关注失败";
                    [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage
                                              indicatorText:msg
                                             indicatorImage:nil
                                                autoDismiss:YES
                                             dismissHandler:nil];
                }
                [wself.webView.bridge invokeJSWithCallbackID:wself.unSubscribeJSCallbackID parameters:@{@"code":@(0)}];
                
                return ;
            }
            
            //成功才刷新
            if ([wself.delegate respondsToSelector:@selector(webContainer:pgcId:Subscribe:)]) {
                [wself.delegate webContainer:wself pgcId:entryID Subscribe:NO];
            }
            
            [wself.webView.bridge invokeJSWithCallbackID:wself.unSubscribeJSCallbackID parameters:@{@"code":@(1)}];
            
            //统计
            [wself p_sendSubscribeTrackWithLabel:@"pgc_unsubscribe" concernType:[result tt_stringValueForKey:@"concern_type"]];
        }];
        
        return @{@"code": @(0)};
        
    } forJSMethod:@"do_media_unlike" authType:SSJSBridgeAuthPrivate];
}

// 订阅操作
- (void)subscribe:(NSDictionary *)result {
    __weak typeof(self) wself = self;
    ExploreEntry *entry ;
    NSString * entryID = [result stringValueForKey:@"id" defaultValue:nil];
    NSArray *entries = [[ExploreEntryManager sharedManager] entryForEntryIDs:@[entryID]];
    NSString *uid = [result stringValueForKey: @"uid" defaultValue:nil];
    
    if (!isEmptyString(entryID)) {
        entries = [[ExploreEntryManager sharedManager] entryForEntryIDs:@[entryID]];
    }
    
    if(entries.count > 0)
    {
        entry = entries[0];
    }
    else if (!isEmptyString(entryID)) {
        NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
        [dic setValue:entryID forKey:@"id"];
        [dic setValue:@1 forKey:@"type"];
        [dic setValue:@0 forKey:@"subscribed"];
        [dic setValue:[NSNumber numberWithLongLong:entryID.longLongValue] forKey:@"media_id"];
        [dic setValue:entryID forKey:@"entry_id"];
        [dic setValue:uid forKey:@"user_id"];
        entry = [[ExploreEntryManager sharedManager] insertExploreEntry:dic save:YES];
    }
    
    NSMutableDictionary *followDic = [NSMutableDictionary dictionary];
    [followDic setValue:uid forKey:@"id"];
    [followDic setValue:@(FriendFollowNewReasonUnknown) forKey:@"new_reason"];
    if ([wself.delegate respondsToSelector:@selector(followNewSourceOfWebContainer:)]) {
        [followDic setValue:@([wself.delegate followNewSourceOfWebContainer:wself]) forKey:@"new_source"];
    }else {
        [followDic setValue:@(FriendFollowNewSourceNewsDetail) forKey:@"new_source"];
    }
    
    if (!TTNetworkConnected()) {
        [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage
                                  indicatorText:@"网络不给力，请稍后重试"
                                 indicatorImage:[UIImage themedImageNamed:@"close_popup_textpage"]
                                    autoDismiss:YES
                                 dismissHandler:nil];
        [self.webView.bridge invokeJSWithCallbackID:self.subscribeJSCallbackID parameters:@{@"code":@(0)}];
        return;
    }
    
    [[FriendDataManager sharedManager] follow:followDic completion:^(NSError * _Nullable error, NSDictionary * _Nullable result) {
        if (!wself) {
            [wself.webView.bridge invokeJSWithCallbackID:wself.subscribeJSCallbackID parameters:@{@"code":@(0)}];
            return;
        }
        //失败提示
        if (error) {
            // 添加订阅失败的统计埋点
            [wself p_sendSubscribeTrackWithLabel:@"pgc_subscribe_fail" concernType:[result tt_stringValueForKey:@"concern_type"]];
            
            if (error.code != TTNetworkErrorCodeNoNetwork) {
                NSString *msg = @"关注失败";
                [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage
                                          indicatorText:msg
                                         indicatorImage:nil
                                            autoDismiss:YES
                                         dismissHandler:nil];
            }
            [wself.webView.bridge invokeJSWithCallbackID:wself.subscribeJSCallbackID parameters:@{@"code":@(0)}];
            return ;
        }
        
        //成功才刷新
        if ([wself.delegate respondsToSelector:@selector(webContainer:pgcId:Subscribe:)]) {
            // 添加订阅成功的统计埋点
            [wself p_sendSubscribeTrackWithLabel:@"pgc_subscribe_success" concernType:[result tt_stringValueForKey:@"concern_type"]];
            
            [wself.delegate webContainer:wself pgcId:entryID Subscribe:YES];
        }
        BOOL showToast = YES;
        if ([TTFirstConcernManager firstTimeGuideEnabled]) {
            showToast = NO;
            TTFirstConcernManager *manager = [[TTFirstConcernManager alloc] init];
            [manager showFirstConcernAlertViewWithDismissBlock:nil];
        }
        
        [wself.webView.bridge invokeJSWithCallbackID:wself.subscribeJSCallbackID
                                          parameters:@{@"code":@(1),
                                                       @"showToast":@(showToast)}];
    }];
    
}

- (void)p_sendSubscribeTrackWithLabel:(NSString *)label concernType:(NSString *)concernType
{
    NSMutableDictionary *dict = nil;
    if (!isEmptyString(self.detailModel.article.itemID)) {
        dict = [NSMutableDictionary dictionary];
        [dict setValue:self.detailModel.article.itemID forKey:@"item_id"];
        [dict setValue:concernType forKey:@"concern_type"];
    }
    
    wrapperTrackEventWithCustomKeys(@"detail", label, [NSString stringWithFormat:@"%@", self.detailModel.article.mediaInfo[@"media_id"]], nil, dict);
}

- (void)setNatantStyle:(TTDetailNatantStyle)natantStyle {
    if (_natantStyle == natantStyle) {
        return;
    }
    _natantStyle = natantStyle;
    [self removeDivFromWebViewIfNeeded];
    [self insertDivToWebViewIfNeed];
}
@end
