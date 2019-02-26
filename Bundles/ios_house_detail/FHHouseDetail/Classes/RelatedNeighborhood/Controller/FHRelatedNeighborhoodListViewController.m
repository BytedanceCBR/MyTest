//
//  FHRelatedNeighborhoodListVC.m
//  Pods
//
//  Created by 张静 on 2019/2/24.
//

#import "FHRelatedNeighborhoodListViewController.h"
#import "FHRelatedNeighborhoodListViewModel.h"
#import <TTUIWidget/UIViewController+Track.h>
#import <TTBaseLib/TTDeviceHelper.h>
#import <TTReachability/TTReachability.h>

@interface FHRelatedNeighborhoodListViewController ()

@property (nonatomic, strong) FHRelatedNeighborhoodListViewModel *viewModel;
@property (nonatomic, copy) NSString *neighborhoodId;
@property (nonatomic, strong) UITableView *tableView;

@end

@implementation FHRelatedNeighborhoodListViewController

- (instancetype)initWithRouteParamObj:(TTRouteParamObj *)paramObj {
    self = [super initWithRouteParamObj:paramObj];
    if (self) {

        self.neighborhoodId = paramObj.userInfo.allInfo[@"neighborhood_id"];
        self.ttTrackStayEnable = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self setupUI];
    [self startLoadData];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.viewModel viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.viewModel viewWillDisappear:animated];
}

- (void)setupUI {
    [self setupDefaultNavBar:NO];
    self.customNavBarView.title.text = @"周边小区";
    [self configTableView];
    self.viewModel = [[FHRelatedNeighborhoodListViewModel alloc] initWithController:self tableView:_tableView];
    self.viewModel.neighborhoodId = self.neighborhoodId;
    [self.view addSubview:_tableView];
    [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(self.view);
        make.top.mas_equalTo(self.customNavBarView.mas_bottom);
        make.bottom.mas_equalTo(self.view);
    }];
    [self addDefaultEmptyViewFullScreen];
    [self.viewModel setMaskView:self.emptyView];
}

- (void)configTableView {
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
}

- (void)startLoadData {
    if ([TTReachability isNetworkConnected]) {
        [self.viewModel requestRelatedNeighborhoodSearch:self.neighborhoodId searchId:nil offset:@(0)];
    } else {
        [self.emptyView showEmptyWithType:FHEmptyMaskViewTypeNoNetWorkAndRefresh];
    }
}

//- (void)retryLoadData {
//    [self startLoadData];
//}

#pragma mark - TTUIViewControllerTrackProtocol

- (void)trackEndedByAppWillEnterBackground {
    [self.viewModel addStayCategoryLog];
}

- (void)trackStartedByAppWillEnterForground {
    [self tt_resetStayTime];
    self.ttTrackStartTime = [[NSDate date] timeIntervalSince1970];
}


@end
