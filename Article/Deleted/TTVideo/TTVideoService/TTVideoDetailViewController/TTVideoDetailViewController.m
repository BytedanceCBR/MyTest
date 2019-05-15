//
//  TTVideoDetailViewController.m
//  Article
//
//  Created by 刘廷勇 on 16/3/31.
//
//

#import "TTVideoDetailViewController+Log.h"
#import "TTVideoDetailStayPageTracker.h"

#import <KVOController/KVOController.h>

#import "TTDetailModel.h"
#import "TTVideoBannerModel.h"
#import "Article.h"

#import "SSAppStore.h"
#import "ExploreVideoDetailHelper.h"
#import "TTCommentDataManager.h"
#import "ExploreDetailManager.h"
#import "ArticleInfoManager.h"
#import "NewsDetailLogicManager.h"
#import "TTActivityShareManager.h"
#import "TTReportManager.h"
#import "TTVideoAutoPlayManager.h"
#import "TTViewWrapper.h"
#import "ExploreMovieView.h"
#import "TTVPlayVideo.h"
#import "TTVideoMovieBanner.h"
#import "ArticleVideoPosterView.h"
#import "ExploreVideoTopView.h"
#import "TTCommentViewController.h"
#import "ExploreDetailToolbarView.h"
#import "TTIndicatorView.h"
#import "SSCommentInputHeader.h"
#import "TTDetailNatantContainerView.h"
#import "TTDetailNatantVideoADView.h"
#import "TTDetailNatantVideoInfoView.h"
#import "TTDetailNatantVideoPGCView.h"
#import "TTDetailNatantVideoBanner.h"
#import "ExploreDetailTextlinkADView.h"
#import "TTDetailNatantRelatedVideoGroupView.h"
#import "TTDetailNatantRelatedVideoNewGroupView.h"
#import "UIViewController+Refresh_ErrorHandler.h"
#import "TTVideoAlbumView.h"
#import "SSActivityView.h"
#import "UINavigationController+NavigationBarConfig.h"
#import "UIViewController+NavigationBarStyle.h"
#import "ArticleShareManager.h"
#import "TTNavigationController.h"

#import <TTAccountBusiness.h>

#import "SSWebViewController.h"
#import "ArticleFriend.h"
#import "TTMovieViewCacheManager.h"
#import <Crashlytics/Crashlytics.h>
#import "TTThemeManager.h"
#import "UIImage+TTThemeExtension.h"
#import "TTStringHelper.h"
#import "TTDeviceHelper.h"
#import "TTArticleTabBarController.h"
#import "TTActionSheetController.h"
#import "TTVideoDetailViewController+ExtendLink.h"
#import "TTNetworkManager.h"
#import "TTVideoDetailFloatCommentViewController.h"
#import "TTVideoShareMovie.h"
#import "TTDetailNatantVideoTagsView.h"
#import "ArticleCommentView.h"
#import "SSIndicatorTipsManager.h"
#import "ArticleMomentCommentModel.h"
#import "ArticleMomentDetailView.h"
#import "TTVideoDetailViewController+VerticalInteract.h"
#import "TTVideoTip.h"
#import "TTCommentWriteView.h"
#import "ArticleMomentDetailViewController.h"
#import "TTVideoDetailADContainerView.h"
#import "TTVideoCallbackTaskGlobalQueue.h"
#import "TTArticleCategoryManager.h"
//#import "TTRepostViewController.h"
//#import "TTRepostOriginModels.h"
#import "ExploreOrderedData+TTAd.h"
#import "SSURLTracker.h"
#import "TTDetailContainerViewController.h"
#import "ExploreItemActionManager.h"
#import "TTAdDetailViewDefine.h"
#import "TTAdDetailViewHelper.h"
#import "TTAdManager.h"
#import "TTAdPromotionManager.h"
#import "TTAdVideoViewFactory.h"
#import "TTCommentWriteView.h"
#import "TTNetworkHelper.h"
#import "TTVideoCommon.h"
#import "TTVideoDetailNewPlayControl.h"
#import "TTVideoDetailOldPlayControl.h"
#import "TTVideoTabBaseCellPlayControl.h"
#import "TTVideoCommon.h"
#import "ExploreItemActionManager.h"
#import "UIView+SupportFullScreen.h"
#import "TTVAutoPlayManager.h"
#import <TTTracker/TTTrackerProxy.h>
#import "Article+TTAdDetailInnerArticleProtocolSupport.h"
//#import "TTShareToRepostManager.h"
#import "TTCommentDetailModel+TTCommentDetailModelProtocolSupport.h"
#import "TTCommentDetailReplyCommentModel+TTCommentDetailReplyCommentModelProtocolSupport.h"
#import "TTActivityShareSequenceManager.h"
#import "TTVSettingsConfiguration.h"
#import <BDTArticle/Article.h>
#import <TTSettingsManager/TTSettingsManager.h>
#import "NSDictionary+TTGeneratedContent.h"
#import "TTTabBarProvider.h"
#import "TTKitchenHeader.h"
#import "TTTabBarProvider.h"
#import "ArticleMomentModel.h"
#import "Article+TTADComputedProperties.h"
#import "TTCommentViewControllerProtocol.h"
#import "TTAdVideoRelateAdModel.h"

//爱看
#import "AKHelper.h"

#define kTopViewHeight  44.f

extern CGFloat ttvs_detailVideoMaxHeight(void);
extern NSInteger ttvs_isVideoShowOptimizeShare(void);
extern NSInteger ttvs_isVideoShowDirectShare(void);
extern BOOL ttvs_isShareIndividuatioEnable(void);

NSString * _Nonnull const TTVideoDetailViewControllerDeleteVideoArticle = @"TTVideoDetailViewControllerDeleteVideoArticle";
static NSString *const video_play_detail_info_status = @"video_play_detail_info_status";

extern NSString * const TTActivityContentItemTypeWechat;
extern NSString * const TTActivityContentItemTypeWechatTimeLine;
extern NSString * const TTActivityContentItemTypeQQFriend;
extern NSString * const TTActivityContentItemTypeQQZone;
//extern NSString * const TTActivityContentItemTypeDingTalk;

@interface TTVideoDetailViewController () <TTCommentDataSource, TTCommentViewControllerDelegate, ExploreDetailManagerDelegate, ArticleInfoManagerDelegate, ExploreMovieViewDelegate, SSActivityViewDelegate, TTCommentWriteManagerDelegate, UIViewControllerErrorHandler, UIScrollViewDelegate, TTVideoMovieBannerDelegate, TTDetailNatantVideoPGCViewDelegate, TTDetailNatantVideoInfoViewDelegate, TTVideoDetailFloatCommentViewControllerDelegate ,TTVideoDetailPlayControlDelegate,TTDetailNatantRelatedVideoBaseViewDelegate, TTAdDetailContainerViewDelegate, TTActivityShareManagerDelegate>

@property (nonatomic, strong) TTVideoDetailStayPageTracker        *tracker;

@property (nonatomic, strong) ExploreVideoTopView                 *topView;
@property (nonatomic, strong) SSThemedView *statusBarBackgrView;
@property (nonatomic, assign) BOOL ttv_statusBarHidden;

@property (nonatomic, strong ,readonly) ArticleVideoPosterView    *movieShotView;
@property (nonatomic, strong) UIView                              *moviewViewContainer;
@property (nonatomic, strong) TTVideoMovieBanner                  *movieBanner;

@property (nonatomic, strong) TTDetailNatantContainerView         *natantContainerView;
@property (nonatomic, strong) TTDetailNatantRelatedVideoBaseView  *relatedVideoGroup;
@property (nonatomic, strong) SSThemedScrollView                  *wrapperScroller;//用给iPad下分屏的相关视频滑动
@property (nonatomic, strong) SSThemedLabel                       *distinctNatantTitle;
@property (nonatomic, strong) SSThemedView                        *distinctLine;

@property (nonatomic, strong) TTVideoAlbumView                    *videoAlbum;

@property (nonatomic, strong) TTCommentViewController             *commentVC;
@property (nonatomic, strong) ExploreDetailToolbarView            *toolbarView;

@property (nonatomic, strong) TTCommentWriteView           *commentWriteView;

@property (nonatomic, strong) TTActivityShareManager              *activityActionManager;

@property (nonatomic, assign) VideoDetailViewFromType             fromType;
@property (nonatomic, assign) VideoDetailViewShowStatus           showStatus;

@property (nonatomic, strong) SSJSBridgeWebView              *webView;
@property (nonatomic, strong) TTDetailNatantVideoPGCView          *pgcView;
@property (nonatomic, strong) ArticleInfoManager                  *buildInfoManager;


@property (nonatomic, strong) ExploreItemActionManager *itemActionManager;

@property (nonatomic, assign) BOOL isBackAction;
@property (nonatomic, assign) BOOL registeredKVO;
@property (nonatomic, assign) BOOL didDisAppear;
@property (nonatomic, assign) BOOL isCommentButtonAnmationing;
@property (nonatomic, assign) BOOL shouldSendCommentTrackEvent;
@property (nonatomic, assign) BOOL enableScrollToChangeShowStatus;
@property (nonatomic, assign) BOOL isCommentButtonClicked;
@property (nonatomic, assign) BOOL hasFetchedComments; //是否已经取到了评论数据

@property (nonatomic, strong) id<TTCommentModelProtocol> commentModelForFloatComment;
@property (nonatomic, strong) NSIndexPath *commentIndexPathToReload;
@property (nonatomic, assign) BOOL isGettingMomentDetail;
@property (nonatomic, assign) NSInteger publishStatusForTrack; //0为初始值，1表示发送了unlog埋点,2表示发送了unlog_done埋点
//详情页dislike及report字典
@property (nonatomic, strong) TTActionSheetController *actionSheetController;

@property (nonatomic, copy) NSString *landingURL;
@property (nonatomic, strong,readwrite) TTDetailNatantVideoADView *embededAD;
@property (nonatomic, strong) TTVideoDetailPlayControl * _Nullable playControl;

//详情页监控
@property (nonatomic, assign) NSTimeInterval startTimestamp;
@property (nonatomic, assign) BOOL startImpression;

@property (nonatomic, strong) TTDetailNatantVideoTagsView *tagsView;
@property (nonatomic, weak) TTVideoDetailViewController *preViewController;
@property (nonatomic, strong) SSActivityView  *phoneShareView;
/**
 *  UGC滚到评论区, 从TTDetailModel中迁移过来的
 */
@property (nonatomic, assign) BOOL beginShowCommentUGC;
/**
 *  UGC拉出评论框, 同上
 */
@property (nonatomic, assign) BOOL beginWriteCommentUGC;

@property (nonatomic, assign) BOOL beginShowComment;

/**
 *  UGC拉出评论框
 */
@property (nonatomic, assign) BOOL enterFromClickComment;
/**
 *
 */
@property (nonatomic, assign) BOOL fromU11Cell;

@property (nonatomic, assign) BOOL isADVideo;        //详情页播放的video是否是广告

@end

@implementation TTVideoDetailViewController

- (void)dealloc
{
    if (self.startImpression) {
        [self.commentVC.commentTableView tt_endImpression];
    }
    [TTVideoAlbumHolder dispose];
    if (![self shouldContinuePlayVideoWhenback] && !([[TTVideoAutoPlayManager sharedManager] dataIsAutoPlaying:self.orderedData] || [[TTVAutoPlayManager sharedManager] IsCurrentAutoPlayingWithUniqueId:self.orderedData.uniqueID])) {
        [self.playControl invalideMovieView];
    }
    [self _logBack];
    [self removeObserver];
}

- (instancetype)initWithDetailViewModel:(TTDetailModel *)model
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        self.ttv_statusBarHidden = ![TTDeviceHelper isIPhoneXDevice];
        
        NSDictionary *params = model.baseCondition;
        self.beginShowCommentUGC = [params tt_boolValueForKey:@"showCommentUGC"];
        self.beginWriteCommentUGC = [params tt_boolValueForKey:@"writeCommentUGC"];
        self.beginShowComment = [params tt_boolValueForKey:@"showcomment"];
        self.fromU11Cell = [params tt_boolValueForKey:@"fromU11Cell"];
        self.enterFromClickComment = [params tt_boolValueForKey:@"clickComment"];
        self.detailModel = model;
        [self settingOrderedData];
        self.ttHideNavigationBar = YES;
        self.shouldSendCommentTrackEvent = ![self shouldBeginShowComment];
        [self.detailModel sharedDetailManager].delegate = self;
        [self _initShowStatus];
        [self _confirmFromType];
        [self _initTracker];
        _shareMovie = params[@"movie_shareMovie"];
        if (!_shareMovie) {
            _shareMovie = [[TTVideoShareMovie alloc] init];
        }
        _interactModel = [[TTVideoDetailInteractModel alloc] init];
        _startTimestamp = [[NSDate date] timeIntervalSince1970];
        [self initPlayControl];
        [self configPlayControl];
        self.preViewController = self;
    }
    return self;
}

- (UIView *)movieView
{
    if ([self.shareMovie.movieView isKindOfClass:[UIView class]]) {
        return self.shareMovie.movieView;
    }else if ([self.shareMovie.playerControl isKindOfClass:[TTVideoTabBaseCellPlayControl class]]){
        TTVideoTabBaseCellPlayControl *control = self.shareMovie.playerControl;
        return control.movieView;
    }
    return nil;
}

- (void)configPlayControl
{
    self.playControl.viewController = self;
    self.playControl.delegate = self;
    self.playControl.detailModel = self.detailModel;
    self.playControl.shareMovie = _shareMovie;
}

- (void)initPlayControl
{
    NSNumber *adid = self.detailModel.adID;
    if (!adid) {
        adid = self.orderedData.ad_id;
    }
    if ([self.shareMovie.movieView isKindOfClass:[ExploreMovieView class]] || [self adid].longLongValue > 0 || ![TTVSettingsConfiguration isNewPlayerEnabled]) {
        self.playControl = [[TTVideoDetailOldPlayControl alloc] init];
    }else{
        self.playControl = [[TTVideoDetailNewPlayControl alloc] init];
    }
}

- (ArticleVideoPosterView *)movieShotView
{
    return self.shareMovie.posterView;
}

- (UIView *)leftBarButton
{
    return nil;
}

- (void)didMoveToParentViewController:(UIViewController *)parent
{
    [super didMoveToParentViewController:parent];
    if (parent) {
        parent.ttDragToRoot = self.detailModel.ttDragToRoot;
        //copy from TTDetailContainerViewController
        //给视频详情页加一个inset，因为现在是错误提示都贴在最外层的VC上，视频详情页顶部有个播放器的placeholder所以会重叠 -- nick add 5.7
        //hardcode一下
        parent.ttContentInset = UIEdgeInsetsMake(220,0,0,0);
    }
}

- (void)themeChanged:(NSNotification *)notification
{
    self.view.backgroundColor = [UIColor tt_themedColorForKey:kColorBackground4];
}

- (BOOL)tt_hasValidateData
{
    return NO;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if ([TTDeviceHelper isIPhoneXDevice]) {
        self.ttStatusBarStyle = UIStatusBarStyleLightContent;
    }
    
    [self.playControl viewDidLoad];
    [self _logGoDetail];
    [self buildPlaceholdView];
    [self restoreAlbumViewIfNeeded];
    [self startLoadArticleInfo];
    
    //这段代码是为了触发commentVC的viewDidLoad方法进行评论请求
    [self.commentVC view];
    
    if ([self p_needAddAlbumView]) {
        [[TTVideoAlbumHolder holder].albumView removeFromSuperview];
        [self.view addSubview:[TTVideoAlbumHolder holder].albumView];
        [TTVideoAlbumHolder holder].albumView.frame = CGRectMake(0, self.interactModel.minMovieH, self.view.width, self.view.height-self.interactModel.minMovieH);
    }
    
    TLS_LOG(@"TTVideoDetailViewController viewDidLoad with groupID %@",[self.detailModel uniqueID]);
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (!self.playControl) {
        [self initPlayControl];
        [self configPlayControl];
    }
    
    [self logEnter];
    self.tracker.viewIsAppear = YES;
    [self.tracker startStayTrack];
    [self.relatedVideoGroup sendRelatedVideoImpressionWhenNatantDidLoadIfNeeded];
    if (![TTDeviceHelper isIPhoneXDevice]) {
        [[UIApplication sharedApplication] setStatusBarHidden:YES];
    }
    [[UIApplication sharedApplication] setStatusBarStyle:self.ttStatusBarStyle == UIStatusBarStyleDefault ? [[TTThemeManager sharedInstance_tt] statusBarStyle] : self.ttStatusBarStyle];
    [self extendLinkViewControllerWillAppear];
    
    if (self.pgcView.isRecommendList) {
        [self.pgcView recommendListWillDisplay];
    }
    
    [self.playControl viewWillAppear];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (![TTDeviceHelper isIPhoneXDevice]) {
        [[UIApplication sharedApplication] setStatusBarHidden:YES];
    }
    [[UIApplication sharedApplication] setStatusBarStyle:self.ttStatusBarStyle == UIStatusBarStyleDefault ? [[TTThemeManager sharedInstance_tt] statusBarStyle] : self.ttStatusBarStyle];
    [TTVideoTip setCanShowVideoTip:YES];
    
    //5.7需求，从底部tabbar进入视频详情页后，不再需要显示气泡
    UIWindow *mainWindow = [[UIApplication sharedApplication].delegate window];
    if ([mainWindow.rootViewController isKindOfClass:[TTArticleTabBarController class]]) {
        if ([[TTTabBarProvider currentSelectedTabTag] isEqualToString:kTTTabVideoTabKey] && ![TTVideoTip hasShownVideoTip]) {
            [TTVideoTip setHasShownVideoTip:YES];
        }
    }
    _didDisAppear = NO;
    [self.playControl viewDidAppear];
    
    if (self.pgcView.isRecommendList) {
        [self.pgcView recommendListWillDisplay];
    }
    
    if ([TTDeviceHelper isPadDevice]) {
        [self layoutViews]; // fix pad rotaion bug
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if (![TTDeviceHelper isIPhoneXDevice]) {
        [[UIApplication sharedApplication] setStatusBarHidden:NO];
    }
    [self.relatedVideoGroup endRelatedVideoImpressionWhenDisappear];
    [self stayPageSendEvent3Data];
    //    endStayTrack中会清空时间，要放到后面调用
    [self.tracker sendFullStayPageWithADId:self.detailModel.adID.stringValue logExtra:self.detailModel.adLogExtra];

    self.tracker.viewIsAppear = NO;
    self.isBackAction = ![self.navigationController.viewControllers containsObject:self.parentViewController] || [self.navigationController.viewControllers containsObject:self];
    [self.playControl viewWillDisappear];
}

- (void)viewSafeAreaInsetsDidChange {
    [super viewSafeAreaInsetsDidChange];
    
    self.statusBarBackgrView.height = self.ttv_statusBarHidden ? 0 : self.view.tt_safeAreaInsets.top;
}

- (void)ttv_playerControlerPreVideoDidPlay
{
    [self _logGoDetail];
}

- (CGRect)ttv_playerControlerMovieFrame
{
    return [self frameForMovieView];
}

- (BOOL)prefersStatusBarHidden{
    return self.ttv_statusBarHidden;
}

- (BOOL)prefersHomeIndicatorAutoHidden {
    return [self.playControl isMovieFullScreen];
}

- (BOOL)shouldContinuePlayVideoWhenback
{
    return (self.isBackAction && [self isFromVideoFloat]);
}

- (BOOL)isFromVideoFloat
{
    return self.detailModel.fromSource == NewsGoDetailFromSourceVideoFloat || self.detailModel.fromSource == NewsGoDetailFromSourceVideoFloatRelated;
}

- (void)pauseMovieIfNeeded
{
    [self.playControl pauseMovieIfNeeded];
}

- (void)playMovieIfNeeded
{
    [self.playControl playMovieIfNeeded];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self.playControl viewDidDisappear];
    if (![self shouldContinuePlayVideoWhenback] && ![[TTVideoAutoPlayManager sharedManager] dataIsAutoPlaying:self.orderedData]) {
        if (!self.isDownloadAppInIOS78 && !self.isBackAction) {
            [self pauseMovieIfNeeded];
        }
    }
    self.isDownloadAppInIOS78 = NO;
    //added 5.7.*:disappear发送read_pct事件
    [self logReadPctTrack];
    _didDisAppear = YES;
    
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    if (!_didDisAppear && [self.playControl shouldLayoutSubviews]) {
        [self layoutViews];
    }
}

- (void)setFromType:(VideoDetailViewFromType)fromType
{
    _fromType = fromType;
    self.playControl.fromType = fromType;
}

- (void)_install
{
    [self buildView];
    
    [self layoutViews];
    
    [self themeChanged:nil];
    
    [self updateMovieShotView];
    [self updateToolbar];
    if (![self vdvi_shouldFiltered] && self.interactModel.minMovieH != self.interactModel.maxMovieH) {
        [self.moviewViewContainer addGestureRecognizer:self.movieContainerViewPanGes];
        [self.commentVC.commentTableView addGestureRecognizer:self.commentTableViewPanGes];
    }
}

- (void)buildView
{
    [self.view addSubview:self.moviewViewContainer];
    [self.view addSubview:self.topView];
    [self.view addSubview:self.commentVC.view];
    [self.view addSubview:self.toolbarView];
    
    if (self.commentVC.parentViewController != self) {
        [self addChildViewController:self.commentVC];
        [self.commentVC didMoveToParentViewController:self];
        
        if ([TTDeviceHelper isPadDevice]) {
            TTViewWrapper *viewWrapper = [[TTViewWrapper alloc] initWithFrame:self.view.bounds];
            viewWrapper.backgroundColorThemeKey = kColorBackground4;
            viewWrapper.targetView = self.commentVC.view;
            viewWrapper.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            [self.view insertSubview:viewWrapper atIndex:0];
            [viewWrapper addSubview:self.commentVC.view];
        }
    }
}

- (void)layoutViews
{
    [self layoutMovieShotView];
    [self.playControl layoutSubViews];
    [self layoutTopPGCView];
    [self layoutComment];
    [self layoutToolbarView];
    [self layoutRelatedVideoViewOnLandscapePadIfNeeded];
    _videoAlbum.width = self.view.width;
    _videoAlbum.height = self.view.height - [self frameForMovieView].size.height;
    _videoAlbum.bottom = self.view.height;
}

- (void)updateMovieShotView
{
    [self.movieShotView refreshWithArticle:self.detailModel.article];
}

- (void)updateToolbar
{
    self.toolbarView.collectButton.selected = self.detailModel.article.userRepined;
    self.toolbarView.commentBadgeValue = [@(self.detailModel.article.commentCount) stringValue];
}

- (void)buildPlaceholdView
{
    CGFloat topMargin = [TTDeviceHelper isIPhoneXDevice] ? 44 : 0;
    CGFloat wrapperScrollviewWidth = 0;
    if ([TTDeviceHelper isPadDevice] && [ExploreVideoDetailHelper currentVideoDetailRelatedStyle] == VideoDetailRelatedStyleDistinct) {
        wrapperScrollviewWidth = [TTUIResponderHelper windowSize].width - [self widthForContentView];
    }
    [self setTtContentInset:UIEdgeInsetsMake([self frameForMovieView].size.height + topMargin, 0, 0, wrapperScrollviewWidth)];
    [self tt_startUpdate];
    
    [self.view addSubview:self.moviewViewContainer];
    [self.view addSubview:self.topView];
    [self layoutMovieShotView];
    [self updateMovieShotView];
    
    self.statusBarBackgrView = [[SSThemedView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, self.ttv_statusBarHidden ? 0 : self.view.tt_safeAreaInsets.top)];
    self.statusBarBackgrView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:self.statusBarBackgrView];
}

- (void)restoreAlbumViewIfNeeded
{
    if ([TTVideoAlbumHolder holder].albumView) {
        self.videoAlbum = [TTVideoAlbumHolder holder].albumView;
    }
}

#pragma mark -layout

- (void)layoutMovieShotView
{
    self.moviewViewContainer.frame = [self frameForMovieContainerView];
    self.movieShotView.frame = [self frameForMovieShotView];
    [self.movieShotView refreshUI];
    if (self.movieView.superview == self.movieShotView) {
        self.movieView.frame = self.movieView.superview.bounds;
    }
    if (self.movieBanner) {
        self.movieBanner.bottom = self.moviewViewContainer.bottom;
    }
    
    if ([TTDeviceHelper isPadDevice]) {
        self.topView.left = self.movieShotView.left;
        self.topView.top = self.movieShotView.top;
    }
}

- (void)layoutTopPGCView {
    self.topPGCView.top = self.moviewViewContainer.bottom;
}

- (CGFloat)maxWidth
{
    return self.view.bounds.size.width;
}

- (void)layoutRelatedVideoViewOnLandscapePadIfNeeded
{
    if (![TTDeviceHelper isPadDevice]) {
        return;
    }
    
    self.wrapperScroller.hidden = [ExploreVideoDetailHelper currentVideoDetailRelatedStyleForMaxWidth:[self maxWidth]] == VideoDetailRelatedStyleNatant;
    self.distinctLine.hidden = self.wrapperScroller.hidden;
    
    self.natantContainerView.width = self.commentVC.view.width;
    
    if ([ExploreVideoDetailHelper currentVideoDetailRelatedStyleForMaxWidth:[self maxWidth]] == VideoDetailRelatedStyleDistinct) {
        CGSize windowSize = self.view.bounds.size;
        self.wrapperScroller.left = [self widthForContentView];
        self.wrapperScroller.width = windowSize.width - self.wrapperScroller.left;
        self.wrapperScroller.height = windowSize.height - ExploreDetailGetToolbarHeight();
        self.distinctLine.right = self.movieShotView.right;
        self.distinctLine.height = self.wrapperScroller.height;
        
        [self.natantContainerView removeObject:self.relatedVideoGroup];
        self.relatedVideoGroup.width = self.wrapperScroller.width;
        self.relatedVideoGroup.top = self.distinctNatantTitle.bottom;
        
        [self.wrapperScroller addSubview:self.relatedVideoGroup];
        [self.view addSubview:self.wrapperScroller];
        [self.view addSubview:self.distinctLine];
        
        self.wrapperScroller.contentSize = CGSizeMake(self.wrapperScroller.width, self.relatedVideoGroup.height + self.distinctNatantTitle.bottom);
        [self.relatedVideoGroup sendRelatedVideoImpressionWhenNatantDidLoadIfNeeded];
    } else {
        self.relatedVideoGroup.width = self.natantContainerView.width;
        [self.natantContainerView insertObject:self.relatedVideoGroup atIndex:2];
    }
    if ([self p_needAddAlbumView]) {
        [self.view bringSubviewToFront:[TTVideoAlbumHolder holder].albumView];
    }
}

- (void)layoutComment
{
    CGSize windowSize = self.view.bounds.size;
    CGFloat topMargin = [TTDeviceHelper isIPhoneXDevice] ? 44 : 0;
    windowSize = CGSizeMake(windowSize.width, windowSize.height - topMargin - [TTUIResponderHelper mainWindow].tt_safeAreaInsets.bottom);
    CGFloat commentViewHeight = windowSize.height - self.interactModel.minMovieH - ExploreDetailGetToolbarHeight();
    CGRect commentViewRect;
    if ([ExploreVideoDetailHelper currentVideoDetailRelatedStyleForMaxWidth:[self maxWidth]] == VideoDetailRelatedStyleNatant) {
        CGFloat commentWidth = [self widthForContentView] + ([TTDeviceHelper isPadDevice] ? kVideoDetailItemCommonEdgeMargin * 2 : 0);
        commentViewRect = CGRectMake((windowSize.width - commentWidth)/2, self.movieShotView.height + topMargin, commentWidth, commentViewHeight);
    }
    else {
        CGFloat leftMargin = 0;
        if ([TTDeviceHelper isPadDevice]) {
            leftMargin = 75 - kVideoDetailItemCommonEdgeMargin;
            if ([TTDeviceHelper isIpadProDevice]) {
                leftMargin = 100 - kVideoDetailItemCommonEdgeMargin;
            }
        }
        commentViewRect = CGRectMake(leftMargin, self.movieShotView.height + topMargin, [self widthForContentView] - leftMargin * 2, commentViewHeight);
    }
    if (self.topPGCView) {
        commentViewRect.origin.y = self.topPGCView.top + self.topPGCView.height;
        commentViewRect.size.height = commentViewHeight - self.topPGCView.height;
    }
    _commentVC.view.frame = commentViewRect;
    [self.commentVC tt_updateConstraintWidth:_commentVC.view.frame.size.width];
    //评论详情页
    CGSize movieSize = [self frameForMovieContainerView].size;
    _floatCommentVC.viewFrame = CGRectMake(0, movieSize.height, movieSize.width, self.view.height - movieSize.height);
}

- (void)layoutToolbarView
{
    self.toolbarView.left = 0;
    self.toolbarView.width = self.view.bounds.size.width;
    self.toolbarView.top = self.view.bounds.size.height - self.toolbarView.height;
}

- (CGRect)frameForMovieShotView
{
    CGFloat proportion = 9.f/16.f;
    CGSize videoAreaSize = [ExploreVideoDetailHelper videoAreaSizeForMaxWidth:[self maxWidth] areaAspect:proportion];
    BOOL result = [[[TTSettingsManager sharedManager] settingForKey:@"video_detail_flexbile_proportion_enabled" defaultValue:@NO freeze:NO] boolValue];
    if (result || [self.article isVideoSourceUGCVideoOrHuoShan]) {
        proportion = [self.article.detailVideoProportion floatValue];
        if (proportion > 0) {
            proportion = 1.f/proportion;
        }
        else
        {
            proportion = 9.f/16.f;
        }
        videoAreaSize = [ExploreVideoDetailHelper videoAreaSizeForMaxWidth:[self maxWidth] areaAspect:proportion];
        CGFloat maxHeight = ttvs_detailVideoMaxHeight();
        if (maxHeight > 0 && videoAreaSize.height > maxHeight){//如果视频高度大于允许的最大高度
            videoAreaSize.height = maxHeight;
        }
        self.interactModel.minMovieH = ceilf([self maxWidth] * 9.f / 16.f);
        self.interactModel.maxMovieH = videoAreaSize.height;
    } else {
        self.interactModel.minMovieH = ceilf([self maxWidth] * proportion);
        self.interactModel.maxMovieH = ceilf([self maxWidth] * proportion);
    }
    if ([TTDeviceHelper isPadDevice]) {
        videoAreaSize = [ExploreVideoDetailHelper videoAreaSizeForMaxWidth:[self maxWidth] areaAspect:proportion];
        CGFloat maxHeight = ttvs_detailVideoMaxHeight();
        if (maxHeight > 0 && videoAreaSize.height > maxHeight){//如果视频高度大于允许的最大高度
            videoAreaSize.height = maxHeight;
        }
        self.interactModel.minMovieH = videoAreaSize.height;
        self.interactModel.maxMovieH = videoAreaSize.height;
        self.interactModel.curMovieH = videoAreaSize.height;
    }
    if (!self.interactModel.curMovieH) {
        if (self.beginShowComment) { //点击评论按钮进入，默认显示16：9
            self.interactModel.curMovieH = self.interactModel.minMovieH;
        } else {
            self.interactModel.curMovieH = self.interactModel.maxMovieH;
        }
        if ([self vdvi_shouldFiltered]) { //默认16:9
            self.interactModel.curMovieH = self.interactModel.minMovieH;
        }
    }
    if ([ExploreVideoDetailHelper currentVideoDetailRelatedStyleForMaxWidth:[self maxWidth]] == VideoDetailRelatedStyleNatant) {
        return CGRectMake((self.view.bounds.size.width - videoAreaSize.width)/2, 0, videoAreaSize.width, self.interactModel.curMovieH);
    } else {
        return CGRectMake(0, 0, videoAreaSize.width, self.interactModel.curMovieH);
    }
}

- (CGRect)frameForMovieView
{
    CGSize size = [self frameForMovieShotView].size;
    return CGRectMake(0, 0, size.width, size.height);
}

- (CGRect)frameForMovieContainerView
{
    CGFloat topMargin = [TTDeviceHelper isIPhoneXDevice] ? 44.0f : 0.0f;
    if ([ExploreVideoDetailHelper currentVideoDetailRelatedStyleForMaxWidth:[self maxWidth]] == VideoDetailRelatedStyleNatant) {
        return CGRectMake(0, topMargin, [self maxWidth], [self frameForMovieShotView].size.height);
    } else {
        CGRect frame = [self frameForMovieShotView];
        return CGRectMake(0, topMargin, frame.size.width, frame.size.height);
    }
}

- (CGFloat)widthForContentView
{
    CGSize windowSize = self.view.bounds.size;
    if ([ExploreVideoDetailHelper currentVideoDetailRelatedStyleForMaxWidth:[self maxWidth]] == VideoDetailRelatedStyleNatant) {
        return windowSize.width - [TTUIResponderHelper paddingForViewWidth:windowSize.width] * 2;
    } else {
        return [self frameForMovieShotView].size.width;
    }
}

- (CGFloat)containerWidth
{
    CGFloat containerWidth;
    
    if ([ExploreVideoDetailHelper currentVideoDetailRelatedStyleForMaxWidth:[self maxWidth]] == VideoDetailRelatedStyleNatant) {
        containerWidth = [self widthForContentView] + ([TTDeviceHelper isPadDevice] ? kVideoDetailItemCommonEdgeMargin * 2 : 0);
    } else {
        CGFloat leftMargin = 0;
        if ([TTDeviceHelper isPadDevice]) {
            leftMargin = 75 - kVideoDetailItemCommonEdgeMargin;
            if ([TTDeviceHelper isIpadProDevice]) {
                leftMargin = 100 - kVideoDetailItemCommonEdgeMargin;
            }
        }
        containerWidth = [self widthForContentView] - leftMargin * 2;
    }
    return containerWidth;
}

#pragma mark Model update

- (NSNumber *)adid
{
    NSNumber *adID = nil;
    if (self.fromType == VideoDetailViewFromTypeCategory) {
        ExploreOrderedData *orderedData = [self orderedData];
        adID = @([orderedData.ad_id longLongValue]);
    } else if (self.fromType == VideoDetailViewFromTypeRelated) {
        adID = self.detailModel.article.relatedVideoExtraInfo[kArticleInfoRelatedVideoAdIDKey];
    }
    
    if (!adID) {
        adID = self.detailModel.adID;
    }
    return adID;
}

- (void)startLoadArticleInfo
{
    //调用info接口获取相关视频等
    [self.infoManager cancelAllRequest];
    
    Article *article = self.detailModel.article;
    NSString *cateoryID = self.detailModel.categoryID;
    
    NSMutableDictionary * condition = [NSMutableDictionary dictionaryWithCapacity:10];
    [condition setValue:article.groupModel forKey:kArticleInfoManagerConditionGroupModelKey];
    if ([[article.comment allKeys] containsObject:@"comment_id"]) {
        [condition setValue:[article.comment objectForKey:@"comment_id"] forKey:kArticleInfoManagerConditionTopCommentIDKey];
    }
    
    NSString *videoSubjectID = [self.article videoSubjectID];
    if (videoSubjectID && [self.detailModel isFromList]) {
        condition[kArticleInfoRelatedVideoSubjectIDKey] = videoSubjectID;
    }
    
    // 转载推荐评论ids
    NSString *zzCommentsID = [article zzCommentsIDString];
    if (!isEmptyString(zzCommentsID)) {
        [condition setValue:zzCommentsID forKey:@"zzids"];
    }
    
    NSNumber *adID = [self adid];
    
    if ([adID longLongValue] > 0) {
        self.isADVideo = YES;
        NSString *adIDString = [NSString stringWithFormat:@"%lld", [adID longLongValue]];
        [condition setValue:adIDString forKey:@"ad_id"];
    }else{
        self.isADVideo = NO;
    }
    
    NSString* log_extra = nil;
    
    if (self.fromType == VideoDetailViewFromTypeRelated) {
        log_extra = article.relatedVideoExtraInfo[kArticleInfoRelatedVideoLogExtraKey];
    }
    
    if (isEmptyString(log_extra)) {
        log_extra = self.detailModel.adLogExtra;
    }
    
    if (!isEmptyString(log_extra)) {
        [condition setValue:log_extra forKey:@"log_extra"];
    }
    
    [condition setValue:cateoryID forKey:kArticleInfoManagerConditionCategoryIDKey];
    [condition setValue:self.detailModel.clickLabel forKey:@"from"];
    [condition setValue:@(0x40) forKey:@"flags"];
    [condition setValue:@(1) forKey:@"article_page"];
    [self.infoManager startFetchArticleInfo:condition];
}

- (void)_buildNatantWithManager:(ArticleInfoManager *)manager
{
    CGFloat containerWidth = [self containerWidth];
    self.buildInfoManager = manager;
    Article *article = self.detailModel.article;
    
    NSMutableArray *natantViewArray = [[NSMutableArray alloc] init];
    id<TTAdFeedModel> adModel = article.adModel;
    if ([adModel isCreativeAd] && ![adModel.type isEqualToString:@"web"]) {
        TTDetailNatantVideoADView *embededAD = [[TTDetailNatantVideoADView alloc] initWithWidth:containerWidth];
        embededAD.data = self.orderedData;
        self.embededAD = embededAD;
        if (self.startImpression) {
            [self.commentVC.commentTableView tt_endImpression];
        }
        [self.commentVC.commentTableView tt_addImpressionView:embededAD];
        [self.commentVC.commentTableView tt_startImpression];
        self.startImpression = YES;
        [natantViewArray addObject:embededAD];
    }
    
    TTDetailNatantVideoInfoView *infoView = [[TTDetailNatantVideoInfoView alloc] initWithWidth:containerWidth];
    infoView.delegate = self;
    if (ttvs_isVideoShowOptimizeShare() > 0 && !self.isADVideo) {
        infoView.isShowShare = YES;
    }
    infoView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    if (infoView) {
        [natantViewArray addObject:infoView];
    }
    
    TTVideoDetailSearchTagPosition tagPosition = TTVideoDetailSearchTagPositionUnknown;
    if (!SSIsEmptyDictionary(manager.video_detail_tags)) {
        tagPosition = [manager.video_detail_tags tt_integerValueForKey:@"video_searchtag_position"];
        if (tagPosition == TTVideoDetailSearchTagPositionTop) {
            [self _addTagsViewWithNatantViewArray:natantViewArray containerWidth:containerWidth tagPosition:tagPosition];
        }
    }
    
    if (manager.videoBanner) {
        TTVideoBannerModel *viewModel = [[TTVideoBannerModel alloc] initWithDictionary:manager.videoBanner error:nil];
        if ([viewModel inValid]) {
            
            if ([TTThemeManager sharedInstance_tt].currentThemeMode != TTThemeModeNight) {
                TTDetailNatantVideoBanner *banner = [[TTDetailNatantVideoBanner alloc] initWithWidth:containerWidth];
                banner.groupID = [self.detailModel uniqueID];
                banner.autoresizingMask = UIViewAutoresizingFlexibleWidth;
                banner.edgeInsets = UIEdgeInsetsMake(9, 0, 12, 0);
                
                WeakSelf;
                banner.relayOutBlock = ^(BOOL animated) {
                    StrongSelf;
                    [self.view setNeedsLayout];
                };
                
                banner.viewModel = viewModel;
                
                [natantViewArray addObject:banner];
                
                TTVideoBannerType type = [viewModel getTTVideoBannerType];
                switch (type) {
                    case TTVideoBannerTypeWebDetail:
                    {
                        if (viewModel.appName && banner.groupID) {
                            [TTTrackerWrapper eventV3:@"video_banner_subscribe_show_h5page" params:@{@"app" : viewModel.appName, @"group_id": banner.groupID}];
                        }
                    }
                        break;
                    case TTVideoBannerTypeOpenApp:
                    {
                        if (viewModel.appName) {
                            wrapperTrackEventWithCustomKeys(@"video_banner", @"subscribe_show_jump", [self.detailModel uniqueID], nil, @{@"app" : viewModel.appName});
                        }
                    }
                        break;
                    case TTVideoBannerTypeDownloadApp:
                    {
                        if (viewModel.appName) {
                            wrapperTrackEventWithCustomKeys(@"video_banner", @"subscribe_show_download", [self.detailModel uniqueID], nil, @{@"app" : viewModel.appName});
                        }
                    }
                        break;
                    default:
                        break;
                }
            }
            
            self.movieBanner.viewModel = viewModel;
            self.movieBanner.groupID = [self.detailModel uniqueID];
            [self.view addSubview:self.movieBanner];
        }
    } else {
        NSString *contentID = [self p_contentID];
        if ([[article.videoDetailInfo objectForKey:VideoInfoShowPGCSubscribeKey] boolValue] &&
            !isEmptyString(contentID)) {
            if ([self p_shouldShowTopPGCView]) {
                //防止topView被多次创建，被多层叠加
                if (!self.topPGCView) {
                    self.topPGCView = [[TTDetailNatantVideoPGCView alloc] initWithWidth:containerWidth];
                }
                self.topPGCView.onTop = YES;
                [self.view addSubview:self.topPGCView];
                self.topPGCView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
//                self.topPGCView.redpacketModel = self.infoManager.activity.redpack;
                if (self.detailModel.orderedData.logPb){
                    self.topPGCView.logPb = self.detailModel.orderedData.logPb;
                }else if (self.detailModel.logPb){
                    self.topPGCView.logPb = self.detailModel.logPb;
                }else{
                    self.topPGCView.logPb = self.detailModel.gdExtJsonDict[@"log_pb"];
                }
                self.topPGCView.enterFrom = [self enterFrom];
                self.topPGCView.categoryName = [self categoryName];
                [self.topPGCView refreshWithArticle:article];
                self.topPGCView.bottomLine.hidden = YES;
            } else {
                self.pgcView = [[TTDetailNatantVideoPGCView alloc] initWithWidth:containerWidth];
                if (self.pgcView) {
                    self.pgcView.delegate = self;
                    self.pgcView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
//                    self.pgcView.redpacketModel = self.infoManager.activity.redpack;
                    self.pgcView.logPb = self.detailModel.orderedData.logPb;
                    self.pgcView.enterFrom = [self enterFrom];
                    self.pgcView.categoryName = [self categoryName];
                    [self.pgcView refreshWithArticle:article];
                    [natantViewArray addObject:self.pgcView];
                }
            }
        }
    }
    
    if (manager.relateVideoArticles.count > 0) {
        if ([SSCommonLogic videoDetailRelatedStyle] == 2) { // 双列
            self.relatedVideoGroup = [[TTDetailNatantRelatedVideoNewGroupView alloc] initWithWidth:containerWidth];
            
        } else {
            self.relatedVideoGroup = [[TTDetailNatantRelatedVideoGroupView alloc] initWithWidth:containerWidth];
        }
        
        self.relatedVideoGroup.delegate = self;
        
        if ([self.detailModel isFromList] && ![self shouldBeginShowComment]) {
            for (NSDictionary *relatedVideoDict in manager.relateVideoArticles) {
                Article *article = nil;
                if ([relatedVideoDict valueForKey:@"article"]) {
                    article = relatedVideoDict[@"article"];
                    if ([article shouldDirectShowVideoSubject]) {
                        [self didSelectVideoAlbum:article];
                        break;
                    }
                }
            }
        }
        
        [natantViewArray addObject:self.relatedVideoGroup];
        if (tagPosition == TTVideoDetailSearchTagPositionBelowRelatedVideo) {
            [self _addTagsViewWithNatantViewArray:natantViewArray containerWidth:containerWidth tagPosition:tagPosition];
        }
    }
    
    if ([self p_needAddAlbumView]) {
        [self.view bringSubviewToFront:[TTVideoAlbumHolder holder].albumView];
    }
   
    //增加浮层广告去重
    NSDictionary *adData = manager.ordered_info[kDetailNatantAdsKey];
    NSAssert(!adData || [adData isKindOfClass:[NSDictionary class]], @"广告浮层广告数据解析错误");
    if (adData.count > 0 && [[self isNeedShowNatantADView:manager withAdData:adData] boolValue]) {
        CGFloat leftMargin = [TTDeviceHelper isPadDevice] ? 20 : 15;
        
        BOOL showPadding = [TTAdDetailViewHelper detailBannerIsUnityAd:adData] && (![TTDeviceHelper isPadDevice]);
        if (showPadding == YES) {
            UIView* topPaddingView = [TTAdManageInstance video_detailBannerPaddingView:containerWidth topLineShow:NO bottomLineShow:YES];
            [natantViewArray addObject:topPaddingView];
        }
        
        TTVideoDetailADContainerView* adContainer = [[TTVideoDetailADContainerView alloc] initWithWidth:containerWidth - leftMargin*2];
        adContainer.left = leftMargin;
        adContainer.delegate = self;
        adContainer.isVideoAd = YES;
        adContainer.edgeInsets = UIEdgeInsetsMake(4, leftMargin, 4, leftMargin);
        adContainer.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        
        TTAdDetailViewModel *viewModel = [TTAdDetailViewModel new];
        viewModel.article = article;
        adContainer.viewModel = viewModel;
        viewModel.fromSource = 1;

        [natantViewArray addObject:adContainer];
        
        if (showPadding == YES) {
            UIView* bottomPaddingView = [TTAdManageInstance video_detailBannerPaddingView:containerWidth topLineShow:YES bottomLineShow:YES];
            [natantViewArray addObject:bottomPaddingView];
        }
    } else {
        [self.relatedVideoGroup enableBottomLine:YES];
    }
    
    if ([manager.adminDebugInfo count] > 0) {
        CGFloat edgePadding = 15.f;
        ExploreDetailTextlinkADView *adminDebugView = [[ExploreDetailTextlinkADView alloc] initWithWidth:containerWidth - edgePadding*2];
        adminDebugView.left = edgePadding;
        [natantViewArray addObject:adminDebugView];
    }
    
    if (tagPosition == TTVideoDetailSearchTagPositionAboveComment) {
        [self _addTagsViewWithNatantViewArray:natantViewArray containerWidth:containerWidth tagPosition:tagPosition];
    }
    
    if (self.topPGCView) {
        infoView.intensifyAuthor = YES;
    }
    
    self.natantContainerView.items = natantViewArray;
    [self.natantContainerView reloadData:manager];
    if (self.topPGCView) {
        [infoView showBottomLine];
    }
    self.relatedVideoGroup.referHeight = self.commentVC.commentTableView.height;
    [self.relatedVideoGroup sendRelatedVideoImpressionWhenNatantDidLoadIfNeeded];
}

- (void)_addTagsViewWithNatantViewArray:(NSMutableArray *)natantViewArray containerWidth:(CGFloat)containerWidth tagPosition:(TTVideoDetailSearchTagPosition)tagPosition {
    TTDetailNatantVideoTagsView *tagView = [[TTDetailNatantVideoTagsView alloc] initWithWidth:containerWidth];
    tagView.tagPosition = tagPosition;
    tagView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [natantViewArray addObject:tagView];
    _tagsView = tagView;
}


- (void)removeNatantView:(TTDetailNatantViewBase *)natantView animated:(BOOL)animated {
    NSString *className = NSStringFromClass([natantView class]);
    NSMutableArray* array = [NSMutableArray arrayWithArray:self.natantContainerView.items];
    [array enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:NSClassFromString(className)]) {
            
            NSInteger index = [self.natantContainerView.items indexOfObject:obj];
            
            //删除bottomPadding
            if (self.natantContainerView.items.count > index + 1) {
                TTVideoDetailBannerPaddingView* spaceBottomItem = (TTVideoDetailBannerPaddingView*)self.natantContainerView.items[index + 1];
                if (spaceBottomItem && [spaceBottomItem isKindOfClass:[TTVideoDetailBannerPaddingView class]]) {
                    [self.natantContainerView removeObject:spaceBottomItem];
                    [spaceBottomItem removeFromSuperview];
                }
            }
            
            //删除topPadding
            if (self.natantContainerView.items.count > index - 1) {
                TTVideoDetailBannerPaddingView* spaceTopItem = (TTVideoDetailBannerPaddingView*)self.natantContainerView.items[index - 1];
                if (spaceTopItem && [spaceTopItem isKindOfClass:[TTVideoDetailBannerPaddingView class]]) {
                    [self.natantContainerView removeObject:spaceTopItem];
                    [spaceTopItem removeFromSuperview];
                }
            }
            
            //删除adContaniner
            [self.natantContainerView removeObject:obj];
            [(UIView*)obj removeFromSuperview];
            *stop = YES;
        }
        
    }];
    
}


#pragma mark - TTDetailNatantVideoPGCViewDelegate
- (void)videoPGCViewClearRedpacket
{
//    self.infoManager.activity.redpack = nil;
}

- (void)updateRecommendView {
    
    if (self.pgcView.changedViewHeight != self.pgcView.originViewHeight) {
        int i = 0;
        for (TTDetailNatantViewBase *viewBase in self.natantContainerView.items) {
            if ([viewBase isKindOfClass:[TTDetailNatantVideoPGCView class]]) {
                break;
            }
            i++;
        }
        
        if (self.pgcView.changedViewHeight > self.pgcView.originViewHeight) {
            //PM需求，再次展开，回滚到first cell
            CGPoint topOffest = CGPointMake(-self.pgcView.collectionView.contentInset.left, 0);
            [self.pgcView.collectionView setContentOffset:topOffest animated:NO];
            
            CGFloat diff = ceil(self.pgcView.changedViewHeight - self.pgcView.originViewHeight);
            self.pgcView.bottomLine.alpha = 0;
            [UIView animateWithDuration:0.4f animations:^{
                //                [self.commentVC.commentTableView beginUpdates];  bugfix #250190 by lijun
                self.pgcView.height += diff;
                for (int j = i + 1; j < self.natantContainerView.items.count; j++) {
                    TTDetailNatantViewBase *viewBase = [self.natantContainerView.items objectAtIndex:j];
                    viewBase.top += diff;
                }
                self.commentVC.commentTableView.tableHeaderView.height += diff;
                //                [self.commentVC.commentTableView endUpdates];  bugfix #250190 by lijun
            }];
            self.pgcView.isRecommendList = YES;
            self.pgcView.detectTop = YES;
            self.pgcView.detectBottom = YES;
            [self.pgcView recommendListWillDisplay];
            self.pgcView.arrowTag.hidden = NO;
            self.pgcView.recommendLabel.hidden = NO;
            self.pgcView.collectionView.hidden = NO;
            self.pgcView.recommendLabel.alpha = 0;
            self.pgcView.collectionView.alpha = 0;
            self.pgcView.arrowTag.alpha = 0;
            [UIView animateWithDuration:0.25f delay:0.15f options:UIViewAnimationOptionCurveEaseInOut animations:^{
                self.pgcView.recommendLabel.alpha = 1;
                self.pgcView.collectionView.alpha = 1;
                self.pgcView.arrowTag.alpha = 1;
                self.pgcView.bottomLine.alpha = 1;
            } completion:^(BOOL finished) {
            }];
        }
        else {
            CGFloat diff = ceil(self.pgcView.originViewHeight - self.pgcView.changedViewHeight);
            self.pgcView.bottomLine.alpha = 0;
            [UIView animateWithDuration:0.4f animations:^{
                //                [self.commentVC.commentTableView beginUpdates];  bugfix #250190 by lijun
                self.pgcView.height -= diff;
                for (int j = i + 1; j < self.natantContainerView.items.count; j++) {
                    TTDetailNatantViewBase *viewBase = [self.natantContainerView.items objectAtIndex:j];
                    viewBase.top -= diff;
                }
                self.commentVC.commentTableView.tableHeaderView.height -= diff;
                //                [self.commentVC.commentTableView endUpdates]; bugfix #250190 by lijun
            }];
            self.pgcView.isRecommendList = NO;
            self.pgcView.detectTop = NO;
            self.pgcView.detectBottom = NO;
            [self.pgcView recommendListEndDisplay];
            [UIView animateWithDuration:0.25f delay:0.15f options:UIViewAnimationOptionCurveEaseInOut animations:^{
                self.pgcView.recommendLabel.alpha = 0;
                self.pgcView.collectionView.alpha = 0;
                self.pgcView.arrowTag.alpha = 0;
                self.pgcView.bottomLine.alpha = 1;
            } completion:^(BOOL finished) {
                self.pgcView.recommendLabel.alpha = 1;
                self.pgcView.collectionView.alpha = 1;
                self.pgcView.arrowTag.alpha = 1;
                self.pgcView.arrowTag.hidden = YES;
                self.pgcView.recommendLabel.hidden = YES;
                self.pgcView.collectionView.hidden = YES;
            }];
        }
    }
    
}


#pragma mark Observer

- (void)addKVO
{
    if (!self.registeredKVO) {
        __weak typeof(self) wself = self;
        [self.KVOController observe:self.detailModel.article keyPath:@keypath(self.detailModel.article,userRepined) options:NSKeyValueObservingOptionNew block:^(id observer, id object, NSDictionary *change) {
            __strong typeof(wself) self = wself;
            [self updateToolbar];
        }];

        [self.KVOController observe:self.detailModel.article keyPath:@keypath(self.detailModel.article, commentCount) options:NSKeyValueObservingOptionNew block:^(id  _Nullable observer, id  _Nonnull object, NSDictionary<NSString *,id> * _Nonnull change) {
            __strong typeof(wself) self = wself;
            [self updateToolbar];
        }];

        [self.KVOController observe:self.relatedVideoGroup keyPath:NSStringFromSelector(@selector(frame)) options:NSKeyValueObservingOptionNew block:^(id observer, id object, NSDictionary *change) {
            __strong typeof(wself) self = wself;
            self.wrapperScroller.contentSize = CGSizeMake(self.wrapperScroller.width, self.relatedVideoGroup.height + self.distinctNatantTitle.bottom);
        }];
        
        self.registeredKVO = YES;
    }
    
}

- (void)addObserver
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveDidEnterBackgroundNotification:) name:UIApplicationDidEnterBackgroundNotification  object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveWillEnterForegroundNotification:) name:UIApplicationWillEnterForegroundNotification  object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(releatedVideoCliced:) name:@"kRelatedClickedNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateMomentCountOfComment:) name:ArticleMomentDetailViewAddMomentNoti object:nil];
    [self el_addObserver];
}

- (void)removeObserver
{
    [self el_removeObserver];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)releatedVideoCliced:(NSNotification *)notification
{
    BOOL deallocMovie = NO;
    if ([[[notification userInfo] valueForKey:@"deallocMovie"] isKindOfClass:[NSNumber class]]) {
        NSNumber *value = [[notification userInfo] valueForKey:@"deallocMovie"];
        if ([value boolValue]) {
            deallocMovie = YES;
        }
    }
    if ([self isFromVideoFloat]) {
        deallocMovie = YES;
    }
    if (deallocMovie)
    {
        [self.playControl releatedVideoCliced];
        self.playControl = nil;
        self.shareMovie.movieView = nil;
    }
    self.shareMovie.hasClickRelated = YES;
}

- (void)receiveDidEnterBackgroundNotification:(NSNotification *)notification
{
    [self stayPageSendEvent3Data];
    
    //added 5.7.*:退到后台发送read_pct事件
    if (!_didDisAppear) {
        [self logReadPctTrack];
    }
}

- (void)receiveWillEnterForegroundNotification:(NSNotification *)notification
{
    [self.tracker startStayTrack];
}

#pragma mark -
#pragma YSWebViewDelegate

- (void)webViewDidStartLoad:(nullable YSWebView *)webView{}
- (void)webViewDidFinishLoad:(nullable YSWebView *)webView{}
- (void)webView:(nullable YSWebView *)webView didFailLoadWithError:(nullable NSError *)error{}
- (BOOL)webView:(nullable YSWebView *)webView shouldStartLoadWithRequest:(nullable NSURLRequest *)request navigationType:(YSWebViewNavigationType)navigationType{return NO;}

#pragma mark -
#pragma mark actions

- (void)_topViewBackButtonPressed
{
    self.isBackAction = YES;
    self.clickedBackBtn = YES;
    NSInteger index = [self topViewControllerIndexWithNoneDragToRoot];
    [self.navigationController popToViewController:self.navigationController.viewControllers[index] animated:YES];
}

- (void)backAction
{
    [self _topViewBackButtonPressed];
}

- (void)_writeCommentActionFired:(id)sender {
    BOOL switchToEmojiInput = (sender == self.toolbarView.emojiButton);
    if (switchToEmojiInput) {
        [TTTrackerWrapper eventV3:@"emoticon_click" params:@{
            @"status" : @"no_keyboard",
            @"source" : @"comment"
        }];
    }

    if ([self.commentVC respondsToSelector:@selector(tt_defaultReplyCommentModel)] && self.commentVC.tt_defaultReplyCommentModel) {
        [self tt_commentViewController:nil shouldPresentCommentDetailViewControllerWithCommentModel:self.commentVC.tt_defaultReplyCommentModel indexPath:[NSIndexPath indexPathForRow:0 inSection:0] showKeyBoard:NO];

        if ([self.commentVC respondsToSelector:@selector(tt_clearDefaultReplyCommentModel)]) {
            [self.commentVC tt_clearDefaultReplyCommentModel];
        }
        [self.toolbarView.writeButton setTitle:@"写评论" forState:UIControlStateNormal];
        return;
    }

    [self _openCommentWithText:nil switchToEmojiInput:switchToEmojiInput];
    [self logClickWriteComment];
}

- (void)_showCommentActionFired
{
    self.isCommentButtonClicked = YES;
    self.enableScrollToChangeShowStatus = NO;
    [self _switchShowStatusAnimated:YES isButtonClicked:YES];
    
    if (self.showStatus == VideoDetailViewShowStatusVideo) {
        self.showStatus = VideoDetailViewShowStatusComment;
    } else {
        self.showStatus = VideoDetailViewShowStatusVideo;
    }
    [self vdvi_changeMovieSizeWithStatus:self.showStatus];
}

- (void)_collectActionFired
{
    if (!TTNetworkConnected()){
        [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage
                                  indicatorText:NSLocalizedString(@"没有网络连接", nil)
                                 indicatorImage:[UIImage themedImageNamed:@"close_popup_textpage.png"]
                                    autoDismiss:YES
                                 dismissHandler:nil];
        return;
    }
    
    self.toolbarView.collectButton.imageView.contentMode = UIViewContentModeCenter;
    self.toolbarView.collectButton.imageView.transform = CGAffineTransformMakeScale(1.f, 1.f);
    self.toolbarView.collectButton.alpha = 1.f;
    [UIView animateWithDuration:0.1f delay:0.f options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.toolbarView.collectButton.imageView.transform = CGAffineTransformMakeScale(0.6f, 0.6f);
        self.toolbarView.collectButton.alpha = 0.f;
    } completion:^(BOOL finished){
        [self _triggerFavoriteAction];
        [UIView animateWithDuration:0.2f delay:0.f options:UIViewAnimationOptionCurveEaseIn animations:^{
            self.toolbarView.collectButton.imageView.transform = CGAffineTransformMakeScale(1.f, 1.f);
            self.toolbarView.collectButton.alpha = 1.f;
        } completion:nil];
    }];
}

- (void)_shareActionFired {
    
    NSMutableArray * activityItems = @[].mutableCopy;
    if ([self.infoManager needShowAdShare]) {
        NSMutableDictionary *shareInfo = [self.infoManager makeADShareInfo];
        activityItems = [ArticleShareManager shareActivityManager:self.activityActionManager shareInfo:shareInfo showReport:YES];
    } else {
        activityItems = [ArticleShareManager shareActivityManager:self.activityActionManager setArticleCondition:self.detailModel.article adID:self.detailModel.adID showReport:YES];
    }
    
    //当视频是ugc视频时将举报按钮替换成删除按钮
    NSString *uid = [[self userInfo] stringValueForKey:@"user_id" defaultValue:nil];
    NSString *accountUserID = [TTAccountManager userID];
    if (!isEmptyString(uid) && !isEmptyString(accountUserID) && [uid isEqualToString:accountUserID]) { //ugc视频
        [activityItems enumerateObjectsUsingBlock:^(TTActivity *obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (obj.activityType == TTActivityTypeReport) {
                [activityItems replaceObjectAtIndex:idx withObject:[TTActivity activityOfDelete]];
                *stop = YES;
            }
        }];
    }
    
    if (self.activityActionManager.useDefaultImage) {
        UIImage *image = [self.movieShotView logoImage];
        if (image) {
            self.activityActionManager.shareImage = image;
            // 原来搜索视频分享到朋友圈，没有设置image，导致分享视频icon是默认image。点击搜索视频，进入视频点击分享后，设置分享到朋友圈的image
            self.activityActionManager.shareToWeixinMomentOrQZoneImage = image;
            self.activityActionManager.systemShareImage = image;
        }
    }
    
    if (self.infoManager.promotionModel) {
        TTActivity *promtionActivity = [TTActivity activityWithModel:self.infoManager.promotionModel];
        [activityItems insertObject:promtionActivity atIndex:0];
        wrapperTrackEventWithCustomKeys(@"share_btn", @"show", self.detailModel.article.groupModel.groupID, nil, nil);
    }
    
    SSActivityView *phoneShareView = [[SSActivityView alloc] init];
    
    phoneShareView.delegate = self;
    phoneShareView.activityItems = activityItems;
    //分享板广告在视频广告详情页不出ad
    if ([self.playControl isMovieFullScreen]) {
        [TTAdManageInstance share_showInAdPage:@"1" groupId:self.detailModel.article.groupModel.groupID];
    }else{
        [TTAdManageInstance share_showInAdPage:self.detailModel.adID.stringValue groupId:self.detailModel.article.groupModel.groupID];
    }
    [phoneShareView showOnViewController:[TTUIResponderHelper topViewControllerFor: self] useShareGroupOnly:NO isFullScreen:[self.playControl isMovieFullScreen]];
    self.phoneShareView = phoneShareView;
}

- (void)toolBarshareDidPress {
    [self _shareActionFired];
    //点击分享按钮统计
    self.activityActionManager.clickSource = @"detail_bottom_bar";
    [TTVideoCommon setCurrentFullScreen:[self.playControl isMovieFullScreen]];
    [self sendVideoShareTrackWithItemType:TTActivityTypeShareButton andSectionType:TTActivitySectionTypeDetailBottomBar];
}

- (void)_moreButtonDidPress {
    
    Article *article = self.detailModel.article;
    
    [_activityActionManager clearCondition];
    if (!_activityActionManager) {
        self.activityActionManager = [[TTActivityShareManager alloc] init];
        self.activityActionManager.delegate = self;
        self.activityActionManager.isVideoSubject = YES;
        self.activityActionManager.authorId = [self.detailModel.article.userInfo ttgc_contentID];
    }
    
    NSNumber *adID = self.detailModel.adID;
    NSMutableArray * activityItems = [ArticleShareManager shareActivityManager:_activityActionManager setArticleCondition:article adID:adID showReport:YES];
    
    NSMutableArray *group1 = [NSMutableArray array];
    NSMutableArray *group2 = [NSMutableArray array];
    
    //头条号icon,放最后
    NSString * avatarUrl = nil;
    NSString * name = nil;
    NSString *msgKey = @"关注";
    
    if ([article.mediaInfo isKindOfClass:[NSDictionary class]] ) {
        avatarUrl = article.mediaInfo[@"avatar_url"];
        
        if (article.isSubscribe.boolValue) {
            name = [NSString stringWithFormat:@"取消%@",msgKey];
        }
        else {
            name = msgKey;
        }
    }
    
    BOOL hidePGCActivity = [article hasVideoSubjectID] || !article.mediaInfo || isEmptyString(avatarUrl) || isEmptyString(name);
    hidePGCActivity = YES;// 新样式不显示关注
    if (!hidePGCActivity) {
        TTActivity *pgcActivity = [TTActivity activityOfPGCWithAvatarUrl:avatarUrl showName:name];
        [group2 addObject:pgcActivity];
    }
    
    // 收藏
    TTActivity * favorite = [TTActivity activityOfVideoFavorite];
    favorite.selected = article.userRepined;
    [group2 addObject:favorite];
    
    //顶踩
    NSString *diggCount = [NSString stringWithFormat:@"%@",@(article.diggCount)];
    if ([article.banDigg boolValue]) {
        if (article.userDigg) {
            diggCount = @"1";
        }
        else{
            diggCount = @"0";
        }
    }
    TTActivity *digUpActivity = [TTActivity activityOfDigUpWithCount:diggCount];
    digUpActivity.selected = article.userDigg;
    [group2 addObject:digUpActivity];
    
    NSString *buryCount = [NSString stringWithFormat:@"%@",@(article.buryCount)];
    if ([article.banBury boolValue]) {
        if (article.userBury) {
            buryCount = @"1";
        }
        else{
            buryCount = @"0";
        }
    }
    TTActivity *digDownActivity = [TTActivity activityOfDigDownWithCount:buryCount];
    digDownActivity.selected = article.userBury;
    [group2 addObject:digDownActivity];
    
    //当视频是ugc视频时将举报按钮替换成删除按钮
    NSString *uid = [[article userInfo] stringValueForKey:@"user_id" defaultValue:nil];
    if (!isEmptyString(uid) && !isEmptyString([TTAccountManager userID]) && [uid isEqualToString:[TTAccountManager userID]]) { //ugc视频
        [activityItems enumerateObjectsUsingBlock:^(TTActivity *obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (obj.activityType == TTActivityTypeReport) {
                [activityItems replaceObjectAtIndex:idx withObject:[TTActivity activityOfDelete]];
                *stop = YES;
            }
        }];
    }
    
    //分开放，举报放最后边
    for (TTActivity *activity in activityItems) {
        if (activity.activityType == TTActivityTypeReport || activity.activityType == TTActivityTypeDetele) {
            [group2 addObject:activity];
        }
        else {
            [group1 addObject:activity];
        }
    }
    
    SSActivityView *phoneShareView = [[SSActivityView alloc] init];
    phoneShareView.delegate = self;
    if ([self.playControl isMovieFullScreen]) {
        [TTAdManageInstance share_showInAdPage:@"1" groupId:self.detailModel.article.groupModel.groupID];
    }else{
        [TTAdManageInstance share_showInAdPage:self.detailModel.orderedData.ad_id groupId:self.detailModel.article.groupModel.groupID];
    }
    //视频特卖 放第一位置
    if ([self showCommodity]) {
        [group2 insertObject:[TTActivity activityOfVideoCommodity] atIndex:0];
    }
    [phoneShareView showActivityItems:@[group1, group2] isFullSCreen: [self.playControl isMovieFullScreen]];
    self.phoneShareView = phoneShareView;
    if (self.detailModel.article) {
        NSMutableDictionary * eventContext = [[NSMutableDictionary alloc] init];
        [eventContext setValue:[@(self.detailModel.article.uniqueID) stringValue] forKey:@"group_id"];
        [eventContext setValue:self.detailModel.article.itemID forKey:@"item_id"];
        [eventContext setValue:[article.mediaInfo[@"media_id"] stringValue] forKey:@"media_id"];
        wrapperTrackEvent(@"list_content", @"share_channel");
    }
}

- (void)_openCommentWithText:(NSString *)text switchToEmojiInput:(BOOL)switchToEmojiInput {
    Article *article = self.detailModel.article;
    [NewsDetailLogicManager trackEventTag:@"detail" label:@"write_button" value:@(article.uniqueID) extValue:self.detailModel.adID groupModel:article.groupModel];

    NSMutableDictionary * condition = [NSMutableDictionary dictionaryWithCapacity:10];
    [condition setValue:article.groupModel forKey:kQuickInputViewConditionGroupModel];
    [condition setValue:[NSNumber numberWithBool:article.hasImage] forKey:kQuickInputViewConditionHasImageKey];
    [condition setValue:self.detailModel.adID forKey:kQuickInputViewConditionADIDKey];

    NSString *mediaID = [article.mediaInfo[@"media_id"] stringValue];
    if ([article hasVideoSubjectID]) {
        mediaID = [article.detailMediaInfo[@"media_id"] stringValue];
    }
    [condition setValue:mediaID forKey:kQuickInputViewConditionMediaID];

    NSString *fwID = self.detailModel.article.groupModel.groupID;

    TTArticleReadQualityModel *qualityModel = [[TTArticleReadQualityModel alloc] init];
    float readPct = [self.playControl watchPercent];
    NSInteger percent = MAX(0, MIN((NSInteger)(readPct * 100), 100));
    qualityModel.readPct = @(percent);
    qualityModel.stayTimeMs = @([self.tracker currentStayDuration]);

    NSMutableDictionary *extraDict = [NSMutableDictionary dictionary];;
    if (self.fromU11Cell){
        if (self.detailModel.gdExtJsonDict.count){
            [extraDict addEntriesFromDictionary:self.detailModel.gdExtJsonDict];
        }
        [extraDict setValue:self.detailModel.categoryID forKey:@"category_id"];
        [extraDict setValue:@(self.enterFromClickComment) forKey:@"is_click_button"];
        [extraDict setValue:self.detailModel.article.groupModel.groupID forKey:@"value"];
        [extraDict setValue:@"video" forKey:@"group_type"];
    }

    TTCommentWriteManager *commentManager = [[TTCommentWriteManager alloc] initWithCommentCondition:condition commentViewDelegate:self commentRepostBlock:^(NSString *__autoreleasing *willRepostFwID) {
        *willRepostFwID = fwID;
    } extraTrackDict:extraDict bindVCTrackDict:nil commentRepostWithPreRichSpanText:nil readQuality:qualityModel];

    self.commentWriteView = [[TTCommentWriteView alloc] initWithCommentManager:commentManager];

    self.commentWriteView.emojiInputViewVisible = switchToEmojiInput;
    [self.commentWriteView showInView:nil animated:YES];
}

- (void)_triggerFavoriteAction
{
    ExploreDetailManager *manager = [self.detailModel sharedDetailManager];
    //    [manager changeFavoriteButtonClicked:1];
    // 调用新增的方法，传入控制器对象，以吊起登录弹窗
    [manager changeFavoriteButtonClicked:1 viewController:self];
    
    if ([SSCommonLogic accountABVersionEnabled]) {
        // 不做操作
    } else {
        if (self.detailModel.article.userRepined) {
            // 原来的操作
            [self logFavorite];
            WeakSelf;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                StrongSelf;
                if (![TTAccountManager isLogin] && ![TTVideoTip hasTipFavLoginUserDefaultKey]) {
                    
                    wrapperTrackEvent(@"pop", @"login_detail_favor_show");
                    
                    [TTAccountManager showLoginAlertWithType:TTAccountLoginAlertTitleTypeFavor source:@"detail_first_favor" completion:^(TTAccountAlertCompletionEventType type, NSString *phoneNum) {
                        if (type == TTAccountAlertCompletionEventTypeTip) {
                            [TTAccountManager presentQuickLoginFromVC:[TTUIResponderHelper topNavigationControllerFor:self] type:TTAccountLoginDialogTitleTypeDefault source:@"detail_first_favor" completion:^(TTAccountLoginState state) {
                            }];
                        }
                    }];
                    
                    [TTVideoTip setHasTipFavLoginUserDefaultKey:YES];
                }
                
            });
        } else {
            [self logUnFavorite];
        }
    }
}

- (void)_switchShowStatusAnimated:(BOOL)animated isButtonClicked:(BOOL)clicked
{
    dispatch_block_t block = ^ {
        WeakSelf;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            StrongSelf;
            if (!self.isBackAction) {
                [self _openCommentWithText:nil switchToEmojiInput:NO];
            }
        });
    };
    if (self.showStatus == VideoDetailViewShowStatusVideo) {
        if (self.commentWriteView && !self.commentWriteView.isDismiss) {
            //修复连续两次_openCommentWithText 导致弹出两个输入框
            return;
        }
        BOOL showCommentUGC = self.beginShowCommentUGC;
        BOOL writeCommentUGC = self.beginWriteCommentUGC;
        if ((writeCommentUGC ||showCommentUGC) && !clicked) {
            if (writeCommentUGC) {
                block();
            }else{
                [self _scrollToCommentListHeadAnimated:animated];
            }
        } else {
            [self _scrollToCommentListHeadAnimated:animated];
            /**
             *  评论数为0时引导评论
             */
            if (self.detailModel.article.commentCount == 0) {
                block();
            }
        }
    } else {
        [self _scrollToTopAnimated:animated];
    }
    
    [self logClickComment:self.showStatus];
}

- (void)_scrollToCommentListHeadAnimated:(BOOL)animated
{
    UITableView *commentView = self.commentVC.commentTableView;
    CGFloat scrollThrougthContentOffset = MIN(commentView.contentSize.height - commentView.height, commentView.tableHeaderView.height);
    if (scrollThrougthContentOffset > 0) {
        if (_tagsView.tagPosition == TTVideoDetailSearchTagPositionAboveComment && _tagsView.height > 0) {
            scrollThrougthContentOffset -= _tagsView.height;
        }
        [commentView setContentOffset:CGPointMake(0, scrollThrougthContentOffset) animated:animated];
        //        self.showStatus = VideoDetailViewShowStatusComment;
    }
}

- (void)_scrollToTopAnimated:(BOOL)animated
{
    //    self.showStatus = VideoDetailViewShowStatusVideo;
    [self.commentVC.commentTableView setContentOffset:CGPointZero animated:animated];
}

- (void)_showVideoAlbumWithAritcle:(Article *)article
{
    [self vdvi_trackWithLabel:@"reduction" source:@"album_float" groupId:self.article.groupModel.groupID];
    self.videoAlbum.article = article;
    self.videoAlbum.currentPlayingArticle = self.detailModel.article;
    
    [TTVideoAlbumHolder holder].albumView = self.videoAlbum;
    
    [self.view addSubview:self.videoAlbum];
    
    CGRect frame = self.moviewViewContainer.frame;
    frame.size.height = self.interactModel.minMovieH;
    self.interactModel.curMovieH = self.interactModel.minMovieH;
    self.videoAlbum.height = self.view.height - self.interactModel.minMovieH;
    
    self.videoAlbum.top = self.view.height;
    self.playControl.forbidLayout = YES;
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.videoAlbum.bottom = self.view.height;
        self.moviewViewContainer.frame = frame;
        self.movieShotView.frame = self.moviewViewContainer.bounds;
        self.playControl.movieFrame = self.movieShotView.bounds;
        if (self.topPGCView) {
            self.commentVC.view.top = self.topPGCView.bottom;
        } else {
            self.commentVC.view.top = self.moviewViewContainer.bottom;
        }
        [self.playControl updateFrame];
    } completion:^(BOOL finished) {
        self.playControl.forbidLayout = NO;
    }];
}

#pragma mark -
#pragma mark public methods

- (NSString *)videoID
{
    Article *article = self.detailModel.article;
    NSString *vid = nil;
    if (!isEmptyString(article.videoID)) {
        vid = article.videoID;
    } else {
        vid = [[article videoDetailInfo] valueForKey:VideoInfoIDKey];
    }
    if ([vid isKindOfClass:[NSString class]] && [vid length] > 0) {
        return vid;
    }
    return nil;
}

- (void)settingOrderedData
{
    if (!self.detailModel.orderedData) {
        self.detailModel.orderedData = [self tempData];
    }
}

- (ExploreOrderedData *)orderedData
{
    [self settingOrderedData];
    return self.detailModel.orderedData;
}

- (Article *)article
{
    return self.detailModel.article;
}

#pragma mark -
#pragma mark private methods

- (void)_confirmFromType
{
    if (self.detailModel.relateReadFromGID) {
        self.fromType = VideoDetailViewFromTypeRelated;
    } else {
        self.fromType = VideoDetailViewFromTypeCategory;
    }
}

- (void)_initTracker
{
    Article *article = self.detailModel.article;
    self.tracker = [[TTVideoDetailStayPageTracker alloc] initWithUniqueID: article.uniqueID clickLabel:_detailModel.clickLabel];
}

- (void)_initShowStatus
{
    self.showStatus = VideoDetailViewShowStatusVideo;
    self.enableScrollToChangeShowStatus = YES;
}

- (void)_scrollToCommentsIfNeeded
{
    if ([self shouldBeginShowComment] &&
        self.showStatus == VideoDetailViewShowStatusVideo) {
        [self _switchShowStatusAnimated:YES isButtonClicked:NO];
    }
}

- (void)_logBack
{
    if (self.clickedBackBtn) {
        wrapperTrackEvent(@"detail", @"page_close_button");
    } else {
        wrapperTrackEvent(@"detail", @"back_gesture");
    }
}

- (void)ttv_addFromGId:(NSMutableDictionary *)dic
{
    if ([dic isKindOfClass:[NSMutableDictionary class]]) {
        if (self.fromType == VideoDetailViewFromTypeRelated && self.detailModel.relateReadFromGID) {
            [dic setValue:[NSString stringWithFormat:@"%@",self.detailModel.relateReadFromGID] forKey:@"from_gid"];
        }
    }
}

- (void)_logGoDetail
{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setValue:self.detailModel.adID.stringValue forKey:@"ext_value"];
    [dic setValue:self.detailModel.article.groupModel.itemID forKey:@"item_id"];
    [dic setValue:self.detailModel.article.aggrType forKey:@"aggr_type"];
    [dic setValue:[self.detailModel.article.userInfo ttgc_contentID] forKey:@"author_id"];
    [dic setValue:@"video" forKey:@"article_type"];
    if (self.detailModel.gdExtJsonDict && self.detailModel.gdExtJsonDict.count > 0){
        [dic addEntriesFromDictionary:self.detailModel.gdExtJsonDict];
    }
    BOOL hasZzComment = self.detailModel.article.zzComments.count > 0;
    [dic setValue:@(hasZzComment ? 1 : 0) forKey:@"has_zz_comment"];
    if (hasZzComment) {
        [dic setValue:self.detailModel.article.firstZzCommentMediaId forKey:@"mid"];
    }
    if (self.detailModel.fromSource == NewsGoDetailFromSourceVideoFloat)
    {
        [self trackEventWithEvent:@"go_detail" label:@"click_headline" value:[self.detailModel uniqueID] extraDic:dic];
    }
    else if (self.detailModel.fromSource == NewsGoDetailFromSourceVideoFloatRelated)
    {
        [self ttv_addFromGId:dic];
        [self trackEventWithEvent:@"go_detail" label:@"click_related" value:[self.detailModel uniqueID] extraDic:dic];
    }
    else
    {
        [self ttv_addFromGId:dic];
        [self trackEventWithEvent:@"go_detail" label:self.detailModel.clickLabel value:[self.detailModel uniqueID] extraDic:dic];
    }
    
}

- (BOOL)isEmptyString:(NSString *)string
{
    return ![string isKindOfClass:[NSString class]] || string.length <= 0;
}

- (void)trackEventWithEvent:(NSString *)event label:(NSString *)label value:(NSString *)value extraDic:(NSDictionary *)extraDic
{
    if ([self isEmptyString:event]) {
        return;
    }
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:3];
    [dict setValue:@"umeng" forKey:@"category"];
    [dict setValue:event forKey:@"tag"];
    [dict setValue:label forKey:@"label"];
    if (![self isEmptyString:value]) {
        [dict setValue:value forKey:@"value"];
    }else{// 有时候  竟然传进来了number类型的值。 所以我要做一些安全处理，尽量保住value
        if (value && [value isKindOfClass:[NSNumber class]]) {
            [dict setValue:[(NSNumber *)value stringValue] forKey:@"value"];
        }
    }
    if (extraDic.allKeys.count) {
        [dict addEntriesFromDictionary:extraDic];
    }
    
    if (![TTTrackerWrapper isOnlyV3SendingEnable]) {
        [TTTrackerWrapper eventData:dict];
    }
    
    [self goDetailSendEvent3Data];
}

- (NSInteger)topViewControllerIndexWithNoneDragToRoot
{
    //栈顶开始向栈底遍历第一个ttDragToRoot为NO的VC
    for (NSInteger idx = self.navigationController.viewControllers.count - 1; idx > 0; idx--) {
        UIViewController *vc = (UIViewController *)self.navigationController.viewControllers[idx];
        if (!vc.ttDragToRoot) {
            return idx;
        }
    }
    return 0;
}

- (BOOL)shouldShowUserTipsView {
    //如果点击的视频是上次缓存过的，不显示引导
    if ([[TTMovieViewCacheManager sharedInstance] hasCachedForKey:self.detailModel.article.videoID]) {
        return NO;
    }
    //如果是从feed中点进来的，不显示引导
    if ([[TTMovieViewCacheManager sharedInstance].currentPlayingVideoID isEqualToString:self.detailModel.article.videoID]) {
        return NO;
    }
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *curVersion = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    if (![[NSUserDefaults standardUserDefaults] valueForKey:@"TTVideoPreviousVersion"]) {
        //首次安装
        [[NSUserDefaults standardUserDefaults] setValue:curVersion forKey:@"TTVideoPreviousVersion"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        return YES;
    } else {
        //是否是新版本
        NSString *preVersion = [[NSUserDefaults standardUserDefaults] stringForKey:@"TTVideoPreviousVersion"];
        if ([preVersion isEqualToString:curVersion]) {
            return NO;
        } else {
            [[NSUserDefaults standardUserDefaults] setValue:curVersion forKey:@"TTVideoPreviousVersion"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            return YES;
        }
    }
}

- (void)p_setupViewAfterLoadData {
    if ([self.detailModel.article.articleDeleted boolValue]) {
        [ExploreMovieView removeAllExploreMovieView];
        [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:NSLocalizedString(@"该内容已删除", nil) indicatorImage:[UIImage themedImageNamed:@"close_popup_textpage"] autoDismiss:YES dismissHandler:^(BOOL isUserDismiss) {
            [self p_deleteLocalVideo];
        }];
    } else {
        _infoManager.detailModel = self.detailModel;
        _infoManager.detailModel.article.videoExtendLink = _infoManager.videoExtendLink;
        [self.playControl playMovieIfNeededAndRebindToMovieShotView:NO];
        [self tt_endUpdataData];
        [self _install];
        [self _buildNatantWithManager:_infoManager];
        [self layoutRelatedVideoViewOnLandscapePadIfNeeded];
        
        if (_infoManager.videoAdUrl && [self.orderedData.ad_id longLongValue] > 0) {
            self.landingURL = _infoManager.videoAdUrl;
            [self.playControl showDetailButtonIfNeeded];
        }
        [self addKVO];
        [self addObserver];
        if ([[_infoManager.videoExtendLink valueForKey:@"open_direct"] boolValue])
        {
            [self showExtendLinkViewWithArticle:_infoManager.detailModel.article];
        }
        if (_hasFetchedComments) {
            //comment接口比info接口先返回
            [self.commentVC.commentTableView reloadData];
            [self _scrollToCommentsIfNeeded];
        }
    }
    if (_startTimestamp) {
        NSTimeInterval interval = [[NSDate date] timeIntervalSince1970] - _startTimestamp;
        _startTimestamp = 0;
        [[TTMonitor shareManager] trackService:@"video_detail_load_interval" value:@(interval) extra:nil];
    }
    
}

- (void)p_showWriteCommentWithCommentModel:(id<TTCommentModelProtocol>)commentModel {
    if (self.isGettingMomentDetail) {
        return;
    }
    self.isGettingMomentDetail = YES;
    if (!_momentManager) {
        _momentManager = [[ArticleMomentManager alloc] init];
    }
    [_momentManager startGetMomentDetailWithID:[commentModel.commentID stringValue] sourceType:ArticleMomentSourceTypeArticleDetail modifyTime:0 finishBlock:^(ArticleMomentModel *model, NSError *error) {
        if (!error) {
            self.commentModelForFloatComment = commentModel;
            [self p_showWriteCommentWithMomentModel:model];
        } else {
            NSDictionary *info = [error.userInfo valueForKey:@"tips"];
            if ([info isKindOfClass:[NSDictionary class]]) {
                NSString *tip = [info stringValueForKey:@"display_info" defaultValue:@""];
                [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:tip indicatorImage:[UIImage themedImageNamed:@"close_popup_textpage"] autoDismiss:YES dismissHandler:^(BOOL isUserDismiss) {
                }];
            }
        }
        self.isGettingMomentDetail = NO;
    }];
}

- (void)p_showWriteCommentWithMomentModel:(ArticleMomentModel *)momentModel {
    // 拉黑逻辑
    if (momentModel.user.isBlocked || momentModel.user.isBlocking)
    {
        NSString * description = nil;
        if (momentModel.user.isBlocked) {
            description = [[SSIndicatorTipsManager shareInstance] indicatorTipsForKey:kTipForActionToBlockedUser];
        } else {
            description = [[SSIndicatorTipsManager shareInstance] indicatorTipsForKey:kTipForActionToBlockingUser];
        }
        if (!description) {
            description = momentModel.user.isBlocked ? @" 根据对方设置，您不能进行此操作" : @"您已拉黑此用户，不能进行此操作";
        }

        [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:description indicatorImage:[UIImage themedImageNamed:@"close_popup_textpage.png"] autoDismiss:YES dismissHandler:nil];
        return;
    }

    NSString *fw_id = self.detailModel.article.groupModel.itemID ?: self.detailModel.article.groupModel.groupID;

    TTCommentDetailModel *detailModel = [TTCommentDetailModel new];
    detailModel.commentID = self.commentModelForFloatComment.commentID.stringValue;
    detailModel.groupModel = self.detailModel.article.groupModel;
    detailModel.banEmojiInput = self.commentVC.tt_banEmojiInput;
    detailModel.user = momentModel.user;
    detailModel.content = momentModel.content;
    detailModel.contentRichSpanJSONString = momentModel.contentRichSpan;
    if (self.detailModel.adID && self.detailModel.adID.longLongValue > 0) {
        detailModel.banForwardToWeitoutiao = @(1);
    }
    else {
        detailModel.banForwardToWeitoutiao = @(0);
    }

    WeakSelf;
    TTCommentDetailReplyWriteManager *replyManager = [[TTCommentDetailReplyWriteManager alloc] initWithCommentDetailModel:detailModel replyCommentModel:nil commentRepostBlock:^(NSString *__autoreleasing *willRepostFwID) {
        *willRepostFwID = fw_id;
    } publishCallback:^(id<TTCommentDetailReplyCommentModelProtocol> replyModel, NSError *error) {
        StrongSelf;
        if (error) {
            [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:@"发布失败" indicatorImage:[UIImage themedImageNamed:@"close_popup_textpage.png"] autoDismiss:YES dismissHandler:nil];
            return;
        }

        self.commentModelForFloatComment.replyCount = @(self.commentModelForFloatComment.replyCount.integerValue+1);
        if (self.commentIndexPathToReload) {
            [self.commentVC tt_updateCommentCellLayoutAtIndexPath:self.commentIndexPathToReload replyCount:self.commentModelForFloatComment.replyCount.integerValue];
        }
        if (self.commentModelForFloatComment) {
            WeakSelf;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                StrongSelf;

                [self p_showFloatCommentView:self.commentModelForFloatComment momentModel:nil momentCommentModel:(ArticleMomentCommentModel *)replyModel];
                self.commentModelForFloatComment = nil;
            });
        }
    } getReplyCommentModelClassBlock:nil commentRepostWithPreRichSpanText:nil commentSource:nil];

    TTCommentWriteView *replyWriteView = [[TTCommentWriteView alloc] initWithCommentManager:replyManager];
    replyWriteView.banEmojiInput = detailModel.banEmojiInput;

    [replyWriteView showInView:nil animated:YES];
}

- (void)p_showFloatCommentView:(id<TTCommentModelProtocol>)model momentModel:(ArticleMomentModel *)momentModel momentCommentModel:(ArticleMomentCommentModel *)momentCommentModel {
    if (_floatCommentVC.view.superview) {
        return;
    }
    TTCommentViewController *ttController = self.commentVC;
    CGSize movieSize = [self frameForMovieContainerView].size;
    movieSize.height = self.interactModel.minMovieH;
    if (!momentModel) {
        momentModel = [self tt_genSimpleMomentModelWithComment:model];
    }
    TTVideoDetailFloatCommentViewController *vc = [[TTVideoDetailFloatCommentViewController alloc] initWithViewFrame:CGRectMake(0, movieSize.height + self.moviewViewContainer.top, movieSize.width, self.view.height - movieSize.height - self.moviewViewContainer.top) comment:model groupModel:model.groupModel momentModel:momentModel delegate:(id<ExploreMomentListCellUserActionItemDelegate>)ttController showWriteComment:NO fromMessage:model.isStick];
    
    if (self.detailModel.adID && self.detailModel.adID.longLongValue > 0) {
        vc.isAdVideo = YES;
    }
    else {
        vc.isAdVideo = NO;
    }
    vc.replyMomentCommentModel = momentCommentModel;
    vc.vcDelegate = self;
    [self addChildViewController:vc];
    [self.view addSubview:vc.view];
    [vc didMoveToParentViewController:self];
    [self.view bringSubviewToFront:vc.view];
    _floatCommentVC = vc;
    self.toolbarView.hidden = YES;
    vc.view.top = self.view.height;

    // toolbar 禁表情
    if ([self.commentVC respondsToSelector:@selector(tt_banEmojiInput)]) {
        vc.banEmojiInput = self.commentVC.tt_banEmojiInput;
    }

    CGRect frame = self.moviewViewContainer.frame;
    frame.size.height = self.interactModel.minMovieH;
    self.interactModel.curMovieH = self.interactModel.minMovieH;
    self.playControl.forbidLayout = YES;
    [UIView animateWithDuration:0.2 animations:^{
        vc.view.bottom = self.view.height;
        self.moviewViewContainer.frame = frame;
        self.movieShotView.frame = self.moviewViewContainer.bounds;
        if (self.movieView.superview == self.movieShotView) {
            self.movieView.frame = self.movieShotView.bounds;
        }
        [self.playControl updateFrame];
    } completion:^(BOOL finished) {
        self.playControl.forbidLayout = NO;
    }];
}

- (void)p_prepareDeleteLocalVideoTask {
    if (self.detailModel.orderedData.originalData.uniqueID) {
        NSString *uniqueID = [NSString stringWithFormat:@"%lld",self.detailModel.orderedData.originalData.uniqueID];
        
        NSMutableDictionary *profileDict = [NSMutableDictionary dictionary];
        [profileDict setValue:self.detailModel.article.itemID forKey:@"item_id"];
        [profileDict setValue:[self.detailModel uniqueID] forKey:@"group_id"];
        [profileDict setValue:[[self userInfo] stringValueForKey:@"user_id" defaultValue:nil] forKey:@"user_id"];
        
        NSMutableDictionary *dongtaiDict = nil;
        if (!isEmptyString(self.detailModel.dongtaiID)) {
            dongtaiDict = [NSMutableDictionary dictionary];
            [dongtaiDict setValue:self.detailModel.dongtaiID forKey:@"id"];
        }
        
        TTVideoCallbackTask *task = [[TTVideoCallbackTask alloc] init];
        WeakSelf;
        task.callback = ^ {
            StrongSelf;
            [[NSNotificationCenter defaultCenter] postNotificationName:TTVideoDetailViewControllerDeleteVideoArticle object:nil userInfo:@{@"uniqueID":uniqueID}];
            NSArray *orderedDataArray = [ExploreOrderedData objectsWithQuery:@{@"uniqueID": uniqueID}];
            [ExploreOrderedData removeEntities:orderedDataArray];
            [self _topViewBackButtonPressed];
            [[NSNotificationCenter defaultCenter] postNotificationName:kDetailDeleteUGCMovieNotification object:nil userInfo:profileDict];
            
            if (dongtaiDict) {
                [[NSNotificationCenter defaultCenter] postNotificationName:kDeleteMomentNotificationKey object:nil userInfo:dongtaiDict];
            }
        };
        [[TTVideoCallbackTaskGlobalQueue sharedInstance] enQueueCallbackTask:task];
    }
}

- (void)p_deleteLocalVideo {
    if (self.detailModel.orderedData.originalData.uniqueID) {
        //给feed发通知
        NSString *uniqueID = [NSString stringWithFormat:@"%lld",self.detailModel.orderedData.originalData.uniqueID];
        [[NSNotificationCenter defaultCenter] postNotificationName:TTVideoDetailViewControllerDeleteVideoArticle object:nil userInfo:@{@"uniqueID":uniqueID}];
        //从数据库中删除
        NSArray *orderedDataArray = [ExploreOrderedData objectsWithQuery:@{@"uniqueID": uniqueID}];
        [ExploreOrderedData removeEntities:orderedDataArray];
        
        //        NSArray * orderedDataArray = [[[SSDataContext sharedContext] mainThreadModelManager] entitiesWithQuery:@{@"originalData.uniqueID":self.detailModel.orderedData.originalData.uniqueID} entityClass:[ExploreOrderedData class] error:nil];
        //        [[SSModelManager sharedManager] removeEntities:orderedDataArray error:nil];
        [self _topViewBackButtonPressed];
        //给个人主页发通知
        NSMutableDictionary *profileDict = [NSMutableDictionary dictionary];
        [profileDict setValue:self.detailModel.article.itemID forKey:@"item_id"];
        [profileDict setValue:[self.detailModel uniqueID] forKey:@"group_id"];
        [profileDict setValue:[[self userInfo] stringValueForKey:@"user_id" defaultValue:nil] forKey:@"user_id"];
        [[NSNotificationCenter defaultCenter] postNotificationName:kDetailDeleteUGCMovieNotification object:nil userInfo:profileDict];
        
        if (!isEmptyString(self.detailModel.dongtaiID)) {
            NSMutableDictionary *dongtaiDict = [NSMutableDictionary dictionary];
            [dongtaiDict setValue:self.detailModel.dongtaiID forKey:@"id"];
            [[NSNotificationCenter defaultCenter] postNotificationName:kDeleteMomentNotificationKey object:nil userInfo:dongtaiDict];
        }
    }
}

- (BOOL)p_willShowNetTrafficView {
    NSString *name = [TTNetworkHelper connectMethodName];
    if ([name isEqualToString:@"WIFI"]) {
        return NO;
    } else if ([name isEqualToString:@""]) {
        return NO;
    }
    if ([ExploreMovieView hasShownTrafficView]) {
        return NO;
    }
    return YES;
}

- (void)updateMomentCountOfComment:(NSNotification *)notification {
    
    NSString *groupID = [notification.userInfo stringValueForKey:@"groupID" defaultValue:@""];
    
    if ([self.detailModel.uniqueID isEqualToString:groupID] && self. self.commentIndexPathToReload) {
        NSInteger increment = [notification.userInfo integerValueForKey:@"increment" defaultValue:0];
        NSInteger count = [notification.userInfo integerValueForKey:@"count" defaultValue:0];
        if (increment) {
            self.floatCommentVC.commentModel.replyCount = @(self.floatCommentVC.commentModel.replyCount.integerValue+increment);
        } else if (count) {
            self.floatCommentVC.commentModel.replyCount = @(count);
        }
        [self.commentVC tt_updateCommentCellLayoutAtIndexPath:self.commentIndexPathToReload replyCount:self.floatCommentVC.commentModel.replyCount.integerValue];
    }
}

- (BOOL)p_needAddAlbumView {
    if ([TTVideoAlbumHolder holder].albumView.superview && ![TTVideoAlbumHolder holder].albumView.hidden && [TTVideoAlbumHolder holder].albumView.alpha) {
        return YES;
    }
    return NO;
}

#pragma mark -
#pragma mark ArticleInfoManagerDelegate

- (void)articleInfoManager:(ArticleInfoManager *)manager getStatus:(NSDictionary *)dict
{
    //获取到info接口,更新article
    [[self.detailModel sharedDetailManager] updateArticleByData:dict];
}

- (void)articleInfoManagerLoadDataFinished:(ArticleInfoManager *)manager
{
    [[TTMonitor shareManager] trackService:video_play_detail_info_status status:0 extra:nil];
    [self p_setupViewAfterLoadData];
}

- (void)articleInfoManagerFetchInfoFailed:(ArticleInfoManager *)manager
{
    [[TTMonitor shareManager] trackService:video_play_detail_info_status status:1 extra:nil];
    [self p_setupViewAfterLoadData];
}

#pragma mark -
#pragma mark ExploreDetailManagerDelegate

- (void)detailManager:(ExploreDetailManager *)manager showTipMsg:(NSString *)tipMsg {
    if (!isEmptyString(tipMsg)) {
        [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:tipMsg indicatorImage:nil autoDismiss:YES dismissHandler:nil];
    }
}

- (void)detailManager:(ExploreDetailManager *)manager showTipMsg:(NSString *)tipMsg icon:(UIImage *)image {
    if (!isEmptyString(tipMsg)) {
        [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:tipMsg indicatorImage:image autoDismiss:YES dismissHandler:nil];
    }
}

- (void)detailManager:(ExploreDetailManager *)manager showTipMsg:(NSString *)tipMsg icon:(UIImage *)image dismissHandler:(DismissHandler)handler{
    if (!isEmptyString(tipMsg)) {
        [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:tipMsg indicatorImage:image autoDismiss:YES dismissHandler:handler];
    }
}

- (void)detailContainerViewController:(SSViewControllerBase *)container reloadData:(TTDetailModel *)detailModel
{
}

- (void)detailContainerViewController:(nullable SSViewControllerBase *)container loadContentFailed:(nullable NSError *)error{
    [self tt_endUpdataData];
}

#pragma mark -
#pragma mark SSActivityViewDelegate

- (void)activityView:(SSActivityView *)view button:(UIButton *)button didCompleteByItemType:(TTActivityType)itemType{
    if (itemType == TTActivityTypeFavorite) {
        if (!TTNetworkConnected()){
            [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage
                                      indicatorText:NSLocalizedString(@"没有网络连接", nil)
                                     indicatorImage:[UIImage themedImageNamed:@"close_popup_textpage.png"]
                                        autoDismiss:YES
                                     dismissHandler:nil];
            return;
        }
        button.selected = !button.selected;
        [self toggleFavorite];
    }
}

- (void)activityView:(SSActivityView *)view didCompleteByItemType:(TTActivityType)itemType
{
    if (itemType == TTActivityTypeWeitoutiao || itemType == TTActivityTypeDislike || itemType ==TTActivityTypeReport || itemType == TTActivityTypeEMail || itemType == TTActivityTypeSystem ||itemType == TTActivityTypeMessage) {
        if ([self.playControl isKindOfClass:[TTVideoDetailNewPlayControl class] ]) {
            TTVideoDetailNewPlayControl *newplaycontrol = (TTVideoDetailNewPlayControl *)self.playControl;
            if ([newplaycontrol.movieView isKindOfClass:[TTVPlayVideo class]]) {
                TTVPlayVideo *movieView = (TTVPlayVideo *) newplaycontrol.movieView;
                if ([self.playControl isMovieFullScreen]) {
                    [movieView.player exitFullScreen:YES completion:^(BOOL finished) {
                    }];
                }
            }
        }else{
            if ([ExploreMovieView isFullScreen]) {
                ExploreMovieView *movieView = [ExploreMovieView currentFullScreenMovieView];
                [movieView exitFullScreen:NO completion:^(BOOL finished) {
                    [UIViewController attemptRotationToDeviceOrientation];
                }];
                
            }
        }
    }

//    if (itemType == TTActivityTypeWeitoutiao) {
//        NSMutableDictionary * extraDic = @{}.mutableCopy;
//        if (!isEmptyString(self.detailModel.article.groupModel.itemID)) {
//            [extraDic setValue:self.detailModel.article.groupModel.itemID forKey:@"item_id"];
//        }
//        [self sendVideoShareTrackWithItemType:itemType];
//        [self forwardToWeitoutiao];
//        if (ttvs_isShareIndividuatioEnable()){
//            [[TTActivityShareSequenceManager sharedInstance_tt] instalAllShareActivitySequenceFirstActivity:itemType];
//        }
//
//    }
    if (itemType == TTActivityTypeReport) {
        
        self.actionSheetController = [[TTActionSheetController alloc] init];
        [self.actionSheetController insertReportArray:[TTReportManager fetchReportVideoOptions]];
        WeakSelf;
        [self.actionSheetController performWithSource:TTActionSheetSourceTypeUser completion:^(NSDictionary * _Nonnull parameters) {
            StrongSelf;
            if (parameters[@"report"]) {
                TTReportContentModel *model = [[TTReportContentModel alloc] init];
                model.groupID = [self.detailModel uniqueID];
                model.videoID = [self videoID];
                NSString *contentType = kTTReportContentTypePGCVideo;
                if ([self.detailModel.article isVideoSourceUGCVideo]) {
                    contentType = kTTReportContentTypeUGCVideo;
                } else if ([self.detailModel.article isVideoSourceHuoShan]) {
                    contentType = kTTReportContentTypeHTSVideo;
                } else if (self.detailModel.adID.longLongValue) {
                    contentType = kTTReportContentTypeAD;
                }
                
                [[TTReportManager shareInstance] startReportVideoWithType:parameters[@"report"] inputText:parameters[@"criticism"] contentType:contentType reportFrom:TTReportFromByEnterFromAndCategory(self.detailModel.clickLabel, self.detailModel.categoryID) contentModel:model extraDic:nil animated:YES];
            }
        }];
    } else if (itemType == TTActivityTypeDetele) {
        NSString *itemID = !isEmptyString(self.detailModel.article.itemID) ? self.detailModel.article.itemID : self.detailModel.article.groupModel.groupID;
        NSMutableDictionary *extraDict = [NSMutableDictionary dictionary];
        [extraDict setValue:itemID forKey:@"item_id"];
        [extraDict setValue:@"click_video" forKey:@"source"];
        [extraDict setValue:@(1) forKey:@"aggr_type"];
        [extraDict setValue:@(1) forKey:@"type"];
        wrapperTrackEventWithCustomKeys(@"detail_share", @"delete_ugc", [self.detailModel uniqueID], nil, extraDict);
        NSMutableDictionary *params = [NSMutableDictionary dictionary];
        [params setValue:[[self userInfo] stringValueForKey:@"user_id" defaultValue:nil] forKey:@"user_id"];
        [params setValue:itemID forKey:@"item_id"];
        [self p_prepareDeleteLocalVideoTask];
        [[TTNetworkManager shareInstance] requestForJSONWithURL:[CommonURLSetting deleteUGCMovieURLString] params:params method:@"GET" needCommonParams:YES callback:^(NSError *error, id jsonObj) {
            NSInteger errorCode = 0;
            if ([jsonObj isKindOfClass:[NSDictionary class]]) {
                errorCode = [(NSDictionary *)jsonObj tt_integerValueForKey:@"error_code"];
            }
            if (error || errorCode != 0) {
                NSString *tip = NSLocalizedString(@"操作失败", nil);
                [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:tip indicatorImage:[UIImage themedImageNamed:@"close_popup_textpage"] autoDismiss:YES dismissHandler:nil];
            } else {
                NSString *tip = NSLocalizedString(@"操作成功", nil);
                [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:tip indicatorImage:[UIImage themedImageNamed:@"doneicon_popup_textpage"] autoDismiss:YES dismissHandler:nil];
                //                [self p_deleteLocalVideo];
                TTVideoCallbackTask *task = [[TTVideoCallbackTaskGlobalQueue sharedInstance] popQueueFromHead];
                
                if (task.callback) {
                    task.callback();
                }
            }
        }];
    } else if (itemType == TTActivityTypePromotion) {
        [TTAdPromotionManager handleModel:self.infoManager.promotionModel  condition:nil];
        wrapperTrackEventWithCustomKeys(@"share_btn", @"click", self.detailModel.article.groupModel.groupID, nil, nil);
    } else if (itemType == TTActivityTypeDigUp){
        [self digUpActivityClicked];
    }else if (itemType == TTActivityTypeDigDown){
        [self digDownActivityClicked];
    }
    else if(itemType == TTActivityTypeCommodity && [self showCommodity]){
        [self.playControl addCommodity];
    }else{
        NSString *adId = nil;
        if ([self.detailModel.adID longLongValue] > 0) {
            adId = [NSString stringWithFormat:@"%@", self.detailModel.adID];
        }
        NSString *groupId = [NSString stringWithFormat:@"%lld", self.detailModel.article.uniqueID];
        [self.activityActionManager performActivityActionByType:itemType inViewController:self sourceObjectType:TTShareSourceObjectTypeVideoDetail uniqueId:groupId adID:adId platform:TTSharePlatformTypeOfMain groupFlags:self.detailModel.article.groupFlags isFullScreenShow:[self.playControl isMovieFullScreen]];
        [self sendVideoShareTrackWithItemType:itemType];
    }
}

- (BOOL)showCommodity
{
    return NO;//旧版本禁用特卖
    return [self.playControl isKindOfClass:[TTVideoDetailNewPlayControl class]] && self.orderedData.article.commoditys.count > 0;
}


- (void)digUpActivityClicked
{
    Article *article = self.detailModel.article;
    if (!_itemActionManager) {
        self.itemActionManager = [[ExploreItemActionManager alloc] init];
    }
    if (article.userDigg) {
        article.userDigg = NO;
        article.diggCount = MAX(0, article.diggCount - 1);
        [article save];
        
        [_itemActionManager sendActionForOriginalData:article adID:nil actionType:DetailActionTypeUnDig finishBlock:nil];
        NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
        [params setValue:self.detailModel.article.groupModel.groupID forKey:@"group_id"];
        [params setValue:self.detailModel.article.groupModel.itemID forKey:@"item_id"];
        NSString *user_id = [self.detailModel.article.userInfo tt_stringValueForKey:@"user_id"]? :[self.detailModel.article.mediaInfo tt_stringValueForKey:@"user_id"];
        [params setValue:user_id forKey:@"user_id"];
        [params setValue:@"detail" forKey:@"position"];
        [params setValue:self.detailModel.orderedData.logPb forKey:@"log_pb"];
        [params setValue:self.detailModel.categoryID forKey:@"category_name"];
        [params setValue:self.detailModel.clickLabel forKey:@"enter_from"];
        [params setValue:[self.detailModel.statParams tt_stringValueForKey:@"card_id"] forKey:@"card_id"];
        [params setValue:[self.detailModel.statParams tt_stringValueForKey:@"card_position"] forKey:@"card_position"];
        [params setValue:self.detailModel.orderedData.groupSource forKey:@"group_source"];
        if (self.detailModel.orderedData.listLocation != 0) {
            [params setValue:@"main_tab" forKey:@"list_entrance"];
        }
        [params setValue:@"video" forKey:@"article_type"];
        [params setValue:[self.detailModel.article.userInfo ttgc_contentID] forKey:@"author_id"];

        [TTTrackerWrapper eventV3:@"rt_unlike" params:params];
    }
    else if (article.userBury){
        NSString * tipMsg = NSLocalizedString(@"您已经踩过", nil);
        if (!isEmptyString(tipMsg)) {
            [self  showIndicatorViewWithTip:tipMsg andImage:nil dismissHandler:nil];
        }
    }
    else{
        article.userDigg = YES;
        article.diggCount = [article.banDigg boolValue]? 1 : article.diggCount + 1;
        [article save];
        
        [_itemActionManager sendActionForOriginalData:article adID:nil actionType:DetailActionTypeDig finishBlock:^(id userInfo, NSError *error) {
            if (!error) {
                if ([userInfo isKindOfClass:[NSDictionary class]]) {
                    int diggCount = [[((NSDictionary *)userInfo) objectForKey:@"digg_count"] intValue];
                    if (diggCount == 1) {
                        article.diggCount = diggCount;
                        [article save];
                    }
                }
            }
        }];
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [dict setValue:@"video" forKey:@"article_type"];
        [dict setValue:[self.detailModel.article.userInfo ttgc_contentID] forKey:@"author_id"];
        wrapperTrackEventWithCustomKeys(@"xiangping", @"video_list_digg",nil,nil,dict);

    }
}

- (void)digDownActivityClicked
{
    Article *article = self.detailModel.article;
    if (!_itemActionManager) {
        self.itemActionManager = [[ExploreItemActionManager alloc] init];
    }
    if (article.userDigg) {
        NSString * tipMsg = NSLocalizedString(@"您已经赞过", nil);
        if (!isEmptyString(tipMsg)) {
            [self  showIndicatorViewWithTip:tipMsg andImage:nil dismissHandler:nil];
        }
    }
    else if (article.userBury){
        article.userBury = NO;
        article.buryCount = [article.banBury boolValue]? 1 : MAX(0, article.buryCount - 1);
        [article save];
        
        [_itemActionManager sendActionForOriginalData:article adID:nil actionType:DetailActionTypeUnBury finishBlock:nil];
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [dict setValue:self.orderedData.categoryID forKey:@"category_name"];
        [dict setValue:self.orderedData.article.groupModel.groupID forKey:@"group_id"];
        [dict setValue:self.orderedData.article.groupModel.itemID forKey:@"item_id"];
        [dict setValue:[self.orderedData.article.mediaInfo tt_stringValueForKey:@"media_id"] forKey:@"user_id"];
        [dict setValue:self.orderedData.groupSource forKey:@"group_source"];
        [dict setValue:self.orderedData.logPb forKey:@"log_pb"];
        [dict setValue:@"detail" forKey:@"position"];
        if ([self.orderedData.categoryID isEqualToString:kTTMainCategoryID]) {
            [dict setValue:@"click_headline" forKey:@"enter_from"];
        }else{
            [dict setValue:@"click_category" forKey:@"enter_from"];
        }
        if (self.orderedData.listLocation != 0) {
            [dict setValue:@"main_tab" forKey:@"list_entrance"];
        }
        [dict setValue:@"video" forKey:@"article_type"];
        [dict setValue:[self.detailModel.article.userInfo ttgc_contentID] forKey:@"author_id"];

        [TTTracker eventV3:@"rt_unbury" params:[dict copy]];

    }
    else{
        article.userBury = YES;
        article.buryCount = [article.banBury boolValue]? 1 : article.buryCount + 1;
        [article save];
        
        [_itemActionManager sendActionForOriginalData:article adID:nil actionType:DetailActionTypeBury finishBlock:^(id userInfo, NSError *error) {
            if (!error) {
                if ([userInfo isKindOfClass:[NSDictionary class]]) {
                    int buryCount = [[((NSDictionary *)userInfo) objectForKey:@"bury_count"] intValue];
                    if (buryCount == 1) {
                        article.buryCount = buryCount;
                        [article save];
                    }
                }
            }
        }];
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [dict setValue:@"video" forKey:@"article_type"];
        [dict setValue:[self.detailModel.article.userInfo ttgc_contentID] forKey:@"author_id"];
        wrapperTrackEventWithCustomKeys(@"xiangping", @"video_list_bury",nil,nil,dict);
    }
}


- (void)toggleFavorite
{
    Article *article = self.detailModel.article;
    if (!_itemActionManager) {
        self.itemActionManager = [[ExploreItemActionManager alloc] init];
    }
    NSMutableDictionary * eventContext = [[NSMutableDictionary alloc] init];
    [eventContext setValue:[@(article.uniqueID) stringValue] forKey:@"group_id"];
    [eventContext setValue:article.itemID forKey:@"item_id"];
    
    if (article.userRepined == YES) {
        __weak __typeof__(self) wself = self;
        [self.itemActionManager unfavoriteForOriginalData:article adID:nil finishBlock:^(id userInfo, NSError *error) {
            if (!error) {
                if (wself.orderedData.article.uniqueID == article.uniqueID) {
                    //[wself updateActionButtons:essayData];
                }
            }
        }];
        
        NSString * tipMsg = NSLocalizedString(@"取消收藏", nil);
        UIImage * image = [UIImage themedImageNamed:@"doneicon_popup_textpage.png"];
        if (!isEmptyString(tipMsg)) {
            [self  showIndicatorViewWithTip:tipMsg andImage:nil dismissHandler:nil];
        }
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [dict setValue:@"video" forKey:@"article_type"];
        [dict setValue:[self.detailModel.article.userInfo ttgc_contentID] forKey:@"author_id"];
        wrapperTrackEventWithCustomKeys(@"xiangping", @"video_detail_unfavorite",nil,nil,dict);
    }
    else {
        __weak __typeof__(self) wself = self;
        [self.itemActionManager favoriteForOriginalData:article adID:nil finishBlock:^(id userInfo, NSError *error) {
            if (!error) {
                if (wself.orderedData.article.uniqueID == article.uniqueID) {
                    //[wself updateActionButtons:essayData];
                }
            }
        }];
        
        NSString * tipMsg = NSLocalizedString(@"收藏成功", nil);
        UIImage * image = [UIImage themedImageNamed:@"doneicon_popup_textpage.png"];
        if (!isEmptyString(tipMsg)) {
            [self  showIndicatorViewWithTip:tipMsg andImage:nil dismissHandler:nil];
        }
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [dict setValue:@"video" forKey:@"article_type"];
        [dict setValue:[self.detailModel.article.userInfo ttgc_contentID] forKey:@"author_id"];
        wrapperTrackEventWithCustomKeys(@"xiangping", @"video_detail_favorite",nil,nil,dict);
    }
    
}

//- (void)forwardToWeitoutiao {
//    //实际转发对象为文章，操作对象为文章
//    [TTRepostViewController presentRepostToWeitoutiaoViewControllerWithRepostType:TTThreadRepostTypeArticle
//                                                                    originArticle:[[TTRepostOriginArticle alloc] initWithArticle:self.detailModel.article]
//                                                                     originThread:nil
//                                                                   originShortVideoOriginalData:nil
//                                                                operationItemType:TTRepostOperationItemTypeArticle
//                                                                  operationItemID:self.detailModel.article.itemID
//                                                                   repostSegments:nil];
//}

#pragma mark -
#pragma mark TTWriteCommentViewDelegate

- (void)commentView:(TTCommentWriteView *) commentView sucessWithCommentWriteManager:(TTCommentWriteManager *)commentWriteManager responsedData:(NSDictionary *)responseData
{
    [commentView dismissAnimated:YES];
    commentWriteManager.delegate = nil;
    [self commentResponsedReceived:responseData];
}

- (void)commentResponsedReceived:(NSDictionary *)notifyDictioanry
{
    if(![notifyDictioanry objectForKey:@"error"])  {
        self.detailModel.article.commentCount = self.detailModel.article.commentCount + 1;
        NSMutableDictionary *data = [NSMutableDictionary dictionaryWithDictionary:[notifyDictioanry objectForKey:@"data"]];
        [self.commentVC tt_insertCommentWithDict:data];
        [self.commentVC tt_markStickyCellNeedsAnimation];
        [self.commentVC tt_commentTableViewScrollToTop];
        [self _scrollToCommentListHeadAnimated:YES];
        if (self.fromU11Cell){
            if (_publishStatusForTrack == 1){
                _publishStatusForTrack = 2;
                //发表评论前没有登录，然后登录后发送成功，多发一个埋点统计
                NSMutableDictionary *dict = [NSMutableDictionary dictionary];
                if (!isEmptyString(self.detailModel.categoryID)){
                    [dict setValue:self.detailModel.categoryID forKey:@"category_id"];
                }
                if (self.detailModel.gdExtJsonDict.count){
                    [dict addEntriesFromDictionary:self.detailModel.gdExtJsonDict];
                }
                [dict setValue:@(self.enterFromClickComment) forKey:@"is_click_button"];
                [dict setValue:@"video" forKey:@"group_type"];
                wrapperTrackEventWithCustomKeys(@"comment", @"write_confirm_unlog_done", self.detailModel.uniqueID, nil, dict);
            }
        }
    }
}

- (BOOL)commentView:(TTCommentWriteView *)commentView shouldCommitWithCommentWriteManager:(TTCommentWriteManager *)commentWriteManager

{
    if (!self.fromU11Cell){
        return YES;
    }
    if (![TTAccountManager isLogin] && _publishStatusForTrack <= 1){
        _publishStatusForTrack = 1;
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        if (!isEmptyString(self.orderedData.categoryID)){
            [dict setValue:self.detailModel.categoryID forKey:@"category_id"];
        }
        if (self.detailModel.gdExtJsonDict.count){
            [dict addEntriesFromDictionary:self.detailModel.gdExtJsonDict];
        }
        [dict setValue:@(self.enterFromClickComment) forKey:@"is_click_button"];
        [dict setValue:@"video" forKey:@"group_type"];
        wrapperTrackEventWithCustomKeys(@"comment", @"write_confirm_unlog", self.detailModel.article.groupModel.groupID, nil, dict);
    }
    
    return YES;
}

#pragma mark - ArticleComentViewDelegate

- (void)commentView:(ArticleCommentView *)commentView didFinishPublishComment:(ArticleMomentCommentModel *)commentModel {
    [commentView dismissAnimated:NO];
    self.commentModelForFloatComment.replyCount = @(self.commentModelForFloatComment.replyCount.integerValue+1);
    if (self.commentIndexPathToReload) {
        [self.commentVC tt_updateCommentCellLayoutAtIndexPath:self.commentIndexPathToReload replyCount:self.commentModelForFloatComment.replyCount.integerValue];
    }
    if (self.commentModelForFloatComment) {
        WeakSelf;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            StrongSelf;
            ArticleMomentModel *momentModel = [commentView.contextInfo objectForKey:ArticleMomentModelKey];
            commentModel.isLocal = YES;
            [self p_showFloatCommentView:self.commentModelForFloatComment momentModel:momentModel momentCommentModel:commentModel];
            self.commentModelForFloatComment = nil;
        });
    }
}

#pragma mark -
#pragma mark TTDetailNatantRelatedVideoBaseViewDelegate

- (void)didSelectVideoAlbum:(Article *)article
{
    [self _showVideoAlbumWithAritcle:article];
    NSString *col_no = [article.videoDetailInfo valueForKey:@"col_no"];
    NSString *media_id =  [self.detailModel.article.mediaInfo valueForKey:@"media_id"];
    if (col_no) {
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        [dic setValue:media_id forKey:@"media_id"];
        wrapperTrackEventWithCustomKeys(@"video", @"detail_click_album", col_no, nil, dic);
    }
    else if ([self.detailModel.article hasVideoSubjectID]) {
        wrapperTrackEventWithCustomKeys(@"video", @"detail_click_album", nil, nil, @{@"video_subject_id": [self.detailModel.article videoSubjectID]});
    }
}

#pragma mark -
#pragma mark PlayControlDelegate

- (CGRect)ttv_playerControlerMovieViewFrameAfterExitFullscreen
{
    return [self frameForMovieView];
}

- (void)ttv_playerControlerShowDetailButtonClicked
{
    if (!isEmptyString(self.landingURL) && ([self.orderedData.ad_id longLongValue] > 0)) {
        UINavigationController *vc = [TTUIResponderHelper topNavigationControllerFor: self];
        ssOpenWebView([TTStringHelper URLWithURLString:self.landingURL], nil, vc, NO, nil);
        [self sendADEvent:@"embeded_ad" label:@"ad_click" value:self.orderedData.ad_id extra:nil logExtra:self.orderedData.log_extra click:YES];
    }
}

- (BOOL)ttv_playerControlerShouldShowDetailButton
{
    if (!isEmptyString(self.landingURL)) {
        return YES;
    }
    return NO;
}

- (void)ttv_shareButtonOnMovieFinishViewClicked
{
    [self _shareActionFired];
    self.activityActionManager.clickSource = @"detail_video_over";
    [TTVideoCommon setCurrentFullScreen:[self.playControl isMovieFullScreen]];
    [self sendVideoShareTrackWithItemType:TTActivityTypeShareButton andSectionType:TTActivitySectionTypeDetailVideoOver];
}

- (void)ttv_shareButtonOnMovieTopViewClicked
{
    [self _shareActionFired];
    self.activityActionManager.clickSource = @"player_share";
    [TTVideoCommon setCurrentFullScreen:[self.playControl isMovieFullScreen]];
    [self sendVideoShareTrackWithItemType:TTActivityTypeShareButton andSectionType:TTActivitySectionTypePlayerShare];
}

- (void)ttv_moreButtonOnMovieTopViewClicked
{
    [self _moreButtonDidPress];
    if ([self.playControl isMovieFullScreen]){
        self.activityActionManager.clickSource = @"player_more";
    }else{
        self.activityActionManager.clickSource = @"no_full_more";
    }
    [TTVideoCommon setCurrentFullScreen:[self.playControl isMovieFullScreen]];
    [self sendVideoShareTrackWithItemType:TTActivityTypeShareButton andSectionType:TTActivitySectionTypePlayerMore];
}

- (void)ttv_playerShareActionClickedWithActivityType:(NSString *)activityType
{
    TTActivityType itemType = [TTActivityShareSequenceManager activityTypeFromStringActivityType:activityType];
    NSString *adId = nil;
    if ([self.detailModel.adID longLongValue] > 0) {
        adId = [NSString stringWithFormat:@"%@", self.detailModel.adID];
    }
    NSString *groupId = [NSString stringWithFormat:@"%lld", self.detailModel.article.uniqueID];
    Article *article = self.orderedData.article;
    NSNumber *adID = @([self.orderedData.ad_id longLongValue]);
    [ArticleShareManager shareActivityManager:self.activityActionManager setArticleCondition:article adID:adID showReport:YES];
    self.activityActionManager.clickSource = @"detail_video_over_direct";
//    if (itemType == TTActivityTypeWeitoutiao){
//        NSMutableDictionary * extraDic = @{}.mutableCopy;
//        if (!isEmptyString(self.detailModel.article.groupModel.itemID)) {
//            [extraDic setValue:self.detailModel.article.groupModel.itemID forKey:@"item_id"];
//        }
//        [self sendVideoShareTrackWithItemType:itemType];
//        [self forwardToWeitoutiao];
//        if (ttvs_isShareIndividuatioEnable()){
//            [[TTActivityShareSequenceManager sharedInstance_tt] instalAllShareActivitySequenceFirstActivity:itemType];
//        }
//    }
//    else{
        [self.activityActionManager performActivityActionByType:itemType inViewController:self sourceObjectType:TTShareSourceObjectTypeVideoDetail uniqueId:groupId adID:adId platform:TTSharePlatformTypeOfMain groupFlags:self.detailModel.article.groupFlags isFullScreenShow:[self.playControl isMovieFullScreen]];
        [self sendVideoShareTrackWithItemType:itemType];
//    }

}

- (void)checkCommentTableShowStatus:(UIScrollView *)scrollView
{
    CGFloat offsetPadding = 0;
    UIView *headerView = self.commentVC.commentTableView.tableHeaderView;
    CGRect rect = [headerView.superview convertRect:headerView.frame toView:self.view];
    if (CGRectGetMaxY(rect) > self.view.frame.size.height)//comment hidden
    {
        [self.commentVC tt_sendShowStatusTrackForCommentShown:NO];
    }
    else
    {
        [self.commentVC tt_sendShowStatusTrackForCommentShown:YES];
    }
    
    [self.natantContainerView checkVisibleAtContentOffset:scrollView.contentOffset.y+offsetPadding referViewHeight:scrollView.height];
    
    
    CGFloat scrollOffsetY = scrollView.contentOffset.y;
    
    if (self.enableScrollToChangeShowStatus) {
        CGFloat scrollToCommentAreaMinHeight = MIN(self.commentVC.commentTableView.contentSize.height - self.commentVC.commentTableView.height, self.commentVC.commentTableView.tableHeaderView.height - self.commentVC.commentTableView.height);
        if (scrollOffsetY < scrollToCommentAreaMinHeight) {
            self.showStatus = VideoDetailViewShowStatusVideo;
        } else {
            self.showStatus = VideoDetailViewShowStatusComment;
        }
    }
    
    [self.natantContainerView sendNatantItemsShowEventWithContentOffset:scrollOffsetY scrollView: scrollView isScrollUp: YES];
}
#pragma mark -
#pragma mark UIScrollView Delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView == self.wrapperScroller) {
        CGFloat scrollOffsetY = scrollView.contentOffset.y;
        [self.relatedVideoGroup checkVisableRelatedArticlesAtContentOffset:scrollOffsetY referViewHeight:0];
    }
}

#pragma mark -
#pragma mark  TTCommentDataSource and  TTCommentDelegate

- (void)tt_commentViewControllerDidShowProfileFill
{
    [self.playControl pauseMovieIfNeeded];
}

/**
 *  required：获取评论列表
 */
- (void)tt_loadCommentsForMode:(TTCommentLoadMode)loadMode
        possibleLoadMoreOffset:(nullable NSNumber *)offset
                       options:(TTCommentLoadOptions)options
                   finishBlock:(nullable TTCommentLoadFinishBlock)finishBlock
{
    //各业务调用自己获取评论的接口，全部封装到TTCommentDataManager
    TTCommentDataManager *dataManager = [[TTCommentDataManager alloc] init];
    [dataManager startFetchCommentsWithGroupModel:self.detailModel.article.groupModel forLoadMode:loadMode loadMoreOffset:offset loadMoreCount:@(TTCommentDefaultLoadMoreFetchCount) msgID:self.detailModel.msgID options:options finishBlock:finishBlock];
}

- (nullable SSThemedView *)tt_commentHeaderView
{
    return self.natantContainerView;
}

- (TTGroupModel *)tt_groupModel
{
    return self.detailModel.article.groupModel;
}

- (NSInteger)tt_zzComments
{
    return self.detailModel.article.zzComments.count;
}

- (void)tt_commentViewController:(id<TTCommentViewControllerProtocol>)ttController didClickCommentCellWithCommentModel:(id<TTCommentModelProtocol>)model
{
}

- (void)tt_commentViewController:(id<TTCommentViewControllerProtocol>)ttController didSelectWithInfo:(NSDictionary *)info {
    id<TTCommentModelProtocol> model = [info tt_objectForKey:@"commentModel"];
    ArticleMomentModel *momentModel = [self tt_genSimpleMomentModelWithComment:model];
    ArticleMomentDetailViewController *detailVC = [[ArticleMomentDetailViewController alloc] initWithComment:model groupModel:model.groupModel momentModel:momentModel delegate:self.commentVC showWriteComment:[info tt_boolValueForKey:@"writeComment"]];
    UINavigationController *topController = [TTUIResponderHelper topNavigationControllerFor: self];
    [topController pushViewController:detailVC animated:YES];
}

- (nullable ArticleMomentModel *)tt_genSimpleMomentModelWithComment:(nullable id<TTCommentModelProtocol>)comment {
    //for preload
    ArticleMomentModel *momentModel = [[ArticleMomentModel alloc] init];
    momentModel.content = comment.commentContent;
    momentModel.diggsCount = [comment.digCount intValue];
    momentModel.digged = comment.userDigged;
    momentModel.createTime = [comment.commentCreateTime doubleValue];
    momentModel.commentsCount = [comment.replyCount intValue];
    momentModel.group = nil;
    momentModel.qutoedCommentModel = comment.quotedComment;
    SSUserModel *user = [[SSUserModel alloc] init];
    user.name = comment.userName;
    user.avatarURLString = comment.userAvatarURL;
    user.ID = [comment.userID stringValue];
    user.userAuthInfo = comment.userAuthInfo;
    user.verifiedReason = comment.verifiedInfo;
    user.relation = [comment.userRelation integerValue];
    user.isFriend = !![comment.userRelation integerValue];
    user.isFollowed = comment.isFollowed;
    user.isFollowing = comment.isFollowing;
    user.authorBadgeList = comment.authorBadgeList;
    momentModel.user = user;

    // 统计用
    momentModel.mediaId = comment.mediaId;
    momentModel.gid = comment.groupModel.groupID;

    return momentModel;
}

- (void)tt_commentViewController:(id<TTCommentViewControllerProtocol>)ttController digCommentWithCommentModel:(id<TTCommentModelProtocol>)model
{
    if (!model.userDigged) {
        NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithCapacity:5];
        [params setValue:self.detailModel.article.groupModel.groupID forKey:@"group_id"];
        [params setValue:self.detailModel.article.groupModel.itemID forKey:@"item_id"];
        [params setValue:model.commentID.stringValue forKey:@"comment_id"];
        [params setValue:model.userID.stringValue forKey:@"user_id"];
        [params setValue:self.detailModel.orderedData.logPb forKey:@"log_pb"];
        [params setValue:self.detailModel.orderedData.categoryID forKey:@"category_name"];
        [params setValue:self.detailModel.clickLabel forKey:@"enter_from"];
        [TTTrackerWrapper eventV3:@"comment_undigg" params:params];
    }
}

- (void)tt_commentViewController:(id<TTCommentViewControllerProtocol>)ttController didClickReplyButtonWithCommentModel:(nonnull id<TTCommentModelProtocol>)model
{
}

- (void)tt_commentViewController:(nonnull TTCommentViewController *)ttController
             scrollViewDidScroll:(nonnull UIScrollView *)scrollView{
    if (![TTDeviceHelper isPadDevice]) {
        self.topPGCView.bottomLine.hidden = (scrollView.contentOffset.y<=0);
    }
    [self vdvi_commentTableViewDidScroll:scrollView];
    [self checkCommentTableShowStatus:scrollView];
    if (self.pgcView.isRecommendList) {
        if (scrollView.contentOffset.y > self.pgcView.bottom && self.pgcView.detectBottom) {
            [self.pgcView recommendListEndDisplay];
            self.pgcView.detectBottom = NO;
        }
        else if (scrollView.contentOffset.y < self.pgcView.bottom && !self.pgcView.detectBottom) {
            [self.pgcView recommendListWillDisplay];
            self.pgcView.detectBottom = YES;
        }
        else if (scrollView.contentOffset.y + self.commentVC.view.height > self.pgcView.top && !self.pgcView.detectTop) {
            [self.pgcView recommendListWillDisplay];
            self.pgcView.detectTop = YES;
        }
        else if (scrollView.contentOffset.y + self.commentVC.view.height < self.pgcView.top && self.pgcView.detectTop) {
            [self.pgcView recommendListEndDisplay];
            self.pgcView.detectTop = NO;
        }
    }
    
}

- (void)tt_commentViewController:(id<TTCommentViewControllerProtocol>)ttController scrollViewDidEndScrollAnimation:(UIScrollView *)scrollView
{
    self.enableScrollToChangeShowStatus = YES;
}

- (void)tt_commentViewController:(id<TTCommentViewControllerProtocol>)ttController scrollViewDidEndDragging:(nonnull UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    [self vdvi_commentTableViewDidEndDragging:scrollView];
}

- (void)tt_commentViewController:(id<TTCommentViewControllerProtocol>)ttController tappedWithUserID:(NSString *)userID {
    if ([userID longLongValue] == 0) {
        return;
    }
    NSString *userIDstr = [NSString stringWithFormat:@"%@", userID];
    
    ArticleMomentProfileViewController * controller = [[ArticleMomentProfileViewController alloc] initWithUserID:userIDstr];
    controller.from = kFromNewsDetailComment;
    [self.navigationController pushViewController:controller animated:YES];
    
}

- (void)tt_commentViewController:(id<TTCommentViewControllerProtocol>)ttController avatarTappedWithCommentModel:(id<TTCommentModelProtocol>)model
{
    if ([model.userID longLongValue] == 0) {
        return;
    }
    
    NSString * userID = [NSString stringWithFormat:@"%@", model.userID];
    
    ArticleFriend *articleFriend = [[ArticleFriend alloc] init];
    articleFriend.userID = [NSString stringWithString:userID];
    articleFriend.avatarURLString = [NSString stringWithString:model.userAvatarURL];
    articleFriend.userAuthInfo = model.userAuthInfo;
    
    if (isEmptyString(articleFriend.userID)) {
        return;
    }
    
    ArticleMomentProfileViewController * controller = [[ArticleMomentProfileViewController alloc] initWithUserID:articleFriend.userID];
    controller.from = kFromNewsDetailComment;
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)tt_commentViewControllerDidFetchCommentsWithError:(NSError *)error
{
    //是否已经更新article的commentCount？
    _hasFetchedComments = YES;
    if ([self.commentVC respondsToSelector:@selector(tt_defaultReplyCommentModel)] && self.commentVC.tt_defaultReplyCommentModel) {
        NSString *userName = self.commentVC.tt_defaultReplyCommentModel.userName;
        [self.toolbarView.writeButton setTitle:isEmptyString(userName)? @"写评论": [NSString stringWithFormat:@"回复 %@：", userName] forState:UIControlStateNormal];
    }
    //如果info接口返回了数据，commenVC.view被添加，则执行此操作
    if (self.commentVC.view.superview) {
        //info接口比comment接口先返回
        [self _scrollToCommentsIfNeeded];
    }

    // toolbar 禁表情
    BOOL isBanRepostOrEmoji = ![KitchenMgr getBOOL:KKCCommentRepostFirstDetailEnable] || (self.detailModel.adID > 0) || ak_banEmojiInput();
    if ([self.commentVC respondsToSelector:@selector(tt_banEmojiInput)]) {
        self.toolbarView.banEmojiInput = self.commentVC.tt_banEmojiInput || isBanRepostOrEmoji;
    }
}

- (BOOL)tt_commentViewController:(id<TTCommentViewControllerProtocol>)ttController shouldPresentCommentDetailViewControllerWithCommentModel:(id<TTCommentModelProtocol>)model indexPath:(NSIndexPath *)indexPath showKeyBoard:(BOOL)showKeyBoard {
    
    if (!isEmptyString(model.openURL)) {
        [[TTRoute sharedRoute] openURLByPushViewController:[TTStringHelper URLWithURLString:model.openURL]];
    } else {
        self.commentIndexPathToReload = indexPath;
        if (!model.replyCount.integerValue) {
            [self p_showWriteCommentWithCommentModel:model];
        } else {
            [self p_showFloatCommentView:model momentModel:nil momentCommentModel:nil];
        }
    }
    return YES;
}

- (void)tt_commentViewController:(id<TTCommentViewControllerProtocol>)ttController startWriteComment:(id<TTCommentModelProtocol>)model {
    [self _writeCommentActionFired:nil];
}

- (void)tt_commentViewControllerRefreshDataInNoNetWorkCondition{
    [self buildPlaceholdView];
    [self.commentVC.view removeFromSuperview];
    [self startLoadArticleInfo];
}

- (void)tt_commentViewController:(nonnull id<TTCommentViewControllerProtocol>)ttController
             refreshCommentCount:(int)count
{
    self.detailModel.article.commentCount = count;
    [self.detailModel.article save];
}

- (void)tt_commentViewControllerFooterCellClicked:(nonnull id<TTCommentViewControllerProtocol>)ttController
{
    NSMutableDictionary *extra = [[NSMutableDictionary alloc] init];
    [extra setValue:self.detailModel.article.itemID forKey:@"item_id"];
    wrapperTrackEventWithCustomKeys(@"fold_comment", @"click", self.detailModel.article.groupModel.groupID, nil, extra);
    NSMutableDictionary *condition = [[NSMutableDictionary alloc] init];
    [condition setValue:self.detailModel.article.groupModel.groupID forKey:@"groupID"];
    [condition setValue:self.detailModel.article.groupModel.itemID forKey:@"itemID"];
    [condition setValue:self.detailModel.article.aggrType forKey:@"aggrType"];
    [condition setValue:[self.detailModel.article zzCommentsIDString] forKey:@"zzids"];
    
    [[TTRoute sharedRoute] openURLByPushViewController:[NSURL URLWithString:@"sslocal://fold_comment"] userInfo:TTRouteUserInfoWithDict(condition)];
}

#pragma mark - TTVideoDetailFloatCommentViewControllerDelegate

- (void)videoDetailFloatCommentViewControllerDidDimiss:(TTVideoDetailFloatCommentViewController *)vc
{
    [_floatCommentVC removeFromParentViewController];
    [_floatCommentVC.view removeFromSuperview];
    _floatCommentVC = nil;
    self.toolbarView.hidden = NO;
}

- (void)videoDetailFloatCommentViewControllerDidChangeDigCount {
    [self.commentVC.commentTableView reloadData];
}

#pragma mark - TTVideoMovieBannerDelegate

- (void)didLoadImage:(TTVideoMovieBanner *)banner
{
    [self layoutViews];
}

#pragma mark - TTDetailNatantVideoInfoViewDelegate

- (void)extendLinkButton:(UIButton *)button clickedWithArticle:(Article *)article {
    [self showExtendLinkViewWithArticle:article isAuto:NO];
}

- (void)shareButton:(UIButton *)button clickedWithArticle:(Article *)article{
    [self _shareActionFired];
    self.activityActionManager.clickSource = @"centre_button";
    [TTVideoCommon setCurrentFullScreen:[self.playControl isMovieFullScreen]];
    [self sendVideoShareTrackWithItemType:TTActivityTypeShareButton andSectionType:TTActivitySectionTypeCentreButton];
}
- (void)directShareActionClickedWithActivityType:(NSString *)activityType
{
    TTActivityType itemType = [TTActivityShareSequenceManager activityTypeFromStringActivityType:activityType];
    NSString *adId = nil;
    if ([self.detailModel.adID longLongValue] > 0) {
        adId = [NSString stringWithFormat:@"%@", self.detailModel.adID];
    }
    NSString *groupId = [NSString stringWithFormat:@"%lld", self.detailModel.article.uniqueID];
    self.activityActionManager.clickSource = @"centre_button_direct";
    self.activityActionManager.authorId = [self.detailModel.article.userInfo ttgc_contentID];
//    if (itemType == TTActivityTypeWeitoutiao){
//        NSMutableDictionary * extraDic = @{}.mutableCopy;
//        if (!isEmptyString(self.detailModel.article.groupModel.itemID)) {
//            [extraDic setValue:self.detailModel.article.groupModel.itemID forKey:@"item_id"];
//        }
//        [self sendVideoShareTrackWithItemType:itemType];
//        [self forwardToWeitoutiao];
//        if (ttvs_isShareIndividuatioEnable()){
//            [[TTActivityShareSequenceManager sharedInstance_tt] instalAllShareActivitySequenceFirstActivity:itemType];
//        }
//    }
//    else{
        [ArticleShareManager shareActivityManager:self.activityActionManager setArticleCondition:self.detailModel.article adID:self.detailModel.adID showReport:YES];
        [self.activityActionManager performActivityActionByType:itemType inViewController:self sourceObjectType:TTShareSourceObjectTypeVideoDetail uniqueId:groupId adID:adId platform:TTSharePlatformTypeOfMain groupFlags:self.detailModel.article.groupFlags isFullScreenShow:[self.playControl isMovieFullScreen]];
        [self sendVideoShareTrackWithItemType:itemType];
//    }

}
#pragma mark - utility

- (BOOL)p_shouldShowTopPGCView {
    return YES;
}

- (NSString *)p_contentID {
    NSString *contentID = nil;
    Article *article = self.detailModel.article;
    if (article.userInfo || article.detailUserInfo) {
        contentID = [article.userInfo[@"user_id"] stringValue];
        if ([article hasVideoSubjectID]) {
            contentID = [article.detailUserInfo[@"user_id"] stringValue];
        }
    } else {
        contentID = [article.mediaInfo[@"media_id"] stringValue];
        if ([article hasVideoSubjectID]) {
            contentID = [article.detailMediaInfo[@"media_id"] stringValue];
        }
    }
    return contentID;
}

//来源-[TTDetailModel shouldBeginShowComment]
- (BOOL)shouldBeginShowComment {
    return self.beginShowComment || self.beginShowCommentUGC;
}
#pragma mark - getters and setters

- (ExploreVideoTopView *)topView
{
    if (!_topView) {
        CGFloat topMargin = [TTDeviceHelper isIPhoneXDevice] ? 44 : 0;
        _topView = [[ExploreVideoTopView alloc] initWithFrame:CGRectMake(0, topMargin, [[UIScreen mainScreen] bounds].size.width, kTopViewHeight)];
        [_topView.backButton addTarget:self action:@selector(_topViewBackButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    }
    return _topView;
}

- (UIView *)moviewViewContainer
{
    if (!_moviewViewContainer) {
        //两边留黑垫一层
        _moviewViewContainer = [[UIView alloc] init];
        [_moviewViewContainer addSubview:self.movieShotView];
    }
    return _moviewViewContainer;
}

- (TTVideoMovieBanner *)movieBanner
{
    if (!_movieBanner) {
        _movieBanner = [[TTVideoMovieBanner alloc] initWithWidth:self.view.width];
        _movieBanner.delegate = self;
        _movieBanner.hidden = YES;
        self.playControl.movieBanner = _movieBanner;
    }
    return _movieBanner;
}

- (TTDetailNatantContainerView *)natantContainerView
{
    if (!_natantContainerView) {
        _natantContainerView = [[TTDetailNatantContainerView alloc] init];
        _natantContainerView.sourceType = TTDetailNatantContainerViewSourceType_VideoDetail;
    }
    return _natantContainerView;
}

- (TTVideoAlbumView *)videoAlbum
{
    if (!_videoAlbum) {
        _videoAlbum = [[TTVideoAlbumView alloc] init];
        _videoAlbum.width = self.view.width;
        _videoAlbum.height = self.view.height - [self frameForMovieView].size.height;
        _videoAlbum.bottom = self.view.height;
    }
    return _videoAlbum;
}

- (SSThemedScrollView *)wrapperScroller
{
    if (!_wrapperScroller) {
        _wrapperScroller = [[SSThemedScrollView alloc] init];
        _wrapperScroller.delegate = self;
        
        self.distinctNatantTitle.left = 20;
        self.distinctNatantTitle.top = 20;
        
        [_wrapperScroller addSubview:self.distinctNatantTitle];
    }
    return _wrapperScroller;
}

- (SSThemedView *)distinctLine
{
    if (!_distinctLine) {
        _distinctLine = [[SSThemedView alloc] init];
        _distinctLine.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        _distinctLine.backgroundColorThemeKey = kColorLine7;
        _distinctLine.width = [TTDeviceHelper ssOnePixel];
        _distinctLine.height = self.view.height;
    }
    return _distinctLine;
}

- (SSThemedLabel *)distinctNatantTitle
{
    if (!_distinctNatantTitle) {
        _distinctNatantTitle = [[SSThemedLabel alloc] init];
        _distinctNatantTitle.font = [UIFont systemFontOfSize:18];
        _distinctNatantTitle.textColorThemeKey = kColorText1;
        _distinctNatantTitle.text = @"相关视频";
        [_distinctNatantTitle sizeToFit];
    }
    return _distinctNatantTitle;
}

- (TTCommentViewController *)commentVC
{
    if (!_commentVC) {
        CGFloat movieHeight = [self frameForMovieContainerView].size.height;
        _commentVC = [[TTCommentViewController alloc] initWithViewFrame:CGRectMake(0, movieHeight, self.view.width, self.view.height - movieHeight) dataSource:self delegate:self];
        _commentVC.enableImpressionRecording = YES;
        _commentVC.hasSelfShown = YES;
    }
    return _commentVC;
}

- (ExploreDetailToolbarView *)toolbarView
{
    if (!_toolbarView) {
        _toolbarView = [[ExploreDetailToolbarView alloc] init];
        _toolbarView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth;
        _toolbarView.toolbarType = ExploreDetailToolbarTypeNormal;
        _toolbarView.fromView = ExploreDetailToolbarFromViewVideoDetail;
        _toolbarView.viewStyle = TTDetailViewStyleDarkContent;
        [_toolbarView.writeButton addTarget:self action:@selector(_writeCommentActionFired:) forControlEvents:UIControlEventTouchUpInside];
        [_toolbarView.emojiButton addTarget:self action:@selector(_writeCommentActionFired:) forControlEvents:UIControlEventTouchUpInside];
        [_toolbarView.commentButton addTarget:self action:@selector(_showCommentActionFired) forControlEvents:UIControlEventTouchUpInside];
        [_toolbarView.topButton addTarget:self action:@selector(_showCommentActionFired) forControlEvents:UIControlEventTouchUpInside];
        [_toolbarView.collectButton addTarget:self action:@selector(_collectActionFired) forControlEvents:UIControlEventTouchUpInside];
        [_toolbarView.shareButton addTarget:self action:@selector(toolBarshareDidPress) forControlEvents:UIControlEventTouchUpInside];
        _toolbarView.topButton.alpha = 0.f;
        _toolbarView.topButton.hidden = NO;
        
    }
    return _toolbarView;
}

- (ArticleInfoManager *)infoManager
{
    if (!_infoManager) {
        _infoManager = [[ArticleInfoManager alloc] init];
        _infoManager.delegate = self;
    }
    return _infoManager;
}

- (TTActivityShareManager *)activityActionManager
{
    if (!_activityActionManager) {
        _activityActionManager = [[TTActivityShareManager alloc] init];
        _activityActionManager.isVideoSubject = YES;
        _activityActionManager.authorId = [self.detailModel.article.userInfo ttgc_contentID];
        _activityActionManager.miniProgramEnable = [self.detailModel.adID longLongValue] == 0 && [self.article isVideoSourceUGCVideoOrHuoShan] == NO;
        _activityActionManager.delegate = self;
    }
    return _activityActionManager;
}

- (ExploreOrderedData *)tempData
{
    if (self.detailModel.article) {
        // TODO: check
        ExploreOrderedData *data = [[ExploreOrderedData alloc] initWithArticle:self.detailModel.article];
        data.uniqueID = [NSString stringWithFormat:@"%lld", self.detailModel.article.uniqueID];
        if (self.shareMovie.hasClickRelated) {
            data.categoryID = @"related";
        }
        data.itemID = self.detailModel.article.itemID;
        //data.originalData = self.detailModel.article;
        data.cellType = ExploreOrderedDataCellTypeArticle;
        data.logExtra = [self.detailModel.article relatedLogExtra];
        data.adID = self.detailModel.article.relatedVideoExtraInfo[kArticleInfoRelatedVideoAdIDKey];
        if (data.adID) {
            data.adIDStr = [NSString stringWithFormat:@"%@",data.adID];
        }
        return data;
    }
    
    return nil;
}

- (UIView *)animationToView
{
    return self.movieShotView;
}

- (NSDictionary *)userInfo
{
    if (self.detailModel.article.detailUserInfo) {
        return self.detailModel.article.detailUserInfo;
    } else {
        return self.detailModel.article.userInfo;
    }
}

- (void)setShowStatus:(VideoDetailViewShowStatus)showStatus
{
    BOOL isComment = showStatus == VideoDetailViewShowStatusComment;
    
    if (isComment && self.shouldSendCommentTrackEvent) {
        NSMutableDictionary *extra = [[NSMutableDictionary alloc] initWithCapacity:2];
        [extra setValue:_isCommentButtonClicked? @"click": @"pull" forKey:@"action"];
        [extra setValue:@"video" forKey:@"source"];
        [extra setValue:self.detailModel.article.itemID forKey:@"item_id"];
        wrapperTrackEventWithCustomKeys(@"enter_comment", [NSString stringWithFormat:@"click_%@", self.detailModel.categoryID], [self.detailModel uniqueID], nil, extra);
        self.shouldSendCommentTrackEvent = NO;
    }
    if (_showStatus == showStatus) {
        return;
    }
    _showStatus = showStatus;
}

#pragma  mark - filter natantAD

- (NSNumber *) isNeedShowNatantADView:(ArticleInfoManager *)manager withAdData:(NSDictionary *)adData {
    if ([SSCommonLogic isRepeatedAdDisable]) {
        return @(YES);
    }
    //默认需要显示natantAdView
    __block NSNumber *result = @(YES);
    if (SSIsEmptyDictionary(adData)) {
        result = @(NO);
        return result;
    }
    NSMutableArray *adIDs = [NSMutableArray arrayWithCapacity:adData.count];
    [adData enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if (!SSIsEmptyDictionary(obj)) {
            NSInteger type = [TTAdDetailViewHelper typeWithADKey:key];
            if (type != NSNotFound) {
                ArticleDetailADModel *adModel = [[ArticleDetailADModel alloc] initWithDictionary:obj detailADType:(ArticleDetailADModelType)type];
                if ([adModel isModelAvailable]) {
                    [adIDs addObject:adModel.ad_id];
                }
            }else{
                //广告类型未知  逻辑同 TTVideoDetailADContainerView
                if(obj[@"id"]){
                    NSMutableDictionary* dict = [NSMutableDictionary dictionary];
                    [dict setValue:@"video" forKey:@"detail_location"];
                    [dict setValue:[NSString stringWithFormat:@"%@", key] forKey:@"type"];
                    [dict setValue:obj[@"log_extra"] forKey:@"log_extra"];
                    [dict setValue:obj[@"id"] forKey:@"ad_id"];
                    [TTAdManager monitor_trackService:@"ad_detail_unkowntype" status:1 extra:dict];
                }
                
            }
        }
    }];
    //与related video AD进行匹配
    if (adIDs.count > 0) {
        if (manager.relateVideoArticles.count > 0) {
            NSDictionary *relatedVideo = [manager.relateVideoArticles objectAtIndex:0];
            
            if(!SSIsEmptyDictionary(relatedVideo)){
                Article* article = [relatedVideo objectForKey:@"article"];
                TTAdVideoRelateAdModel* adModel = article.videoAdExtra;
                NSString *relatedAdID = adModel.ad_id;
                [adIDs enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    if(!isEmptyString(relatedAdID)){
                        NSString *objStr = [NSString stringWithFormat:@"%@",obj];
                        if ([relatedAdID isEqualToString:objStr]) {
                            result = @(NO);
                            *stop = YES;
                        }
                    }
                }];
                
            }
            
        }
    } else {          //adIDs数组容量是0，说明没有合法adModel，则不需要展示浮层广告
        result = @(NO);
    }
    return result;
}


#pragma mark - 埋点

- (void)sendVideoShareTrackWithItemType:(TTActivityType)itemType
{
    TTActivitySectionType sectionType = 100; //100返回空
    NSString *iconSeat;
    if (_activityActionManager.clickSource) {
        if ([_activityActionManager.clickSource isEqualToString:@"centre_button"]) {
            sectionType = TTActivitySectionTypeCentreButton;
            iconSeat = @"inside";
        }else if ([_activityActionManager.clickSource isEqualToString:@"centre_button_direct"]){
            sectionType = TTActivitySectionTypeCentreButton;
            iconSeat = @"exposed";
        }else if ([_activityActionManager.clickSource isEqualToString:@"player_more"]){
            sectionType = TTActivitySectionTypePlayerMore;
            iconSeat = nil;
        }else if ([_activityActionManager.clickSource isEqualToString:@"player_share"]){
            sectionType = TTActivitySectionTypePlayerShare;
            iconSeat = nil;
        }else if ([_activityActionManager.clickSource isEqualToString:@"detail_video_over"]){
            sectionType = TTActivitySectionTypeDetailVideoOver;
            iconSeat = @"inside";
        }else if ([_activityActionManager.clickSource isEqualToString:@"detail_video_over_direct"]){
            sectionType = TTActivitySectionTypeDetailVideoOver;
            iconSeat = @"exposed";
        }else if ([_activityActionManager.clickSource isEqualToString:@"detail_bottom_bar"]){
            sectionType = TTActivitySectionTypeDetailBottomBar;
            iconSeat = nil;
        }else if ([_activityActionManager.clickSource isEqualToString:@"no_full_more"]){
            sectionType = TTActivitySectionTypePlayerMore;
            iconSeat = nil;
        }
    }
    [self sendVideoShareTrackWithItemType:itemType andSectionType:sectionType WithIconSeat:iconSeat];
}

- (void)sendVideoShareTrackWithItemType:(TTActivityType)itemType andSectionType:(TTActivitySectionType)sectionType
{
    [self sendVideoShareTrackWithItemType:itemType andSectionType:sectionType WithIconSeat:nil];
}

- (void)sendVideoShareTrackWithItemType:(TTActivityType)itemType andSectionType:(TTActivitySectionType)sectionType WithIconSeat:(NSString *)iconSeat
{
    
    NSString *tag = [TTActivityShareManager tagNameForShareSourceObjectType:TTShareSourceObjectTypeVideoDetail];
    NSString *label = [[self class] labelNameForShareActivityType:itemType];
    NSMutableDictionary *extValueDic = [NSMutableDictionary dictionary];
    if ([self.detailModel.adID longLongValue]) {
        NSString *adId = [NSString stringWithFormat:@"%lld", [self.detailModel.adID longLongValue]];
        extValueDic[@"ext_value"] = adId;
    }
    NSString *sectionName = [TTVideoCommon videoSectionNameForShareActivityType:sectionType];
    if (sectionName) {
        [extValueDic setValue:sectionName forKey:@"section"];
        [extValueDic setValue:@"video" forKey:@"source"];
        if ([TTVideoCommon MovieWiewIsFullScreen]){
            [extValueDic setValue: @"fullscreen" forKey: @"fullscreen"];
        }else{
            [extValueDic setValue:@"notfullscreen" forKey: @"fullscreen"];
        }
    }
    if (iconSeat) {
        [extValueDic setValue:iconSeat forKey:@"icon_seat"];
    }
    [self.detailModel sendDetailTrackEventWithTag:tag label:label extra:extValueDic];
}

+ (NSString *)labelNameForShareActivityType:(TTActivityType)activityType
{
    return [TTVideoCommon videoListlabelNameForShareActivityType:activityType];
}

#pragma mark - toast:顶／踩／收藏 适配全屏
//默认Image类类型
- (void) showIndicatorViewWithTip:(NSString *)tipMsg andImage:(UIImage *)indicatorImage dismissHandler:(DismissHandler)handler{
    TTIndicatorView *indicateView = [[TTIndicatorView alloc] initWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:tipMsg indicatorImage:indicatorImage dismissHandler:handler];
//    [indicateView addTransFormIsFullScreen:[self.playControl isMovieFullScreen]];
    indicateView.autoDismiss = YES;
    [indicateView showFromParentView:self.phoneShareView.panelController.backWindow.rootViewController.view];
//    [indicateView changeFrameIsFullScreen:[self.playControl isMovieFullScreen]];
}

- (NSString *)enterFrom
{
    NSString *enterFrom = self.detailModel.clickLabel;
    if (self.detailModel.fromSource == NewsGoDetailFromSourceVideoFloat || self.detailModel.fromSource == NewsGoDetailFromSourceCategory)
    {
        enterFrom = @"click_category";
    }
    else if (self.detailModel.fromSource == NewsGoDetailFromSourceVideoFloatRelated)
    {
        enterFrom = @"click_related";
    }
    return enterFrom;
}

- (NSString *)categoryName
{
    NSString *categoryName = self.detailModel.categoryID;
    if ([categoryName hasPrefix:@"_"]) {
        categoryName = [categoryName substringFromIndex:1];
    }
    if (!categoryName || [categoryName isEqualToString:@"xx"]) {
        categoryName = [[self enterFrom] stringByReplacingOccurrencesOfString:@"click_" withString:@""];
    }
    return categoryName;
}

#pragma mark log3.0

- (void)goDetailSendEvent3Data{
    
    NSMutableDictionary *event3Dic = [NSMutableDictionary dictionary];
    [self event3CommonData:event3Dic];
    [event3Dic setValue:self.detailModel.article.novelData[@"book_id"] forKey:@"novel_id"];
    NSString *mediaID = [self.detailModel.article.mediaInfo[@"media_id"] stringValue];
    if ([self.detailModel.article hasVideoSubjectID]) {
        mediaID = [self.detailModel.article.detailMediaInfo[@"media_id"] stringValue];
    }
    [event3Dic setValue:mediaID forKey:@"media_id"];
    [event3Dic setValue:self.detailModel.orderedData.concernID forKey:@"concern_id"];
    [event3Dic setValue:self.detailModel.orderedData.ad_id forKey:@"ad_id"];
    BOOL hasZzComment = self.detailModel.article.zzComments.count > 0;
    [event3Dic setValue:@(hasZzComment ? 1 : 0) forKey:@"has_zz_comment"];
    
    if (hasZzComment) {
        [event3Dic setValue:self.detailModel.article.firstZzCommentMediaId forKey:@"zz_mdedia"];
    }
    [event3Dic setValue:@"video" forKey:@"group_type"];
    [event3Dic setValue:self.detailModel.orderedData.groupSource forKey:@"group_source"];
    [event3Dic setValue:self.detailModel.categoryID forKey:@"category_id"];
    [event3Dic setValue:[self.detailModel.article.userInfo ttgc_contentID] forKey:@"author_id"];
    [event3Dic setValue:@"video" forKey:@"article_type"];
    [TTTrackerWrapper eventV3:@"go_detail" params:event3Dic isDoubleSending:YES];
    
    /** TODO
     *parent_enterfrom
     *qid
     *question_id
     *card_id
     *gtype
     *card_position
     *ansid
     *answer_id
     *click_position
     *refer
     *group_source
     **/
}

- (void)stayPageSendEvent3Data{
    NSMutableDictionary *event3Dic = [NSMutableDictionary dictionary];
    [self event3CommonData:event3Dic];
    [event3Dic setValue:self.detailModel.article.novelData[@"book_id"] forKey:@"novel_id"];
    [event3Dic setValue:@"video" forKey:@"page_type"];
    if (!isEmptyString(_detailModel.article.groupModel.itemID)) {
        [event3Dic setValue:_detailModel.article.groupModel.itemID forKey:@"item_id"];
        [event3Dic setValue:@(_detailModel.article.groupModel.aggrType) forKey:@"aggr_type"];
    }
    [event3Dic setValue:_detailModel.orderedData.log_extra forKey:@"log_extra"];
    [event3Dic setValue:self.detailModel.orderedData.concernID forKey:@"concern_id"];
    
    
    //埋点1.0字段
    [event3Dic setValue:_detailModel.orderedData.log_extra forKey:@"log_extra"];
    
    /** TODO
     *parent_enterfrom
     *card_id
     *gtype
     *refer
     *question_id
     *answer_id
     *group_source
     *stay_time2
     */
    [self.tracker endStayTrackWithDict:event3Dic];
}

- (void)event3CommonData:(NSMutableDictionary *)event3Dic{
    
    [event3Dic setValue:self.detailModel.article.itemID forKey:@"item_id"];
    [event3Dic setValue:[self.detailModel uniqueID] forKey:@"group_id"];
    NSString *enterFrom = self.detailModel.clickLabel;
    NSString *categoryName = self.detailModel.categoryID;
    if (![enterFrom isEqualToString:@"click_headline"]) {
        if (self.detailModel.fromSource == NewsGoDetailFromSourceVideoFloat || self.detailModel.fromSource == NewsGoDetailFromSourceCategory)
        {
            enterFrom = @"click_category";
        }
        else if (self.detailModel.fromSource == NewsGoDetailFromSourceClickTodayExtenstion) {
            enterFrom = @"click_widget";
        }
        if ([categoryName hasPrefix:@"_"]) {
            categoryName = [categoryName substringFromIndex:1];
        }
    }
    if (!categoryName || [categoryName isEqualToString:@"xx"]) {
        categoryName = [enterFrom stringByReplacingOccurrencesOfString:@"click_" withString:@""];
    }
    [event3Dic setValue:enterFrom forKey:@"enter_from"];
    [event3Dic setValue:self.detailModel.article.aggrType forKey:@"aggr_type"];
    //self.detailModel.gdExtJsonDict
    [event3Dic setValue:categoryName forKey:@"category_name"];
    [event3Dic setValue:self.detailModel.logPb forKey:@"log_pb"];
    [event3Dic addEntriesFromDictionary:self.detailModel.gdExtJsonDict];
}

#pragma mark - TTActivityShareManagerDelegate

- (void)activityShareManager:(TTActivityShareManager *)activityShareManager
    completeWithActivityType:(TTActivityType)activityType
                       error:(NSError *)error {
//    if (!error) {
//        [[TTShareToRepostManager sharedManager] shareToRepostWithActivityType:activityType
//                                                                   repostType:TTThreadRepostTypeArticle
//                                                            operationItemType:TTRepostOperationItemTypeArticle
//                                                              operationItemID:self.detailModel.article.itemID
//                                                                originArticle:[[TTRepostOriginArticle alloc] initWithArticle:self.detailModel.article]
//                                                                 originThread:nil
//                                                               originShortVideoOriginalData:nil
//                                                            originWendaAnswer:nil
//                                                               repostSegments:nil];
//    }
}

@end

