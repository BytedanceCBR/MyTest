//
//  TTVPlayFinishViewState.m
//  TTVPlayerPod
//
//  Created by lisa on 2019/3/5.
//

#import "TTVPlayerFinishViewState.h"

@implementation TTVPlayerFinishViewState

- (instancetype)copyWithZone:(NSZone *)zone {
    TTVPlayerFinishViewState * copy = [TTVPlayerFinishViewState allocWithZone:zone];
    copy.playerErrorViewShowed = self.playerErrorViewShowed;
    copy.playerErrorViewShouldShow = self.playerErrorViewShouldShow;
    copy.playerFinishNoErrorViewShow = self.playerFinishNoErrorViewShow;
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

- (BOOL)isEqualToState:(TTVPlayerFinishViewState *)other {
    if (self.playerErrorViewShowed == other.playerErrorViewShowed &&
        self.playerErrorViewShouldShow == other.playerErrorViewShouldShow &&
        self.playerFinishNoErrorViewShow == other.playerFinishNoErrorViewShow) { // need remove
        return YES;
    }
    
    return NO;
}

- (NSUInteger)hash {
    return self.isPlayerErrorViewShowed ^ self.isplayerFinishNoErrorViewShow ^ self.playerErrorViewShouldShow;
}

@end
