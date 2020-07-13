//
//  FHChildBrowsingHistoryViewController.m
//  FHHouseMine
//
//  Created by xubinbin on 2020/7/13.
//

#import "FHChildBrowsingHistoryViewController.h"
#import "FHBrowsingHistoryEmptyView.h"
#import "Masonry.h"

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
    
    NSMutableDictionary *dictTrace = [NSMutableDictionary new];
    [dictTrace setValue:@"maintab" forKey:@"enter_from"];
    [dictTrace setValue:@"maintab_icon" forKey:@"element_from"];
    [dictTrace setValue:@"click" forKey:@"enter_type"];
    [dictTrace setValue:@"be_null" forKey:@"origin_from"];
    NSDictionary *userInfoDict = @{@"tracer":dictTrace};
    TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:userInfoDict];
    NSURL *secondHandHouseUrl = [NSURL URLWithString:@"sslocal://second_house_main"];
    NSURL *rentHouseUrl = [NSURL URLWithString:@"sslocal://rent_main"];
    NSURL *newHouseUrl = [NSURL URLWithString:@"sslocal://house_list?house_type=1"];
    NSURL *neighborhoodUrl = [NSURL URLWithString:@"sslocal://main_page"];
    
    switch (houseType) {
        case FHHouseTypeSecondHandHouse:
           [[TTRoute sharedRoute] openURLByPushViewController:secondHandHouseUrl userInfo:userInfo];
            break;
        case FHHouseTypeRentHouse:
            [[TTRoute sharedRoute] openURLByPushViewController:rentHouseUrl userInfo:userInfo];
            break;
        case FHHouseTypeNewHouse:
            [[TTRoute sharedRoute] openURLByPushViewController:newHouseUrl userInfo:userInfo];
            break;
        case FHHouseTypeNeighborhood:
            [[TTRoute sharedRoute] openURLByPushViewController:neighborhoodUrl userInfo:userInfo];
            break;
        default:
            break;
    }
}
@end
