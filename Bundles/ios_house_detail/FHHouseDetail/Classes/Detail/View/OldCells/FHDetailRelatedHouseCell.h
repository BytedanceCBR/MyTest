//
//  FHDetailRelatedHouseCell.h
//  FHHouseDetail
//
//  Created by 张元科 on 2019/2/15.
//

#import "FHDetailBaseCell.h"
#import "FHDetailBaseModel.h"
#import "FHDetailOldModel.h"
#import "FHHouseDetailBaseViewModel.h"
#import "FHDetailRelatedHouseResponseModel.h"

NS_ASSUME_NONNULL_BEGIN

// 二手房周边房源
@interface FHDetailRelatedHouseCell : FHDetailBaseCell<FHDetailScrollViewDidScrollProtocol>

@end

// FHDetailRelatedHouseModel
@interface FHDetailRelatedHouseModel : FHDetailBaseModel

@property (nonatomic, strong , nullable) FHDetailRelatedHouseResponseDataModel *relatedHouseData;

@end

NS_ASSUME_NONNULL_END
