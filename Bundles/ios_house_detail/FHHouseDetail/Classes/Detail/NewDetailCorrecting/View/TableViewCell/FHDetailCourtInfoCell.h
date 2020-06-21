//
//  FHDetailCourtInfoCell.h
//  FHHouseDetail
//
//  Created by 张静 on 2020/3/8.
//

#import "FHDetailBaseCell.h"
#import "FHDetailBaseModel.h"
#import "FHDetailNewModel.h"

NS_ASSUME_NONNULL_BEGIN

@class FHHouseDetailContactViewModel;
// 新房 周边配套里面地理位置信息
@interface FHDetailCourtInfoCell : FHDetailBaseCell

@end

@interface FHDetailCourtInfoCellModel : FHDetailBaseModel

@property (nonatomic, strong , nullable) FHDetailNewSurroundingInfo *surroundingInfo;
@property (nonatomic, weak)     UITableView       *tableView;
@property (nonatomic, weak) FHHouseDetailContactViewModel *contactViewModel;


@end

NS_ASSUME_NONNULL_END
