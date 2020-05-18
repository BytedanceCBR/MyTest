//
//  FHHouseListBaseItemCell.h
//  FHHouseBase
//
//  Created by liuyu on 2020/3/5.
//

#import "FHDetailBaseCell.h"
#import "FHSingleImageInfoCellModel.h"
#import "FHHomeHouseModel.h"
NS_ASSUME_NONNULL_BEGIN

@class FHHouseListBaseItemCell;

@protocol FHHouseListBaseItemCellDelegate <NSObject>

@optional
//dislike确认
- (void)dislikeConfirm:(FHHomeHouseDataItemsModel *)model cell:(FHHouseListBaseItemCell *)cell;
//dislike按钮点击前
- (BOOL)canDislikeClick;

@end

@interface FHHouseListBaseItemCell : FHDetailBaseCell
//更新首页混排新房cell
- (void)updateSynchysisNewHouseCellWithModel:(FHHomeHouseDataItemsModel *)model;
-(void)refreshIndexCorner:(BOOL)isFirst andLast:(BOOL)isLast;

////更新大类页混排新房cell
- (void)updateSynchysisNewHouseCellWithSearchHouseModel:(FHSearchHouseItemModel *)model;
@end

NS_ASSUME_NONNULL_END
