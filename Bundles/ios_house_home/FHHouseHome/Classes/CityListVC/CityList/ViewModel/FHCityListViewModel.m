//
//  FHCityListViewModel.m
//  FHHouseHome
//
//  Created by 张元科 on 2018/12/26.
//

#import "FHCityListViewModel.h"
#import "FHCityListCell.h"
#import "FHEnvContext.h"
#import "YYCache.h"
#import "FHCityListModel.h"
#import "FHLocManager.h"
#import "FHUtils.h"
#import "FHIndexSectionView.h"
#import "FHUserTracker.h"
#import "FHHouseSwitchCityDelegate.h"
#import "FHPopupViewManager.h"

#define kCityListItemCellId @"city_list_item_cell_id"
#define kCityListHotItemCellId @"city_list_hot_item_cell_id"

static const NSString *kHistoryCityCacheKey = @"cache_country_list_history";
static const NSString *kFHHistoryListKey = @"key_history_list";

@interface FHCityListViewModel ()<UITableViewDelegate,UITableViewDataSource,FHHouseSwitchCityDelegate>

@property(nonatomic , weak) UITableView *tableView;
@property(nonatomic , weak) FHCityListViewController *listController;

@property (nonatomic, strong , nullable) NSArray<FHConfigDataHotCityListModel> *hotCityList;
@property (nonatomic, strong , nullable) NSArray<FHConfigDataCityListModel> *cityList;
@property (nonatomic, strong , nullable) NSArray<FHHistoryCityListModel> *historyCityList;
@property (nonatomic, strong) NSMutableArray    *sectionsKeyData;
@property (nonatomic, strong) NSMutableArray    *sectionsData;
@property (nonatomic, assign)   NSInteger       mainCount; // 历史 + 热门 + 其他 (共3种 目的为了计算行高等)

@property (nonatomic, strong)   YYCache       *historyCache;

@end

@implementation FHCityListViewModel

-(instancetype)initWithController:(FHCityListViewController *)viewController tableView:(UITableView *)tableView {
    self = [super init];
    if (self) {
        self.listController = viewController;
        self.tableView = tableView;
        [self configTableView];
        [self loadListCityData:[[FHEnvContext sharedInstance] getConfigFromCache]];
    }
    return self;
}

- (instancetype)init
{
    return [self initWithController:nil tableView:nil];
}

- (void)setCityList:(NSArray<FHConfigDataCityListModel> *)cityList {
    _cityList = cityList;
}

-(void)configTableView
{
    _tableView.delegate = self;
    _tableView.dataSource = self;
    
    [_tableView registerClass:[FHCityItemCell class] forCellReuseIdentifier:kCityListItemCellId];
    [_tableView registerClass:[FHCityHotItemCell class] forCellReuseIdentifier:kCityListHotItemCellId];
}

- (YYCache *)historyCache
{
    if (!_historyCache) {
        _historyCache = [YYCache cacheWithName:kHistoryCityCacheKey];
    }
    return _historyCache;
}

- (void)loadListCityData:(FHConfigDataModel *)configDataModel {
    self.cityList = NULL;
    self.hotCityList = NULL;
    self.historyCityList = NULL;
    self.cityList = [configDataModel cityList];
    self.hotCityList = [configDataModel hotCityList];
    [self loadHistoryData];
    [self configSectionData];
    [self.tableView reloadData];
}

// 加载历史数据
- (void)loadHistoryData {
    NSString *historyStr = [self.historyCache objectForKey:kFHHistoryListKey];
    if (historyStr.length > 0) {
        JSONModelError *jerror = nil;
        FHHistoryCityCacheModel *cacheData = [[FHHistoryCityCacheModel alloc] initWithString:historyStr error:&jerror];
        if (cacheData && !jerror) {
            self.historyCityList = cacheData.datas;
        }
    }
}

// 保存历史记录数据
- (void)saveHistoryData {
    if (self.historyCityList) {
        FHHistoryCityCacheModel *cacheModel = [[FHHistoryCityCacheModel alloc] init];
        cacheModel.datas = self.historyCityList;
        NSString *saveStr = [cacheModel toJSONString];
        if (saveStr.length > 0) {
            [self.historyCache setObject:saveStr forKey:kFHHistoryListKey];
        }
    }
}

// 历史最多8个
- (void)addCityToHistory:(id)city {
    if (city) {
        // YES 说明当前城市是选择过的城市，而且如果未选择过城市，其他页面不让跳转
        [FHUtils setContent:@(YES) forKey:kUserHasSelectedCityKey];
        // 进历史
        NSString *name = NULL;
        NSString *simplePinyin = NULL;
        NSString *cityId = NULL;
        NSString *pinyin = NULL;
        if ([city isKindOfClass:[FHConfigDataCityListModel class]]) {
            // 城市
            FHConfigDataCityListModel *item = city;
            name = item.name;
            cityId = item.cityId;
            pinyin = item.fullPinyin;
            simplePinyin = item.simplePinyin;
        } else if ([city isKindOfClass:[FHConfigDataHotCityListModel class]]) {
            // 热门
            FHConfigDataHotCityListModel *item = city;
            name = item.name;
            cityId = item.cityId;
            pinyin = @"";
            simplePinyin = @"";
        } else if ([city isKindOfClass:[FHHistoryCityListModel class]]) {
            FHHistoryCityListModel *item = city;
            // 历史
            name = item.name;
            cityId = item.cityId;
            pinyin = item.pinyin;
            simplePinyin = item.simplePinyin;
        } else if ([city isKindOfClass:[FHCitySearchDataDataModel class]]) {
            FHCitySearchDataDataModel *item = city;
            // 城市搜索
            name = item.name;
            cityId = item.cityId;
            pinyin = item.fullPinyin;
            simplePinyin = item.simplePinyin;
        } else {
            //
        }
        if (cityId.length > 0) {
            NSMutableArray *tempHisArray = [NSMutableArray new];
            // 去除相同的城市
            for (FHHistoryCityListModel *obj in self.historyCityList) {
                if (![obj.cityId isEqualToString:cityId]) {
                    [tempHisArray addObject:obj];
                }
            }
            // 添加现有的
            FHHistoryCityListModel *tempHistoryData = [[FHHistoryCityListModel alloc] init];
            tempHistoryData.name = name;
            tempHistoryData.cityId = cityId;
            tempHistoryData.pinyin = pinyin;
            tempHistoryData.simplePinyin = simplePinyin;
            [tempHisArray insertObject:tempHistoryData atIndex:0];
            if (tempHisArray.count > 8) {
                NSRange range = NSMakeRange(0, 8);
                tempHisArray = [tempHisArray subarrayWithRange:range];
            }
            self.historyCityList = tempHisArray;
            [self saveHistoryData];
        }
    }
}

// 构建列表页数据
- (void)configSectionData {
    _mainCount = 1;
    _sectionsKeyData = [[NSMutableArray alloc] init];
    _sectionsData = [[NSMutableArray alloc] init];
    
    // 历史
    if (self.historyCityList.count > 0) {
        [self.sectionsData addObject:self.historyCityList];
        [self.sectionsKeyData addObject:@"历史"];
        _mainCount += 1;
    }
    // 热门
    if (self.hotCityList.count > 0) {
        [self.sectionsData addObject:self.hotCityList];
        [self.sectionsKeyData addObject:@"热门"];
        _mainCount += 1;
    }
    // A B C
    [self analyseCities];
}

-(void)analyseCities
{
    NSMutableDictionary *citiesDict = [NSMutableDictionary new];
    
    for (FHConfigDataCityListModel *city in self.cityList) {
        // 服务端返回为空，需要做兼容判断，但是会导致当前城市不在城市列表
        if (city.simplePinyin.length == 0) {
            continue;
        }
        NSString *alp = [[city.simplePinyin substringWithRange:NSMakeRange(0, 1)] uppercaseString];
        if (!citiesDict[alp]) {
            citiesDict[alp] = [NSMutableArray new];
        }
        NSMutableArray *cities = citiesDict[alp];
        [cities addObject:city];
    }
    
    NSArray *keys = [[citiesDict allKeys] sortedArrayUsingComparator:^NSComparisonResult(NSString *  _Nonnull obj1, NSString *  _Nonnull obj2) {
        return [obj1 compare:obj2];
    }];
    
    if (keys.count > 0) {
        // add cities
        for (NSString *key in keys) {
            NSArray *cities = citiesDict[key];
            [self.sectionsData addObject:cities];
        }
        [self.sectionsKeyData addObjectsFromArray:keys];
    }
    // 添加索引
    if (self.sectionsKeyData.count > 0) {
        [self.listController addSectionIndexs:self.sectionsKeyData];
    }
}

- (void)hotOrHistoryCityItemClickBySection:(NSInteger)section index:(NSInteger)index {
    // 历史和热门
    if (section < self.mainCount - 1) {
        if (self.mainCount == 3) {
            // 有历史和热门
            if (section == 0) {
                // 历史
                [self historyItemClick:index];
            } else if (section == 1) {
                // 热门
                [self hotItemClick:index];
            } else {
                // 没有历史且没有热门
            }
        } else if (self.mainCount == 2) {
            // 有历史或者有热门
            if (self.historyCityList.count > 0) {
                // 历史
                [self historyItemClick:index];
            } else if (self.hotCityList.count > 0) {
                // 热门
                [self hotItemClick:index];
            } else {
                // 没有历史且没有热门
            }
        } else {
            // 没有历史且没有热门
        }
    }
}

- (void)historyItemClick:(NSInteger)index {
    if (index >= 0 && index < self.historyCityList.count) {
        FHHistoryCityListModel *item = self.historyCityList[index];
        [self addCityFilterTracer:item.name queryType:@"history"];
        __weak typeof(self) wSelf = self;
        [self switchCityByCityId:item.cityId switchCompletion:^(BOOL isSuccess) {
            if (isSuccess) {
                [wSelf addCityToHistory:item];
            }
        }];
    }
}

- (void)hotItemClick:(NSInteger)index {
    if (index >= 0 && index < self.hotCityList.count) {
        FHConfigDataHotCityListModel *item = self.hotCityList[index];
        [self addCityFilterTracer:item.name queryType:@"hot"];
        __weak typeof(self) wSelf = self;
        [self switchCityByCityId:item.cityId switchCompletion:^(BOOL isSuccess) {
            if (isSuccess) {
                [wSelf addCityToHistory:item];
            }
        }];
    }
}

- (void)cellItemClick:(FHConfigDataCityListModel *)item {
    __weak typeof(self) wSelf = self;
    [self addCityFilterTracer:item.name queryType:@"list"];
    [self switchCityByCityId:item.cityId switchCompletion:^(BOOL isSuccess) {
        if (isSuccess) {
            [wSelf addCityToHistory:item];
        }
    }];
}

// 城市搜索
- (void)searchCellItemClick:(FHCitySearchDataDataModel *)item {
    __weak typeof(self) wSelf = self;
    [self switchCityByCityId:item.cityId switchCompletion:^(BOOL isSuccess) {
        if (isSuccess) {
            [wSelf addCityToHistory:item];
        }
    }];
}

- (void)cityNameBtnClick {
    if ([FHLocManager sharedInstance].currentReGeocode && [FHLocManager sharedInstance].isLocationSuccess) {
        AMapLocationReGeocode * currentReGeocode = [FHLocManager sharedInstance].currentReGeocode;
        __weak typeof(self) wSelf = self;
        // 特殊处理，当前定位城市，选择cityid为0，结果返回后，用结果数据存历史
        [self switchCityByCityId:@"0" switchCompletion:^(BOOL isSuccess) {
            if (isSuccess) {
                NSString *cityName = [[[FHEnvContext sharedInstance] generalBizConfig] configCache].currentCityName;
                NSString *cityId = [[[FHEnvContext sharedInstance] generalBizConfig] configCache].currentCityId;
                FHHistoryCityListModel *item = NULL;
                if (cityId.length > 0) {
                    for (FHConfigDataCityListModel *obj in wSelf.cityList) {
                        if ([obj.cityId isEqualToString:cityId]) {
                            item = obj;
                            break;
                        }
                    }
                }
                if (item) {
                    [wSelf addCityToHistory:item];
                }
            }
        }];
    }
}

- (void)switchCityByOpenUrlSuccess {
    NSString *cityName = [[[FHEnvContext sharedInstance] generalBizConfig] configCache].currentCityName;
    NSString *cityId = [[[FHEnvContext sharedInstance] generalBizConfig] configCache].currentCityId;
    FHHistoryCityListModel *item = NULL;
    if (cityId.length > 0) {
        for (FHConfigDataCityListModel *obj in self.cityList) {
            if ([obj.cityId isEqualToString:cityId]) {
                item = obj;
                break;
            }
        }
    }
    if (item) {
        [self addCityToHistory:item];
    }
}

// 切换城市
- (void)switchCityByCityId:(NSString *)cityId switchCompletion:(void(^)(BOOL isSuccess))switchCompletion {
    if (cityId.length > 0) {
        [FHEnvContext sharedInstance].refreshConfigRequestType = @"switch";

        NSString *url = [NSString stringWithFormat:@"fschema://fhomepage?city_id=%@",cityId];
        [FHEnvContext openSwitchCityURL:url completion:^(BOOL isSuccess) {
            // 进历史
            if (switchCompletion) {
                switchCompletion(isSuccess);
            [[FHPopupViewManager shared].dataFetcher fetchData];
            }
        }];
    }
}

// city_filter 埋点
// 搜索输入方式,{'点击历史记录': 'history', '列表选择': 'list', '当前定位': 'location', '热门城市': 'hot'}
- (void)addCityFilterTracer:(NSString *)cityName queryType:(NSString *)queryType {
    NSMutableDictionary *tracerDict = @{}.mutableCopy;
    tracerDict[@"page_type"] = @"maintab";
    tracerDict[@"query_type"] = queryType ?: @"be_null";
    tracerDict[@"city"] = cityName ?: @"be_null";
    [FHUserTracker writeEvent:@"city_filter" params:tracerDict];
}

#pragma mark - UITableViewDelegate UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.sectionsData.count;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section < self.sectionsData.count && section < self.sectionsKeyData.count) {
        // 历史和热门
        if (section < self.mainCount - 1) {
            return 1;
        } else {
            return [self.sectionsData[section] count];
        }
    }
    return 0;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section < self.sectionsData.count) {
        // 历史和热门
        if (indexPath.section < self.mainCount - 1) {
            NSArray *tempData = self.sectionsData[indexPath.section];
            NSString *sectionName = self.sectionsKeyData[indexPath.section];
            FHCityHotItemCell *cell = [tableView dequeueReusableCellWithIdentifier:kCityListHotItemCellId];
            if (cell) {
                NSMutableArray *cityNames = [NSMutableArray new];
                for (id obj in tempData) {
                    NSString *name = [obj name];
                    if (name) {
                        [cityNames addObject:name];
                    }
                }
                if (cityNames.count > 0) {
                    cell.cityList = cityNames;
                }
                cell.label.text = sectionName;
                __weak typeof(self) wSelf = self;
                cell.itemClickBlk = ^(NSInteger index) {
                    [wSelf hotOrHistoryCityItemClickBySection:indexPath.section index:index];
                };
            }
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell;
        } else {
            NSArray *tempData = self.sectionsData[indexPath.section];
            if (indexPath.row < tempData.count) {
                
                FHCityItemCell *cell = [tableView dequeueReusableCellWithIdentifier:kCityListItemCellId];
                if (cell) {
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    FHConfigDataCityListModel *model = (FHConfigDataCityListModel *)tempData[indexPath.row];
                    cell.cityNameLabel.text = model.name;
                    cell.enabled = model.enable;
                }
                return cell;
            }
        }
    }
    return [[UITableViewCell alloc] init];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    // 历史和热门
    if (section < self.mainCount - 1) {
        return nil;
    }
    FHCityItemHeaderView *headerView = [[FHCityItemHeaderView alloc] init];
    if (section < self.sectionsKeyData.count) {
        NSString *tempText = self.sectionsKeyData[section];
        headerView.label.text = tempText;
        if (section < self.mainCount - 1) {
            headerView.label.textColor = [UIColor themeGray3];
            [headerView.label mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo(headerView).offset(20);
                make.left.mas_equalTo(20);
                make.height.mas_equalTo(22);
                make.right.mas_equalTo(headerView).offset(-20);
            }];
        } else {
            headerView.label.textColor = [UIColor themeGray4];
            [headerView.label mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo(headerView).offset(6);
                make.left.mas_equalTo(20);
                make.height.mas_equalTo(22);
                make.right.mas_equalTo(headerView).offset(-20);
            }];
        }
    }
    return headerView;
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = indexPath.section;
    // 历史和热门
    if (section < self.mainCount - 1) {
        NSArray *tempData = self.sectionsData[indexPath.section];
        if (tempData.count > 0) {
            NSInteger rowCount = (tempData.count / 4) + (tempData.count % 4 > 0 ? 1 : 0);
            CGFloat rowHeight = rowCount * 40.0 + 44.0;
            if (section == self.mainCount - 2) {
                return rowHeight + 20.0;
            } else {
                return rowHeight;
            }
        }
    }
    return 44;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    // 历史和热门
    if (section < self.mainCount - 1) {
        return CGFLOAT_MIN;
    }
    return 34;
}
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section < self.sectionsData.count) {
        if (indexPath.section < self.mainCount - 1) {
            // 历史和热门
        } else {
            NSArray *tempData = self.sectionsData[indexPath.section];
            if (indexPath.row < tempData.count) {
                FHConfigDataCityListModel *model = (FHConfigDataCityListModel *)tempData[indexPath.row];
                [self cellItemClick:model];
            }
        }
    }
}

@end
