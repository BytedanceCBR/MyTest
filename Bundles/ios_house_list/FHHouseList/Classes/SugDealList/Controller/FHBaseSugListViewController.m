//
//  FHSugDealListViewController.m
//  FHHouseList
//
//  Created by 张静 on 2019/4/18.
//

#import "FHBaseSugListViewController.h"
#import <FHCommonUI/FHSearchBar.h>
#import "FHBaseSugListViewModel.h"
#import <FHCommonUI/FHHouseBaseTableView.h>
#import <TTBaseLib/TTDeviceHelper.h>
#import <TTUIWidget/TTNavigationController.h>
#import <TTReachability/TTReachability.h>

@interface FHBaseSugListViewController ()

@property (nonatomic, strong)   FHSearchBar       *naviBar;
@property (nonatomic, strong)   FHHouseBaseTableView       *suggestTableView;
@property (nonatomic, strong)   FHBaseSugListViewModel      *viewModel;
@property (nonatomic, strong)   TTRouteParamObj      *paramObj;
@property (nonatomic, assign)   FHHouseType      houseType;
@property (nonatomic, assign)   FHSugListSearchType      searchType;

@end

@implementation FHBaseSugListViewController

- (instancetype)initWithRouteParamObj:(TTRouteParamObj *)paramObj
{
    self = [super initWithRouteParamObj:paramObj];
    if (self) {
        _paramObj = paramObj;
        if ([paramObj.host isEqualToString:@"house_search_deal_neighborhood"]) {
            self.houseType = FHHouseTypeNeighborhood;
            self.searchType = FHSugListSearchTypeNeighborDealList;
        }
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self setupUI];
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
    __weak typeof(self) weakSelf = self;
    self.panBeginAction = ^{
        [weakSelf.naviBar.searchInput resignFirstResponder];
    };
    // 初始化
    if (![TTReachability isNetworkConnected]) {
        [self.emptyView showEmptyWithType:FHEmptyMaskViewTypeNoNetWorkNotRefresh];
        self.suggestTableView.hidden = YES;
    } else {
        self.suggestTableView.hidden = YES;
        self.emptyView.hidden = YES;
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [weakSelf.naviBar.searchInput becomeFirstResponder];
    });
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.naviBar.searchInput resignFirstResponder];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self.naviBar.searchInput resignFirstResponder];
}

- (void)setupUI
{
    self.suggestTableView = [self createTableView];
    [self setupNaviBar];
    self.viewModel = [[FHBaseSugListViewModel alloc] initWithTableView:self.suggestTableView paramObj:_paramObj];
    self.viewModel.houseType = self.houseType;
    self.viewModel.searchType = self.searchType;
    self.viewModel.listController = self;
    self.viewModel.naviBar = _naviBar;
    [self addDefaultEmptyViewWithEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    self.emptyView.hidden = NO;
}

- (void)setupNaviBar
{
    BOOL isIphoneX = [TTDeviceHelper isIPhoneXDevice];
    _naviBar = [[FHSearchBar alloc] init];
    [self.view addSubview:_naviBar];
    CGFloat naviHeight = 44 + (isIphoneX ? 44 : 20);
    [_naviBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.mas_equalTo(self.view);
        make.height.mas_equalTo(naviHeight);
    }];
    [_naviBar.backBtn addTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];

}

- (FHHouseBaseTableView *)createTableView
{
    BOOL isIphoneX = [TTDeviceHelper isIPhoneXDevice];
    FHHouseBaseTableView *tableView = [[FHHouseBaseTableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    __weak typeof(self) weakSelf = self;
    tableView.handleTouch = ^{
        [weakSelf.view endEditing:YES];
    };
    tableView.backgroundColor = UIColor.whiteColor;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    if (isIphoneX) {
        tableView.contentInset = UIEdgeInsetsMake(0, 0, 34, 0);
    }
    tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    [self.view addSubview:tableView];
    [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(self.view);
        make.top.mas_equalTo(self.naviBar.mas_bottom);
        make.bottom.mas_equalTo(self.view);
    }];
    if (@available(iOS 11.0 , *)) {
        tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    tableView.estimatedRowHeight = UITableViewAutomaticDimension;
    tableView.estimatedSectionFooterHeight = 0;
    tableView.estimatedSectionHeaderHeight = 0;
    
    return tableView;
}

@end
