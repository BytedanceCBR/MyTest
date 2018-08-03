//
//  TTRNScrollView.m
//  Article
//
//  Created by yin on 2017/7/27.
//
//  wiki：https://wiki.bytedance.net/pages/viewpage.action?pageId=114231317
//  滑动效果引用   https://github.com/jan-christiansen/MOScrollView
//  这里重写了滑动效果，因为如果用UIView的自定义动画会导致Banner组件动画过程中消失
//  使用scrollView系统的setContentOffset方法是没有问题的胆识滑动的效果不好，所以这里
//  将滑动的效果重写了一下。。。       --yingjie

#import "TTRNScrollView.h"
#import "UIView+CustomTimingFunction.h"
#import <QuartzCore/QuartzCore.h>
#import "TTAdCanvasViewController.h"
#import "TTNavigationController.h"
#define kScrollListTopKey    @"top"
#define kScrollListHeightKey @"height"

const static CFTimeInterval kDefaultSetContentOffsetDuration = 0.25;
/// Constants used for Newton approximation of cubic function root.
const static double kApproximationTolerance = 0.00000001;
const static int kMaximumSteps = 10;

@interface TTRNScrollView () <UIScrollViewDelegate>

@property (nonatomic ,assign) NSUInteger cellingIndex;
@property (nonatomic, assign) BOOL endPull;
@property (nonatomic, assign) BOOL inAnimate;

/// Display link used to trigger event to scroll the view.
@property(nonatomic, strong) CADisplayLink *displayLink;

/// Timing function of an scroll animation.
@property(nonatomic, strong) CAMediaTimingFunction *timingFunction;

/// Duration of an scroll animation.
@property(nonatomic, assign) CFTimeInterval duration;

/// States whether the animation has started.
@property(nonatomic, assign) BOOL animationStarted;

/// Time at the begining of an animation.
@property(nonatomic, assign) CFTimeInterval beginTime;

/// The content offset at the begining of an animation.
@property(nonatomic, assign) CGPoint beginContentOffset;

/// The delta between the contentOffset at the start of the animation and
/// the contentOffset at the end of the animation.
@property(nonatomic, assign) CGPoint deltaContentOffset;

@end

@implementation TTRNScrollView

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)initWithEventDispatcher:(RCTEventDispatcher *)eventDispatcher
{
    if ((self = [super initWithEventDispatcher:eventDispatcher])) {
        [self registerLiveNotification];
    }
    return self;
}

- (void)registerLiveNotification
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(viewWillDisappear) name:kTTAdCanvasNotificationViewDidDisappear object:nil];
}

- (void)viewWillDisappear
{
    [self.displayLink invalidate];
    self.displayLink = nil;
}

- (void)setScrollList:(NSArray *)scrollList
{
    _scrollList = scrollList;
//    _scrollList = @[@{@"top":@(500), @"scope1":@(100), @"scope2":@(500), @"height":@(500)},
//                    @{@"top":@(1000), @"scope1":@(500), @"scope2":@(100), @"height":@(500)},
//                    @{@"top":@(1800), @"scope1":@(100), @"scope2":@(100), @"height":@(500)}];
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    [super scrollViewWillEndDragging:scrollView withVelocity:velocity targetContentOffset:targetContentOffset];
    
    if (!self.scrollList.count) {
        return;
    }
    self.cellingIndex = self.scrollList.count + 1;
    
    if (velocity.y > 0) {
        [self.scrollList enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj isKindOfClass:[NSDictionary class]]) {
                CGFloat top = [[obj objectForKey:kScrollListTopKey] floatValue];
                CGFloat scope1 = [[obj objectForKey:@"scope1"] floatValue];
                CGFloat scope2 = [[obj objectForKey:@"scope2"] floatValue];
                CGFloat height = [[obj objectForKey:@"height"] floatValue];
                CGFloat y = (*targetContentOffset).y;
                
                if ((scrollView.contentOffset.y > top && velocity.y < 0 && y > top - height && y < top) ||(scrollView.contentOffset.y < top && velocity.y > 0 && y > top && y < top + height)){
                    self.cellingIndex = idx;
                    *stop = YES;
                } else if ((velocity.y < 0 && y > top  && y < top + scope2) ||(velocity.y > 0 && y > top - scope1  && y < top)) {
                    self.cellingIndex = idx;
                    *stop = YES;
                }
            }
        }];

    } else {
        [self.scrollList enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj isKindOfClass:[NSDictionary class]]) {
                CGFloat top = [[obj objectForKey:kScrollListTopKey] floatValue];
                CGFloat scope1 = [[obj objectForKey:@"scope1"] floatValue];
                CGFloat scope2 = [[obj objectForKey:@"scope2"] floatValue];
                CGFloat height = [[obj objectForKey:@"height"] floatValue];
                CGFloat y = (*targetContentOffset).y;
                
                if ((scrollView.contentOffset.y > top && velocity.y < 0 && y > top - height && y < top) ||(scrollView.contentOffset.y < top && velocity.y > 0 && y > top && y < top + height)){
                    self.cellingIndex = idx;
                    *stop = YES;
                } else if ((velocity.y < 0 && y > top  && y < top + scope2) ||(velocity.y > 0 && y > top - scope1  && y < top)) {
                    self.cellingIndex = idx;
                    *stop = YES;
                }
            }
        }];
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [super scrollViewWillBeginDragging:scrollView];
    self.endPull = NO;
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [super scrollViewDidEndDragging:scrollView willDecelerate:decelerate];
    self.endPull = YES;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [super scrollViewDidEndDecelerating:scrollView];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [super scrollViewDidScroll:scrollView];
    
    if (self.endPull == YES) {
        if (self.inAnimate == NO) {
            if (self.cellingIndex < self.scrollList.count) {
                CGFloat top = [[self.scrollList[self.cellingIndex] objectForKey:kScrollListTopKey] floatValue];
                CGFloat scope1 = [[self.scrollList[self.cellingIndex] objectForKey:@"scope1"] floatValue];
                CGFloat scope2 = [[self.scrollList[self.cellingIndex] objectForKey:@"scope2"] floatValue];

                if (scrollView.contentOffset.y > top - scope1 & scrollView.contentOffset.y < top + scope2) {
                    scrollView.userInteractionEnabled = NO;
                    self.inAnimate = YES;
                    WeakSelf;
                    /*
                    [UIView animateWithDuration:0.5 customTimingFunction:CustomTimingFunctionEaseOut animation:^{
                        StrongSelf;
//                        scrollView.contentOffset = CGPointMake(scrollView.contentOffset.x, [[self.scrollList[self.cellingIndex] objectForKey:kScrollListTopKey] floatValue]);
                        [scrollView setContentOffset: CGPointMake(scrollView.contentOffset.x, [[self.scrollList[self.cellingIndex] objectForKey:kScrollListTopKey] floatValue]) animated:YES];
                        self.inAnimate = NO;
                        self.cellingIndex = self.scrollList.count + 1;
                        scrollView.userInteractionEnabled = YES;
                    }];
                    */
                    [scrollView setContentOffset:CGPointMake(scrollView.contentOffset.x, scrollView.contentOffset.y) animated:NO];
                    UIViewController *topController = [TTUIResponderHelper topViewControllerFor: self];
                    // 做动画的过程中先把横滑退出的手势禁掉，不然滑动时有可能识别成pan退出手势
                    TTNavigationController *naviController = (TTNavigationController *)topController.navigationController;
                    naviController.panRecognizer.enabled = NO;
                    
                    [self setContentOffset:CGPointMake(scrollView.contentOffset.x, [[self.scrollList[self.cellingIndex] objectForKey:kScrollListTopKey] floatValue]) withTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut] duration:0.5];
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        StrongSelf;
                        self.inAnimate = NO;
                        self.cellingIndex = self.scrollList.count + 1;
                        scrollView.userInteractionEnabled = YES;
                        naviController.panRecognizer.enabled = YES;
                    });
                }
            }
        }
    }
}

#pragma mark - Set ContentOffset with Custom Animation

- (void)setContentOffset:(CGPoint)contentOffset
      withTimingFunction:(CAMediaTimingFunction *)timingFunction {
    [self setContentOffset:contentOffset
        withTimingFunction:timingFunction
                  duration:kDefaultSetContentOffsetDuration];
}

- (void)setContentOffset:(CGPoint)contentOffset
      withTimingFunction:(CAMediaTimingFunction *)timingFunction
                duration:(CFTimeInterval)duration {
    self.duration = duration;
    self.timingFunction = timingFunction;
    
    self.deltaContentOffset = CGPointMinus(contentOffset, self.scrollView.contentOffset);
    
    if (!self.displayLink) {
        self.displayLink = [CADisplayLink
                            displayLinkWithTarget:self
                            selector:@selector(updateContentOffset:)];
        self.displayLink.frameInterval = 1;
        [self.displayLink addToRunLoop:[NSRunLoop currentRunLoop]
                               forMode:NSDefaultRunLoopMode];
    } else {
        self.displayLink.paused = NO;
    }
}

- (void)updateContentOffset:(CADisplayLink *)displayLink {
    if (self.beginTime == 0.0) {
        self.beginTime = self.displayLink.timestamp;
        self.beginContentOffset = self.scrollView.contentOffset;
    } else {
        CFTimeInterval deltaTime = displayLink.timestamp - self.beginTime;
        
        // Ratio of duration that went by
        CGFloat progress = (CGFloat)(deltaTime / self.duration);
        if (progress < 1.0) {
            // Ratio adjusted by timing function
            CGFloat adjustedProgress = (CGFloat)timingFunctionValue(self.timingFunction, progress);
            if (1 - adjustedProgress < 0.001) {
                [self stopAnimation];
            } else {
                [self updateProgress:adjustedProgress];
            }
        } else {
            [self stopAnimation];
        }
    }
}

- (void)updateProgress:(CGFloat)progress {
    CGPoint currentDeltaContentOffset = CGPointScalarMult(progress, self.deltaContentOffset);
    self.scrollView.contentOffset = CGPointAdd(self.beginContentOffset, currentDeltaContentOffset);
}

- (void)stopAnimation {
    self.displayLink.paused = YES;
    self.beginTime = 0.0;
    
    self.scrollView.contentOffset = CGPointAdd(self.beginContentOffset, self.deltaContentOffset);
    
    if (self.scrollView.delegate
        && [self.scrollView.delegate respondsToSelector:@selector(scrollViewDidEndScrollingAnimation:)]) {
        // inform delegate about end of animation
        [self.scrollView.delegate scrollViewDidEndScrollingAnimation:self.scrollView];
    }
}


//fix warnnings: no previous prototype for function
CGPoint CGPointScalarMult(CGFloat s, CGPoint p);
CGPoint CGPointAdd(CGPoint p, CGPoint q);
CGPoint CGPointMinus(CGPoint p, CGPoint q);
double cubicFunctionValue(double a, double b, double c, double d, double x);
double cubicDerivativeValue(double a, double b, double c, double __unused d, double x);
double cubicDerivativeValue(double a, double b, double c, double __unused d, double x);
double rootOfCubic(double a, double b, double c, double d, double startPoint);
double timingFunctionValue(CAMediaTimingFunction *function, double x);

CGPoint CGPointScalarMult(CGFloat s, CGPoint p) {
    return CGPointMake(s * p.x, s * p.y);
}

CGPoint CGPointAdd(CGPoint p, CGPoint q) {
    return CGPointMake(p.x + q.x, p.y + q.y);
}

CGPoint CGPointMinus(CGPoint p, CGPoint q) {
    return CGPointMake(p.x - q.x, p.y - q.y);
}

double cubicFunctionValue(double a, double b, double c, double d, double x) {
    return (a*x*x*x)+(b*x*x)+(c*x)+d;
}

double cubicDerivativeValue(double a, double b, double c, double __unused d, double x) {
    /// Derivation of the cubic (a*x*x*x)+(b*x*x)+(c*x)+d
    return (3*a*x*x)+(2*b*x)+c;
}

double rootOfCubic(double a, double b, double c, double d, double startPoint) {
    // We use 0 as start point as the root will be in the interval [0,1]
    double x = startPoint;
    double lastX = 1;
    
    // Approximate a root by using the Newton-Raphson method
    int y = 0;
    while (y <= kMaximumSteps && fabs(lastX - x) > kApproximationTolerance) {
        lastX = x;
        x = x - (cubicFunctionValue(a, b, c, d, x) / cubicDerivativeValue(a, b, c, d, x));
        y++;
    }
    
    return x;
}

double timingFunctionValue(CAMediaTimingFunction *function, double x) {
    float a[2];
    float b[2];
    float c[2];
    float d[2];
    
    [function getControlPointAtIndex:0 values:a];
    [function getControlPointAtIndex:1 values:b];
    [function getControlPointAtIndex:2 values:c];
    [function getControlPointAtIndex:3 values:d];
    
    // Look for t value that corresponds to provided x
    double t = rootOfCubic(-a[0]+3*b[0]-3*c[0]+d[0], 3*a[0]-6*b[0]+3*c[0], -3*a[0]+3*b[0], a[0]-x, x);
    
    // Return corresponding y value
    double y = cubicFunctionValue(-a[1]+3*b[1]-3*c[1]+d[1], 3*a[1]-6*b[1]+3*c[1], -3*a[1]+3*b[1], a[1], t);
    
    return y;
}


@end
