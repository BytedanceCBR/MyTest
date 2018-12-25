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

@interface FHHomeListViewModel()

@property (nonatomic, strong) UITableView *tableViewV;
@property (nonatomic, assign) BOOL showPlaceHolder;
@property (nonatomic, strong) FHHomeMainTableViewDataSource *dataSource;
@property (nonatomic, strong) FHHomeViewController *homeViewController;
@property (nonatomic, strong) FHHomeSectionHeader *categoryView;
@property (nonatomic, assign) FHHouseType currentHouseType;

@end

@implementation FHHomeListViewModel

- (instancetype)initWithViewController:(UITableView *)tableView andViewController:(FHHomeViewController *)homeVC
{
    self = [super init];
    if (self) {
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
            [self requestOriginData];
        }];
        
        FHConfigDataModel *configDataModel = [[FHEnvContext sharedInstance] getConfigFromCache];
        //订阅config变化发送网络请求
        __block BOOL isFirstChange = YES;
        [[FHHomeConfigManager sharedInstance].configDataReplay subscribeNext:^(id  _Nullable x) {
            StrongSelf;
            //过滤多余刷新
            if (configDataModel == [[FHEnvContext sharedInstance] getConfigFromCache] && !isFirstChange) {
                return ;
            }
            [self reloadHomeTableHeaderSection];
            
            [self updateCategoryViewSegmented];
            
            isFirstChange = NO;
        }];
    }
    return self;
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

    WeakSelf;
    [FHHomeRequestAPI requestRecommendFirstTime:requestDictonary completion:^(FHHomeHouseModel * _Nonnull model, NSError * _Nonnull error) {
        StrongSelf;
        [self.tableViewV finishPullDownWithSuccess:YES];
        [self reloadHomeTableHouseSection:model.data.items];
    }];
}

- (void)requestDataForLoadMore
{
    NSMutableDictionary *requestDictonary = [NSMutableDictionary new];
    [requestDictonary setValue:[FHEnvContext getCurrentSelectCityIdFromLocal] forKey:@"city_id"];
    [requestDictonary setValue:@(0) forKey:@"offset"];
    [requestDictonary setValue:@"2" forKey:@"house_type"];
    [requestDictonary setValue:@(20) forKey:@"count"];
    [requestDictonary setValue:@(20) forKey:@"search_id"];
    WeakSelf;
    [FHHomeRequestAPI requestRecommendForLoadMore:requestDictonary completion:^(FHHomeHouseModel * _Nonnull model, NSError * _Nonnull error) {
        StrongSelf;
    }];
}

- (void)updateCategoryViewSegmented
{
    NSNumber *numberIndex = [[FHEnvContext sharedInstance].generalBizConfig getUserSelectIndexDiskCache];
    NSInteger indexValue = 0;
    if ([numberIndex isKindOfClass:[NSNumber class]]) {
        indexValue = [numberIndex integerValue];
    }
    [self.categoryView updateSegementedTitles:[self matchHouseSegmentedTitleArray]  andSelectIndex:indexValue];
    self.currentHouseType = indexValue;
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
    
    if (self.tableViewV.numberOfSections > kFHHomeListHouseBaseViewSection) {
        [self.tableViewV reloadData];
//        [UIView performWithoutAnimation:^{
//            [self.tableViewV reloadSections:[NSIndexSet indexSetWithIndex:kFHHomeListHouseBaseViewSection] withRowAnimation:UITableViewRowAnimationNone];
//        }];
    }
}
@end
