//
//  ExploreMovieLoadingView.m
//  Article
//
//  Created by Chen Hong on 15/9/21.
//
//

#import "ExploreMovieLoadingView.h"
#import "UIColor+TTThemeExtension.h"
#import "TTThemeConst.h"

@interface ExploreMovieLoadingView()<CAAnimationDelegate>
{
    UIImageView *_loadingImageView;
    CABasicAnimation *rotateAnimation;
}
@end

//loading_video_float
@implementation ExploreMovieLoadingView

- (void)dealloc
{
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self onInit];
    }
    return self;
}

- (instancetype)init
{
    self = [self initWithFrame:CGRectZero];
    if (self) {
    }
    return self;
}

- (void)onInit
{
    self.backgroundColor = [UIColor clearColor];
    _loadingImageView = [[UIImageView alloc] init];
    _loadingImageView.backgroundColor = [UIColor clearColor];
    [self addSubview:_loadingImageView];
    self.isFullScreen = NO;
}

- (void)startAnimating {
//    NSLog(@"startAnimating");
    CALayer *presentationLayer = nil;
    if (rotateAnimation) {
        presentationLayer = (CALayer *)_loadingImageView.layer.presentationLayer;
    }
    [_loadingImageView.layer removeAllAnimations];
    rotateAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    if (presentationLayer) {//动画中断后,继续从上一次中断点开始动画
        rotateAnimation.duration = 1.0f;
        rotateAnimation.repeatCount = HUGE_VAL;
        rotateAnimation.fromValue = [NSNumber numberWithDouble:presentationLayer.transform.m43];
        rotateAnimation.toValue = @(M_PI * 2);
    }
    else
    {
        rotateAnimation.duration = 1.0f;
        rotateAnimation.repeatCount = 1000000;
        rotateAnimation.toValue = @(M_PI * 2);
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [_loadingImageView.layer addAnimation:rotateAnimation forKey:@"rotateAnimation"];
    });
}

- (void)stopAnimating {
//    NSLog(@"stopAnimating");
    [_loadingImageView.layer removeAllAnimations];
}

- (void)setIsFullScreen:(BOOL)isFullScreen
{
    _isFullScreen = isFullScreen;
    if (isFullScreen) {
        _loadingImageView.image = [UIImage imageNamed:@"video_fullLoading"];
        [_loadingImageView sizeToFit];
    }
    else
    {
        _loadingImageView.image = [UIImage imageNamed:@"video_loading"];
        [_loadingImageView sizeToFit];
    }
    self.bounds = CGRectMake(0, 0, _loadingImageView.frame.size.width, _loadingImageView.frame.size.height);
}
@end
