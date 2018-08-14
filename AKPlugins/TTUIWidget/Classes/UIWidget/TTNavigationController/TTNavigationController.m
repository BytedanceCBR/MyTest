//
//  TTNavigationController.m
//  TestUniversaliOS6
//
//  Created by Nick Yu on 3/13/15.
//  Copyright (c) 2015 Nick Yu. All rights reserved.
//

#import "TTNavigationController.h"
#import "UINavigationController+NavigationBarConfig.h"
#import "UIViewController+NavigationBarStyle.h"
#import "SSThemed.h"
#import "SSViewControllerBase.h"
#import "UIViewAdditions.h"
#import "NSObject+FBKVOController.h"
#import "TTDeviceHelper.h"
#import "TTThemeManager.h"
#import "UIView+CustomTimingFunction.h"
#import "UIImageAdditions.h"
#import <objc/runtime.h>

//#ifndef TTModule
//#import <Crashlytics/Crashlytics.h>
//#endif

#pragma mark 分割线

static const NSUInteger kTabBarSnapShotTag = 2001;

@interface UINavigationController(TTNavigationController)
- (void)didShowViewController:(UIViewController *)viewController animated:(BOOL)animated;
@end

@interface TTNavigationController () <UIGestureRecognizerDelegate>

@property (nonatomic, assign) BOOL fullScreenVideoIsPlaying;
@property (nonatomic, assign) BOOL animationLock;
@property (nonatomic, strong) UIView * insertView;
@property (nonatomic, strong) UIImageView * shadowImage;
@property (nonatomic, strong) UIView *maskView;
@property (nonatomic, assign) BOOL viewDidLoadDone;
@property (nonatomic, strong) UIColor *originalColor;
@property (nonatomic, strong) UIImageView *snapShot;
@end

static inline CGFloat navigationBarTop() {
    if ([TTDeviceHelper isIPhoneXDevice]) {
        return 44.f;
    }
    return 20.f;
}

@implementation TTNavigationController

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (id)initWithRootViewController:(UIViewController *)rootViewController
{
    self = [super initWithRootViewController:rootViewController];
    if (self)
    {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.viewDidLoadDone = YES;
    //监听主题变化
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reloadTheme)
                                                 name:TTThemeManagerThemeModeChangedNotification
                                               object:nil];
    
    self.shadowImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed: @"touying.png"]];
    
    self.maskView = [[UIView alloc] initWithFrame:self.view.bounds];
    self.maskView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
    self.interactivePopGestureRecognizer.enabled = YES;
    self.interactivePopGestureRecognizer.delegate = self;

//    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
//
//        self.swipeRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipe:)];
//        self.swipeRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
//        self.swipeRecognizer.delegate = self;
//        [self.view addGestureRecognizer:self.swipeRecognizer];
//    }
//    else {
//        // 滑动手势
//        self.panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
//        self.panRecognizer.delegate = self;
//        [self.view addGestureRecognizer:self.panRecognizer];
//
//        // Disable the onboard gesture recognizer.
//        self.interactivePopGestureRecognizer.enabled = NO;
//    }
}

- (void)viewWillAppear:(BOOL)animated {
    [self tt_performSelector:@selector(addCustomNavigationBarIfNeeded) onlyOnceInSelector:_cmd];
    [self setNavigationBarHidden:self.topViewController.ttHideNavigationBar animated:NO];
    [super viewWillAppear:animated];
}

- (BOOL)gestureView:(UIView *)view isClass:(Class)aclass
{
    if ([view isKindOfClass:aclass]) {
        return YES;
    }
    if ([view.superview isKindOfClass:aclass]) {
        return YES;
    }
    if ([view.superview.superview isKindOfClass:aclass]) {
        return YES;
    }
    return NO;
}

#pragma mark ============= TODOP delete =============
//- (BOOL)gestureRecognizer:(UIGestureRecognizer *)myPopGestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
//{
//    //    otherGestureRecognizer.delaysTouchesBegan = YES;
//    // 修复单元格无法滑出删除功能的问题
//    if ([otherGestureRecognizer isKindOfClass:[UISwipeGestureRecognizer class]]) {
//        UISwipeGestureRecognizer *recognizer = (UISwipeGestureRecognizer *)otherGestureRecognizer;
//        if (recognizer.direction & UISwipeGestureRecognizerDirectionRight) {
//            recognizer.direction = UISwipeGestureRecognizerDirectionLeft;
//        }
//        return YES;
//    }
//
//    if ([otherGestureRecognizer.view isKindOfClass:[UICollectionView class]]) {
//        return NO;
//    }
//
//    if ([self gestureView:otherGestureRecognizer.view isClass:NSClassFromString(@"UITableViewWrapperView")]) {
//        return YES;
//    };
//
//    if ([self gestureView:otherGestureRecognizer.view isClass:[UITableViewCell class]]) {
//        return YES;
//    };
//
//    if ([self gestureView:otherGestureRecognizer.view isClass:NSClassFromString(@"UITableViewCellContentView")]) {
//        return YES;
//    };
//
//    // TODO: 解决React Native页面中，存在左右滑动切换tab的页面结构，滑动到最左侧时，无法右滑返回的问题
//    if ([self gestureView:otherGestureRecognizer.view isClass:NSClassFromString(@"RCTCustomScrollView")] && [otherGestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
//        UIPanGestureRecognizer *panGestureRecognizer = (UIPanGestureRecognizer *)otherGestureRecognizer;
//        UIScrollView *v = (UIScrollView *)otherGestureRecognizer.view;
//        CGPoint velocity = [panGestureRecognizer velocityInView:v];
//        BOOL xDirection = 0.5 * abs(velocity.x) > abs(velocity.y);
//        if (v.contentOffset.x == 0 && xDirection && velocity.x > 0) {
//            return YES;
//        }
//    }
//
//    // 处理iOS11上私信消息中心的会话左滑删除手势失效的问题
//    if ([otherGestureRecognizer.view.viewController isKindOfClass:NSClassFromString(@"TTIMChatCenterViewController")] &&
//        [otherGestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]] &&
//        [otherGestureRecognizer.view isKindOfClass:[UITableView class]]) {
//        CGPoint velocity = [(UIPanGestureRecognizer *)otherGestureRecognizer velocityInView:otherGestureRecognizer.view];
//        if (velocity.x < 0) return YES;
//    }
//
//    return NO;
//}


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (self.topViewController.ttNavBarStyle) {
        [self setTtNavBarStyle:self.topViewController.ttNavBarStyle];
    }
    
    if (!self.topViewController.ttStatusBarStyle) {
        
        [UIApplication sharedApplication].statusBarStyle = [[TTThemeManager sharedInstance_tt] statusBarStyle];
    }
    else {
        
        if ([UIApplication sharedApplication].statusBarStyle != self.topViewController.ttStatusBarStyle) {
            
            [UIApplication sharedApplication].statusBarStyle = self.topViewController.ttStatusBarStyle;
            
        }
    }
}

- (BOOL)shouldAutorotate
{
    return [self.topViewController shouldAutorotate];
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return [self.topViewController supportedInterfaceOrientations];
}

- (void)reloadTheme
{
    [self tt_reloadTheme];
}

#pragma mark ---- 这下面都是为了iOS6啊 ~ 截屏神马的

- (BOOL) orientationMaskSupportsOrientationMask: (UIInterfaceOrientationMask) mask orientation:(UIInterfaceOrientation) orientation {
    
    BOOL result = (mask & (1 << orientation)) != 0;
    return result;
}

- (void)pushViewControllerByTransitioningAnimation:(UIViewController *)viewController animated:(BOOL)animated
{
    if (!viewController) {
        return;
    }
    if (self.shouldIgnorePushingViewControllers) {
        return;
    }
    
    if (([viewController supportedInterfaceOrientations] != UIInterfaceOrientationMaskAll ||[viewController supportedInterfaceOrientations] != UIInterfaceOrientationMaskAllButUpsideDown )
        && ![self orientationMaskSupportsOrientationMask:[viewController supportedInterfaceOrientations] orientation:[[UIApplication sharedApplication] statusBarOrientation]]) {
        
        if ([viewController supportedInterfaceOrientations]  == UIInterfaceOrientationMaskLandscape || [viewController supportedInterfaceOrientations]  == UIInterfaceOrientationMaskLandscapeLeft || [viewController supportedInterfaceOrientations]  == UIInterfaceOrientationMaskLandscapeRight) {
            [[UIDevice currentDevice] setValue:@(UIDeviceOrientationLandscapeLeft) forKey:@"orientation"];
        }
        else
            [[UIDevice currentDevice] setValue:@(UIDeviceOrientationPortrait) forKey:@"orientation"];
    }
    
    @try {
        [super pushViewController:viewController animated:animated];
        //这里需要提前触发VC的viewDidLoad方法，通过SSViewControllerBase设置默认的ttHideNavigationBar=NO，进而就不会初始化ttNavigationBar保持隐藏
        [viewController view];
        [self addCustomNavigationBarForViewController:viewController];
    }
    @catch (NSException * ex) {
        
    }
    
    [self ignorePushViewControllersIfNeeded:animated];
}

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if (!viewController) {
        return;
    }
    if (self.shouldIgnorePushingViewControllers) {
        return;
    }
    
    if (([viewController supportedInterfaceOrientations] != UIInterfaceOrientationMaskAll ||[viewController supportedInterfaceOrientations] != UIInterfaceOrientationMaskAllButUpsideDown )
        && ![self orientationMaskSupportsOrientationMask:[viewController supportedInterfaceOrientations] orientation:[[UIApplication sharedApplication] statusBarOrientation]]) {
        
        if ([viewController supportedInterfaceOrientations]  == UIInterfaceOrientationMaskLandscape || [viewController supportedInterfaceOrientations]  == UIInterfaceOrientationMaskLandscapeLeft || [viewController supportedInterfaceOrientations]  == UIInterfaceOrientationMaskLandscapeRight) {
            [[UIDevice currentDevice] setValue:@(UIDeviceOrientationLandscapeLeft) forKey:@"orientation"];
        }
        else
            [[UIDevice currentDevice] setValue:@(UIDeviceOrientationPortrait) forKey:@"orientation"];
    }
    
    @try {
        if (self.viewDidLoadDone) {//push rootvc 不需要动画
            UIViewController* fromViewController = [self.viewControllers lastObject];
            if (!fromViewController) {
                return;
            }
            
            [UIView setAnimationsEnabled:YES];
            
            [super pushViewController:viewController animated:NO];
            //这里需要提前触发VC的viewDidLoad方法，通过SSViewControllerBase设置默认的ttHideNavigationBar=NO，进而就不会初始化ttNavigationBar保持隐藏
            [viewController view];
            
            [self addCustomNavigationBarForViewController:viewController];
            
            if (animated) {
                [self.view addSubview:fromViewController.view];
                [self.view sendSubviewToBack:fromViewController.view];
                
                if (![TTDeviceHelper isPadDevice] && [self.viewControllers indexOfObject:fromViewController] == 0 && [self.tabBarController.viewControllers containsObject:self]) {
                    [self addTabBarSnapshotForSuperView:fromViewController.view];
                }
                [fromViewController.view addSubview:_maskView];
                _maskView.alpha = 0.0;
                
                CGRect fromVCFrame = CGRectMake(0, 0, CGRectGetWidth(fromViewController.view.frame), CGRectGetHeight(fromViewController.view.frame));
                fromViewController.view.frame = fromVCFrame;
                fromViewController.view.userInteractionEnabled = NO;
                viewController.view.left = CGRectGetWidth(viewController.view.frame);
                viewController.view.top = fromViewController.view.top;
                
                self.originalColor = self.view.backgroundColor;
                self.view.backgroundColor = [UIColor blackColor];
                [UIView animateWithDuration:0.28 customTimingFunction:CustomTimingFunctionSineOut animation:^{
                    if (!fromViewController.ttNeedIgnoreZoomAnimation) {
                        fromViewController.view.transform = CGAffineTransformMakeScale(0.98, 0.98);
                    }
                    viewController.view.transform = CGAffineTransformMakeTranslation(-CGRectGetWidth(viewController.view.frame), 0);
                    _maskView.alpha = 1.0;
                } completion:^(BOOL finished) {
                    self.view.backgroundColor = self.originalColor;
                    self.originalColor = nil;
                    if(self.topViewController == viewController) {
                        [fromViewController.view removeFromSuperview];
                        fromViewController.view.transform = CGAffineTransformIdentity;
                    }
                    [_maskView removeFromSuperview];
                    fromViewController.view.userInteractionEnabled = YES;
                    viewController.view.transform = CGAffineTransformIdentity;
                    [self removeTabBarSnapshotForSuperView:fromViewController.view];
                    if ([viewController respondsToSelector:@selector(pushAnimationCompletion)]){
                        [viewController pushAnimationCompletion];
                    }
                }];
            }else{
                if ([viewController respondsToSelector:@selector(pushAnimationCompletion)]){
                    [viewController pushAnimationCompletion];
                }
            }
        }
        else {
            [super pushViewController:viewController animated:animated];
            if ([viewController respondsToSelector:@selector(pushAnimationCompletion)]){
                [viewController pushAnimationCompletion];
            }
            
        }
    } @catch (NSException * ex) {
        
    }
    
    [self ignorePushViewControllersIfNeeded:animated];
}

- (void)pushViewController:(UIViewController *)viewController
              animationTag:(NSInteger)animationTag
                 direction:(TT_PUSH_STYLE)direction
                  animated:(BOOL)animated
{
    if (!viewController) {
        return;
    }
    if (self.shouldIgnorePushingViewControllers) {
        return;
    }
    
    if (([viewController supportedInterfaceOrientations] != UIInterfaceOrientationMaskAll ||[viewController supportedInterfaceOrientations] != UIInterfaceOrientationMaskAllButUpsideDown )
        && ![self orientationMaskSupportsOrientationMask:[viewController supportedInterfaceOrientations] orientation:[[UIApplication sharedApplication] statusBarOrientation]]) {
        
        if ([viewController supportedInterfaceOrientations]  == UIInterfaceOrientationMaskLandscape || [viewController supportedInterfaceOrientations]  == UIInterfaceOrientationMaskLandscapeLeft || [viewController supportedInterfaceOrientations]  == UIInterfaceOrientationMaskLandscapeRight) {
            [[UIDevice currentDevice] setValue:@(UIDeviceOrientationLandscapeLeft) forKey:@"orientation"];
        }
        else
            [[UIDevice currentDevice] setValue:@(UIDeviceOrientationPortrait) forKey:@"orientation"];
    }
    
    @try {
        UIViewController* fromViewController = [self.viewControllers lastObject];
        if (!fromViewController) {
            return;
        }
        
        [UIView setAnimationsEnabled:YES];
        [super pushViewController:viewController animated:NO];
        //这里需要提前触发VC的viewDidLoad方法，通过SSViewControllerBase设置默认的ttHideNavigationBar=NO，进而就不会初始化ttNavigationBar保持隐藏
        [viewController view];
        
        [self addCustomNavigationBarForViewController:viewController];
        
        CGFloat duaration = 0.5;
        UIView *toView = [viewController.view viewWithTag:animationTag];
        UIView *fromView = [fromViewController.view viewWithTag:animationTag];
        
        if (animated) {
            switch (direction) {
                case TT_PUSH_FADE:{
                    toView = viewController.view;
                    fromView = fromViewController.view;
                    [toView addSubview:fromView];
                    fromView.alpha = 1.0f;
                    duaration = 0.3;
                }
                    break;
                case TT_PUSH_DIRECTION_UP:{
                    [toView.superview insertSubview:fromView belowSubview:toView];
                    toView.top += toView.height;
                }
                    break;
                case TT_PUSH_DIRECTION_DOWN:{
                    [toView.superview insertSubview:fromView belowSubview:toView];
                    toView.top -= toView.height;
                }
                    break;
            }
            viewController.view.userInteractionEnabled = NO;
            fromViewController.view.userInteractionEnabled = NO;
            [UIView animateWithDuration:duaration delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                switch (direction) {
                    case TT_PUSH_FADE:{
                        fromView.alpha = 0.0f;
                        toView.alpha = 1.0f;
                    }
                        break;
                    case TT_PUSH_DIRECTION_UP:{
                        fromView.transform = CGAffineTransformMakeTranslation(0.0f, -CGRectGetHeight(fromView.frame));
                        toView.transform = CGAffineTransformMakeTranslation(0.0f, -CGRectGetHeight(toView.frame));
                    }
                        break;
                    case TT_PUSH_DIRECTION_DOWN:{
                        fromView.transform = CGAffineTransformMakeTranslation(0.0f, CGRectGetHeight(fromView.frame));
                        toView.transform = CGAffineTransformMakeTranslation(0.0f, CGRectGetHeight(toView.frame));
                    }
                        break;
                }
            } completion:^(BOOL finished) {
                if(self.topViewController == viewController) {
                    [fromView removeFromSuperview];
                    fromView.transform = CGAffineTransformIdentity;
                }
                switch (direction) {
                    case TT_PUSH_FADE:{
                        fromView.alpha = 1.0f;
                        toView.alpha = 1.0f;
                    }
                        break;
                    case TT_PUSH_DIRECTION_UP:{
                        toView.top -= toView.height;
                    }
                        break;
                    case TT_PUSH_DIRECTION_DOWN:{
                        toView.top += toView.height;
                    }
                        break;
                }
                toView.transform = CGAffineTransformIdentity;
                fromViewController.view.userInteractionEnabled = YES;
                viewController.view.userInteractionEnabled = YES;
            }];
        }
        
    } @catch (NSException * ex) {
        
    }
    
    [self ignorePushViewControllersIfNeeded:YES];
}

- (void)setViewControllers:(NSArray<UIViewController *> *)viewControllers animated:(BOOL)animated {
    [super setViewControllers:viewControllers animated:animated];
    
    [self.KVOController unobserveAll];
    [self setCustomNavigationBarForViewControllers:viewControllers];
}

- (void)setViewControllers:(NSArray<UIViewController *> *)viewControllers {
    [super setViewControllers:viewControllers];
    
    [self.KVOController unobserveAll];
    [self setCustomNavigationBarForViewControllers:viewControllers];
}

- (void)setCustomNavigationBarForViewControllers:(NSArray<UIViewController *> *)viewControllers{
    for (UIViewController *vc in viewControllers) {
        [self addCustomNavigationBarForViewController:vc];
    }
}

- (void)addKVO {
    WeakSelf;
    __block NSArray <CALayer *> *layers = [self.topViewController.view.layer.sublayers copy];
    [self.KVOController observe:self.topViewController.view keyPath:@"layer.sublayers" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld block:^(id  _Nullable observer, id  _Nonnull object, NSDictionary<NSString *,id> * _Nonnull change) {
        StrongSelf;
        NSArray<CALayer *> *newLayers = change[NSKeyValueChangeNewKey];
        
        [self.topViewController.view bringSubviewToFront:self.topViewController.ttNavigationBar];
        
        if (newLayers.count > layers.count) {
            
            __block CALayer *lookupLayer = nil;
            
            [newLayers enumerateObjectsUsingBlock:^(CALayer * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if (![layers containsObject:obj]) {
                    lookupLayer = obj;
                    *stop = YES;
                }
            }];
            
            UIView *newAddedView;
            if ([lookupLayer.delegate isKindOfClass:[UIView class]]) {
                newAddedView = (UIView *)lookupLayer.delegate;
            }
            
            if (!CGRectIntersectsRect(self.topViewController.ttNavigationBar.frame, newAddedView.frame)) {
                return;
            }
            
            if ([newAddedView isKindOfClass:[UIScrollView class]] && CGRectGetHeight(self.topViewController.view.bounds) == CGRectGetHeight(newAddedView.bounds)) {
                UIEdgeInsets edgeInsets = ((UIScrollView*)newAddedView).contentInset;
                CGFloat topInset = self.view.tt_safeAreaInsets.top;
                if (!self.topViewController.ttHideNavigationBar){
                    topInset += 44;
                }
                [(UIScrollView*)newAddedView setContentInset:UIEdgeInsetsMake(topInset + edgeInsets.top, edgeInsets.left, edgeInsets.bottom, edgeInsets.right)];
                [(UIScrollView*)newAddedView setContentOffset:CGPointMake(0, -topInset - edgeInsets.top)];
            } else {
                [self setScrollViewContentInset:newAddedView viewController:self.topViewController];
            }
            
            layers = [newLayers copy];
        }
    }];
}

- (void)removeKVO {
    [self.KVOController unobserve:self.topViewController.view];
}

- (void)removeKVOForControllers:(NSArray *)controllers {
    for (UIViewController *controller in controllers) {
        [self.KVOController unobserve:controller.view];
    }
}

- (void)setScrollViewContentInset:(UIView *)view viewController:(UIViewController *)viewController {
    for (UIView * subView in [view subviews]) {
        if ([subView isKindOfClass:[UIScrollView class]] && CGRectGetHeight(viewController.view.bounds) == CGRectGetHeight(subView.bounds)) {
            UIEdgeInsets edgeInsets = ((UIScrollView*)subView).contentInset;
            CGFloat topInset = self.view.tt_safeAreaInsets.top;
            if (!self.topViewController.ttHideNavigationBar){
                topInset += 44;
            }
            [(UIScrollView*)subView setContentInset:UIEdgeInsetsMake(topInset + edgeInsets.top, edgeInsets.left, edgeInsets.bottom, edgeInsets.right)];
            [(UIScrollView*)subView setContentOffset:CGPointMake(0, -topInset - edgeInsets.top)];
            
            break;
        }
        [self setScrollViewContentInset:subView viewController:viewController];
    }
}

- (void)setNavigationBarHidden:(BOOL)hidden animated:(BOOL)animated {
    [super setNavigationBarHidden:YES animated:NO];
    UIViewController *topVC = self.topViewController;
    topVC.ttNavigationBar.hidden = hidden;
}

- (UIViewController *)popViewControllerByTransitioningAnimationAnimated:(BOOL)animated {
    if ([self.viewControllers count] < 2){
        return nil;
    }
    
    [self removeKVO];
    
    UIViewController *vc = nil;
    @try {
        vc = [super popViewControllerAnimated:animated];
    }
    @catch (NSException *exception) {
        
    }
    
    [self ignorePushViewControllersIfNeeded:animated];
    
    return vc;
}

- (UIViewController *)popViewControllerAnimated:(BOOL)animated
{
    [self removeKVO];
    
    UIViewController *vc = [super popViewControllerAnimated:animated];
    [vc view];
    UIViewController *toVC = [self.viewControllers lastObject];

    NSInteger index = [self.viewControllers indexOfObject:toVC];

    if (![TTDeviceHelper isPadDevice] &&
        index == 0 &&
        [self.tabBarController.viewControllers containsObject:self]) {
        [self addTabBarSnapshotForSuperViewFromCache:toVC.view];

    }
    return vc;
}


- (NSArray *)popToRootViewControllerAnimated:(BOOL)animated
{
    if ([self.viewControllers count] < 2){
        return nil;
    }
    
    NSArray *removedVCs = [self.viewControllers subarrayWithRange:NSMakeRange(1, self.viewControllers.count - 2)];
    [self removeKVOForControllers:removedVCs];
    
    UIViewController *fromVC = [self.viewControllers lastObject];
    NSArray *vcs = [super popToRootViewControllerAnimated:NO];
    UIViewController *toVC = [self.viewControllers lastObject];
    
    [self customPopToViewController:toVC fromViewController:fromVC animated:animated];
    
    [self ignorePushViewControllersIfNeeded:animated];

    return vcs;
}

- (NSArray *)popToViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if ([self.viewControllers count] < 2){
        return nil;
    }
    
    NSInteger index = [self.viewControllers indexOfObject:viewController];
    if (index == NSNotFound) return nil;
    NSArray *removedVCs = [self.viewControllers subarrayWithRange:NSMakeRange(index + 1, self.viewControllers.count - index - 1)];
    [self removeKVOForControllers:removedVCs];
    
    UIViewController *fromVC = [self.viewControllers lastObject];
    NSArray *vcs = [super popToViewController:viewController animated:NO];
    UIViewController *toVC = [self.viewControllers lastObject];
    
    [self customPopToViewController:toVC fromViewController:fromVC animated:animated];
    
    [self ignorePushViewControllersIfNeeded:animated];
    
    return vcs;
}

- (void)customPopToViewController:(UIViewController *)viewController fromViewController:(UIViewController *)fromViewController animated:(BOOL)animated
{
    [UIView setAnimationsEnabled:YES];
    
    //这里需要提前触发VC的viewDidLoad方法，通过SSViewControllerBase设置默认的ttHideNavigationBar=NO，进而就不会初始化ttNavigationBar保持隐藏
    [viewController view];
    
    if (animated) {
        
        [self.view addSubview:fromViewController.view];
        [self.view bringSubviewToFront:fromViewController.view];
        
        if (![TTDeviceHelper isPadDevice] && [self.viewControllers indexOfObject:viewController] == 0 && [self.tabBarController.viewControllers containsObject:self]) {
            [self addTabBarSnapshotForSuperView:viewController.view];
        }
        
        [self.view addSubview:_maskView];
        [self.view insertSubview:_maskView belowSubview:fromViewController.view];
        _maskView.alpha = 1.0f;
        
        CGRect fromVCFrame = CGRectMake(0, 0, CGRectGetWidth(fromViewController.view.frame), CGRectGetHeight(fromViewController.view.frame));
        fromViewController.view.frame = fromVCFrame;
        fromViewController.view.userInteractionEnabled = NO;
        if (!viewController.ttNeedIgnoreZoomAnimation) {
            viewController.view.transform = CGAffineTransformMakeScale(0.98, 0.98);
        }
        
        self.originalColor = self.view.backgroundColor;
        self.view.backgroundColor = [UIColor blackColor];
        [UIView animateWithDuration:0.15 customTimingFunction:CustomTimingFunctionQuadIn animation:^{
            fromViewController.view.transform = CGAffineTransformMakeTranslation(CGRectGetWidth(viewController.view.frame), 0);
            viewController.view.transform = CGAffineTransformIdentity;
            _maskView.alpha = 0.0;
        } completion:^(BOOL finished) {
            self.view.backgroundColor = self.originalColor;
            self.originalColor = nil;
            if(self.topViewController == viewController) {
                [fromViewController.view removeFromSuperview];
                fromViewController.view.transform = CGAffineTransformIdentity;
            }
            [_maskView removeFromSuperview];
            fromViewController.view.userInteractionEnabled = YES;
            viewController.view.transform = CGAffineTransformIdentity;
            [self removeTabBarSnapshotForSuperView:viewController.view];
            
            if (![TTDeviceHelper isPadDevice] && [self.viewControllers indexOfObject:viewController] == 0 && [self.tabBarController.viewControllers containsObject:self]) {
                self.tabBarController.tabBar.hidden = NO;
            }
        }];
    }
}

#pragma mark - Private API
- (void)didShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    [super didShowViewController:viewController animated:animated];
    //#ifndef TTModule
    // CLS_LOG(@"NavDidShowVC %@",NSStringFromClass([viewController class]));
    //#endif
    
}



#pragma mark Gesture Delegate

//- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
//
//    if ([gestureRecognizer isKindOfClass:[UISwipeGestureRecognizer class]]) {
//        if (([touch.view isKindOfClass:[UISwitch class]]) || [touch.view.superview.superview isKindOfClass:[UISwitch class]]) {
//            return NO;
//        }
//        //fix:ipad下详情页字体设置弹出后swip手势优先响应的bug
//        UIView *view = touch.view;
//        while (view) {
//            if ([view isKindOfClass:NSClassFromString(@"SSActivityView")]) {
//                return NO;
//            }
//            view = view.superview;
//        }
//        return YES;
//    }
//    else {
//        if (self.shouldIgnorePushingViewControllers) {
//            return NO;
//        }
//        else if (![TTDeviceHelper isPadDevice] && UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation)) {
//            return NO;
//        }
//        else
//        {
//            UIView *view = touch.view;
//            while (view) {
//                if ([view isKindOfClass:NSClassFromString(@"TTAdCanvasLoopPicCell")])
//                {
//                    return NO;
//                }
//                view = view.superview;
//            }
//        }
//
//    }
//    return self.viewControllers.count > 1;
//}
//
//- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
//
//    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad && [gestureRecognizer isKindOfClass:[UISwipeGestureRecognizer class]]) {
//        if (!self.topViewController.
//            ttDisableDragBack && self.viewControllers.count > 1) {
//            return YES;
//        } else {
//            return NO;
//        }
//    }
//    else {
//        if ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
//            if (!self.topViewController.
//                ttDisableDragBack && self.viewControllers.count > 1) {
//                return YES;
//            } else {
//                return NO;
//            }
//        }
//    }
//
//    return self.viewControllers.count > 1;
//}


#pragma mark ---- 这下面都是为了iOS6啊 ~ 截屏神马的

- (void)removeViewControllerAtIndex:(NSUInteger)index
{
    if (index >= self.viewControllers.count) {
        return;
    }
    
    NSMutableArray *viewControllers = self.viewControllers.mutableCopy;
    // 移除view controller
    [viewControllers removeObjectAtIndex:index];
    
    self.viewControllers = viewControllers;
}

#pragma mark - Gesture

- (void)pan:(UIPanGestureRecognizer *)recognizer
{
    UIGestureRecognizerState state = recognizer.state;
    CGPoint offset = [recognizer translationInView:recognizer.view];
    CGPoint velovity = [recognizer velocityInView:recognizer.view];
    CGRect screenBounds = [UIScreen mainScreen].bounds;
    CGFloat offsetPercent = MIN(1, MAX(0, offset.x / CGRectGetWidth(screenBounds)));
    CGFloat velovityX = velovity.x;
    switch (state)
    {
        case UIGestureRecognizerStateBegan:
        {
            if (self.topViewController.panBeginAction) {
                self.topViewController.panBeginAction();
            }
            
            self.topViewController.view.userInteractionEnabled = NO;
            
            if (self.viewControllers.count >=2) {
                UIViewController * viewController = self.viewControllers[self.viewControllers.count-2];
                
                //取前一个vc的view垫在底下
                NSInteger shouldCaptureVCIndex = [self topViewControllerIndexWithNoneDragToRoot];
                if (self.topViewController.ttDragToRoot && shouldCaptureVCIndex < self.viewControllers.count) {
                    viewController = [self.viewControllers objectAtIndex:shouldCaptureVCIndex];
                }
                
                viewController.view.frame = self.view.bounds;
                self.insertView = viewController.view;
                //对tabBar采取截屏方式处理，不改变视图的层级结构以免出bug
                if (![TTDeviceHelper isPadDevice] && ([self.viewControllers indexOfObject:viewController] == 0) && [self.tabBarController.viewControllers containsObject:self]) {
                    [self addTabBarSnapshotForSuperView:self.insertView];
                }
                //加一个shadow
                self.shadowImage.frame = CGRectMake(-9, 0, 9, CGRectGetHeight(viewController.view.frame));
                [viewController.view addSubview:self.shadowImage];
                
                self.originalColor = self.view.backgroundColor;
                self.view.backgroundColor = [UIColor blackColor];
                self.maskView.frame = viewController.view.bounds;
                [viewController.view addSubview:_maskView];
                _maskView.alpha = 1.0f;
                
                //修改实现方式，sendBack到self.view后面不会被presentingView遮挡，也不会盖在当前的顶层视图上面
                [self.view addSubview:viewController.view];
                [self.view sendSubviewToBack:viewController.view];
                
                [viewController didMoveToParentViewController:self];
            }
            
        } break;
            
        case UIGestureRecognizerStateChanged:
        {
            if (offset.x < 0 ) {
                
                [self transitionAtPercent:0];
                return;
            }
            [self transitionAtPercent:offsetPercent];
            
        } break;
            
            // Finger release
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
        {
            self.topViewController.view.userInteractionEnabled = YES;
            // 暂时禁用手势，防止狂滑滑出bug
            self.panRecognizer.enabled = NO;
            // Pop
            if (offsetPercent >= 0.3f || velovityX >= 500)
            {
                
                [self performAnimation:^{
                    self.animationLock = YES;
                    [self transitionAtPercent:1];
                    
                } completion:^{
                    
                    self.view.backgroundColor = self.originalColor;
                    self.originalColor = nil;
                    
                    [self transitionAtPercent:0];
                    self.maskView.alpha = 0.0f;
                    self.insertView.transform = CGAffineTransformIdentity;
                    
                    UIViewController *vc = [self.viewControllers lastObject];
                    
                    if(vc.ttDragToRoot) {
                        [UIView performWithoutAnimation:^{
                            [self popToViewController:[self.viewControllers objectAtIndex:[self topViewControllerIndexWithNoneDragToRoot]]
                                             animated:NO];
                        }];
                    }
                    else
                        [self popViewControllerAnimated:NO];
                    
                    self.panRecognizer.enabled = YES;
                    
                    //tricky code不延时的话可能会出现tabbar从无到有的闪动
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_MSEC)), dispatch_get_main_queue(), ^{
                        if (self.viewControllers.count == 1 && [self.tabBarController.viewControllers containsObject:self]) {
                            self.tabBarController.tabBar.hidden = NO;
                            [self removeTabBarSnapshotForSuperView:self.insertView];
                        } else {
                            [self removeTabBarSnapshotForSuperView:self.insertView];
                        }
                        self.insertView = nil;
                    });
                    [self.maskView removeFromSuperview];
                }];
                
            }
            // Restore
            else
            {
                [self performAnimation:^{
                    
                    [self transitionAtPercent:0];
                    
                } completion:^{
                    self.view.backgroundColor = self.originalColor;
                    self.originalColor = nil;
                    self.maskView.alpha = 0.0f;
                    self.insertView.transform = CGAffineTransformIdentity;
                    [self removeTabBarSnapshotForSuperView:self.insertView];
                    [self.maskView removeFromSuperview];
                    if ([self.view.subviews containsObject:self.insertView]) {
                        [self.insertView removeFromSuperview];
                    }
                    self.insertView = nil;
                    self.panRecognizer.enabled = YES;
                    
                    if (self.topViewController.panRestoreAction) {
                        self.topViewController.panRestoreAction();
                    }
                    
                }];
            }
            
        } break;
            
        default:
            break;
    }
}

- (void)swipe:(UISwipeGestureRecognizer *)recognizer
{
    UIGestureRecognizerState state = recognizer.state;
    switch (state)
    {
        case UIGestureRecognizerStateEnded:
        {
            
            UIViewController *vc = [self.viewControllers lastObject];
            
            if(vc.ttDragToRoot) {
                [UIView performWithoutAnimation:^{
                    [self popToViewController:[self.viewControllers objectAtIndex:[self topViewControllerIndexWithNoneDragToRoot]]
                                     animated:NO];
                }];
            }
            else {
                [self popViewControllerAnimated:YES];
            }
        }
        default:
            break;
    }
}

- (void)transitionAtPercent:(CGFloat)percent
{
    UIView *movingView = nil;
    
    movingView = [self innerTransitionView];
    
    self.maskView.alpha = 1 - percent;
    
    if (!self.insertView.viewController.ttNeedIgnoreZoomAnimation) {
        self.insertView.transform = CGAffineTransformMakeScale(0.98 + 0.02 * percent, 0.98 + 0.02 * percent);
    }
    
    self.shadowImage.frame = CGRectMake(CGRectGetWidth(self.view.bounds) * percent-9, 0, 9, self.shadowImage.frame.size.height);
    [self.view insertSubview:self.shadowImage aboveSubview:movingView];
    
    // 移动当前view
    movingView.frame = CGRectOffset(self.view.bounds, CGRectGetWidth(self.view.bounds) * percent, 0);
}


#pragma mark - Helpers

- (UIView *)innerBarBackgroundView
{
    for (UIView *subview in self.navigationBar.subviews)
    {
        if ([subview isMemberOfClass:NSClassFromString(@"_UINavigationBarBackground")])
        {
            return subview;
        }
    }
    return nil;
}

- (UIView *)innerTransitionView
{
    for (UIView *subview in self.view.subviews)
    {
        if ([subview isMemberOfClass:NSClassFromString(@"UINavigationTransitionView")])
        {
            return subview;
        }
    }
    return nil;
}

- (NSArray *)innerBarItemViews
{
    NSMutableArray *views = [NSMutableArray array];
    for (UIView *subview in self.navigationBar.subviews)
    {
        if ([subview isMemberOfClass:NSClassFromString(@"UINavigationItemView")] ||
            [subview isKindOfClass:[UILabel class]] ||
            [subview isKindOfClass:[UIButton class]])
        {
            [views addObject:subview];
        }
        
    }
    return [views copy];
}

- (void)performAnimation:(dispatch_block_t)animationBlock completion:(dispatch_block_t)competionBlock
{
    [UIView animateWithDuration:0.165 customTimingFunction:CustomTimingFunctionQuadOut delay:0.f options:0 animation:animationBlock completion:^(BOOL finished) {
        self.shouldIgnorePushingViewControllers = NO;
        competionBlock();
    }];
}

- (UIView *)snapshotViewFromView:(UIView *)view
{
    //Test Code -- 5.1 nick
    if (view.superview && view.window && ([TTDeviceHelper OSVersionNumber] >= 8)) {
        UIGraphicsBeginImageContextWithOptions(view.bounds.size, YES, [UIScreen mainScreen].scale);
        // afterScreenUpdates:YES会导致页面H5动画不流畅
        [view drawViewHierarchyInRect:view.bounds afterScreenUpdates:NO];
        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        UIImageView * imageView = [[UIImageView alloc] initWithFrame:view.bounds];
        imageView.image = image;
        
        return imageView;
    }
    // afterScreenUpdates:YES会导致页面H5动画不流畅
    return [view snapshotViewAfterScreenUpdates:NO];
}

- (NSInteger)topViewControllerIndexWithNoneDragToRoot
{
    //栈顶开始向栈底遍历第一个ttDragToRoot为NO的VC
    for (NSInteger idx = self.viewControllers.count - 1; idx > 0; idx--) {
        UIViewController *vc = (UIViewController *)self.viewControllers[idx];
        if (!vc.ttDragToRoot) {
            return idx;
        }
    }
    return 0;
}

- (UIView *)snapShotForTabbar {
    UITabBar *tabBar = self.tabBarController.tabBar;
    UIView *tabBarSnapShot = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(tabBar.frame), CGRectGetHeight(tabBar.superview.frame))];
    
    //iOS10 TabBar高斯模糊效果的子视图换成了UIVisualEffectview 直接截图是截不到的
    //https://developer.apple.com/reference/uikit/uivisualeffectview
    if ([TTDeviceHelper OSVersionNumber] >= 10.f) {
        UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:[[TTThemeManager sharedInstance_tt].currentThemeName isEqualToString:@"night"] ? UIBlurEffectStyleDark : UIBlurEffectStyleLight];
        UIVisualEffectView *effectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
        effectView.frame = tabBar.frame;
        [tabBarSnapShot addSubview:effectView];
    }
    
    //tabBar截图
    tabBar.layer.hidden = NO;
    UIGraphicsBeginImageContextWithOptions(tabBarSnapShot.bounds.size, NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(context, 0, CGRectGetHeight(tabBarSnapShot.frame)-CGRectGetHeight(tabBar.frame));
    [tabBar.layer renderInContext:context];
    
    UIImage *image = [UIGraphicsGetImageFromCurrentImageContext() imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UIGraphicsEndImageContext();
    UIImageView *snapShot = [[UIImageView alloc] initWithImage:image];
    snapShot.frame = tabBarSnapShot.bounds;
    [tabBarSnapShot addSubview:snapShot];
    self.snapShot = snapShot;
    tabBar.layer.hidden = YES;

    tabBarSnapShot.tag = kTabBarSnapShotTag;
    
    return tabBarSnapShot;
}


+ (BOOL)refactorNaviEnabled {
    return YES;
}

- (void)addTabBarSnapshotForSuperViewFromCache:(UIView *)superView {
    if (![superView viewWithTag:kTabBarSnapShotTag]) {
        UITabBar *tabBar = self.tabBarController.tabBar;
        UIView *tabBarSnapShot = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(tabBar.frame), CGRectGetHeight(tabBar.superview.frame))];

        //iOS10 TabBar高斯模糊效果的子视图换成了UIVisualEffectview 直接截图是截不到的
        //https://developer.apple.com/reference/uikit/uivisualeffectview
        if ([TTDeviceHelper OSVersionNumber] >= 10.f) {
            UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:[[TTThemeManager sharedInstance_tt].currentThemeName isEqualToString:@"night"] ? UIBlurEffectStyleDark : UIBlurEffectStyleLight];
            UIVisualEffectView *effectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
            effectView.frame = tabBar.frame;
            [tabBarSnapShot addSubview:effectView];
            [tabBarSnapShot addSubview:_snapShot];
            _snapShot = nil;
            tabBarSnapShot.tag = kTabBarSnapShotTag;
            [superView addSubview:tabBarSnapShot];

        }
    }
}

- (void)addTabBarSnapshotForSuperView:(UIView *)superView {
    if (![superView viewWithTag:kTabBarSnapShotTag]) {
        [superView addSubview:[self snapShotForTabbar]];
    }
}

- (void)removeTabBarSnapshotForSuperView:(UIView *)superView {
    if ([superView viewWithTag:kTabBarSnapShotTag]) {
        [[superView viewWithTag:kTabBarSnapShotTag] removeFromSuperview];
    }
}

- (void)addCustomNavigationBarIfNeeded {
    [self addCustomNavigationBarForViewController:self.topViewController];
}

- (void)addCustomNavigationBarForViewController:(UIViewController *)viewController {
    // SSViewControllerBase中会在viewDidLoad中设置ttHideNavigationBar=NO进而跳过ttNavigationBar初始化而隐藏
    if (!viewController.ttHideNavigationBar && viewController.navigationItem && !viewController.ttNavigationBar) {
        CGFloat topInset = navigationBarTop();
        TTNavigationBar * navBar = [[TTNavigationBar alloc] initWithFrame:CGRectMake(0, topInset, viewController.view.frame.size.width, 44)];
        if (viewController.ttNeedTopExpand){
            [navBar setValue:@(UIBarPositionTopAttached) forKey:@"barPosition"];
        }
        viewController.ttNavigationBar = navBar;
        navBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [viewController.view addSubview:navBar];
        [navBar tt_configNavBarWithTheme:viewController.navigationController.ttNavBarStyle];
        
        if (viewController.automaticallyAdjustsScrollViewInsets) {
            viewController.automaticallyAdjustsScrollViewInsets = NO;
            [self setScrollViewContentInset:viewController.view viewController:viewController];
        }
    }
    //只有对用了自定义navigationBar的VC.view才需要观察是否有子视图动态的被添加，来调整其inset
    if (!viewController.ttHideNavigationBar && viewController.ttNavigationBar) {
        [self addKVO];
    }
}

- (void)ignorePushViewControllersIfNeeded:(BOOL)needIgnore {
    if (needIgnore) {
        self.shouldIgnorePushingViewControllers = YES;
        
        //把didShowViewController的保护放在这里 用timer 试一下
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.6f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            self.shouldIgnorePushingViewControllers = NO;
        });
    }
}

#pragma safeInset

//- (UIEdgeInsets)additionalSafeAreaInsets
//{
//    UIEdgeInsets additionalSafeAreaInsets = super.additionalSafeAreaInsets;
//    if (!self.topViewController.ttHideNavigationBar){
//        additionalSafeAreaInsets.top += 44;
//    }
//    return additionalSafeAreaInsets;
//}

@end


@implementation UIViewController (PanLifeCycleBlock)
@dynamic panBeginAction, panRestoreAction;

- (void(^)())panBeginAction
{
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setPanBeginAction:(void (^)())panBeginAction
{
    objc_setAssociatedObject(self, @selector(panBeginAction), panBeginAction, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (void (^)())panRestoreAction
{
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setPanRestoreAction:(void (^)())panRestoreAction
{
    objc_setAssociatedObject(self, @selector(panRestoreAction), panRestoreAction, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (void)pushAnimationCompletion
{
    
}

@end

