//
//  FHHouseSearchSecondHouseCell.h
//  FHHouseBase
//
//  Created by xubinbin on 2020/8/24.
//

#import "FHListBaseCell.h"
#import "FHHouseCardStatusManager.h"

NS_ASSUME_NONNULL_BEGIN
//新二手房列表页、搜索页cell
@class FHHouseSearchSecondHouseCell;
@class FHHomeHouseDataItemsModel;
@protocol FHHouseSearchSecondHouseCellDelegate <NSObject>

@optional
//dislike确认
- (void)dislikeConfirm:(FHHomeHouseDataItemsModel *)model cell:(FHHouseSearchSecondHouseCell *)cell;
//dislike按钮点击前
- (BOOL)canDislikeClick;

@end

@interface FHHouseSearchSecondHouseCell : FHListBaseCell<FHHouseCardReadStateProtocol>

@property (nonatomic, weak) id<FHHouseSearchSecondHouseCellDelegate> delegate;

- (void)updateHeightByTopMargin:(CGFloat)topMarigin;

- (void)resumeVRIcon;

- (void)updateHeightByIsFirst:(BOOL)isFirst;

@end

NS_ASSUME_NONNULL_END
