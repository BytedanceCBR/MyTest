//
//  FHOldPriceComparisonListViewModel.h
//  FHHouseDetail
//
//  Created by 谢思铭 on 2019/4/9.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class FHOldPriceComparisonListController,FHErrorView;
@interface FHOldPriceComparisonListViewModel : NSObject

@property(nonatomic ,copy) NSString *query;

-(instancetype)initWithController:(FHOldPriceComparisonListController *)viewController tableView:(UITableView *)tableView;
-(void)setMaskView:(FHErrorView *)maskView;
-(void)viewWillAppear:(BOOL)animated;
-(void)viewWillDisappear:(BOOL)animated;
// 周边小区
//- (void)requestRelatedNeighborhoodSearch:(NSString *)neighborhoodId searchId:(nullable NSString *)searchId offset:(NSString *)offset;
- (void)requestErshouHouseListData:(BOOL)isRefresh query:(NSString *)query offset:(NSInteger)offset searchId:(nullable NSString *)searchId;
-(void)addCategoryRefreshLog;
-(void)addStayCategoryLog;

@end

NS_ASSUME_NONNULL_END
