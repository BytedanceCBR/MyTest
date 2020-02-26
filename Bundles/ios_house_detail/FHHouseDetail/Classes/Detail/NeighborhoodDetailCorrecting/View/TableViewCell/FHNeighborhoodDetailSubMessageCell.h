//
//  FHNeighborhoodDetailSubMessageCell.h
//  FHHouseDetail
//
//  Created by liuyu on 2020/2/5.
//

#import "FHDetailBaseCell.h"
#import "FHDetailNeighborhoodModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHNeighborhoodDetailSubMessageCell : FHDetailBaseCell
@end
@interface FHDetailNeighborhoodSubMessageModel : FHDetailBaseModel
@property (nonatomic, copy)     NSString       *name;
@property (nonatomic, strong , nullable) FHDetailNeighborhoodDataNeighborhoodInfoModel *neighborhoodInfo ;
@end
NS_ASSUME_NONNULL_END
