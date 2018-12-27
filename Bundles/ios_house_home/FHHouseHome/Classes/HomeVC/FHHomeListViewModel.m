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
@property (nonatomic, strong) NSMutableDictionary <NSString *, NSArray <FHHomeHouseDataItemsModel *> *>* itemsDataCache;
@property (nonatomic, strong) NSMutableDictionary <NSString *, NSString *>* itemsSearchIdCache;
@property (nonatomic, strong) NSMutableDictionary <NSString *, NSNumber *>* isItemsHasMoreCache;
@property (nonatomic, strong) NSMutableDictionary <NSString *, NSArray <NSIndexPath *> *>* itemsTraceCache;
@end

@implementation FHHomeListViewModel

- (instancetype)initWithViewController:(UITableView *)tableView andViewController:(FHHomeViewController *)homeVC
{
    self = [super init];
    if (self) {
        [self initItemsCaches];
        
        self.categoryView = [FHHomeSectionHeader new];
        self.tableViewV = tableView;
        self.homeViewController = homeVC;
        self.dataSource = [FHHomeMainTableViewDataSource new];
        self.dataSource.categoryView = self.categoryView;
        self.dataSource.showPlaceHolder = YES;
        self.tableViewV.delegate = self.dataSource;
        self.tableViewV.dataSource = self.dataSource;

        self.tableViewV.hasMore = YES;
        
        WeakSelf;
        // 下拉刷新，修改tabbar条和请求数据
        [self.tableViewV tt_addDefaultPullUpLoadMoreWithHandler:^{
            StrongSelf;
            
        }];
        
        [self.tableViewV tt_addDefaultPullDownRefreshWithHandler:^{
            StrongSelf;
            [self resetAllCacheData];
            [self requestOriginData];
        }];
        
        FHConfigDataModel *configDataModel = [[FHEnvContext sharedInstance] getConfigFromCache];
        //订阅config变化发送网络请求
        __block BOOL isFirstChange = YES;
        [[FHHomeConfigManager sharedInstance].configDataReplay subscribeNext:^(id  _Nullable x) {
            StrongSelf;
            //过滤多余刷新
            if (configDataModel == [[FHEnvContext sharedInstance] getConfigFromCache] && !isFirstChange) {
                return;
            }
            [self reloadHomeTableHeaderSection];
            
            [self updateCategoryViewSegmented];
            
            isFirstChange = NO;
        }];
        
        self.categoryView.clickIndexCallBack = ^(NSInteger indexValue) {
            
            NSString *urlStr = @"http://10.1.10.250:8080/#/test";
//            NSString *urlStr = @"http://s.pstatp.com/site/lib/js_sdk/";
//            NSString *urlStr = @"http://s.pstatp.com/site/tt_mfsroot/test/main.html";
            
            NSString *unencodedString = urlStr;
            NSString *encodedString = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                                      (CFStringRef)unencodedString,
                                                                      NULL,
                                                                      (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                                      kCFStringEncodingUTF8));

        
            urlStr = [NSString stringWithFormat:@"sslocal://webview?url=%@",encodedString];
    
            NSURL *url = [TTURLUtils URLWithString:urlStr];
            [[TTRoute sharedRoute] openURLByPushViewController:url];
            return ;
//
            StrongSelf;
            if (configDataModel.houseTypeList.count > indexValue) {
                NSNumber *numberType = [configDataModel.houseTypeList objectAtIndex:indexValue];
                if ([numberType isKindOfClass:[NSNumber class]]) {
                    self.currentHouseType = [numberType integerValue];
                }
            }
            NSString *cacheKey = [self getCurrentHouseTypeChacheKey];
            
            if (kIsNSString(cacheKey)) {
                NSArray *modelsCache = self.itemsDataCache[cacheKey];
                if (modelsCache != nil && kIsNSArray(modelsCache) && modelsCache.count !=0) {
                    [self reloadHomeTableForSwitchFromCache:modelsCache];
                }else
                {
                    [self requestOriginData];
                }
            }else
            {
                [self requestOriginData];
            }
        };
        
    }
    return self;
}

- (NSString *)getCurrentHouseTypeChacheKey
{
    return [self matchHouseString:self.currentHouseType];
}

- (void)initItemsCaches
{
    self.itemsDataCache = [NSMutableDictionary new];
    self.itemsSearchIdCache = [NSMutableDictionary new];
    self.isItemsHasMoreCache = [NSMutableDictionary new];
    self.itemsTraceCache = [NSMutableDictionary new];
}

- (void)requestOriginData
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
        NSString *cahceKey = [self getCurrentHouseTypeChacheKey];
        if (kIsNSString(cahceKey)) {
            self.itemsDataCache[cahceKey] = model.data.items;
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
    }];
}


- (void)requestDataForRefresh:(FHHomePullTriggerType)pullType
{
    NSMutableDictionary *requestDictonary = [NSMutableDictionary new];
    [requestDictonary setValue:[FHEnvContext getCurrentSelectCityIdFromLocal] forKey:@"city_id"];
    NSString *cahceKey = [self getCurrentHouseTypeChacheKey];
    NSInteger offsetValue = 20;
    if (kIsNSString(cahceKey)) {
        offsetValue = self.itemsDataCache[cahceKey].count;
    }
    [requestDictonary setValue:@(offsetValue) forKey:@"offset"];
    [requestDictonary setValue:@"2" forKey:@"house_type"];
    [requestDictonary setValue:@(20) forKey:@"count"];
    [requestDictonary setValue:@(20) forKey:@"search_id"];
    
    self.categoryView.segmentedControl.userInteractionEnabled = NO;
    WeakSelf;
    [FHHomeRequestAPI requestRecommendForLoadMore:requestDictonary completion:^(FHHomeHouseModel * _Nonnull model, NSError * _Nonnull error) {
        StrongSelf;
        
        self.categoryView.segmentedControl.userInteractionEnabled = YES;
    }];
}

- (void)resetAllCacheData
{
    [self.itemsDataCache removeAllObjects];
    [self.itemsSearchIdCache removeAllObjects];
    [self.isItemsHasMoreCache removeAllObjects];
}

- (void)updateCategoryViewSegmented
{
    NSNumber *numberIndex = [[FHEnvContext sharedInstance].generalBizConfig getUserSelectIndexDiskCache];
    NSInteger indexValue = 0;
    if ([numberIndex isKindOfClass:[NSNumber class]]) {
        indexValue = [numberIndex integerValue];
    }
    [self.categoryView updateSegementedTitles:[self matchHouseSegmentedTitleArray]  andSelectIndex:indexValue];
    NSArray *houstTypeList = [[FHEnvContext sharedInstance] getConfigFromCache].houseTypeList;
    if (houstTypeList.count > indexValue) {
        NSNumber *numberType = [[[FHEnvContext sharedInstance] getConfigFromCache].houseTypeList objectAtIndex:indexValue];
        if ([numberType isKindOfClass:[NSNumber class]]) {
            self.currentHouseType = [numberType integerValue];
        }
    }else
    {
        if (houstTypeList.count > 0 && [houstTypeList.firstObject respondsToSelector:@selector(integerValue)]) {
            self.currentHouseType = [houstTypeList.firstObject integerValue];
        }else
        {
            self.currentHouseType = FHHouseTypeSecondHandHouse;
        }
    }

    [self requestOriginData];
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


- (void)reloadHomeTableHeaderSection
{
    self.dataSource.showPlaceHolder = YES;
    
    if (self.tableViewV.numberOfSections > kFHHomeListHeaderBaseViewSection) {
        [UIView performWithoutAnimation:^{
            [self.tableViewV reloadData];
//        [self.tableViewV reloadSections:[NSIndexSet indexSetWithIndex:kFHHomeListHeaderBaseViewSection] withRowAnimation:UITableViewRowAnimationNone];
        }];
    }
}

- (void)reloadHomeTableHouseSection:(NSArray <JSONModel *> *)models
{
    self.dataSource.showPlaceHolder = NO;
    self.dataSource.modelsArray = models;
    
    NSLog(@"models oucnt = %d", models.count);

    if (self.tableViewV.numberOfSections > kFHHomeListHouseBaseViewSection) {
        [self.tableViewV reloadData];
//        [UIView performWithoutAnimation:^{
//            [self.tableViewV reloadSections:[NSIndexSet indexSetWithIndex:kFHHomeListHouseBaseViewSection] withRowAnimation:UITableViewRowAnimationNone];
//        }];
    }
}

- (void)reloadHomeTableForSwitchFromCache:(NSArray <JSONModel *> *)models
{
    if (kIsNSArray(models)) {
        self.dataSource.modelsArray = models;
        [self.tableViewV reloadData];
    }
}

@end
