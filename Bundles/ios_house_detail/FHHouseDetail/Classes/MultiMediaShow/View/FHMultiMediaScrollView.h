//
//  FHMultiMediaScrollView.h
//  FHHouseMine
//
//  Created by 谢思铭 on 2019/4/15.
//

#import <UIKit/UIKit.h>
#import "FHMultiMediaModel.h"

NS_ASSUME_NONNULL_BEGIN

@protocol FHMultiMediaScrollViewDelegate <NSObject>

- (void)didSelectItemAtIndex:(NSInteger)index;

@end

@interface FHMultiMediaScrollView : UIView

@property(nonatomic , weak) id<FHMultiMediaScrollViewDelegate> delegate;

- (void)updateWithModel:(FHMultiMediaModel *)model;

- (void)scrollToItemAtIndexPath:(NSIndexPath *)indexPath atScrollPosition:(UICollectionViewScrollPosition)scrollPosition animated:(BOOL)animated;

- (void)updateItemAndInfoLabel;

@end

NS_ASSUME_NONNULL_END
