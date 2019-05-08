//
//  TTVVideoTabViewController.m
//  Article
//
//  Created by yuxin on 7/27/15.
//
//

#import "TTVVideoTabViewController.h"
#import "SSNavigationBar.h"
#import "ExploreMovieView.h"
#import "UIScrollView+Refresh.h"
#import "TTCategorySelectorView.h"
#import "TTVideoCategoryManager.h"
#import "TTCollectionPageViewController.h"
#import "TTVFeedListPageCell.h"
#import "ExploreSearchViewController.h"
#import "NewsListLogicManager.h"
#import "TTVFeedListViewController.h"
#import "TTNetworkManager.h"
#import "TTReachability.h"
#import "TTArticleTabBarController.h"
#import "TTFeedRefreshView.h"
#import "NewsBaseDelegate.h"
#import "UIViewController+NavigationBarStyle.h"

#import "TTVideoPGCBar.h"

#import "TTPGCFetchManager.h"
#import "ExploreEntryManager.h"
#import "UIViewController+Track.h"

#import "UIViewController+RefreshEvent.h"
#import <Crashlytics/Crashlytics.h>
#import "TTCustomAnimationNavigationController.h"
#import "TTCollectionListPageCell.h"
#import "TTTopBar.h"
#import "TTProfileViewController.h"
#import "TTAccountBindingMobileViewController.h"
#import <Aspects/Aspects.h>
#import <TTSettingsManager/TTSettingsManager.h>
#import <ReactiveObjC/ReactiveObjC.h>
#import "TTTabBarProvider.h"
#import "TTTopBarManager.h"
#import "TTVPlayVideo.h"
#import "TTCustomAnimationDelegate.h"

extern BOOL ttsettings_showRefreshButton(void);

@interface TTVCategoryBackView : SSThemedView
@end

@implementation TTVCategoryBackView

@end

@interface TTVVideoTabViewController () <TTCategorySelectorViewDelegate, TTCollectionPageViewControllerDelegate, TTVFeedListPageCellDelegate, TTAccountMulticastProtocol, TTTopBarDelegate>
{
    BOOL showPGC;
    BOOL shouldUpdatePGCStatus;
    BOOL _isFirstShow;
}

@property (nonatomic, strong) TTCollectionPageViewController *pageViewController;
@property (nonatomic, strong) TTCategorySelectorView *categorySelectorView;
@property (nonatomic, strong) TTVCategoryBackView *selectorBackView;
@property (nonatomic, strong) TTVideoPGCBar *pgcCell;
@property (nonatomic, strong) UIView *barView;

@property (nonatomic, assign) NSInteger lastSelectedPageIndex;

@property (nonatomic, strong) NSArray *categories;

@property (nonatomic) CGFloat topInset;
@property (nonatomic) CGFloat bottomInset;

@property (nonatomic, strong) TTFeedRefreshView *feedRefreshView;

@property (nonatomic, strong) TTTopBar *topBar;

@end

@implementation TTVVideoTabViewController

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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
        BOOL result = [[[TTSettingsManager sharedManager] settingForKey:@"should_optimize_launch" defaultValue:@YES freeze:NO] boolValue];
        if (result) {
            self.hidesBottomBarWhenPushed = NO;
            self.ttStatusBarStyle = UIStatusBarStyleLightContent;
//            [[UIApplication sharedApplication] aspect_hookSelector:@selector(setStatusBarStyle:) withOptions:AspectPositionAfter usingBlock:^(id<AspectInfo> aspectInfo, UIStatusBarStyle x) {
//                NSLog(@"x == %ld", x);
//            }error:nil];
//            [[UIApplication sharedApplication] aspect_hookSelector:@selector(setStatusBarStyle:animated:) withOptions:AspectPositionAfter usingBlock:^(id<AspectInfo> aspectInfo, UIStatusBarStyle x) {
//                NSLog(@"x == %ld", x);
//            }error:nil];
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
    
    [self.topBar setupSubviews];
    
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
    self.ttHideNavigationBar = YES;
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
    UIStatusBarStyle style = UIStatusBarStyleLightContent;
    //TODO:Jason
//    if ([TTTopBarManager sharedInstance_tt].topBarConfigValid.boolValue) {
//        if (![TTTopBarManager sharedInstance_tt].isStatusBarLight) {
//            style = UIStatusBarStyleDefault;
//        } else {
//            style = UIStatusBarStyleLightContent;
//        }
//    }
    [[UIApplication sharedApplication] setStatusBarStyle:style animated:NO];
    self.ttStatusBarStyle = style;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if ([[self.pageViewController currentCollectionPageCell] respondsToSelector:@selector(didAppear)]) {
        [[self.pageViewController currentCollectionPageCell] didAppear];
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [[UIApplication sharedApplication] setStatusBarStyle:self.ttStatusBarStyle == UIStatusBarStyleDefault ? [[TTThemeManager sharedInstance_tt] statusBarStyle] : self.ttStatusBarStyle animated:animated];
    });
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if ([[self.pageViewController currentCollectionPageCell] respondsToSelector:@selector(willDisappear)]) {
        [[self.pageViewController currentCollectionPageCell] willDisappear];
    }
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
    self.selectorBackView = [[TTVCategoryBackView alloc] initWithFrame:CGRectMake(0, -[self statusBarHeight], self.view.width, [self statusBarHeight] + kTopSearchButtonHeight)];
    
    CGFloat selectorHeight = 37.0f;
    
    [self.selectorBackView addSubview:self.categorySelectorView];
    
    self.selectorBackView.backgroundColorThemeKey = self.categorySelectorView.backgroundColorThemeKey;
    
}

- (void)setCategories:(NSArray *)categories
{
    if (_categories != categories) {
        _categories = categories;
        if ([categories count] > 0) {
            [self.categorySelectorView refreshWithCategories:categories];
            self.pageViewController.pageCategories = categories;
            @weakify(self);
            self.pageViewController.getCellClassStringForIndexPath = ^NSString *(NSIndexPath *indexPath) {
                @strongify(self);
                TTCategory *category = indexPath.row < self.categories.count ? self.categories[indexPath.row] : nil;
                if ([category.categoryID isEqualToString:@"subv_hotsoon"] || [category.categoryID isEqualToString:@"hotsoon"]) {
                    return NSStringFromClass([TTCollectionListPageCell class]);
                } else {
                    return NSStringFromClass([TTVFeedListPageCell class]);
                }
            };
            [self categorySelectorView:self.categorySelectorView selectCategory:categories[0]];
        }
    }
}

#pragma mark - TTAccountMulticastProtocol

- (void)onAccountStatusChanged:(TTAccountStatusChangedReasonType)reasonType platform:(NSString *)platformName
{
    shouldUpdatePGCStatus = YES;
}

#pragma mark -
#pragma mark methods

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
                TTVFeedListPageCell *cell = (TTVFeedListPageCell *)self.pageViewController.currentCollectionPageCell;
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
    if([[self.pageViewController currentCollectionPageCell] isKindOfClass:[TTVFeedListPageCell class]]){
        //5.7新增，对于视频Tab 点击底部tabbar刷新事件
        //在刷新之前将对应的listview的refreshFromType设置为正确的值
        BOOL hasTip = [[[notification userInfo] objectForKey:kMainTabbarClickedNotificationUserInfoHasTipKey] boolValue];
        TTVFeedListPageCell *collectionListPageCell = (TTVFeedListPageCell *)[self.pageViewController currentCollectionPageCell];
        TTCategory *category = collectionListPageCell.category;
        [collectionListPageCell.feedListViewController clickVideoTabbarWithCategory:category hasTip:hasTip];
    }
    
    [self.pageViewController reloadCurrentPage];
}

- (void)connectionChanged:(NSNotification *)noti
{
    CLS_LOG(@"connectionChanged");
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
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.categories = [[TTVideoCategoryManager sharedManager] videoCategoriesWithDataDicts:nil];
    });
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
        _pageViewController = [[TTCollectionPageViewController alloc] initWithTabType:TTCategoryModelTopTypeVideo cellClassStringArray:@[NSStringFromClass([TTVFeedListPageCell class]), NSStringFromClass([TTCollectionListPageCell class])]];
        _pageViewController.delegate = self;
    }
    return _pageViewController;
}

- (TTCategorySelectorView *)categorySelectorView
{
    if (!_categorySelectorView) {
        TTCategorySelectorViewTabType tabType =  TTCategorySelectorViewNewVideoTab;
        TTCategorySelectorViewStyle selectorViewStyle = TTCategorySelectorViewNewVideoStyle;
        _categorySelectorView = [[TTCategorySelectorView alloc] initWithFrame:CGRectZero style:selectorViewStyle tabType:tabType];
        _categorySelectorView.delegate = self;
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
            
            //log3.0
            NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:10];
            [dict setValue:category.categoryID forKey:@"category_name"];
            [dict setValue:@"click" forKey:@"enter_type"];
            NSString *enterFrom = [NSString stringWithFormat:@"%@_%@", @"click", category.categoryID];
            [dict setValue:enterFrom forKey:@"enter_from"];
            [TTTrackerWrapper eventV3:@"enter_category" params:dict isDoubleSending:YES];
            
        } else {
            //5.7 新增对于视频Tab刷新统计
            //针对点击频道名刷新
            //在刷新之前将对应的listview的refreshFromType设置为正确的值
            if([[self.pageViewController currentCollectionPageCell] isKindOfClass:[TTVFeedListPageCell class]]){
                BOOL hasTip = [self isTabbarHasTip];
                TTVFeedListPageCell *collectionListPageCell = (TTVFeedListPageCell *)[self.pageViewController currentCollectionPageCell];                
                [collectionListPageCell.feedListViewController clickCategorySelectorViewWithCategory:category hasTip:hasTip];
            }
            [self.pageViewController reloadCurrentPage];
        }
    }
}

- (void)categorySelectorView:(TTCategorySelectorView *)selectorView didClickExpandButton:(UIButton *)expandButton
{

}

- (void)categorySelectorView:(TTCategorySelectorView *)selectorView didClickSearchButton:(UIButton *)searchButton
{
    ExploreSearchViewController * viewController = [[ExploreSearchViewController alloc] initWithNavigationBar:YES showBackButton:NO queryStr:nil fromType:ListDataSearchFromTypeVideo];
    
    [ExploreMovieView removeAllExploreMovieView];
    [self.navigationController pushViewController:viewController animated:YES];
    
    // TODO: Jason
    
    [TTTrackerWrapper eventV3:@"search_tab_click" params:@{@"search_source":@"top_bar",
                                                           @"from_tab_name" : @"video"}];
}

#pragma mark -
#pragma mark Page View Controller Delegate

- (void)pageViewController:(TTCollectionPageViewController *)pageViewController pagingFromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex completePercent:(CGFloat)percent
{
    
    [self.categorySelectorView moveSelectFrameFromIndex:fromIndex toIndex:toIndex percentage:percent];

//    //统计针对外面是滑动的事件
//    if (percent == 0 && fromIndex < self.categorySelectorView.categories.count) {
//        TTCategory *category = [self.categorySelectorView.categories objectAtIndex:fromIndex];
//        NSString *categoryID = category.categoryID;
//        if ([categoryID isEqualToString:@"hotsoon"]) {
//            categoryID = @"subv_hotsoon";
//        }
//        NSString *labelString = [NSString stringWithFormat:@"enter_flip_%@",categoryID];
//        wrapperTrackEventWithCustomKeys(@"category", labelString, nil, nil, @{@"category_id":categoryID});
//    }
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
        
        //log3.0
        NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:10];
        [dict setValue:currCategoryModel.categoryID forKey:@"category_name"];
        [dict setValue:@(1) forKey:@"refer"];
        [dict setValue:@"flip" forKey:@"enter_type"];
        NSString *enterFrom = [NSString stringWithFormat:@"%@_%@", @"flip", currCategoryModel.categoryID];
        [dict setValue:enterFrom forKey:@"enter_from"];
        [TTTrackerWrapper eventV3:@"enter_category" params:dict isDoubleSending:YES];

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
    TTVFeedListPageCell *cell = (TTVFeedListPageCell *)[_pageViewController currentCollectionPageCell];
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
    BOOL refreshButtonSettingEnabled = [TTDeviceHelper isPadDevice] ? YES : [[[TTSettingsManager sharedManager] settingForKey:@"refresh_button_setting_enabled" defaultValue:@NO freeze:NO] boolValue];
    self.feedRefreshView.hidden = !(refreshButtonSettingEnabled && ttsettings_showRefreshButton());
}

- (BOOL)shouldAnimateRefreshViewWithPageCell:(TTVFeedListPageCell *)cell
{
    return !(PULL_REFRESH_STATE_LOADING == cell.feedListViewController.tableView.pullUpView.state);
}

#pragma mark - TTVFeedListPageCellDelegate Methods

- (void)listViewOfTTCollectionPageCellStartLoading:(TTVFeedListPageCell *)collectionPageCell
{
    if (!_feedRefreshView.hidden && [self shouldAnimateRefreshViewWithPageCell:collectionPageCell]) {
        [_feedRefreshView startLoading];
    }
}

- (void)listViewOfTTCollectionPageCellEndLoading:(TTVFeedListPageCell *)collectionPageCell
{
    if (!_feedRefreshView.hidden && [self shouldAnimateRefreshViewWithPageCell:collectionPageCell]) {
        [_feedRefreshView endLoading];
    }
    [collectionPageCell setHeaderView:[self headerViewForCell:collectionPageCell]];
}

- (UIView *)headerViewForCell:(TTVFeedListPageCell *)collectionPageCell
{
    TTCategory *category = collectionPageCell.category;
    BOOL shouldShow = [TTPGCFetchManager shouldShowVideoPGC];
    if (showPGC && shouldShow && category == self.categories[0]) {
        return self.pgcCell;
    } else {
        return nil;
    }
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

#pragma TTTopBarDelegate
- (void)searchActionFired:(id)sender {
    [TTVPlayVideo removeAll];
    [self searchBarButtonActionFired:sender];
    wrapperTrackEvent(@"video", @"video_tab_search");
}

- (void)searchBarButtonActionFired:(id)sender {
    [TTTrackerWrapper eventV3:@"search_tab_click" params:@{@"search_source":@"top_bar",
                                                           @"from_tab_name" : @"video"}];
    ExploreSearchViewController *searchViewController = [[ExploreSearchViewController alloc] initWithNavigationBar:NO showBackButton:NO queryStr:nil fromType:ListDataSearchFromTypeVideo];
    searchViewController.fromTabName = _topBar.tab;
    searchViewController.animatedWhenDismiss = YES;
    [searchViewController view]; //preload view
    searchViewController.searchView.isFromTopSearchbar = YES;
    searchViewController.searchView.categoryID = [self.categorySelectorView categoryId];
    
    if ([SSCommonLogic useNewSearchTransitionAnimation] && [SSCommonLogic isSearchTransitionEnabled] && [SSCommonLogic useNewSearchTransitionAnimationForVideo]) {
        searchViewController.ttNavBarStyle = @"Red";
        if ([TTTopBarManager sharedInstance_tt].topBarConfigValid.boolValue) {
            searchViewController.ttHideNavigationBar = YES;
        }
        TTCustomAnimationNavigationController *nav = [[TTCustomAnimationNavigationController alloc] initWithRootViewController:searchViewController animationStyle:TTCustomAnimationStyleUGCPostEntrance];
        nav.useWhiteStyle = YES;
        nav.ttNavBarStyle = @"White";
        [self presentViewController:nav animated:YES completion:nil];
    } else {
        if (![TTTabBarProvider isMineTabOnTabBar] || ![SSCommonLogic isSearchTransitionEnabled] || ![SSCommonLogic useNewSearchTransitionAnimationForVideo]){
            [self.navigationController pushViewController:searchViewController animated:YES];
            [TTCustomAnimationManager sharedManager].pushSearchVCWithCustomAnimation = NO;
        }
        else{
            TTCustomAnimationNavigationController *nav = [[TTCustomAnimationNavigationController alloc] initWithRootViewController:searchViewController animationStyle:TTCustomAnimationStyleUGCPostEntrance];
            [self presentViewController:nav animated:YES completion:nil];
        }
    }
}

- (void)mineActionFired:(id)sender {
    [TTVPlayVideo removeAll];
    // 标记能够展示绑定手机号逻辑
    [TTAccountBindingMobileViewController setShowBindingMobileEnabled:YES];
    
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Profile" bundle:nil];
    TTProfileViewController *profileVC = [sb instantiateInitialViewController];
    profileVC.fromTab = _topBar.tab;
    [self.navigationController pushViewController:profileVC animated:YES];
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
        self.topBar.height = self.topInset;
        if (self.selectorBackView) {
            self.selectorBackView.top = -[self statusBarHeight];
            self.selectorBackView.height = [self statusBarHeight] + kTopSearchButtonHeight;
        }
    }
}

- (UIEdgeInsets)additionalSafeAreaInsets
{
    return  UIEdgeInsetsMake(kTopSearchButtonHeight + kSelectorViewHeight, 0, 0, 0);
}
@end
