//
//  FHCitySearchViewController.h
//  FHHouseHome
//
//  Created by 张元科 on 2018/12/26.
//

#import <UIKit/UIKit.h>
#import "FHBaseViewController.h"
#import <FHCommonUI/FHSearchBar.h>
#import "FHCityListViewModel.h"
#import <FHCommonUI/FHHouseBaseTableView.h>

NS_ASSUME_NONNULL_BEGIN

@interface FHCitySearchViewController : FHBaseViewController

@property (nonatomic, strong)   FHHouseBaseTableView       *tableView;
@property (nonatomic, strong)     FHSearchBar     *naviBar;
@property (nonatomic, weak)   FHCityListViewModel       *cityListViewModel;

@end

NS_ASSUME_NONNULL_END
