//
//  TTVSegmentedPageViewController.h
//  Article
//
//  Created by pei yun on 2017/3/22.
//
//

#import "TTVBaseViewController.h"
#import "TTVSegmentedControl.h"

@protocol TTVSegmentedPageLoadDataProtocol <NSObject>

- (void)loadDataWhenNeeded;

@end

@protocol TTVSegmentedPageRefreshProtocol <NSObject>

- (void)refreshListIfOutdated;

@end

@protocol TTVSegmentedPageViewDelegate <NSObject>

@optional
- (void)viewControllerDidBecomeInvisible:(UIViewController *)viewController isSwiping:(BOOL)isSwiping;
- (void)viewControllerDidBecomeVisible:(UIViewController *)viewController firstAppear:(BOOL)firstAppear isSwiping:(BOOL)isSwiping;
- (void)viewControllerFromIndex:(NSUInteger)fromIndex toIndex:(NSUInteger)toIndex;

@end

@interface TTVSegmentedPageViewController : TTVBaseViewController <UIScrollViewDelegate, TTVSegmentedPageViewDelegate>

@property (nonatomic, readonly) NSArray *viewControllers;
@property (nonatomic, readonly) UIScrollView *pageScrollView;
@property (nonatomic, readonly) NSUInteger currentPageIndex;
@property (nonatomic, readonly) BOOL isMovingForward;
@property (nonatomic, readonly) id <TTVSegmentedControl> segmentedControl;
@property (nonatomic, weak) id <TTVSegmentedPageViewDelegate> pageDelegate; // defaults to self
@property (nonatomic, assign) BOOL rightPopAllowed;
@property (nonatomic, assign) CGRect viewFrame;

- (void)switchToPageIndex:(NSUInteger)idx animated:(BOOL)animated;
- (void)setViewControllers:(NSArray *)viewControllers segmentedControl:(id<TTVSegmentedControl> )segmentedControl; // segmentedControl will not be added to the view

@end
