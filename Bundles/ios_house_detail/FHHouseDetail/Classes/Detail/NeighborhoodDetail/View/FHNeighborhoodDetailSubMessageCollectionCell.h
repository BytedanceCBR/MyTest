//
//  FHNeighborhoodDetailSubMessageCollectionCell.h
//  FHHouseDetail
//
//  Created by luowentao on 2020/10/10.
//

#import "FHDetailBaseCell.h"
#import "FHDetailNeighborhoodModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHNeighborhoodDetailSubMessageCollectionCell : FHDetailBaseCollectionCell

@end

@interface FHNeighborhoodDetailSubMessageModel : NSObject

@property (nonatomic, strong , nullable) FHDetailNeighborhoodDataNeighborhoodInfoModel *neighborhoodInfo ;
@end

NS_ASSUME_NONNULL_END
