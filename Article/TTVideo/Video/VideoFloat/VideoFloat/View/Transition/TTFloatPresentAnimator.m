
#import "TTFloatPresentAnimator.h"
#import "TTSharedViewTransition.h"

#import "TTVideoFloatSingletonTransition.h"

#import <objc/runtime.h>

@interface TTTransitionInfo : NSObject
@property (nonatomic, weak) UIView *fromSuperView;
@property (nonatomic, assign) CGRect fromOriginRect;
@property (nonatomic, assign) CGRect fromOriginRectOnTransitionContainer;
@end

@implementation TTTransitionInfo

+ (instancetype)sharedTransitionInfo
{
    static TTTransitionInfo *transitionInfo;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        transitionInfo = [[TTTransitionInfo alloc] init];
    });
    return transitionInfo;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self reset];
    }
    return self;
}

- (void)reset
{
    self.fromSuperView = nil;
    self.fromOriginRect = CGRectZero;
    self.fromOriginRectOnTransitionContainer = CGRectZero;
}
@end

#define kExtensionInfo "extensionInfo"
@interface NSObject (Property)
@property (nonatomic, strong) NSObject *extensionInfo;
@end

@implementation NSObject(Property)
@dynamic extensionInfo;
- (void)setExtensionInfo:(NSObject *)info
{
    objc_setAssociatedObject(self, kExtensionInfo, info, OBJC_ASSOCIATION_RETAIN);
}

- (NSObject *)extensionInfo
{
    return objc_getAssociatedObject(self, kExtensionInfo);
}

@end

@interface TTFloatPresentAnimator ()
@property (nonatomic, weak) id<UIViewControllerContextTransitioning> transitionContext;
@end

@implementation TTFloatPresentAnimator

- (UIViewController<TTSharedViewTransitionTo> *)topViewControllerfromAnimatedViewController:(UIViewController *)viewController
{
    UIViewController *result = nil;
    if ([viewController isKindOfClass:[UINavigationController class]]) {
        result = [(UINavigationController *)viewController topViewController];
    }
    else if ([viewController isKindOfClass:[UITabBarController class]]){
        UIViewController *rootController = [(UITabBarController *)viewController selectedViewController];
        if ([rootController isKindOfClass:[UINavigationController class]]) {
            result = [(UINavigationController *)rootController topViewController];
        }
        else{
            result = rootController;
        }
    }
    else{
        result = viewController;
    }
    if ([result conformsToProtocol:@protocol(TTSharedViewTransitionTo)]) {
        return (UIViewController<TTSharedViewTransitionTo> *)result;
    }
    //首页是containerViewController实现的
    else if ([result.childViewControllers count]){
        while ([self childViewControllerOnViewController:result]) {
            result = [self childViewControllerOnViewController:result];
            if ([result conformsToProtocol:@protocol(TTSharedViewTransitionTo)]) {
                return (UIViewController<TTSharedViewTransitionTo> *)result;
            }
        }
    }
    return nil;
}

- (UIViewController *)childViewControllerOnViewController:(UIViewController *)result
{
    if ([result.childViewControllers count]){
        for (UIViewController *vc in result.childViewControllers) {
            return vc;
        }
    }
    return nil;
}

- (void)animationEnded:(BOOL) transitionCompleted
{
    
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
    TTVideoFloatSingletonTransition *transitionView = [TTVideoFloatSingletonTransition sharedInstance_tt];
    
    UIViewController *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    
    UIViewController *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIViewController<TTSharedViewTransitionTo> *tmpToVC = [self topViewControllerfromAnimatedViewController:[TTUIResponderHelper topViewControllerFor:toVC]];
    
    UIView *containerView = [transitionContext containerView];
    containerView.backgroundColor = [UIColor clearColor];
    NSTimeInterval dur = [self transitionDuration:transitionContext];
    UIView *fromAnimatedView = transitionView.fromAnimatedView;
    
    UIImageView *animatedView = [[UIImageView alloc] initWithImage:transitionView.fixedAnimatedImage];
    animatedView.backgroundColor = [UIColor blackColor];
    
    if (self.presenting) {
        
        TTTransitionInfo *transitionInfo = [[TTTransitionInfo alloc] init];
        
        transitionInfo.fromSuperView = fromAnimatedView.superview;
        transitionInfo.fromOriginRect = fromAnimatedView.frame;
        transitionInfo.fromOriginRectOnTransitionContainer = [fromAnimatedView.superview convertRect:fromAnimatedView.frame toView:containerView];

        if ([TTDeviceHelper OSVersionNumber] < 8.0) {
            toVC.view.frame = [TTUIResponderHelper mainWindow].bounds;
        } else {
            toVC.view.frame = [transitionContext finalFrameForViewController:toVC];
        }
        toVC.view.alpha = 0;
        [containerView addSubview:toVC.view];
        
        animatedView.frame = transitionInfo.fromOriginRectOnTransitionContainer;
        [containerView addSubview:animatedView];
        toVC.extensionInfo = transitionInfo;
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            CGRect toFrame = CGRectZero;
            if ([tmpToVC respondsToSelector:@selector(animationToFrame)]) {
                toFrame = [tmpToVC animationToFrame];
            }
            if (CGRectEqualToRect(toFrame, CGRectZero)) {
                [animatedView removeFromSuperview];
                [UIView animateWithDuration:dur animations:^{
                    toVC.view.alpha = 1;
                } completion:^(BOOL finished) {
                    [transitionContext completeTransition:!transitionContext.transitionWasCancelled];
                    if (!transitionContext.transitionWasCancelled) {
                        [fromVC viewWillDisappear:NO];
                        [fromVC viewDidDisappear:NO];
                    }
                }];
            }
            else
            {
                if ([tmpToVC respondsToSelector:@selector(animationToBegin:)]) {
                    [tmpToVC animationToBegin:animatedView];
                }
                [UIView animateWithDuration:dur animations:^{
                    toVC.view.alpha = 1;
                    animatedView.frame = toFrame;
                } completion:^(BOOL finished) {
                    UIView *toTargetView = nil;
                    if ([tmpToVC respondsToSelector:@selector(animationToView)]) {
                        [tmpToVC animationToView];
                    }
                    animatedView.frame = toTargetView.bounds;
                    [toTargetView addSubview:animatedView];
                    animatedView.hidden = YES;
                    if ([tmpToVC respondsToSelector:@selector(animationToFinished:)]) {
                        [tmpToVC animationToFinished:animatedView];
                    }
                    [transitionContext completeTransition:!transitionContext.transitionWasCancelled];
                    if (!transitionContext.transitionWasCancelled) {
                        [fromVC viewWillDisappear:NO];
                        [fromVC viewDidDisappear:NO];
                    }
                }];
            }

        });
    }
    else{
        
        TTTransitionInfo *transitionInfo = (TTTransitionInfo *)fromVC.extensionInfo;

        [containerView addSubview:fromVC.view];
        
        
        if (!self.interactionController) {
            LOGD(@"backbutton clicked");
            LOGD(@"!self.interactionController");
            
            UIViewController<TTSharedViewTransitionTo> *tmpToVC = [self topViewControllerfromAnimatedViewController:[TTUIResponderHelper topViewControllerFor:fromVC]];
            UIView *toTargetView = nil;
            if ([tmpToVC respondsToSelector:@selector(animationToView)]) {
                toTargetView = [tmpToVC animationToView];
            }
            UIImageView *animatedView = [[UIImageView alloc] initWithImage:transitionView.fixedAnimatedImage];
            animatedView.backgroundColor = [UIColor blackColor];
            animatedView.frame = [toTargetView.superview convertRect:toTargetView.frame toView:containerView];
            [containerView addSubview:animatedView];
            
            fromVC.view.alpha = 1.f;

            [UIView animateWithDuration:dur animations:^{
                fromVC.view.alpha = 0.0; // Fade out
                animatedView.frame = transitionInfo.fromOriginRectOnTransitionContainer;
            } completion:^(BOOL finished) {
                [transitionContext completeTransition:!transitionContext.transitionWasCancelled];
                [animatedView removeFromSuperview];
                if (transitionContext.transitionWasCancelled) {
                    LOGD(@"transitionWasCancelled");
                    if ([transitionView.fromView respondsToSelector:@selector(animationFromCancel)]) {
                        [transitionView.fromView animationFromCancel];
                    }
                    [UIView animateWithDuration:0.2f animations:^{
                        fromVC.view.alpha = 1.f;
                    } completion:^(BOOL f) {
                        
                    }];
                } else {
                    LOGD(@"transitionWas not Cancelled");
                    tmpToVC.navigationController.navigationBar.hidden = NO;
                    fromVC.extensionInfo = nil;
                    [transitionInfo reset];
                    if ([transitionView.fromView respondsToSelector:@selector(animationFromClose)]) {
                        [transitionView.fromView animationFromClose];
                    }
                    if (!transitionContext.transitionWasCancelled) {
                        [toVC viewWillAppear:NO];
                        [toVC viewDidAppear:NO];
                    }
                }
            }];
        }
        else
        {
            fromVC.view.alpha = 1.f;
            LOGD(@"self.interactionController");
            LOGD(@"fromVC %@",fromVC);//浮层
            [UIView animateWithDuration:dur animations:^{
                fromVC.view.alpha = 0.0; // Fade out
            } completion:^(BOOL finished) {
                
                [transitionContext completeTransition:!transitionContext.transitionWasCancelled];
                if (transitionContext.transitionWasCancelled) {
                    LOGD(@"transitionWasCancelled");
                    if ([transitionView.fromView respondsToSelector:@selector(animationFromCancel)]) {
                        [transitionView.fromView animationFromCancel];
                    }
                    [UIView animateWithDuration:0.2f animations:^{
                        fromVC.view.alpha = 1.f;
                    } completion:^(BOOL f) {
                    }];
                } else {
                    LOGD(@"transitionWas not Cancelled");
                    tmpToVC.navigationController.navigationBar.hidden = NO;
                    fromVC.extensionInfo = nil;
                    [transitionInfo reset];
                    if ([transitionView.fromView respondsToSelector:@selector(animationFromClose)]) {
                        [transitionView.fromView animationFromClose];
                    }
                    if (!transitionContext.transitionWasCancelled) {
                        [toVC viewWillAppear:NO];
                        [toVC viewDidAppear:NO];
                    }
                }
            }];
        }

    }
}

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext
{
    return 0.25;
}

@end
