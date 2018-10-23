//
//  TSVSeondUseSwipeAnimation.m
//  AFgzipRequestSerializer
//
//  Created by Zuyang Kou on 07/12/2017.
//

#import "TSVSeondUseSwipeAnimation.h"
#import "UIView+CustomTimingFunction.h"

@interface TSVSeondUseSwipeAnimation ()

@property (nonatomic, assign) CGRect originalBounds;
@property (nonatomic, strong) UIImageView *arrowImageView;
@property (nonatomic, assign) NSInteger animationInteration;

@end

@implementation TSVSeondUseSwipeAnimation

+ (instancetype)sharedAnimation
{
    static dispatch_once_t onceToken;
    static TSVSeondUseSwipeAnimation *animation;
    dispatch_once(&onceToken, ^{
        animation = [[TSVSeondUseSwipeAnimation alloc] init];
    });

    return animation;
}

- (void)startAnimation
{
    self.animationInteration = 0;

    [self _startAnimaiton];
}

- (void)_startAnimaiton
{
    self.arrowImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"hts_left_arrow_indicator3"]];
    [self.arrowParentView addSubview:self.arrowImageView];
    self.arrowImageView.center = CGPointMake(0, CGRectGetHeight(self.scrollView.frame) / 2);
    self.arrowImageView.frame = CGRectMake(CGRectGetWidth(self.arrowParentView.frame) - 58, self.arrowImageView.frame.origin.y, 81, 26);

    self.arrowImageView.alpha = 0;
    [UIView animateWithDuration:0.15
           customTimingFunction:CustomTimingFunctionSineOut
                      animation:^{
                          self.arrowImageView.alpha = 1;
                      } completion:^(BOOL finished) {
                          [UIView animateWithDuration:0.28
                                 customTimingFunction:CustomTimingFunctionQuadraticEasyOut
                                                delay:0.85
                                              options:0
                                            animation:^{
                                                self.arrowImageView.alpha = 0;
                                            } completion:nil];
                      }];

    [UIView animateWithDuration:0.6
           customTimingFunction:CustomTimingFunctionSineOut
                          delay:0.35
                        options:0
                      animation:^{
                          CGRect frame = self.arrowImageView.frame;
                          frame.origin.x -= 60;
                          self.arrowImageView.frame = frame;
                      } completion:^(BOOL finished) {
                          [UIView animateWithDuration:0.28
                                 customTimingFunction:CustomTimingFunctionQuadraticEasyOut
                                                delay:0.05
                                              options:0
                                            animation:^{
                                                CGRect frame = self.arrowImageView.frame;
                                                frame.origin.x += 30;
                                                self.arrowImageView.frame = frame;
                                            } completion:nil];
                      }];

    self.originalBounds = self.scrollView.bounds;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.35 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        // 这个地方拉出来的时候要用 view 动画，因为这会触发 UICollectionView 把本来不在屏幕上的 cell 显示出来。放回去的时候要用 layer 动画，这样能避免把目标位置在屏幕外的 cell 隐藏掉
        [UIView animateWithDuration:0.6 customTimingFunction:CustomTimingFunctionSineOut
                              delay:0
                            options:UIViewAnimationOptionAllowUserInteraction
                          animation:^{
            CGRect targetBounds = self.scrollView.bounds;
            targetBounds.origin.x += 30;
            self.scrollView.bounds = targetBounds;
        } completion:^(BOOL finished) {
            if (finished) {
                [UIView animateWithDuration:0.28
                       customTimingFunction:CustomTimingFunctionQuadraticEasyOut
                                      delay:0.05
                                    options:UIViewAnimationOptionAllowUserInteraction|UIViewAnimationOptionBeginFromCurrentState
                                  animation:^{
                                      self.scrollView.layer.bounds = self.originalBounds;
                                  } completion:^(BOOL finished) {
                                      if (finished) {
                                          self.animationInteration++;
                                          if (self.animationInteration < 2) {
                                              dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.6 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                                  [self _startAnimaiton];
                                              });
                                          } else {
                                              [self stopAnimation];
                                          }
                                      }
                                  }];

            }
        }];
    });
}

- (void)stopAnimation
{
    [self.arrowImageView removeFromSuperview];
    self.arrowImageView = nil;
    [self.scrollView.layer removeAllAnimations];
}

@end
