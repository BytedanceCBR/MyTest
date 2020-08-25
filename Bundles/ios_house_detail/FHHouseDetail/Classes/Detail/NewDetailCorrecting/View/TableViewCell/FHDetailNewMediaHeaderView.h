//
//  FHDetailNewMediaHeaderView.h
//  FHHouseDetail
//
//  Created by luowentao on 2020/8/25.
//

#import <UIKit/UIKit.h>
#import "FHDetailNewMediaHeaderScrollView.h"
NS_ASSUME_NONNULL_BEGIN

@interface FHDetailNewMediaHeaderView : UIView

@property (nonatomic, assign) BOOL showHeaderImageNewType;

- (void)updateMultiMediaModel :(FHMultiMediaModel *)model;
- (void)updateTitleModel: (FHDetailHouseTitleModel *)model;
- (void)setTotalPagesLabelText:(NSString *)text;

//点击了某个Cell
@property (nonatomic, copy) FHDetailNewMediaHeaderViewEventByIndex didSelectiItemAtIndex;
//某个Cell展示时
@property (nonatomic, copy) FHDetailNewMediaHeaderViewEventByIndex willDisplayCellForItemAtIndex;
//从头图进入图片相册
@property (nonatomic, copy) FHDetailNewMediaHeaderViewEventByString goToPictureListFrom;
//滑动到某处
@property (nonatomic, copy) FHDetailNewMediaHeaderViewEventByIndex scrollToIndex;
//点击itemView （VR,视频,图片,户型）
@property (nonatomic, copy) FHDetailNewMediaHeaderViewEventByString didClickItemViewName;

@end

NS_ASSUME_NONNULL_END
