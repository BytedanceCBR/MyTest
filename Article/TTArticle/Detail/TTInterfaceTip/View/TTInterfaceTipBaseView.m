//
//  TTInterfaceTipBaseView.m
//  Article
//
//  Created by chenjiesheng on 2017/6/23.
//
//

#import "TTInterfaceTipBaseView.h"
#import "TTInterfaceTipBaseModel.h"
#import <UIViewAdditions.h>

@interface TTInterfaceTipBaseView ()

@property (nonatomic, strong, readwrite)TTInterfaceTipBaseModel *model;
@property (nonatomic, strong, readwrite)NSTimer *timer;
@property (nonatomic, weak, readwrite)TTInterfaceTipManager *manager;
@end

@implementation TTInterfaceTipBaseView

- (void)dealloc
{
    
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.borderColorThemeKey = kColorLine7Highlighted;
        self.layer.borderWidth = 0.5f;
        self.backgroundColors = @[@"ffffff",@"1b1b1b"];
        self.layer.shadowColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:.3f].CGColor;
        self.layer.shadowOffset = CGSizeMake(0.f, 2.f);
        self.layer.shadowRadius = 6.f;
        self.layer.shadowOpacity = 1.f;
        if ([self needTimer]){
            _timer = [NSTimer scheduledTimerWithTimeInterval:[self timerDuration] target:self selector:@selector(timerAction:) userInfo:nil repeats:NO];
            [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
        }
    }
    return self;
}

- (void)setupViewWithModel:(TTInterfaceTipBaseModel *)model
{
    _model = model;
    _manager = model.manager;
}

- (CGFloat)heightForView
{
    return CGRectGetHeight([UIScreen mainScreen].bounds);
}

- (CGFloat)widthForView
{
    return CGRectGetWidth([UIScreen mainScreen].bounds);
}

- (CGFloat)bottomPadding
{
    return 0;
}

- (CGFloat)topPadding
{
    return 0;
}

- (TTInterfaceTipViewType)viewType
{
    return TTInterfaceTipViewTypeSheet;
}

- (BOOL)needDimBackground
{
    return NO;
}

- (BOOL)needBlockTouchInBlankView
{
    return NO;
}

- (BOOL)needTimer
{
    return YES;
}

- (CGFloat)timerDuration
{
    return 6;
}

- (CGFloat)restartTimerDuration{
    return 6;
}

- (void)show
{
    UIView *superView = self.superview;
    CGFloat height = [self heightForView];
    CGFloat width = [self widthForView];
    UIView *dimBackgroundView = nil;
    if (self.needDimBackground) {
        dimBackgroundView = self.manager.backgroundView;
    }
    TTInterfaceTipViewType viewType = [self viewType];
    switch (viewType) {
        case TTInterfaceTipViewTypeSheet:
        {
            self.frame = CGRectMake((superView.width - width) / 2, superView.bottom, width, height);
            if (self.panGestureDirection == TTInterfaceTipsMoveDirectionUp){
                self.bottom = superView.top;
            }
            if ([self needDimBackground]){
                dimBackgroundView.alpha = 0;
            }
            [UIView animateWithDuration:kTTInterfaceTipViewSpringDuration delay:0 usingSpringWithDamping:kTTInterfaceTipViewSpringDampingRatio initialSpringVelocity:kTTInterfaceTipViewSpringVelocity options:0 animations:^{
                if ([self needDimBackground]){
                    dimBackgroundView.alpha = 1;
                }
                if (self.panGestureDirection == TTInterfaceTipsMoveDirectionDown){
                    self.bottom = superView.bottom - [self bottomPadding] - _model.bottomHeight.floatValue;
                }else if (self.panGestureDirection == TTInterfaceTipsMoveDirectionUp){
                    self.top = superView.top - [self topPadding] - _model.topHeight.floatValue;
                }
            } completion:nil];
        }
            break;
        case TTInterfaceTipViewTypeAlert:
        {
            self.size = CGSizeMake(width, height);
            self.center = CGPointMake(superView.width / 2, superView.height / 2);
            if ([self needDimBackground]){
                dimBackgroundView.alpha = 0;
            }
            self.transform = CGAffineTransformMakeScale(.01, .01);
            [UIView animateWithDuration:.22 delay:0 usingSpringWithDamping:0.7 initialSpringVelocity:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                if ([self needDimBackground]){
                    dimBackgroundView.alpha = 1;
                }
                self.transform = CGAffineTransformIdentity;
            } completion:^(BOOL finished) {
                
            }];
        }
            break;
        default:
            self.size = CGSizeMake(width, height);
            self.center = CGPointMake(superView.width / 2, superView.height / 2);
            break;
    }
   
}

- (BOOL)needPanGesture
{
    return YES;
}

- (TTInterfaceTipsMoveDirection)panGestureDirection
{
    return TTInterfaceTipsMoveDirectionDown;
}

+ (BOOL)shouldDisplayWithModel:(TTInterfaceTipBaseModel *)model
{
    return YES;
}

- (void)removeFromSuperviewByGesture
{
    
}

- (void)removeFromSuperViewByTimer
{
    
}

- (void)hideByTipWithHigherPriority
{
    [self dismissSelfWithAnimation:@NO];
}

- (void)blankGroundViewClickCallBack
{
    
}

- (void)restartTimer
{
    [_timer invalidate];
    _timer = nil;
    _timer = [NSTimer scheduledTimerWithTimeInterval:[self restartTimerDuration] target:self selector:@selector(timerAction:) userInfo:nil repeats:NO];
    [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
}

- (void)clearTimer
{
    [_timer invalidate];
    _timer = nil;
}

- (void)selectedTabChangeWithCurrentIndex:(NSUInteger)current lastIndex:(NSUInteger)last isUGCPostEntrance:(BOOL)isPostEntrance;
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self dismissSelfWithAnimation:@YES];
    });
}

- (void)topVCChange
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self dismissSelfWithAnimation:@YES];
    });
}

- (void)enterBackground
{
    [self dismissSelfWithAnimation:@NO];
}

- (void)dismissSelfWithAnimation:(NSNumber *)animate
{
    [self.manager dismissViewWithDefaultAnimation:animate withView:self];
}
#pragma mark -- private

- (void)timerAction:(NSTimer *)timer
{
    if (_panGestureRun){
        return ;
    }
    [self removeFromSuperViewByTimer];
    [self dismissSelfWithAnimation:@YES];
}

#pragma mark -- Setter & Getter

- (void)setPanGestureRun:(BOOL)panGestureRun{
    _panGestureRun = panGestureRun;
    if (_panGestureRun == NO && [_timer isValid] == NO){
        [self removeFromSuperviewByGesture];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self dismissSelfWithAnimation:@YES];
        });
    }
}

@end
