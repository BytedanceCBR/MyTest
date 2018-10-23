//
//  TTSwipePageViewController.h
//  Article
//
//  Created by Dai Dongpeng on 4/9/16.
//
//

#import <UIKit/UIKit.h>

@protocol TTSwipePageViewControllerDelegate;

@interface TTSwipePageViewController : UIViewController

// 必须是UIView 或者 UIViewController
@property (nonatomic, copy) NSArray <__kindof UIResponder *> *pages;
@property (nonatomic, weak) id <TTSwipePageViewControllerDelegate> delegate;

//默认为NO
@property (nonatomic) BOOL shouldAutoForwordAppearances;

- (instancetype)initWithDefaultSelectedIndex:(NSUInteger)defaultIndex;

- (UIScrollView *)internalScrollView;
- (UIViewController *)currentPageViewController;
- (UIViewController *)pageViewControllerWithIndex:(NSInteger)index;
- (void)setSelectedIndex:(NSUInteger)selectedIndex; // default, animated is `YES`.
- (void)setSelectedIndex:(NSUInteger)selectedIndex animated:(BOOL)animated;

@end

@protocol TTSwipePageViewControllerDelegate <NSObject>

@optional
- (void)pageViewController:(TTSwipePageViewController *)pageViewController
           pagingFromIndex:(NSInteger)fromIndex
                   toIndex:(NSInteger)toIndex
           completePercent:(CGFloat)percent;

- (void)pageViewController:(TTSwipePageViewController *)pageViewController
         willPagingToIndex:(NSInteger)toIndex;

- (void)pageViewController:(TTSwipePageViewController *)pageViewController
          didPagingToIndex:(NSInteger)toIndex;

- (void)pageViewControllerWillBeginDragging:(UIScrollView *)scrollView;

@end

@interface UIViewController (TTSWipePageAddition)

@property BOOL tt_ControllerIsVisiable;

@end
