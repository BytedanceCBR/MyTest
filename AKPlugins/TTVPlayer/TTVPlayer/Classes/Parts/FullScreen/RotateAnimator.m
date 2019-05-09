//
//  RotateAnimator.m
//  ScreenRotate
//
//  Created by mac on 2017/10/19.
//  Copyright © 2017年 zuiye. All rights reserved.
//

#import "RotateAnimator.h"
#import "Masonry.h"

@interface RotateAnimator ()

@property (nonatomic) NSUInteger rotatedViewTag;
@property (nonatomic, weak) UIView * superViewOfPlayer;
@property (nonatomic) UIDeviceOrientation lastOrientation;
@property (nonatomic, weak) UIViewController * playerVC;

//外面传的只是playview的frame，这里记的是真正的playerview的frame，可能是包了很多层的view，为了返回时候还原
@property (nonatomic) CGRect frameBeforePresentRelative;


@end

@implementation RotateAnimator

- (instancetype)initWithRotateViewTag:(NSUInteger)tag playerVC:(UIViewController *)playerVC {
    self = [super init];
    if (self) {
        _rotatedViewTag = tag;
        self.playerVC = playerVC;
    }
    return self;
}
- (instancetype)init
{
    self = [super init];
    if (self) {
        _rotatedViewTag = -1;
    }
    return self;
}
- (void)dealloc
{
    ;
}
#pragma mark - UIViewControllerTransitioningDelegate
- (nullable id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source{
    
    return self;
}

- (nullable id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed{
    
    return self;
}

- (NSTimeInterval)transitionDuration:(nullable id <UIViewControllerContextTransitioning>)transitionContext{
    return 0.5;
}

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext{
    if (self.rotatedViewTag == -1) {
        return;
    }
    //转场过渡的容器view
    UIView *containerView = [transitionContext containerView];
    containerView.backgroundColor = [UIColor clearColor];
    //ToVC
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    toViewController.view.frame = containerView.bounds;
    
    [containerView addSubview:toViewController.view];
    
    //FromVC
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    fromViewController.view.frame = containerView.bounds;
    [containerView addSubview:fromViewController.view];
    
    //播放器视图
    UIView* playView = [fromViewController.view viewWithTag:self.rotatedViewTag];
    
    playView = [self getRotateView:playView];
    
    BOOL isPresent = [fromViewController.presentedViewController isEqual:toViewController];//如果底层的视图弹出的视图是顶层的，那么是present出来的
    
    if (isPresent) {
        self.superViewOfPlayer = playView.superview;
        self.frameBeforePresentRelative = [playView convertRect:self.frameBeforePresent toView:self.superViewOfPlayer];
        
        // 添加转屏通知
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(screenRotate:) name:UIDeviceOrientationDidChangeNotification object:nil];
        
        // 这里加一个覆盖的view，因为旋转时候可能导致原来view布局问题，盖一个view只看到playview就够了
        CGSize size = containerView.frame.size;
        
        CGPoint center = CGPointMake(size.height / 2, size.width / 2);
        UIView *coverView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, containerView.bounds.size.height, containerView.bounds.size.width)];

        coverView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:1];
        [fromViewController.view addSubview:coverView];
        [containerView bringSubviewToFront:fromViewController.view];
        [playView removeFromSuperview];
        [coverView addSubview:playView];

        [UIView animateWithDuration:[self transitionDuration:transitionContext]
                              delay:0.0 options:UIViewAnimationOptionLayoutSubviews
                         animations:^{
                             [playView.superview layoutIfNeeded];
                             playView.width = size.width;
                             playView.height = size.height;
                             playView.center = center;
                             [self changePlayViewTransform:playView isPrensent:YES];
                         } completion:^(BOOL finished) {
                             [playView removeFromSuperview];
                             [coverView removeFromSuperview];
                             [toViewController.view addSubview:playView];
                             playView.transform = CGAffineTransformMakeRotation(0);//CGAffineTransformIdentity;//
                             playView.frame = toViewController.view.bounds;

                             BOOL wasCancelled = [transitionContext transitionWasCancelled];
                             // 设置transitionContext通知系统动画执行完毕
                             [transitionContext completeTransition:!wasCancelled];
                         }];
    }else{
        // 移除转屏通知
        [[NSNotificationCenter defaultCenter] removeObserver:self];
        
        [containerView bringSubviewToFront:fromViewController.view];
    
        CGRect toRect = self.frameBeforePresentRelative;
        
        [UIView animateWithDuration:[self transitionDuration:transitionContext]
                              delay:0.0 options:UIViewAnimationOptionLayoutSubviews
                         animations:^{
                             [playView.superview layoutIfNeeded];
                             playView.width = toRect.size.width;
                             playView.height = toRect.size.height;
                             if (self.lastOrientation == UIDeviceOrientationLandscapeLeft) {
                                 playView.center = CGPointMake(fromViewController.view.center.y - (containerView.frame.size.height - toRect.size.height)/2.0 + toRect.origin.y, fromViewController.view.center.x);
                             }
                             else if (self.lastOrientation == UIDeviceOrientationLandscapeRight){
                                 playView.center = CGPointMake(fromViewController.view.center.y + (containerView.frame.size.height - toRect.size.height)/2.0 - toRect.origin.y, fromViewController.view.center.x);
                             }
                             [self changePlayViewTransform:playView isPrensent:NO];
                             fromViewController.view.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0];
                         } completion:^(BOOL finished) {
                             [playView removeFromSuperview];
                             [self.superViewOfPlayer addSubview:playView];
                             playView.transform = CGAffineTransformMakeRotation(0);
                             
                             playView.frame = toRect;
                             
                             BOOL wasCancelled = [transitionContext transitionWasCancelled];
                             //设置transitionContext通知系统动画执行完毕
                             [transitionContext completeTransition:!wasCancelled];
                         }];
    }
}
// isPrensent 是否是大屏那个 playview
- (void)changePlayViewTransform:(UIView *)playView isPrensent:(BOOL)isPrensent {
    UIDeviceOrientation currentOrirentation = [UIDevice currentDevice].orientation;
    if (isPrensent) {
        if (currentOrirentation == UIDeviceOrientationLandscapeRight) {
            playView.transform = CGAffineTransformMakeRotation(-M_PI_2);
            self.lastOrientation = UIDeviceOrientationLandscapeRight;
        }
        else {
            playView.transform = CGAffineTransformMakeRotation(M_PI_2);
            self.lastOrientation = UIDeviceOrientationLandscapeLeft;
        }
    }
    else {
        if (currentOrirentation == UIDeviceOrientationLandscapeRight) {
            playView.transform = CGAffineTransformMakeRotation(M_PI_2);
        }
        else if (currentOrirentation == UIDeviceOrientationLandscapeLeft){
            playView.transform = CGAffineTransformMakeRotation(-M_PI_2);
        }
        else //if (currentOrirentation == UIDeviceOrientationPortrait) {
        {
            if (self.lastOrientation == UIDeviceOrientationLandscapeLeft) {
                playView.transform = CGAffineTransformMakeRotation(-M_PI_2);
            }
            else if (self.lastOrientation == UIDeviceOrientationLandscapeRight){
                playView.transform = CGAffineTransformMakeRotation(M_PI_2);
            }
        }
    }
}

-(void)screenRotate:(NSNotification*)notification{
    UIDevice* device = notification.object;
    //    NSLog(@"notification1:::%@", @(device.orientation));
    if (device.orientation == UIDeviceOrientationLandscapeLeft && self.lastOrientation == UIDeviceOrientationLandscapeRight) {
        self.lastOrientation = UIDeviceOrientationLandscapeLeft;
    }
    else if (device.orientation == UIDeviceOrientationLandscapeRight && self.lastOrientation == UIDeviceOrientationLandscapeLeft) {
        self.lastOrientation = UIDeviceOrientationLandscapeRight;
    }
}

- (BOOL)isEqualSizeFromFrame:(CGRect)fromFrame toFrame:(CGRect)toFrame {
    if(round(fromFrame.size.width) == round(toFrame.size.width) && round(fromFrame.size.height) == round(toFrame.size.height)){
        return YES;
    }
    return NO;
}

//获取正确的playview,不管外面包了多少层
- (UIView *)getRotateView:(UIView *)rotateView {
    UIView *view = rotateView;
    while ([self isEqualSizeFromFrame:view.frame toFrame:view.superview.frame]) {
        view = view.superview;
    }
    return view;
}

@end
