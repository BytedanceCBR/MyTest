//
//  AWEVideoDetailFirstUsePromptTypeBViewController.m
//  Pods
//
//  Created by Zuyang Kou on 02/08/2017.
//
//

#import "AWEVideoDetailSwipePromptAnimationViewController.h"
#import "UIView+CustomTimingFunction.h"
#import <TTBaseLib/UIViewAdditions.h>

@interface AWEVideoDetailSwipePromptAnimationViewController ()

@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) UIImageView *arrowImageView;
@property (nonatomic, strong) UIImageView *handImageView;
@property (nonatomic, strong) UILabel *label;
@property (nonatomic, strong) NSString *text;

@end

static CGFloat alphaThatTransparentButTouchable = 0.02;

@implementation AWEVideoDetailSwipePromptAnimationViewController
@synthesize dismissCompleteBlock;

- (instancetype)initWithText:(NSString *)text
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        _text = text;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];

    self.containerView = [[UIView alloc] init];
    [self.view addSubview:self.containerView];

    self.arrowImageView = [[UIImageView alloc] init];
    switch (self.direction) {
        case AWEPromotionDiretionLeft:
        case AWEPromotionDiretionLeftEnterProfile:
            self.arrowImageView.image = [UIImage imageNamed:@"hts_left_arrow_indicator2"];
            break;
        case AWEPromotionDiretionUpVideoSwitch:
        case AWEPromotionDiretionUpFloatingViewPop:
            self.arrowImageView.image = [UIImage imageNamed:@"hts_up_arrow_indicator2"];
            break;
    }
    [self.containerView addSubview:self.arrowImageView];

    self.handImageView = [[UIImageView alloc] init];
    switch (self.direction) {
        case AWEPromotionDiretionLeft:
        case AWEPromotionDiretionLeftEnterProfile:
            self.handImageView.image = [UIImage imageNamed:@"hts_prompt_hand_horizontal"];
            break;
        case AWEPromotionDiretionUpVideoSwitch:
        case AWEPromotionDiretionUpFloatingViewPop:
            self.handImageView.image = [UIImage imageNamed:@"hts_prompt_hand_vertical"];
            break;
    }
    [self.containerView addSubview:self.handImageView];

    self.label = [[UILabel alloc] init];
    if (self.text) {
        self.label.text = self.text;
    } else {
        self.label.text = @"滑动查看更多视频";
    }
    self.label.textAlignment = NSTextAlignmentCenter;
    self.label.font = [UIFont systemFontOfSize:17];
    self.label.textColor = [UIColor whiteColor];
    [self.containerView addSubview:self.label];

    self.view.alpha = alphaThatTransparentButTouchable;
    self.handImageView.alpha = 0;
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];

    switch (self.direction) {
        case AWEPromotionDiretionLeft:
        case AWEPromotionDiretionLeftEnterProfile:
            self.handImageView.layer.anchorPoint = CGPointMake(0.5, 1);
            self.handImageView.frame = CGRectMake(32, 30, 72, 100);
            self.arrowImageView.frame = CGRectMake(15, 0, 110, 24);
            self.label.frame = CGRectMake(0, 139, 139, 24);
            self.containerView.bounds = CGRectMake(0, 0, 139, 163);
            self.containerView.center = self.view.center;

            break;
        case AWEPromotionDiretionUpVideoSwitch:
            self.handImageView.layer.anchorPoint = CGPointMake(1, 1);
            self.handImageView.frame = CGRectMake(40, 67, 103, 81);
            self.arrowImageView.frame = CGRectMake(26, 0, 24, 111);
            self.label.frame = CGRectMake(0, 141, 175, 24);
            self.containerView.bounds = CGRectMake(0, 0, 175, 165);
            self.containerView.center = self.view.center;
            break;
        case AWEPromotionDiretionUpFloatingViewPop:
            self.handImageView.layer.anchorPoint = CGPointMake(1, 1);
            self.handImageView.frame = CGRectMake(40, 67, 103, 81);
            self.arrowImageView.frame = CGRectMake(26, 0, 24, 111);
            self.label.frame = CGRectMake(0, 141, 175, 24);
            self.containerView.bounds = CGRectMake(0, 0, 175, 165);
            self.containerView.center = self.view.center;
            self.containerView.bottom = self.view.height - 148;
    }
}

- (void)animateHandHorizontallyWithFadeOut:(BOOL)fadeOut
{
    CGAffineTransform transform = CGAffineTransformMakeTranslation(20, 0);
    transform = CGAffineTransformRotate(transform, 20. / 180 * M_PI);
    self.handImageView.transform = transform;
    self.handImageView.alpha = 0;

    [UIView animateWithDuration:1
           customTimingFunction:CustomTimingFunctionQuadOut
                          delay:0
                        options:UIViewAnimationOptionAllowUserInteraction
                      animation:^{
                          CGAffineTransform transform = CGAffineTransformMakeTranslation(-20, 0);
                          transform = CGAffineTransformRotate(transform, -20. / 180 * M_PI);
                          self.handImageView.transform = transform;
                      } completion:nil];

    [self animateHandOpicityWithFadeOut:fadeOut];
}

- (void)animateHandVerticallyWithFadeOut:(BOOL)fadeOut
{
    CGAffineTransform transform = CGAffineTransformIdentity;
    transform = CGAffineTransformRotate(transform, -20. / 180 * M_PI);
    self.handImageView.transform = transform;
    self.handImageView.alpha = 0;

    [UIView animateWithDuration:1
           customTimingFunction:CustomTimingFunctionQuadOut
                          delay:0
                        options:UIViewAnimationOptionAllowUserInteraction
                      animation:^{
                          CGAffineTransform transform = CGAffineTransformMakeTranslation(0, -80);
                          transform = CGAffineTransformRotate(transform, 10. / 180 * M_PI);
                          self.handImageView.transform = transform;
                      } completion:nil];

    [self animateHandOpicityWithFadeOut:fadeOut];
}

- (void)animateHandOpicityWithFadeOut:(BOOL)fadeOut
{
    [UIView animateWithDuration:0.12
           customTimingFunction:CustomTimingFunctionLinear
                          delay:0
                        options:UIViewAnimationOptionAllowUserInteraction
                      animation:^{
                          self.handImageView.alpha = 1;
                      } completion:^(BOOL finished) {
                          if (fadeOut) {
                              [UIView animateWithDuration:0.12
                                     customTimingFunction:CustomTimingFunctionLinear
                                                    delay:0.88
                                                  options:UIViewAnimationOptionAllowUserInteraction
                                                animation:^{
                                                    self.handImageView.alpha = 0;
                                                } completion:nil];
                          }
                      }];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    [UIView animateWithDuration:0.12
                          delay:0
                        options:UIViewAnimationOptionAllowUserInteraction|UIViewAnimationCurveLinear
                     animations:^{
                         self.view.alpha = 1;
                     } completion:^(BOOL finished) {
                         [UIView animateWithDuration:0.12
                                               delay:2.68
                                             options:UIViewAnimationOptionAllowUserInteraction|UIViewAnimationCurveLinear
                                          animations:^{
                                              self.view.alpha = alphaThatTransparentButTouchable;
                                          } completion:^(BOOL finished) {
                                              [self dismiss];
                                          }];
                     }];

    switch (self.direction) {
        case AWEPromotionDiretionLeft:
        case AWEPromotionDiretionLeftEnterProfile:
        {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self animateHandHorizontallyWithFadeOut:YES];
            });

            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.6 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self animateHandHorizontallyWithFadeOut:NO];
            });
            break;
        }
        case AWEPromotionDiretionUpVideoSwitch:
        case AWEPromotionDiretionUpFloatingViewPop: {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self animateHandVerticallyWithFadeOut:YES];
            });

            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.6 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self animateHandVerticallyWithFadeOut:NO];
            });
            break;
        }
    }
}

- (void)dismiss
{
    [self willMoveToParentViewController:nil];
    [self.view removeFromSuperview];
    [self removeFromParentViewController];
    
    if (dismissCompleteBlock) {
        dismissCompleteBlock();
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self dismiss];
}

@end
