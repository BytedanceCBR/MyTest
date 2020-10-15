//
//  FHNeighborhoodDetailSurroundingSM.h
//  FHHouseDetail
//
//  Created by luowentao on 2020/10/13.
//

#import "FHNeighborhoodDetailSectionModel.h"

#import "MAMapKit.h"

NS_ASSUME_NONNULL_BEGIN

@class FHNewHouseDetailSurroundingCellModel;
@class FHNewHouseDetailMapCellModel;

@interface FHNeighborhoodDetailSurroundingSM : FHNeighborhoodDetailSectionModel
@property (nonatomic, copy) NSString *baiduPanoramaUrl;
@property (nonatomic, assign) CLLocationCoordinate2D centerPoint;
@property (nonatomic, copy) NSString *mapCentertitle;
@property(nonatomic, copy) NSString *curCategory;

@property (nonatomic, strong) FHNewHouseDetailMapCellModel *mapCellModel;

- (NSArray *)dataItems;
@end

NS_ASSUME_NONNULL_END
