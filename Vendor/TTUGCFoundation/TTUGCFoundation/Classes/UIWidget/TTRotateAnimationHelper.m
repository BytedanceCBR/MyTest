//
//  TTRotateAnimationHelper.m
//  Forum
//
//  Created by ZhangLeonardo on 15/5/29.
//
//

#import "TTRotateAnimationHelper.h"

@interface TTRotateAnimationHelper() <CAAnimationDelegate>
@property(nonatomic, assign)BOOL animating;
@property(nonatomic, strong)CABasicAnimation * rotateAnimation;
@property(nonatomic, strong)NSDate * startDate;
@property(nonatomic, strong)UIView * view;

@end

@implementation TTRotateAnimationHelper


#pragma mark -- animation

- (void)startRotateAnimationForView:(UIView *)view
{
    if(![NSThread isMainThread])
    {
        [self performSelectorOnMainThread:@selector(startAnimation:) withObject:view waitUntilDone:NO];
        return;
    }
    [self startAnimation:view];
}

- (void)startAnimation:(UIView *)view {
    
    if(!_animating)
    {
        self.view = view;
        self.animating = YES;
        self.rotateAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
        _rotateAnimation.delegate = self;
        _rotateAnimation.toValue = [NSNumber numberWithFloat:M_PI * 2];
        _rotateAnimation.duration = 1;
        _rotateAnimation.repeatCount = HUGE_VALF;
        [view.layer addAnimation:_rotateAnimation forKey:@"rotateAnimation"];
        
    }
}

- (void)stopAnimation
{
    NSTimeInterval duration = fabs([_startDate timeIntervalSinceNow]);
    duration = 1 - (duration - (int)duration);
    
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(duration * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [_view.layer removeAllAnimations];
        self.view = nil;
    });
    
}

#pragma mark -- delegate

- (void)animationDidStart:(CAAnimation *)anim
{
    self.startDate = [NSDate date];
}


- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    self.animating = NO;
}


@end
