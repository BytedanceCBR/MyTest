//
//  Created by xubinbin on 2020/8/14.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, MGSwipeEasingFunction) {
    MGSwipeEasingFunctionLinear = 0,
    MGSwipeEasingFunctionQuadIn,
    MGSwipeEasingFunctionQuadOut,
    MGSwipeEasingFunctionQuadInOut,
    MGSwipeEasingFunctionCubicIn,
    MGSwipeEasingFunctionCubicOut,
    MGSwipeEasingFunctionCubicInOut,
    MGSwipeEasingFunctionBounceIn,
    MGSwipeEasingFunctionBounceOut,
    MGSwipeEasingFunctionBounceInOut
};

typedef NS_ENUM(NSUInteger, SwipeViewTransfromMode)
{
    SwipeViewTransfromModeStatic, // 静态效果
};


@interface FHMessageSwipeView : UIView

@property (nonatomic, assign) CGFloat from;
@property (nonatomic, assign) CGFloat to;
@property (nonatomic, assign) CFTimeInterval start;
@property (nonatomic, assign) CGFloat duration; //动画持续时间 默认0.3
@property (nonatomic, assign) MGSwipeEasingFunction easingFunction; // 手势动画执行节奏
@property (nonatomic, assign) SwipeViewTransfromMode mode;// swipeView的弹出效果

/**
 *  初始化swipeView，添加滑动按钮
 */
- (instancetype)initWithButtons:(NSArray *)buttos fromRight:(BOOL)fromRight cellHeght:(CGFloat)cellHeight edge:(UIEdgeInsets)edge;

/**
 *  滑动手势滑动的距离超过swipeView的一半时，会自动显示或隐藏swipeView
 */
- (CGFloat)value:(CGFloat)elapsed duration:(CGFloat)duration from:(CGFloat)from to:(CGFloat)to;

/**
 *  swipeView的弹出、隐藏动画
 *
 *  @param fromRight  是否是右滑
 *  @param t          动画控制量
 *  @param cellHeight cell的高度
 */
- (void)swipeViewAnimationFromRight:(BOOL)fromRight effect:(CGFloat)t cellHeight:(CGFloat)cellHeight;

@end
