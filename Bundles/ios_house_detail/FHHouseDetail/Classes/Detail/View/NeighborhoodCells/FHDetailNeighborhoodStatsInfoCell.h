//
//  FHDetailNeighborhoodStatsInfoCell.h
//  FHHouseDetail
//
//  Created by 张元科 on 2019/2/18.
//

#import "FHDetailBaseCell.h"
#import "FHDetailBaseModel.h"
#import "FHDetailNeighborhoodModel.h"
#import "FHHouseDetailBaseViewModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHDetailNeighborhoodStatsInfoCell : FHDetailBaseCell

@end

// FHDetailNeighborhoodStatsInfoModel
@interface FHDetailNeighborhoodStatsInfoModel : FHDetailBaseModel

@property (nonatomic, strong , nullable) NSArray<FHDetailNeighborhoodDataStatsInfoModel> *statsInfo;

@end
// 按钮
@interface FHDetailNeighborhoodItemButtonControl : UIControl

@property (nonatomic, assign)   BOOL       isEnabled;
@property (nonatomic, strong)   UILabel       *valueLabel;
@property (nonatomic, strong)   UIImageView       *rightArrowImageView;

@end
// 小区头部成交房源套数
@interface FHDetailNeighborhoodItemValueView : UIControl

@property (nonatomic, assign)   BOOL       isDataEnabled;
@property (nonatomic, strong)   UILabel       *keyLabel;
@property (nonatomic, strong)   FHDetailNeighborhoodItemButtonControl       *valueDataLabel;

@end

NS_ASSUME_NONNULL_END
