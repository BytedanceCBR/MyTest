//
//  FHNewHouseDetailMultiFloorpanCollectionCell.h
//  Pods
//
//  Created by bytedance on 2020/9/7.
//

#import "FHDetailBaseCell.h"
#import "FHDetailNewModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHNewHouseDetailMultiFloorpanCollectionCell : FHDetailBaseCollectionCell

@property (nonatomic, copy) void (^didSelectItem)(NSInteger atIndex);

@property (nonatomic, copy) void (^willShowItem)(NSIndexPath *indexPath);

@property (nonatomic, copy) void (^imItemClick)(NSInteger atIndex);
@end

@interface FHNewHouseDetailMultiFloorpanCellModel : NSObject

@property (nonatomic, strong , nullable) FHDetailNewDataFloorpanListModel *floorPanList;



@end

NS_ASSUME_NONNULL_END
