//
//  FHDetailSameNeighborhoodHouseCell.h
//  FHHouseDetail
//
//  Created by 张元科 on 2019/2/17.
//

#import "FHDetailBaseCell.h"
#import "FHDetailBaseModel.h"
#import "FHDetailOldModel.h"
#import "FHHouseDetailBaseViewModel.h"
#import "FHDetailSameNeighborhoodHouseResponseModel.h"
#import "YYText.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHDetailSameNeighborhoodHouseCell : FHDetailBaseCell

@end

// FHDetailSameNeighborhoodHouseModel
@interface FHDetailSameNeighborhoodHouseModel : FHDetailBaseModel

@property (nonatomic, strong , nullable) FHDetailSameNeighborhoodHouseResponseDataModel *sameNeighborhoodHouseData;

@end


#pragma mark -  CollectionCell

@interface FHDetailSameNeighborhoodHouseSaleItemCollectionCell : FHDetailBaseCollectionCell

@end
@interface FHDetailSameNeighborhoodHouseSaleMoreItemCollectionCell : FHDetailBaseCollectionCell

@end

@interface FHDetailSameNeighborhoodHouseSaleMoreItemModel : FHDetailBaseModel

@end

@interface FHSameHouseTagImageView : UIImageView

@end

NS_ASSUME_NONNULL_END
