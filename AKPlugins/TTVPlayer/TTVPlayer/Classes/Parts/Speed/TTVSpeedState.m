//
//  TTVSpeedState.m
//  TTVPlayerPod
//
//  Created by lisa on 2019/4/24.
//

#import "TTVSpeedState.h"

@implementation TTVSpeedState

- (instancetype)init {
    self = [super init];
    if (self) {
//        _speedSelectViewShouldShow = YES;
    }
    return self;
}
- (instancetype)copyWithZone:(NSZone *)zone {
    TTVSpeedState * copy = [TTVSpeedState allocWithZone:zone];
    copy.speedSelectViewShowed= self.speedSelectViewShowed;
    copy.speedSelectViewShouldShow = self.speedSelectViewShouldShow;
    copy.speed = self.speed;
    return copy;
}

- (BOOL)isEqual:(id)object {
    if (!object) {
        return NO;
    }
    if (self == object) {
        return YES;
    }
    if (![object isKindOfClass:[self class]]) {
        return NO;
    }
    return [self isEqualToState:object];
}

- (BOOL)isEqualToState:(TTVSpeedState *)other {
    if (self.speedSelectViewShowed == other.speedSelectViewShowed &&
        self.speedSelectViewShouldShow == other.speedSelectViewShouldShow &&
        self.speed == other.speed) {
        return YES;
    }
    
    return NO;
}

- (NSUInteger)hash {
    return self.speedSelectViewShowed ^ [@(self.speed) hash] ^ self.speedSelectViewShouldShow;
}


@end
