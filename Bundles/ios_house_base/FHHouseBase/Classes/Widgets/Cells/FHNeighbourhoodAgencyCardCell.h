//
// 小区搜索 结果卡片，带有推荐经纪人展位
// Created by fengbo on 2019-10-28.
//

#import <Foundation/Foundation.h>

@class FHHouseNeighborAgencyModel;

NS_ASSUME_NONNULL_BEGIN


@interface FHNeighbourhoodAgencyCardCell : UITableViewCell

@property(nonatomic, weak) UIViewController *belongsVC;

- (void)bindData:(FHHouseNeighborAgencyModel *)model traceParams:(NSMutableDictionary *)params;

@end

NS_ASSUME_NONNULL_END
