//
//  TTCollectionPageViewControllerDelegate.h
//  Pods
//
//  Created by fengyadong on 2017/3/13.
//
//

#import <Foundation/Foundation.h>

@protocol TTCollectionPageViewControllerDelegate <NSObject>

@optional

/**
 *  Called when user is dragging the page
 *
 *  @param pageViewController container view controller
 *  @param fromIndex          page which occupied over 50% of the screen, equal to current page
 *  @param toIndex            page which occupied below 50% of the screen
 *  @param percent            percent = current page width offscreen / current page width.
 *                            percent > 0 means scrolling from left to right, vice versa.
 *                            Ranging from -0.5 to 0.5
 */
- (void)pageViewController:(TTCollectionPageViewController *)pageViewController pagingFromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex completePercent:(CGFloat)percent;

/**
 *  Called on finger up after dragging
 *
 *  @param pageViewController container view controller
 *  @param toIndex            target index when stop scrollong
 */
- (void)pageViewController:(TTCollectionPageViewController *)pageViewController willPagingToIndex:(NSInteger)toIndex;

/**
 *  Called on scrollView stopped scrolling
 *
 *  @param pageViewController container view controller
 *  @param toIndex            current index
 */
- (void)pageViewController:(TTCollectionPageViewController *)pageViewController didPagingToIndex:(NSInteger)toIndex;



/**
 Called when scrollView will begin drag

 @param scrollView draggingScrollView
 */
- (void)pageCollectionViewWillBeginDragging:(UIScrollView *)scrollView;

@end
