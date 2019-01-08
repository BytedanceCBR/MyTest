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

// 进入当前页面肯定有城市数据
@interface FHCityListViewController ()

@property (nonatomic, strong)   FHCityListNavBarView       *naviBar;
@property (nonatomic, strong)   FHCityListLocationBar       *locationBar;

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong)   FHCityListViewModel       *viewModel;

@property (nonatomic, weak)     TTNavigationController       *weakNavVC;
@property (nonatomic, assign)   BOOL       disablePanGesture;

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
    } else {
        // add by zyk "加载中"
        [[ToastManager manager] showCustomLoading:@"加载中"];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(configDataLoadSuccess:) name:kFHAllConfigLoadSuccessNotice object:nil];
    }
}

- (void)configDataLoadSuccess:(NSNotification *)noti {
    [[ToastManager manager] dismissCustomLoading];
    [self.viewModel loadListCityData];
    // 定位当前城市
    if ([TTReachability isNetworkConnected]) {
        if ([self locAuthorization]) {
            [self requestCurrentLocationWithToast:NO];
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
    self.tableView.sectionIndexBackgroundColor = [UIColor clearColor];
    self.tableView.sectionIndexColor = [UIColor themeBlue1];
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
        // 禁止左滑
        self.weakNavVC = self.navigationController;
        if (self.weakNavVC) {
            self.weakNavVC.panRecognizer.delegate = nil;
            [self.weakNavVC.view removeGestureRecognizer:self.weakNavVC.panRecognizer];
        }
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    if (self.disablePanGesture) {
        // 取消禁止左滑
        if (self.weakNavVC) {
            self.weakNavVC.panRecognizer.delegate = self.weakNavVC;
            [self.weakNavVC.view addGestureRecognizer:self.weakNavVC.panRecognizer];
        }
    }
}

- (void)goSearchCity {
    NSDictionary* info = @{
                           @"tracer":@{@"enter_from": @"test",
                                       @"element_from": @"be_null",
                                       @"rank": @"be_null",
                                       @"card_type": @"be_null",
                                       @"origin_from": @"test",
                                       @"origin_search_id": @"be_null"
                                       }};
    TTRouteUserInfo* userInfo = [[TTRouteUserInfo alloc] initWithInfo:info];
    NSURL *url = [[NSURL alloc] initWithString:@"sslocal://city_search"];
    [[TTRoute sharedRoute] openURLByPushViewController:url userInfo:userInfo];
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

@end
