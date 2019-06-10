//
//  TTVGestureState.m
//  TTVPlayerPod
//
//  Created by lisa on 2019/3/4.
//

#import "TTVGestureState.h"

@implementation TTVGestureState

- (instancetype)copyWithZone:(NSZone *)zone {
    TTVGestureState * copy = [TTVGestureState allocWithZone:zone];
    copy.supportPanDirection = self.supportPanDirection;
    copy.panGestureEnabled = self.panGestureEnabled;
    copy.singleTapEnabled = self.singleTapEnabled;
    copy.doubleTapEnabled = self.doubleTapEnabled;
    return copy;
}

- (BOOL)isEqual:(id)other {
    if (!other) {
        return NO;
    }
    
    if (other == self)  {
        return YES;
    }
    
    if (![other isKindOfClass:[TTVGestureState class]]) {
        return NO;
    }
    return [self isEqualToState:(TTVGestureState *)other];
}

- (BOOL)isEqualToState:(TTVGestureState *)other {
    if (self.supportPanDirection == other.supportPanDirection &&
        self.panGestureEnabled == other.panGestureEnabled &&
        self.singleTapEnabled == other.singleTapEnabled &&
        self.doubleTapEnabled == other.doubleTapEnabled) {
        return YES;
    }
    return NO;
}

- (NSUInteger)hash {
    return self.supportPanDirection ^ self.panGestureEnabled ^ self.singleTapEnabled ^ self.doubleTapEnabled;
}

@end
