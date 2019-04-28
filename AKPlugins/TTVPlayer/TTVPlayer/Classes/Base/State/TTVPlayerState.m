//
//  TTVPlayerState.m
//  Article
//
//  Created by lisa on 2018/7/22.
//

#import "TTVPlayerState.h"

@interface TTVReduxState ()

@property (nonatomic, strong) NSMutableDictionary<id<NSCopying>, NSObject<TTVReduxStateProtocol> *>* subStates;

@end

@implementation TTVPlayerState

- (instancetype)init {
    self = [super init];
    if (self) {
        _playbackTime = [[TTVPlaybackTime alloc] init];
        _fullScreenState = [[TTVFullScreenState alloc] init];
        _controlViewState = [[TTVPlayerControlViewState alloc] init];
        _seekStatus = [[TTVSeekState alloc] init];
        _networkState = [[TTVNetworkMonitorState alloc] init];
        _loadingViewState = [[TTVLoadingState alloc] init];
        _gestureState = [[TTVGestureState alloc] init];
        _finishViewState = [[TTVPlayerFinishViewState alloc] init];
        _speedState = [[TTVSpeedState alloc] init];
    }
    return self;
}

- (void)dealloc {
//    Debug_NSLog(@"%s", __FUNCTION__);
}

- (id)copyWithZone:(NSZone *)zone {
    TTVPlayerState * state = [[self class] allocWithZone:zone];
    if (self.subStates) {
        // 避免是 nil 还有拷贝
        state.subStates = [[NSMutableDictionary alloc] initWithDictionary:self.subStates copyItems:YES];
    }

    state.playbackState = self.playbackState;
    state.playbackTime = [self.playbackTime copy];
    state.finishStatus = [self.finishStatus copy];
    state.videoTitle = [self.videoTitle copy];
    state.loadState = self.loadState;
    state.readyForDisplay = self.readyForDisplay;
    state.seekStatus = [self.seekStatus copy];
    state.controlViewState = [self.controlViewState copy];
    state.fullScreenState = [self.fullScreenState copy];
    state.networkState = [self.networkState copy];
    state.loadingViewState = [self.loadingViewState copy];
    state.finishViewState = [self.finishViewState copy];
    state.seeking = self.seeking;
    state.gestureState = self.gestureState;
    state.speedState = [self.speedState copy];

    return state;
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

- (BOOL)isEqualToState:(TTVPlayerState *)other {
    if ((self.subStates == other.subStates || [self.subStates isEqual:other.subStates]) &&
        self.playbackState == other.playbackState &&
        (self.playbackTime == other.playbackTime || [self.playbackTime isEqual:other.playbackTime]) &&
        (self.finishStatus == other.finishStatus || [self.finishStatus isEqual:other.finishStatus]) &&
        (self.videoTitle == other.videoTitle || [self.videoTitle isEqualToString:other.videoTitle]) &&
        self.loadState == other.loadState &&
        (self.seekStatus == other.seekStatus || [self.seekStatus isEqual:other.seekStatus]) &&
        (self.controlViewState == other.controlViewState || [self.controlViewState isEqual:other.controlViewState]) &&
        (self.networkState == other.networkState || [self.networkState isEqual:other.networkState]) &&
        (self.loadingViewState == other.loadingViewState || [self.loadingViewState isEqual:other.loadingViewState]) &&
        (self.finishViewState == other.finishViewState || [self.finishViewState isEqual:other.finishViewState])  &&
        self.seeking == other.seeking &&
        (self.gestureState == other.gestureState || [self.gestureState isEqual:other.gestureState]) &&
        (self.speedState == other.speedState || [self.speedState isEqual:other.speedState]) &&
        (self.fullScreenState == other.fullScreenState || [self.fullScreenState isEqual:other.fullScreenState])) { // need remove
        return YES;
    }
    
    return NO;
}

- (NSUInteger)hash {
    return ([self.subStates hash] ^ self.playbackState ^ [self.playbackTime hash] ^ [self.finishStatus hash] ^ [self.videoTitle hash] ^
            self.loadState ^ [self.seekStatus hash] ^ [self.controlViewState hash] ^
            [self.networkState hash] ^ [self.loadingViewState hash] ^
            [self.finishViewState hash] && self.seeking && [self.gestureState hash] ^ [self.speedState hash] ^ [self.fullScreenState hash]);
}

@end





