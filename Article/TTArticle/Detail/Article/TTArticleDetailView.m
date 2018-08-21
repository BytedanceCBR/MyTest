//
//  TTArticleDetailView.m
//  Article
//
//  Created by 冯靖君 on 16/4/8.
//
//  文章详情页正文部分。对TTWebView进行了封装，并增加文章相关业务逻辑

#import "TTArticleDetailView.h"
#import "TTArticleDetailView+JSBridge.h"
#import "TTArticleDetailTracker.h"
#import "TTArticleDetailMonitor.h"
#import "TTArticleStoryToolView.h"
#import "TTOriginalDetailWebviewContainer.h"
#import "TTDetailWebviewContainer+JSImageVideoLogic.h"
#import "TTNovelRecordManager.h"
#import "Article.h"
#import "NSDictionary+TTGeneratedContent.h"
#import "ArticleWebViewToAppStoreManager.h"
#import "ExploreDetailToolbarView.h"
#import "ExploreMixListDefine.h"
#import "ExploreOrderedData+TTBusiness.h"
#import "ExploreSearchViewController.h"
#import "FriendDataManager.h"

#import <TTAdModule/SSAppStore.h>
#import "SSCommonLogic.h"
#import "SSWebViewController.h"
#import "NewsDetailLogicManager.h"

#import <TTBaseLib/TTNetworkHelper.h>
#import <TTBaseLib/JSONAdditions.h>
#import <TTBaseLib/TTUIResponderHelper.h>
#import <TTBaseLib/NSDictionary+TTAdditions.h>
#import <TTBaseLib/NetworkUtilities.h>
#import <TTUIWidget/TTIndicatorView.h>
#import <TTUIWidget/UIView+Refresh_ErrorHandler.h>
#import <AKWebViewBundlePlugin/SSWebViewUtil.h>
#import <TTPhotoScrollVC/TTPhotoScrollViewController.h>
#import <TTUserSettings/TTUserSettingsManager+FontSettings.h>
#import <TTImagePreviewAnimateManager/TTInteractExitHelper.h>
#import <TTServiceKit/TTServiceCenter.h>
#import <TTAdModule/TTAdManagerProtocol.h>
#import <AKWebViewBundlePlugin/YSWebView.h>
#import <TTNetworkManager/TTNetworkManager.h>
#import <TTTracker/TTTrackerProxy.h>
#import <TTAccountSDK/TTAccount+Multicast.h>
#import <AVFoundation/AVFoundation.h>
#import <AVFoundation/AVAudioSession.h>
#import "ExploreOrderedData+TTAd.h"
#import "TTADTrackEventLinkModel.h"
#import "TTVPlayerUrlTracker.h"

static NSInteger const kRedirectStatusCode = 302;
static NSInteger const kErrorStatusCode = 400;


#pragma mark - TTArticleDetailWebViewFooter
//给浮层包一层，相当于重构前的superNatantview
@interface TTArticleDetailWebViewFooter : SSThemedView <TTDetailFooterViewProtocol>
@end

@implementation TTArticleDetailWebViewFooter
@synthesize footerScrollView;
@end

#pragma mark - TTArticleDetailView

@interface TTArticleDetailView () </*YSWebViewDelegate,*/ TTDetailWebviewDelegate, TTDetailWebViewRequestProcessorDelegate, UIScrollViewDelegate, UIViewControllerErrorHandler, TTAccountMulticastProtocol, UIGestureRecognizerDelegate>
{
    BOOL _didDisAppear;
    BOOL _didEnterBackground;
    BOOL _isWebViewLoading;
    BOOL _webViewHasError;
    BOOL _webViewHasExecuteScriptJS;
    BOOL _webViewHasInsertedContextJS;
    NSString *_latestWebViewRequestURLString;
    
    //导流页302重定向上报
    NSString *_webViewURLBeforeRedirection;
    NSString *_webViewRedirectToURL;
    BOOL _webTypeContentStatusCodeChecked;
    
    BOOL _webTypeContentDidFinishLoadMonitorSent;
    
    //added 6.0+ 是否已设置audioSessionCategory标记
    BOOL _webViewAudioSessionCategorySet;
}

@property (nonatomic, copy) NSString *requestUrlString;

@property (nonatomic, strong) NSTimer * countDownTimer;

@property (nonatomic, strong) TTArticleDetailTracker *tracker;
@property (nonatomic, assign) BOOL shouldInterceptAutoJump;

@property (nonatomic, strong) TTArticleDetailMonitor *monitor;

@property (nonatomic, strong) TTArticleDetailWebViewFooter *detailWebViewDivFooter;

@property (nonatomic, assign) BOOL didWebViewFinished;
@property (nonatomic, assign) BOOL hasInfomationGet;
@property (nonatomic, assign) BOOL hasInfomationJSInjected;

@property (nonatomic, weak) TTPhotoScrollViewController *photoScrollViewController;

@property (nonatomic, strong) UITapGestureRecognizer *webTapGesture;
@property (nonatomic, assign) NSTimeInterval clickTimeStamp;
@property (nonatomic, assign) SSWebViewStayStat webStayState;

@end

@implementation TTArticleDetailView

+ (void)load {
    
    //被吐槽了... 占了34ms....
    //    if([SSCommonLogic detailSharedWebViewEnabled]) {
    //        [self performSelectorOnMainThread:@selector(sharedWebView) withObject:nil waitUntilDone:NO];
    //    }
}

- (nonnull instancetype)initWithFrame:(CGRect)frame
                          detailModel:(TTDetailModel *)detailModel
{
    self = [super initWithFrame:frame];
    if (self) {
        self.titleViewAnimationTriggerPosY = 100;
        _webTypeContentStatusCodeChecked = NO;
        _webTypeContentDidFinishLoadMonitorSent = NO;
        _webViewAudioSessionCategorySet = NO;
        _detailModel = detailModel;
        [self p_initMonitor];
        
        [self p_initViewModel];
        [self p_detailCommonInit];
        [self p_buildDetailWebView];
        [self reloadThemeUI];
        [self p_initTracker];
        [self p_initAdInfo];
        
        if ([_detailModel.article isImageSubject] || [_detailModel.article isVideoSubject]) {
            [[TTMonitor shareManager] trackService:@"article_detail_incorrect_flags" value:_detailModel.article.groupFlags extra:[self.tracker detailTrackerCommonParams]];
        }
    }
    return self;
}

#pragma mark - life cycle

- (void)dealloc
{
    [self p_uploadArticlePositionIfNeed];
    // 发送广告落地页面跳转次数的统计
    [self.tracker tt_sendJumpEventTrack];
    if (self.tracker.startLoadDate) {
        self.webStayState = SSWebViewStayStatCancel;
        [self.tracker tt_sendStatStayEventTrack:SSWebViewStayStatCancel error:nil];
        [self.tracker tt_resetStartLoadDate];
    }
    [self.tracker tt_sendDomCompleteEventTrack];
    if ([_detailModel.adID longLongValue] > 0) {
        [self.tracker tt_sendLandingPageEventTrack];
    }
    [self.tracker tt_sendJumpLinksTrackWithKey:_infoManager.webViewTrackKey];
    if (self.detailWebView) {
        //        [self.tracker tt_sendReadTrackWithPCT:[self.detailWebView readPCTValue] pageCount:[self.detailWebView pageCount]];
        //        [self.tracker tt_sendStayTimeImpresssion];
    }
    
    [self p_registerArticleDetailCloseCallback];
    [self p_clearSharedWebViewContextIfNeed];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)willAppear
{
    [super willAppear];
    [_detailWebView didAppear];
}

- (void)didAppear
{
    [super didAppear];
    _didDisAppear = NO;
}

- (void)didDisappear
{
    [super didDisappear];
    [self.detailWebView didDisappear];
    
    //added 5.7.*:disappear也发送read_pct事件
    if (self.detailWebView) {
        [self.tracker tt_sendReadTrackWithPCT:[self.detailWebView readPCTValue] pageCount:[self.detailWebView pageCount]];
        [self.tracker tt_sendStayTimeImpresssion];
    }
    
    _didDisAppear = YES;
    
    [self p_pauseAudiosWhenDisappeared];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    _detailWebView.frame = [self p_frameForVisableRect];
}

- (void)themeChanged:(NSNotification *)notification
{
    [super themeChanged:notification];
    [self p_refreshDetailTheme];
    if ([[TTThemeManager sharedInstance_tt] currentThemeMode] == TTThemeModeDay) {
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
    } else {
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
    }
}

- (void)setWebStayState:(SSWebViewStayStat)webStayState
{
    _webStayState = webStayState;
    switch (webStayState) {
        case SSWebViewStayStatLoadFinish:
            self.tracker.loadState = @"load_finish";
            break;
        case SSWebViewStayStatLoadFail:
            self.tracker.loadState = @"load_fail";
            break;
        case SSWebViewStayStatCancel:
        default:
            self.tracker.loadState = @"load";
            break;
    }
}

#pragma mark - public
- (void)tt_setContentAndExtraWithArticle:(Article *)article {
    NSString *content = [self.detailViewModel tt_sharedHTMLContentWithArticle:article];
    [self.detailWebView.webView evaluateJavaScriptFromString:[NSString stringWithFormat:@"setContent(\"%@\");setExtra(%@);", content, [self.detailViewModel tt_h5ExtraDictWithArticle:article].JSONRepresentation ] completionBlock:nil];
}

- (void)tt_handleDetailViewWithInfoManager:(ArticleInfoManager *)infoManager
{
    self.hasInfomationGet = YES;
    SSLog(@"info get");
    self.infoManager = infoManager;
    // 如果已经Dom Ready， 则直接插入js。否则，则记住JS，等待DomReady或者加载完成之后 插入JS
    if (self.domReady) {
        //        [self p_executeJsForWebViewWithJS:self.infoManager.insertedJavaScript];
        //        [self p_insertJSContext:self.infoManager.insertedContextJS];
        [self p_injectInfomationJSIfNeed];
    }
    [self p_refreshInformation];
    [self.detailViewModel tt_setContentOffsetY:[self.infoManager.articlePosition floatValue]];
    
    [self p_startWebTransformWhenInfoGetIfNeed];
}

- (void)tt_deleteArticleByInfoFetchedIfNeeded
{
    [self p_deleteArticleIfNeeded];
}

- (void)tt_setNatantWithFooterView:(UIView *)footerView
         includingFooterScrollView:(UIScrollView *)footerScrollView
{
    self.detailWebViewDivFooter = [[TTArticleDetailWebViewFooter alloc] initWithFrame:[self p_frameForVisableRect]];
    [self.detailWebViewDivFooter addSubview:footerView];
    [self.detailWebViewDivFooter setFooterScrollView:footerScrollView];
    TTDetailNatantStyle style = [self.detailViewModel tt_natantStyleFromNatantLevel];
    [self.detailWebView addFooterView:self.detailWebViewDivFooter detailFooterAddType:style];
}

- (BOOL)tt_isNovelArticle
{
    return self.detailModel.article.novelData != nil;
}

- (void)tt_initializeServerRequestMonitorWithName:(NSString *)apiName
{
    [self.monitor initializeServerRequestTimeMonitorWithName:apiName];
}

- (void)tt_serverRequestTimeMonitorWithName:(NSString *)apiName error:(NSError *)error
{
    NSString *intervalStr = [self.monitor intervalFromServerRequestStartTimeWithName:apiName];
    NSMutableDictionary *extra = [[self.tracker detailTrackerCommonParams] mutableCopy];
    if (error) {
        [extra setValue:@(error.code) forKey:@"err_code"];
        [extra setValue:error.localizedDescription forKey:@"err_des"];
    }
    [[TTMonitor shareManager] trackService:apiName value:intervalStr extra:extra];
}

#pragma mark - private

- (void)p_initAdInfo {
    _shouldInterceptAutoJump = [SSCommonLogic shouldAutoJumpControlEnabled];
}

- (void)p_initTracker
{
    _tracker = [[TTArticleDetailTracker alloc] initWithDetailModel:_detailModel
                                                     detailWebView:_detailWebView];
}

- (void)p_initMonitor
{
    _monitor = [[TTArticleDetailMonitor alloc] init];
}

- (void)p_initViewModel
{
    _detailViewModel = [[TTArticleDetailViewModel alloc] initWithDetailModel:self.detailModel];
}

- (void)p_detailCommonInit
{
    [self reloadThemeUI];
    [self p_addNotiCenterObservers];
}

- (void)p_buildDetailWebView
{
    BOOL disableWKWebView = [_detailViewModel tt_disableWKWebview];
    
    if ([self.detailModel.adID longLongValue] > 0 && ![SSCommonLogic newNatantStyleInADEnabled]) {
        _detailWebView = [[TTOriginalDetailWebviewContainer alloc] initWithFrame:[self p_frameForVisableRect]
                                                                disableWKWebView:disableWKWebView
                                                           ignoreGlobalSwitchKey:YES
                                                                   hiddenWebView:nil
                                                                 webViewDelegate:nil];
    } else {
        SSJSBridgeWebView *sharedWebView = [self p_needUseSharedWebView]? self.class.sharedWebView: nil;
        _detailWebView = [[TTDetailWebviewContainer alloc] initWithFrame:[self p_frameForVisableRect]
                                                        disableWKWebView:disableWKWebView
                                                   ignoreGlobalSwitchKey:YES
                                                           hiddenWebView:sharedWebView
                                                         webViewDelegate:nil];
    }
    
    TTDetailNatantStyle style = [self.detailViewModel tt_natantStyleFromNatantLevel];
    _detailWebView.needAutoDemoted = YES;
    _detailWebView.natantStyle = style;
    _detailWebView.delegate = self;
    _detailWebView.webView.dataDetectorTypes = UIDataDetectorTypeNone;
    _detailWebView.webView.opaque = NO;
    _detailWebView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self addSubview:_detailWebView];
    
    if ([self.detailModel.adID longLongValue] > 0) {
        _detailWebView.webView.shouldInterceptUrls = [SSCommonLogic shouldInterceptAdJump];
        if ([SSCommonLogic shouldClickJumpControlEnabled]) {
            self.webTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(p_handleTapGesture:)];
            self.webTapGesture.delegate = self;
            self.webTapGesture.enabled = NO;
            [_detailWebView.webView addGestureRecognizer:self.webTapGesture];
        }
    }
    
    [self registerJSBridge];
    //added 5.8+:只针对导流页关闭内嵌视频自动播放
    if ([self.detailViewModel tt_articleDetailLoadedContentType] == ArticleTypeWebContent &&
        self.detailModel.adID.longLongValue == 0) {
        if ([[_detailWebView.webView tt_webViewInUse] respondsToSelector:@selector(setMediaPlaybackRequiresUserAction:)]) {
            [[_detailWebView.webView tt_webViewInUse] setValue:@(YES) forKey:NSStringFromSelector(@selector(mediaPlaybackRequiresUserAction))];
        }
    }
    
    if ([self p_checkArticleReliable]) {
        [self tt_startLoadWebViewContent];
    }
    [self p_showLoadingView];
}

- (void)tt_startLoadWebViewContent
{
    //    [self tt_endUpdataData];
    [self p_registerWebViewUserAgent];
    [self p_registerArticleWebViewJSCallback];
    if ([_detailModel.article.articleDeleted boolValue]) {
        [self p_deleteArticleIfNeeded];
    }
    else {
        [self p_startLoadArticleContent];
        //added 5.4:导流页超时加载转码页+web图集超时加载native图集机制
        [self p_startLoadNativeContentForWebTimeoffIfNeeded];
    }
}

- (void)p_deleteArticleIfNeeded
{
    if ([_detailModel.article.articleDeleted boolValue]) {
        _detailModel.article.detail.content = NSLocalizedString(@"该内容已删除", nil);
        [_detailModel.article save];
        //[[SSModelManager sharedManager] save:nil];
        
        //5.4：文章删除后改为显示native页面
        [self p_startLoadForArticleDeleted];
        [self tt_endUpdataData:NO error:nil];
        //        [self p_removeLoadingView];
        
        //需要先发出notification， 再删除数据库
        if (_detailModel.orderedData) {
            NSDictionary * userInfo = @{kExploreMixListDeleteItemKey:_detailModel.orderedData};
            [[NSNotificationCenter defaultCenter] postNotificationName:kExploreMixListItemDeleteNotification object:nil userInfo:userInfo];
        }
        
        _detailModel.orderedData = nil;
        
        //        NSPredicate * predicate = [NSPredicate predicateWithFormat:@"originalData.uniqueID = %@", _detailModel.article.uniqueID];
        //        [[SSModelManager sharedManager] removeEntitiesWithPredicate:predicate entityName:[ExploreOrderedData entityName] error:nil];
        
        [[TTMonitor shareManager] trackService:@"article_deleted" status:1 extra:[self.tracker detailTrackerCommonParams]];
        
        NSString *uniqueID = [NSString stringWithFormat:@"%lld", _detailModel.article.uniqueID];
        [ExploreOrderedData deleteObjectsWhere:@"WHERE uniqueID = ?" arguments:@[uniqueID]];
    }
}

- (void)p_startLoadForArticleDeleted
{
    self.ttViewType = TTFullScreenErrorViewTypeDeleted;
    _isWebViewLoading = NO;
    if (_detailWebView.webView == [self.class sharedWebView]) {
        [self p_clearSharedWebViewContextIfNeed];
        return;
    }
    [_detailWebView removeFromSuperview];
    [_detailWebView removeDivFromWebViewIfNeeded];
    [_detailWebView.webView loadHTMLString:nil baseURL:nil];
    
}

- (void)p_startLoadArticleContent
{
    if(!_detailModel.article.managedObjectContext)
    {
        LOGD(@"%s, error: article is removed", __PRETTY_FUNCTION__);
        return;
    }
    
    //初始化web请求monitor
    [self.monitor initializeWebRequestTimeMonitor];
    
    if ([_detailViewModel tt_articleDetailLoadedContentType] == TTArticleDetailLoadedContentTypeNative) {
        [self p_startLoadNativeTypeArticle];
        [self p_showLoadingView];
    }
    else {
        [self p_startLoadWebTypeArticle];
        [self p_showLoadingView];
        WeakSelf;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if (wself.domReady) {
                return;
            }
            [wself p_removeLoadingView];
        });
    }
    
    [_detailViewModel tt_setArticleHasRead];
}

- (void)p_startLoadNativeTypeArticle {
    
    if (_detailWebView.webView == self.class.sharedWebView) {
        [self p_refreshContentInSharedWebView];
        return;
    }
    
    if (_detailWebView.webView.isWKWebView) {
        [self p_startLoadNativeTypeArticleWithWKWebView];
    } else {
        [self p_startLoadNativeTypeArticleWithUIWebView];
    }
}

- (void)p_startLoadNativeTypeArticleWithUIWebView
{
    [_detailWebView.webView stopLoading];
    _detailWebView.webView.disableThemedMask = YES;
    NSString * html = [_detailViewModel tt_nativeContentHTMLForWebView:_detailWebView.webView];
    NSURL * baseURL = [_detailViewModel tt_nativeContentFilePath];
    [_detailWebView.webView loadHTMLString:html baseURL:baseURL];
    //[self p_webViewUpdateFontSize];
    _detailWebView.webView.scalesPageToFit = NO;
    
}

- (void)p_startLoadNativeTypeArticleWithWKWebView
{
    [_detailWebView.webView stopLoading];
    _detailWebView.webView.disableThemedMask = YES;
    [self.detailViewModel tt_nativeContentFilePathWithWebView:_detailWebView.webView callback:^(NSURL * _Nullable fileURL) {
        NSString *cachePath = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)[0];
        [self.detailWebView.webView loadFileURL:fileURL allowingReadAccessToURL:[NSURL URLWithString:[@"file://" stringByAppendingString:cachePath]]];
        self.detailWebView.webView.scalesPageToFit = NO;
    }];
}

- (void)p_startLoadWebTypeArticle
{
    _webViewHasExecuteScriptJS = NO;
    _webViewHasInsertedContextJS = NO;
    if ([_detailViewModel tt_isArticleNonCooperationWebContent]) {
        _detailWebView.webView.disableThemedMask = YES;
    }
    _detailWebView.webView.scalesPageToFit = YES;
    [self p_startLoadWebTypeContentDirectlyIfNeeded];
}

- (void)p_refreshInformation {
    //TODO: info回来后 刷新页面.
}
//导流页是否可以加载转码页
- (BOOL)p_canLoadNativeContentForWebTypeArticle
{
    if ([SSCommonLogic webContentArticleProtectionTimeoutDisabled]) {
        return NO;
    }
    
    //是转码页或已经强制加载过转码页，则返回
    if ([self.detailViewModel tt_articleDetailLoadedContentType] == TTArticleDetailLoadedContentTypeNative) {
        return NO;
    }
    
    if ([self.detailModel.adID longLongValue]) {
        return NO;
    }
    
    if ([self.detailModel.article.ignoreWebTranform boolValue]) {
        return NO;
    }
    
    return YES;
}

//导流页超时加载转码页机制
- (void)p_startLoadNativeContentForWebTimeoffIfNeeded
{
    if (![self p_canLoadNativeContentForWebTypeArticle]) {
        return;
    }
    
    float timeoutDelay = [SSCommonLogic webContentArticleProtectionTimeoutInterval];
    WeakSelf;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(timeoutDelay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (wself.domReady) {
            return;
        }
        if (_didEnterBackground) {
            //fix crash
            //#123276WebCore::GraphicsContext3D::reshape(int, int)
            //https://fabric.io/news/ios/apps/com.ss.iphone.article.news/issues/561f6f97f5d3a7f76bd030f0
            return;
        }
        [wself.detailWebView.webView stringByEvaluatingJavaScriptFromString:@"document.body.childElementCount;" completionHandler:^(NSString * _Nullable result, NSError * _Nullable error) {
            if (!error && !isEmptyString(result) && result.integerValue > 0) {
                return;
            }
            [wself p_didStartLoadNativeContentForWebTimeoff];
        }];
    });
}

- (void)p_didStartLoadNativeContentForWebTimeoff
{
    //added 5.9.9 开始转码前再判断一次开关，可能已被info重新设为关
    if ([self.detailModel.article.ignoreWebTranform boolValue] ||
        [self.detailViewModel tt_webHasBeenTransformed]) {
        return;
    }
    
    [self p_startLoadNativeTypeArticle];
    
    [self.detailViewModel tt_setWebHasBeenTransformed:YES];
    [self.tracker tt_sendStartLoadNativeContentForWebTimeoffTrack];
    [[TTMonitor shareManager] trackService:@"web_transform" status:1 extra:[self.tracker detailTrackerCommonParams]];
}

- (void)p_startWebTransformWhenInfoGetIfNeed
{
    //added 5.9.9 info返回后增加一次判断是否需要转码
    if (![self.detailViewModel tt_webHasBeenTransformed]) {
        [self p_startLoadNativeContentForWebTimeoffIfNeeded];
    }
}

- (void)p_registerWebViewUserAgent
{
    [SSWebViewUtil registerUserAgent:_detailModel.article.shouldUseCustomUserAgent];
}

- (void)p_registerArticleDetailCloseCallback
{
    [self.detailWebView.webView ttr_fireEvent:@"close" data:nil];
    
    if (self.detailWebView.webView == [self.class sharedWebView]) {
        return; //共享webview 不需要延迟释放
    }
    // 延时释放，确保close事件调用成功
    TTDetailWebviewContainer *detailWebViewContainer = self.detailWebView;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        // 这里随便写了一条语句，避免编译器把这个block优化没了
        detailWebViewContainer.natantStyle = 0;
    });
}

- (void)p_registerADInfoCallback
{
    WeakSelf;
    [_detailWebView.webView.ttr_staticPlugin registerHandlerBlock:^(NSDictionary *result, TTRJSBResponse callback) {
        
        StrongSelf;
        
        NSNumber *cid = self.detailModel.adID?self.detailModel.adID:@(0);
        NSString *cidString;
        if (cid) {
            cidString = [NSString stringWithFormat:@"%@",cid];
        }
        cidString = cidString ? cidString : @"";
        
        NSString *adLogExtra = !isEmptyString(self.detailModel.adLogExtra)?self.detailModel.adLogExtra:@"";
        
        NSString *adExtraString = nil;
        
        if (self.detailModel.orderedData && self.detailModel.orderedData.adEventLinkModel) {
            NSString *adEventLinkString = [self.detailModel.orderedData.adEventLinkModel webPageEventLinkExtraData];
            if (!isEmptyString(adEventLinkString)) {
                adExtraString = adEventLinkString;
            }
        }
        
        adExtraString = !isEmptyString(adExtraString) ? adExtraString : @"";
        
        NSDictionary *dic = @{@"cid":cidString,
                              @"log_extra":adLogExtra,
                              @"ad_extra_data":adExtraString};
        if (callback) {
            callback(TTRJSBMsgSuccess, [dic copy]);
        }
    } forMethodName:@"adInfo"];
}

- (void)p_registerActionSheetCallback {
    WeakSelf;
    [self.detailWebView.webView.ttr_staticPlugin registerHandlerBlock:^(NSDictionary *result, TTRJSBResponse callback) {
        StrongSelf;
        [self.delegate tt_articleDetailViewWillShowActionSheet:result];
    } forMethodName:@"showActionSheet"];
}

- (void)p_registerDislikeCallback {
    WeakSelf;
    [self.detailWebView.webView.ttr_staticPlugin registerHandlerBlock:^(NSDictionary *result, TTRJSBResponse callback) {
        StrongSelf;
        [self.delegate tt_articleDetailViewWillShowDislike:result];
    } forMethodName:@"dislike"];
}

- (void)p_registerMenuItemTypos {
    WeakSelf;
    [self.detailWebView.webView.ttr_staticPlugin registerHandlerBlock:^(NSDictionary *result, TTRJSBResponse callback) {
        StrongSelf;
        [self.delegate tt_articleDetailViewTypos:[result tt_arrayValueForKey:@"strings"]];
    } forMethodName:@"typos"];
}

- (void)p_registerUserFollowActionCallback {
    WeakSelf;
    [self.detailWebView.webView.ttr_staticPlugin registerHandlerBlock:^(NSDictionary *result, TTRJSBResponse callback) {
        FriendDataManager *dataManager = [FriendDataManager sharedManager];
        FriendActionType actionType;
        if ([[result tt_stringValueForKey:@"action"] isEqualToString:@"dofollow"]) {
            actionType = FriendActionTypeFollow;
        }
        else {
            actionType = FriendActionTypeUnfollow;
        }
        
        
        
        [[TTFollowManager sharedManager] startFollowAction:actionType userID:[result tt_stringValueForKey:@"id"] platform:nil name:nil from:nil reason:nil newReason:@([result tt_longValueForKey:@"reason"]) newSource:@(TTFollowNewSourceNewsDetailRecommend) completion:^(FriendActionType type, NSError * _Nullable error, NSDictionary * _Nullable result) {
            NSMutableDictionary *jsCallbackParameters = [[NSMutableDictionary alloc] init];
            if (!error) {
                NSDictionary *response = [result tt_dictionaryValueForKey:@"result"];
                NSDictionary *data = [response tt_dictionaryValueForKey:@"data"];
                NSDictionary *user = [data tt_dictionaryValueForKey:@"user"];
                [user tt_boolValueForKey:@"is_following"];
                [jsCallbackParameters setObject:@"1" forKey:@"code"];
                [jsCallbackParameters setObject:@"success" forKey:@"message"];
                if (type == FriendActionTypeFollow) {
                    [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:@"关注成功" indicatorImage:[UIImage themedImageNamed:@"doneicon_popup_textpage.png"] autoDismiss:YES dismissHandler:nil];
                }
            }
            else {
                NSString *hint = [[[result tt_dictionaryValueForKey:@"result"] tt_dictionaryValueForKey:@"data"] tt_stringValueForKey:@"description"];
                if (isEmptyString(hint)) {
                    hint = NSLocalizedString(actionType == FriendActionTypeFollow ? @"关注失败" : @"取消关注失败", nil);
                }
                [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:hint indicatorImage:[UIImage themedImageNamed:@"close_popup_textpage"] autoDismiss:YES dismissHandler:nil];
                [jsCallbackParameters setObject:@"0" forKey:@"code"];
                [jsCallbackParameters setObject:hint forKey:@"message"];
            }
            if (callback) {
                callback(TTRJSBMsgSuccess, jsCallbackParameters);
            }
        }];
    } forMethodName:@"user_follow_action"];
}

- (void)p_registerArticleWebViewJSCallback
{
    [self p_registerArticleWebViewImageCallback];
    [self p_registerArticleWebViewVideoCallback];
    [self p_registerADInfoCallback];
    [self p_registerActionSheetCallback];
    [self p_registerDislikeCallback];
    [self p_registerMenuItemTypos];
    [self p_registerUserFollowActionCallback];
}

- (void)p_registerArticleWebViewImageCallback
{
    __weak typeof(self) weakSelf = self;
    //显示webView正文图片
    [_detailWebView tt_registerWebImageWithLargeImageModels:[_detailModel.article detailLargeImageModels] thumbImageModels:[_detailModel.article detailThumbImageModels] loadImageMode:_detailModel.article.imageMode showOriginForThumbIfCached:YES evaluateJsCallbackBlock:^(NSString *jsMethod) {
        [weakSelf p_detailWebView:weakSelf.detailWebView.webView stringByEvaluatingJavaScriptFromString:jsMethod];
    }];
    
    [_detailWebView tt_registerCarouselBackUpdateWithCallback:^(NSInteger index, CGRect updatedFrame) {
        NSMutableArray *frames = [weakSelf.photoScrollViewController.placeholderSourceViewFrames mutableCopy];
        updatedFrame = [weakSelf.detailWebView.webView.scrollView convertRect:updatedFrame toView:nil];
        [frames setObject:[NSValue valueWithCGRect:updatedFrame] atIndexedSubscript:index];
        weakSelf.photoScrollViewController.placeholderSourceViewFrames = frames;
    }];
}

- (NSString *)enterFromString{
    NSString * enterFrom = self.detailModel.clickLabel;
    if (self.detailModel.fromSource == NewsGoDetailFromSourceCategory | self.detailModel.fromSource == NewsGoDetailFromSourceVideoFloat) {
        enterFrom = @"click_category";
    }else if(self.detailModel.fromSource == NewsGoDetailFromSourceClickTodayExtenstion) {
        enterFrom = @"click_widget";
    }
    if (isEmptyString(enterFrom) && !isEmptyString(self.detailModel.gdLabel)) {
        enterFrom = self.detailModel.gdLabel;
    }
    return enterFrom;
}

- (NSString *)categoryName
{
    NSString *categoryName = self.detailModel.categoryID;
    if (!categoryName || [categoryName isEqualToString:@"xx"] ) {
        categoryName = [[self enterFromString] stringByReplacingOccurrencesOfString:@"click_" withString:@""];
    }else{
        if (![[self enterFromString] isEqualToString:@"click_headline"]) {
            if ([categoryName hasPrefix:@"_"]) {
                categoryName = [categoryName substringFromIndex:1];
            }
        }
    }
    return categoryName;
}

- (void)p_registerArticleWebViewVideoCallback
{
    //显示webView正文视频
    NSString * aID = [_detailModel.adID longLongValue] > 0 ? [NSString stringWithFormat:@"%@", _detailModel.adID] : @"";
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setValue:[NSNumber numberWithBool:YES] forKey:@"isInDetail"];
    [dic setValue:_detailModel.article.groupModel.itemID forKey:@"item_id"];
    [dic setValue:_detailModel.article.groupModel.groupID forKey:@"group_id"];
    [dic setValue:@(_detailModel.article.groupModel.aggrType) forKey:@"aggr_type"];
    [dic setValue:aID forKey:@"aID"];
    [dic setValue:_detailModel.categoryID forKey:@"cID"];
    [dic setValue:_detailModel.article.title forKey:@"movieTitle"];
    [dic setValue:_detailModel.adLogExtra forKey:@"log_extra"];
    [dic setValue:_detailModel.clickLabel forKey:@"gd_label"];
    [dic setValue:[_detailModel.article videoThirdMonitorUrl] forKey:@"videoThirdMonitorUrl"];
    TTVPlayerUrlTracker *tracker = [_detailModel.orderedData videoPlayTracker];
    [dic setValue:tracker.clickTrackURLs forKey:@"adClickTrackURLs"];
    [dic setValue:tracker.playOverTrackUrls forKey:@"adPlayOverTrackUrls"];
    [dic setValue:tracker.effectivePlayTrackUrls forKey:@"adPlayEffectiveTrackUrls"];
    [dic setValue:tracker.activePlayTrackUrls forKey:@"adPlayActiveTrackUrls"];
    [dic setValue:tracker.playTrackUrls forKey:@"adPlayTrackUrls"];
    [dic setValue:@(tracker.effectivePlayTime) forKey:@"effectivePlayTime"];
    [dic setValue:_detailModel.article.videoID forKey:@"video_id"];
    [dic setValue:_detailModel.logPb forKey:@"log_pb"];
    [dic setValue:[self enterFromString] forKey:@"enter_from"];
    [dic setValue:[self categoryName] forKey:@"category_name"];
    [dic setValue:@(NO) forKey:@"playerShowShareMore"];
    [dic setValue:[self.detailModel.article.userInfo ttgc_contentID] forKey:@"author_id"];
//    largeImageDict
    [_detailWebView tt_registerWebVideoWithMovieViewInfo:dic];
}

- (BOOL)p_checkArticleReliable
{
    return self.detailModel.isArticleReliable;
}

- (void)p_webViewUpdateFontSize
{
    NSString *fontSizeType = [TTUserSettingsManager settedFontShortString];
    NSString *updateFontJS = [NSString stringWithFormat:@"window.TouTiao && TouTiao.setFontSize(\"%@\")", fontSizeType];
    [self p_detailWebView:_detailWebView.webView stringByEvaluatingJavaScriptFromString:updateFontJS];
}

- (void)p_showLoadingView
{
    CGFloat toolbarHeight = 44.5;
    CGFloat topEdgeInsetHeight = 64;
    self.ttContentInset = UIEdgeInsetsMake(0, 0, topEdgeInsetHeight + toolbarHeight, 0);
    [self tt_startUpdate];
}

- (void)p_removeLoadingView
{
    [self tt_endUpdataData];
}

- (void)p_refreshDetailTheme
{
    if(/*![TTDeviceHelper isPadDevice] &&*/ self.detailModel.article)
    {
        if([self.detailViewModel tt_articleDetailLoadedContentType] == ArticleTypeWebContent &&
           self.detailModel.article.articleSubType == ArticleSubTypeCooperationWap)
        {
            self.detailWebView.webView.disableThemedMask = YES;
        }
        else {
            if (self.domReady) {
                NSString *js = [NSString stringWithFormat:@"window.TouTiao && TouTiao.setDayMode(%d)", [[TTThemeManager sharedInstance_tt] currentThemeMode] == TTThemeModeDay];
                [self p_detailWebView:self.detailWebView.webView stringByEvaluatingJavaScriptFromString:js];
            }
        }
    }
}

- (NSString *)p_detailWebView:(YSWebView *)wView stringByEvaluatingJavaScriptFromString:(NSString *)jsStr
{
    if (isEmptyString(jsStr) || ![_detailViewModel tt_detailNeedLoadJS]) {
        return nil;
    }
    return [wView stringByEvaluatingJavaScriptFromString:jsStr completionHandler:nil];
}

- (void)p_startLoadWebTypeContentDirectlyIfNeeded
{
    if (isEmptyString(_detailModel.article.articleURLString)) {
        return;
    }
    
    [_detailWebView.webView stopLoading];
    
    [_detailWebView.webView loadRequest:[_detailViewModel tt_requstForWebContentArticle] appendBizParams:_detailModel.adID.longLongValue == 0];
    
    if ([_detailModel.article.groupType intValue]==ArticleGroupTypeTopic) {
        [self startCountDownTimer];
    }
    
}

//直接执行下发的js脚本
- (void)p_executeJsForWebViewWithJS:(NSString *)js
{
    if (!isEmptyString(js) && !_webViewHasExecuteScriptJS) {
        [self.detailWebView.webView stringByEvaluatingJavaScriptFromString:js
                                                         completionHandler:nil];
        _webViewHasExecuteScriptJS = YES;
    }
}

//调fe方法，下发的字段作为参数
- (void)p_insertJSContext:(NSString *)contextStr
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (isEmptyString(contextStr) || _webViewHasInsertedContextJS) {
            return;
        }
        
        NSString * insertStr = [NSString stringWithFormat:@";window.insertDiv && insertDiv(%@);", contextStr];
        [_detailWebView.webView stringByEvaluatingJavaScriptFromString:insertStr completionHandler:nil];
        _webViewHasInsertedContextJS = YES;
    });
}

- (void)p_injectInfomationJSIfNeed {
    
    if (self.hasInfomationJSInjected) {
        return;
    }
    
    if (!self.didWebViewFinished) {
        return;
    }
    
    if (!self.hasInfomationGet) {
        return;
    }
    
    if (!self.domReady) {
        return;
    }
    
    self.hasInfomationJSInjected = YES;
    
    [self.detailWebView.webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"window.setExtra && setExtra(%@)", [self.detailViewModel tt_h5ExtraDictWithArticle:self.detailModel.article].JSONRepresentation] completionHandler:nil];
    [self p_executeJsForWebViewWithJS:self.infoManager.insertedJavaScript];
    [self p_insertJSContext:self.infoManager.insertedContextJS];
}

- (void)p_execWebTypeArticleRedirectURLScript
{
    NSString *itemID = self.detailModel.article.groupModel.itemID;
    if (isEmptyString(itemID)) {
        itemID = @"0";
    }
    
    if (!isEmptyString(_webViewURLBeforeRedirection)) {
        [_detailWebView.webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"window._toutiao_param_originUrl = '%@';", _webViewURLBeforeRedirection] completionHandler:nil];
    }
    
    NSString *execJs = [NSString stringWithFormat:@"window._toutiao_param_groupid = '%@'; \
                        window._toutiao_param_itemid = '%@';", self.detailModel.article.groupModel.groupID, itemID];
    [_detailWebView.webView stringByEvaluatingJavaScriptFromString:execJs completionHandler:nil];
    LOGD(@"webView response redirect has reported to url %@", _webViewRedirectToURL);
}

- (void)p_addNotiCenterObservers
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(pn_fontChanged)
                                                 name:kSettingFontSizeChangedNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(pn_didEnterBackground)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(pn_willEnterForeground)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pn_applicationStautsBarDidRotate) name:@"TTDetailRelateArticleGroupViewUpdate" object:nil];
}

- (CGRect)p_frameForVisableRect
{
    //区分是否展示了toolbar
    TTDetailArchType detailType = [self.detailViewModel tt_articleDetailType];
    UIEdgeInsets safeAreaInset = self.tt_safeAreaInsets;
    if (detailType == TTDetailArchTypeNormal) {
        return CGRectMake(0, 0, self.width, self.height - 44.5 - safeAreaInset.bottom);
    }
    else {
        return CGRectMake(0, 0, self.width, self.height);
    }
}

- (void)p_updateTitleViewAnimationTriggerPos
{
    __weak typeof(self) weakSelf = self;
    [self.detailWebView.webView stringByEvaluatingJavaScriptFromString:@";window.getElementPosition && getElementPosition(\"#profile\");" completionHandler:^(NSString * _Nullable result, NSError * _Nullable error) {
        if (!isEmptyString(result)) {
            CGRect frame = CGRectFromString(result);
            if (!CGRectIsEmpty(frame)) {
                weakSelf.titleViewAnimationTriggerPosY = frame.origin.y + frame.size.height;
            } else {
                weakSelf.titleViewAnimationTriggerPosY = 100; // 默认
            }
        } else {
            weakSelf.titleViewAnimationTriggerPosY = 100; // 默认
        }
    }];
}

- (void)p_updateStoryToolViewAnimationTriggerPos
{
    if (![self tt_isNovelArticle]) {
        return;
    }
    __weak typeof(self) wself = self;
    [self.detailWebView.webView stringByEvaluatingJavaScriptFromString:@";window.getElementPosition && getElementPosition(\".serial\");" completionHandler:^(NSString * _Nullable result, NSError * _Nullable error) {
        __strong typeof(wself) self = wself;
        LOGD(@"storyToolView add location is %@, error is %@", result, error);
        if (!isEmptyString(result)) {
            CGRect frame = CGRectFromString(result);
            if (!CGRectIsEmpty(frame)) {
                self.storyToolViewAnimationTriggerPosY = frame.origin.y + frame.size.height;
            }
        }
    }];
}

- (void)p_skipReadPartIfNeed {
    SSLog(@"skip get");
    if (![SSCommonLogic isEnableArticleReadPosition]) {
        return;
    }
    
    //WK下 跳转后会被 系统置回来.... 暂时对WK关闭 @zengruihuan
    if (self.detailWebView.webView.isWKWebView) {
        return;
    }
    
    //只对转码页和小说生效
    if ([self.detailViewModel tt_articleDetailLoadedContentType] != TTArticleDetailLoadedContentTypeNative && ![self tt_isNovelArticle]) {
        return;
    }
    //if小说, 只跳转上次阅读的章节
    if ([self tt_isNovelArticle] && ![TTNovelRecordManager isLastReadChapter:self.detailModel.article.itemID inBook:self.detailModel.article.novelData[@"book_id"]]) {
        return;
    }
    //用户滚动了就不再跳转
    if (!CGPointEqualToPoint(self.detailWebView.webView.scrollView.contentOffset, CGPointZero)) {
        return;
    }
    
    [self.detailWebView setWebContentOffset:CGPointMake(0, [self.detailViewModel tt_getLastContentOffsetY])];
    //原地滚动一下, 猜测是前端监听了scroll时间来懒加载图片
    [self.detailWebView.webView evaluateJavaScriptFromString:@"window.scrollBy(0, 0)" completionBlock:nil];
}

- (void)p_uploadArticlePositionIfNeed {
    CGFloat offset = self.detailWebView.webView.scrollView.contentOffset.y;
    SSJSBridgeWebView *webView = self.detailWebView.webView;
    CGFloat contentHeight = [self.detailWebView webViewContentHeight];
    if (webView.scrollView.contentOffset.y + webView.height > contentHeight) {
        offset = contentHeight - webView.height;
    }
    offset = offset > 0? offset: 0;
    [self.detailViewModel tt_setContentOffsetY:offset];
    if ([self tt_isNovelArticle]) {
        [self.detailViewModel tt_uploadArticlePosition:offset finishBlock:nil];//暂时不需要回调 @by zengruihuan
    }
}

- (void)p_sendDetailTimeIntervalMonitorForService:(NSString *)serviceName
{
    NSString *intervalString = [_monitor intervalFromWebRequestStartTime];
    if (!isEmptyString(intervalString)) {
        //        LOGD(@"[%@]intervalString is %@", serviceName, intervalString);
        [[TTMonitor shareManager] trackService:serviceName value:intervalString extra:[self.tracker detailTrackerCommonParams]];
    }
}

- (void)p_setWebViewAudioSessionCategoryIfNeed
{
    NSError *error = nil;
    BOOL res = [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:&error];
    if (!res) {
        LOGD(@"webView audio session set category error : %@", error);
    }
    else {
        _webViewAudioSessionCategorySet = YES;
    }
}

// 离开文章页时暂停所有音频播放
- (void)p_pauseAudiosWhenDisappeared
{
    NSString *script = @"var audios = document.getElementsByTagName(\"audio\"); \
    var arr = Array.prototype.slice.call(audios); \
    for (var i = arr.length - 1; i >= 0; i--) { \
    arr[i].pause(); \
    };";
    [self.detailWebView.webView stringByEvaluatingJavaScriptFromString:script completionHandler:^(id _Nullable instance, NSError * _Nullable error) {
        if (error) {
            LOGD(@"error occured when stop page audios %@", error.localizedDescription);
        }
    }];
}

- (BOOL)p_hasAudioInArticle
{
    NSString *script = @"var audios = document.getElementsByTagName(\"audio\"); \
    var arr = Array.prototype.slice.call(audios); \
    arr.length > 0;";
    __block BOOL hasAudio = NO;
    [self.detailWebView.webView stringByEvaluatingJavaScriptFromString:script completionHandler:^(id _Nullable instance, NSError * _Nullable error) {
        if (!error && [instance isKindOfClass:[NSString class]]) {
            hasAudio = [(NSString *)instance isEqualToString:@"true"];
        }
    }];
    return hasAudio;
}

- (BOOL)p_clickJumpRecognized
{
    if ([self.detailModel.adID longLongValue] == 0 || ![SSCommonLogic shouldClickJumpControlEnabled]) {
        return NO;
    }
    NSTimeInterval interval = fabs([[NSDate date] timeIntervalSince1970] - self.clickTimeStamp) * 1000;
    return interval <= [SSCommonLogic clickJumpTimeInterval];
}

- (void)p_handleTapGesture:(UIGestureRecognizer *)recognizer
{
    self.clickTimeStamp = [[NSDate date] timeIntervalSince1970];
}

#pragma mark - Notifications

- (void)pn_fontChanged
{
    if (_delegate && [_delegate respondsToSelector:@selector(tt_articleDetailViewWillChangeFontSize)]) {
        [_delegate tt_articleDetailViewWillChangeFontSize];
    }
    
    [self p_webViewUpdateFontSize];
    
    [self p_updateTitleViewAnimationTriggerPos];
    [self p_updateStoryToolViewAnimationTriggerPos];
    
    if (_delegate && [_delegate respondsToSelector:@selector(tt_articleDetailViewDidChangeFontSize)]) {
        [_delegate tt_articleDetailViewDidChangeFontSize];
    }
}

- (void)pn_didEnterBackground {
    // 如果加载期间切换到后台，则放弃这一次统计
    _didEnterBackground = YES;
    [_tracker tt_resetStartLoadDate];
    [_tracker tt_sendJumpLinksTrackWithKey:_infoManager.webViewTrackKey];
    
    //added 5.7.*:退到后台也发送read_pct事件
    if (self.detailWebView && !_didDisAppear) {
        [self.tracker tt_sendReadTrackWithPCT:[self.detailWebView readPCTValue] pageCount:[self.detailWebView pageCount]];
        [self.tracker tt_sendStayTimeImpresssion];
    }
}

- (void)pn_willEnterForeground {
    _didEnterBackground = NO;
}

- (void)pn_applicationStautsBarDidRotate {
    if (_delegate && [_delegate respondsToSelector:@selector(tt_articleApplicationStautsBarDidRotate)]) {
        [_delegate tt_articleApplicationStautsBarDidRotate];
    }
}

#pragma mark - UIViewControllerErrorHandler

- (BOOL)tt_hasValidateData
{
    if (_isWebViewLoading) {
        if (_webViewHasError) {
            return NO;
        }
        return YES;
    }
    return NO;
}

#pragma mark - TTDetailWebViewDelegate

- (BOOL)webViewContentIsNativeType
{
    return [self.detailViewModel tt_articleDetailLoadedContentType] == TTArticleDetailLoadedContentTypeNative;
}

- (void)webViewDidChangeContentSize
{
    [self p_updateStoryToolViewAnimationTriggerPos];
}

- (void)webViewContainerWillShowFirstCommentCellByScrolling
{
    if (_delegate && [_delegate respondsToSelector:@selector(tt_articleDetailViewWillShowFirstCommentCell)]) {
        [_delegate tt_articleDetailViewWillShowFirstCommentCell];
    }
}

- (void)webViewContainerInFooterHalfShowStatusWithScrollOffset:(CGFloat)rOffset
{
    if (_delegate && [_delegate respondsToSelector:@selector(tt_articleDetailViewFooterHalfStatusOffset:)]) {
        [_delegate tt_articleDetailViewFooterHalfStatusOffset:rOffset];
    }
}


- (BOOL)webView:(YSWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(YSWebViewNavigationType)navigationType
{
    //检测导流页302跳转
    if ([self.detailViewModel tt_articleDetailLoadedContentType] == ArticleTypeWebContent && self.detailModel.adID.longLongValue == 0) {
        if (!_webTypeContentStatusCodeChecked) {
            //fix:导流页302时，读取缓存会导致再次进入时不发请求造成白屏，强制忽略缓存
            NSURLRequest *noCacheRequest = [NSURLRequest requestWithURL:request.URL cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:3.f];
            NSMutableURLRequest *mutableRequest = [noCacheRequest mutableCopy];
            [mutableRequest setValue:[SSWebViewUtil userAgentString:YES] forHTTPHeaderField:@"User-Agent"];
            NSURLConnection *connection = [NSURLConnection connectionWithRequest:[mutableRequest copy] delegate:self];
            if (!connection) {
                LOGD(@"cannot create webTypeContent httpHeader check connection");
            }
            else {
                return NO;
            }
        }
    }
    
    if ([self.detailModel.adID longLongValue] != 0) {
        /// 如果是广告的，则需要统计连接跳转。需求说明一下，这是一个很蛋疼的统计，要统计广告落地页中，所有跳转的统计
        BOOL needReport = (navigationType == UIWebViewNavigationTypeLinkClicked || navigationType == UIWebViewNavigationTypeFormSubmitted);
        if (needReport) {
            self.tracker.jumpCount ++;
            if (navigationType == UIWebViewNavigationTypeLinkClicked) {
                self.tracker.clickLinkCount ++;
            }
        }
        
        if (navigationType == UIWebViewNavigationTypeLinkClicked || [self p_clickJumpRecognized]) {
            NSSet *blackList = [SSCommonLogic blackListForClickJump];
            if ([blackList containsObject:request.URL.scheme]) {
                NSString *tips = [SSCommonLogic frobidClickJumpTips];
                if (!isEmptyString(tips)) {
                    [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:tips indicatorImage:nil autoDismiss:YES dismissHandler:nil];
                }
                return NO;
            }
        } else if (self.shouldInterceptAutoJump) {
            NSSet *whitList = [SSCommonLogic whiteListForAutoJump];
            if (![whitList containsObject:request.URL.scheme]) {
                return NO;
            }
        }
    }
    if (navigationType == UIWebViewNavigationTypeLinkClicked) {
        self.tracker.userHasClickLink = YES;
    }
    
    //统计跳转到某个URL
    if (!isEmptyString(request.URL.absoluteString)) {
        [self.tracker.jumpLinks addObject:request.URL.absoluteString];
    }
    
    // stay_page统计需求  需求：https://wiki.bytedance.net/pages/viewpage.action?pageId=89884456
    if ([ArticleWebViewToAppStoreManager isToAppStoreRequestURLStr:request.URL.absoluteString]) {
        [self.tracker tt_sendJumpOutAppEventTrack];
    }
    
    //webview跳转app store; 需求：https://wiki.bytedance.com/pages/viewpage.action?pageId=40699201
    if ([ArticleWebViewToAppStoreManager isToAppStoreRequestURLStr:request.URL.absoluteString] && [self.detailViewModel tt_articleDetailLoadedContentType] == ArticleTypeWebContent && [self.detailModel.adID longLongValue] == 0) {
        if (![[ArticleWebViewToAppStoreManager sharedManager] isAllowedURLStr:self.detailModel.article.articleURLString]) {
            [self.tracker tt_sendJumpToAppStoreTrackWithReuqestURLStr:request.URL.absoluteString inWhiteList:NO];
            return NO;
        } else {
            [self.tracker tt_sendJumpToAppStoreTrackWithReuqestURLStr:request.URL.absoluteString inWhiteList:YES];
        }
    }
    
    //针对WKWebview 的下载做一个特殊处理 主动通过openURL去打开AppStore nick -5.6
    if ([ArticleWebViewToAppStoreManager isToAppStoreRequestURLStr:request.URL.absoluteString] && [webView isWKWebView]) {
        if ([[UIApplication sharedApplication] canOpenURL:request.URL]) {
            [[UIApplication sharedApplication] openURL:request.URL];
            return NO;
        }
    }
    
    if (!_webViewAudioSessionCategorySet) {
        if ([self p_hasAudioInArticle]) {
            [self p_setWebViewAudioSessionCategoryIfNeed];
        }
    }
    
    return YES;
}

- (void)webView:(nullable YSWebView *)webView scrollViewDidScroll:(nullable UIScrollView *)scrollView{
    //1.do something in this class if needed
    //2. call to upper
    if ([self.delegate respondsToSelector:@selector(webView:scrollViewDidScroll:)]) {
        [self.delegate webView:self.detailWebView scrollViewDidScroll:scrollView];
    }
}

- (void)webView:(TTDetailWebviewContainer *)webViewContainer scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if ([self.delegate respondsToSelector:@selector(webView:scrollViewDidEndDragging:willDecelerate:)]) {
        [self.delegate webView:self.detailWebView scrollViewDidEndDragging:scrollView willDecelerate:decelerate];
    }
}

- (void)webViewWillCloseFooter
{
    if (_delegate && [_delegate respondsToSelector:@selector(tt_articleDetailViewWillCloseFooter)]) {
        [_delegate tt_articleDetailViewWillCloseFooter];
    }
}


- (void)webViewDidStartLoad:(YSWebView *)webView
{
    if (!isEmptyString(_latestWebViewRequestURLString)) {
        BOOL isHTTP = [webView.request.URL.scheme isEqualToString:@"http"] || [webView.request.URL.scheme isEqualToString:@"https"];
        if (![webView.request.URL.absoluteString isEqualToString:_latestWebViewRequestURLString] && isHTTP) {
            self.webStayState = SSWebViewStayStatCancel;
            // 页面发生跳转，发送取消事件(里面会判断是否已经发送过其他事件，如果发送过，则不会重复发送)
            [self.tracker tt_sendStatStayEventTrack:SSWebViewStayStatCancel error:nil];
        }
    }
    _isWebViewLoading = YES;
    _latestWebViewRequestURLString = webView.request.URL.absoluteString;
}

- (void)webViewDidFinishLoad:(YSWebView *)webView
{
    self.didWebViewFinished = YES;
    //导流页302重定向上报
    if ([self.detailViewModel tt_articleDetailLoadedContentType] == ArticleTypeWebContent) {
        //给重定向后的页面上报原请求URL
        [self p_execWebTypeArticleRedirectURLScript];
    }
    
    if (self.ttViewType == TTFullScreenErrorViewTypeDeleted) {
        self.domReady = YES;
        return;
    }
    [self stopCountDownTimer];
    //移除可能正在显示的loadingView
    [self p_removeLoadingView];
    
    //合作页的script在此注入
    //    [self p_executeJsForWebViewWithJS:self.infoManager.insertedJavaScript];
    //导流页的domreay和didFinished等价. 转码页domReady的在processRequestReceiveDomReady
    if ([self.detailViewModel tt_articleDetailLoadedContentType] == ArticleTypeWebContent) {
        self.domReady = YES;
    }
    
    [self p_injectInfomationJSIfNeed];
    
    //所有类型导流页didFinish耗时monitor
    if ([self.detailViewModel tt_articleDetailLoadedContentType] == ArticleTypeWebContent &&
        !_webTypeContentDidFinishLoadMonitorSent) {
        _webTypeContentDidFinishLoadMonitorSent = YES;
        [self p_sendDetailTimeIntervalMonitorForService:@"web_finish_load"];
    }
    
    //广告监控统计 注入js
    NSNumber *adIDNumber = _detailModel.adID;
    if ([adIDNumber longLongValue] > 0) {
        self.webTapGesture.enabled = YES;
        [webView stringByEvaluatingJavaScriptFromString:[SSCommonLogic shouldEvaluateActLogJsStringForAdID:[adIDNumber stringValue]] completionHandler:nil];
    }
    self.webStayState = SSWebViewStayStatLoadFinish;
    [self.tracker tt_sendStatStayEventTrack:SSWebViewStayStatLoadFinish error:nil];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self p_webViewUpdateFontSize];
        _webViewHasError = NO;
    });
}


- (void)webView:(YSWebView *)webView didFailLoadWithError:(NSError *)error
{
    if (self.ttViewType == TTFullScreenErrorViewTypeDeleted) {
        self.domReady = YES;
        return;
    }
    [self stopCountDownTimer];
    //移除可能正在显示的loadingView
    [self p_removeLoadingView];
    
    self.domReady = YES;
    [self p_executeJsForWebViewWithJS:self.infoManager.insertedJavaScript];
    
    __weak __typeof(self)wself = self;
    [webView evaluateJavaScriptFromString:@"document.body.childElementCount;" completionBlock:^(NSString * _Nullable result, NSError * _Nullable error) {
        __strong typeof(wself) sself = wself;
        if ([result isEqualToString:@"0"]) {
            if (sself) {
                sself->_webViewHasError = YES;
            }
        }
    }];
    self.webStayState = SSWebViewStayStatLoadFail;
    [self.tracker tt_sendStatStayEventTrack:SSWebViewStayStatLoadFail error:error];
    
    //    if (!TTNetworkConnected()) {
    //        [self tt_endUpdataData:NO error:[NSError errorWithDomain:NSLocalizedString(@"没有网络连接", nil) code:-3 userInfo:@{@"errmsg":NSLocalizedString(@"没有网络连接", nil)}]];
    //    }
}


- (void)startCountDownTimer{
    if (![SSCommonLogic enabledWhitePageMonitor]) {
        return;
    }
    if (self.countDownTimer) {
        if ([self.countDownTimer isValid]) {
            [self.countDownTimer invalidate];
        }
        self.countDownTimer = nil;
    }
    self.countDownTimer = [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(guardTimerExceeded:) userInfo:nil repeats:NO];
    [[NSRunLoop currentRunLoop] addTimer:self.countDownTimer forMode:NSRunLoopCommonModes];
}

- (void)stopCountDownTimer{
    if (self.countDownTimer) {
        if ([self.countDownTimer isValid]) {
            [self.countDownTimer invalidate];
        }
        self.countDownTimer = nil;
    }
}

- (void)guardTimerExceeded:(id)sender{
    //    LOGD(@"TTArticleDetailView guardTimer");
    NSMutableDictionary * params = [[NSMutableDictionary alloc] init];
    [params setValue:self.requestUrlString forKey:@"url"];
    NSURL * url = [NSURL URLWithString:self.requestUrlString];
    if (url) {
        [params setValue:[url host] forKey:@"hostname"];
    }
    [params setValue:@"subject" forKey:@"pathname"];
    [params setValue:@"fail" forKey:@"page_status"];
    [params setValue:[TTNetworkHelper connectMethodName] forKey:@"net_type"];
    [self stopCountDownTimer];
    //    [[TTMonitor shareManager] trackData:params logType:@"empty_webview"];
    [[TTNetworkManager shareInstance] requestForBinaryWithURL:@"http://toutiao.com/__utm.gif" params:params method:@"GET" needCommonParams:YES callback:^(NSError *error, id obj) {
        if (error.code == TTNetworkErrorCodeSuccess) {
            NSString * decodeStr = [[NSString alloc] initWithData:obj encoding:NSUTF8StringEncoding];
            if (!isEmptyString(decodeStr)) {
            }
        }
    }];
    
}

#pragma mark - TTDetailWebViewRequestProcessorDelegate

- (void)processRequestReceiveDomReady
{
    //移除可能正在显示的loadingView
    [self p_removeLoadingView];
    self.domReady = YES;
    //转码页的script在此注入
    //    [self p_executeJsForWebViewWithJS:self.infoManager.insertedJavaScript];
    //    [self p_insertJSContext:self.infoManager.insertedContextJS];
    [self p_injectInfomationJSIfNeed];
    
    // titleView 位置
    [self p_updateTitleViewAnimationTriggerPos];
    
    // 连载小说动画触发位置更新
    [self p_updateStoryToolViewAnimationTriggerPos];
    [self p_skipReadPartIfNeed];
    
    [self p_didFinishedLoadInSharedWebView];
    //做统计
    [self.tracker tt_sendStartLoadDateTrackIfNeeded];
    
    //转码和合作导流加载耗时monitor
    //    LOGD(@"native_dom_ready interval %@", [_monitor intervalFromWebRequestStartTime]);
    
    
    if ([self.detailViewModel tt_articleDetailLoadedContentType] == ArticleTypeWebContent) {
        if (_webTypeContentDidFinishLoadMonitorSent) {
            return;
        }
        _webTypeContentDidFinishLoadMonitorSent = YES;
        [self p_sendDetailTimeIntervalMonitorForService:@"web_finish_load"];
    } else {
        [self p_sendDetailTimeIntervalMonitorForService:[SSCommonLogic detailSharedWebViewEnabled]? @"native_dom_ready_new": @"native_dom_ready"];
    }
    
    if ([self.delegate respondsToSelector:@selector(tt_articleDetailViewDidDomReady)]) {
        [self.delegate tt_articleDetailViewDidDomReady];
    }
}

- (void)processRequestUpdateArticleImageMode:(NSNumber *)mode
{
    @try {
        self.detailModel.article.imageMode = mode;
        [self.detailModel.article save];
        //[[SSModelManager sharedManager] save:nil];
    }
    @catch (NSException *exception) {
    }
}

- (void)processRequestOpenWebViewUseURL:(NSURL *)url supportRotate:(BOOL)support
{
    if (url) {
        NSMutableDictionary *params = [NSMutableDictionary dictionary];
        [params setValue:self.detailModel.clickLabel forKey:@"gd_lable"];
        ssOpenWebView(url, nil, [TTUIResponderHelper topNavigationControllerFor: self], support, params);
    }
}

- (void)processRequestShowImgInPhotoScrollViewAtIndex:(NSUInteger)index withFrameValue:(NSValue *)frameValue
{
    // show photo scroll view
    
    wrapperTrackEvent(@"image", @"enter_detail");
    TTPhotoScrollViewController *showImageViewController = [[TTPhotoScrollViewController alloc] init];
    self.photoScrollViewController = showImageViewController;
    showImageViewController.targetView = self.detailWebView.webView.scrollView;
    showImageViewController.finishBackView = [TTInteractExitHelper getSuitableFinishBackViewWithCurrentContext];
    NSArray *infoModels = [self.detailModel.article detailLargeImageModels];
    showImageViewController.imageInfosModels = infoModels;
    [showImageViewController setStartWithIndex:index];
    WeakSelf;
    showImageViewController.indexUpdatedBlock = ^(NSInteger lastIndex, NSInteger currentIndex) {
        StrongSelf;
        NSMutableDictionary *param = [NSMutableDictionary dictionary];
        [param setValue:self.detailModel.article.groupModel.groupID forKey:@"id"];
        [param setValue:@(currentIndex) forKey:@"status"];
        [param setValue:@"carousel_image_switch" forKey:@"type"];
        
        [self.detailWebView.webView ttr_fireEvent:@"page_state_change" data:param];
    };
    if (frameValue) {
        CGRect frame;
        frame = [self.detailWebView.webView.scrollView convertRect:[frameValue CGRectValue] toView:nil];
        NSMutableArray * frames = [NSMutableArray arrayWithCapacity:index + 1];
        NSMutableArray * animateFrames = [NSMutableArray arrayWithCapacity:index + 1];
        for (NSUInteger i = 0; i < index; ++i) {
            [frames addObject:[NSNull null]];
            [animateFrames addObject:[NSNull null]];
        }
        [frames addObject:[NSValue valueWithCGRect:frame]];
        [animateFrames addObject:frameValue];
        showImageViewController.placeholderSourceViewFrames = frames;
        UINavigationController *nav = [TTUIResponderHelper topNavigationControllerFor:self];
        CGFloat topBarHeight = [UIApplication sharedApplication].statusBarFrame.size.height + nav.navigationBar.height;
        CGFloat bottomBarHeight = 0;
        TTDetailArchType detailType = [self.detailViewModel tt_articleDetailType];
        if (detailType == TTDetailArchTypeNormal) {
            bottomBarHeight = ExploreDetailGetToolbarHeight();
        }
        showImageViewController.dismissMaskInsets = UIEdgeInsetsMake(topBarHeight, 0, bottomBarHeight, 0); //图片点击移入移出动画的遮罩Insets
    }
    [showImageViewController presentPhotoScrollView];
    if (self.delegate && [self.delegate respondsToSelector:@selector(tt_articleDetailViewWillShowLargeImage)]) {
        [self.delegate tt_articleDetailViewWillShowLargeImage];
    }
}

- (void)processRequestShowTipMsg:(NSString *)tipMsg icon:(UIImage *)image
{
    if (!isEmptyString(tipMsg)) {
        [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:tipMsg indicatorImage:image autoDismiss:YES dismissHandler:nil];
    }
}

- (void)processRequestShowUserProfileForUserID:(NSString *)userID
{
   
}

- (void)processRequestOpenAppStoreByActionURL:(NSString *)actionURL itunesID:(NSString *)appleID
{
    [[SSAppStore shareInstance] openAppStoreByActionURL:actionURL itunesID:appleID presentController:[TTUIResponderHelper topViewControllerFor: self]];
}

- (void)processRequestShowSearchViewWithQuery:(NSString *)query fromType:(ListDataSearchFromType)type index:(NSUInteger)index
{
    if (isEmptyString(query)) {
        return;
    }
    ExploreSearchViewController * searchController = [[ExploreSearchViewController alloc] initWithNavigationBar:YES showBackButton:YES queryStr:query fromType:type];
    searchController.groupID = @(self.detailModel.article.uniqueID);
    
    UINavigationController * rootController = [TTUIResponderHelper topNavigationControllerFor: self];
    [rootController pushViewController:searchController animated:YES];
    
    if (type == ListDataSearchFromTypeContent) {
        [NewsDetailLogicManager trackEventTag:@"detail" label:[NSString stringWithFormat:@"click_keyword_%lu", (unsigned long)index] value:@(self.detailModel.article.uniqueID) extValue:nil  groupModel:self.detailModel.article.groupModel];
    }
    else if (type == ListDataSearchFromTypeTag) {
        [NewsDetailLogicManager trackEventTag:@"detail" label:[NSString stringWithFormat:@"click_tag_%lu", (unsigned long)index] value:@(self.detailModel.article.uniqueID) extValue:nil  groupModel:self.detailModel.article.groupModel];
    }
}

#pragma mark - NSURLConnectionDelegate

- (nullable NSURLRequest *)connection:(NSURLConnection *)connection
                      willSendRequest:(NSURLRequest *)request
                     redirectResponse:(nullable NSURLResponse *)response
{
    //The delegate may return request unmodified to allow the redirect, return a new request, or return nil to reject the redirect and continue processing the connection
    NSURLRequest *newRequest = request;
    if (response) {
        //发生重定向则reject，此时request为重定向后的新请求。当前request下放到didReceiveResponse回调中截获处理
        LOGD(@"webView redirect to url %@", request.URL.absoluteString);
        _webViewRedirectToURL = request.URL.absoluteString;
        newRequest = nil;
    }
    
    //response为nil表示没有发生重定向，返回原request
    return newRequest;
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    LOGD(@"[TTArticleDetail]webTypeContent connection:didReceiveResponse");
    if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        NSInteger status = [httpResponse statusCode];
        
        BOOL shouldLoadNativeTypeContent = NO;
        if (status == kRedirectStatusCode) {
            //302页面记录跳转前的url
            LOGD(@"[TTArticleDetail]webTypeContent 302 redirectStatusCode found");
            _webViewURLBeforeRedirection = response.URL.absoluteString;
        }
        else if (status >= kErrorStatusCode) {
            //404页面尝试加载转码页
            LOGD(@"[TTArticleDetail]webTypeContent 404 fileNotFoundStatusCode found, will load nativeType content");
            shouldLoadNativeTypeContent = YES;
        }
        else {
            LOGD(@"[TTArticleDetail]webTypeContent http status code: %ld", status);
        }
        
        [[TTMonitor shareManager] trackService:@"web_http_status" status:status extra:({
            NSMutableDictionary *param = [[self.tracker detailTrackerCommonParams] mutableCopy];
            [param setValue:response.URL.absoluteString forKey:@"cur_url"];
            [param copy];
        })];
        _webTypeContentStatusCodeChecked = YES;
        [connection cancel];
        
        BOOL canLoadNativeType = [self p_canLoadNativeContentForWebTypeArticle];
        if (shouldLoadNativeTypeContent && canLoadNativeType) {
            [self p_didStartLoadNativeContentForWebTimeoff];
        }
        else {
            //1.每次检测完加载当前检测URL，有可能出现无效URL导致最终落地页面和加载原始URL的情况不一致
            //            [_detailWebView.webView loadRequest:[_detailViewModel tt_requstForWebContentArticleForURLString:response.URL.absoluteString]];
            
            //2.每次检测完重新加载原始URL，但会导致流程冗余变长
            //暂时使用方案2，牺牲一些效率保证准确率。对大多数简单302的页面无明显效率影响
            
            [_detailWebView.webView loadRequest:[_detailViewModel tt_requstForWebContentArticle] appendBizParams:_detailModel.adID.longLongValue == 0];
        }
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    LOGD(@"[TTArticleDetail]webTypeContent connection:didReceiveData");
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    LOGD(@"[TTArticleDetail]webTypeContentconnection:didFailWithError - %@", error);
    if (error) {
        //connection请求错误，通常webView请求也会有问题，优先加载转码页，如果开关禁止，则加载web
        _webTypeContentStatusCodeChecked = YES;
        [connection cancel];
        
        if ([self p_canLoadNativeContentForWebTypeArticle]) {
            [self p_didStartLoadNativeContentForWebTimeoff];
        }
        else {
            [_detailWebView.webView loadRequest:[_detailViewModel tt_requstForWebContentArticle]];
        }
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    LOGD(@"[TTArticleDetail]webTypeContent connectionDidFinishLoading");
}

#pragma mark - sharedWebView
- (BOOL)p_needUseSharedWebView {
    if (![SSCommonLogic detailSharedWebViewEnabled]) {
        return NO;
    }
    
    if (![SSCommonLogic newNatantStyleEnabled]) {
        return NO;
    }
    
    //广告 return NO
    if (self.detailModel.adID.longLongValue) {
        return NO;
    }
    //导流页 return NO
    if ([self.detailViewModel tt_articleDetailLoadedContentType] == ArticleTypeWebContent) {
        return NO;
    }
    //sharedWebView 未使用 并且模板已经domReady return YES
    if (!self.class.sharedWebView.superview && self.class.sharedWebView.isDomReady) {
        return YES;
    }
    
    return NO;
}

- (void)p_clearSharedWebViewContextIfNeed {
    if (_detailWebView.webView != self.class.sharedWebView) {
        return;
    }
    [_detailWebView removeFromSuperview];
    [_detailWebView removeDivFromWebViewIfNeeded];
    self.class.sharedWebView.delegate = nil;
    [self.class.sharedWebView removeAllDelegates];
    [self.class.sharedWebView evaluateJavaScriptFromString:@"onQuit();" completionBlock:nil];
}

- (void)p_refreshContentInSharedWebView {
    
    NSString *content = [self.detailViewModel tt_sharedHTMLContentWithArticle:self.detailModel.article];
    if (isEmptyString(content)) {
        self.ttViewType = TTFullScreenErrorViewTypeEmpty;
        [self tt_endUpdataData:NO error:nil];
        return;
    }
    
    _isWebViewLoading = YES;
    
    [self.class.sharedWebView evaluateJavaScriptFromString:[NSString stringWithFormat:@"setContent(\"%@\");setExtra(%@);", content, [self.detailViewModel tt_sharedWebViewExtraJSONString]] completionBlock:nil];
}

- (void)p_didFinishedLoadInSharedWebView {
    if (_detailWebView.webView != self.class.sharedWebView) {
        return;
    }
    
    if ([_detailWebView respondsToSelector:@selector(webViewDidFinishLoad:)]) {
        [_detailWebView webViewDidFinishLoad:self.class.sharedWebView];
    } else {
        NSAssert(NO, @"TTDetailWebviewContainer must implement SEL:webViewDidFinishLoad:");
    }
}

+ (SSJSBridgeWebView *)sharedWebView {
    static SSJSBridgeWebView *kWebView;
    static dispatch_once_t onceToken;
    
    if (![SSCommonLogic detailSharedWebViewEnabled]) {
        return nil;
    }
    
    dispatch_once(&onceToken, ^{
        [SSWebViewUtil registerUserAgent:YES];
        kWebView = [[SSJSBridgeWebView alloc] initWithFrame:CGRectZero disableWKWebView:YES];
        kWebView.disableThemedMask = YES;
        [kWebView loadHTMLString:[TTArticleDetailViewModel tt_sharedHTMLTemplate] baseURL:[TTArticleDetailViewModel tt_sharedHTMLFilePath]];
    });
    return kWebView;
}

#pragma mark - GestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

@end

