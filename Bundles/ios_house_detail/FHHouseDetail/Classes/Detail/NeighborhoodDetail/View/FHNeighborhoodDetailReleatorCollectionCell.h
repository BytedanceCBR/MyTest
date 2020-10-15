//
//  FHNeighborhoodDetailReleatorCollectionCell.h
//  FHHouseDetail
//
//  Created by luowentao on 2020/10/13.
//

#import "FHDetailBaseCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHNeighborhoodDetailReleatorCollectionCell : FHDetailBaseCollectionCell
@property (nonatomic, copy) void (^licenseClickBlock)(FHDetailContactModel *model);

@property (nonatomic, copy) void (^phoneClickBlock)(FHDetailContactModel *model);

@property (nonatomic, copy) void (^imClickBlock)(FHDetailContactModel *model);

@property (nonatomic, copy) void (^releatorClickBlock)(FHDetailContactModel *model);


@end

NS_ASSUME_NONNULL_END
