//
//  Created by xubinbin on 2020/8/14.
//

#import "FHMessageSwipeView.h"
#import "FHMessageSwipeButton.h"
#import "FHMessageSwipeTableCell.h"

static inline CGFloat mgEaseLinear(CGFloat t, CGFloat b, CGFloat c) {
    return c*t + b;
}

static inline CGFloat mgEaseInQuad(CGFloat t, CGFloat b, CGFloat c) {
    return c*t*t + b;
}
static inline CGFloat mgEaseOutQuad(CGFloat t, CGFloat b, CGFloat c) {
    return -c*t*(t-2) + b;
}
static inline CGFloat mgEaseInOutQuad(CGFloat t, CGFloat b, CGFloat c) {
    if ((t*=2) < 1) return c/2*t*t + b;
    --t;
    return -c/2 * (t*(t-2) - 1) + b;
}
static inline CGFloat mgEaseInCubic(CGFloat t, CGFloat b, CGFloat c) {
    return c*t*t*t + b;
}
static inline CGFloat mgEaseOutCubic(CGFloat t, CGFloat b, CGFloat c) {
    --t;
    return c*(t*t*t + 1) + b;
}
static inline CGFloat mgEaseInOutCubic(CGFloat t, CGFloat b, CGFloat c) {
    if ((t*=2) < 1) return c/2*t*t*t + b;
    t-=2;
    return c/2*(t*t*t + 2) + b;
}
static inline CGFloat mgEaseOutBounce(CGFloat t, CGFloat b, CGFloat c) {
    if (t < (1/2.75)) {
        return c*(7.5625*t*t) + b;
    } else if (t < (2/2.75)) {
        t-=(1.5/2.75);
        return c*(7.5625*t*t + .75) + b;
    } else if (t < (2.5/2.75)) {
        t-=(2.25/2.75);
        return c*(7.5625*t*t + .9375) + b;
    } else {
        t-=(2.625/2.75);
        return c*(7.5625*t*t + .984375) + b;
    }
};
static inline CGFloat mgEaseInBounce(CGFloat t, CGFloat b, CGFloat c) {
    return c - mgEaseOutBounce (1.0 -t, 0, c) + b;
};

static inline CGFloat mgEaseInOutBounce(CGFloat t, CGFloat b, CGFloat c) {
    if (t < 0.5) return mgEaseInBounce (t*2, 0, c) * .5 + b;
    return mgEaseOutBounce (1.0 - t*2, 0, c) * .5 + c*.5 + b;
};



@interface FHMessageSwipeView ()

@property (nonatomic, strong) UIView *containView; /**< 装swipeButton的容器*/
@property (nonatomic, strong) NSArray *buttonArray; /**< 重新排序后的buttons*/
@property (nonatomic, assign) UIEdgeInsets btnEdge; /**< swipeBtn间距*/

@end

@implementation FHMessageSwipeView

- (instancetype)initWithButtons:(NSArray *)buttos fromRight:(BOOL)fromRight cellHeght:(CGFloat)cellHeight edge:(UIEdgeInsets)edge
{
    CGFloat containerWidth = 0;
    CGFloat horizontalSpace = ABS(edge.left) + ABS(edge.right);
    CGFloat verticalSpace = ABS(edge.top) + ABS(edge.bottom);
    // 计算buttons的总宽度
    for(FHMessageSwipeButton *button in buttos){
        containerWidth += MAX(button.frame.size.width, cellHeight - verticalSpace);
    }
    // 加上左右间距
    containerWidth += horizontalSpace;
    
    if([super initWithFrame:CGRectMake(0, 0, containerWidth, cellHeight - verticalSpace)])
    {
        self.btnEdge = edge;
        self.duration = 0.3;
        self.easingFunction = MGSwipeEasingFunctionCubicOut;
        self.containView.frame = CGRectMake(0, ABS(edge.top), containerWidth, cellHeight - verticalSpace);
        
        // 若是右滑 则倒序。即将数组的最后一个元素放在swipeView的最后
        self.buttonArray = fromRight ? [[buttos reverseObjectEnumerator] allObjects] : buttos;
        [self addSubview:self.containView];
        
        CGFloat offset = ABS(edge.left);
        for(FHMessageSwipeButton *button in self.buttonArray)
        {
            button.frame = CGRectMake(offset, 0, MAX(button.frame.size.width, cellHeight - verticalSpace), cellHeight - verticalSpace);
            offset += button.frame.size.width;
            // 防止重用问题，移除点击事件
            [button removeTarget:self action:@selector(touchSwipeButton:) forControlEvents:UIControlEventTouchUpInside];
            [button addTarget:self action:@selector(touchSwipeButton:) forControlEvents:UIControlEventTouchUpInside];
            // 直接用addSubview会覆盖左滑的动画效果
            [self.containView insertSubview:button atIndex:fromRight ? self.containView.subviews.count : 0];
        }
    }
    return self;
}

/**
 * 点击滑动按钮的响应事件
 */
- (void)touchSwipeButton:(FHMessageSwipeButton *)btn
{
    // 点击按钮隐藏滑动按钮，即将cell恢复原状
    [self hideSwipeView];
    // 点击按钮的回调事件
    btn.touchBlock();
}

/**
 * 点击SwipeButton隐藏SwipeView，即将cell恢复原状
 */
- (void)hideSwipeView
{
    FHMessageSwipeTableCell *cell = nil;
    UIView *view = self.superview;
    while (view != nil)
    {
        if([view isKindOfClass:[FHMessageSwipeTableCell class]])
        {
            cell = (FHMessageSwipeTableCell *)view;
            break;
        }
        view = view.superview;
    }
    if(cell.swipeDelegate && [cell.swipeDelegate respondsToSelector:@selector(hideSwipeViewWhenClickSwipeButtonAtCell:)])
    {
        cell.hideSwipeViewWhenClickSwipeButton = [cell.swipeDelegate hideSwipeViewWhenClickSwipeButtonAtCell:cell];
    }
    [cell hiddenSwipeAnimationAtCell:cell.hideSwipeViewWhenClickSwipeButton];
}

#pragma mark -- 动画效果

// 手势动画效果
-(CGFloat)value:(CGFloat)elapsed duration:(CGFloat)duration from:(CGFloat)from to:(CGFloat)to
{
    CGFloat t = MIN(elapsed/duration, 1.0f);
    if (t == 1.0) {
        return to;
    }
    CGFloat (*easingFunction)(CGFloat t, CGFloat b, CGFloat c) = 0;
    switch (_easingFunction) {
        case MGSwipeEasingFunctionLinear: easingFunction = mgEaseLinear; break;
        case MGSwipeEasingFunctionQuadIn: easingFunction = mgEaseInQuad; break;
        case MGSwipeEasingFunctionQuadOut: easingFunction = mgEaseOutQuad; break;
        case MGSwipeEasingFunctionQuadInOut: easingFunction = mgEaseInOutQuad; break;
        case MGSwipeEasingFunctionCubicIn: easingFunction = mgEaseInCubic; break;
        default:
        case MGSwipeEasingFunctionCubicOut: easingFunction = mgEaseOutCubic;break;
        case MGSwipeEasingFunctionCubicInOut: easingFunction = mgEaseInOutCubic;break;
        case MGSwipeEasingFunctionBounceIn: easingFunction = mgEaseInBounce;break;
        case MGSwipeEasingFunctionBounceOut: easingFunction = mgEaseOutBounce;break;
        case MGSwipeEasingFunctionBounceInOut: easingFunction = mgEaseInOutBounce;break;
    }
    return (*easingFunction)(t, from, to - from);
}

// swipeView的弹出动画效果
- (void)swipeViewAnimationFromRight:(BOOL)fromRight effect:(CGFloat)t cellHeight:(CGFloat)cellHeight
{
    //CGFloat verticalSpace = self.btnEdge.top + self.btnEdge.bottom;
    switch (self.mode)
    {
        case SwipeViewTransfromModeStatic:
        {
            const CGFloat dx = self.bounds.size.width * (1.0 - t);
            CGFloat offsetX = ABS(self.btnEdge.left);
            
            for (UIView *button in self.buttonArray) {
                CGRect frame = button.frame;
                frame.origin.x = offsetX + (fromRight ? -dx : dx);
                button.frame = CGRectMake(0, 0, 108, 80);
                offsetX += frame.size.width;
            }
        }
        break;
    }
}


- (void)removeAllSubViewsAtView:(UIView *)view
{
    while (view.subviews.count) {
        [[view.subviews lastObject] removeFromSuperview];
    }
}

#pragma mark -- 懒加载

- (UIView *)containView
{
    if(!_containView)
    {
        _containView = [[UIView alloc] initWithFrame:self.bounds];
        _containView.backgroundColor = [UIColor clearColor];
        _containView.clipsToBounds = YES;
    }
    return _containView;
}

- (NSArray *)buttonArray
{
    if(!_buttonArray)
    {
        _buttonArray = [NSArray array];
    }
    return _buttonArray;
}

@end