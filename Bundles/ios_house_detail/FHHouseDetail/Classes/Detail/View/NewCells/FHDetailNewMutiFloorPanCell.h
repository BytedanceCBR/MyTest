//
//  FHDetailNewMutiFloorPanCell.h
//  AFgzipRequestSerializer
//
//  Created by 谢飞 on 2019/2/17.
//

#import "FHDetailBaseCell.h"
#import "FHDetailBaseModel.h"
#import "FHDetailNewModel.h"
#import "FHDetailTagBackgroundView.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHDetailNewMutiFloorPanCell : FHDetailBaseCell

@end


#pragma mark -  CollectionCell

// 楼盘item
@interface FHDetailNewMutiFloorPanCollectionCell : FHDetailBaseCollectionCell

@property (nonatomic, strong)   UIView        *iconView;
@property (nonatomic, strong)   UIImageView   *icon;
@property (nonatomic, strong)   UILabel       *titleLabel;
@property (nonatomic, strong)   FHDetailTagBackgroundView        *tagBacView;
@property (nonatomic, strong)   UILabel       *priceLabel;
@property (nonatomic, strong)   UILabel       *spaceLabel;
@property (nonatomic, strong)   UIButton      *consultDetailButton;

@end


@interface FHDetailNewMutiFloorPanCellModel : FHDetailBaseModel

@property (nonatomic, strong , nullable) FHDetailNewDataFloorpanListModel *floorPanList;
@property (nonatomic, weak)     UITableView       *tableView;
@property (nonatomic, weak) FHHouseDetailContactViewModel *contactViewModel;


@end


NS_ASSUME_NONNULL_END
