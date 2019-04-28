

#import "TTSharedViewTransition.h"
#import <objc/runtime.h>
#import "TTFloatPresentAnimator.h"



@interface UIViewController (Dismiss)<SharedViewTransitionWillDismissViewControllerProtocol>

@end

@interface TTSharedViewTransition ()

@property (nonatomic, strong) UIPercentDrivenInteractiveTransition *interactionController;

@property(nonatomic) CGPoint initialTouchPosition;
@property(nonatomic) BOOL animationEnd;
@property(nonatomic ,assign) CGPoint velocity;
@property(nonatomic ,assign) CGPoint currentTouchPoint;
@property(nonatomic ,assign) CGPoint firstVelocity;
@property (nonatomic, assign) BOOL isVerticalGesture;
@end

@implementation TTSharedViewTransition

#pragma mark - Setup & Initializers

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

+ (instancetype)sharedInstance
{
    static TTSharedViewTransition *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[TTSharedViewTransition alloc] init];
        instance.animationEnd = YES;
//        [[NSNotificationCenter defaultCenter] addObserverForName:UIDeviceOrientationDidChangeNotification object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
//            if (UIDeviceOrientationIsLandscape([UIDevice currentDevice].orientation)) {
//                instance.disableAnimation = YES;
//            }
//            else
//            {
//                instance.disableAnimation = NO;
//            }
//        }];
        
        [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidEnterBackgroundNotification object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
            if (!instance.animationEnd) {
                [instance endGestureAnimationDidEnterBackground:YES];
            }
        }];
    });
    return instance;
}


#pragma mark UIViewControllerTransitioningDelegate

- (nullable id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source
{
    LOGD(@"animationControllerForPresentedController");
    TTFloatPresentAnimator *animator = [[TTFloatPresentAnimator alloc] init];
    animator.presenting = YES;
    animator.interactionController = self.interactionController;
    return animator;
}

- (nullable id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed
{
    LOGD(@"animationControllerForDismissedController");
//    if (self.disableAnimation) {
//        self.disableAnimation = NO;
//        LOGD(@"return nil");
//        return nil;
//    }
//    LOGD(@"return animator");
    TTFloatPresentAnimator *animator = [[TTFloatPresentAnimator alloc] init];
    animator.presenting = NO;
    animator.interactionController = self.interactionController;
    return animator;
}

- (nullable id <UIViewControllerInteractiveTransitioning>)interactionControllerForPresentation:(id <UIViewControllerAnimatedTransitioning>)animator
{
    return self.interactionController;
}

- (nullable id <UIViewControllerInteractiveTransitioning>)interactionControllerForDismissal:(id <UIViewControllerAnimatedTransitioning>)animator
{
    return self.interactionController;
}

#pragma mark PanGesture

+ (TTGestureDirection)directionWithAmount:(CGPoint)amount
{
    TTGestureDirection direction = TTGestureDirection_Unknown;
    BOOL isVerticalGesture = fabs(amount.y) > fabs(amount.x);
    if (isVerticalGesture) {
        if (amount.y > 0) {
            direction = TTGestureDirection_Down;
        } else {
            direction = TTGestureDirection_Up;
        }
    }
    else {
        if (amount.x > 0) {
            direction = TTGestureDirection_Right;
        } else {
            direction = TTGestureDirection_Left;
        }
    }
    return direction;
}

+ (BOOL)canFinishInteractiveTransitionWithPanAmount:(CGPoint)amount velocity:(CGPoint)velocity firstVelocity:(CGPoint)firstVelocity isVerticalGestureOnBegin:(BOOL)isVerticalGestureOnBegin
{
    BOOL isTheSameDirection = NO;
    if ([TTSharedViewTransition sharedInstance].isVerticalGestureOnBegin)
    {
        isTheSameDirection = firstVelocity.y * velocity.y > 0;
    }
    else
    {
        isTheSameDirection = firstVelocity.x * velocity.x > 0;
    }
    [TTSharedViewTransition sharedInstance].isTheSameDirection = isTheSameDirection;
    
    LOGD(@"direction %ld",[TTSharedViewTransition sharedInstance].gestureDirection);
    if (velocity.y == 0 && velocity.x == 0) {
        LOGD(@"(velocity.y == 0 && velocity.x == 0)");
        return NO;
    }
    if (![TTSharedViewTransition sharedInstance].isTheSameDirection) {
        return NO;
    }
    

    switch ([TTSharedViewTransition sharedInstance].gestureDirection) {
        case TTGestureDirection_Left:
            return NO;
            break;
        case TTGestureDirection_Right:
            return amount.x >= kMaxDistance || velocity.x > kMaxSpeed;
            break;
        case TTGestureDirection_Down:
            return amount.y >= kMaxDistance || velocity.y > kMaxSpeed;
            break;
        case TTGestureDirection_Up:
            return amount.y <= -kMaxDistance || velocity.y < -kMaxSpeed;
            break;
        default:
            break;
    }
    return NO;
}

- (void)handlePanGestureRecognizer:(UIGestureRecognizer *)recognizer
{
    UIPanGestureRecognizer *panGestuer = (UIPanGestureRecognizer *)recognizer;
    UIView* view = [panGestuer view];
    UIViewController *viewController = [TTUIResponderHelper topViewControllerFor:view];
    self.currentTouchPoint = [recognizer locationInView:view];
    self.velocity = [panGestuer velocityInView:view];
    
    if (panGestuer.state == UIGestureRecognizerStateBegan) {
        self.initialTouchPosition = self.currentTouchPoint;
        self.animationEnd = NO;
        _firstVelocity = CGPointZero;
        if ([panGestuer velocityInView:view].y != 0 || [panGestuer velocityInView:view].x != 0) {
            if (self.disableAnimation) {
                if ([viewController respondsToSelector:@selector(willDismiss)]) {
                    [viewController willDismiss];
                }
                [viewController dismissViewControllerAnimated:YES completion:nil];
                return;
            }
            self.interactionController = [[UIPercentDrivenInteractiveTransition alloc] init];
            [viewController dismissViewControllerAnimated:YES completion:nil];
        }
    } else if (panGestuer.state == UIGestureRecognizerStateChanged) {
        if (CGPointEqualToPoint(_firstVelocity, CGPointZero)) {
            _firstVelocity = self.velocity;
            self.isVerticalGesture = fabs(self.velocity.y) > fabs(self.velocity.x);
        }
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
        CGFloat d = 0;
        if (self.isVerticalGestureOnBegin) {
            d = MIN(fabs((self.currentTouchPoint.y - self.initialTouchPosition.y) / [UIScreen mainScreen].bounds.size.height * 2.0/3.0), 1);
        }
        else
        {
            d = MIN(fabs((self.currentTouchPoint.x - self.initialTouchPosition.x) / [UIScreen mainScreen].bounds.size.width * 2.0/3.0), 1);
        }
        
        [self.interactionController updateInteractiveTransition:d];
    } else if (panGestuer.state == UIGestureRecognizerStateEnded || panGestuer.state == UIGestureRecognizerStateCancelled) {
        [self endGestureAnimationDidEnterBackground:NO];
    }
}

- (void)endGestureAnimationDidEnterBackground:(BOOL)enterBackground
{
    [[UIApplication sharedApplication] setStatusBarStyle:[UIApplication sharedApplication].statusBarStyle animated:YES];
    
    if (enterBackground) {
        LOGD(@"enterBackground finishInteractiveTransition");
        [self.interactionController finishInteractiveTransition];
    }
    else
    {
        LOGD(@"self.interactionController %@",self.interactionController);
        if (self.pop)
        {
            LOGD(@"finishInteractiveTransition");
            [self.interactionController finishInteractiveTransition];
        }
        else
        {
            LOGD(@"cancelInteractiveTransition");
            [self.interactionController cancelInteractiveTransition];
        }
    }
    self.interactionController = nil;
    self.animationEnd = YES;
}
@end


