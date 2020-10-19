//
//  FHNewHouseDetailReleatorMoreCell.h
//  Pods
//
//  Created by bytedance on 2020/9/9.
//

#import "FHDetailBaseCell.h"
#import "FHDetailFoldViewButton.h"
#import <IGListKit/IGListKit.h>
NS_ASSUME_NONNULL_BEGIN

@interface FHNewHouseDetailReleatorMoreCell : FHDetailBaseCollectionCell<IGListBindable>

@property (nonatomic, strong) FHDetailFoldViewButton *foldButton;

@property (nonatomic, copy) void (^foldButtonActionBlock)(void);

@end

@interface FHNewHouseDetailReleatorMoreCellModel : NSObject<IGListDiffable>

@end

NS_ASSUME_NONNULL_END
