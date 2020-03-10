//
//  FHDetailNewPropertyListCell.h
//  FHHouseDetail
//
//  Created by 张静 on 2020/3/9.
//

#import "FHDetailBaseCell.h"

NS_ASSUME_NONNULL_BEGIN

@class FHHouseCoreInfoModel;

@interface FHDetailNewPropertyListCell : FHDetailBaseCell

@end

@interface FHDetailNewPropertyListCellModel : FHDetailBaseModel

@property (nonatomic, strong , nullable) NSArray<FHHouseCoreInfoModel> *baseInfo;

@end

NS_ASSUME_NONNULL_END
