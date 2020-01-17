//
//  SSAlertViewBase.m
//  Article
//
//  Created by Zhang Leonardo on 13-3-7.
//
//

#import "SSAlertViewBase.h"
#import "UIColor+TTThemeExtension.h"
#import <Masonry/Masonry.h>
#import "TTUIResponderHelper.h"
#import "UIViewAdditions.h"
#import "UIView+CustomTimingFunction.h"

@interface SSAlertViewBase()

@end

@implementation SSAlertViewBase

- (void)dealloc
{
    self.contentBaseView = nil;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.contentBaseView = [[UIView alloc] init];
        _contentBaseView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        [self addSubview:_contentBaseView];
        [_contentBaseView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
    }
    return self;
}

- (void)showOnWindow:(UIWindow *)window
{
    _contentBaseView.origin = CGPointMake(0, [TTUIResponderHelper screenSize].height);
    self.backgroundColor = [UIColor clearColor];
    
    if(![self superview])
    {
        UIViewController *aimVC = window.rootViewController;
        BOOL hasPresent = NO;
        while (aimVC.presentedViewController) {
            hasPresent = YES;
            aimVC = aimVC.presentedViewController;
        }
        UIView *aimSuperView = (hasPresent && aimVC.view.superview) ? aimVC.view.superview : aimVC.view;
        self.frame = aimSuperView.bounds;
        self.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
        [aimSuperView addSubview:self];
        [aimSuperView bringSubviewToFront:self];
    }
    

    [CATransaction begin];
    [CATransaction setAnimationTimingFunction:[CAMediaTimingFunction functionWithControlPoints:0.22:1: 0.36: 1]];
    [UIView animateWithDuration:0.45 delay:0 options:0 animations:^{
        self.backgroundColor = [UIColor colorWithHexString:@"00000066"];
        _contentBaseView.origin = CGPointMake(0, 0);
    } completion:nil];
    [CATransaction commit];
}

- (void)showOnViewController:(UIViewController *)controller
{
    _contentBaseView.origin = CGPointMake(0, [TTUIResponderHelper screenSize].height);
    self.backgroundColor = [UIColor clearColor];
    
    if(![self superview])
    {
        [controller.view addSubview:self];
        [controller.view bringSubviewToFront:self];
    }


    [CATransaction begin];
    [CATransaction setAnimationTimingFunction:[CAMediaTimingFunction functionWithControlPoints:0.22:1: 0.36: 1]];
    [UIView animateWithDuration:0.45 delay:0 options:0 animations:^{
        self.backgroundColor = [UIColor colorWithHexString:@"00000066"];
        _contentBaseView.origin = CGPointMake(0, 0);
    } completion:nil];
    [CATransaction commit];
}

- (void)dismissWithAnimation:(BOOL)animation
{
    if (animation) {
        [CATransaction begin];
        [CATransaction setAnimationTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];
        [UIView animateWithDuration:0.8 delay:0 options:0 animations:^{
            [self _dismiss];
        } completion:^(BOOL finished) {
            [self dismissDone];
            [self removeFromSuperview];
        }];
        [CATransaction commit];

    }
    else {
        [self _dismiss];
        [self removeFromSuperview];//
        [self dismissDone];
    }
}

- (void)_dismiss
{
    _contentBaseView.origin = CGPointMake(0, [TTUIResponderHelper screenSize].height);
    self.backgroundColor = [UIColor clearColor];
//    [self removeFromSuperview];
}

- (void)dismissDone
{
    //subview implement
}

@end
