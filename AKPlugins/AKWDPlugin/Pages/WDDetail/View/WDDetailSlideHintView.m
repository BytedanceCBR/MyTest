//
//  WDDetailSlideHintView.m
//  Article
//
//  Created by wangqi.kaisa on 2017/6/26.
//
//

#import "WDDetailSlideHintView.h"
#import "UIView+CustomTimingFunction.h"
#import "WDLayoutHelper.h"
#import <TTPlatformBaseLib/TTTrackerWrapper.h>

@interface WDDetailSlideHintView ()

@property (nonatomic, strong) SSThemedView *containerView;
@property (nonatomic, strong) SSThemedImageView *arrowImageView;
@property (nonatomic, strong) SSThemedImageView *handImageView;
@property (nonatomic, strong) SSThemedLabel *slideHintLabel;
@property (nonatomic, strong) SSThemedView *transparentView; // 用于处理交互
@property (nonatomic, assign) BOOL isDismissing;

@end

@implementation WDDetailSlideHintView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.alpha = 0;
        self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
    }
    return self;
}

- (void)setSlideHintViewIfNeeded {
    [self addSubviews];
    [self adjustSubviewsPosition];
    [self startAnimation];
    [TTTrackerWrapper eventV3:@"slide_answer_hint_show" params:nil];
}

- (void)addSubviews {
    [self addSubview:self.containerView];
    [self.containerView addSubview:self.arrowImageView];
    [self.containerView addSubview:self.slideHintLabel];
    [self.containerView addSubview:self.handImageView];
    [self addSubview:self.transparentView];
    [self addGestureRecognizer];
}

- (void)adjustSubviewsPosition {
    self.handImageView.frame = CGRectMake(32, 30, 72, 100);
    self.arrowImageView.frame = CGRectMake(15, 0, 110, 24);
    self.slideHintLabel.frame = CGRectMake(0, 139, 139, 24);
    self.containerView.bounds = CGRectMake(0, 0, 139, 163);
    self.containerView.center = self.center;
}

- (void)addGestureRecognizer {
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureTrigger)];
    [self.transparentView addGestureRecognizer:tap];
    
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureTrigger:)];
    [self.transparentView addGestureRecognizer:pan];
}

- (void)startAnimation {
    [UIView animateWithDuration:0.12f delay:0.f options:UIViewAnimationOptionCurveLinear animations:^{
        self.alpha = 1;
    } completion:^(BOOL finished) {
    }];
    // after 2.4
    [self performSelector:@selector(dismissSelfIfAuto:) withObject:@(1) afterDelay:2.4f];
    [self animateHandHorizontallyWithFadeOut:YES];
    // after 1.2
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self animateHandHorizontallyWithFadeOut:NO];
    });
}

- (void)tapGestureTrigger {
    [self performSelector:@selector(dismissSelfIfAuto:) withObject:@(0) afterDelay:0.3];
}

- (void)panGestureTrigger:(UIPanGestureRecognizer *)gesture {
    
    switch (gesture.state) {
        case UIGestureRecognizerStateBegan:
        {
        }
            break;
        case UIGestureRecognizerStateChanged:
        {
            [self commitTranslation:[gesture translationInView:self]];
        }
            break;
        case UIGestureRecognizerStateEnded:
        {
        }
            break;
        case UIGestureRecognizerStateCancelled:
        {
        }
            break;
        default:
            break;
    }
    
}

- (void)commitTranslation:(CGPoint)translation {
    CGFloat absX = fabs(translation.x);
    CGFloat absY = fabs(translation.y);
    
    // 设置滑动有效距离
    if (MAX(absX, absY) < 10)
        return;
    
    if (absX > absY ) {
        
        if (translation.x<0) {
            //向左滑动
            if (self.delegate && [self.delegate respondsToSelector:@selector(wdDetailSlideHintViewSlideTrigger)]) {
                [self.delegate wdDetailSlideHintViewSlideTrigger];
            }
        }else{
            //向右滑动
        }
        
    } else if (absY > absX) {
        if (translation.y<0) {
            //向上滑动
        }else{
            //向下滑动
        }
    }
    
    [self performSelector:@selector(dismissSelfIfAuto:) withObject:@(0) afterDelay:0.3];
    
}

- (void)dismissSelfIfAuto:(NSNumber *)iaAuto {
    if (self.isDismissing) {
        return;
    }
    self.isDismissing = YES;
    [self dismissSelf];
    
    NSString *closeType = iaAuto.boolValue ? @"auto" : @"manual";
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setValue:closeType forKey:@"close_type"];
    [TTTrackerWrapper eventV3:@"slide_answer_hint_close" params:dict];
}

- (void)dismissSelf {
    [UIView animateWithDuration:0.12f delay:0.f options:UIViewAnimationOptionCurveLinear animations:^{
        self.alpha = 0;
    } completion:^(BOOL finished) {
        [self notifyDelegate];
        [self removeFromSuperview];
    }];
}

- (void)notifyDelegate {
    if (self.delegate && [self.delegate respondsToSelector:@selector(wdDetailSlideHintViewWillDismiss)]) {
        [self.delegate wdDetailSlideHintViewWillDismiss];
    }
}

#pragma mark - Animation

- (void)animateHandHorizontallyWithFadeOut:(BOOL)fadeOut {
    CGAffineTransform transform = CGAffineTransformMakeTranslation(20, 0);
    transform = CGAffineTransformRotate(transform, 20. / 180 * M_PI);
    self.handImageView.transform = transform;
    self.handImageView.alpha = 0;
    
    [UIView animateWithDuration:1
           customTimingFunction:CustomTimingFunctionQuadOut
                          delay:0
                        options:0
                      animation:^{
                          CGAffineTransform transform = CGAffineTransformMakeTranslation(-20, 0);
                          transform = CGAffineTransformRotate(transform, -20. / 180 * M_PI);
                          self.handImageView.transform = transform;
                      } completion:nil];
    
    [self animateHandOpicityWithFadeOut:fadeOut];
}

- (void)animateHandOpicityWithFadeOut:(BOOL)fadeOut {
    [UIView animateWithDuration:0.12
           customTimingFunction:CustomTimingFunctionLinear
                          delay:0
                        options:0
                      animation:^{
                          self.handImageView.alpha = 1;
                      } completion:^(BOOL finished) {
                          if (fadeOut) {
                              [UIView animateWithDuration:0.12
                                     customTimingFunction:CustomTimingFunctionLinear
                                                    delay:0.88
                                                  options:0
                                                animation:^{
                                                    self.handImageView.alpha = 0;
                                                } completion:nil];
                          }
                      }];
}

#pragma mark - Get

- (SSThemedView *)containerView {
    if (!_containerView) {
        _containerView = [[SSThemedView alloc] initWithFrame:self.bounds];
        _containerView.backgroundColor = [UIColor clearColor];
    }
    return _containerView;
}

- (SSThemedLabel *)slideHintLabel {
    if (!_slideHintLabel) {
        SSThemedLabel *titleLabel = [[SSThemedLabel alloc] initWithFrame:CGRectZero];
        titleLabel.textColorThemeKey = kColorText12;
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.font = [UIFont boldSystemFontOfSize:17.0];
        titleLabel.backgroundColor = [UIColor clearColor];
        NSShadow *shadow = [[NSShadow alloc]init];
        shadow.shadowBlurRadius = 0.5;
        shadow.shadowOffset = CGSizeMake(0, 1);
        shadow.shadowColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
        NSMutableAttributedString *attributedString = [WDLayoutHelper attributedStringWithString:@"滑动看下一个回答" fontSize:17 isBoldFont:YES lineHeight:24];
        [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor tt_themedColorForKey:kColorText12] range:NSMakeRange(0, [attributedString.string length])];
        [attributedString addAttribute:NSShadowAttributeName value:shadow range:NSMakeRange(0, [attributedString.string length])];
        titleLabel.attributedText = attributedString;
        titleLabel.layer.shadowColor = [[UIColor colorWithRed:0 green:0 blue:0 alpha:0.5] CGColor];
        titleLabel.layer.shadowRadius = 0.5;
        titleLabel.layer.shadowOpacity = 0.5;
        titleLabel.layer.shadowOffset = CGSizeMake(0, -1);
        _slideHintLabel = titleLabel;
    }
    return _slideHintLabel;
}

- (SSThemedImageView *)arrowImageView {
    if (!_arrowImageView) {
        _arrowImageView = [[SSThemedImageView alloc] init];
        _arrowImageView.imageName = @"details_slide_arrow_ask";
    }
    return _arrowImageView;
}

- (SSThemedImageView *)handImageView {
    if (!_handImageView) {
        _handImageView = [[SSThemedImageView alloc] init];
        _handImageView.imageName = @"details_slide_hand_ask";
        _handImageView.alpha = 0.0;
        _handImageView.layer.anchorPoint = CGPointMake(0.5, 1);
    }
    return _handImageView;
}

- (SSThemedView *)transparentView {
    if (!_transparentView) {
        _transparentView = [[SSThemedView alloc] initWithFrame:self.bounds];
        _transparentView.backgroundColor = [UIColor clearColor];
    }
    return _transparentView;
}

@end
