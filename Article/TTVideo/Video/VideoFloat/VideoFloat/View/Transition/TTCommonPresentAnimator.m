//
//  TTCommonPresentAnimator.m
//  EverPhoto
//
//  Created by 栾军 on 15/11/12.
//  Copyright © 2015年 bytedance. All rights reserved.
//

#import "TTCommonPresentAnimator.h"

@implementation TTCommonPresentAnimator

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext
{
    return 0.3f;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
    UIViewController *fromVc = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toVc = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    fromVc.view.userInteractionEnabled = NO;
    toVc.view.userInteractionEnabled = NO;
    if (self.presenting) {
        [transitionContext.containerView addSubview:toVc.view];
        
        toVc.view.alpha = 0.0f;
        [UIView animateWithDuration:[self transitionDuration:transitionContext] delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            toVc.view.alpha = 1.0f;
        } completion:^(BOOL finished) {
            fromVc.view.userInteractionEnabled = YES;
            toVc.view.userInteractionEnabled = YES;
            [transitionContext completeTransition:YES];
        }];
    } else {
        [transitionContext.containerView addSubview:fromVc.view];
        
        [UIView animateWithDuration:[self transitionDuration:transitionContext] delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            fromVc.view.alpha = 0.0f;
        } completion:^(BOOL finished) {
            fromVc.view.userInteractionEnabled = YES;
            toVc.view.userInteractionEnabled = YES;
            [transitionContext completeTransition:YES];
        }];
    }
}

@end
