//
//  FHChildBrowsingHistoryViewController.m
//  FHHouseMine
//
//  Created by xubinbin on 2020/7/13.
//

#import "FHChildBrowsingHistoryViewController.h"
#import "FHBrowsingHistoryEmptyView.h"
#import "Masonry.h"
#import "FHHomeConfigManager.h"
#import "FHEnvContext.h"

@interface FHChildBrowsingHistoryViewController()<FHBrowsingHistoryEmptyViewDelegate>

@property (nonatomic, strong) FHBrowsingHistoryEmptyView *emptyView;;

@end

@implementation FHChildBrowsingHistoryViewController

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

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

- (void)setHouseType:(FHHouseType)houseType {
    _houseType = houseType;
    self.emptyView.houseType = houseType;
}

- (void)setupUI {
    self.emptyView = [[FHBrowsingHistoryEmptyView alloc] init];
    self.emptyView.delegate = self;
    [self.view addSubview:self.emptyView];
    [self.emptyView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.view);
    }];
}

#pragma mark - FHBrowsingHistoryEmptyViewDelegate
- (void)clickFindHouse:(FHHouseType)houseType {
    NSArray *houseTypeList = [[FHEnvContext sharedInstance] getConfigFromCache].houseTypeList;
    NSNumber *houseTypeNum = [NSNumber numberWithInteger:houseType];
    if (![houseTypeList containsObject:houseTypeNum]) {
        [self popToMainPage];
        return;
    }
    
    NSMutableDictionary *dictTrace = [NSMutableDictionary new];
    [dictTrace setValue:@"maintab" forKey:@"enter_from"];
    [dictTrace setValue:@"maintab_icon" forKey:@"element_from"];
    [dictTrace setValue:@"click" forKey:@"enter_type"];
    [dictTrace setValue:@"be_null" forKey:@"origin_from"];
    NSDictionary *userInfoDict = @{@"tracer":dictTrace};
    TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:userInfoDict];
    
    NSString *urlStr = @"";
    switch (houseType) {
        case FHHouseTypeSecondHandHouse:
            urlStr = @"sslocal://second_house_main";
            break;
        case FHHouseTypeRentHouse:
            urlStr = @"sslocal://rent_main";
            break;
        case FHHouseTypeNewHouse:
            urlStr = @"sslocal://house_list?house_type=1";
            break;
        case FHHouseTypeNeighborhood:
            [self popToMainPage];
            return;
        default:
            break;
    }
    if (![urlStr isEqualToString:@""]) {
        NSURL *url = [NSURL URLWithString:urlStr];
        [[TTRoute sharedRoute] openURLByPushViewController:url userInfo:userInfo];
    }
}

- (void)popToMainPage {
    [self.fatherVC.navigationController popToRootViewControllerAnimated:YES];
    if (![[FHHomeConfigManager sharedInstance].fhHomeBridgeInstance isCurrentTabFirst]) {
        [[FHHomeConfigManager sharedInstance].fhHomeBridgeInstance jumpToTabbarFirst];
    }
}

- (void)dealloc
{
    
}
@end
