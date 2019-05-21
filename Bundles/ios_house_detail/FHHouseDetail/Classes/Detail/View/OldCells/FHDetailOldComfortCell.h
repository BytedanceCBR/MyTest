//
//  FHDetailOldComfortCell.h
//  FHHouseDetail
//
//  Created by 张静 on 2019/5/21.
//

#import "FHDetailBaseCell.h"
#import "FHDetailOldModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHDetailOldComfortModel : FHDetailBaseModel

@property (nonatomic, strong , nullable) FHDetailOldDataComfortInfoModel *comfortInfo;

@end

@interface FHDetailOldComfortCell : FHDetailBaseCell

@end

NS_ASSUME_NONNULL_END
