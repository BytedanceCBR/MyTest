//
//  FHTopicListController.m
//  小区话题列表页VC
//
//  Created by zhulijun on 2019/6/3.
//

#import "FHTopicListController.h"
#import "FHTopicListViewModel.h"
#import "FHRefreshCustomFooter.h"
#import "TTReachability.h"
#import "TTBaseMacro.h"

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
    [self initView];
    [self initConstraints];
    [self initViewModel];
}

- (void)initView {
    [self setupDefaultNavBar:YES];

    [self.customNavBarView.leftBtn setBackgroundImage:[UIImage imageNamed:@"icon-return-white"] forState:UIControlStateNormal];
    [self.customNavBarView.leftBtn setBackgroundImage:[UIImage imageNamed:@"icon-return-white"] forState:UIControlStateHighlighted];
    [self.customNavBarView setNaviBarTransparent:YES];
    [self setTitle:@"小区话题"];


    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    [self.view addSubview:self.tableView];

    WeakSelf;
    self.refreshFooter = [FHRefreshCustomFooter footerWithRefreshingBlock:^{
        [wself loadMore];
    }];
    self.tableView.mj_footer = self.refreshFooter;

    [self addDefaultEmptyViewWithEdgeInsets:UIEdgeInsetsMake(44, 0, 0, 0)];
}

- (void)initConstraints {
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.bottom.mas_equalTo(self.view);
    }];
}

- (void)initViewModel {
    self.viewModel = [[FHTopicListViewModel alloc] initWithController:self tableView:self.tableView];
    [self.viewModel requestData:NO];
}

- (void)retryLoadData {
    [self loadData:NO];
}

- (void)loadMore {
    [self loadData:YES];
}

- (void)loadData:(BOOL)isLoadMore {
    if (![TTReachability isNetworkConnected]) {
        return;
    }
    [self.viewModel requestData:isLoadMore];
}

@end
