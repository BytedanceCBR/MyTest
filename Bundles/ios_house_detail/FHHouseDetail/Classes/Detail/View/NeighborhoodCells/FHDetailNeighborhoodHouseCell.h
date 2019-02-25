//
//  FHDetailNeighborhoodHouseCell.h
//  FHHouseDetail
//
//  Created by 张元科 on 2019/2/19.
//

#import "FHDetailBaseCell.h"
#import "FHDetailBaseModel.h"
#import "FHDetailNeighborhoodModel.h"
#import "FHHouseDetailBaseViewModel.h"
#import "FHDetailRelatedHouseResponseModel.h"
#import "FHRentSameNeighborhoodResponse.h"
#import "FHDetailRelatedNeighborhoodResponseModel.h"
#import "FHDetailRelatedHouseResponseModel.h"
#import "FHRentSameNeighborhoodResponse.h"
#import "FHDetailSameNeighborhoodHouseResponseModel.h"

NS_ASSUME_NONNULL_BEGIN

// 小区房源-二手房 + 租房
@interface FHDetailNeighborhoodHouseCell : FHDetailBaseCell<FHDetailScrollViewDidScrollProtocol>

@end

@interface FHDetailNeighborhoodHouseModel : FHDetailBaseModel

@property (nonatomic, weak)     UITableView       *tableView;
@property (nonatomic, assign)   NSInteger       currentSelIndex; // 0二手房，1租房
@property (nonatomic, assign)   NSInteger       firstSelIndex;// -1，第一次选中
@property (nonatomic, strong , nullable) FHDetailSameNeighborhoodHouseResponseDataModel *sameNeighborhoodErshouHouseData;// 同小区房源，二手房
@property (nonatomic, strong , nullable) FHRentSameNeighborhoodResponseDataModel *sameNeighborhoodRentHouseData;// 同小区房源，租房

@end

NS_ASSUME_NONNULL_END
