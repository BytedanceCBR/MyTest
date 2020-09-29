//
//  FHNewHouseDetailRGCImageCollectionCell.h
//  Pods
//
//  Created by bytedance on 2020/9/10.
//

#import "FHDetailBaseCell.h"

NS_ASSUME_NONNULL_BEGIN
@class FHFeedUGCCellModel;
@interface FHNewHouseDetailRGCImageCollectionCell : FHDetailBaseCollectionCell

@property (nonatomic, copy) void (^clickIMBlock)(FHFeedUGCCellModel *model);

@property (nonatomic, copy) void (^clickPhoneBlock)(FHFeedUGCCellModel *model);

@property (nonatomic, copy) void (^clickRealtorHeaderBlock)(FHFeedUGCCellModel *model);

@property (nonatomic, copy) void (^clickLinkBlock)(FHFeedUGCCellModel *model, NSURL *url);

@end

NS_ASSUME_NONNULL_END
