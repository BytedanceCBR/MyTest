//
//  FHDetailHouseOutlineInfoCorrectingCell.h
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
@interface FHDetailHouseOutlineInfoCorrectingCell : FHDetailBaseCell

@end

// FHDetailHouseOutlineInfoView
@interface FHDetailHouseOutlineInfoCorrectingView : UIView

@property (nonatomic, strong)   UIImageView       *iconImg;
@property (nonatomic, strong)   UILabel       *keyLabel;
@property (nonatomic, strong)   UILabel       *valueLabel;

- (void)showIconAndTitle:(BOOL)showen;

@end

// FHDetailHouseOutlineInfoModel
@interface FHDetailHouseOutlineInfoCorrectingModel : FHDetailBaseModel
@property (nonatomic, weak)     UITableView       *tableView;
@property (nonatomic, assign) BOOL isFold;
@property (nonatomic, weak)     FHHouseDetailBaseViewModel       *baseViewModel;
@property (nonatomic, strong , nullable) FHDetailOldDataHouseOverreviewModel *houseOverreview ;
@property (nonatomic, assign)   BOOL       hideReport;

@end

NS_ASSUME_NONNULL_END
