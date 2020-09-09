//
//  FHNewHouseDetailReleatorCollectionCell.h
//  Pods
//
//  Created by bytedance on 2020/9/9.
//

#import "FHDetailBaseCell.h"

NS_ASSUME_NONNULL_BEGIN

@class FHDetailContactModel;

@interface FHNewHouseDetailReleatorCollectionCell : FHDetailBaseCollectionCell

@property (nonatomic, copy) void (^licenseClickBlock)(FHDetailContactModel *model);

@property (nonatomic, copy) void (^phoneClickBlock)(FHDetailContactModel *model);

@property (nonatomic, copy) void (^imClickBlock)(FHDetailContactModel *model);

@end

@interface FHNewHouseDetailReleatorCellModel : NSObject

@end

NS_ASSUME_NONNULL_END
