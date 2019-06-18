//
//  TTMessageNotificationViewController.m
//  Article
//
//  Created by lizhuoli on 17/3/27.
//
//

#import "FHMessageListController.h"
#import "FHMessageNotificationBaseCell.h"
#import "TTMessageNotificationManager.h"

#import <TTAccountBusiness.h>
#import "UIScrollView+Refresh.h"
#import "SDWebImageCompat.h"
#import "FHMessageNotificationCellHelper.h"
#import "TTMessageNotificationTipsManager.h"
#import <WDNetWorkPluginManager.h>
#import "FHMessageListViewModel.h"
#import <WDApiModel.h>
#import <TTBaseLib/TTUIResponderHelper.h>


@interface FHMessageListController ()

@property (nonatomic, strong) SSThemedTableView *tableView;
@property (nonatomic, copy) NSArray<TTMessageNotificationModel *> *messageModels; //所有拉取到的message模型数组
@property (nonatomic, strong) NSNumber *minCursor; //当前的消息列表的minCursor，在loadMore为YES时可以继续用该cursor值拉取后续的消息
@property (nonatomic, strong) NSNumber *readCursor; //未读已读的分界线cursor
@property (nonatomic, assign) NSUInteger readSeparatorIndex; //message模型数组对应的未读已读分界线index，找不到时为NSNotFound
@property (nonatomic, assign) BOOL hasMore; //请求是否hasMore
@property (nonatomic, assign) BOOL hasLoad; //是否第一次加载成功
@property (nonatomic, assign) BOOL hasReadFooterView; //是否已经点击了查看历史消息
@property (nonatomic, assign) BOOL hasGetListResponse; //判断是否获取过list接口的response
@property (nonatomic, assign) BOOL shouldSendPushEvent; //针对的是通过push进入页面时，用户点击页面跳转时，需要发送埋点
@property(nonatomic, strong) FHMessageListViewModel *viewModel;

@end

@implementation FHMessageListController

- (instancetype)initWithRouteParamObj:(TTRouteParamObj *)paramObj {
    self = [super initWithRouteParamObj:paramObj];
    if (self) {

    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initView];
    [self initConstraints];
    [self initViewModel];
    [[TTMessageNotificationTipsManager sharedManager] clearTipsModel];
}

- (void)initView {
    [self setupDefaultNavBar:YES];
    [self setTitle:@"消息"];
    self.automaticallyAdjustsScrollViewInsets = NO;

    self.tableView = [[SSThemedTableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.tableView.enableTTStyledSeparator = NO;
    self.tableView.backgroundView = nil;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:self.tableView];

    if (@available(iOS 11.0, *)) {
        self.tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }

    //允许上拉刷新
    WeakSelf;
    [self.tableView tt_addDefaultPullUpLoadMoreWithHandler:^{
        StrongSelf;
        [wself loadData:YES];
    }];

    self.tableView.pullUpView.enabled = NO;

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
    [self.viewModel requestData:NO];
}

- (void)retryLoadData {
    [self loadData:NO];
}

- (void)loadData:(BOOL)isLoadMore {
    [self.viewModel requestData:isLoadMore];
}

@end
