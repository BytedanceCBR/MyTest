//
//  FHChildBrowsingHistoryViewController.m
//  FHHouseMine
//
//  Created by xubinbin on 2020/7/13.
//

#import "FHChildBrowsingHistoryViewController.h"
#import "FHBrowsingHistoryEmptyView.h"
#import "Masonry.h"
#import "FHChildBrowsingHistoryViewModel.h"
#import "TTDeviceHelper.h"
#import <FHHouseBase/FHBaseTableView.h>
#import "FHEnvContext.h"

@interface FHChildBrowsingHistoryViewController()

@property (nonatomic, strong) FHBrowsingHistoryEmptyView *findHouseView;
@property (nonatomic, strong) FHChildBrowsingHistoryViewModel *viewModel;
@property (nonatomic, strong) UITableView *tableView;

@end

@implementation FHChildBrowsingHistoryViewController

- (instancetype)initWithRouteParamObj:(TTRouteParamObj *)paramObj {
    self = [super initWithRouteParamObj:paramObj];
    if (self) {
        self.tracerDict[@"origin_from"] = @"minetab_service";
        self.tracerDict[@"enter_from"] = @"minetab";
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addDefaultEmptyViewFullScreen];
    [self setupUI];
    self.viewModel = [[FHChildBrowsingHistoryViewModel alloc] initWithViewController:self tableView:self.tableView emptyView:self.findHouseView];
}

- (void)retryLoadData {
    [self.viewModel requestData:YES];
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
    self.findHouseView.houseType = houseType;
    self.viewModel.houseType = houseType;
    [self requestBrowsingHistoryData];
}

- (void)requestBrowsingHistoryData {
    if (![FHEnvContext isNetworkConnected]) {
        [self.emptyView showEmptyWithType:FHEmptyMaskViewTypeNoNetWorkAndRefresh];
    } else {
        [self startLoading];
        [self.viewModel requestData:YES];
    }
}

- (void)setupUI {
    self.findHouseView = [[FHBrowsingHistoryEmptyView alloc] init];
    self.findHouseView.hidden = YES;
    [self.view addSubview:self.findHouseView];
    [self.findHouseView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.view);
    }];
    
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.view);
    }];
    self.tableView.hidden = YES;
}

#pragma mark - lazy load

-(UITableView *)tableView {
    if (!_tableView) {
        
        _tableView = [[FHBaseTableView alloc] initWithFrame:self.view.bounds];
        if (@available(iOS 11.0, *)) {
            _tableView.estimatedRowHeight = 0;
            _tableView.estimatedSectionHeaderHeight = 0;
            _tableView.estimatedSectionFooterHeight = 0;
            _tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
        if ([TTDeviceHelper isIPhoneXDevice]) {
            _tableView.contentInset = UIEdgeInsetsMake(0, 0, 34, 0);
        }
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.showsVerticalScrollIndicator = NO;
        _tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    }
    return _tableView;
}

- (void)dealloc
{
    
}
@end
