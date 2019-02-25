//
//  FHRelatedNeighborhoodListViewModel.h
//  Pods
//
//  Created by 张静 on 2019/2/24.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class FHRelatedNeighborhoodListViewController;
@interface FHRelatedNeighborhoodListViewModel : NSObject

@property (nonatomic , copy) NSString *neighborhoodId;

-(instancetype)initWithController:(FHRelatedNeighborhoodListViewController *)viewController tableView:(UITableView *)tableView;
-(void)viewWillAppear:(BOOL)animated;
-(void)viewWillDisappear:(BOOL)animated;
// 周边小区
- (void)requestRelatedNeighborhoodSearch:(NSString *)neighborhoodId searchId:(NSString*)searchId offset:(NSString *)offset;
-(void)addCategoryRefreshLog;
-(void)addStayCategoryLog;

@end

NS_ASSUME_NONNULL_END
