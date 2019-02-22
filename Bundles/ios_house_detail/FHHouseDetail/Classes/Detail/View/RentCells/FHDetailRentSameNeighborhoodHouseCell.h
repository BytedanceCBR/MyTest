//
//  FHDetailRentSameNeighborhoodHouseCell.h
//  FHHouseDetail
//
//  Created by 张元科 on 2019/2/18.
//

#import "FHDetailBaseCell.h"
#import "FHDetailBaseModel.h"
#import "FHDetailOldModel.h"
#import "FHHouseDetailBaseViewModel.h"
#import "FHRentSameNeighborhoodResponse.h"
#import <YYText.h>
#import "FHDetailRentModel.h"

NS_ASSUME_NONNULL_BEGIN

// 同小区房源-租房
@interface FHDetailRentSameNeighborhoodHouseCell : FHDetailBaseCell

@end

@interface FHDetailRentSameNeighborhoodHouseModel : FHDetailBaseModel

@property (nonatomic, strong , nullable) FHRentSameNeighborhoodResponseDataModel *sameNeighborhoodHouseData;

@end

#pragma mark -  CollectionCell

// 同小区房源 item rent
@interface FHDetailRentSameNeighborhoodHouseCollectionCell : FHDetailBaseCollectionCell

@property (nonatomic, strong)   UIImageView       *icon;
@property (nonatomic, strong)   YYLabel       *descLabel;
@property (nonatomic, strong)   UILabel       *priceLabel;
@property (nonatomic, strong)   UILabel       *spaceLabel;


@end

NS_ASSUME_NONNULL_END
