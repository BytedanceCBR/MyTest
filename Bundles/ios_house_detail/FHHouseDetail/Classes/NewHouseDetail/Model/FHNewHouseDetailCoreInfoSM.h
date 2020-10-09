//
//  FHNewHouseDetailCoreInfoSM.h
//  AKCommentPlugin
//
//  Created by bytedance on 2020/9/6.
//

#import "FHNewHouseDetailSectionModel.h"
#import "FHNewHouseDetailHeaderTitleCollectionCell.h"
#import "FHNewHouseDetailPropertyListCollectionCell.h"
#import "FHNewHouseDetailAddressInfoCollectionCell.h"
#import "FHNewHouseDetailPriceNotifyCollectionCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHNewHouseDetailCoreInfoSM : FHNewHouseDetailSectionModel

@property (nonatomic, strong) FHNewHouseDetailHeaderTitleCellModel *titleCellModel;

@property (nonatomic, strong, nullable) FHNewHouseDetailPropertyListCellModel *propertyListCellModel;

@property (nonatomic, strong) FHNewHouseDetailAddressInfoCellModel *addressInfoCellModel;

@property (nonatomic, strong) FHNewHouseDetailPriceNotifyCellModel *priceNotifyCellModel;
@end

NS_ASSUME_NONNULL_END
