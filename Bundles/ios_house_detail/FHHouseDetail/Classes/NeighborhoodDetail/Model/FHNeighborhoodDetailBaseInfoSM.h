//
//  FHNeighborhoodDetailBaseInfoSM.h
//  FHHouseDetail
//
//  Created by 谢雷 on 2020/12/10.
//

#import "FHNeighborhoodDetailSectionModel.h"
#import "FHNeighborhoodDetailPropertyInfoCollectionCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHNeighborhoodDetailBaseInfoSM : FHNeighborhoodDetailSectionModel

@property (nonatomic, strong) FHNeighborhoodDetailPropertyInfoModel *propertyInfoModel;

@property (nonatomic, copy) NSDictionary *neighborhoodDetailModules;

@end

NS_ASSUME_NONNULL_END
