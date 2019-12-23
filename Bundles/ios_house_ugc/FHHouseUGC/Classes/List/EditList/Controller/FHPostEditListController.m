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
#import <FHUserTracker.h>
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
        int64_t tid = [[paramObj.allParams objectForKey:@"tid"] longLongValue];
        self.tid = tid;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.ttTrackStayEnable = YES;
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self setupUI];
    [self startLoadData];
}

- (void)setupUI {
    [self setupDefaultNavBar:YES];
    [self setTitle:@"编辑记录"];
    self.ttNeedHideBottomLine = NO;
    
    CGFloat height = [FHFakeInputNavbar perferredHeight];
    
    [self configTableView];
    self.viewModel = [[FHPostEditListViewModel alloc] initWithController:self tableView:_tableView];
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
    _tableView.estimatedRowHeight = 0;
    _tableView.estimatedSectionFooterHeight = 0;
    _tableView.estimatedSectionHeaderHeight = 0;
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
        [self startLoading];
        self.isLoadingData = YES;
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

@end
