//
//  FHCitySearchViewController.h
//  FHHouseHome
//
//  Created by 张元科 on 2018/12/26.
//

#import <UIKit/UIKit.h>
#import "FHBaseViewController.h"
#import "FHCitySearchNavBarView.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHCitySearchViewController : FHBaseViewController

@property (nonatomic, strong)   FHCitySearchTableView       *tableView;
@property (nonatomic, strong)     FHCitySearchNavBarView     *naviBar;

@end

NS_ASSUME_NONNULL_END
