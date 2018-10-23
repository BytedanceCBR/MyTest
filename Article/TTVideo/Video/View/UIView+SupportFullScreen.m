//
//  UIView+SupportFullScreen.m
//  Article
//
//  Created by lishuangyang on 2017/7/7.
//
//
#import "ExploreMovieView.h"
#import <Aspects/Aspects.h>
#import "UIView+SupportFullScreen.h"
#import "TTDeviceHelper.h"

@implementation UIView (supportFullScreen)

static CGRect originalFrame;
- (void)addTransFormIsFullScreen:(BOOL)isFullScreen
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(movieViewFullScreenDidChange:) name:kExploreMovieViewDidChangeFullScreenNotifictaion object:nil];
    
    originalFrame = self.frame;
    BOOL isMovieFullScreen = isFullScreen;
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    if (isMovieFullScreen) {
        self.transform = [self transformForRotationAngle:orientation];
    } else {
        self.transform = CGAffineTransformIdentity;
    }
    if ([self isKindOfClass:[UIWindow class] ]) {
        UIWindow *backWindow = (UIWindow *)self;
        [backWindow makeKeyAndVisible];
        backWindow.rootViewController.view.frame = backWindow.bounds;
    }
}

- (void)movieViewFullScreenDidChange:(NSNotification *)notification {
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    BOOL isMovieFullScreen = [ExploreMovieView isFullScreen];
    if(!notification.object){
        NSNumber *isfullScreen = [notification.userInfo objectForKey:@"isFullScreen"];
        isMovieFullScreen = isfullScreen.boolValue;
    }
    if (isMovieFullScreen) {
        self.transform = [self transformForRotationAngle:orientation];
    } else {
        self.transform = CGAffineTransformIdentity;
    }
//    [self changeFrameIsFullScreen:isMovieFullScreen];
    if ([self isKindOfClass:[UIWindow class]]) {
        UIWindow *window = (UIWindow *)self;
        window.rootViewController.view.frame = self.bounds;
    }
}

- (CGAffineTransform)transformForRotationAngle:(UIInterfaceOrientation)statusBarOri {
    if (statusBarOri == UIInterfaceOrientationPortrait) {
        return CGAffineTransformIdentity;
    } else if (statusBarOri == UIInterfaceOrientationLandscapeLeft) {
        return CGAffineTransformMakeRotation(-M_PI_2);
    } else if (statusBarOri == UIInterfaceOrientationLandscapeRight) {
        return CGAffineTransformMakeRotation(M_PI_2);
    }
    return CGAffineTransformIdentity;
}

+ (UIView *)defaultParentView
{
    UIView *window = nil;
    if ([[[UIApplication sharedApplication] delegate] respondsToSelector:@selector(window)]) {
        window = [[[UIApplication sharedApplication] delegate] window];
    }
    
    if ([[UIApplication sharedApplication] keyWindow]) {
        window = [[UIApplication sharedApplication] keyWindow];
    }
    return window;
}

- (void)changeFrameIsFullScreen:(BOOL)isFullScreen{
    
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    if (orientation == UIInterfaceOrientationPortrait) {
        self.frame = originalFrame;
    }else if (isFullScreen){
        self.size = CGSizeMake([[self class] defaultParentView].size.height,[[self class] defaultParentView].size.width);
        self.center = CGPointMake([self.class defaultParentView].width/2, [self.class defaultParentView].height/2);
    }
}

@end
