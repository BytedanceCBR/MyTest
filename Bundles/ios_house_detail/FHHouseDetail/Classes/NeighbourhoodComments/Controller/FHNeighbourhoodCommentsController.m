//
//  FHNeighbourhoodCommentsController.m
//  FHHouseDetail
//
//  Created by 王志舟 on 2020/2/23.
//

#import "FHNeighbourhoodCommentsController.h"
#import "UIColor+Theme.h"
#import "FHCommunityFeedListBaseViewModel.h"
#import "FHNeighbourhoodCommentsViewModel.h"
#import "TTReachability.h"
#import "UIViewAdditions.h"
#import "TTDeviceHelper.h"
#import "TTRoute.h"
#import "TTAccountManager.h"
#import "TTAccount+Multicast.h"
#import "FHEnvContext.h"
#import "FHUserTracker.h"
#import "UIScrollView+Refresh.h"
#import "FHFeedOperationView.h"
#import <FHHouseBase/FHBaseTableView.h>
#import "FHUGCConfig.h"
#import "ToastManager.h"
#import "FHUGCPostMenuView.h"
#import "FHCommonDefines.h"
#import "FHUserTracker.h"
#import "UIViewController+Track.h"

@interface FHNeighbourhoodCommentsController ()<SSImpressionProtocol, FHUGCPostMenuViewDelegate>

@property(nonatomic, strong) FHCommunityFeedListBaseViewModel *viewModel;
@property(nonatomic, copy) void(^notifyCompletionBlock)(void);
@property(nonatomic, assign) NSInteger currentCityId;
@property(nonatomic, strong) FHUGCPostMenuView *publishMenuView;

@end

@implementation FHNeighbourhoodCommentsController

- (instancetype)initWithRouteParamObj:(TTRouteParamObj *)paramObj {
    self = [super initWithRouteParamObj:paramObj];
    if (self) {
        
        _tableViewNeedPullDown = NO;
        _showErrorView = YES;
        
        NSDictionary *params = paramObj.allParams;
        self.title = [params objectForKey:@"title"];
        
        // 埋点
        self.tracerDict[@"page_type"] = @"neigborhood_comments_list";
        // 取链接中的埋点数据
        NSString *enterFrom = params[@"tracer"][@"enter_from"];
        if (enterFrom.length > 0) {
            self.tracerDict[@"enter_from"] = enterFrom;
        }
        NSString *elementFrom = params[@"tracer"][@"element_from"];
        if (elementFrom.length > 0) {
            self.tracerDict[@"element_from"] = elementFrom;
        }
        NSString *originFrom = params[@"tracer"][@"origin_from"];
        if (originFrom.length > 0) {
            self.tracerDict[@"origin_from"] = originFrom;
        }
        
        NSDictionary *logPb = params[@"tracer"][@"log_pb"];
        if (logPb) {
            self.tracerDict[@"log_pb"] = logPb;
        }
        
        self.neighborhoodId = params[@"neighborhood_id"];
        
        self.ttTrackStayEnable = YES;
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
    [self startLoadData];
    [self addGoDetailLog];
}

- (void)initNavbar {
    [self setupDefaultNavBar:NO];
    self.customNavBarView.title.text = self.title ?: @"小区点评";
}

- (void)initView {
    [self initTableView];
    [self initNotifyBarView];
    [self addDefaultEmptyViewFullScreen];
}

- (void)initTableView {
    self.tableView = [[FHBaseTableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    _tableView.backgroundColor = [UIColor themeGray7];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, CGFLOAT_MIN)];
    _tableView.tableHeaderView = headerView;
    
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, CGFLOAT_MIN)];
    _tableView.tableFooterView = footerView;
    
    _tableView.sectionFooterHeight = 0.0;
    
    _tableView.estimatedRowHeight = 0;
    
    if (@available(iOS 11.0 , *)) {
        _tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        _tableView.estimatedRowHeight = 0;
        _tableView.estimatedSectionFooterHeight = 0;
        _tableView.estimatedSectionHeaderHeight = 0;
    }
    
    if ([TTDeviceHelper isIPhoneXSeries]) {
        _tableView.contentInset = UIEdgeInsetsMake(0, 0, 34, 0);
    }
    
    [self.view addSubview:_tableView];
}

- (void)setTableHeaderView:(UIView *)tableHeaderView {
    _tableHeaderView = tableHeaderView;
    if(self.tableView){
        self.tableView.tableHeaderView = tableHeaderView;
    }
}

- (void)initNotifyBarView {
    self.notifyBarView = [[ArticleListNotifyBarView alloc]initWithFrame:CGRectZero];
    [self.view addSubview:self.notifyBarView];
}

- (void)initConstraints {
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        if (@available(iOS 11.0, *)) {
            make.top.mas_equalTo(self.mas_topLayoutGuide).offset(44);
        } else {
            make.top.mas_equalTo(64);
        }
        make.left.right.bottom.mas_equalTo(self.view);
    }];
    
    [self.notifyBarView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.mas_equalTo(self.tableView);
        make.height.mas_equalTo(32);
    }];
}

- (void)initViewModel {
    self.viewModel = [[FHNeighbourhoodCommentsViewModel alloc] initWithTableView:_tableView controller:self];
    self.needReloadData = YES;
    _viewModel.categoryId = @"f_neigh_review";
}

- (void)startLoadData {
    if ([TTReachability isNetworkConnected]) {
        [_viewModel requestData:YES first:YES];
    } else {
        if(!self.hasValidateData){
            [self.emptyView showEmptyWithType:FHEmptyMaskViewTypeNoNetWorkAndRefresh];
        }
    }
}

- (void)startLoadData:(BOOL)isFirst {
    if ([TTReachability isNetworkConnected]) {
        [_viewModel requestData:YES first:isFirst];
    } else {
        if(!self.hasValidateData){
            [self.emptyView showEmptyWithType:FHEmptyMaskViewTypeNoNetWorkAndRefresh];
        }
    }
}

- (void)retryLoadData {
    [self startLoadData];
}

#pragma mark - show notify

- (void)showNotify:(NSString *)message
{
    [self showNotify:message completion:nil];
}

- (void)showNotify:(NSString *)message completion:(void(^)(void))completion{
    UIEdgeInsets inset = self.tableView.contentInset;
    inset.top = self.notifyBarView.height;
    self.tableView.contentInset = inset;
    self.tableView.contentOffset = CGPointMake(0, -inset.top);
    self.notifyCompletionBlock = completion;
    WeakSelf;
    [self.notifyBarView showMessage:message actionButtonTitle:@"" delayHide:YES duration:1 bgButtonClickAction:nil actionButtonClickBlock:nil didHideBlock:nil willHideBlock:^(ArticleListNotifyBarView *barView, BOOL isImmediately) {
        WeakSelf;
        if(!isImmediately) {
            [wself hideIfNeeds];
        } else {
            if(wself.notifyCompletionBlock) {
                wself.notifyCompletionBlock();
            }
        }
    }];
}

- (void)hideIfNeeds {
    [UIView animateWithDuration:0.3 animations:^{
        
        if ([TTDeviceHelper isIPhoneXSeries]) {
            self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 34, 0);
        }else{
            self.tableView.contentInset = UIEdgeInsetsZero;
        }
        self.tableView.originContentInset = UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f);
        
    }completion:^(BOOL finished) {
        if (self.notifyCompletionBlock) {
            
            
            
            
            self.notifyCompletionBlock();
        }
    }];
}

- (void)hideImmediately {
    [self.notifyBarView hideImmediately];
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

#pragma mark - 埋点

- (void)addGoDetailLog {
    NSMutableDictionary *tracerDict = self.tracerDict.mutableCopy;
    tracerDict[@"group_id"] = self.neighborhoodId;
    TRACK_EVENT(@"go_detail", tracerDict);
}

- (void)addStayPageLog {
    NSTimeInterval duration = self.ttTrackStayTime * 1000.0;
    if (duration == 0) {
        return;
    }
    NSMutableDictionary *tracerDict = self.tracerDict.mutableCopy;
    tracerDict[@"group_id"] = self.neighborhoodId;
    tracerDict[@"stay_time"] = [NSNumber numberWithInteger:duration];
    TRACK_EVENT(@"stay_page", tracerDict);
    
    [self tt_resetStayTime];
}

@end
