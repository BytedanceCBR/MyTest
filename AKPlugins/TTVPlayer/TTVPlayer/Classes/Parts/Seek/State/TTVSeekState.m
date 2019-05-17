//
//  TTVSeekState.m
//  TTVPlayer
//
//  Created by lisa on 2019/1/29.
//

#import "TTVSeekState.h"
#import "TTVSeekStatePrivate.h"

@implementation TTVSeekState

- (instancetype)copyWithZone:(NSZone *)zone {
    TTVSeekState * copy = [TTVSeekState allocWithZone:zone];
    copy.panningOutOfSlider = self.isPanningOutOfSlider;
    copy.panSeekingOutOfSliderInfo = self.panSeekingOutOfSliderInfo;
    copy.sliderPanning = self.isSliderPanning;
    copy.hudShowed = self.isHudShowed;
    return copy;
}

- (BOOL)isEqual:(id)other {
    if (!other) {
        return NO;
    }
    if (self == other)  {
        return YES;
    }
    
    if (![other isKindOfClass:[TTVSeekState class]]) {
        return NO;
    }
    return [self isEqualToSeekState:(TTVSeekState *)other];
}

- (BOOL)isEqualToSeekState:(TTVSeekState *)other {
    if (self.panningOutOfSlider == other.isPanningOutOfSlider &&
        [self isEqualToPanSeekingOutOfSliderInfo:other.panSeekingOutOfSliderInfo] && // TODO 改成类
        self.sliderPanning == other.isSliderPanning &&
        self.hudShowed == other.isHudShowed ) {
        return YES;
    }
    return NO;
}

- (NSUInteger)hash {
    return self.isPanningOutOfSlider ^ self.isSliderPanning ^ self.hudShowed;
}

- (BOOL)isEqualToPanSeekingOutOfSliderInfo:(TTVPanSeekInfo)otherInfo {
    if (self.panSeekingOutOfSliderInfo.progress == otherInfo.progress &&
        self.panSeekingOutOfSliderInfo.fromProgress == otherInfo.fromProgress &&
        self.panSeekingOutOfSliderInfo.gestureState == otherInfo.gestureState &&
        self.panSeekingOutOfSliderInfo.isCancelledOutArea == otherInfo.isCancelledOutArea &&
        self.panSeekingOutOfSliderInfo.isMovingForward == otherInfo.isMovingForward &&
        self.panSeekingOutOfSliderInfo.isSwipeGesture == otherInfo.isSwipeGesture) {
        return YES;
    }
    return NO;
}


@end
