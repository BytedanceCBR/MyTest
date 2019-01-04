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
    _locationBar.cityName = @"北京";
    _locationBar.isLocationSuccess = YES;
}

- (void)setupTableView {
    
}

@end
