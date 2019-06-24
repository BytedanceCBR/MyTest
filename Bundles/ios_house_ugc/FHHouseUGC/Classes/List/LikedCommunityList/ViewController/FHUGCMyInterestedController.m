//
//  FHUGCMyInterestedController.m
//  FHHouseUGC
//
//  Created by 谢思铭 on 2019/6/13.
//

#import "FHUGCMyInterestedController.h"
#import "UIViewController+Refresh_ErrorHandler.h"
#import "FHUGCMyInterestedViewModel.h"
#import "TTReachability.h"

@interface FHUGCMyInterestedController ()<TTRouteInitializeProtocol,UIViewControllerErrorHandler>

@property(nonatomic, strong) FHUGCMyInterestedViewModel *viewModel;
@property(nonatomic ,strong) UITableView *tableView;

@end

@implementation FHUGCMyInterestedController

- (instancetype)initWithRouteParamObj:(nullable TTRouteParamObj *)paramObj {
    self = [super initWithRouteParamObj:paramObj];
    if (self) {
//        self.type = [paramObj.allParams[@"type"] integerValue];
        self.title = @"你可能感兴趣的小区";
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    if(self.type == FHUGCMyInterestedTypeMore){
        [self initNavbar];
    }
    [self initView];
    [self initConstraints];
    [self initViewModel];
}

- (void)initNavbar {
    [self setupDefaultNavBar:NO];
    self.customNavBarView.title.text = self.title;
}

- (void)initView {
    _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    _tableView.backgroundColor = [UIColor themeGray7];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0.001)];
    if(self.type == FHUGCMyInterestedTypeEmpty){
        headerView = [self emptyHeaderView];
    }
    _tableView.tableHeaderView = headerView;
    
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0.001)];
    _tableView.tableFooterView = footerView;
    
    _tableView.sectionFooterHeight = 0.0;
    
    _tableView.estimatedSectionHeaderHeight = 0;
    _tableView.estimatedSectionFooterHeight = 0;
    
    if (@available(iOS 11.0 , *)) {
        self.tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    
    [self.view addSubview:_tableView];
    
    [self addDefaultEmptyViewWithEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    
    if(self.type == FHUGCMyInterestedTypeEmpty){
        
        _tableView.estimatedRowHeight = 192;
        
        [self.emptyView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(self.view);
        }];
    }else{
        _tableView.estimatedRowHeight = 70;
    }
}

- (UIView *)emptyHeaderView {
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 36)];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(20, 15, [UIScreen mainScreen].bounds.size.width, 21)];
    label.font = [UIFont themeFontRegular:15];
    label.textColor = [UIColor themeGray1];
    label.text = @"你可能刚兴趣的小区";
    [headerView addSubview:label];
    
    return headerView;
}

- (void)initConstraints {
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        if(self.type == FHUGCMyInterestedTypeMore){
            if (@available(iOS 11.0, *)) {
                make.top.mas_equalTo(self.mas_topLayoutGuide).offset(44);
            } else {
                make.top.mas_equalTo(64);
            }
        }else{
            make.top.mas_equalTo(self.view);
        }
        make.left.right.bottom.mas_equalTo(self.view);
    }];
}

- (void)initViewModel {
    self.viewModel = [[FHUGCMyInterestedViewModel alloc] initWithTableView:self.tableView controller:self];
    [self startLoadData];
}

- (void)startLoadData {
    if ([TTReachability isNetworkConnected]) {
        [_viewModel requestData:YES];
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
    return _viewModel.dataList.count == 0 ? NO : YES; //默认会显示空
}

@end
