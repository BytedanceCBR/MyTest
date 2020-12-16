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
#import "FHEnvContext.h"
#import "FHUserTracker.h"
#import "UIScrollView+Refresh.h"
#import "FHFeedOperationView.h"
#import <FHHouseBase/FHBaseTableView.h>
#import "FHUGCConfig.h"
#import "ToastManager.h"
#import "FHFeedCustomHeaderView.h"
#import "UIDevice+BTDAdditions.h"
#import "FHBaseCollectionView.h"
#import "UIViewController+Track.h"
#import "ExploreLogicSetting.h"
#import "FHFirstPageManager.h"

@interface FHUGCShortVideoListController ()<SSImpressionProtocol>

@property(nonatomic, strong) FHUGCShortVideoListViewModel *viewModel;
@property(nonatomic, copy) void(^notifyCompletionBlock)(void);
@property(nonatomic, assign) NSInteger currentCityId;
@property(nonatomic, assign) NSTimeInterval enterTabTimestamp;
@property(nonatomic, assign) UIEdgeInsets originContentInset;
@property(nonatomic, assign) BOOL alreadySetContentInset;
@property(nonatomic ,strong) FHBaseCollectionView *collectionView;

@end

@implementation FHUGCShortVideoListController

- (instancetype)init {
    self = [super init];
    if(self){
        _tableViewNeedPullDown = YES;
        _showErrorView = YES;
        _category = @"f_house_smallvideo";
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [[FHFirstPageManager sharedInstance] addFirstPageModelWithPageType:[self fh_pageType] withUrl:@"" withTabName:@"" withPriority:1];
    [[FHFirstPageManager sharedInstance] sendTrace]; //上报用户第一次感知的页面埋点
    // Do any additional setup after loading the view.
    self.startMonitorTime = [[NSDate date] timeIntervalSince1970];
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self initView];
    [self initViewModel];
    
    [[SSImpressionManager shareInstance] addRegist:self];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive) name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshData) name:kExploreMixedListRefreshTypeNotification object:nil];
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
    
    if(self.viewModel.dataList.count > 0 || self.notLoadDataWhenEmpty){
        if (self.needReloadData) {
            self.needReloadData = NO;
            [self scrollToTopAndRefreshAllData];
        }
    }else{
        self.needReloadData = NO;
        [self scrollToTopAndRefreshAllData];
    }
    
//    if (![FHEnvContext sharedInstance].isShowingHomeHouseFind) {
//        [self viewAppearForEnterType:1];
//    }
    [self addEnterCategoryLog];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
//    [self viewWillAppear];
}

- (void)viewWillDisappear {
    [self.viewModel viewWillDisappear];
//    if (![FHEnvContext sharedInstance].isShowingHomeHouseFind) {
//        [self viewDisAppearForEnterType:1];
//    }
    [self addStayCategoryLog];
    [FHFeedOperationView dismissIfVisible];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
//    [self viewWillDisappear];
}

- (void)initView {
    [self initCollectionView];
    [self initNotifyBarView];
    if(self.showErrorView){
        [self addDefaultEmptyViewFullScreen];
    }
}

- (void)initCollectionView {
    self.flowLayout = [[FHUGCShortVideoFlowLayout alloc] init];
    _flowLayout.sectionInset = UIEdgeInsetsMake(10, 15, 10, 15);
    _flowLayout.minimumLineSpacing = 12;
    _flowLayout.minimumInteritemSpacing = 9;
    _flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    
    self.collectionView = [[FHBaseCollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:_flowLayout];
    _collectionView.showsHorizontalScrollIndicator = NO;
    _collectionView.backgroundColor = [UIColor whiteColor];
    
    [self.view addSubview:_collectionView];
    
    if ([UIDevice btd_isIPhoneXSeries]) {
        _collectionView.contentInset = UIEdgeInsetsMake(0, 0, 34, 0);
    }
}

- (void)reloadData {
    self.flowLayout = [[FHUGCShortVideoFlowLayout alloc] init];
    _flowLayout.sectionInset = UIEdgeInsetsMake(10, 15, 10, 15);
    _flowLayout.minimumLineSpacing = 12;
    _flowLayout.minimumInteritemSpacing = 9;
    _flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    self.collectionView.collectionViewLayout = self.flowLayout;
    [self.collectionView reloadData];
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
    _viewModel.categoryId = self.category;
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

- (void)refreshData {
    if(![FHEnvContext sharedInstance].isShowingHomeHouseFind){
        [self scrollToTopAndRefresh];
    }
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
    CGPoint offset = self.collectionView.contentOffset;
    offset.y = 0;
    [self.collectionView setContentOffset:offset animated:NO];
    [self startLoadData];
}

- (void)scrollToTopAndRefresh {
    if(self.viewModel.isRefreshingTip || self.isLoadingData || self.dataList.count <= 0){
        return;
    }
    
    CGPoint offset = self.collectionView.contentOffset;
    offset.y = 0;
    [self.collectionView setContentOffset:offset animated:NO];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.collectionView triggerPullDown];
    });
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
    tracerDict[@"event_tracking_id"] = @"110838";
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
    tracerDict[@"event_tracking_id"] = @"110839";
    TRACK_EVENT(@"stay_category", tracerDict);
    
    self.enterTabTimestamp = [[NSDate date]timeIntervalSince1970];
}

- (void)viewAppearForEnterType:(NSInteger)enterType {
    self.enterTabTimestamp = [[NSDate date] timeIntervalSince1970];
    NSMutableDictionary *tracerDict = [NSMutableDictionary new];
    if (enterType == 1) {
        tracerDict[@"enter_type"] = @"click";
    }else{
        tracerDict[@"enter_type"] = @"flip";
    }
    tracerDict[@"enter_from"] = self.tracerDict[@"enter_from"] ?: @"be_null";
    tracerDict[@"category_name"] = self.tracerDict[@"category_name"] ?: @"be_null";
    [FHEnvContext recordEvent:tracerDict andEventKey:@"enter_category"];
    
//    [self addEnterCategoryLog:tracerDict[@"enter_type"]];
}

- (void)viewDisAppearForEnterType:(NSInteger)enterType
{
    NSMutableDictionary *tracerDict = [NSMutableDictionary new];
    NSTimeInterval duration = ([[NSDate date] timeIntervalSince1970] - self.enterTabTimestamp) * 1000.0;
    if (enterType == 1) {
        tracerDict[@"enter_type"] = @"click";
    }else{
        tracerDict[@"enter_type"] = @"flip";
    }
    tracerDict[@"enter_from"] = self.tracerDict[@"enter_from"] ?: @"be_null";
    tracerDict[@"category_name"] = self.tracerDict[@"category_name"] ?: @"be_null";
    tracerDict[@"stay_time"] = @((int) duration);

    if (((int) duration) > 0) {
        [FHEnvContext recordEvent:tracerDict andEventKey:@"stay_category"];
    }
    
//    [self addStayCategoryLog:tracerDict[@"enter_type"]];
}

- (NSString *)fh_pageType {
    return @"f_house_smallvideo";
}

@end
