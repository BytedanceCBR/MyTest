//
//  TTMovieLandscapeViewController.m
//  Article
//
//  Created by 徐霜晴 on 16/9/23.
//
//

#import "TTMovieFullscreenViewController.h"


@interface TTMovieFullscreenViewController ()

@property (nonatomic, assign) UIInterfaceOrientation orientationBeforePresented;
@property (nonatomic, assign) UIInterfaceOrientation orientationAfterPresented;
@property (nonatomic, assign) UIInterfaceOrientationMask supportedOrientations;

@end

@implementation TTMovieFullscreenViewController

- (instancetype)initWithOrientationBeforePresented:(UIInterfaceOrientation)orientationBeforePresented
                         orientationAfterPresented:(UIInterfaceOrientation)orientationAfterPresented
                             supportedOrientations:(UIInterfaceOrientationMask)supportedOrientations {
    self = [super init];
    if (self) {
        self.orientationBeforePresented = orientationBeforePresented;
        self.orientationAfterPresented = orientationAfterPresented;
        self.supportedOrientations = supportedOrientations;
    }
    return self;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    if (self.isBeingPresented) {
        switch (self.orientationAfterPresented) {
            case UIInterfaceOrientationLandscapeLeft:
                return UIInterfaceOrientationMaskLandscapeLeft;
            case UIInterfaceOrientationLandscapeRight:
                return UIInterfaceOrientationMaskLandscapeRight;
            case UIInterfaceOrientationPortrait:
                return UIInterfaceOrientationMaskPortrait;
            case UIInterfaceOrientationPortraitUpsideDown:
                return UIInterfaceOrientationMaskPortraitUpsideDown;
            default:
                return UIInterfaceOrientationMaskPortrait;
        }
    }
    return self.supportedOrientations;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    if (self.delegate && [self.delegate respondsToSelector:@selector(movieFullscreenVC:willRotateToOrientation:)]) {
        [self.delegate movieFullscreenVC:self willRotateToOrientation:toInterfaceOrientation];
    }
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    if (self.delegate && [self.delegate respondsToSelector:@selector(movieFullscreenVC:didRotateFromOrientation:)]) {
        [self.delegate movieFullscreenVC:self didRotateFromOrientation:fromInterfaceOrientation];
    }
}

+ (CGFloat)rotationRadianForInterfaceOrienationIniOS7:(UIInterfaceOrientation)interfaceOrientation {
    switch (interfaceOrientation) {
        case UIInterfaceOrientationPortrait:
            return 0.0;
        case UIInterfaceOrientationPortraitUpsideDown:
            return M_PI;
        case UIInterfaceOrientationLandscapeLeft:
            return -M_PI_2;
        case UIInterfaceOrientationLandscapeRight:
            return M_PI_2;
        default:
            return 0.0;
    }
}

+ (CGRect)windowBoundsForInterfaceOrientationIniOS7:(UIInterfaceOrientation)interfaceOrientation {
    UIWindow *window = [TTUIResponderHelper mainWindow];
    CGSize windowSize = window.bounds.size;
    switch (interfaceOrientation) {
        case UIInterfaceOrientationLandscapeRight:
        case UIInterfaceOrientationLandscapeLeft:
            return CGRectMake(0, 0, windowSize.height, windowSize.width);
        case UIInterfaceOrientationPortrait:
        case UIInterfaceOrientationPortraitUpsideDown:
        default:
            return CGRectMake(0, 0, windowSize.width, windowSize.height);
    }
}

@end
