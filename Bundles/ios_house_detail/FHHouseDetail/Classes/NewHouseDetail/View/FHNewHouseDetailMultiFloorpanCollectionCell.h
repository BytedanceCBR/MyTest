//
//  FHNewHouseDetailMultiFloorpanCollectionCell.h
//  Pods
//
//  Created by bytedance on 2020/9/7.
//

#import "FHDetailBaseCell.h"
#import "FHDetailNewMutiFloorPanCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHNewHouseDetailMultiFloorpanCollectionCell : FHDetailBaseCollectionCell

@end

@interface FHNewHouseDetailMultiFloorpanCellModel : NSObject

@property (nonatomic, strong , nullable) FHDetailNewDataFloorpanListModel *floorPanList;

@end

NS_ASSUME_NONNULL_END
