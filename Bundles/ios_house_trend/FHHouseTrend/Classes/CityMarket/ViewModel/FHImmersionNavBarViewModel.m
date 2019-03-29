//
//  FHImmersionNavBarViewModel.m
//  Pods
//
//  Created by leo on 2019/3/29.
//

#import "FHImmersionNavBarViewModel.h"

@interface FHImmersionNavBarViewModel ()
{
    CGFloat _throttle;
}
@end

@implementation FHImmersionNavBarViewModel


- (instancetype)init
{
    self = [super init];
    if (self) {
        _throttle = 44;
    }
    return self;
}

- (instancetype)initWithThrottle:(CGFloat)throttle {
    self = [super init];
    if (self) {
        _throttle = throttle;
    }
    return self;
}

- (void)setCurrentContentOffset:(CGPoint)currentContentOffset {
    [self willChangeValueForKey:@"currentContentOffset"];
    NSLog(@"setCurrentContentOffset : %d -- %d", currentContentOffset.x, currentContentOffset.y);
    _currentContentOffset = currentContentOffset;
    [self didChangeValueForKey:@"currentContentOffset"];
}

-(void)resetAlphaByOffset:(CGFloat)offset {
    CGFloat theAlpha = 0;
    if (offset > _throttle) {
        theAlpha = 1;
    } else if (_throttle - offset > 0) {
        theAlpha = 0.5;
    } else {
        theAlpha = 0;
    }
    self.alpha = theAlpha;
}

@end
