//
//  TTArticleDetailViewController.m
//  Article
//
//  Created by 冯靖君 on 16/4/8.
//
//  文章详情页VC。创建所需View并根据展示需求进行装配、调度

#import "TTArticleDetailViewController.h"
#import "TTArticleDetailViewController+Share.h"
#import "TTArticleDetailViewController+Report.h"
#import "TTArticleDetailViewController+AKReadBonus.h"
#import "TTArticleDetailView.h"
#import "TTDetailModel.h"
#import "TTArticleStoryToolView.h"
#import "TTDetailViewController.h"
#import "TTCommentWriteView.h"
#import "TTArticleDetailMenuController.h"
#import "TTNovelRecordManager.h"

#import "ExploreDetailToolbarView.h"
#import "ExploreDetailNavigationBar.h"
#import "ExploreSearchViewController.h"
#import "SSWebViewBackButtonView.h"

#import "NewsDetailLogicManager.h"
#import "NewsListLogicManager.h"
#import "TTAuthorizeManager.h" //Account&Login系列
#import <TTAccountBusiness.h>

#import "FriendDataManager.h"
#import <TTFriendRelation/TTBlockManager.h>

#import "TTDetailContainerViewController.h"
#import "TTArticleDetailNatantViewModel.h" //DetailNatant系列
#import "TTDetailNatantContainerView.h"
#import "TTDetailNatantRiskWarningView.h"
#import "TTDetailNatantRelateVideoView.h"
#import "TTDetailNatantRelateArticleGroupView.h"
#import "TTDetailNatantContainerView.h"
#import "TTDetailNatantHeaderPaddingView.h"
#import "TTDetailNatantViewBase.h"
#import "TTDetailNatantRelateReadView.h"
#import "TTDetailNatantRewardView.h"
#import "TTDetailNatantLayout.h"
#import "Article+TTADComputedProperties.h"

#import "ExploreSearchViewController.h"

#import "SSWebViewBackButtonView.h"

//Explore系列
#import "ExploreMixListDefine.h"
#import <TTEntry/ExploreEntryManager.h>

#import "SSFeedbackManager.h" //反馈

#import "TTModalWrapController.h" //评论系列
#import "TTModalContainerController.h"
#import "TTCommentDetailViewController.h"
#import "TTCommentDataManager.h"
#import "TTCommentViewController.h"

//AD系列
#import "TTAdWebResPreloadManager.h"
#import "TTAdManager.h"
#import "ExploreDetailADContainerView.h"
#import "ExploreDetailMixedVideoADView.h"
#import "TTAdDetailViewDefine.h"
#import "ExploreOrderedData+TTAd.h"

#import <TTBaseLib/TTDeviceHelper.h>
#import <TTBaseLib/TTStringHelper.h>
#import <TTBaseLib/UIButton+TTAdditions.h>
#import <TTUIWidget/TTNavigationController.h>
#import <TTUIWidget/TTIndicatorView.h>
#import <TTUIWidget/TTViewWrapper.h>
#import <TTUIWidget/UIViewController+NavigationBarStyle.h>
#import <TTUIWidget/UIViewController+Refresh_ErrorHandler.h>
#import <TTThemed/TTThemeManager.h>
#import <TTThemed/UIImage+TTThemeExtension.h>

#import <KVOController/KVOController.h>
#import <Crashlytics/Crashlytics.h>

#import "SSWebViewBackTipsButtonView.h"
#import "ArticleTabBarStyleNewsListViewController.h"

#import <TTInteractExitHelper.h>
#import "TTInteractExitHelper.h"
//#import "TTRedPacketManager.h"
#import "TTAuthorizeManager.h"

#import "TTMemoryMonitor.h"
#import "TTArticleDetailMemoryMonitor.h"
#import <TTNetworkUtil.h>
#import "TTKitchenHeader.h"

#import "TTWebImageManager.h"
#import "TTImageView.h"
#import "SSWebViewController.h"
#import "SSCommonLogic.h"
#import "SSCommentInputHeader.h"
#import "TTCommentViewControllerProtocol.h"
#import "TTUGCTrackerHelper.h"
#import <ExploreMomentDefine_Enums.h>
#import "FHTraceEventUtils.h"

//爱看
#import "AKHelper.h"
//#import "Bubble-Swift.h"
#import "FHEnvContext.h"

#define CASE(str)                       if ([__s__ isEqualToString:(str)])
#define SWITCH(s)                       for (NSString *__s__ = (s); ; )
#define DEFAULT
#define kPaddingHeight 15

@interface TTArticleDetailViewController () <TTDetailViewController, TTArticleDetailViewDelegate, TTCommentDataSource, TTCommentViewControllerDelegate, TTCommentWriteManagerDelegate, TTDetailNatantContainerDatasource, TTAdDetailContainerViewDelegate, TTModalContainerDelegate,TTInteractExitProtocol, TTAccountMulticastProtocol>
{
    BOOL _backButtonTouched;
    BOOL _closeButtonTouched;
    BOOL _hasCleanPreviousVCIfNeed;
    //进入详情页点击评论按钮导致的浮层scroll，不发送浮层item的show事件（不认为是用户主动scroll的）
    BOOL _isScrollingTriggeredByCommentButtonClicked;
    BOOL _webViewWillChangeFontSize;
    BOOL _hasSendEnterCommentTrack;
    BOOL _hasSendFinishCommentTrack;
    BOOL _hasSendReadContentTrack;
    BOOL _hasSendFinishContentTrack;
}

@property(nonatomic, strong) TTViewWrapper *wrapperView;
@property(nonatomic, strong) TTCommentViewController *commentViewController;
@property(nonatomic, strong) TTImageView *logoTitleView;
@property(nonatomic, strong) TTArticleDetailNavigationTitleView *titleView;
@property(nonatomic, strong) ExploreDetailToolbarView *toolbarView;
@property(nonatomic, strong) TTCommentWriteView *commentWriteView;
@property(nonatomic, strong) TTDetailNatantContainerView *natantContainerView;
@property(nonatomic, strong) SSWebViewBackButtonView *backButtonView;
@property(nonatomic, strong) TTAlphaThemedButton *rightBarButtonItemView;
@property(nonatomic, strong) TTFollowThemeButton *rightFollowButton;
@property(nonatomic, strong) TTArticleStoryToolView *storyToolView;

@property(nonatomic, strong) TTArticleDetailNatantViewModel *natantViewModel;
@property(nonatomic, strong) TTNovelRecordManager *novelManager;

@property(nonatomic, assign) CGFloat enterHalfFooterStatusContentOffset;

@property(nonatomic, assign) BOOL detailKVOHasAdd;
// staypage统计
@property(nonatomic, assign) BOOL hasDidAppeared;
@property(nonatomic, assign) BOOL isAppearing;
// 记录弹起浮层前titleView的显示状态
@property(nonatomic, assign) BOOL wasTitleViewShowed;
// 重新加载
@property(nonatomic, assign) BOOL hasReload;
@property (nonatomic, strong) TTArticleDetailMenuController *detailMenuController;

@property (nonatomic, assign) BOOL beginShowComment;
@property (nonatomic, assign) BOOL shouldShowTipsOnNavBar;
@property (nonatomic, assign) BOOL showTipsOnNavBarChecked;
@property (nonatomic, assign) BOOL showTipsViewWillAppearChecked;
@property (nonatomic, copy) NSString *parentPageCategoryID;
@property (nonatomic, assign) BOOL willGoBackFromNav;

@property (nonatomic, assign) BOOL hasTrackRedPacketShowEvent;

//记录下viewWillAppear时的内存值，与viewWillDisappear时对比
@property (nonatomic, assign) CGFloat memoryOnViewWillAppear;

@property (nonatomic,assign) double commentShowTimeTotal;
@property (nonatomic,strong) NSDate *commentShowDate;

//懂车帝拓展业务
@property (nonatomic, assign) BOOL shouldShowLogoView;
@property (nonatomic, assign) BOOL isCarPage;
@property (nonatomic, assign) BOOL logoDownloadFinished;

@end

@implementation TTArticleDetailViewController

@synthesize shouldShowNavigationBar;
@synthesize leftBarButton;
@synthesize rightBarButtons;
@synthesize dataSource;
@synthesize delegate;

#pragma mark - init
- (instancetype)initWithDetailViewModel:(TTDetailModel *)model
{
    //create detailView
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        _detailModel = model;
        _novelManager = [[TTNovelRecordManager alloc] initWithArticle:model.article];
        [self p_addObservers];
    }
    return self;
}

- (void)detailContainerViewController:(SSViewControllerBase *)container reloadData:(TTDetailModel *)detailModel
{
    NSDictionary *params = detailModel.baseCondition;
    
    _detailModel = detailModel;
    self.beginShowComment = [params tt_boolValueForKey:@"showcomment"];
    [self p_buildViews];
    //[self.detailView tt_startLoadWebViewContent];
    [self p_updateNavigationTitleView];
    
    [self.detailView tt_initializeServerRequestMonitorWithName:@"detail_info_load"];
    [self p_startLoadArticleInfo];
    [self.detailModel.sharedDetailManager startStayTracker];
    self.isCarPage = [detailModel.article.navTitleType isEqualToString:@"dongchedi"];
    if (self.isCarPage) {
        //先判断category 防止提前进入setter
        self.shouldShowLogoView = [SSCommonLogic articleTitleLogoEnable];
        if (self.shouldShowLogoView) {
            if (!isEmptyString(detailModel.article.navTitleUrl) && !isEmptyString(detailModel.article.navTitleNightUrl)) {
                self.shouldShowLogoView = YES;
            } else {
                self.shouldShowLogoView = NO;
            }
        }
    } else {
        self.shouldShowLogoView = NO;
    }
    self.hasReload = YES;
}

- (void)detailContainerViewController:(nullable SSViewControllerBase *)container loadContentFailed:(nullable NSError *)error{
    [self tt_endUpdataData];
}
#pragma mark - life circle

- (void)dealloc
{
    TLS_LOG(@"dealloc with groupID %lld , adID:%lld", self.detailModel.article.uniqueID, self.detailModel.adID.longLongValue);
    [[UIMenuController sharedMenuController] setMenuItems:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [TTAccount removeMulticastDelegate:self];
    [self p_removeDetailViewKVO];
    [self p_sendDetailDeallocTrack];
    [self p_sendDetailLoadTimeOffLeaveTrack];
    [self report_dealloc];
    
    if (_detailModel.adID.longLongValue > 0) {
        [[TTAdWebResPreloadManager sharedManager] stopCaptureAdWebResRequest];
    }
    
    NSInteger pushTipsEnabled = 0, showTipsOnNavBar = 0;
    if ([SSCommonLogic detailPushTipsEnable]) {
        pushTipsEnabled = 1;
    }
    if (self.shouldShowTipsOnNavBar) {
        showTipsOnNavBar = 1;
    }
    if ([self isFromPushAndOtherApp]) {
        //[TTTrackerWrapper eventV3:@"push_page_back_to_feed" params:@{@"value":@(1), @"is_show_count":@(showTipsOnNavBar), @"push_tips_enable":@(pushTipsEnabled)}];
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [dict setValue:self.detailModel.rid forKey:@"rule_id"];
        [dict setValue:self.detailModel.originalGroupID forKey:@"group_id"];
        [dict setValue:@"article" forKey:@"message_type"];
        [TTTracker eventV3:@"push_page_back_to_feed" params:[dict copy]];
    }
    
    if (self.shouldShowTipsOnNavBar) {
        NSInteger backToFeedValue = 0;
        NSString *backButtonName = @"gesture";
        if (self.willGoBackFromNav) {
            backButtonName = @"back_button";
        }
        
        if ([self.parentPageCategoryID isEqualToString:@"__all__"]) {
            backToFeedValue = 1;
        }
        
        [TTTrackerWrapper eventV3:@"push_back" params:@{@"value":@(1), @"back_button_name":backButtonName, @"back_to_feed":@(backToFeedValue)}];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (_detailModel.isArticleReliable) {
        [self detailContainerViewController:nil reloadData:_detailModel];
    }
    
    wrapperTrackEvent(@"detail", @"enter");
    [self p_sendGoDetailTrack];
    
    TLS_LOG(@"TTArticleDetailViewController viewDidLoad with groupID %lld, adID:%lld", self.detailModel.article.uniqueID, self.detailModel.adID.longLongValue);
    
    [self p_setupMenuItems];
    if (_detailModel.adID.longLongValue > 0) {
        [[TTAdWebResPreloadManager sharedManager] startCaptureAdWebResRequest];
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(themeChanged:) name:TTThemeManagerThemeModeChangedNotification object:nil];
    [self ak_checkNeedReadBonus];
    [self ak_createCountDownTimer];
}

- (BOOL)shouldShowTipsOnNavBar
{
    if (![SSCommonLogic detailPushTipsEnable]) {
        return NO;
    }
    
    if ([self isFromPushAndOtherApp] && !self.showTipsOnNavBarChecked && self.detailModel.article.articleType == ArticleTypeNativeContent) {
        NSArray *vcArray = self.navigationController.viewControllers;
        if (vcArray.count > 1) {
            NSInteger index = 0;
            UIViewController *vc = [vcArray objectAtIndex:index];
            if ([vc isKindOfClass:[ArticleTabBarStyleNewsListViewController class]]) {
                ArticleTabBarStyleNewsListViewController *articleVC = (ArticleTabBarStyleNewsListViewController *)vc;
                TTExploreMainViewController *mainVC = articleVC.mainVC;
                TTCategory *currentSelectedCategory = mainVC.categorySelectorView.currentSelectedCategory;
                _parentPageCategoryID = currentSelectedCategory.categoryID;
                if (!_parentPageCategoryID) {
                    _parentPageCategoryID = @"__all__";
                }
                
                [[NewsListLogicManager shareManager] fetchReloadTipWithMinBehotTime:[NewsListLogicManager listLastReloadTimeForCategory:_parentPageCategoryID] categoryID:_parentPageCategoryID count:ListDataDefaultRemoteNormalLoadCount];
            }
        }
        
        if (!_parentPageCategoryID) {
            _parentPageCategoryID = @" ";
        }
        
        _shouldShowTipsOnNavBar = YES;
        self.showTipsOnNavBarChecked = YES;
    }
    
    return _shouldShowTipsOnNavBar;
}

- (BOOL)isFromPushAndOtherApp
{
    return _detailModel.fromSource == NewsGoDetailFromSourceAPNS || _detailModel.fromSource == NewsGoDetailFromSourceOtherApp;
}

- (void)goBack
{
    self.willGoBackFromNav = YES;
    [self.parentViewController.navigationController popViewControllerAnimated:YES];
}

- (void)receiveShowRemoteReloadTipNotification:(NSNotification *)notification
{
    NSUInteger count = [[[notification userInfo] objectForKey:@"count"] integerValue];
    if ([self.backButtonView isKindOfClass:[SSWebViewBackTipsButtonView class]]) {
        SSWebViewBackTipsButtonView *backTipsButtonView = (SSWebViewBackTipsButtonView *)self.backButtonView;
        if ([backTipsButtonView getBadgeNumber] == 0) {
            [backTipsButtonView setTipsCount:count];
        }
    }
}

- (void)viewWillAppear:(BOOL)animated {
    TLS_LOG(@"viewWillAppear with groupID %lld, adID:%lld", self.detailModel.article.uniqueID, self.detailModel.adID.longLongValue);
    [super viewWillAppear:animated];
    
    self.memoryOnViewWillAppear = [TTMemoryMonitor currentMemoryUsageByAppleFormula];
    
    if (self.shouldShowTipsOnNavBar && !self.showTipsViewWillAppearChecked) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveShowRemoteReloadTipNotification:) name:kNewsListFetchedRemoteReloadItemCountNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveShowRemoteReloadTipNotification:) name:kNewsListFetchedRemoteReloadTipNotification object:nil];
        UITapGestureRecognizer *singleFingerTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(goBack)];
        SSWebViewBackTipsButtonView *backTipsButtonView = (SSWebViewBackTipsButtonView *)self.leftBarButton;
        backTipsButtonView.tipLabel.userInteractionEnabled = YES;
        [backTipsButtonView.tipLabel addGestureRecognizer:singleFingerTap];
        [backTipsButtonView setTipsCount:0];
        
        self.showTipsViewWillAppearChecked = YES;
        self.titleView.hidden = YES;
        if (self.parentPageCategoryID) {
            [NewsListLogicManager setNewsListShowRefreshInfo:@{self.parentPageCategoryID : @(YES)}];
        }
    }
}

- (void)viewDidAppear:(BOOL)animated {
    TLS_LOG(@"viewDidAppear with groupID %lld, adID:%lld", self.detailModel.article.uniqueID, self.detailModel.adID.longLongValue);
    [super viewDidAppear:animated];
    [_detailView didAppear];
    
    // 第一次进入是在内容加载完成后才开始记录staypage时间，push到其他页面时停止记录staypage，返回时重新开始记录
    if (_hasDidAppeared) {
        [self.detailModel.sharedDetailManager startStayTracker];
    }
    if (self.natantContainerView.contentOffsetWhenLeave!=NSNotFound) {
        [self.natantContainerView checkVisibleAtContentOffset:self.natantContainerView.contentOffsetWhenLeave referViewHeight:self.commentViewController.view.frame.size.height];
    }
    _hasDidAppeared = YES;
    _isAppearing = YES;
    //    self.rightFollowButton.followed = [self.detailModel.article.mediaInfo tt_boolValueForKey:@"subcribed"];
    //强制显示statusbar
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    
    if (self.shouldShowTipsOnNavBar) {
        NSArray *vcArray = self.navigationController.viewControllers;
        if (vcArray.count > 2) {
            NSMutableArray *ary = [NSMutableArray new];
            UIViewController *vc1 = vcArray[0];
            UIViewController *vc2 = vcArray[vcArray.count - 2];
            
            if ([vc1 isKindOfClass:[ArticleTabBarStyleNewsListViewController class]] && [vc2 isKindOfClass:[TTDetailContainerViewController class]]) {
                ArticleTabBarStyleNewsListViewController *articleVC = (ArticleTabBarStyleNewsListViewController *)vc1;
                TTExploreMainViewController *mainVC = articleVC.mainVC;
                TTCategory *currentSelectedCategory = mainVC.categorySelectorView.currentSelectedCategory;
                if ([currentSelectedCategory.categoryID isEqualToString:@"__all__"]) {
                    TTDetailContainerViewController *detailContainerVC = (TTDetailContainerViewController *)vc2;
                    UIViewController *vc = detailContainerVC.detailViewController;
                    if ([vc isKindOfClass:[TTArticleDetailViewController class]]) {
                        [ary addObject:vcArray[0]];
                        [ary addObject:[vcArray lastObject]];
                        self.navigationController.viewControllers = ary;
                    }
                }
            }
        }
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            SSWebViewBackTipsButtonView *backTipsButtonView = (SSWebViewBackTipsButtonView *)self.leftBarButton;
            if ([backTipsButtonView getBadgeNumber] == 0) {
                [backTipsButtonView setTipsCount:8];
            }
        });
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    TLS_LOG(@"viewWillDisappear with groupID %lld, adID:%lld", self.detailModel.article.uniqueID, self.detailModel.adID.longLongValue);
    
    CGFloat currentMemory = [TTMemoryMonitor currentMemoryUsageByAppleFormula];
    CGFloat memory_growth = currentMemory - self.memoryOnViewWillAppear;
    [TTArticleDetailMemoryMonitor monitorMemoryGrowth:memory_growth forGroupID:self.detailModel.article.uniqueID title:self.detailModel.article.title];
    
    [super viewWillDisappear:animated];
    
    [self.commentWriteView dismissAnimated:YES];
    
    //    self.writeCommentView.delegate = nil;  //需要delegate来接收评论发布的回调 @zengruihuan
}

- (void)viewDidDisappear:(BOOL)animated
{
    TLS_LOG(@"viewDidDisappear with groupID %lld, adID:%lld", self.detailModel.article.uniqueID, self.detailModel.adID.longLongValue);
    [super viewDidDisappear:animated];
    
    if (self.commentShowDate) {
        NSTimeInterval timeInterval = [[NSDate date] timeIntervalSinceDate:self.commentShowDate];
        self.commentShowTimeTotal += timeInterval*1000;
        self.commentShowDate = nil;
    }
    
    [_detailView didDisappear];
    NSDictionary *commentDic = @{@"stay_comment_time":[[NSNumber numberWithDouble:round(self.commentShowTimeTotal)] stringValue]};
    [self.detailModel.sharedDetailManager extraTrackerDic:commentDic];
    [self.detailModel.sharedDetailManager endStayTracker];
    _isAppearing = NO;
    [self.natantContainerView resetAllRelatedItemsWhenNatantDisappear];
    [[NSNotificationCenter defaultCenter] postNotificationName:kDetailVideoADDisappearNotification object:nil];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    if ([TTDeviceHelper isPadDevice]) {
        CGFloat natantWidth = [TTUIResponderHelper splitViewFrameForView:self.view].size.width;
        //self.natantContainerView.frame = CGRectMake(0, 0, natantWidth, 0);
        self.natantContainerView.width = natantWidth;
        [self.natantContainerView.items enumerateObjectsUsingBlock:^(TTDetailNatantViewBase * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            TTDetailNatantViewBase * natantViewItem = (TTDetailNatantViewBase *)obj;
            natantViewItem.width = natantWidth-30;
        }];
        self.commentViewController.commentTableView.tableHeaderView = self.natantContainerView;
        self.detailView.frame = [self p_frameForDetailView];
        self.toolbarView.frame = [self p_frameForToolBarView];
    }
}

#pragma mark UIMenuController Delegate

- (void)p_setupMenuItems {
    
    UIMenuItem *typosMenuItem = [[UIMenuItem alloc] initWithTitle:@"举报错别字" action:@selector(selectedTypos:)];
    UIMenuItem *customMenuItem1 = [[UIMenuItem alloc] initWithTitle:@"搜索" action:@selector(searchSelectionText:)];
    [[UIMenuController sharedMenuController] setMenuItems:[NSArray arrayWithObjects:typosMenuItem, customMenuItem1, nil]];
    
    [self.detailView.detailWebView.webView tt_becomeFirstResponder];
}

- (void)menControllerDidShow {
    NSMutableDictionary *extra = [[NSMutableDictionary alloc] init];
    [extra setValue:self.detailModel.article.itemID forKey:@"item_id"];
    [extra setValue:@"article" forKey:@"group_type"];
    [extra setValue:@"detail_long_press" forKey:@"position"];
    if (!isEmptyString(self.detailModel.orderedData.ad_id)) {
        [extra setValue:self.detailModel.orderedData.ad_id forKey:@"aid"];
    }
    wrapperTrackEventWithCustomKeys(@"detail", @"long_press", self.detailModel.article.groupModel.groupID, self.detailModel.clickLabel, extra);
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {
    if (self.detailView.detailWebView.webView != nil) {
        if (action == @selector(searchSelectionText:) || action == @selector(selectedTypos:)) {
            return YES;
        }
    }
    return [super canPerformAction:action withSender:sender];
}

- (void)selectedTypos:(id)sender {
    //0为转码页，1为导流页
    if (self.detailModel.article.articleType == ArticleTypeNativeContent) {
        [self.detailView.detailWebView.webView ttr_fireEvent:@"menuItemPress" data:nil];
    }
    else {
        [self tt_articleDetailViewTypos:@[@"", [self selectedText], @""]];
    }
}

- (NSString *)selectedText {
    return [self.detailView.detailWebView.webView stringByEvaluatingJavaScriptFromString:@"window.getSelection().toString()" completionHandler:nil];
}
- (void)searchSelectionText:(id)sender {
    
    //NSLog(@"%@",[self selectedText]);
    ExploreSearchViewController * searchController = [[ExploreSearchViewController alloc] initWithNavigationBar:YES showBackButton:YES queryStr:[self selectedText] fromType:ListDataSearchFromTypeWebViewMenuItem];
    searchController.groupID = @(self.detailModel.article.uniqueID);
    
    UINavigationController * rootController = [TTUIResponderHelper topNavigationControllerFor: self];
    [rootController pushViewController:searchController animated:YES];
    
    NSMutableDictionary *extra = [[NSMutableDictionary alloc] init];
    [extra setValue:self.detailModel.article.itemID forKey:@"item_id"];
    [extra setValue:@"article" forKey:@"group_type"];
    [extra setValue:@"detail_long_press" forKey:@"position"];
    if (!isEmptyString(self.detailModel.orderedData.ad_id)) {
        [extra setValue:self.detailModel.orderedData.ad_id forKey:@"aid"];
    }
    wrapperTrackEventWithCustomKeys(@"detail", @"search_click", self.detailModel.article.groupModel.groupID, self.detailModel.clickLabel, extra);
}
#pragma mark - setter
-(void)setShouldShowLogoView:(BOOL)shouldShowLogoView {
    _shouldShowLogoView = shouldShowLogoView;
    if (self.isCarPage) {
        [self p_refreshLogoView];
    }
}

#pragma mark - private
- (void)p_refreshLogoView {
    if (!self.logoTitleView && self.shouldShowLogoView) {
        [self p_buildLogoTitleView];
        if (self.titleView) {
            [self p_showTitle:self.titleView.isShow];
        }
    }
}

- (void)themeChanged:(NSNotification *)notification {
    if (self.shouldShowLogoView && [[TTThemeManager sharedInstance_tt] currentThemeMode] == TTThemeModeNight) {
        [self.logoTitleView setImageWithURLString:self.detailModel.article.navTitleNightUrl];
    } else {
        [self.logoTitleView setImageWithURLString:self.detailModel.article.navTitleUrl];
    }
}

- (void)p_buildViews
{
    [self p_buildDetailView];
    [self p_buildDetailNatant];
    [self p_buildToolbarViewIfNeeded];
    [self p_buildStoryToolView];
    [self p_setDetailViewBars];
    [self p_buildNaviBar];
}

- (void)p_buildDetailView
{
    
    self.detailView = [[TTArticleDetailView alloc] initWithFrame:[self p_frameForDetailView] detailModel:self.detailModel];
    
    self.detailView.delegate = self;
    if ([SSCommonLogic detailNewLayoutEnabled]) {
        self.detailView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    } else {
        self.detailView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    }
    
    
    if ([TTDeviceHelper isPadDevice]) {
        self.wrapperView = [[TTViewWrapper alloc] initWithFrame:self.view.bounds];
        [self.wrapperView addSubview:self.detailView];
        self.wrapperView.targetView = self.detailView;
        [self.view addSubview:self.wrapperView];
    }
    else {
        [self.view addSubview:self.detailView];
    }
    
    [_detailView willAppear];
    
    [self p_addDetailViewKVO];
    
    //必须becomeFR 否则第一次长按不出pop-out
    [self.detailView.detailWebView.webView tt_becomeFirstResponder];
    
    [self p_updateNavigationTitleViewWithScrollViewContentOffset:0];
}

- (void)p_buildDetailNatant
{
    if ([self.detailModel.article.articleDeleted boolValue]) {
        return;
    }
    
    [self p_buildCommentViewController];
    
    
    
    //有ToolBar时才创建_detailView浮层
    if ([self p_needShowToolBarView]) {
        [self p_buildNatantView];
    }
    //添加浮层到转码页组件TTDetailWebContainerView
    [self.detailView tt_setNatantWithFooterView:self.commentViewController.view
                      includingFooterScrollView:[self.commentViewController commentTableView]];
}

- (void)p_buildStoryToolView {
    self.storyToolView = [[TTArticleStoryToolView alloc] initWithWidth:self.detailView.width article:self.detailModel.article];
}

- (void)p_buildLogoTitleView {
    if (self.logoTitleView) return;
    
    NSString *logoUrl = [[TTThemeManager sharedInstance_tt] currentThemeMode] == TTThemeModeNight ? self.detailModel.article.navTitleNightUrl : self.detailModel.article.navTitleUrl;
    if (logoUrl) {
        self.logoTitleView = [[TTImageView alloc] initWithFrame:CGRectMake(0, 0, [self frameSizeWithSize:54.f], [self frameSizeWithSize:28.f])];
        self.logoTitleView.imageContentMode = UIViewContentModeScaleToFill;
        self.logoTitleView.enableNightCover = NO;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onLogoTitleViewClick)];
        [self.logoTitleView addGestureRecognizer:tap];
        self.logoTitleView.userInteractionEnabled = YES;
        [self.logoTitleView setImageWithURLString:logoUrl];
    }
}

- (void)p_buildTitleView
{
    self.titleView = [[TTArticleDetailNavigationTitleView alloc] initWithFrame:CGRectZero];
    if (self.shouldShowLogoView) {
        [self p_buildLogoTitleView];
        if (self.logoTitleView) {
            self.navigationItem.titleView = self.logoTitleView;
            [self p_sendLogoViewEventWithEventName:@"logo_show"];
        } else {
            self.navigationItem.titleView = self.titleView;
            self.shouldShowLogoView = NO;
        }
    } else {
        self.navigationItem.titleView = self.titleView;
    }
    // 点击跳转到pgc主页
    __weak typeof(self) wself = self;
    [self.titleView setTapHandler:^{
        if ([wself.detailModel.article.articleDeleted boolValue]) {
            return;
        }
        
        if (wself.detailModel.article.mediaInfo[@"media_id"]) {
            NSMutableDictionary *extra = [NSMutableDictionary dictionary];
            [extra setValue:wself.detailModel.article.itemID forKey:@"item_id"];
            
            [TTTrackerWrapper event:@"detail" label:@"click_titlebar_pgc" value:wself.detailModel.article.mediaInfo[@"media_id"] extValue:wself.detailModel.adID extValue2:nil dict:extra];
            
            NSString *enterItemId = wself.detailModel.article.groupModel.itemID;
            NSString *mediaID = [NSString stringWithFormat:@"%@", wself.detailModel.article.mediaInfo[@"media_id"]];
            
            NSString *enterSource = @"article_top_titlebar";
            NSMutableString *linkURLString = [NSMutableString stringWithFormat:@"sslocal://media_account?media_id=%@&source=%@&itemt_id=%@", mediaID, enterSource, enterItemId];
            [[TTRoute sharedRoute] openURLByPushViewController:[TTNetworkUtil URLWithURLString:[TTUGCTrackerHelper schemaTrackForPersonalHomeSchema:linkURLString categoryName:wself.detailModel.categoryID fromPage:@"detail_article" groupId:wself.detailModel.article.groupModel.groupID profileUserId:nil]]];
        }
    }];
    [self p_updateNavigationTitleView];
}

- (void)p_buildNaviBar {
    if ([[self.detailModel.article articleDeleted] boolValue]) {
        self.navigationItem.rightBarButtonItems = nil;
        return;
    }
    NSMutableArray *buttons = [[NSMutableArray alloc] init];
    TTDetailArchType detailArchType = [self.detailView.detailViewModel tt_articleDetailType];
    BOOL shouldShowMoreButton = (detailArchType != TTDetailArchTypeNotAssign);
    if(shouldShowMoreButton) {
        _rightBarButtonItemView = [self p_generateBarButtonWithImageName:@"new_more_titlebar"];
        [_rightBarButtonItemView addTarget:self action:@selector(p_showMorePanel) forControlEvents:UIControlEventTouchUpInside];
        
        SSThemedView *view = [[SSThemedView alloc] initWithFrame:CGRectMake(0, 0, self.rightFollowButton.width + [TTDeviceUIUtils tt_newPadding:16], self.rightFollowButton.height)];
        self.rightFollowButton.centerX = view.width / 2;
        if (!self.shouldShowTipsOnNavBar) {
            [view addSubview:self.rightFollowButton];
        }
        
        [buttons addObject:[[UIBarButtonItem alloc] initWithCustomView:_rightBarButtonItemView]];
        if (![[TTAccountManager userID] isEqualToString:[self.detailModel.article.userInfo tt_stringValueForKey:@"user_id"]]) {
            [buttons addObject:[[UIBarButtonItem alloc] initWithCustomView:view]];
        }
        
        
    }
    
    self.navigationItem.rightBarButtonItems = buttons;
    
    if (self.shouldShowTipsOnNavBar) {
        self.backButtonView = (SSWebViewBackButtonView *)self.leftBarButton;
        [self.backButtonView.backButton addTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
        [self.backButtonView.closeButton addTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
    } else {
        if (!self.backButtonView) {
            self.backButtonView = [[SSWebViewBackButtonView alloc] init];
        }
        [self.backButtonView.backButton addTarget:self action:@selector(leftBarButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self.backButtonView.closeButton addTarget:self action:@selector(leftBarButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self.backButtonView showCloseButton:NO];
    }
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.backButtonView];
    
}

- (CGFloat)frameSizeWithSize: (CGFloat)size {
    if([TTDeviceHelper is568Screen] || [TTDeviceHelper is480Screen]){//4/4s/5/s
        return size * 0.9;
    } else {
        return size;
    }
}


- (void)p_cleanArticleDetailViewControllersInNavIfNeed
{
    if (_hasCleanPreviousVCIfNeed) {
        return;
    }
    
    _hasCleanPreviousVCIfNeed = YES;
    
    //只对小说做此优化
    if (!self.detailModel.article.novelData && !self.detailModel.needQuickExit) {
        return;
    }
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 8.0) {
        return;
    }
    
    NSArray *reverseViewControllers = [[[self.navigationController viewControllers] reverseObjectEnumerator] allObjects];
    NSMutableArray *mutableReverse = reverseViewControllers.mutableCopy;
    
    if (reverseViewControllers.count <= 1) {
        return;
    }
    
    UIViewController *previousVC = reverseViewControllers[1];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    if (![previousVC isKindOfClass:NSClassFromString(@"TTDetailContainerViewController")] || ![previousVC respondsToSelector:NSSelectorFromString(@"detailViewController")]) {
        return;
    }
    
    TTArticleDetailViewController *previousDetailVC = (TTArticleDetailViewController *)[previousVC performSelector:NSSelectorFromString(@"detailViewController")];
#pragma clang diagnostic pop
    if (![previousDetailVC isKindOfClass:self.class] || [previousDetailVC isEqual:self]) {
        return;
    }
    
    //当前是小说 但是 上一层不是小说时.. 根据needQuickExit来判断
    if (self.detailModel.article.novelData && ![previousDetailVC.detailView tt_isNovelArticle] && !self.detailModel.needQuickExit) {
        return;
    }
    
    [mutableReverse removeObject:previousVC];
    
    NSArray *normalViewControllers = [[mutableReverse reverseObjectEnumerator] allObjects];
    [self.navigationController setViewControllers:normalViewControllers animated:YES];
}
#pragma mark -

- (void)didMoveToParentViewController:(UIViewController *)parent
{
    [super didMoveToParentViewController:parent];
    if (parent) {
        [self p_buildTitleView];
        [self p_showTitle:self.wasTitleViewShowed];
        //清理nav栈，防止内存爆掉
        [self p_cleanArticleDetailViewControllersInNavIfNeed];
    }
}

- (void)p_updateStoryToolViewWithOffset:(CGFloat)offsetY
{
    if (!_isScrollingTriggeredByCommentButtonClicked && !_webViewWillChangeFontSize) {
        if (offsetY > self.detailView.storyToolViewAnimationTriggerPosY) {
            [self p_triggerStoryToolViewAnimation:YES];
        }
        else {
            [self p_triggerStoryToolViewAnimation:NO];
        }
    }
}


- (void)p_updateNavigationTitleViewInfo {
    if (self.detailModel.article.mediaInfo[@"media_id"]) {
        if ([SSCommonLogic articleNavBarShowFansNumEnable] && self.titleView.type == TTArticleDetailNavigationTitleViewTypeDefault){
            self.titleView.type = TTArticleDetailNavigationTitleViewTypeShowFans;
        }
        NSString *name = self.detailModel.article.mediaInfo[@"name"];
        NSString *userAuthInfo = [self.detailModel.article.userInfo tt_stringValueForKey:@"user_auth_info"];
        NSInteger fansNum = [self.detailModel.article.userInfo tt_integerValueForKey:@"fans_count"];
        if (isEmptyString(userAuthInfo)) userAuthInfo = [self.detailModel.article.mediaInfo tt_stringValueForKey:@"user_auth_info"];
        if (!isEmptyString(name)) {
            [self.titleView updateNavigationTitle:name imageURL:self.detailModel.article.mediaInfo[@"avatar_url"] verifyInfo:userAuthInfo decoratorURL:self.detailModel.article.userDecoration fansNum:fansNum];
        }
        if ([self.detailModel.article.mediaInfo objectForKey:@"subcribed"]) {
            self.rightFollowButton.followed = [self.detailModel.article.mediaInfo tt_boolValueForKey:@"subcribed"];
        }
        else {
            self.rightFollowButton.followed = [[ExploreEntryManager sharedManager] isSubscribedForMediaID:self.detailModel.article.mediaUserID];
        }
    }
}

- (void)p_updateNavigationTitleView
{
    if (self.shouldShowTipsOnNavBar) {
        [self p_hideTitleView];
    }
    
    if ([self.detailView.detailViewModel tt_articleDetailLoadedContentType] != ArticleTypeNativeContent) {
        if ([SSCommonLogic articleNavBarShowFansNumEnable]){
            if (self.titleView.type == TTArticleDetailNavigationTitleViewTypeDefault){
                self.titleView.type = TTArticleDetailNavigationTitleViewTypeFollowLeft;
            }
        }else{
            self.titleView.type = TTArticleDetailNavigationTitleViewTypeFollow;
        }
        if ([TTDeviceHelper is568Screen] || [TTDeviceHelper is480Screen]) {
            self.titleView.hidden = YES;
            self.rightFollowButton.hidden = YES;
        }
    }
    
    if ([self.detailView.detailViewModel tt_articleDetailLoadedContentType] != ArticleTypeNativeContent && !SSIsEmptyDictionary(self.detailModel.article.mediaInfo) && self.detailModel.article.mediaInfo[@"media_id"]) {
        if ([SSCommonLogic articleNavBarShowFansNumEnable]){
            if (self.titleView.type == TTArticleDetailNavigationTitleViewTypeDefault){
                self.titleView.type = TTArticleDetailNavigationTitleViewTypeFollowLeft;
            }
        }else{
            self.titleView.type = TTArticleDetailNavigationTitleViewTypeFollow;
        }
        if ([TTDeviceHelper is568Screen] || [TTDeviceHelper is480Screen]) {
            //针对小屏手机设置
            self.titleView.centerX = 124;
            if (!self.shouldShowTipsOnNavBar) {
                self.titleView.hidden = NO;
            }
            self.rightFollowButton.hidden = YES;
        }
        
        if ([self.detailModel.article.mediaInfo objectForKey:@"subcribed"]) {
            self.rightFollowButton.followed = [self.detailModel.article.mediaInfo tt_boolValueForKey:@"subcribed"];
        }
        else {
            self.rightFollowButton.followed = [[ExploreEntryManager sharedManager] isSubscribedForMediaID:self.detailModel.article.mediaUserID];
        }
    }
    
    [self p_updateNavigationTitleViewInfo];
    // self.rightFollowButton.hidden = self.titleView.isShow ? NO : YES; //F项目隐藏关注
    self.rightFollowButton.hidden = YES; //F项目隐藏关注
    [self p_updateRightFollowButton];
}
- (void)p_hideTitleView {
    self.titleView.hidden = YES;
    if (self.logoTitleView) {
        self.logoTitleView.hidden = YES;
    }
}

- (void)p_updateRightFollowButton {
    CGPoint followButtonCenter = self.rightFollowButton.center;
//    if (self.articleInfoManager.activity.redpack) {
//        if (!self.hasTrackRedPacketShowEvent) {
//            self.hasTrackRedPacketShowEvent = YES;
//            NSMutableDictionary * showEventExtraDic  = [NSMutableDictionary dictionary];
//            [showEventExtraDic setValue:self.articleInfoManager.activity.redpack.user_info.user_id
//                                 forKey:@"user_id"];
//            [showEventExtraDic setValue:@"show"
//                                 forKey:@"action_type"];
//            [showEventExtraDic setValue:self.detailModel.categoryID
//                                 forKey:@"category_name"];
//            [showEventExtraDic setValue:@"article_detail"
//                                 forKey:@"show"];
//            [TTTrackerWrapper eventV3:@"red_button" params:showEventExtraDic];
//
//        }
//        self.rightFollowButton.unfollowedType = [TTFollowThemeButton redpacketButtonUnfollowTypeButtonStyle:self.articleInfoManager.activity.redpack.button_style.integerValue defaultType:TTUnfollowedType201];
//    }else {
        self.rightFollowButton.unfollowedType = TTUnfollowedType101;
//    }
    CGFloat width = self.rightFollowButton.width;
    [self.rightFollowButton refreshUI];
    if (width > self.rightFollowButton.width) {
        self.rightFollowButton.constWidth = kRedPacketFollowButtonWidth();
        [self.rightFollowButton refreshUI];
    }
    self.rightFollowButton.center = followButtonCenter;
}

- (void)p_updateTopSubscribe:(NSNotification *)notification {
    ExploreEntry *entry = [[notification userInfo] objectForKey:kEntrySubscribeStatusChangedNotificationUserInfoEntryKey];
    NSString *mediaID = [entry.mediaID stringValue];
    if ([mediaID isEqualToString:[self.detailModel.article.mediaInfo tt_stringValueForKey:@"media_id"]]) {
        NSMutableDictionary *mediaInfo = [self.detailModel.article.mediaInfo mutableCopy];
        [mediaInfo setValue:entry.subscribed forKey:@"subcribed"];
        BOOL preFollowStatus = [self.detailModel.article.userInfo tt_boolValueForKey:@"follow"];
        BOOL currentFollowStatus = entry.subscribed.boolValue;
        self.detailModel.article.mediaInfo = [mediaInfo copy];
        if (preFollowStatus != currentFollowStatus){
            NSMutableDictionary *userInfo = [self.detailModel.article.userInfo mutableCopy];
            long long fansCount = [userInfo tt_longlongValueForKey:@"fans_count"];
            if (currentFollowStatus){
                fansCount += 1;
            }else{
                fansCount -= 1;
            }
            [userInfo setValue:@(fansCount) forKey:@"fans_count"];
            self.detailModel.article.userInfo = userInfo;
        }
        [self.detailModel.article save];
        self.rightFollowButton.followed = [self.detailModel.article.mediaInfo tt_boolValueForKey:@"subcribed"];
//        if (self.rightFollowButton.followed && self.articleInfoManager.activity.redpack) {
//            self.articleInfoManager.activity.redpack = nil;
//        }
        [self p_updateRightFollowButton];
        [self p_updateNavigationTitleView];
    }
}

- (void)blockNotification:(NSNotification *)notify {
    NSString * userID = notify.userInfo[kBlockedUnblockedUserIDKey];
    if ([userID isEqualToString:[self.detailModel.article.mediaInfo tt_stringValueForKey:@"media_id"]]) {
        NSMutableDictionary *mediaInfo = [self.detailModel.article.mediaInfo mutableCopy];
        [mediaInfo setValue:@(NO) forKey:@"subcribed"];
        self.detailModel.article.mediaInfo = [mediaInfo copy];
        [self.detailModel.article save];
        self.rightFollowButton.followed = [self.detailModel.article.mediaInfo tt_boolValueForKey:@"subcribed"];
//        if (self.rightFollowButton.followed && self.articleInfoManager.activity.redpack) {
//            self.articleInfoManager.activity.redpack = nil;
//        }
        [self p_updateRightFollowButton];
    }
}

- (void)p_updateNavigationTitleViewWithScrollViewContentOffset:(CGFloat)offset
{
    if (self.detailModel.article.articleType != ArticleTypeWebContent && self.titleView.type != TTArticleDetailNavigationTitleViewTypeFollowLeft){
        BOOL hasMediaInfo = self.detailModel.article.mediaInfo[@"media_id"];
        BOOL show = hasMediaInfo && (offset > self.detailView.titleViewAnimationTriggerPosY || self.detailModel.article.articleType == ArticleTypeWebContent);
        [self p_showTitle:show];
        self.wasTitleViewShowed = show;
    } else {
        if (!self.wasTitleViewShowed){
            [self p_showTitle:YES];
            self.wasTitleViewShowed = YES;
        }
        if ([SSCommonLogic articleNavBarShowFansNumEnable]){
            TTArticleDetailNavigationTitleViewType newType = offset > 140 ? TTArticleDetailNavigationTitleViewTypeShowFans :
            TTArticleDetailNavigationTitleViewTypeFollowLeft;
            if (self.titleView.type != newType){
                self.titleView.type = newType;
                [self p_updateNavigationTitleViewInfo];
                self.titleView.alpha = 0;
                [UIView animateWithDuration:.15 animations:^{
                    self.titleView.alpha = 1;
                }];
            }
        }
    }
}

- (void)p_showTitle:(BOOL)show
{
    BOOL hasMediaInfo = self.detailModel.article.mediaInfo[@"media_id"];
    show = show && hasMediaInfo;
    BOOL isShow = self.titleView.isShow;
    BOOL animated = self.detailModel.article.articleType == ArticleTypeNativeContent;
    if (show) {
        if (self.navigationItem.titleView != self.titleView) {
            self.navigationItem.titleView = self.titleView;
        }
    } else {
        if (self.shouldShowLogoView) {
            if (self.navigationItem.titleView != self.logoTitleView) {
                self.navigationItem.titleView = self.logoTitleView;
                [self p_sendLogoViewEventWithEventName:@"logo_show"];
            }
        }
    }
    [self.titleView show:show animated:animated];
    
    // self.rightFollowButton.hidden = !show;
    self.rightFollowButton.hidden = YES;  //F项目隐藏关注按钮

    if (show && !isShow) {
        NSMutableDictionary *params = [NSMutableDictionary dictionary];
        [params setValue:@"top_title_bar" forKey:@"position"];
        [params setValue:@"article_detail" forKey:@"source"];
        [params setValue:self.detailModel.article.mediaUserID forKey:@"user_id"];
        [params setValue:self.detailModel.article.groupModel.groupID forKey:@"group_id"];
        [TTTrackerWrapper eventV3:@"follow_show" params:params];
    }
}

- (void)p_triggerStoryToolViewAnimation:(BOOL)show
{
    if (![self.detailView tt_isNovelArticle]) {
        return;
    }
    if (!self.detailView.storyToolViewAnimationTriggerPosY) {
        return;
    }
    
    if (show) {
        [self.storyToolView showInView:self.detailView animated:YES];
    }
    else {
        [self.storyToolView hideWithAnimated:YES];
    }
}

- (void)p_buildToolbarViewIfNeeded
{
    if ([self.detailModel.fitArticle.articleDeleted boolValue]) {
        return;
    }
    
    if (self.toolbarView || ![self p_needShowToolBarView]) {
        return;
    }
    switch ([self.detailView.detailViewModel tt_articleDetailType]) {
        case TTDetailArchTypeSimple:
        {
            wrapperTrackEvent(@"detail", @"simple_mode");
        }
            break;
        case TTDetailArchTypeNoComment:
        {
            wrapperTrackEvent(@"detail", @"no_comments_mode");
        }
            break;
        case TTDetailArchTypeNoToolBar:
        {
            wrapperTrackEvent(@"detail", @"hide_mode");
        }
            break;
        default:
            break;
    }
    
    //    ExploreDetailToolbarType type = ([self.detailView.detailViewModel tt_articleDetailType] == TTDetailArchTypeNormal) ? ExploreDetailToolbarTypeNormal : ExploreDetailToolbarTypeExcludeCommentButtons;
    
    self.toolbarView = [[ExploreDetailToolbarView alloc] initWithFrame:[self p_frameForToolBarView]];
    
    if ([SSCommonLogic detailNewLayoutEnabled]) {
        self.toolbarView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    }
    
    self.toolbarView.toolbarType = ExploreDetailToolbarTypeArticleComment;
    //    self.toolbarView.backgroundColorThemeKey = kColorBackground4;
    [self.view addSubview:self.toolbarView];
    
    [self.toolbarView.collectButton addTarget:self action:@selector(toolBarButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.toolbarView.writeButton addTarget:self action:@selector(toolBarButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.toolbarView.emojiButton addTarget:self action:@selector(toolBarButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.toolbarView.commentButton addTarget:self action:@selector(toolBarButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.toolbarView.shareButton addTarget:self action:@selector(toolBarButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    self.toolbarView.frame = [self p_frameForToolBarView];
    self.toolbarView.hidden = NO;
    [self p_refreshToolbarView];
}

- (void)p_buildCommentViewController
{
    self.commentViewController = [[TTCommentViewController alloc] initWithViewFrame:[self p_contentVisableRect] dataSource:self delegate:self];
    self.commentViewController.enableImpressionRecording = YES;
    [self.commentViewController willMoveToParentViewController:self];
    [self addChildViewController:self.commentViewController];
    [self.commentViewController didMoveToParentViewController:self];
    
    [self.detailView tt_initializeServerRequestMonitorWithName:@"comment"];
}

- (void)p_buildNatantView
{
    self.natantContainerView = [[TTDetailNatantContainerView alloc] initWithFrame:CGRectMake(0, 0, [TTUIResponderHelper splitViewFrameForView:self.view].size.width, 0)];
    self.natantContainerView.datasource = self;
    self.natantContainerView.sourceType = TTDetailNatantContainerViewSourceType_ArtileDetail;
}

- (void)p_startLoadArticleInfo {
    self.natantViewModel = [[TTArticleDetailNatantViewModel alloc] initWithDetailModel:self.detailModel];
    __weak typeof(self) weakSelf = self;
    NSNumber *oriGroupFlags = self.detailModel.fitArticle.groupFlags;
    TTDetailNatantStyle origNatantStyle = [weakSelf.detailView.detailViewModel tt_natantStyleFromNatantLevel];
    [self.natantViewModel tt_startFetchInformationWithFinishBlock:^(ArticleInfoManager *infoManager, NSError *error) {
        if (!weakSelf) {
            return;
        }
        
        if (!error) {
            [[TTMonitor shareManager] trackService:@"detail_info_status" status:0 extra:nil];
            [weakSelf.detailView tt_serverRequestTimeMonitorWithName:@"detail_info_load" error:nil];
            if (![weakSelf.detailModel.fitArticle.articleDeleted boolValue]) {
//                if ([weakSelf.detailModel.fitArticle.mediaInfo tt_boolValueForKey:@"subcribed"] && infoManager.activity.redpack) {
//                    //如果当前已经关注该作者，那么清空服务端下发的红包，避免取消关注后有红包
//                    infoManager.activity.redpack = nil;
//                }
                //TODO:build natantItems with infoManager
                //add by suruiqiang  我需要把detailModel透传到浮层子view中进行数据刷新和更改
                infoManager.detailModel = weakSelf.detailModel;
                
                [weakSelf.detailView tt_handleDetailViewWithInfoManager:infoManager];
                weakSelf.articleInfoManager = infoManager;
                
                [weakSelf p_reloadItemsWithInforManager:infoManager];
                
                
                // 获取到mediaInfo后更新titleView
                [weakSelf p_updateNavigationTitleView];
                
                //added 5.8+：info接口更新natantLevel，groupFlags等字段后刷新UI
                if (weakSelf.detailModel.fitArticle.groupFlags && ![oriGroupFlags isEqualToNumber:weakSelf.detailModel.fitArticle.groupFlags]) {
                    [weakSelf p_refreshArticleTypeRelevantUIIfNeeded];
                }
                
                TTDetailNatantStyle natantStyle = [weakSelf.detailView.detailViewModel tt_natantStyleFromNatantLevel];
                if (origNatantStyle != natantStyle) {
                    weakSelf.detailView.detailWebView.natantStyle = natantStyle;
                    //                    [weakSelf.detailView.detailWebView removeDivFromWebViewIfNeeded];
                    //                    [weakSelf.detailView.detailWebView insertDivToWebViewIfNeed];
                    weakSelf.detailView.detailWebView.webView.scrollView.bounces = YES;
                }
                [weakSelf.commentViewController.commentTableView reloadData];
            }
            else {
                [weakSelf p_deleteArticleByInfoFetchedIfNeeded];
            }
        }
        else {
            NSMutableDictionary *extra = [[NSMutableDictionary alloc] init];
            [extra setValue:@(error.code) forKey:@"err_code"];
            [extra setValue:error.localizedDescription forKey:@"err_des"];
            [[TTMonitor shareManager] trackService:@"detail_info_status" status:1 extra:extra];
            //显示错误状态
            [weakSelf.natantContainerView reloadData:infoManager];
//            [self.detailView tt_setNatantWithFooterView:self.commentViewController.view
//                              includingFooterScrollView:[self.commentViewController commentTableView]];
        }
    }];
}

- (void)p_deleteArticleByInfoFetchedIfNeeded
{
    [self.detailView.detailWebView removeNatantLoadingView];
    
    [self.detailView tt_deleteArticleByInfoFetchedIfNeeded];
    
    [self.commentViewController removeFromParentViewController];
    
    [self.toolbarView removeFromSuperview];
    
    [self.natantContainerView removeFromSuperview];
    
    self.navigationItem.titleView = nil;
    
    self.navigationItem.rightBarButtonItems = nil;
    
    self.titleView = nil;
}

- (nullable NSMutableArray <TTDetailNatantViewBase *> *)p_newItemsBuildInNatantWithInfoManager:(ArticleInfoManager *)infoManager{
    
    NSMutableArray *natantItems = [NSMutableArray array];
    CGFloat natantWidth = [TTUIResponderHelper splitViewFrameForView:self.view].size.width - [[TTDetailNatantLayout sharedInstance_tt] leftMargin] - [[TTDetailNatantLayout sharedInstance_tt] rightMargin];
    NSArray * classNameList = infoManager.classNameList;
    [natantItems addObject:[self p_natantSpacingItemForClass:@"topMargin"]];
    [classNameList enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        NSString * className = (NSString *)obj;
        
        TTDetailNatantViewBase * natantView = [(TTDetailNatantViewBase *)[NSClassFromString(className) alloc] initWithWidth:natantWidth];
        natantView.left = [[TTDetailNatantLayout sharedInstance_tt] leftMargin];
        if (natantView) {
            if ([natantView isKindOfClass:[TTDetailNatantRewardView class]]) {
                TTDetailNatantRewardView *rewardView = (TTDetailNatantRewardView *)natantView;
                rewardView.goDetailLabel = self.detailModel.clickLabel;
                rewardView.hidden = YES;
                TTActionSheetSourceType source = TTActionSheetSourceTypeDislike;
                NSString *trackSource = nil;
                NSString *style = nil;
                if (infoManager.dislikeWords.count == 0) {
                    source = TTActionSheetSourceTypeReport;
                    [rewardView filterWordIsEmpty];
                    trackSource = @"report_click";
                    style = @"report";
                }
                else {
                    trackSource = @"report_and_dislike_click";
                    style = @"report_and_dislike";
                }
                WeakSelf;
                rewardView.clickReportBlock = ^{
                    StrongSelf;
                    [self report_showReportOnNatantView:style source:source trackSource:trackSource];
                };
            }else
            {
                if ([natantView isKindOfClass:[ExploreDetailADContainerView class]]) {
                    ((ExploreDetailADContainerView*)natantView).delegate = self;
                }
          
                [natantItems addObject:natantView];
                [natantItems addObject:[self p_natantSpacingItemForClass:className]];
                
                if ([natantView isKindOfClass:[TTDetailNatantRelateArticleGroupView class]]) {
                    [natantItems addObject:[self p_natantSpacingItemForClass:@"topMargin"]];
                }
            }
        }
    }];
    
    //如果没有内容类型则删掉topmargin
    if (![self p_natantValidContentViewFromArray:natantItems]) {
        [natantItems removeAllObjects];
    }
    
    return natantItems;
}

- (void)removeNatantView:(TTDetailNatantViewBase *)natantView animated:(BOOL)animated {
    NSString *className = NSStringFromClass([natantView class]);
    NSMutableArray* array = [NSMutableArray arrayWithArray:self.natantContainerView.items];
    [array enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:NSClassFromString(className)]) {
            //删除bottomPadding
            NSInteger index = [self.natantContainerView.items indexOfObject:obj];
            if (self.natantContainerView.items.count > index + 1) {
                TTDetailNatantHeaderPaddingView* spaceBottomItem = (TTDetailNatantHeaderPaddingView*)self.natantContainerView.items[index + 1];
                if (spaceBottomItem && [spaceBottomItem isKindOfClass:[TTDetailNatantHeaderPaddingView class]]) {
                    [self.natantContainerView removeObject:spaceBottomItem];
                    [spaceBottomItem removeFromSuperview];
                }
            }
            //删除adContaniner
            [self.natantContainerView removeObject:obj];
            [(UIView*)obj removeFromSuperview];
            //删除topPadding
            if (self.natantContainerView.items.count==1) {
                TTDetailNatantHeaderPaddingView* spaceTopItem = (TTDetailNatantHeaderPaddingView*)self.natantContainerView.items[0];
                if (spaceTopItem && [spaceTopItem isKindOfClass:[TTDetailNatantHeaderPaddingView class]]) {
                    [self.natantContainerView removeObject:spaceTopItem];
                    [spaceTopItem removeFromSuperview];
                }
            }
            *stop = YES;
        }
    }];
}

- (TTDetailNatantHeaderPaddingView *)p_natantSpacingItemForClass:(NSString *)className{
    CGFloat paddingHeight = 0;
    SWITCH (className) {
        CASE (@"topMargin") {
            paddingHeight = [[TTDetailNatantLayout sharedInstance_tt] topMargin];
//            paddingHeight = 0;
            break;
        }
        CASE (@"TTDetailNatantRiskWarningView") {
            //TTDetailNatantRiskWarningView bottomMargin和topMargin相同
            paddingHeight = [[TTDetailNatantLayout sharedInstance_tt] topMargin];
            break;
        }
        CASE (@"TTDetailNatantTagsView") {
            paddingHeight = [[TTDetailNatantLayout sharedInstance_tt] spaceBeweenNantants];
            break;
        }
        CASE (@"TTDetailNatantRewardView") {
            paddingHeight = 0;
//            paddingHeight = [[TTDetailNatantLayout sharedInstance_tt] spaceBeweenNantants];
            break;
        }
        CASE (@"ExploreDetailADContainerView") {
            paddingHeight = [[TTDetailNatantLayout sharedInstance_tt] spaceBeweenNantants];
            break;
        }
        CASE (@"TTDetailNatantRelateArticleGroupView"){
            paddingHeight = 0;
            break;
        }
        CASE (@"ExploreDetailTextlinkADView"){
            paddingHeight = [[TTDetailNatantLayout sharedInstance_tt] bottomMargin];
            break;
        }
        DEFAULT {
            paddingHeight = [[TTDetailNatantLayout sharedInstance_tt] spaceBeweenNantants] - 14; //修正下面评论前的padding
            break;
        }
    }
    TTDetailNatantHeaderPaddingView *spacingItem = [[TTDetailNatantHeaderPaddingView alloc] initWithWidth:[TTUIResponderHelper splitViewFrameForView:self.view].size.width];
    spacingItem.height = paddingHeight;
    spacingItem.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    spacingItem.userInteractionEnabled = NO;
    return spacingItem;
}

- (BOOL)p_natantValidContentViewFromArray:(NSMutableArray *)array{
    
    BOOL hasValidNatant = NO;
    
    for (id obj in array) {
        if ([obj isKindOfClass:[TTDetailNatantViewBase class]]) {
            NSString *className = NSStringFromClass([obj class]);
            
            if ([className isEqualToString:@"TTDetailNatantRiskWarningView"] ||
                [className isEqualToString:@"TTDetailNatantTagsView"] ||
                [className isEqualToString:@"TTDetailNatantRewardView"] ||
                [className isEqualToString:@"ExploreDetailADContainerView"] ||
                [className isEqualToString:@"TTDetailNatantRelateArticleGroupView"]) {
                
                hasValidNatant = YES;
                
                break;
            }
            else {
                hasValidNatant = NO;
            }
            
        }
    }
    
    return hasValidNatant;
}

- (void)p_scrollToCommentIfNeeded
{
    if (self.beginShowComment && [self p_needShowToolBarView]) {
        [self toolBarButtonClicked:self.toolbarView.commentButton];
    }
}

- (void)p_refreshToolbarView
{
    self.toolbarView.collectButton.selected = self.detailModel.article.userRepined;
    self.toolbarView.commentBadgeValue = [@(self.detailModel.article.commentCount) stringValue];
}

- (void)p_refreshArticleTypeRelevantUIIfNeeded
{
    //更新toolbar
    BOOL needShowToolBar = [self p_needShowToolBarView];
    if (needShowToolBar) {
        if (!self.toolbarView) {
            [self p_buildToolbarViewIfNeeded];
        }
        else {
            self.toolbarView.frame = [self p_frameForToolBarView];
            //            ExploreDetailToolbarType type = ([self.detailView.detailViewModel tt_articleDetailType] == TTDetailArchTypeNormal) ? ExploreDetailToolbarTypeNormal : ExploreDetailToolbarTypeExcludeCommentButtons;
            self.toolbarView.toolbarType = ExploreDetailToolbarTypeArticleComment;
            self.toolbarView.hidden = NO;
            
            // toolbar 禁表情，改变 toolbarType 会重置 button 的状态
            BOOL isBanRepostOrEmoji = ![KitchenMgr getBOOL:KKCCommentRepostFirstDetailEnable] || (self.detailModel.adID > 0) || ak_banEmojiInput();
            if ([self.commentViewController respondsToSelector:@selector(tt_banEmojiInput)]) {
                self.toolbarView.banEmojiInput = self.commentViewController.tt_banEmojiInput || isBanRepostOrEmoji;
            }
        }
    }
    else {
        self.toolbarView.hidden = YES;
    }
    //更新detailWebView及footerView
    CGRect detailWebViewFrame = CGRectMake(0, 0, self.detailView.width, self.detailView.height);
    TTDetailArchType detailType = [self.detailView.detailViewModel tt_articleDetailType];
    if (detailType == TTDetailArchTypeNormal) {
        detailWebViewFrame.size.height -= self.toolbarView.height;
    }
    self.detailView.detailWebView.frame = detailWebViewFrame;
    self.commentViewController.view.frame = [self p_contentVisableRect];
}

- (void)p_setDetailViewBars {
    self.toolbarView.viewStyle = TTDetailViewStyleArticleComment;
    self.ttHideNavigationBar = NO;
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    
    if (![[TTThemeManager sharedInstance_tt] viewControllerBasedStatusBarStyle]) {
        [[UIApplication sharedApplication] setStatusBarStyle:[TTThemeManager sharedInstance_tt].statusBarStyle animated:YES];
    }
    else {
        [[UIApplication sharedApplication] setStatusBarStyle:[TTThemeManager sharedInstance_tt].statusBarStyle animated:YES];
        self.ttStatusBarStyle = [TTThemeManager sharedInstance_tt].statusBarStyle;
    }
}

- (BOOL)p_needShowToolBarView
{
    TTDetailArchType detailType = [self.detailView.detailViewModel tt_articleDetailType];
    if (detailType == TTDetailArchTypeNormal) {
        return YES;
    }
    //其他类型都不显示toolbar
    return NO;
}

- (CGRect)p_frameForDetailView
{
    if ([SSCommonLogic detailNewLayoutEnabled]) {
        if ([TTDeviceHelper isPadDevice]) {
            return [TTUIResponderHelper splitViewFrameForView:self.view];
        }
        return self.view.bounds;
    }
    
    CGSize windowSize = [TTUIResponderHelper windowSize];
    if ([TTDeviceHelper isPadDevice]) {
        CGFloat edgePadding = [TTUIResponderHelper paddingForViewWidth:windowSize.width];
        if([_detailModel.adID longLongValue] != 0 && [TTDeviceHelper OSVersionNumber] < 9){
            edgePadding = 0;
        }
        return CGRectMake(edgePadding, 0, windowSize.width - edgePadding*2, windowSize.height-64);
    }
    else {
        CGFloat topInset = self.view.tt_safeAreaInsets.top;
        CGFloat bottomInset = self.view.tt_safeAreaInsets.bottom;
        if (topInset <= 0){
            topInset = [UIApplication sharedApplication].statusBarFrame.size.height;
        }
        if (topInset <= 0){
            topInset = 20;
        }
        topInset += TTNavigationBarHeight;
        //frame fix 因为进入的时候self.view大小有可能变化（如果是在viewdidload里 那大小是{0，0，screen.width，screen height}，如果是异步也就是viewappear之后 view大小会是{0，64，screen.width，screen height-64}）
        CGRect rect = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - topInset - bottomInset);
        
        return rect;
    }
}

- (CGRect)p_frameForToolBarView
{
    if (![self p_needShowToolBarView]) {
        return CGRectZero;
    }
    self.toolbarView.height = ExploreDetailGetToolbarHeight() + [TTUIResponderHelper mainWindow].tt_safeAreaInsets.bottom;
    if ([SSCommonLogic detailNewLayoutEnabled]) {
        return CGRectMake(0, self.view.height - self.toolbarView.height, self.view.width, self.toolbarView.height);
    }
    
    CGFloat toolbarOriginY = [self p_frameForDetailView].size.height - self.toolbarView.height;
    if ([TTDeviceHelper isPadDevice]) {
        CGSize windowSize = [TTUIResponderHelper windowSize];
        return CGRectMake(0, toolbarOriginY, windowSize.width, self.toolbarView.height);
    }
    else {
        return CGRectMake(0, [self p_contentVisableRect].size.height, [self p_frameForDetailView].size.width, self.toolbarView.height);
    }
}

//当前详情页可视范围标准rect(去掉顶部导航,且根据articleType判断是否去掉底部toolbar)
- (CGRect)p_contentVisableRect
{
    //parentVC has UIRectEdgeNone property
    CGFloat visableHeight = [self p_frameForDetailView].size.height;
    TTDetailArchType detailType = [self.detailView.detailViewModel tt_articleDetailType];
    if (detailType == TTDetailArchTypeNormal) {
        visableHeight -= self.toolbarView.height;

        // add by zjing 兼容评论条高度
        if (@available(iOS 11.0, *)) {
            UIEdgeInsets safeInset = self.view.safeAreaInsets;
            visableHeight += safeInset.bottom;
        }

    }
    return CGRectMake(0, 0, [TTUIResponderHelper splitViewFrameForView:self.view].size.width, visableHeight);
}

- (void)p_addObservers
{
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(pn_statusBarOrientationDidChange)
                                                 name:UIApplicationDidChangeStatusBarOrientationNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(pn_applicationDidEnterBackground:)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(pn_applicationWillEnterForeground:)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(menControllerDidShow)
                                                 name:UIMenuControllerWillShowMenuNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(pn_userDidTakeScreenshot:)
                                                 name:UIApplicationUserDidTakeScreenshotNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(p_paidNovelPurchasedFinished:) name:@"novel_purchase_result" object:nil];
    [TTAccount addMulticastDelegate:self];
}

- (void)p_addDetailViewKVO
{
    if (!self.detailKVOHasAdd) {
        self.detailKVOHasAdd = YES;
        
        //webView footerStatus 相关KVO 由VC处理
        [self.detailView.detailWebView addObserver:self forKeyPath:@"footerStatus" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
        
        //article更新的KVO
        [self.detailModel.article addObserver:self forKeyPath:@"userLike" options:NSKeyValueObservingOptionNew context:NULL];
        [self.detailModel.article addObserver:self forKeyPath:@"userRepined" options:NSKeyValueObservingOptionNew context:NULL];
        [self.detailModel.article addObserver:self forKeyPath:@"actionDataModel.commentCount" options:NSKeyValueObservingOptionNew context:NULL];
    }
}

- (void)p_removeDetailViewKVO
{
    if (self.detailKVOHasAdd) {
        self.detailKVOHasAdd = NO;
        [self.detailView.detailWebView removeObserver:self forKeyPath:@"footerStatus"];
        [self.detailModel.article removeObserver:self forKeyPath:@"userLike"];
        [self.detailModel.article removeObserver:self forKeyPath:@"userRepined"];
        [self.detailModel.article removeObserver:self forKeyPath:@"actionDataModel.commentCount"];
    }
    
}

- (void)p_popToLastCorrectController
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (TTAlphaThemedButton *)p_generateBarButtonWithImageName:(NSString *)imageName {
    TTAlphaThemedButton *barButton = [TTAlphaThemedButton buttonWithType:UIButtonTypeCustom];
    barButton.hitTestEdgeInsets = UIEdgeInsetsMake(-5, -10, -5, -10);
    barButton.imageName = imageName;
    [barButton sizeToFit];
    
    if ([TTDeviceHelper isScreenWidthLarge320]) {
        [barButton setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, -2)];
    }
    else {
        [barButton setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, -4)];
    }
    return barButton;
}

//build natantItems with infoManager
//
/**
 *  p_newItemsBuildInNatantWithInfoManager使用了重构的浮层
 * 如果想使用以前的浮层 请使用p_itemsBuildInNatantWithInfoManager。
 */
- (void)p_reloadItemsWithInforManager:(ArticleInfoManager *)infoManager {
    CGRect origFrame = self.natantContainerView.frame;
    self.natantContainerView.items = [self p_newItemsBuildInNatantWithInfoManager:infoManager];
    [self.natantContainerView reloadData:infoManager];
    CGRect newFrame = self.natantContainerView.frame;
    
    CGFloat offset = (newFrame.origin.y + newFrame.size.height) - (origFrame.origin.y + origFrame.size.height);
    if ([self.detailView.detailWebView isCommentVisible]) {
        self.commentViewController.commentTableView.contentOffset = CGPointMake(self.commentViewController.commentTableView.contentOffset.x, self.commentViewController.commentTableView.contentOffset.y + offset);
    }
}

- (void)p_reloadItems {
    CGRect origFrame = self.natantContainerView.frame;
    
    [self.natantContainerView reloadData:self.articleInfoManager];
    CGRect newFrame = self.natantContainerView.frame;
    
    CGFloat offset = (newFrame.origin.y + newFrame.size.height) - (origFrame.origin.y + origFrame.size.height);
    if ([self.detailView.detailWebView isCommentVisible]) {
        self.commentViewController.commentTableView.contentOffset = CGPointMake(self.commentViewController.commentTableView.contentOffset.x, self.commentViewController.commentTableView.contentOffset.y + offset);
    }
}

- (void)fetchPaidNovelIfNeed {
    __weak __typeof(self)weakSelf = self;
    NSNumber *oriGroupFlags = self.detailModel.fitArticle.groupFlags;
    TTDetailNatantStyle origNatantStyle = [weakSelf.detailView.detailViewModel tt_natantStyleFromNatantLevel];
    [self.novelManager fetchPaidNovelIfNeed:^(NSError *error, Article *novelArticle) {
        if (error) {
            return;
        }
        
        if (!novelArticle) {
            return;
        }
        
        [weakSelf.detailView tt_setContentAndExtraWithArticle:novelArticle];
        weakSelf.detailModel.paidArticle = novelArticle;
        if (weakSelf.detailModel.fitArticle.groupFlags && ![oriGroupFlags isEqualToNumber:weakSelf.detailModel.fitArticle.groupFlags]) {
            [weakSelf p_refreshArticleTypeRelevantUIIfNeeded];
        }
        
        TTDetailNatantStyle natantStyle = [weakSelf.detailView.detailViewModel tt_natantStyleFromNatantLevel];
        if (origNatantStyle != natantStyle) {
            weakSelf.detailView.detailWebView.natantStyle = natantStyle;
            weakSelf.detailView.detailWebView.webView.scrollView.bounces = YES;
        }
        
        [weakSelf.commentViewController.commentTableView reloadData];
        
    }];
}
#pragma mark - TitleView actions
- (void)onLogoTitleViewClick {
    NSString *urlString = @"";
    if (self.detailModel.article.navOpenUrl) {
        urlString = self.detailModel.article.navOpenUrl;
    }
    if (isEmptyString(urlString)) return;
    
    if (self.isCarPage) {
        [SSWebViewController openWebViewForNSURL:[TTStringHelper URLWithURLString:urlString] title:@"懂车帝" navigationController:self.navigationController supportRotate:NO];
    } else {
        [SSWebViewController openWebViewForNSURL:[TTStringHelper URLWithURLString:urlString] title:nil navigationController:self.navigationController supportRotate:NO];
    }
    [self p_sendLogoViewEventWithEventName:@"logo_click"];
}



#pragma mark - Toolbar actions

- (void)toolBarButtonClicked:(id)sender
{
    if (sender == self.toolbarView.collectButton) {
        self.toolbarView.collectButton.imageView.contentMode = UIViewContentModeCenter;
        self.toolbarView.collectButton.imageView.transform = CGAffineTransformMakeScale(1.f, 1.f);
        self.toolbarView.collectButton.alpha = 1.f;
        [UIView animateWithDuration:0.1f delay:0.f options:UIViewAnimationOptionCurveEaseOut animations:^{
            self.toolbarView.collectButton.imageView.transform = CGAffineTransformMakeScale(0.6f, 0.6f);
            self.toolbarView.collectButton.alpha = 0.f;
        } completion:^(BOOL finished){
            [self p_willChangeArticleFavoriteState];
            [UIView animateWithDuration:0.2f delay:0.f options:UIViewAnimationOptionCurveEaseIn animations:^{
                self.toolbarView.collectButton.imageView.transform = CGAffineTransformMakeScale(1.f, 1.f);
                self.toolbarView.collectButton.alpha = 1.f;
            } completion:^(BOOL finished){
            }];
        }];
    }
    else if (sender == self.toolbarView.writeButton) {
        if ([self.commentViewController respondsToSelector:@selector(tt_defaultReplyCommentModel)] && self.commentViewController.tt_defaultReplyCommentModel) {
            [self tt_commentViewController:self.commentViewController didSelectWithInfo:({
                NSMutableDictionary *baseCondition = [[NSMutableDictionary alloc] init];
                [baseCondition setValue:self.detailModel.article.groupModel forKey:@"groupModel"];
                [baseCondition setValue:@(1) forKey:@"from"];
                [baseCondition setValue:@(YES) forKey:@"writeComment"];
                [baseCondition setValue:self.commentViewController.tt_defaultReplyCommentModel forKey:@"commentModel"];
                [baseCondition setValue:@(ArticleMomentSourceTypeArticleDetail) forKey:@"sourceType"];
                [baseCondition setValue:self.detailModel.article forKey:@"group"]; //竟然带了article.....
                baseCondition;
            })];
            if ([self.commentViewController respondsToSelector:@selector(tt_clearDefaultReplyCommentModel)]) {
                [self.commentViewController tt_clearDefaultReplyCommentModel];
            }
            [self.toolbarView.writeButton setTitle:@"写评论" forState:UIControlStateNormal];
            return;
        }
        [self p_willOpenWriteCommentViewWithReservedText:nil switchToEmojiInput:NO];
        [self p_sendDetailLogicTrackWithLabel:@"write_button"];
        TLS_LOG(@"write_button");
    }
    else if (sender == self.toolbarView.emojiButton) {
        if ([self.commentViewController respondsToSelector:@selector(tt_defaultReplyCommentModel)] && self.commentViewController.tt_defaultReplyCommentModel) {
            [self tt_commentViewController:self.commentViewController didSelectWithInfo:({
                NSMutableDictionary *baseCondition = [[NSMutableDictionary alloc] init];
                [baseCondition setValue:self.detailModel.article.groupModel forKey:@"groupModel"];
                [baseCondition setValue:@(1) forKey:@"from"];
                [baseCondition setValue:@(YES) forKey:@"writeComment"];
                [baseCondition setValue:self.commentViewController.tt_defaultReplyCommentModel forKey:@"commentModel"];
                [baseCondition setValue:@(ArticleMomentSourceTypeArticleDetail) forKey:@"sourceType"];
                [baseCondition setValue:self.detailModel.article forKey:@"group"]; //竟然带了article.....
                baseCondition;
            })];
            if ([self.commentViewController respondsToSelector:@selector(tt_clearDefaultReplyCommentModel)]) {
                [self.commentViewController tt_clearDefaultReplyCommentModel];
            }
            [self.toolbarView.writeButton setTitle:@"写评论" forState:UIControlStateNormal];
            return;
        }
        [self p_willOpenWriteCommentViewWithReservedText:nil switchToEmojiInput:YES];
        //        [self p_sendDetailLogicTrackWithLabel:@"write_button"];
        TLS_LOG(@"emoji_button");
        //        [self p_sendDetailTTLogV2WithEvent:@"click_write_button" eventContext:nil referContext:nil];
    }
    else if (sender == _toolbarView.commentButton) {
        
        [self p_sendNatantViewVisableTrack];
        if ([self.detailView.detailWebView isNatantViewOnOpenStatus]) {
            [self p_closeNatantView];
        }
        else {
            [self p_openNatantView];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(([self.detailView.detailWebView isNewWebviewContainer]? 0.6: 0.3) * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [[TTAuthorizeManager sharedManager].loginObj showAlertAtActionDetailComment:^{
                    
                    [TTAccountManager showLoginAlertWithType:TTAccountLoginAlertTitleTypeDefault source:nil completion:^(TTAccountAlertCompletionEventType type, NSString *phoneNum) {
                        if (type == TTAccountAlertCompletionEventTypeDone) {
                            if ([TTAccountManager isLogin]) {
                                [self p_willOpenWriteCommentViewWithReservedText:nil switchToEmojiInput:NO];
                            }
                        } else if (type == TTAccountAlertCompletionEventTypeTip) {
                            [TTAccountManager presentQuickLoginFromVC:[TTUIResponderHelper topNavigationControllerFor:self] type:TTAccountLoginDialogTitleTypeDefault source:nil completion:^(TTAccountLoginState state) {
                                
                            }];
                        }
                    }];
                }];
            });
            
            //added 5.3 无评论时引导用户发评论
            //与新版浮层动画冲突.延迟到0.6s执行
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(([self.detailView.detailWebView isNewWebviewContainer]? 0.6: 0.3) * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                if (!self.detailModel.article.commentCount) {
                    [self p_willOpenWriteCommentViewWithReservedText:nil switchToEmojiInput:NO];
                }
            });
            
            //added5.7:评论较少或无评论时，点击评论按钮弹起浮层时不会走scrollDidScroll，此处需强制调用一次检查浮层诸item是否需要发送show事件
            [self.natantContainerView sendNatantItemsShowEventWithContentOffset:0 isScrollUp:YES shouldSendShowTrack:YES];
        }
    }
    else if (sender == _toolbarView.shareButton) {
        [self p_willShowSharePannel];
    }
}

- (void)p_markIsScrollingTriggeredByCommentButtonClicked {
    _isScrollingTriggeredByCommentButtonClicked = YES;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)([self.detailView.detailWebView isNewWebviewContainer]? 0.2: 0.5) * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        _isScrollingTriggeredByCommentButtonClicked = NO;
    });
    
}

- (void)p_willOpenWriteCommentViewWithReservedText:(NSString *)reservedText switchToEmojiInput:(BOOL)switchToEmojiInput {
    if (switchToEmojiInput) {
        [TTTrackerWrapper eventV3:@"emoticon_click" params:@{
            @"status" : @"no_keyboard",
            @"source" : @"comment"
        }];
    }

    //    if (self.detailModel.article.banComment) {
    //        [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:sBannCommentTip indicatorImage:[UIImage themedImageNamed:@"close_popup_textpage"] autoDismiss:YES dismissHandler:nil];
    //        return;
    //    }

    NSMutableDictionary *condition = [NSMutableDictionary dictionaryWithCapacity:10];
    [condition setValue:self.detailModel.article.groupModel forKey:kQuickInputViewConditionGroupModel];
    [condition setValue:reservedText forKey:kQuickInputViewConditionInputViewText];
    [condition setValue:@(self.detailModel.article.hasImage) forKey:kQuickInputViewConditionHasImageKey];
    [condition setValue:self.detailModel.adID forKey:kQuickInputViewConditionADIDKey];
    [condition setValue:self.detailModel.article.mediaInfo[@"media_id"] forKey:kQuickInputViewConditionMediaID];

    NSString *fwID = self.detailModel.article.groupModel.groupID;

    TTArticleReadQualityModel *qualityModel = [[TTArticleReadQualityModel alloc] init];
    double readPct = [self.detailView.detailWebView readPCTValue];
    NSInteger percent = MAX(0, MIN((NSInteger)(readPct * 100), 100));
    qualityModel.readPct = @(percent);
    qualityModel.stayTimeMs = @([self.detailModel.sharedDetailManager currentStayDuration]);

    TTCommentWriteManager *commentManager = [[TTCommentWriteManager alloc] initWithCommentCondition:condition commentViewDelegate:self commentRepostBlock:^(NSString *__autoreleasing *willRepostFwID) {
        *willRepostFwID = fwID;
    } extraTrackDict:nil bindVCTrackDict:nil commentRepostWithPreRichSpanText:nil readQuality:qualityModel];
    commentManager.enterFrom = @"article";

    commentManager.enterFromStr = self.detailModel.clickLabel;
    commentManager.categoryID = self.detailModel.categoryID;
    commentManager.logPb = self.detailModel.logPb;

    self.commentWriteView = [[TTCommentWriteView alloc] initWithCommentManager:commentManager];

    self.commentWriteView.emojiInputViewVisible = switchToEmojiInput;

    // writeCommentView 禁表情
    if ([self.commentViewController respondsToSelector:@selector(tt_banEmojiInput)]) {
        self.commentWriteView.banEmojiInput = self.commentViewController.tt_banEmojiInput;
    }

    if ([self.commentViewController respondsToSelector:@selector(tt_writeCommentViewPlaceholder)]) {
        [self.commentWriteView setTextViewPlaceholder:self.commentViewController.tt_writeCommentViewPlaceholder];
    }

    [self.commentWriteView showInView:self.view animated:YES];
}

#pragma mark - Natant control

-(BOOL)p_isNewsDetailForImageSubject{
    return [self.detailModel.article isImageSubject];
}

- (void)p_openNatantView
{
    
    [self p_markIsScrollingTriggeredByCommentButtonClicked];
    
    if (![self.detailView.detailWebView isNewWebviewContainer]) { //新版浮层不再需要这个方法,DetailWebContainer里会实现类似效果 @zengruihuan
        [self.commentViewController tt_commentTableViewScrollToTop];
    }
    [self.detailView.detailWebView openFooterView:NO];
    self.wasTitleViewShowed = self.titleView.isShow;
    [self p_showTitle:YES];
    
    [self p_triggerStoryToolViewAnimation:YES];
}

- (void)p_closeNatantView
{
    //TODO；临时浮层相关
    //    if (_footerAddStatus != ExploreFooterAddStatusNormal) {
    //        [self.detailView.detailWebView removeFooterView];
    //        _natantView = nil;
    //        if (_footerAddStatus == ExploreFooterAddStatusReducedOpenWithPending) {
    //            [self buildAndLoadArticleSuperNatantIfNeeded];
    //        }
    //        else {
    //            _footerAddStatus = ExploreFooterAddStatusReducedClose;
    //        }
    //    }
    [self p_markIsScrollingTriggeredByCommentButtonClicked];
    
    [self.detailView.detailWebView closeFooterView];
    [self.natantContainerView resetAllRelatedItemsWhenNatantDisappear];
    [self p_showTitle:self.wasTitleViewShowed];
}

#pragma mark - Notifications
- (void)pn_statusBarOrientationDidChange
{
    if ([self.detailView.detailWebView isNewWebviewContainer]) {
        return; //新版浮层不需要做特殊处理
    }
    //pad浏览到评论区后旋转屏幕的特殊处理
    if ([TTDeviceHelper isPadDevice] && [self.detailView.detailViewModel tt_natantStyleFromNatantLevel] == TTDetailNatantStyleAppend && self.detailView.detailWebView.footerStatus == TTDetailWebViewFooterStatusDisplayTotal) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            CGPoint preLocation = self.commentViewController.commentTableView.contentOffset;
            [self.detailView.detailWebView refreshNatantLocation];
            [self toolBarButtonClicked:self.toolbarView.commentButton];
            [self.commentViewController.commentTableView setContentOffset:preLocation];
        });
    }
}

- (void)pn_applicationDidEnterBackground:(NSNotification *)notification {
    if (_isAppearing) {
        //进入后台 暂停计时 @liangxinyu
        if (self.commentShowDate) {
            NSTimeInterval timeInterval = [[NSDate date] timeIntervalSinceDate:self.commentShowDate];
            self.commentShowTimeTotal += timeInterval*1000;
            self.commentShowDate = nil;
        }
        NSDictionary *commentDic = @{@"stay_comment_time":[[NSNumber numberWithDouble:round(self.commentShowTimeTotal)] stringValue]};
        [self.detailModel.sharedDetailManager extraTrackerDic:commentDic];
        [self.detailModel.sharedDetailManager endStayTracker];
        self.commentShowTimeTotal = 0;
    }
    
    
    if (self.shouldShowTipsOnNavBar) {
        [TTTrackerWrapper eventV3:@"push_home" params:@{@"value" : @(1)}];
    }
    [self ak_suspendCountDownTimer];
}

- (void)pn_applicationWillEnterForeground:(NSNotification *)notification {
    if (_isAppearing) {
        [self.detailModel.sharedDetailManager startStayTracker];
    }
    
    if(self.detailView.detailWebView.isCommentVisible) {
        self.commentShowDate = [NSDate date];
    }
    [self ak_resumeCountDownTimer];
}

- (void)pn_userDidTakeScreenshot:(NSNotification *)notification {
    UIViewController *parentVC = self.presentedViewController? :self.parentViewController;
    
    NSInteger i = 0;
    while (parentVC && (parentVC.parentViewController != self.navigationController)) {
        parentVC = parentVC.presentedViewController? :parentVC.parentViewController;
        i++;
        if (i > 5) {
            break;
        }
    }
    
    if (self.navigationController.topViewController != parentVC) {
        return;
    }
    
    WeakSelf;
    [self.KVOController observe:self.detailView keyPath:@"domReady" options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld block:^(id  _Nullable observer, id  _Nonnull object, NSDictionary<NSString *,id> * _Nonnull change) {
        StrongSelf;
        BOOL old = [change[NSKeyValueChangeOldKey] boolValue];
        BOOL new = [change[NSKeyValueChangeNewKey] boolValue];
        if (!new || old == new) {
            return;
        }
        NSString *currentURL = [self.detailView.detailWebView.webView.currentURL.scheme.lowercaseString isEqualToString:@"file"]? [NSString stringWithFormat:@"gid=%@", self.detailModel.article.groupModel.groupID]: [self.detailView.detailWebView.webView.currentURL.absoluteString copy];
        
        [self.detailView.detailWebView.webView stringByEvaluatingJavaScriptFromString:@"document.documentElement.outerHTML" completionHandler:^(id _Nullable result, NSError * _Nullable error) {
            [SSFeedbackManager shareInstance].snapshotURL = currentURL;
            [SSFeedbackManager shareInstance].snapshotDOM = result;
            [SSFeedbackManager shareInstance].snapshotDate = [NSDate date];
        }];
    }];
}

- (void)p_paidNovelPurchasedFinished:(NSNotification *)notification {
    [self fetchPaidNovelIfNeed];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    if (object == self.detailView.detailWebView && [keyPath isEqualToString:@"footerStatus"]) {
        int oType = [[change objectForKey:NSKeyValueChangeOldKey] intValue];
        int nType = [[change objectForKey:NSKeyValueChangeNewKey] intValue];
        
        if (oType != nType) {
            if ([self.detailView.detailWebView isNatantViewVisible]) {
                if ([self.detailView.detailWebView isCommentVisible]) {
                    [self p_sendEnterCommentTrack];
                }
                [self.commentViewController tt_sendShowStatusTrackForCommentShown:YES];
                self.commentShowDate = [NSDate date];
            }
            else {
                [self.commentViewController tt_sendShowStatusTrackForCommentShown:NO];
                if (self.commentShowDate) {
                    NSTimeInterval timeInterval = [[NSDate date] timeIntervalSinceDate:self.commentShowDate];
                    self.commentShowTimeTotal += timeInterval*1000;
                    self.commentShowDate = nil;
                }
            }
        }
        //浮层出现时，尝试发送评论列表的统计
        if (nType == TTDetailWebViewFooterStatusDisplayNotManual ||
            nType == TTDetailWebViewFooterStatusDisplayTotal) {
            self.commentViewController.hasSelfShown = YES;
            [self.commentViewController tt_sendShowTrackForVisibleCells];
        }
        else if (nType == TTDetailWebViewFooterStatusNoDisplay) {
            [self p_showTitle:self.wasTitleViewShowed];
        }
        else {
            self.commentViewController.hasSelfShown = NO;
        }
        
        //insert类型浮层，拽起时要发送浮层上items的show统计事件
        BOOL isInsertNatant = self.detailView.detailWebView.natantStyle == TTDetailNatantStyleInsert;
        if (isInsertNatant &&
            oType == TTDetailWebViewFooterStatusNoDisplay &&
            nType == TTDetailWebViewFooterStatusDisplayNotManual) {
            [self.natantContainerView sendNatantItemsShowEventWithContentOffset:0 isScrollUp:YES shouldSendShowTrack:YES];
        }
    }
    if ([object isKindOfClass:[Article class]]) {
        [self p_refreshToolbarView];
    }
}

#pragma mark - TTAccountMulticastProtocol
- (void)onAccountLogin {
    [self fetchPaidNovelIfNeed];
}

#pragma mark - TTDetailViewController protocol (NavBarItems)

- (UIView *)leftBarButton
{
    if (!self.backButtonView) {
        if (self.shouldShowTipsOnNavBar) {
            self.backButtonView = [[SSWebViewBackTipsButtonView alloc] init];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            if ([self.parentViewController isKindOfClass:NSClassFromString(@"TTDetailContainerViewController")] && [self.parentViewController respondsToSelector:NSSelectorFromString(@"refreshLeftBarButtonItemsWithCloseButtonShown:")]) {
                [self.parentViewController performSelector:NSSelectorFromString(@"refreshLeftBarButtonItemsWithCloseButtonShown:") withObject:@(NO)];
            }
#pragma clang diagnostic pop
        } else {
            self.backButtonView = [[SSWebViewBackButtonView alloc] init];
        }
        
    }
    [self.backButtonView showCloseButton:NO];
    return self.backButtonView;
}

- (NSArray *)rightBarButtons{
    if ([[self.detailModel.article articleDeleted] boolValue]) {
        return nil;
    }
    NSMutableArray *buttons = [[NSMutableArray alloc] init];
    TTDetailArchType detailArchType = [self.detailView.detailViewModel tt_articleDetailType];
    BOOL shouldShowMoreButton = (detailArchType != TTDetailArchTypeNotAssign);
    if(shouldShowMoreButton) {
        _rightBarButtonItemView = [self p_generateBarButtonWithImageName:@"new_more_titlebar"];
        
        SSThemedView *view = [[SSThemedView alloc] initWithFrame:CGRectMake(0, 0, self.rightFollowButton.width + [TTDeviceUIUtils tt_newPadding:16], self.rightFollowButton.height)];
        self.rightFollowButton.centerX = view.width / 2;
        self.rightFollowButton.centerY = view.height / 2;
        [view addSubview:self.rightFollowButton];
        [buttons addObject:_rightBarButtonItemView];
        if (!self.shouldShowTipsOnNavBar) {
            [buttons addObject:view];
        }
    }
    
    return buttons;
}

- (TTFollowThemeButton *)rightFollowButton {
    if (!_rightFollowButton) {
        //文章详情页顶部使用
        _rightFollowButton = [[TTFollowThemeButton alloc] initWithUnfollowedType:TTUnfollowedType101 followedType:TTFollowedType101];
        _rightFollowButton.hidden = YES;
        _rightFollowButton.followed = [self.detailModel.article.mediaInfo tt_boolValueForKey:@"subcribed"];
        WeakSelf;
        [_rightFollowButton addTarget:self withActionBlock:^{
            StrongSelf;
            //Article中的mediaInfo中拼写错误：subcribed;
            BOOL isFollowed = [self.detailModel.article.mediaInfo tt_boolValueForKey:@"subcribed"];
            FriendActionType actionType;
            
            //老的关注统计
            NSMutableDictionary *params = [NSMutableDictionary dictionary];
            [params setValue:@"top_title_bar" forKey:@"position"];
            [params setValue:@"article_detail" forKey:@"source"];
            [params setValue:self.detailModel.article.mediaUserID forKey:@"user_id"];
            [params setValue:self.detailModel.article.groupModel.groupID forKey:@"group_id"];
            if (isFollowed) {
                actionType = FriendActionTypeUnfollow;
            }else {
                actionType = FriendActionTypeFollow;
            }
            //新关注统计
            NSMutableDictionary * extraDic = @{}.mutableCopy;
            NSString * followEvent = nil;
            if (isFollowed) {
                followEvent = @"rt_unfollow";
                [extraDic setValue:@(TTFollowNewSourceNewsDetail)
                            forKey:@"server_source"];
            }else {
                followEvent = @"rt_follow";
//                if (self.articleInfoManager.activity.redpack) {
//                    [extraDic setValue:@(1)
//                                forKey:@"is_redpacket"];
//                    [extraDic setValue:@(TTFollowNewSourceNewsDetailRedPacket)
//                                forKey:@"server_source"];
//                }else {
                    [extraDic setValue:@(TTFollowNewSourceNewsDetail)
                                forKey:@"server_source"];
//                }
            }
            [extraDic setValue:self.detailModel.article.userIDForAction
                        forKey:@"to_user_id"];
            [extraDic setValue:[self.detailModel.article.mediaInfo tt_stringValueForKey:@"media_id"]
                        forKey:@"media_id"];
            [extraDic setValue:@"from_group"
                        forKey:@"follow_type"];
            [extraDic setValue:self.detailModel.article.groupModel.groupID
                        forKey:@"group_id"];
            [extraDic setValue:self.detailModel.article.groupModel.itemID
                        forKey:@"item_id"];
            //            [extraDic setValue:[self.detailModel clickFromLabel]
            //                        forKey:@"enter_from"];
            [extraDic setValue:self.detailModel.categoryID
                        forKey:@"category_name"];
            [extraDic setValue:@"article_detail"
                        forKey:@"source"];
            [extraDic setValue:@"top_title_bar"
                        forKey:@"position"];
            [extraDic setValue:self.detailModel.orderedData.logPb
                        forKey:@"log_pb"];
            [TTTrackerWrapper eventV3:followEvent
                               params:extraDic];
            
            if (!TTNetworkConnected()) {
                [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage
                                          indicatorText:@"网络不给力，请稍后重试"
                                         indicatorImage:[UIImage themedImageNamed:@"close_popup_textpage"]
                                            autoDismiss:YES
                                         dismissHandler:nil];
                return;
            }
            
            self.rightFollowButton.followed = isFollowed;
            [self.rightFollowButton startLoading];
            
            [[TTFollowManager sharedManager] startFollowAction:actionType userID:self.detailModel.article.mediaUserID platform:nil name:nil from:nil reason:nil newReason:nil newSource:@(TTFollowNewSourceNewsDetail) completion:^(FriendActionType type, NSError * _Nullable error, NSDictionary * _Nullable result) {
                StrongSelf;
                [self.rightFollowButton stopLoading:^{
                    
                }];
                if (!error) {
                    NSDictionary *response = [result tt_dictionaryValueForKey:@"result"];
                    NSDictionary *data = [response tt_dictionaryValueForKey:@"data"];
                    NSDictionary *user = [data tt_dictionaryValueForKey:@"user"];
                    NSMutableDictionary *mediaInfo = [self.detailModel.article.mediaInfo mutableCopy];
                    [mediaInfo setValue:@([user tt_boolValueForKey:@"is_following"]) forKey:@"subcribed"];
                    self.detailModel.article.mediaInfo = [mediaInfo copy];
                    [self.detailModel.article save];
                    if ([self.detailModel.article.mediaInfo tt_boolValueForKey:@"subcribed"]) {
                        NSMutableDictionary *extra = [[NSMutableDictionary alloc] init];
                        [extra setValue:self.detailModel.article.itemID forKey:@"item_id"];
                        //                        wrapperTrackEventWithCustomKeys(@"detail", @"title_bar_pgc_subscribe", self.detailModel.article.mediaInfo[@"media_id"], nil, extra);
                        self.rightFollowButton.followed = YES;
//                        if (self.articleInfoManager.activity.redpack) {
//                            TTRedPacketTrackModel * redPacketTrackModel = [TTRedPacketTrackModel new];
//                            redPacketTrackModel.userId = self.detailModel.article.userIDForAction;
//                            redPacketTrackModel.mediaId = [self.detailModel.article.mediaInfo tt_stringValueForKey:@"media_id"];
//                            redPacketTrackModel.categoryName = self.detailModel.categoryID;
//                            redPacketTrackModel.source = @"article_detail";
//                            redPacketTrackModel.position = @"top_title_bar";
//                            [[TTRedPacketManager sharedManager] presentRedPacketWithRedpacket:self.articleInfoManager.activity.redpack
//                                                                                       source:redPacketTrackModel
//                                                                               viewController:self];
//                            self.articleInfoManager.activity.redpack = nil;
//                        }
                    }
                    else {
                        NSMutableDictionary *extra = [[NSMutableDictionary alloc] init];
                        [extra setValue:self.detailModel.article.itemID forKey:@"item_id"];
                        //                        wrapperTrackEventWithCustomKeys(@"detail", @"title_bar_pgc_unsubscribe", self.detailModel.article.mediaInfo[@"media_id"], nil, extra);
                        self.rightFollowButton.followed = NO;
                    }
                    [self p_updateNavigationTitleView];
                } else {
                    NSString * tips = nil;
                    if ([result isKindOfClass:[NSDictionary class]]) {
                        tips = [[[result tt_dictionaryValueForKey:@"result"] tt_dictionaryValueForKey:@"data"] tt_stringValueForKey:@"description"];
                    }
                    if (error) {
                        if (!isEmptyString(tips) && ![tips isEqualToString:@"关注成功"]) {
                            [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage
                                                      indicatorText:tips
                                                     indicatorImage:[UIImage themedImageNamed:@"close_popup_textpage"]
                                                        autoDismiss:YES
                                                     dismissHandler:nil];
                        }
                    }
                }
            }];
            
        } forControlEvent:UIControlEventTouchUpInside];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(p_updateTopSubscribe:) name:kEntrySubscribeStatusChangedNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(blockNotification:) name:kHasBlockedUnblockedUserNotification object:nil];
        
    }
    return _rightFollowButton;
}

- (void)leftBarButtonClicked:(id)sender
{
    //TODO: 判断逻辑有待优化
    BOOL couldSendPageBack = YES;
    SSJSBridgeWebView *webView = self.detailView.detailWebView.webView;
    if ([self.backButtonView isCloseButtonShowing]) {
        if (sender == self.backButtonView.backButton) {
            if ([webView canGoBack]) {
                [webView goBack];
            }
            else {
                couldSendPageBack = NO;
                [self p_popToLastCorrectController];
            }
            _backButtonTouched = YES;
        }
        else {
            couldSendPageBack = NO;
            [self p_popToLastCorrectController];
        }
    } else {
        if ([webView canGoBack]) {
            [webView goBack];
            [self.backButtonView showCloseButton:YES];
        } else {
            couldSendPageBack = NO;
            _backButtonTouched = YES;
            [self p_popToLastCorrectController];
        }
    }
    
    if (sender == self.backButtonView.closeButton) {
        wrapperTrackEvent(@"detail", @"close_button");
        _closeButtonTouched = YES;
    }
    else if (sender == self.backButtonView.backButton && couldSendPageBack) {
        wrapperTrackEvent(@"detail", @"page_back");
    }
}

- (void)detailContainerViewController:(SSViewControllerBase *)container rightBarButtonClicked:(id)sender
{
    if (sender == self.rightBarButtonItemView) {
        [self p_showMorePanel];
    }
}

- (BOOL)shouldShowErrorPageInDetailContaierViewController:(SSViewControllerBase *)container {
    return YES;
}

- (CGRect)detailViewFrame {
    CGFloat statusBarOffset = [[UIApplication sharedApplication] statusBarFrame].size.height - 20.f;
    CGFloat detailVCOriginY = 64.f - statusBarOffset;
    if ([SSCommonLogic detailNewLayoutEnabled]) {
        detailVCOriginY = 64.f;
    }
    if (!([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) || [[UIApplication sharedApplication] statusBarFrame].size.height == 0) {
        detailVCOriginY = 64.0;
    }
    
    if ([TTDeviceHelper isIPhoneXDevice]){
        detailVCOriginY = 44.f + TTNavigationBarHeight;
    }
    return CGRectMake(0, detailVCOriginY, self.parentViewController.view.frame.size.width, self.parentViewController.view.frame.size.height - detailVCOriginY);
}
#pragma mark - Tracker
- (void)p_sendNatantViewVisableTrack
{
    if ([self.detailView.detailWebView isNatantViewOnOpenStatus]) {
        wrapperTrackEvent(@"detail", @"handle_close_drawer");
        TLS_LOG(@"handle_close_drawer");
    }
    else {
        wrapperTrackEvent(@"detail", @"handle_open_drawer");
        TLS_LOG(@"handle_open_drawer");
        
    }
}

- (void)p_sendGoDetailTrack
{
    NSString* enterFrom = [self enterFromString];

    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
//    [dic setValue:self.detailModel.adID.stringValue forKey:@"ext_value"];
    [dic setValue:self.detailModel.article.groupModel.itemID forKey:@"item_id"];
//    [dic setValue:self.detailModel.article.aggrType forKey:@"aggr_type"];

    if (![@"push" isEqualToString: enterFrom]) {
        if (self.detailModel.relateReadFromGID) {
            [dic setValue:[NSString stringWithFormat:@"%@",self.detailModel.relateReadFromGID] forKey:@"from_gid"];
        }
    }

//    BOOL hasZzComment = self.detailModel.article.zzComments.count > 0;
//    [dic setValue:@(hasZzComment?1:0) forKey:@"has_zz_comment"];
//    if (hasZzComment) {
//        [dic setValue:self.detailModel.article.firstZzCommentMediaId forKey:@"mid"];
//    }
    
//    if (self.detailModel.gdExtJsonDict) {
//        [dic setValuesForKeysWithDictionary:self.detailModel.gdExtJsonDict];
//    }
    
    [dic setValue:self.detailModel.article.groupModel.groupID forKey:@"group_id"];

    [dic setValue:enterFrom forKey:@"enter_from"];
    if (![@"push" isEqualToString: enterFrom]) {
        [dic setValue:[self categoryName] forKey:@"category_name"];
    }
    [dic setValue:self.detailModel.logPb == nil ? @"be_null" : self.detailModel.logPb forKey:@"log_pb"];
//    [[EnvContext shared].tracer writeEvent:@"go_detail" params:dic];

    [FHEnvContext recordEvent:dic andEventKey:@"go_detail"];
//    id value = self.detailModel.article.groupModel.groupID;
//    if (![TTTrackerWrapper isOnlyV3SendingEnable]) {
//        wrapperTrackEventWithCustomKeys(@"go_detail", self.detailModel.clickLabel, value, nil, dic);
//    }
    
    //log3.0 doubleSending
//    NSMutableDictionary *logv3Dic = [NSMutableDictionary dictionaryWithCapacity:5];
//    [logv3Dic setValue:self.detailModel.article.groupModel.groupID forKey:@"group_id"];
//    [logv3Dic setValue:self.detailModel.article.groupModel.itemID forKey:@"item_id"];
//    [logv3Dic setValue:[NewsDetailLogicManager enterFromValueForLogV3WithClickLabel:self.detailModel.clickLabel categoryID:self.detailModel.categoryID] forKey:@"enter_from"];
//    NewsGoDetailFromSource fromSource = self.detailModel.fromSource;
//    if (fromSource == NewsGoDetailFromSourceHeadline ||
//        fromSource == NewsGoDetailFromSourceCategory) {
//        [logv3Dic setValue:self.detailModel.categoryID forKey:@"category_name"];
//    }
//    [logv3Dic setValue:self.detailModel.logPb forKey:@"log_pb"];
//    [logv3Dic setValue:self.detailModel.adID.stringValue forKey:@"ad_id"];
//    [logv3Dic setValue:self.detailModel.article.aggrType forKey:@"aggr_type"];
//    if (self.detailModel.relateReadFromGID) {
//        [logv3Dic setValue:[NSString stringWithFormat:@"%@",self.detailModel.relateReadFromGID] forKey:@"from_gid"];
//    }
//    [logv3Dic setValue:@(hasZzComment?1:0) forKey:@"has_zz_comment"];
//    if (hasZzComment) {
//        [logv3Dic setValue:self.detailModel.article.firstZzCommentMediaId forKey:@"mid"];
//    }
//
//    if (self.detailModel.gdExtJsonDict) {
//        [logv3Dic setValuesForKeysWithDictionary:self.detailModel.gdExtJsonDict];
//    }
//
//    [TTTrackerWrapper eventV3:@"go_detail" params:logv3Dic isDoubleSending:YES];
}

- (NSString *)enterFromString {
    
    return [NewsDetailLogicManager enterFromValueForLogV3WithClickLabel:self.detailModel.clickLabel categoryID:self.detailModel.categoryID];
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

- (void)p_sendDetailDeallocTrack
{
    NSString *leaveType;
    if (!_closeButtonTouched) {
        if (_backButtonTouched) {
            wrapperTrackEvent(@"detail", @"back_button");
            leaveType = @"page_back_button";
        }
        else {
            wrapperTrackEvent(@"detail", @"back_gesture");
            leaveType = @"back_gesture";
        }
    }
    else {
        leaveType = @"page_close_button";
    }
}

- (void)p_sendDetailLoadTimeOffLeaveTrack
{
    BOOL stayTooLong = [self.dataSource stayPageTimeInterValForDetailView:self] > 3000.f;
    if (stayTooLong && !self.detailView.domReady) {
        __weak typeof(self) weakSelf = self;
        [self.detailView.detailWebView.webView stringByEvaluatingJavaScriptFromString:@"document.body.innerHTML;" completionHandler:^(NSString * _Nullable result, NSError * _Nullable error) {
            if (error || isEmptyString(result)) {
                NSMutableDictionary *dict = [NSMutableDictionary dictionary];
                [dict setValue:weakSelf.detailModel.article.groupModel.groupID forKey:@"value"];
                [TTTrackerWrapper category:@"article" event:@"detail_load" label:@"loading" dict:dict];
            }
        }];
    }
}

- (void)p_sendEnterCommentTrack
{
    if (_hasSendEnterCommentTrack) {
        return;
    }
    [self p_sendDetailLogicTrackForEvent:@"enter_comment"];
    _hasSendEnterCommentTrack = YES;
}

- (void)p_sendFinishCommentTrack
{
    if (_hasSendFinishCommentTrack) {
        return;
    }
    [self p_sendDetailLogicTrackForEvent:@"finish_comment"];
    _hasSendFinishCommentTrack = YES;
}

- (void)p_sendReadContentTrack
{
    if (_hasSendReadContentTrack) {
        return;
    }
    [self p_sendDetailLogicTrackForEvent:@"read_content"];
    _hasSendReadContentTrack = YES;
}

- (void)p_sendFinishContentTrack
{
    if (_hasSendFinishContentTrack) {
        return;
    }
    [self p_sendDetailLogicTrackForEvent:@"finish_content"];
    _hasSendFinishContentTrack = YES;
}

- (void)p_sendDetailLogicTrackWithLabel:(NSString *)label
{
    [NewsDetailLogicManager trackEventTag:[self.detailView.detailWebView isCommentVisible]? @"comment": @"detail" label:label value:@(self.detailModel.article.uniqueID) extValue:self.detailModel.adID fromID:nil params:self.detailModel.gdExtJsonDict groupModel:self.detailModel.article.groupModel];
}

- (void)p_sendDetailLogicTrackForEvent:(NSString *)event
{
    NSMutableDictionary * dict = [NSMutableDictionary dictionaryWithCapacity:10];
    if (self.detailModel.gdExtJsonDict) {
        [dict setValuesForKeysWithDictionary:self.detailModel.gdExtJsonDict];
    }
    [dict setValue:@"umeng" forKey:@"category"];
    [dict setValue:event forKey:@"tag"];
    [dict setValue:@"article" forKey:@"source"];
    [dict setValue:[self.detailView.detailWebView isManualPullFooter]? @"pull": @"click" forKey:@"action"];
    [dict setValue:self.detailModel.clickLabel forKey:@"label"];
    [dict setValue:@(self.detailModel.article.uniqueID) forKey:@"value"];
    if (!isEmptyString(self.detailModel.article.itemID)) {
        [dict setValue:self.detailModel.article.itemID forKey:@"item_id"];
        [dict setValue:self.detailModel.article.aggrType forKey:@"aggr_type"];
    }
    [dict setValue:self.detailModel.adID forKey:@"ext_value"];
    [TTTrackerWrapper eventData:dict];
}

//懂车帝logo适配
- (void)p_sendLogoViewEventWithEventName:(NSString *)event {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setValue:self.detailModel.article.groupModel.groupID forKey:@"group_id"];
    [params setValue:[TTAccountManager userID] forKey:@"user_id"];
    [params setValue:self.detailModel.article.navTitleType forKey:@"type"];
    [TTTrackerWrapper eventV3:event params:params];
}


#pragma mark - TTArticleDetailViewDelegate

////导流页超时，加载转码页
//- (void)tt_articleDetailViewShouldLoadNativeContent
//{
//    [self p_destructHasLoadedWebDetailView];
//    [self p_buildViews];
//}

- (void)tt_articleDetailViewDidDomReady {
    [self fetchPaidNovelIfNeed];
}

- (void)tt_articleDetailViewWillShowFirstCommentCell
{
    [self p_sendEnterCommentTrack];
    self.commentViewController.hasSelfShown = YES;
    [self.commentViewController tt_sendShowTrackForVisibleCells];
}

- (void)tt_articleDetailViewFooterHalfStatusOffset:(CGFloat)rOffset
{
    //此时footer处于half状态，且webView相对于half起点滚动了rOffset的距离。
    //用于统计露出评论的impressions
    [self.commentViewController tt_sendHalfStatusFooterImpressionsForViableCellsWithOffset:rOffset];
}

- (void)tt_articleDetailViewWillCloseFooter
{
    if (self.detailView.detailWebView.webView.scrollView.contentOffset.y <= self.detailView.storyToolViewAnimationTriggerPosY) {
        [self p_triggerStoryToolViewAnimation:NO];
    }
}

- (void)tt_articleDetailViewWillChangeFontSize
{
    [self p_reloadItemsWithInforManager:self.articleInfoManager];
    _webViewWillChangeFontSize = YES;
}

- (void)tt_articleDetailViewDidChangeFontSize
{
    _webViewWillChangeFontSize = NO;
}

- (void)tt_articleApplicationStautsBarDidRotate {
    [self p_reloadItems];
}

- (void)webView:(nullable TTDetailWebviewContainer *)webViewContainer scrollViewDidScroll:(nullable UIScrollView *)scrollView{
    UIScrollView *targetScrollView = [self.detailView.detailWebView isNewWebviewContainer]? webViewContainer.containerScrollView: webViewContainer.webView.scrollView;
    
    if (scrollView == targetScrollView) {
        if (scrollView.contentOffset.y > webViewContainer.webView.frame.size.height) {
            [self p_sendReadContentTrack];
            if (scrollView.contentOffset.y > webViewContainer.webView.frame.size.height * 2) {
                [self p_sendFinishContentTrack];
            }
        }
        
        if (webViewContainer.footerStatus == TTDetailWebViewFooterStatusDisplayHalf) {
            [self ak_readComplete];
            if (!_enterHalfFooterStatusContentOffset) {
                _enterHalfFooterStatusContentOffset = scrollView.contentOffset.y;
            }
            CGFloat natantScrollOffset = scrollView.contentOffset.y - _enterHalfFooterStatusContentOffset;
            
            if (self.articleInfoManager.dislikeWords.count == 0) {
                [self.natantContainerView sendNatantItemsShowEventWithContentOffset:natantScrollOffset isScrollUp:NO shouldSendShowTrack:YES style:@"report"];
            }
            else {
                [self.natantContainerView sendNatantItemsShowEventWithContentOffset:natantScrollOffset isScrollUp:NO shouldSendShowTrack:YES style:@"report_and_dislike"];
            }
            
            [self.natantContainerView checkVisibleAtContentOffset:natantScrollOffset - self.commentViewController.view.frame.size.height referViewHeight:self.commentViewController.view.frame.size.height];
        }
        
        [self p_updateNavigationTitleViewWithScrollViewContentOffset:scrollView.contentOffset.y];
        
        [self p_updateStoryToolViewWithOffset:scrollView.contentOffset.y];
    }
}

- (void)webView:(nullable TTDetailWebviewContainer *)webViewContainer scrollViewDidEndDragging:(nullable UIScrollView *)scrollView
 willDecelerate:(BOOL)decelerate{
    UIScrollView *targetScrollView = [self.detailView.detailWebView isNewWebviewContainer]? webViewContainer.containerScrollView: webViewContainer.webView.scrollView;
    if (scrollView == targetScrollView) {
        if (webViewContainer.footerStatus != TTDetailWebViewFooterStatusNoDisplay) {
            if (!_enterHalfFooterStatusContentOffset) {
                _enterHalfFooterStatusContentOffset = scrollView.contentOffset.y;
            }
            CGFloat natantScrollOffset = scrollView.contentOffset.y - _enterHalfFooterStatusContentOffset;
                        
            [self.natantContainerView scrollViewDidEndDraggingAtContentOffset:natantScrollOffset - self.commentViewController.view.frame.size.height referViewHeight:self.commentViewController.view.frame.size.height];
        }
    }
}


- (void)tt_articleDetailViewWillShowActionSheet:(NSDictionary *)result {
    self.detailMenuController = [[TTArticleDetailMenuController alloc] init];
    WeakSelf;
    [self.detailMenuController performMenuAndInsertData:result article:self.detailModel.article dismiss:^{
        StrongSelf;
        self.detailMenuController = nil;
    }];
}

#pragma mark - TTDetailNatantContainerDatasource

- (Article *)getCurrentArticle
{
    return self.detailModel.article;
}

- (NSString *)getCatagoryID
{
    return self.detailModel.categoryID;
}

- (NSDictionary *)getLogPb
{
    return self.detailModel.logPb;
}

#pragma mark - TTCommentDataSource & TTCommentDelegate

- (void)tt_loadCommentsForMode:(TTCommentLoadMode)loadMode
        possibleLoadMoreOffset:(NSNumber *)offset
                       options:(TTCommentLoadOptions)options
                   finishBlock:(TTCommentLoadFinishBlock)finishBlock
{
    TTCommentDataManager *commentDataManager = [[TTCommentDataManager alloc] init];
    [commentDataManager startFetchCommentsWithGroupModel:self.detailModel.article.groupModel forLoadMode:loadMode  loadMoreOffset:offset loadMoreCount:@(TTCommentDefaultLoadMoreFetchCount) msgID:self.detailModel.msgID options:options finishBlock:finishBlock];
}

- (SSThemedView *)tt_commentHeaderView
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

- (BOOL)tt_canDeleteComments
{
    return NO;
}

- (void)tt_commentViewControllerDidFetchCommentsWithError:(NSError *)error
{
    //点击评论进入文章时跳转到评论区
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self p_scrollToCommentIfNeeded];
    });
    
    if ([self.commentViewController respondsToSelector:@selector(tt_defaultReplyCommentModel)] && self.commentViewController.tt_defaultReplyCommentModel) {
        NSString *userName = self.commentViewController.tt_defaultReplyCommentModel.userName;
        [self.toolbarView.writeButton setTitle:isEmptyString(userName)? @"写评论": [NSString stringWithFormat:@"回复 %@：", userName] forState:UIControlStateNormal];
    }
    
    // toolbar 禁表情
    BOOL isBanRepostOrEmoji = ![KitchenMgr getBOOL:KKCCommentRepostFirstDetailEnable] || (self.detailModel.adID > 0) || ak_banEmojiInput();
    if ([self.commentViewController respondsToSelector:@selector(tt_banEmojiInput)]) {
        self.toolbarView.banEmojiInput = self.commentViewController.tt_banEmojiInput || isBanRepostOrEmoji;
    }
    
    [self.detailView tt_serverRequestTimeMonitorWithName:@"comment" error:error];
}

- (void)tt_commentViewController:(id<TTCommentViewControllerProtocol>)ttController digCommentWithCommentModel:(id<TTCommentModelProtocol>)model
{
    if (!model.userDigged) {
        NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithCapacity:5];
        [params setValue:@"house_app2c_v2" forKey:@"event_type"];
        [params setValue:self.detailModel.article.groupModel.groupID forKey:@"group_id"];
        [params setValue:self.detailModel.article.groupModel.itemID forKey:@"item_id"];
        [params setValue:model.commentID.stringValue forKey:@"comment_id"];
        [params setValue:model.userID.stringValue forKey:@"user_id"];
        [params setValue:self.detailModel.orderedData.logPb forKey:@"log_pb"];
        [params setValue:self.detailModel.orderedData.categoryID forKey:@"category_name"];
        [params setValue:self.detailModel.clickLabel forKey:@"enter_from"];
        [TTTrackerWrapper eventV3:@"comment_undigg" params:params];
    } else {
        NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithCapacity:5];
        [params setValue:@"house_app2c_v2" forKey:@"event_type"];
        [params setValue:self.detailModel.article.groupModel.groupID forKey:@"group_id"];
        [params setValue:self.detailModel.article.groupModel.itemID forKey:@"item_id"];
        [params setValue:model.commentID.stringValue forKey:@"comment_id"];
//        [params setValue:model.userID.stringValue forKey:@"user_id"];
        [params setValue:self.detailModel.orderedData.logPb forKey:@"log_pb"];
        [params setValue:self.detailModel.orderedData.categoryID forKey:@"category_name"];
        [params setValue:[FHTraceEventUtils generateEnterfrom:self.detailModel.orderedData.categoryID] forKey:@"enter_from"];
        [params setValue:@"comment" forKey:@"position"];
        [TTTrackerWrapper eventV3:@"rt_like" params:params];
    }
}

- (void)tt_commentViewController:(id<TTCommentViewControllerProtocol>)ttController didClickCommentCellWithCommentModel:(id<TTCommentModelProtocol>)model
{
}

- (void)tt_commentViewController:(id<TTCommentViewControllerProtocol>)ttController didClickReplyButtonWithCommentModel:(nonnull id<TTCommentModelProtocol>)model
{
}

- (void)tt_commentViewController:(id<TTCommentViewControllerProtocol>)ttController avatarTappedWithCommentModel:(id<TTCommentModelProtocol>)model
{
    // add by zjing 去掉个人主页跳转
    return;
    
    if ([model.userID longLongValue] == 0) {
        return;
    }
    
    NSString * userID = [NSString stringWithFormat:@"%@", model.userID];
    NSMutableString *linkURLString = [NSMutableString stringWithFormat:@"sslocal://media_account?uid=%@", userID];
    
    NSString *trackLinkString = [TTUGCTrackerHelper schemaTrackForPersonalHomeSchema:linkURLString categoryName:self.detailModel.categoryID fromPage:@"detail_article_comment" groupId:self.detailModel.article.groupModel.groupID profileUserId:nil];
    [[TTRoute sharedRoute] openURLByPushViewController:[TTNetworkUtil URLWithURLString:trackLinkString]];
    
}

- (void)tt_commentViewController:(id<TTCommentViewControllerProtocol>)ttController tappedWithUserID:(NSString *)userID {
    if ([userID longLongValue] == 0) {
        return;
    }
    NSString *userIDstr = [NSString stringWithFormat:@"%@", userID];
    
    NSMutableString *linkURLString = [NSMutableString stringWithFormat:@"sslocal://media_account?uid=%@", userIDstr];
    
    [[TTRoute sharedRoute] openURLByPushViewController:[NSURL URLWithString:linkURLString]];
    
}

- (void)tt_commentViewController:(id<TTCommentViewControllerProtocol>)ttController startWriteComment:(id<TTCommentModelProtocol>)model
{
    [self p_willOpenWriteCommentViewWithReservedText:nil switchToEmojiInput:NO];
}

- (void)tt_commentViewController:(id <TTCommentViewControllerProtocol>)ttController
             scrollViewDidScroll:(nonnull UIScrollView *)scrollView{
    CGFloat offsetPadding = 0;
    //modified 5.7:此处如果按照之前逻辑，评论较少文章当浮层弹起时广告露出了却没发。和安卓商量后改回最初逻辑，统一发送
    //    BOOL shouldSendShowTrack = !_isScrollingTriggeredByCommentButtonClicked;
    BOOL shouldSendShowTrack = YES;
    [self.natantContainerView sendNatantItemsShowEventWithContentOffset:scrollView.contentOffset.y isScrollUp:YES shouldSendShowTrack:shouldSendShowTrack];
    [self.natantContainerView checkVisibleAtContentOffset:scrollView.contentOffset.y+offsetPadding referViewHeight:scrollView.height];
}

- (void)tt_commentViewController:(id<TTCommentViewControllerProtocol>)ttController didSelectWithInfo:(NSDictionary *)info {
    NSMutableDictionary *mdict = info.mutableCopy;
    [mdict setValue:@"detail_article_comment_dig" forKey:@"fromPage"];
    [mdict setValue:self.detailModel.categoryID forKey:@"categoryName"];
    [mdict setValue:self.detailModel.article.groupModel.groupID forKey:@"groupId"];
    [mdict setValue:self.detailModel.article forKey:@"group"];
    
    [mdict setValue:self.detailModel.categoryID forKey:@"categoryID"];
    [mdict setValue:self.detailModel.clickLabel forKey:@"enterFrom"];
    [mdict setValue:self.detailModel.logPb forKey:@"logPb"];

    TTCommentDetailViewController *detailRoot = [[TTCommentDetailViewController alloc] initWithRouteParamObj:TTRouteParamObjWithDict(mdict.copy)];
    
    detailRoot.categoryID = self.detailModel.categoryID;
    detailRoot.enterFrom = self.detailModel.clickLabel;
    detailRoot.logPb = self.detailModel.logPb;

    TTModalContainerController *navVC = [[TTModalContainerController alloc] initWithRootViewController:detailRoot];
    navVC.containerDelegate = self;
    if ([TTDeviceHelper OSVersionNumber] < 8.0f) {
        self.commentViewController.view.window.rootViewController.modalPresentationStyle = UIModalPresentationCurrentContext;
        [self.commentViewController presentViewController:navVC animated:NO completion:nil];
        self.commentViewController.view.window.rootViewController.modalPresentationStyle = UIModalPresentationFullScreen;
    }
    else {
        [self.commentViewController presentViewController:navVC animated:NO completion:nil];
    }
    
    
    //停止评论时间
    if (self.commentShowDate) {
        NSTimeInterval timeInterval = [[NSDate date] timeIntervalSinceDate:self.commentShowDate];
        self.commentShowTimeTotal += timeInterval*1000;
        self.commentShowDate = nil;
    }
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

#pragma mark - TTModalContainerDelegate

- (void)didDismissModalContainerController:(TTModalContainerController *)container {
    [[UIApplication sharedApplication] setStatusBarStyle:[[TTThemeManager sharedInstance_tt] currentThemeMode] == TTThemeModeDay? UIStatusBarStyleDefault: UIStatusBarStyleLightContent];
    if ([self.commentViewController respondsToSelector:@selector(tt_reloadData)]) {
        [self.commentViewController tt_reloadData];
    }
    
    //续上评论列表时间
    self.commentShowDate = [NSDate date];
}

#pragma mark - TTWriteCommentViewDelegate

- (void)commentView:(TTCommentWriteView *) commentView sucessWithCommentWriteManager:(TTCommentWriteManager *)commentWriteManager responsedData:(NSDictionary *)responseData
{
    commentWriteManager.delegate = nil;
    self.commentViewController.hasSelfShown = YES;
    if(![responseData objectForKey:@"error"])  {
        [commentView dismissAnimated:YES];
        Article *article = self.detailModel.article;
        article.commentCount = article.commentCount + 1;
        NSMutableDictionary * data = [NSMutableDictionary dictionaryWithDictionary:[responseData objectForKey:@"data"]];
        [self.commentViewController tt_insertCommentWithDict:data];
        [self.commentViewController tt_markStickyCellNeedsAnimation];

        if ([self.detailView.detailWebView isNewWebviewContainer]) {
            if (![self.detailView.detailWebView isNatantViewOnOpenStatus]) {
                [self p_sendNatantViewVisableTrack];
            }
            [self.detailView.detailWebView openFirstCommentIfNeed];
        } else {
            [self.commentViewController tt_commentTableViewScrollToTop];
            if (![self.detailView.detailWebView isNatantViewOnOpenStatus]) {
                [self.detailView.detailWebView openFooterView:NO];
                [self p_sendNatantViewVisableTrack];
            }
        }

    }
}


#pragma mark - UIViewControllerErrorHandler

- (BOOL)tt_hasValidateData
{
    if ([self.detailModel.article.articleDeleted boolValue]) {
        self.ttViewType = TTFullScreenErrorViewTypeDeleted;
        return NO;
    }
    return YES;
}

//- (UIView *)animationFromView
//{
//    return nil;
//}

#pragma mark - UIKeyboardWillHideNotification
- (void)keyboardDidHide {
    [self.commentWriteView dismissAnimated:NO];
}

#pragma mark - TTInteractExitProtocol

- (UIView *)suitableFinishBackView{
    return _detailView;
}

- (void)viewSafeAreaInsetsDidChange
{
    [super viewSafeAreaInsetsDidChange];
}

@end


