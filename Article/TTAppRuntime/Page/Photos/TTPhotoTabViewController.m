//
//  TTPhotoTabViewController.m
//  Article
//
//  Created by 刘廷勇 on 15/11/3.
//
//

#import "TTPhotoTabViewController.h"
#import "SSNavigationBar.h"
#import "UIScrollView+Refresh.h"

#import "TTCategorySelectorView.h"
#import "TTArticleCategoryManager.h"
#import "TTCollectionPageViewController.h"
#import "TTCollectionListPageCell.h"

#import "ExploreSearchViewController.h"
#import "ArticleURLSetting.h"
#import "NewsListLogicManager.h"


#import "TTReachability.h"

#import "TTFeedRefreshView.h"
#import "NewsBaseDelegate.h"
#import "ExploreMixedListView.h"

#import "UIViewController+NavigationBarStyle.h"

#import "TTTrackerWrapper.h"

#import "ArticleFetchSettingsManager.h"
#import "TTDeviceHelper.h"

#import "UIViewController+RefreshEvent.h"

#import <TTInteractExitHelper.h>

@interface TTPhotoTabViewController () <TTCategorySelectorViewDelegate, TTCollectionPageViewControllerDelegate, TTCollectionListPageCellDelegate,TTInteractExitProtocol>

@property (nonatomic, strong) TTCollectionPageViewController *pageViewController;
@property (nonatomic, strong) TTCategorySelectorView *categorySelectorView;
@property (nonatomic, strong) UIView *barView;

@property (nonatomic, assign) NSInteger lastSelectedPageIndex;

@property (nonatomic, strong) NSArray *categories;

@property (nonatomic) CGFloat topInset;
@property (nonatomic) CGFloat bottomInset;

@property (nonatomic, strong) TTFeedRefreshView *feedRefreshView;

@end

@implementation TTPhotoTabViewController

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivePhotoTabbarClickedNotification:) name:kPhotoTabbarKeepClickedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveIarNotification:) name:kIarNotification object:nil];

    [self setInset];
    
    [self addChildViewController:self.pageViewController];
    [self.view addSubview:self.pageViewController.view];
    [self.view addSubview:self.barView];
    
    [self setupConstraints];
    [self fetchCategoryData];
    
    self.lastSelectedPageIndex = 0;
    
    // FeedRefreshView
    [self setupFeedRefreshView];
    
    self.ttHideNavigationBar = YES;
    self.ttStatusBarStyle = UIStatusBarStyleLightContent;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self hiddenFeedRefreshViewIfNeeded];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    [_feedRefreshView resetFrameWithSuperviewFrame:self.view.frame bottomInset:_bottomInset];
}

- (void)setupConstraints
{
    [self.barView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.equalTo(self.view);
        make.height.mas_equalTo(self.topInset);
    }];
    
    [self.pageViewController.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
}

#pragma mark -
#pragma mark init

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

#pragma mark -
#pragma mark methods

- (void)fetchCategoryData
{
    self.categories = [[TTArticleCategoryManager sharedManager] localPhotoCategories];
}

- (void)setInset
{
    CGFloat bottomPadding = 0;
    CGFloat topPadding = 0;

    if ([TTDeviceHelper isPadDevice]) {
        topPadding = 64 + 44;
        bottomPadding = 0;
    } else {
        topPadding = 64;
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
        _pageViewController = [[TTCollectionPageViewController alloc] initWithTabType:TTCategoryModelTopTypePhoto cellClass:NSStringFromClass([TTCollectionListPageCell class])];
        _pageViewController.delegate = self;
    }
    return _pageViewController;
}

- (TTCategorySelectorView *)categorySelectorView
{
    if (!_categorySelectorView) {
        _categorySelectorView = [[TTCategorySelectorView alloc] initWithFrame:CGRectZero style:[TTDeviceHelper isPadDevice] ? TTCategorySelectorViewBlackStyle : TTCategorySelectorViewWhiteStyle
                                 tabType:TTCategorySelectorViewPhotoTab];
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
        _barView.backgroundColor = [UIColor whiteColor];
        
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

- (CGFloat)statusBarHeight
{
    return 20.f;
}

#pragma mark -
#pragma mark Selector delegate

- (void)categorySelectorView:(TTCategorySelectorView *)selectorView selectCategory:(TTCategory *)category
{
    NSUInteger index = NSNotFound;
    index = [self.categories indexOfObject:category];
    if (index != NSNotFound) {
        [self.pageViewController setCurrentPage:index scrollToPositionCenteredAnimated:NO];
        [selectorView selectCategory:category];
        if (self.lastSelectedPageIndex != index) {
            self.lastSelectedPageIndex = index;
            
            NSString *label = [NSString stringWithFormat:@"%@_%@", @"enter_click", category.categoryID];
            wrapperTrackEvent(@"category", label);
        } else {
            //5.7 新增对于图片tab刷新统计
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

#pragma mark -
#pragma mark Page View Controller Delegate

- (void)pageViewController:(TTCollectionPageViewController *)pageViewController pagingFromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex completePercent:(CGFloat)percent
{
    [self.categorySelectorView moveSelectFrameFromIndex:fromIndex toIndex:toIndex percentage:percent];
}

- (void)pageViewController:(TTCollectionPageViewController *)pageViewController didPagingToIndex:(NSInteger)toIndex
{
    TTCategory *currCategoryModel = self.categories[toIndex];
    [self.categorySelectorView selectCategory:currCategoryModel];
    if (self.lastSelectedPageIndex != toIndex) {
        self.lastSelectedPageIndex = toIndex;
        
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
    [cell.listView pullAndRefresh];
    
    wrapperTrackEvent(@"refresh", [NSString stringWithFormat:@"pic_%@", cell.category.categoryID]);
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
}

#pragma mark - Refresh when tap tab twice

- (void)receivePhotoTabbarClickedNotification:(NSNotification *)notification
{
    if([[self.pageViewController currentCollectionPageCell] isKindOfClass:[TTCollectionListPageCell class]]){
        //5.7新增，对于图集Tab 点击底部tabbar刷新事件
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

- (void)receiveIarNotification:(NSNotification *)notification
{
    [self fetchCategoryData];
}

#pragma mark - TTInteractExitProtocol

- (UIView *)suitableFinishBackView{
    return _pageViewController.view;
}

@end
