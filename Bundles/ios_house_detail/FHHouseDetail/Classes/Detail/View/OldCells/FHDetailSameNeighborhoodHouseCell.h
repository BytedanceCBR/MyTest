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
#import <YYText.h>

NS_ASSUME_NONNULL_BEGIN

@interface FHDetailSameNeighborhoodHouseCell : FHDetailBaseCell

@end

// FHDetailSameNeighborhoodHouseModel
@interface FHDetailSameNeighborhoodHouseModel : FHDetailBaseModel

@property (nonatomic, strong , nullable) FHDetailSameNeighborhoodHouseResponseDataModel *sameNeighborhoodHouseData;

@end


#pragma mark -  CollectionCell

// 同小区房源 item
@interface FHDetailSameNeighborhoodHouseCollectionCell : FHDetailBaseCollectionCell

@property (nonatomic, strong)   UIImageView       *icon;
@property (nonatomic, strong)   YYLabel       *descLabel;
@property (nonatomic, strong)   UILabel       *priceLabel;
@property (nonatomic, strong)   UILabel       *spaceLabel;


@end

NS_ASSUME_NONNULL_END
