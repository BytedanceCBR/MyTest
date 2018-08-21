//
//  TTExploreMainViewController.m
//  Article
//
//  Created by 刘廷勇 on 15/9/23.
//
//

#import <TTBaseLib/NSObject+TTAdditions.h>
#import "TTExploreMainViewController.h"
#import "TTArticleTabBarController.h"
#import "TTCategorySelectorView.h"
#import "TTArticleCategoryManager.h"
#import "ArticleCategoryManagerView.h"
#import "NewsListLogicManager.h"
#import "ExploreMovieView.h"
#import "ExploreSubscribeDataListManager.h"
#import "ExploreSearchViewController.h"
#import "TTNavigationController.h"
#import "ArticleFetchSettingsManager.h"
#import "NewsBaseDelegate.h"
#import "UIViewAdditions.h"
#import "TTAuthorizeManager.h"
#import "TTSeachBarView.h"
#import "TTTopBar.h"
#import "TTTopBarManager.h"
#import "TTDeviceHelper.h"
#import "UIImage+TTThemeExtension.h"
#import "UIViewController+RefreshEvent.h"
#import "ExploreMixedListView.h"
#import <Crashlytics/Crashlytics.h>
#import "TTCustomAnimationNavigationController.h"
#import "TTProfileViewController.h"
#import "TTAccountBindingMobileViewController.h"
#import "TTFeedCollectionViewController.h"
#import "TTPlatformSwitcher.h"
//#import "TTFollowCategoryMixedListView.h"
#import "TTModalContainerController.h"
#import <TTInteractExitHelper.h>
#import "TTFeedGuideView.h"
//#import "SSADManager.h"
#import "TTAdSplashMediator.h"
#import "TTPushAlertManager.h"
#import "TTArticleSearchManager.h"
#import "TTRNView.h"
//#import "TTContactsGuideManager.h"
#import "TTTabBarProvider.h"

@interface TTExploreMainViewController () <TTCategorySelectorViewDelegate, ExploreSearchViewDelegate, TTTopBarDelegate, UINavigationControllerDelegate, TTFeedCollectionViewControllerDelegate, TTInteractExitProtocol>

//新版首页
@property (nonatomic, strong) TTFeedCollectionViewController *collectionVC;

@property (nonatomic, copy) NSString *lastRefreshedCategoryID;
@property (nonatomic, assign) BOOL hasReloadData;
@property (nonatomic, assign) BOOL hasShownCategoryView;
@property (nonatomic, strong) TTTopBar *topBar;
@property (nonatomic, strong) NSArray *guideControlArray;
@property (nonatomic, strong) TTSeachBarView *searchBar;
@property (nonatomic, strong) NSTimer *weatherTimer;
@property (nonatomic, copy) NSDate *lastShouldFireDate; // 退到后台后停止定时器，记录触发时间，进入前台后恢复定时器

@property (nonatomic) BOOL isRefreshByClickTabBar;

@property (nonatomic) BOOL adShow;

@property (nonatomic, weak) TTFeedGuideView *feedGuideView;

@end

@implementation TTExploreMainViewController

+ (BOOL)isNewFeed {
    return YES;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    [self registerNotifications];
    
    [self setInset];
    
    [self addChildViewController:self.collectionVC];
    [self.view addSubview:self.collectionVC.view];
    //[self.collectionVC didMoveToParentViewController:self];
    
    [self themeChanged:nil];
    
    // Ugly code
    // 由于该manager用于监听 “添加/取消订阅”，需保证在启动时实例化
    [ExploreSubscribeDataListManager shareManager];

//    [self showContactsGuideViewIfNeeded];

    [self setupTopBar];
    [self tryGetCategories];
    
//    self.adShow = [SSADManager shareInstance].adShow;
    self.adShow = [TTAdSplashMediator shareInstance].isAdShowing;

}

- (void)dealloc
{
    [self unregisterNotifications];
}

- (void)setupTopBarConstraints
{
    [self.topBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.equalTo(self.view);
        make.height.mas_equalTo(self.topInset);
    }];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [SharedAppDelegate trackCurrentIntervalInMainThreadWithTag:@"ExploreMainViewController ViewAppear"];

    if (!self.adShow) {
        [self showFeedGuideView];
    }
    
//    [self showPushAuthorizeAlertIfNeed];
    
    [TTPushAlertManager enterFeedPage:TTPushWeakAlertPageTypeMainFeed];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if (self.hasShownCategoryView) {
        [self closeCategoryViewController];
        self.hasShownCategoryView = NO;
    }
    
    // 通过推送等方式跳转页面需要关掉引导
    [self.feedGuideView dismiss];

    [TTPushAlertManager leaveFeedPage:TTPushWeakAlertPageTypeMainFeed];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

#pragma mark -
#pragma mark methods

- (void)setInset
{
    CGFloat bottomPadding = 0;
    CGFloat topPadding = 0;
    
    topPadding = 20 + kTopSearchButtonHeight + kSelectorViewHeight;
    bottomPadding = 44;
    
    if ([TTDeviceHelper isIPhoneXDevice]){
        topPadding = 44.f + kTopSearchButtonHeight + kSelectorViewHeight;
    }
    
    self.topInset = topPadding;
    self.bottomInset = bottomPadding;
}

- (void)setupTopBar {
    [self.view addSubview:self.topBar];
}

// only get category when local storage only has default category
- (void)tryGetCategories
{
    NSArray *categories = [[TTArticleCategoryManager sharedManager] allCategories];
    if([categories count] <= 1) {
        [[TTArticleCategoryManager sharedManager] startGetCategory];
    } else {
        // [self categoryGotFinished:nil];
        if (self.hasReloadData) {
            self.hasReloadData = NO;
        }else{
            [self categoryGotFinished:nil];
        }
    }
}

- (void)categoryGotFinished:(NSNotification*)notification
{
    self.hasReloadData = YES;
    NSArray *preFixedAndSubscribeCategories = [[[TTArticleCategoryManager sharedManager] preFixedAndSubscribeCategories] copy];
    [self.categorySelectorView refreshWithCategories:preFixedAndSubscribeCategories];
    
    self.collectionVC.pageCategories = preFixedAndSubscribeCategories;
    TTCategory *model = [self.collectionVC currentCategory];
    [self.categorySelectorView selectCategory:model];
}

- (void)categorySelectorView:(TTCategorySelectorView *)selectorView selectCategory:(TTCategory *)category
{
    [self selectCategory:category];
    self.hasShownCategoryView = NO;
}

- (void)categorySelectorView:(TTCategorySelectorView *)selectorView closeCategoryView:(BOOL)animated{
    [self.collectionVC viewWillAppear:NO];
    [self.collectionVC viewDidAppear:NO];
    self.hasShownCategoryView = NO;
}

- (void)categorySelectorView:(TTCategorySelectorView *)selectorView didClickExpandButton:(UIButton *)expandButton
{
    [self.collectionVC viewWillDisappear:NO];
    [self.collectionVC viewDidDisappear:NO];
    
    wrapperTrackEvent(@"channel_manage", @"open");
    
    [self showCategoryViewController];
}

- (void)categorySelectorView:(TTCategorySelectorView *)selectorView didClickSearchButton:(UIButton *)searchButton
{
    ExploreSearchViewController * viewController = [[ExploreSearchViewController alloc] initWithNavigationBar:YES showBackButton:NO queryStr:nil fromType:ListDataSearchFromTypeTab];
    [TTTrackerWrapper eventV3:@"search_tab_click" params:@{@"search_source":@"top_bar",
                                                           @"from_tab_name" : @"home"}];
    [self.navigationController pushViewController:viewController animated:YES];
}

- (void)showCategoryViewController
{
    [ExploreMovieView removeAllExploreMovieView];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kDisplayCategoryManagerViewNotification object:self userInfo:nil];
    
    self.hasShownCategoryView = YES;
}

- (void)closeCategoryViewController
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kCloseCategoryManagerViewNotification object:self userInfo:nil];
}

- (NSArray<NSString *> *)categorySelectorTextColors {
    if ([TTTopBarManager sharedInstance_tt].topBarConfigValid.boolValue) {
        return [TTTopBarManager sharedInstance_tt].selectorViewTextColors;
    } else {
        return nil;
    }
}

- (NSArray <NSString *> *)categorySelectorTextGlowColors {
    if ([TTTopBarManager sharedInstance_tt].topBarConfigValid.boolValue && [TTTopBarManager sharedInstance_tt].selectorViewTextGlowColors.count == 4) {
        return [TTTopBarManager sharedInstance_tt].selectorViewTextGlowColors;
    } else {
        return nil;
    }
}

- (CGFloat)categorySelectorTextGlowSize {
    if ([TTTopBarManager sharedInstance_tt].topBarConfigValid.boolValue && [TTTopBarManager sharedInstance_tt].selectorViewTextGlowSize > 0) {
        return [TTTopBarManager sharedInstance_tt].selectorViewTextGlowSize;
    } else {
        return 0;
    }
}

#pragma mark categorys

- (void)selectCategory:(TTCategory *)category
{
    NSString * oldChannleId = self.collectionVC.currentCategory.categoryID;
    
    NSString * lastRefreshedCategoryID = self.lastRefreshedCategoryID;
    
    BOOL didClickedSameCategory;
    if (category.categoryID && [category.categoryID isEqualToString:oldChannleId]) {
        didClickedSameCategory = YES;
    } else {
        didClickedSameCategory = NO;
    }
    
    NSUInteger index = NSNotFound;

    index = [self.collectionVC.pageCategories indexOfObject:category];
    
    if (index != NSNotFound) {
        [self.collectionVC setCurrentIndex:index scrollToPositionAnimated:NO];
    }
    
    if (![SSCommonLogic boolForKey:@"tt_refresh_by_click_category"]) {
        lastRefreshedCategoryID = self.lastRefreshedCategoryID;
    }
    
    if ((isEmptyString(lastRefreshedCategoryID) || [lastRefreshedCategoryID isEqualToString:category.categoryID]))
    {
        id<TTFeedCollectionCell> currentCell = self.collectionVC.currentCollectionPageCell;
        
        if (didClickedSameCategory) {
            self.isRefreshByClickTabBar = NO;
            
            BOOL hasTip = [self isTabbarHasTip];
            ListDataOperationReloadFromType refreshFromType = hasTip ? ListDataOperationReloadFromTypeClickCategoryWithTip : ListDataOperationReloadFromTypeClickCategory;
            [currentCell refreshDataWithType:refreshFromType];
            
            [self sendClickRefreshEventWithCateogry:category hasTip:hasTip];
        }
        
        if ([category.categoryID isEqualToString:kTTSubscribeCategoryID])
        {
            wrapperTrackEvent(@"subscription", @"tab_refresh");
        }
        
        NSString *eventStr = @"navigation";
        wrapperTrackEvent(eventStr, [NSString stringWithFormat:@"click_%@", category.categoryID]);
    }
    
    if (![category.categoryID isEqualToString:self.lastRefreshedCategoryID]) {
        UIWindow * mainWindow = [[UIApplication sharedApplication].delegate window];
        TTArticleTabBarController * tabBarController = (TTArticleTabBarController *)mainWindow.rootViewController;
        if ([tabBarController isKindOfClass:[TTArticleTabBarController class]]) {
            [tabBarController didChangeCategory];
        }
    }
    self.lastRefreshedCategoryID = category.categoryID;
}

- (void)sendClickRefreshEventWithCateogry:(TTCategory *)category hasTip:(BOOL)hasTip {
    NSString *label = nil;
    if(hasTip){
        label = @"refresh_click_tip";
    }
    else{
        label = @"refresh_click";
    }
    label = [self modifyEventLabelForRefreshEvent:label categoryModel:category];
    
    NSString *event = nil;
    if([category.categoryID isEqualToString:kTTMainCategoryID]){
        event = @"new_tab";
    }
    else if ([category.categoryID isEqualToString:kTTUGCVideoCategoryID]){
        return;//火山
    }
    else{
        event = @"category";
    }
    
    NSMutableDictionary * dictionary = [NSMutableDictionary dictionary];
    [dictionary setValue:label forKey:@"label"];
    [dictionary setValue:@"umeng" forKey:@"category"];
    [dictionary setValue:event forKey:@"tag"];
    [dictionary setValue:category.categoryID forKey:@"category_id"];
    [dictionary setValue:category.concernID forKey:@"concern_id"];
    [dictionary setValue:@(1) forKey:@"refer"];
    if (![TTTrackerWrapper isOnlyV3SendingEnable]) {
        [TTTrackerWrapper eventData:dictionary];
    }
    
    //log3.0
    [self trackRefreshEvent3Label:hasTip?@"click_tip":@"click" category:category];
}

#pragma mark - notifications

- (void)registerNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mainTabbarClicked:) name:kMainTabbarKeepClickedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(categoryGotFinished:) name:kAritlceCategoryGotFinishedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(categoryHasChangedNotification:) name:kArticleCategoryHasChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(themeChanged:) name:TTThemeManagerThemeModeChangedNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(adShowFinish:) name:kTTAdSplashShowFinish object:nil];
}

- (void)unregisterNotifications
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)mainTabbarClicked:(NSNotification *)notification
{
    BOOL hasTip = [[[notification userInfo] objectForKey:kMainTabbarClickedNotificationUserInfoHasTipKey] boolValue];
    BOOL showFriendLabel = [[[notification userInfo] objectForKey:kMainTabbarClickedNotificationUserInfoShowFriendLabelKey] boolValue];
    if (showFriendLabel) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kExploreFetchListShowFriendLabelKey];
        
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    id<TTFeedCollectionCell> currentCell = self.collectionVC.currentCollectionPageCell;
    
    self.isRefreshByClickTabBar = YES;
    
    ListDataOperationReloadFromType refreshFromType = hasTip ? ListDataOperationReloadFromTypeTabWithTip : ListDataOperationReloadFromTypeTab;
    [currentCell refreshDataWithType:refreshFromType];
    
    id<TTFeedCategory> category = self.collectionVC.currentCategory;
    
    if (![TTTrackerWrapper isOnlyV3SendingEnable]) {
        if ([category.categoryID isEqualToString:kTTMainCategoryID]) {
            if (hasTip) {
                wrapperTrackEvent(@"new_tab", @"tab_refresh_tip");
            }
            else {
                wrapperTrackEvent(@"new_tab", @"tab_refresh");
            }
        }
        else if(![category.categoryID isEqualToString:kTTUGCVideoCategoryID]){
            TTCategory *ttCategory = (TTCategory *)category;
            if (hasTip) {
                wrapperTrackEvent(@"category", [self modifyEventLabelForRefreshEvent:@"tab_refresh_tip" categoryModel:ttCategory]);
            }
            else {
                wrapperTrackEvent(@"category", [self modifyEventLabelForRefreshEvent:@"tab_refresh" categoryModel:ttCategory]);
            }
        }
    }
    //log3.0
    [self trackRefreshEvent3Label:hasTip?@"tab_tip":@"tab" category:(TTCategory *)category];
}

- (void)trackRefreshEvent3Label:(NSString *)label category:(TTCategory *)category
{
    if (isEmptyString(label) || !category) {
        return;
    }
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:4];
    [dict setValue:category.categoryID forKey:@"category_name"];
    [dict setValue:category.concernID forKey:@"concern_id"];
    [dict setValue:@(1) forKey:@"refer"];
    [dict setValue:label forKey:@"refresh_type"];
//    [TTTrackerWrapper eventV3:@"category_refresh" params:dict isDoubleSending:YES];
}

- (void)applicationDidEnterBackground:(NSNotification *)notification
{
    [[NewsListLogicManager shareManager] didEnterBackground];
    [self.collectionVC.currentCollectionPageCell cellWillEnterBackground];
}

- (void)applicationWillEnterForeground:(NSNotification*)notification
{
    [[NewsListLogicManager shareManager] willEnterForground];
    
    NSUInteger index = [TTArticleCategoryManager sharedManager].preFixedCategories.count;

    [self.collectionVC.currentCollectionPageCell cellWillEnterForground];
        
    //自动切换回推荐列表
    if ([[NewsListLogicManager shareManager] needSwitchToRecommendTab]) {
        if (index < self.collectionVC.pageCategories.count) {
            [self.collectionVC setCurrentIndex:index scrollToPositionAnimated:NO];
        }
    }

}

- (void)categoryHasChangedNotification:(NSNotification *)notification
{
    [self categoryGotFinished:notification];
}

- (void)themeChanged:(NSNotification *)notification
{
    self.view.backgroundColor = [UIColor tt_themedColorForKey:kColorBackground4];
}

- (void)showFeedSearchGuideView {
// 搜索引导
}

- (void)showFeedGuideView {
    return;
    if ([TTFeedGuideView isFeedGuideTypeEnabled:TTFeedGuideTypeSearch]) {
        [self showFeedSearchGuideView];
    }
}

//- (void)showContactsGuideViewIfNeeded {
//    if ([[TTContactsGuideManager sharedManager] shouldCheckContactsValidation]) {
//        [[TTContactsGuideManager sharedManager] checkContactsValidation];
//    } else if ([[TTContactsGuideManager sharedManager] shouldPresentContactsGuideView]) {
//        [[TTContactsGuideManager sharedManager] presentContactsGuideView];
//    }
//}

#pragma mark - TTFeedCollectionViewControllerDelegate

- (void)ttFeedCollectionViewController:(TTFeedCollectionViewController *)vc scrollFromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex completePercent:(CGFloat)percent
{
    [self.categorySelectorView moveSelectFrameFromIndex:fromIndex toIndex:toIndex percentage:percent];
}

- (void)ttFeedCollectionViewController:(TTFeedCollectionViewController *)vc willScrollToIndex:(NSInteger)toIndex
{
    [self.categorySelectorView scrollToCategory:[vc categoryAtIndex:toIndex]];
}

- (void)ttFeedCollectionViewController:(TTFeedCollectionViewController *)vc didScrollToIndex:(NSInteger)toIndex
{
    [self.categorySelectorView selectCategory:[vc categoryAtIndex:toIndex]];

    UIWindow * mainWindow = [[UIApplication sharedApplication].delegate window];
    TTArticleTabBarController * tabBarController = (TTArticleTabBarController *)mainWindow.rootViewController;
    if ([tabBarController isKindOfClass:[TTArticleTabBarController class]]) {
        [tabBarController didChangeCategory];
        
        if ([[TTTabBarProvider currentSelectedTabTag] isEqualToString:kTTTabHomeTabKey]) {
            // 清除tab红点
            [[NSNotificationCenter defaultCenter] postNotificationName:kChangeExploreTabBarBadgeNumberNotification object:nil userInfo:@{kExploreTabBarItemIndentifierKey:kTTTabHomeTabKey, kExploreTabBarBadgeNumberKey:@(0)}];
        }
    }
    
    self.lastRefreshedCategoryID = self.collectionVC.currentCategory.categoryID;
//    [self showPushAuthorizeAlertIfNeed];
    self.isChangeChannel = YES;
}

- (void)ttFeedCollectionViewControllerWillBeginDragging:(UIScrollView *)scrollView
{
    //按住RNCell滑动列表时需要主动调用RCTRootView的cancelTouches方法，否则松手后仍会触发点击事件
    [[NSNotificationCenter defaultCenter] postNotificationName:kTTRNViewCancelTouchesNotification object:nil];
}

- (void)ttFeedCollectionViewControllerDidStartLoading:(TTFeedCollectionViewController *)vc
{
    if (self.startLoadingBlock) {
        self.startLoadingBlock();
    }
}

- (void)ttFeedCollectionViewControllerDidFinishLoading:(TTFeedCollectionViewController *)vc isUserPull:(BOOL)userPull
{
    if (self.finishLoadingBlock) {
        self.finishLoadingBlock();
    }
    self.isRefreshByClickTabBar = NO;
}

#pragma mark -
#pragma mark setters and getters

- (TTFeedCollectionViewController *)collectionVC
{
    if (!_collectionVC) {
        _collectionVC = [[TTFeedCollectionViewController alloc] initWithName:@"mainTab" topInset:self.topInset bottomInset:self.bottomInset];
        _collectionVC.delegate = self;
    }
    return _collectionVC;
}

- (TTCategorySelectorView *)categorySelectorView
{
    if (!_categorySelectorView) {
        TTCategorySelectorViewStyle style = [TTDeviceHelper isPadDevice] ? TTCategorySelectorViewBlackStyle : TTCategorySelectorViewLightStyle;
        _categorySelectorView = [[TTCategorySelectorView alloc] initWithFrame:CGRectZero style:style
                                                                      tabType:TTCategorySelectorViewNewsTab];
        _categorySelectorView.delegate = self;
    }
    return _categorySelectorView;
}

- (TTTopBar *)topBar {
    if (!_topBar) {
        _topBar = [[TTTopBar alloc] init];
        _topBar.tab = @"home";
        [self.view addSubview:_topBar];
        [_topBar addTTCategorySelectorView:self.categorySelectorView delegate:self];
        [self setupTopBarConstraints];
        _topBar.delegate = self;
        [_topBar setupSubviews];
    }
    return _topBar;
}

#pragma mark -- Helper

- (BOOL)isRecommendChannel {
    return [self.collectionVC.currentCategory.categoryID isEqualToString:kTTMainCategoryID];
}

#pragma mark -- ExploreSearchViewDelegate Method
- (void)searchBarButtonActionFired:(id)sender {
    
    if ([SSCommonLogic threeTopBarEnable]){
        [TTTrackerWrapper eventV3:@"search_tab_click" params:@{@"search_source":@"top_bar",
                                                               @"from_tab_name" : @"home"}];
    }else{
        wrapperTrackEvent(@"search_tab", @"top_bar_click");
    }
    TLS_LOG(@"searchBarButtonActionFired");
    
    ExploreSearchViewController *searchViewController = [[ExploreSearchViewController alloc] initWithNavigationBar:NO];
    searchViewController.fromTabName = _topBar.tab;
    searchViewController.animatedWhenDismiss = YES;
    [searchViewController view]; //preload view
    searchViewController.searchView.searchViewDelegate = self;
    searchViewController.searchView.isFromTopSearchbar = YES;
    searchViewController.searchView.categoryID = self.collectionVC.currentCategory.categoryID;
    
    if ([SSCommonLogic useNewSearchTransitionAnimation] && [SSCommonLogic isSearchTransitionEnabled]) {
        searchViewController.ttNavBarStyle = @"Red";
        if ([TTTopBarManager sharedInstance_tt].topBarConfigValid.boolValue) {
            searchViewController.ttHideNavigationBar = YES;
        }
        [((TTNavigationController *)self.navigationController) pushViewControllerByTransitioningAnimation:searchViewController animated:YES];
        [TTCustomAnimationManager sharedManager].pushSearchVCWithCustomAnimation = YES;
    } else {
        if ([TTDeviceHelper isPadDevice] || ![TTTabBarProvider isMineTabOnTabBar] || ![SSCommonLogic isSearchTransitionEnabled]){
            [self.navigationController pushViewController:searchViewController animated:YES];
            [TTCustomAnimationManager sharedManager].pushSearchVCWithCustomAnimation = NO;
        }
        else{
            [((TTNavigationController *)self.navigationController) pushViewControllerByTransitioningAnimation:searchViewController animated:YES];
            [TTCustomAnimationManager sharedManager].pushSearchVCWithCustomAnimation = YES;
        }
    }
}

- (void)searchViewCancelButtonClicked:(ExploreSearchView *)searchView {
}

#pragma mark -- Check GuideView Show

- (void)showPushAuthorizeAlertIfNeed {
    if ([self isRecommendChannel] && [TTGuideDispatchManager sharedInstance_tt].isQueueEmpty) {
        [[TTAuthorizeManager sharedManager].pushObj showAlertAtActionFeedRefreshWithCompletion:nil sysAuthFlag:0];//显示系统弹窗前显示自有弹窗的逻辑下掉，0代表直接显示系统弹窗，1代表先自有弹窗，再系统弹窗
    }
}

#pragma mark - TTTopBarDelegate Method

- (void)searchActionFired:(id)sender {
    [self searchBarButtonActionFired:sender];
}

- (void)mineActionFired:(id)sender {
    // 标记能够展示绑定手机号逻辑
//    [TTAccountBindingMobileViewController setShowBindingMobileEnabled:YES];
    
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Profile" bundle:nil];
    TTProfileViewController *profileVC = [sb instantiateInitialViewController];
    profileVC.fromTab = _topBar.tab;
    [self.navigationController pushViewController:profileVC animated:YES];
}

+ (TTSeachBarView *)searchBar {
    TTSeachBarView * searchBar = [[TTSeachBarView alloc] init];
    searchBar.backgroundColor = [UIColor clearColor];
    searchBar.searchField.userInteractionEnabled = NO;
    searchBar.bottomLineView.hidden = YES;
    searchBar.inputBackgroundView.backgroundColorThemeKey = kColorBackground10;
    searchBar.inputBackgroundView.layer.borderWidth = 0.f;
    return searchBar;
}

#pragma mark -  InteractExitProtocol

- (UIView *)suitableFinishBackView{
    return _collectionVC.view;
}

- (void)adShowFinish:(NSNotification *)notification {
    if ([TTDeviceHelper isPadDevice]) {
        return;
    }
    
    UIWindow * mainWindow = [[UIApplication sharedApplication].delegate window];
    
    if (![mainWindow.rootViewController isKindOfClass:[TTArticleTabBarController class]]) {
        return;
    }
    
    TTArticleTabBarController *tabBarController = (TTArticleTabBarController *)mainWindow.rootViewController;
    if (tabBarController.selectedIndex != 0) {
        return;
    }
    
    UINavigationController * nav = [tabBarController.viewControllers objectAtIndex:0];
    if ([nav isKindOfClass:[UINavigationController class]]
        && nav.viewControllers.count == 1) {
        [self showFeedGuideView];
    }
    
    self.adShow = NO;
}

#pragma safeInset
- (void)viewSafeAreaInsetsDidChange
{
    [super viewSafeAreaInsetsDidChange];
    UIEdgeInsets safeInset = self.view.safeAreaInsets;
    if (safeInset.top > self.topInset){
        self.topInset = safeInset.top;
        [self.topBar mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.top.right.equalTo(self.view);
            make.height.mas_equalTo(self.topInset);
        }];
    }
}

- (UIEdgeInsets)additionalSafeAreaInsets
{
    UIEdgeInsets additionalSafeAreaInsets = [super additionalSafeAreaInsets];
    additionalSafeAreaInsets.top += kTopSearchButtonHeight + kSelectorViewHeight;
    return additionalSafeAreaInsets;
}

@end
