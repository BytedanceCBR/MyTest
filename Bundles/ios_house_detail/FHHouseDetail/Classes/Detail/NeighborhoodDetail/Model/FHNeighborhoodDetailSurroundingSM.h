//
//  FHNeighborhoodDetailSurroundingSM.h
//  FHHouseDetail
//
//  Created by luowentao on 2020/10/13.
//

#import "FHNeighborhoodDetailSectionModel.h"

#import "MAMapKit.h"

NS_ASSUME_NONNULL_BEGIN

@class FHNewHouseDetailMapCellModel;
@class FHNeighborhoodDetailPriceTrendCellModel;

@interface FHNeighborhoodDetailSurroundingSM : FHNeighborhoodDetailSectionModel
@property (nonatomic, copy) NSString *baiduPanoramaUrl;
@property (nonatomic, assign) CLLocationCoordinate2D centerPoint;
@property (nonatomic, copy) NSString *mapCentertitle;
@property(nonatomic, copy) NSString *curCategory;

@property (nonatomic, strong) FHNewHouseDetailMapCellModel *mapCellModel;
@property (nonatomic, strong) FHNeighborhoodDetailPriceTrendCellModel *priceTrendModel;

- (NSArray *)dataItems;
@end

NS_ASSUME_NONNULL_END
