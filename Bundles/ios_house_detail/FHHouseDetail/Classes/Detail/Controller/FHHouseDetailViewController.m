//
//  FHHouseDetailViewController.m
//  FHHouseDetail
//
//  Created by 春晖 on 2018/12/6.
//

#import "FHHouseDetailViewController.h"
#import "FHHouseDetailBaseViewModel.h"
#import "TTReachability.h"

@interface FHHouseDetailViewController ()

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong)   FHHouseDetailBaseViewModel       *viewModel;
@property (nonatomic, assign)   FHHouseType houseType; // 房源类型
@property (nonatomic, copy)   NSString* houseId; // 房源id

@end

@implementation FHHouseDetailViewController

- (instancetype)initWithRouteParamObj:(TTRouteParamObj *)paramObj {
    self = [super initWithRouteParamObj:paramObj];
    if (self) {
        self.houseType = [paramObj.allParams[@"house_type"] integerValue];
        self.houseId = paramObj.allParams[@"house_id"];
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self setupUI];
    [self startLoadData];
}

- (void)startLoadData {
    if ([TTReachability isNetworkConnected]) {
        [self.viewModel startLoadData];
    } else {
        [self.emptyView showEmptyWithType:FHEmptyMaskViewTypeNoNetWorkAndRefresh];
    }
}

// 重新加载
- (void)retryLoadData {
    [self startLoadData];
}

- (void)setupUI {
    [self configTableView];
    self.viewModel = [FHHouseDetailBaseViewModel createDetailViewModelWithHouseType:self.houseType withController:self tableView:_tableView];
    self.viewModel.houseId = self.houseId;
    [self.view addSubview:_tableView];
    [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.view);
    }];
    [self addDefaultEmptyViewFullScreen];
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
}

@end
