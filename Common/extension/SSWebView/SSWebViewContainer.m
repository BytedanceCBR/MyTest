
//
//  SSWebViewContainer.m
//  Article
//
//  Created by Zhang Leonardo on 13-8-19.
//
//

#import "SSWebViewContainer.h"
#import "WebResourceManager.h"
#import "TTIndicatorView.h"
#import "SSThemed.h"
#import "SSPayManager.h"
#import "AccountManager.h"
#import "SSAppPageManager.h"
#import "NetworkUtilities.h"

#import "UIView+Refresh_ErrorHandler.h"
#import "TTNetworkDefine.h"

#define kSaveImgActionSheetTagKey 111

/// 假的进度条处理到 80%
static const CGFloat kMaximumFakeProgressValue = 0.8;
/// 假进度条duration
static const CGFloat kFakeDuration = 3.0;


@interface SSWebViewContainer()<UIGestureRecognizerDelegate, UIActionSheetDelegate, NSURLConnectionDelegate,UIViewControllerErrorHandler>
{
    BOOL _enableWebViewLongPressSave;
    CGFloat _loadingProgress;
    BOOL _interactive;
    
    NSInteger _maxLoadCount;
    NSInteger _loadingCount;
    /// 这个是为了统计广告落地页的跳转次数。
    NSInteger _jumpCount;
    BOOL _userHasClickLink;
    NSInteger   _clickLinkCount;
}
@property (nonatomic, strong) UILongPressGestureRecognizer * longPressGesture;
@property (nonatomic, strong) NSString * tmpSaveImgURLString;
@property (nonatomic, strong) NSMutableData *saveTmpImageData;

@property (nonatomic, strong) SSThemedView      * progressView;
/// 开始加载的时间，为了统计
@property (nonatomic, strong) NSDate            *startLoadDate;
@property (nonatomic, strong) NSString * latestWebViewRequestURL;
@property (nonatomic, strong) NSMutableArray         *jumpLinks;
@property (nonatomic, copy) NSURL                   * URL;

@property (nonatomic, copy) NSURLRequest * request;
@property (nonatomic, assign) BOOL webViewHasLoaded;
@end

@implementation SSWebViewContainer

- (void)dealloc
{
    if (self.adID && _jumpCount > 0) {
        // 发送广告落地页面跳转次数的统计
        [self _sendJumpEventWithCount:_jumpCount];
    }
    // 如果已经统计过成功、失败，则_startLoadDate会被置为空，否则则表示网页到现在为止，还没有加载结束
    if (self.startLoadDate) {
        [self _sendStatEvent:SSWebViewStayStatCancel error:nil];
    }
    [self _sendJumpLinks];
    self.adID = nil;
    self.logExtra = nil;
    self.saveTmpImageData = nil;
    self.tmpSaveImgURLString = nil;
    if (_enableWebViewLongPressSave) {
        [_ssWebView removeGestureRecognizer:_longPressGesture];
        _longPressGesture.delegate = nil;
        _longPressGesture.allowableMovement = 20;
        _longPressGesture.minimumPressDuration = 1.0f;
        self.longPressGesture = nil;
    }
    self.delegate = nil;
    self.latestWebViewRequestURL = nil;
    [self.ssWebView removeDelegate:self];
    self.ssWebView = nil;
    self.progressView = nil;
    self.startLoadDate = nil;
    self.jumpLinks = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _enableWebViewLongPressSave = [SSWebViewContainer enableLongPressSave];
        self.backgroundColor = [UIColor clearColor];
        
        if(NSClassFromString(@"ArticleJSBridgeWebView"))
        {
            self.ssWebView = [[NSClassFromString(@"ArticleJSBridgeWebView") alloc] initWithFrame:self.bounds];
        }
        else
        {
            self.ssWebView = [[SSJSBridgeWebView alloc] initWithFrame:self.bounds];
        }
        
        _ssWebView.dataDetectorTypes = UIDataDetectorTypeNone;
        setAutoresizingMaskFlexibleWidthAndHeight(_ssWebView);
        _ssWebView.scalesPageToFit = YES;
        [_ssWebView addDelegate:self];
        [self addSubview:_ssWebView];
        
        [SSWebViewUtil registerUserAgent:YES];
        
       self.progressView = [[SSThemedView alloc] initWithFrame:CGRectZero];
        self.progressView.backgroundColors = SSThemedColors(@"2a90d7", @"4371a0");
        [self addSubview:self.progressView];
        
        if (_enableWebViewLongPressSave) {
            self.longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPressGesture:)];
            _longPressGesture.delegate = self;
            _longPressGesture.enabled = NO;
            [_ssWebView addGestureRecognizer:_longPressGesture];
        }
        self.jumpLinks = [NSMutableArray arrayWithCapacity:5];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    }
    return self;
}



- (void)hiddenProgressView:(BOOL)hidden
{
    if (hidden) {
        [_progressView removeFromSuperview];
    }
    else {
        [self addSubview:_progressView];
    }
}

- (void)loadRequest:(NSURLRequest *)request {
    // 让外部同意调用这个方法，内部则处理一些统计的事件
    self.request = request;
    [_ssWebView loadRequest:request];
    self.startLoadDate = [NSDate date];
}

- (void) layoutSubviews {
    [super layoutSubviews];
    setFrameWithY(self.progressView, self.ssWebView.scrollView.contentInset.top);
}

- (NSString *)stringByEvaluatingJavaScriptFromString:(NSString *)str {
    if (isEmptyString(str)) {
        return  nil;
    }
    [_ssWebView stringByEvaluatingJavaScriptFromString:str completionHandler:nil];
    return nil;
}

#pragma mark -- long press to save image

+ (BOOL)enableLongPressSave {
    return YES;
}

#pragma mark -- long press gesture response
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {    
    return YES;
}


- (void)handleLongPressGesture:(UIGestureRecognizer *)recognizer {
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        CGPoint pt = [recognizer locationInView:_ssWebView];
        NSString *imgURL = [NSString stringWithFormat:@"document.elementFromPoint(%f, %f).src", pt.x, pt.y];
        
        [_ssWebView stringByEvaluatingJavaScriptFromString:imgURL completionHandler:^(id _Nullable result, NSError * _Nullable error) {
            NSString *urlToSave = result;
            
            self.tmpSaveImgURLString = nil;
            if (!isEmptyString(urlToSave)) {
                self.tmpSaveImgURLString = urlToSave;
                UIActionSheet * actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                                          delegate:self
                                                                 cancelButtonTitle:SSLocalizedString(@"取消", nil)
                                                            destructiveButtonTitle:nil
                                                                 otherButtonTitles:SSLocalizedString(@"保存到手机", nil), nil];
                actionSheet.tag = kSaveImgActionSheetTagKey;
                [actionSheet showInView:self];
            }

        }];
       
    }
}



#pragma mark -- UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    
    if(!SSNetworkConnected())
    {
        [self tt_endUpdataData:NO error:[NSError errorWithDomain:kCommonErrorDomain code:TTNetworkErrorCodeNoNetwork userInfo:nil]];
        
        if (_delegate && [_delegate respondsToSelector:@selector(ssWebView:didFailLoadWithError:)]) {
            [_delegate ssWebView:webView didFailLoadWithError:[NSError errorWithDomain:kCommonErrorDomain code:TTNetworkErrorCodeNoNetwork userInfo:nil]];
        }
    
        return NO;
    }
    
    BOOL should = [SSWebViewUtil webView:webView shouldStartLoadWithRequest:request navigationType:navigationType];
    if (!should) {
        return should;
    }
    
    if ([request.URL.scheme isEqualToString:@"sslocal"] && [request.URL.host isEqualToString:@"refresh_user_info"]) {
        // 登陆
        [AccountManager sharedManager].isLogin = YES;
        [[AccountManager sharedManager] startGetAccountStates:NO];
        return NO;
    }
    if ([request.URL.scheme isEqualToString:@"sslocal"] || [request.URL.scheme hasPrefix:@"snssdk"]) {
        [[SSAppPageManager sharedManager] openURL:request.URL];
        return NO;
    }
    if (self.adID) {
        /// 如果是广告的，则需要统计连接跳转。需求说明一下，这是一个很蛋疼的统计，要统计广告落地页中，所有跳转的统计
        BOOL needReport = (navigationType == UIWebViewNavigationTypeLinkClicked || navigationType == UIWebViewNavigationTypeFormSubmitted);
        if (needReport) {
            _jumpCount ++;
            if (navigationType == UIWebViewNavigationTypeLinkClicked) {
                _clickLinkCount ++;
            }
        }
    }
    
    if (navigationType == UIWebViewNavigationTypeLinkClicked) {
        _userHasClickLink = YES;
    }
    
    if (_delegate && [_delegate respondsToSelector:@selector(ssWebView:shouldStartLoadWithRequest:navigationType:)]) {
        BOOL result = [_delegate ssWebView:webView shouldStartLoadWithRequest:request navigationType:navigationType];
        if (!result) {
            return NO;
        }
    }
    
    BOOL shouldStart = YES;
    
    //TODO: Implement TOModalWebViewController Delegate callback
    
    //if the URL is the load completed notification from JavaScript
    if ([request.URL.absoluteString isEqualToString:@"webviewprogress:///complete"]) {
        [self finishLoadProgress];
        return NO;
    }
    
    //If the URL contrains a fragement jump (eg an anchor tag), check to see if it relates to the current page, or another
    //If we're merely jumping around the same page, don't perform a new loading bar sequence
    BOOL isFragmentJump = NO;
    if (request.URL.fragment) {
        NSString *nonFragmentURL = [request.URL.absoluteString stringByReplacingOccurrencesOfString:[@"#" stringByAppendingString:request.URL.fragment] withString:@""];
        isFragmentJump = [nonFragmentURL isEqualToString:request.URL.absoluteString];
    }
    
    BOOL isTopLevelNavigation = [request.mainDocumentURL isEqual:request.URL];
    BOOL isHTTP = [request.URL.scheme isEqualToString:@"http"] || [request.URL.scheme isEqualToString:@"https"];
    if (shouldStart && !isFragmentJump && isHTTP && isTopLevelNavigation && navigationType != UIWebViewNavigationTypeBackForward) {
        //Save the URL in the accessor property
        [self resetLoadProgress];
        self.URL = [request URL];
    }
    if (should && self.webViewTrackKey) {
            /// 统计跳转到某个URL
        if (!isEmptyString(request.URL.absoluteString) && [SSWebViewUtil shouldTrackWebViewWithNavigationType:navigationType]) {
            [self.jumpLinks addObject:request.URL.absoluteString];
        }
        
    }
    return should;
}

- (void)webViewDidStartLoad:(UIWebView *)webView {

    [self tt_startUpdate];

    _longPressGesture.enabled = NO;
    if (_delegate && [_delegate respondsToSelector:@selector(ssWebViewDidStartLoad:)]) {
        [_delegate ssWebViewDidStartLoad:webView];
    }
    

    _loadingCount++;
    
    //keep track if this is the highest number of concurrent requests
    _maxLoadCount = MAX(_maxLoadCount, _loadingCount);
    
    //start tracking the load state
    [self resetLoadProgress];
    
    
    if (!isEmptyString(self.latestWebViewRequestURL)) {
        BOOL isHTTP = [webView.request.URL.scheme isEqualToString:@"http"] || [webView.request.URL.scheme isEqualToString:@"https"];
        if (![webView.request.URL.absoluteString isEqualToString:self.latestWebViewRequestURL] && isHTTP) {
            // 页面发生跳转，发送取消事件(里面会判断是否已经发送过其他事件，如果发送过，则不会重复发送)
            [self _sendStatEvent:SSWebViewStayStatCancel error:nil];
        }
    }
    [self startLoadProgress];
}


- (void)webViewDidFinishLoad:(UIWebView *)webView {
    if (_delegate && [_delegate respondsToSelector:@selector(ssWebViewDidFinishLoad:)]) {
        [_delegate ssWebViewDidFinishLoad:webView];
    }
    if (_enableWebViewLongPressSave) {
        _longPressGesture.enabled = YES;
    }
    [self handleLoadRequestCompletion];
    // 发送统计事件
    [self _sendStatEvent:SSWebViewStayStatLoadFinish error:nil];
    
    //广告监控统计 注入js
    if ([_adID longLongValue] > 0) {
        [webView stringByEvaluatingJavaScriptFromString:[SSCommonLogic shouldEvaluateActLogJsStringForAdID:_adID]];
    }
    self.webViewHasLoaded = YES;
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    _longPressGesture.enabled = NO;
    if (_delegate && [_delegate respondsToSelector:@selector(ssWebView:didFailLoadWithError:)]) {
        [_delegate ssWebView:webView didFailLoadWithError:error];
    }
    [self handleLoadRequestCompletion];
    // 发送统计事件
    [self _sendStatEvent:SSWebViewStayStatLoadFail error:error];
    
    if (!webView.isLoading) {
        [self tt_endUpdataData];
    }

}

#pragma mark -- UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (actionSheet.tag == kSaveImgActionSheetTagKey) {
        if (buttonIndex == actionSheet.cancelButtonIndex) {
            self.tmpSaveImgURLString = nil;
        }
        else {
            self.saveTmpImageData = [NSMutableData data];
            NSURLConnection * connection = [NSURLConnection connectionWithRequest:[NSURLRequest requestWithURL:[SSCommon URLWithURLString:_tmpSaveImgURLString]] delegate:self];
            [connection start];
        }
    }
}

#pragma mark -- NSURLConnectionDelegate

- (void)connection:(NSURLConnection *)aConnection didReceiveData:(NSData *)data {
    [_saveTmpImageData appendData:data];
}
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    UIImage * img = [UIImage imageWithData:_saveTmpImageData];
    UIImageWriteToSavedPhotosAlbum(img, nil, nil, nil);
    self.saveTmpImageData = nil;
    [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:@"保存成功" indicatorImage:[UIImage resourceImageNamed:@"doneicon_popup_textpage"] autoDismiss:YES dismissHandler:nil];
}

#pragma mark -
#pragma mark Page Load Progress Tracking Handlers
- (void)resetLoadProgress {
    _loadingProgress  = 0;
    _interactive = NO;
    
    _maxLoadCount =0;
    _loadingCount = 0;
    [self setLoadingProgress:0.0f duration:0.0];
}

- (void)startLoadProgress {
    //If we haven't started loading yet, set the progress to small, but visible value
    if (_loadingProgress < kMaximumFakeProgressValue) {
        //reset the loading bar
        CGRect frame = self.progressView.frame;
        frame.origin.x = 0;
        frame.size.width = 0;
        frame.size.height = 2;
        self.progressView.frame = frame;
        self.progressView.alpha = 1.0f;
        //kickstart the loading progress
        [self setLoadingProgress:kMaximumFakeProgressValue duration:kFakeDuration];
    }
    [self bringSubviewToFront: self.progressView];
}

#pragma mark ErrorHandler
- (BOOL)tt_hasValidateData {

    return self.webViewHasLoaded;

}

- (void)refreshData {
    
    [_ssWebView loadRequest:self.request];
    self.startLoadDate = [NSDate date];
}

- (void)incrementLoadProgress {
    float progress          = _loadingProgress;
    float maxProgress       = kMaximumFakeProgressValue;
    float remainingPercent  = (float)_loadingCount / (float)_maxLoadCount;
    float increment         = (maxProgress - progress) * remainingPercent;
    progress                = fmin((progress+increment), maxProgress);
    [self setLoadingProgress:progress duration:0.3];
}

- (void)finishLoadProgress {
    //hide the activity indicator in the status bar
    //reset the load progress
    self.progressView.hidden = YES;
    self.progressView.hidden = NO;
    [self setLoadingProgress:1.0f duration:0.3];
    
    [self tt_endUpdataData];

}

- (void)setLoadingProgress:(CGFloat)loadingProgress duration:(NSTimeInterval) duration {
    // progress should be incremental only
    if (loadingProgress > _loadingProgress || loadingProgress == 0) {
        _loadingProgress = loadingProgress;
        if (loadingProgress != 0) {
            self.progressView.alpha = 1.0;
        }
        CGRect frame = self.progressView.frame;
        frame.size.width = CGRectGetWidth(self.ssWebView.bounds) * _loadingProgress;
        [UIView animateWithDuration:duration delay:0.0f options:UIViewAnimationOptionCurveEaseOut animations:^{
            self.progressView.frame = frame;
        } completion:^(BOOL finished) {
            //once loading is complete, fade it out
            if (loadingProgress >= 1.0f - FLT_EPSILON) {
                [UIView animateWithDuration:0.2 delay:0.3 options:UIViewAnimationOptionCurveEaseIn animations:^{
                    self.progressView.alpha = 0.0;
                } completion:^(BOOL finished) {
                    
                }];
            }
        }];
    }
}

- (void)handleLoadRequestCompletion {
    //decrement the number of concurrent requests
    _loadingCount--;
    
    //update the progress bar
    [self incrementLoadProgress];
    [self finishLoadProgress];
}

- (void)applicationDidEnterBackground:(NSNotification *)notification {
    // 切换到后台的情况下，如果还没有加载完，则不发送统计
    self.startLoadDate = nil;
    [self _sendJumpLinks];
}

- (void)_sendJumpLinks {
    if (!self.webViewTrackKey) {
        return;
    }
    if (self.jumpLinks.count == 0) {
        return;
    }
    NSArray *URLs = [self.jumpLinks copy];
    [SSWebViewUtil trackWebViewLinksWithKey:self.webViewTrackKey URLStrings:URLs adID:_adID logExtra:_logExtra];
    [self.jumpLinks removeAllObjects];
}
#pragma mark -PrivateMethod
- (void)_sendJumpEventWithCount:(NSInteger) count {
    // 只统计广告的页面停留时间，和qiuliang约定，如果停留时常<3s，则忽略
    if (count <= 0 || isEmptyString(self.adID) || self.adID.longLongValue == 0) {
        return;
    }
    NSMutableDictionary * dict = [NSMutableDictionary dictionaryWithCapacity:10];
    [dict setValue:@"wap_stat" forKey:@"category"];
    [dict setValue:@"jump_count" forKey:@"tag"];
    [dict setValue:[NSString stringWithFormat:@"%ld", (long)count] forKey:@"value"];
    if (_clickLinkCount > 0) {
        [dict setValue:@(_clickLinkCount) forKey:@"link_count"];
    }
    if (!isEmptyString(self.logExtra)) {
        [dict setValue:self.logExtra forKey:@"log_extra"];
    }
    [dict setValue:self.adID forKey:@"ext_value"];
    [SSTracker eventData:dict];
}

// 统计网页加载完毕、加载失败、返回取消加载的事件
- (void)_sendStatEvent:(SSWebViewStayStat) stat error:(NSError *)error {
    /// 这里的顺序与 _SSWebViewStat 定义的顺序一致
    NSArray *tags = @[@"load", @"load_finish", @"load_fail"];
    if (stat >= tags.count) {
        return;
    }
    // 如果没有发送，则发送。之前是针对ad的 现在扩展到所有详情页 -- add 5.1 nick
    if (self.startLoadDate) {
        NSMutableDictionary * dict = [NSMutableDictionary dictionaryWithCapacity:10];
        [dict setValue:@"wap_stat" forKey:@"category"];
        [dict setValue:tags[stat] forKey:@"tag"];
        [dict setValue:self.adID forKey:@"ext_value"];
        if (_userHasClickLink) {
            [dict setValue:@(YES) forKey:@"click_link"];
        }
        // 这里的加载时间是指从一开始LoadRequest就开始记时，到加载结束
        if (stat == SSWebViewStayStatLoadFail && error) {
            [dict setValue:[NSString stringWithFormat:@"%ld", (long)error.code] forKey:@"error"];
        } else {
            /// 需要减去后台停留时间
            NSTimeInterval timeInterval = [[NSDate date] timeIntervalSinceDate:_startLoadDate];
            // 转换成毫秒
            [dict setValue:[NSString stringWithFormat:@"%.0f", timeInterval*1000] forKey:@"load_time"];
        }
        if (!isEmptyString(self.logExtra)) {
            [dict setValue:self.logExtra forKey:@"log_extra"];
        }
        [SSTracker eventData:dict];
        
        // 这里要把这个变成空的，下次如果看到时间是空的，则不重新发送统计。
        self.startLoadDate = nil;
    }
}

- (UIScrollView *)scrollView {
    return self.ssWebView.scrollView;
}
@end
