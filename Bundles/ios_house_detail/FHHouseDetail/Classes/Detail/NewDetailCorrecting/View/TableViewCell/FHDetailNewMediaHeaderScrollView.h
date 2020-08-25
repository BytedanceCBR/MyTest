//
//  FHDetailNewMediaHeaderScrollView.h
//  FHHouseDetail
//
//  Created by luowentao on 2020/8/21.
//

#import <UIKit/UIKit.h>
#import "FHMultiMediaModel.h"
#import "FHVideoViewController.h"
#import "FHMultiMediaVideoCell.h"
#import "FHDetailHouseTitleModel.h"

NS_ASSUME_NONNULL_BEGIN
typedef void(^FHDetailNewMediaHeaderViewEventByIndex)(NSInteger index);
typedef void(^FHDetailNewMediaHeaderViewEventByString)(NSString *name);

@interface FHDetailNewMediaHeaderScrollView : UIView

@property (nonatomic, assign) BOOL closeInfinite; //关闭无限轮播
//点击了某个Cell
@property (nonatomic, copy) FHDetailNewMediaHeaderViewEventByIndex didSelectiItemAtIndex;
//某个Cell展示时
@property (nonatomic, copy) FHDetailNewMediaHeaderViewEventByIndex willDisplayCellForItemAtIndex;
//从头图进入图片相册
@property (nonatomic, copy) FHDetailNewMediaHeaderViewEventByString goToPictureListFrom;
//滑动到某处
@property (nonatomic, copy) FHDetailNewMediaHeaderViewEventByIndex scrollToIndex;

- (void)updateModel:(FHMultiMediaModel *)model;

//移动到某个Cell
- (void)scrollToItemAtIndexPath:(NSIndexPath *)indexPath atScrollPosition:(UICollectionViewScrollPosition)scrollPosition animated:(BOOL)animated;
- (NSInteger)getCurPagae;
@end

NS_ASSUME_NONNULL_END
