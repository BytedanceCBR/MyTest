//
//  TTCollectionPageViewController.h
//  Article
//
//  Created by 刘廷勇 on 15/8/28.
//
//

#import <UIKit/UIKit.h>
#import "TTCategoryDefine.h"

@class TTCollectionPageViewController;

@protocol TTCollectionCell <NSObject>

// 频道驻留统计
- (void)enterCategory;
- (void)leaveCategory;

@optional

@property (nonatomic, weak) TTCollectionPageViewController *sourceViewController;

- (void)setupCellModel:(id)model isDisplay:(BOOL)isDisplay;
- (void)refreshIfNeeded;

- (void)refreshData;
- (void)willAppear;
- (void)didAppear;
- (void)willDisappear;
- (void)didDisappear;
@end

@protocol TTCollectionPageViewControllerDelegate;

@interface TTCollectionPageViewController : UIViewController

- (instancetype)initWithTabType:(TTCategoryModelTopType)tabType cellClass:(NSString *)classString;
- (instancetype)initWithTabType:(TTCategoryModelTopType)tabType cellClassStringArray:(NSArray *)cellClassStringArray;

@property (nonatomic, copy) NSString *(^getCellClassStringForIndexPath)(NSIndexPath *indexPath);

@property (nonatomic, assign, readonly) TTCategoryModelTopType tabType;

@property (nonatomic, assign) CGFloat topInset;
@property (nonatomic, assign) CGFloat bottomInset;

/**
 *  Model. Page will reload after setting newValue.
 */
@property (nonatomic, strong) NSArray *pageCategories;

/**
 *  Currently selected page index
 */
@property (nonatomic, readonly) NSInteger currentPage;

/**
 *  Delegate
 */
@property (nonatomic, weak) id <TTCollectionPageViewControllerDelegate> delegate;

/**
 *  Trigger reloading of current page
 */
- (void)reloadCurrentPage;

/**
 *  Trigger reloading of all pages
 */
- (void)reloadPages;

/**
 *  Update current page index and scroll to centered position
 *
 *  @param currentPage   new page index
 *  @param animated      YES to scroll current page to center position with animation, otherwise no animation
 */
- (void)setCurrentPage:(NSInteger)currentPage scrollToPositionCenteredAnimated:(BOOL)animated;

/// 获取 CollectionView 当前展示的 Cell
- (UICollectionViewCell<TTCollectionCell> *)currentCollectionPageCell;

- (UICollectionViewCell<TTCollectionCell> *)pageCellAtIndex:(NSInteger)index;

@end

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


///...
- (void)pageCollectionViewWillBeginDragging:(UIScrollView *)scrollView;

@end
