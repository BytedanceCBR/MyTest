//
//  TTVPlayerFullScreenState.m
//  TTVPlayer
//
//  Created by lisa on 2019/1/13.
//

#import "TTVFullScreenState.h"

@implementation TTVFullScreenState

- (instancetype)init {
    self = [super init];
    if (self) {
        _enableAutoRotate = YES;
    }
    return self;
}

- (instancetype)copyWithZone:(NSZone *)zone {
    TTVFullScreenState * copy = [TTVFullScreenState allocWithZone:zone];
    copy.fullScreen = self.isFullScreen;
    copy.enableAutoRotate = self.enableAutoRotate;
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


- (BOOL)isEqualToState:(TTVFullScreenState *)other {
    if (self.fullScreen == other.fullScreen &&
        self.enableAutoRotate == other.enableAutoRotate) {
        return YES;
    }
    return NO;
}

- (NSUInteger)hash {
    return self.fullScreen ^ self.enableAutoRotate;
}

@end
