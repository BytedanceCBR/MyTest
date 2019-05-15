//
//  NewsDetailView.m
//  Article
//
//  Created by Hu Dianwei on 6/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

/*
    详情页 impression记录的实现： 首先，客户端记录用户滚动过最大的Y值， 
    退出的时候，通过reportElementOffset获取到的文章gid和y值的关系， 
    把所有top小于最大Y的item，都记录impression
 */

#import <QuartzCore/QuartzCore.h>
#import "NewsDetailView.h"
#import "SocialActionButton.h"
#import "UIColorAdditions.h"
#import "DetailActionRequestManager.h"
#import "AccountManager.h"
#import "SSOperation.h"
#import "ShareOne.h"
#import "AuthorityViewController.h"
#import "ShareOneHelper.h"
#import "NetworkUtilities.h"
#import "SSPhotoScrollViewController.h"
#import "NewsUserSettingManager.h"
#import "SSWebViewController.h"
#import "WebResourceManager.h"
#import "SimpleIndicator.h"
#import "SSActivityIndicatorView.h"
#import "ExploreShareViewController.h"
#import "SSOperation.h"
#import "ArticleURLSetting.h"
#import "UIDevice-Hardware.h"
#import "ExploreItemActionManager.h"
#import "SSCommon+JSON.h"
#import "UIImage+ReplaceImageNamed.h"
#import "SSVideoPlayerViewController.h"
#import "SSCommon.h"
#import "SSResourceManager.h"
#import "UIImage+ReplaceImageNamed.h"
#import "SSSimpleCache.h"
#import "SSShareManager.h"
#import "ArticleTitleImageView.h"
#import "ArticleUserProfileViewController.h"
#import "CommonURLSetting.h"
#import "UIApplication+Addition.h"
#import "UIScreen+Addition.h"
#import "SSCommonLogic.h"
#import "SSActivityViewController.h"
#import "SSActivityView.h"
#import "SSActivityShareManager.h"
#import "SSVideoManager.h"
#import "ArticleShareManager.h"
#import "SSCommentMenuActionManager.h"
#import "UIScreen+Addition.h"
#import "ArticleButton.h"
#import "NSStringAdditions.h"
#import "SSAppPageManager.h"
#import "NewsDetailImageDownloadManager.h"
#import "ArticlePadUserProfileView.h"
#import "PadFontSelectContainerView.h"
#import "UIScreen+Addition.h"
#import "SSWebViewAddressBar.h"
#import "SSAppStore.h"
#import "SSURLTracker.h"
#import "ArticleActionAlertView.h"
#import "ArticleReportViewController.h"
#import "ArticlePadReportView.h"
#import "NewsDetailSupernatantView.h"
#import "SSActivityPopoverController.h"
#import "ArticlePGCProfileViewController.h"
#import "NewsFetchArticleDetailManager.h"
#import "SSReportManager.h"
#import "SSImpressionManager.h"
#import "NewsDetailFunctionView.h"
#import "NewsDetailNoCommentShareView.h"
#import "ArticleJSManager.h"
#import "SSReportManager.h"
#import "ArticleMomentProfileViewController.h"
#import "NewsDetailLogicManager.h"
#import "SSCommon+JSON.h"
#import "SSWebViewBackButtonView.h"
#import "NewsDetailToolBarView.h"
#import "ArticleListNotifyBarView.h"
#import "ArticleClientEscapeManager.h"
#import "UIAlertView+BlocksMain.h"
#import "ExploreItemActionManager.h"
#import "ExploreMixListDefine.h"
#import "SSWebImageManager.h"
#import "ExploreLogicSetting.h"
#import "ListDataHeader.h"
#import "ArticleJSBridgeWebView.h"
#import "ArticleLoginViewController.h"
#import "ExploreEntryManager.h"
#import "SSTracker.h"
#import "SSWebViewUtil.h"
#import "ArticleBridgeJSManager.h"
// 使用浮层来“写评论”（由branch “news_4.0”移植代码; Changed by luohuaqing）
#import "ExploreWriteCommentView.h"

#import "HDAccountPopOverViewController.h"
#import "PGCWAPViewController.h"
#import "TTThemedAlertController.h"
#import "TTNavigationController.h"

#define kRandomParameter    @"tt_ios_random"

#define kMediaAccountProfileHost            @"media_account"        //PGC profile
#define kShowOriginImageHost                @"origin_image"         //单张显示大图
#define kShowFullImageHost                  @"full_image"           //进入图片浏览页面
#define kVideoHost                          @"video"                //视频
#define kUserProfile                        @"user_profile"         //用户主页
#define kWebViewUserClickLoadOriginImg      @"toggle_image"         //用户点击显示原图
#define kClickSource                        @"click_source"         //来源
#define kBytedanceScheme                    @"bytedance"
#define kSNSSDKScheme                       @"snssdk"
#define kDownloadAppHost                    @"download_app"
#define kCustomOpenHost                     @"custom_open"
#define kTrackURLHost                       @"track_url"
#define kCustomEventHost                    @"custom_event"
#define kKeyWordsHost                       @"keywords"
#define kArticleImpression                  @"article_impression"
#define kClientEscapeTranscodeError         @"transcode_error"      //客户端转码失败
#define kClientEscapeOpenInWebViewHost      @"open_origin_url"      //客户端转码
#define kMediaLike                          @"media_like"
#define kMediaUnlike                        @"media_unlike"

//兼容较早相关阅读代码
#define kLocalSDKDetailSCheme               @"localsdk://detail"

#define NotifyBarViewHeight 35.f

#define validOpenDistanceForHalfOpenLevel 100

#define kChangeNetworkTrafficSettingTag     1336
#define kEnableNatantSwitchAlertViewWhenClickCommentButtonTag       1
#define kEnableNatantSwitchAlertViewWhenWillSendCommentTag          2
#define kEnablePadNatantSwitchAlertViewWhenWillSendCommentTag       3
#define kEnableNatantSwitchAlertViewWhenEnterShowHotCommentTag      4

#define kNewsDetailViewRequesterKey         @"kNewsDetailViewRequesterKey"

#define kJsMetaImageOriginKey       @"origin"
#define kJsMetaImageThumbKey        @"thumb"
#define kJsMetaImageNoneKey         @"none"


static NSString *const kWebViewLoadOriginImg    = @"loadOriginImage";      //显示原图
static NSString *const kWebViewLoadThumbImage   = @"loadThumbImage";       //显示小图
static NSString *const kWebViewLoadOfflineImage = @"loadOfflineImage";     //显示已下载图

static NSString *const kWebViewShowThumbImage   = @"thumb_image";
static NSString *const kWebViewShowOfflineImage   = @"offline_image";
static NSString *const kWebViewCancelimageDownload = @"cancel_image";
typedef enum JSMetaInsertImageType {
    JSMetaInsertImageTypeNone,      //kJsMetaImageNoneKey
    JSMetaInsertImageTypeOrigin,    //kJsMetaImageOriginKey
    JSMetaInsertImageTypeThumb      //kJsMetaImageThumbKey
}JSMetaInsertImageType;

#define sNoNetworkConnectTip SSLocalizedString(@"无网络连接", nil)

///**
//    iPad 右上角均无按钮
//    iPad 不支持NewsDetailTypeNoToolBar，如果传回，按照NewsDetailTypeNoComment处理
// */
//typedef NS_ENUM(NSUInteger, NewsDetailType) {
//    NewsDetailTypeNotAssign,            //还未指定
//    NewsDetailTypeNormal,               //普通模式,有评论， 有浮层， 右上角是AA按钮
//    NewsDetailTypeNoComment,            //无评论模式,无浮层，无评论、发评论按钮;右上角是AA按钮
//    NewsDetailTypeNoToolBar,            //隐藏模式, 无浮层，无tool bar 右上角有..按钮
//    NewsDetailTypeSimple,               //精简模式,无浮层，无tool bar 右上角有...按钮
//};

/**
    浮层level只对NewsDetailTypeNormal有效
 */
typedef enum NewsDetailNatantLevel{  //浮层级别方案
    NewsDetailNatantLevelNotAssign,  //还未指定
    NewsDetailNatantLevelOpen,       //随手滑动展示, 可点
    NewsDetailNatantLevelHalfClose,  //可点，不可滑
    NewsDetailNatantLevelHalfOpen,   //降级可滑，可点
    NewsDetailNatantLevelClose,      //完全关闭
}NewsDetailNatantLevel;

typedef enum NewsDetailOpenNatantShowType{
    NewsDetailOpenNatantShowTypeNatantTop = 0, //默认，浮层顶部
    NewsDetailOpenNatantShowTypeHotComment,
    NewsDetailOpenNatantShowTypeRecentComment,
    NewsDetailOpenNatantShowTypeADViewTopLocation,    //定位到广告上方, 如果广告存在
    NewsDetailOpenNatantShowTypeDigBuryButtonTop,    //定位到顶踩按钮上方
}NewsDetailOpenNatantShowType;


////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - NewsDetailWebView

@protocol NewsDetailWebViewDelegate;

@interface NewsDetailWebView : ArticleJSBridgeWebView<UIScrollViewDelegate>
{
    //该参数记录用户上次触发delegate的detailWebViewDragToRefreshDone:的时间， 需要该参数是因为ios对scrollViewDidEndDragging会回调两次(ios bug)， 限制1秒钟之内的只会有一次触发
    NSTimeInterval _lastDragToRefreshTime;
}
@property(nonatomic, assign)id<NewsDetailWebViewDelegate> ssDelegate;
@property(nonatomic, retain)UIView * coverView;//给articleType为1（web类型）使用
@property(nonatomic, assign)CGFloat userScrolledMaxY;//用户滚动过的最大的Y值
@property(nonatomic, assign)BOOL couldSetContentInset;//是否允许设置content inset, default is NO

- (void)showCoverIfNeed;
- (void)hideCover;

- (void)webViewScrollToOffset:(CGFloat)offset animatied:(BOOL)animated NS_AVAILABLE_IOS(5_0);
@end


@protocol NewsDetailWebViewDelegate <NSObject>

@optional

- (void)detailWebView:(NewsDetailWebView *)webView scrollViewDidScroll:(UIScrollView *)scrollView;
- (void)detailWebView:(NewsDetailWebView *)webView scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate;
- (void)detailWebView:(NewsDetailWebView *)webView scrollViewDidEndDecelerating:(UIScrollView *)scrollView;
- (void)detailWebView:(NewsDetailWebView *)webView scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView;
- (void)detailWebView:(NewsDetailWebView *)webView scrollViewWillBeginDragging:(UIScrollView *)scrollView;
- (void)detailWebViewDragToRefreshDone:(NewsDetailWebView *)webView;
- (void)detailWebViewContentSizeChanged:(NewsDetailWebView *)webView;
- (void)detailWebView:(NewsDetailWebView *)webView handlePanGestureRecognizer:(UIPanGestureRecognizer *)recognizer;

@end

@implementation NewsDetailWebView

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.scrollView.panGestureRecognizer removeTarget:self action:@selector(handlePanGestureRecognizer:)];
    self.ssDelegate = nil;
    [self.scrollView removeObserver:self forKeyPath:@"contentSize"];
    self.coverView = nil;
    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _couldSetContentInset = NO;
        _userScrolledMaxY = self.frame.size.height;
        _lastDragToRefreshTime = 0;
        self.coverView = [[[UIView alloc] initWithFrame:self.bounds] autorelease];
        _coverView.userInteractionEnabled = NO;
        _coverView.backgroundColor = [UIColor blackColor];
        _coverView.alpha = 0.6f;
        setAutoresizingMaskFlexibleWidthAndHeight(_coverView);
        self.scrollView.bounces = NO;
        [self.scrollView addObserver:self forKeyPath:@"contentSize" options:NSKeyValueObservingOptionNew context:nil];
        
        [self.scrollView.panGestureRecognizer addTarget:self action:@selector(handlePanGestureRecognizer:)];
    }
    return self;
}

- (void)handlePanGestureRecognizer:(UIPanGestureRecognizer *)recognizer
{
    if (_ssDelegate && [_ssDelegate respondsToSelector:@selector(detailWebView:handlePanGestureRecognizer:)]) {
        [_ssDelegate detailWebView:self handlePanGestureRecognizer:recognizer];
    }
}

- (void)reloadNatant
{
    if (_couldSetContentInset) {
        self.scrollView.contentInset = UIEdgeInsetsMake(0, 0, self.frame.size.height, 0);
    }
    
    [self reportDetailContentSizeChanged];
}

- (void)reportDetailContentSizeChanged
{
    if (_ssDelegate && [_ssDelegate respondsToSelector:@selector(detailWebViewContentSizeChanged:)]) {
        [_ssDelegate detailWebViewContentSizeChanged:self];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"contentSize"]) {
        [self reloadNatant];
    }
}

- (void)webViewScrollToOffset:(CGFloat)offset animatied:(BOOL)animated
{
    if (offset == NAN || offset > MAXFLOAT) {
        return;
    }
    
    if (offset == self.scrollView.contentOffset.y) {
        return;
    }
    
    [self.scrollView setContentOffset:CGPointMake(0, offset) animated:animated];
}

- (void)showCoverIfNeed
{
    [self hideCover];
    
    if ([[SSResourceManager shareBundle] currentMode] == SSThemeModeNight) {
        [self addSubview:_coverView];
    }
}

- (void)hideCover
{
    if (_coverView.superview != nil) {
        [_coverView removeFromSuperview];
    }
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender
{
    /*
     *  IOS 5 的WebView 系统菜单和自定义菜单同时使用的情况，添加一个自定义菜单按钮，显示正常， 添加两个以上多了一个more按钮
     *  IOS5中只有拷贝，分享和搜索
     *  IOS6中系统的＋搜索和分享
     */
    if ([SSCommon OSVersionNumber] < SSOSVersion6) {
        return NO;
    }
    return [super canPerformAction:action withSender:sender];;
}

#pragma mark -- UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if ([UIWebView instancesRespondToSelector:@selector(scrollViewDidScroll:)]) {
        [super scrollViewDidScroll:scrollView];
    }

    
    if (_ssDelegate && [_ssDelegate respondsToSelector:@selector(detailWebView:scrollViewDidScroll:)]) {
        [_ssDelegate detailWebView:self scrollViewDidScroll:scrollView];
    }
    _userScrolledMaxY = MAX((scrollView.contentOffset.y + scrollView.frame.size.height), _userScrolledMaxY);
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if ([UIWebView instancesRespondToSelector:@selector(scrollViewDidEndDragging:willDecelerate:)]) {
        [super scrollViewDidEndDragging:scrollView willDecelerate:decelerate];
    }
    
    if (_ssDelegate && [_ssDelegate respondsToSelector:@selector(detailWebView:scrollViewDidEndDragging:willDecelerate:)]) {
        [_ssDelegate detailWebView:self scrollViewDidEndDragging:scrollView willDecelerate:decelerate];
    }

}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    if (_ssDelegate && [_ssDelegate respondsToSelector:@selector(detailWebView:scrollViewDidEndScrollingAnimation:)]) {
        [_ssDelegate detailWebView:self scrollViewDidEndScrollingAnimation:scrollView];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{

    if ([UIWebView instancesRespondToSelector:@selector(scrollViewDidEndDecelerating:)]) {
        [super scrollViewDidEndDecelerating:scrollView];
    }
    
    if (_ssDelegate && [_ssDelegate respondsToSelector:@selector(detailWebView:scrollViewDidEndDecelerating:)]) {
        [_ssDelegate detailWebView:self scrollViewDidEndDecelerating:scrollView];
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if ([UIWebView instancesRespondToSelector:@selector(scrollViewWillBeginDragging:)]) {
        [super scrollViewWillBeginDragging:scrollView];
    }

    if (_ssDelegate && [_ssDelegate respondsToSelector:@selector(detailWebView:scrollViewWillBeginDragging:)]) {
        [_ssDelegate detailWebView:self scrollViewWillBeginDragging:scrollView];
    }
}

@end

////////////////////////////////////////////////////////////////////////////////////////////////////
/**
    统计发送
 */
@interface NewsDetailViewEventTracker : NSObject
{
    BOOL _hasSendReadContentEvent;
    BOOL _hasSendFinishContentEvent;
    BOOL _hasSendEnterCommentEvent;
    BOOL _hasSendFinishCommentEvent;
}
@property(nonatomic, assign)CGFloat detailViewBeginDraginContentOffsetY;//用于umeng统计,发送 pull_open_drawer / pull_close_drawer
@property(nonatomic, assign)NSTimeInterval startReadTime;               //用于统计停留时间
@property(nonatomic, retain)NSTimer * stayTimer;                        //用于统计停留时间
@property(nonatomic, retain)NSNumber * adID;//广告ID，可能为nil
/**
 *  相关阅读的来源id
 */
@property(nonatomic, retain)NSNumber * relateReadFromID;

@property(nonatomic, retain)NSString * umengEventLabel;

@property(nonatomic, assign)CGFloat detailMaxOffsetY;//用于统计详情页最大滚动的距离

@property(nonatomic, retain)NSDictionary *statParams; //自定义统计key-value

@end

@implementation NewsDetailViewEventTracker

- (void)dealloc
{
    self.adID = nil;
    [self invalidate];
    self.relateReadFromID = nil;
    self.umengEventLabel = nil;
    self.statParams = nil;
    [super dealloc];
}

- (id)init
{
    self = [super init];
    if (self) {
        _detailMaxOffsetY = 0;
        _hasSendReadContentEvent = NO;
        _hasSendFinishContentEvent = NO;
        _hasSendEnterCommentEvent = NO;
        _hasSendFinishCommentEvent = NO;
    }
    return self;
}

- (void)updateContentScrollY:(CGFloat)scrollY
{
    _detailMaxOffsetY = MAX(scrollY, _detailMaxOffsetY);
}

/**
 *  发送阅读进度
 *
 *  @param contentSizeHeight 文章的长度
 */
- (void)sendContentReadPercentForWebView:(UIWebView *)webview article:(Article *)article
{
    NSInteger pageCount = 0; //页数
    int percent = 0;        //百分比
    if ([article isContentFetched]) {
        CGFloat contentSizeHeight = webview.scrollView.contentSize.height - webview.scrollView.contentInset.bottom;
        contentSizeHeight += SSHeight(webview);
        contentSizeHeight = MAX(0, contentSizeHeight);
        
        if (SSHeight(webview) > 0) {
            pageCount = (NSInteger)ceilf(contentSizeHeight / SSHeight(webview));
        }
        CGFloat detailShowHeight = _detailMaxOffsetY + SSHeight(webview);
        
        if (detailShowHeight >= contentSizeHeight) {
            percent = 100;
        }
        else {
            CGFloat pct = 0;
            if (contentSizeHeight > 0) {
                pct = detailShowHeight / contentSizeHeight;
            }
            percent = (int)(pct * 100);
            percent = MAX(percent, 0);
        }
    }
    
    NSMutableDictionary * dict = [NSMutableDictionary dictionaryWithCapacity:10];
    [dict setValue:@"article" forKey:@"category"];
    [dict setValue:@"read_pct" forKey:@"tag"];
    [dict setValue:_umengEventLabel forKey:@"label"];
    [dict setValue:article.uniqueID forKey:@"value"];
    [dict setValue:_adID forKey:@"ext_value"];
    [dict setValue:@(percent) forKey:@"pct"];
    [dict setValue:@(pageCount) forKey:@"page_count"];
    [SSTracker eventData:dict];
}

/**
    发送 pull_open_drawer / pull_close_drawer
 */

- (void)sendChangeDrawerEventForWebView:(UIWebView *)webView beginShowOriginY:(CGFloat)beginShowOriginY
{
    if (webView.scrollView.contentOffset.y >= beginShowOriginY) {
        if (_detailViewBeginDraginContentOffsetY < beginShowOriginY) {
            ssTrackEvent(@"detail", @"pull_open_drawer");
        }
    }
    else {
        if (_detailViewBeginDraginContentOffsetY >= beginShowOriginY) {
            ssTrackEvent(@"detail", @"pull_close_drawer");
        }
    }
}

/**
    发送 go_detail
 */
- (void)sendGoDetailForArticle:(Article *)article
{
    if (!isEmptyString(_umengEventLabel)) {
        [NewsDetailLogicManager trackEventTag:@"go_detail" label:_umengEventLabel value:article.uniqueID extValue:_adID fromID:_relateReadFromID params:_statParams groupModel:article.groupModel];
    }
    
    if ([article.articleType intValue] == ArticleTypeWebContent && ([article.groupFlags intValue] & kArticleGroupFlagsClientEscape) > 0) {
        if ([ArticleClientEscapeManager isAutoClientEscapse]) {
            ssTrackEvent(@"detail", @"transcode_true");
        }
        else {
            ssTrackEvent(@"detail", @"transcode_false");
        }
    }
}
/**
    尝试发送finish_comment
 */
- (void)sendFinishCommentIfNeedForArticel:(Article *)article
{
    if (_hasSendFinishCommentEvent) {
        return;
    }
    _hasSendFinishCommentEvent = YES;
    
    if (article.managedObjectContext &&!isEmptyString(_umengEventLabel)) {
        [NewsDetailLogicManager trackEventTag:@"finish_comment" label:_umengEventLabel value:article.uniqueID extValue:_adID  groupModel:article.groupModel];
    }
}

/**
    尝试发送 read_content
 */
- (void)sendReadContentIfNeedForWebView:(UIWebView *)webView article:(Article *)article
{
    if (_hasSendReadContentEvent) {
        return;
    }
    if (webView.scrollView.contentOffset.y > webView.frame.size.height) {
        _hasSendReadContentEvent = YES;
        if (article.managedObjectContext && !isEmptyString(_umengEventLabel)) {
            [NewsDetailLogicManager trackEventTag:@"read_content" label:_umengEventLabel value:article.uniqueID extValue:_adID groupModel:article.groupModel];
        }
    }
}
/**
    尝试发送 finish_content
 */
- (void)sendFinishContentIfNeedByNatantOriginY:(CGFloat)natantOriginY webView:(UIWebView *)webView article:(Article *)article
{
    if (_hasSendFinishContentEvent) {
        return;
    }
    if (webView.scrollView.contentOffset.y >= natantOriginY) {
        _hasSendFinishContentEvent = YES;
        if (article.managedObjectContext &&!isEmptyString(_umengEventLabel)) {
            [NewsDetailLogicManager trackEventTag:@"finish_content" label:_umengEventLabel value:article.uniqueID extValue:_adID groupModel:article.groupModel];
        }
    }
}

/**
    尝试发送enter_comment
 */
- (void)sendEnterCommentIfNeedByNatantOriginY:(CGFloat)natantOriginY natantHeight:(float)natantHeigth webView:(UIWebView *)webView article:(Article *)article forceSendIfNotSend:(BOOL)force
{
    if (_hasSendEnterCommentEvent) {
        return;
    }
    
    if (force || (webView.scrollView.contentOffset.y >= natantOriginY + (natantHeigth / 2))) {
        _hasSendEnterCommentEvent = YES;
        if (article.managedObjectContext &&!isEmptyString(_umengEventLabel)) {
            [NewsDetailLogicManager trackEventTag:@"enter_comment" label:_umengEventLabel value:article.uniqueID extValue:_adID groupModel:article.groupModel];
        }
    }
}

#pragma mark -- page stay


- (void)invalidate
{
    [_stayTimer invalidate];
    self.stayTimer = nil;
}

- (void)recordStayTimerForArticle:(Article *)article
{
    if([article isContentFetched])
    {
        [_stayTimer invalidate];
        self.stayTimer = [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(setShouldSendStayTrack) userInfo:nil repeats:NO];
    }
}

- (void)setShouldSendStayTrack
{
    self.startReadTime = [[NSDate date] timeIntervalSince1970];
}
/**
    尝试发送停留时间
 */
- (void)trySendStayTrackForArticle:(Article *)article
{
    if(_startReadTime > 0)
    {
        NSTimeInterval duration = [[NSDate date] timeIntervalSince1970] - _startReadTime + 3; // 3 is threahold time
        
        if (!isEmptyString(_umengEventLabel)) {
            [NewsDetailLogicManager trackEventTag:@"stay_page" label:_umengEventLabel value:article.uniqueID extValue:[NSNumber numberWithDouble:duration] adID:_adID groupModel:article.groupModel];
            if ([_adID longLongValue] != 0) {
                [NewsDetailLogicManager trackEventTag:@"stay_page2" label:_umengEventLabel value:article.uniqueID extValue:_adID groupModel:article.groupModel];
            }
        }
        
        _startReadTime = 0;
    }
}


@end

////////////////////////////////////////////////////////////////////////////////////////////////////

@interface ArticleClientEscapeButtonTipView : SSViewBase

@property(nonatomic, retain)UILabel * tipLabel;
@property(nonatomic, retain)UIImageView * tipImgView;
@end

@implementation ArticleClientEscapeButtonTipView

- (void)dealloc
{
    self.tipImgView = nil;
    self.tipLabel = nil;
    [super dealloc];
}

- (id)init
{
    self = [super initWithFrame:CGRectMake(0, 0, 204, 51)];
    if (self) {
        self.tipImgView = [[[UIImageView alloc] initWithImage:[UIImage resourceImageNamed:@"mask_subscribe.png"]] autorelease];
        [self addSubview:_tipImgView];
    
        self.tipLabel = [[[UILabel alloc] initWithFrame:CGRectZero] autorelease];
        _tipLabel.backgroundColor = [UIColor clearColor];
        _tipLabel.textAlignment = NSTextAlignmentCenter;
        _tipLabel.frame = CGRectMake(0, 7, self.frame.size.width, 44);
        _tipLabel.text = SSLocalizedString(@"使用阅读模式浏览体验更佳", nil);
        _tipLabel.font = [UIFont systemFontOfSize:15];
        [self addSubview:_tipLabel];
        
        [self reloadThemeUI];
    }
    return self;
}

- (void)themeChanged:(NSNotification *)notification
{
    self.tipImgView.image = [UIImage resourceImageNamed:@"mask_subscribe.png"];
    _tipLabel.textColor = [UIColor colorWithDayColorName:@"fafafa" nightColorName:@"b1b1b1"];
}

@end

////////////////////////////////////////////////////////////////////////////////////////////////////

#define kMoreButtonWidth 38
#define kMoreButtonHeight 44
#define kMoreButtonRightPadding 4

#define kTitleAddressBarNoEditStatusWidth 245

@interface NewsDetailTitleBarView : SSViewBase<SSWebViewAddressBarDelegate>
{
    NewsDetailType _titleBarSuperViewDetailType;
    BOOL _isClientEscapeButtonSelected;
}
@property(nonatomic, retain)SSWebViewBackButtonView * backButtonView;
@property(nonatomic, retain)ArticleTitleImageView * titleImageView;
@property(nonatomic, retain)UIButton * moreButton;
@property(nonatomic, retain)SSWebViewAddressBar * addressBar;
@property(nonatomic, retain)UIButton * clientEscapeButton;
@property(nonatomic, retain)UIView * rightViewContainer;
@property(nonatomic, retain)ArticleClientEscapeButtonTipView * escapeButtonTipView;
- (void)refreshForDetailType:(NewsDetailType)type;
@end

@implementation NewsDetailTitleBarView

- (void)dealloc
{
//    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    self.escapeButtonTipView = nil;
    self.rightViewContainer = nil;
    self.clientEscapeButton = nil;
    self.addressBar = nil;
    self.moreButton = nil;
    self.backButtonView = nil;
    self.titleImageView = nil;
    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _titleBarSuperViewDetailType = NewsDetailTypeNotAssign;
        self.titleImageView = [[[ArticleTitleImageView alloc] initWithFrame:frame] autorelease];
        _titleImageView.titleUItype = ArticleTitleImageViewUITypeDetailView;
        [_titleImageView setBottomLineColorName:@"NewsDetailViewTitleBarBottomLineColor"];
        [self addSubview:_titleImageView];

        self.backButtonView = [[[SSWebViewBackButtonView alloc] init] autorelease];
        _backButtonView.frame = CGRectMake(0, 0, 75, 44);
        _titleImageView.leftView = _backButtonView;
        
        self.rightViewContainer = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, kMoreButtonWidth + kMoreButtonRightPadding, kMoreButtonHeight)] autorelease];
        _rightViewContainer.backgroundColor = [UIColor clearColor];
        
        _titleImageView.rightView = _rightViewContainer;
        
        CGFloat addressBarWidth = kTitleAddressBarNoEditStatusWidth;
        CGFloat addressBarHeight = 27;
        if ([SSCommon isPadDevice]) {
            addressBarWidth = 440;
            addressBarHeight = 33;
        }
        
        self.addressBar = [[[SSWebViewAddressBar alloc] initWithFrame:CGRectMake(0, 0, addressBarWidth, addressBarHeight)] autorelease];
        
        [self.addressBar.addressField addTarget:self action:@selector(textDidBeginEdit:) forControlEvents:UIControlEventEditingDidBegin];
        [self.addressBar.addressField addTarget:self action:@selector(textDidEndEdit:) forControlEvents:UIControlEventEditingDidEnd];
        _addressBar.delegate = self;
        _titleImageView.centerView = _addressBar;
        /// 由于地址栏有点大，默认情况下把 返回按钮放在上层
        [self.backButtonView.superview bringSubviewToFront:self.backButtonView];
        
        [self reloadThemeUI];
        
    }
    return self;
}

- (void)removeEscapeTipViewIfNeed
{
    [_escapeButtonTipView removeFromSuperview];
    self.escapeButtonTipView = nil;
}

- (void)setClientEscapeButtonEnabe:(BOOL)enable
{
    _clientEscapeButton.enabled = enable;
}

- (void)setClientEscapeButtonSelected:(BOOL)selected
{
    _isClientEscapeButtonSelected = selected;
    [self refreshClientEscapeButton];
}

- (void)refreshClientEscapeButton
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (_isClientEscapeButtonSelected) {
            [_clientEscapeButton setImage:[UIImage resourceImageNamed:@"read_title_details_selected.png"] forState:UIControlStateNormal];
            [_clientEscapeButton setImage:[UIImage resourceImageNamed:@"read_title_details_selected_press.png"] forState:UIControlStateHighlighted];
        }
        else {
            [_clientEscapeButton setImage:[UIImage resourceImageNamed:@"read_title_details.png"] forState:UIControlStateNormal];
            [_clientEscapeButton setImage:[UIImage resourceImageNamed:@"read_title_details_press.png"] forState:UIControlStateHighlighted];
        }
    });
}

- (void)showClientEscapeButton:(BOOL)show
{
    if ((_clientEscapeButton && _clientEscapeButton.superview && show) ||
        (!show && !_clientEscapeButton.superview)) {
        return;
    }
    
    if (show) {
        if (!_clientEscapeButton) {
            self.clientEscapeButton = [UIButton buttonWithType:UIButtonTypeCustom];
            _clientEscapeButton.frame = CGRectMake(0, 0, kMoreButtonWidth, SSHeight(_rightViewContainer));
        }
        if (!_clientEscapeButton.superview) {
            [_rightViewContainer addSubview:_clientEscapeButton];
        }
        [_rightViewContainer.superview bringSubviewToFront:_rightViewContainer];
        
        if (!_escapeButtonTipView && [[ArticleClientEscapeTipManager shareManager] needShowTip]) {
            self.escapeButtonTipView = [[[ArticleClientEscapeButtonTipView alloc] init] autorelease];
            [self.superview addSubview:_escapeButtonTipView];
            [[ArticleClientEscapeTipManager shareManager] tipShowed];
            ssTrackEvent(@"detail", @"show_transcode_tips");
        }
        
        setFrameWithOrigin(_escapeButtonTipView, SSWidth(self.superview) - SSWidth(_escapeButtonTipView) - 5, SSMaxY(self));
        [_addressBar refreshAddressFiledRightContentInset:20];
        [self refreshClientEscapeButton];
    }
    else {
        [_clientEscapeButton removeFromSuperview];
        self.clientEscapeButton = nil;
        [_addressBar refreshAddressFiledRightContentInset:0];
    }
    _escapeButtonTipView.hidden = !show;
    
    if (_moreButton && _clientEscapeButton.superview) {
        _rightViewContainer.frame = CGRectMake(0, _rightViewContainer.frame.origin.y, kMoreButtonWidth * 2 + kMoreButtonRightPadding, kMoreButtonHeight);
    }
    else {
        _rightViewContainer.frame = CGRectMake(0, _rightViewContainer.frame.origin.y, kMoreButtonWidth + kMoreButtonRightPadding, kMoreButtonHeight);
    }
    setFrameWithOrigin(_moreButton, SSWidth(_rightViewContainer) - SSWidth(_moreButton) - kMoreButtonRightPadding, 0);
    _titleImageView.rightView = nil;
    _titleImageView.rightView = _rightViewContainer;
}

- (void)showCloseButton:(BOOL)show
{
    [_backButtonView showCloseButton:show];
    if (show) {
        [self.addressBar refreshAddressFiledLeftContentInset:addressFiledLeftContentInset + 30];
    }
    else {
        [self.addressBar refreshAddressFiledLeftContentInset:addressFiledLeftContentInset];
    }
}

- (void)refreshMoreButton
{
    if (_titleBarSuperViewDetailType == NewsDetailTypeNotAssign) {
        [_moreButton removeFromSuperview];
        self.moreButton = nil;
        return;
    }
    if (!_moreButton) {
        
        BOOL needInit = NO;
        
        if ([SSCommon isPadDevice]) {
            if (_titleBarSuperViewDetailType == NewsDetailTypeSimple) {
                needInit = YES;
            }
        }
        else {
            needInit = YES;
        }
        
        if(needInit)
        {
            self.moreButton = [UIButton buttonWithType:UIButtonTypeCustom];
            _moreButton.frame = CGRectMake(0, SSWidth(_rightViewContainer) - kMoreButtonWidth - kMoreButtonRightPadding, kMoreButtonWidth, kMoreButtonHeight);
            [_rightViewContainer addSubview:_moreButton];
        }
    }
    BOOL isAAStyle = NO;
    if (![SSCommon isPadDevice]) {
        if (_titleBarSuperViewDetailType == NewsDetailTypeNormal || _titleBarSuperViewDetailType == NewsDetailTypeNoComment) {
            isAAStyle = YES;
        }
    }

    if (isAAStyle) {
        [_moreButton setImage:[UIImage resourceImageNamed:@"show_title_details.png"] forState:UIControlStateNormal];
        [_moreButton setImage:[UIImage resourceImageNamed:@"show_title_details_press.png"] forState:UIControlStateHighlighted];
    }
    else {
        [_moreButton setImage:[UIImage resourceImageNamed:@"more_title_details.png"] forState:UIControlStateNormal];
        [_moreButton setImage:[UIImage resourceImageNamed:@"more_title_details_press.png"] forState:UIControlStateHighlighted];

    }
}

- (void)themeChanged:(NSNotification *)notification
{
    [self refreshMoreButton];
    
    if ([_titleImageView.centerView isKindOfClass:[UIImageView class]]) {
        UIImageView *imageView = (UIImageView*)_titleImageView.centerView;
        [imageView setImage:[UIImage resourceImageNamed:@"title.png"]];
    }

}

#pragma mark -- public

- (void)refreshForDetailType:(NewsDetailType)type
{
    _titleBarSuperViewDetailType = type;
    [self refreshMoreButton];
    
}

- (void)refreshAddressTitle:(NSString *)addressTitle addressURL:(NSString *)urlString
{
    [_addressBar refreshTitle:addressTitle];
    [_addressBar refreshURLString:urlString];
}



#pragma mark -- address edit text target

- (void)addressBarEndEdit:(SSWebViewAddressBar*)bar
{
    [_rightViewContainer.superview bringSubviewToFront:_rightViewContainer];
}

/// 当开始编辑地址栏时，将地址栏放在最顶层，方便用户操作
- (void) textDidBeginEdit:(id) sender {
    if(![SSCommon isPadDevice])
    {
        CGRect frame = _addressBar.frame;
        frame.origin.x = 0;
        frame.size.width = self.frame.size.width;
        _addressBar.frame = frame;
    }
    
    [self.addressBar.superview bringSubviewToFront:self.addressBar];
    [_addressBar setNeedsLayout];
    _moreButton.hidden = YES;
}
/// 当结束编辑网址时，将返回按钮放在最顶层，方便用户点击
- (void) textDidEndEdit:(id) sender {
    if(![SSCommon isPadDevice])
    {
        CGRect frame = _addressBar.frame;
        frame.size.width = kTitleAddressBarNoEditStatusWidth;
        frame.origin.x = (self.frame.size.width - kTitleAddressBarNoEditStatusWidth) / 2.f;
        _addressBar.frame = frame;
    }
    
    [self.backButtonView.superview bringSubviewToFront:self.backButtonView];
    [_addressBar setNeedsLayout];
    _moreButton.hidden = NO;
}

#pragma mark -- SSWebViewAddressBarDelegate

- (void)addressBar:(SSWebViewAddressBar *)bar prepareLoadURLString:(NSString *)urlStr
{
    NSURL * url = [SSCommon URLWithURLString:urlStr];
    
    if (!url) {
        url = [SSCommon URLWithURLString:[urlStr stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    }
    if (url.scheme == nil) {
        NSString * tempURLString = [NSString stringWithFormat:@"http://%@", urlStr];
        url = [SSCommon URLWithURLString:tempURLString];
        if (!url) {
            url = [SSCommon URLWithURLString:[tempURLString stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        }
    }
    
    SSWebViewController * controller = [[SSWebViewController alloc] init];
    [controller setTitleText:SSLocalizedString(@"网页浏览", nil)];
    
    [controller showAddressBar:YES];
    [controller requestWithURL:url];
    [self.navigationController pushViewController:controller animated:YES];
    [controller release];
}


@end

////////////////////////////////////////////////////////////////////////////////////////////////////


#pragma mark - NewsDetailView

#define kNewsDetailSimpleTypeActionSheetTag 222

typedef enum ShowLoginReason
{
    ShowLoginReasonNone = 0,
    ShowLoginReasonClickWriteComment = 1,
    ShowLoginReasonClickShare = 2,
}ShowLoginReason;

@interface NewsDetailView()<UIWebViewDelegate, ExploreShareViewControllerDelegate, SSActivityViewDelegate, SSVideoManagerDelegate, UIActionSheetDelegate, UIAlertViewDelegate, ArticleActionAlertViewDelegate, NewsDetailWebViewDelegate, SSActivityPopoverControllerDelegate, NewsDetailSupernatantViewDelegate,SSCommentManagerDelegate, ExploreWriteCommentViewDelegate, UIPopoverControllerDelegate, NewsDetailImageDownloadManagerDelegate>{
@private
    BOOL _beginShowComment;//打开即显示评论
    NewsDetailType _newsDetailType;                 //详情页模式
    NewsDetailNatantLevel _newsDetailNatantLevel;   //浮层级别, 默认 NewsDetailNatantLevelNotAssign
    BOOL _hasLoaded;
    Article *_article;
    
}
// 有ADID的需要统计webview的加载时间
@property (nonatomic, strong) NSDate    *startLoadDate;
@property(nonatomic, retain)ExploreItemActionManager * exploreItemActionManager;
@property(nonatomic, retain)ArticleListNotifyBarView * notInterestNotifyBarView;
@property(nonatomic, retain)NewsDetailViewEventTracker * eventTracker;
@property(nonatomic, retain)NewsDetailSupernatantView * natantView;
@property(nonatomic, retain)NewsDetailToolBarView * toolBarView;
@property(nonatomic, retain)NewsDetailTitleBarView * titleBarView;

@property(nonatomic, retain)NewsDetailWebView           *webView;
@property(nonatomic, retain)Article                     *article;
@property(nonatomic, retain)DetailActionRequestManager  *actionManager;

@property(nonatomic, retain)UIImageView                 *loadingView;

@property(nonatomic, retain)UIButton                    *retryButton;

// Changed by luohuaqing
// @property(nonatomic, retain)CommentInputViewController  *phoneCommentInputController;
@property(nonatomic, retain)ExploreShareViewController *phoneShareViewController;

@property(nonatomic, retain)PadFontSelectContainerView  *fontSelectView;
// @property(nonatomic, retain)PadCommentInputView         *padCommentInputView;
@property(nonatomic, retain)ExploreItemActionManager *  itemAction;
@property(nonatomic, retain)UIActivityIndicatorView     *loadingIndicatorView;
@property(nonatomic, retain)SSActivityShareManager     *activityActionManager;//use for share

//显示新article的时候， 清除imageURISet、largeImgModels、image
@property(nonatomic, retain)NSMutableSet                *imageURISet;//用于快速查找URI是否存在
@property(nonatomic, retain)NSArray                     *largeImgModels;//存储大图的列表
@property(nonatomic, retain)NSArray                     *thumbImgModels;//存储缩略图列表

@property (nonatomic,retain)ArticlePadUserProfileView   *padProfileView;

//@property(nonatomic, assign)BOOL                        webViewLoadingAddressBarURL;//用于记录当前webView加载的URL是否是地址栏中开始的
@property(nonatomic, retain)SSActivityView              *phoneShareView;
@property(nonatomic, retain)SSActivityPopoverController *padShareController;

@property(nonatomic, assign)CGFloat offsetYForBeyondWebViewBottomBounds;//超过webview的界限之后继续滑动的距离的初始位移

@property(nonatomic, retain)UIButton * closeNatantButton;
@property(nonatomic, retain)NSString * latestWebViewRequestURL;//记录最近的一次webview加载的URL

@property(nonatomic, retain)NewsDetailFunctionView *functionView;
@property(nonatomic, retain)NewsDetailNoCommentShareView * noToolBarShareView;

@property(nonatomic, assign)CGFloat latestPanGestureOriginYForHalfOpenStatus;   //user for halfOpen level

@property(nonatomic, retain)ArticleClientEscapeManager * clientEscapeManager;
@property(nonatomic, retain)ExploreOrderedData * orderedData;//可能为nil（不是列表来的，都是nil）

@property(nonatomic, retain)UIPopoverController * padAccountPopOverController;

@property(nonatomic, assign)ShowLoginReason showLoginIfNeededReason;
@property(nonatomic, assign)SSActivityType activityType;
@property(nonatomic, retain)NewsDetailImageDownloadManager * detailImageDownloadManager;

@end

@implementation NewsDetailView
{
    BOOL _scrollViewBeginScrollOnce;
    BOOL _webviewInsertedInformationJS;
    /// 这个是为了统计广告落地页的跳转次数。
    NSInteger _jumpCount;
    BOOL    _userHasClickLink;
    NSInteger   _clickLinkCount;
}

@synthesize webView;
@synthesize actionManager;
@synthesize loadingView;
@synthesize retryButton;
@synthesize fontSelectView;
// @synthesize padCommentInputView;
@synthesize loadingIndicatorView;

- (void)dealloc
{
    
    if (_jumpCount > 0) {
        // 发送广告落地页面跳转次数的统计
        [self _sendJumpEventWithCount:_jumpCount];
    }
    
    if (self.startLoadDate) {
        [self _sendStatStayEvent:SSWebViewStayStatCancel error:nil];
    }
    [_eventTracker sendContentReadPercentForWebView:webView article:_article];
    
    [self invalidate];
    self.exploreItemActionManager = nil;
    if (_clientEscapeManager) {
        [_clientEscapeManager removeObserver:self forKeyPath:@"mainPageIsClientEscape"];
    }
    self.clientEscapeManager = nil;
    
    //记录专题 impression
    if ([_article.groupType intValue] == ArticleGroupTypeTopic) {
        [self recordArticleTopicImpression];
    }
    //不感兴趣
    if ([_article.notInterested boolValue] && _orderedData) {
        NSMutableDictionary * userInfo = [NSMutableDictionary dictionaryWithCapacity:10];
        [userInfo setValue:_orderedData forKey:kExploreMixListNotInterestItemKey];
        [[NSNotificationCenter defaultCenter] postNotificationName:kExploreMixListNotInterestNotification object:nil userInfo:userInfo];
    }
    
    [_notInterestNotifyBarView clean];
    self.notInterestNotifyBarView = nil;
    
    self.orderedData = nil;
    
    self.titleBarView = nil;
    self.noToolBarShareView = nil;

    
    self.eventTracker = nil;
    
    self.closeNatantButton = nil;
    self.latestWebViewRequestURL = nil;
    
    
    self.phoneShareView = nil;
    self.natantView = nil;
    if (_padProfileView) {
        [[SSFlipContainerManager sharedManager] closeFlipContainers:@[_padProfileView]];
    }
    self.padProfileView = nil;
    
    self.imageURISet = nil;
    self.thumbImgModels = nil;
    self.largeImgModels = nil;
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    self.phoneShareViewController = nil;
    
    self.activityActionManager = nil;
    [_padShareController dismissPopoverAnimated:NO];
    self.padShareController = nil;
    self.toolBarView = nil;
    self.article = nil;
    [self.webView removeDelegate:self];
    self.webView = nil;
    self.actionManager = nil;
    self.loadingView = nil;

    self.retryButton = nil;
    self.fontSelectView = nil;
    // self.padCommentInputView = nil;
    self.itemAction = nil;
    self.loadingIndicatorView = nil;
    self.functionView = nil;
    
    self.padAccountPopOverController = nil;
    self.startLoadDate = nil;
    [super dealloc];
}



- (id)initWithFrame:(CGRect)frame
            article:(Article*)tArticle
        orderedData:(ExploreOrderedData *)orderedData
   beginShowComment:(BOOL)beginShowComment
    umengEventLabel:(NSString *)eventLabel
          condition:(NSDictionary *)dict
{
    self = [super initWithFrame:frame];
    if (self) {
        self.detailImageDownloadManager = [[[NewsDetailImageDownloadManager alloc] init] autorelease];
        _detailImageDownloadManager.delegate = self;
        self.orderedData = orderedData;
        _webviewInsertedInformationJS = NO;
        _newsDetailType = NewsDetailTypeNotAssign;
        _scrollViewBeginScrollOnce = NO;
        _newsDetailNatantLevel = NewsDetailNatantLevelNotAssign;

        _beginShowComment = beginShowComment;
        self.article = tArticle;
        self.showLoginIfNeededReason = ShowLoginReasonNone;
        self.activityType = SSActivityTypeNone;
        
        self.eventTracker = [[[NewsDetailViewEventTracker alloc] init] autorelease];
        _eventTracker.umengEventLabel = eventLabel;

        if ([[dict allKeys] containsObject:kNewsDetailViewConditionADIDKey] && [[dict objectForKey:kNewsDetailViewConditionADIDKey] longLongValue] > 0) {
            _eventTracker.adID = @([[dict objectForKey:kNewsDetailViewConditionADIDKey] longLongValue]);
        }
        
        if ([[dict allKeys] containsObject:kNewsDetailViewConditionRelateReadFromGID] && [[dict objectForKey:kNewsDetailViewConditionRelateReadFromGID] longLongValue] > 0) {
            _eventTracker.relateReadFromID = @([[dict objectForKey:kNewsDetailViewConditionRelateReadFromGID] longLongValue]);
        }
        
        _eventTracker.statParams = [dict objectForKey:kNewsDetailViewCustomStatParamsKey];
        
        [_eventTracker sendGoDetailForArticle:_article];
        
        self.actionManager = [[[DetailActionRequestManager alloc] init] autorelease];

        //title bar init
        self.titleBarView = [[[NewsDetailTitleBarView alloc] initWithFrame:[self frameForTitleBar]] autorelease];
        [_titleBarView.backButtonView.closeButton addTarget:self action:@selector(titleBarButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [_titleBarView.backButtonView.backButton addTarget:self action:@selector(titleBarButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_titleBarView];
        

        self.webView = [[[NewsDetailWebView alloc] initWithFrame:[self frameForWebView]] autorelease];
        webView.dataDetectorTypes = UIDataDetectorTypeNone;
        [webView addDelegate:self];
        webView.ssDelegate = self;
        webView.opaque = NO;
        [self addSubview:webView];
        [self refreshWebviewMenu];
        [self addNotificationObserver];
        
        [self showLoadingView];
        
        [self reloadThemeUI];
        ssTrackEvent(@"detail", @"enter");
        
        // 有ADID的需要统计webview的加载时间,从进入就开始计时
        self.startLoadDate = [NSDate date];
    }

    return self;
}

- (void)addNotificationObserver
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationDidEnterBackground:)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationWillEnterForeground:)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(contentLoadFinished:)
                                                 name:kNewsFetchArticleDetailFinishedNotification
                                               object:nil];
    
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(fontChanged:)
                                                 name:kSettingFontSizeChangedNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(wvNatantSwitchChanged:)
                                                 name:kNewsDetailNatantSwitchChangedNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(menuControllerDidHideMenuNotification:)
                                                 name:UIMenuControllerDidHideMenuNotification
                                               object:nil];
}

- (void)invalidate
{
    _detailImageDownloadManager.delegate = nil;
    [_detailImageDownloadManager cancelAll];
    self.detailImageDownloadManager = nil;
    [_eventTracker invalidate];
    [[SSVideoManager sharedManager] cancelAndClearDelegate];
    self.natantView.delegate = nil;
    self.natantView.commentView.commentManager.delegate = nil;
    webView.delegate = nil;
    webView.ssDelegate = nil;

}

- (void)handleRightSwip
{
    [self goBack:nil];
}

- (void)themeChanged:(NSNotification*)notification
{
    [_closeNatantButton setTitleColor:[UIColor colorWithHexString:SSUIString(@"NewsDetailViewCloseNatantButtonTitleColor", @"da4242")] forState:UIControlStateNormal];
    [_closeNatantButton setTitleColor:[UIColor colorWithHexString:SSUIString(@"NewsDetailViewCloseNatantButtonTitleHighlightColor", @"999999")] forState:UIControlStateHighlighted];

    self.backgroundColor = [UIColor colorWithHexString:SSUIString(@"detailViewBackgroundColor", @"")];

    if ([self isWebContentType] && [_article.articleSubType intValue] != ArticleSubTypeCooperationWap) {
        webView.backgroundColor = [UIColor whiteColor];
    }
    else {
        webView.backgroundColor = [UIColor colorWithHexString:SSUIString(@"detailViewBackgroundColor", @"")];
    }
    [loadingView setImage:[UIImage resourceImageNamed:@"detail_loading.png"]];
    
    [self refreshDetailTheme];
    
    if ([[SSResourceManager shareBundle] currentMode] == SSThemeModeDay) {
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    }
    else {
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    }

    
}

- (void)refreshDetailTheme
{
    if(![SSCommon isPadDevice])
    {
        if([self isWebContentType] && [_article.articleSubType intValue] != ArticleSubTypeCooperationWap)
        {
            [self.webView showCoverIfNeed];
        }
        else {
            NSString *js = [NSString stringWithFormat:@"TouTiao.setDayMode(%d)", [[SSResourceManager shareBundle] currentMode] == SSThemeModeDay];
            [self webView:webView stringByEvaluatingJavaScriptFromString:js];
        }
    }
}

- (void)setArticle:(Article *)article
{
    [article retain];
    [_article release];
    _article = article;
    
    if (_article.managedObjectContext) {
        self.largeImgModels = [_article detailLargeImageModels];
        self.thumbImgModels = [_article detailThumbImageModels];
        
        self.imageURISet = [NSMutableSet setWithCapacity:10];
        
        for (SSImageInfosModel * m in _largeImgModels) {
            if (m.URI != nil) {
                [_imageURISet addObject:m.URI];
            }
        }
        
        for (SSImageInfosModel * m in _thumbImgModels) {
            if (m.URI != nil) {
                [_imageURISet addObject:m.URI];
            }
        }
    }
}

- (Article*)article
{
    return _article;
}

- (void)commentButtonClicked:(id)sender
{
    if ([self isNatantViewOnOpenStatus]) {
        ssTrackEvent(@"detail", @"comment_button_close");
    }
    else {
        ssTrackEvent(@"detail", @"comment_button_open");
    }
    [self clickChangeNatantStatusButton];
}

- (void)setViewsHidden:(BOOL)hidden
{
    if (webView.hidden) {
        webView.hidden = NO;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    self.phoneShareViewController.delegate = nil;
    [_phoneShareViewController didReceiveMemoryWarning];
    self.phoneShareViewController = nil;
}

- (void)willAppear
{
    [super willAppear];
//    不需要在这里add了，disappear 的时候也没有remove
//    [self.webView addDelegate:self];
    [_natantView willAppear];
}

- (void)didAppear
{
    [super didAppear];
    [self tryLoadContent];
    [_natantView didAppear];
}

- (void)tryLoadContent
{
    if(!_hasLoaded)
    {
        [self startGetContent];
        //产品需求， 一进入详情页如果有地址信息，就先显示地址信息
        if (!isEmptyString(_article.displayTitle) || !isEmptyString(_article.displayURL)) {
            [_titleBarView refreshAddressTitle:_article.displayTitle addressURL:_article.displayURL];
        }
    }
    else
    {
        [_eventTracker recordStayTimerForArticle:self.article];
    }
}

- (void)willDisappear
{
    [super willDisappear];
//    不需要在这里remove了，这里没有了循环引用，在dealloc中会被释放。
//    [self.webView removeDelegate:self];
    [_natantView willDisappear];
    
    if([SSCommon isPadDevice])
    {
        if (_padProfileView) {
            [[SSFlipContainerManager sharedManager] closeOtherFlipContainers:@[_padProfileView]];
        }
    }
    
    [_eventTracker trySendStayTrackForArticle:self.article];
}

- (void)didDisappear
{
    [super didDisappear];
    [_natantView didDisappear];
}

- (void)startGetContent
{
    if(!self.article.managedObjectContext)
    {
        SSLog(@"%s, error: article is removed", __PRETTY_FUNCTION__);
        return;
    }
    
    if (![self.article isContentFetched] && !SSNetworkConnected()) {
        [[SSActivityIndicatorView sharedView] showMessage:sNoNetworkConnectTip];
        [self showRetryButton];
        return;
    }
    
    if (!_hasLoaded) {
        [self startLoadingIndicatorViewAnimating];
    }
    [_eventTracker invalidate];
    
    if ([_article.articleType intValue] == ArticleTypeWebContent && [_article isContentFetched]) {
        if(!_hasLoaded)
        {
            [self loadAllTypeContent];
            _hasLoaded = YES;
        }
    }
    else {
        [[NewsFetchArticleDetailManager sharedManager] fetchDetailForArticle:self.article withOperationPriority:NSOperationQueuePriorityVeryHigh notifyCompleteBeforRealFetch:YES notifyError:YES];
    }
}


#pragma mark -- Natant View

- (void)buildNatantViewIfNeed
{
    if (![self needLoadComment]) {
        return;
    }
    if (!_natantView) {
        self.natantView = [[[NewsDetailSupernatantView alloc] initWithFrame:[self frameForNatantView]] autorelease];
        _natantView.delegate = self;
        _natantView.commentView.commentManager.delegate = self;
        [_natantView willAppear];
        [_natantView didAppear];
        
        [self refreshNatantLevel];
    }
}

//有效的阅读完成的高度
- (CGFloat)availableSendFinishedContentY
{
    if (_newsDetailNatantLevel == NewsDetailNatantLevelClose ||
        _newsDetailNatantLevel == NewsDetailNatantLevelHalfClose ||
        _newsDetailNatantLevel == NewsDetailNatantLevelHalfOpen) {
        return webView.scrollView.contentSize.height - webView.frame.size.height;
    }
    else {
        return [self originYForWebViewBeginShowNatant];
    }
}

- (CGFloat)originYForWebViewBeginShowNatant NS_AVAILABLE_IOS(5_0)
{
    return webView.scrollView.contentSize.height - webView.scrollView.contentInset.bottom;
}

#pragma mark -- NewsDetailWebViewDelegate

- (void)detailWebView:(NewsDetailWebView *)wView handlePanGestureRecognizer:(UIPanGestureRecognizer *)recognizer
{
    if (_newsDetailNatantLevel == NewsDetailNatantLevelHalfOpen) {
        
        CGPoint p = [recognizer translationInView:webView];

        if ([recognizer state] == UIGestureRecognizerStateBegan) {
            _latestPanGestureOriginYForHalfOpenStatus = 0;
        }
        
        if (webView.scrollView.contentOffset.y >= webView.scrollView.contentSize.height - webView.scrollView.frame.size.height) {
            if (_latestPanGestureOriginYForHalfOpenStatus == 0) {
                _latestPanGestureOriginYForHalfOpenStatus = p.y;
            }
            CGFloat detla = _latestPanGestureOriginYForHalfOpenStatus - p.y;
            CGFloat oY =  _natantView.frame.origin.y - detla;
            oY = MAX(oY, CGRectGetMaxY(_titleBarView.frame) + 1);
            oY = MIN(oY, CGRectGetMinY(_toolBarView.frame) - 1);
            [_natantView changeFrameOriginY:oY animated:NO];
        }
        
        _latestPanGestureOriginYForHalfOpenStatus = p.y;
        
        if ([recognizer state] == UIGestureRecognizerStateCancelled || [recognizer state] == UIGestureRecognizerStateEnded) {
            if (_natantView.frame.origin.y < CGRectGetMinY(_toolBarView.frame) || _natantView.frame.origin.y > CGRectGetMaxY(_titleBarView.frame)) {
                if (_natantView.frame.origin.y < _natantView.frame.size.height - validOpenDistanceForHalfOpenLevel) {
                    [UIView animateWithDuration:0.25 animations:^{
                        [self openNatantShowComment:NewsDetailOpenNatantShowTypeNatantTop beginPositionStart:NO animatedTime:0];
                    }];
                }
                else {
                    [_natantView changeFrameOriginY:CGRectGetMinY(_toolBarView.frame) animated:YES];
                    _natantView.statusType = NewsDetailSupernatantStatusTypeFullClose;
                }
            }
        }
    }
    else {
        if ([recognizer state] == UIGestureRecognizerStateBegan) {
            _offsetYForBeyondWebViewBottomBounds = 0;
        }
        
        if (webView.scrollView.contentOffset.y >= webView.scrollView.contentSize.height) {
            if (_natantView.commentView.commentTableView.contentOffset.y > _natantView.frame.size.height / 2.f) {
                return;
            }
            
            CGPoint t = [recognizer translationInView:webView];
            
            if (_offsetYForBeyondWebViewBottomBounds == 0) {
                _offsetYForBeyondWebViewBottomBounds = t.y;
            }
            
            CGFloat detla =  t.y - _offsetYForBeyondWebViewBottomBounds;
            CGFloat offsetY = _natantView.commentView.commentTableView.contentOffset.y - detla;
            offsetY = MAX(0, offsetY);
            CGFloat maxOffsetY = _natantView.commentView.commentTableView.contentSize.height - _natantView.frame.size.height;
            maxOffsetY = MAX(0, maxOffsetY);
            maxOffsetY = MIN(maxOffsetY, _natantView.frame.size.height);
            offsetY = MIN(offsetY, maxOffsetY);
            [_natantView changeContentOffsetY:offsetY animated:NO];
            _offsetYForBeyondWebViewBottomBounds = t.y;
        }
    }
}

- (void)detailWebView:(NewsDetailWebView *)wView scrollViewDidScroll:(UIScrollView *)sView
{
    [self refreshNatantStatus];
    [_eventTracker updateContentScrollY:sView.contentOffset.y];
    [_eventTracker sendFinishContentIfNeedByNatantOriginY:[self availableSendFinishedContentY] webView:self.webView article:_article];
}

- (void)detailWebView:(NewsDetailWebView *)wView scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    _eventTracker.detailViewBeginDraginContentOffsetY = wView.scrollView.contentOffset.y;
}

- (void)detailWebView:(NewsDetailWebView *)webView scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    [self refreshNatantStatus];
}

- (void)detailWebView:(NewsDetailWebView *)wView scrollViewDidEndDecelerating:(UIScrollView *)sView
{
    
    [_eventTracker sendChangeDrawerEventForWebView:webView beginShowOriginY:[self originYForWebViewBeginShowNatant]];
    
    [self refreshNatantStatus];
}

- (void)detailWebView:(NewsDetailWebView *)wView scrollViewDidEndDragging:(UIScrollView *)sView willDecelerate:(BOOL)decelerate_
{
    if (!decelerate_) {
        [_eventTracker sendChangeDrawerEventForWebView:webView beginShowOriginY:[self originYForWebViewBeginShowNatant]];
    }
    [_eventTracker sendReadContentIfNeedForWebView:self.webView article:_article];
    [_eventTracker sendEnterCommentIfNeedByNatantOriginY:[self originYForWebViewBeginShowNatant] natantHeight:[_natantView headerViewHeight] webView:self.webView article:_article forceSendIfNotSend:NO];
}


- (void)detailWebViewContentSizeChanged:(NewsDetailWebView *)wView{
    if (_natantView.statusType == NewsDetailSupernatantStatusTypeButtonOpen) {
        
    }
    else {
        _natantView.frame = [self frameForNatantView];
        if (_natantView.statusType == NewsDetailSupernatantStatusTypeFullShow) {
            [webView webViewScrollToOffset:[self normalOriginYForNatantView] animatied:NO];
        }
    }
}

#pragma mark UIWebViewDelegate

- (BOOL)webView:(UIWebView *)wView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    BOOL utilResult = [SSWebViewUtil webView:wView shouldStartLoadWithRequest:request navigationType:navigationType];
    if (!utilResult) {
        return utilResult;
    }
    
    NSNumber *adID = _eventTracker.adID;
    if (adID.longLongValue == 0) {
        adID = self.orderedData.adID;
    }
    if (adID) {
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
    
    BOOL canResponse = NO;
    BOOL result = YES;
    
    if([self redirectRequestCanOpen:request])
    {
        canResponse = YES;
        result = NO;
        [self redirectLocalRequest:request.URL];
    }
    
    if (!canResponse && navigationType == UIWebViewNavigationTypeLinkClicked) {
        _clientEscapeManager.userClickedWebViewLink = YES;
    }
    
    if (!canResponse && [_article.articleType intValue] != ArticleTypeNativeContent) {
        return YES;
    }

    if (!canResponse && [request.URL.host length] > 0) {
        [self redirectRequest:request.URL navigationType:navigationType];
        return NO;
    }
    
    return result;
}

#pragma mark -PrivateMethod
- (void)_sendJumpEventWithCount:(NSInteger) count {
    
    NSNumber *adID = _eventTracker.adID;
    if (adID.longLongValue == 0) {
        adID = self.orderedData.adID;
    }
    // 只统计广告的页面停留时间，和qiuliang约定，如果停留时常<3s，则忽略
    if (count <= 0 || adID.longLongValue == 0) {
        return;
    }
    NSMutableDictionary * dict = [NSMutableDictionary dictionaryWithCapacity:10];
    [dict setValue:@"wap_stat" forKey:@"category"];
    [dict setValue:@"jump_count" forKey:@"tag"];
    if (_clickLinkCount > 0) {
        [dict setValue:@(_clickLinkCount) forKey:@"click_link"];
    }
    [dict setValue:@(count).stringValue forKey:@"value"];
    [dict setValue:adID forKey:@"ext_value"];
    [SSTracker eventData:dict];
}

- (void)_sendStatStayEvent:(SSWebViewStayStat) stat error:(NSError *)error {
    /// 这里的顺序与 _SSWebViewStat 定义的顺序一致
    NSArray *tags = @[@"load", @"load_finish", @"load_fail"];
    if (stat >= tags.count) {
        return;
    }
    // 客户端转码页
    BOOL clientEscaped = (_article.articleType.intValue == ArticleTypeNativeContent);
    BOOL isHTTP = [self.webView.request.URL.scheme isEqualToString:@"http"] || [self.webView.request.URL.scheme isEqualToString:@"https"];
    NSNumber *adID = _eventTracker.adID;
    if (adID.longLongValue == 0) {
        adID = self.orderedData.adID;
    }
    if (adID.longLongValue > 0 && !self.webView.canGoBack && (isHTTP|| clientEscaped) && self.startLoadDate) {
        NSMutableDictionary * dict = [NSMutableDictionary dictionaryWithCapacity:10];
        [dict setValue:@"wap_stat" forKey:@"category"];
        [dict setValue:[NSString stringWithFormat:@"%lld",self.orderedData.originalData.uniqueID.longLongValue] forKey:@"value"];
        [dict setValue:tags[stat] forKey:@"tag"];
        [dict setValue:[NSString stringWithFormat:@"%lld", adID.longLongValue] forKey:@"ext_value"];
        // 这里的加载时间是指从一开始LoadRequest就开始记时，到加载结束
        if (stat == SSWebViewStayStatLoadFail && error) {
            [dict setValue: @(error.code).stringValue forKey:@"error"];
        } else {
            /// 需要减去后台停留时间
            NSTimeInterval timeInterval = [[NSDate date] timeIntervalSinceDate:_startLoadDate];
            [dict setValue:[NSString stringWithFormat:@"%.0f", timeInterval*1000] forKey:@"load_time"];
        }
        if (_userHasClickLink) {
            [dict setValue:@(YES) forKey:@"hasClickLink"];
        }
        if (!isEmptyString(self.orderedData.logExtra)) {
            [dict setValue:self.orderedData.logExtra forKey:@"log_extra"];
        } else if (!isEmptyString(self.orderedData.article.adModel.logExtra)) {
            [dict setValue:self.orderedData.article.adModel.logExtra forKey:@"log_extra"];
        }
        [SSTracker eventData:dict];
        // 这里要把这个变成空的，下次如果看到时间是空的，则不重新发送统计。
        self.startLoadDate = nil;
    }
}

- (void)webView:(UIWebView *)myWebView didFailLoadWithError:(NSError *)error
{
    if ([self isWebContentType]) {
        if ([ArticleClientEscapeManager needShowClientEscapseButton:_article]) {
            NSRange range = [myWebView.request.URL.absoluteString rangeOfString:[self baseURLStringWithRandomParam:NO]];
            if ((range.location != NSNotFound || (![myWebView canGoBack])) && !_clientEscapeManager.tryClientEscapeFailed) {
                [self showClientEscapeButton:YES];
            }
            else {
                [self showClientEscapeButton:NO];
            }
            [_titleBarView setClientEscapeButtonEnabe:YES];
        }
        else if (!SSNetworkConnected()) {
            [self showRetryViewIfNeed:sNoNetworkConnectTip];
        }
    }
    [self stopLoadingIndicatorViewAnimation];
    [self _sendStatStayEvent:SSWebViewStayStatLoadFail error:error];
}

- (void)webViewDidStartLoad:(UIWebView *)tWebView
{
    if (!isEmptyString(self.latestWebViewRequestURL)) {
        BOOL isHTTP = [tWebView.request.URL.scheme isEqualToString:@"http"] || [tWebView.request.URL.scheme isEqualToString:@"https"];
        if (![tWebView.request.URL.absoluteString isEqualToString:self.latestWebViewRequestURL] && isHTTP) {
            // 页面发生跳转，发送取消事件(里面会判断是否已经发送过其他事件，如果发送过，则不会重复发送)
            [self _sendStatStayEvent:SSWebViewStayStatCancel error:nil];
        }
    }
    [self startLoadingIndicatorViewAnimating];
    self.latestWebViewRequestURL = tWebView.request.URL.absoluteString;
}

- (void)webViewDidFinishLoad:(UIWebView *)tWebView
{
    [self _sendStatStayEvent:SSWebViewStayStatLoadFinish error:nil];
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([_article.articleType intValue] == ArticleTypeNativeContent) {
            [self loadWebResource:@"iphone.js" fromLocalForce:NO];
            [self loadBridgeWebResource:@"TTBridge.js" fromLocalForce:NO];
            [self updateFontSizeForWebView:tWebView];
            [self webViewShowImageIfCachedOrDownload:NO];
        }
        else if ([_article.articleSubType intValue] == ArticleSubTypeCooperationWap) {
            [self updateFontSizeForWebView:tWebView];
            [self webViewShowImageIfCachedOrDownload:NO];
        }
        if ([_article isClientEscapeType]) {
            [self insertJSContext:[_natantView getFetchedJSContextIfHave]];
        }
        else {
            [self insertJSContext:[_natantView getAndClearFetchedJSContextIfHave]];
        }
        _webviewInsertedInformationJS = YES;
        
        [self removeRetryButton];
        [self setViewsHidden:NO];
        
        [self removeLoadingView];
        [self stopLoadingIndicatorViewAnimation];
        
        _hasLoaded = YES;
        
        if ([ArticleClientEscapeManager needShowClientEscapseButton:_article]) {
            NSRange range = [tWebView.request.URL.absoluteString rangeOfString:[self baseURLStringWithRandomParam:NO]];
            if ((range.location != NSNotFound || (![tWebView canGoBack])) && !_clientEscapeManager.tryClientEscapeFailed) {
                [self showClientEscapeButton:YES];
            }
            else {
                [self showClientEscapeButton:NO];
            }
            if (!_titleBarView.clientEscapeButton.enabled) {
                [_titleBarView setClientEscapeButtonEnabe:YES];
            }
        }
        if (!webView.opaque) {
            webView.opaque = YES;
        }
    });
}

- (void)updateFontSizeForWebView:(UIWebView*)tWebView
{
    NSString *fontSizeType = [NewsUserSettingManager settedFontShortString];
    [self webView:tWebView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"TouTiao.setFontSize(\"%@\")", fontSizeType]];
}


- (BOOL)redirectRequestCanOpen:(NSURLRequest *)requestURL
{
    if ([requestURL.URL.scheme isEqualToString:kBytedanceScheme] ||
        [[requestURL.URL absoluteString] hasPrefix:SSLocalScheme] ||
        [[requestURL.URL absoluteString] hasPrefix:kLocalSDKDetailSCheme] ||
        [[requestURL.URL absoluteString] hasPrefix:kSNSSDKScheme]) {
        return YES;
    }
    return NO;
};

- (void)redirectLocalRequest:(NSURL*)requestURL
{
    if([requestURL.scheme isEqualToString:kBytedanceScheme])
    {
        if ([requestURL.host isEqualToString:kClientEscapeTranscodeError]) {
            if ([ArticleClientEscapeManager needShowClientEscapseButton:_article]) {
                _clientEscapeManager.tryClientEscapeFailed = YES;
                [self loadWebTypeContent];
                [[SSActivityIndicatorView sharedView] showInView:webView message:SSLocalizedString(@"优化失败", nil)];
            }
        }
        else if([requestURL.host isEqualToString:kShowFullImageHost])
        {
            NSDictionary *parameters = [SSCommon parametersOfURLString:requestURL.query];
            if([parameters count] > 0)
            {
                int index = [[parameters objectForKey:@"index"] intValue];
                [self fullScreenShowImageOriginIndex:index];
            }
        }
        else if ([requestURL.host isEqualToString:kShowOriginImageHost]) {
            NSDictionary *parameters = [SSCommon parametersOfURLString:requestURL.query];
            int parIndex = (int)[[parameters objectForKey:@"index"] longLongValue];
            int index = parIndex;
            if (index < [_largeImgModels count] && index >= 0) {
                SSImageInfosModel * largeModels = [_largeImgModels objectAtIndex:index];
                UIImage * largeImg = [SSWebImageManager imageForModel:largeModels];
                BOOL cached = largeImg != nil;
                if (cached) {
                    [self webViewShowImageForModel:largeModels imageIndex:index imageType:JSMetaInsertImageTypeOrigin];
                }
                else {
                    [self downloadImageModel:largeModels index:index insertTop:YES];
                }
            }
            NetworkTrafficSetting settingType = [SSUserSettingManager networkTrafficSetting];
            if (settingType == NetworkTrafficSave) {
                ssTrackEvent(@"detail", @"show_one_image");
            }
            else {
                ssTrackEvent(@"detail", @"enlarger_image");
            }
            
        }
        else if([requestURL.host isEqualToString:kWebViewShowThumbImage])
        {
            NSDictionary *parameters = [SSCommon parametersOfURLString:requestURL.query];
            int parIndex = (int)[[parameters objectForKey:@"index"] longLongValue];
            int index = parIndex;
            [self webViewShowThumbImageAtIndex:index showOriginIfCached:YES];
        }
        else if([requestURL.host isEqualToString:kWebViewShowOfflineImage])
        {
            NSDictionary *parameters = [SSCommon parametersOfURLString:requestURL.query];
            int parIndex = (int)[[parameters objectForKey:@"index"] longLongValue];
            int index = parIndex;
            [self webViewShowOfflineImageAtIndex:index];
        }
        else if ([requestURL.host isEqualToString:kVideoHost])
        {
            NSDictionary *parameters = [SSCommon parametersOfURLString:requestURL.query];
            
            if ([parameters.allKeys containsObject:@"play_url"]) {
                
                NSString *playURL = [parameters objectForKey:@"play_url"];
                [[SSVideoManager sharedManager] setDelegate:self];
                [[SSVideoManager sharedManager] loadVideoDataWithURL:playURL];
            }
            else {
                [[SSActivityIndicatorView sharedView] showMessage:SSLocalizedString(@"视频不存在", nil)];
            }
        }
        else if([requestURL.host isEqualToString:kUserProfile])
        {
            NSDictionary *parameters = [SSCommon parametersOfURLString:requestURL.query];
            [self presentUserProfileWithUserID:[parameters objectForKey:@"user_id"]];
            
            NSString *action = [parameters objectForKey:@"action"];
            if([action isEqualToString:@"digg"])
            {
                ssTrackEvent(@"detail", @"click_digg_users");
            }
            else if([action isEqualToString:@"bury"])
            {
                ssTrackEvent(@"detail", @"click_bury_users");
            }
            else if([action isEqualToString:@"repin"])
            {
                ssTrackEvent(@"detail", @"click_favorite_users");
            }
            else if ([action isEqualToString:@"pgc"])
            {
                ssTrackEvent(@"detail", @"click_pgc_user_profile");
            }
        }
        else if ([requestURL.host isEqualToString:kWebViewUserClickLoadOriginImg] || [requestURL.host isEqualToString:kWebViewLoadOriginImg]) {

            if ([requestURL.host isEqualToString:kWebViewUserClickLoadOriginImg]) {
                ssTrackEvent(@"detail", @"show_image");
            }

            if (!SSNetworkConnected()) {
                [[SSActivityIndicatorView sharedView] showMessage:sNoNetworkConnectTip];
            }
            
            [self webViewShowImageIfCachedOrDownload:YES];
            [NewsDetailLogicManager didClickShowOriginButtonOnceInNoWifiNetworkIfNotSetNetworkTrafficOptimum];
            BOOL shouldShow = [NewsDetailLogicManager shouldShowChangedNetworkTrafficAlertWhenClickShowOriginButtonInNoWifiNetwork];
            if (shouldShow) {
                if ([SSCommonLogic ttAlertControllerEnabled]) {
                    TTThemedAlertController *alert = [[TTThemedAlertController alloc] initWithTitle:nil message:SSLocalizedString(@"总是显示大图", nil) preferredType:TTThemedAlertControllerTypeAlert];
                    [alert addActionWithTitle:SSLocalizedString(@"否", nil) actionType:TTThemedAlertActionTypeCancel actionBlock:nil];
                    [alert addActionWithTitle:SSLocalizedString(@"是", nil) actionType:TTThemedAlertActionTypeNormal actionBlock:^{
                        [SSUserSettingManager setNetworkTrafficSetting:NetworkTrafficOptimum];
                    }];
                    [alert showFrom:self.viewController animated:YES];
                    [alert release];
                }
                else {
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil
                                                                        message:SSLocalizedString(@"总是显示大图", nil)
                                                                       delegate:self
                                                              cancelButtonTitle:SSLocalizedString(@"否", nil)
                                                              otherButtonTitles:SSLocalizedString(@"是", nil), nil];
                    alertView.tag = kChangeNetworkTrafficSettingTag;
                    [alertView show];
                    [alertView release];
                }
            }
        }
        else if([requestURL.host isEqualToString:kWebViewLoadThumbImage])
        {
            [self webViewShowThumbImage];
        }
        else if([requestURL.host isEqualToString:kWebViewLoadOfflineImage])
        {
            [self webViewShowOfflineImage];
        }
        else if([requestURL.host isEqualToString:kWebViewCancelimageDownload])
        {
            NSDictionary *parameters = [SSCommon parametersOfURLString:requestURL.query];
            int parIndex = (int)[[parameters objectForKey:@"index"] longLongValue];
            
            if(parIndex < _largeImgModels.count)
            {
                int index = parIndex;
                
                [_detailImageDownloadManager cancelDownloadForImageModel:_largeImgModels[index]];
            }
            
            if(parIndex < _thumbImgModels.count)
            {
                int index = parIndex;
                
                [_detailImageDownloadManager cancelDownloadForImageModel:_thumbImgModels[index]];
            }
        }
        
        else if ([requestURL.host isEqualToString:kClickSource]) {
            NSDictionary *parameters = [SSCommon parametersOfURLString:requestURL.query];
            NSString * sourceURL = [parameters objectForKey:@"source"];
            
            sourceURL = [sourceURL stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            
            ssOpenWebView([SSCommon URLWithURLString:sourceURL], nil, [SSCommon topNavigationControllerFor:self], NO, nil);
            ssTrackEvent(@"detail", @"click_source");
        }
        else if ([requestURL.host isEqualToString:kDownloadAppHost]) {
            NSDictionary * parameters = [SSCommon parametersOfURLString:requestURL.query];
            [[SSAppStore shareInstance] openAppStoreByActionURL:[parameters objectForKey:@"url"] itunesID:[parameters objectForKey:@"apple_id"] presentController:[SSCommon topViewControllerFor:self]];
        }
        else if ([requestURL.host isEqualToString:kCustomOpenHost]) {
            NSDictionary *parameters = [SSCommon parametersOfURLString:requestURL.query];
            NSString * sourceURL = [parameters objectForKey:@"url"];
            
            sourceURL = [sourceURL stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            
            ssOpenWebView([SSCommon URLWithURLString:sourceURL], nil, [SSCommon topNavigationControllerFor:self], NO, nil);
        }
        else if ([requestURL.host isEqualToString:kTrackURLHost]) {
            NSDictionary * parameters = [SSCommon parametersOfURLString:requestURL.query];
            NSString * trackStr = [parameters objectForKey:@"url"];
            ssTrackURL(trackStr);
            
        }
        else if ([requestURL.host isEqualToString:kCustomEventHost]) {
            NSDictionary * parameters = [SSCommon parametersOfURLString:requestURL.query];
            NSString * categoryStr = [parameters objectForKey:@"category"];
            if (isEmptyString(categoryStr)) {
                categoryStr = @"umeng";
            }
            NSString * tagStr = [parameters objectForKey:@"tag"];
            if (!isEmptyString(tagStr)) {
                [NewsDetailLogicManager trackEventCategory:categoryStr tag:tagStr label:[parameters objectForKey:@"label"] value:[parameters objectForKey:@"value"] extValue:[parameters objectForKey:@"ext_value"] groupModel:nil];
            }
        }
        else if ([requestURL.host isEqualToString:kMediaAccountProfileHost]) {
            if (![SSCommon isPadDevice]) {//目前只支持iPhone
                NSDictionary * parameters = [SSCommon parametersOfURLString:requestURL.query];
                NSString * mediaID = [NSString stringWithFormat:@"%@", [parameters objectForKey:@"media_id"]];
                PGCAccount *account = [[[PGCAccount alloc] init] autorelease];
                account.mediaID = mediaID;
                PGCWAPViewController * profileView = [[[PGCWAPViewController alloc] initWithPGCAccount:account] autorelease];
                [[SSCommon topNavigationControllerFor:self] pushViewController:profileView animated:YES];
                ssTrackEvent(@"detail", @"click_web_header");
            }
            
        }
        else if ([requestURL.host isEqualToString:kKeyWordsHost]) {
            NSDictionary * parameters = [SSCommon parametersOfURLString:requestURL.query];
            NSString * keyWordString = [[NSString stringWithFormat:@"%@", [parameters objectForKey:@"keyword"]] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            NSUInteger index = [[parameters objectForKey:@"index"] integerValue];
            if (!isEmptyString(keyWordString)) {
                keyWordString = [NSString stringWithFormat:@"%@", keyWordString];
                [_natantView showSearchViewWithQuery:keyWordString fromType:ListDataSearchFromTypeContent index:index];
            }
        }
        else if ([requestURL.host isEqualToString:kClientEscapeOpenInWebViewHost]) {
            NSDictionary * parameters = [SSCommon parametersOfURLString:requestURL.query];
            NSString * url = [parameters objectForKey:@"url"];
            if (isEmptyString(url) || [url rangeOfString:kRandomParameter].location != NSNotFound ) {
                url = _article.articleURLString;
            }
            if (!isEmptyString(url)) {
                ssOpenWebView([SSCommon URLWithURLString:url], nil, [SSCommon topNavigationControllerFor:self], NO, nil);
            }
        }
        else if ([requestURL.host isEqualToString:kMediaLike] || [requestURL.host isEqualToString:kMediaUnlike]) {
            if ([requestURL.host isEqualToString:kMediaLike]) {
                ssTrackEvent(@"detail", @"pgc_subscribe");
            }
            else {
                ssTrackEvent(@"detail", @"pgc_unsubscribe");
            }
            NSDictionary * parameters = [SSCommon parametersOfURLString:requestURL.query];
            if ([[parameters allKeys] containsObject:@"media_id"]) {
                NSString * mediaID = [NSString stringWithFormat:@"%@", [parameters objectForKey:@"media_id"]];
                [[ExploreEntryManager sharedManager] fetchEntryFromMediaID:mediaID notifySubscribedStatus:YES finishBlock:nil];
            }
        }
    }
    else if ([[SSAppPageManager sharedManager] canOpenURL:requestURL]) {
        NSDictionary * pageCondition = nil;
        if ([_eventTracker.umengEventLabel isEqualToString:@"click_related"]) {
            pageCondition = [NSDictionary dictionaryWithObject:@"click_related" forKey:@"gd_label"];
        }
        [[SSAppPageManager sharedManager] openURL:requestURL displayType:SSAppPageDisplayTypePushed baseCondition:pageCondition popSameController:NO];
    }
}

- (void)redirectRequest:(NSURL*)requestURL navigationType:(UIWebViewNavigationType)navigationType
{
    if (navigationType == UIWebViewNavigationTypeLinkClicked) {
        ssOpenWebView(requestURL, nil, [SSCommon topNavigationControllerFor:self], NO, nil);
    }
    ssTrackEvent(@"detail", @"open_url");
}

- (void)presentUserProfileWithUserID:(NSString*)userID
{
    if ([SSCommon isPadDevice]) {
        
        if ([_padProfileView.currentFriend.userID isEqualToString:userID]) {
            [_padProfileView show];
        }
        else {
            if (_padProfileView) {
                [[SSFlipContainerManager sharedManager] closeFlipContainers:@[_padProfileView]];
            }
            
            ArticleFriend *tmpFriend = [[[ArticleFriend alloc] init] autorelease];
            tmpFriend.userID = [NSString stringWithString:userID];
            self.padProfileView = [[[ArticlePadUserProfileView alloc] initWithFrame:frameForPadFlipView() appearType:UserProfileViewAppearTypeUpdate friendData:tmpFriend isFlip:YES] autorelease];
            
            [[SSFlipContainerManager sharedManager] closeOtherFlipContainers:nil remainKey:kPadFlipUpdateViewRemainKey];
            _padProfileView.from = kFromNewsDetailComment;
            _padProfileView.frame = frameForPadFlipView();
            _padProfileView.appearType = UserProfileViewAppearTypeUpdate;
            _padProfileView.currentFriend = tmpFriend;
            [_padProfileView show];
        }
    }
    else {
        NSString * uID = [NSString stringWithFormat:@"%@", userID];
        if (!isEmptyString(uID)) {
            ArticleMomentProfileViewController * controller = [[ArticleMomentProfileViewController alloc] initWithUserID:uID];
            controller.from = kFromNewsDetailComment;
            UIViewController *topController = [SSCommon topViewControllerFor:self];
            [topController.navigationController pushViewController:controller animated:YES];
            [controller release];
        }
    }
    
}

#pragma mark - SSVideoManagerDelegate

- (void)ssVideoPlayerManager:(SSVideoManager *)manager didLoadVideoModel:(SSVideoModel *)model error:(NSError *)error
{
    if (error || !model) {
        [[SSActivityIndicatorView sharedView] showMessage:SSLocalizedString(@"获取视频失败，请稍后重试", nil)];
    }
    else {
        SSVideoPlayerViewController * videoController = [[SSVideoPlayerViewController alloc] initWithModel:model];
        UIViewController *topController = [SSCommon topViewControllerFor:self];
        [topController.navigationController pushViewController:videoController animated:NO];
        [videoController release];
    }
}

- (void)fullScreenShowImageOriginIndex:(NSUInteger)index
{
    ssTrackEvent(@"detail", @"image_button");
    // show photo scroll view
    SSPhotoScrollViewController * showImageViewController = [[SSPhotoScrollViewController alloc] init];
    NSArray *infoModels = [_article detailLargeImageModels];
    showImageViewController.imageInfosModels = infoModels;
    [showImageViewController setStartWithIndex:index];
    UIViewController *topController = [SSCommon topViewControllerFor:self];
    [topController.navigationController pushViewController:showImageViewController animated:NO];
    [showImageViewController release];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kLargeImageViewDisplayedNotification object:self];
}

#pragma mark - data related

- (void)showRetryViewIfNeed:(NSString *)msg
{
    if ([_article.articleType intValue] == ArticleTypeNativeContent) {
        if ([_article isContentFetched]) {
            return;
        }
    }

    [self displayFailMessage:msg];
    
    [self showRetryButton];
}

- (void)bannArticle
{
    if (![_article.banComment boolValue]) {
        _article.banComment = [NSNumber numberWithBool:YES];
        [[SSModelManager sharedManager] save:nil];
    }
}

- (BOOL)needClientEscape
{
    return [_clientEscapeManager permitClientEscapse:_article];
}

- (BOOL)isWebContentType
{
    return [_article.articleType intValue] == ArticleTypeWebContent;
}

- (void)retry:(id)sender
{
    retryButton.enabled = NO;
    _hasLoaded = NO;
    [self tryLoadContent];
}

- (void)loadWebResource:(NSString*)sourceFileName fromLocalForce:(BOOL)localForce
{
//#warning debug code: web前端联调代码
//    NSString * remotelib = [NSString stringWithContentsOfURL:[SSCommon URLWithURLString:@"http://s2.pstatp.com/js/appdetail_js_debug/iphone.js"] encoding:NSUTF8StringEncoding error:nil];
//    [webView stringByEvaluatingJavaScriptFromString:remotelib];
    
    NSString *lib = nil;
    
    if ([[ArticleJSManager shareInstance] shouldUseJSFromWeb] && !localForce) {
        lib = [[ArticleJSManager shareInstance] getJSFromWeb];
    }else{
        lib = [[WebResourceManager sharedManager] resourceForName:sourceFileName];
    }
    
    [self webView:webView stringByEvaluatingJavaScriptFromString:lib];
    
    [self refreshDetailTheme];
}

- (void)loadBridgeWebResource:(NSString*)sourceFileName fromLocalForce:(BOOL)localForce
{
    NSString *bridgeLib = nil;
    
    if ([[ArticleBridgeJSManager shareInstance] shouldUseJSFromWeb] && !localForce) {
        bridgeLib = [[ArticleBridgeJSManager shareInstance] getJSFromWeb];
    }
    else {
        bridgeLib = [[WebResourceManager sharedManager] resourceForName:sourceFileName];
    }
    
    [self webView:webView stringByEvaluatingJavaScriptFromString:bridgeLib];
}


- (NSString *)webView:(UIWebView *)wView stringByEvaluatingJavaScriptFromString:(NSString *)jsStr
{
    
    if (isEmptyString(jsStr)) {
        return nil;
    }
    
    if ([_article.articleType intValue] != ArticleTypeNativeContent &&
        !([_article.articleType intValue] == ArticleTypeWebContent && [_article.articleSubType intValue] == ArticleSubTypeCooperationWap)) {
        return nil;
    }
    
    return [wView stringByEvaluatingJavaScriptFromString:jsStr];
}


- (void)loadAllTypeContent
{
    [self buildToolBarIfNeed];
    [_toolBarView refreshArticle:_article];
    [self buildNatantViewIfNeed];
    [_natantView refreshForActicle:_article adID:_eventTracker.adID categoryID:_orderedData.categoryID];
    [_titleBarView refreshForDetailType:_newsDetailType];
    [_titleBarView.moreButton addTarget:self action:@selector(titleBarButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    if (!CGRectEqualToRect(webView.frame, [self frameForWebView])) {
        webView.frame = [self frameForWebView];
    }

    [self loadNativeTypeContent];
    [self loadWebTypeContent];
    
    if ([self needLoadComment]) {
        [self showBottomCommentIfNeed];
    }
    
    //对于透明背景的非合作wap页需要处理， 否则夜间模式下， 有问题
    if ([self isWebContentType] && [_article.articleSubType intValue] != ArticleSubTypeCooperationWap) {
        webView.backgroundColor = [UIColor whiteColor];
    }
}

- (void)loadNativeTypeContent
{
    if ([_article.articleType intValue] != ArticleTypeNativeContent) {
        return;
    }

    if(!self.article.managedObjectContext)
    {
        SSLog(@"%s, error: article is removed", __PRETTY_FUNCTION__);
        return;
    }
    [_titleBarView refreshAddressTitle:_article.displayTitle addressURL:_article.displayURL];
    
    [webView stopLoading];
//    self.webViewLoadingAddressBarURL = NO;
    [self.webView hideCover];
    
    NSString * autoLoad = [self loadImageJSStringKeyForType:[self loadImageType:NO]];
    
    int showAvatarAuto = 1;
    if (!SSNetworkWifiConnected() && [SSUserSettingManager networkTrafficSetting] == NetworkTrafficSave) {
        showAvatarAuto = 0;
    }
    int lazyLoadBufferOffset = SSHeight(self);
    lazyLoadBufferOffset = MAX(320, lazyLoadBufferOffset);
    lazyLoadBufferOffset = MIN(768, lazyLoadBufferOffset);
    
    /*ios 8 目前不能播放gif， 临时处理
     0 ： 点击无效
     1 ： 仅对大图生效
     2： 对大图，小图都生效
     */
    int gifPlayInNative = [SSCommon OSVersionNumber] >= 8 ? 2 : 0;
    //ios 8 目前不能播放gif， 临时处理
    int showLargeGifIcon = [SSCommon OSVersionNumber] >= 8 ? 1 : 0;
    
    NSMutableString *head = [NSMutableString stringWithFormat:
                             @"<html><head>"
                             @"<style type=\"text/css\">"
                             @".i-holder{background:url(%@) #ccc no-repeat center center;}"
                             @"</style>"
                             @"<meta name=\"apple-mobile-web-app-capable\" content=\"yes\" />"
                             @"<meta name=\"network_available\" content=\"\" />"
                             @"<meta name=\"digg_count\" content=\"%d\" />"
                             @"<meta name=\"bury_count\" content=\"%d\" />"
                             @"<meta name=\"user_digg\" content=\"%d\" />"
                             @"<meta name=\"user_bury\" content=\"%d\" />"
                             @"<meta name=\"show_video\" content=\"%d\" />"
                             @"<meta name=\"show_avatar\" content=\"%d\"/>"
                             @"<meta name=\"offset_height\" content=\"%d\"/>"
                             @"<meta name=\"lazy_load\" content=\"%d\"/>"
                             @"<meta name=\"gif_play_in_native\" content=\"%d\"/>"
                             @"<meta name=\"show_large_gif_icon\" content=\"%d\"/>",
                             @"loading.png",
                             [self.article.diggCount intValue],
                             [self.article.buryCount intValue],
                             [self.article.userDigg intValue],
                             [self.article.userBury intValue],
                             SSNetworkWifiConnected(),
                             showAvatarAuto,
                             lazyLoadBufferOffset,
                             !SSNetworkWifiConnected(),
                             gifPlayInNative,
                             showLargeGifIcon];
    
//#warning debug code 测试css
//    NSString * cssLib = [NSString stringWithContentsOfURL:[SSCommon URLWithURLString:@"http://10.2.0.188/svn/3.2.0/iphone.css"] encoding:NSUTF8StringEncoding error:nil];
    
    NSString *cssLib = nil;
    if ([SSCommon OSVersionNumber] >= 6) {
        cssLib = [[WebResourceManager sharedManager] resourceForName:@"article.css"];
    }
    else {
        cssLib = [[WebResourceManager sharedManager] resourceForName:@"article_for_ios5.css"];
    }
    
    if(!isEmptyString(cssLib))
    {
        [head appendFormat:@"<style>%@</style>", cssLib];
    }
    if (![SSCommon isPadDevice]) {
        NSMutableString * widthStyle = [NSMutableString stringWithFormat:@"<style>html,body{ width:%ipx;  overflow: hidden}</style>", (int)SSWidth(self)];
        [head appendString:widthStyle];
    }
    [head appendString:@"</head>"];
    
    NSMutableString *content = [NSMutableString stringWithString:head];
    NSString *articleContent = isEmptyString(self.article.content) ? @"" : self.article.content;

    NSString *fontSizeType = [NewsUserSettingManager settedFontShortString];
    //为了让加载html的时候就可以直接显示夜间模式， 防止刚进入详情页会白一下
    if ([[SSResourceManager shareBundle] currentMode] == SSThemeModeDay) {
        [content appendFormat:@"<body class=\"font_%@\">%@", fontSizeType, articleContent];
    }
    else {
        [content appendFormat:@"<body class=\"night font_%@\">%@", fontSizeType, articleContent];
    }
    
    
    NSString * filePath = [[[NSBundle mainBundle] bundleURL] absoluteString];
    filePath = [NSString stringWithFormat:@"%@#tt_image=%@", filePath, autoLoad];
    
    
    filePath = [NSString stringWithFormat:@"%@&tt_font=%@", filePath, fontSizeType];
    
    BOOL isDayModel = [[SSResourceManager shareBundle] currentMode] == SSThemeModeDay;
    filePath = [NSString stringWithFormat:@"%@&tt_daymode=%i", filePath, isDayModel ? 1 : 0];
    
    NSURL * bURL = [SSCommon URLWithURLString:filePath];
    [self webviewLoadHtml:content baseURL:bURL];
    [self updateFontSizeForWebView:webView];
    
    
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//       [webView stringByEvaluatingJavaScriptFromString:@"function bridge_cb(o) {    alert(JSON.stringify(o))    }; window.ToutiaoJSBridge.call(\"isAppInstalled\", { \"pkg_name\": \"com.ss.android.essay.joke\" }, bridge_cb);"];
//    });
    
    
    webView.scalesPageToFit = NO;

    [self updateArticleReadStatus];
    [_eventTracker recordStayTimerForArticle:self.article];
}

- (void)updateArticleReadStatus
{
    self.article.hasRead = [NSNumber numberWithBool:YES];
    [[SSModelManager sharedManager] save:nil];
}

- (void)showClientEscapeButton:(BOOL)show
{
    if (show) {
        [_titleBarView showClientEscapeButton:YES];
        [_titleBarView.clientEscapeButton addTarget:self action:@selector(titleBarButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    else {
        [_titleBarView showClientEscapeButton:NO];
    }

}

- (void)loadWebTypeContent
{
    if (![self isWebContentType]) {
        return;
    }
    _webviewInsertedInformationJS = NO;
    if (!_clientEscapeManager && [ArticleClientEscapeManager needShowClientEscapseButton:_article]) {//如果不是客户端转码， 则不需要生成
        self.clientEscapeManager = [[[ArticleClientEscapeManager alloc] init] autorelease];
        [_clientEscapeManager addObserver:self forKeyPath:@"mainPageIsClientEscape" options:NSKeyValueObservingOptionNew context:NULL];
    }
    _clientEscapeManager.userClickedWebViewLink = NO;
    
    if([self isWebContentType] && [_article.articleSubType intValue] != ArticleSubTypeCooperationWap)
    {
        [self.webView showCoverIfNeed];
    }
    
    //此处判断是否需要看是客户端转码按钮
    if ([ArticleClientEscapeManager needShowClientEscapseButton:_article] && !_clientEscapeManager.tryClientEscapeFailed) {
        [self showClientEscapeButton:YES];
    }
    else {
        [self showClientEscapeButton:NO];
    }
    
    [_titleBarView refreshAddressTitle:_article.displayTitle addressURL:_article.displayURL];
    
    [self loadWebTypeContentUseClientEscape];
    [self loadWebTypeContentDirect];
    [_titleBarView setClientEscapeButtonEnabe:NO];
    
    if (!_clientEscapeManager.showedAutoClientEscapeTipAlert &&
        _clientEscapeManager.clientEscapeButtonStatus != ArticleClientEscapeButtonStatusNeverClicked &&
        _clientEscapeManager.tryClientEscapeFailed) {
        
        [[SSActivityIndicatorView sharedView] showInView:webView message:SSLocalizedString(@"优化失败", nil)];
    }

}

//客户端转码方式加载wap类型
- (void)loadWebTypeContentUseClientEscape
{
    if (![self isWebContentType]) {
        return;
    }
    
    if (![self needClientEscape]){
        return;
    }
    
    webView.scalesPageToFit = YES;
    
    [webView stopLoading];
    _hasLoaded = NO;
    
    [_clientEscapeManager requestForURLStr:_article.articleURLString insertText:_article.tcHeadText finishBlock:^(NSString *html, NSError *error) {
        if (error) {
            _clientEscapeManager.mainPageIsClientEscape = NO;
            _clientEscapeManager.tryClientEscapeFailed = YES;
            [self loadWebTypeContent];
        }
        else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [webView loadHTMLString:html baseURL:[SSCommon URLWithURLString:[self baseURLStringWithRandomParam:YES]]];
                _clientEscapeManager.mainPageIsClientEscape = YES;
                _hasLoaded = YES;
                [self removeLoadingView];
                [self insertJSContext:[_natantView getFetchedJSContextIfHave]];
            });
        }
    }];
    
    [self updateArticleReadStatus];
    [_eventTracker recordStayTimerForArticle:self.article];
    
}

- (NSString *)webTypeLoadURLString
{
    NSMutableString * webURLString = [NSMutableString stringWithString:_article.articleURLString];
    
    //处理合作网站
    if ([_article.articleSubType integerValue] == ArticleSubTypeCooperationWap) {
        webURLString = [NSMutableString stringWithString: [NewsDetailLogicManager changegCooperationWapURL:_article.articleURLString]];
    }

    return webURLString;
}

- (NSString *)baseURLStringWithRandomParam:(BOOL)hasRandom
{
    NSMutableString * urlString = [NSMutableString stringWithString:_article.articleURLString];
    NSRange qmRange = [urlString rangeOfString:@"?"];
    if (qmRange.location != NSNotFound) {
        urlString = [NSMutableString stringWithString:[urlString substringToIndex:qmRange.location]];
    }
    if (hasRandom) {
        [urlString appendFormat:@"?%@=%li", kRandomParameter,random()];
    }
    return urlString;
}

//用webview直接加载wap类型
- (void)loadWebTypeContentDirect
{
    if (![self isWebContentType]) {
        return;
    }
    
    if ([self needClientEscape]){
        return;
    }

    if (isEmptyString(_article.articleURLString)) {
        
        return;
    }

    NSString * webURLString = [self webTypeLoadURLString];
    NSURL * webURL = [SSCommon URLWithURLString:webURLString];
    NSMutableURLRequest * urlRequest = nil;
    if (SSNetworkConnected()) {
        urlRequest = (NSMutableURLRequest*)[SSWebViewUtil requestWithURL:webURL];
    }
    else {
        urlRequest = (NSMutableURLRequest*)[SSWebViewUtil requestWithURL:webURL cachePolicy:NSURLRequestReturnCacheDataElseLoad timeoutInterval:60];
    }
    
    //判断是否是最近加载的URL
    if (!isEmptyString(_latestWebViewRequestURL) && [_latestWebViewRequestURL isEqualToString:[[urlRequest URL] absoluteString]]) {
        [self stopLoadingIndicatorViewAnimation];
        return;
    }
    [webView stopLoading];
    _hasLoaded = NO;

    
    [self webviewLoadRequest:urlRequest];
    
    webView.scalesPageToFit = YES;

    [self updateArticleReadStatus];
    [_eventTracker recordStayTimerForArticle:self.article];
    
    [self removeLoadingView];
    
    _clientEscapeManager.mainPageIsClientEscape = NO;
}


- (void)webviewLoadRequest:(NSURLRequest *)request
{
//    self.latestWebViewRequestURL = [[request URL] absoluteString];
    [webView loadRequest:request];
}

- (void)webviewLoadHtml:(NSString *)content baseURL:(NSURL *)URL
{
    [webView loadHTMLString:content baseURL:URL];
}



- (void)recordArticleTopicImpression
{
    if ([_article.uniqueID longLongValue] == 0) {
        return;
    }
    
    NSString * infos = [webView stringByEvaluatingJavaScriptFromString:@"reportElementOffset()"];
    NSArray * ary = [infos JSONValue];
    if ([ary isKindOfClass:[NSArray class]] && [ary count] > 0) {
        for (NSDictionary * dict in ary) {
            if ([dict isKindOfClass:[NSDictionary class]] && [[dict allKeys] containsObject:@"groupid"] && [[dict allKeys] containsObject:@"top"]) {
                int top = (int)[[dict objectForKey:@"top"] longLongValue];
                if (top < webView.userScrolledMaxY) {
                    NSString * unitCategoryID = [NSString stringWithFormat:@"%@%@",kImpressionSubjectKeyNamePrefix, self.article.uniqueID];
                    NSString * gid = [NSString stringWithFormat:@"%@", [dict objectForKey:@"groupid"]];
                    NSString *itemID = [NSString stringWithFormat:@"%@", [dict objectForKey:@"item_id"]];
                    NSString *aggrType = [NSString stringWithFormat:@"%@", [dict objectForKey:@"aggr_type"]];
                    TTGroupModel *model = [[[TTGroupModel alloc] initWithGroupID:gid itemID:itemID aggrType:[aggrType integerValue]] autorelease];
                    [[SSImpressionManager shareInstance] recordSubjectImpressionSubjectGroupID:unitCategoryID groupID:model.impressionDescription status:SSImpressionStatusRecording userInfo:nil];
                }
            }
        }
    }
    
}

- (void)closeNatantButtonClicked:(id)sender
{
    if (_natantView.statusType == NewsDetailSupernatantStatusTypeButtonOpen) {
        [self clickChangeNatantStatusButton];
    }
}

- (void)goBack:(id)sender
{
    if(sender)
    {
        ssTrackEvent(@"detail", @"back_button");
    }
    
    UIViewController *controller = [SSCommon topViewControllerFor:self];
    [controller.navigationController popViewControllerAnimated:YES];
}


- (void)displayMessage:(NSString*)msg
{
    [[SSActivityIndicatorView sharedView] showMessage:msg];
}

- (void)displayFailMessage:(NSString*)msg
{
    if(isEmptyString(msg)) return;
    [[SSActivityIndicatorView sharedView] showMessage:msg];
}


#pragma mark -- Notification response

- (void)menuControllerDidHideMenuNotification:(NSNotification *)notification
{
    [self refreshWebviewMenu];
}

- (void)wvNatantSwitchChanged:(NSNotification *)notification
{
    [self refreshNatantLevel];
}

- (void)fontChanged:(NSNotification*)notification
{
    BOOL _couldChangeNatant = webView.couldSetContentInset;
    
    webView.couldSetContentInset = NO;
    webView.scrollView.contentInset = UIEdgeInsetsZero;
    webView.couldSetContentInset = _couldChangeNatant;
    [webView reload];
    [self loadAllTypeContent];
    double delayInSeconds = .5f;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [webView reloadNatant];
    });
} 


- (void)applicationWillEnterForeground:(NSNotification *)notification
{
    [self tryLoadContent];
}

- (void)applicationDidEnterBackground:(NSNotification *)notification
{
    // 如果加载期间切换到后台，则放弃这一次统计
    self.startLoadDate = nil;
    dispatch_async(dispatch_get_main_queue(), ^{
        [_eventTracker trySendStayTrackForArticle:self.article];
    });
    
}

- (void)contentLoadFinished:(NSNotification*)notification
{
    Article *newArticle = [[notification userInfo] objectForKey:@"data"];
    
    if(self.article == nil || self.article.managedObjectContext == nil) // don't have valid article
    {
        return ;
    }
    
    if(newArticle && newArticle.managedObjectContext == nil) // don't have valid new article
    {
        return;
    }
    
    if(self.article != nil && newArticle != nil && ![[self.article.uniqueID stringValue] isEqualToString:[newArticle.uniqueID stringValue]])
    {
        return;
    }
    
    NSError *error = [[notification userInfo] objectForKey:@"error"];
    if(error == nil)
    {
        if(!_hasLoaded)
        {
            self.article = newArticle;
            [self loadAllTypeContent];
            _hasLoaded = YES;
        }
        [self removeRetryButton];
        [self removeLoadingView];
    }
    else if(![self.article isContentFetched])
    {
        if([error.domain isEqualToString:kCommonErrorDomain])
        {
            NSString *msg = [[error userInfo] objectForKey:kErrorDisplayMessageKey];
            [self showRetryViewIfNeed:msg];
        }
        else if (!SSNetworkConnected()) {
            [self showRetryViewIfNeed:sNoNetworkConnectTip];
        }
        else {
            [self showRetryViewIfNeed:nil];
        }
    }
    [self delegateCurrentArticleIfNeed];
}

- (BOOL)needLoadComment
{
    return _newsDetailType == NewsDetailTypeNormal;
}

- (void)showBottomCommentIfNeed
{
    if (_beginShowComment) {
//        [_natantView scrollToTopCommentAnimated:NO];
        //点列表页中放出的热门评论，进入详情页，加载文章并弹出确认对话框：查看热门评论需开启互动浮层，现在开启？不开启，开启（不开启在左，开启在右，安卓根据系统决定位置），点击开启后，打开浮层显示并定位到热门评论
        _beginShowComment = NO;
        
        if (_newsDetailNatantLevel == NewsDetailNatantLevelClose) {
            if ([SSCommonLogic ttAlertControllerEnabled]) {
                TTThemedAlertController *alert = [[[TTThemedAlertController alloc] initWithTitle:nil message:SSLocalizedString(@"查看热门评论需开启互动浮层，现在开启？", nil) preferredType:TTThemedAlertControllerTypeAlert] autorelease];
                [alert addActionWithTitle:SSLocalizedString(@"不开启", nil) actionType:TTThemedAlertActionTypeNormal actionBlock:nil];
                [alert addActionWithTitle:SSLocalizedString(@"开启", nil) actionType:TTThemedAlertActionTypeNormal actionBlock:^{
                    [NewsDetailLogicManager setNatantInteractionEnable:YES];
                    [self openNatantShowComment:NewsDetailOpenNatantShowTypeHotComment animated:YES];
                    ssTrackEvent(@"more_tab", @"interactive_on");
                }];
                [alert showFrom:self.viewController animated:YES];
            }
            else {
                UIAlertView * alertView = [[[UIAlertView alloc] initWithTitle:nil message:SSLocalizedString(@"查看热门评论需开启互动浮层，现在开启？", nil) delegate:self cancelButtonTitle:nil otherButtonTitles:SSLocalizedString(@"不开启", nil), SSLocalizedString(@"开启", nil), nil] autorelease];
                alertView.tag = kEnableNatantSwitchAlertViewWhenEnterShowHotCommentTag;
                [alertView show];
            }
            return;
        }
        _natantView.needScrollToHotCommentWhenLoadDataFinish = YES;
        [self openNatantShowComment:NewsDetailOpenNatantShowTypeDigBuryButtonTop animated:NO];
        
    }
}

#pragma mark -- SSActivityViewDelegate

- (void)activityView:(SSActivityView *)view didCompleteByItemType:(SSActivityType)itemType
{
    self.activityType = itemType;
    if (view == _phoneShareView) {
        NSString *groupId = [NSString stringWithFormat:@"%lld", [self.article.uniqueID longLongValue]];
        [_activityActionManager performActivityActionByType:itemType inViewController:[SSCommon topViewControllerFor:self] sourceObjectType:SSShareSourceObjectTypeArticle uniqueId:groupId];
        self.phoneShareView = nil;
    }
}

#pragma mark -- SSActivityPopoverControllerDelegate

- (void)activityPopoverController:(SSActivityPopoverController *)controller didCompleteByItemType:(SSActivityType)itemType
{
    self.activityType = itemType;
    if (controller == _padShareController) {
        NSString *groupId = [NSString stringWithFormat:@"%lld", [self.article.uniqueID longLongValue]];
        [_activityActionManager performActivityActionByType:itemType inViewController:[SSCommon topViewControllerFor:self] sourceObjectType:SSShareSourceObjectTypeArticle uniqueId:groupId];
        // Ugly code (由于在没登陆状态下，弹出的登陆界面view被_padShareController的activityController拥有（被present），因此不能直接dismiss)
        if ([[AccountManager sharedManager] isLogin])
        {
            [_padShareController dismissPopoverAnimated:YES];
            self.padShareController = nil;
        }
    }
}

- (void)systemShareUseActivityController
{
    [_activityActionManager clearCondition];
    if (!_activityActionManager) {
        self.activityActionManager = [[[SSActivityShareManager alloc] init] autorelease];
    }
    
    NSMutableArray * activityItems = [ArticleShareManager shareActivityManager:_activityActionManager setArticleCondition:_article adID:_eventTracker.adID];
    
    if (![SSCommon isPadDevice]) {
        self.phoneShareView = [[[SSActivityView alloc] init] autorelease];
        _phoneShareView.delegate = self;
        _phoneShareView.activityItems = activityItems;
        [_phoneShareView showOnWindow:self.window];
    }
    else {
        self.padShareController = [[[SSActivityPopoverController alloc] initWithActivityItems:activityItems] autorelease];
        CGRect showRect = [self convertRect:_toolBarView.shareButton.frame fromView:_toolBarView];
        [_padShareController presentPopoverFromRect:showRect inView:self permittedArrowDirections:UIPopoverArrowDirectionDown animated:YES];
        _padShareController.ssDelegate = self;
    }
}


- (BOOL)canBecomeFirstResponder
{
    return YES;
}

- (void)reportItemInvokeByLongPress
{
    [self reportArticle];
    ssTrackEvent(@"detail", @"text_menu_report");
}

- (void)reportArticle
{
    NSString * selectedText = [self webView:self.webView stringByEvaluatingJavaScriptFromString:@"window.getSelection().toString()"];
    NSString * html = [self reportHtmlForWebContentIfNeed];
    if ([SSCommon isPadDevice]) {
        ArticlePadReportView * reportView = [[ArticlePadReportView alloc] initWithGroupModel:_article.groupModel html:html];
        [reportView showOnViewController:[SSCommon topViewControllerFor:self]];
        [reportView release];

    }
    else {
        ArticleReportViewController * reportViewController = [[ArticleReportViewController alloc] initWithGroupModel:_article.groupModel selectedText:selectedText html:html viewStyle:ArticleReportViewNormalStyle reportType:ArticleReportArticle];
        [[SSCommon topViewControllerFor:self] presentViewController:[[[TTNavigationController alloc] initWithRootViewController: reportViewController] autorelease] animated:YES completion:NULL];
        [reportViewController release];
    }
}

- (void)toolbarReportItemClicked
{
    ssTrackEvent(@"detail", @"report_button");
    ssTrackEvent(@"detail", @"report");
    [self reportArticle];
}

#pragma mark -- ArticleActionAlertViewDelegate

- (void)articleActionAlertView:(ArticleActionAlertView *)alertView buttonClickedForTag:(NSUInteger)itag
{
    [alertView dismissView];
    
    if ([alertView.infoTag isEqualToString:@"phoneSimpleTypeShare"]){
        if (itag == 0) {
            [self openUseSafari];
        }
        else if (itag == 1) {
            [self copyText];
        }
    }
    
}

- (void)authorityLoginSuccessInvokeMethod:(NSString *)invokeKey
{
}

- (void)applicationStatusBarOrientationDidChanged
{
    [_padShareController dismissPopoverAnimated:YES];
}

- (void)detailViewLayoutSubView
{
    [super detailViewLayoutSubView];
    
    _titleBarView.frame = [self frameForTitleBar];
    
    _padProfileView.frame = frameForPadFlipView();

    if (fontSelectView) {
        fontSelectView.frame = self.bounds;
    }
    _toolBarView.frame = [self frameForToolBar];
    webView.frame = [self frameForWebView];
    _natantView.frame = [self frameForNatantView];
    [_natantView refreshFrame];
    [self resetNatant];
    
}

#pragma mark -- calculate frame

- (CGFloat)normalOriginYForNatantView
{
    return webView.scrollView.contentSize.height;
}

- (CGRect)frameForNatantView
{
    CGRect rect = CGRectZero;
    rect.size.height = CGRectGetMinY(_toolBarView.frame) - CGRectGetMaxY(_titleBarView.frame);
    rect.size.width = CGRectGetWidth(self.webView.frame);
    if (_natantView.superview == webView.scrollView || !_natantView.superview) {
        rect.origin.y = [self normalOriginYForNatantView];
    }
    else {
        rect.origin.x = CGRectGetMinX(webView.frame);

        if ([self isNatantViewOnOpenStatus]) {
            rect.origin.y = CGRectGetMaxY(_titleBarView.frame);
            
        }
        else {
            rect.origin.y = CGRectGetMinY(_toolBarView.frame);
        }
    }
    return rect;
}


- (CGRect)frameForCommentAndInputView
{
    float offsetY = 0;
    CGRect detailViewFrame = CGRectZero;
    if (UIInterfaceOrientationIsPortrait([UIApplication currentUIOrientation])) {
        detailViewFrame = CGRectMake([UIScreen shortScreenSideLength] - PadFlipViewWidth, offsetY, PadFlipViewWidth, [UIScreen largeScreenSideLengthWithoutStatusBarHeight] - offsetY);
    }
    else {
        detailViewFrame = CGRectMake([UIScreen largeScreenSideLength] - PadFlipViewWidth, offsetY, PadFlipViewWidth, [UIScreen shortScreenSideLengthWithoutStatusBarHeight] - offsetY);
    }
    return detailViewFrame;
}

- (CGRect)frameForWebView
{
    float height = self.frame.size.height - SSHeight(_toolBarView) - SSHeight(_titleBarView);
    CGRect frame = CGRectMake(0, SSHeight(_titleBarView), SSWidth(self), height);
    return frame;
}

- (CGRect)frameForPadExternalLinkView
{
    float offsetY = 0;
    CGRect padExternalLinkViewFrame = CGRectZero;
    padExternalLinkViewFrame = CGRectMake(0, offsetY, self.frame.size.width, self.frame.size.height - offsetY);
    return padExternalLinkViewFrame;
}


#pragma mark -- detail comment action

- (void)refreshWebviewMenu
{
    UIMenuItem * shareItem = [[[UIMenuItem alloc] initWithTitle:SSLocalizedString(@"转发", nil) action:@selector(commentSelected)] autorelease];
    UIMenuItem * reportItem = [[[UIMenuItem alloc] initWithTitle:SSLocalizedString(@"举报", nil) action:@selector(reportItemInvokeByLongPress)] autorelease];
    UIMenuItem * detailCustomCopyItem = [[[UIMenuItem alloc] initWithTitle:SSLocalizedString(@"拷贝", nil) action:@selector(customCopy)] autorelease];
    if ([SSCommon OSVersionNumber] < SSOSVersion6) {
        [[UIMenuController sharedMenuController] setMenuItems:[NSArray arrayWithObjects:detailCustomCopyItem, shareItem, reportItem, nil]];
    }
    else {
        [[UIMenuController sharedMenuController] setMenuItems:[NSArray arrayWithObjects:shareItem, reportItem, nil]];
    }
}

//评论选中的文字
- (void)commentSelected
{
    NSString* selection = [self webView:self.webView stringByEvaluatingJavaScriptFromString:@"window.getSelection().toString()"];

    NSString * repostText = @"//";
    if ([selection length] > 0) {
        repostText = [NSString stringWithFormat:@"//\"%@\"", selection];
    }
    
    [self openCommentWithText:repostText];
    ssTrackEvent(@"detail", @"text_menu_forward");
}

- (void)customCopy
{
    //用于IOS5
    NSString* selection = [self webView:self.webView stringByEvaluatingJavaScriptFromString:@"window.getSelection().toString()"];
    [[SSShareManager shareInstance] copyText:selection];
}



- (void)openCommentWithText:(NSString *)defaultText
{
    if ([_article.banComment boolValue]) {
        [[SSActivityIndicatorView sharedView] showMessage:sBannCommentTip];
        return;
    }
    
    NSMutableDictionary * condition = [NSMutableDictionary dictionaryWithCapacity:10];
    [condition setValue:self.article.groupModel forKey:kQuickInputViewConditionGroupModel];
    [condition  setValue:defaultText forKey:kQuickInputViewConditionInputViewText];
    [condition setValue:[NSNumber numberWithBool:[_article.hasImage boolValue]] forKey:kQuickInputViewConditionHasImageKey];
    [condition setValue:_eventTracker.adID forKey:kQuickInputViewConditionADIDKey];

    ExploreWriteCommentView *commentView = [[[ExploreWriteCommentView alloc] initWithFrame:CGRectZero] autorelease];
    commentView.delegate = self;
    [commentView showInView:self animated:YES];
    [commentView setCondition:condition];
}

- (void)delegateCurrentArticleIfNeed
{
    if ([_article.articleDeleted boolValue] && _article != nil && _article.uniqueID) {
        
        _article.content = SSLocalizedString(@"该内容已删除", nil);
        [[SSModelManager sharedManager] save:nil];
        
        [webView loadHTMLString:_article.content baseURL:nil];
        
        //需要先发出notification， 再删除数据库
        if (_orderedData) {
            NSDictionary * userInfo = [NSDictionary dictionaryWithObjectsAndKeys:_orderedData, kExploreMixListDeleteItemKey, nil];
            [[NSNotificationCenter defaultCenter] postNotificationName:kExploreMixListItemDeleteNotification object:nil userInfo:userInfo];
        }
        self.orderedData = nil;
        NSPredicate * predicate = [NSPredicate predicateWithFormat:@"originalData.uniqueID = %@", _article.uniqueID];
        [[SSModelManager sharedManager] removeEntitiesWithPredicate:predicate entityName:[ExploreOrderedData entityName] error:nil];
    }
}

- (void)showFontSelectView
{
    if (!fontSelectView) {
        self.fontSelectView = [[[PadFontSelectContainerView alloc] initWithFrame:self.bounds] autorelease];
    }
    [fontSelectView showInView:self];
}

#pragma mark -- Show UIWebView Image
//webview 显示已经缓存的图片， 或者下载新的图片
//showOriginImgForce: 如果为 true， 强制显示原图， 没有则下载
- (void)webViewShowImageIfCachedOrDownload:(BOOL)forseShowOriginImg
{
    JSMetaInsertImageType showImageType = [self loadImageType:forseShowOriginImg];
    NSInteger listCount = MIN([_largeImgModels count], [_thumbImgModels count]);
    
    NSMutableArray * needDownloadModels = [NSMutableArray arrayWithCapacity:10];
    
    for (int i = 0; i < listCount; i ++) {
        
        SSImageInfosModel * largeModel = [_largeImgModels objectAtIndex:i];
        UIImage * largeImage = [SSWebImageManager imageForModel:largeModel];
        BOOL largeImageCached =  (largeImage != nil);
        
        if (showImageType == JSMetaInsertImageTypeOrigin || largeImageCached) {
            if (largeImageCached) {
                [self webViewShowImageForModel:largeModel imageIndex:i imageType:JSMetaInsertImageTypeOrigin];
            }
            else if (showImageType == JSMetaInsertImageTypeOrigin){
//                [self downloadImageModel:largeModel index:i insertTop:NO];
                [needDownloadModels addObject:largeModel];
            }
        }
        else if (showImageType == JSMetaInsertImageTypeThumb) {
            
            SSImageInfosModel * thumbModel = [_thumbImgModels objectAtIndex:i];
            UIImage * thumbImage = [SSWebImageManager imageForModel:largeModel];
            BOOL thumbImageCached =  (thumbImage != nil);

            if (thumbImageCached) {
                [self webViewShowImageForModel:thumbModel imageIndex:i imageType:JSMetaInsertImageTypeThumb];
            }
            else {
                [needDownloadModels addObject:thumbModel];
//                [self downloadImageModel:thumbModel index:i insertTop:NO];
            }
        }
    }
    
    if ([needDownloadModels count] > 0) {
        [self downloadImageModels:needDownloadModels insertTop:YES];
    }
    
    
}

- (void)webViewShowThumbImage
{
    [_thumbImgModels enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop){
        
        [self webViewShowThumbImageAtIndex:idx showOriginIfCached:NO];
    }];
}

- (void)webViewShowThumbImageAtIndex:(NSInteger)index showOriginIfCached:(BOOL)showOriginIfCached
{
    UIImage * largeImg = nil;
    if (showOriginIfCached && index < _largeImgModels.count) {
        largeImg = [SSWebImageManager imageForModel:_largeImgModels[index]];
    }
    
    if(largeImg)
    {
        [self webViewShowImageForModel:_largeImgModels[index] imageIndex:index imageType:JSMetaInsertImageTypeOrigin];
    }
    else if(index < _thumbImgModels.count)
    {
        SSImageInfosModel *imageModel = _thumbImgModels[index];
        
        UIImage * middleImg = [SSWebImageManager imageForModel:_largeImgModels[index]];
        
        if (middleImg)
        {
            [self webViewShowImageForModel:imageModel imageIndex:index imageType:JSMetaInsertImageTypeThumb];
        }
        else
        {
            [self downloadImageModel:imageModel index:index insertTop:YES];
        }
    }
}

- (void)webViewShowOfflineImage
{
    NSUInteger count = MAX([_largeImgModels count], [_thumbImgModels count]);
    for(int idx = 0; idx < count; idx ++)
    {
        [self webViewShowOfflineImageAtIndex:idx];
    }
}

- (void)webViewShowOfflineImageAtIndex:(int)idx
{
    if(idx < _largeImgModels.count)
    {
        SSImageInfosModel * largeModel = [_largeImgModels objectAtIndex:idx];
        UIImage * largeImg = [SSWebImageManager imageForModel:largeModel];
        if(largeImg)
        {
            [self webViewShowImageForModel:largeModel imageIndex:idx imageType:JSMetaInsertImageTypeOrigin];
        }
        else if(idx < _thumbImgModels.count)
        {
            SSImageInfosModel * thumbModel = [_thumbImgModels objectAtIndex:idx];
            UIImage * thumbImg = [SSWebImageManager imageForModel:thumbModel];
            if(thumbImg)
            {
                [self webViewShowImageForModel:thumbModel imageIndex:idx imageType:JSMetaInsertImageTypeThumb];
            }
        }
    }
}

- (NSString *)loadImageJSStringKeyForType:(JSMetaInsertImageType)type
{
    NSString * keyString = nil;
    switch (type) {
        case JSMetaInsertImageTypeThumb:
            keyString = kJsMetaImageThumbKey;
            break;
        case JSMetaInsertImageTypeOrigin:
            keyString = kJsMetaImageOriginKey;
            break;
        default:
            keyString = kJsMetaImageNoneKey;
            break;
    }
    return keyString;
}

- (JSMetaInsertImageType)loadImageType:(BOOL)forseShowOriginImg
{
    NetworkTrafficSetting settingType = [SSUserSettingManager networkTrafficSetting];
    BOOL showOriginForce = forseShowOriginImg || SSNetworkWifiConnected() || (settingType == NetworkTrafficOptimum);
    if (showOriginForce) {
        return JSMetaInsertImageTypeOrigin;
    }
    else if (settingType == NetworkTrafficMedium) {
        return JSMetaInsertImageTypeThumb;
    }
    else {
        return JSMetaInsertImageTypeNone;
    }
}

- (void)downloadImageModels:(NSArray *)models insertTop:(BOOL)insert
{
    [_detailImageDownloadManager fetchImageWithModels:models insertTop:insert];
}

- (void)downloadImageModel:(SSImageInfosModel *)model index:(NSInteger)index insertTop:(BOOL)insert
{
    [_detailImageDownloadManager fetchImageWithModel:model insertTop:insert];
}

////调用js显示model的方法
- (void)webViewShowImageForModel:(SSImageInfosModel *)model imageIndex:(NSInteger)index imageType:(JSMetaInsertImageType)type
{
    if (model == nil) {
        return;
    }
    NSString * insertTypeStr = [self loadImageJSStringKeyForType:type];

    NSString * path = [SSWebImageManager cachePathForModel:model];
    if (isEmptyString(path)) {
        return;
    }
    NSString * jsMethod = [NSString stringWithFormat:@"appendLocalImage(%ld,'file://%@','%@')", (long)index, path, insertTypeStr];
    [self webView:webView stringByEvaluatingJavaScriptFromString:jsMethod];
}

- (void)openNatantToRecentComment
{
    if ([self isNatantViewOnOpenStatus]) {
        [_natantView scrollToRecentCommentAnimated:YES];
    }
    else {
        [self openNatantShowComment:NewsDetailOpenNatantShowTypeRecentComment animated:YES];
    }
}

#pragma mark -- ExploreShareViewControllerDelegate
// Changed by luohuaqing
- (BOOL) commentCouldSendMessage:(NSObject *) commentInfo {
    if (_newsDetailNatantLevel == NewsDetailNatantLevelClose) {
        if ([SSCommonLogic ttAlertControllerEnabled]) {
            TTThemedAlertController *alert = [[[TTThemedAlertController alloc] initWithTitle:nil message:@"此功能需开启互动插件，现在开启？" preferredType:TTThemedAlertControllerTypeAlert] autorelease];
            [alert addActionWithTitle:SSLocalizedString(@"不开启", nil) actionType:TTThemedAlertActionTypeNormal actionBlock:nil];
            [alert addActionWithTitle:SSLocalizedString(@"开启", nil) actionType:TTThemedAlertActionTypeNormal actionBlock:^{
                [NewsDetailLogicManager setNatantInteractionEnable:YES];
                [_phoneShareViewController.commentInputView sendButtonClicked];
                ssTrackEvent(@"more_tab", @"interactive_on");
            }];
            [alert showFrom:self.viewController animated:YES];
        }
        else {
            UIAlertView * alertView = [[[UIAlertView alloc] initWithTitle:nil message:@"此功能需开启互动插件，现在开启？" delegate:self cancelButtonTitle:nil otherButtonTitles:SSLocalizedString(@"不开启", nil), SSLocalizedString(@"开启", nil), nil] autorelease];
            alertView.tag = kEnableNatantSwitchAlertViewWhenWillSendCommentTag;
            [alertView show];
        }
        return NO;
    }
    else {
        return YES;
    }
}

- (void) commentDidCancelled:(NSObject *) commentInfo {
    //// TODO:用户取消分享
}

- (void) commentResponsedReceived:(NSNotification *) notification {
    if(![notification.userInfo objectForKey:@"error"])  {
        self.article.commentCount = [NSNumber numberWithInt:[self.article.commentCount intValue] + 1];
        NSDictionary * data = [[notification userInfo] objectForKey:@"data"];
        [_natantView.commentView.commentManager insertCommentDictToTop:data];
        
        [self openNatantToRecentComment];
    }
}


- (void)commentInputViewControllerCancelled:(ExploreShareViewController *) controller {
    [self commentDidCancelled:controller];
}

- (void)commentInputViewController:(ExploreShareViewController *)controller responsedReceived:(NSNotification*)notification {
    if (_phoneShareViewController == controller) {
        
        [_phoneShareViewController dismissViewControllerAnimated:YES completion:NULL];
        
        _phoneShareViewController.commentInputView.delegate = nil;
        _phoneShareViewController.commentInputView = nil;
        
        _phoneShareViewController.delegate = nil;
        _phoneShareViewController = nil;
        [self commentResponsedReceived:notification];
    }
    
}

- (BOOL)commentInputViewControllerWillSendMsg:(ExploreShareViewController *)controller {
    return [self commentCouldSendMessage:controller];
}


#pragma mark -- ExploreWriteComentViewDelegate
- (void)commentViewCancelled:(ExploreWriteCommentView *) commentView {
    [self commentDidCancelled:commentView];
}

- (void)commentView:(ExploreWriteCommentView *) commentView responsedReceived:(NSNotification*)notification {
    [commentView dismissAnimated:YES];
    commentView.delegate = nil;
    [self commentResponsedReceived:notification];
}

- (BOOL)commentViewWillSendMsg:(ExploreWriteCommentView *) commentView {
    return [self commentCouldSendMessage:commentView];
}

#pragma mark -- UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == kEnableNatantSwitchAlertViewWhenClickCommentButtonTag) {
        if (buttonIndex == 1) {
            [NewsDetailLogicManager setNatantInteractionEnable:YES];
            [self clickChangeNatantStatusButton];
            ssTrackEvent(@"more_tab", @"interactive_on");
        }
    }
    else if (alertView.tag == kEnableNatantSwitchAlertViewWhenWillSendCommentTag) {
        if (buttonIndex == 1) {
            [NewsDetailLogicManager setNatantInteractionEnable:YES];
            [_phoneShareViewController.commentInputView sendButtonClicked];
            ssTrackEvent(@"more_tab", @"interactive_on");
        }
    }
    else if (alertView.tag == kEnablePadNatantSwitchAlertViewWhenWillSendCommentTag) {
        if (buttonIndex == 1) {
            [NewsDetailLogicManager setNatantInteractionEnable:YES];
            // [padCommentInputView sendButtonClicked];
            ssTrackEvent(@"more_tab", @"interactive_on");
        }
    }
    else if (alertView.tag == kEnableNatantSwitchAlertViewWhenEnterShowHotCommentTag) {
        if (buttonIndex == 1) {
            [NewsDetailLogicManager setNatantInteractionEnable:YES];
            [self openNatantShowComment:NewsDetailOpenNatantShowTypeHotComment animated:YES];
            ssTrackEvent(@"more_tab", @"interactive_on");
        }
    }
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == kChangeNetworkTrafficSettingTag) {
        if (buttonIndex != alertView.cancelButtonIndex) {
            [SSUserSettingManager setNetworkTrafficSetting:NetworkTrafficOptimum];
        }
    }
}




- (void)refreshNatantStatus
{
//    BOOL needSendDetailShowEvent = NO;
    
    if (_natantView.statusType != NewsDetailSupernatantStatusTypeButtonOpen) {
        CGFloat beginShowOriginY = [self originYForWebViewBeginShowNatant];
        
        if (webView.scrollView.contentOffset.y >= beginShowOriginY) {
            if (webView.scrollView.contentOffset.y >= (beginShowOriginY + webView.frame.size.height)) {
                _natantView.statusType = NewsDetailSupernatantStatusTypeFullShow;
//                needSendDetailShowEvent = YES;
            }
            else {
                _natantView.statusType = NewsDetailSupernatantStatusTypeShowPart;
                if (webView.scrollView.contentOffset.y >= beginShowOriginY + detailADViewOriginY) {
//                    needSendDetailShowEvent = YES;
                }
            }
        }
        else {
            _natantView.statusType = NewsDetailSupernatantStatusTypeFullClose;
        }
    }
    else {
//        needSendDetailShowEvent = YES;
    }
    [_natantView refreshCommentViewStatus];

//    if (needSendDetailShowEvent) {
//        [_natantView sendNatantADShowTrackIfNeed];
//    }

}

- (BOOL)isNatantViewOnOpenLevel
{
    return (_newsDetailNatantLevel == NewsDetailNatantLevelOpen);
}

- (BOOL)isNatantViewOnOpenStatus
{
    return (_natantView.statusType == NewsDetailSupernatantStatusTypeFullShow || _natantView.statusType == NewsDetailSupernatantStatusTypeButtonOpen);
}

- (void)clickChangeNatantStatusButton
{
    if ([self isNatantViewOnOpenStatus]) {
        [self closeNatantAnimated:YES];
    }
    else {
        if (_newsDetailNatantLevel == NewsDetailNatantLevelClose) {
            if ([SSCommonLogic ttAlertControllerEnabled]) {
                TTThemedAlertController *alert = [[[TTThemedAlertController alloc] initWithTitle:nil message:SSLocalizedString(@"此功能需开启互动插件，现在开启？", nil) preferredType:TTThemedAlertControllerTypeAlert] autorelease];
                [alert addActionWithTitle:SSLocalizedString(@"不开启", nil) actionType:TTThemedAlertActionTypeNormal actionBlock:nil];
                [alert addActionWithTitle:SSLocalizedString(@"开启", nil) actionType:TTThemedAlertActionTypeNormal actionBlock:^{
                    [NewsDetailLogicManager setNatantInteractionEnable:YES];
                    [self clickChangeNatantStatusButton];
                    ssTrackEvent(@"more_tab", @"interactive_on");
                }];
                [alert showFrom:self.viewController animated:YES];
            }
            else {
                UIAlertView * alertView = [[[UIAlertView alloc] initWithTitle:nil message:SSLocalizedString(@"此功能需开启互动插件，现在开启？", nil) delegate:self cancelButtonTitle:nil otherButtonTitles:SSLocalizedString(@"不开启", nil), SSLocalizedString(@"开启", nil), nil] autorelease];
                alertView.tag = kEnableNatantSwitchAlertViewWhenClickCommentButtonTag;
                [alertView show];
            }
            return;
        }
        [_natantView.commentView tryForceShowAndReload];
        [self openNatantShowComment:NewsDetailOpenNatantShowTypeDigBuryButtonTop animated:YES];
    }
}


- (void)insertJSContext:(NSString *)contextStr
{
    if (isEmptyString(contextStr) || _webviewInsertedInformationJS) {
        return;
    }
    //此处判断是否是main page
    BOOL couldInsert = YES;
    if ([_article isClientEscapeType]) {//客户端转码
        if ([webView canGoBack]) {
            couldInsert = NO;
        }
    }
    
    if (couldInsert) {
        NSString * insertStr = [NSString stringWithFormat:@"insertDiv(%@)", contextStr];
        [webView stringByEvaluatingJavaScriptFromString:insertStr];
    }
}

#pragma mark -- NewsDetailSupernatantViewDelegate

- (void)detailNatantViewWillLoadComment:(NewsDetailSupernatantView *)view
{
    [_eventTracker sendFinishCommentIfNeedForArticel:_article];
}

- (void)detailNatantViewHandleDownSwipWhenOnTop:(NewsDetailSupernatantView *)view
{
    if (_natantView.statusType == NewsDetailSupernatantStatusTypeButtonOpen) {
        [self closeNatantAnimated:YES];
    }
}

- (void)detailNatantViewHandleRightSwip:(NewsDetailSupernatantView *)view
{
    [self goBack:nil];
    ssTrackEvent(@"detail", @"flip_to_list");
}

- (void)detailNatantView:(NewsDetailSupernatantView *)view fetchedJSContext:(NSString *)jsContext
{
    if (view == _natantView) {
        [self insertJSContext:jsContext];
    }
}

- (void)articleInfoManager:(SSCommentManager *)manager refreshCommentsCount:(NSUInteger)commentsCount{
    
    self.article.commentCount = @(commentsCount);
}

- (void)detailNatantView:(NewsDetailSupernatantView *)view getStatus:(NSDictionary *)dict
{
    if (view == _natantView) {
        
        if ([[dict allKeys] containsObject:@"go_detail_count"]) {
            int goDetailCount = [[dict objectForKey:@"go_detail_count"] intValue];
            _article.goDetailCount = @(goDetailCount);
        }
        
        if ([[dict allKeys] containsObject:@"bury_count"]) {
            int buryCount = [[dict objectForKey:@"bury_count"] intValue];
            _article.buryCount = @(buryCount);
        }

        if ([[dict allKeys] containsObject:@"user_bury"]) {
            int userBury = [[dict objectForKey:@"user_bury"] intValue];
            _article.userBury = @(userBury);
        }
        
        BOOL bannComment = [[dict objectForKey:@"ban_comment"] boolValue];
        _article.banComment = @(bannComment);
        
        if ([[dict allKeys] containsObject:@"repin_count"]) {
            int repinCount = [[dict objectForKey:@"repin_count"] intValue];
            _article.repinCount = @(repinCount);
        }

        if ([[dict allKeys] containsObject:@"digg_count"]) {
            int diggCount = [[dict objectForKey:@"digg_count"] intValue];
            _article.diggCount = @(diggCount);
        }
        
        if ([[dict allKeys] containsObject:@"share_url"]) {
            NSString * shareURL = [dict objectForKey:@"share_url"];
            _article.shareURL = shareURL;
        }
        
        BOOL needRefershTitle = NO;
        
        if ([[dict allKeys] containsObject:@"display_title"]) {
            NSString * displayTitle = [dict objectForKey:@"display_title"];
            _article.displayTitle = displayTitle;
            needRefershTitle = YES;
        }
        
        if ([[dict allKeys] containsObject:@"display_url"]) {
            NSString * displayURL = [dict objectForKey:@"display_url"];
            _article.displayURL = displayURL;
            needRefershTitle = YES;
        }

        
        /*
         * information 接口返回的接口字段 comment_count 数字不是及时的，所以更新评论数不使用该接口字段
         *
         * 应该使用all_comments接口的total_number字段，该字段是实时更新的
         */
        
//        if ([[dict allKeys] containsObject:@"comment_count"]) {
//            int commentCount = [[dict objectForKey:@"comment_count"] intValue];
//            _article.commentCount = @(commentCount);
//        }

        if ([[dict allKeys] containsObject:@"user_repin"]) {
            BOOL userRepin = [[dict objectForKey:@"user_repin"] boolValue];
            _article.userRepined = @(userRepin);
        }

        if ([[dict allKeys] containsObject:@"user_digg"]) {
            BOOL userDigg = [[dict objectForKey:@"user_digg"] boolValue];
            _article.userDigg = @(userDigg);
        }

        BOOL delArticle = [[dict objectForKey:@"delete"] boolValue];
        _article.articleDeleted = @(delArticle);

        [[SSModelManager sharedManager] save:nil];

        if (bannComment) {
            [self bannArticle];
        }

        if (delArticle) {
            [self delegateCurrentArticleIfNeed];
        }
        
        if (needRefershTitle) {
            [_titleBarView refreshAddressTitle:_article.displayTitle addressURL:_article.displayURL];
        }
    }
}

- (void)detailNatantView:(NewsDetailSupernatantView *)view scriptString:(NSString *)scp
{
    if (view == _natantView) {
        [self webView:webView stringByEvaluatingJavaScriptFromString:scp];
    }
}

- (void)detailNatantView:(NewsDetailSupernatantView *)view avatarTappedWithCommentModel:(SSCommentModel *)model
{
    [self presentUserProfileWithUserID:[NSString stringWithFormat:@"%@", model.userID]];
}

- (void)detailNatantView:(NewsDetailSupernatantView *)view statusChangedFrom:(NewsDetailSupernatantStatusType)fromType statusChangedTo:(NewsDetailSupernatantStatusType)type
{
    BOOL webViewScrollsToTopEnable = !(type == NewsDetailSupernatantStatusTypeButtonOpen || type == NewsDetailSupernatantStatusTypeFullShow);
    webView.scrollView.scrollsToTop = webViewScrollsToTopEnable;
    [_natantView.commentView setScrollToTopEnable:!webViewScrollsToTopEnable];
    //版权问题， titlebar变换
    if (_newsDetailNatantLevel == NewsDetailNatantLevelHalfClose) {
        if (type == NewsDetailSupernatantStatusTypeButtonOpen || type == NewsDetailSupernatantStatusTypeFullShow) {
            
            _titleBarView.addressBar.addressField.enabled = NO;
            [_titleBarView.addressBar refreshTitle:_article.title];
            if (!_closeNatantButton) {
                self.closeNatantButton = [UIButton buttonWithType:UIButtonTypeCustom];
                [_closeNatantButton setTitle:SSLocalizedString(@"关闭", nil) forState:UIControlStateNormal];
                _closeNatantButton.titleLabel.font = [UIFont boldSystemFontOfSize:16];
                [_closeNatantButton addTarget:self action:@selector(closeNatantButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
                [_closeNatantButton setTitleColor:[UIColor colorWithHexString:SSUIString(@"NewsDetailViewCloseNatantButtonTitleColor", @"da4242")] forState:UIControlStateNormal];
                [_closeNatantButton setTitleColor:[UIColor colorWithHexString:SSUIString(@"NewsDetailViewCloseNatantButtonTitleHighlightColor", @"505050")] forState:UIControlStateHighlighted];
                _closeNatantButton.frame = CGRectMake(0, 0, 44, 44);
            }
            _titleBarView.titleImageView.leftView = _closeNatantButton;
        }
        else {
            _titleBarView.addressBar.addressField.enabled = YES;
            [_titleBarView.addressBar refreshTitle:_article.displayTitle];
            _titleBarView.titleImageView.leftView = _titleBarView.backButtonView;
        }
    }
    
    if (fromType != type && (type == NewsDetailSupernatantStatusTypeButtonOpen || type == NewsDetailSupernatantStatusTypeFullShow)) {
        [_eventTracker sendEnterCommentIfNeedByNatantOriginY:0 natantHeight:[_natantView headerViewHeight] webView:self.webView article:_article forceSendIfNotSend:YES];
    }
}

#pragma mark -- util

- (NSString *)reportHtmlForWebContentIfNeed
{
    if ([self isWebContentType] && [SSReportManager needPostArticleHTML]) {
        return [SSCommon fetchWebViewHTML:webView];
    }
    return nil;
}

#pragma mark -- Natant container

- (void)refreshNatantLevel
{
    BOOL localClose = ![NewsDetailLogicManager isNatantInteractionEnable];
    if (localClose) {
        _newsDetailNatantLevel = NewsDetailNatantLevelClose;
    }
    else {
        switch ([_article.natantLevel integerValue]) {
            case ArticleNatantLevelDefault:
            {
                if ([_eventTracker.adID longLongValue] != 0 || ([_article.groupFlags longLongValue] & kArticleGroupFlagsClientEscape) > 0) {
                    _newsDetailNatantLevel = NewsDetailNatantLevelHalfOpen;
                }
                else {
                    _newsDetailNatantLevel = NewsDetailNatantLevelOpen;
                }
            }
                break;
            case ArticleNatantLevelClose:
            {
                _newsDetailNatantLevel = NewsDetailNatantLevelClose;
            }
                break;
            case ArticleNatantLevelOpen:
            {
                _newsDetailNatantLevel = NewsDetailNatantLevelOpen;
            }
                break;
            case ArticleNatantLevelHalfOpen:
            {
                _newsDetailNatantLevel = NewsDetailNatantLevelHalfOpen;
            }
                break;
            case ArticleNatantLevelHalfClose:
            {
                _newsDetailNatantLevel = NewsDetailNatantLevelHalfClose;
            }
                break;
            default:
                break;
        }
    }
    
    if (_newsDetailNatantLevel == NewsDetailNatantLevelOpen) {
        if (_natantView.statusType == NewsDetailSupernatantStatusTypeButtonOpen) {
            [self natantViewAddToSuperView:NO];
        }
        else {
            [self natantViewAddToSuperView:YES];
        }
    }
    else {
        [self natantViewAddToSuperView:NO];
    }
}

- (void)resetNatant
{
    [webView webViewScrollToOffset:0 animatied:NO];
    [_natantView scrollToTopHeaderAnimated:NO];
    _natantView.statusType = NewsDetailSupernatantStatusTypeFullClose;
    [self natantViewAddToSuperView:[self isNatantViewOnOpenLevel]];
}

- (void)natantViewAddToSuperView:(BOOL)addToWebView
{
    if (_natantView.superview) {
        [_natantView removeFromSuperview];
    }
    if (addToWebView) {
        webView.couldSetContentInset = (_natantView != nil);
        [webView.scrollView addSubview:_natantView];
        [webView reloadNatant];
    }
    else {
        [self addSubview:_natantView];
    }
    _natantView.frame = [self frameForNatantView];
    [self bringSubviewToFront:_toolBarView];
}

//该方法认为当前_natant.statusType为FullShow或者ButtonOpen，其他状态忽略
- (void)closeNatantAnimated:(BOOL)animated
{
    if (_natantView.statusType == NewsDetailSupernatantStatusTypeFullShow) {
        [webView webViewScrollToOffset:[self normalOriginYForNatantView] - _natantView.frame.size.height animatied:animated];
        [_natantView scrollToTopHeaderAnimated:NO];
    }
    else if (_natantView.statusType == NewsDetailSupernatantStatusTypeButtonOpen) {
        setFrameWithOrigin(_natantView, CGRectGetMinX(webView.frame), CGRectGetMaxY(_titleBarView.frame));
        CGFloat time = animated ? 0.25 : 0;
        [UIView animateWithDuration:time animations:^{
            setFrameWithOrigin(_natantView, CGRectGetMinX(webView.frame), CGRectGetMinY(_toolBarView.frame));
        } completion:^(BOOL finished) {
            _natantView.statusType = NewsDetailSupernatantStatusTypeFullClose;
            [self natantViewAddToSuperView:[self isNatantViewOnOpenLevel]];
            [self refreshNatantStatus];
            [_natantView scrollToTopHeaderAnimated:NO];
        }];
    }
}

//该方法认为当前_natant.statusType为FullClose或者ShowPart，其他状态忽略
- (void)openNatantShowComment:(NewsDetailOpenNatantShowType)showType animated:(BOOL)animated
{
    [self openNatantShowComment:showType beginPositionStart:YES animatedTime:animated ? 0.25 : 0];
}
- (void)openNatantShowComment:(NewsDetailOpenNatantShowType)showType beginPositionStart:(BOOL)begin animatedTime:(CGFloat)time
{
    if (showType == NewsDetailOpenNatantShowTypeHotComment) {
        [_natantView scrollToTopCommentAnimated:NO];
    }
    else if (showType == NewsDetailOpenNatantShowTypeRecentComment) {
        [_natantView scrollToRecentCommentAnimated:NO];
    }
    else if (showType == NewsDetailOpenNatantShowTypeADViewTopLocation) {
        [_natantView scrollToADViewTop:NO];
    }
    else if (showType == NewsDetailOpenNatantShowTypeDigBuryButtonTop) {
        [_natantView scrollToDigOrBuryButtonTop:NO];
    }
    else {
        [_natantView scrollToTopHeaderAnimated:NO];
    }
    
    if (_natantView.statusType == NewsDetailSupernatantStatusTypeShowPart) {
        CGFloat webViewOriginY = webView.scrollView.contentSize.height;
        [webView webViewScrollToOffset:webViewOriginY animatied:time > 0];
    }
    else if (_natantView.statusType == NewsDetailSupernatantStatusTypeFullClose) {
        _natantView.statusType = NewsDetailSupernatantStatusTypeButtonOpen;
        [self natantViewAddToSuperView:NO];
        if (begin) {
            setFrameWithOrigin(_natantView, CGRectGetMinX(webView.frame), CGRectGetMinY(_toolBarView.frame));
        }
        [UIView animateWithDuration:time animations:^{
            setFrameWithOrigin(_natantView, CGRectGetMinX(webView.frame), CGRectGetMaxY(_titleBarView.frame));
        } completion:^(BOOL finished) {
            [self refreshNatantStatus];
        }];
    }
}

#pragma mark -- private UI method
#pragma mark -- loadingIndicatorView

- (void)startLoadingIndicatorViewAnimating
{
    if(!loadingIndicatorView)
    {
        self.loadingIndicatorView = [[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray] autorelease];
        loadingIndicatorView.center = CGPointMake(SSWidth(self) / 2, SSMinY(loadingView) - 10);
    }
    if (loadingIndicatorView.superview == nil) {
        [self addSubview:loadingIndicatorView];
    }
    [self bringSubviewToFront:loadingIndicatorView];
    if (!loadingIndicatorView.isAnimating) {
        [loadingIndicatorView startAnimating];
    }
    
}

- (void)stopLoadingIndicatorViewAnimation
{
    if (loadingIndicatorView) {
        [loadingIndicatorView stopAnimating];
        [loadingIndicatorView removeFromSuperview];
        self.loadingIndicatorView = nil;
    }
}

#pragma mark -- loadingIndicatorView

/**
    显示“今日头条”四个字的view
 */
- (void)showLoadingView
{
    if (!loadingView) {
        self.loadingView = [[[UIImageView alloc] initWithImage:[UIImage resourceImageNamed:@"detail_loading.png"]] autorelease];
        loadingView.center = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
        loadingView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    }
    [self addSubview:loadingView];
}

- (void)removeLoadingView
{
    if (loadingView) {
        [loadingView removeFromSuperview];
        self.loadingView = nil;
    }
}

#pragma mark -- retry button

- (void)showRetryButton
{
    [self showLoadingView];
    if(!retryButton)
    {
        self.retryButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [retryButton setBackgroundImage:[UIImage resourceImageNamed:@"btn_tryagain.png"] forState:UIControlStateNormal];
        [retryButton setBackgroundImage:[UIImage resourceImageNamed:@"btn_tryagain_press.png"] forState:UIControlStateHighlighted];
        [retryButton setTitle:SSLocalizedString(@"重试", nil) forState:UIControlStateNormal];
        [retryButton setTitleColor:[UIColor colorWithHexString:@"888888"] forState:UIControlStateNormal];
        retryButton.frame = CGRectMake(0, 0, 60, 30);
        [retryButton addTarget:self action:@selector(retry:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    CGRect retryRect = retryButton.frame;
    if(loadingView)
    {
        retryRect.origin.y = CGRectGetMaxY(loadingView.frame) + 15;
    }
    else
    {
        retryRect.origin.y = self.frame.size.height/2 - retryRect.size.height/2;
    }
    retryButton.frame = retryRect;
    retryButton.center = CGPointMake(self.frame.size.width/2, retryButton.center.y);
    
    retryButton.enabled = YES;
    [self addSubview:retryButton];
    [self stopLoadingIndicatorViewAnimation];
}

- (void)removeRetryButton
{
    if (retryButton) {
        [retryButton removeFromSuperview];
        self.retryButton = nil;
    }
}

#pragma mark -- tool bar

- (void)buildToolBarIfNeed
{
    if (!_toolBarView && _newsDetailType == NewsDetailTypeNotAssign) {
        if (([_article.groupFlags longLongValue] & kArticleGroupFlagsDetailTypeSimple) > 0) {
            _newsDetailType = NewsDetailTypeSimple;
            ssTrackEvent(@"detail", @"simple_mode");
        }
        else if (([_article.groupFlags longLongValue] & kArticleGroupFlagsDetailTypeNoToolBar) > 0) {
            if ([SSCommon isPadDevice]) {
                _newsDetailType = NewsDetailTypeNoComment;
                ssTrackEvent(@"detail", @"no_comments_mode");
            }
            else {
                _newsDetailType = NewsDetailTypeNoToolBar;
                ssTrackEvent(@"detail", @"hide_mode");
            }
        }
        else if (([_article.groupFlags longLongValue] & kArticleGroupFlagsDetailTypeNoComment) > 0) {
            _newsDetailType = NewsDetailTypeNoComment;
            ssTrackEvent(@"detail", @"no_comments_mode");
        }
        else {
            _newsDetailType = NewsDetailTypeNormal;
        }
        
        if (_newsDetailType == NewsDetailTypeNormal || _newsDetailType == NewsDetailTypeNoComment) {
            NewsDetailToolBarViewStyle style = _newsDetailType == NewsDetailTypeNormal ? NewsDetailToolBarViewFullStyle : NewsDetailToolBarViewNoCommentStyle;
            self.toolBarView = [[[NewsDetailToolBarView alloc] initWithStyle:style] autorelease];
            [self addSubview:_toolBarView];
            [_toolBarView.favouriteButton addTarget:self action:@selector(toolBarButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
            [_toolBarView.writeCommentButton addTarget:self action:@selector(toolBarButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
            [_toolBarView.commentButton addTarget:self action:@selector(toolBarButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
//            [_toolBarView.reportButton addTarget:self action:@selector(toolBarButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
            [_toolBarView.shareButton addTarget:self action:@selector(toolBarButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        }
    }
    _toolBarView.frame = [self frameForToolBar];
    [_toolBarView refreshArticle:_article];
}

- (CGRect)frameForToolBar
{
    CGRect frame = CGRectMake(0, self.frame.size.height - kNewsDetailToolBarViewHeight, self.frame.size.width, kNewsDetailToolBarViewHeight);
    return frame;
}

//- (void)noToolBarShareViewActionButtonClicked:(id)sender
//{
//    [_noToolBarShareView dismiss];
//    if (sender == _noToolBarShareView.favoriteButton.actionButton) {
//        [self changeFavoriteButtonClicked];
//    }
//    else if (sender == _noToolBarShareView.fontButton.actionButton) {
//        [self openFontSettingView];
//    }
//    else if (sender == _noToolBarShareView.notInterestButton.actionButton) {
//        [self changeInterestStatus];
//    }
//    else if (sender == _noToolBarShareView.reportButton.actionButton) {
//        [self reportArticle];
//    }
//}

- (void)openFontSettingView
{
    if(!_functionView)
    {
        self.functionView = [[[NewsDetailFunctionView alloc] initWithFrame:CGRectMake(0, 0, SSWidth(self), 174)] autorelease];
    }
    
    if(![_functionView isDisplay])
    {
        [_functionView showInView:self atPoint:CGPointMake(0,  SSHeight(self) -  SSHeight(_functionView))];
        [_functionView.superview bringSubviewToFront:_functionView];
    }

}

- (void)changeFavoriteButtonClicked
{
    if (!_itemAction) {
        self.itemAction = [[[ExploreItemActionManager alloc] init] autorelease];
    }
    
    if (![_article.userRepined boolValue]) {
        [_itemAction favoriteForOriginalData:_article adID:_eventTracker.adID finishBlock:nil];
        [NewsDetailLogicManager trackEventTag:@"detail" label:@"favorite_button" value:_article.uniqueID extValue:_eventTracker.adID groupModel:_article.groupModel];
    }
    else {
        [_itemAction unfavoriteForOriginalData:_article adID:_eventTracker.adID finishBlock:nil];
        [NewsDetailLogicManager trackEventTag:@"detail" label:@"unfavorite_button" value:_article.uniqueID extValue:_eventTracker.adID groupModel:_article.groupModel];
    }
    
    if([_article.userRepined boolValue])
    {
        [self displayMessage:SSLocalizedString(@"收藏成功", nil)];
    }
    else
    {
        [self displayMessage:SSLocalizedString(@"取消收藏", nil)];
    }
}

- (void)toolBarButtonClicked:(id)sender
{
    if (sender == _toolBarView.favouriteButton) {
        [self changeFavoriteButtonClicked];
    }
    else if (sender == _toolBarView.writeCommentButton) {
        self.showLoginIfNeededReason = ShowLoginReasonClickWriteComment;
        if ([[AccountManager sharedManager] isLogin]) {
            [self openCommentWithText:nil];
        }
        else {
            if ([SSCommon isPadDevice])
            {
                if (!_padAccountPopOverController)
                {
                    
                    HDAccountPopOverViewController * cell = [[HDAccountPopOverViewController alloc] init];
                    self.padAccountPopOverController = [[[UIPopoverController alloc] initWithContentViewController:cell] autorelease];
                    _padAccountPopOverController.delegate = self;
                    [cell release];
                }
                
                CGRect rect = _toolBarView.writeCommentButton.frame;
                if (!_padAccountPopOverController.isPopoverVisible)
                {
                    [_padAccountPopOverController presentPopoverFromRect:rect inView:_toolBarView permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
                }
            }
            else
            {
                ArticleLoginViewController * loginViewController = [[ArticleLoginViewController alloc] init];
                loginViewController.completion = ^(ArticleLoginState state){
                    if ([[AccountManager sharedManager] isLogin]) {
                        [self openCommentWithText:nil];
                    }
                };
                [self.navigationController pushViewController:loginViewController animated:YES];
                [loginViewController release];
            }
        }
        
        [NewsDetailLogicManager trackEventTag:@"detail" label:@"write_button" value:_article.uniqueID extValue:_eventTracker.adID groupModel:_article.groupModel];
    }
    else if (sender == _toolBarView.commentButton) {
        if ([self isNatantViewOnOpenStatus]) {
            ssTrackEvent(@"detail", @"handle_close_drawer");
        }
        else {
            ssTrackEvent(@"detail", @"handle_open_drawer");
        }
        [self clickChangeNatantStatusButton];
    }
//    else if (sender == _toolBarView.reportButton) {
//        [self toolbarReportItemClicked];
//    }
    else if (sender == _toolBarView.shareButton) {
        self.showLoginIfNeededReason = ShowLoginReasonClickShare;
        [self systemShareUseActivityController];
        [NewsDetailLogicManager trackEventTag:@"detail" label:@"share_button" value:_article.uniqueID extValue:_eventTracker.adID groupModel:_article.groupModel];
    }
}

#pragma mark -- No Interesting

- (void)showNoInterestListBarView
{
    if (![_article isContentFetched]) {
        [[SSActivityIndicatorView sharedView] showMessage:SSLocalizedString(@"内容获取中,请稍后", nil)];
        return;
    }
    if (!_notInterestNotifyBarView) {
        self.notInterestNotifyBarView = [[[ArticleListNotifyBarView alloc] initWithFrame:CGRectMake(0, SSMaxY(_titleBarView), SSWidth(self), kNotifyBarViewHeight)] autorelease];
        [self addSubview:_notInterestNotifyBarView];
    }
    NSString * title = nil;
    if ([_article.userRepined boolValue]) {
        title = kNotInterestTipUserRepined;
    }
    else if ([[AccountManager sharedManager] isLogin]) {
        title = kNotInterestTipUserLogined;
    }
    else {
        title = kNotInterestTipUserUnLogined;
    }
    //__block NewsDetailView * weakSelf = self;
    
    [_notInterestNotifyBarView showMessage:title actionButtonTitle:nil/*SSLocalizedString(@"撤销", nil) */delayHide:YES duration:2.f bgButtonClickAction:NULL actionButtonClickBlock:^(UIButton *button) {
        //[weakSelf cancelLastNoInterest];
    } didHideBlock:NULL];
}

- (void)hideNoInterestListBarView
{
    [_notInterestNotifyBarView hideImmediately];
}

- (void)changeInterestStatus
{
    if(!_article.notInterested.boolValue)
    {
        [self showNoInterestListBarView];
        [self setArticleNotInterest:YES];
    }
    else
    {
        [self cancelLastNoInterest];
    }
}

- (void)cancelLastNoInterest
{
    [self setArticleNotInterest:NO];
    [self hideNoInterestListBarView];
}

- (void)setArticleNotInterest:(BOOL)notInterest
{
    _article.notInterested = @(notInterest);
    [[SSModelManager sharedManager] save:nil];
    
    DetailActionRequestType type = notInterest ? DetailActionTypeDislike : DetailActionTypeUnDislike;
    [_itemAction sendActionForOriginalData:_article adID:_eventTracker.adID actionType:type finishBlock:nil];
}

#pragma mark -- title bar
#pragma mark -- frame
- (CGRect)frameForTitleBar
{
    CGRect frame = CGRectMake(0, 0, self.frame.size.width, [SSTitleBarView titleBarHeight]);
    return frame;
}
#pragma mark -- title bar view button action

- (void)titleBarButtonClicked:(id)sender
{
    if (sender == _titleBarView.backButtonView.closeButton || sender == _titleBarView.backButtonView.backButton) {
        
        BOOL couldSendPageBack = YES;
        if ([_clientEscapeManager needReloadClientEscapeHTML:_article webView:webView] &&
            sender == _titleBarView.backButtonView.backButton) {
            [self loadWebTypeContent];
        }
        else if ([_titleBarView.backButtonView isCloseButtonShowing]) {
            if (sender == _titleBarView.backButtonView.backButton && [webView canGoBack]) {
                [webView goBack];
            }
            else {
                couldSendPageBack = NO;
                [self goBack:sender];
            }
        }
        else {
            if ([webView canGoBack]) {
                [webView goBack];
                [_titleBarView showCloseButton:YES];
            }
            else {
                couldSendPageBack = NO;
                [self goBack:sender];
            }
        }
        
        if (sender == _titleBarView.backButtonView.closeButton) {
            ssTrackEvent(@"detail", @"close_button");
        }
        else if (sender == _titleBarView.backButtonView.backButton && couldSendPageBack) {
            ssTrackEvent(@"detail", @"page_back");
        }

    }
    else if (sender == _titleBarView.clientEscapeButton) {

        BOOL couldSendTranscode = YES;
        if (_titleBarView.escapeButtonTipView && _titleBarView.escapeButtonTipView.superview) {
            ssTrackEvent(@"detail", @"transcode_with_tips");
            couldSendTranscode = NO;
        }
        
        if (_clientEscapeManager.mainPageIsClientEscape) {
            ssTrackEvent(@"detail", @"transcode_back");
        }
        else if(couldSendTranscode) {
            ssTrackEvent(@"detail", @"transcode");
        }

        
        _clientEscapeManager.clientEscapeButtonStatus = _clientEscapeManager.mainPageIsClientEscape ? ArticleClientEscapeButtonStatusToDisableClientEscape: ArticleClientEscapeButtonStatusToEnableClientEscape;
        [_titleBarView setClientEscapeButtonEnabe:NO];
        [_titleBarView removeEscapeTipViewIfNeed];
        self.latestWebViewRequestURL = nil;
        [self startLoadingIndicatorViewAnimating];
        [self loadWebTypeContent];
        
        if (_clientEscapeManager.clientEscapeButtonStatus == ArticleClientEscapeButtonStatusToEnableClientEscape) {
            _clientEscapeManager.showedAutoClientEscapeTipAlert = [self showAutoClientEscapeIfNeed];
        }
    }
    else if (sender == _titleBarView.moreButton) {
        
        if ([SSCommon isPadDevice]) {
            if (_newsDetailType == NewsDetailTypeSimple && !isEmptyString(_article.shareURL)) {
                UIActionSheet * sheet = [[UIActionSheet alloc] initWithTitle:nil
                                                                    delegate:self
                                                           cancelButtonTitle:SSLocalizedString(@"取消", nil)
                                                      destructiveButtonTitle:nil
                                                           otherButtonTitles:SSLocalizedString(@"用Safari打开", nil), SSLocalizedString(@"复制链接", nil), nil];
                sheet.tag = kNewsDetailSimpleTypeActionSheetTag;
                [sheet showInView:self];
                [sheet release];
            }
        }
        else {
            if (_newsDetailType == NewsDetailTypeNoComment || _newsDetailType == NewsDetailTypeNormal) {
                ////// 统计点击设置
                ssTrackEvent(@"detail", @"preferences");
                [self openFontSettingView];
            }
            else if (_newsDetailType == NewsDetailTypeNoToolBar) {
                if (!_noToolBarShareView) {
                    self.noToolBarShareView = [[[NewsDetailNoCommentShareView alloc] initWithFrame:CGRectMake(0, 0, SSWidth(self), 287) article:_article adID:_eventTracker.adID] autorelease];
                    [_noToolBarShareView.favoriteButton.actionButton addTarget:self action:@selector(noToolBarShareViewActionButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
                    [_noToolBarShareView.fontButton.actionButton addTarget:self action:@selector(noToolBarShareViewActionButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
                    [_noToolBarShareView.notInterestButton.actionButton addTarget:self action:@selector(noToolBarShareViewActionButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
                    [_noToolBarShareView.reportButton.actionButton addTarget:self action:@selector(noToolBarShareViewActionButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
                    
                }
                if(![_noToolBarShareView isDisplay])
                {
                    [self hideNoInterestListBarView];
                    [_noToolBarShareView showInView:self atPoint:CGPointMake(0,  SSHeight(self) -  SSHeight(_noToolBarShareView))];
                    [_noToolBarShareView.superview bringSubviewToFront:_noToolBarShareView];
                }
            }
            else if (_newsDetailType == NewsDetailTypeSimple) {
                ArticleActionAlertView * view = [[ArticleActionAlertView alloc] initWithTitles:@[SSLocalizedString(@"用Safari打开", nil), SSLocalizedString(@"复制链接", nil)]
                                                                                   deleteTitle:nil
                                                                                   cancelTitle:SSLocalizedString(@"取消", nil)];
                view.delegate = self;
                view.infoTag = @"phoneSimpleTypeShare";
                
                view.portraitOriginPoint = CGPointMake(450, 805);
                view.landscapeOriginPoint = CGPointMake(650, 550);
                [view showOnViewController:[SSCommon topViewControllerFor:self]];
                [view release];

            }
        }
    }
}

#pragma mark -- UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet.tag == kNewsDetailSimpleTypeActionSheetTag) {
        if (buttonIndex == 0) {
            [self openUseSafari];
        }
        else if (buttonIndex == 1) {
            [self copyText];
        }
    }
}

- (void)copyText
{
    [[SSShareManager shareInstance] copyText:_article.shareURL];
}

- (void)openUseSafari
{
    NSURL * url = [SSCommon URLWithURLString:_article.shareURL];
    [[UIApplication sharedApplication] openURL:url];
}

#pragma mark -- observer

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"mainPageIsClientEscape"]) {
        [_titleBarView setClientEscapeButtonSelected:_clientEscapeManager.mainPageIsClientEscape];
    }
}

#pragma mark -- auto escape alert

- (BOOL)showAutoClientEscapeIfNeed
{
    if (![[ArticleClientEscapeTipManager shareManager] needShowAutoEscapeAlert]) {
        return NO;
    }
    ssTrackEvent(@"detail", @"auto_transcode_window");
    [[ArticleClientEscapeTipManager shareManager] alertShowed];
    if ([SSCommonLogic ttAlertControllerEnabled]) {
        TTThemedAlertController *alert = [[TTThemedAlertController alloc] initWithTitle:nil message:SSLocalizedString(@"自动启动阅读模式以获得最佳体验?", nil) preferredType:TTThemedAlertControllerTypeAlert];
        [alert addActionWithTitle:SSLocalizedString(@"否", nil) actionType:TTThemedAlertActionTypeCancel actionBlock:^{
            [ArticleClientEscapeManager setAutoClientEscapse:NO];
            ssTrackEvent(@"detail", @"auto_transcode_false");
        }];
        [alert addActionWithTitle:SSLocalizedString(@"是", nil) actionType:TTThemedAlertActionTypeNormal actionBlock:^{
            [ArticleClientEscapeManager setAutoClientEscapse:YES];
            ssTrackEvent(@"detail", @"auto_transcode_true");
        }];
        [alert showFrom:self.viewController animated:YES];
    }
    else {
        [UIAlertView showMainTitle:nil
                           message:SSLocalizedString(@"自动启动阅读模式以获得最佳体验?", nil)
                 cancelButtonTitle:SSLocalizedString(@"否", nil)
                 otherButtonTitles:@[SSLocalizedString(@"是", nil)]
                          tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                              if (buttonIndex != alertView.cancelButtonIndex) {
                                  [ArticleClientEscapeManager setAutoClientEscapse:YES];
                                  ssTrackEvent(@"detail", @"auto_transcode_true");
                              }
                              else {
                                  [ArticleClientEscapeManager setAutoClientEscapse:NO];
                                  ssTrackEvent(@"detail", @"auto_transcode_false");
                              }
                          }];
    }
    return YES;
}

#pragma mark -- UIPopoverControllerDelegate
- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    if(![[AccountManager sharedManager] isLogin])
    {
        ssTrackEvent(@"login", @"login_pop_close");
    }
}

#pragma mark -- NewsDetailImageDownloadManagerDelegate

- (void)detailImageDownloadManager:(NewsDetailImageDownloadManager *)manager finishDownloadImageMode:(SSImageInfosModel *)model success:(BOOL)success
{
    NSUInteger index = [[[model userInfo] objectForKey:kArticleImgsIndexKey] intValue];
    if ((model.imageType == SSImageTypeLarge || model.imageType == SSImageTypeThumb)) {
        JSMetaInsertImageType type = (model.imageType == SSImageTypeLarge) ? JSMetaInsertImageTypeOrigin : JSMetaInsertImageTypeThumb;
        [self webViewShowImageForModel:model imageIndex:index imageType:type];
    }
}

@end
