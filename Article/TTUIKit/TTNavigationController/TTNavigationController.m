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
#import "SSWebViewController.h"

#import <Crashlytics/Crashlytics.h>


@interface TTChildViewControllerInfo : NSObject

@property (nonatomic, weak) UIViewController *viewController;
@property (nonatomic) BOOL canDragBack;
@property (nonatomic, strong) UIView *snapshotView;
@property (nonatomic, strong) UIView *barSnapshotView;
@property (nonatomic, weak) UINavigationItem *navigationItem;
@property (nonatomic) BOOL navigationBarHidden;

- (void)cleanUpSnapshots;
@end

@implementation TTChildViewControllerInfo

- (void)cleanUpSnapshots
{
    [self.snapshotView removeFromSuperview];
    [self.barSnapshotView removeFromSuperview];
}

@end

#pragma mark 分割线

@interface UINavigationController(TTNavigationController)
- (void)didShowViewController:(UIViewController *)viewController animated:(BOOL)animated;
@end

@interface TTNavigationController () <UIGestureRecognizerDelegate>

@property (nonatomic, strong) NSMutableArray *childVCInfos;
@property (nonatomic, strong) TTChildViewControllerInfo *currentChildVCInfo;

@property (nonatomic, assign) BOOL fullScreenVideoIsPlaying;
@property (nonatomic, assign) BOOL useScheenShot;
 
@property (nonatomic, strong) UIImageView * shadowImage;

@end


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
    
    //监听主题变化
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reloadTheme)
                                                 name:SSResourceManagerThemeModeChangedNotification
                                               object:nil];

    self.shadowImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed: @"touying.png"]];
    self.useScheenShot = YES;
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        
        self.swipeRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipe:)];
        self.swipeRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
        self.swipeRecognizer.delegate = self;
        [self.view addGestureRecognizer:self.swipeRecognizer];

    }
    else {
        if (self.useScheenShot) {

            self.childVCInfos = [NSMutableArray array];
            
            // 滑动手势
            self.panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
            self.panRecognizer.delegate = self;
            [self.view addGestureRecognizer:self.panRecognizer];

        }
        else {
        
            UIPanGestureRecognizer* panRecognizer = [[UIPanGestureRecognizer alloc] init];
            [self.view addGestureRecognizer:panRecognizer];
            panRecognizer.delegate = self;
            
            
            NSArray *internalTargets = [self.interactivePopGestureRecognizer valueForKey:@"targets"];
            id internalTarget = [internalTargets.firstObject valueForKey:@"target"];
            SEL internalAction = NSSelectorFromString(@"handleNavigationTransition:");
            
            //do hack here
            [panRecognizer addTarget:internalTarget action:internalAction];
        }
        
        // Disable the onboard gesture recognizer.
        self.interactivePopGestureRecognizer.enabled = NO;
    }
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
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)myPopGestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
//    otherGestureRecognizer.delaysTouchesBegan = YES;
    // 修复单元格无法滑出删除功能的问题
    if ([otherGestureRecognizer isKindOfClass:[UISwipeGestureRecognizer class]]) {
        UISwipeGestureRecognizer *recognizer = (UISwipeGestureRecognizer *)otherGestureRecognizer;
        if (recognizer.direction & UISwipeGestureRecognizerDirectionRight) {
            recognizer.direction = UISwipeGestureRecognizerDirectionLeft;
        }
        return YES;
    }
   
    
    if ([self gestureView:otherGestureRecognizer.view isClass:NSClassFromString(@"UITableViewWrapperView")]) {
        return YES;
    };
    
    if ([self gestureView:otherGestureRecognizer.view isClass:[UITableViewCell class]]) {
        return YES;
    };
    
    if ([self gestureView:otherGestureRecognizer.view isClass:NSClassFromString(@"UITableViewCellContentView")]) {
        return YES;
    };
    
    return NO;
}


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self setTtNavBarStyle:self.topViewController.ttNavBarStyle];
    
    if (!self.topViewController.ttStatusBarStyle) {
        
        [UIApplication sharedApplication].statusBarStyle = [[TTThemeManager sharedInstance_tt] statusBarStyle];
    }
    else {
        
        if ([UIApplication sharedApplication].statusBarStyle != self.topViewController.ttStatusBarStyle) {
            
            [UIApplication sharedApplication].statusBarStyle = self.topViewController.ttStatusBarStyle;
            
        }
    }
    
    [self setNavigationBarHidden:self.topViewController.ttHideNavigationBar animated:NO];
    
    
}
static NSString * const VIDEO_CONTROLLER_CLASS_NAME_IOS7 = @"MPInlineVideoFullscreenViewController";
static NSString * const VIDEO_CONTROLLER_CLASS_NAME_IOS8 = @"AVFullScreenViewController";


- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    if (![SSCommon isPadDevice]) {
        
        //视频播放 支持横竖屏
        if ([[self presentedViewController] isKindOfClass:NSClassFromString(VIDEO_CONTROLLER_CLASS_NAME_IOS7)] ||
            [[self presentedViewController] isKindOfClass:NSClassFromString(VIDEO_CONTROLLER_CLASS_NAME_IOS8)]) {
            
            return UIInterfaceOrientationMaskAll;
        }
        
        UIViewController *presentedViewController = self.topViewController;
        
        if ([presentedViewController isKindOfClass:NSClassFromString(@"SSWebViewController")]) {
            
//            if (((SSWebViewController *)presentedViewController).iphoneSupportRotate) {
//                return UIInterfaceOrientationMaskAll;
//            }
//            return UIInterfaceOrientationMaskPortrait;
            
            ///...
            SSWebViewController *webViewController = (SSWebViewController *)presentedViewController;
            if (webViewController.supportLandscapeOnly) {
                return UIInterfaceOrientationMaskLandscapeRight;
            } else if (webViewController.iphoneSupportRotate) {
                return UIInterfaceOrientationMaskAll;
            }
            return UIInterfaceOrientationMaskPortrait;
        }
        return UIInterfaceOrientationMaskPortrait;
    }
    else {
        return UIInterfaceOrientationMaskAll;
    }
}

- (void)reloadTheme
{
    [self tt_reloadTheme];
}

#pragma mark ---- 这下面都是为了iOS6啊 ~ 截屏神马的

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if (!viewController) {
        return;
    }
    if (self.shouldIgnorePushingViewControllers) {
        return;
    }
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        TTChildViewControllerInfo *newInfo = [self createInfoWithVC:viewController];
        [self.childVCInfos addObject:newInfo];
        self.currentChildVCInfo = newInfo;
    }
    else {
        if (self.useScheenShot) {
            TTChildViewControllerInfo *newInfo = [self createInfoWithVC:viewController];
            [self.childVCInfos addObject:newInfo];
            
            [self.currentChildVCInfo cleanUpSnapshots];
            self.currentChildVCInfo = newInfo;
        }
    }
    

    @try {
        [super pushViewController:viewController animated:animated];
    } @catch (NSException * ex) {
        
    }
    if (animated) {
        self.shouldIgnorePushingViewControllers = YES;

        //把didShowViewController的保护放在这里 用timer 试一下
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.6f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            self.shouldIgnorePushingViewControllers = NO;
        });
    }
    
    
}

- (UIViewController *)popViewControllerAnimated:(BOOL)animated
{

    UIViewController *vc = nil;
    @try {
        vc = [super popViewControllerAnimated:animated];
    }
    @catch (NSException *exception) {
        
    }
    
    if (vc && YES) {
        
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
            
        }
        else {
            TTChildViewControllerInfo *lastInfo = [self.childVCInfos lastObject];
            if (lastInfo) {
                [self.childVCInfos removeLastObject];
            }
            // Clean up
            [self.currentChildVCInfo cleanUpSnapshots];
        }
    }
    return vc;
}
 

- (NSArray *)popToRootViewControllerAnimated:(BOOL)animated
{
    // 删除截图
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        self.currentChildVCInfo = nil;
    }
    else {
        if (self.useScheenShot) {
            
            [self.childVCInfos removeAllObjects];
        }
    }
    return [super popToRootViewControllerAnimated:animated];
}

- (NSArray *)popToViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        
    }
    else {
        //处理一下截图
        for (NSUInteger i = 0; i< [self.viewControllers count]; i++) {
            if ([self.viewControllers[i] isEqual:viewController]) {
                [self.childVCInfos removeObjectsInRange:NSMakeRange(i, [self.childVCInfos count]-i)];
                break;
            }
        }
    }
    return [super popToViewController:viewController animated:animated];
}

#pragma mark - Private API
- (void)didShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    [super didShowViewController:viewController animated:animated];
    
    CLS_LOG(@"NavDidShowVC %@",NSStringFromClass([viewController class]));
}



#pragma mark Gesture Delegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    
    if ([gestureRecognizer isKindOfClass:[UISwipeGestureRecognizer class]]) {
        if (([touch.view isKindOfClass:[UISwitch class]]) || [touch.view.superview.superview isKindOfClass:[UISwitch class]]) {
            return NO;
        }
        return YES;
    }
    else {
        if (self.shouldIgnorePushingViewControllers) {
            return NO;
        }
    }
    return self.viewControllers.count > 1;
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad && [gestureRecognizer isKindOfClass:[UISwipeGestureRecognizer class]]) {
        
        if (self.currentChildVCInfo.canDragBack && !self.currentChildVCInfo.viewController.
            ttDisableDragBack && self.viewControllers.count > 1) {
            return YES;
        }
        else
            return NO;
    }
    else {
        if (self.useScheenShot && [gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {

            // 设置为当前vc
            self.currentChildVCInfo = [self.childVCInfos lastObject];
            
            if (self.currentChildVCInfo.canDragBack && !self.currentChildVCInfo.viewController.ttDisableDragBack && self.viewControllers.count > 1) {
                // 当从左向右滑动时才开始手势识别
                CGPoint transition = [(UIPanGestureRecognizer*)gestureRecognizer translationInView:gestureRecognizer.view];
                if (transition.x > 0) {
                    return YES;
                }
            }
            else
                return NO;
        }
    }
 
    return YES;
}


#pragma mark ---- 这下面都是为了iOS6啊 ~ 截屏神马的

- (void)setCanDragBack:(BOOL)canDragBack
{
    _canDragBack = canDragBack;
    self.currentChildVCInfo.canDragBack = canDragBack;
}

- (void)removeViewControllerAtIndex:(NSUInteger)index
{
    if (index >= self.viewControllers.count) {
        return;
    }
    
    NSMutableArray *viewControllers = self.viewControllers.mutableCopy;
    // 移除view controller
    [viewControllers removeObjectAtIndex:index];
    // 移除截图
    if (index < self.childVCInfos.count) {
        [self.childVCInfos removeObjectAtIndex:index];
    }
    self.viewControllers = viewControllers;
}

#pragma mark - Gesture

- (void)pan:(UIPanGestureRecognizer *)recognizer
{
    UIGestureRecognizerState state = recognizer.state;
    CGPoint offset = [recognizer translationInView:recognizer.view];
    CGRect screenBounds = [UIScreen mainScreen].bounds;
    CGFloat offsetPercent = MIN(1, MAX(0, offset.x / CGRectGetWidth(screenBounds)));
    
    switch (state)
    {
        case UIGestureRecognizerStateBegan:
        {
            
            self.shouldIgnorePushingViewControllers = YES;

            // 若这个vc中有键盘则resign
            UIViewController *vc = [self.viewControllers lastObject];
            [vc.view endEditing:YES];
            
            // 暂时屏蔽用户事件
            vc.view.userInteractionEnabled = NO;
            
            //如果需要手滑到第一个页面 用第一个页面的信息来做currentChildVCInfo -- nick add on 4.9.x
            NSInteger shouldCaptureVCIndex = [self topViewControllerIndexWithNoneDragToRoot];
            if (vc.ttDragToRoot && shouldCaptureVCIndex < self.childVCInfos.count) {
                self.currentChildVCInfo = [self.childVCInfos objectAtIndex:shouldCaptureVCIndex];
            }
            // Snapshot
            self.currentChildVCInfo.snapshotView.frame = self.view.bounds;
            [self.view addSubview:self.currentChildVCInfo.snapshotView];
            [self.view sendSubviewToBack:self.currentChildVCInfo.snapshotView];
            
            //加一个shadow
            self.shadowImage.frame = CGRectMake(-9, 0, 9, self.currentChildVCInfo.snapshotView.frame.size.height);
            [self.view addSubview:self.shadowImage];

            
            // Bar
            if (!self.currentChildVCInfo.navigationBarHidden) {
                
                // Bar的截图，无需针对6和7分别修改
                self.currentChildVCInfo.barSnapshotView.frame = CGRectMake(0, -20, CGRectGetWidth(self.view.frame), 64);
                self.currentChildVCInfo.barSnapshotView.alpha = 0;
                [self.navigationBar addSubview:self.currentChildVCInfo.barSnapshotView];
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
            if (offsetPercent >= 0.3f)
            {
                
                [self performAnimation:^{
                    
                    [self transitionAtPercent:1];
                    
                } completion:^{

                    [self transitionAtPercent:0];

                    // Clean up
                    [self.currentChildVCInfo cleanUpSnapshots];
                    
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
                }];
                
            }
            // Restore
            else
            {
                [self performAnimation:^{
                    
                    [self transitionAtPercent:0];
                    
                } completion:^{
            
                    [self.currentChildVCInfo cleanUpSnapshots];

                    self.panRecognizer.enabled = YES;
                    
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
    CGFloat offsetX = 0;
    UIView *movingView = nil;
    
    if (!self.currentChildVCInfo.navigationBarHidden)
    {
        movingView = [self innerTransitionView];
        offsetX = (0.3f * percent - 0.3f) * CGRectGetWidth(self.view.bounds);
    }
    else
    {
        movingView = self.view;
        offsetX = (-0.7f * percent - 0.3f) * CGRectGetWidth(self.view.bounds);
    }
    
    if (!self.currentChildVCInfo.navigationBarHidden){
        self.shadowImage.frame = CGRectMake(CGRectGetWidth(self.view.bounds) * percent-9, 0, 9, self.shadowImage.frame.size.height);
        [self.view insertSubview:self.shadowImage aboveSubview:movingView];

    }
    // 移动当前view
    movingView.frame = CGRectOffset(self.view.bounds, CGRectGetWidth(self.view.bounds) * percent, 0);
    
    
    
    // 移动后面的截图
    self.currentChildVCInfo.snapshotView.frame = CGRectOffset(self.view.bounds, offsetX, 0);
    
    // 后面的截图边滑alpha值边变大
    // 有从阴影中出来的感觉
//    self.currentChildVCInfo.snapshotView.alpha = 0.8f + percent * 0.2f;
    
    // snapshot bar alpha从0开始变化阈值
    static const CGFloat threshold = 0.4f;
    // 当前的title alpha减小速率
    static const CGFloat speed = 1.4f;
    
    // 当前导航栏的item view随滑动渐隐
    CGFloat barAlpha = 1 - speed * sqrtf(percent);
    for (UIView *view in [self innerBarItemViews]) {
        view.alpha = barAlpha;
    }
    
    // 滑动开始时，上一次的导航栏截图覆盖在当前导航栏上边，初始alpha为0
    // 随滑动逐渐变成1
    self.currentChildVCInfo.barSnapshotView.alpha = sqrtf(MAX(0, percent - threshold));
    
}


#pragma mark - Helpers

- (TTChildViewControllerInfo *)createInfoWithVC:(UIViewController *)vc
{
    TTChildViewControllerInfo *newInfo = [TTChildViewControllerInfo new];
    
    newInfo.viewController = vc;
    
    // 默认可以滑动返回
    newInfo.canDragBack = YES;
    
    //iPad不做截屏
    if ([[UIDevice currentDevice] userInterfaceIdiom] != UIUserInterfaceIdiomPad) {

        // 判断当前这个vc是被present出来的还是从tabBarController某个地方push的
        // 分别截取tab vc和window
        if (self.tabBarController) {
            newInfo.snapshotView = [self snapshotViewFromView:self.tabBarController.view];
        }
        else {
            newInfo.snapshotView = [self snapshotViewFromView:self.view.window];
        }
        
        newInfo.navigationBarHidden = self.navigationBarHidden;
        if (!self.navigationBarHidden)
        {
            newInfo.barSnapshotView = ({
                UIView *barSnapshotView = [self snapshotViewFromView:[self innerBarBackgroundView]];
                UIView *contentView = [self snapshotViewFromView:self.navigationBar];
                contentView.frame = CGRectMake(0, 20, CGRectGetWidth(self.view.frame), 44);
                [barSnapshotView addSubview:contentView];
                barSnapshotView;
            });
        }
    }
    
    // 储存 Navigation item
    newInfo.navigationItem = vc.navigationItem;
    return newInfo;
}

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
    NSTimeInterval duration = 0.35;
    UIViewAnimationOptions options = UIViewAnimationOptionCurveEaseOut;
    
    [UIView animateWithDuration:duration delay:0 options:options animations:animationBlock completion:^(BOOL finished) {
        
        self.shouldIgnorePushingViewControllers = NO;
        competionBlock();
    }];
}

- (UIView *)snapshotViewFromView:(UIView *)view
{
    //Test Code -- 5.1 nick
    if (view.superview && view.window && ([SSCommon OSVersionNumber] >= 8)) {
        UIGraphicsBeginImageContextWithOptions(view.bounds.size, YES, [UIScreen mainScreen].scale);
        [view drawViewHierarchyInRect:view.bounds afterScreenUpdates:YES];
        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        UIImageView * imageView = [[UIImageView alloc] initWithFrame:view.bounds];
        imageView.image = image;
        
        return imageView;
    }
    return [view snapshotViewAfterScreenUpdates:YES];
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

@end



@interface TTNavigationBar : UINavigationBar

@end

@implementation TTNavigationBar

- (void)layoutSubviews {
    [super layoutSubviews];
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
    
        CGFloat NAVIGATION_BTN_MARGIN = [SSCommon paddingForViewWidth:0];
    
        UINavigationItem *navigationItem = [self topItem];
        
        UIView *subview = [[navigationItem rightBarButtonItem] customView];
        
        if (subview) {
            
            CGRect subviewFrame = subview.frame;
            subviewFrame = CGRectMake(self.frame.size.width - subview.frame.size.width - NAVIGATION_BTN_MARGIN, subviewFrame.origin.y, subviewFrame.size.width, subviewFrame.size.height);

            
            [subview setFrame:subviewFrame];
        }
        
        subview = [[navigationItem leftBarButtonItem] customView];
        
        if (subview) {
            
            CGRect subviewFrame = subview.frame;
            subviewFrame = CGRectMake(NAVIGATION_BTN_MARGIN, subviewFrame.origin.y, subviewFrame.size.width, subviewFrame.size.height);
            
            [subview setFrame:subviewFrame];
        }
        
        UIView * titleView = [navigationItem titleView];
        if (titleView) {
            
            CGRect subviewFrame = titleView.frame;
            CGPoint center = titleView.center;
            subviewFrame = CGRectMake(0,0,self.frame.size.width-NAVIGATION_BTN_MARGIN*2, subviewFrame.size.height);
            
            [titleView setFrame:subviewFrame];
            titleView.center = center;
        }

    }
}

@end
