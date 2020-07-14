//
//  FHChildBrowsingHistoryViewModel.m
//  FHHouseMine
//
//  Created by xubinbin on 2020/7/13.
//

#import "FHChildBrowsingHistoryViewModel.h"
#import "FHChildBrowsingHistoryViewController.h"
#import "FHBrowsingHistoryEmptyView.h"
#import "FHHomeConfigManager.h"
#import "FHEnvContext.h"
#import <TTNetworkManager/TTHttpTask.h>
#import "FHBrowseHistoryAPI.h"
#import "FHBrowseHistoryHouseDataModel.h"

@interface FHChildBrowsingHistoryViewModel()<FHBrowsingHistoryEmptyViewDelegate, UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, weak) FHChildBrowsingHistoryViewController *viewController;
@property (nonatomic, weak) FHBrowsingHistoryEmptyView *emptyView;
@property (nonatomic, weak) UITableView *tableView;
@property(nonatomic , weak) TTHttpTask *requestTask;
@property(nonatomic , strong) NSMutableArray *houseList;

@end

@implementation FHChildBrowsingHistoryViewModel

- (instancetype)initWithViewController:(FHChildBrowsingHistoryViewController *)viewController tableView:(UITableView *)tableView emptyView:(FHBrowsingHistoryEmptyView *)emptyView {
    self = [super init];
    if (self) {
        self.houseList = [[NSMutableArray alloc] init];
        self.viewController = viewController;
        self.emptyView = emptyView;
        self.tableView = tableView;
        emptyView.delegate = self;
        tableView.delegate = self;
        tableView.dataSource = self;
    }
    return self;
}

- (void)requestData:(BOOL)isHead {
    [_requestTask cancel];
    NSInteger offset = 0;
    if (!isHead) {
        offset = _houseList.count;
    }
    __weak typeof(self) wself = self;
    self.requestTask = [FHBrowseHistoryAPI requestOldHouseBrowseHistoryWithCount:20 offset:offset class:([FHBrowseHistoryHouseResultModel class]) completion:^(id<FHBaseModelProtocol>  _Nonnull model, NSError * _Nonnull error) {
        if (!error) {
            [wself processData:model];
        }
    }];
}

- (void)processData:(id)data {
    
}

#pragma mark UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return [[UITableViewCell alloc] init];
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
    [self.viewController.fatherVC.navigationController popToRootViewControllerAnimated:YES];
    if (![[FHHomeConfigManager sharedInstance].fhHomeBridgeInstance isCurrentTabFirst]) {
        [[FHHomeConfigManager sharedInstance].fhHomeBridgeInstance jumpToTabbarFirst];
    }
}

@end
