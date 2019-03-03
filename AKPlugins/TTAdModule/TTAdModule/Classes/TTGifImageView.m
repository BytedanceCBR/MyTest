//
//  TTGifImageView.m
//  Article
//
//  Created by carl on 2017/5/21.
//
//

#import "TTGifImageView.h"

@interface TTGifImageView ()
@property (nonatomic, strong) CADisplayLink *displayLink;
@property (nonatomic, strong, readwrite) VVeboImage *gifImage;
@property (nonatomic, assign) CFTimeInterval startTime;
@property (nonatomic, assign) CFTimeInterval duration;
@end

@implementation TTGifImageView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithImage:(UIImage *)image {
    self = [super initWithImage:image];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithImage:(UIImage *)image highlightedImage:(UIImage *)highlightedImage {
    self = [super initWithImage:image highlightedImage:highlightedImage];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit {
    _duration = 0;
    _displayLink = nil;
    _startTime = CGFLOAT_MAX;
}

- (void)dealloc {
    if(_gifImage) {
        _gifImage = nil;
    }
    if (_displayLink) {
        [_displayLink invalidate];
        _displayLink = nil;
    }
}

- (void)beginAnimation {
    [self endAnimation];
    _displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(displayImage:)];
    [_displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    [_displayLink setPaused:NO];
    _startTime = CACurrentMediaTime();
}

- (void)endAnimation {
    if (_displayLink) {
        [_displayLink invalidate];
        _displayLink = nil;
    }
}

- (void)setImage:(UIImage *)image {
    if (image == nil) {
        [self endAnimation];
        [super setImage:nil];
        return;
    }
    if ([image isKindOfClass:[VVeboImage class]]) {
        self.gifImage = (VVeboImage *)image;
        if (self.gifImage.count > 1) {
            [self.gifImage resumeIndex];
            [super setImage:[self.gifImage nextImage]];
            self.duration += [self.gifImage frameDuration];
            [self beginAnimation];
        } else {
            [super setImage:image];
        }
    } else {
        [super setImage:image];
    }
}

- (void)displayImage:(CADisplayLink *)dispalyLink {
    CFTimeInterval endTime = CACurrentMediaTime();
    if ((endTime - self.startTime) >= self.duration) {
        self.duration += [self.gifImage frameDuration];
        [super setImage:[self.gifImage nextImage]];
    }
    if (!self.repeats && !self.gifImage.hasNextImage) {
        [self endAnimation];
        if (self.completionHandler) {
            self.completionHandler(YES);
        }
    }
}

- (void)removeFromSuperview {
    [self endAnimation];
    self.image = nil;
    self.gifImage = nil;
    [super removeFromSuperview];
}

- (void)setCurrentPlayIndex:(NSInteger)currentPlayIndex {
    self.gifImage.currentPlayIndex = currentPlayIndex;
    [super setImage:[self.gifImage nextImage]];
}

- (NSInteger)currentPlayIndex {
    return self.gifImage.currentPlayIndex;
}

@end

