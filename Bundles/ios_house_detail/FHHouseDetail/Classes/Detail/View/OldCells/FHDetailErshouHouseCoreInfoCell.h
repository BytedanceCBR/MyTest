//
//  FHDetailErshouHouseCoreInfoCell.h
//  FHHouseDetail
//
//  Created by 张元科 on 2019/2/13.
//

#import "FHDetailBaseCell.h"
#import "FHDetailBaseModel.h"
#import "FHDetailOldModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHDetailErshouHouseCoreInfoCell : FHDetailBaseCell

@end

@interface FHDetailHouseCoreInfoItemView : UIView

@property (nonatomic, strong)   UILabel       *keyLabel;
@property (nonatomic, strong)   UILabel       *valueLabel;

@end


@interface  FHDetailErshouHouseCoreInfoModel: FHDetailBaseModel

@property (nonatomic, strong , nullable) NSArray<FHDetailOldDataCoreInfoModel> *coreInfo;

@end

NS_ASSUME_NONNULL_END
