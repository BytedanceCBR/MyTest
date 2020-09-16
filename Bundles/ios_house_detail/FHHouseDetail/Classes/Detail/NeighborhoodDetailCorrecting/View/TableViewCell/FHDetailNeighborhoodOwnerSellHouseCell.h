//
//  FHDetailNeighborhoodOwnerSellHouseCell.h
//  FHHouseDetail
//
//  Created by bytedance on 2020/9/6.
//

#import "FHDetailBaseCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHDetailNeighborhoodOwnerSellHouseCell : FHDetailBaseCell

@end

@interface FHDetailNeighborhoodOwnerSellHouseModel : FHDetailBaseModel
@property(nonatomic,copy) NSString *imgUrl;
@property(nonatomic,copy) NSString *helpMeSellHouseOpenUrl;
@end

NS_ASSUME_NONNULL_END
