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
@property (nonatomic) UIDeviceOrientation lastPlayViewOrientation;

@end

@implementation RotateAnimator

- (instancetype)initWithRotateViewTag:(NSUInteger)tag {
    self = [super init];
    if (self) {
        _rotatedViewTag = tag;
        _lastPlayViewOrientation = UIDeviceOrientationPortrait;
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
        
        CGSize size = containerView.frame.size;
        [playView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(@(size.width));
            make.height.equalTo(@(size.height));
            make.center.equalTo(playView.superview);
        }];
        
        [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
            [playView.superview layoutIfNeeded];
//            playView.transform = CGAffineTransformMakeRotation([self angleOfCurrentOrientation:YES]);
            [self changePlayViewTransform:playView isPrensent:YES];
           
            toViewController.view.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:1];
            
        } completion:^(BOOL finished) {
            [playView removeFromSuperview];
            [toViewController.view addSubview:playView];
            playView.transform = CGAffineTransformMakeRotation(0);
            [playView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.edges.equalTo(toViewController.view).insets(UIEdgeInsetsZero);
            }];
            
            BOOL wasCancelled = [transitionContext transitionWasCancelled];
            //设置transitionContext通知系统动画执行完毕
            [transitionContext completeTransition:!wasCancelled];
            
        }];
    }else{
        UIDeviceOrientation currentOrirentation = [UIDevice currentDevice].orientation;
        
        [containerView bringSubviewToFront:fromViewController.view];
        playView = [fromViewController.view viewWithTag:self.rotatedViewTag];
        
        CGFloat width = self.frameBeforePresent.size.width;
        CGFloat height = self.frameBeforePresent.size.height;
        [playView mas_remakeConstraints:^(MASConstraintMaker *make) {
            
            make.width.mas_equalTo(@(width));
            make.height.mas_equalTo(@(height));
            make.center.equalTo(playView.superview).centerOffset(CGPointMake(-(containerView.frame.size.height - height) / 2.0+self.frameBeforePresent.origin.y, 0));
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
//    if (isPrensent) {
//         playView.transform = CGAffineTransformMakeRotation(M_PI_2);
//    }
//    else {
//         playView.transform = CGAffineTransformMakeRotation(-M_PI_2);
//    }
    if (currentOrirentation == UIDeviceOrientationPortrait) {
        if (self.lastPlayViewOrientation == UIDeviceOrientationPortrait) {
            if (isPrensent) {
                playView.transform = CGAffineTransformMakeRotation(M_PI_2);
                self.lastPlayViewOrientation = UIDeviceOrientationLandscapeLeft;
            }
        }
        else if (self.lastPlayViewOrientation == UIDeviceOrientationLandscapeLeft) {
            if (!isPrensent) { // 说明需要缩小
                playView.transform = CGAffineTransformMakeRotation(-M_PI_2);
                self.lastPlayViewOrientation = UIDeviceOrientationLandscapeLeft;
            }
        }
        else if (self.lastPlayViewOrientation == UIDeviceOrientationLandscapeRight){
            if (!isPrensent) { // 说明需要缩小
                playView.transform = CGAffineTransformMakeRotation(M_PI_2);
                self.lastPlayViewOrientation = UIDeviceOrientationLandscapeRight;
            }
        }
    }
    else if (currentOrirentation == UIDeviceOrientationLandscapeLeft) {
        if (self.lastPlayViewOrientation == UIDeviceOrientationPortrait) {
            if (isPrensent) {
                playView.transform = CGAffineTransformMakeRotation(M_PI_2);
                self.lastPlayViewOrientation = UIDeviceOrientationLandscapeLeft;
            }
        }
        else if (self.lastPlayViewOrientation == UIDeviceOrientationLandscapeRight) {
            if (isPrensent) {
                playView.transform = CGAffineTransformMakeRotation(M_PI);
                self.lastPlayViewOrientation = UIDeviceOrientationLandscapeLeft;
            }
        }
    }
    else if (currentOrirentation == UIDeviceOrientationLandscapeRight) {
        if (self.lastPlayViewOrientation == UIDeviceOrientationPortrait) {
            if (isPrensent) {
                playView.transform = CGAffineTransformMakeRotation(-M_PI_2);
                self.lastPlayViewOrientation = UIDeviceOrientationLandscapeRight;
            }
        }
        else if (self.lastPlayViewOrientation == UIDeviceOrientationLandscapeRight) {
            if (isPrensent) {
                playView.transform = CGAffineTransformMakeRotation(-M_PI);
                self.lastPlayViewOrientation = UIDeviceOrientationLandscapeRight;
            }
        }
    }

}

@end
