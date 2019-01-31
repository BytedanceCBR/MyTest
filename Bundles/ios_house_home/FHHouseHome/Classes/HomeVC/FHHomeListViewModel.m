//
//  FHHomeListViewModel.m
//  AFgzipRequestSerializer
//
//  Created by 谢飞 on 2018/12/22.
//

#import "FHHomeListViewModel.h"
#import "FHHomeMainTableViewDataSource.h"
#import "FHHomeConfigManager.h"
#import "FHHomeSectionHeader.h"
#import "FHEnvContext.h"
#import "FHHomeRequestAPI.h"
#import "FHHouseType.h"
#import "FHHomeHouseModel.h"
#import "TTURLUtils.h"
#import "FHTracerModel.h"
#import "TTCategoryStayTrackManager.h"
#import "ToastManager.h"
#import "ArticleListNotifyBarView.h"
#import <UIScrollView+Refresh.h>
#import <MJRefresh.h>
#import "FHRefreshCustomFooter.h"

typedef NS_ENUM (NSInteger , FHHomePullTriggerType){
    FHHomePullTriggerTypePullUp = 1, //上拉刷新
    FHHomePullTriggerTypePullDown = 2  //下拉刷新
};

@interface FHHomeListViewModel()

@property (nonatomic, strong) UITableView *tableViewV;
@property (nonatomic, assign) BOOL showPlaceHolder;
@property (nonatomic, strong) FHHomeMainTableViewDataSource *dataSource;
@property (nonatomic, strong) FHHomeViewController *homeViewController;
@property (nonatomic, strong) FHHomeSectionHeader *categoryView;
@property (nonatomic, assign) FHHouseType currentHouseType;
@property (nonatomic, assign) FHHomePullTriggerType currentPullType;
@property(nonatomic , strong) FHRefreshCustomFooter *refreshFooter;
@property (nonatomic, strong) NSMutableDictionary <NSString *, NSArray <FHHomeHouseDataItemsModel *> *>* itemsDataCache;
@property (nonatomic, strong) NSMutableDictionary <NSString *, NSString *>* itemsSearchIdCache;
@property (nonatomic, strong) NSMutableDictionary <NSString *, NSString *>* originSearchIdCache;
@property (nonatomic, strong) NSMutableDictionary <NSString *, NSNumber *>* isItemsHasMoreCache;
@property (nonatomic, strong) ArticleListNotifyBarView *notifyBarView;
@end

@implementation FHHomeListViewModel

- (instancetype)initWithViewController:(UITableView *)tableView andViewController:(FHHomeViewController *)homeVC
{
    self = [super init];
    if (self) {
        [self initItemsCaches];
        
        self.categoryView = [[FHHomeSectionHeader alloc] init];
        self.tableViewV = tableView;
        self.homeViewController = homeVC;
        self.dataSource = [FHHomeMainTableViewDataSource new];
        self.dataSource.categoryView = self.categoryView;
        self.dataSource.showPlaceHolder = YES;
        [self updateCategoryViewSegmented:YES];
        self.tableViewV.delegate = self.dataSource;
        self.tableViewV.dataSource = self.dataSource;
        self.hasShowedData = NO;
        
        self.tableViewV.hasMore = YES;
        self.enterType = [TTCategoryStayTrackManager shareManager].enterType != nil ? [TTCategoryStayTrackManager shareManager].enterType : @"default";
        
        WeakSelf;
        self.refreshFooter = [FHRefreshCustomFooter footerWithRefreshingBlock:^{
            if ([FHEnvContext isNetworkConnected]) {
                [self requestDataForRefresh:FHHomePullTriggerTypePullUp];
            }else
            {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.tableViewV finishPullUpWithSuccess:YES];
                    });
                });
                [[ToastManager manager] showToast:@"网络异常"];
            }
        }];
        self.tableViewV.mj_footer = self.refreshFooter;
        
        // 上拉刷新，修改tabbar条和请求数据
//        [self.tableViewV tt_addDefaultPullUpLoadMoreWithHandler:^{
//            StrongSelf;
//            if ([FHEnvContext isNetworkConnected]) {
//                [self requestDataForRefresh:FHHomePullTriggerTypePullUp];
//            }else
//            {
//                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//                    dispatch_async(dispatch_get_main_queue(), ^{
//                        [self.tableViewV finishPullUpWithSuccess:YES];
//                    });
//                });
//                [[ToastManager manager] showToast:@"网络异常"];
//            }
//        }];
        // 下拉刷新，修改tabbar条和请求数据
        [self.tableViewV tt_addDefaultPullDownRefreshWithHandler:^{
            StrongSelf;
            if (![FHEnvContext isNetworkConnected]) {
                [[ToastManager manager] showToast:@"网络异常"];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.tableViewV finishPullDownWithSuccess:YES];
                    });
                });
                return ;
            }
            
            //切换城市显示房源默认
            if ([FHEnvContext sharedInstance].isRefreshFromCitySwitch) {
                self.dataSource.showPlaceHolder = YES;
                [self reloadHomeTableHeaderSection];
            }
            
            [self resetCurrentHouseCacheData];
            [self requestDataForRefresh:FHHomePullTriggerTypePullDown];
        }];
        
        FHConfigDataModel *configDataModel = [[FHEnvContext sharedInstance] getConfigFromCache];
        //订阅config变化发送网络请求
        __block BOOL isFirstChange = YES;
        [[FHEnvContext sharedInstance].configDataReplay subscribeNext:^(id  _Nullable x) {
            StrongSelf;
            //切换城市先隐藏error页
            [self.homeViewController.emptyView hideEmptyView];
            
            //过滤多余刷新
            if (configDataModel == [[FHEnvContext sharedInstance] getConfigFromCache] && !isFirstChange) {
                return;
            }
            
            self.dataSource.showPlaceHolder = YES;
            
            [self reloadHomeTableHeaderSection];
            
            [self updateCategoryViewSegmented:isFirstChange];

            if ([configDataModel.currentCityId isEqualToString:[[FHEnvContext sharedInstance] getConfigFromCache].currentCityId] && [FHEnvContext sharedInstance].isSendConfigFromFirstRemote) {
                [UIView performWithoutAnimation:^{
                    if ([self.tableViewV numberOfRowsInSection:0] > 0) {
                        [self.tableViewV beginUpdates];
                            NSIndexSet *indexSet=[[NSIndexSet alloc] initWithIndex:0];
                            [self.tableViewV reloadSections:indexSet withRowAnimation:UITableViewRowAnimationNone];
                        [self.tableViewV endUpdates];
                    }
                }];
                return;
            }
            
            //防止二次刷新
            if ([FHEnvContext sharedInstance].isRefreshFromCitySwitch && configDataModel.cityAvailability.enable == YES) {
                return;
            }
            
            [self resetAllCacheData];
            
            [self requestOriginData:isFirstChange];
            
            isFirstChange = NO;
        }];
        
        
        self.categoryView.clickIndexCallBack = ^(NSInteger indexValue) {
            StrongSelf;
            
            [self sendTraceEvent:FHHomeCategoryTraceTypeStay];
            
            FHConfigDataModel *currentDataModel = [[FHEnvContext sharedInstance] getConfigFromCache];
            if (currentDataModel.houseTypeList.count > indexValue) {
                NSNumber *numberType = [currentDataModel.houseTypeList objectAtIndex:indexValue];
                if ([numberType isKindOfClass:[NSNumber class]]) {
                    self.currentHouseType = [numberType integerValue];
                }
            }
            NSString *cacheKey = [self getCurrentHouseTypeChacheKey];
            
            self.tableViewV.hasMore = [self.isItemsHasMoreCache[cacheKey] boolValue];
            [self updateTableViewWithMoreData:[self.isItemsHasMoreCache[cacheKey] boolValue]];

            if (kIsNSString(cacheKey)) {
                NSArray *modelsCache = self.itemsDataCache[cacheKey];
                
                self.enterType = @"switch";
                
                if (modelsCache != nil && kIsNSArray(modelsCache) && modelsCache.count !=0) {
                    [self reloadHomeTableForSwitchFromCache:modelsCache];
                    self.stayTime = [self getCurrentTime];
                    [[FHEnvContext sharedInstance] updateOriginFrom:[self pageTypeString] originSearchId:self.itemsSearchIdCache[cacheKey]];
                    self.dataSource.originSearchId = self.originSearchIdCache[cacheKey];
                }else
                {
                    [self reloadHomeTableHeaderSection];
                    [self requestOriginData:NO];
                }
            }else
            {
                [self reloadHomeTableHeaderSection];
                [self requestOriginData:NO];
            }
            
            [self sendSwitchButtonClickTrace];
            
        };
        
    }
    return self;
}

-(NSString *)pageTypeString {
    
    switch (self.currentHouseType) {
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

- (void)updateTableViewWithMoreData:(BOOL)hasMore {
    self.tableViewV.mj_footer.hidden = NO;
    if (hasMore == NO) {
        [self.refreshFooter setUpNoMoreDataText:@" -- 暂无更多数据 -- "];
        [self.tableViewV.mj_footer endRefreshingWithNoMoreData];
    }else {
        [self.tableViewV.mj_footer endRefreshing];
    }
}


- (NSTimeInterval)getCurrentTime
{
    return  [[NSDate date] timeIntervalSince1970];
}

- (NSString *)getCurrentHouseTypeChacheKey
{
    return [self matchHouseString:self.currentHouseType];
}

- (void)initItemsCaches
{
    self.itemsDataCache = [NSMutableDictionary new];
    self.itemsSearchIdCache = [NSMutableDictionary new];
    self.originSearchIdCache = [NSMutableDictionary new];
    self.isItemsHasMoreCache = [NSMutableDictionary new];
    [self.dataSource resetTraceCahce];
}

- (void)requestOriginData:(BOOL)isFirstChange
{
    NSMutableDictionary *requestDictonary = [NSMutableDictionary new];
    [requestDictonary setValue:[FHEnvContext getCurrentSelectCityIdFromLocal] forKey:@"city_id"];
    [requestDictonary setValue:@(0) forKey:@"offset"];
    if (self.currentHouseType != 0) {
        [requestDictonary setValue:@(self.currentHouseType) forKey:@"house_type"];
    }else
    {
        NSInteger houseType = FHHouseTypeSecondHandHouse;
        NSNumber *firstObject = [[[FHEnvContext sharedInstance] getConfigFromCache].houseTypeList firstObject];
        if ([firstObject respondsToSelector:@selector(integerValue)]) {
            houseType = [firstObject integerValue];
        }
        [requestDictonary setValue:@(houseType) forKey:@"house_type"];
    }
    [requestDictonary setValue:@(20) forKey:@"count"];
    self.categoryView.segmentedControl.userInteractionEnabled = NO;
    
    WeakSelf;
    [FHHomeRequestAPI requestRecommendFirstTime:requestDictonary completion:^(FHHomeHouseModel * _Nonnull model, NSError * _Nonnull error) {
        StrongSelf;
        
        if (!model || error) {
            if (![FHEnvContext isNetworkConnected]) {
                [self.homeViewController.emptyView showEmptyWithTip:@"网络异常，请检查网络连接" errorImage:[UIImage imageNamed:@"group-4"] showRetry:YES];
            }else
            {
                [self.homeViewController.emptyView showEmptyWithTip:@"数据走丢了" errorImage:[UIImage imageNamed:@"group-8"] showRetry:YES];
            }
            self.tableViewV.hidden = YES;
            return;
        }
        
        if (model.data.items.count == 0) {
            self.tableViewV.hidden = YES;
            
            if ([[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CHANNEL_NAME"] isEqualToString:@"local_test"])
            {
                [self.homeViewController.view sendSubviewToBack:self.tableViewV];
                [self.homeViewController.emptyView showEmptyWithTip:@"当前城市暂未开通服务，敬请期待" errorImage:[UIImage imageNamed:@"group-9"] showRetry:NO];
                
                return;
            }
            
            if (![[FHEnvContext sharedInstance] getConfigFromCache].cityAvailability.enable.boolValue) {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.homeViewController.view sendSubviewToBack:self.tableViewV];
                        [self.homeViewController.emptyView showEmptyWithTip:@"当前城市暂未开通服务，敬请期待" errorImage:[UIImage imageNamed:@"group-9"] showRetry:NO];
                    });
                });
                return;
            }
        }
        
        NSString *cahceKey = [self getCurrentHouseTypeChacheKey];
        if (kIsNSString(cahceKey)) {
            self.itemsDataCache[cahceKey] = model.data.items;
        }
        
        if (kIsNSString(cahceKey)) {
            self.originSearchIdCache[cahceKey] = model.data.searchId;
        }
        
        
        if (kIsNSString(cahceKey)) {
            self.itemsSearchIdCache[cahceKey] = model.data.searchId;
        }
        
        
        if (kIsNSString(cahceKey) && model.data.hasMore != nil) {
            self.isItemsHasMoreCache[cahceKey] = @(model.data.hasMore);
        }
        
        self.categoryView.segmentedControl.userInteractionEnabled = YES;
        [self.tableViewV finishPullDownWithSuccess:YES];
        [self reloadHomeTableHouseSection:model.data.items];
        [[FHEnvContext sharedInstance].generalBizConfig updateUserSelectDiskCacheIndex:@(self.currentHouseType)];
        
        
        self.tableViewV.hasMore = model.data.hasMore;
        [self updateTableViewWithMoreData:model.data.hasMore];
        
        self.hasShowedData = YES;
        
        [[FHEnvContext sharedInstance] updateOriginFrom:[self pageTypeString] originSearchId:model.data.searchId];
        
        [self sendTraceEvent:FHHomeCategoryTraceTypeEnter];
        
        if ((model.data.refreshTip && ![FHEnvContext sharedInstance].isRefreshFromCitySwitch) || ![FHEnvContext sharedInstance].isSendConfigFromFirstRemote) {
            
            [self.homeViewController showNotify:model.data.refreshTip];
            
            [self.tableViewV scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
        }
        
        [FHEnvContext sharedInstance].isRefreshFromCitySwitch = NO;
        
        self.stayTime = [self getCurrentTime];
        self.dataSource.originSearchId = model.data.searchId;
        self.tableViewV.hidden = NO;
        [self checkLoadingAndEmpty];
    }];
}


- (void)requestDataForRefresh:(FHHomePullTriggerType)pullType
{
    self.currentPullType = pullType;
    NSMutableDictionary *requestDictonary = [NSMutableDictionary new];
    [requestDictonary setValue:[FHEnvContext getCurrentSelectCityIdFromLocal] forKey:@"city_id"];
    NSString *cahceKey = [self getCurrentHouseTypeChacheKey];
    NSInteger offsetValue = 20;
    if (kIsNSString(cahceKey)) {
        offsetValue = self.itemsDataCache[cahceKey].count;
    }
    [requestDictonary setValue:@(offsetValue) forKey:@"offset"];
    [requestDictonary setValue:@(self.currentHouseType) forKey:@"house_type"];
    [requestDictonary setValue:@(20) forKey:@"count"];
    
    if (pullType == FHHomePullTriggerTypePullUp) {
        if (kIsNSString(self.itemsSearchIdCache[cahceKey])) {
            [requestDictonary setValue:self.itemsSearchIdCache[cahceKey] forKey:@"search_id"];
        }
    }
    
    self.categoryView.segmentedControl.userInteractionEnabled = NO;
    WeakSelf;
    [FHHomeRequestAPI requestRecommendForLoadMore:requestDictonary completion:^(FHHomeHouseModel * _Nonnull model, NSError * _Nonnull error) {
        StrongSelf;
        NSString *cacheKey = [self getCurrentHouseTypeChacheKey];
        NSMutableArray *modelsCache =[[NSMutableArray alloc] initWithArray:self.itemsDataCache[cacheKey]];
        if (kIsNSString(cahceKey)) {
            if (pullType == FHHomePullTriggerTypePullUp) {
                if (model && model.data.items.count > 0) {
                    self.itemsDataCache[cacheKey] = [modelsCache arrayByAddingObjectsFromArray:model.data.items];
                }
            }else
            {
                self.itemsDataCache[cacheKey] = model.data.items;
            }
        }
        
        if (pullType == FHHomePullTriggerTypePullDown) {
            if ((model.data.items.count == 0 && self.dataSource.modelsArray.count == 0) || ![[FHEnvContext sharedInstance] getConfigFromCache].cityAvailability.enable) {
                self.tableViewV.hidden = YES;
                [self.homeViewController.view sendSubviewToBack:self.tableViewV];
                [self.homeViewController.emptyView showEmptyWithTip:@"当前城市暂未开通服务，敬请期待" errorImage:[UIImage imageNamed:@"group-9"] showRetry:NO];
                return;
            }
            
            if (model.data.items.count == 0 && self.dataSource.modelsArray.count != 0) {
                [self.tableViewV finishPullDownWithSuccess:YES];
                return;
            }
        }
        
        if (kIsNSString(cahceKey) && pullType == FHHomePullTriggerTypePullDown) {
            self.originSearchIdCache[cahceKey] = model.data.searchId;
        }
        
        if (kIsNSString(cahceKey) && model.data.searchId) {
            self.itemsSearchIdCache[cacheKey] = model.data.searchId;
        }
        
        if (kIsNSString(cahceKey) && model.data.hasMore != nil) {
            self.isItemsHasMoreCache[cacheKey] = @(model.data.hasMore);
        }
        
        self.categoryView.segmentedControl.userInteractionEnabled = YES;
        [self.tableViewV finishPullDownWithSuccess:YES];
        [self.tableViewV finishPullUpWithSuccess:YES];
        [self reloadHomeTableHouseSection:self.itemsDataCache[cacheKey]];
        
        
        [[FHEnvContext sharedInstance].generalBizConfig updateUserSelectDiskCacheIndex:@(self.currentHouseType)];
        self.tableViewV.hasMore = model.data.hasMore;
        [self updateTableViewWithMoreData:model.data.hasMore];

        [self checkLoadingAndEmpty];
        
        [self sendTraceEvent:FHHomeCategoryTraceTypeRefresh];
        
        if (model.data.refreshTip && pullType == FHHomePullTriggerTypePullDown) {
            [self.homeViewController showNotify:model.data.refreshTip];
            self.tableViewV.contentOffset = CGPointMake(0, 0);
            [self.tableViewV scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
        }
    }];
}

- (void)resetAllCacheData
{
    [self.itemsDataCache removeAllObjects];
    [self.itemsSearchIdCache removeAllObjects];
    [self.originSearchIdCache removeAllObjects];
    [self.isItemsHasMoreCache removeAllObjects];
}

- (void)resetCurrentHouseCacheData
{
    [self.itemsDataCache removeObjectForKey:[self getCurrentHouseTypeChacheKey]];
    [self.itemsSearchIdCache removeObjectForKey:[self getCurrentHouseTypeChacheKey]];
    [self.originSearchIdCache removeObjectForKey:[self getCurrentHouseTypeChacheKey]];
    [self.isItemsHasMoreCache removeObjectForKey:[self getCurrentHouseTypeChacheKey]];
    [self.dataSource resetTraceCahce];
}

- (void)updateCategoryViewSegmented:(BOOL)isFirstChange
{
    NSNumber *userSelectType = [[FHEnvContext sharedInstance].generalBizConfig getUserSelectTypeDiskCache];
    NSInteger indexValue = 0;
    NSArray *houstTypeList = [[FHEnvContext sharedInstance] getConfigFromCache].houseTypeList;
    
    if ([houstTypeList containsObject:userSelectType]) {
        indexValue = [houstTypeList indexOfObject:userSelectType];
        NSNumber *numberType = [houstTypeList objectAtIndex:indexValue];
        self.currentHouseType = [userSelectType integerValue];
    }else
    {
        if (houstTypeList.count > 0 && [houstTypeList.firstObject respondsToSelector:@selector(integerValue)]) {
            self.currentHouseType = [houstTypeList.firstObject integerValue];
        }else
        {
            self.currentHouseType = FHHouseTypeSecondHandHouse;
        }
    }
    
    [self.categoryView updateSegementedTitles:[self matchHouseSegmentedTitleArray]  andSelectIndex:indexValue];
}

- (NSArray <NSString *>*)matchHouseSegmentedTitleArray
{
    FHConfigDataModel *configDataModel = [[FHEnvContext sharedInstance] getConfigFromCache];
    NSMutableArray *titleArrays = [[NSMutableArray alloc] initWithCapacity:3];
    for (int i = 0; i < configDataModel.houseTypeList.count; i++) {
        NSNumber *houseTypeNum = configDataModel.houseTypeList[i];
        if ([houseTypeNum isKindOfClass:[NSNumber class]]) {
            NSString * houseStr = [self matchHouseString:[houseTypeNum integerValue]];
            if (kIsNSString(houseStr) && houseStr.length != 0) {
                [titleArrays addObject:houseStr];
            }
        }
    }
    return titleArrays;
}

- (NSString *)matchHouseString:(FHHouseType)houseType
{
    switch (houseType) {
        case FHHouseTypeNewHouse:
        {
            return @"新房";
        }
            break;
        case FHHouseTypeRentHouse:
        {
            return @"租房";
        }
            break;
        case FHHouseTypeNeighborhood:
        {
            return @"小区";
        }
            break;
        case FHHouseTypeSecondHandHouse:
        {
            return @"二手房";
        }
            break;
            
        default:
            return @"";
            break;
    }
}

- (void)checkLoadingAndEmpty
{
    if ([self.homeViewController respondsToSelector:@selector(tt_endUpdataData)]) {
        [self.homeViewController.emptyView hideEmptyView];
        if (self.dataSource.modelsArray.count > 0) {
            self.homeViewController.mainTableView.hidden = NO;
        }else
        {
            self.homeViewController.mainTableView.hidden = YES;
        }
        [self.homeViewController tt_endUpdataData];
    }
}


- (void)reloadHomeTableHeaderSection
{
    self.dataSource.showPlaceHolder = YES;
    self.dataSource.currentHouseType = self.currentHouseType;
    
    if (self.tableViewV.numberOfSections > kFHHomeListHeaderBaseViewSection) {
        [UIView performWithoutAnimation:^{
            [self.tableViewV reloadData];
        }];
    }
}

- (void)reloadHomeTableHouseSection:(NSArray <JSONModel *> *)models
{
    if (models.count == 0) {
        return;
    }
    
    self.dataSource.showPlaceHolder = NO;
    self.dataSource.modelsArray = models;
    self.dataSource.currentHouseType = self.currentHouseType;
    
    if (self.tableViewV.numberOfSections > kFHHomeListHouseBaseViewSection) {
        [self.tableViewV reloadData];
    }
}

- (void)reloadHomeTableForSwitchFromCache:(NSArray <JSONModel *> *)models
{
    if (kIsNSArray(models)) {
        self.dataSource.modelsArray = models;
        self.dataSource.currentHouseType = self.currentHouseType;
        self.dataSource.modelsArray = models;
        [self.tableViewV reloadData];
    }
    [self sendTraceEvent:FHHomeCategoryTraceTypeEnter];
}

- (void)sendSwitchButtonClickTrace
{
    NSString *stringClickType = @"be_null";
    NSMutableDictionary *tracerDict = [NSMutableDictionary new];
    switch (self.currentHouseType) {
        case FHHouseTypeNewHouse:
            stringClickType = @"new";
            break;
        case FHHouseTypeSecondHandHouse:
            stringClickType = @"old";
            break;
        case FHHouseTypeRentHouse:
            stringClickType = @"rent";
            break;
        default:
            break;
    }
    tracerDict[@"click_type"] = stringClickType;
    
    [FHEnvContext recordEvent:tracerDict andEventKey:@"click_switch_maintablist"];
    
}

- (void)sendTraceEvent:(FHHomeCategoryTraceType)traceType
{
    NSMutableDictionary *tracerDict = [NSMutableDictionary new];
    self.homeViewController.tracerModel.enterFrom = @"maintab";
    self.homeViewController.tracerModel.elementFrom = @"maintab_list";
    
    tracerDict[@"category_name"] = [self.dataSource pageTypeString] ? : @"be_null";
    tracerDict[@"enter_from"] = @"maintab";
    tracerDict[@"enter_type"] = self.enterType ? : @"be_null";
    tracerDict[@"element_from"] = @"maintab_list";
    tracerDict[@"search_id"] = self.itemsSearchIdCache[[self matchHouseString:self.currentHouseType]] ? : @"be_null";
    tracerDict[@"origin_from"] = [self.dataSource pageTypeString]  ? : @"be_null";
    tracerDict[@"origin_search_id"] = self.originSearchIdCache[[self matchHouseString:self.currentHouseType]] ? : @"be_null";
    
    
    if (traceType == FHHomeCategoryTraceTypeEnter) {
        [FHEnvContext recordEvent:tracerDict andEventKey:@"enter_category"];
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
        tracerDict[@"refresh_type"] = (self.currentPullType == FHHomePullTriggerTypePullUp ? @"pre_load_more" : stringReloadType);
        [FHEnvContext recordEvent:tracerDict andEventKey:@"category_refresh"];
        
        self.reloadType = nil;
    }
    
}

@end
