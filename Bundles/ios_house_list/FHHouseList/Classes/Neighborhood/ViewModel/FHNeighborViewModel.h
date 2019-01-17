//
//  FHNeighborViewModel.h
//  FHHouseList
//
//  Created by 春晖 on 2018/12/6.
//

#import <Foundation/Foundation.h>
#import "FHBaseHouseListViewModel.h"

NS_ASSUME_NONNULL_BEGIN
@class FHNeighborListViewController;

@interface FHNeighborViewModel : FHBaseHouseListViewModel

@property (nonatomic , strong) NSMutableArray *houseList;
@property (nonatomic , copy) NSString *searchId;
@property (nonatomic , copy) NSString *condition; // 过滤条件
@property (nonatomic, strong)   NSMutableDictionary       *houseShowTracerDic; // 埋点key记录
@property (nonatomic, assign)   BOOL       firstRequestData;

-(instancetype)initWithController:(FHNeighborListViewController *)viewController tableView:(UITableView *)tableView;

- (void)requestHouseInSameNeighborhoodSearch:(NSString *)neighborhoodId houseId:(NSString *)houseId offset:(NSInteger)offset;

- (void)requestRentInSameNeighborhoodSearch:(NSString *)neighborhoodId houseId:(NSString *)houseId offset:(NSInteger)offset;

- (void)requestRelatedHouseSearch:(NSString *)neighborhoodId houseId:(NSString *)houseId offset:(NSInteger)offset;

- (void)requestRentRelatedHouseSearch:(NSString *)neighborhoodId houseId:(NSString *)houseId offset:(NSInteger)offset;

-(void)addCategoryRefreshLog;
-(void)addStayCategoryLog;

@end

NS_ASSUME_NONNULL_END
