//
//  FHNeighborhoodDetailFloorpanCollectionCell.h
//  FHHouseDetail
//
//  Created by bytedance on 2020/10/14.
//

#import "FHDetailBaseCell.h"
#import "FHDetailNeighborhoodModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHNeighborhoodDetailFloorpanCollectionCell : FHDetailBaseCollectionCell

@property (nonatomic, copy) void (^didSelectItem)(NSInteger index);
@property (nonatomic, copy) void (^willShowItem)(NSIndexPath *indexPath);

@end

@interface FHNeighborhoodDetailFloorpanItemCollectionCell : FHDetailBaseCollectionCell

@end

@interface FHNeighborhoodDetailFloorpanCellModel : NSObject
@property (nonatomic,strong) FHDetailNeighborhoodSaleHouseInfoListModel *saleHouseInfoModel;
@end

NS_ASSUME_NONNULL_END