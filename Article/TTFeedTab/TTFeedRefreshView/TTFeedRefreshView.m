//
//  TTFeedRefreshView.m
//  Article
//
//  Created by matrixzk on 15/9/2.
//
//

#import "TTFeedRefreshView.h"
#import "TTAlphaThemedButton.h"
#import "TTDeviceHelper.h"


@interface TTFeedRefreshView ()
@property (nonatomic, strong, readwrite) TTAlphaThemedButton *arrowBtn;
@property (nonatomic, assign, readwrite) CGFloat             originAlpha;
@end

@implementation TTFeedRefreshView

- (id)init
{
    CGFloat side = [TTDeviceHelper isPadDevice] ? 60 : 50;
    self = [super initWithFrame:CGRectMake(0, 0, side, side)];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
        
        UIImageView *bgImageView = [[UIImageView alloc] initWithFrame:self.bounds];
        [self addSubview:bgImageView];
        
        _arrowBtn = [TTAlphaThemedButton buttonWithType:UIButtonTypeCustom];
        _arrowBtn.frame = self.bounds;
        _arrowBtn.imageName = @"feed_refresh";
        _arrowBtn.contentMode = UIViewContentModeCenter;
        [self addSubview:_arrowBtn];
        
        // self.alpha = 0.7f;
        _originAlpha = self.alpha;
    }
    return self;
}

- (void)startLoading
{
    CABasicAnimation *rotationAnimation;
    rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.toValue = [NSNumber numberWithFloat: M_PI * 2.0];
    rotationAnimation.duration = 1.0f;
    rotationAnimation.cumulative = YES;
    rotationAnimation.repeatCount = 10000.0f;
    [self.arrowBtn.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
}

- (void)endLoading
{
    [self.arrowBtn.layer removeAllAnimations];
    self.arrowBtn.transform = CGAffineTransformIdentity;
}

- (void)resetFrameWithSuperviewFrame:(CGRect)superViewFrame
                         bottomInset:(CGFloat)bottomInset
{
    CGFloat widthOfSuperview = superViewFrame.size.width;
    CGFloat widthRightMargin = 8;
    CGFloat heightRightMargin = 8;
    if ([TTDeviceHelper isPadDevice]) {
        BOOL isSpliScreenState = [UIScreen mainScreen].bounds.size.width > widthOfSuperview;
        if (isSpliScreenState) {
            widthRightMargin = [TTUIResponderHelper paddingForViewWidth:widthOfSuperview];
            heightRightMargin = 20;
        } else {
            widthRightMargin = UIDeviceOrientationIsLandscape([UIDevice currentDevice].orientation) ? 37 : 30;
            heightRightMargin = 30;
        }
    }
    
    self.center = CGPointMake(widthOfSuperview - self.frame.size.width/2 - widthRightMargin, superViewFrame.size.height - self.frame.size.height/2 - bottomInset - heightRightMargin);
}

@end
