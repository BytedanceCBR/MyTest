//
//  FHCityListViewModel.m
//  FHHouseHome
//
//  Created by 张元科 on 2018/12/26.
//

#import "FHCityListViewModel.h"
#import "FHCityListCell.h"
#import "FHEnvContext.h"

#define kCityListItemCellId @"city_list_item_cell_id"

@interface FHCityListViewModel ()<UITableViewDelegate,UITableViewDataSource>

@property(nonatomic , weak) UITableView *tableView;
@property(nonatomic , weak) FHCityListViewController *listController;

@property (nonatomic, strong , nullable) NSArray<FHConfigDataHotCityListModel> *hotCityList;
@property (nonatomic, strong , nullable) NSArray<FHConfigDataCityListModel> *cityList;
@property (nonatomic, strong , nullable) NSArray<FHConfigDataCityListModel> *historyCityList;
@property (nonatomic, strong) NSMutableArray    *sectionsKeyData;
@property (nonatomic, strong) NSMutableArray    *sectionsData;

@end

@implementation FHCityListViewModel

-(instancetype)initWithController:(FHCityListViewController *)viewController tableView:(UITableView *)tableView {
    self = [super init];
    if (self) {
        self.listController = viewController;
        self.tableView = tableView;
        [self configTableView];
        [self loadListCityData];
    }
    return self;
}
-(void)configTableView
{
    _tableView.delegate = self;
    _tableView.dataSource = self;
    
    [_tableView registerClass:[FHCityItemCell class] forCellReuseIdentifier:kCityListItemCellId];
}

- (void)loadListCityData {
    FHConfigDataModel *configDataModel  = [[FHEnvContext sharedInstance] getConfigFromCache];
    self.cityList = [configDataModel cityList];
    self.hotCityList = [configDataModel hotCityList];
    // 加载历史数据
    [self configSectionData];
    [self.tableView reloadData];
}

// 构建列表页数据
- (void)configSectionData {
    _sectionsKeyData = [[NSMutableArray alloc] init];
    _sectionsData = [[NSMutableArray alloc] init];
    
    // 历史
    if (self.historyCityList.count > 0) {
        [self.sectionsData addObject:self.historyCityList];
        [self.sectionsKeyData addObject:@"历史"];
    }
    // 热门
    if (self.hotCityList.count > 0) {
        [self.sectionsData addObject:self.hotCityList];
        [self.sectionsKeyData addObject:@"热门"];
    }
    // A B C
    [self analyseCities];
}

-(void)analyseCities
{
    NSMutableDictionary *citiesDict = [NSMutableDictionary new];
    
    for (FHConfigDataCityListModel *city in self.cityList) {
        
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
}


#pragma mark - UITableViewDelegate UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.sectionsData.count;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section < self.sectionsData.count && section < self.sectionsKeyData.count) {
        return [self.sectionsData[section] count];
    }
    return 0;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section < self.sectionsData.count) {
        NSArray *tempData = self.sectionsData[indexPath.section];
        if (indexPath.row < tempData.count) {
            
            FHCityItemCell *cell = [tableView dequeueReusableCellWithIdentifier:kCityListItemCellId];
            if (cell) {
                FHConfigDataCityListModel *model = (FHConfigDataCityListModel *)tempData[indexPath.row];
                cell.cityNameLabel.text = model.name;
            }
            return cell;
        }
    }
    return [[UITableViewCell alloc] init];
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
}
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


@end
