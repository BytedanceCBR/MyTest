//
//  TTCustomAnimationDelegate.m
//  Article
//
//  Created by 王双华 on 17/3/6.
//
//

#import "TTCustomAnimationDelegate.h"
#import "ExploreSearchView.h"
#import "ExploreSearchViewController.h"
#import "TTExploreMainViewController.h"
#import "TTSeachBarView.h"
#import "UIView+CustomTimingFunction.h"
#import "UIViewController+TabBarSnapShot.h"
#import "AWEVideoDetailViewController.h"
#import "TTHTSTabViewController.h"
#import "ArticleTabBarStyleNewsListViewController.h"
#import "TTVideoTabViewController.h"
//#import "TTWeitoutiaoViewController.h"
#import "TSVTransitionAnimationManager.h"

static TTCustomAnimationManager *manager;

@interface TTCustomAnimationManager ()

@property(nonatomic, strong) NSMutableDictionary *animationInfoDict;

@end

@implementation TTCustomAnimationManager

+ (instancetype)sharedManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[TTCustomAnimationManager alloc] init];
    });
    return manager;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _animationInfoDict = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)registerFromVCClass:(Class)fromVCClass toVCClass:(Class)toVCClass animationClass:(Class)animationClass
{
    if (fromVCClass && toVCClass && animationClass) {
        NSString *fromVCAndToVCClassStr = [NSStringFromClass(fromVCClass) stringByAppendingFormat:@" %@", NSStringFromClass(toVCClass)];
        [self.animationInfoDict setValue:animationClass forKey:fromVCAndToVCClassStr];
    } else if (fromVCClass && !toVCClass && animationClass) {
        NSString *fromVCStr = NSStringFromClass(fromVCClass);
        [self.animationInfoDict setValue:animationClass forKey:fromVCStr];
    } else {
        NSAssert(NO, @"fromVCClass/toVCClass/animationClass should not be nil");
    }
}

- (id)customAnimationForOperation:(UINavigationControllerOperation)operation fromViewController:(UIViewController *)fromVC toViewController:(UIViewController *)toVC
{
    NSString *fromVCAndToVCClassStr = [NSStringFromClass([fromVC class]) stringByAppendingFormat:@" %@", NSStringFromClass([toVC class])];
    Class animationClass = [self.animationInfoDict objectForKey:fromVCAndToVCClassStr];
    if (animationClass) {
        return [[animationClass alloc] init];
    }
    NSString *fromVCStr = NSStringFromClass([fromVC class]);
    Class animationClassForFromVC = [self.animationInfoDict objectForKey:fromVCStr];
    if (animationClassForFromVC) {
        return [[animationClassForFromVC alloc] init];
    }
    return nil;
}

- (UIPercentDrivenInteractiveTransition *)percentDrivenTransitionForAnimationController:(id<UIViewControllerAnimatedTransitioning>)animationController
{
    if ([animationController isKindOfClass:[TTCustomAnimationPushAnimation class]]) {
        return [TSVTransitionAnimationManager sharedManager].enterProfilePercentDrivenTransition;
    } else {
        return nil;
    }
}

+ (NSTimeInterval)enterTSVDetailTransitionDuration
{
    return 0.3f;
}

+ (void)enterTSVDetailAnimateTransition:(id<UIViewControllerContextTransitioning>)transitionContext selectedCellFrame:(CGRect)selectedCellFrame
{
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    UIView *fromView;
    UIView *toView;
    
    if ([transitionContext respondsToSelector:@selector(viewForKey:)]) {
        fromView = [transitionContext viewForKey:UITransitionContextFromViewKey];
        toView = [transitionContext viewForKey:UITransitionContextToViewKey];
    } else {
        fromView = fromViewController.view;
        toView = toViewController.view;
    }
    
    UIView *containerView = [transitionContext containerView];
    
    UITabBar *tabBar = fromViewController.tabBarController.tabBar;
    BOOL needHiddenTabbar = tabBar.hidden;
    UIImageView *fakeTabView;
    if (!needHiddenTabbar) {
        // 添加 fake Tabbar
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(CGRectGetWidth(tabBar.bounds), CGRectGetHeight(tabBar.bounds)), NO, 0);
        [tabBar.layer renderInContext:UIGraphicsGetCurrentContext()];
        UIImage *fakeTabImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        fakeTabView = [[UIImageView alloc] initWithImage:fakeTabImage];
        fakeTabView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleWidth;
        fakeTabView.frame = CGRectMake(0, CGRectGetHeight(containerView.bounds) - CGRectGetHeight(fakeTabView.bounds), CGRectGetWidth(fakeTabView.bounds), CGRectGetHeight(fakeTabView.bounds));
        [containerView addSubview:fakeTabView];
        // 隐藏真的TabBar，动画后恢复
        tabBar.hidden = YES;
    }
    UIView *blackMaskView = [[UIView alloc] initWithFrame:containerView.bounds];
    blackMaskView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    blackMaskView.backgroundColor = [UIColor colorWithHexString:@"#000000"];
    blackMaskView.alpha = 0;
    [containerView addSubview:blackMaskView];
    [containerView addSubview:toView];
    
    // 将要展示的controller调整到指定大小和位置，加到视图中
    CGRect fromFrame = [fromViewController.view convertRect:selectedCellFrame toView:toViewController.navigationController.view];
    CGFloat scale = CGRectGetWidth(fromFrame) / CGRectGetWidth(toViewController.view.bounds);
    toViewController.view.transform = CGAffineTransformMakeScale(scale, scale);
    CGRect toFrame = toViewController.view.frame; // 记录transform之后的frame
    toViewController.view.frame = fromFrame; // 调整到fromframe大小
    
    NSTimeInterval duration = [self enterTSVDetailTransitionDuration];
    [UIView animateWithDuration:duration customTimingFunction:CustomTimingFunctionCubicOut animation:^{
        toViewController.view.frame = toFrame; // 恢复transform之后的frame
        toViewController.view.transform = CGAffineTransformIdentity; // 恢复TransformIdentity
        blackMaskView.alpha = 1;
    }completion:^(BOOL finished) {
        BOOL complete = ![transitionContext transitionWasCancelled];
        [transitionContext completeTransition:complete];
        [fakeTabView removeFromSuperview];
        [blackMaskView removeFromSuperview];
    }];
    
}

@end

@implementation TTCustomAnimationDelegate

- (void)setViewController:(UINavigationController *)viewController {
    _viewController = viewController;
    if (_viewController != nil) {
        _viewController.transitioningDelegate = self;
    }
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    switch (self.style) {
        case TTCustomAnimationStyleUGCPostEntrance:
            return [[TTCustomAnimationPresentAnimation alloc] init];
        default:
            return [[TTCustomAnimationPresentAnimation alloc] init];
            break;
    }
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    switch (self.style) {
        case TTCustomAnimationStyleUGCPostEntrance:
            return [[TTCustomAnimationDismissAnimation alloc] init];
        default:
            return [[TTCustomAnimationDismissAnimation alloc] init];
            break;
    }
}

@end

@implementation TTCustomAnimationPresentAnimation

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext
{
    return 0.45;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    UIView *fromView;
    UIView *toView;
    
    if ([transitionContext respondsToSelector:@selector(viewForKey:)]) {
        fromView = [transitionContext viewForKey:UITransitionContextFromViewKey];
        toView = [transitionContext viewForKey:UITransitionContextToViewKey];
    } else {
        fromView = fromViewController.view;
        toView = toViewController.view;
    }
    
    UIView *containerView = [transitionContext containerView];
    [containerView addSubview:toView];
    
    toView.transform = CGAffineTransformMakeTranslation(0, CGRectGetHeight(fromView.frame));
    
    [UIView animateWithDuration:[self transitionDuration:transitionContext] customTimingFunction:CustomTimingFunctionExpoOut animation:^{
        toView.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
        if ([transitionContext transitionWasCancelled]) {
            [toView removeFromSuperview];
            [transitionContext completeTransition:NO];
        } else {
            [transitionContext completeTransition:YES];
            [fromViewController.view removeFromSuperview];
        }
    }];
}

@end

@implementation TTCustomAnimationDismissAnimation

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext
{
    return 0.2;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    UIView *fromView;
    UIView *toView;
    
    if ([transitionContext respondsToSelector:@selector(viewForKey:)]) {
        fromView = [transitionContext viewForKey:UITransitionContextFromViewKey];
        toView = [transitionContext viewForKey:UITransitionContextToViewKey];
    } else {
        fromView = fromViewController.view;
        toView = toViewController.view;
    }
    
    UIView *containerView = [transitionContext containerView];
    [containerView insertSubview:toView belowSubview:fromView];
    
    fromView.transform = CGAffineTransformIdentity;
    [UIView animateWithDuration:[self transitionDuration:transitionContext] customTimingFunction:CustomTimingFunctionQuadIn animation:^{
        fromView.transform = CGAffineTransformMakeTranslation(0, CGRectGetHeight(fromView.frame));
    } completion:^(BOOL finished) {
        fromView.transform = CGAffineTransformIdentity;
        if ([transitionContext transitionWasCancelled]) {
            [toView removeFromSuperview];
            [transitionContext completeTransition:NO];
        } else {
            [transitionContext completeTransition:YES];
        }
    }];
}

@end



@implementation TSVShortVideoEnterDetailAnimation

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext
{
    return [[TTCustomAnimationManager class] enterTSVDetailTransitionDuration];
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
    [[TTCustomAnimationManager class] enterTSVDetailAnimateTransition:transitionContext selectedCellFrame:[TSVTransitionAnimationManager sharedManager].listSelectedCellFrame];
}

@end

@implementation TSVProfileVCEnterDetailAnimation

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext
{
    return [[TTCustomAnimationManager class] enterTSVDetailTransitionDuration];
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
    [[TTCustomAnimationManager class] enterTSVDetailAnimateTransition:transitionContext selectedCellFrame:[TSVTransitionAnimationManager sharedManager].profileListSelectedCellFrame];
}

@end

@implementation TTCustomAnimationPushAnimation

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext
{
    return 0.28;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    UIView *containerView = [transitionContext containerView];
    
    UITabBar *tabBar = fromViewController.tabBarController.tabBar;
    BOOL needHiddenTabbar = tabBar.hidden;
    UIImageView *fakeTabView;
    if (!needHiddenTabbar) {
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(CGRectGetWidth(tabBar.bounds), CGRectGetHeight(tabBar.bounds)), NO, 0);
        [tabBar.layer renderInContext:UIGraphicsGetCurrentContext()];
        UIImage *fakeTabImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        fakeTabView = [[UIImageView alloc] initWithImage:fakeTabImage];
        fakeTabView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleWidth;
        fakeTabView.frame = CGRectMake(0, CGRectGetHeight(containerView.bounds) - CGRectGetHeight(fakeTabView.bounds), CGRectGetWidth(fakeTabView.bounds), CGRectGetHeight(fakeTabView.bounds));
        [containerView addSubview:fakeTabView];
        // 隐藏真的TabBar，动画后恢复
        tabBar.hidden = YES;
    }
    
    UIView *blackMaskView = [[UIView alloc] initWithFrame:containerView.bounds];
    blackMaskView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    blackMaskView.backgroundColor = [UIColor colorWithHexString:@"#000000"];
    blackMaskView.alpha = 0;
    [containerView addSubview:blackMaskView];
    [containerView addSubview:toViewController.view];
    
    CGRect fromVCFrame = CGRectMake(0, 0, CGRectGetWidth(fromViewController.view.frame), CGRectGetHeight(fromViewController.view.frame));
    fromViewController.view.frame = fromVCFrame;
    fromViewController.view.userInteractionEnabled = NO;
    toViewController.view.left = CGRectGetWidth(toViewController.view.frame);
    toViewController.view.top = fromViewController.view.top;
    
    NSTimeInterval duration = [self transitionDuration:transitionContext];
    [UIView animateWithDuration:duration customTimingFunction:CustomTimingFunctionSineOut animation:^{
        fromViewController.view.transform = CGAffineTransformMakeScale(0.98, 0.98);
        toViewController.view.left = 0;
        blackMaskView.alpha = 1.0;
    } completion:^(BOOL finished) {
        [blackMaskView removeFromSuperview];
        fromViewController.view.userInteractionEnabled = YES;
        fromViewController.view.transform = CGAffineTransformMakeScale(1, 1);
        toViewController.view.left = 0;
        [fakeTabView removeFromSuperview];
        if ([transitionContext transitionWasCancelled]) {
            [toViewController.view removeFromSuperview];
            [transitionContext completeTransition:NO];
        } else {
            [transitionContext completeTransition:YES];
        }
    }];
}

@end
