//
//  FHPriceValuationHistoryController.m
//  FHHouseTrend
//
//  Created by 谢思铭 on 2019/3/22.
//

#import "FHPriceValuationHistoryController.h"
#import "FHPriceValuationHistoryCell.h"
#import "FHPriceValuationHistoryViewModel.h"
#import "FHPriceValuationHistoryModel.h"
#import "UIViewController+Refresh_ErrorHandler.h"
#import <TTReachability/TTReachability.h>

@interface FHPriceValuationHistoryController ()<TTRouteInitializeProtocol,UIViewControllerErrorHandler>

@property(nonatomic, strong) FHPriceValuationHistoryViewModel *viewModel;
@property(nonatomic ,strong) UITableView *tableView;

@end

@implementation FHPriceValuationHistoryController

- (instancetype)initWithRouteParamObj:(nullable TTRouteParamObj *)paramObj {
    self = [super initWithRouteParamObj:paramObj];
    if (self) {
        NSDictionary *params = paramObj.allParams;
//        self.tracerModel = [[FHTracerModel alloc] init];
//        self.tracerModel.enterFrom = params[@"enter_from"];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self initNavbar];
    [self initView];
    [self initConstraints];
    [self initViewModel];
}

- (void)initNavbar {
    [self setupDefaultNavBar:NO];
    self.customNavBarView.title.text = @"估价历史";
}

- (void)initView {
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    _tableView.backgroundColor = [UIColor themeGray7];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 10)];
    _tableView.tableHeaderView = headerView;
    
    CGFloat height = 10;
    if (@available(iOS 11.0 , *)) {
        height += [[[[UIApplication sharedApplication] delegate] window] safeAreaInsets].bottom;
    }
    
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, height)];
    _tableView.tableFooterView = footerView;
    
    _tableView.sectionFooterHeight = 0.0;
    
    _tableView.estimatedRowHeight = 85;
    _tableView.estimatedSectionHeaderHeight = 0;
    _tableView.estimatedSectionFooterHeight = 0;
    
    if (@available(iOS 11.0 , *)) {
        self.tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    
    [self.view addSubview:_tableView];
    [self addDefaultEmptyViewFullScreen];
}

- (void)initConstraints {
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        if (@available(iOS 11.0, *)) {
            make.top.mas_equalTo(self.mas_topLayoutGuide).offset(44);
        } else {
            make.top.mas_equalTo(64);
        }
        make.left.right.bottom.equalTo(self.view);
    }];
}

- (void)initViewModel {
    self.viewModel = [[FHPriceValuationHistoryViewModel alloc] initWithTableView:self.tableView controller:self];
    [self startLoadData];
}

- (void)startLoadData {
    if ([TTReachability isNetworkConnected]) {
        [_viewModel requestData];
    } else {
        if(!self.hasValidateData){
            [self.emptyView showEmptyWithType:FHEmptyMaskViewTypeNoNetWorkAndRefresh];
        }
    }
}

- (void)retryLoadData {
    [self startLoadData];
}

#pragma mark - UIViewControllerErrorHandler

- (BOOL)tt_hasValidateData {
    return NO;
}

@end
