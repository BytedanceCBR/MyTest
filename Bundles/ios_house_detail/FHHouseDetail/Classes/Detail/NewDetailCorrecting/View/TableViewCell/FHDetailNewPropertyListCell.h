//
//  FHDetailNewPropertyListCell.h
//  FHHouseDetail
//
//  Created by 张静 on 2020/3/9.
//

#import "FHDetailBaseCell.h"

NS_ASSUME_NONNULL_BEGIN

@class FHHouseCoreInfoModel,FHDetailDisclaimerModel,FHDetailHouseNameModel;

@interface FHDetailNewPropertyListCell : FHDetailBaseCell

@end

@interface FHDetailNewPropertyListCellModel : FHDetailBaseModel

@property (nonatomic, strong , nullable) NSArray<FHHouseCoreInfoModel> *baseInfo;
@property (nonatomic, copy, nullable) NSString *courtId;
@property (nonatomic, strong)   FHDetailHouseNameModel *houseName;
@property (nonatomic, strong, nullable) FHDetailDisclaimerModel *disclaimerModel;

@end

NS_ASSUME_NONNULL_END
