//
//  FHImmersionNavBarViewModel.m
//  Pods
//
//  Created by leo on 2019/3/29.
//

#import "FHImmersionNavBarViewModel.h"
#import "UIColor+Theme.h"
#import "UIFont+House.h"
#import <FHHouseBase/UIImage+FIconFont.h>
@interface FHImmersionNavBarViewModel ()
{
    CGFloat _throttle;
    CGFloat _currentOffset;
}
@end

@implementation FHImmersionNavBarViewModel


- (instancetype)init
{
    self = [super init];
    if (self) {
        _throttle = 44;
        self.isHasData = YES;
        self.statusBarStyle = UIStatusBarStyleDefault;
    }
    return self;
}

- (instancetype)initWithThrottle:(CGFloat)throttle {
    self = [super init];
    if (self) {
        _throttle = throttle;
        self.statusBarStyle = UIStatusBarStyleDefault;
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
    _currentOffset = offset;
    CGFloat theAlpha = 0;
    if (!_isHasData) {
        theAlpha = 1;
        self.titleColor = [UIColor blackColor];
        self.backButtonImage = FHBackBlackImage;
        self.statusBarStyle = UIStatusBarStyleDefault;
    } else {
        if (offset == 0) {
            theAlpha = 0;
            self.titleColor = [UIColor whiteColor];
            self.backButtonImage = FHBackWhiteImage;
            self.statusBarStyle = UIStatusBarStyleLightContent;
        } else if (offset > _throttle) {
            theAlpha = 1;
            self.titleColor = [UIColor blackColor];
            self.backButtonImage = FHBackBlackImage;
            self.statusBarStyle = UIStatusBarStyleDefault;
        } else if (_throttle - offset >= 0) {
            theAlpha = offset / _throttle;
            self.titleColor = [UIColor blackColor];
            self.backButtonImage = FHBackBlackImage;
            self.statusBarStyle = UIStatusBarStyleLightContent;
        }
    }
    self.alpha = theAlpha;
}

-(void)setIsHasData:(BOOL)isHasData {
    _isHasData = isHasData;
    [self resetAlphaByOffset:_currentOffset];
}

@end
