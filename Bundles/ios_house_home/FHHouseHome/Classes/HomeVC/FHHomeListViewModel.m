//
//  FHHomeListViewModel.m
//  AFgzipRequestSerializer
//
//  Created by 谢飞 on 2018/10/22.
//

#import "FHHomeListViewModel.h"
#import "FHHomeMainTableViewDataSource.h"
#import "FHHomeConfigManager.h"
#import "FHHomeSectionHeader.h"
#import "FHEnvContext.h"
#import "FHHomeRequestAPI.h"
#import "FHHouseType.h"
#import <FHHomeHouseModel.h>
#import "TTURLUtils.h"
#import "FHTracerModel.h"
#import "TTCategoryStayTrackManager.h"
#import "ToastManager.h"
#import "ArticleListNotifyBarView.h"
#import <UIScrollView+Refresh.h>
#import <MJRefresh.h>
#import <FHRefreshCustomFooter.h>
#import <TTArticleCategoryManager.h>

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
@property (nonatomic, strong) TTHttpTask * requestOriginTask;
@property (nonatomic, strong) TTHttpTask * requestRefreshTask;
@property (nonatomic, assign) BOOL isHasCallBackForFirstTime;
@property (nonatomic, assign) BOOL isRetryedPullDownRefresh;
@property (nonatomic, assign) BOOL isFirstChange;
@property (nonatomic, assign) BOOL isFromLocalTestChange;

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
        self.isHasCallBackForFirstTime = NO;
        self.isFirstChange = YES;
        
        
        self.tableViewV.hasMore = YES;
        self.enterType = [TTCategoryStayTrackManager shareManager].enterType != nil ? [TTCategoryStayTrackManager shareManager].enterType : @"default";
        
        WeakSelf;
        self.refreshFooter = [FHRefreshCustomFooter footerWithRefreshingBlock:^{
            StrongSelf;
            if ([FHEnvContext isNetworkConnected]) {
                [self requestDataForRefresh:FHHomePullTriggerTypePullUp];
            }else
            {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.tableViewV finishPullUpWithSuccess:YES];
                    });
                });
                [self.tableViewV.mj_footer endRefreshing];
                [[ToastManager manager] showToast:@"网络异常"];
            }
        }];
        self.tableViewV.mj_footer = self.refreshFooter;
        
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
            self.isRetryedPullDownRefresh = YES;
            [self requestDataForRefresh:FHHomePullTriggerTypePullDown];
        }];
        
        if ([self checkIsHasFindHouse] && ![[FHEnvContext sharedInstance] getConfigFromCache].cityAvailability.enable.boolValue)
        {
            self.tableViewV.hidden = YES;
            self.isFromLocalTestChange = YES;
            [self checkCityStatus];
        }else
        {
            self.isFromLocalTestChange = NO;
        }
        
        FHConfigDataModel *configDataModel = [[FHEnvContext sharedInstance] getConfigFromCache];
        //       __block NSString *previousCityId = configDataModel.currentCityId;
        //订阅config变化发送网络请求
        __block BOOL isShowLocalTest = NO;
        [[FHEnvContext sharedInstance].configDataReplay subscribeNext:^(id  _Nullable x) {
            StrongSelf;
            
            self.tableViewV.hidden = NO;
            
            //切换城市先隐藏error页
            [self.homeViewController.emptyView hideEmptyView];
            
            //更新切换
            [self updateCategoryViewSegmented:self.isFirstChange];
            
            
            if ([FHEnvContext sharedInstance].isRefreshFromAlertCitySwitch) {
                
                //刷新头部
                [self reloadHomeTableHeaderSection];
                
                //清除缓存数据
                [self resetAllCacheData];
                
                //请求推荐房源
                [self requestOriginData:self.isFirstChange];
                return ;
            }
            
            //过滤多余刷新
            if (configDataModel == [[FHEnvContext sharedInstance] getConfigFromCache] && !self.isFirstChange) {
                return;
            }
            
            //非首次只刷新头部
            if ((!self.isFirstChange && [FHEnvContext sharedInstance].isSendConfigFromFirstRemote) && ![FHEnvContext sharedInstance].isRefreshFromAlertCitySwitch && !isShowLocalTest) {
                
                [self resetAllOthersCacheData];
                [UIView performWithoutAnimation:^{
                    if ([self.tableViewV numberOfRowsInSection:0] > 0) {
                        [self.tableViewV beginUpdates];
                        NSIndexSet *indexSet=[[NSIndexSet alloc] initWithIndex:0];
                        [self.tableViewV reloadSections:indexSet withRowAnimation:UITableViewRowAnimationNone];
                        [self.tableViewV endUpdates];
                    }
                }];
                
                
                if ([[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CHANNEL_NAME"] isEqualToString:@"local_test"] && ![[FHEnvContext sharedInstance] getConfigFromCache].cityAvailability.enable.boolValue)
                {
                    [self checkCityStatus];
                    isShowLocalTest = YES;
                    self.isFromLocalTestChange = YES;
                }else
                {
                    isShowLocalTest = NO;
                    self.isFromLocalTestChange = NO;
                }
                
                return;
            }
            
            self.isFirstChange = NO;
            
            //防止二次刷新
            if ([FHEnvContext sharedInstance].isRefreshFromCitySwitch && (configDataModel.cityAvailability.enable == YES || self.isFirstChange)&& ![FHEnvContext sharedInstance].isRefreshFromAlertCitySwitch) {
                return;
            }
            //刷新头部
            [self reloadHomeTableHeaderSection];
            
            //清除缓存数据
            [self resetAllCacheData];
            
            //请求推荐房源
            [self requestOriginData:self.isFirstChange];
            
        }];
        
        //切换推荐房源类型
        self.categoryView.clickIndexCallBack = ^(NSInteger indexValue) {
            StrongSelf;
            
            if (self.requestRefreshTask != nil || self.requestOriginTask != nil) {
                return ;
            }
            
            //上报stay埋点
            [self sendTraceEvent:FHHomeCategoryTraceTypeStay];
            
            //收起tip
            [self.homeViewController hideImmediately];
            
            //设置当前房源类型
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
                
                //判断是否已有缓存数据，如有则直接使用缓存
                if (modelsCache != nil && kIsNSArray(modelsCache) && modelsCache.count !=0) {
                    [[FHEnvContext sharedInstance].generalBizConfig updateUserSelectDiskCacheIndex:@(self.currentHouseType)];
                    [self reloadHomeTableForSwitchFromCache:modelsCache];
                    self.stayTime = [self getCurrentTime];
                    //更新切换
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
        [self.refreshFooter setUpNoMoreDataText:@"没有更多信息了" offsetY:3];
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

//初始缓存对象
- (void)initItemsCaches
{
    self.itemsDataCache = [NSMutableDictionary new];
    self.itemsSearchIdCache = [NSMutableDictionary new];
    self.originSearchIdCache = [NSMutableDictionary new];
    self.isItemsHasMoreCache = [NSMutableDictionary new];
    [self.dataSource resetTraceCahce];
}

//检测10秒内网络请求是否有返回，确保首页异常时可以自动恢复
- (void)checkoutIsRequestCanCallBack:(NSNumber *)isHasCallBack
{
    if (!_isHasCallBackForFirstTime) {
        if ([self.requestOriginTask isKindOfClass:[TTHttpTask class]]) {
            [self.requestOriginTask cancel];
            self.requestOriginTask = nil;
        }
        
        if ([FHEnvContext isNetworkConnected]) {
            [self requestOriginData:NO];
        }
    }
}

//请求房源推荐数据
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
    
    if ([self.requestOriginTask isKindOfClass:[TTHttpTask class]]) {
        [self.requestOriginTask cancel];
        self.requestOriginTask = nil;
    }
    
    self.categoryView.segmentedControl.userInteractionEnabled = NO;
    
    if(isFirstChange)
    {
        //10秒还没有请求回调则进行尝试新请求
        [self performSelector:@selector(checkoutIsRequestCanCallBack:) withObject:nil afterDelay:10];
    }
    
    WeakSelf;
    self.requestOriginTask = [FHHomeRequestAPI requestRecommendFirstTime:requestDictonary completion:^(FHHomeHouseModel * _Nonnull model, NSError * _Nonnull error) {
        StrongSelf;
        
        self.requestOriginTask = nil;
        
        self.isHasCallBackForFirstTime = YES;
        if (!model || error) {
            
            if (isFirstChange) {
                //首次请求失败尝试重试一次
                [self requestOriginData:NO];
                return;
            }
            
            if (![FHEnvContext isNetworkConnected]) {
                [self.homeViewController.emptyView showEmptyWithTip:@"网络异常，请检查网络连接" errorImage:[UIImage imageNamed:@"group-4"] showRetry:YES];
            }else
            {
                [self.homeViewController.emptyView showEmptyWithTip:@"数据走丢了" errorImage:[UIImage imageNamed:@"group-8"] showRetry:YES];
            }
            self.tableViewV.hidden = YES;
            self.categoryView.segmentedControl.userInteractionEnabled = YES;
            [FHEnvContext sharedInstance].isRefreshFromAlertCitySwitch = NO;
            return;
        }
        
        [[FHEnvContext sharedInstance].generalBizConfig updateUserSelectDiskCacheIndex:@(self.currentHouseType)];
        
        if (model.data.items.count == 0) {
            self.tableViewV.hidden = YES;
            
            if ([[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CHANNEL_NAME"] isEqualToString:@"local_test"])
            {
                self.isFromLocalTestChange = YES;
                [self checkCityStatus];
                self.categoryView.segmentedControl.userInteractionEnabled = YES;
                [FHEnvContext sharedInstance].isRefreshFromAlertCitySwitch = NO;
                return;
            }
            
            if (![[FHEnvContext sharedInstance] getConfigFromCache].cityAvailability.enable.boolValue) {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    dispatch_async(dispatch_get_main_queue(), ^{
                        self.isFromLocalTestChange = YES;
                        [self checkCityStatus];
                    });
                });
                self.categoryView.segmentedControl.userInteractionEnabled = YES;
                [FHEnvContext sharedInstance].isRefreshFromAlertCitySwitch = NO;
                return;
            }
        }
        
        //缓存房源数据
        NSString *cahceKey = [self getCurrentHouseTypeChacheKey];
        if (kIsNSString(cahceKey)) {
            self.itemsDataCache[cahceKey] = model.data.items;
        }
        
        //缓存oirigin searchid
        if (kIsNSString(cahceKey)) {
            self.originSearchIdCache[cahceKey] = model.data.searchId;
        }
        
        //缓存searchid
        if (kIsNSString(cahceKey)) {
            self.itemsSearchIdCache[cahceKey] = model.data.searchId;
        }
        
        //缓存loadmore状态
        if (kIsNSString(cahceKey) && model.data.hasMore != nil) {
            self.isItemsHasMoreCache[cahceKey] = @(model.data.hasMore);
        }
        
        //结束刷新态
        [self.tableViewV finishPullDownWithSuccess:YES];
        [self reloadHomeTableHouseSection:model.data.items];
        
        
        self.tableViewV.hasMore = model.data.hasMore;
        [self updateTableViewWithMoreData:model.data.hasMore];
        
        self.hasShowedData = YES;
        
        [[FHEnvContext sharedInstance] updateOriginFrom:[self pageTypeString] originSearchId:model.data.searchId];
        
        [self sendTraceEvent:FHHomeCategoryTraceTypeEnter];
        
        if ([[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CHANNEL_NAME"] isEqualToString:@"local_test"])
        {
            //过滤多余tip提示
            if ((((model.data.refreshTip && ![FHEnvContext sharedInstance].isRefreshFromCitySwitch) || ![FHEnvContext sharedInstance].isSendConfigFromFirstRemote) || [FHEnvContext sharedInstance].isRefreshFromAlertCitySwitch) || (self.isFromLocalTestChange && [FHEnvContext sharedInstance].isRefreshFromCitySwitch)) {
                [self.homeViewController showNotify:model.data.refreshTip];
                self.tableViewV.contentOffset = CGPointMake(0, 0);
                [self.tableViewV scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
            }
        }else
        {
            //过滤多余tip提示
            if ((model.data.refreshTip && (![FHEnvContext sharedInstance].isRefreshFromCitySwitch) || ![FHEnvContext sharedInstance].isSendConfigFromFirstRemote || [FHEnvContext sharedInstance].isRefreshFromAlertCitySwitch)) {
                [self.homeViewController showNotify:model.data.refreshTip];
                self.tableViewV.contentOffset = CGPointMake(0, 0);
                [self.tableViewV scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
            }
        }
        
        self.isFromLocalTestChange = NO;
        
        [FHEnvContext sharedInstance].isRefreshFromAlertCitySwitch = NO;
        
        [FHEnvContext sharedInstance].isRefreshFromCitySwitch = NO;
        
        self.stayTime = [self getCurrentTime];
        self.dataSource.originSearchId = model.data.searchId;
        self.tableViewV.hidden = NO;
        [self checkLoadingAndEmpty];
        
        self.categoryView.segmentedControl.userInteractionEnabled = YES;
    }];
}

//请求推荐刷新数据，包括上拉和下拉
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
    
    if ([self.requestRefreshTask isKindOfClass:[TTHttpTask class]]) {
        [self.requestRefreshTask cancel];
        self.requestRefreshTask = nil;
    }
    
    self.categoryView.segmentedControl.userInteractionEnabled = NO;
    WeakSelf;
    self.requestRefreshTask = [FHHomeRequestAPI requestRecommendForLoadMore:requestDictonary completion:^(FHHomeHouseModel * _Nonnull model, NSError * _Nonnull error) {
        StrongSelf;
        
        self.requestRefreshTask = nil;
        
        [FHEnvContext sharedInstance].isRefreshFromAlertCitySwitch = NO;
        
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
        
        [[FHEnvContext sharedInstance].generalBizConfig updateUserSelectDiskCacheIndex:@(self.currentHouseType)];
        
        //判断下拉刷新
        if (pullType == FHHomePullTriggerTypePullDown) {
            
            if ((model.data.items.count == 0 && self.dataSource.modelsArray.count == 0 && !error) || ![[FHEnvContext sharedInstance] getConfigFromCache].cityAvailability.enable.boolValue) {
                self.tableViewV.hidden = YES;
                self.isFromLocalTestChange = YES;
                [self checkCityStatus];
                
                
                if ([[FHEnvContext sharedInstance] getConfigFromCache].cityAvailability.enable.boolValue) {
                    [self.homeViewController.emptyView showEmptyWithTip:@"数据走丢了" errorImage:[UIImage imageNamed:@"group-8"] showRetry:YES];
                }
                
                self.categoryView.segmentedControl.userInteractionEnabled = YES;
                return;
            }else
            {
                if (error && self.dataSource.modelsArray.count == 0) {
                    [self.homeViewController.emptyView showEmptyWithTip:@"数据走丢了" errorImage:[UIImage imageNamed:@"group-8"] showRetry:YES];
                    return;
                }else
                {
                    if (error) {
                        [[ToastManager manager] showToast:@"网络异常"];
                        return;
                    }
                }
            }
            
            
            if (model.data.items.count == 0 && self.dataSource.modelsArray.count != 0) {
                if (self.isRetryedPullDownRefresh) {
                    self.isRetryedPullDownRefresh = NO;
                    [self.tableViewV finishPullDownWithSuccess:YES];
                    [self requestDataForRefresh:FHHomePullTriggerTypePullDown];
                }else
                {
                    [self.tableViewV finishPullDownWithSuccess:YES];
                }
                
                self.categoryView.segmentedControl.userInteractionEnabled = YES;
                return;
            }
        }
        
        self.isRetryedPullDownRefresh = NO;
        
        //缓存origin searchid
        if (kIsNSString(cahceKey) && pullType == FHHomePullTriggerTypePullDown) {
            self.originSearchIdCache[cahceKey] = model.data.searchId;
        }
        
        //缓存search id
        if (kIsNSString(cahceKey) && model.data.searchId) {
            self.itemsSearchIdCache[cacheKey] = model.data.searchId;
        }
        
        //缓存load more状态
        if (kIsNSString(cahceKey) && model.data.hasMore != nil) {
            self.isItemsHasMoreCache[cacheKey] = @(model.data.hasMore);
        }
        
        [self.tableViewV finishPullDownWithSuccess:YES];
        [self.tableViewV finishPullUpWithSuccess:YES];
        [self reloadHomeTableHouseSection:self.itemsDataCache[cacheKey]];
        
        
        self.tableViewV.hasMore = model.data.hasMore;
        [self updateTableViewWithMoreData:model.data.hasMore];
        
        [self checkLoadingAndEmpty];
        
        [self sendTraceEvent:FHHomeCategoryTraceTypeRefresh];
        
        if (model.data.refreshTip && pullType == FHHomePullTriggerTypePullDown) {
            [FHEnvContext sharedInstance].isRefreshFromAlertCitySwitch = NO;
            [self.homeViewController showNotify:model.data.refreshTip];
            self.tableViewV.contentOffset = CGPointMake(0, 0);
            [self.tableViewV scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
        }
        
        self.categoryView.segmentedControl.userInteractionEnabled = YES;
    }];
}

//清除所有缓存数据
- (void)resetAllCacheData
{
    [self.itemsDataCache removeAllObjects];
    [self.itemsSearchIdCache removeAllObjects];
    [self.originSearchIdCache removeAllObjects];
    [self.isItemsHasMoreCache removeAllObjects];
}

//清除所有缓存数据
- (void)resetAllOthersCacheData
{
    for (NSString *key in self.itemsDataCache.allKeys) {
        if (![key isEqualToString:[self getCurrentHouseTypeChacheKey]]) {
            [self.itemsDataCache removeObjectForKey:key];
        }
    }
    
    for (NSString *key in self.itemsSearchIdCache.allKeys) {
        if (![key isEqualToString:[self getCurrentHouseTypeChacheKey]]) {
            [self.itemsSearchIdCache removeObjectForKey:key];
        }
    }
    
    for (NSString *key in self.originSearchIdCache.allKeys) {
        if (![key isEqualToString:[self getCurrentHouseTypeChacheKey]]) {
            [self.originSearchIdCache removeObjectForKey:key];
        }
    }
    
    for (NSString *key in self.isItemsHasMoreCache.allKeys) {
        if (![key isEqualToString:[self getCurrentHouseTypeChacheKey]]) {
            [self.isItemsHasMoreCache removeObjectForKey:key];
        }
    }
}

//清除当前选中的缓存数据
- (void)resetCurrentHouseCacheData
{
    [self.itemsDataCache removeObjectForKey:[self getCurrentHouseTypeChacheKey]];
    [self.itemsSearchIdCache removeObjectForKey:[self getCurrentHouseTypeChacheKey]];
    [self.originSearchIdCache removeObjectForKey:[self getCurrentHouseTypeChacheKey]];
    [self.isItemsHasMoreCache removeObjectForKey:[self getCurrentHouseTypeChacheKey]];
    [self.dataSource resetTraceCahce];
}

//更新房源切换选择器
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

//匹配房源名称
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

//检测加载情况，去除圆圈loading
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

- (void)checkCityStatus
{
    if (![[FHEnvContext sharedInstance] getConfigFromCache].cityAvailability.enable.boolValue) {
        [self.homeViewController.view sendSubviewToBack:self.tableViewV];
        [self.homeViewController.emptyView showEmptyWithTip:@"当前城市暂未开通服务，敬请期待" errorImage:[UIImage imageNamed:@"group-9"] showRetry:NO];
    }
}

- (BOOL)checkIsHasFindHouse
{
    return [[[TTArticleCategoryManager sharedManager] allCategories] containsObject:[TTArticleCategoryManager categoryModelByCategoryID:@"f_find_house"]];
}

//重载首页头部数据
- (void)reloadHomeTableHeaderSection
{
    self.dataSource.showPlaceHolder = YES;
    self.dataSource.currentHouseType = self.currentHouseType;
    self.dataSource.isHasFindHouseCategory = [self checkIsHasFindHouse];
    if (self.tableViewV.numberOfSections > kFHHomeListHeaderBaseViewSection) {
        [UIView performWithoutAnimation:^{
            [self.tableViewV reloadData];
        }];
    }
}


//重载当前请求数据
- (void)reloadHomeTableHouseSection:(NSArray <JSONModel *> *)models
{
    if (models.count == 0) {
        return;
    }
    
    self.dataSource.showPlaceHolder = NO;
    self.dataSource.modelsArray = models;
    self.dataSource.currentHouseType = self.currentHouseType;
    self.dataSource.isHasFindHouseCategory = [self checkIsHasFindHouse];
    if (self.tableViewV.numberOfSections > kFHHomeListHouseBaseViewSection) {
        [self.tableViewV reloadData];
    }
}

//重载当前缓存数据
- (void)reloadHomeTableForSwitchFromCache:(NSArray <JSONModel *> *)models
{
    if (kIsNSArray(models)) {
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
