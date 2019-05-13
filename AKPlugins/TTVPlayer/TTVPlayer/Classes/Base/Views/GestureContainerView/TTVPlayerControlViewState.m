//
//  TTVPlayerControlViewState.m
//  TTVPlayer
//
//  Created by lisa on 2019/1/15.
//

#import "TTVPlayerControlViewState.h"

@implementation TTVPlayerControlViewState

- (nonnull id)copyWithZone:(nullable NSZone *)zone {
    TTVPlayerControlViewState * copy = [TTVPlayerControlViewState allocWithZone:zone];
    copy.showed = self.isShowed;
    copy.panning = self.isPanning;
    copy.locked = self.isLocked;
    return copy;
}

- (BOOL)isEqual:(id)other {
    if (!other) {
        return NO;
    }
    if (self == other)  {
        return YES;
    }
    
    if (![other isKindOfClass:[TTVPlayerControlViewState class]]) {
        return NO;
    }
    return [self isEqualToControlViewState:(TTVPlayerControlViewState *)other];
}

- (BOOL)isEqualToControlViewState:(TTVPlayerControlViewState *)other {
    if (self.isShowed == other.isShowed &&
        self.isPanning == other.isPanning &&
        self.isLocked == other.isLocked) {
        return YES;
    }
    return NO;
}

- (NSUInteger)hash {
    return self.isLocked ^ self.isShowed ^ self.isPanning;
}

@end
