//
//  FHSugSubscribeListViewController.m
//  FHHouseList
//
//  Created by 张元科 on 2019/3/19.
//

#import "FHSugSubscribeListViewController.h"
#import "FHHouseType.h"
#import "FHNeighborViewModel.h"
#import "TTReachability.h"
#import "UIViewAdditions.h"
#import "FHRefreshCustomFooter.h"
#import "FHUserTracker.h"
#import "FHConditionFilterFactory.h"
#import "SSNavigationBar.h"
#import "UIView+Refresh_ErrorHandler.h"
#import "UIViewController+NavbarItem.h"
#import "UIViewController+NavigationBarStyle.h"
#import "TTDeviceHelper.h"
#import "FHSugSubscribeListViewModel.h"
#import "FHFakeInputNavbar.h"

@interface FHSugSubscribeListViewController ()

@property (nonatomic, strong) FHSugSubscribeListViewModel *viewModel;

@property (nonatomic, strong) UITableView *tableView;

@end

@implementation FHSugSubscribeListViewController

- (instancetype)initWithRouteParamObj:(TTRouteParamObj *)paramObj {
    self = [super initWithRouteParamObj:paramObj];
    if (self) {
        self.houseType = [paramObj.allParams[@"house_type"] integerValue];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
}

- (void)setupUI {
    CGFloat height = [FHFakeInputNavbar perferredHeight];
    [self setupDefaultNavBar:YES];
    [self configTableView];
    self.viewModel = [[FHSugSubscribeListViewModel alloc] initWithController:self tableView:_tableView];
    [self.view addSubview:_tableView];
    [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.mas_equalTo(self.view);
        make.top.mas_equalTo(self.view).offset(height);
    }];
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
//        [self firstRequestDataWithLoading:YES];
    } else {
        [self.emptyView showEmptyWithType:FHEmptyMaskViewTypeNoNetWorkAndRefresh];
    }
}

- (void)retryLoadData {
    [self startLoadData];
}

@end
