//
//  FHPostEditListController.m
//
//  Created by zhangyuanke on 2019/12/19.
//

#import "FHPostEditListController.h"
#import "TTBaseMacro.h"
#import "UIScrollView+Refresh.h"
#import "UIViewAdditions.h"
#import <TTUIWidget/UIViewController+Track.h>
#import "FHUserTracker.h"
#import "FHUserTracker.h"
#import "FHFakeInputNavbar.h"
#import "FHConditionFilterFactory.h"
#import "FHUGCScialGroupModel.h"
#import "SSNavigationBar.h"
#import "UIView+Refresh_ErrorHandler.h"
#import "UIViewController+NavbarItem.h"
#import "UIViewController+NavigationBarStyle.h"
#import "TTDeviceHelper.h"
#import "FHBaseTableView.h"
#import "FHRefreshCustomFooter.h"
#import "FHPostEditListViewModel.h"
#import "TTReachability.h"

@interface FHPostEditListController ()

@property (nonatomic, assign) int64_t tid; //帖子ID--必须
@property (nonatomic, strong) FHPostEditListViewModel *viewModel;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) FHRefreshCustomFooter *refreshFooter;

@end

@implementation FHPostEditListController

- (instancetype)initWithRouteParamObj:(nullable TTRouteParamObj *)paramObj {
    self = [super initWithRouteParamObj:paramObj];
    if (self) {
        NSDictionary *params = paramObj.allParams;
        int64_t tid = [[paramObj.allParams objectForKey:@"query_id"] longLongValue];
        self.tid = tid;
        self.tracerDict[@"enter_type"] = @"click";
        self.tracerDict[@"category_name"] = [self pageType];
        self.tracerDict[@"page_type"] = [self pageType];
    }
    return self;
}

- (NSString *)pageType {
    return @"edit_record_list";
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.ttTrackStayEnable = YES;
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self setupUI];
    [self startLoadData];
    [self addGoDetailLog];
}

- (void)setupUI {
    [self setupDefaultNavBar:NO];
    self.customNavBarView.title.text = @"编辑记录";
    self.ttNeedHideBottomLine = NO;
    
    CGFloat height = [FHFakeInputNavbar perferredHeight];
    
    [self configTableView];
    self.viewModel = [[FHPostEditListViewModel alloc] initWithController:self tableView:_tableView];
    self.viewModel.tid = self.tid;
    [self.view addSubview:_tableView];
    [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(self.view);
        make.top.mas_equalTo(height);
        make.bottom.mas_equalTo(self.view);
    }];
    [self addDefaultEmptyViewWithEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    
}

- (void)configTableView {
    _tableView = [[FHBaseTableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    if (@available(iOS 11.0 , *)) {
        _tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    _tableView.estimatedRowHeight = 100;
    _tableView.estimatedSectionFooterHeight = 0;
    _tableView.estimatedSectionHeaderHeight = 0;
    _tableView.backgroundColor = [UIColor themeGray7];
    if ([TTDeviceHelper isIPhoneXDevice]) {
        _tableView.contentInset = UIEdgeInsetsMake(0, 0, 34, 0);
    }
    __weak typeof(self) wself = self;
    self.refreshFooter = [FHRefreshCustomFooter footerWithRefreshingBlock:^{
        [wself loadMore];
    }];
    self.tableView.mj_footer = _refreshFooter;
    [_refreshFooter setUpNoMoreDataText:@"暂无更多内容" offsetY:-3];
    
    _refreshFooter.hidden = YES;
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
    if (!self.isLoadingData) {
        [self startLoadData];
    }
}

// 加载更多
- (void)loadMore {
    [self.viewModel loadMore];
}

#pragma mark - TTUIViewControllerTrackProtocol

- (void)trackEndedByAppWillEnterBackground {
    [self addStayPageLog];
}

- (void)trackStartedByAppWillEnterForground {
    [self tt_resetStayTime];
    self.ttTrackStartTime = [[NSDate date] timeIntervalSince1970];
}

#pragma mark - Tracer

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self addStayPageLog];
}

-(void)addGoDetailLog {
    NSMutableDictionary *tracerDict = self.tracerDict.mutableCopy;
    [tracerDict removeObjectForKey:@"page_type"];
    [FHUserTracker writeEvent:@"enter_category" params:tracerDict];
}

-(void)addStayPageLog {
    NSTimeInterval duration = self.ttTrackStayTime * 1000.0;
    if (duration == 0) {
        return;
    }
    NSMutableDictionary *tracerDict = self.tracerDict.mutableCopy;
    [tracerDict removeObjectForKey:@"page_type"];
    tracerDict[@"stay_time"] = [NSNumber numberWithInteger:duration];
    [FHUserTracker writeEvent:@"stay_category" params:tracerDict];
    [self tt_resetStayTime];
}

@end
