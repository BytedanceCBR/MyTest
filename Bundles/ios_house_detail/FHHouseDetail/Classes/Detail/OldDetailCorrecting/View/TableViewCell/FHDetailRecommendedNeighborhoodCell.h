//
//  FHDetailRecommendedNeighborhoodCell.h
//  FHHouseDetail
//
//  Created by luowentao on 2020/5/3.
//

#import "FHDetailBaseCell.h"
#import "FHDetailBaseModel.h"
#import "FHDetailRelatedNeighborhoodResponseModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHDetailRecommendedNeighborhoodCell : FHDetailBaseCell

@end

@interface FHDetailRecommendedNeighborhoodModel : FHDetailBaseModel
@property (nonatomic, strong, nullable) FHDetailRelatedNeighborhoodResponseDataModel *relatedNeighborhoodData;
@property (nonatomic, copy , nullable) NSString *neighborhoodId;
@end

#pragma mark - collectionCell
@interface FHDetailRecommendedNeighborhoodItemCollectionCell : FHDetailBaseCollectionCell

@property (nonatomic, strong)    UIImageView     *icon;
@property (nonatomic, strong)    UILabel         *nameLabel;
@property (nonatomic, strong)    UILabel         *spaceLabel;
@property (nonatomic, strong)    UILabel         *priceLabel;

@end



NS_ASSUME_NONNULL_END
