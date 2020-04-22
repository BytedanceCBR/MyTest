//
//  FHHomeItemViewController.m
//  AKCommentPlugin
//
//  Created by 谢飞 on 2019/6/12.
//

#import "FHHomeItemViewController.h"
#import "FHRefreshCustomFooter.h"
#import "TTBaseMacro.h"
#import "FHEnvContext.h"
#import "ToastManager.h"
#import "UIScrollView+Refresh.h"
#import "TTHttpTask.h"
#import "FHHomeRequestAPI.h"
#import "FHHomePlaceHolderCell.h"
#import "FHhomeHouseTypeBannerCell.h"
#import "TTDeviceHelper.h"
#import "FHHouseBaseItemCell.h"
#import "FHHomeCellHelper.h"
#import "FHPlaceHolderCell.h"
#import "FHHomeListViewModel.h"
#import "TTSandBoxHelper.h"
#import <FHHomeSearchPanelViewModel.h>
#import <FHHouseBase/FHSearchChannelTypes.h>
#import <FHHouseBase/TTDeviceHelper+FHHouse.h>
#import "FHUserTracker.h"
#import <FHHouseBase/FHBaseTableView.h>
#import "FHHouseBaseNewHouseCell.h"
#import "FHPlaceHolderCell.h"
#import "UIColor+Theme.h"
#import "FHHomeMainViewModel.h"
#import <FHHouseBase/FHRelevantDurationTracker.h>
#import "FHHouseListBaseItemCell.h"

extern NSString *const INSTANT_DATA_KEY;

static NSString const * kCellSmallItemImageId = @"FHHomeSmallImageItemCell";
static NSString const * kCellNewHouseItemImageId = @"FHHouseBaseNewHouseCell";
static NSString const * kCellRentHouseItemImageId = @"FHHomeRentHouseItemCell";

@interface FHHomeItemViewController ()<UITableViewDataSource,UITableViewDelegate,FHHouseBaseItemCellDelegate>

@property (nonatomic , strong) FHRefreshCustomFooter *refreshFooter;
@property (nonatomic , assign) NSInteger itemCount;
@property (nonatomic , assign) FHHomePullTriggerType currentPullType;
@property (nonatomic, strong) TTHttpTask * requestTask;
@property (nonatomic, strong) NSString *currentSearchId;
@property (nonatomic, strong) NSMutableArray *houseDataItemsModel;
@property (nonatomic, assign) BOOL isRetryedPullDownRefresh;
@property (nonatomic, assign) BOOL hasMore;
@property (nonatomic, strong) NSString *originSearchId;
@property (nonatomic, assign) NSTimeInterval stayTime; //页面停留时间
@property (nonatomic, strong) NSMutableDictionary *traceRecordDict;
@property (nonatomic, assign) BOOL isOriginRequest;
@property (nonatomic, assign) BOOL isDisAppeared;
@property (nonatomic, weak) FHHomeListViewModel *listModel;
@property (nonatomic, assign) NSInteger lastOffset;
@end

@implementation FHHomeItemViewController

- (instancetype)initItemWith:(FHHomeListViewModel *)listModel
{
    self = [super init];
    if (self) {
        _listModel = listModel;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.houseDataItemsModel = [NSMutableArray new];
    self.isRetryedPullDownRefresh = NO;
    self.hasMore = YES;
    self.isOriginRequest = YES;
    self.isDisAppeared = NO;
    self.traceNeedUploadCache = [NSMutableArray new];
    self.traceEnterCategoryCache = [NSMutableDictionary new];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pageTitleViewToTop) name:@"headerViewToTop" object:nil];
    
    [self.view addSubview:self.tableView];
    self.traceRecordDict = [NSMutableDictionary new];
    
    [FHHomeCellHelper registerCells:self.tableView];
    
    _itemCount = 20;
    
    WeakSelf;
    self.refreshFooter = [FHRefreshCustomFooter footerWithRefreshingBlock:^{
        StrongSelf;
        if ([FHEnvContext isNetworkConnected]) {
            [self requestDataForRefresh:FHHomePullTriggerTypePullUp andIsFirst:NO];
        }else
        {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.tableView finishPullUpWithSuccess:YES];
                });
            });
            [self.tableView.mj_footer endRefreshing];
            [[ToastManager manager] showToast:@"网络异常"];
        }
    }];
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    self.tableView.mj_footer = self.refreshFooter;
    
    [self.refreshFooter setUpWhiteBackGroud];
    
    [self.refreshFooter setBackgroundColor:[UIColor themeHomeColor]];
    [self.tableView setBackgroundColor:[UIColor themeHomeColor]];
    
    [self registerCells];
    
    [self requestDataForRefresh:FHHomePullTriggerTypePullDown andIsFirst:YES];
    
    self.tableView.scrollsToTop = NO;
    
}

- (void)initNotifications {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enterCategoryWithEnterType:) name:@"FHHomeItemVCEnterCategory" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stayCategoryWithEnterType:) name:@"FHHomeItemVCStayCategory" object:nil];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
}

#pragma mark  埋点
- (void)applicationDidEnterBackground:(NSNotification *)notification {
    if (self.houseType == FHHouseTypeSecondHandHouse) {
      
    }
}

- (void)applicationWillEnterForeground:(NSNotification *)notification {
    if (self.houseType == FHHouseTypeSecondHandHouse) {
        [self resumeVRIcon];
    }
}

- (void)removeNotifications
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)enterCategoryWithEnterType:(NSNotification *)notify
{
    self.traceEnterTopTabache = [NSMutableDictionary new];

    if ([notify.object isKindOfClass:[NSNumber class]] && [(NSNumber *)notify.object integerValue] == FHHomeMainTraceEnterTypeClick) {
        [self.traceEnterCategoryCache setValue:@"click" forKey:@"enter_type"];
        [self.traceEnterTopTabache setValue:@"click" forKey:@"enter_type"];
    }else
    {
        [self.traceEnterCategoryCache setValue:@"flip" forKey:@"enter_type"];
        [self.traceEnterTopTabache setValue:@"flip" forKey:@"enter_type"];
    }
    
    self.stayTime = [self getCurrentTime];
    [FHEnvContext recordEvent:self.traceEnterCategoryCache andEventKey:@"enter_category"];
    
    [self.traceEnterTopTabache setValue:@"maintab" forKey:@"enter_from"];
    [self.traceEnterTopTabache setValue:@"f_find_house" forKey:@"category_name"];
    [FHEnvContext recordEvent:self.traceEnterTopTabache andEventKey:@"enter_category"];
}

- (void)stayCategoryWithEnterType:(NSNotification *)notify
{
    if (self.houseType == _listModel.houseType) {
        [self currentViewIsDisappeared];
        
        NSMutableDictionary *stayTabParams = [NSMutableDictionary new];
        if (self.traceEnterTopTabache) {
            [stayTabParams addEntriesFromDictionary:self.traceEnterTopTabache];
        }else
        {
            [stayTabParams setValue:@"click" forKey:@"enter_type"];
            [stayTabParams setValue:@"maintab" forKey:@"enter_from"];
            [stayTabParams setValue:@"f_find_house" forKey:@"category_name"];

        }
        NSTimeInterval duration = ([self getCurrentTime] - self.stayTime) * 1000.0;
        if (duration) {
            [stayTabParams setValue:@((int)duration) forKey:@"stay_time"];
        }
        
//        if ([enterType isKindOfClass:[NSNumber class]] && [(NSNumber *)enterType integerValue] == FHHomeMainTraceEnterTypeFlip) {
//            [stayTabParams setValue:@"click" forKey:@"enter_type"];
//
//        }else
//        {
//            [stayTabParams setValue:@"flip" forKey:@"enter_type"];
//        }
        [FHEnvContext recordEvent:stayTabParams andEventKey:@"stay_category"];
    }
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.stayTime = [self getCurrentTime];
    
    //进入其他页面，返回上报
    if (self.isDisAppeared && self.houseType == _listModel.houseType) {
        if (self.traceEnterCategoryCache.allKeys.count > 0 && self.isOriginShowSelf) {
            [self.traceEnterCategoryCache setValue:@"click" forKey:@"enter_type"];
            [FHEnvContext recordEvent:self.traceEnterCategoryCache andEventKey:@"enter_category"];
        }
    }
    
    [self resumeVRIcon];
}

- (void)resumeVRIcon{
    if (self.houseType == FHHouseTypeSecondHandHouse) {
        NSArray *tableCells = [self.tableView visibleCells];
        if (tableCells) {
            [tableCells enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if ([obj respondsToSelector:@selector(resumeVRIcon)]) {
                    [obj performSelector:@selector(resumeVRIcon)];
                }
            }];
        }
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    if (self.houseType == _listModel.houseType && [FHEnvContext sharedInstance].isShowingHomeHouseFind) {
        [self currentViewIsDisappeared];
    }
    self.isDisAppeared = YES;
}

- (void)currentViewIsShowing
{
    [self.traceEnterCategoryCache setValue:self.enterType forKey:@"enter_type"];
    
    if (self.traceEnterCategoryCache.allKeys.count > 0) {
        if (self.traceEnterCategoryCache && self.traceEnterCategoryCache[@"category_name"]) {
            [FHEnvContext recordEvent:self.traceEnterCategoryCache andEventKey:@"enter_category"];
        }
    }
    
    if (self.showRequestErrorView) {
        [self showPlaceHolderCells];
        [self requestDataForRefresh:FHHomePullTriggerTypePullDown andIsFirst:YES];
        if (self.panelVM) {
            [self.panelVM fetchSearchPanelRollData];
        }
    }
    
    self.stayTime = [self getCurrentTime];
    
    [self uploadFirstScreenHouseShow];
    
    if (self.traceRecordDict && self.houseType == _listModel.houseType && !self.traceRecordDict[@(self.houseType)]) {
        [self.traceRecordDict setValue:@"" forKey:@(self.houseType)];
        [FHHomeCellHelper sendBannerTypeCellShowTrace:_houseType];
    }
}

- (void)currentViewIsDisappeared
{
    [self sendTraceEvent:FHHomeCategoryTraceTypeStay];
}

- (void)registerCells
{
    [self.tableView registerClass:[FHHouseBaseItemCell class] forCellReuseIdentifier:kCellSmallItemImageId];

    [self.tableView registerClass:[FHHouseBaseItemCell class] forCellReuseIdentifier:kCellRentHouseItemImageId];
    
    [self.tableView registerClass:[FHHouseBaseNewHouseCell class] forCellReuseIdentifier:kCellNewHouseItemImageId];

    [self.tableView  registerClass:[FHHomePlaceHolderCell class] forCellReuseIdentifier:NSStringFromClass([FHHomePlaceHolderCell class])];
    
    [self.tableView  registerClass:[FHHomeBaseTableCell class] forCellReuseIdentifier:NSStringFromClass([FHHomeBaseTableCell class])];
    
    [self.tableView  registerClass:[FHhomeHouseTypeBannerCell class] forCellReuseIdentifier:NSStringFromClass([FHhomeHouseTypeBannerCell class])];
    
    [self.tableView registerClass:[FHPlaceHolderCell class] forCellReuseIdentifier:NSStringFromClass([FHPlaceHolderCell class])];
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:NSStringFromClass([UITableViewCell class])];
}

//判断是否有运营位
- (BOOL)checkIsHaveEntrancesList
{
    FHConfigDataModel *dataModel = [[FHEnvContext sharedInstance] getConfigFromCache];
    
    BOOL isShowHouseBanner = NO;
    
    for (NSInteger i = 0; i < dataModel.opData2list.count; i ++) {
        FHConfigDataOpData2ListModel *dataModelItem = dataModel.opData2list[i];
        if (dataModelItem.opData2Type && [dataModelItem.opData2Type integerValue] == self.houseType && dataModelItem.opDataList && dataModelItem.opDataList.items.count > 0) {
            isShowHouseBanner = YES;
        }
    }
    
    return isShowHouseBanner;
}

- (void)pageTitleViewToTop {
    self.tableView.contentOffset = CGPointZero;
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.tableView.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [[FHHomeCellHelper sharedInstance] heightForFHHomeListHouseSectionHeight]);
}

#pragma mark 刷新列表

- (void)showPlaceHolderCells
{
    self.showNoDataErrorView = NO;
    self.showRequestErrorView = NO;
    self.showDislikeNoDataView = NO;
    self.showPlaceHolder = YES;
    [self.tableView reloadData];
}
//城市开通，且无房源时显示error页
- (void)reloadCityEnbaleAndNoHouseData:(BOOL)isNoData
{
    self.tableView.hasMore = NO;
    self.tableView.mj_footer.hidden = YES;
    [self.refreshFooter setUpNoMoreDataText:@"" offsetY:3];
    [self.tableView.mj_footer endRefreshingWithNoMoreData];
    self.showNoDataErrorView = isNoData;
    self.showRequestErrorView = !isNoData;
    self.showDislikeNoDataView = NO;
    self.showPlaceHolder = NO;
    [self.tableView reloadData];
}

//重载当前请求下发的数据
- (void)reloadHomeTableHouseSection
{
    self.showNoDataErrorView = NO;
    self.showRequestErrorView = NO;
    self.showDislikeNoDataView = NO;
    self.showPlaceHolder = NO;
    [self.tableView reloadData];
}


- (void)checkCityStatus
{
    [self reloadCityEnbaleAndNoHouseData:[[FHEnvContext sharedInstance] getConfigFromCache].cityAvailability.enable.boolValue];
}

- (void)updateTableViewWithMoreData:(BOOL)hasMore {
    self.tableView.mj_footer.hidden = NO;
    if (hasMore == NO) {
        [self.refreshFooter setUpNoMoreDataText:@"没有更多信息了" offsetY:0];
        [self.tableView.mj_footer endRefreshingWithNoMoreData];
    }else {
        [self.tableView.mj_footer endRefreshing];
    }
    
//    if (self.houseDataItemsModel.count < 10 && !self.tableView.hasMore) {
//        self.tableView.mj_footer.hidden = YES;
//    }
    
}

#pragma mark 网络请求
//请求推荐刷新数据，包括上拉和下拉
- (void)requestDataForRefresh:(FHHomePullTriggerType)pullType andIsFirst:(BOOL)isFirst
{
    self.currentPullType = pullType;
    
    if (isFirst) {
        [self showPlaceHolderCells];
    }
    
    if (pullType == FHHomePullTriggerTypePullDown) {
        self.traceRecordDict = [NSMutableDictionary new];
    }
    
    NSMutableDictionary *requestDictonary = [NSMutableDictionary new];
    [requestDictonary setValue:[FHEnvContext getCurrentSelectCityIdFromLocal] forKey:@"city_id"];
    NSInteger offsetValue = self.lastOffset;

    if (isFirst || pullType == FHHomePullTriggerTypePullDown) {
        [requestDictonary setValue:@(0) forKey:@"offset"];
    }else
    {
        if(self.currentSearchId)
        {
            [requestDictonary setValue:self.currentSearchId forKey:@"search_id"];
        }
        
        [requestDictonary setValue:@(offsetValue) forKey:@"offset"];
    }
    [requestDictonary setValue:@(self.houseType) forKey:@"house_type"];
    [requestDictonary setValue:@(self.itemCount) forKey:@"count"];
    
    if (self.houseType == FHHouseTypeNewHouse) {
        requestDictonary[CHANNEL_ID] = CHANNEL_ID_RECOMMEND_COURT;
    } else if (self.houseType == FHHouseTypeSecondHandHouse) {
        requestDictonary[CHANNEL_ID] = CHANNEL_ID_RECOMMEND;
    } else if (self.houseType == FHHouseTypeRentHouse) {
        requestDictonary[CHANNEL_ID] = CHANNEL_ID_RECOMMEND_RENT;
    }

    self.requestTask = nil;
    
    WeakSelf;
    self.requestTask = [FHHomeRequestAPI requestRecommendForLoadMore:requestDictonary completion:^(FHHomeHouseModel * _Nonnull model, NSError * _Nonnull error) {
        StrongSelf;
        
        [self.tableView finishPullUpWithSuccess:YES];
        
        //判断下拉刷新
        if (pullType == FHHomePullTriggerTypePullDown) {
            //请求无错误,无错误
            if (model.data.items.count == 0 && !error) {
                [self checkCityStatus];
                if (self.requestCallBack) {
                    self.requestCallBack(pullType, self.houseType, NO, nil);
                }
                return;
            }
            
            if ((error && [error.userInfo[@"NSLocalizedDescription"] isKindOfClass:[NSString class]] && ![error.userInfo[@"NSLocalizedDescription"] isEqualToString:@"the request was cancelled"]) || !model || error) {
                [self reloadCityEnbaleAndNoHouseData:NO];
                if (self.requestCallBack) {
                    self.requestCallBack(pullType, self.houseType, NO, nil);
                }
                return ;
            }
        }else
        {
            if (error) {
                if ([error.userInfo[@"NSLocalizedDescription"] isKindOfClass:[NSString class]] && ![error.userInfo[@"NSLocalizedDescription"] isEqualToString:@"the request was cancelled"]) {
                    [[ToastManager manager] showToast:@"网络异常"];
                }
                [self updateTableViewWithMoreData:YES];
                return;
            }
        }
        
        self.isRetryedPullDownRefresh = NO;
        
        if (pullType == FHHomePullTriggerTypePullDown) {
            self.originSearchId = model.data.searchId;
            self.houseDataItemsModel = [NSMutableArray arrayWithArray:model.data.items];
            self.lastOffset = model.data.items.count;
        }else
        {
            if (model.data.items && self.houseDataItemsModel && model.data.items.count != 0) {
                [self.houseDataItemsModel addObjectsFromArray:model.data.items];
                self.lastOffset += model.data.items.count;
            }
        }
        self.currentSearchId = model.data.searchId;
        
        [self reloadHomeTableHouseSection];
        
        self.tableView.hasMore = model.data.hasMore;
        [self updateTableViewWithMoreData:model.data.hasMore];
        
        
        if (self.isOriginRequest || [FHEnvContext sharedInstance].isRefreshFromCitySwitch || [FHEnvContext sharedInstance].isRefreshFromAlertCitySwitch) {
            [self sendTraceEvent:FHHomeCategoryTraceTypeEnter];
        }else
        {
            [self sendTraceEvent:FHHomeCategoryTraceTypeRefresh];
        }
        
        
        if (self.requestCallBack) {
            self.requestCallBack(pullType, self.houseType, YES, model);
        }
        
        self.isOriginRequest = NO;
    }];
}

#pragma mark 埋点

-(NSString *)pageTypeString {
    switch (self.houseType) {
        case FHHouseTypeNewHouse:
            return @"new_list";
            break;
        case FHHouseTypeSecondHandHouse:
            return @"old_list";
            break;
        case FHHouseTypeRentHouse:
            return @"rent_list";
            break;
        case FHHouseTypeNeighborhood:
            return @"neighborhood_list";
            break;
        default:
            return @"be_null";
            break;
    }
}


-(NSString *)houseTypeString {
    switch (self.houseType) {
        case FHHouseTypeNewHouse:
            return @"new";
            break;
        case FHHouseTypeSecondHandHouse:
            return @"old";
            break;
        case FHHouseTypeRentHouse:
            return @"rent";
            break;
        default:
            return @"be_null";
            break;
    }
}

- (void)uploadFirstScreenHouseShow
{
    for (NSMutableDictionary *houseShowTrace in self.traceNeedUploadCache) {
        [FHEnvContext recordEvent:houseShowTrace andEventKey:@"house_show"];
    }
    
    if (self.traceNeedUploadCache.count > 0) {
        [self.traceNeedUploadCache removeAllObjects];
        self.isOriginShowSelf = YES;
    }
}

- (NSTimeInterval)getCurrentTime
{
    return  [[NSDate date] timeIntervalSince1970];
}

- (void)sendTraceEvent:(FHHomeCategoryTraceType)traceType
{
    //如果首页没有显示
    if (![FHEnvContext sharedInstance].isShowingHomeHouseFind) {
        return;
    }
    
    NSMutableDictionary *tracerDict = [NSMutableDictionary new];
    self.tracerModel.enterFrom = @"maintab";
    self.tracerModel.elementFrom = @"maintab_list";
    
    tracerDict[@"category_name"] = [self pageTypeString] ? : @"be_null";
    tracerDict[@"enter_from"] = @"maintab";
    tracerDict[@"enter_type"] = self.enterType ? : @"click";
    tracerDict[@"element_from"] = @"maintab_list";
    tracerDict[@"search_id"] = self.currentSearchId ? : @"be_null";
    tracerDict[@"origin_from"] = [self pageTypeString]  ? : @"be_null";
    tracerDict[@"origin_search_id"] = self.currentSearchId ? :@"be_null";
    
    
    if (traceType == FHHomeCategoryTraceTypeEnter) {
        if (self.isOriginShowSelf) {
            tracerDict[@"enter_type"] = @"click";
            [FHEnvContext recordEvent:tracerDict andEventKey:@"enter_category"];
        }
        
        self.traceEnterCategoryCache = tracerDict;
    }else if (traceType == FHHomeCategoryTraceTypeStay)
    {
        NSTimeInterval duration = ([self getCurrentTime] - self.stayTime) * 1000.0;
        if (duration) {
            [tracerDict setValue:@((int)duration) forKey:@"stay_time"];
        }
        [FHEnvContext recordEvent:tracerDict andEventKey:@"stay_category"];
    }else if (traceType == FHHomeCategoryTraceTypeRefresh)
    {
        NSString *stringReloadType = @"pull";
        if (self.reloadType == TTReloadTypeTab) {
            stringReloadType = @"tab";
        }
        if (self.reloadType == TTReloadTypeClickCategory) {
            stringReloadType = @"click";
        }
        tracerDict[@"refresh_type"] = (self.currentPullType == FHHomePullTriggerTypePullUp ? @"pre_load_more" :  stringReloadType);
        [FHEnvContext recordEvent:tracerDict andEventKey:@"category_refresh"];
        
        self.reloadType = nil;
    }
}

#pragma mark 计算高度

- (CGFloat)getHeightShowNoData
{
    if([TTDeviceHelper isScreenWidthLarge320])
    {
        return [UIScreen mainScreen].bounds.size.height * 0.45;
    }else
    {
        return [UIScreen mainScreen].bounds.size.height * 0.65;
    }
}

#pragma mark tableview等回调

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if (self.scrollDidBegin) {
        self.scrollDidBegin();
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"FHHomeMainDidScrollBegin" object:nil];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    // 滚动时发出通知
//    [[NSNotificationCenter defaultCenter] postNotificationName:@"FHHomeSubTableViewDidScroll" object:scrollView];
    if (self.scrollDidScrollCallBack) {
        self.scrollDidScrollCallBack(scrollView);
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (self.scrollDidEnd) {
        self.scrollDidEnd();
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"FHHomeMainDidScrollEnd" object:nil];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (self.scrollDidEnd) {
        self.scrollDidEnd();
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"FHHomeMainDidScrollEnd" object:nil];
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"FHHomeMainDidScrollEnd" object:nil];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 1;
    }
    
    if (self.showNoDataErrorView || self.showRequestErrorView || self.showDislikeNoDataView) {
        return 1;
    }
    
    if (self.showPlaceHolder) {
        return 10;
    }
    return self.houseDataItemsModel.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        if ([self checkIsHaveEntrancesList]) {
            //适配5s
            if ([TTDeviceHelper isScreenWidthLarge320]) {
                return 105;
            }else{
                return 85;
            }
        }
        return 12;
    }else
    {
        if (self.showNoDataErrorView || self.showRequestErrorView || self.showDislikeNoDataView) {
            return [self getHeightShowNoData];
        }
        
        if (self.houseType == FHHouseTypeNewHouse) {
            if (indexPath.row < self.houseDataItemsModel.count) {
                JSONModel *model = self.houseDataItemsModel[indexPath.row];
                return [FHHouseBaseNewHouseCell heightForData:model];
            }
        }
        
        if (self.showPlaceHolder && self.houseType == FHHouseTypeNewHouse) {
            return 118;
        }
        
        return kFHHomeHouseItemHeight;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    if(indexPath.section == kFHHomeHouseTypeBannerViewSection)
    {
        if ([self checkIsHaveEntrancesList]) {
            FHhomeHouseTypeBannerCell *bannerCell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([FHhomeHouseTypeBannerCell class])];
            [bannerCell refreshData:self.houseType];
            [bannerCell.contentView setBackgroundColor:[UIColor themeHomeColor]];
            bannerCell.selectionStyle = UITableViewCellSelectionStyleNone;
            return bannerCell;
        }else
        {
            UITableViewCell *cellMargin = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([UITableViewCell class])];
            for (UIView *subView in cellMargin.contentView.subviews) {
                [subView removeFromSuperview];
            }
            [cellMargin setBackgroundColor:[UIColor themeHomeColor]];
            cellMargin.selectionStyle = UITableViewCellSelectionStyleNone;
            return cellMargin;
        }
    }else
    {
        if (self.showNoDataErrorView) {
            
            UITableViewCell *cellError = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([UITableViewCell class])];
            for (UIView *subView in cellError.contentView.subviews) {
                [subView removeFromSuperview];
            }
            cellError.selectionStyle = UITableViewCellSelectionStyleNone;
            FHErrorView * noDataErrorView = [[FHErrorView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [self getHeightShowNoData])];
            //        [noDataErrorView setBackgroundColor:[UIColor redColor]];
            [cellError.contentView addSubview:noDataErrorView];
            noDataErrorView.backgroundColor = [UIColor themeHomeColor];
            [noDataErrorView showEmptyWithTip:@"当前城市暂未开通服务，敬请期待" errorImageName:@"group-9"
                                    showRetry:NO];
            return cellError;
        }
        
        if (self.showRequestErrorView) {
            UITableViewCell *cellError = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([UITableViewCell class])];
            for (UIView *subView in cellError.contentView.subviews) {
                [subView removeFromSuperview];
            }
            cellError.selectionStyle = UITableViewCellSelectionStyleNone;
            FHErrorView * noDataErrorView = [[FHErrorView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [self getHeightShowNoData])];
            //        [noDataErrorView setBackgroundColor:[UIColor redColor]];
            [cellError.contentView addSubview:noDataErrorView];
            noDataErrorView.backgroundColor = [UIColor themeHomeColor];
            if ([FHEnvContext isNetworkConnected]) {
                [noDataErrorView showEmptyWithTip:@"数据走丢了" errorImageName:@"group-9"
                                        showRetry:YES];
                __weak typeof(self) weakSelf = self;
                noDataErrorView.retryBlock = ^{
                    if (weakSelf.panelVM) {
                        [weakSelf.panelVM fetchSearchPanelRollData];
                    }
                    [weakSelf requestDataForRefresh:FHHomePullTriggerTypePullDown andIsFirst:YES];
                };
            }else
            {
                [noDataErrorView showEmptyWithTip:@"网络异常，请检查网络连接" errorImageName:@"group-9"
                                        showRetry:YES];
                __weak typeof(self) weakSelf = self;
                noDataErrorView.retryBlock = ^{
                    if ([FHEnvContext isNetworkConnected]) {
                        if ([TTSandBoxHelper isAPPFirstLaunch]) {
                            if (weakSelf.requestNetworkUnAvalableRetryCallBack) {
                                weakSelf.requestNetworkUnAvalableRetryCallBack();
                            }
                        }else
                        {
                            if (weakSelf.panelVM) {
                                [weakSelf.panelVM fetchSearchPanelRollData];
                            }
                            [weakSelf requestDataForRefresh:FHHomePullTriggerTypePullDown andIsFirst:YES];
                        }
                    }
                };
            }
            return cellError;
        }
        
        if (self.showDislikeNoDataView) {
            UITableViewCell *cellError = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([UITableViewCell class])];
            for (UIView *subView in cellError.contentView.subviews) {
                [subView removeFromSuperview];
            }
            cellError.selectionStyle = UITableViewCellSelectionStyleNone;
            FHErrorView * noDataErrorView = [[FHErrorView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [self getHeightShowNoData])];
            //        [noDataErrorView setBackgroundColor:[UIColor redColor]];
            [cellError.contentView addSubview:noDataErrorView];
            
            [noDataErrorView showEmptyWithTip:@"点击为您推荐更多房源" errorImageName:@"group-9"
                                    showRetry:YES];
            __weak typeof(self) weakSelf = self;
            [noDataErrorView.retryButton setTitle:@"推荐更多" forState:UIControlStateNormal];
            noDataErrorView.retryBlock = ^{
                [weakSelf trackClickHouseRecommend];
                if (weakSelf.panelVM) {
                    [weakSelf.panelVM fetchSearchPanelRollData];
                }
                [weakSelf requestDataForRefresh:FHHomePullTriggerTypePullDown andIsFirst:YES];
            };
            
            return cellError;
        }
        
        if (self.showPlaceHolder) {
            if (self.houseType == FHHouseTypeNewHouse) {
                FHPlaceHolderCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([FHPlaceHolderCell class])];
                return cell;
            }
            FHHomePlaceHolderCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([FHHomePlaceHolderCell class])];
            return cell;
        }
        if (self.houseDataItemsModel.count>0) {
               FHHomeHouseDataItemsModel *model = (FHHomeHouseDataItemsModel *)self.houseDataItemsModel[indexPath.row];
            if ([model.houseType integerValue] == FHHouseTypeNewHouse && [model.cellStyle isEqualToString:@"6"]) {
                      FHHouseListBaseItemCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FHSynchysisNewHouseCell"];
                [cell updateSynchysisNewHouseCellWithModel:model];
                  [cell refreshIndexCorner:(indexPath.row == 0) andLast:(indexPath.row == (self.houseDataItemsModel.count - 1) && !self.hasMore)];
                      return cell;
                  }
        }
        if (self.houseType == FHHouseTypeNewHouse) {
            //to do 房源cell
            FHHouseBaseNewHouseCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellNewHouseItemImageId];
            cell.delegate = self;
            if (indexPath.row < self.houseDataItemsModel.count) {
                JSONModel *model = self.houseDataItemsModel[indexPath.row];
                [cell refreshTopMargin:([TTDeviceHelper is896Screen3X] || [TTDeviceHelper is896Screen2X]) ? 4 : 0];
                [cell updateHomeNewHouseCellModel:model];
            }
            [cell refreshIndexCorner:(indexPath.row == 0) andLast:(indexPath.row == (self.houseDataItemsModel.count - 1) && !self.hasMore)];
            return cell;
        }
        
        
        //to do 房源cell
        NSString *identifier = self.houseType == FHHouseTypeRentHouse ? kCellRentHouseItemImageId : kCellSmallItemImageId;
        FHHouseBaseItemCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        cell.delegate = self;
        if (indexPath.row < self.houseDataItemsModel.count) {
            JSONModel *model = self.houseDataItemsModel[indexPath.row];
            [cell refreshTopMargin:([TTDeviceHelper is896Screen3X] || [TTDeviceHelper is896Screen2X]) ? 4 : 0];
            [cell updateHomeSmallImageHouseCellModel:model andType:self.houseType];
        }
        [cell refreshIndexCorner:(indexPath.row == 0) andLast:(indexPath.row == (self.houseDataItemsModel.count - 1) && !self.hasMore)];
        [cell.contentView setBackgroundColor:[UIColor themeHomeColor]];
        return cell;
    }
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == kFHHomeHouseTypeBannerViewSection) {
        if (self.houseType == _listModel.houseType && ![self.traceRecordDict objectForKey:@(self.houseType)] && [self checkIsHaveEntrancesList]) {
            [self.traceRecordDict setValue:@"" forKey:@(self.houseType)];
            [FHHomeCellHelper sendBannerTypeCellShowTrace:_houseType];
        }
        return ;
    }
    
    if (self.houseDataItemsModel.count <= indexPath.row) {
        return;
    }
    
    FHHomeHouseDataItemsModel *cellModel = [_houseDataItemsModel objectAtIndex:indexPath.row];
    if (cellModel.idx && ![self.traceRecordDict objectForKey:cellModel.idx])
    {
        if (cellModel.idx) {
            [self.traceRecordDict setValue:@"" forKey:cellModel.idx];
            
            NSString *originFrom = [FHEnvContext sharedInstance].getCommonParams.originFrom ? : @"be_null";
            
            NSMutableDictionary *tracerDict = [NSMutableDictionary new];
            tracerDict[@"house_type"] = cellModel.houseType.integerValue == FHHouseTypeNewHouse?@"new":([self houseTypeString] ? : @"be_null");
            tracerDict[@"card_type"] = @"left_pic";
            tracerDict[@"page_type"] = @"maintab";
            tracerDict[@"element_type"] = @"maintab_list";
            tracerDict[@"group_id"] = cellModel.idx ? : @"be_null";
            tracerDict[@"impr_id"] = cellModel.imprId ? : @"be_null";
            tracerDict[@"search_id"] = cellModel.searchId ? : @"";
            tracerDict[@"rank"] = @(indexPath.row);
            tracerDict[@"origin_from"] = [self pageTypeString];
            tracerDict[@"origin_search_id"] = self.originSearchId ? : @"be_null";
            tracerDict[@"log_pb"] = [cellModel logPb] ? : @"be_null";
            [tracerDict removeObjectForKey:@"element_from"];
            
            NSMutableDictionary *dic = [tracerDict mutableCopy];
            dic[@"enter_from"] = @"maintab";
            dic[@"element_from"] = @"maintab_list";
            cellModel.tracerDict = [dic copy];
            
            if (tracerDict && !self.isOriginShowSelf) {
                [self.traceNeedUploadCache addObject:tracerDict];
            }else
            {
                [FHEnvContext recordEvent:tracerDict andEventKey:@"house_show"];
            }
        }
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!self.showPlaceHolder && indexPath.section == 1) {
        [self jumpToDetailPage:indexPath];
        if(self.houseDataItemsModel.count > indexPath.row){
            FHHomeHouseDataItemsModel *theModel = self.houseDataItemsModel[indexPath.row];
                if (self.houseType == FHHouseTypeSecondHandHouse &&theModel.houseType.integerValue != FHHouseTypeNewHouse) {
                    [[FHRelevantDurationTracker sharedTracker] beginRelevantDurationTracking];
             }
        }
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (self.houseType == FHHouseTypeSecondHandHouse) {
        [[FHRelevantDurationTracker sharedTracker] sendRelevantDuration];
    }
}

#pragma mark - 详情页跳转
-(void)jumpToDetailPage:(NSIndexPath *)indexPath {
    if (self.houseDataItemsModel.count > indexPath.row) {
        FHHomeHouseDataItemsModel *theModel = self.houseDataItemsModel[indexPath.row];
        NSMutableDictionary *traceParam = [NSMutableDictionary new];
        traceParam[@"enter_from"] = [self pageTypeString];
        traceParam[@"log_pb"] = theModel.logPb;
        traceParam[@"origin_from"] = [self pageTypeString];
        traceParam[@"card_type"] = @"left_pic";
        traceParam[@"rank"] = @(indexPath.row);
        traceParam[@"origin_search_id"] = self.originSearchId ? : @"be_null";
        traceParam[@"element_from"] = @"maintab_list";
        traceParam[@"enter_from"] = @"maintab";
        
        NSInteger houseType = 0;
        if ([theModel.houseType isKindOfClass:[NSString class]]) {
            houseType = [theModel.houseType integerValue];
        }
        
        if (houseType == 0) {
            houseType = self.houseType;
        }
//        if (houseType != 0) {
//            if (houseType != self.houseType) {
//                return;
//            }
//        }else
//        {
//            houseType = self.houseType;
//        }
                
        NSMutableDictionary *dict = @{@"house_type":@(houseType),
                               @"tracer": traceParam
                               }.mutableCopy;
        dict[INSTANT_DATA_KEY] = theModel;
        
        NSURL *jumpUrl = nil;
        
        if (houseType == FHHouseTypeSecondHandHouse) {
            jumpUrl = [NSURL URLWithString:[NSString stringWithFormat:@"sslocal://old_house_detail?house_id=%@",theModel.idx]];
        }else if(houseType == FHHouseTypeNewHouse)
        {
            jumpUrl = [NSURL URLWithString:[NSString stringWithFormat:@"sslocal://new_house_detail?court_id=%@",theModel.idx]];
        }else if(houseType == FHHouseTypeRentHouse)
        {
            jumpUrl = [NSURL URLWithString:[NSString stringWithFormat:@"sslocal://rent_detail?house_id=%@",theModel.idx]];
        }
        
        if (jumpUrl != nil) {
            TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:dict];
            [[TTRoute sharedRoute] openURLByPushViewController:jumpUrl userInfo:userInfo];
        }
    }
}

- (UITableView *)tableView {
    
    if (!_tableView) {
        _tableView = [[FHHomeBaseTableView alloc] initWithFrame:CGRectMake(0, 0,  [UIScreen mainScreen].bounds.size.width,[[FHHomeCellHelper sharedInstance] heightForFHHomeListHouseSectionHeight]) style:UITableViewStylePlain];
        _tableView.dataSource = self;
        _tableView.delegate = self;
//        _tableView.bounces = NO;
        //        _tableView.decelerationRate = 0.1;
        _tableView.showsVerticalScrollIndicator = NO;
        _tableView.estimatedRowHeight = 0;
        if (@available(iOS 11.0 , *)) {
            self.tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }else{
            self.automaticallyAdjustsScrollViewInsets = NO;
        }
    }
    return _tableView;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - FHHouseBaseItemCellDelegate

- (BOOL)canDislikeClick {
    return !self.isShowRefreshTip;
}

- (void)dislikeConfirm:(FHHomeHouseDataItemsModel *)model cell:(id)cell {
    NSInteger row = [self getCellIndex:model];
    if(row < self.houseDataItemsModel.count && row >= 0){
        [self.houseDataItemsModel removeObjectAtIndex:row];
        if(self.houseDataItemsModel.count == 0){
            self.showDislikeNoDataView = YES;
            self.tableView.hasMore = NO;
            self.tableView.mj_footer.hidden = YES;
            [self.tableView.mj_footer endRefreshingWithNoMoreData];
            [self.tableView reloadData];
        }else{
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:1];
//            [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
            //当数据少于一页的时候，拉下一页数据填充
            [self.tableView reloadData];

            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                dispatch_async(dispatch_get_main_queue(), ^{
                    if(self.houseDataItemsModel.count < self.itemCount && self.tableView.hasMore){
                        [self requestDataForRefresh:FHHomePullTriggerTypePullUp andIsFirst:NO];
                    }
                });
            });
        }
    }
}

- (NSInteger)getCellIndex:(FHHomeHouseDataItemsModel *)model {
    NSInteger index = [self.houseDataItemsModel indexOfObject:model];
    if(index >= 0 && index < self.houseDataItemsModel.count){
        return index;
    }
    return -1;
}

- (void)trackClickHouseRecommend {
    NSMutableDictionary *tracerDict = [NSMutableDictionary dictionary];
    tracerDict[@"page_type"] = [self pageTypeString];
    tracerDict[@"enter_from"] = @"maintab";
    tracerDict[@"element_from"] = @"maintab_list";
    tracerDict[@"click_position"] = @"house_recommend_more";
    TRACK_EVENT(@"click_house_recommend", tracerDict);
}

@end

