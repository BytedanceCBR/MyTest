//
//  FHNewHouseDetailReleatorMoreCell.h
//  Pods
//
//  Created by bytedance on 2020/9/9.
//

#import "FHDetailBaseCell.h"
#import "FHDetailFoldViewButton.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHNewHouseDetailReleatorMoreCell : FHDetailBaseCollectionCell

@property (nonatomic, strong) FHDetailFoldViewButton *foldButton;

@property (nonatomic, copy) void (^foldButtonActionBlock)(void);

@end

NS_ASSUME_NONNULL_END
