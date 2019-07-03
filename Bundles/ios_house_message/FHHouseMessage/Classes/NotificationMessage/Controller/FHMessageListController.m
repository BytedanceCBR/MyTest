//
//  FHMessageListController.m
//  Article
//
// Created by zhulijun on 2019-06-17.
//
//

#import "FHMessageListController.h"
#import "FHMessageNotificationBaseCell.h"
#import "FHMessageNotificationManager.h"

#import <TTAccountBusiness.h>
#import "UIScrollView+Refresh.h"
#import "FHMessageNotificationCellHelper.h"
#import "FHMessageNotificationTipsManager.h"
#import <WDNetWorkPluginManager.h>
#import "FHMessageListViewModel.h"
#import "FHRefreshCustomFooter.h"
#import "UIViewController+Track.h"
#import <WDApiModel.h>


@interface FHMessageListController ()<TTUIViewControllerTrackProtocol>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, assign) BOOL hasMore;
@property (nonatomic, strong) FHRefreshCustomFooter *refreshFooter;
@property(nonatomic, strong) FHMessageListViewModel *viewModel;

@end

@implementation FHMessageListController

- (instancetype)initWithRouteParamObj:(TTRouteParamObj *)paramObj {
    self = [super initWithRouteParamObj:paramObj];
    if (self) {
        self.ttTrackStayEnable = YES;
        self.title = paramObj.allParams[@"title"];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initView];
    [self initConstraints];
    [self initViewModel];
    [[FHMessageNotificationTipsManager sharedManager] clearTipsModel];
}

- (void)initView {
    [self setupDefaultNavBar:YES];
    [self setTitle:self.title];
    self.automaticallyAdjustsScrollViewInsets = NO;

    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.tableView.backgroundView = nil;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:self.tableView];

    if (@available(iOS 11.0, *)) {
        self.tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }

    WeakSelf;
    self.refreshFooter = [FHRefreshCustomFooter footerWithRefreshingBlock:^{
        StrongSelf;
        [wself.viewModel requestData:YES isFirst:NO];
    }];
    self.tableView.mj_footer = self.refreshFooter;
    [self.refreshFooter setUpNoMoreDataText:@"暂无更多数据" offsetY:-3];
    self.refreshFooter.hidden = YES;

    [FHMessageNotificationCellHelper registerAllCellClassWithTableView:self.tableView];
    [self addDefaultEmptyViewFullScreen];
}


- (void)initConstraints {
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        if (@available(iOS 11.0, *)) {
            make.top.mas_equalTo(self.view).offset(44.f + self.view.tt_safeAreaInsets.top);
        } else {
            make.top.mas_equalTo(64);
        }
        make.left.right.bottom.mas_equalTo(self.view);
    }];
}


- (void)initViewModel {
    self.viewModel = [[FHMessageListViewModel alloc] initWithTableView:self.tableView controller:self];
    self.viewModel.tracerDict = self.tracerDict;
    [self.viewModel requestData:NO isFirst:YES];
}

- (void)retryLoadData {
    [self.viewModel requestData:NO isFirst:NO];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.viewModel addStayCategoryLog:self.ttTrackStartTime];
    [self tt_resetStayTime];
}

- (void)trackEndedByAppWillEnterBackground {
    [self.viewModel addStayCategoryLog:self.ttTrackStayTime];
    [self tt_resetStayTime];
}

- (void)trackStartedByAppWillEnterForground {
    [self tt_resetStayTime];
    self.ttTrackStartTime = [[NSDate date] timeIntervalSince1970];
}

@end
