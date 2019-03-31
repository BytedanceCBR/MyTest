//
//  FHImmersionNavBarViewModel.m
//  Pods
//
//  Created by leo on 2019/3/29.
//

#import "FHImmersionNavBarViewModel.h"
#import "UIColor+Theme.h"
#import "UIFont+House.h"
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
    _currentContentOffset = currentContentOffset;
    [self resetAlphaByOffset:_currentContentOffset.y];
    [self didChangeValueForKey:@"currentContentOffset"];
}

-(void)resetAlphaByOffset:(CGFloat)offset {
    CGFloat theAlpha = 0;
    if (offset == 0) {
        theAlpha = 0;
        self.titleColor = [UIColor whiteColor];
        self.backButtonImage = [UIImage imageNamed:@"icon-return-white"];
    } else if (offset > _throttle) {
        theAlpha = 1;
        self.titleColor = [UIColor blackColor];
        self.backButtonImage = [UIImage imageNamed:@"icon-return"];
    } else if (_throttle - offset > 0) {
        theAlpha = 0.5;
        self.titleColor = [UIColor whiteColor];
        self.backButtonImage = [UIImage imageNamed:@"icon-return-white"];
    }
    self.alpha = theAlpha;
}

@end
