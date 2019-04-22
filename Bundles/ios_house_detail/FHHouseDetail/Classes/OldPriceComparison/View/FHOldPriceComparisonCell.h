//
//  FHOldPriceComparisonCell.h
//  FHHouseDetail
//
//  Created by 谢思铭 on 2019/4/10.
//

#import <UIKit/UIKit.h>
#import "FHHouseType.h"

NS_ASSUME_NONNULL_BEGIN
//当图图片cell
@class FHSingleImageInfoCellModel;
@class FHHomeHouseDataItemsModel;
@interface FHOldPriceComparisonCell : UITableViewCell

- (void)updateWithHouseCellModel:(FHSingleImageInfoCellModel *)cellModel;

- (void)refreshTopMargin:(CGFloat)top;

@end

NS_ASSUME_NONNULL_END
