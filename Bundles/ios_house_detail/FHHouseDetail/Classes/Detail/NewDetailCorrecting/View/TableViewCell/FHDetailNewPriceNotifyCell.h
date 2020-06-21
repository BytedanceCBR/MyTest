//
//  FHDetailNewPriceNotifyCell.h
//  FHHouseDetail
//
//  Created by 张静 on 2020/3/9.
//

#import "FHDetailBaseCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHDetailNewPriceNotifyCell : FHDetailBaseCell

@end

@interface FHDetailNewPriceNotifyCellModel : FHDetailBaseModel

@property (nonatomic, weak)   id contactModel;
@property (nonatomic, strong, nullable) FHClueAssociateInfoModel *priceAssociateInfo;
@property (nonatomic, strong, nullable) FHClueAssociateInfoModel *openAssociateInfo;

@end

NS_ASSUME_NONNULL_END
