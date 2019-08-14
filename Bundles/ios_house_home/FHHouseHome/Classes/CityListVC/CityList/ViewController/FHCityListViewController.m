//
//  FHCityListViewController.m
//  FHHouseHome
//
//  Created by 张元科 on 2018/12/26.
//

#import "FHCityListViewController.h"
#import "FHEnvContext.h"
#import "ToastManager.h"
#import "TTNavigationController.h"
#import "FHCityListNavBarView.h"
#import "TTDeviceHelper.h"
#import "FHCityListLocationBar.h"
#import "FHLocManager.h"
#import "TTReachability.h"
#import "ToastManager.h"
#import "FHCityListViewModel.h"
#import "TTNavigationController.h"
#import "UINavigationController+NavigationBarConfig.h"
#import "FHCitySearchViewController.h"
#import "FHUtils.h"
#import "TTThemedAlertController.h"
#import "TTUIResponderHelper.h"
#import "FHIndexSectionView.h"
#import "FHUserTracker.h"
#import "FHEnvContext.h"
#import "TTSandBoxHelper.h"
#import <FHHouseBase/FHBaseTableView.h>

// 进入当前页面肯定有城市数据
@interface FHCityListViewController ()<FHIndexSectionDelegate>

@property (nonatomic, strong)   FHCityListNavBarView       *naviBar;
@property (nonatomic, strong)   FHCityListLocationBar       *locationBar;

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong)   FHCityListViewModel       *viewModel;

@property (nonatomic, weak)     TTNavigationController       *weakNavVC;
@property (nonatomic, assign)   BOOL       disablePanGesture;

@property (nonatomic, weak)     FHIndexSectionView       *sectionView;
@property (nonatomic, strong)   FHIndexSectionTipView       *sectionTipView;
@property (nonatomic, assign)   BOOL       hasShowenConfigListData;

@end

@implementation FHCityListViewController

- (instancetype)initWithRouteParamObj:(TTRouteParamObj *)paramObj {
    self = [super initWithRouteParamObj:paramObj];
    if (self) {
        self.hasShowenConfigListData = NO;
        self.disablePanGesture = [paramObj.allParams[@"disablePanGes"] boolValue];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
    [self setupData];
    // 禁止左滑-使用
    self.weakNavVC = self.navigationController;
    [UIApplication sharedApplication].statusBarHidden = NO;
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enterForegroundNotification:) name:UIApplicationWillEnterForegroundNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willTerminateNotification:) name:UIApplicationWillTerminateNotification object:nil];
}

- (void)setupUI {
    [self setupNaviBar];
    [self setupLocationBar];
    [self setupTableView];
    self.viewModel = [[FHCityListViewModel alloc] initWithController:self tableView:_tableView];
    [self.view addSubview:_tableView];
    [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(self.view);
        make.top.mas_equalTo(self.locationBar.mas_bottom);
        make.bottom.mas_equalTo(self.view);
    }];
    [self addDefaultEmptyViewWithEdgeInsets:UIEdgeInsetsMake(50, 0, 0, 0)];
    self.sectionTipView = [[FHIndexSectionTipView alloc] init];
    [self.sectionTipView addToSuperView:self.view];
}

- (void)setupData {
    if (self.disablePanGesture) {
        self.naviBar.backBtn.hidden = YES;
        // 重新布局导航栏
        [self.naviBar.searchBtn mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.naviBar).offset(20);
        }];
    }
    FHConfigDataModel *configDataModel  = [[FHEnvContext sharedInstance] getConfigFromCache];
    NSArray *cityList = [configDataModel cityList];
    if (configDataModel && cityList.count > 0) {
        [self.viewModel loadListCityData:configDataModel];
        self.hasShowenConfigListData = YES;
        [self checkShowLocationErrorAlert];
        // 兼容重新覆盖安装App逻辑(v0.5.0版本开始，后续如果线上没有0.4版本，可以删除当前track)
        if ([TTSandBoxHelper isAPPFirstLaunch]) {
            // 第一次覆盖安装而且未选择城市
            [self fetchConfigDataFirstLaunch];
        }
    } else {
        [[ToastManager manager] showCustomLoading:@"加载中"];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(configDataLoadSuccess:) name:kFHAllConfigLoadSuccessNotice object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(configDataLoadError:) name:kFHAllConfigLoadErrorNotice object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(connectionChanged:) name:kReachabilityChangedNotification object:nil];
        // 第一次提前请求config数据
        [self checkConfigDataWithNoConfigData];
    }
}

- (void)connectionChanged:(NSNotification *)notification {
    if ([FHEnvContext isNetworkConnected]) {
        FHConfigDataModel *configDataModel  = [[FHEnvContext sharedInstance] getConfigFromCache];
        BOOL shown = !self.emptyView.hidden;
        if (shown && configDataModel == NULL) {
            // 请求config数据
            [self checkConfigDataWithNoConfigData];
        }
    }
}

- (void)configDataLoadSuccess:(NSNotification *)noti {
    [[ToastManager manager] dismissCustomLoading];
    [self.emptyView hideEmptyView];
    [self.viewModel loadListCityData:[[FHEnvContext sharedInstance] getConfigFromCache]];
    self.hasShowenConfigListData = YES;
    if (noti) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:kFHAllConfigLoadSuccessNotice object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:kFHAllConfigLoadErrorNotice object:nil];
    }
    // 定位当前城市
    if ([TTReachability isNetworkConnected]) {
        if ([self locAuthorization]) {
            BOOL isFirstInstallApp = [TTSandBoxHelper isAPPFirstLaunch];
            [self requestCurrentLocationWithToast:NO needSwitchCity:isFirstInstallApp];
        } else {
            [self checkShowLocationErrorAlert];
        }
    }
}

- (void)configDataLoadError:(NSNotification *)noti {
    [[ToastManager manager] dismissCustomLoading];
    if (noti) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:kFHAllConfigLoadSuccessNotice object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:kFHAllConfigLoadErrorNotice object:nil];
    }
    if (self.hasShowenConfigListData) {
        [self.emptyView hideEmptyView];
    } else {
        [self.emptyView showEmptyWithType:FHEmptyMaskViewTypeNoNetWorkAndRefresh];
        [self.emptyView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(self.tableView);
        }];
    }
}

- (void)checkConfigDataWithNoConfigData {
    FHConfigDataModel *configDataModel  = [[FHEnvContext sharedInstance] getConfigFromCache];
    if (configDataModel == NULL) {
        if ([TTReachability isNetworkConnected]) {
            __weak typeof(self) wSelf = self;
            [[FHLocManager sharedInstance] requestConfigByCityId:0 completion:^(BOOL isSuccess, FHConfigModel * _Nullable model) {
                if (isSuccess) {
                    [wSelf.emptyView hideEmptyView];
                    [wSelf.viewModel loadListCityData:model.data];
                    wSelf.hasShowenConfigListData = YES;
                }
            }];
        }
    }
}

- (void)fetchConfigDataFirstLaunch {
    if ([TTReachability isNetworkConnected]) {
        __weak typeof(self) wSelf = self;
        [[FHLocManager sharedInstance] requestConfigByCityId:0 completion:^(BOOL isSuccess, FHConfigModel * _Nullable model) {
            if (isSuccess) {
                [wSelf.emptyView hideEmptyView];
                [wSelf.viewModel loadListCityData:model.data];
                wSelf.hasShowenConfigListData = YES;
            }
        }];
    }
}

// 重新加载
- (void)retryLoadData {
    // 重新加载只加载列表
    if ([TTReachability isNetworkConnected]) {
        __weak typeof(self) wSelf = self;
        [[ToastManager manager] showCustomLoading:@"加载中"];
        [[FHLocManager sharedInstance] requestConfigByCityId:0 completion:^(BOOL isSuccess, FHConfigModel * _Nullable model) {
            [[ToastManager manager] dismissCustomLoading];
            if (isSuccess) {
                [wSelf.emptyView hideEmptyView];
                [wSelf.viewModel loadListCityData:model.data];
                wSelf.hasShowenConfigListData = YES;
            }
        }];
    } else {
        [[ToastManager manager] showToast:@"网络异常"];
    }
}

// 有config数据，进入城市列表
- (void)checkShowLocationErrorAlert {
    BOOL hasSelectedCity = [(id)[FHUtils contentForKey:kUserHasSelectedCityKey] boolValue];
    if (!hasSelectedCity && ![FHLocManager sharedInstance].isLocationSuccess) {
        // 未选择城市而且定位失败，重新定位
        __weak typeof(self) wSelf = self;
        [[FHLocManager sharedInstance] requestCurrentLocation:YES completion:^(AMapLocationReGeocode * _Nonnull reGeocode) {
            if (reGeocode && reGeocode.city.length > 0) {
                // 定位成功
                wSelf.locationBar.cityName = reGeocode.city;
                wSelf.locationBar.isLocationSuccess = YES;
                [FHLocManager sharedInstance].isLocationSuccess = YES;
            } else {
                // 定位失败弹窗
                [[ToastManager manager] showToast:@"定位失败，请手动选择城市"];
            }
        }];
    }
}

- (void)enterForegroundNotification:(NSNotification *)noti {
    // 进入前台
    [self checkLocAuthorization];
}

- (void)willTerminateNotification:(NSNotification *)noti {
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"kFHDeepLinkFirstLaunchKey"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)setupNaviBar {
    BOOL isIphoneX = [TTDeviceHelper isIPhoneXDevice];
    _naviBar = [[FHCityListNavBarView alloc] init];
    [self.view addSubview:_naviBar];
    CGFloat naviHeight = 49 + (isIphoneX ? 44 : 20);
    [_naviBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.mas_equalTo(self.view);
        make.height.mas_equalTo(naviHeight);
    }];
    [_naviBar.backBtn addTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
    [_naviBar.searchBtn addTarget:self action:@selector(goSearchCity) forControlEvents:UIControlEventTouchUpInside];
}

- (void)setupLocationBar {
    _locationBar = [[FHCityListLocationBar alloc] init];
    [self.view addSubview:_locationBar];
    [_locationBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(self.view);
        make.top.mas_equalTo(self.naviBar.mas_bottom);
        make.height.mas_equalTo(50);
    }];
    [self.locationBar.cityNameBtn addTarget:self action:@selector(cityNameBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.locationBar.reLocationBtn addTarget:self action:@selector(reLocation) forControlEvents:UIControlEventTouchUpInside];
    // 当前有城市数据 && 定位成功
    if ([FHLocManager sharedInstance].currentReGeocode && [FHLocManager sharedInstance].isLocationSuccess) {
        self.locationBar.cityName = [FHLocManager sharedInstance].currentReGeocode.city;
        self.locationBar.isLocationSuccess = YES;
    } else {
        self.locationBar.isLocationSuccess = NO;
    }
}

- (void)setupTableView {
    _tableView = [[FHBaseTableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    if (@available(iOS 11.0 , *)) {
        _tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    _tableView.estimatedRowHeight = 0;
    _tableView.estimatedSectionFooterHeight = 0;
    _tableView.estimatedSectionHeaderHeight = 0;
    if ([TTDeviceHelper isIPhoneXDevice]) {
        _tableView.contentInset = UIEdgeInsetsMake(0, 0, 34, 0);
    }
    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.sectionIndexBackgroundColor = [UIColor clearColor];
    self.tableView.sectionIndexColor = [UIColor themeGray1];
}

- (void)addSectionIndexs:(NSArray *)indexDatas {
    if (self.sectionView) {
        [self.sectionView removeFromSuperview];
    }
    if (indexDatas.count > 0) {
        BOOL isIphoneX = [TTDeviceHelper isIPhoneXDevice];
        CGFloat topOffset = 119 + (isIphoneX ? 44 : 20);
        FHIndexSectionView *isv = [[FHIndexSectionView alloc] initWithTitles:indexDatas topOffset:topOffset];
        if (isv) {
            isv.delegate = self;
            [self.view addSubview:isv];
            self.sectionView = isv;
        }
    }
}

// 是否允许定位
- (BOOL)locAuthorization {
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    if (status == kCLAuthorizationStatusAuthorizedWhenInUse || status == kCLAuthorizationStatusAuthorizedAlways) {
        return YES;
    }
    return NO;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self checkLocAuthorization];
    
    if (self.disablePanGesture) {
        // 禁止滑动手势
        if (self.weakNavVC) {
            self.weakNavVC.panRecognizer.delegate = nil;
            [self.weakNavVC.view removeGestureRecognizer:self.weakNavVC.panRecognizer];
        }
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    if (self.disablePanGesture) {
        // 取消禁止滑动手势
        if (self.weakNavVC) {
            self.weakNavVC.panRecognizer.delegate = self.weakNavVC;
            [self.weakNavVC.view addGestureRecognizer:self.weakNavVC.panRecognizer];
        }
    }
}

- (void)goSearchCity {
    NSMutableDictionary *tracerDict = @{}.mutableCopy;
    tracerDict[@"page_type"] = @"city_list";
    [FHUserTracker writeEvent:@"click_city_search" params:tracerDict];
    
    FHCitySearchViewController *citySearchVC = [[FHCitySearchViewController alloc] init];
    citySearchVC.cityListViewModel = self.viewModel;
    [self.navigationController pushViewController:citySearchVC animated:YES];
}

// 重新定位
- (void)reLocation {
    if ([TTReachability isNetworkConnected]) {
        if ([self locAuthorization]) {
            // custom loading
            [[ToastManager manager] showCustomLoading:@"定位中"];
        }
        [self requestCurrentLocationWithToast:YES needSwitchCity:NO];
    } else {
        // 无网络
        [[ToastManager manager] showToast:@"网络异常"];
    }
}

- (void)cityNameBtnClick {
    if ([TTReachability isNetworkConnected]) {
        // 添加埋点
        if ([FHLocManager sharedInstance].currentReGeocode && [FHLocManager sharedInstance].isLocationSuccess) {
            AMapLocationReGeocode * currentReGeocode = [FHLocManager sharedInstance].currentReGeocode;
            if (currentReGeocode != NULL) {
                [self.viewModel addCityFilterTracer:currentReGeocode.city queryType:@"location"];
            }
        }
        [self.viewModel cityNameBtnClick];
    } else {
         [[ToastManager manager] showToast:@"网络异常"];
    }
}

// 检测
- (void)checkLocAuthorization {
    if ([self locAuthorization]) {
        if ([TTReachability isNetworkConnected] && !self.locationBar.isLocationSuccess) {
            [self requestCurrentLocationWithToast:NO needSwitchCity:NO];
        }
    }
}

// 请求定位信息
- (void)requestCurrentLocationWithToast:(BOOL)hasToast needSwitchCity:(BOOL)isNeedSwitchCity {
    __weak typeof(self) wSelf = self;
    [[FHLocManager sharedInstance] requestCurrentLocation:YES completion:^(AMapLocationReGeocode * _Nonnull reGeocode) {
        [[ToastManager manager] dismissCustomLoading];
        if (reGeocode && reGeocode.city.length > 0) {
            // 定位成功
            wSelf.locationBar.cityName = reGeocode.city;
            wSelf.locationBar.isLocationSuccess = YES;
            [FHLocManager sharedInstance].isLocationSuccess = YES;
            if (hasToast) {
                [[ToastManager manager] showToast:@"定位成功" duration:1.0 isUserInteraction:YES];
            }
            //如果用户首次安装，且没有选过城市，且有城市列表，自动跳到首页
            BOOL hasSelectedCity = [(id)[FHUtils contentForKey:kUserHasSelectedCityKey] boolValue];
            if (!hasSelectedCity && isNeedSwitchCity && wSelf.hasShowenConfigListData) {
                [wSelf.viewModel cityNameBtnClick];
            }
        } else {
            wSelf.locationBar.isLocationSuccess = NO;
            [FHLocManager sharedInstance].isLocationSuccess = NO;
            if (hasToast) {
                [[ToastManager manager] showToast:@"定位失败" duration:1.0 isUserInteraction:YES];
            }
        }
    }];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[FHEnvContext sharedInstance] checkZLink];
}

#pragma mark - FHIndexSectionDelegate

- (void)indexSectionView:(FHIndexSectionView *)view didSelecteedTitle:(NSString *)title atSectoin:(NSInteger)section {
    if (section >= 0) {
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:section] atScrollPosition:UITableViewScrollPositionTop animated:NO];
        [self.sectionTipView showWithText:title];
    }
}

- (void)indexSectionViewTouchesBegin {
    if (self.disablePanGesture) {
        // 已经禁止滑动手势
        return;
    }
    // 禁止滑动手势
    if (self.weakNavVC) {
        self.weakNavVC.panRecognizer.delegate = nil;
        [self.weakNavVC.view removeGestureRecognizer:self.weakNavVC.panRecognizer];
    }
}

- (void)indexSectionViewTouchesEnd {
    [self.sectionTipView dismiss];
    if (self.disablePanGesture) {
        // 已经禁止滑动手势
        return;
    }
    // 取消禁止滑动手势
    if (self.weakNavVC) {
        self.weakNavVC.panRecognizer.delegate = self.weakNavVC;
        [self.weakNavVC.view addGestureRecognizer:self.weakNavVC.panRecognizer];
    }
}

@end
