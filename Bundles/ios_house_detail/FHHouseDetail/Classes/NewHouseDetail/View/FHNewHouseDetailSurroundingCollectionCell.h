//
//  FHNewHouseDetailSurroundingCollectionCell.h
//  Pods
//
//  Created by bytedance on 2020/9/11.
//

#import "FHDetailBaseCell.h"
#import "FHDetailNewModel.h"
#import <IGListKit/IGListKit.h>
NS_ASSUME_NONNULL_BEGIN

@interface FHNewHouseDetailSurroundingCollectionCell : FHDetailBaseCollectionCell<IGListBindable>

@property (nonatomic, copy) void (^imActionBlock)(void);

@end

@interface FHNewHouseDetailSurroundingCellModel : NSObject<IGListDiffable>

@property (nonatomic, strong , nullable) FHDetailNewSurroundingInfo *surroundingInfo;

@end

NS_ASSUME_NONNULL_END
