//
//  TTVPlayerSpeedState.m
//  TTVPlayer
//
//  Created by lisa on 2018/12/26.
//

#import "TTVPlayerSpeedState.h"

@implementation TTVPlayerSpeedState

- (instancetype)init {
    self = [super init];
    if (self) {
        _currentSpeed = 1;
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeDouble:self.currentSpeed forKey:@"currentSpeed"];
}

- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        self.currentSpeed = [aDecoder decodeDoubleForKey:@"currentSpeed"];
    }
    return self;
}

- (instancetype)copyWithZone:(NSZone *)zone {
    TTVPlayerSpeedState * speed = [TTVPlayerSpeedState allocWithZone:zone];
    speed.currentSpeed = self.currentSpeed;
    return speed;
}

@end
