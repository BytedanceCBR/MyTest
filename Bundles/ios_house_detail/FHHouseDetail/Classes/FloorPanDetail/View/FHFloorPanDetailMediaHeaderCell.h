//
//  FHFloorPanDetailMediaHeaderCell.h
//  FHHouseDetail
//
//  Created by luowentao on 2020/9/7.
//

#import "FHDetailBaseCell.h"
#import "FHDetailOldModel.h"
#import "FHMultiMediaModel.h"
#import "FHHouseDetailContactViewModel.h"
#import "FHDetailHouseTitleModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHFloorPanDetailMediaHeaderCell : FHDetailBaseCell



@end

@interface FHFloorPanDetailMediaHeaderModel : FHDetailBaseModel
@property (nonatomic, weak) FHHouseDetailContactViewModel *contactViewModel;
@property (strong, nonatomic) FHDetailHouseTitleModel *titleDataModel;//标题，标签模型
@property (nonatomic, weak) UIViewController *weakVC;
@property (nonatomic, strong) FHHouseDetailMediaInfo *albumInfo;
@property (nonatomic, strong) FHHouseDetailMediaInfo *topImages;
@end

NS_ASSUME_NONNULL_END
