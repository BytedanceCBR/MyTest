//
//  FHEntranceItemCell.h
//  FHHouseHome
//
//  Created by CYY RICH on 2020/11/9.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

#define ITEM_PER_ROW  5
#define TOP_MARGIN_PER_ROW 10
#define NORMAL_ICON_WIDTH  56
#define NEW_ICON_WIDTH 36
#define NORMAL_NAME_HEIGHT 20
#define NORMAL_ITEM_WIDTH  40
#define ITEM_TAG_BASE      100

@class FHConfigDataOpDataItemsModel;

@interface FHHomeEntranceItemCell : UICollectionViewCell

- (void)bindModel:(FHConfigDataOpDataItemsModel *)model;

@end

NS_ASSUME_NONNULL_END
