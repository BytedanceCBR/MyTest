//
//  FHNeighborhoodDetailSpaceCell.h
//  FHHouseDetail
//
//  Created by 谢思铭 on 2020/10/13.
//

#import "FHDetailBaseCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHNeighborhoodDetailSpaceCell : FHDetailBaseCollectionCell

@end

@interface FHNeighborhoodDetailSpaceModel : NSObject

@property(nonatomic , assign) CGFloat height;
@property(nonatomic , strong) UIColor *backgroundColor;

@end

NS_ASSUME_NONNULL_END
