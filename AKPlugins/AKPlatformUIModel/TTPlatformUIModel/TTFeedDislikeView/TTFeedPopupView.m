//
//  ExplorePopupView.m
//  Article
//
//  Created by Chen Hong on 14/11/19.
//
//

#import "TTFeedPopupView.h"
#import "SSThemed.h"

#define RGB(r, g, b)    [UIColor colorWithRed:(r)/255.f green:(g)/255.f blue:(b)/255.f alpha:1.f]
#define kCornerRadius 4.f

@implementation TTFeedPopupView

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.borderColor = RGB(200, 199, 204);
        self.fillColor = RGB(245, 245, 245);
        self.backgroundColor = [UIColor clearColor];
        self.layer.cornerRadius = kCornerRadius;
        self.layer.masksToBounds = YES;
        self.clipsToBounds = YES;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(statusBarFrameOrOrientationChanged:) name:UIApplicationWillChangeStatusBarOrientationNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(statusBarFrameOrOrientationChanged:) name:UIApplicationWillChangeStatusBarFrameNotification object:nil];
    }
    return self;
}

- (CGRect)getViewFrame {
    CGRect frame = self.frame;
    if (_arrowDirection == TTFeedPopupViewArrowUp) {
        frame.origin.y = _arrowPoint.y;
    } else if (_arrowDirection == TTFeedPopupViewArrowDown) {
        frame.origin.y = _arrowPoint.y - frame.size.height;
    }
    return frame;
}

- (void)showAtPoint:(CGPoint)p direction:(TTFeedPopupViewArrowDirection)dir {
    self.maskView = [UIButton buttonWithType:UIButtonTypeCustom];
    _maskView.frame = [UIScreen mainScreen].bounds;
    _maskView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.3];
    [_maskView addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
    [_maskView addSubview:self];
    
    UIWindow *window = SSGetMainWindow();//[UIApplication sharedApplication].keyWindow;
    [window addSubview:_maskView];
    
    _arrowPoint = p;
    _arrowDirection = dir;
    self.frame = [self getViewFrame];
    
    CGPoint arrowPoint = [self convertPoint:p fromView:window];
    
    CGRect frame = self.frame;
    if (self.frame.size.width > 0 && self.frame.size.height > 0) {
        self.layer.anchorPoint = CGPointMake(arrowPoint.x / self.frame.size.width, arrowPoint.y / self.frame.size.height);
    }
    self.frame = frame;
    
    [self refreshUI];
    
    self.alpha = 0.f;
    _maskView.alpha = 0.f;
    self.transform = CGAffineTransformMakeScale(0.1f, 0.1f);
    [UIView animateWithDuration:0.2f delay:0.f options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.transform = CGAffineTransformMakeScale(1.05f, 1.05f);
        self.alpha = 1.f;
        _maskView.alpha = 1.f;
    } completion:^(BOOL finished) {
        self.alpha = 1.f;
        [UIView animateWithDuration:0.08f delay:0.f options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.transform = CGAffineTransformIdentity;
        } completion:nil];
    }];
}

- (void)viewWillDisappear {
    
}

- (void)dismiss {
    [self dismiss:YES];
}

- (void)dismiss:(BOOL)animated {
    [self viewWillDisappear];
    
    if (!animated) {
        [_maskView removeFromSuperview];
        _maskView = nil;
        return;
    }
    
    [UIView animateWithDuration:0.3f animations:^{
        _maskView.alpha = 0.f;
    } completion:^(BOOL finished) {
        [_maskView removeFromSuperview];
        self.maskView = nil;
    }];
}

- (void)refreshUI {
    // 子类override
}

- (void)statusBarFrameOrOrientationChanged:(NSNotification *)notification
{
    [self dismiss:NO];
}

@end
