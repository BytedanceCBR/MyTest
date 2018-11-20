//
//  HouseRentDetailPageVC.m
//  NewsLite
//
//  Created by leo on 2018/11/19.
//

#import "HouseRentDetailPageVC.h"
#import "TTRoute.h"
#import <Masonry/Masonry.h>
#import "FHBTableViewDataSource.h"
#import "FHDetailPageCellCoordinator.h"
#import "Bubble-Swift.h"
#import "TTNavigationController.h"
@interface HouseRentDetailPageVC ()<TTRouteInitializeProtocol>
{
    UITableView* _tableView;
    FHBTableViewDataSource* _detailPageDataSource;
    FHDetailPageCellCoordinator* _coordinator;
}
@end

@implementation HouseRentDetailPageVC

- (instancetype)init
{
    self = [super init];
    if (self) {
        _coordinator = [[FHDetailPageCellCoordinator alloc] init];
        _detailPageDataSource = [[FHBTableViewDataSource alloc] initWithCoordinator:_coordinator
                                                                     withRespoitory:_coordinator];
        

    }
    return self;
}

- (instancetype)initWithRouteParamObj:(TTRouteParamObj *)paramObj {
    self = [super init];
    if (self) {
        _coordinator = [[FHDetailPageCellCoordinator alloc] init];
        _detailPageDataSource = [[FHBTableViewDataSource alloc] initWithCoordinator:_coordinator
                                                                     withRespoitory:_coordinator];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    _tableView = [[UITableView alloc] init];
    [self.view addSubview:_tableView];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.dataSource = _detailPageDataSource;
    [_tableView registerClass:[CycleImageCell class] forCellReuseIdentifier:@"cycle"];
    [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.view);
    }];
}

@end
