//
//  FHNeighborhoodDetailReleatorMoreCell.h
//  FHHouseDetail
//
//  Created by luowentao on 2020/10/14.
//

#import "FHDetailBaseCell.h"
#import "FHDetailFoldViewButton.h"
NS_ASSUME_NONNULL_BEGIN

@interface FHNeighborhoodDetailReleatorMoreCell : FHDetailBaseCollectionCell

@property (nonatomic, strong) FHDetailFoldViewButton *foldButton;

@property (nonatomic, copy) void (^foldButtonActionBlock)(void);

@end

NS_ASSUME_NONNULL_END
