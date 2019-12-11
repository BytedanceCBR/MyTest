//
// FHDetailSurroundingAreaCell.h
//  FHHouseDetail
//
//  Created by 张元科 on 2019/2/15.
//

#import "FHDetailBaseCell.h"
#import "FHDetailBaseModel.h"
#import "FHDetailOldModel.h"
#import "FHHouseDetailBaseViewModel.h"
#import "FHDetailRelatedNeighborhoodResponseModel.h"

NS_ASSUME_NONNULL_BEGIN

// 周边小区
@interface FHDetailSurroundingAreaCell : FHDetailBaseCell

@end

// FHDetailRelatedNeighborhoodModel
@interface FHDetailSurroundingAreaModel : FHDetailBaseModel

@property (nonatomic, strong , nullable) FHDetailRelatedNeighborhoodResponseDataModel *relatedNeighborhoodData;
@property (nonatomic, copy , nullable) NSString *neighborhoodId;

@end



#pragma mark -  CollectionCell

// 小区item
@interface FHDetailSurroundingAreaItemCollectionCell : FHDetailBaseCollectionCell

@property (nonatomic, strong)   UIImageView       *icon;
@property (nonatomic, strong)   UILabel       *descLabel;
@property (nonatomic, strong)   UILabel       *priceLabel;
@property (nonatomic, strong)   UILabel       *spaceLabel;


@end

NS_ASSUME_NONNULL_END
