//
//  FHDetailHouseOutlineInfoCell.h
//  FHHouseDetail
//
//  Created by 张元科 on 2019/2/14.
//

#import "FHDetailBaseCell.h"
#import "FHDetailBaseModel.h"
#import "FHDetailOldModel.h"
#import "FHHouseDetailBaseViewModel.h"

NS_ASSUME_NONNULL_BEGIN

// 房源概况
@interface FHDetailHouseOutlineInfoCell : FHDetailBaseCell

@end

// FHDetailHouseOutlineInfoView
@interface FHDetailHouseOutlineInfoView : UIView

@property (nonatomic, strong)   UIImageView       *iconImg;

@end

// FHDetailHouseOutlineInfoModel
@interface FHDetailHouseOutlineInfoModel : FHDetailBaseModel

@property (nonatomic, strong , nullable) FHDetailOldDataHouseOverreviewModel *houseOverreview ;

@end

NS_ASSUME_NONNULL_END
