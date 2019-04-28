//
//  TTHTSTabViewController.m
//  Article
//
//  Created by 王双华 on 2017/4/12.
//
//

#import "TTHTSTabViewController.h"
#import "UIViewController+Track.h"
#import "UIViewController+NavigationBarStyle.h"
#import "TTHTSTabHeaderView.h"
#import "TTHTSWaterfallCollectionView.h"
#import "TTCategory.h"
#import "TTArticleCategoryManager.h"
#import "NewsListLogicManager.h"
#import "TTHTSHeaderScrollView.h"
#import <TTInteractExitHelper.h>
#import "TTInteractExitHelper.h"
#import "TTCustomAnimationDelegate.h"
#import "TTPushAlertManager.h"
#import <ReactiveObjC/ReactiveObjC.h>
#import "TSVTabManager.h"
#import "TSVStartupTabManager.h"
#import "TSVTabTipManager.h"
#import "TSVListAutoRefreshRecorder.h"
#import <TTSettingsManager/TTSettingsManager.h>
#import "TSVPushLaunchManager.h"
#import <TSVEnterTabAutoRefreshConfig.h>

@interface TTHTSTabViewController ()<TTHTSHeaderScrollViewDelegate, UIScrollViewDelegate, TTInteractExitProtocol>

@property (nonatomic) CGFloat topInset;
@property (nonatomic) CGFloat bottomInset;

@property (nonatomic, strong) SSThemedView *statusBarBackView;
@property (nonatomic, strong) TTHTSHeaderScrollView *headerContainerScrollView;
@property (nonatomic, strong) TTHTSTabHeaderView *headerView;
@property (nonatomic, strong) TTHTSWaterfallCollectionView *htsWaterfallView;

@property (nonatomic, strong) TTCategory *category;
@property (nonatomic, assign) BOOL firstTimeEnterShortVideoTab;

@end

@implementation TTHTSTabViewController

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        _firstTimeEnterShortVideoTab = YES;
    }
    return self;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    [[TTCustomAnimationManager sharedManager] registerFromVCClass:[self class] toVCClass:NSClassFromString(@"AWEVideoDetailViewController") animationClass:[TSVShortVideoEnterDetailAnimation class]];
    
    self.hidesBottomBarWhenPushed = NO;
    self.statusBarStyle = SSViewControllerStatsBarDayWhiteNightBlackStyle;
    self.ttStatusBarStyle = UIStatusBarStyleDefault;
    self.ttHideNavigationBar = YES;
    self.ttTrackStayEnable = YES;
    //必须设置，否则scrollView会异常
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(htsTabbarTapped:)
                                                 name:kHTSTabbarClickedNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(tabbarKeepClick:)
                                                 name:kTSVTabbarContinuousClickNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(themeChanged:)
                                                 name:TTThemeManagerThemeModeChangedNotification
                                               object:nil];
    
    [[[[NSNotificationCenter defaultCenter] rac_addObserverForName:kExploreTabBarClickNotification object:nil]
      takeUntil:self.rac_willDeallocSignal]
     subscribeNext:^(NSNotification *notification) {
         NSDictionary *userInfo = notification.userInfo;
         [[TSVTabManager sharedManager] enterOrLeaveShortVideoTabWithLastViewController:userInfo[@"lastViewController"]
                                                                  currentViewController:userInfo[@"currentViewController"]];
     }];
    
    [self buildSubviews];
    
    [self themeChanged:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.htsWaterfallView willAppear];
    [self.headerView refreshUI];
    [self trackForHeadViewShow];
    
    [TSVStartupTabManager sharedManager].shortVideoTabViewControllerVisibility = YES;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    [self.htsWaterfallView didAppear];

    if ([[TSVPushLaunchManager sharedManager] shouldAutoRefresh]) {
        [self.headerContainerScrollView scrollDown];
        [[TSVPushLaunchManager sharedManager] setShouldAutoRefresh:NO];
        self.firstTimeEnterShortVideoTab = NO;
        [self.htsWaterfallView refreshListViewForCategory:_category isDisplayView:YES fromLocal:YES fromRemote:YES reloadFromType:ListDataOperationReloadFromTypeAuto listEntrance:@"main_tab"];
    }
    
    [TTPushAlertManager enterFeedPage:TTPushWeakAlertPageTypeSmallVideoFeed];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.htsWaterfallView willDisappear];
    
    [TTPushAlertManager leaveFeedPage:TTPushWeakAlertPageTypeSmallVideoFeed];
    
    [TSVStartupTabManager sharedManager].shortVideoTabViewControllerVisibility = NO;
}

- (void)buildSubviews
{
    [self setInset];
    
    CGFloat statusBarHeight = [TTDeviceHelper isIPhoneXDevice] ? 44 : 20;
    _statusBarBackView = [[SSThemedView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, statusBarHeight)];
    _statusBarBackView.backgroundColorThemeKey = kColorBackground4;
    [self.view addSubview:_statusBarBackView];
    
    _headerContainerScrollView = [[TTHTSHeaderScrollView alloc] initWithFrame:CGRectMake(0, statusBarHeight, self.view.width, self.view.height - statusBarHeight)];
    _headerContainerScrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    _headerContainerScrollView.backgroundColorThemeKey = kColorBackground2;
    _headerContainerScrollView.delegate = self;
    _headerContainerScrollView.animationEnable = NO;
    [self.view addSubview:_headerContainerScrollView];
    
    UIScrollView * listViewContainerScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, self.view.height - statusBarHeight)];
    listViewContainerScrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    listViewContainerScrollView.scrollEnabled = NO;
    listViewContainerScrollView.bounces = NO;
    listViewContainerScrollView.scrollsToTop = NO;
    listViewContainerScrollView.contentSize = CGSizeMake(self.view.width, self.view.height - statusBarHeight);
    self.headerContainerScrollView.contentView = listViewContainerScrollView;
    
    _htsWaterfallView = [[TTHTSWaterfallCollectionView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, self.view.height - statusBarHeight) topInset:self.topInset bottomInset:self.bottomInset];
    _htsWaterfallView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [listViewContainerScrollView addSubview:_htsWaterfallView];
    
    if ([SSCommonLogic htsTabBannerEnabled]){
        _headerView = [[TTHTSTabHeaderView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, kTTHTSHeaderViewHeight)];
        _headerContainerScrollView.headerView = _headerView;
    }
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:2];
    [dict setValue:kTTUGCVideoCategoryID forKey:@"category"];
    _category = [TTCategory objectWithDictionary:dict];
}

- (void)setInset
{
    self.topInset = 0;
    
    self.bottomInset = 44 + [TTUIResponderHelper mainWindow].tt_safeAreaInsets.bottom;
}

#pragma mark notification

- (void)themeChanged:(NSNotification *)notification
{
    self.view.backgroundColor = [UIColor tt_themedColorForKey:kColorBackground4];
}

- (void)htsTabbarTapped:(NSNotification*)notification
{
    BOOL shouldAutoRefreshWhenLaunchEnterTab = [[[TTSettingsManager sharedManager] settingForKey:@"tt_huoshan_tab_launch_auto_refresh_enable" defaultValue:@0 freeze:YES] boolValue] && self.firstTimeEnterShortVideoTab;
    BOOL shouldAutoRefreshWhenEnterTab = [TSVEnterTabAutoRefreshConfig shouldAutoRefreshWhenEnterTab];
    
    if (shouldAutoRefreshWhenLaunchEnterTab || shouldAutoRefreshWhenEnterTab) {
        [self.headerContainerScrollView scrollDown];
        [self.htsWaterfallView refreshListViewForCategory:_category isDisplayView:YES fromLocal:YES fromRemote:YES reloadFromType:ListDataOperationReloadFromTypeAuto listEntrance:@"main_tab"];
    } else {
        [self refreshIfNeeded];
    }
    self.firstTimeEnterShortVideoTab = NO;
}

- (void)refreshIfNeeded
{
    BOOL shouldAutoRefreshWhenDisplayingRedDot = [[TSVTabTipManager sharedManager] shouldAutoReloadFromRemoteForCategory:self.category.categoryID listEntrance:@"main_tab"];
    BOOL shouldAutoRefreshWhenEnteringOverTime = [TSVListAutoRefreshRecorder shouldAutoRefreshForCategory:self.category];
    ListDataOperationReloadFromType type;
    if (shouldAutoRefreshWhenDisplayingRedDot) {
        type = ListDataOperationReloadFromTypeTip;
    } else if (shouldAutoRefreshWhenEnteringOverTime) {
        type = ListDataOperationReloadFromTypeAuto;
    } else {
        type = ListDataOperationReloadFromTypeNone;
    }
    if (shouldAutoRefreshWhenDisplayingRedDot || shouldAutoRefreshWhenEnteringOverTime) {
        [self.headerContainerScrollView scrollDown];
        [self.htsWaterfallView refreshListViewForCategory:_category isDisplayView:YES fromLocal:YES fromRemote:YES reloadFromType:type listEntrance:@"main_tab"];
    } else if (![self.htsWaterfallView tt_hasValidateData]) {
        [self.headerContainerScrollView scrollDown];
        [self.htsWaterfallView refreshListViewForCategory:_category isDisplayView:YES fromLocal:YES fromRemote:NO reloadFromType:type listEntrance:@"main_tab"];
    }
}

- (void)tabbarKeepClick:(NSNotification*)notification
{
    [self.headerContainerScrollView scrollDown];
    [self.htsWaterfallView setRefreshFromType:ListDataOperationReloadFromTypeTab];
    [self.htsWaterfallView pullAndRefresh];
}

- (void)trackStartedByAppWillEnterForground
{
    [self.htsWaterfallView listViewWillEnterForground];
    [self.headerView refreshUI];
    [self trackForHeadViewShow];
}

- (void)trackEndedByAppWillEnterBackground
{
    [self.htsWaterfallView listViewWillEnterBackground];
}

#pragma mark -- UIScrollViewDelegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self headViewScrollDidEnd:scrollView];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (!decelerate) {
        [self headViewScrollDidEnd:scrollView];
    }
}

- (void)headViewScrollDidEnd:(UIScrollView *)scrollView
{
    if (_headerView) {
        BOOL isDisplayViewBeforeScroll = self.headerView.isDisplayView;
        if (scrollView.contentOffset.y < 0) {
            self.headerView.isDisplayView = YES;
        }
        else{
            self.headerView.isDisplayView = NO;
        }
        //headview滑动到屏幕上时
        if (!isDisplayViewBeforeScroll) {
            [self trackForHeadViewShow];
        }
    }
}

//顶部banner出现在屏幕中
- (void)trackForHeadViewShow
{
    if (_headerView) {
        if (_headerContainerScrollView.contentOffset.y < 0) {
            [TTTrackerWrapper eventV3:@"huoshan_download_banner_show" params:nil];
        }
    }
}

#pragma mark -  InteractExitProtocol

- (UIView *)suitableFinishBackView{
    return self.htsWaterfallView;
}

@end
