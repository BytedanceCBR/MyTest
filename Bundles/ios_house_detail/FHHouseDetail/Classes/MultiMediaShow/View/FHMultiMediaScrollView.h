//
//  FHMultiMediaScrollView.h
//  FHHouseMine
//
//  Created by 谢思铭 on 2019/4/15.
//

#import <UIKit/UIKit.h>
#import "FHMultiMediaModel.h"
#import "FHVideoViewController.h"

NS_ASSUME_NONNULL_BEGIN

@protocol FHMultiMediaScrollViewDelegate <NSObject>

- (void)didSelectItemAtIndex:(NSInteger)index;

- (void)willDisplayCellForItemAtIndex:(NSInteger)index;

- (void)selectItem:(NSString *)title;

@end

@interface FHMultiMediaScrollView : UIView

@property (nonatomic, assign) BOOL isShowenPictureVC;
@property(nonatomic, strong) FHVideoViewController *videoVC;
@property(nonatomic, strong) UICollectionViewCell *currentMediaCell;
@property(nonatomic , weak) id<FHMultiMediaScrollViewDelegate> delegate;

- (void)updateWithModel:(FHMultiMediaModel *)model;

- (void)scrollToItemAtIndexPath:(NSIndexPath *)indexPath atScrollPosition:(UICollectionViewScrollPosition)scrollPosition animated:(BOOL)animated;

- (void)updateItemAndInfoLabel;

@end

NS_ASSUME_NONNULL_END
