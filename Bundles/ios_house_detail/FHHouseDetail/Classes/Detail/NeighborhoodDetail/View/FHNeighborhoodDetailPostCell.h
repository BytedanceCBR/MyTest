//
//  FHNeighborhoodDetailPostCell.h
//  FHHouseDetail
//
//  Created by 谢思铭 on 2020/10/13.
//

#import "FHDetailBaseCell.h"
#import "FHFeedUGCCellModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHNeighborhoodDetailPostCell : FHDetailBaseCollectionCell

@property (nonatomic, copy) void (^clickLinkBlock)(FHFeedUGCCellModel *model, NSURL *url);

@end

NS_ASSUME_NONNULL_END
