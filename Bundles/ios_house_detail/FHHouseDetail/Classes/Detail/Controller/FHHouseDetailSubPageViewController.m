//
//  FHHouseDetailSubPageViewController.m
//  Pods
//
//  Created by 张静 on 2019/2/22.
//

#import "FHHouseDetailSubPageViewController.h"
#import "FHHouseDetailContactViewModel.h"
#import "FHDetailBottomBarView.h"
#import "FHDetailNavBar.h"
#import "TTDeviceHelper.h"
#import <TTUIWidget/UIViewController+Track.h>
#import <FHEnvContext.h>

@interface FHHouseDetailSubPageViewController ()

@property (nonatomic, strong) FHDetailNavBar *navBar;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) FHDetailBottomBarView *bottomBar;
@property (nonatomic, strong) FHHouseDetailContactViewModel *contactViewModel;
@property (nonatomic, assign) FHHouseType houseType; // 房源类型
@property (nonatomic, copy) NSString *houseId; // 房源id
//@property (nonatomic, strong) NSDictionary *tracerDict;
@property (nonatomic, copy)   NSString* searchId;
@property (nonatomic, copy)   NSString* imprId;
@property (nonatomic, strong) FHDetailContactModel *contactPhone;
@property (nonatomic, assign) NSInteger followStatus;
@property (nonatomic, copy) NSString *customHouseId; //
@property (nonatomic, copy) NSString *fromStr; //

@end

@implementation FHHouseDetailSubPageViewController

- (instancetype)initWithRouteParamObj:(TTRouteParamObj *)paramObj {
    self = [super initWithRouteParamObj:paramObj];
    if (self) {
        
        self.houseType = FHHouseTypeNewHouse;
        if (paramObj.allParams[@"house_type"]) {
            self.houseType = [paramObj.allParams[@"house_type"] integerValue];
        }
        self.ttTrackStayEnable = YES;
        switch (_houseType) {
            case FHHouseTypeNewHouse:
                self.houseId = paramObj.allParams[@"court_id"];
                break;
            case FHHouseTypeSecondHandHouse:
                self.houseId = paramObj.allParams[@"house_id"];
                break;
            case FHHouseTypeRentHouse:
                self.houseId = paramObj.allParams[@"house_id"];
                break;
            case FHHouseTypeNeighborhood:
                self.houseId = paramObj.allParams[@"neighborhood_id"];
                break;
            default:
                if (!self.houseId) {
                    self.houseId = paramObj.allParams[@"court_id"];
                }
                break;
        }
        if ([paramObj.sourceURL.absoluteString containsString:@"floor_plan_detail"]) {
            self.customHouseId = paramObj.allParams[@"floor_plan_id"];
            self.fromStr = @"app_floorplan";
        }
        
        if ([paramObj.sourceURL.absoluteString containsString:@"neighborhood_detail"]) {
            self.houseId = paramObj.allParams[@"neighborhood_id"];
        }
        NSDictionary *allInfo = paramObj.userInfo.allInfo;
        if ([paramObj.allParams[@"subscribe_status"] isKindOfClass:[NSString class]]) {
            NSString *statusStr = paramObj.allParams[@"subscribe_status"];
            if (statusStr.length > 0) {
                if ([statusStr isEqualToString:@"true"]) {
                    _followStatus = 1;
                }else {
                    _followStatus = 0;
                }
            }
        }else {
            _followStatus = [allInfo[@"follow_status"] integerValue];
        }
        if (allInfo[@"contact_phone"]) {
            _contactPhone = allInfo[@"contact_phone"];
        }else {
            _contactPhone = [[FHDetailContactModel alloc]init];
            _contactPhone.phone = paramObj.allParams[@"telephone"];
        }
        if ([paramObj.queryParams[@"log_pb"] isKindOfClass:[NSString class]]) {
            
            NSData *jsonData = [paramObj.queryParams[@"log_pb"] dataUsingEncoding:NSUTF8StringEncoding];
            NSDictionary *logPbDict = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingAllowFragments error:nil];
            self.searchId = logPbDict[@"search_id"];
            self.imprId = logPbDict[@"impr_id"];
        }else if ([allInfo[@"log_pb"] isKindOfClass:[NSDictionary class]]) {
            
            NSDictionary *logPbDict = allInfo[@"log_pb"];
            self.searchId = logPbDict[@"search_id"];
            self.imprId = logPbDict[@"impr_id"];
        }
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (![FHEnvContext isNetworkConnected]) {
        [self.contactViewModel hideFollowBtn];
    }
}

- (void)setupUI
{
    __weak typeof(self)wself = self;
    CGRect screenBounds = [UIScreen mainScreen].bounds;
    CGFloat navBarHeight = [TTDeviceHelper isIPhoneXDevice] ? 44 : 20;
    _navBar = [[FHDetailNavBar alloc]initWithType:FHDetailNavBarTypeTitle];
    _navBar.backActionBlock = ^{
        [wself.navigationController popViewControllerAnimated:YES];
    };
    [self.view addSubview:_navBar];
    
    _bottomBar = [[FHDetailBottomBarView alloc]initWithFrame:CGRectZero];
    [self.view addSubview:_bottomBar];
    [_bottomBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(self.view);
        make.height.mas_equalTo(64);
        if (@available(iOS 11.0, *)) {
            make.bottom.mas_equalTo(self.view.mas_bottom).mas_offset(-[UIApplication sharedApplication].keyWindow.safeAreaInsets.bottom);
        }else {
            make.bottom.mas_equalTo(self.view);
        }
    }];
    self.contactViewModel = [[FHHouseDetailContactViewModel alloc] initWithNavBar:_navBar bottomBar:_bottomBar houseType:_houseType houseId:_houseId];
    self.contactViewModel.customHouseId = self.customHouseId;
    self.contactViewModel.fromStr = self.fromStr;
    self.contactViewModel.searchId = self.searchId;
    self.contactViewModel.imprId = self.imprId;
    NSMutableDictionary *tracer = @{}.mutableCopy;
    if (self.tracerDict) {
        [tracer addEntriesFromDictionary:self.tracerDict];
        tracer[@"page_type"] = [self pageTypeString];
    }
    self.contactViewModel.tracerDict = tracer;
    self.contactViewModel.belongsVC = self;
    self.contactViewModel.contactPhone = self.contactPhone;
    self.contactViewModel.followStatus = self.followStatus;
    
    [self.navBar refreshAlpha:1];
    [[UIApplication sharedApplication]setStatusBarStyle:UIStatusBarStyleDefault];    
}

- (void)setNavBarTitle:(NSString *)navTitle
{
    UILabel *titleLabel = [UILabel new];
    titleLabel.text = navTitle;
    titleLabel.textColor = [UIColor themeBlue1];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    
    [self.navBar addSubview:titleLabel];
    
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.bottom.equalTo(self.navBar);
        make.width.mas_equalTo(100);
        make.height.mas_equalTo(44);
    }];
}

- (UIView *)getNaviBar
{
    return self.navBar;
}

- (UIView *)getBottomBar
{
    return self.bottomBar;
}
//
//- (FHHouseDetailContactViewModel *)getContactViewModel
//{
//    return self.contactViewModel;
//}

- (NSDictionary *)subPageParams
{
    NSMutableDictionary *info = @{}.mutableCopy;
    if (self.contactViewModel) {
        info[@"follow_status"] = @(self.contactViewModel.followStatus);
    }
    if (self.contactViewModel.contactPhone) {
        info[@"contact_phone"] = self.contactViewModel.contactPhone;
    }
    switch (_houseType) {
        case FHHouseTypeNewHouse:
            info[@"court_id"] = self.houseId;
            break;
        case FHHouseTypeSecondHandHouse:
            info[@"house_id"] = self.houseId;
            break;
        case FHHouseTypeRentHouse:
            info[@"house_id"] = self.houseId;
            break;
        case FHHouseTypeNeighborhood:
            info[@"neighborhood_id"] = self.houseId;
            break;
        default:
            info[@"house_id"] = self.houseId;
            break;
    }
    info[@"contact_phone"] = self.contactViewModel.contactPhone;
    info[@"page_type"] = [self pageTypeString];
    if (self.tracerDict) {
        
        NSMutableDictionary *tracerDict = @{}.mutableCopy;
        [tracerDict addEntriesFromDictionary:self.tracerDict];
        info[@"tracer"] = tracerDict;
    }
    return info;
}

- (NSString *)pageTypeString
{
    return self.tracerDict[@"page_type"];
}

@end
