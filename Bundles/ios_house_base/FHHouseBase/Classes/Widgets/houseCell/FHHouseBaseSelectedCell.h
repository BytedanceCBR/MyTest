//
//  FHHouseBaseSelectedCell.h
//  FHHouseBase
//
//  Created by xubinbin on 2020/11/4.
//

#import "FHHouseBaseCell.h"
#import "FHSingleImageInfoCellModel.h"

NS_ASSUME_NONNULL_BEGIN
//房源卡片基类 业务代码可继承，不可直接使用基类
@interface FHHouseBaseSelectedCell : FHHouseBaseCell

@property (nonatomic, strong) FHSingleImageInfoCellModel *cellModel;

- (void)setItemSelected:(BOOL)itemSelected;

- (void)setDisable:(BOOL)isDisable;

- (void)updateTitlesLayout:(BOOL)showTags;

@end

NS_ASSUME_NONNULL_END
