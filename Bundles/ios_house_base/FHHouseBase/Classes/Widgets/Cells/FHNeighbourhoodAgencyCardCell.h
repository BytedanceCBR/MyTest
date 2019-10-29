//
// 小区搜索 结果卡片，带有推荐经纪人展位
// Created by fengbo on 2019-10-28.
//

#import <Foundation/Foundation.h>

@class FHHouseNeighborAgencyModel;

NS_ASSUME_NONNULL_BEGIN


@interface FHNeighbourhoodAgencyCardCell : UITableViewCell

//TODO fengbo delegate




- (void)bindData:(FHHouseNeighborAgencyModel *)model;
@end

NS_ASSUME_NONNULL_END
