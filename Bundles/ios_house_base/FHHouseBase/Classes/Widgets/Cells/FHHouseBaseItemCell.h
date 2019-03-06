//
//  FHHouseBaseItemCell.h
//  FHHouseBase
//
//  Created by 春晖 on 2019/3/5.
//

#import <UIKit/UIKit.h>
#import "FHHouseType.h"

NS_ASSUME_NONNULL_BEGIN
//当图图片cell
@class FHSingleImageInfoCellModel;
@class FHHomeHouseDataItemsModel;
@interface FHHouseBaseItemCell : UITableViewCell

-(void)updateWithHouseCellModel:(FHSingleImageInfoCellModel *)cellModel;

-(void)updateHomeHouseCellModel:(FHHomeHouseDataItemsModel *)commonModel andType:(FHHouseType)houseType;

-(void)refreshTopMargin:(CGFloat)top;


@end

NS_ASSUME_NONNULL_END
