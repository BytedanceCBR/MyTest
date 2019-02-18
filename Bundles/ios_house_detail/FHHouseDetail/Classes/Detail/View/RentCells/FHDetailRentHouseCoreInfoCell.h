//
//  FHDetailRentHouseCoreInfoCell.h
//  FHHouseDetail
//
//  Created by 张元科 on 2019/2/18.
//

#import "FHDetailBaseCell.h"
#import "FHDetailBaseModel.h"
#import "FHDetailRentModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHDetailRentHouseCoreInfoCell : FHDetailBaseCell

@end

@interface FHDetailRentHouseCoreInfoItemView : UIView

@property (nonatomic, strong)   UILabel       *keyLabel;
@property (nonatomic, strong)   UILabel       *valueLabel;

@end

@interface  FHDetailRentHouseCoreInfoModel: FHDetailBaseModel

@property (nonatomic, strong , nullable) NSArray<FHRentDetailResponseDataCoreInfoModel> *coreInfo;

@end


NS_ASSUME_NONNULL_END
