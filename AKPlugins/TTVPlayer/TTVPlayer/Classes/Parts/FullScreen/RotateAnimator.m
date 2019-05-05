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


@end

@implementation RotateAnimator

- (instancetype)initWithRotateViewTag:(NSUInteger)tag {
    self = [super init];
    if (self) {
        _rotatedViewTag = tag;
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
    
    //ToVC
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    toViewController.view.frame = containerView.bounds;
    //    toViewController.view.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0];
    [containerView addSubview:toViewController.view];
    
    //FromVC
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    fromViewController.view.frame = containerView.bounds;// CGRectMake(0, 0, containerView.frame.size.height, containerView.frame.size.width);
    [containerView addSubview:fromViewController.view];
    
    //播放器视图
    UIView* playView = [fromViewController.view viewWithTag:self.rotatedViewTag];
    
    BOOL isPresent = [fromViewController.presentedViewController isEqual:toViewController];//如果底层的视图弹出的视图是顶层的，那么是present出来的
    
    if (isPresent) {
        self.superViewOfPlayer = playView.superview;
        [containerView bringSubviewToFront:fromViewController.view];
//        self.testRect = [playView.superview convertRect:self.frameBeforePresent toView:[UIApplication sharedApplication].keyWindow];
        
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(screenRotate:) name:UIDeviceOrientationDidChangeNotification object:nil];
        
        CGSize size = containerView.frame.size;
        [playView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(@(size.width));
            make.height.equalTo(@(size.height));
            make.center.equalTo(toViewController.view);
        }];
        
        [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
            [playView.superview layoutIfNeeded];
            [self changePlayViewTransform:playView isPrensent:YES];
            toViewController.view.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:1];
            
        } completion:^(BOOL finished) {
            [playView removeFromSuperview];
            [toViewController.view addSubview:playView];
            playView.transform = CGAffineTransformMakeRotation(0);//CGAffineTransformIdentity;//CGAffineTransformMakeRotation(0);
            [playView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.edges.equalTo(toViewController.view).insets(UIEdgeInsetsZero);
            }];
            
            BOOL wasCancelled = [transitionContext transitionWasCancelled];
            //设置transitionContext通知系统动画执行完毕
            [transitionContext completeTransition:!wasCancelled];
            
        }];
    }else{
        [[NSNotificationCenter defaultCenter] removeObserver:self];
        
        UIDeviceOrientation currentOrirentation = [UIDevice currentDevice].orientation;
        
        [containerView bringSubviewToFront:fromViewController.view];
        playView = [fromViewController.view viewWithTag:self.rotatedViewTag];
    
        CGRect toRect = [self.superViewOfPlayer convertRect:self.frameBeforePresent toView:fromViewController.view.window];

//        CGRect toRect = [playView.superview convertRect:self.frameBeforePresent toView:toViewController.view];
//        CGRect toRect = [toViewController.view convertRect:self.frameBeforePresent fromView:playView.superview];
        
        [playView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(@(toRect.size.width));
            make.height.mas_equalTo(@(toRect.size.height));
    
            if (self.lastOrientation == UIDeviceOrientationLandscapeLeft) {
                make.center.equalTo(fromViewController.view).centerOffset(CGPointMake(-(containerView.frame.size.height - toRect.size.height)/2.0 + toRect.origin.y, 0));
            }
            else if (self.lastOrientation == UIDeviceOrientationLandscapeRight){
                make.center.equalTo(fromViewController.view).centerOffset(CGPointMake((containerView.frame.size.height - toRect.size.height)/2.0 - toRect.origin.y, 0));
            }
        }];
        
        [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
            [playView.superview layoutIfNeeded];
            [self changePlayViewTransform:playView isPrensent:NO];
            fromViewController.view.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0];
        } completion:^(BOOL finished) {
            
            [playView removeFromSuperview];
            [self.superViewOfPlayer addSubview:playView];
            playView.transform = CGAffineTransformMakeRotation(0);

            [playView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo(@(self.frameBeforePresent.origin.y));
                make.left.mas_equalTo(@(self.frameBeforePresent.origin.x));
                make.left.right.equalTo(playView.superview);
                make.height.mas_equalTo(@(self.frameBeforePresent.size.height));
            }];
        
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

@end
