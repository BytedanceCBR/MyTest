//
//  FHCityListViewModel.h
//  FHHouseHome
//
//  Created by 张元科 on 2018/12/26.
//

#import <Foundation/Foundation.h>
#import "FHCityListViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHCityListViewModel : NSObject

-(instancetype)initWithController:(FHCityListViewController *)viewController tableView:(UITableView *)tableView;
- (void)cityNameBtnClick;
// 加载城市列表数据
- (void)loadListCityData;

@end

NS_ASSUME_NONNULL_END
