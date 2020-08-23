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
@protocol FHDetailNewMediaHeaderScrollViewDelegate <NSObject>
//点击某个Cell后
- (void)didSelectItemAtIndex:(NSInteger)index;
//某个Cell展现后
- (void)willDisplayCellForItemAtIndex:(NSInteger)index;
//底部导航被点击后
- (void)selectItem:(NSString *)title;
//进入图片相册
- (void)goToPictureListFrom:(NSString *)from;
@end

@interface FHDetailNewMediaHeaderScrollView : UIView

@property (nonatomic, assign) BOOL isShowenPictureVC;
@property(nonatomic, strong) FHVideoViewController *videoVC;
@property(nonatomic, strong) FHMultiMediaVideoCell *currentMediaCell;
@property(nonatomic , weak) id<FHDetailNewMediaHeaderScrollViewDelegate> delegate;
@property(nonatomic, strong) NSDictionary *tracerDic;
@property (nonatomic, weak) FHHouseDetailBaseViewModel *baseViewModel;
@property (nonatomic, assign) BOOL isShowTopImageTab; //新房详情 展示新UI
@property (nonatomic, assign) NSUInteger exposeImageNum; //展示几张

- (void)updateModel:(FHMultiMediaModel *)model;

//移动到某个Cell
- (void)scrollToItemAtIndexPath:(NSIndexPath *)indexPath atScrollPosition:(UICollectionViewScrollPosition)scrollPosition animated:(BOOL)animated;

- (void)updateItemAndInfoLabel;

- (void)updateVideoState;



@end

NS_ASSUME_NONNULL_END
