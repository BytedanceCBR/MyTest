//
//  TTVVideoDetailViewController.m
//  Article
//
//  Created by pei yun on 2017/5/8.
//
//

#import "TTVVideoDetailViewController.h"
#import "ExploreVideoTopView.h"
#import "TTVVideoDetailHeaderPosterViewController.h"
#import "TTVVideoDetailRelatedVideoViewController.h"
#import "TTVCommentViewController.h"
#import "TTVVideoDetailToolBarViewController.h"
#import "TTAdDetailViewHelper.h"
#import "TTVReplyViewController.h"
#import "Article.h"
#import <TTVideoService/VideoFeed.pbobjc.h>
#import "TTVFeedItem+TTVConvertToArticle.h"
#import "TTVFeedItem+TTVArticleProtocolSupport.h"
#import "TTVFeedItem+Extension.h"
#import "TTVVideoArticle+Extension.h"
#import "TTMonitor.h"
#import "TTIndicatorView.h"
#import "TTDetailModel+videoArticleProtocol.h"
#import "TTVVideoInformationSyncProtocol.h"
#import "TTVVideoDetailContainerScrollView.h"
#import "UIViewController+Refresh_ErrorHandler.h"
#import "Article+TTVArticleProtocolSupport.h"
#import "UIViewController+NavigationBarStyle.h"
#import "TTVideoDetailHeaderPosterView.h"
#import "ExploreDetailToolbarView.h"
#import "TTVVideoDetailVCDefine.h"
#import "TTVMacros.h"
#import "TTVVideoDetailStayPageTracker.h"
#import "TTCommentDataManager.h"
#import "ArticleFriend.h"
#import "UIView+TTVNestedScrollViewSupport.h"
#import "TTVVideoDetailViewController+ExtendLink.h"
#import "SSIndicatorTipsManager.h"
#import "HPGrowingTextView.h"
#import "TTVVideoDetailAlbumView.h"
#import "UIView+TTVHitTestExtensions.h"
#import "TTRoute.h"
#import "TTVVideoDetailNatantVideoBanner.h"
#import "TTVPartnerVideo+TTVVideoDetailNatantViewDataProtocolSupport.h"
#import "TTVVideoDetailMovieBanner.h"
#import "TTVVideoDetailNatantTagsView.h"
#import "TTVArticleConvertor.h"
#import "TTVVideoDetailNatantADView.h"
#import "TTVVideoDetailNatantPGCViewController.h"
#import "TTVVideoDetailNatantPGCAuthorView.h"
#import "TTVVideoDetailNatantInfoViewController.h"
#import "TTVideoDetailADContainerView.h"
#import "TTAdVideoViewFactory.h"
#import "TTAdManager.h"
#import "TTVVideoDetailTextlinkADView.h"
#import "ExploreVideoDetailHelper.h"
#import "TTVVideoDetailViewController_Private.h"
#import "TTUIResponderHelper.h"
#import "TTVideoTip.h"
#import "TTArticleTabBarController.h"
#import "SSAppStore.h"
#import "ExploreMomentDefine.h"
#import "TTVideoShareMovie.h"
#import "KVOController.h"
#import <TTVideoService/TTVideoInfomationService.h>
#import <TTVideoService/TTVideoDetailResponse.h>
#import "TTVVideoInformationResponse+TTVArticleProtocolSupport.h"
#import "TTVVideoInformationResponse+TTVVideoDetailNatantViewDataProtocolSupport.h"
#import "TTVVideoInformationResponse+TTAdDetailInnerArticleProtocolSupport.h"
#import "TTVVideoInformationResponse+TTAdNatantDataModelSupport.h"
#import "TTVVideoInformationResponse+TTVComputedProperties.h"
#import "ExploreMovieView.h"
#import "TTVDetailContentEntity.h"
#import "TTVAutoPlayManager.h"
#import "UIViewController+TTVAdditions.h"
#import "TTCommentWriteView.h"
#import "TTVShareDetailTracker.h"
#import "TTCommentDetailModel+TTCommentDetailModelProtocolSupport.h"
#import "TTCommentDetailReplyCommentModel+TTCommentDetailReplyCommentModelProtocolSupport.h"
#import "TTCommentDetailReplyCommentModel+TTVReplyModelProtocolSupport.h"
#import "TTCommentDataManager.h"
#import "TTVVideoDetailCarCardView.h"
#import <ReactiveObjC/ReactiveObjC.h>
#import "TTVFeedItem+TTVArticleProtocolSupport.h"
#import "ExploreOrderedData.h"
#import "ExploreOrderedData+TTAd.h"
#import "TTVPlayerDoubleTap666Delegate.h"
#import "TTVFeedListViewController.h"
#import <TTSettingsManager/TTSettingsManager.h>
#import "TTVVideoDetailCommodityViewController.h"
#import "TTVDetailFollowRecommendViewController.h"
#import "UIView+CustomTimingFunction.h"
#import "TTRelevantDurationTracker.h"
#import "TTTabBarProvider.h"
#import "TTCommentViewControllerProtocol.h"
#import "AKAwardCoinVideoMonitorManager.h"

#define kTopViewHeight  44.f

NSString *const TTVideoDetailViewControllerDeleteVideoArticle = @"TTVideoDetailViewControllerDeleteVideoArticle";
NSString *const video_play_detail_info_status = @"video_play_detail_info_status";
NSString *const assertDesc_articleType = @"protocoledArticle must be Article";


@interface TTVVideoDetailViewController () <TTCommentDataSource, TTCommentViewControllerDelegate, UIScrollViewDelegate, TTVReplyViewControllerDelegate, TTVVideoDetailHomeToToolbarVCActionProtocol, TTVVideoDetailHomeToHeaderActionProtocol, TTVVideoDetailHomeToRelatedVideoVCActionProtocol, TTAdDetailContainerViewDelegate, TTVVideoDetailMovieBannerDelegate ,TTVCommentDataSource,TTVCommentDelegate ,UIViewControllerErrorHandler,TTVVideoDetailNatantPGCViewDelegate>

@property (nonatomic, strong) ExploreVideoTopView                 *topView;
@property (nonatomic, strong) SSThemedView *statusBarBackgrView;
@property (nonatomic, assign) BOOL ttv_statusBarHidden;
@property (nonatomic, assign) BOOL originalStatusBarHidden;
@property (nonatomic, strong) UINavigationController *navigationControllerBeforeBeingPoped;

@property (nonatomic, copy) NSString *ruleID;   //推送gid对应的唯一标识
@property (nonatomic, copy) NSString *originalGroupID;  //schema中的初始gid

@property (nonatomic, strong) TTVVideoDetailHeaderPosterViewController *headerPosterVC;
@property (nonatomic, strong) TTVVideoDetailRelatedVideoViewController *relatedVideoVC;
@property (nonatomic, strong) TTVCommentViewController *commentVC;
@property (nonatomic, strong) TTVVideoDetailToolBarViewController *toolbarVC;
@property (nonatomic, strong) TTVVideoDetailCommodityViewController *commodityVC;
//弹出的评论页详情页
@property (nonatomic, strong, nullable) TTVideoDetailFloatCommentViewController *floatCommentVC;
@property (nonatomic, strong) TTVVideoDetailMovieBanner                  *movieBanner;
@property (nonatomic, strong, nullable) TTVReplyViewController *replyVC;
@property (nonatomic, strong) TTVVideoDetailNatantTagsView *tagsView;

@property (nonatomic, strong) TTVContainerScrollView                  *wrapperScroller;//用给iPad下分屏的相关视频滑动
@property (nonatomic, strong) SSThemedView                        *distinctLine;
@property (nonatomic, assign) NSInteger relatedVideoIndexWhenNotDistinct;
@property (nonatomic, assign) BOOL registeredKVO;
@property (nonatomic, assign) BOOL reloadVideoInfoFinished;

@property (nonatomic, strong) TTVVideoDetailContainerScrollView *ttvContainerScrollView;

@property (nonatomic, assign) TTVVideoDetailViewFromType             fromType;
@property (nonatomic, strong) TTVVideoDetailStayPageTracker        *tracker;
@property (nonatomic, strong) TTVWhiteBoard *whiteboard;

@property (nonatomic, assign) BOOL hasFetchedComments; //是否已经取到了评论数据

@property (nonatomic, strong) id<TTVCommentModelProtocol, TTCommentDetailModelProtocol> commentModelForFloatComment;
@property (nonatomic, strong) NSIndexPath *commentIndexPathToReload;
@property (nonatomic, strong) TTCommentDataManager *commentDetailService;
@property (nonatomic, assign) BOOL isGettingMomentDetail;

@property (nonatomic, assign) BOOL didDisAppear;

//详情页监控
@property (nonatomic, assign) NSTimeInterval startTimestamp;
@property (nonatomic, assign) BOOL startImpression;

@property (nonatomic, strong) TTVideoInfomationService *videoInfoService;

//pgcVC &infoVC
@property (nonatomic, strong) TTVVideoDetailNatantInfoViewController *InfoVC;
@property (nonatomic, strong) TTVVideoDetailNatantPGCViewController  *topPGCVC;
@property (nonatomic, strong) TTVVideoDetailAlbumView                *albumView;

@property (nonatomic ,strong) TTCommentWriteView *replyWriteView;

/**
 *  UGC滚到评论区, 从TTDetailModel中迁移过来的
 */
@property (nonatomic, assign) BOOL beginShowCommentUGC;
/**
 *  UGC拉出评论框, 同上
 */
@property (nonatomic, assign) BOOL beginWriteCommentUGC;

@property (nonatomic, assign) BOOL beginShowComment;
@property (nonatomic, weak) TTVFeedListViewController *feedListViewController;

@property (nonatomic, strong) NSArray *subviewsBeforeLoadInfo;

@property (nonatomic, strong)TTVShareDetailTracker *detailShareTracker;
@property (nonatomic, strong) NSArray<RACDisposable *> *cardViewObserveDisposableArray;

@property (nonatomic, strong) TTVDetailFollowRecommendViewController *followRecommendVC;

@end

@implementation TTVVideoDetailViewController

- (void)dealloc
{
    _ttvContainerScrollView.delegate = nil;
    if (self.startImpression) {
        [self.commentVC.commentTableView tt_endImpression];
    }
    if (_linkView) {
        [self videoLinkViewWillDisappear];
    }
    [TTVVideoAlbumHolder dispose];
    BOOL videoContinuePlayWhenFromDetail  = [[[TTSettingsManager sharedManager] settingForKey:@"tt_feed_continue_play_from_detail_enable" defaultValue:@NO freeze:NO] boolValue];
    if (videoContinuePlayWhenFromDetail && self.feedListViewController != nil) {
        [self.feedListViewController attachVideoIfNeededForCellWithUniqueID:[NSString stringWithFormat:@"%lld", self.videoInfo.uniqueID] playingVideo:[self.headerPosterVC movieView]];
    } else {
        if ([self shouldPauseMovieWhenVCDidDisappearInternal__]) {
            UIStatusBarStyle originalStatusBarStyle = self.originalStatusBarStyle;
            BOOL originalStatusBarHidden = self.originalStatusBarHidden;
            [self.headerPosterVC _invalideMovieViewWithFinishedBlock:^{
                if (![TTDeviceHelper isIPhoneXDevice]) {
                    [[UIApplication sharedApplication] setStatusBarHidden:originalStatusBarHidden];
                }
                [[UIApplication sharedApplication] setStatusBarStyle:originalStatusBarStyle animated:NO];
            }];
        }
    }
        
    [self removeObserver];
    [self ttv_detailBackTrack];
    ttv_removeChildViewController(_headerPosterVC);
    ttv_removeChildViewController(_relatedVideoVC);
    ttv_removeChildViewController(_commentVC);
    ttv_removeChildViewController(_toolbarVC);
    ttv_removeChildViewController(_InfoVC);
    ttv_removeChildViewController(_topPGCVC);
    ttv_removeChildViewController(_commodityVC);
    ttv_removeChildViewController(_followRecommendVC);
}

- (instancetype)initWithDetailViewModel:(TTDetailModel *)model
{
    self = [super init];
    if (self) {
        self.ttv_statusBarHidden = ![TTDeviceHelper isIPhoneXDevice];
        self.detailStateStore = [[TTVDetailStateStore alloc] init];
        self.detailModel = model;
        [self configDetailStateStore];
        NSDictionary *params = model.baseCondition;
        self.originalGroupID = params[@"group_id"];
        self.ruleID = params[@"rid"];
        self.beginShowCommentUGC = [params tt_boolValueForKey:@"showCommentUGC"];
        self.beginWriteCommentUGC = [params tt_boolValueForKey:@"writeCommentUGC"];
        self.beginShowComment = [params tt_boolValueForKey:@"showcomment"];

        self.detailStateStore.state.rawAdData = [params tt_dictionaryValueForKey:@"raw_ad_data"];
        self.feedListViewController = [params valueForKey:@"video_feedListViewController"];

        self.detailStateStore.state.videoProgress = [params tt_floatValueForKey:@"video_progress"];
//        if ([model.protocoledArticle rawAdData] && !self.detailStateStore.state.rawAdData) {
//            self.detailStateStore.state.rawAdData = [model.protocoledArticle rawAdData];
//        }

        @weakify(self);
        self.detailModel.detailManagerCustomBlock = ^ExploreDetailManager * _Nonnull(BOOL * _Nonnull shouldRetrun) {
            @strongify(self);
            if (![self.detailModel.article isKindOfClass:[Article class]]) {
                *shouldRetrun = YES;
            }
            return nil;
        };
        self.ttHideNavigationBar = YES;
        [self _confirmFromType];
        [self _initTracker];
        _videoInfoService = [[TTVideoInfomationService alloc] init];
        
        _headerPosterVC = [[TTVVideoDetailHeaderPosterViewController alloc] init];
        //先给videoinfo赋值，不然后后面的播放器打点没有信息。。。
        _headerPosterVC.videoInfo = model.article;
        _headerPosterVC.detailModel = model;
        _headerPosterVC.detailStateStore = self.detailStateStore;
        _headerPosterVC.fromType = self.fromType;
        [self addChildViewController:_headerPosterVC];
        _relatedVideoVC = [[TTVVideoDetailRelatedVideoViewController alloc] init];
        _relatedVideoVC.detailStateStore = self.detailStateStore;
        [self addChildViewController:_relatedVideoVC];
        _commentVC = [[TTVCommentViewController alloc] initWithDataSource:self delegate:self];
        _commentVC.enableImpressionRecording = YES;
        _commentVC.hasSelfShown = YES;
        _commentVC.detailStateStore = self.detailStateStore;
        [self addChildViewController:_commentVC];
        _toolbarVC = [[TTVVideoDetailToolBarViewController alloc] init];
        _toolbarVC.detailModel = model;
        _toolbarVC.detailStateStore = self.detailStateStore;
        _toolbarVC.detailStateStore = self.detailStateStore;
        _toolbarVC.diggActionFired = ^(BOOL digg) {
            @strongify(self);
            if (digg) {
                [self.InfoVC.infoView.viewModel digAction];
            }else{
                [self.InfoVC.infoView.viewModel cancelDiggAction];
            }
            [self.InfoVC.infoView updateActionButtons];
        };
        _toolbarVC.buryActionFired = ^(BOOL bury) {
            @strongify(self);
            if (bury) {
                [self.InfoVC.infoView.viewModel buryAction];
            }else{
                [self.InfoVC.infoView.viewModel cancelBurryAction];
            }
            [self.InfoVC.infoView updateActionButtons];
        };
        _toolbarVC.commodityActionFired = ^{
            @strongify(self);
            [self.playControl addCommodity];
        };
        _toolbarVC.WriteButtonActionFired = ^BOOL{
            @strongify(self);
            if (self.commentVC.defaultReplyCommentModel && [self.commentVC respondsToSelector:@selector(defaultReplyCommentModel)] ) {
                
                [self commentViewController:self.commentVC shouldPresentCommentDetailViewControllerWithCommentModel:[self.commentVC defaultReplyCommentModel].commentModel indexPath:[NSIndexPath indexPathForRow:0 inSection:0] showKeyBoard:NO];
                
                if ([self.commentVC respondsToSelector:@selector(clearDefalutReplyCommentModel)]) {
                    [self.commentVC clearDefalutReplyCommentModel];
                }
                self.toolbarVC.writeButtonPlayHoldText = @"写评论";
                return YES;
            }
            return NO;
        };
        [self addChildViewController:_toolbarVC];
        _headerPosterVC.toolbarActionDelegate = _toolbarVC;
        _headerPosterVC.homeActionDelegate = self;
        _headerPosterVC.doubleTap666Delegate = self;
        _toolbarVC.homeActionDelegate = self;
        _relatedVideoVC.homeActionDelegate = self;
        self.toolbarActionDelegate = _toolbarVC;
        
        _whiteboard = [[TTVWhiteBoard alloc] init];
        _headerPosterVC.whiteboard = self.whiteboard;
        _toolbarVC.whiteboard = self.whiteboard;
        self.detailStateStore.state.whiteBoard = _whiteboard;
        
        _startTimestamp = [[NSDate date] timeIntervalSince1970];
        self.relatedVideoIndexWhenNotDistinct = NSNotFound;
    }
    return self;
}

- (void)setDetailStateStore:(TTVDetailStateStore *)detailStateStore
{
    if (detailStateStore != _detailStateStore) {
        [self.KVOController unobserve:self.detailStateStore.state];
        [_detailStateStore unregisterForActionClass:[TTVDetailStateAction class] observer:self];
        _detailStateStore = detailStateStore;
        [_detailStateStore registerForActionClass:[TTVDetailStateAction class] observer:self];
        [self ttv_kvo];
    }
}

- (void)ttv_kvo
{
    
}

- (void)actionChangeCallbackWithAction:(TTVDetailStateAction *)action state:(TTVDetailStateModel *)state
{
    
}

- (void)configDetailStateStore
{
    [self.detailStateStore.state setDetailModel:self.detailModel];
    self.detailStateStore.state.entity.categoryId = self.detailModel.categoryID;
    self.detailStateStore.state.entity.clickLabel = self.detailModel.clickLabel;
    if (self.detailModel.logPb) {
        self.detailStateStore.state.logPb = self.detailModel.logPb;
    }else{
        self.detailStateStore.state.logPb = self.detailModel.gdExtJsonDict[@"log_pb"];
    }
    self.detailStateStore.state.enterFrom = [self enterFromString];
    self.detailStateStore.state.categoryName = [self categoryName];
    self.detailStateStore.state.authorId = [self.detailModel.article.userInfo ttgc_contentID];
    self.detailStateStore.state.rawAdData = self.detailModel.orderedData.raw_ad_data;
}

- (void)setVideoInfo:(id<TTVArticleProtocol>)videoInfo
{
    if (videoInfo != _videoInfo) {
        _videoInfo = videoInfo;
        self.detailModel.videoInfo = videoInfo;
        _headerPosterVC.videoInfo = videoInfo;
        _toolbarVC.videoInfo = videoInfo;
    }
}

- (void)afterReloadVideoInfo
{
    self.reloadVideoInfoFinished = YES;
    _headerPosterVC.reloadVideoInfoFinished = YES;
    _toolbarVC.reloadVideoInfoFinished = YES;
}

- (void)setReplyVC:(TTVReplyViewController *)replyVC {
    
    _replyVC = replyVC;
    [self.whiteboard setValue:replyVC forKey:@"replyVC"];
}

- (void)setTopPGCVC:(TTVVideoDetailNatantPGCViewController *)topPGCVC
{
    _topPGCVC = topPGCVC;
    [self.whiteboard setValue:topPGCVC forKey:@"topPGCView"];
}

- (void)setFollowRecommendVC:(TTVDetailFollowRecommendViewController *)followRecommendVC
{
    _followRecommendVC = followRecommendVC;
    [self.whiteboard setValue:followRecommendVC forKey:@"followRecommendVC"];
}

- (UIView *)movieContainerView
{
    if (self.headerPosterVC.isViewLoaded) {
        return self.headerPosterVC.view;
    } else {
        return nil;
    }
}

#pragma mark - TTVWhiteBoard methods

- (TTVideoDetailHeaderPosterView *)movieShotView
{
    id value = [self.whiteboard valueForKey:@"movieShotView"];
    if ([value isKindOfClass:[TTVideoDetailHeaderPosterView class]]) {
        return (TTVideoDetailHeaderPosterView *)value;
    } else {
        return nil;
    }
}

- (UIView * _Nullable)movieView
{
    return self.headerPosterVC.playControl.movieView;
}

- (void)_confirmFromType
{
    if (self.detailModel.relateReadFromGID) {
        self.fromType = TTVVideoDetailViewFromTypeRelated;
    } else {
        self.fromType = TTVVideoDetailViewFromTypeCategory;
    }
}

- (void)setFromType:(TTVVideoDetailViewFromType)fromType
{
    if (_fromType != fromType) {
        _fromType = fromType;
        self.detailStateStore.state.fromType = fromType;
        self.detailStateStore.state.enterFrom = [self enterFromString];
        self.detailStateStore.state.categoryName = [self categoryName];
    }
}

- (NSString *)enterFromString{
    NSString * enterFrom = self.detailModel.clickLabel;
    if (self.detailModel.fromSource == NewsGoDetailFromSourceCategory | self.detailModel.fromSource == NewsGoDetailFromSourceVideoFloat) {
        enterFrom = @"click_category";
    } else if (self.detailModel.fromSource == NewsGoDetailFromSourceHeadline) {
        enterFrom = @"click_headline";
    }else if (self.detailModel.fromSource == NewsGoDetailFromSourceFavorite) {
        enterFrom = @"click_favorite";
    } else if(self.detailModel.fromSource == NewsGoDetailFromSourceClickTodayExtenstion) {
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

    // 这段代码是因为埋点文档不清楚加的，注释掉，不删除了
//    if ([categoryName isEqualToString:@"f_shipin"]) {
//        categoryName = @"video";
//    }
    return categoryName;
}

- (NSDictionary *)logPb
{
    if (self.detailModel.logPb) {
        return self.detailModel.logPb;
    }else{
        return self.detailModel.gdExtJsonDict[@"log_pb"];
    }
}



- (void)_initTracker
{
    id<TTVArticleProtocol> article = self.detailModel.protocoledArticle;
    
    self.tracker = [[TTVVideoDetailStayPageTracker alloc] initWithArticle:article];
    self.tracker.detailStateStore = self.detailStateStore;
    self.tracker.detailModel = self.detailModel;
    self.tracker.enterFrom = [self enterFromString];
    self.tracker.categoryName = [self categoryName];
    //orderedData 传过去为了 logextra
    self.tracker.articleExtraInfo = self.detailModel.articleExtraInfo;
}

- (void)didMoveToParentViewController:(UIViewController *)parent
{
    [super didMoveToParentViewController:parent];
    if (parent) {
        parent.ttDragToRoot = self.detailModel.ttDragToRoot;
    }
}

#pragma mark UIViewControllerErrorHandler
- (BOOL)tt_hasValidateData
{
    return NO;
}

#pragma mark - UIViewController LifeCycle

- (void)viewDidLoad {
    [super viewDidLoad];
    if (self.detailModel.originalStatusBarHiddenNumber == nil) {
        self.originalStatusBarHidden = [UIApplication sharedApplication].isStatusBarHidden;
    } else {
        self.originalStatusBarHidden = [self.detailModel.originalStatusBarHiddenNumber boolValue];
    }
    if (self.detailModel.originalStatusBarStyleNumber == nil) {
        self.originalStatusBarStyle = [UIApplication sharedApplication].statusBarStyle;
    } else {
        self.originalStatusBarStyle = (UIStatusBarStyle)[self.detailModel.originalStatusBarStyleNumber integerValue];
    }
    
    if ([TTDeviceHelper isIPhoneXDevice]) {
        self.ttStatusBarStyle = UIStatusBarStyleLightContent;
    }
    
    self.videoInfo = self.detailModel.article;
    
    [self buildPlaceholdView];
    [self restoreAlbumViewIfNeed];
    [self.whiteboard setValue:self.tracker forKey:@"tracker"];
    [self.whiteboard setValue:self.commentVC forKey:@"commentVC"];
    [self.whiteboard setValue:self.topView forKey:@"topView"];
    [self.whiteboard setValue:@(self.beginShowComment) forKey:@"beginShowComment"];
    
    //    [self startLoadArticleInfo];
    [self loadVideoInfo];
    
    if ([self _needAddAlbumView]) {
        [[TTVVideoAlbumHolder holder].albumView removeFromSuperview];
        [self.view addSubview:[TTVVideoAlbumHolder holder].albumView];
        [TTVVideoAlbumHolder holder].albumView.frame = CGRectMake(0, self.headerPosterVC.interactModel.minMovieH, self.view.width, self.view.height-self.headerPosterVC.interactModel.minMovieH);
    }
    
    CLS_LOG(@"TTVideoDetailViewController viewDidLoad with groupID %@",[self.detailModel uniqueID]);
    [self.detailStateStore sendAction:TTVDetailEventTypeViewDidLoad payload:nil];
    [AKAwardCoinVideoMonitorManager shareInstance].videoDetailModel = self.detailModel;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (![TTDeviceHelper isIPhoneXDevice]) {
        [[UIApplication sharedApplication] setStatusBarHidden:YES];
    }
    [[UIApplication sharedApplication] setStatusBarStyle:self.ttStatusBarStyle == UIStatusBarStyleDefault ? [[TTThemeManager sharedInstance_tt] statusBarStyle] : self.ttStatusBarStyle];
    [self extendLinkViewControllerWillAppear];
    
    [self.detailStateStore sendAction:TTVDetailEventTypeViewWillAppear payload:nil];
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
    [self.detailStateStore sendAction:TTVDetailEventTypeViewDidAppear payload:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.navigationControllerBeforeBeingPoped = self.navigationController;
    if (![TTDeviceHelper isIPhoneXDevice]) {
        [[UIApplication sharedApplication] setStatusBarHidden:self.originalStatusBarHidden];
    }
    //先显示时间
    [self.detailStateStore sendAction:TTVDetailEventTypeCommentDetailViewWillDisappear payload:_replyVC.commentModel];
    
    self.detailStateStore.state.isBackAction = ![self.navigationController.viewControllers containsObject:self.parentViewController] || [self.navigationController.viewControllers containsObject:self];
    [self.detailStateStore sendAction:TTVDetailEventTypeViewWillDisappear payload:nil];
}

- (BOOL)shouldContinuePlayVideoWhenback
{
    return (self.detailStateStore.state.isBackAction && [self isFromVideoFloat]);
}

- (BOOL)isFromVideoFloat
{
    return self.detailModel.fromSource == NewsGoDetailFromSourceVideoFloat || self.detailModel.fromSource == NewsGoDetailFromSourceVideoFloatRelated;
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    _didDisAppear = YES;
    [self.detailStateStore sendAction:TTVDetailEventTypeViewDidDisappear payload:nil];
    
}

- (BOOL)prefersStatusBarHidden {
    return self.ttv_statusBarHidden;
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    if (!_didDisAppear && [self.headerPosterVC.playControl shouldLayoutSubviews]) {
        [self layoutViews];
    }
    [self.detailStateStore sendAction:TTVDetailEventTypeViewWillLayoutSubviews payload:nil];
}

- (TTVVideoDetailMovieBanner *)movieBanner
{
    if (!_movieBanner) {
        _movieBanner = [[TTVVideoDetailMovieBanner alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 0)];
        _movieBanner.delegate = self;
        [self.whiteboard setValue:self.movieBanner forKey:@"movieBanner"];
        _movieBanner.hidden = YES;
        self.playControl.movieBanner = _movieBanner;
    }
    return _movieBanner;
}

-(TTVVideoDetailAlbumView *)albumView;
{
    if (!_albumView) {
        _albumView = [[TTVVideoDetailAlbumView alloc] init];
        _albumView.width = self.view.width;
        _albumView.height = self.view.height - self.headerPosterVC.view.bottom;
        _albumView.bottom = self.view.height;
    }
    return _albumView;
}


- (TTVContainerScrollView *)wrapperScroller
{
    if (!_wrapperScroller) {
        _wrapperScroller = [[TTVContainerScrollView alloc] init];
        
        UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 20)];
        [_wrapperScroller.contentView addSubview:paddingView];
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

- (ExploreVideoTopView *)topView
{
    if (!_topView) {
        CGFloat topMargin = [TTDeviceHelper isIPhoneXDevice] ? 44 : 0;
        _topView = [[ExploreVideoTopView alloc] initWithFrame:CGRectMake(0, topMargin, [[UIScreen mainScreen] bounds].size.width, kTopViewHeight)];
        [_topView.backButton addTarget:self action:@selector(_topViewBackButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    }
    return _topView;
}

- (void)themeChanged:(NSNotification *)notification
{
    self.view.backgroundColor = [UIColor tt_themedColorForKey:kColorBackground4];
}

- (void)playMovieIfNeeded
{
    [self.headerPosterVC playMovieIfNeeded];
}

- (void)pauseMovieIfNeeded
{
    [self.headerPosterVC pauseMovieIfNeeded];
}

- (void)_install
{
    [self buildView];
    
    [self layoutViews];
    
    [self themeChanged:nil];
}

- (void)buildPlaceholdView
{
    CGFloat topMargin = [TTDeviceHelper isIPhoneXDevice] ? 44 : 0;
    {
        UIView *view = _headerPosterVC.view;
        view.frame = CGRectMake(0, topMargin, self.view.width, 0);
        view.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [self.view addSubview:view];
        [_headerPosterVC didMoveToParentViewController:self];
    }
    CGFloat wrapperScrollviewWidth = 0;
    if ([TTDeviceHelper isPadDevice] && [ExploreVideoDetailHelper currentVideoDetailRelatedStyle] == VideoDetailRelatedStyleDistinct) {
        wrapperScrollviewWidth = [TTUIResponderHelper windowSize].width - [self widthForContentView];
    }
    [self setTtContentInset:UIEdgeInsetsMake([self.headerPosterVC frameForMovieView].size.height + topMargin, 0, 0, wrapperScrollviewWidth)];
    [self tt_startUpdate];
    
    [self.view addSubview:self.topView];
    
    self.statusBarBackgrView = [[SSThemedView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, self.ttv_statusBarHidden ? 0 : self.view.tt_safeAreaInsets.top)];
    self.statusBarBackgrView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:self.statusBarBackgrView];
}

- (void)viewSafeAreaInsetsDidChange {
    [super viewSafeAreaInsetsDidChange];

    self.statusBarBackgrView.height = (self.ttv_statusBarHidden && ![TTDeviceHelper isIPhoneXDevice]) ? 0 : self.view.tt_safeAreaInsets.top;
}

- (void)restoreAlbumViewIfNeed
{
    if ([TTVVideoAlbumHolder holder].albumView) {
        self.albumView = [TTVVideoAlbumHolder holder].albumView;
    }
}


- (void)buildView
{
    _ttvContainerScrollView = [[TTVVideoDetailContainerScrollView alloc] initWithFrame:self.view.bounds];
    _ttvContainerScrollView.width = [self containerWidth];
    _ttvContainerScrollView.showsVerticalScrollIndicator = ![TTDeviceHelper isPadDevice];
    _ttvContainerScrollView.delegate = self;
    _ttvContainerScrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:_ttvContainerScrollView];
    _headerPosterVC.ttvContainerScrollView = _ttvContainerScrollView;
    _commentVC.ttvContainerScrollView = _ttvContainerScrollView;
    _toolbarVC.ttvContainerScrollView = _ttvContainerScrollView;
    
    {
        UIView *view = _toolbarVC.view;
        // add by zjing safeArea
        CGFloat safeAreaBottom = 0;
        if ([TTDeviceHelper isIPhoneXDevice]) {
            safeAreaBottom = 34;
        }
        view.frame = CGRectMake(0, 0, self.view.width, ExploreDetailGetToolbarHeight() + safeAreaBottom);
        view.bottom = self.view.height;
        view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
        [self.view addSubview:view];
        [_toolbarVC didMoveToParentViewController:self];
    }
}

- (void)layoutViews
{
    [self.headerPosterVC layoutMovieShotView];
    [self layoutTopPGCView];
    [self layoutFollowRecommendView];
    [self layoutComment];
    self.toolbarVC.view.bottom = self.view.height;
    [self layoutRelatedVideoViewOnLandscapePadIfNeeded];
    if (self.followRecommendVC.recommendView.isSpread) {
        self.followRecommendVC.view.height = self.view.height - self.topPGCVC.view.bottom;
    }
    
    _albumView.width = self.view.width;
    _albumView.height = self.view.height - self.headerPosterVC.view.bottom;
    _albumView.bottom = self.view.height;
    
}

- (void)layoutTopPGCView {
    if (self.detailStateStore.state.hasCommodity) {
        CGFloat offsetY = MIN(self.ttvContainerScrollView.contentOffset.y, self.commodityVC.view.height - self.topPGCVC.view.height);
        self.ttvContainerScrollView.bounces = NO;
        self.topPGCVC.view.top = self.headerPosterVC.view.bottom + self.commodityVC.view.height -self.topPGCVC.view.height - offsetY;
        self.topPGCVC.view.width = self.headerPosterVC.view.width;
    }else{
        self.ttvContainerScrollView.bounces = YES;
        self.topPGCVC.view.top = self.headerPosterVC.view.bottom;
        self.topPGCVC.view.width = self.headerPosterVC.view.width;
    }
    [self layoutFollowRecommendView];
}

- (void)layoutFollowRecommendView{
    self.followRecommendVC.view.top = self.topPGCVC.view.bottom;
    self.followRecommendVC.view.width = self.topPGCVC.view.width;
}

- (void)layoutRelatedVideoViewOnLandscapePadIfNeeded
{
    if (![TTDeviceHelper isPadDevice]) {
        return;
    }
    if (!self.reloadVideoInfoFinished) {
        return;
    }
    if (!self.relatedVideoVC.isViewLoaded) {
        return;
    }
    
    self.wrapperScroller.hidden = [ExploreVideoDetailHelper currentVideoDetailRelatedStyleForMaxWidth:[self maxWidth]] == VideoDetailRelatedStyleNatant;
    self.distinctLine.hidden = self.wrapperScroller.hidden;
    
    if ([ExploreVideoDetailHelper currentVideoDetailRelatedStyleForMaxWidth:[self maxWidth]] == VideoDetailRelatedStyleDistinct) {
        if (self.relatedVideoVC.view.superview != self.wrapperScroller.contentView) {
            CGSize windowSize = self.view.bounds.size;
            self.wrapperScroller.left = [self widthForContentView];
            self.wrapperScroller.width = windowSize.width - self.wrapperScroller.left;
            self.wrapperScroller.height = windowSize.height - ExploreDetailGetToolbarHeight();
            self.distinctLine.right = self.movieContainerView.right;
            self.distinctLine.height = self.wrapperScroller.height;
            
            [self.relatedVideoVC.view removeFromSuperview];
            self.relatedVideoVC.view.frame = self.wrapperScroller.bounds;
            [self.relatedVideoVC.tableView reloadData];
            
            [self.wrapperScroller.contentView  addSubview:self.relatedVideoVC.view];
            [self.view addSubview:self.wrapperScroller];
            [self.view addSubview:self.distinctLine];
        }
    } else {
        if (self.relatedVideoVC.view.superview != self.ttvContainerScrollView.contentView) {
            self.relatedVideoVC.view.width = self.ttvContainerScrollView.width;
            [self.relatedVideoVC.view removeFromSuperview];
            [self.relatedVideoVC.tableView reloadData];
            if (self.relatedVideoIndexWhenNotDistinct != NSNotFound) {
                [self.ttvContainerScrollView.contentView insertSubview:self.relatedVideoVC.view atIndex:self.relatedVideoIndexWhenNotDistinct];
            } else {
                // in case
                [self.ttvContainerScrollView.contentView insertSubview:self.relatedVideoVC.view atIndex:2];
            }
        }
    }
    if ([self _needAddAlbumView]) {
        [self.view bringSubviewToFront:[TTVVideoAlbumHolder holder].albumView];
    }
}

- (void)layoutComment
{
    CGFloat topMargin = [TTDeviceHelper isIPhoneXDevice] ? 44 : 0;
    CGSize windowSize = self.view.bounds.size;
    windowSize = CGSizeMake(windowSize.width, windowSize.height - topMargin - [TTUIResponderHelper mainWindow].tt_safeAreaInsets.bottom);
    CGFloat commentViewHeight = windowSize.height - self.headerPosterVC.interactModel.minMovieH - ExploreDetailGetToolbarHeight();
    CGRect commentViewRect;
    if ([ExploreVideoDetailHelper currentVideoDetailRelatedStyleForMaxWidth:[self maxWidth]] == VideoDetailRelatedStyleNatant) {
        CGFloat commentWidth = [self widthForContentView] + ([TTDeviceHelper isPadDevice] ? kVideoDetailItemCommonEdgeMargin * 2 : 0);
        commentViewRect = CGRectMake((windowSize.width - commentWidth)/2, self.movieContainerView.bottom, commentWidth, commentViewHeight);
    }
    else {
        CGFloat leftMargin = 0;
        if ([TTDeviceHelper isPadDevice]) {
            leftMargin = 75 - kVideoDetailItemCommonEdgeMargin;
            if ([TTDeviceHelper isIpadProDevice]) {
                leftMargin = 100 - kVideoDetailItemCommonEdgeMargin;
            }
        }
        commentViewRect = CGRectMake(leftMargin, self.movieContainerView.bottom, [self widthForContentView] - leftMargin * 2, commentViewHeight);
    }
    
    if (!self.detailStateStore.state.hasCommodity) {
        if (self.topPGCVC)
        {
            commentViewRect.origin.y = self.topPGCVC.view.top + self.topPGCVC.view.height;
            commentViewRect.size.height = commentViewHeight - self.topPGCVC.view.height;
        }
    }
    _ttvContainerScrollView.frame = commentViewRect;
    _ttvContainerScrollView.ttv_hitTestEdgeInsets = UIEdgeInsetsMake(0, -_ttvContainerScrollView.left, 0, _ttvContainerScrollView.width + _ttvContainerScrollView.left - self.view.width);
    [self.commentVC videoUpdateCommentWidth:_ttvContainerScrollView.width];
    //评论详情页
    CGSize movieSize = self.headerPosterVC.view.size;
    _replyVC.viewFrame = CGRectMake(0, movieSize.height, movieSize.width, self.view.height - movieSize.height);
}

- (void)p_setupViewAfterLoadData {
    if ([self.detailModel.protocoledArticle.articleDeleted boolValue]) {
        [ExploreMovieView removeAllExploreMovieView];
        [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:NSLocalizedString(@"该内容已删除", nil) indicatorImage:[UIImage themedImageNamed:@"close_popup_textpage"] autoDismiss:YES dismissHandler:^(BOOL isUserDismiss) {
            [self p_deleteLocalVideo];
        }];
    } else {
        [self tt_endUpdataData];
        [self _install];
        [self afterReloadVideoInfo];
        [self _buildNatantSubviews];
        [self layoutRelatedVideoViewOnLandscapePadIfNeeded];
        
        [self addObserver];
        if ([[self.detailModel.videoInfo.videoExtendLink valueForKey:@"open_direct"] boolValue])
        {
            [self showExtendLinkViewWithArticle:self.detailModel.videoInfo];
        }
        if (_hasFetchedComments) {
            //comment接口比info接口先返回
            [self.commentVC.commentTableView reloadData];
            [self _scrollToCommentsIfNeeded];
        }
        [self addDetailShareTracker];
    }
    if (_startTimestamp) {
        NSTimeInterval interval = [[NSDate date] timeIntervalSince1970] - _startTimestamp;
        _startTimestamp = 0;
        [[TTMonitor shareManager] trackService:@"video_detail_load_interval" value:@(interval) extra:nil];
    }
    
}

- (void)loadVideoInfo
{
    //网络出错的时候可能会重新调用loadVideoInfo
    NSArray *subviews = [self.view subviews];
    if (self.subviewsBeforeLoadInfo.count > 0) {
        for (UIView *subview in subviews) {
            if (![self.subviewsBeforeLoadInfo containsObject:subview]) {
                [subview removeFromSuperview];
            }
        }
    }
    self.subviewsBeforeLoadInfo = subviews;
    self.InfoVC = nil;
    self.topPGCVC = nil;
    self.commodityVC = nil;
    
    NSMutableDictionary *parameter = [[NSMutableDictionary alloc] initWithCapacity:8];
    parameter[kAggrTypeForVideoInfo] = self.detailModel.protocoledArticle.aggrType ?: @1;
    parameter[kGroupIDForVideoInfo] = [NSString stringWithFormat:@"%lld", self.detailModel.protocoledArticle.uniqueID];
    parameter[kItemIDForVideoInfo] = self.detailModel.protocoledArticle.itemID;
    parameter[kFromForVideoInfo] = self.detailModel.clickLabel;
    parameter[kFromCateGoryForVideoInfo] = self.detailModel.articleExtraInfo.categoryID;
    parameter[kFlagsForVideoInfo] = @64;
    parameter[kArticlePageadIDForVideoInfo] = @1;
    
    //TODOPY: 加其他的参数
    NSNumber *adID = [self.detailStateStore.state ttv_adid];
    
    if ([adID longLongValue] > 0) {
        NSString *adIDString = [adID stringValue];
        parameter[kAdIDForVideoInfo] = adIDString;
    }
    @weakify(self);
    [self.videoInfoService getDetailWithParameters:parameter completion:^(TTVideoDetailResponse *response, NSError *error) {
        @strongify(self);
        if (error) {
            [[TTMonitor shareManager] trackService:video_play_detail_info_status status:1 extra:nil];
            [self p_setupViewAfterLoadData];
            return;
        }
        [[TTMonitor shareManager] trackService:video_play_detail_info_status status:0 extra:nil];
        if (![response isKindOfClass:[TTVideoDetailResponse class]]) {
            return;
        }
        TTVVideoInformationResponse *videoInfo = response.originData;
        videoInfo.ttv_requestTime = [[NSDate date] timeIntervalSince1970];
        if (self.detailModel.videoArticle) {
            if (videoInfo.article != self.detailModel.videoArticle) {
                [self.detailModel.videoArticle mergeFrom:videoInfo.article];
                [videoInfo.article mergeFrom:self.detailModel.videoArticle];
            }
        } else if ([self.detailModel.article conformsToProtocol:@protocol(TTVArticleProtocol)]) {
            videoInfo.articleMiddleman = self.detailModel.article;
        }
        self.detailModel.videoInfo = videoInfo;
        //详情页的logPb不需要,需要使用feed里面传过来的.
        [TTVArticleConvertor updateArticle:self.detailModel.article withNewArticle:videoInfo];
        self.videoInfo = videoInfo;
        [self p_setupViewAfterLoadData];
    }];
}

- (void)_buildNatantSubviews
{
    CGFloat containerWidth = [self containerWidth];
    TTVVideoInformationResponse *videoInfoResponse = nil;
    if ([self.videoInfo isKindOfClass:[TTVVideoInformationResponse class]]) {
        videoInfoResponse = (TTVVideoInformationResponse *)self.videoInfo;
    }
    
    NSMutableArray *natantViewArray = [[NSMutableArray alloc] init];
    
    /*
     commodity
     */
    {
        NSDictionary *dic = [[TTSettingsManager sharedManager] settingForKey:@"tt_video_commodity" defaultValue:@{} freeze:NO];
        BOOL show = [[dic valueForKey:@"detail_show_commodity_list"] boolValue];
        self.detailStateStore.state.hasCommodity = NO;
        if (self.videoInfo.commoditys.count > 0 && show) {
            self.commodityVC = [[TTVVideoDetailCommodityViewController alloc] init];
            self.detailStateStore.state.hasCommodity = YES;
            [self addChildViewController:self.commodityVC];
            [self.commodityVC willMoveToParentViewController:self];
            [self.ttvContainerScrollView.contentView addSubview:self.commodityVC.view];
            [self.commodityVC didMoveToParentViewController:self];
            [natantViewArray addObject:self.commodityVC.view];
            self.commodityVC.view.autoresizingMask = UIViewAutoresizingFlexibleWidth;
            @weakify(self);
            [self.KVOController observe:self.ttvContainerScrollView keyPath:@keypath(self.ttvContainerScrollView,contentOffset) options:NSKeyValueObservingOptionNew block:^(id  _Nullable observer, id  _Nonnull object, NSDictionary<NSString *,id> * _Nonnull change) {
                @strongify(self);
                [self layoutTopPGCView];
            }];
            self.commodityVC.whiteboard = self.whiteboard;
        }
    }
    
    id<TTAdFeedModel> adModel = self.detailModel.protocoledArticle.adModel;
    if ([adModel isCreativeAd] && ![adModel.type isEqualToString:@"web"]) {
        TTVVideoDetailNatantADView *embededAD = [[TTVVideoDetailNatantADView alloc] initWithFrame:CGRectMake(0, 0, containerWidth, 0)];
        embededAD.detailStateStore = self.detailStateStore;
        if ([self.videoInfo conformsToProtocol:@protocol(TTVVideoDetailNatantADViewDataProtocol)]) {
            embededAD.article = (id<TTVVideoDetailNatantADViewDataProtocol> )self.videoInfo;
        }
        embededAD.getADEventTrackerEntity = ^TTADEventTrackerEntity *{
            TTADEventTrackerEntity *entity = [[TTADEventTrackerEntity alloc] init];
            entity.ad_id = videoInfoResponse.adIDStr;
            entity.itemID = videoInfoResponse.itemID;
            entity.uniqueid = [NSString stringWithFormat:@"%lld", videoInfoResponse.uniqueID];
            entity.aggrType = videoInfoResponse.aggrType;
            entity.log_extra = videoInfoResponse.logExtra;
            return entity;
        };
        self.embededAD = embededAD;
        if (self.startImpression) {
            [self.commentVC.commentTableView tt_endImpression];
        }
        [self.commentVC.commentTableView tt_addImpressionView:embededAD];
        [self.commentVC.commentTableView tt_startImpression];
        self.startImpression = YES;
        [self.ttvContainerScrollView.contentView addSubview:embededAD];
        [natantViewArray addObject:embededAD];
    }
    
    NSString *videoAbstract = videoInfoResponse.videoLabelHtml;
    //兼容刚刚发布视频时服务器端没有返回titleRichSpan的情况
    NSString *titleRichSpan = nil;
    if (isEmptyString(videoInfoResponse.article.titleRichSpan)) {
        if ([self.detailModel.article respondsToSelector:@selector(titleRichSpanJSONString)]){
            titleRichSpan = self.detailModel.article.titleRichSpanJSONString;
        }
    }else{
        titleRichSpan = videoInfoResponse.article.titleRichSpan;
    }
    TTVVideoDetailNatantInfoModel *infoModel = [[TTVVideoDetailNatantInfoModel alloc] initWithArticle:self.videoInfo andadId:[_detailModel.adID stringValue] withCategoryId:_detailModel.categoryID andVideoAbstract:videoAbstract andTitleRichSpan:titleRichSpan];
    if (self.detailModel.logPb) {
        infoModel.logPb = self.detailModel.logPb;
    }else{
        infoModel.logPb = self.detailModel.gdExtJsonDict[@"log_pb"];
    }

    infoModel.enterFrom = [self enterFromString];
    TTVVideoDetailNatantInfoViewController  *natantInfoVC = [[TTVVideoDetailNatantInfoViewController alloc] initWithWidth:containerWidth andinfoModel: infoModel];
    natantInfoVC.detailStateStore = self.detailStateStore;
    self.detailStateStore.state.titleRichSpan = titleRichSpan;

    if (natantInfoVC) {
        self.InfoVC = natantInfoVC;
        RACChannelTo(self.detailModel.protocoledArticle, userDigg) = RACChannelTo(self.InfoVC, infoView.viewModel.infoModel.userDiged);
        RACChannelTo(self.detailModel.protocoledArticle, userBury) = RACChannelTo(self.InfoVC, infoView.viewModel.infoModel.userBuried);
        RACChannelTo(self.detailModel.protocoledArticle, diggCount) = RACChannelTo(self.InfoVC, infoView.viewModel.infoModel.digCount);
        RACChannelTo(self.detailModel.protocoledArticle, buryCount) = RACChannelTo(self.InfoVC, infoView.viewModel.infoModel.buryCount);
        natantInfoVC.infoView.shareManager = _toolbarVC;
        [self addChildViewController:natantInfoVC];
        [self.ttvContainerScrollView.contentView addSubview: natantInfoVC.view];
        [natantViewArray addObject:natantInfoVC.view];
        [self.InfoVC didMoveToParentViewController:self];
        natantInfoVC.view.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        @weakify(self);
        natantInfoVC.showBlock = ^(BOOL isAvailable){//isAvailable 参数暂时不用
            @strongify(self);
            [self showExtendLinkViewWithArticle:videoInfoResponse isAuto:NO];
        };
    }
    
    BOOL showCarCardView = videoInfoResponse.carCardArray.count > 0;
    if (showCarCardView) {
        self.InfoVC.infoView.showCardView = YES;
        for (RACDisposable *disposable in self.cardViewObserveDisposableArray) {
            [disposable dispose];
        }
        NSMutableArray *disposableArray = [[NSMutableArray alloc] init];
        for (TTVDetailCarCard *carCard in videoInfoResponse.carCardArray) {
            TTVVideoDetailCarCardView *cardView = [[TTVVideoDetailCarCardView alloc] initWithFrame:CGRectMake((self.view.width - containerWidth) / 2, 0, containerWidth, 44)];
            if ([TTDeviceHelper isPadDevice]) {
                cardView.frame = CGRectMake(0, 0, self.InfoVC.infoView.width, 44);
            }
            cardView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
            cardView.card = carCard;
            cardView.artileGroupID = self.videoInfo.groupModel.groupID;
            [self.ttvContainerScrollView.contentView addSubview:cardView];
            if (self.InfoVC.infoView.showShareView){
                UIView* cardPaddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, cardView.width, [TTDeviceUIUtils tt_newPadding:3])];
                [self.ttvContainerScrollView.contentView addSubview:cardPaddingView];
            }
            @weakify(self);
            RACDisposable *disposable = [[[[[RACObserve(self.ttvContainerScrollView, contentOffset) distinctUntilChanged] filter:^BOOL(NSValue *value) {
                @strongify(self);
                return self.ttvContainerScrollView.contentOffset.y + self.ttvContainerScrollView.height > cardView.ttvOriginalY;
            }] take:1] takeUntil:self.rac_willDeallocSignal] subscribeCompleted:^{
                @strongify(self);
                NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
                [params setValue:@"page_detail_video_pic" forKey:@"source"];
                [params setValue:self.videoInfo.groupModel.groupID forKey:@"group_id"];
                [TTTrackerWrapper eventV3:@"show_autocard" params:params];
            }];
            [disposableArray addObject:disposable];
            [natantViewArray addObject:cardView];
        }
        self.cardViewObserveDisposableArray = [disposableArray copy];
    }
    
    TTVideoDetailSearchTagPosition tagPosition = TTVideoDetailSearchTagPositionUnknown;
    if (videoInfoResponse.hasVideoDetailTags) {
        tagPosition = videoInfoResponse.videoDetailTags.videoSearchtagPosition;
        if (tagPosition == TTVideoDetailSearchTagPositionTop) {
            [self _addTagsViewWithNatantViewArray:natantViewArray containerWidth:containerWidth tagPosition:tagPosition];
        }
    }
    
    if (videoInfoResponse.hasPartnerVideo) {
        if ([videoInfoResponse.partnerVideo inValid]) {
            
            if ([TTThemeManager sharedInstance_tt].currentThemeMode != TTThemeModeNight) {
                TTVVideoDetailNatantVideoBanner *banner = [[TTVVideoDetailNatantVideoBanner alloc] initWithFrame:CGRectMake(0, 0, containerWidth, 0)];
                banner.groupID = [self.detailModel uniqueID];
                banner.viewModel = videoInfoResponse.partnerVideo;
                
                [self.ttvContainerScrollView.contentView addSubview:banner];
                [natantViewArray addObject:banner];
                
                TTVVideoDetailBannerType type = [videoInfoResponse.partnerVideo getTTVideoBannerType];
                switch (type) {
                    case TTVVideoDetailBannerTypeWebDetail:
                    {
                        if (videoInfoResponse.partnerVideo.appName && banner.groupID) {
                            [TTTrackerWrapper eventV3:@"video_banner_subscribe_show_h5page" params:@{@"app" : videoInfoResponse.partnerVideo.appName, @"group_id": banner.groupID}];
                        }
                    }
                        break;
                    case TTVVideoDetailBannerTypeOpenApp:
                    {
                        if (videoInfoResponse.partnerVideo.appName) {
                            wrapperTrackEventWithCustomKeys(@"video_banner", @"subscribe_show_jump", [self.detailModel uniqueID], nil, @{@"app" : videoInfoResponse.partnerVideo.appName});
                        }
                    }
                        break;
                    case TTVVideoDetailBannerTypeDownloadApp:
                    {
                        if (videoInfoResponse.partnerVideo.appName) {
                            wrapperTrackEventWithCustomKeys(@"video_banner", @"subscribe_show_download", [self.detailModel uniqueID], nil, @{@"app" : videoInfoResponse.partnerVideo.appName});
                        }
                    }
                        break;
                    default:
                        break;
                }
            }
            
            self.movieBanner.viewModel = videoInfoResponse.partnerVideo;
            self.movieBanner.groupID = [self.detailModel uniqueID];
            [self.view addSubview:self.movieBanner];
        }
    } else {
        NSString *contentID = [self p_contentID];
        if ([[self.videoInfo.videoDetailInfo objectForKey:VideoInfoShowPGCSubscribeKey] boolValue] &&
            !isEmptyString(contentID))
        {
            TTVVideoDetailNatantPGCModel *pgcModel = [[TTVVideoDetailNatantPGCModel alloc] initWithVideoArticle:self.videoInfo];
            @weakify(self);
            pgcModel.updateFansCountBlock = ^(NSNumber *fansCount) {
                @strongify(self);
                if ([self.videoInfo isKindOfClass:[TTVVideoInformationResponse class]]) {
                    TTVVideoInformationResponse *infoRe = (TTVVideoInformationResponse *) self.videoInfo;
                    infoRe.userInfoEntity.fansCount = [fansCount longLongValue];
                }
            };
            pgcModel.activityDic = videoInfoResponse.activityDic;
            pgcModel.categoryName = [self categoryName];
            pgcModel.enterFrom = [self enterFromString];
            if (self.detailModel.logPb) {
                pgcModel.logPb = self.detailModel.logPb;
            }else{
                pgcModel.logPb = self.detailModel.gdExtJsonDict[@"log_pb"];
            }
            
            TTVVideoDetailNatantPGCViewController *topPGCVC = [[TTVVideoDetailNatantPGCViewController alloc] initWithInfoModel:pgcModel andWidth:containerWidth];
            self.topPGCVC = topPGCVC;
            topPGCVC.authorView.delegate = self;
            [self addChildViewController:self.topPGCVC];
            [self.view addSubview:self.topPGCVC.view];
            [self.topPGCVC didMoveToParentViewController:self];
            self.topPGCVC.view.autoresizingMask = UIViewAutoresizingFlexibleWidth;
            
            self.commodityVC.pgcHeight = self.topPGCVC.view.height;
            
            {
                self.followRecommendVC = [[TTVDetailFollowRecommendViewController alloc] initWithPGCViewModel:self.topPGCVC.authorView.viewModel ViewWidth:self.headerPosterVC.view.width];
                [self addChildViewController:self.followRecommendVC];
                [self.view addSubview:self.followRecommendVC.view];
                [self.followRecommendVC didMoveToParentViewController:self];
                self.followRecommendVC.view.autoresizingMask = UIViewAutoresizingFlexibleWidth;
                @weakify(self);
                self.followRecommendVC.backActionFired = ^{
                    @strongify(self);
                    [self.topPGCVC.authorView arrowButtonPressed];
                };
            }
        }
    }
    
    if (videoInfoResponse.relatedVideoArray.count > 0) {
        _relatedVideoVC.videoInfo = videoInfoResponse;
        UIView *videoView = _relatedVideoVC.view;
        videoView.frame = CGRectMake(0, 0, containerWidth, 0);
        [self.ttvContainerScrollView.contentView addSubview:videoView];
        [_relatedVideoVC didMoveToParentViewController:self];
        [natantViewArray addObject:videoView];
        self.relatedVideoIndexWhenNotDistinct = [natantViewArray indexOfObject:videoView];
        
        if (tagPosition == TTVideoDetailSearchTagPositionBelowRelatedVideo) {
            [self _addTagsViewWithNatantViewArray:natantViewArray containerWidth:containerWidth tagPosition:tagPosition];
        }
    }
    
    if ([self _needAddAlbumView]) {
        [self.view bringSubviewToFront:[TTVVideoAlbumHolder holder].albumView];
    }
    
    UIView* topPaddingView = [TTAdManageInstance video_detailBannerPaddingView:containerWidth topLineShow:NO bottomLineShow:YES];
    [self.ttvContainerScrollView.contentView addSubview:topPaddingView];
    [natantViewArray addObject:topPaddingView];
    
    if (videoInfoResponse.adData) {
        
        CGFloat leftMargin = [TTDeviceHelper isPadDevice] ? 20 : 15;
        NSDictionary* adData = videoInfoResponse.adData;
        if ([videoInfoResponse.adData isKindOfClass:[NSString class]]) {
            NSData *jsonData = [(NSString *)videoInfoResponse.adData dataUsingEncoding:NSUTF8StringEncoding];
            NSError *jsonError;
            adData = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&jsonError];
        }
    
        if (videoInfoResponse.relatedVideoArray.count < 1 && self.InfoVC.infoView.showShareView) {
            UIView* adPaddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, containerWidth, [TTDeviceUIUtils tt_newPadding:12])];
            [self.ttvContainerScrollView.contentView addSubview:adPaddingView];
        }
        
        TTVideoDetailADContainerView* adContainer = [[TTVideoDetailADContainerView alloc] initWithFrame:CGRectMake(0, 0, containerWidth - leftMargin*2, 0)];
        adContainer.left = leftMargin;
        adContainer.delegate = self;
        adContainer.isVideoAd = YES;
        
        TTAdDetailViewModel *viewModel = [TTAdDetailViewModel new];
        viewModel.article = videoInfoResponse;
        adContainer.viewModel = viewModel;
        viewModel.fromSource = 1;
        
        [adContainer reloadData:videoInfoResponse];
        [self.ttvContainerScrollView.contentView addSubview:adContainer];
        [natantViewArray addObject:adContainer];
        BOOL showPadding = [TTAdDetailViewHelper detailBannerIsUnityAd:adData] && (![TTDeviceHelper isPadDevice]);
        if (showPadding == YES) {
            UIView* bottomPaddingView = [TTAdManageInstance video_detailBannerPaddingView:containerWidth topLineShow:YES bottomLineShow:YES];
            [self.ttvContainerScrollView.contentView addSubview:bottomPaddingView];
            [natantViewArray addObject:bottomPaddingView];
        }
    }
    
    if (videoInfoResponse.hasAdminDebug) {
        CGFloat edgePadding = 15.f;
        TTVVideoDetailTextlinkADView *adminDebugView = [[TTVVideoDetailTextlinkADView alloc] initWithFrame:CGRectMake(0, 0, containerWidth - edgePadding*2, 0)];
        adminDebugView.left = edgePadding;
        adminDebugView.viewModel = videoInfoResponse;
        [self.ttvContainerScrollView.contentView addSubview:adminDebugView];
        [natantViewArray addObject:adminDebugView];
    }
    
    
    if (tagPosition == TTVideoDetailSearchTagPositionAboveComment) {
        [self _addTagsViewWithNatantViewArray:natantViewArray containerWidth:containerWidth tagPosition:tagPosition];
    }
    
    if (self.topPGCVC) {
        self.InfoVC.infoView.intensifyAuthor = YES;
    }
    
    if (self.topPGCVC && !showCarCardView) {
        [self.InfoVC.infoView showBottomLine];
    };;
    UIView *commentView = _commentVC.view;
    _commentVC.view.ttvNestedScrollView = _commentVC.commentTableView;
    commentView.frame = CGRectMake(0, 0, containerWidth, 0);
    [self.ttvContainerScrollView.contentView addSubview:commentView];
    [_commentVC didMoveToParentViewController:self];
}

- (void)_addTagsViewWithNatantViewArray:(NSMutableArray *)natantViewArray containerWidth:(CGFloat)containerWidth tagPosition:(TTVideoDetailSearchTagPosition)tagPosition {
    TTVVideoInformationResponse *videoInfoResponse = nil;
    if ([self.videoInfo isKindOfClass:[TTVVideoInformationResponse class]]) {
        videoInfoResponse = (TTVVideoInformationResponse *)self.videoInfo;
    }
    TTVVideoDetailNatantTagsView *tagView = [[TTVVideoDetailNatantTagsView alloc] initWithFrame:CGRectMake(0, 0, containerWidth, 0)];
    tagView.tagPosition = tagPosition;
    tagView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    tagView.viewModel = videoInfoResponse;
    [self.ttvContainerScrollView.contentView addSubview:tagView];
    [natantViewArray addObject:tagView];
    _tagsView = tagView;
}

- (CGFloat)widthForContentView
{
    CGSize windowSize = self.view.bounds.size;
    if ([ExploreVideoDetailHelper currentVideoDetailRelatedStyleForMaxWidth:[self maxWidth]] == VideoDetailRelatedStyleNatant) {
        return windowSize.width - [TTUIResponderHelper paddingForViewWidth:windowSize.width] * 2;
    } else {
        return self.headerPosterVC.view.size.width;
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

- (NSString *)p_contentID {
    NSString *contentID = nil;
    id<TTVArticleProtocol> article = self.detailModel.protocoledArticle;
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
    return contentID.integerValue > 0 ? contentID : nil;
}

- (BOOL)_needAddAlbumView {
    if ([TTVVideoAlbumHolder holder].albumView.superview && ![TTVVideoAlbumHolder holder].albumView.hidden && [TTVVideoAlbumHolder holder].albumView.alpha) {
        return YES;
    }
    return NO;
}

#pragma mark - TTVPlayerDoubleTap666Delegate

- (TTVDoubleTapDigType)ttv_doubleTapDigType {
    if (!isEmptyString(self.videoInfo.adIDStr)) {
        return TTVDoubleTapDigTypeForbidDig;
    }
    if (self.videoInfo.userBury) {
        return TTVDoubleTapDigTypeAlreadyBury;
    }
    if (self.videoInfo.userDigg) {
        return TTVDoubleTapDigTypeAlreadyDig;
    }
    return TTVDoubleTapDigTypeCanDig;
}

- (void)ttv_doDigActionWhenDoubleTap:(TTVDoubleTapDigType)digType {
    if (digType == TTVDoubleTapDigTypeForbidDig || digType == TTVDoubleTapDigTypeAlreadyBury) {
        if (digType == TTVDoubleTapDigTypeAlreadyBury) {
                        [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:@"您已经踩过" indicatorImage:nil autoDismiss:YES dismissHandler:nil];
        }
        return;
    }
    NSMutableDictionary *pramas = [NSMutableDictionary dictionary];
    [pramas setValue:[self enterFromString] forKey:@"enter_from"];
    [pramas setValue:[self categoryName] forKey:@"category_name"];
    [pramas setValue:self.videoInfo.groupModel.groupID forKey:@"group_id"];
    [pramas setValue:self.videoInfo.groupModel.itemID forKey:@"item_id"];
    [pramas setValue:@"detail" forKey:@"position"];
    [pramas setValue:(self.detailStateStore.state.isFullScreen ? @"fullscreen" : @"notfullscreen") forKey:@"fullscreen"];
    [pramas setValue:@"double_like" forKey:@"action_type"];
    [TTTrackerWrapper eventV3:@"rt_like" params:pramas];
    if (digType == TTVDoubleTapDigTypeCanDig) {
        [self.InfoVC.infoView.viewModel digAction];
        [self.InfoVC.infoView updateActionButtons];
    }
}

#pragma mark - TTVVideoDetailHomeToRelatedVideoVCActionProtocol

- (void)_showVideoAlbumWithItem:(TTVRelatedItem *)relatedItem
{
    [self.headerPosterVC vdvi_trackWithLabel:@"reduction" source:@"album_float" groupId:self.videoInfo.groupModel.groupID];   
    self.albumView.viewModel.item = relatedItem;
    self.albumView.viewModel.currentPlayingArticle = self.detailModel.protocoledArticle;
    [TTVVideoAlbumHolder holder].albumView = self.albumView;
    [self.view addSubview:self.albumView];
    
    CGRect frame = self.headerPosterVC.view.frame;
    frame.size.height = self.headerPosterVC.interactModel.minMovieH;
    self.headerPosterVC.interactModel.curMovieH = self.headerPosterVC.interactModel.minMovieH;
    self.albumView.height = self.view.height - self.headerPosterVC.interactModel.minMovieH - self.headerPosterVC.view.top;
    
    self.albumView.top = self.view.height;
    self.detailStateStore.state.forbidLayout = YES;
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.albumView.bottom = self.view.height;
        
        self.headerPosterVC.view.frame = frame;
        self.movieShotView.frame = self.headerPosterVC.view.bounds;
        self.movieView.frame = self.movieShotView.bounds;
        if (self.topPGCVC){
            self.ttvContainerScrollView.top = self.topPGCVC.view.bottom;
        }
        else {
            self.ttvContainerScrollView.top = self.headerPosterVC.view.bottom;
        }
        [self.headerPosterVC.playControl updateFrame];
        [self adjustContainerScrollViewHeight];
    } completion:^(BOOL finished) {
        self.detailStateStore.state.forbidLayout = NO;
    }];
}

- (TTVDetailPlayControl *)playControl
{
    return self.headerPosterVC.playControl;
}

- (BOOL)detailVCIsFromList
{
    return [self.detailModel isFromList] && ![self shouldBeginShowComment];
}

- (BOOL)shouldBeginShowComment {
    return self.beginShowComment || self.beginShowCommentUGC;
}

- (void)ttv_invalideMovieView
{
    [self.headerPosterVC _invalideMovieViewWithFinishedBlock:nil];
}

#pragma mark - notification

- (void)addObserver
{
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
    self.detailStateStore.state.hasClickRelated = YES;
}

#pragma mark - TTDetailViewController

- (void)detailContainerViewController:(SSViewControllerBase *)container reloadData:(TTDetailModel *)detailModel
{
}

- (void)detailContainerViewController:(nullable SSViewControllerBase *)container loadContentFailed:(nullable NSError *)error{
    [self tt_endUpdataData];
}

#pragma mark - TTAdDetailContainerViewDelegate

- (void)removeNatantView:(TTDetailNatantViewBase *_Nonnull)natantView animated:(BOOL)animated
{
    NSString *className = NSStringFromClass([natantView class]);
    NSMutableArray* array = [NSMutableArray arrayWithArray:self.ttvContainerScrollView.contentView.subviews];
    [array enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:NSClassFromString(className)]) {
            
            NSInteger index = [self.ttvContainerScrollView.contentView.subviews indexOfObject:obj];
            if (index == NSNotFound) {
                *stop = YES;
                return;
            }
            //删除bottomPadding
            if (self.ttvContainerScrollView.contentView.subviews.count > index + 1) {
                TTVideoDetailBannerPaddingView* spaceBottomItem = (TTVideoDetailBannerPaddingView*)self.ttvContainerScrollView.contentView.subviews[index + 1];
                if (spaceBottomItem && [spaceBottomItem isKindOfClass:[TTVideoDetailBannerPaddingView class]]) {
                    [spaceBottomItem removeFromSuperview];
                }
            }
            //删除adContaniner
            [(UIView*)obj removeFromSuperview];
            *stop = YES;
        }
        
    }];
    
}

#pragma mark - notification

- (void)updateMomentCountOfComment:(NSNotification *)notification {
    if (self.commentIndexPathToReload) {
        NSInteger increment = [notification.userInfo integerValueForKey:@"increment" defaultValue:0];
        NSInteger count = [notification.userInfo integerValueForKey:@"count" defaultValue:0];
        if (increment) {
            self.replyVC.commentModel.replyCount = @(self.replyVC.commentModel.replyCount.integerValue+increment);
        } else if (count) {
            self.replyVC.commentModel.replyCount = @(count);
        }
        [self.commentVC refreshVideoCommentCellLayoutAtIndexPath:self.commentIndexPathToReload replyCount:self.replyVC.commentModel.replyCount.integerValue];
    }
}

#pragma mark - private methods

- (void)p_deleteLocalVideo {
    if (self.videoInfo.uniqueID > 0) {
        //给feed发通知
        NSString *uniqueID = [NSString stringWithFormat:@"%lld", self.videoInfo.uniqueID];
        [[NSNotificationCenter defaultCenter] postNotificationName:TTVideoDetailViewControllerDeleteVideoArticle object:nil userInfo:@{@"uniqueID":uniqueID}];
        //从数据库中删除
        NSArray *orderedDataArray = [ExploreOrderedData objectsWithQuery:@{@"uniqueID": uniqueID}];
        [ExploreOrderedData removeEntities:orderedDataArray];
        
        //        NSArray * orderedDataArray = [[[SSDataContext sharedContext] mainThreadModelManager] entitiesWithQuery:@{@"originalData.uniqueID":self.detailModel.orderedData.originalData.uniqueID} entityClass:[ExploreOrderedData class] error:nil];
        //        [[SSModelManager sharedManager] removeEntities:orderedDataArray error:nil];
        [self _topViewBackButtonPressed];
        //给个人主页发通知
        NSMutableDictionary *profileDict = [NSMutableDictionary dictionary];
        [profileDict setValue:self.detailModel.protocoledArticle.itemID forKey:@"item_id"];
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

- (void)ttv_detailBackTrack
{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setValue:self.detailModel.protocoledArticle.groupModel.groupID forKey:@"group_id"];
    [dic setValue:self.detailModel.protocoledArticle.groupModel.itemID forKey:@"item_id"];
    [dic setValue:self.detailStateStore.state.clickedBackBtn ? @"page_close_button" : @"gesture" forKey:@"back_type"];
    [TTTrackerWrapper eventV3:@"detail_back" params:dic isDoubleSending:YES];
    
    if (!isEmptyString(self.ruleID)) {
        NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithCapacity:3];
        [parameters setValue:self.ruleID forKey:@"rule_id"];
        [parameters setValue:self.originalGroupID forKey:@"group_id"];
        [parameters setValue:@"video" forKey:@"message_type"];
        [TTTrackerWrapper eventV3:@"push_page_back_to_feed"
                           params:[parameters copy]];
    }
}

- (void)_topViewBackButtonPressed
{
    self.detailStateStore.state.isBackAction = YES;
    self.detailStateStore.state.clickedBackBtn = YES;
    NSInteger index = [self topViewControllerIndexWithNoneDragToRoot];
    [self.navigationController popToViewController:self.navigationController.viewControllers[index] animated:YES];
}

- (void)backAction
{
    [self _topViewBackButtonPressed];
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

#pragma mark - TTVVideoDetailHomeToToolbarVCActionProtocol

- (void)_scrollToCommentListHeadAnimated:(BOOL)animated
{
    TTVContainerScrollView *commentView = self.ttvContainerScrollView;
    CGFloat scrollThrougthContentOffset = MIN(commentView.contentSize.height - commentView.height, _commentVC.view.ttvOriginalY);
    if (self.commodityVC.view.height > 0) {
        scrollThrougthContentOffset -= self.topPGCVC.view.height;
    }
    if (scrollThrougthContentOffset > 0) {
        if (_tagsView. tagPosition == TTVideoDetailSearchTagPositionAboveComment && _tagsView.height > 0) {
            scrollThrougthContentOffset -= _tagsView.height;
        }
        [commentView setContentOffset:CGPointMake(0, scrollThrougthContentOffset) animated:animated];
    }
}

- (void)vdvi_changeMovieSizeWithStatus:(TTVVideoDetailViewShowStatus)status
{
    [self.headerPosterVC vdvi_changeMovieSizeWithStatus:status];
}

#pragma mark - TTVVideoDetailHomeToHeaderActionProtocol

- (CGFloat)maxWidth
{
    return self.view.bounds.size.width;
}

- (void)adjustContainerScrollViewHeight
{
    self.ttvContainerScrollView.height = self.view.height - self.toolbarVC.view.height - self.ttvContainerScrollView.top;
}

- (BOOL)shouldPauseMovieWhenVCDidDisappear
{
    return ![self shouldContinuePlayMovieWhenBackToFeedListInternal__] && [self shouldPauseMovieWhenVCDidDisappearInternal__];
}

#pragma mark - Helpers

- (NSDictionary *)userInfo
{
    if (self.detailModel.protocoledArticle.detailUserInfo) {
        return self.detailModel.protocoledArticle.detailUserInfo;
    } else {
        return self.detailModel.protocoledArticle.userInfo;
    }
}

- (void)_scrollToCommentsIfNeeded
{
    if ([self shouldBeginShowComment] &&
        self.toolbarVC.showStatus == TTVVideoDetailViewShowStatusVideo) {
        [self.toolbarVC _switchShowStatusAnimated:YES isButtonClicked:NO];
    }
}

- (BOOL)shouldPauseMovieWhenVCDidDisappearInternal__
{
    if (self.playControl.movieView.playerModel.isAutoPlaying) {
        return NO;
    }
    return ![self shouldContinuePlayVideoWhenback] && (![[TTVAutoPlayManager sharedManager] IsCurrentAutoPlayingWithUniqueId:[self.detailModel uniqueID]]);
}

- (BOOL)shouldContinuePlayMovieWhenBackToFeedListInternal__
{
    BOOL videoContinuePlayWhenFromDetail  = [[[TTSettingsManager sharedManager] settingForKey:@"tt_feed_continue_play_from_detail_enable" defaultValue:@NO freeze:NO] boolValue];
    return videoContinuePlayWhenFromDetail && self.navigationControllerBeforeBeingPoped.topViewController == [TTUIResponderHelper correctTopViewControllerFor:self.feedListViewController];
}

- (void)checkCommentTableShowStatus:(UIScrollView *)scrollView
{
    CGFloat offsetPadding = 0;
    UIView *headerView = self.commentVC.commentTableView.tableHeaderView;
    CGRect rect = [headerView.superview convertRect:headerView.frame toView:self.view];
    if (CGRectGetMaxY(rect) > self.view.frame.size.height)//comment hidden
    {
        [self.commentVC sendShowStatusTrackForCommentShown:NO];
        [self.detailStateStore sendAction:TTVDetailEventTypeCommentListViewWillDisappear payload:nil];
    }
    else
    {
        [self.commentVC sendShowStatusTrackForCommentShown:YES];
        
        [self.detailStateStore sendAction:TTVDetailEventTypeCommentListViewDidAppear payload:nil];
    }
    
    [self.ttvContainerScrollView checkVisibleAtContentOffset:scrollView.contentOffset.y+offsetPadding referViewHeight:scrollView.height];
    
    CGFloat scrollOffsetY = scrollView.contentOffset.y;
    
    if (self.toolbarVC.enableScrollToChangeShowStatus) {
        CGFloat scrollToCommentAreaMinHeight = MIN(self.ttvContainerScrollView.contentSize.height - self.ttvContainerScrollView.height, _commentVC.view.ttvOriginalY - self.ttvContainerScrollView.height);
        if (scrollOffsetY < scrollToCommentAreaMinHeight) {
            self.toolbarVC.showStatus = TTVVideoDetailViewShowStatusVideo;
        } else {
            self.toolbarVC.showStatus = TTVVideoDetailViewShowStatusComment;
        }
    }
    
    [self.ttvContainerScrollView sendNatantItemsShowEventWithContentOffset:scrollOffsetY scrollView: scrollView isScrollUp: YES];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView == self.ttvContainerScrollView) {
        if (![TTDeviceHelper isPadDevice]) {
            self.topPGCVC.authorView.bottomLine.hidden = (scrollView.contentOffset.y<=0);
        }
        
        [self.headerPosterVC vdvi_commentTableViewDidScroll:scrollView];
        if (self.detailStateStore.state.hasCommodity) {
            [self layoutTopPGCView];
        }
        [self checkCommentTableShowStatus:scrollView];
    }
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    if (scrollView == self.ttvContainerScrollView) {
        self.toolbarVC.enableScrollToChangeShowStatus = YES;
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (scrollView == self.ttvContainerScrollView) {
        [self.headerPosterVC vdvi_commentTableViewDidEndDragging:scrollView];
    }
}

#pragma mark -
#pragma mark  TTVCommentDataSource and  TTVCommentDelegate

- (void)commentViewControllerDidShowProfileFill
{
    [self.playControl pauseMovieIfNeeded];
}

- (SSThemedView *)commentHeaderView
{
    return nil;
}

- (NSString *)msgId
{
    return self.detailModel.msgID;
}

- (id<TTVArticleProtocol> )serveArticle
{
    if ([self.detailModel.protocoledArticle conformsToProtocol:@protocol(TTVArticleProtocol)]) {
        return self.detailModel.protocoledArticle;
    } else {
        return nil;
    }
}

- (void)commentViewController:(id<TTCommentViewControllerProtocol>)ttController didClickCommentCellWithCommentModel:(id<TTVCommentModelProtocol, TTCommentDetailModelProtocol>)model
{
    [self p_sendDetailTTLogV2WithEvent:@"click_comment" eventContext:@{@"comment_id":model.commentIDNum.stringValue} referContext:nil];
    NSMutableDictionary *paramsDict = [[NSMutableDictionary alloc] init];
    [paramsDict setValue:self.videoInfo.groupModel.groupID forKey:@"group_id"];
    [paramsDict setValue:model.commentIDNum forKey:@"comment_id"];
    [paramsDict setValue:[self categoryName] forKey:@"category_name"];
    [paramsDict setValue:@"click_comment" forKey:@"enter_type"];
    [TTTrackerWrapper eventV3:@"reply_comment" params:paramsDict];
}

- (void)sendCommentDiggActionLogV3WithCommentID:(NSString *) commentId digg:(BOOL )isDigg commentPosition:(NSString *)position
{
    NSMutableDictionary *event3Dic = [NSMutableDictionary dictionary];
    [event3Dic setValue:commentId forKey:@"comment_id"];
    [event3Dic setValue:self.videoInfo.groupModel.groupID forKey:@"group_id"];
    [event3Dic setValue:[self categoryName] forKey:@"category_name"];
    [event3Dic setValue:[self enterFromString] forKey:@"enter_from"];
    [event3Dic setValue:[self p_contentID] forKey:@"user_id"];
    [event3Dic setValue:[self logPb] forKey:@"log_pb"];
    [event3Dic setValue:@"detail" forKey:@"position"];
    [event3Dic setValue:position forKey:@"comment_position"];
    if (isDigg) {
        [TTTrackerWrapper eventV3:@"comment_digg" params:event3Dic];
    }else{
        [TTTrackerWrapper eventV3:@"comment_undigg" params:event3Dic];
    }
}

- (void)commentViewController:(id<TTCommentViewControllerProtocol>)ttController digCommentWithCommentModel:(nonnull id<TTVCommentModelProtocol, TTCommentDetailModelProtocol>)model
{
    [self p_sendDetailTTLogV2WithEvent:@"click_comment_like" eventContext:@{@"comment_id":model.commentIDNum.stringValue} referContext:nil];
    [self sendCommentDiggActionLogV3WithCommentID:model.commentIDNum.stringValue digg:model.userDigged commentPosition:@"detail"];
}

- (void)commentViewController:(id<TTCommentViewControllerProtocol>)ttController didClickReplyButtonWithCommentModel:(nonnull id<TTVCommentModelProtocol, TTCommentDetailModelProtocol>)model
{
    NSMutableDictionary *paramsDict = [[NSMutableDictionary alloc] init];
    [paramsDict setValue:self.videoInfo.groupModel.groupID forKey:@"group_id"];
    [paramsDict setValue:model.commentIDNum forKey:@"comment_id"];
    [paramsDict setValue:[self categoryName] forKey:@"category_name"];
    [paramsDict setValue:@"reply_button" forKey:@"enter_type"];
    [TTTrackerWrapper eventV3:@"reply_comment" params:paramsDict];
    
    [self p_sendDetailTTLogV2WithEvent:@"click_reply" eventContext:@{@"comment_id":model.commentIDNum.stringValue} referContext:nil];
}

- (void)p_enterProfileWithUserID:(NSString *)userID {
    
    // add by zjing 去掉个人主页跳转
    return;
    
    NSMutableDictionary *baseCondition = [[NSMutableDictionary alloc] init];
    [baseCondition setValue:userID forKey:@"uid"];
    [[TTRoute sharedRoute] openURLByPushViewController:[NSURL URLWithString:@"sslocal://profile"] userInfo:TTRouteUserInfoWithDict(baseCondition)];
}

- (void)commentViewController:(id<TTCommentViewControllerProtocol>)ttController tappedWithUserID:(NSString *)userID {
    if ([userID longLongValue] == 0) {
        return;
    }
    [self p_enterProfileWithUserID:userID];
    
}

- (void)commentViewController:(id<TTVCommentViewControllerProtocol>)ttController avatarTappedWithCommentModel:(nonnull id<TTVCommentModelProtocol, TTCommentDetailModelProtocol>)model
{
    
    // add by zjing 去掉个人主页跳转
    return;
    
    if ([model.userID longLongValue] == 0) {
        return;
    }
    
    [self p_enterProfileWithUserID:model.userID];
    
    [self p_sendDetailTTLogV2WithEvent:@"click_profile" eventContext:@{@"uid":model.userID.stringValue} referContext:nil];
}

- (void)commentViewControllerDidFetchCommentsWithError:(NSError *)error
{
    //是否已经更新article的commentCount？
    _hasFetchedComments = YES;
    if ([self.commentVC respondsToSelector:@selector(defaultReplyCommentModel)] && self.commentVC.defaultReplyCommentModel) {
        TTVCommentListItem *defaultReplyCommentModel = [self.commentVC defaultReplyCommentModel];
          NSString *userName = defaultReplyCommentModel.commentModel.userName;
        NSString *writeCommentButtonHoldText = isEmptyString(userName)? @"写评论...": [NSString stringWithFormat:@"回复 %@：", userName];
        self.toolbarVC.writeButtonPlayHoldText = writeCommentButtonHoldText;
    }
    //如果info接口返回了数据，commenVC.view被添加，则执行此操作
    if (self.commentVC.view.superview) {
        //info接口比comment接口先返回
        [self _scrollToCommentsIfNeeded];
    }
    // toolbar 禁表情
    if ([self.commentVC respondsToSelector:@selector(tt_banEmojiInput)]) {
        self.toolbarVC.banEmojiInput = self.commentVC.tt_banEmojiInput;
    }
}

- (void)p_sendDetailTTLogV2WithEvent:(NSString *)event
                        eventContext:(NSDictionary *)eventContext
                        referContext:(NSDictionary *)referContext
{

}

- (BOOL)commentViewController:(id<TTVCommentViewControllerProtocol>)ttController shouldPresentCommentDetailViewControllerWithCommentModel:(id<TTVCommentModelProtocol, TTCommentDetailModelProtocol>)model indexPath:(NSIndexPath *)indexPath showKeyBoard:(BOOL)showKeyBoard {
    if (!isEmptyString(model.openURL)) {
        [[TTRoute sharedRoute] openURLByPushViewController:[TTStringHelper URLWithURLString:model.openURL]];
    } else {
        self.commentIndexPathToReload = indexPath;
        if (!model.replyCount.integerValue) {
            [self p_showWriteCommentWithCommentModel:model];
        } else {
            [self p_showFloatCommentView:model momentCommentModel:nil];
        }
    }
    
    [self.detailStateStore sendAction:TTVDetailEventTypeCommentDetailViewDidAppear payload:nil];
    
    return YES;
}

- (void)commentViewController:(id<TTVCommentViewControllerProtocol>)ttController startWriteComment:(id<TTVCommentModelProtocol, TTCommentDetailModelProtocol>)model {
    if (self.toolbarActionDelegate && [self.toolbarActionDelegate respondsToSelector:@selector(_writeCommentActionFired)]) {
        [self.toolbarActionDelegate _writeCommentActionFired];
    }
}

- (void)tt_commentViewControllerRefreshDataInNoNetWorkCondition{
    [self buildPlaceholdView];
    [self loadVideoInfo];
}

#pragma mark -

- (void)p_showWriteCommentWithCommentModel:(id<TTVCommentModelProtocol, TTCommentDetailModelProtocol>)commentModel {
    if (self.isGettingMomentDetail) {
        return;
    }
    self.isGettingMomentDetail = YES;
    if (!_commentDetailService) {
        _commentDetailService = [[TTCommentDataManager alloc] init];
    }
    @weakify(self);
    [_commentDetailService fetchCommentDetailWithCommentID:[commentModel.commentIDNum stringValue] finishBlock:^(TTCommentDetailModel *model, NSError *error) {
        @strongify(self);
        if (error || !model) {
            NSDictionary *info = [error.userInfo valueForKey:@"tips"];
            if ([info isKindOfClass:[NSDictionary class]]) {
                NSString *tip = [info stringValueForKey:@"display_info" defaultValue:@""];
                [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:tip indicatorImage:[UIImage themedImageNamed:@"close_popup_textpage"] autoDismiss:YES dismissHandler:^(BOOL isUserDismiss) {
                }];
            }
            else {

                NSString *tip = @"连接失败，请稍后再试";
                [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:tip indicatorImage:[UIImage themedImageNamed:@"close_popup_textpage"] autoDismiss:YES dismissHandler:^(BOOL isUserDismiss) {
                }];
            }
        } else {
            self.commentModelForFloatComment = commentModel;
            model.groupModel = self.detailModel.article.groupModel ?: model.groupModel;
            [self p_showWriteCommentWithMomentModel:model];
        }
        self.isGettingMomentDetail = NO;
    }];
}

- (void)p_showWriteCommentWithMomentModel:(TTCommentDetailModel *)commentDetailModel {

    if (self.replyWriteView && !self.replyWriteView.isDismiss) {
        return;
    }
    if (commentDetailModel.user.isBlocked || commentDetailModel.user.isBlocking)
    {
        NSString * description = nil;
        if (commentDetailModel.user.isBlocked) {
            description = [[SSIndicatorTipsManager shareInstance] indicatorTipsForKey:kTipForActionToBlockedUser];
        } else {
            description = [[SSIndicatorTipsManager shareInstance] indicatorTipsForKey:kTipForActionToBlockingUser];
        }
        if (!description) {
            description = commentDetailModel.user.isBlocked ? @" 根据对方设置，您不能进行此操作" : @"您已拉黑此用户，不能进行此操作";
        }

        [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:description indicatorImage:[UIImage themedImageNamed:@"close_popup_textpage.png"] autoDismiss:YES dismissHandler:nil];
        return;
    }

    NSString *fw_id = [commentDetailModel.repost_params tt_stringValueForKey:@"fw_id"];
    if (isEmptyString(fw_id)) {
        fw_id = self.videoInfo.groupModel.groupID;
    }

    WeakSelf;
    TTCommentDetailReplyWriteManager *replyManager = [[TTCommentDetailReplyWriteManager alloc] initWithCommentDetailModel:commentDetailModel replyCommentModel:nil commentRepostBlock:^(NSString *__autoreleasing *willRepostFwID) {
        *willRepostFwID = fw_id;
    } publishCallback:^(id<TTCommentDetailReplyCommentModelProtocol> replyModel, NSError *error) {
        StrongSelf;
        if (error) {
            [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:@"发布失败" indicatorImage:[UIImage themedImageNamed:@"close_popup_textpage.png"] autoDismiss:YES dismissHandler:nil];
            return;
        }

        self.commentModelForFloatComment.replyCount = @(self.commentModelForFloatComment.replyCount.integerValue+1);
        if (self.commentIndexPathToReload) {
            [self.commentVC refreshVideoCommentCellLayoutAtIndexPath:self.commentIndexPathToReload replyCount:self.commentModelForFloatComment.replyCount.integerValue];
        }
        if (self.commentModelForFloatComment) {
            WeakSelf;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                StrongSelf;
                [self p_showFloatCommentView:self.commentModelForFloatComment momentCommentModel:replyModel];
                self.commentModelForFloatComment = nil;
            });
        }
    } getReplyCommentModelClassBlock:nil commentRepostWithPreRichSpanText:nil commentSource:nil];

    replyManager.enterFrom = self.detailModel.clickLabel;
    replyManager.categoryID = self.detailModel.categoryID;
    replyManager.logPb = self.detailModel.logPb;

    self.replyWriteView = [[TTCommentWriteView alloc] initWithCommentManager:replyManager];
    self.replyWriteView.banEmojiInput = commentDetailModel.banEmojiInput;

    [self.replyWriteView showInView:nil animated:YES];
}

- (void)p_showFloatCommentView:(id<TTVCommentModelProtocol, TTCommentDetailModelProtocol>)model momentCommentModel:(TTCommentDetailReplyCommentModel *)replyCommentModel {
    if (_replyVC.view.superview) {
        return;
    }
    TTVCommentViewController *ttController = self.commentVC;
    UIView *movieViewContainer = self.headerPosterVC.view;
    CGSize movieSize = movieViewContainer.size;
    movieSize.height = self.headerPosterVC.interactModel.minMovieH;

    TTVReplyViewController *vc = [[TTVReplyViewController alloc] initWithViewFrame:CGRectMake(0, movieSize.height + movieViewContainer.top, movieSize.width, self.view.height - movieSize.height - movieViewContainer.top) comment:model showWriteComment:NO];
    vc.vcDelegate = self;
    vc.categoryID = self.detailModel.categoryID;
    vc.enterFromStr = self.detailModel.clickLabel;
    vc.logPb = self.detailModel.logPb;
    if (self.detailModel.adID && self.detailModel.adID.longLongValue > 0) {
        vc.isAdVideo = YES;
    }
    else {
        vc.isAdVideo = NO;
    }
    vc.replyMomentCommentModel = replyCommentModel;
    if ([self.commentVC respondsToSelector:@selector(tt_banEmojiInput)]) {
        vc.isBanEmoji = self.commentVC.tt_banEmojiInput;
    }

    [self addChildViewController:vc];
    [self.view addSubview:vc.view];
    [vc didMoveToParentViewController:self];
    [self.view bringSubviewToFront:vc.view];
    self.replyVC = vc;
    self.toolbarVC.view.hidden = YES;
    vc.view.top = self.view.height;
    CGRect frame = movieViewContainer.frame;
    frame.size.height = self.headerPosterVC.interactModel.minMovieH;
    self.headerPosterVC.interactModel.curMovieH = self.headerPosterVC.interactModel.minMovieH;
    self.detailStateStore.state.forbidLayout = YES;
    [UIView animateWithDuration:0.2 animations:^{
        vc.view.bottom = self.view.height;
        movieViewContainer.frame = frame;
        self.movieShotView.frame = movieViewContainer.bounds;
        self.movieView.frame = self.movieShotView.bounds;
        [self.headerPosterVC.playControl updateFrame];
    } completion:^(BOOL finished) {
        self.detailStateStore.state.forbidLayout = NO;
    }];
}

#pragma mark - TTVideoDetailFloatCommentViewControllerDelegate

- (void)videoDetailFloatCommentViewControllerDidDimiss:(TTVReplyViewController *)vc
{
    [self.commentVC refreshVideoCommentCellLayoutAtIndexPath:self.commentIndexPathToReload replyCount:self.replyVC.commentModel.replyCount.integerValue];
    [_replyVC removeFromParentViewController];
    [_replyVC.view removeFromSuperview];
    self.replyVC = nil;
    self.toolbarVC.view.hidden = NO;

    [self.detailStateStore sendAction:TTVDetailEventTypeCommentDetailViewWillDisappear payload:vc.commentModel];

}

- (void)videoDetailFloatCommentViewControllerDidChangeDigCount {
    [self.commentVC.commentTableView reloadData];
    [self sendCommentDiggActionLogV3WithCommentID:self.replyVC.commentModel.commentID digg:self.replyVC.commentModel.userDigged commentPosition:@"comment_detail"];
}

- (void)videoDetailFloatCommentViewCellDidDigg:(BOOL)digged withModel:(id<TTVReplyModelProtocol>)model
{
    [self sendCommentDiggActionLogV3WithCommentID:model.commentID digg:!model.userDigg commentPosition:@"comment_detail"];
}
#pragma mark - TTVVideoDetailMovieBannerDelegate

- (void)didLoadImage:(TTVVideoDetailMovieBanner *)banner
{
    [self layoutViews];
}

- (UIView *)animationToView
{
    return self.movieContainerView;
}

#pragma mark - TTVVideoDetailNatantPGCViewDelegate

- (void)updateRecommendView:(BOOL)isSpread isShowRedPacket:(BOOL)showRedPacket
{
    if (self.topPGCVC.authorView.viewModel.recommendArray.count < 1){
        return ;
    }
    if (isSpread)
    {
        [self.followRecommendVC.recommendView.collectionView configUserModels:self.topPGCVC.authorView.viewModel.recommendArray];
        [self.followRecommendVC.recommendView.collectionView willDisplay];
        [self.view bringSubviewToFront:self.followRecommendVC.view];
    }else{
        self.topPGCVC.authorView.viewModel.recommendArray = nil;
        self.topPGCVC.authorView.viewModel.recommendResponse = nil;
        [self.followRecommendVC.recommendView.collectionView didEndDisplaying];
    }
    if (!showRedPacket) {
//        [self.topPGCVC.authorView subScribButtonMovement];
//        [self relayoutRecommendViewFrame:isSpread isClickArrowImage:NO];
    }

}

- (void)relayoutRecommendViewFrame:(BOOL)isSpread isClickArrowImage:(BOOL) clickArrawImage
{
    self.followRecommendVC.recommendView.actionType = clickArrawImage ? @"click_show" : @"show";
    self.followRecommendVC.view.height = self.view.bottom - self.topPGCVC.view.bottom + self.headerPosterVC.interactModel.maxMovieH - self.headerPosterVC.interactModel.minMovieH;
    if (isSpread) {
        self.followRecommendVC.view.alpha = 1.f;
        self.followRecommendVC.recommendView.alpha = 0;
        self.followRecommendVC.recommendView.height = self.followRecommendVC.recommendView.collectionView.bottom + [TTDeviceUIUtils tt_newPadding:10] + 5;
        self.followRecommendVC.recommendView.top = -self.followRecommendVC.recommendView.height;
        if (self.detailStateStore.state.hasCommodity){
            self.ttvContainerScrollView.contentOffset = CGPointMake(0, self.commodityVC.view.height);
            self.followRecommendVC.view.height += self.commodityVC.view.height;
        }
    }
    self.followRecommendVC.backButton.height = self.followRecommendVC.view.height;
    //统一三个动画的曲线，勿删CATransaction
    [CATransaction begin];
    [CATransaction setAnimationTimingFunction:[CAMediaTimingFunction functionWithControlPoints:0.39 :0.575 :0.565 :1]];
    if (isSpread){
        [self.headerPosterVC vdvi_changeMovieSizeWithStatus:TTVVideoDetailViewShowStatusComment];
    }
    [UIView animateWithDuration: 0.25f customTimingFunction: CustomTimingFunctionSineOut animation:^{
        self.followRecommendVC.recommendView.top = isSpread ? 0 : 0 - self.followRecommendVC.recommendView.height;
    } completion:^(BOOL finished) {
        self.topPGCVC.authorView.isSpread = isSpread;
        self.followRecommendVC.recommendView.isSpread = isSpread;
        if (!isSpread) {
            self.followRecommendVC.view.alpha = 0.f;
        }
    }];
    [UIView animateWithDuration:0.08f customTimingFunction: CustomTimingFunctionSineOut delay:isSpread ? 0.f:0.17f options:0 animation:^{
        self.followRecommendVC.backButton.alpha = isSpread ? 1.f : 0;
        self.followRecommendVC.recommendView.alpha = isSpread ? 1.f : 0;
    }completion:^(BOOL finished) {

    }];
    [CATransaction commit];
    
}

- (void)adTopShareActionFired
{
    [self.toolbarVC adTopShareActionFired];
}

#pragma mark - share log3.0

- (void)addDetailShareTracker{
    if (!_detailShareTracker) {
        _detailShareTracker = [[TTVShareDetailTracker alloc] init];
    }
    _detailShareTracker.enterFrom = [self enterFromString];
    _detailShareTracker.categoryName = [self categoryName];
    if (self.detailModel.logPb) {
        _detailShareTracker.logPb = self.detailModel.logPb;
    }else{
        _detailShareTracker.logPb = self.detailModel.gdExtJsonDict[@"log_pb"];
    }
    _detailShareTracker.position = @"detail";
    _detailShareTracker.platform = [NSString stringWithFormat:@"%ld",(long)0];
    _detailShareTracker.itemID = self.detailModel.article.groupModel.itemID;
    _detailShareTracker.source = @"video";
    _detailShareTracker.groupID = [self.detailModel uniqueID];
    _detailShareTracker.authorId = [self.detailModel.article.userInfo ttgc_contentID];
}
@end
