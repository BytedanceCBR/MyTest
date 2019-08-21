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
#import <FHHouseBase/FHBaseTableView.h>

@interface FHSugSubscribeListViewController ()

@property (nonatomic, strong) FHSugSubscribeListViewModel *viewModel;

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong)   UILabel       *headerLabel;

@property (nonatomic, weak)     id<FHSugSubscribeListDelegate>    subscribeDelegate; // 搜索组合订阅列表页的代理subscribe_delegate

@property (nonatomic, strong)   NSMutableDictionary       *categoryLogDict;

@end

@implementation FHSugSubscribeListViewController

- (instancetype)initWithRouteParamObj:(TTRouteParamObj *)paramObj {
    self = [super initWithRouteParamObj:paramObj];
    if (self) {
        self.categoryLogDict = [NSMutableDictionary new];
        self.houseType = [paramObj.allParams[@"house_type"] integerValue];
        NSHashTable<FHSugSubscribeListDelegate> *subscribe_delegate = paramObj.allParams[@"subscribe_delegate"];
        self.subscribeDelegate = subscribe_delegate.anyObject;
        
        // 埋点数据
        if (self.tracerDict.count > 0) {
            [self.categoryLogDict addEntriesFromDictionary:self.tracerDict];
        }
        self.ttTrackStayEnable = YES;
        // 添加固定埋点
        self.categoryLogDict[@"category_name"] = @"search_subscribe";
        self.categoryLogDict[@"enter_type"] = @"click";
        self.categoryLogDict[@"origin_search_id"] = self.tracerDict[@"origin_search_id"] ? self.tracerDict[@"origin_search_id"] : @"be_null";
        self.categoryLogDict[@"search_id"] = self.tracerDict[@"search_id"] ? self.tracerDict[@"search_id"] : @"be_null";
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
     self.automaticallyAdjustsScrollViewInsets = NO;
    self.view.backgroundColor = [UIColor whiteColor];
    [self setupUI];
    [self startLoadData];
    [self addEnterCategoryLog];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self addStayCategoryLog];
}

- (void)setupUI {
    CGFloat height = [FHFakeInputNavbar perferredHeight];
    [self setupDefaultNavBar:YES];
    [self configTableView];
    self.viewModel = [[FHSugSubscribeListViewModel alloc] initWithController:self tableView:_tableView];
    self.viewModel.houseType = self.houseType;
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
    [self addDefaultEmptyViewWithEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
}

- (void)configTableView {
    _tableView = [[FHBaseTableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    if (@available(iOS 11.0 , *)) {
        _tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    _tableView.estimatedRowHeight = 75;
    _tableView.estimatedSectionFooterHeight = 0;
    _tableView.estimatedSectionHeaderHeight = 0;
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
            if (self.subscribeDelegate) {
                [self.subscribeDelegate cellSubscribeItemClick:model];
            }
        }
    }
}

-(void)addEnterCategoryLog {
    NSMutableDictionary *tracerDict = self.categoryLogDict.mutableCopy;
    [FHUserTracker writeEvent:@"enter_category" params:tracerDict];
}

-(void)addStayCategoryLog {
    NSTimeInterval duration = self.ttTrackStayTime * 1000.0;
    if (duration == 0) {
        return;
    }
    NSMutableDictionary *tracerDict = self.categoryLogDict.mutableCopy;
    tracerDict[@"stay_time"] = [NSNumber numberWithInteger:duration];
    [FHUserTracker writeEvent:@"stay_category" params:tracerDict];
    [self tt_resetStayTime];
}

#pragma mark - TTUIViewControllerTrackProtocol

- (void)trackEndedByAppWillEnterBackground {
    [self addStayCategoryLog];
}

- (void)trackStartedByAppWillEnterForground {
    [self tt_resetStayTime];
    self.ttTrackStartTime = [[NSDate date] timeIntervalSince1970];
}

@end
