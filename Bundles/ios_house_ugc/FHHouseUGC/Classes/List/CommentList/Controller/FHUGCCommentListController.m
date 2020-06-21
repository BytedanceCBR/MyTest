//
//  FHUGCCommentListController.m
//  FHHouseUGC
//
//  Created by 谢思铭 on 2019/10/11.
//

#import "FHUGCCommentListController.h"
#import "UIColor+Theme.h"
#import "FHUGCCommentListViewModel.h"
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
#import "FHUserTracker.h"
#import "UIViewController+Track.h"
#import "TTAccountManager.h"

@interface FHUGCCommentListController ()

@property(nonatomic, strong) FHUGCCommentListViewModel *viewModel;
@property(nonatomic, assign) BOOL needReloadData;
@property(nonatomic, copy) void(^notifyCompletionBlock)(void);

@property (nonatomic, strong) NSString *userId;//用户id

@end

@implementation FHUGCCommentListController

- (instancetype)initWithRouteParamObj:(TTRouteParamObj *)paramObj {
    self = [super initWithRouteParamObj:paramObj];
    if (self) {
        
        _tableViewNeedPullDown = YES;
        _showErrorView = YES;

        NSDictionary *params = paramObj.allParams;
        self.userId = [params objectForKey:@"uid"];
    
        // 埋点
        self.tracerDict[@"page_type"] = @"personal_comment_list";
        // 取链接中的埋点数据
        NSString *enterFrom = params[@"enter_from"];
        if (enterFrom.length > 0) {
            self.tracerDict[@"enter_from"] = enterFrom;
        }

        self.tracerDict[@"enter_type"] = @"click";

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

- (void)dealloc {
    
}

- (void)initNavbar {
    [self setupDefaultNavBar:NO];
    self.customNavBarView.title.text = [[TTAccountManager userID] isEqualToString:self.userId] ? @"我的评论" : @"TA的评论";
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
    
    UIView *headerView = self.tableHeaderView ? self.tableHeaderView : [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0.001)];
    _tableView.tableHeaderView = headerView;
    
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0.001)];
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
    
    [self.publishBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.view).offset(-self.publishBtnBottomHeight);
        make.right.mas_equalTo(self.view).offset(-12);
        make.width.height.mas_equalTo(64);
    }];
}

- (void)initViewModel {
    self.viewModel = [[FHUGCCommentListViewModel alloc] initWithTableView:_tableView controller:self];
    self.needReloadData = YES;
    _viewModel.categoryId = @"f_project_social";
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
    TRACK_EVENT(@"go_detail", tracerDict);
}

- (void)addStayPageLog {
    NSTimeInterval duration = self.ttTrackStayTime * 1000.0;
    if (duration == 0) {
        return;
    }
    NSMutableDictionary *tracerDict = self.tracerDict.mutableCopy;
    tracerDict[@"stay_time"] = [NSNumber numberWithInteger:duration];
    TRACK_EVENT(@"stay_page", tracerDict);

    [self tt_resetStayTime];
}

@end

