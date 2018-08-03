//
//  TTVideoTabViewController.m
//  Article
//
//  Created by yuxin on 7/27/15.
//
//

#import "TTVideoTabViewController.h"
#import "SSNavigationBar.h"
#import "ExploreMovieView.h"
#import "UIScrollView+Refresh.h"
#import "TTArticleTabBarController.h"
#import "TTCategorySelectorView.h"
#import "TTVideoCategoryManager.h"
#import "TTCollectionPageViewController.h"
#import "TTCollectionListPageCell.h"

#import "ExploreSearchViewController.h"
#import "ArticleURLSetting.h"
#import "NewsListLogicManager.h"

#import "TTNetworkManager.h"
#import "TTReachability.h"

#import "TTFeedRefreshView.h"
#import "NewsBaseDelegate.h"
#import "ExploreMixedListView.h"

#import "UIViewController+NavigationBarStyle.h"

#import "TTVideoPGCBar.h"

#import "TTPGCFetchManager.h"
#import "ExploreEntryManager.h"
#import "UIViewController+Track.h"

#import "UIViewController+RefreshEvent.h"
#import <Crashlytics/Crashlytics.h>
#import "TTCustomAnimationNavigationController.h"

#import "TTTopBar.h"
#import "TTProfileViewController.h"
#import "TTAccountBindingMobileViewController.h"
#import "TTPushAlertManager.h"
#import <ReactiveObjC/ReactiveObjC.h>
#import "TTTabBarProvider.h"

@interface CategoryBackView : SSThemedView
@end

@implementation CategoryBackView

@end


@interface TTVideoTabViewController ()
<
TTCategorySelectorViewDelegate,
TTCollectionPageViewControllerDelegate,
TTCollectionListPageCellDelegate,
TTAccountMulticastProtocol,
TTTopBarDelegate
>
{
    BOOL showPGC;
    BOOL shouldUpdatePGCStatus;
    BOOL _isFirstShow;
}

@property (nonatomic, strong) TTCollectionPageViewController *pageViewController;
@property (nonatomic, strong) TTCategorySelectorView *categorySelectorView;
@property (nonatomic, strong) CategoryBackView *selectorBackView;
@property (nonatomic, strong) TTVideoPGCBar *pgcCell;
@property (nonatomic, strong) UIView *barView;

@property (nonatomic, assign) NSInteger lastSelectedPageIndex;

@property (nonatomic, strong) NSArray *categories;

@property (nonatomic) CGFloat topInset;
@property (nonatomic) CGFloat bottomInset;

@property (nonatomic, strong) TTFeedRefreshView *feedRefreshView;

@property (nonatomic, strong) TTTopBar *topBar;
@property (nonatomic, assign) BOOL topBarEnable;
@end

@implementation TTVideoTabViewController

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [TTAccount removeMulticastDelegate:self];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.hidesBottomBarWhenPushed = NO;
    }
    return self;
}

- (instancetype)init {
    if (self = [super init]) {
        if ([SSCommonLogic shouldUseOptimisedLaunch]) {
            self.hidesBottomBarWhenPushed = NO;
            self.ttStatusBarStyle = UIStatusBarStyleDefault;
        }
    }
    return self;
}


- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    _isFirstShow = YES;
    self.ttTrackStayEnable = YES;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(connectionChanged:) name:kReachabilityChangedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveVideoTabbarClickedNotification:) name:kVideoTabbarKeepClickedNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(videoPGCStatusChanged:) name:kVideoPGCStatusChangedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(subscribeStatusChanged:) name:kPGCSubscribeStatusChangedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(subscribeStatusChanged:) name:kVideoDetailPGCSubscribeStatusChangedNotification object:nil];
    
    [TTAccount addMulticastDelegate:self];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    [self setInset];
    
    [self addChildViewController:self.pageViewController];
    [self.view addSubview:self.pageViewController.view];
    
    if ([TTDeviceHelper isPadDevice]) {
        [self.view addSubview:self.barView];
    } else {
        if (self.topBarEnable){
            [self.topBar setupSubviews];
        }else{
            [self initSelectorView];
        }
    }
    
    [self setupConstraints];
    [self fetchCategoryData];
    
    self.lastSelectedPageIndex = 0;
    
    // FeedRefreshView
    [self setupFeedRefreshView];
    
    [self fetchVideoPGC];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if ([TTDeviceHelper isPadDevice] || self.topBarEnable) {
        self.ttHideNavigationBar = YES;
        self.ttStatusBarStyle = UIStatusBarStyleLightContent;
    } else {
        self.ttHideNavigationBar = NO;
    }
    
    [self hiddenFeedRefreshViewIfNeeded];
    
    if (shouldUpdatePGCStatus) {
        shouldUpdatePGCStatus = NO;
        [self fetchVideoPGC];
    }
    if ([[self.pageViewController currentCollectionPageCell] respondsToSelector:@selector(willAppear)]) {
        [[self.pageViewController currentCollectionPageCell] willAppear];
    }
    if (_isFirstShow) {
        _isFirstShow = NO;
        if (self.categories.count > 0) {
            [self categorySelectorView:self.categorySelectorView selectCategory:self.categories[0]];
        }
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if ([[self.pageViewController currentCollectionPageCell] respondsToSelector:@selector(didAppear)]) {
        [[self.pageViewController currentCollectionPageCell] didAppear];
    }
    
    [TTPushAlertManager enterFeedPage:TTPushWeakAlertPageTypeWatermelonVideoFeed];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if ([[self.pageViewController currentCollectionPageCell] respondsToSelector:@selector(willDisappear)]) {
        [[self.pageViewController currentCollectionPageCell] willDisappear];
    }
    
    [TTPushAlertManager leaveFeedPage:TTPushWeakAlertPageTypeWatermelonVideoFeed];
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    [_feedRefreshView resetFrameWithSuperviewFrame:self.view.frame bottomInset:_bottomInset];
}

- (void)setupConstraints
{
    if ([TTDeviceHelper isPadDevice]) {
        [self.barView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.top.right.equalTo(self.view);
            make.height.mas_equalTo(self.topInset);
        }];
    }
    
    [self.pageViewController.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
}

#pragma mark -
#pragma mark init

- (void)initSelectorView
{
    self.selectorBackView = [[CategoryBackView alloc] initWithFrame:CGRectMake(0, -[self statusBarHeight], self.view.width, [self statusBarHeight] + kTopSearchButtonHeight)];
    
    CGFloat selectorHeight = 37.0f;
    
    [self.selectorBackView addSubview:self.categorySelectorView];
    
    self.selectorBackView.backgroundColorThemeKey = self.categorySelectorView.backgroundColorThemeKey;
    
    [self.categorySelectorView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.selectorBackView);
        make.height.mas_equalTo(selectorHeight);
        make.bottom.equalTo(self.selectorBackView);
    }];
    
    @weakify(self);
    [[[RACObserve(self, ttNavigationBar) ignore:nil] take:1] subscribeNext:^(id x) {
        @strongify(self);
        [self.ttNavigationBar addSubview:self.selectorBackView];
    }];
}

- (void)setCategories:(NSArray *)categories
{
    if (_categories != categories) {
        _categories = categories;
        if ([categories count] > 0) {
            [self.categorySelectorView refreshWithCategories:categories];
            self.pageViewController.pageCategories = categories;
            [self categorySelectorView:self.categorySelectorView selectCategory:categories[0]];
        }
    }
}

#pragma mark - TTAccountMulticastProtocol

- (void)onAccountStatusChanged:(TTAccountStatusChangedReasonType)reasonType platform:(NSString *)platformName
{
    shouldUpdatePGCStatus = YES;
}

#pragma mark - methods

- (void)subscribeStatusChanged:(NSNotification *)noti
{
    shouldUpdatePGCStatus = YES;
}

- (void)videoPGCStatusChanged:(NSNotification *)noti
{
    NSDictionary *info = noti.userInfo;
    BOOL show = [info[@"show"] boolValue];
    if (show) {
        [self fetchVideoPGC];
    } else {
        [self showPGCBar:NO model:nil];
    }
}

- (void)fetchVideoPGC
{
    BOOL shouldShow = [TTPGCFetchManager shouldShowVideoPGC];
    if ([TTDeviceHelper isPadDevice] || !shouldShow) {
        return;
    }
    
    TTPGCFetchManager *fetcher = [[TTPGCFetchManager alloc] init];
    [fetcher startFetchWithCompletion:^(TTVideoPGCViewModel *model, NSError *error) {
        if (model && [model.message isEqualToString:@"success"]) {
            [self showPGCBar:YES model:model];
            if (self.pageViewController.currentPage == 0) {
                TTCollectionListPageCell *cell = (TTCollectionListPageCell *)self.pageViewController.currentCollectionPageCell;
                [cell setHeaderView:self.pgcCell];
            }
        } else {
            [self showPGCBar:NO model:nil];
        }
    }];
}

- (void)showPGCBar:(BOOL)show model:(TTVideoPGCViewModel *)model
{
    if (show && model) {
        self.pgcCell.viewModel = model;
        showPGC = YES;
    } else {
        self.pgcCell = nil;
        showPGC = NO;
    }
}

- (void)receiveVideoTabbarClickedNotification:(NSNotification*)notification
{
    if([[self.pageViewController currentCollectionPageCell] isKindOfClass:[TTCollectionListPageCell class]]){
        //5.7新增，对于视频Tab 点击底部tabbar刷新事件
        //在刷新之前将对应的listview的refreshFromType设置为正确的值
        BOOL hasTip = [[[notification userInfo] objectForKey:kMainTabbarClickedNotificationUserInfoHasTipKey] boolValue];
        
        TTCollectionListPageCell *collectionListPageCell = (TTCollectionListPageCell *)[self.pageViewController currentCollectionPageCell];
        TTCategory *category = collectionListPageCell.category;
        ExploreMixedListView *mixedListView = collectionListPageCell.listView;
        NSString *label = nil;
        
        NSString *event = nil;
        if([category.categoryID isEqualToString:kTTMainCategoryID]){
            event = @"new_tab";
        }
        else{
            event = @"category";
        }
        
        if(hasTip){
            mixedListView.listView.refreshFromType = ListDataOperationReloadFromTypeTabWithTip;
            label = @"tab_refresh_tip";
        }
        else{
            mixedListView.listView.refreshFromType = ListDataOperationReloadFromTypeTab;
            label = @"tab_refresh";
        }
        label = [self modifyEventLabelForRefreshEvent:label categoryModel:category];
        
        wrapperTrackEvent(event, label);
    }
    
    [self.pageViewController reloadCurrentPage];
}

- (void)connectionChanged:(NSNotification *)noti
{
    TLS_LOG(@"connectionChanged");
    if ([self.categories count] == 0) {
        TTReachability *reachability = noti.object;
        if (reachability.currentReachabilityStatus == ReachableViaWiFi) {
            [self fetchCategoryData];
        }
    }
}

- (void)fetchCategoryData
{
    //先加载本地默认数据
    self.categories = [[TTVideoCategoryManager sharedManager] videoCategoriesWithDataDicts:nil];
    [[TTNetworkManager shareInstance] requestForJSONWithURL:[CommonURLSetting videoCategoryURLString] params:nil method:@"GET" needCommonParams:YES callback:^(NSError *error, id jsonObj) {
        if (!error) {
            if ([jsonObj isKindOfClass:[NSDictionary class]]) {
                NSArray *categories = jsonObj[@"data"];
                self.categories = [[TTVideoCategoryManager sharedManager] videoCategoriesWithDataDicts:categories];
            }
        }
    }];
}

- (void)setInset
{
    CGFloat bottomPadding = 0;
    CGFloat topPadding = 0;
    
    if ([TTDeviceHelper isPadDevice]) {
        topPadding = 64 + kSelectorViewHeight;
        bottomPadding = 0;
    } else {
        topPadding = 20 + kTopSearchButtonHeight + kSelectorViewHeight;
        bottomPadding = 44;
    }

    self.topInset = topPadding;
    self.bottomInset = bottomPadding;
}

#pragma mark -
#pragma mark accessors

- (TTCollectionPageViewController *)pageViewController
{
    if (!_pageViewController) {
        _pageViewController = [[TTCollectionPageViewController alloc] initWithTabType:TTCategoryModelTopTypeVideo cellClass:NSStringFromClass([TTCollectionListPageCell class])];
        _pageViewController.delegate = self;
    }
    return _pageViewController;
}

- (TTCategorySelectorView *)categorySelectorView
{
    if (!_categorySelectorView) {
        TTCategorySelectorViewTabType tabType = self.topBarEnable ? TTCategorySelectorViewNewVideoTab : TTCategorySelectorViewVideoTab;
        TTCategorySelectorViewStyle selectorViewStyle = self.topBarEnable ? TTCategorySelectorViewNewVideoStyle : TTCategorySelectorViewVideoStyle;
        _categorySelectorView = [[TTCategorySelectorView alloc] initWithFrame:CGRectZero style:selectorViewStyle tabType:tabType];
        _categorySelectorView.delegate = self;
        
        if ([TTDeviceHelper isPadDevice]) {
            [_categorySelectorView hideExpandButton];
        }
    }
    return _categorySelectorView;
}

- (UIView *)barView
{
    if (!_barView) {
        _barView = [[UIView alloc] init];
        
        CGFloat statusBarHeight = [self statusBarHeight];
        
        [_barView addSubview:self.categorySelectorView];
        
        CGFloat selectorViewHeight = 44;
        
        [self.categorySelectorView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(_barView);
            make.height.mas_equalTo(selectorViewHeight);
            if ([TTDeviceHelper isPadDevice]) {
                make.bottom.equalTo(_barView);
            } else {
                make.centerY.equalTo(_barView).offset(statusBarHeight / 2);
            }
        }];
    }
    return _barView;
}

- (TTVideoPGCBar *)pgcCell
{
    if (!_pgcCell) {
        _pgcCell = [[TTVideoPGCBar alloc] initWithFrame:CGRectMake(0, 0, self.view.width, kVideoPGCBarHeight)];
        _pgcCell.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    }
    return _pgcCell;
}

- (CGFloat)statusBarHeight
{
    return self.view.tt_safeAreaInsets.top == 0 ? 20.f : self.view.tt_safeAreaInsets.top;
}

#pragma mark -
#pragma mark Selector delegate

- (void)categorySelectorView:(TTCategorySelectorView *)selectorView selectCategory:(TTCategory *)category
{
    
    
    //统计针对外面是点击的事件
    NSString *categoryID = category.categoryID;
    if ([categoryID isEqualToString:@"hotsoon"]) {
        categoryID = @"subv_hotsoon";
    }
    
    
    NSUInteger index = NSNotFound;
    index = [self.categories indexOfObject:category];
    if (index != NSNotFound) {
        [self.pageViewController setCurrentPage:index scrollToPositionCenteredAnimated:NO];
        [selectorView selectCategory:category];
        if (self.lastSelectedPageIndex != index) {
            
            [ExploreMovieView removeAllExploreMovieView];
            
            self.lastSelectedPageIndex = index;
            
            NSString *label = [NSString stringWithFormat:@"%@_%@", @"enter_click", category.categoryID];
            wrapperTrackEvent(@"category", label);
        } else {
            //5.7 新增对于视频Tab刷新统计
            //针对点击频道名刷新
            //在刷新之前将对应的listview的refreshFromType设置为正确的值
            if([[self.pageViewController currentCollectionPageCell] isKindOfClass:[TTCollectionListPageCell class]]){
                BOOL hasTip = [self isTabbarHasTip];
                TTCollectionListPageCell *collectionListPageCell = (TTCollectionListPageCell *)[self.pageViewController currentCollectionPageCell];
                
                NSString *event = nil;
                if([category.categoryID isEqualToString:kTTMainCategoryID]){
                    event = @"new_tab";
                }
                else{
                    event = @"category";
                }
                
                ExploreMixedListView *mixedListView = collectionListPageCell.listView;
                NSString *label = nil;
                if(hasTip){
                    mixedListView.listView.refreshFromType = ListDataOperationReloadFromTypeClickCategoryWithTip;
                    label = @"refresh_click_tip";
                }
                else{
                    mixedListView.listView.refreshFromType = ListDataOperationReloadFromTypeClickCategory;
                    label = @"refresh_click";
                }
                label = [self modifyEventLabelForRefreshEvent:label categoryModel:category];
                
                wrapperTrackEvent(event, label);
            }
            
            [self.pageViewController reloadCurrentPage];
        }
    }
}

- (void)categorySelectorView:(TTCategorySelectorView *)selectorView didClickExpandButton:(UIButton *)expandButton
{
    ExploreSearchViewController * viewController = [[ExploreSearchViewController alloc] initWithNavigationBar:YES showBackButton:NO queryStr:nil fromType:ListDataSearchFromTypeVideo];
    
    [ExploreMovieView removeAllExploreMovieView];
    
    if ([TTDeviceHelper isPadDevice] || ![SSCommonLogic isSearchTransitionEnabled]) {
        viewController.animatedWhenDismiss = NO;
        [self.navigationController pushViewController:viewController animated:YES];
        [TTCustomAnimationManager sharedManager].pushSearchVCWithCustomAnimation = NO;
    }
    else{
        viewController.animatedWhenDismiss = YES;
        [((TTNavigationController *)self.navigationController) pushViewControllerByTransitioningAnimation:viewController animated:YES];
        [TTCustomAnimationManager sharedManager].pushSearchVCWithCustomAnimation = YES;
    }
    wrapperTrackEvent(@"video", @"video_tab_search");
}

#pragma mark -
#pragma mark Page View Controller Delegate

- (void)pageViewController:(TTCollectionPageViewController *)pageViewController pagingFromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex completePercent:(CGFloat)percent
{
    
    [self.categorySelectorView moveSelectFrameFromIndex:fromIndex toIndex:toIndex percentage:percent];
    
    //统计针对外面是滑动的事件
    if (percent == 0 && fromIndex < self.categorySelectorView.categories.count) {
        TTCategory *category = [self.categorySelectorView.categories objectAtIndex:fromIndex];
        NSString *categoryID = category.categoryID;
        if ([categoryID isEqualToString:@"hotsoon"]) {
            categoryID = @"subv_hotsoon";
        }
        NSString *labelString = [NSString stringWithFormat:@"enter_flip_%@",categoryID];
        wrapperTrackEventWithCustomKeys(@"category", labelString, nil, nil, @{@"category_id":categoryID});
    }
}

- (void)pageViewController:(TTCollectionPageViewController *)pageViewController didPagingToIndex:(NSInteger)toIndex
{
    [self.categorySelectorView selectCategory:self.categories[toIndex]];
    if (self.lastSelectedPageIndex != toIndex) {
        
        [ExploreMovieView removeAllExploreMovieView];
        
        self.lastSelectedPageIndex = toIndex;
        
        TTCategory *currCategoryModel = self.categories[toIndex];
        NSString *label = [NSString stringWithFormat:@"%@_%@", @"enter_flip", currCategoryModel.categoryID];
        wrapperTrackEvent(@"category", label);
    }
}

- (void)pageViewController:(TTCollectionPageViewController *)pageViewController willPagingToIndex:(NSInteger)toIndex
{
    [self.categorySelectorView scrollToCategory:self.categories[toIndex]];
}

#pragma mark - FeedRefreshView

- (void)setupFeedRefreshView
{
    _feedRefreshView = [[TTFeedRefreshView alloc] init];
    [_feedRefreshView.arrowBtn addTarget:self action:@selector(feedRefreshButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_feedRefreshView];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleRefreshButtonSettingEnabledNotification:) name:kFeedRefreshButtonSettingEnabledNotification object:nil];
}

- (void)feedRefreshButtonPressed:(id)sender
{
    TTCollectionListPageCell *cell = (TTCollectionListPageCell *)[_pageViewController currentCollectionPageCell];
    [cell triggerPullRefresh];
    
    wrapperTrackEvent(@"refresh", [NSString stringWithFormat:@"video_%@", cell.category.categoryID]);
}

- (void)handleRefreshButtonSettingEnabledNotification:(NSNotification *)notification
{
    [self.feedRefreshView endLoading];
    [self hiddenFeedRefreshViewIfNeeded];
}

- (void)hiddenFeedRefreshViewIfNeeded
{
    self.feedRefreshView.hidden = !([SSCommonLogic refreshButtonSettingEnabled] && [SSCommonLogic showRefreshButton]);
}

- (BOOL)shouldAnimateRefreshViewWithPageCell:(TTCollectionListPageCell *)cell
{
    return !(PULL_REFRESH_STATE_LOADING == cell.listView.listView.listView.pullUpView.state);
}

#pragma mark - TTCollectionListPageCellDelegate Methods

- (void)listViewOfTTCollectionPageCellStartLoading:(TTCollectionListPageCell *)collectionPageCell
{
    if (!_feedRefreshView.hidden && [self shouldAnimateRefreshViewWithPageCell:collectionPageCell]) {
        [_feedRefreshView startLoading];
    }
}

- (void)listViewOfTTCollectionPageCellEndLoading:(TTCollectionListPageCell *)collectionPageCell
{
    if (!_feedRefreshView.hidden && [self shouldAnimateRefreshViewWithPageCell:collectionPageCell]) {
        [_feedRefreshView endLoading];
    }
    [collectionPageCell setHeaderView:[self headerViewForCell:collectionPageCell]];
}

- (UIView *)headerViewForCell:(TTCollectionListPageCell *)collectionPageCell
{
    TTCategory *category = collectionPageCell.category;
    BOOL shouldShow = [TTPGCFetchManager shouldShowVideoPGC];
    if (showPGC && shouldShow && category == self.categories[0]) {
        return self.pgcCell;
    } else {
        return nil;
    }
}

#pragma mark - Getter
- (BOOL)topBarEnable{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _topBarEnable = [SSCommonLogic threeTopBarEnable];
    });
    return _topBarEnable;
}

- (TTTopBar *)topBar {
    if (!_topBar) {
        _topBar = [[TTTopBar alloc] init];
        _topBar.tab = @"video";
        [self.view addSubview:_topBar];
        [_topBar addTTCategorySelectorView:self.categorySelectorView delegate:self];
        _topBar.frame = CGRectMake(0, 0, self.view.width, self.topInset);
        _topBar.delegate = self;
    }
    return _topBar;
}

#pragma safeInset
- (void)viewSafeAreaInsetsDidChange
{
    [super viewSafeAreaInsetsDidChange];
    if (self.navigationController.topViewController != self) {
        return;
    }
    
    UIEdgeInsets safeInset = self.view.safeAreaInsets;
    if (safeInset.top > self.topInset) {
        self.topInset = safeInset.top;
        if (self.topBarEnable) {
            self.topBar.height = self.topInset;
        }
        if (self.selectorBackView) {
            self.selectorBackView.top = -[self statusBarHeight];
            self.selectorBackView.height = [self statusBarHeight] + kTopSearchButtonHeight;
        }
    }
}

- (UIEdgeInsets)additionalSafeAreaInsets
{
    return self.topBarEnable ? UIEdgeInsetsMake(kTopSearchButtonHeight + kSelectorViewHeight, 0, 0, 0) : UIEdgeInsetsZero;
}

@end
