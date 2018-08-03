
//
//  SSWebViewContainer.m
//  Article
//
//  Created by Zhang Leonardo on 13-8-19.
//
//

#import "SSWebViewContainer.h"
#import <TTAccountBusiness.h>
#import "SSCommonLogic.h"
#import "TTAdManager.h"
#import "TTAdSiteWebPreloadManager.h"
#import "ArticleWebViewToAppStoreManager.h"

#import <TTRexxar/TTRCookiesSyncer.h>
#import <TTNetworkManager/TTNetworkManager.h>
#import <TTRexxar/TTRWebViewProgressView.h>
#import <TTThemed/UIImage+TTThemeExtension.h>
#import <TTThemed/SSThemed.h>
#import <TTBaseLib/JSONAdditions.h>
#import <TTBaseLib/TTStringHelper.h>
#import <TTBaseLib/NetworkUtilities.h>
#import <TTBaseLib/NSDictionary+TTAdditions.h>
#import <TTUIWidget/TTIndicatorView.h>
#import <TTUIWidget/UIView+Refresh_ErrorHandler.h>
#import <TTTracker/TTTrackerProxy.h>
#import <TTtracker/TTTracker.h>
#import <TTRoute/TTRoute.h>
#import <TTSettingsManager/TTSettingsManager.h>

#define kSaveImgActionSheetTagKey 111

@interface SSWebViewContainer()<UIGestureRecognizerDelegate, UIActionSheetDelegate, UIViewControllerErrorHandler>
{
    /// 这个是为了统计广告落地页的跳转次数。
    BOOL _userHasClickLink;
}
@property (nonatomic, strong) UILongPressGestureRecognizer *longPressGesture;
@property (nonatomic, strong) NSString *tmpSaveImgURLString;

@property (nonatomic, strong) TTRWebViewProgressView *progressView;
/// 开始加载的时间，为了统计
@property (nonatomic, strong) NSDate *startLoadDate;
@property (nonatomic, strong) NSMutableArray *jumpLinks;

@property (nonatomic, copy) NSURLRequest *request;

@property (nonatomic, assign) SSWebViewStayStat webStayStat;
@property (nonatomic, assign) NSTimeInterval loadTime;
@property (nonatomic, copy) NSString *loadState;
@property(nonatomic, assign) NSInteger preload_num;
@property(nonatomic, assign) NSInteger match_num;

@end

@implementation SSWebViewContainer

+ (void)load {
    if ([[[TTSettingsManager sharedManager] settingForKey:@"tt_wk_cookie" defaultValue:@(YES) freeze:NO] boolValue]) {
//        [TTRCookiesSyncer autoSyncHttpCookiesToWKCookies];
    }
}

- (void)dealloc
{
    // 如果已经统计过成功、失败，则_startLoadDate会被置为空，否则则表示网页到现在为止，还没有加载结束
    if (self.startLoadDate) {
        self.webStayStat = SSWebViewStayStatCancel;
        [self _sendStatEvent:SSWebViewStayStatCancel error:nil];
    }

    [self _sendJumpLinks];
    if (!isEmptyString(self.adID)) {
        [self _sendLandingPageEvent];
    }
    [_ssWebView removeGestureRecognizer:_longPressGesture];
    _longPressGesture.delegate = nil;
    _longPressGesture.allowableMovement = 20;
    _longPressGesture.minimumPressDuration = 1.0f;
    self.longPressGesture = nil;
    [self.ssWebView removeDelegate:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)initWithFrame:(CGRect)frame {
    return [self initWithFrame:frame baseCondition:@{}];
}

- (instancetype)initWithFrame:(CGRect)frame baseCondition:(NSDictionary *)baseCondition {
    self = [super initWithFrame:frame];
    if (self) {
        [SSWebViewUtil registerUserAgent:YES];

        self.backgroundColor = [UIColor clearColor];
        
        BOOL forceUseWK = [baseCondition tt_boolValueForKey:@"use_wk"];
        self.ssWebView = [[SSJSBridgeWebView alloc] initWithFrame:self.bounds disableWKWebView:NO ignoreGlobalSwitchKey:forceUseWK];
        
        _ssWebView.dataDetectorTypes = UIDataDetectorTypeNone;
        _ssWebView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _ssWebView.scalesPageToFit = YES;
        [_ssWebView addDelegate:self];
        [self addSubview:_ssWebView];
        
        self.disableTTUserAgent = NO;
        
        _progressView = [[TTRWebViewProgressView alloc] initWithFrame:self.bounds];
        _progressView.height = 2.f;
        [self.ssWebView addDelegate:(NSObject<YSWebViewDelegate> *)_progressView];
        [self addSubview:_progressView];
        
        
        self.longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPressGesture:)];
        _longPressGesture.delegate = self;
        _longPressGesture.enabled = NO;
        [_ssWebView addGestureRecognizer:_longPressGesture];

        self.jumpLinks = [NSMutableArray arrayWithCapacity:5];
        [self p_registerADInfo];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
        
        _loadTime = 0;
    }
    return self;
}

- (void)p_registerADInfo {
    WeakSelf;
    [_ssWebView.ttr_staticPlugin registerHandlerBlock:^(NSDictionary *result, TTRJSBResponse callback) {
        StrongSelf;
        NSNumber *cid = [NSNumber numberWithLongLong:[self.adID longLongValue]];
        NSString *adLogExtra = !isEmptyString(self.logExtra) ? self.logExtra : @"";
        NSDictionary *dic = @{@"cid":cid,
                              @"log_extra":adLogExtra};
        if (callback) {
            callback(TTRJSBMsgSuccess, [dic copy]);
        }
    } forMethodName:@"adInfo"];
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
    [self loadRequest:request shouldAppendQuery:YES];
}

- (void)loadRequest:(NSURLRequest *)request shouldAppendQuery:(BOOL)shouldAppendQuery {
    // 让外部同意调用这个方法，内部则处理一些统计的事件
    self.request = request;
    [_ssWebView loadRequest:request shouldTransferedHttps:YES shouldAppendQuery:shouldAppendQuery];
    self.startLoadDate = [NSDate date];
}

- (void) layoutSubviews {
    [super layoutSubviews];
    self.progressView.top = self.ssWebView.scrollView.contentInset.top;
}

- (void)setDisableTTUserAgent:(BOOL)disable {
    _disableTTUserAgent = disable;
    [SSWebViewUtil registerUserAgent:!disable];
}

- (NSString *)loadState {
    switch (self.webStayStat) {
        case SSWebViewStayStatLoadFinish:
            return @"load_finish";
        case SSWebViewStayStatLoadFail:
            return @"load_fail";
        default:
            return @"load";
    }
}

#pragma mark -- long press gesture response
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {    
    return YES;
}


- (void)handleLongPressGesture:(UIGestureRecognizer *)recognizer {
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        CGPoint pt = [recognizer locationInView:_ssWebView];
        
        NSString *imgURL = [NSString stringWithFormat:@";(function(){"
                            @"var el = document.elementFromPoint(%f, %f);"
                            @"if (el.tagName.toLowerCase() != 'img') {"
                            @"return;"
                            @"}"
                            @"return el.src;"
                            @"})();", pt.x, pt.y];
        
        __weak typeof(self) wself = self;
        [_ssWebView stringByEvaluatingJavaScriptFromString:imgURL completionHandler:^(id _Nullable result, NSError * _Nullable error) {
            __strong typeof(wself) self = wself;
            NSString *urlToSave = result;
            NSURL *imageURL = [NSURL URLWithString:result];
            self.tmpSaveImgURLString = nil;
            if (imageURL && !isEmptyString(urlToSave)) {
                self.tmpSaveImgURLString = urlToSave;
                UIActionSheet * actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                                          delegate:self
                                                                 cancelButtonTitle:NSLocalizedString(@"取消", nil)
                                                            destructiveButtonTitle:nil
                                                                 otherButtonTitles:NSLocalizedString(@"保存到手机", nil), nil];
                actionSheet.tag = kSaveImgActionSheetTagKey;
                [actionSheet showInView:self];
            }
            
        }];
        
    }
}

#pragma mark -- YSWebViewDelegate

- (BOOL)webView:(YSWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(YSWebViewNavigationType)navigationType {
    
    if(!TTNetworkConnected())
    {
        [self tt_endUpdataData:NO error:[NSError errorWithDomain:kCommonErrorDomain code:TTNetworkErrorCodeNoNetwork userInfo:nil]];
        
        if (self.ssWebView.delegate && [self.ssWebView.delegate respondsToSelector:@selector(webView:didFailLoadWithError:)]) {
            [self.ssWebView.delegate webView:self.ssWebView didFailLoadWithError:[NSError errorWithDomain:kCommonErrorDomain code:TTNetworkErrorCodeNoNetwork userInfo:nil]];
        }
    
        return NO;
    }
    
    if ([request.URL.scheme isEqualToString:@"sslocal"] && [request.URL.host isEqualToString:@"refresh_user_info"]) {
        // 登录
        [TTTracker eventV3:@"deprecated_feature" params:@{@"name": @"sswebviewcontainer_refresh_user_info"}];
        [TTAccountManager setIsLogin:YES];
        [TTAccountManager startGetAccountStatus:NO];
        
        return NO;
    }
    
    if (navigationType == YSWebViewNavigationTypeLinkClicked) {
        _userHasClickLink = YES;
    }
    
    if (self.webViewTrackKey) {
            /// 统计跳转到某个URL
        if (!isEmptyString(request.URL.absoluteString)) {
            [self.jumpLinks addObject:request.URL.absoluteString];
        }
        
    }
    
    // stay_page统计需求  需求：https://wiki.bytedance.net/pages/viewpage.action?pageId=89884456
    if ([ArticleWebViewToAppStoreManager isToAppStoreRequestURLStr:request.URL.absoluteString]) {
        [self _sendJumpOutAppEvent];
    }
    
    return YES;
}

- (void)webViewDidStartLoad:(YSWebView *)webView {
    [self tt_startUpdate];
    _longPressGesture.enabled = NO;
}


- (void)webViewDidFinishLoad:(YSWebView *)webView {
    _longPressGesture.enabled = YES;
    [self tt_endUpdataData];
    // 发送统计事件
    self.webStayStat = SSWebViewStayStatLoadFinish;
    [self _sendStatEvent:SSWebViewStayStatLoadFinish error:nil];

}

- (void)webView:(YSWebView *)webView didFailLoadWithError:(NSError *)error {
    _longPressGesture.enabled = NO;
    // 发送统计事件
    self.webStayStat = SSWebViewStayStatLoadFail;
    [self _sendStatEvent:SSWebViewStayStatLoadFail error:error];
    
    if ([error.domain isEqualToString:kCommonErrorDomain] && error.code == TTNetworkErrorCodeNoNetwork) {
        [self tt_endUpdataData:NO error:[NSError errorWithDomain:kCommonErrorDomain code:TTNetworkErrorCodeNoNetwork userInfo:nil]];
        return;
    }
    
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
            [TTTracker eventV3:@"deprecated_feature" params:@{@"name": @"sswebviewcontainer_savephoto"}];
            [[TTNetworkManager shareInstance] requestForBinaryWithURL:_tmpSaveImgURLString params:nil method:@"GET" needCommonParams:NO callback:^(NSError *error, id obj) {
                if (![obj isKindOfClass:[NSData class]]) {
                    return;
                }
                UIImage * img = [UIImage imageWithData:obj];
                
                if (!img) {
                    return;
                }
                UIImageWriteToSavedPhotosAlbum(img, nil, nil, nil);
                [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:@"保存成功" indicatorImage:[UIImage themedImageNamed:@"doneicon_popup_textpage"] autoDismiss:YES dismissHandler:nil];
            }];
        }
    }
}


#pragma mark ErrorHandler
- (BOOL)tt_hasValidateData {
    return self.ssWebView.isDomReady;
}

- (void)refreshData {
    [_ssWebView loadRequest:self.request];
    self.startLoadDate = [NSDate date];
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
        NSString * articleUrl = self.request.URL.absoluteString;
        if (articleUrl && [[TTAdSiteWebPreloadManager sharedManager].preloadURLSet containsObject:articleUrl]) {
            [dict setValue:@1 forKey:@"preload"];
        } else {
            [dict setValue:@0 forKey:@"preload"];
        }
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
            if (self.adID.longLongValue > 0 && timeInterval >90) {//超过90秒 当90秒处理
                timeInterval = 90;
            }
            self.loadTime = timeInterval;
            [dict setValue:[NSString stringWithFormat:@"%.0f", timeInterval*1000] forKey:@"load_time"];
        }
        if (!isEmptyString(self.logExtra)) {
            [dict setValue:self.logExtra forKey:@"log_extra"];
        }
        else {
            [dict setValue:@"" forKey:@"log_extra"];

        }
        //添加三方广告落地页预加载打点字段
        if (!isEmptyString(self.adID)) {
            if ([TTAdManageInstance preloadWebRes_isFirstEnterPageAdid:self.adID]) {
                [dict setValue:@"1" forKey:@"first_open"];
            }
            else{
                [dict setValue:@"0" forKey:@"first_open"];
            }
            if ([TTAdManageInstance preloadWebRes_hasPreloadResource:self.adID] == YES) {
                [dict setValue:@"ad_wap_stat" forKey:@"label"];
                [dict setValue:self.adID forKey:@"value"];
                [dict setValue:@"1" forKey:@"is_ad_event"];
                NSInteger preload_total = [TTAdManageInstance preloadWebRes_preloadTotalAdID:self.adID];
                if (preload_total > 0) {
                    NSInteger rate = 0;
                    NSInteger preload_num = [TTAdManageInstance preloadWebRes_preloadNumInWebView];
                    self.preload_num = preload_num;
                    rate =100 * preload_num / preload_total;
                    NSMutableDictionary *ad_extra_data = [NSMutableDictionary dictionary];
                    [ad_extra_data setValue:@(rate<100?rate:100) forKey:@"load_percent"];
                    
                    CGFloat match_rate = 0;
                    NSInteger match_num = [TTAdManageInstance preloadWebRes_matchNumInWebView];
                    self.match_num = match_num;
                    match_rate = 100* match_num / preload_total;
                    [ad_extra_data setValue:@(match_rate>100? 100:match_rate) forKey:@"match_percent"];
                    [dict setValue:[ad_extra_data tt_JSONRepresentation]
                            forKey:@"ad_extra_data"];
                    [dict setValue:@1 forKey:@"preload"];
                    [TTAdManageInstance preloadWebRes_finishCaptureThePage];
                }
            }
        }
        [TTTrackerWrapper eventData:dict];
        
        // 这里要把这个变成空的，下次如果看到时间是空的，则不重新发送统计。
        self.startLoadDate = nil;
    }
}

- (void)_sendLandingPageEvent {
    if (isEmptyString(self.adID)) {
        return;
    }
    
    NSMutableDictionary * dict = [NSMutableDictionary dictionaryWithCapacity:10];
    NSString * articleUrl = self.request.URL.absoluteString;
    [dict setValue:@"umeng" forKey:@"category"];
    [dict setValue:@"wap_stat" forKey:@"tag"];
    [dict setValue:@"landing_page" forKey:@"label"];
    [dict setValue:self.adID forKey:@"value"];
    [dict setValue:@"1" forKey:@"is_ad_event"];
    TTInstallNetworkConnection connectionType = [[TTTrackerProxy sharedProxy] connectionType];
    [dict setValue:@(connectionType) forKey:@"nt"];

    if (!isEmptyString(self.logExtra)) {
        [dict setValue:self.logExtra forKey:@"log_extra"];
    } else {
        [dict setValue:@"" forKey:@"log_extra"];
    }

    /// 需要减去后台停留时间
    NSTimeInterval timeInterval;
    NSMutableDictionary *ad_extra_data = [NSMutableDictionary dictionary];
    if (_startLoadDate) {
        timeInterval = [[NSDate date] timeIntervalSinceDate:_startLoadDate];
        // 转换成毫秒
        if (self.adID.longLongValue > 0 && timeInterval >90) {//超过90秒 当90秒处理
            timeInterval = 90;
        }
    } else {
        timeInterval = self.loadTime;
    }
    
    [ad_extra_data setValue:[NSString stringWithFormat:@"%.0f", timeInterval*1000] forKey:@"load_time"];
    if (articleUrl && [[TTAdSiteWebPreloadManager sharedManager].preloadURLSet containsObject:articleUrl]) {
        [ad_extra_data setValue:@1 forKey:@"preload"];
    } else {
        [ad_extra_data setValue:@0 forKey:@"preload"];
    }

    NSString* timeStr = nil;
    @try {
        timeStr = [self.ssWebView stringByEvaluatingJavaScriptFromString:@"performance.timing.domComplete - performance.timing.navigationStart" completionHandler:nil];
    } @catch (NSException *exception) {
        NSLog(@"performance.timing.domComplete--exception:%@",exception.description);
    } @finally {
        
    }
    if (isEmptyString(timeStr)) {
        timeStr = @"90000";
    }
    timeInterval = timeStr.longLongValue;
    if (timeStr.longLongValue < 0 || timeStr.longLongValue >90000) {
        timeInterval = 90000;
    }
    [ad_extra_data setValue:@(timeInterval) forKey:@"dom_complete_time"];
    [ad_extra_data setValue:self.loadState forKey:@"load_status"];

    //添加三方广告落地页预加载打点字段

    if ([TTAdManageInstance preloadWebRes_hasPreloadResource:self.adID] == YES) {
        NSInteger preload_total = [TTAdManageInstance preloadWebRes_preloadTotalAdID:self.adID];
        if (preload_total > 0) {
            NSInteger rate = 0;
            NSInteger preload_num = [TTAdManageInstance preloadWebRes_preloadNumInWebView];
            if (self.preload_num || self.match_num) {
                preload_num = self.preload_num;
            }
            rate =100 * preload_num / preload_total;
            [ad_extra_data setValue:@(rate<100?rate:100) forKey:@"load_percent"];
            
            CGFloat match_rate = 0;
            NSInteger match_num = [TTAdManageInstance preloadWebRes_matchNumInWebView];
            if (self.preload_num || self.match_num) {
                match_num = self.preload_num;
            }
            match_rate = 100* match_num / preload_total;
            [ad_extra_data setValue:@(match_rate>100? 100:match_rate) forKey:@"match_percent"];
            [ad_extra_data setValue:@1 forKey:@"preload"];
            [TTAdManageInstance preloadWebRes_finishCaptureThePage];
        }
    }
    [dict setValue:[ad_extra_data tt_JSONRepresentation] forKey:@"ad_extra_data"];

    [TTTrackerWrapper eventData:dict];
    
    // 这里要把这个变成空的，下次如果看到时间是空的，则不重新发送统计。
    self.startLoadDate = nil;
    
}

- (void)_sendJumpOutAppEvent {
    if (isEmptyString(self.adID) || self.adID.longLongValue == 0) {
        return;
    }
    NSMutableDictionary * dict = [NSMutableDictionary dictionaryWithCapacity:10];
    [dict setValue:@"wap_stat" forKey:@"category"];
    [dict setValue:@"jump_out_app" forKey:@"tag"];
    [dict setValue:self.adID forKey:@"value"];
    [dict setValue:self.logExtra forKey:@"log_extra"];
    [dict setValue:@"1" forKey:@"is_ad_event"];
    TTInstallNetworkConnection connectionType = [[TTTrackerProxy sharedProxy] connectionType];
    [dict setValue:@(connectionType) forKey:@"nt"];
    [TTTrackerWrapper eventData:dict];
}

- (UIScrollView *)scrollView {
    return self.ssWebView.scrollView;
}
@end
