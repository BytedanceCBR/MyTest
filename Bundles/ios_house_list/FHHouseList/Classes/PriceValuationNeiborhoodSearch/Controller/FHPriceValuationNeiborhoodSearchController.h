//
//  FHPriceValuationNeiborhoodSearchController.h
//  FHHouseTrend
//
//  Created by 张元科 on 2019/3/26.
//

#import "FHBaseViewController.h"
#import "FHSuggestionItemCell.h"

NS_ASSUME_NONNULL_BEGIN

// 估价-小区搜索
@interface FHPriceValuationNeiborhoodSearchController : FHBaseViewController

@property (nonatomic, strong)   FHSuggectionTableView       *suggestTableView;

// cell点击
- (void)cellDidClick:(NSString *)text neigbordId:(NSString *)neigbordId;

@end

NS_ASSUME_NONNULL_END
