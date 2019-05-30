//
//  FHBaseSugListViewModel.h
//  FHHouseList
//
//  Created by 张静 on 2019/4/18.
//

#import <Foundation/Foundation.h>
#import "FHHouseListAPI.h"

NS_ASSUME_NONNULL_BEGIN
@class TTRouteParamObj,FHBaseViewController,FHSearchBar,FHPriceValuationNSearchView,FHErrorView;

typedef enum : NSUInteger {
    FHSugListSearchTypeDefault,
    FHSugListSearchTypePriceValuation, // 查房价
    FHSugListSearchTypeNeighborDealList, // 小区查成交
} FHSugListSearchType;

@interface FHBaseSugListViewModel : NSObject

@property(nonatomic , weak) FHBaseViewController *listController;
@property (nonatomic, weak)   FHSearchBar       *naviBar;
@property (nonatomic, weak)   FHPriceValuationNSearchView       *searchView;
@property (nonatomic, weak) FHErrorView *emptyView;
@property (nonatomic, assign) FHSugListSearchType searchType;
@property (nonatomic, assign) FHHouseType houseType;

- (instancetype)initWithTableView:(UITableView *)tableView paramObj:(TTRouteParamObj *)paramObj;
- (void)clearSugTableView;
- (void)reloadSugTableView;
- (void)viewWillDisappear:(BOOL)animated;
- (BOOL)resignFirstResponder;

@end

NS_ASSUME_NONNULL_END
