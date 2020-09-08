//
//  FHNewHouseDetailPriceNotifyCollectionCell.h
//  AKCommentPlugin
//
//  Created by bytedance on 2020/9/6.
//

#import "FHDetailBaseCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHNewHouseDetailPriceNotifyCollectionCell : FHDetailBaseCollectionCell

@property (nonatomic, copy) void (^openNotifyActionBlock)(void);
@property (nonatomic, copy) void (^priceChangedNotifyActionBlock)(void);

@end

@interface FHNewHouseDetailPriceNotifyCellModel : NSObject
@property (nonatomic, weak)   id contactModel;
@property (nonatomic, strong, nullable) FHClueAssociateInfoModel *priceAssociateInfo;
@property (nonatomic, strong, nullable) FHClueAssociateInfoModel *openAssociateInfo;
@end

NS_ASSUME_NONNULL_END
