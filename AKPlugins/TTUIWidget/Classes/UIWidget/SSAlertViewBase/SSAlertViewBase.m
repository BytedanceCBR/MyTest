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
        [aimSuperView addSubview:self];
        [aimSuperView bringSubviewToFront:self];
    }
    
    [UIView animateWithDuration:0.25 animations:^{
        self.backgroundColor = [UIColor colorWithHexString:@"00000066"];
        _contentBaseView.origin = CGPointMake(0, 0);
    }];
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
    
    [UIView animateWithDuration:0.25 animations:^{
        self.backgroundColor = [UIColor colorWithHexString:@"00000066"];
        _contentBaseView.origin = CGPointMake(0, 0);
    }];
}

- (void)dismissWithAnimation:(BOOL)animation
{
    if (animation) {
        [UIView animateWithDuration:0.25 animations:^{
            [self _dismiss];
        } completion:^(BOOL finished) {
            [self dismissDone];
            [self removeFromSuperview];
        }];
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
