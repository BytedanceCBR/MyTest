//
//  FHDetailNeighborhoodPropertyInfoCell.h
//  FHHouseDetail
//
//  Created by 张元科 on 2019/2/19.
//

#import "FHDetailBaseCell.h"
#import "FHDetailBaseModel.h"
#import "FHDetailNeighborhoodModel.h"
#import "FHHouseDetailBaseViewModel.h"

NS_ASSUME_NONNULL_BEGIN

// 属性列表，可折叠
@interface FHDetailNeighborhoodPropertyInfoCell : FHDetailBaseCell

@end

// FHDetailNeighborhoodPropertyInfoModel
@interface FHDetailNeighborhoodPropertyInfoModel : FHDetailBaseModel

@property (nonatomic, weak)     UITableView       *tableView;
@property (nonatomic, assign)   BOOL       isFold; // 折叠
@property (nonatomic, strong , nullable) NSArray<FHDetailNeighborhoodDataBaseInfoModel> *baseInfo;

@end

@interface FHDetailNeighborhoodPropertyItemView : UIView

@property (nonatomic, strong)   UILabel       *keyLabel;
@property (nonatomic, strong)   UILabel       *valueLabel;

@end

NS_ASSUME_NONNULL_END
