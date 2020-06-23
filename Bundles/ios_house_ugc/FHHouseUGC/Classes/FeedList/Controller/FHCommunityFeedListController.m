//
//  FHCommunityFeedListController.m
//  FHHouseUGC
//
//  Created by 谢思铭 on 2019/6/2.
//

#import "FHCommunityFeedListController.h"
#import "UIColor+Theme.h"
#import "FHCommunityFeedListBaseViewModel.h"
#import "FHCommunityFeedListNearbyViewModel.h"
#import "FHCommunityFeedListMyJoinViewModel.h"
#import "FHCommunityFeedListPostDetailViewModel.h"
#import "FHCommunityFeedListCustomViewModel.h"
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
#import "FHFeedCustomHeaderView.h"

@interface FHCommunityFeedListController ()<SSImpressionProtocol>

@property(nonatomic, strong) FHCommunityFeedListBaseViewModel *viewModel;
@property(nonatomic, copy) void(^notifyCompletionBlock)(void);
@property(nonatomic, assign) NSInteger currentCityId;
@property(nonatomic, assign) NSTimeInterval enterTabTimestamp;
@property(nonatomic, assign) BOOL noNeedAddEnterCategorylog;

@end

@implementation FHCommunityFeedListController

- (instancetype)init {
    self = [super init];
    if(self){
        _tableViewNeedPullDown = YES;
        _showErrorView = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self initView];
//    [self initConstraints];
    [self initViewModel];
    
    [[SSImpressionManager shareInstance] addRegist:self];
    [TTAccount addMulticastDelegate:self];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive) name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
}

- (void)dealloc {
    [[SSImpressionManager shareInstance] removeRegist:self];
    [TTAccount removeMulticastDelegate:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillAppear {
    [self.viewModel viewWillAppear];
    
    if ([[NSDate date]timeIntervalSince1970] - _enterTabTimestamp > 24*60*60) {
        //超过一天
        _enterTabTimestamp = [[NSDate date]timeIntervalSince1970];
    }
    
    if(!self.noNeedAddEnterCategorylog){
        if(self.needReportEnterCategory){
            [self addEnterCategoryLog];
        }
    }else{
        self.noNeedAddEnterCategorylog = NO;
    }
    
    if(self.viewModel.dataList.count > 0 || self.notLoadDataWhenEmpty){
        if (self.needReloadData) {
            self.needReloadData = NO;
            [self scrollToTopAndRefreshAllData];
        }
    }else{
        self.needReloadData = NO;
        [self scrollToTopAndRefreshAllData];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
}

- (void)viewWillDisappear {
    [self.viewModel viewWillDisappear];
    if(self.needReportEnterCategory){
        [self addStayCategoryLog];
    }
    [FHFeedOperationView dismissIfVisible];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
}

- (void)initView {
    [self initTableView];
    [self initNotifyBarView];
    if(self.showErrorView){
        [self addDefaultEmptyViewFullScreen];
        if(self.errorViewTopOffset != 0){
            [self.emptyView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.left.right.bottom.mas_equalTo(self.view);
                make.top.mas_equalTo(self.view).offset(self.errorViewTopOffset);
            }];
        }
    }
}

- (void)initTableView {
    if(!_tableView){
        self.tableView = [[FHBaseTableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        _tableView.backgroundColor = [UIColor themeGray7];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        
        UIView *headerView = self.tableHeaderView ? self.tableHeaderView : [self customTableHeaderView];
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
        
        if ([TTDeviceHelper isIPhoneXDevice]) {
            _tableView.contentInset = UIEdgeInsetsMake(0, 0, 34, 0);
        }
        
        [self.view addSubview:_tableView];
    }
}

- (FHFeedCustomHeaderView *)customTableHeaderView {
    if(!_tableHeaderView){
        _headerViewHeight = 0.001f;
        FHFeedCustomHeaderView *tableHeaderView = [[FHFeedCustomHeaderView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, _headerViewHeight) addProgressView:self.isInsertFeedWhenPublish];
        if(self.isInsertFeedWhenPublish){
            WeakSelf;
            tableHeaderView.progressView.refreshViewBlk = ^{
                StrongSelf;
                [self.viewModel updateJoinProgressView];
            };
        }
        _tableHeaderView = tableHeaderView;
    }
    return _tableHeaderView;
}

- (void)setTableHeaderView:(UIView *)tableHeaderView {
    _tableHeaderView = tableHeaderView;
    if(self.tableView){
        self.tableView.tableHeaderView = tableHeaderView;
    }
}

- (void)setErrorViewTopOffset:(CGFloat)errorViewTopOffset {
    _errorViewTopOffset = errorViewTopOffset;
    
    [self.emptyView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.mas_equalTo(self.view);
        make.top.mas_equalTo(self.view).offset(errorViewTopOffset);
    }];
}

- (void)initNotifyBarView {
    self.notifyBarView = [[ArticleListNotifyBarView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 32)];
    [self.view addSubview:self.notifyBarView];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    self.tableView.frame = self.view.bounds;
}

//- (void)initConstraints {
//    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.edges.equalTo(self.view);
//    }];
//    
//    [self.notifyBarView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.left.right.mas_equalTo(self.tableView);
//        make.height.mas_equalTo(32);
//    }];
//}

- (void)initViewModel {
    FHCommunityFeedListBaseViewModel *viewModel = nil;

    if(self.listType == FHCommunityFeedListTypeNearby){
        viewModel = [[FHCommunityFeedListNearbyViewModel alloc] initWithTableView:_tableView controller:self];
        viewModel.categoryId = @"f_ugc_neighbor";
    }else if(self.listType == FHCommunityFeedListTypeMyJoin) {
        viewModel = [[FHCommunityFeedListMyJoinViewModel alloc] initWithTableView:_tableView controller:self];
        viewModel.categoryId = @"f_ugc_follow";
    }else if(self.listType == FHCommunityFeedListTypePostDetail) {
        FHCommunityFeedListPostDetailViewModel *postDetailViewModel = [[FHCommunityFeedListPostDetailViewModel alloc] initWithTableView:_tableView controller:self];
        postDetailViewModel.socialGroupId = self.forumId;
        postDetailViewModel.tabName = self.tabName;
        postDetailViewModel.categoryId = @"f_project_social";
        viewModel = postDetailViewModel;
    }else if(self.listType == FHCommunityFeedListTypeCustom) {
        viewModel = [[FHCommunityFeedListCustomViewModel alloc] initWithTableView:_tableView controller:self];
        viewModel.categoryId = self.category;
    }
    
    self.viewModel = viewModel;
    self.needReloadData = YES;
    //切换开关
    WeakSelf;
    [[FHEnvContext sharedInstance].configDataReplay subscribeNext:^(id  _Nullable x) {
        StrongSelf;
        NSInteger cityId = [[FHEnvContext getCurrentSelectCityIdFromLocal] integerValue];
        if(self.currentCityId != cityId){
            self.needReloadData = YES;
            self.currentCityId = cityId;
        }
    }];
}

- (void)startLoadData {
    if ([TTReachability isNetworkConnected]) {
        [_viewModel requestData:YES first:YES];
    } else {
        if(!self.hasValidateData){
            if(!self.showErrorView && self.errorViewHeight > 0){
                [self.viewModel showCustomErrorView:FHEmptyMaskViewTypeNoNetWorkAndRefresh];
            }else{
                [self.emptyView showEmptyWithType:FHEmptyMaskViewTypeNoNetWorkAndRefresh];
            }
        }
    }
}

- (void)startLoadData:(BOOL)isFirst {
    if ([TTReachability isNetworkConnected]) {
        [_viewModel requestData:YES first:isFirst];
    } else {
        if(!self.hasValidateData){
            if(!self.showErrorView && self.errorViewHeight > 0){
                [self.viewModel showCustomErrorView:FHEmptyMaskViewTypeNoNetWorkAndRefresh];
            }else{
                [self.emptyView showEmptyWithType:FHEmptyMaskViewTypeNoNetWorkAndRefresh];
            }
        }
    }
}

- (void)scrollToTopAndRefreshAllData {
    [self.tableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO]; 
    [self startLoadData];
}

- (void)scrollToTopAndRefresh {
    if(self.viewModel.isRefreshingTip || self.isLoadingData){
        return;
    }
    [self.tableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
    [self.tableView triggerPullDown];
}

- (void)retryLoadData {
    [self startLoadData];
}

#pragma mark - show notify

- (void)showNotify:(NSString *)message {
    [self showNotify:message completion:nil];
}

- (void)showNotify:(NSString *)message completion:(void(^)())completion {
    UIEdgeInsets inset = self.tableView.contentInset;
    inset.top = self.notifyBarView.height;
    self.tableView.contentInset = inset;
    self.tableView.contentOffset = CGPointMake(0, -inset.top);
    self.notifyCompletionBlock = completion;
    WeakSelf;
    [self.notifyBarView showMessage:message actionButtonTitle:@"" delayHide:YES duration:1 bgButtonClickAction:nil actionButtonClickBlock:nil didHideBlock:nil willHideBlock:^(ArticleListNotifyBarView *barView, BOOL isImmediately) {
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
        if ([TTDeviceHelper isIPhoneXDevice]) {
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

- (NSArray *)dataList {
    return self.viewModel.dataList;
}

- (void)applicationDidEnterBackground {
    if(self.needReportEnterCategory){
        [self addStayCategoryLog];
    }
}

- (void)applicationDidBecomeActive {
    self.enterTabTimestamp = [[NSDate date]timeIntervalSince1970];
}

#pragma mark - TTAccountMulticaastProtocol

// 帐号切换
- (void)onAccountStatusChanged:(TTAccountStatusChangedReasonType)reasonType platform:(NSString *)platformName {
    if(self.listType == FHCommunityFeedListTypeNearby || self.listType == FHCommunityFeedListTypeMyJoin) {
        self.needReloadData = YES;
    }
}

#pragma mark - SSImpressionProtocol

- (void)needRerecordImpressions {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.viewModel.dataList.count == 0) {
            return;
        }
        
        SSImpressionParams *params = [[SSImpressionParams alloc] init];
        params.refer = self.viewModel.refer;
        
        for (FHUGCBaseCell *cell in [self.tableView visibleCells]) {
            if ([cell isKindOfClass:[FHUGCBaseCell class]]) {
                id data = cell.currentData;
                if ([data isKindOfClass:[FHFeedUGCCellModel class]]) {
                    FHFeedUGCCellModel *cellModel = (FHFeedUGCCellModel *)data;
                    if (self.viewModel.isShowing) {
                        [self.viewModel recordGroupWithCellModel:cellModel status:SSImpressionStatusRecording];
                    }
                    else {
                        [self.viewModel recordGroupWithCellModel:cellModel status:SSImpressionStatusSuspend];
                    }
                }
            }
        }
    });
    
}

#pragma mark - 埋点

- (void)addEnterCategoryLog {
    NSMutableDictionary *tracerDict = self.tracerDict.mutableCopy;
    tracerDict[@"category_name"] = self.category;
    TRACK_EVENT(@"enter_category", tracerDict);
    
    self.enterTabTimestamp = [[NSDate date] timeIntervalSince1970];
}

- (void)addStayCategoryLog {
    NSTimeInterval duration = [[NSDate date] timeIntervalSince1970] - _enterTabTimestamp;
    if (duration <= 0 || duration >= 24*60*60) {
        return;
    }
    NSMutableDictionary *tracerDict = self.tracerDict.mutableCopy;
    tracerDict[@"category_name"] = self.category;
    tracerDict[@"stay_time"] = [NSNumber numberWithInteger:(duration * 1000)];
    TRACK_EVENT(@"stay_category", tracerDict);
    
    self.enterTabTimestamp = [[NSDate date]timeIntervalSince1970];
}

@end
