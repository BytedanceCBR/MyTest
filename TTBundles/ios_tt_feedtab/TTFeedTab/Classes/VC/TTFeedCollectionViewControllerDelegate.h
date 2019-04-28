//
//  TTFeedCollectionViewControllerDelegate.h
//  Article
//
//  Created by Chen Hong on 2017/3/28.
//
//

#import <Foundation/Foundation.h>

@class TTFeedCollectionViewController;

@protocol TTFeedCollectionViewControllerDelegate <NSObject>

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
- (void)ttFeedCollectionViewController:(TTFeedCollectionViewController *)vc scrollFromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex completePercent:(CGFloat)percent;

/**
 *  Called on finger up after dragging
 *
 *  @param vc container view controller
 *  @param toIndex            target index when stop scrollong
 */
- (void)ttFeedCollectionViewController:(TTFeedCollectionViewController *)vc willScrollToIndex:(NSInteger)toIndex;


- (void)ttFeedCollectionViewController:(TTFeedCollectionViewController *)vc didScrollToIndex:(NSInteger)toIndex;

- (void)ttFeedCollectionViewControllerWillBeginDragging:(UIScrollView *)scrollView;

- (void)ttFeedCollectionViewControllerDidStartLoading:(TTFeedCollectionViewController *)vc;

- (void)ttFeedCollectionViewControllerDidFinishLoading:(TTFeedCollectionViewController *)vc isUserPull:(BOOL)userPull;

@end
