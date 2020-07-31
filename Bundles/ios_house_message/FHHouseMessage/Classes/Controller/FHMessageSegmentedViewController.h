//
//  FHMessageSegmentedViewController.h
//  Pods
//
//  Created by bytedance on 2020/7/30.
//

#import "FHBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@class FHMessageSegmentedViewController;

@protocol FHMessageSegmentedViewControllerDelegate <NSObject>
@optional

- (void)segmentedViewController:(FHMessageSegmentedViewController *)segmentedViewController willChangeContentViewControllerFromViewController:(UIViewController *)fromViewController toViewController:(UIViewController *)toViewController;

- (void)segmentedViewController:(FHMessageSegmentedViewController *)segmentedViewController didChangeContentViewControllerFromViewController:(UIViewController *)fromViewController toViewController:(UIViewController *)toViewController;

@end


@interface FHMessageSegmentedViewController : FHBaseViewController

@property (nonatomic,weak) id<FHMessageSegmentedViewControllerDelegate> delegate;

@property (nonatomic,strong,readonly) UISegmentedControl *segmentedControl;

@property (nonatomic,copy) NSArray *viewControllers;

@property (nonatomic,readonly,weak) UIViewController *activeViewController;

@property (nonatomic,readonly,weak) UIPanGestureRecognizer *interactivePanGestureRecognizer;

- (void)selectViewControllerAtIndex:(NSInteger)index;

@end

NS_ASSUME_NONNULL_END
