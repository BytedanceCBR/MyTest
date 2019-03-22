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
#import "FHEnvContext.h"

@interface FHSugSubscribeListViewController ()

@property (nonatomic, strong) FHSugSubscribeListViewModel *viewModel;

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong)   UILabel       *headerLabel;

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
     self.automaticallyAdjustsScrollViewInsets = NO;
    self.view.backgroundColor = [UIColor whiteColor];
    [self setupUI];
    [self startLoadData];
}

- (void)setupUI {
    CGFloat height = [FHFakeInputNavbar perferredHeight];
    [self setupDefaultNavBar:YES];
    [self configTableView];
    self.viewModel = [[FHSugSubscribeListViewModel alloc] initWithController:self tableView:_tableView];
    [self.view addSubview:_tableView];
    _tableView.backgroundColor = [UIColor whiteColor];
    [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.mas_equalTo(self.view);
        make.top.mas_equalTo(self.view).offset(height);
    }];
    // headerLabel
    UIView *headerBgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 30)];
    headerBgView.backgroundColor = [UIColor themeGray7];
    _headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, [UIScreen mainScreen].bounds.size.width - 40, 30)];
    _headerLabel.backgroundColor = [UIColor themeGray7];
    _headerLabel.text = @"订阅后的房源列表筛选条件会出现在这里哦~";
    _headerLabel.textColor = [UIColor themeGray3];
    _headerLabel.font = [UIFont themeFontRegular:12];
    _headerLabel.textAlignment = NSTextAlignmentCenter;
    [headerBgView addSubview:_headerLabel];
    _tableView.tableHeaderView = headerBgView;
    
    // empty view
    [self addDefaultEmptyViewWithEdgeInsets:UIEdgeInsetsMake(height, 0, 0, 0)];
}

- (void)configTableView {
    _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    if (@available(iOS 11.0 , *)) {
        _tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        _tableView.estimatedRowHeight = UITableViewAutomaticDimension;
        _tableView.estimatedSectionFooterHeight = 0;
        _tableView.estimatedSectionHeaderHeight = 0;
    }
    if ([TTDeviceHelper isIPhoneXDevice]) {
        _tableView.contentInset = UIEdgeInsetsMake(0, 0, 34, 0);
    }
}

- (void)startLoadData {
    if ([TTReachability isNetworkConnected]) {
        [self requestData];
    } else {
        [self.emptyView showEmptyWithType:FHEmptyMaskViewTypeNoNetWorkAndRefresh];
    }
}

- (void)retryLoadData {
    [self startLoadData];
}

- (void)requestData {
    self.hasValidateData = NO;
    [self startLoading];
    NSInteger cityId = [[FHEnvContext getCurrentSelectCityIdFromLocal] integerValue];
    [self.viewModel requestSugSubscribe:cityId houseType:self.houseType];
}

// cell 点击
- (void)cellSubscribeItemClick:(FHSugSubscribeDataDataItemsModel *)model {
    if (model && [model isKindOfClass:[FHSugSubscribeDataDataItemsModel class]]) {
        if (model.status) {
            // 可点击
            
        }
    }
}

@end
