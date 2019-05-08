//
//  FHDetailNeighborhoodMapInfoCell.h
//  FHHouseDetail
//
//  Created by 谢飞 on 2019/3/4.
//

#import "FHDetailBaseCell.h"
#import "FHDetailBaseModel.h"
#import "FHDetailNeighborhoodModel.h"
#import "FHDetailOldModel.h"
#import "FHHouseDetailBaseViewModel.h"
#import "FHDetailRentModel.h"

NS_ASSUME_NONNULL_BEGIN

// 小区地图cell
@interface FHDetailNeighborhoodMapInfoCell : FHDetailBaseCell

@end


// 地图所需数据
@interface FHDetailNeighborhoodMapInfoModel : FHDetailBaseModel

@property (nonatomic, copy , nullable) NSString *gaodeLng;
@property (nonatomic, copy , nullable) NSString *gaodeLat;
@property (nonatomic, copy , nullable) NSString *title;
@property (nonatomic, copy , nullable) NSString *category;
@property (nonatomic, copy , nullable) NSString *houseId;
@property (nonatomic, copy , nullable) NSString *houseType;

@end


NS_ASSUME_NONNULL_END
