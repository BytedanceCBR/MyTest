//
//  TTVLoadingState.m
//  TTVPlayer
//
//  Created by lisa on 2019/2/15.
//

#import "TTVLoadingState.h"

@implementation TTVLoadingState

- (instancetype)copyWithZone:(NSZone *)zone {
    TTVLoadingState * copy = [TTVLoadingState allocWithZone:zone];
    copy.showed= self.showed;
    copy.shouldShow = self.shouldShow;
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

- (BOOL)isEqualToState:(TTVLoadingState *)other {
    if (self.showed == other.showed &&
        self.shouldShow == other.shouldShow) { // need remove
        return YES;
    }
    
    return NO;
}

- (NSUInteger)hash {
    return self.showed ^ self.shouldShow;
}

@end
