//
//  FHHomeViewController.m
//  AFgzipRequestSerializer
//
//  Created by 谢飞 on 2018/12/20.
//

#import "FHHomeViewController.h"
#import "FHHomeListViewModel.h"
#import <TTUIWidget/ArticleListNotifyBarView.h>
#import "FHEnvContext.h"
#import "FHHomeCellHelper.h"
#import "FHHomeConfigManager.h"
#import "TTBaseMacro.h"
#import "TTURLUtils.h"
#import "ToastManager.h"
#import "FHTracerModel.h"
#import "TTCategoryStayTrackManager.h"
#import "FHLocManager.h"
#import "HMDTTMonitor.h"
#import "TTSandBoxHelper.h"
#import "TTArticleCategoryManager.h"
#import "FHHomeScrollBannerCell.h"
#import "TTDeviceHelper.h"
#import "TTAppUpdateHelper.h"
#import "CommonURLSetting.h"
#import "FHCommuteManager.h"
#import "TTUIResponderHelper.h"
#import "TTTabBarController.h"
#import <FHHomeSearchPanelViewModel.h>
#import "ExploreLogicSetting.h"
#import <FHHouseBase/TTSandBoxHelper+House.h>
#import "TTArticleTabBarController.h"
#import <TTUIWidget/UIViewController+NavigationBarStyle.h>
#import "TTThemedAlertController.h"
#import "FHUtils.h"
#import "FHHomeBaseScrollView.h"
#import "FHHomeMainViewController.h"
#import <FHHouseBase/FHHomeScrollBannerView.h>
#import "FHUGCCategoryManager.h"
#import "NSObject+FHTracker.h"
#import "FHUserTracker.h"
#import "FHHomeRenderFlow.h"

static CGFloat const kShowTipViewHeight = 32;

static CGFloat const kSectionHeaderHeight = 38;


@interface FHHomeViewController ()<TTAppUpdateHelperProtocol>

@property (nonatomic, strong) FHHomeListViewModel *homeListViewModel;
@property (nonatomic, assign) BOOL isClickTab;
@property (nonatomic, assign) BOOL isRefreshing;
@property (nonatomic, assign) BOOL isShowToasting;
@property (nonatomic, strong) ArticleListNotifyBarView * notifyBar;
@property (nonatomic) BOOL adColdHadJump;
@property (nonatomic) BOOL adUGCHadJump;
@property (nonatomic, strong) FHHomeSearchPanelViewModel *panelVM;
@property (nonatomic, assign) NSTimeInterval stayTime; //页面停留时间
@property (nonatomic, assign) BOOL isShowing;
@property (nonatomic, assign) BOOL initedViews;

@end

@implementation FHHomeViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        _isMainTabVC = YES;
        [[FHHomeRenderFlow sharedInstance] traceHomeInit];
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    [[FHHomeRenderFlow sharedInstance] traceHomeViewDidLoad];
    self.ttNeedIgnoreZoomAnimation = YES;

    self.ttTrackStayEnable = YES;
    self.isRefreshing = NO;
    self.adColdHadJump = NO;
    self.adUGCHadJump = NO;
    self.automaticallyAdjustsScrollViewInsets = NO;
    [FHEnvContext sharedInstance].isShowingHomeHouseFind = YES;
    
    [self registerNotifications];
    
    [self resetMaintableView];

    // 当HomeViewController被添加为FHHomeMainViewController的子控制器时触发ViewModel的创建和配置
    @weakify(self);
    [[[[RACObserve(self, parentViewController) filter:^BOOL(id  _Nullable value) {
        return value != nil;
    }] take: 1] deliverOnMainThread] subscribeNext:^(id  _Nullable x) {
        @strongify(self);
        if([x isKindOfClass:[FHHomeMainViewController class]]) {
            FHHomeMainViewController *mainVC = (FHHomeMainViewController *)x;
            FHHomeSearchPanelView *searchPanel = mainVC.topView.searchPanelView;
            // 获取导航条上的搜索控件，用于赋值滚动搜索文字
            FHHomeSearchPanelViewModel *panelVM = [[FHHomeSearchPanelViewModel alloc] initWithSearchPanel:searchPanel];
            panelVM.viewController = self;
            self.panelVM = panelVM;
            self.homeListViewModel = [[FHHomeListViewModel alloc] initWithViewController:self.mainTableView andViewController:self andPanelVM:self.panelVM];
        }
    }];
}

- (void)bindIndexChangedBlock
{
    __weak typeof(self) weakSelf = self;
    if ([self.parentViewController isKindOfClass:[FHHomeMainViewController class]]) {
        FHHomeMainViewController *mainVC = (FHHomeMainViewController *)self.parentViewController;
        mainVC.topView.indexHouseChangeBlock = ^(NSInteger index) {
            [weakSelf.homeListViewModel selectIndexHouseType:index];
        };
    }
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_willEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
}

- (void)scrollMainTableToTop
{
    if (self.isShowing) {
        [self.homeListViewModel setUpTableScrollOffsetZero];
    }
}

-(void)dealyIniViews
{

    [self addDefaultEmptyViewFullScreen];
    
    if (!_isMainTabVC) {
        [self.mainTableView removeFromSuperview];
        [self.emptyView showEmptyWithTip:@"功能暂未开通" errorImage:[UIImage imageNamed:@"group-9"] showRetry:NO];
    }
    
    self.mainTableView.scrollsToTop = YES;
}

- (void)setIsShowRefreshTip:(BOOL)isShowRefreshTip {
    _isShowRefreshTip = isShowRefreshTip;
    [self.homeListViewModel setIsShowRefreshTip:isShowRefreshTip];
}

//初始化main table
- (void)resetMaintableView
{
    if (self.mainTableView) {
        [self.mainTableView removeFromSuperview];
    }
    
    self.mainTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
//    self.mainTableView.decelerationRate = 0.5;
    self.mainTableView.showsVerticalScrollIndicator = NO;
    

    [self.view addSubview:self.mainTableView];
    
    self.mainTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [self setUpMainTableConstraints];
    
    [FHHomeCellHelper registerCells:self.mainTableView];
    
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor themeHomeColor];
    self.mainTableView.backgroundColor = [UIColor themeHomeColor];
    FHConfigDataModel *configModel = [[FHEnvContext sharedInstance] getConfigFromCache];
    if (!configModel) {
        [self tt_startUpdate];
    }
    
    if (self.notifyBar) {
        [self.notifyBar removeFromSuperview];
    }
    
    self.notifyBar = [[ArticleListNotifyBarView alloc]initWithFrame:CGRectZero];
    [self.view addSubview:self.notifyBar];
    
    [self.notifyBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self.mainTableView);
        make.height.mas_equalTo(32);
    }];
}

#pragma mark - notifications
- (void)registerNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mainTabbarClicked:) name:kMainTabbarKeepClickedNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(scrollMainTableToTop) name:@"kScrollToTopKey" object:nil];
    
}

- (void)mainTabbarClicked:(NSNotification *)notification
{
    if([FHEnvContext sharedInstance].isShowingHomeHouseFind){
        self.homeListViewModel.reloadType = TTReloadTypeTab;
        [self pullAndRefresh];
    }
}

- (void)setUpMainTableConstraints
{
    if ([TTDeviceHelper isIPhoneXSeries]) {
        [self.mainTableView setFrame:CGRectMake(0.0f, 0, MAIN_SCREEN_WIDTH, MAIN_SCREENH_HEIGHT - 64 - 44 - 49)];
    }else
    {
        [self.mainTableView setFrame:CGRectMake(0.0f, 0, MAIN_SCREEN_WIDTH, MAIN_SCREENH_HEIGHT - 64 - 49)];
    }
}

#pragma mark  埋点
- (void)applicationDidEnterBackground:(NSNotification *)notification {
    self.homeListViewModel.stayTime = 0;
}

- (void)applicationWillEnterForeground:(NSNotification *)notification {
    self.homeListViewModel.stayTime = [[NSDate date] timeIntervalSince1970];
}

-(void)showNotify:(NSString *)message
{
    //如果首页没有显示，则不提示tip
    if (!self.isShowing) {
        return;
    }
    
    [self hideImmediately];
    
    self.isShowRefreshTip = YES;
    
    UIEdgeInsets inset = self.mainTableView.contentInset;
    inset.top = 32;
    self.mainTableView.contentInset = inset;
    WeakSelf;
    [self.notifyBar showMessage:message
              actionButtonTitle:@""
                      delayHide:YES
                       duration:1.8
            bgButtonClickAction:nil
         actionButtonClickBlock:nil
                   didHideBlock:nil
                  willHideBlock:^(ArticleListNotifyBarView *barView, BOOL isImmediately) {
                      [UIView animateWithDuration:0.3 animations:^{
                          UIEdgeInsets inset = self.mainTableView.contentInset;
                          inset.top = 0;
                          self.mainTableView.contentInset = inset;
                          [FHEnvContext sharedInstance].isRefreshFromCitySwitch = NO;
                          self.homeListViewModel.isResetingOffsetZero = NO;
                      }completion:^(BOOL finished) {
                          if(!isImmediately){
                              self.isShowRefreshTip = NO;
                          }
                      }];

    }];
}

- (void)hideImmediately
{
    if(!self.notifyBar.hidden){
        [self.notifyBar hideImmediately];
        self.isShowRefreshTip = NO;
    }
}

- (void)retryLoadData
{
    if (![FHEnvContext isNetworkConnected]) {
        
        if (self.isShowToasting) {
            return;
        }
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            dispatch_async(dispatch_get_main_queue(), ^{
                self.isShowToasting = NO;
            });
        });
        
        if (!self.isShowToasting) {
            [[ToastManager manager] showToast:@"网络异常"];
            self.isShowToasting = YES;
        }
        
        return;
    }
    
    if (self.isRefreshing) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            dispatch_async(dispatch_get_main_queue(), ^{
                self.isRefreshing = NO;
            });
        });
        return;
    }
    
    self.isRefreshing = YES;
    //无网点击重试逻辑
    FHConfigDataModel *configDataModel = [[FHEnvContext sharedInstance] getConfigFromCache];
    if (configDataModel) {
        [self.homeListViewModel updateCategoryViewSegmented:NO];
    }
    
    [FHEnvContext sharedInstance].refreshConfigRequestType = @"refresh_config";
    
    [[FHLocManager sharedInstance] requestCurrentLocation:NO andShowSwitch:NO];
    
    //首次无网启动点击加载重试，增加拉取频道
    if ([TTSandBoxHelper isAPPFirstLaunch]) {
        [[FHUGCCategoryManager sharedManager] startGetCategory];
    }
}

- (void)willAppear
{    
    if (![FHEnvContext isNetworkConnected]) {
        if (self.homeListViewModel.hasShowedData) {
            [[ToastManager manager] showToast:@"网络异常"];
        }else
        {
            [self.view bringSubviewToFront:self.emptyView];
            [self.emptyView showEmptyWithTip:@"网络异常，请检查网络连接" errorImage:[UIImage imageNamed:@"group-4"] showRetry:YES];
        }
    }
    
    self.homeListViewModel.enterType = [TTCategoryStayTrackManager shareManager].enterType != nil ? [TTCategoryStayTrackManager shareManager].enterType : @"default";
    if (self.mainTableView.contentOffset.y > MAIN_SCREENH_HEIGHT) {
        [[FHHomeConfigManager sharedInstance].fhHomeBridgeInstance isShowTabbarScrollToTop:YES];
    }
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if(!_initedViews){
        [self dealyIniViews];
        _initedViews = YES;
    }
    
    self.isShowing = YES;
    self.isShowRefreshTip = NO;
    
    [self scrollToTopEnable:YES];
    
    self.homeListViewModel.enterType = [TTCategoryStayTrackManager shareManager].enterType != nil ? [TTCategoryStayTrackManager shareManager].enterType : @"default";
    
    if (self.mainTableView.contentOffset.y >= [[FHHomeCellHelper sharedInstance] heightForFHHomeHeaderCellViewType] + 80) {
        [[FHHomeConfigManager sharedInstance].fhHomeBridgeInstance isShowTabbarScrollToTop:YES];
    }
    
    self.stayTime = [[NSDate date] timeIntervalSince1970];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.isShowing = NO;
    self.isShowRefreshTip = NO;
    
    if(_isMainTabVC && self.mainTableView.contentOffset.y <= [[FHHomeCellHelper sharedInstance] heightForFHHomeHeaderCellViewType])
    {
        [[FHHomeConfigManager sharedInstance].fhHomeBridgeInstance isShowTabbarScrollToTop:NO];
    }
    
//    [self addStayCategoryLog:self.ttTrackStayTime];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    //开屏广告启动不会展示，保留逻辑代码
    if (!self.adColdHadJump) {
        self.adColdHadJump = YES;
        FHConfigDataModel *currentDataModel = [[FHEnvContext sharedInstance] getConfigFromCache];
        if ([currentDataModel.jump2AdRecommend isKindOfClass:[NSString class]]) {
            TTTabBarController *topVC = [TTUIResponderHelper topmostViewController];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                dispatch_async(dispatch_get_main_queue(), ^{
                    if ([topVC tabBarIsVisible] && !topVC.tabBar.hidden) {
                        [self traceJump2AdEvent:currentDataModel.jump2AdRecommend];
                        if ([currentDataModel.jump2AdRecommend containsString:@"://commute_list"]){
                            //通勤找房
                            [[FHCommuteManager sharedInstance] tryEnterCommutePage:currentDataModel.jump2AdRecommend logParam:nil];
                        }else
                        {
                            [[TTRoute sharedRoute] openURLByPushViewController:[NSURL URLWithString:currentDataModel.jump2AdRecommend]];
                        }
                    }
                });
            });
        }
    }
    
    [TTSandBoxHelper setAppFirstLaunchForAd];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"FHHomeMainDidScrollEnd" object:nil];
    
    [self bindIndexChangedBlock];
    
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
}


-(void)addStayCategoryLog:(NSTimeInterval)stayTime {
//    NSMutableDictionary *tracerDict = [NSMutableDictionary new];
//    NSTimeInterval duration = ([[NSDate date] timeIntervalSince1970] -  self.stayTime) * 1000.0;
//    [tracerDict setValue:@"main" forKey:@"tab_name"];
//    [tracerDict setValue:@(0) forKey:@"with_tips"];
//    [tracerDict setValue:[FHEnvContext sharedInstance].isClickTab ? @"click_tab" : @"default" forKey:@"enter_type"];
//    tracerDict[@"stay_time"] = @((int)duration);
//
//    if (((int)duration) > 0) {
//        [FHEnvContext recordEvent:tracerDict andEventKey:@"stay_tab"];
//    }
}

- (void)traceJump2AdEvent:(NSString *)urlString
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:4];
    [dict setValue:@"1" forKey:@"result"];
    [dict setValue:urlString forKey:@"url"];
    [FHEnvContext recordEvent:dict andEventKey:@"link_jump"];
}

- (void)pullAndRefresh
{
    [self.mainTableView triggerPullDown];
}

- (void)scrollToTopEnable:(BOOL)enable
{
    //    self.mainTableView.scrollsToTop = enable;
}

- (void)scrollToTopAnimated:(BOOL)animated
{
    //    self.mainTableView.contentOffset = CGPointMake(0, 0);
}

- (void)didAppear
{
    self.homeListViewModel.stayTime = [[NSDate date] timeIntervalSince1970];
    self.stayTime = [[NSDate date] timeIntervalSince1970];
    
    [[FHHomeCellHelper sharedInstance].fhLastHomeScrollBannerCell.bannerView resetTimer];
}

- (void)willDisappear
{
    [FHLocManager sharedInstance].isShowHomeViewController = NO;
}


- (void)didDisappear
{
    [self.homeListViewModel sendTraceEvent:FHHomeCategoryTraceTypeStay];
    self.homeListViewModel.stayTime = 0;
    [FHEnvContext sharedInstance].isRefreshFromCitySwitch = NO;
    [[FHHomeCellHelper sharedInstance].fhLastHomeScrollBannerCell.bannerView pauseTimer];
}

- (void)setTopEdgesTop:(CGFloat)top andBottom:(CGFloat)bottom
{
    //    self.mainTableView.ttContentInset = UIEdgeInsetsMake(top, 0, bottom, 0);
    //    self.mainTableView.scrollIndicatorInsets = UIEdgeInsetsMake(top, 0, bottom, 0);
}

- (BOOL)tt_hasValidateData
{
    FHConfigDataModel *configModel = [[FHEnvContext sharedInstance] getConfigFromCache];
    return configModel != nil;
}

#pragma mark - TTUIViewControllerTrackProtocol

- (void)trackEndedByAppWillEnterBackground {
    [self tt_resetStayTime];
}

- (void)trackStartedByAppWillEnterForground {
    [self tt_resetStayTime];
    self.ttTrackStartTime = [[NSDate date] timeIntervalSince1970];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


#pragma mark init views
- (UIScrollView *)scrollView {
    if (!_scrollView) {
        _scrollView = [[FHHomeBaseScrollView alloc] init];
        _scrollView.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [[FHHomeCellHelper sharedInstance] heightForFHHomeListHouseSectionHeight]);
        _scrollView.pagingEnabled = YES;
        _scrollView.bounces = NO;
//        _scrollView.decelerationRate = 0.5;
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.scrollsToTop = NO;
        _scrollView.contentSize = CGSizeMake([UIScreen mainScreen].bounds.size.width*4, 0);
        _scrollView.backgroundColor = [UIColor themeHomeColor];
        if (@available(iOS 11.0 , *)) {
            _scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
    }
    return _scrollView;
}

#pragma mark - Tracker相关
- (NSString *)fh_pageType {
    return @"maintab";
}

@end
