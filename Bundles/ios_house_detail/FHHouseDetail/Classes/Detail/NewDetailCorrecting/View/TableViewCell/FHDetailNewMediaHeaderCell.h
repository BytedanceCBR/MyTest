//
//  FHDetailNewMediaHeaderCell.h
//  FHHouseDetail
//
//  Created by luowentao on 2020/8/21.
//

//新房专用头图
#import "FHDetailBaseCell.h"
#import "FHMultiMediaModel.h"
#import "FHHouseDetailContactViewModel.h"
#import "FHDetailHouseTitleModel.h"
#import "FHDetailNewModel.h"
NS_ASSUME_NONNULL_BEGIN
@class FHDetailNewTopImage;

@interface FHDetailNewMediaHeaderCell : FHDetailBaseCell

@end

@interface FHDetailNewMediaHeaderModel : FHDetailBaseModel
@property (strong, nonatomic) FHDetailHouseTitleModel *titleDataModel;//标题，标签模型
@property (nonatomic, weak) UIViewController *weakVC;

@property (nonatomic, strong) FHHouseDetailMediaInfo *albumInfo;
@property (nonatomic, strong) FHHouseDetailMediaInfo *courtTopImage;

@property (nonatomic, weak) FHHouseDetailContactViewModel *contactViewModel;

@end

NS_ASSUME_NONNULL_END
