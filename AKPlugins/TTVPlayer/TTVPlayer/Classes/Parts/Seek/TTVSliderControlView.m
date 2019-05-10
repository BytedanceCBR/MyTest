//
//  TTVSliderControlView.m
//  TTVPlayerPod
//
//  Created by lisa on 2019/4/21.
//

#import "TTVSliderControlView.h"
#import <TTBaseLib/UIViewAdditions.h>
#import "TTVProgressViewOfSlider.h"

#define kThumbViewOutInRatio (20.f / 13.f)

@interface TTVSliderControlView ()


@property (nonatomic, strong) UITapGestureRecognizer *tapGesture;
@property (nonatomic, strong) UIPanGestureRecognizer *panGesture;

@property (nonatomic, assign) CGFloat progressBeforeDragging;

@property (nonatomic, readwrite, getter=isInteractive) BOOL interactive;

@property (nonatomic, assign) CGFloat sliderHeight;
@property (nonatomic, assign) CGFloat thumbViewWidth;
@property (nonatomic, readonly) CGFloat thumbViewBorder;

@end


@implementation TTVSliderControlView

@synthesize progressView = _progressView, thumbView = _thumbView, thumbBackgroundView = _thumbBackgroundView, progress, cacheProgress;
@synthesize didSeekToProgress = _didSeekToProgress, seekingToProgress = _seekingToProgress;

@synthesize thumbColorString = _thumbColorString, thumbBackgroundColorString = _thumbBackgroundColorString;

- (void)dealloc {
    [_panGesture removeTarget:self action:nil];
}

- (instancetype)initWithCustomThumbView:(UIView *)customThumbView {
    self = [self init];
    if (self) {
        if (customThumbView) {
            [self.thumbBackgroundView removeFromSuperview];
            [[self.thumbView viewWithTag:9801] removeFromSuperview];
            self.thumbView = customThumbView;
            [self addSubview:self.thumbView];
        }
    }
    return self;
}

- (instancetype)initWithCustomThumbView:(UIView *)customThumbView
                         thumbViewWidth:(CGFloat)thumbViewWidth
                        thumbViewHeight:(CGFloat)thumbViewHeight
                           sliderHeight:(CGFloat)sliderHeight{
    self = [self initWithCustomThumbView:customThumbView];
    if (self) {
        self.thumbView.frame = CGRectMake(0, 0, thumbViewWidth, thumbViewHeight);
        _sliderHeight = sliderHeight;
        _thumbViewWidth = thumbViewWidth;
    }
    return self;
}
- (instancetype)init {
    self = [super init];
    if (self) {
        _sliderHeight = 2;
        _thumbViewWidth = 13;
        
        [self _buildViewHierarchy];
        [self _buildGestures];
    }
    return self;
}

//- (void)_updateCacheProgress {
////    self. cacheProgressView.width = self.progressView.width * self.cacheProgress;
//    [self setCacheProgress:self.cacheProgress animated:NO];
//}
//
//- (void)_updateTrackProgress {
////    self.trackProgressView.width = self.progressView.width * self.progress;
//    [self setProgress:self.progress animated:NO];
//}

- (void)_updateThumbPosition {
    CGFloat minCenterX = (self.thumbViewWidth - self.thumbViewBorder * 2) / 2;
    CGFloat maxCenterX = self.progressView.width - (self.thumbViewWidth - self.thumbViewBorder * 2) / 2;
    self.thumbView.centerX = [self _maxProgressWidth] * self.progress + minCenterX;
    self.thumbView.centerX = MIN(maxCenterX, MAX(minCenterX, self.thumbView.centerX));

    // 抗锯齿
    self.thumbView.top = floor(self.thumbView.top);
    self.thumbView.left = floor(self.thumbView.left);
    
    self.thumbBackgroundView.center = self.thumbView.center;

}

- (CGFloat)_maxProgressWidth {
    return self.progressView.width - (self.thumbViewWidth - self.thumbViewBorder * 2);
}

#pragma mark -
#pragma mark public methods
- (void)updateThumbViewWidth:(CGFloat)thumbViewWidth thumbViewHeight:(CGFloat)thumbViewHeight sliderHeight:(CGFloat)sliderHeight {
    self.thumbViewWidth = thumbViewWidth;
    self.sliderHeight = sliderHeight;
    
    self.thumbView.width = thumbViewWidth;
    self.thumbView.height = thumbViewHeight;
    self.thumbBackgroundView.width = _thumbViewWidth * kThumbViewOutInRatio;
    self.thumbBackgroundView.height = _thumbViewWidth * kThumbViewOutInRatio;
    
    [self _updateThumbPosition];
    [self setNeedsLayout];
}

- (void)cancelPanGesture {
    if (self.isInteractive && self.panGesture.isEnabled) {
        self.panGesture.enabled = NO;
        self.panGesture.enabled = YES;
    }
}

#pragma mark -
#pragma mark internal methods

- (void)tap:(UITapGestureRecognizer *)tap {
    self.progressBeforeDragging = self.progress;
    
    CGPoint location = [tap locationInView:self];
    CGFloat progress = MAX(0, MIN(1, location.x / self.progressView.width));
    [self setProgress:progress animated:NO];
    
    if (self.didSeekToProgress) {
        self.didSeekToProgress(self.progress, self.progressBeforeDragging);
    }
}

- (void)pan:(UIPanGestureRecognizer *)pan {
    UIGestureRecognizerState state = pan.state;
    CGPoint translate = [pan translationInView:self];
    
    switch (state) {
        case UIGestureRecognizerStateBegan: {
            
            self.interactive = YES;
            self.progressBeforeDragging = self.progress;
            [UIView animateWithDuration:0.3 animations:^{
                self.thumbBackgroundView.transform = CGAffineTransformMakeScale(2, 2);
            }];
        }
            break;
        case UIGestureRecognizerStateChanged: {
            CGFloat progressDelta = translate.x / [self _maxProgressWidth];
            CGFloat newProgress = self.progressBeforeDragging + progressDelta;
            [self setProgress:newProgress animated:NO];
            
            if (self.seekingToProgress) {
                self.seekingToProgress(self.progress, NO, NO);
            }
        }
            break;
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateFailed: {
            
            [UIView animateWithDuration:0.3 animations:^{
                self.thumbBackgroundView.transform = CGAffineTransformIdentity;
            }];
            if (state == UIGestureRecognizerStateEnded) {
                if (self.didSeekToProgress) {
                    self.didSeekToProgress(self.progress, self.progressBeforeDragging);
                }
                self.interactive = NO;
                
                if (self.seekingToProgress) {
                    self.seekingToProgress(self.progress, NO, YES);
                }
            } else {
                self.interactive = NO;
                if (self.seekingToProgress) {
                    self.seekingToProgress(self.progressBeforeDragging, YES, YES);
                }
            }
        }
            break;
        default:
            break;
    }
}

#pragma mark -
#pragma mark UI

- (void)_buildViewHierarchy {
    [self addSubview:self.progressView];
    [self addSubview:self.thumbBackgroundView];
    [self addSubview:self.thumbView];
}

- (void)_buildGestures {
    [self addGestureRecognizer:self.tapGesture];
    [self addGestureRecognizer:self.panGesture];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self _updateLayout];
    [self _updateThumbPosition];

//    [self _updateCacheProgress];
//    [self _updateTrackProgress];
}

- (void)_updateLayout {
    self.progressView.width = self.width;
    self.progressView.height = _sliderHeight;
    self.progressView.centerX = self.width / 2;
    self.progressView.centerY = self.height / 2;
    
    self.thumbView.centerY = self.progressView.centerY;
    // 抗锯齿
    self.thumbView.top = floor(self.thumbView.top);
    self.thumbView.left = floor(self.thumbView.left);
    self.thumbBackgroundView.center = self.thumbView.center;
    
    self.progressView.layer.cornerRadius = _sliderHeight / 2;
    self.progressView.trackProgressView.layer.cornerRadius = _sliderHeight / 2;
    self.progressView.cacheProgressView.layer.cornerRadius = _sliderHeight / 2;
}

- (UITapGestureRecognizer *)tapGesture {
    if (!_tapGesture) {
        _tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
    }
    
    return _tapGesture;
}

- (UIPanGestureRecognizer *)panGesture {
    if (!_panGesture) {
        _panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
    }
    return _panGesture;
}
#pragma mark -  getters && setters

- (UIView<TTVProgressViewOfSliderProtocol> *)progressView {
    if (!_progressView) {
        _progressView = [[TTVProgressViewOfSlider alloc] init];
    }
    return _progressView;
}

- (CGFloat)thumbViewBorder {
    return (self.thumbViewWidth - self.thumbViewWidth / kThumbViewOutInRatio) * 0.5;
}

- (UIView *)thumbBackgroundView {
    if (!_thumbBackgroundView) {
        _thumbBackgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.thumbViewWidth+7, self.thumbViewWidth+7)];
        UIImageView *thumbViewBackgrounImagedView = [[UIImageView alloc] init];
        thumbViewBackgrounImagedView.frame = CGRectMake(0, 0, self.thumbViewWidth+7, self.thumbViewWidth+7);
        thumbViewBackgrounImagedView.tag = 9802;
        [_thumbBackgroundView addSubview:thumbViewBackgrounImagedView];
        [thumbViewBackgrounImagedView setContentMode:UIViewContentModeScaleToFill];
        [thumbViewBackgrounImagedView setAutoresizingMask:UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth];
        [_thumbBackgroundView setUserInteractionEnabled:NO];
        
        /// TODO
        //        dispatch_async(dispatch_get_global_queue(QOS_CLASS_DEFAULT, 0), ^{
        //            UIImage *image = self.progressIndicatorBackgroundImage;
        //            if (image) {
        //                dispatch_async(dispatch_get_main_queue(), ^{
        [thumbViewBackgrounImagedView setImage:[self imageForThumbBackgroundView]];
        //                });
        //            }
        //        });
    }
    return _thumbBackgroundView;
}

- (UIView *)thumbView {
    if (!_thumbView) {
        _thumbView = [[UIView alloc] init];
        _thumbView.frame = CGRectMake(0, 0, _thumbViewWidth, _thumbViewWidth);
        
        UIImageView *thumbViewBackgroundView = [[UIImageView alloc] init];
        thumbViewBackgroundView.frame = CGRectMake(0, 0, _thumbViewWidth, _thumbViewWidth);
        [_thumbView addSubview:thumbViewBackgroundView];
        thumbViewBackgroundView.tag = 9801;
        [thumbViewBackgroundView setContentMode:UIViewContentModeScaleToFill];
        [thumbViewBackgroundView setAutoresizingMask:UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth];
        [thumbViewBackgroundView setImage:[self imageForThumbView]];
        _thumbView.userInteractionEnabled = NO;
    }
    return _thumbView;
}


- (UIImage *)imageForThumbView {
    UIBezierPath *path = [UIBezierPath bezierPathWithOvalInRect:(CGRect){0, 0, _thumbViewWidth, _thumbViewWidth}];

    UIGraphicsBeginImageContextWithOptions(CGSizeMake(_thumbViewWidth, _thumbViewWidth), NO, [UIScreen mainScreen].scale);

    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [TTVPlayerUtility colorWithHexString:self.thumbColorString].CGColor);
    [path fill];
    CGContextSetShadowWithColor(context, CGSizeMake(0, 0), 3, [TTVPlayerUtility colorWithHexString:self.thumbColorString].CGColor);

    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

- (UIImage *)imageForThumbBackgroundView {
    UIBezierPath *path = [UIBezierPath bezierPathWithOvalInRect:(CGRect){0, 0, 72, 72}];
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(72, 72), NO, [UIScreen mainScreen].scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    CGContextSetFillColorWithColor(context, [TTVPlayerUtility colorWithHexString:[self.thumbBackgroundColorString stringByAppendingString:@"29"]].CGColor);
    CGContextSetShadowWithColor(context, CGSizeMake(0, 0), 9, [TTVPlayerUtility colorWithHexString:[self.thumbBackgroundColorString stringByAppendingString:@"61"]].CGColor);
    CGContextSetStrokeColorWithColor(context, [TTVPlayerUtility colorWithHexString:[self.thumbBackgroundColorString stringByAppendingString:@"F0"]].CGColor);
    [path fill];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

- (CGFloat)progress {
    return self.progressView.progress;
}

- (CGFloat)cacheProgress {
    return self.progressView.cacheProgress;
}

- (void)setProgress:(CGFloat)progress animated:(BOOL)animated {
    [self.progressView setProgress:progress animated:animated];
    [self _updateThumbPosition];
}

- (void)setCacheProgress:(CGFloat)progress animated:(BOOL)animated {
    [self.progressView setCacheProgress:progress animated:animated];
}

- (NSString *)thumbBackgroundColorString {
    if (isEmptyString(_thumbBackgroundColorString)) {
        _thumbBackgroundColorString = @"0xCC0000";
    }
    return _thumbBackgroundColorString;
}

- (void)setThumbBackgroundColorString:(NSString *)thumbBackgroundColorString {
    _thumbBackgroundColorString = thumbBackgroundColorString;
    [[self.thumbBackgroundView viewWithTag:9802] setImage:[self imageForThumbBackgroundView]];
}

- (NSString *)thumbColorString {
    if (isEmptyString(_thumbColorString)) {
        _thumbColorString = @"0xffffff";
    }
    return _thumbColorString;
}

- (void)setThumbColorString:(NSString *)thumbColor {
    _thumbColorString = thumbColor;
    [[self.thumbView viewWithTag:9801] setImage:[self imageForThumbView]];
}
@end


