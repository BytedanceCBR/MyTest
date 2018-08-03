//
//  ExploreMainListView.m
//  Article
//
//  Created by Zhang Leonardo on 14-9-5.
//
//

#import "ExploreMainListView.h"
#import <QuartzCore/QuartzCore.h>
#import "ArticleBaseListView.h"
//#import "SSMenuController.h"
#import "CategoryModel.h"
#import "ArticleCategoryManager.h"
#import "ArticleCategoryManagerView.h"
#import "NetworkUtilities.h"
#import "UIColorAdditions.h"
#import "SSHorizenScrollView.h"
#import "ExploreMixedListHorizenScrollViewCell.h"
#import "WebListHorizenScrollViewCell.h"
#import "ExploreSubscribeListHorizenScrollViewCell.h"
#import "NewsListLogicManager.h"
#import "CategorySelectorView.h"
#import "ExploreArchitectureManager.h"
#import "ArticleCategoryManager.h"
#import "ExploreSubscribeDataListManager.h"
#import "ExploreMovieView.h"
#import "TTAuthorizeManager.h"
#import "TTLocationManager.h"

#import "ArticleCategoryOptimizingBubbleView.h"
#import "ArticleOptimizedCategoryManager.h"

#import "TTFeedRefreshView.h"
#import "UIScrollView+Refresh.h"

static BOOL isSendInitTime;

@interface ExploreMainListView()<SSHorizenScrollViewDataSource, SSHorizenScrollViewDelegate, SSHorizenScrollViewCellDelegate, CategorySelectorViewDelegate>{
    BOOL _hasAppeared;
}
@property(nonatomic, strong, readwrite)SSHorizenScrollView * exploreListView;

/**
 *  所有用于显示的category mode
 */
@property (nonatomic, strong) NSMutableArray * showCategoryModes;
@property (nonatomic, copy)   NSString *lastRefreshedCategoryID;
@property (nonatomic, strong) CategorySelectorView *categorySelectorView;

@property (nonatomic, strong) CategoryModel *categorySelectorCategoryModel;
@property (nonatomic, assign) CGFloat topInset;
@property (nonatomic, assign, readwrite) CGFloat bottomInset;

@end

@implementation ExploreMainListView

@synthesize currentCategory;

- (void)dealloc
{
    self.delegate = nil;
    [_exploreListView removeCellDelegates];
    _exploreListView.ssDelegate = nil;
    _exploreListView.ssDataSource = nil;
    _categorySelectorView.delegate = nil;
    [self unregisterNotifications];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - view

- (id)initWithFrame:(CGRect)frame topInset:(CGFloat)topInset bottomInset:(CGFloat)bottomInset {
    self = [self initWithFrame:frame];
    if (self) {

        self.clipsToBounds = YES;
        
        self.topInset = topInset;
        self.bottomInset = bottomInset;
        

        self.exploreListView = [[SSHorizenScrollView alloc] initWithFrame:self.bounds];

        if (![ExploreArchitectureManager isDrawerType]) {
            self.exploreListView.contentScrollView.bounces = YES;
        }
        
        self.exploreListView.ssDataSource = self;
        self.exploreListView.ssDelegate = self;
        [self addSubview:self.exploreListView];

        #pragma mark ============= TODOP delete =============
        [self registerNotifications];
        [self reloadThemeUI];
    }
    return self;
}

- (void)addRefreshView
{
    if (!_refreshView) {
        _refreshView = [[TTFeedRefreshView alloc] init];
        _refreshView.center = CGPointMake(CGRectGetWidth(self.frame) - CGRectGetWidth(_refreshView.frame)/2,
                                          CGRectGetHeight(self.frame) - CGRectGetHeight(_refreshView.frame)/2 - self.bottomInset);
        [_refreshView.arrowBtn addTarget:self action:@selector(refreshButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_refreshView];
    }
}

- (void)addCategorySelectorView
{
    if (!self.categorySelectorView) {
        self.categorySelectorView = [[CategorySelectorView alloc] initWithFrame:CGRectMake(0, self.topInset-37, SSWidth(self), 37) style:[ExploreArchitectureManager isDrawerType]?CategorySelectorViewBlackStyle:CategorySelectorViewWhiteStyle];
        _categorySelectorView.delegate = self;
        NSArray *subscribedCategories = [[ArticleCategoryManager sharedManager] subScribedCategories];
        
        if (subscribedCategories.count > 0) {
            [_categorySelectorView refreshWithCategories:subscribedCategories];
        }
        if (self.categorySelectorCategoryModel) {
            [_categorySelectorView selectCategory:self.categorySelectorCategoryModel];
            self.categorySelectorCategoryModel = nil;
        }
        [self addSubview:_categorySelectorView];
    }
}

- (void)layoutSubviews
{
    if ([ExploreArchitectureManager isDrawerType]) {
        self.categorySelectorView.frame = CGRectMake(0, self.topInset-37, SSWidth(self), 37);
    }
    
    self.exploreListView.frame = self.bounds;
}

- (void)themeChanged:(NSNotification *)notification
{
    [super themeChanged:notification];
    //_exploreListView.cellBackgroundImage = [UIImage resourceImageNamed:@"toutiao_icon_list.png"];

    _exploreListView.backgroundColor = [UIColor tt_themedColorForKey:kColorBackground4];
    self.backgroundColor = [UIColor tt_themedColorForKey:kColorBackground4];
}

#pragma mark -- life cycle

- (void)mainTabbarClicked:(NSNotification *)notification
{
    if ([_exploreListView.currentDisplayCell respondsToSelector:@selector(pullAndRefresh)]) {
        [_exploreListView.currentDisplayCell performSelector:@selector(pullAndRefresh) withObject:nil];
    }
    if ([_exploreListView.currentDisplayCell respondsToSelector:@selector(categoryModel)]) {
        CategoryModel * model = [_exploreListView.currentDisplayCell performSelector:@selector(categoryModel)];
        if ([model.categoryID isEqualToString:kMainCategoryID]) {
            BOOL hasTip = [[[notification userInfo] objectForKey:kMainTabbarClickedNotificationUserInfoHasTipKey] boolValue];
            if (hasTip) {
                ssTrackEvent(@"new_tab", @"tab_refresh_tip");
            }
            else {
                ssTrackEvent(@"new_tab", @"tab_refresh");
            }
        }
    }
}

- (void)applicationDidEnterBackground:(NSNotification *)notification
{
    [[NewsListLogicManager shareManager] didEnterBackground];
    if ([[_exploreListView currentDisplayCell] respondsToSelector:@selector(cellWillEnterBackground)]) {
        [[_exploreListView currentDisplayCell] performSelector:@selector(cellWillEnterBackground)];
    }
    [ArticleCategoryOptimizingBubbleView dismissIfNeeded];
}

- (void)applicationWillEnterForeground:(NSNotification*)notification
{
    [[NewsListLogicManager shareManager] willEnterForground];
    
    if ([[_exploreListView currentDisplayCell] respondsToSelector:@selector(cellWillEnterForground)]) {
        [[_exploreListView currentDisplayCell] performSelector:@selector(cellWillEnterForground)];
    }
    //自动切换回推荐列表

    if ([[NewsListLogicManager shareManager] needSwitchToRecommendTab]){
        int index = 0;
        [_exploreListView reloadDataAtIndex:index];
    }
}

- (void)willAppear
{
    [super willAppear];
    [self addCategorySelectorView];
}

- (void)trackInitTime
{
    if (!isSendInitTime) {//切换UI不在调用,app启动只发送一次.
        [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithLongLong:[NSObject currentUnixTime]] forKey:kTrackTime_mainList_viewAppear];
        
        CGFloat load = [[[NSUserDefaults standardUserDefaults] valueForKey:kTrackTime_load] longLongValue];
        CGFloat start = [[[NSUserDefaults standardUserDefaults] valueForKey:kTrackTime_didFinishLaunch_start] longLongValue];
        CGFloat end = [[[NSUserDefaults standardUserDefaults] valueForKey:kTrackTime_didFinishLaunch_end]longLongValue];
        
        CGFloat appear = [[[NSUserDefaults standardUserDefaults] valueForKey:kTrackTime_mainList_viewAppear]longLongValue];
        
        double pre_init_time = [NSObject machTimeToSecs:start - load];
        double init_time = [NSObject machTimeToSecs:end - start];
        double show = [NSObject machTimeToSecs:appear - end];
        double total = pre_init_time + init_time + show;
        
        NSNumber *totalTime = [NSNumber numberWithDouble:total * 1000];
        NSNumber *preTime = [NSNumber numberWithDouble:pre_init_time * 1000];
        NSNumber *initTime = [NSNumber numberWithDouble:init_time * 1000];
        NSNumber *showTime = [NSNumber numberWithDouble:show * 1000];
        
        NSMutableDictionary * dict = [NSMutableDictionary dictionaryWithCapacity:10];
        [dict setValue:@"umeng" forKey:@"category"];
        [dict setValue:@"launch_stat" forKey:@"tag"];
        [dict setValue:@"finish" forKey:@"label"];
        [dict setValue:totalTime forKey:@"value"];
        [dict setValue:preTime forKey:@"pre_init_time"];
        [dict setValue:initTime forKey:@"init_time"];
        [dict setValue:showTime forKey:@"render_time"];
        [SSTracker eventData:dict];
        isSendInitTime = YES;
        
        NSLog(@"pre_init_time %f,init_time %f ,show %f,total %F",pre_init_time,init_time,show,total);
    }
}

- (void)didAppear
{
    [super didAppear];
    if (!_refreshView) {
        [self addRefreshView];
        [self hiddenRefreshViewIfNeeded];
    }
    [self trackInitTime];
    
    //这里本来是 will appear里做 现在房子 didappear里 减少will时候的cpu使用 保证交互式返回动画 流程
    [[_exploreListView currentDisplayCell] willAppear];
    //--end

    if(!_hasAppeared)
    {
        _hasAppeared = YES;
        [self tryGetCategories];
        [_exploreListView loadCellsNearbyWhenFirstAppear];
        // Ugly code
        // 由于该manager用于监听 “添加/取消订阅”，需保证在启动时实例化
        [ExploreSubscribeDataListManager shareManager];
    }
    
    [[_exploreListView currentDisplayCell] didAppear];
    [[TTLocationManager sharedManager] processLocationCommandIfNeeded];
    
}



- (void)willDisappear
{
    [super willDisappear];
    
    [[_exploreListView currentDisplayCell] willDisappear];
}

- (void)didDisappear
{
    [super didDisappear];
    
    [[_exploreListView currentDisplayCell] didDisappear];
    
    [ArticleCategoryOptimizingBubbleView dismissIfNeeded];
}

#pragma mark -- notification response

//控制当前页面是否可以scrollsToTop
//- (void)openSideChanged:(NSNotification *)notification
//{
//    MMDrawerSide openSide = [[[notification userInfo] objectForKey:kMMDrawerControllerOpenSideKey] intValue];
//    
//    if ([[self currentDisplayView] respondsToSelector:@selector(scrollToTopEnable:)]) {
//        [((ArticleBaseListView *)self.currentDisplayView) scrollToTopEnable:openSide == MMDrawerSideNone];
//    }
//    
//    if (openSide == MMDrawerSideLeft ||
//        openSide == MMDrawerSideRight) {
//        [ExploreMovieView removeAllExploreMovieView];
//    }
//}

#pragma mark - notifications


- (void)registerNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mainTabbarClicked:) name:kMainTabbarKeepClickedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(categoryGotFinished:) name:kAritlceCategoryGotFinishedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(categoryHasChangedNotification:) name:kArticleCategoryHasChangeNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getOptimizedCategoriesFinished:) name:kGetRemoteOptimizedCategoriesNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleRefreshButtonSettingEnabledNotification:) name:kFeedRefreshButtonSettingEnabledNotification object:nil];
}

- (void)unregisterNotifications
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mari -- list util

- (void)reloadExploreListView
{
    CategoryModel * originCategory = [self currentCategory];

    //判断是否变化了， 仅变化了才reload
    NSMutableArray * recentAry = [[ArticleCategoryManager sharedManager] subScribedCategories];
    BOOL hasChanged = NO;
    if ([recentAry count] != [_showCategoryModes count]) {
        hasChanged = YES;
    }
    else {
        for (int i = 0; i < [recentAry count]; i ++) {
            if (![((CategoryModel *)[recentAry objectAtIndex:i]).categoryID isEqualToString: ((CategoryModel *)[_showCategoryModes objectAtIndex:i]).categoryID]) {
                hasChanged = YES;
                break;
            }
        }
    }
    
    if (hasChanged) {
        self.showCategoryModes = [NSMutableArray arrayWithArray:[[ArticleCategoryManager sharedManager] subScribedCategories]];
        
        NSUInteger index = 0;
        
        if ([NewsListLogicManager needShowFixationCategory]) {
            index = 1;
        }
        
        CategoryModel * changedToCategory = [[ArticleCategoryManager sharedManager] lastAddedCategory];
        if (!changedToCategory && originCategory) {
            changedToCategory = originCategory;
        }
        
        if (changedToCategory) {
            index = [_showCategoryModes indexOfObject:changedToCategory];
            if (index == NSNotFound) {
                index = 0;
            } else {
                index = MAX(0, index);
                index = MIN(index, [_showCategoryModes count] - 1);
            }
        }
        
        [ArticleCategoryManager sharedManager].lastAddedCategory = nil;
        
        [_exploreListView reloadDataAtIndex:index];
    }
}

#pragma mark categorys

// only get category when local storage only has default category
- (void)tryGetCategories
{
    NSArray *_categories = [[ArticleCategoryManager sharedManager] allCategories];
    if([_categories count] <= 1)
    {
        [[ArticleCategoryManager sharedManager] startGetCategory];
    }
    else
    {
        [self categoryGotFinished:nil];
    }
}

- (CategoryModel *)categoryAtIndex:(NSUInteger)index
{
    if (index >= [_showCategoryModes count]) {
        return nil;
    }
    else {
        return ((CategoryModel *)[_showCategoryModes objectAtIndex:index]);
    }
}

- (void)selectCategory:(CategoryModel*)category
{
    self.currentCategory = category;
    NSUInteger index = NSNotFound;
    index = [_showCategoryModes indexOfObject:currentCategory];
    if (index != NSNotFound)
    {
        [_exploreListView scrollToIndex:index animated:NO];
        
        [self adjustRefreshViewAppearance];
    }
    
    if((isEmptyString(_lastRefreshedCategoryID) || [_lastRefreshedCategoryID isEqualToString:category.categoryID]))
    {
        if ([_exploreListView.currentDisplayCell respondsToSelector:@selector(refreshListWithCategory:)]) {
            [_exploreListView.currentDisplayCell performSelector:@selector(refreshListWithCategory:) withObject:category];
        }
        if ([_exploreListView.currentDisplayCell respondsToSelector:@selector(pullAndRefresh)] &&
            !isEmptyString(_lastRefreshedCategoryID)) {
            [_exploreListView.currentDisplayCell performSelector:@selector(pullAndRefresh) withObject:nil];
        }
        
        if ([category.categoryID isEqualToString:kSubscribeCategoryID])
        {
            ssTrackEvent(@"subscription", @"tab_refresh");
        }
    }
    
    self.lastRefreshedCategoryID = category.categoryID;
    
}

- (UIView *)currentDisplayView
{
    return [[_exploreListView currentDisplayCell] contentView];
}

#pragma mark - Feed Refresh View

- (void)refreshButtonPressed:(UIButton *)button
{
    if ([_exploreListView.currentDisplayCell respondsToSelector:@selector(pullAndRefresh)]) {
        [_exploreListView.currentDisplayCell performSelector:@selector(pullAndRefresh) withObject:nil];
    }
    
    if ([self.currentCategory.categoryID isEqualToString:kMainCategoryID]) {
        ssTrackEvent(@"new_tab", @"new_button_refresh"); // 推荐频道
    } else {
        ssTrackEvent(@"category", @"new_button_refresh");
    }
}

- (void)handleRefreshButtonSettingEnabledNotification:(NSNotification *)notification
{
    [self.refreshView endLoading];
    [self hiddenRefreshViewIfNeeded];
}

- (void)adjustRefreshViewAppearance
{
    if (!_refreshView.hidden) {
        ListDataType targetListType = self.currentCategory.listDataType.intValue;
        if ((ListDataTypeSubscribeEntry == targetListType && [self subscribeListIsEmpty]) ||
            ListDataTypeWeb == targetListType ) {
            _refreshView.alpha = 0.0f;
        } else {
            _refreshView.alpha = _refreshView.originAlpha;
        }
    }
}

- (void)hiddenRefreshViewIfNeeded
{
    self.refreshView.hidden = !([SSCommonLogic refreshButtonSettingEnabled] && [SSCommonLogic showRefreshButton]);
    // 订阅列表为空时不显示refreshView，添加订阅后返回订阅列表，需要及时显示refreshView
    [self adjustRefreshViewAppearance];
}

- (void)adjustRefreshViewWhenListCellMovedFromIndex:(NSUInteger)fromIndex toIndex:(NSUInteger)toIndex percent:(CGFloat)percent
{
    if (_refreshView.hidden || fromIndex >= [_showCategoryModes count] ||
        toIndex >= [_showCategoryModes count]) {
        return;
    }
    
    ListDataType fromListDataType = [(CategoryModel *)[_showCategoryModes objectAtIndex:fromIndex] listDataType].intValue;
    ListDataType toListDataType = [(CategoryModel *)[_showCategoryModes objectAtIndex:toIndex] listDataType].intValue;
    
    CGFloat realPercent = percent;
    ListDataType targetListDataType = ListDataTypeWeb;
    
    if ([self subscribeListIsEmpty]) {
        
        targetListDataType = ListDataTypeSubscribeEntry;
        
        if (ListDataTypeSubscribeEntry == fromListDataType) {
            realPercent = percent / 0.5;
        } else if (ListDataTypeSubscribeEntry == toListDataType) {
            realPercent = (percent - 0.5) / 0.5;
        }
    }
    // NSLog(@"percent : %@, realPersont : %@", @(percent), @(realPercent));
    
    if (targetListDataType != fromListDataType && targetListDataType != toListDataType) {
        _refreshView.alpha = _refreshView.originAlpha;
    } else if (targetListDataType != fromListDataType && targetListDataType == toListDataType) {
        _refreshView.alpha = (1 - realPercent) * _refreshView.originAlpha;
    } else if (targetListDataType == fromListDataType && targetListDataType != toListDataType) {
        _refreshView.alpha = realPercent * _refreshView.originAlpha;
    } else {
        _refreshView.alpha = 0;
    }
}

- (BOOL)shouldAnimateRefreshViewWithScrollViewCell:(SSHorizenScrollViewCell *)cell
{
    BOOL result = YES;
    id currentListView = [(NewsListHorizenScrollViewCellBase *)cell listView];
    if ([currentListView isKindOfClass:NSClassFromString(@"ExploreMixedListView")]) {
        if ([currentListView respondsToSelector:@selector(listView)]) {
            UIView *innerListView = [currentListView performSelector:@selector(listView) withObject:nil]; // ExploreMixedListBaseView
            if ([innerListView respondsToSelector:@selector(listView)]) {
                UITableView *tableView = [innerListView performSelector:@selector(listView) withObject:nil];
                if ([tableView respondsToSelector:@selector(pullUpView)]) {
                    if (PULL_REFRESH_STATE_LOADING == tableView.pullUpView.state) {
                        result = NO;
                    }
                }
            }
        }
    }
    return result;
}

- (BOOL)subscribeListIsEmpty
{
    if (![[self currentDisplayView] isKindOfClass:NSClassFromString(@"ExploreSubscribeListView")]) {
        return NO;
    }
    SEL selector = NSSelectorFromString(@"listEmptyView");
    id (*func)(id, SEL) = (void *)[[self currentDisplayView] methodForSelector:selector];
    UIView *subscribeListEmptyView = func([self currentDisplayView], selector);
    return !subscribeListEmptyView.hidden;
}

#pragma mark -- SSHorizenScrollViewDataSource

- (NSUInteger)numberOfCellCachesForHorizenScrollView:(SSHorizenScrollView *)scrollView;
{
    return 4;
}

- (NSUInteger)numberOfCellsForHorizenScrollView:(SSHorizenScrollView *)scrollView
{
    return [_showCategoryModes count];
}

- (void)horizenScrollView:(SSHorizenScrollView *)scrollView refreshScrollCell:(SSHorizenScrollViewCell *)cell cellIndex:(NSUInteger)index
{
    CategoryModel * model = [self categoryAtIndex:index];
    if ([cell isKindOfClass:[NewsListHorizenScrollViewCellBase class]]) {
        [((NewsListHorizenScrollViewCellBase *)cell) refreshListWithCategory:model];
    }
}

- (SSHorizenScrollViewCell *)horizenScrollView:(SSHorizenScrollView *)scrollView cellAtIndex:(NSUInteger)index
{
    static NSString * mixListViewIdentifier = @"mixListViewIdentifier";
    static NSString * webIdentifier = @"webIdentifier";
    static NSString * subscribeIdentifier = @"subscribeIdentifier";
    
    CategoryModel * model = [self categoryAtIndex:index];
    
    NewsListHorizenScrollViewCellBase * cell;
    switch ([model.listDataType intValue]) {
        case ListDataTypeArticle:
        case ListDataTypeEssay:
        case ListDataTypeImage:
        {
            cell = [scrollView dequeueReusableCellWithIdentifier:mixListViewIdentifier suggestIndex:index];
            if (!cell) {
                cell = [[ExploreMixedListHorizenScrollViewCell alloc] initWithReuseIdentifier:mixListViewIdentifier];
                cell.delegate = self;
            }
        }
            break;
        case ListDataTypeWeb:
        {
            cell = [scrollView dequeueReusableCellWithIdentifier:webIdentifier suggestIndex:index];
            if (!cell) {
                cell = [[WebListHorizenScrollViewCell alloc] initWithReuseIdentifier:webIdentifier];
                cell.delegate = self;
            }
        }
            break;
        case ListDataTypeSubscribeEntry:
        {
            cell = [scrollView dequeueReusableCellWithIdentifier:subscribeIdentifier suggestIndex:index];
            if (!cell) {
                cell = [[ExploreSubscribeListHorizenScrollViewCell alloc] initWithReuseIdentifier:subscribeIdentifier];
                cell.delegate = self;
            }
        }
            break;
        default:
        {
            //error status, now return ListDataTypeWeb
            cell = [scrollView dequeueReusableCellWithIdentifier:webIdentifier suggestIndex:index];
            if (!cell) {
                cell = [[WebListHorizenScrollViewCell alloc] initWithReuseIdentifier:webIdentifier];
                cell.delegate = self;
            }
        }
            break;
    }
    
    cell.frame = _exploreListView.bounds;
    cell.topInset = self.topInset;
    cell.bottomInset = self.bottomInset;
    
    if (index < [_showCategoryModes count] && [cell respondsToSelector:@selector(refreshListWithCategory:)]) {
        [cell refreshListWithCategory:model];
    }
    
    [self adjustRefreshViewAppearance];
    
    return cell;
}

#pragma mark -- SSHorizenScrollViewDelegate

- (void)horizenScrollView:(SSHorizenScrollView *)scrollView didDisplayCellsForIndex:(NSUInteger)index isUserFlipScroll:(NSNumber *)userScroll
{
    if (scrollView == _exploreListView && index < [_showCategoryModes count]) {
        CategoryModel * model = [_showCategoryModes objectAtIndex:index];
        self.currentCategory = model;
        if (!self.categorySelectorView) {
            self.categorySelectorCategoryModel = _showCategoryModes[index];
        }
        else
        {
            [_categorySelectorView selectCategory:_showCategoryModes[index]];
        }

        
        // 统计 - 进入推荐列表
        static NSInteger lastDisplayedCellIndex = -1;
        if (lastDisplayedCellIndex != index) {
            if ([model.categoryID isEqualToString:kMainCategoryID]) {
                ssTrackEvent(@"new_tab", @"enter");
            }
            lastDisplayedCellIndex = index;
        }
        
        // 统计 - 进入订阅列表
        if ([model.categoryID isEqualToString:kSubscribeCategoryID])
        {
            NSString * label = nil;
            if ([userScroll boolValue])
            {
                if ([ExploreSubscribeDataListManager shareManager].hasNewUpdatesIndicator){
                    label = @"enter_flip_tip";
                }else{
                    label = @"enter_flip";
                }
            }
            else
            {
                if ([ExploreSubscribeDataListManager shareManager].hasNewUpdatesIndicator){
                    label = @"enter_click_tip";
                }else{
                    label = @"enter_click";
                }
            }
                
            ssTrackEvent(@"subscription", label);
        }
        
        
        if ([model.categoryID isEqualToString:kNewsLocalCategoryID]) {
            [[TTAuthorizeManager sharedManager].locationObj showAlertAtLocalCategory:^{
                
            }];
        }
    }
}

- (void)horizenScrollView:(SSHorizenScrollView *)scrollView scrollViewDidScrollFromIndex:(NSUInteger)fromIndex toIndex:(NSUInteger)toIndex percent:(CGFloat)percent
{
    [_categorySelectorView moveSelectFrameFromIndex:fromIndex toIndex:toIndex percentage:percent];
    
    [self adjustRefreshViewWhenListCellMovedFromIndex:fromIndex toIndex:toIndex percent:percent];
}

- (void)horizenScrollView:(SSHorizenScrollView *)scrollView scrollViewDidScrollToIndex:(NSUInteger)index
{
    if (scrollView == _exploreListView && index < [_showCategoryModes count]) {
        CategoryModel * model = [_showCategoryModes objectAtIndex:index];
        self.currentCategory = model;
    }
}

- (void)horizenScrollView:(SSHorizenScrollView *)scrollView didEndScrollLastDisplayCellsForIndex:(NSUInteger)index
{
//    if (scrollView == _exploreListView && index < [_showCategoryModes count]) {
//        if ([[SSMenuController shareMenuController] menuVisible]) {
//            [[SSMenuController shareMenuController] setMenuVisible:NO animated:YES];
//        }
//    }
}

#pragma mark -- SSHorizenScrollViewCellDelegate

- (void)horizenScrollCellContentViewStartLoading:(SSHorizenScrollViewCell *)cell
{
    if (_delegate && [_delegate respondsToSelector:@selector(exploreMainListViewDisplayViewDidStartLoad:)]) {
        [_delegate exploreMainListViewDisplayViewDidStartLoad:self];
    }
    
    if (!_refreshView.hidden && cell.isCurrentDisplayCell &&
        [self shouldAnimateRefreshViewWithScrollViewCell:cell]) {
        [_refreshView startLoading];
    }
}

- (void)horizenScrollCellContentViewStopLoading:(SSHorizenScrollViewCell *)cell
{
    if (_delegate && [_delegate respondsToSelector:@selector(exploreMainListViewDisplayViewDidEndLoad:)]) {
        [_delegate exploreMainListViewDisplayViewDidEndLoad:self];
    }

    if (!_refreshView.hidden && cell.isCurrentDisplayCell &&
        [self shouldAnimateRefreshViewWithScrollViewCell:cell]) {
        [_refreshView endLoading];
    }
}

- (void)categoryHasChangedNotification:(NSNotification *)notification
{
    [self categoryGotFinished:notification];
}

- (void)categoryGotFinished:(NSNotification*)notification
{
    [_categorySelectorView refreshWithCategories:[[ArticleCategoryManager sharedManager] subScribedCategories]];//刚开始启动的时候,_categorySelectorView可能还没有初始化,但是不影响结果,在willAppear中会再次调用.
     
    if ([_exploreListView currentCellIndex] < [_showCategoryModes count]) {
        CategoryModel * model = [_showCategoryModes objectAtIndex:[_exploreListView currentCellIndex]];
        [_categorySelectorView selectCategory:model];
    }
    
    [self reloadExploreListView];
}

- (void)categorySelectorView:(CategorySelectorView *)selectorView selectCategory:(CategoryModel *)category
{
    [self selectCategory:category];
}

- (void)categorySelectorView:(CategorySelectorView *)selectorView didClickExpandButton:(UIButton *)expandButton
{
    if ([ArticleCategoryOptimizingBubbleView isShown]) {
        ssTrackEvent(@"channel_manage", @"tip_open");
    }
    ssTrackEvent(@"channel_manage", @"open");
    
    [self showCategoryViewController];
    
    [ArticleCategoryOptimizingBubbleView dismissIfNeeded];
}

- (void)getOptimizedCategoriesFinished:(NSNotification *)notification
{
    if ([ArticleOptimizedCategoryManager sharedManager].needShowBubbleView) {
        UIViewController * topVC = [SSCommon topViewControllerFor:self];
        UIView * topView = topVC.view;
        if (topVC.navigationController) {
            topView = topVC.navigationController.view;
        }
        [ArticleCategoryOptimizingBubbleView showInView:topView withFrameOrigin:CGPointMake(SSWidth(self) - 8.f - kArticleCategoryOptimizingBubbleViewWidth, _topInset - 8.f)];
    }
}

- (void)showCategoryViewController
{
    [ExploreMovieView removeAllExploreMovieView];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kDisplayCategoryManagerViewNotification object:self userInfo:nil];
}

@end
