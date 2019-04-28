//
//  TTVPlaybackTime.m
//  TTVPlayer
//
//  Created by lisa on 2019/1/17.
//

#import "TTVPlaybackTime.h"
#import "TTVPlaybackTimePrivate.h"

@interface TTVPlaybackTime ()

@property (nonatomic, weak) NSObject<TTVPlayerTimeAdaptor> * adaptor;

@end

@implementation TTVPlaybackTime

- (instancetype)initWithTTVPlayerTimeAdaptor:(NSObject<TTVPlayerTimeAdaptor> *)adaptor {
    self = [super init];
    if (self) {
        self.adaptor = adaptor;
    }
    return self;
}

- (instancetype)copyWithZone:(NSZone *)zone {
    TTVPlaybackTime * copy = [TTVPlaybackTime allocWithZone:zone];
    copy.currentPlaybackTime = self.currentPlaybackTime;
    copy.duration = self.duration;
    copy.durationWatched = self.durationWatched;
    copy.playableDuration = self.playableDuration;
    copy.progress = self.progress;
    copy.cachedProgress = self.cachedProgress;
    return copy;
}

- (BOOL)isEqual:(id)other {
    if (!other) {
        return NO;
    }
    
    if (other == self)  {
        return YES;
    }
    
    if (![other isKindOfClass:[TTVPlaybackTime class]]) {
        return NO;
    }
    return [self isEqualToPlaybackTime:(TTVPlaybackTime *)other];
}

- (BOOL)isEqualToPlaybackTime:(TTVPlaybackTime *)other {
    if (self.currentPlaybackTime == other.currentPlaybackTime &&
        self.duration == other.duration &&
        self.durationWatched == other.durationWatched &&
        self.playableDuration == other.playableDuration &&
        self.progress == other.progress &&
        self.cachedProgress == other.cachedProgress) {
        return YES;
    }
    return NO;
}

- (NSUInteger)hash {
    return ([@(self.currentPlaybackTime) hash] ^ [@(self.duration) hash] ^ [@(self.durationWatched) hash]
            ^ [@(self.playableDuration) hash] ^ [@(self.progress) hash] ^ [@(self.cachedProgress) hash]);
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@:%p>:%@",[self class],&self,@{@"currentTime":@(_currentPlaybackTime),@"duration":@(_duration),@"durationWatched":@(_durationWatched), @"playableDuration":@(_playableDuration), @"progress":@(_progress), @"cacheProgress":@(_cachedProgress)}];
}

- (BOOL)ttv_isvalidNumber:(NSTimeInterval)number {
    return !isnan(number) && number != NAN;
}
#pragma mark - getters & setters
- (NSTimeInterval)currentPlaybackTime {
    if (self.adaptor) {
        return self.adaptor.currentPlaybackTime;
    }
    return _currentPlaybackTime;
}

- (NSTimeInterval)duration {
    if (self.adaptor) {
        return self.adaptor.duration;
    }
    return _duration;
}

- (NSTimeInterval)durationWatched {
    if (self.adaptor) {
        return self.adaptor.durationWatched;
    }
    return _durationWatched;
}

- (NSTimeInterval)playableDuration {
    if (self.adaptor) {
        return self.adaptor.playableDuration;
    }
    return _playableDuration;
}

- (CGFloat)progress {
    return [self ttv_progress];
}

- (CGFloat)cachedProgress {
    return [self ttv_cacheProgress];
}
#pragma mark - progress calculate

- (CGFloat)ttv_progress {
    NSTimeInterval currentPlaybackTime = self.currentPlaybackTime;
    NSTimeInterval duration = self.duration;
    if (![self ttv_isvalidNumber:currentPlaybackTime] ||
        ![self ttv_isvalidNumber:duration] ||
        currentPlaybackTime < 0 || duration <= 0) {
        return 0;
    }
    return currentPlaybackTime / duration;
}

- (CGFloat)ttv_cacheProgress {
    NSTimeInterval cacheTime = self.playableDuration;
    NSTimeInterval duration = self.duration;
    
    if (![self ttv_isvalidNumber:cacheTime] ||
        ![self ttv_isvalidNumber:duration] ||
        cacheTime < 0 || duration <= 0) {
        return 0;
    }
    return cacheTime / duration;
}

@end
