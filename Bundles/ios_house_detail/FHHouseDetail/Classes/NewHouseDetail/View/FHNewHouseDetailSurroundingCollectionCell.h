//
//  FHNewHouseDetailSurroundingCollectionCell.h
//  Pods
//
//  Created by bytedance on 2020/9/11.
//

#import "FHDetailBaseCell.h"
#import "FHDetailNewModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHNewHouseDetailSurroundingCollectionCell : FHDetailBaseCollectionCell

@property (nonatomic, copy) void (^imActionBlock)(void);

@end

@interface FHNewHouseDetailSurroundingCellModel : NSObject

@property (nonatomic, strong , nullable) FHDetailNewSurroundingInfo *surroundingInfo;

@end

NS_ASSUME_NONNULL_END
