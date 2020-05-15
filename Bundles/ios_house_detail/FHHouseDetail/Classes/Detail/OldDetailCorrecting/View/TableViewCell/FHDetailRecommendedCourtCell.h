//
//  FHDetailRecommendedNeighborhoodCell.h
//  FHHouseDetail
//
//  Created by luowentao on 2020/5/3.
//

#import "FHDetailBaseCell.h"
#import "FHDetailBaseModel.h"
#import "FHDetailRelatedNeighborhoodResponseModel.h"
#import "FHHouseListBaseItemModel.h"
NS_ASSUME_NONNULL_BEGIN

@interface FHDetailRecommendedCourtCell : FHDetailBaseCell

@end

@interface FHDetailRecommendedCourtModel : FHDetailBaseModel
@property (nonatomic, strong, nullable) FHHouseListDataModel *recommendedCourtData;

@end

#pragma mark - collectionCell
@interface FHDetailRecommendedCourtItemCollectionCell : FHDetailBaseCollectionCell

@property (nonatomic, strong)    UIImageView     *icon;
@property (nonatomic, strong)    UILabel         *nameLabel;
@property (nonatomic, strong)    UILabel         *spaceLabel;
@property (nonatomic, strong)    UILabel         *priceLabel;

@end



NS_ASSUME_NONNULL_END
