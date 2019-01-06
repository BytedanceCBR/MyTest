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

// 进入当前页面肯定有城市数据
@interface FHCityListViewController ()

@property (nonatomic, strong)   FHCityListNavBarView       *naviBar;
@property (nonatomic, strong)   FHCityListLocationBar       *locationBar;

@end

@implementation FHCityListViewController

- (instancetype)initWithRouteParamObj:(TTRouteParamObj *)paramObj {
    self = [super initWithRouteParamObj:paramObj];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
}

- (void)setupUI {
    [self setupNaviBar];
    [self setupLocationBar];
    [self setupTableView];
}

- (void)setupNaviBar {
    BOOL isIphoneX = [TTDeviceHelper isIPhoneXDevice];
    _naviBar = [[FHCityListNavBarView alloc] init];
    [self.view addSubview:_naviBar];
    CGFloat naviHeight = 44 + (isIphoneX ? 44 : 20);
    [_naviBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.mas_equalTo(self.view);
        make.height.mas_equalTo(naviHeight);
    }];
    [_naviBar.backBtn addTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
}

- (void)setupLocationBar {
    _locationBar = [[FHCityListLocationBar alloc] init];
    [self.view addSubview:_locationBar];
    [_locationBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(self.view);
        make.top.mas_equalTo(self.naviBar.mas_bottom);
        make.height.mas_equalTo(50);
    }];
    [self.locationBar.reLocationBtn addTarget:self action:@selector(reLocation) forControlEvents:UIControlEventTouchUpInside];
    // 当前有城市数据
    if ([FHLocManager sharedInstance].currentReGeocode) {
        self.locationBar.cityName = [FHLocManager sharedInstance].currentReGeocode.city;
        self.locationBar.isLocationSuccess = YES;
    } else {
        self.locationBar.isLocationSuccess = NO;
    }
}

- (void)setupTableView {
    
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
}

// 重新定位
- (void)reLocation {
    if ([TTReachability isNetworkConnected]) {
        // EnvContext.shared.toast.showCustomLoadingToast("定位中")
        [self requestCurrentLocation];
    } else {
        // 无网络
        // EnvContext.shared.toast.showToast("网络异常")
    }
}

// 检测
- (void)checkLocAuthorization {
    if ([self locAuthorization]) {
        if ([TTReachability isNetworkConnected] && !self.locationBar.isLocationSuccess) {
            [self requestCurrentLocation];
        }
    }
}

// 请求定位信息
- (void)requestCurrentLocation {
    __weak typeof(self) wSelf = self;
    [[FHLocManager sharedInstance] requestCurrentLocation:YES completion:^(AMapLocationReGeocode * _Nonnull reGeocode) {
        if (reGeocode && reGeocode.city.length > 0) {
            // 定位成功
            wSelf.locationBar.cityName = reGeocode.city;
            wSelf.locationBar.isLocationSuccess = YES;
        } else {
            wSelf.locationBar.isLocationSuccess = NO;
        }
    }];
}

@end
