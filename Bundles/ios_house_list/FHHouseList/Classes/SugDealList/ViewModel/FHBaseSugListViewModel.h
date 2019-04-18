//
//  FHBaseSugListViewModel.h
//  FHHouseList
//
//  Created by 张静 on 2019/4/18.
//

#import <Foundation/Foundation.h>
#import "FHHouseListAPI.h"

NS_ASSUME_NONNULL_BEGIN
@class TTRouteParamObj,FHBaseViewController,FHSearchBar;

typedef enum : NSUInteger {
    FHSugListSearchTypeDefault,
    FHSugListSearchTypePriceValuation,
    FHSugListSearchTypeNeighborDealList,
} FHSugListSearchType;

@interface FHBaseSugListViewModel : NSObject

@property(nonatomic , weak) FHBaseViewController *listController;
@property (nonatomic, weak)   FHSearchBar       *naviBar;
@property (nonatomic, assign) FHSugListSearchType searchType;
@property (nonatomic, assign) FHHouseType houseType;

- (instancetype)initWithTableView:(UITableView *)tableView paramObj:(TTRouteParamObj *)paramObj;
- (void)clearSugTableView;
- (void)reloadSugTableView;

@end

NS_ASSUME_NONNULL_END
