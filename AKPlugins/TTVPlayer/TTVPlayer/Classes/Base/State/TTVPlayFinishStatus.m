//
//  TTVPlayFinishStatus.m
//  TTVPlayer
//
//  Created by lisa on 2019/1/18.
//

#import "TTVPlayFinishStatus.h"

@implementation TTVPlayFinishStatus

- (instancetype)copyWithZone:(NSZone *)zone {
    TTVPlayFinishStatus * copy = [TTVPlayFinishStatus allocWithZone:zone];
    copy.type = self.type;
    copy.playError = [self.playError copy];
    copy.sourceErrorStatus = self.sourceErrorStatus;
    return copy;
}

- (BOOL)isEqual:(id)other {
    if (!other) {
        return NO;
    }
    
    if (other == self)  {
        return YES;
    }
    
    if (![other isKindOfClass:[TTVPlayFinishStatus class]]) {
        return NO;
    }
    return [self isEqualToOther:(TTVPlayFinishStatus *)other];
}

- (BOOL)isEqualToOther:(TTVPlayFinishStatus *)other {
    if (self.type == other.type &&
        [self.playError isEqual:other.playError] &&
        self.sourceErrorStatus == other.sourceErrorStatus) {
        return YES;
    }
    return NO;
}

- (NSUInteger)hash {
    return self.type ^ [self.playError hash] ^ self.sourceErrorStatus;
}

@end
