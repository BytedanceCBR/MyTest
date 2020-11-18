//
//  FHHomeRentCell.h
//  FHHouseHome
//
//  Created by xubinbin on 2020/11/2.
//

#import "FHHouseBaseUsuallyCell.h"
#import "FHHomeHouseModel.h"

NS_ASSUME_NONNULL_BEGIN

@class FHHomeRentCell;
@protocol FHHomeRentCellDelegate <NSObject>

@optional
//dislike确认
- (void)dislikeConfirm:(FHHomeHouseDataItemsModel *)model cell:(FHHomeRentCell *)cell;
//dislike按钮点击前
- (BOOL)canDislikeClick;

@end

@interface FHHomeRentCell : FHHouseBaseUsuallyCell

@property (nonatomic, weak) id<FHHomeRentCellDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
