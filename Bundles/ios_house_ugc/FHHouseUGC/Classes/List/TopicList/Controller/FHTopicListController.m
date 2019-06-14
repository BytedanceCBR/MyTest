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

@interface FHTopicListController ()
@property(nonatomic, copy) NSString *topicId;
@property(nonatomic, strong) UITableView *tableView;
@property(nonatomic, strong) FHRefreshCustomFooter *refreshFooter;
@property(nonatomic, strong) FHTopicListViewModel *viewModel;
@end

@implementation FHTopicListController

- (instancetype)initWithRouteParamObj:(nullable TTRouteParamObj *)paramObj {
    self = [super initWithRouteParamObj:paramObj];
    if (self) {
        self.topicId = paramObj.allParams[@"topic_id"];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self initView];
    [self initConstraints];
    [self initViewModel];
}

- (void)initView {
    [self setupDefaultNavBar:YES];
    [self setTitle:@"小区话题"];

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

    WeakSelf;
    self.refreshFooter = [FHRefreshCustomFooter footerWithRefreshingBlock:^{
        [wself loadData:NO];
    }];
    self.tableView.mj_footer = self.refreshFooter;

    [self.tableView tt_addDefaultPullDownRefreshWithHandler:^{
        [wself loadData:YES];
    }];

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

@end
