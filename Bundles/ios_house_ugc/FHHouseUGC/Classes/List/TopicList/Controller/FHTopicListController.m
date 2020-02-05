//
//  FHTopicListController.m
//  小区话题列表页VC
//
//  Created by zhulijun on 2019/6/3.
//

#import "FHTopicListController.h"
#import "FHTopicListViewModel.h"
#import "FHRefreshCustomFooter.h"
#import "TTBaseMacro.h"
#import "UIScrollView+Refresh.h"
#import "UIViewAdditions.h"
#import <TTUIWidget/UIViewController+Track.h>
#import <FHUserTracker.h>

@interface FHTopicListController () <TTUIViewControllerTrackProtocol>
@property(nonatomic, strong) UITableView *tableView;
@property(nonatomic, strong) FHRefreshCustomFooter *refreshFooter;
@property(nonatomic, strong) FHTopicListViewModel *viewModel;
@property(nonatomic, weak) id<FHTopicListControllerDelegate> delegate;
@end

@implementation FHTopicListController

- (instancetype)initWithRouteParamObj:(nullable TTRouteParamObj *)paramObj {
    self = [super initWithRouteParamObj:paramObj];
    if (self) {
        self.delegate = paramObj.allParams[@"delegate"];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.ttTrackStayEnable = YES;
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self initView];
    [self initConstraints];
    [self initViewModel];
    [self.viewModel addEnterCategoryLog];
}

- (void)initView {
    [self setTitle:@"热门话题"];
    [self setupDefaultNavBar:YES];
    
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    [self.view addSubview:self.tableView];
    
    if (@available(iOS 11.0 , *)) {
        self.tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    
//    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0.001)];
//    _tableView.tableHeaderView = headerView;
//    
//    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0.001)];
//    _tableView.tableFooterView = footerView;
    
    _tableView.estimatedRowHeight = 85;
    _tableView.estimatedSectionHeaderHeight = 0;
    _tableView.estimatedSectionFooterHeight = 0;

    // 本期接回一次性返回，不涉及上下拉操作和相关埋点
//    // 下拉刷新
//    WeakSelf;
//    [self.tableView tt_addDefaultPullDownRefreshWithHandler:^{
//        StrongSelf;
//        [self loadData:YES];
//        [wself.viewModel addCategoryRefreshLog:YES];
//    }];
//
//    // 上拉加载更多
//    self.refreshFooter = [FHRefreshCustomFooter footerWithRefreshingBlock:^{
//        StrongSelf;
//        [wself loadData:NO];
//        [wself.viewModel addCategoryRefreshLog:NO];
//    }];
    
    self.tableView.mj_footer = self.refreshFooter;

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
    self.viewModel = [[FHTopicListViewModel alloc] initWithController:self tableView:self.tableView];
    [self.viewModel requestData:YES];
}

- (void)retryLoadData {
    [self loadData:NO];
}

- (void)loadData:(BOOL)isRefresh {
    [self.viewModel requestData:isRefresh];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    [self.viewModel addStayCategoryLog:self.ttTrackStayTime];
    [self tt_resetStayTime];
}

#pragma mark - TTUIViewControllerTrackProtocol

- (void)trackEndedByAppWillEnterBackground {
    [self.viewModel addStayCategoryLog:self.ttTrackStayTime];
    [self tt_resetStayTime];
}
@end
