//
//  FHUGCShortVideoListController.m
//  FHHouseUGC
//
//  Created by 谢思铭 on 2020/9/18.
//

#import "FHUGCShortVideoListController.h"
#import "UIColor+Theme.h"
#import "FHUGCShortVideoListViewModel.h"
#import "TTReachability.h"
#import "UIViewAdditions.h"
#import "TTRoute.h"
#import "TTAccountManager.h"
#import "FHEnvContext.h"
#import "FHUserTracker.h"
#import "UIScrollView+Refresh.h"
#import "FHFeedOperationView.h"
#import <FHHouseBase/FHBaseTableView.h>
#import "FHUGCConfig.h"
#import "ToastManager.h"
#import "FHFeedCustomHeaderView.h"
#import "UIDevice+BTDAdditions.h"
#import "FHUGCShortVideoFlowLayout.h"
#import "FHBaseCollectionView.h"

@interface FHUGCShortVideoListController ()<SSImpressionProtocol>

@property(nonatomic, strong) FHUGCShortVideoListViewModel *viewModel;
@property(nonatomic, copy) void(^notifyCompletionBlock)(void);
@property(nonatomic, assign) NSInteger currentCityId;
@property(nonatomic, assign) NSTimeInterval enterTabTimestamp;
@property(nonatomic, assign) UIEdgeInsets originContentInset;
@property(nonatomic, assign) BOOL alreadySetContentInset;

@property(nonatomic ,strong) FHBaseCollectionView *collectionView;
@property(nonatomic, strong) FHUGCShortVideoFlowLayout *flowLayout;

@end

@implementation FHUGCShortVideoListController

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
    self.startMonitorTime = [[NSDate date] timeIntervalSince1970];
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self initView];
    [self initViewModel];
    
    [[SSImpressionManager shareInstance] addRegist:self];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive) name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
}

- (void)setTracerDict:(NSMutableDictionary *)tracerDict {
    [super setTracerDict:tracerDict];
    if(self.dataList.count > 0){
        for (FHFeedUGCCellModel *cellModel in self.dataList) {
            NSMutableDictionary *tracerDic = [cellModel.tracerDic mutableCopy];
            if(tracerDict[@"origin_from"]){
                tracerDic[@"origin_from"] = tracerDict[@"origin_from"];
            }
            cellModel.tracerDic = tracerDic;
        }
    }
}

- (void)dealloc {
    [[SSImpressionManager shareInstance] removeRegist:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillAppear {
    [self.viewModel viewWillAppear];
    
    if ([[NSDate date]timeIntervalSince1970] - _enterTabTimestamp > 24*60*60) {
        //超过一天
        _enterTabTimestamp = [[NSDate date]timeIntervalSince1970];
    }
    
    [self addEnterCategoryLog];
    
//    if(self.viewModel.dataList.count > 0 || self.notLoadDataWhenEmpty){
//        if (self.needReloadData) {
//            self.needReloadData = NO;
//            [self scrollToTopAndRefreshAllData];
//        }
//    }else{
//        self.needReloadData = NO;
//        [self scrollToTopAndRefreshAllData];
//    }
    
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
    [self initCollectionView];
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

- (void)initCollectionView {
    self.flowLayout = [[FHUGCShortVideoFlowLayout alloc] init];
    _flowLayout.sectionInset = UIEdgeInsetsMake(0, 4, 0, 4);
    _flowLayout.minimumLineSpacing = 4;
    _flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    
    self.collectionView = [[FHBaseCollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:_flowLayout];
    _collectionView.showsHorizontalScrollIndicator = NO;
    _collectionView.backgroundColor = [UIColor whiteColor];
    
    [self.view addSubview:_collectionView];
    
    if ([UIDevice btd_isIPhoneXSeries]) {
        _collectionView.contentInset = UIEdgeInsetsMake(0, 0, 34, 0);
    }
    
//    [_collectionView registerClass:[FHUGCHotCommunitySubCell class] forCellWithReuseIdentifier:cellId];
}

//- (void)initTableView {
//    if(!_tableView){
//        self.tableView = [[FHBaseTableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
//        _tableView.backgroundColor = [UIColor themeGray7];
//        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
//
//        UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0.001)];
//        _tableView.tableHeaderView = headerView;
//
//        UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0.001)];
//        _tableView.tableFooterView = footerView;
//
//        _tableView.sectionFooterHeight = 0.0;
//
//        _tableView.estimatedRowHeight = 0;
//
//        if (@available(iOS 11.0 , *)) {
//            _tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
//            _tableView.estimatedRowHeight = 0;
//            _tableView.estimatedSectionFooterHeight = 0;
//            _tableView.estimatedSectionHeaderHeight = 0;
//        }
//
//        if ([UIDevice btd_isIPhoneXSeries]) {
//            _tableView.contentInset = UIEdgeInsetsMake(0, 0, 34, 0);
//        }
//
//        [self.view addSubview:_tableView];
//    }
//}

//- (void)setTableHeaderView:(UIView *)tableHeaderView {
//    _tableHeaderView = tableHeaderView;
//    if(self.tableView){
//        self.tableView.tableHeaderView = tableHeaderView;
//    }
//}

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
    self.collectionView.frame = self.view.bounds;
}

- (void)initViewModel {
    self.viewModel = [[FHUGCShortVideoListViewModel alloc] initWithCollectionView:self.collectionView controller:self];
    _viewModel.categoryId = @"f_hotsoon_video";
    [self startLoadData];
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

- (void)scrollToTopAndRefreshAllData {
    [self.collectionView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
    [self startLoadData];
}

- (void)scrollToTopAndRefresh {
    if(self.viewModel.isRefreshingTip || self.isLoadingData){
        return;
    }
    [self.collectionView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
    [self.collectionView triggerPullDown];
}

- (void)retryLoadData {
    [self startLoadData];
}

#pragma mark - show notify

- (void)showNotify:(NSString *)message {
    [self showNotify:message completion:nil];
}

- (void)showNotify:(NSString *)message completion:(void(^)(void))completion {
    if(!self.alreadySetContentInset){
        self.originContentInset = self.collectionView.contentInset;
        self.alreadySetContentInset = YES;
    }
    UIEdgeInsets inset = self.collectionView.contentInset;
    inset.top = self.notifyBarView.height;
    self.collectionView.contentInset = inset;
    self.collectionView.contentOffset = CGPointMake(0, -inset.top);
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
        self.collectionView.contentInset = self.originContentInset;
        self.collectionView.originContentInset = UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f);
        
    }completion:^(BOOL finished) {
        self.collectionView.originContentInset = self.originContentInset;
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

#pragma mark - SSImpressionProtocol

- (void)needRerecordImpressions {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.viewModel.dataList.count == 0) {
            return;
        }
        
        SSImpressionParams *params = [[SSImpressionParams alloc] init];
        params.refer = self.viewModel.refer;
        
        for (FHUGCBaseCell *cell in [self.collectionView visibleCells]) {
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
