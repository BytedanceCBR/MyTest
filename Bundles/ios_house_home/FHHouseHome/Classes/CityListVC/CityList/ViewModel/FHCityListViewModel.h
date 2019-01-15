//
//  FHCityListViewModel.h
//  FHHouseHome
//
//  Created by 张元科 on 2018/12/26.
//

#import <Foundation/Foundation.h>
#import "FHCityListViewController.h"
#import "FHCitySearchModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHCityListViewModel : NSObject

-(instancetype)initWithController:(FHCityListViewController *)viewController tableView:(UITableView *)tableView;
- (void)cityNameBtnClick;
// 加载城市列表数据
- (void)loadListCityData;
// 城市搜索 cell 点击，和城市搜索列表联动
- (void)searchCellItemClick:(FHCitySearchDataDataModel *)item;

// city_filter 埋点
// 搜索输入方式,{'点击历史记录': 'history', '列表选择': 'list', '当前定位': 'location', '热门城市': 'hot'}
- (void)addCityFilterTracer:(NSString *)cityName queryType:(NSString *)queryType;

@property (nonatomic, assign)   BOOL       hasReloadListData;

@end

NS_ASSUME_NONNULL_END
