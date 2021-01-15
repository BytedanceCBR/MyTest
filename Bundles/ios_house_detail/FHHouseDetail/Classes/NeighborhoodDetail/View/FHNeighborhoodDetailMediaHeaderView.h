//
//  FHNeighborhoodDetailMediaHeaderView.h
//  FHHouseDetail
//
//  Created by luowentao on 2020/10/10.
//

#import <UIKit/UIKit.h>
#import "FHDetailNewMediaHeaderScrollView.h"
#import "FHHouseDetailBaseViewModel.h"
NS_ASSUME_NONNULL_BEGIN

@interface FHNeighborhoodDetailMediaHeaderView : UIView
@property (nonatomic, weak) FHHouseDetailBaseViewModel *baseViewModel;
- (void)updateMultiMediaModel :(FHMultiMediaModel *)model;
- (void)scrollToItemAtIndex:(NSInteger)index;
+ (CGFloat)cellHeight;
//点击了某个Cell
@property (nonatomic, copy) FHDetailNewMediaHeaderViewEventByIndex didSelectiItemAtIndex;
//某个Cell展示时
@property (nonatomic, copy) FHDetailNewMediaHeaderViewEventByIndex willDisplayCellForItemAtIndex;
//从头图进入图片相册
@property (nonatomic, copy) FHDetailNewMediaHeaderViewEventByString goToPictureListFrom;
//点击itemView （VR,视频,图片,户型）
@property (nonatomic, copy) FHDetailNewMediaHeaderViewEventByString didClickItemViewName;

@end

NS_ASSUME_NONNULL_END
