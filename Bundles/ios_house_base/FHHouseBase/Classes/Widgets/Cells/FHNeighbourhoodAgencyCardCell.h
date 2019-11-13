//
// 小区搜索 结果卡片，带有推荐经纪人展位
// Created by fengbo on 2019-10-28.
//

#import <Foundation/Foundation.h>
#import "FHListBaseCell.h"
@class FHHouseNeighborAgencyModel;

NS_ASSUME_NONNULL_BEGIN


@interface FHNeighbourhoodAgencyCardCell : FHListBaseCell

- (void)bindData:(FHHouseNeighborAgencyModel *)model traceParams:(NSMutableDictionary *)params;

@end

NS_ASSUME_NONNULL_END
