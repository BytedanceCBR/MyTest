//
//  FHDetailRentHouseOutlineInfoCell.h
//  FHHouseDetail
//
//  Created by 张元科 on 2019/2/18.
//

#import "FHDetailBaseCell.h"
#import "FHDetailBaseModel.h"
#import "FHDetailRentModel.h"
#import "FHHouseDetailBaseViewModel.h"

NS_ASSUME_NONNULL_BEGIN

@class FHDetailHouseOutlineInfoView;
// 后续可能和二手房 样式不同
@interface FHDetailRentHouseOutlineInfoCell : FHDetailBaseCell

@end

// FHDetailHouseOutlineInfoModel
@interface FHDetailRentHouseOutlineInfoModel : FHDetailBaseModel

@property (nonatomic, weak)     FHHouseDetailBaseViewModel       *baseViewModel;
@property (nonatomic, strong , nullable) FHRentDetailResponseDataHouseOverviewModel *houseOverreview ;

@end


NS_ASSUME_NONNULL_END
