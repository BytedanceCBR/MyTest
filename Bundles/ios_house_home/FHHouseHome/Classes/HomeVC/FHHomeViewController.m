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
#import <HMDTTMonitor.h>
#import "TTSandBoxHelper.h"
#import "TTArticleCategoryManager.h"
#import "FHHomeScrollBannerCell.h"
#import <TTDeviceHelper.h>
#import <TTAppUpdateHelper.h>
#import <TTInstallIDManager.h>
#import <CommonURLSetting.h>
#import <FHCommuteManager.h>
#import <TTUIResponderHelper.h>
#import "TTTabBarController.h"
#import <TTTopBar.h>
#import <FHHomeSearchPanelViewModel.h>
#import <ExploreLogicSetting.h>
#import <FHHouseBase/TTSandBoxHelper+House.h>
#import <TTArticleTabBarController.h>
#import <TTUIWidget/UIViewController+NavigationBarStyle.h>
#import <TTThemedAlertController.h>
#import <FHUtils.h>
#import <FHMinisdkManager.h>

static CGFloat const kShowTipViewHeight = 32;

static CGFloat const kSectionHeaderHeight = 38;

static NSString * const kFUGCPrefixStr = @"fugc";

@interface FHHomeViewController ()<TTAppUpdateHelperProtocol>

@property (nonatomic, strong) FHHomeListViewModel *homeListViewModel;
@property (nonatomic, assign) BOOL isClickTab;
@property (nonatomic, assign) BOOL isRefreshing;
@property (nonatomic, assign) BOOL isShowToasting;
@property (nonatomic, strong) ArticleListNotifyBarView * notifyBar;
@property (nonatomic) BOOL adColdHadJump;
@property (nonatomic) BOOL adUGCHadJump;
@property (nonatomic, strong) TTTopBar *topBar;
@property (nonatomic, weak) FHHomeSearchPanelViewModel *panelVM;
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
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.ttNeedIgnoreZoomAnimation = YES;
    [self.view addSubview:self.topBar];
    
    FHHomeSearchPanelViewModel *panelVM = [[FHHomeSearchPanelViewModel alloc] initWithSearchPanel:self.topBar.pageSearchPanel];
    //    NIHSearchPanelViewModel *panelVM = [[NIHSearchPanelViewModel alloc] initWithSearchPanel:self.topBar.pageSearchPanel viewController:self];
    panelVM.viewController = self;
    self.panelVM = panelVM;
    
    self.isRefreshing = NO;
    self.adColdHadJump = NO;
    self.adUGCHadJump = NO;
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    [self registerNotifications];
    
    [self resetMaintableView];
    self.homeListViewModel = [[FHHomeListViewModel alloc] initWithViewController:self.mainTableView andViewController:self andPanelVM:self.panelVM];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_willEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
    
}

- (void)scrollMainTableToTop
{
    if (self.isShowing) {
        [self.homeListViewModel setUpTableScrollOffsetZero];
    }
}

-(void)dealyIniViews
{
    
    //如果是inhouse的，弹升级弹窗
    if ([TTSandBoxHelper isInHouseApp] && _isMainTabVC) {
        //#if INHOUSE
        [self checkLocalTestUpgradeVersionAlert];
        //#endif
    }
    
    [self addDefaultEmptyViewFullScreen];
    
    if (!_isMainTabVC) {
        [self.topBar removeFromSuperview];
        [self.mainTableView removeFromSuperview];
        [self.emptyView showEmptyWithTip:@"功能暂未开通" errorImage:[UIImage imageNamed:@"group-9"] showRetry:NO];
    }
    
    [self.view bringSubviewToFront:self.topBar];
    
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
    
    self.mainTableView = [[FHHomeBaseTableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.mainTableView.decelerationRate = 0.5;
    self.mainTableView.showsVerticalScrollIndicator = NO;
    
//    if (_isMainTabVC) {
//        self.homeListViewModel = [[FHHomeListViewModel alloc] initWithViewController:self.mainTableView andViewController:self andPanelVM:self.panelVM];
//    }
    
    [self.view addSubview:self.mainTableView];
    
    self.mainTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [self setUpMainTableConstraints];
    
    [FHHomeCellHelper registerCells:self.mainTableView];
    
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.mainTableView.backgroundColor = [UIColor whiteColor];
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
    
    
    [self.view bringSubviewToFront:self.topBar];
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
    self.homeListViewModel.reloadType = TTReloadTypeTab;
    [self pullAndRefresh];
}

- (void)setUpMainTableConstraints
{
    if ([TTDeviceHelper isIPhoneXDevice]) {
        [self.mainTableView setFrame:CGRectMake(0.0f, 64 + 44, MAIN_SCREEN_WIDTH, MAIN_SCREENH_HEIGHT - 64 - 44 - 49)];
    }else
    {
        [self.mainTableView setFrame:CGRectMake(0.0f, 64 + 20, MAIN_SCREEN_WIDTH, MAIN_SCREENH_HEIGHT - 64 - 20 - 49)];
    }
}

- (void)setupTopBarConstraints
{
    [self.topBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo([TTDeviceHelper isIPhoneXSeries] ? 44 : 20);
        make.left.right.equalTo(self.view);
        make.height.mas_equalTo(64);
    }];
}

- (TTTopBar *)topBar {
    if (!_topBar) {
        _topBar = [[TTTopBar alloc] init];
        _topBar.isShowTopSearchPanel = YES;
        _topBar.tab = @"home";
        [self.view addSubview:_topBar];
        [self setupTopBarConstraints];
        _topBar.delegate = self;
        [_topBar setupSubviews];
    }
    return _topBar;
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
    [self.notifyBar hideImmediately];
    self.isShowRefreshTip = NO;
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
        [[TTArticleCategoryManager sharedManager] startGetCategoryWithCompleticon:^(BOOL isSuccessed){
            
        }];
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
    
    if (![[FHEnvContext sharedInstance] getConfigFromCache].cityAvailability.enable.boolValue) {
        [self.homeListViewModel checkCityStatus];
    }
    
    [self scrollToTopEnable:YES];
    
    self.homeListViewModel.enterType = [TTCategoryStayTrackManager shareManager].enterType != nil ? [TTCategoryStayTrackManager shareManager].enterType : @"default";
    
    if (self.mainTableView.contentOffset.y > [[FHHomeCellHelper sharedInstance] heightForFHHomeHeaderCellViewType]) {
        [[FHHomeConfigManager sharedInstance].fhHomeBridgeInstance isShowTabbarScrollToTop:YES];
    }
    
    self.stayTime = [[NSDate date] timeIntervalSince1970];
    
    [self checkPasteboard:NO];
    
    //春节活动
    if([FHEnvContext isSpringOpen]){
        if([FHMinisdkManager sharedInstance].isSpring && [FHMinisdkManager sharedInstance].url){
             [[TTRoute sharedRoute] openURL:[FHMinisdkManager sharedInstance].url userInfo:nil objHandler:nil];
        }
    }
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
    
    [self addStayCategoryLog:self.ttTrackStayTime];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
//    if(_isMainTabVC && !self.homeListViewModel){
//        self.homeListViewModel = [[FHHomeListViewModel alloc] initWithViewController:self.mainTableView andViewController:self andPanelVM:self.panelVM];
//    }
    
    
    //开屏广告启动不会展示，保留逻辑代码
    if (!self.adColdHadJump && [TTSandBoxHelper isAPPFirstLaunchForAd]) {
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
    
    [FHEnvContext addTabUGCGuid];
    
    [TTSandBoxHelper setAppFirstLaunchForAd];
    
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
}

- (void)_willEnterForeground:(NSNotification *)notification
{
    if (self.isShowing) {
        [self checkPasteboard:NO];
    }
}


-(void)addStayCategoryLog:(NSTimeInterval)stayTime {
    NSMutableDictionary *tracerDict = [NSMutableDictionary new];
    NSTimeInterval duration = ([[NSDate date] timeIntervalSince1970] -  self.stayTime) * 1000.0;
    //        if (duration) {
    //            [tracerDict setValue:@((int)duration) forKey:@"stay_time"];
    //        }
    [tracerDict setValue:@"main" forKey:@"tab_name"];
    [tracerDict setValue:@(0) forKey:@"with_tips"];
    [tracerDict setValue:[FHEnvContext sharedInstance].isClickTab ? @"click_tab" : @"default" forKey:@"enter_type"];
    tracerDict[@"stay_time"] = @((int)duration);
    
    if (((int)duration) > 0) {
        [FHEnvContext recordEvent:tracerDict andEventKey:@"stay_tab"];
    }
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
        _scrollView = [[UIScrollView alloc] init];
        _scrollView.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [[FHHomeCellHelper sharedInstance] heightForFHHomeListHouseSectionHeight]);
        _scrollView.pagingEnabled = YES;
        _scrollView.bounces = NO;
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.scrollsToTop = NO;
        _scrollView.contentSize = CGSizeMake([UIScreen mainScreen].bounds.size.width*4, 0);
        _scrollView.backgroundColor = [UIColor whiteColor];
        if (@available(iOS 11.0 , *)) {
            _scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
    }
    return _scrollView;
}

#pragma mark 内测弹窗
- (void)checkLocalTestUpgradeVersionAlert
{
    //内测弹窗
    NSString * iidValue = [[TTInstallIDManager sharedInstance] installID];
    NSString * didValue = [[TTInstallIDManager sharedInstance] deviceID];
    NSString * channelValue = [[NSBundle mainBundle] infoDictionary][@"CHANNEL_NAME"];
    NSString * aidValue = @"1370";
    NSString * baseUrl = [CommonURLSetting baseURL];
    //    NSString * baseUrl = @"https://i.snssdk.com";
    
    [TTAppUpdateHelper sharedInstance].delegate = self;
    [[TTAppUpdateHelper sharedInstance] checkVersionUpdateWithInstallID:iidValue deviceID:didValue channel:channelValue aid:aidValue checkVersionBaseUrl:baseUrl correctVC:self completionBlock:^(__kindof UIView *view, NSError * _Nullable error) {
        [self.view addSubview:view];
    } updateBlock:^(BOOL isTestFlightUpdate, NSString *downloadUrl) {
        //        if (!downloadUrl) {
        //            return;
        //        }
        //        NSURL *url = [NSURL URLWithString:downloadUrl];
        //        [[UIApplication sharedApplication] openURL:url];
    } closeBlock:^{
        
    }];
}

/** 通知代理对象已获取到弹窗升级Title和具体升级内容,如果自定义弹窗，必须实现此方法
 @params title 弹窗升级title,ex: 6.x.x内测更新了..
 @param content 更新具体内容
 @params tipVersion 弹窗升级版本号,ex: 6.7.8
 @param downloadUrl TF弹窗下载地址
 */
//- (void)showUpdateTipTitle:(NSString *)title content:(NSString *)content tipVersion:(NSString *)tipVersion updateButtonText:(NSString *)text downloadUrl:(NSString *)downloadUrl error:(NSError * _Nullable)error
//{
//
//}

/** 通知代理对象弹窗需要remove
 *  代理对象需要在此方法里面将弹窗remove掉
 */
- (void)dismissTipView
{
    
}

///*
// 判断是否是内测包，当打包注入与头条主工程不一致时
// 可以实现自行进行判断，默认与头条判断方式相同
// 通过检查bundleID是否有inHouse字段进行判断
// */
- (BOOL)decideIsInhouseApp
{
    return YES;
}
//
///*
// 判断是否是LR包，当打包注入与头条主工程不一致时
// 可以实现自行进行判断，默认与头条判断方式相同
// 通过检查buildinfo字段进行判断
// 注意：只有lr包才弹内测弹窗，如果业务方没有
// lr包的概念，则返回YES即可
// */
- (BOOL)decideIsLrPackage
{
    return YES;
}
//
///*
// 判断是否需要上报用户did，主要用来上报用户是否安装tTestFlight
// 的情况，业务方可以自行通过开关控制
// */
//- (BOOL)decideShouldReportDid
//{
//
//}

#pragma mark UGC线上线下推广

- (void)checkPasteboard:(BOOL)isAutoJump
{
    __weak typeof(self) weakSelf = self;
    //据说主线程读剪切板会导致app卡死。。。改为子线程读
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
        NSArray<NSString *> *pasteboardStrs = [pasteboard strings];

        if (([pasteboardStrs isKindOfClass:[NSArray class]] && pasteboardStrs.count > 0)) {
            dispatch_async(dispatch_get_main_queue(), ^{
                __block NSString *pasteboardStr = nil;
                [pasteboardStrs enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    if ([obj hasPrefix:kFUGCPrefixStr]) {
                        pasteboardStr = obj;
                        *stop = YES;
                    }
                }];
                
                if (pasteboardStr) {
                    NSString *base64Str = [pasteboardStr stringByReplacingOccurrencesOfString:kFUGCPrefixStr withString:@""];
                    
                    if (base64Str) {
                        [weakSelf requestSendUGCUserAD:base64Str];
                    }
                    //清空剪切板
                    NSMutableArray * strs = pasteboardStrs.mutableCopy;
                    [strs removeObject:pasteboardStr];
                    pasteboard.strings = strs;
                }
            });
        }
    });
}

- (void)requestSendUGCUserAD:(NSString *)requestStr
{
    NSMutableDictionary *params = [NSMutableDictionary new];
    [params setValue:requestStr forKey:@"promotion_code"];
    __weak typeof(self) weakSelf = self;

    [FHMainApi uploadUGCPostPromotionparams:params completion:^(NSDictionary * _Nullable result, NSError * _Nullable error) {
        
        if (!error && [result isKindOfClass:[NSDictionary class]]) {
            NSNumber *cityId = nil;
            NSString *alertStr = nil;
            NSNumber *inviteStatus = nil;
            NSDictionary *dataDict = result[@"data"];
            if ([dataDict isKindOfClass:[NSDictionary class]] && [dataDict[@"city_id"] isKindOfClass:[NSNumber class]]) {
                cityId = dataDict[@"city_id"];
            }
            
            if ([dataDict isKindOfClass:[NSDictionary class]] && [dataDict[@"tips"] isKindOfClass:[NSString class]]) {
                alertStr = dataDict[@"tips"];
            }
            
            if ([dataDict isKindOfClass:[NSDictionary class]] && [dataDict[@"invite_status"] isKindOfClass:[NSNumber class]]) {
                inviteStatus = dataDict[@"invite_status"];
            }
            
            if (alertStr && [inviteStatus isKindOfClass:[NSNumber class]] && [inviteStatus integerValue] != 2) {
                TTThemedAlertController *alertVC = [[TTThemedAlertController alloc] initWithTitle:alertStr message:nil preferredType:TTThemedAlertControllerTypeAlert];
                
                [alertVC addActionWithTitle:@"确定" actionType:TTThemedAlertActionTypeCancel actionBlock:^{
                    
                }];
                
                UIViewController *topVC = [TTUIResponderHelper topmostViewController];
                if (topVC) {
                    [alertVC showFrom:topVC animated:YES];
                }
                
                [FHUtils setContent:@"1" forKey:kFHUGCPromotionUser];
            }
            
            if ([inviteStatus integerValue] != 2 && cityId) {
                [[FHEnvContext sharedInstance] switchCityConfigForUGCADUser:cityId];
            }
            //只保存数据
            [[FHEnvContext sharedInstance] checkUGCADUserIsLaunch:NO];
        }
    }];
}

@end
