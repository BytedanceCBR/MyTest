//
//  VVeboImageView.m
//  vvebo
//
//  Created by Johnil on 14-3-6.
//  Copyright (c) 2014年 Johnil. All rights reserved.
//

#import "VVeboImageView.h"

@implementation VVeboImageView {
	NSTimer *timer;
}

- (void)setImage:(UIImage *)image{
	if (image==nil) {
		if (timer) {
			[timer invalidate];
			timer = nil;
		}
		[super setImage:nil];
		return;
	}
	if ([image isKindOfClass:[VVeboImage class]]) {
		self.gifImage = (VVeboImage *)image;
		if ([(VVeboImage *)image count]>1) {
			float duration = [self.gifImage frameDuration];
			[(VVeboImage *)image resumeIndex];
			[super setImage:[(VVeboImage *)image nextImage]];
            if (self.delayDuration > 0) {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.delayDuration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    timer = [NSTimer scheduledTimerWithTimeInterval:duration target:self selector:@selector(tick) userInfo:nil repeats:NO];
                    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
                });
            } else {
                timer = [NSTimer scheduledTimerWithTimeInterval:duration target:self selector:@selector(tick) userInfo:nil repeats:NO];
                [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
            }
		} else {
			[super setImage:image];
		}
	} else {
		[super setImage:image];
	}
}

- (void)tick{
	[timer invalidate];
	timer = nil;
    if (!self.repeats && !self.gifImage.hasNextImage) {
        if (self.completionHandler) {
            self.completionHandler(YES);
        }
        return;
    }
	float duration = [self.gifImage frameDuration];
	[super setImage:[self.gifImage nextImage]];
	timer = [NSTimer scheduledTimerWithTimeInterval:duration target:self selector:@selector(tick) userInfo:nil repeats:NO];
	[[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
}

- (void)removeFromSuperview{
	if (timer) {
		[timer invalidate];
		timer = nil;
	}
	self.image = nil;
    self.gifImage = nil;
	[super removeFromSuperview];
}

- (void)dealloc{
}

- (void)setCurrentPlayIndex:(NSInteger)currentPlayIndex {
    self.gifImage.currentPlayIndex = currentPlayIndex;
    [super setImage:[self.gifImage nextImage]];
}

- (NSInteger)currentPlayIndex {
    return self.gifImage.currentPlayIndex;
}
@end
