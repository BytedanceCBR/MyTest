//
//  TSVCategoryContainerViewController.h
//  Article
//
//  Created by 王双华 on 2017/7/27.
//
//

#import <UIKit/UIKit.h>
#import "TTCategory.h"
#import "TTFeedCollectionCell.h"

NS_ASSUME_NONNULL_BEGIN

@class TSVCategoryContainerViewController;

@protocol TSVCategoryContainerViewControllerDelegate <NSObject>

@optional

/**
 *  Called when user is dragging the page
 *
 *  @param vc container view controller
 *  @param fromIndex          page which occupied over 50% of the screen, equal to current page
 *  @param toIndex            page which occupied below 50% of the screen
 *  @param percent            percent = current page width offscreen / current page width.
 *                            percent > 0 means scrolling from left to right, vice versa.
 *                            Ranging from -0.5 to 0.5
 */
- (void)tsvCategoryContainerViewController:(TSVCategoryContainerViewController *)vc scrollFromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex completePercent:(CGFloat)percent;

/**
 *  Called on finger up after dragging
 *
 *  @param vc container view controller
 *  @param toIndex            target index when stop scrollong
 */
- (void)tsvCategoryContainerViewController:(TSVCategoryContainerViewController *)vc willScrollToIndex:(NSInteger)toIndex;


- (void)tsvCategoryContainerViewController:(TSVCategoryContainerViewController *)vc didScrollToIndex:(NSInteger)toIndex;

- (void)tsvCategoryContainerViewControllerWillBeginDragging:(UIScrollView *)scrollView;

- (void)tsvCategoryContainerViewControllerDidStartLoading:(TSVCategoryContainerViewController *)vc;

- (void)tsvCategoryContainerViewControllerDidFinishLoading:(TSVCategoryContainerViewController *)vc isUserPull:(BOOL)userPull;

@end


@interface TSVCategoryContainerViewController : UIViewController

/**
 *  Model. Page will reload after setting newValue.
 */
@property (nonatomic, copy) NSArray<TTCategory *> *pageCategories;

/**
 *  Delegate
 */
@property (nonatomic, weak, nullable) id<TSVCategoryContainerViewControllerDelegate> delegate;

/**
 *  Update current page index and scroll to centered position
 */
- (void)setCurrentIndex:(NSInteger)index scrollToPositionAnimated:(BOOL)animated;

/// 获取 CollectionView 当前展示的 Cell
- (UICollectionViewCell<TTFeedCollectionCell> *)currentCollectionPageCell;

- (nullable TTCategory *)currentCategory;

@end

NS_ASSUME_NONNULL_END
