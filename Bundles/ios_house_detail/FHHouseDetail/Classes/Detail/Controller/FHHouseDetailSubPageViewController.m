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

@interface FHHouseDetailSubPageViewController ()

@property (nonatomic, strong) FHDetailNavBar *navBar;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) FHDetailBottomBarView *bottomBar;
@property (nonatomic, strong) FHHouseDetailContactViewModel *contactViewModel;
@property (nonatomic, assign) FHHouseType houseType; // 房源类型
@property (nonatomic, copy) NSString *houseId; // 房源id
@property (nonatomic, strong) NSDictionary *tracerDict;
@property (nonatomic, copy)   NSString* searchId;
@property (nonatomic, copy)   NSString* imprId;
@property (nonatomic, strong) FHDetailContactModel *contactPhone;
@property (nonatomic, assign) NSInteger followStatus;

@end

@implementation FHHouseDetailSubPageViewController

- (instancetype)initWithRouteParamObj:(TTRouteParamObj *)paramObj {
    self = [super initWithRouteParamObj:paramObj];
    if (self) {
        
        self.houseType = [paramObj.allParams[@"house_type"] integerValue];
        
        if (!self.houseType) {
            if ([paramObj.sourceURL.absoluteString containsString:@"neighborhood_detail"]) {
                self.houseType = FHHouseTypeNeighborhood;
            }
            
            if ([paramObj.sourceURL.absoluteString containsString:@"old_house_detail"]) {
                self.houseType = FHHouseTypeSecondHandHouse;
            }
            
            if ([paramObj.sourceURL.absoluteString containsString:@"new_house_detail"]) {
                self.houseType = FHHouseTypeNewHouse;
            }
            
            if ([paramObj.sourceURL.absoluteString containsString:@"rent_detail"]) {
                self.houseType = FHHouseTypeRentHouse;
            }
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
                    self.houseId = paramObj.allParams[@"house_id"];
                }
                break;
        }
        
        if ([paramObj.sourceURL.absoluteString containsString:@"neighborhood_detail"]) {
            self.houseId = paramObj.allParams[@"neighborhood_id"];
        }
        
        NSDictionary *tracer = paramObj.allParams[@"tracer"];
        if ([tracer[@"log_pb"] isKindOfClass:[NSDictionary class]]) {
            NSDictionary *logPbDict = tracer[@"log_pb"];
            self.searchId = logPbDict[@"search_id"];
            self.imprId = logPbDict[@"impr_id"];
        }
        _contactPhone = paramObj.userInfo.allInfo[@"contact_phone"];
        NSDictionary *allInfo = paramObj.userInfo.allInfo;
        _followStatus = [allInfo[@"follow_status"] integerValue];
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
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
    _bottomBar.hidden = YES;
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
    self.contactViewModel.searchId = self.searchId;
    self.contactViewModel.imprId = self.imprId;
    self.contactViewModel.tracerDict = self.tracerDict;
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
    NSMutableDictionary *tracerDict = @{}.mutableCopy;
    [tracerDict addEntriesFromDictionary:self.tracerDict];
    return info;
}

@end
