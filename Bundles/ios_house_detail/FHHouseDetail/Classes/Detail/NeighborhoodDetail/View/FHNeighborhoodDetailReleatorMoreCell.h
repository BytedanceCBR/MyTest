//
//  FHNeighborhoodDetailReleatorMoreCell.h
//  FHHouseDetail
//
//  Created by luowentao on 2020/10/14.
//

#import "FHDetailBaseCell.h"
#import "FHDetailFoldViewButton.h"
#import <IGListKit/IGListKit.h>
NS_ASSUME_NONNULL_BEGIN

@interface FHNeighborhoodDetailReleatorMoreCell : FHDetailBaseCollectionCell<IGListBindable>

@property (nonatomic, strong) FHDetailFoldViewButton *foldButton;

@property (nonatomic, copy) void (^foldButtonActionBlock)(void);

@end

@interface FHNeighborhoodDetailReleatorMoreCellModel : NSObject<IGListDiffable>

@property (nonatomic, assign) BOOL isFold; // 折叠

+ (FHNeighborhoodDetailReleatorMoreCellModel *)modelWithFold:(BOOL )fold;

@end

NS_ASSUME_NONNULL_END
