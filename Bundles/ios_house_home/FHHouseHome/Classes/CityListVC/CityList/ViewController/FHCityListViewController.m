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

// 进入当前页面肯定有城市数据
@interface FHCityListViewController ()<FHIndexSectionDelegate>

@property (nonatomic, strong)   FHCityListNavBarView       *naviBar;
@property (nonatomic, strong)   FHCityListLocationBar       *locationBar;

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong)   FHCityListViewModel       *viewModel;

@property (nonatomic, weak)     TTNavigationController       *weakNavVC;
@property (nonatomic, assign)   BOOL       disablePanGesture;

@property (nonatomic, weak)     FHIndexSectionView       *sectionView;

@end

@implementation FHCityListViewController

- (instancetype)initWithRouteParamObj:(TTRouteParamObj *)paramObj {
    self = [super initWithRouteParamObj:paramObj];
    if (self) {
        self.disablePanGesture = [paramObj.userInfo.allInfo[@"disablePanGes"] boolValue];
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
    if (configDataModel) {
        [self.viewModel loadListCityData];
        [self checkShowLocationErrorAlert];
    } else {
        [[ToastManager manager] showCustomLoading:@"加载中"];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(configDataLoadSuccess:) name:kFHAllConfigLoadSuccessNotice object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(configDataLoadError:) name:kFHAllConfigLoadErrorNotice object:nil];
    }
}

- (void)configDataLoadSuccess:(NSNotification *)noti {
    [[ToastManager manager] dismissCustomLoading];
    [self.emptyView hideEmptyView];
    [self.viewModel loadListCityData];
    // 定位当前城市
    if ([TTReachability isNetworkConnected]) {
        if ([self locAuthorization]) {
            [self requestCurrentLocationWithToast:NO];
        } else {
            [self checkShowLocationErrorAlert];
        }
    }
}

- (void)configDataLoadError:(NSNotification *)noti {
    [[ToastManager manager] dismissCustomLoading];
    [self.emptyView showEmptyWithType:FHEmptyMaskViewTypeNoNetWorkAndRefresh];
    [self.emptyView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.tableView);
    }];
}

// 重新加载
- (void)retryLoadData {
    [[ToastManager manager] showCustomLoading:@"加载中"];
    [[FHLocManager sharedInstance] requestCurrentLocation:NO andShowSwitch:NO];
}

- (void)checkShowLocationErrorAlert {
    BOOL hasSelectedCity = [(id)[FHUtils contentForKey:kUserHasSelectedCityKey] boolValue];
    if (!hasSelectedCity) {
        // 定位失败弹窗
        TTThemedAlertController *alertVC = [[TTThemedAlertController alloc] initWithTitle:@"定位失败，请手动选择城市" message:nil preferredType:TTThemedAlertControllerTypeAlert];
        [alertVC addActionWithTitle:@"确定" actionType:TTThemedAlertActionTypeNormal actionBlock:^{
            
        }];
        
        UIViewController *topVC = [TTUIResponderHelper topmostViewController];
        if (topVC) {
            [alertVC showFrom:topVC animated:YES];
        }
    }
}

- (void)enterForegroundNotification:(NSNotification *)noti {
    // 进入前台
    [self checkLocAuthorization];
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
    _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    if (@available(iOS 11.0 , *)) {
        _tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        _tableView.estimatedRowHeight = 0;
        _tableView.estimatedSectionFooterHeight = 0;
        _tableView.estimatedSectionHeaderHeight = 0;
    }
    if ([TTDeviceHelper isIPhoneXDevice]) {
        _tableView.contentInset = UIEdgeInsetsMake(0, 0, 34, 0);
    }
    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.sectionIndexBackgroundColor = [UIColor clearColor];
    self.tableView.sectionIndexColor = [UIColor themeBlue1];
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
        [self requestCurrentLocationWithToast:YES];
    } else {
        // 无网络
        [[ToastManager manager] showToast:@"网络异常"];
    }
}

- (void)cityNameBtnClick {
    if ([TTReachability isNetworkConnected]) {
        [self.viewModel cityNameBtnClick];
    } else {
         [[ToastManager manager] showToast:@"网络异常"];
    }
}

// 检测
- (void)checkLocAuthorization {
    if ([self locAuthorization]) {
        if ([TTReachability isNetworkConnected] && !self.locationBar.isLocationSuccess) {
            [self requestCurrentLocationWithToast:NO];
        }
    }
}

// 请求定位信息
- (void)requestCurrentLocationWithToast:(BOOL)hasToast {
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
}

#pragma mark - FHIndexSectionDelegate

- (void)indexSectionView:(FHIndexSectionView *)view didSelecteedTitle:(NSString *)title atSectoin:(NSInteger)section {
    if (section >= 0) {
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:section] atScrollPosition:UITableViewScrollPositionTop animated:NO];
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
