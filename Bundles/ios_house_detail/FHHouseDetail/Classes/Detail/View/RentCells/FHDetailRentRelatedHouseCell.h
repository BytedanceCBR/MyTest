//
//  FHDetailRentRelatedHouseCell.h
//  FHHouseDetail
//
//  Created by 张元科 on 2019/2/18.
//

#import "FHDetailBaseCell.h"
#import "FHDetailBaseModel.h"
#import "FHDetailRentModel.h"
#import "FHHouseDetailBaseViewModel.h"
#import "FHDetailRelatedHouseResponseModel.h"
#import "FHHouseRentRelatedResponse.h"

NS_ASSUME_NONNULL_BEGIN

// 租房周边房源
@interface FHDetailRentRelatedHouseCell : FHDetailBaseCell<FHDetailScrollViewDidScrollProtocol>

@end

@interface FHDetailRentRelatedHouseModel : FHDetailBaseModel

@property (nonatomic, strong , nullable) FHHouseRentRelatedResponseDataModel *relatedHouseData;

@end

NS_ASSUME_NONNULL_END
