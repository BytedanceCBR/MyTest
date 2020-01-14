//
//  TTVNetworkMonitorReducer.m
//  TTVPlayer
//
//  Created by lisa on 2019/2/13.
//

#import "TTVNetworkMonitorReducer.h"
#import "TTVPlayerState.h"
#import "TTVPlayerAction.h"
#import "NetworkUtilities.h"
#import <TTReachability.h>
#import "TTVPlayer+Engine.h"

/// 只出现一次，所以需要全局标志
BOOL _ignoreInterrupt;

@interface TTVNetworkMonitorReducer () {
    BOOL _pauseByCellularNetwork;
}
@property (nonatomic,weak) TTVPlayer * player;
@end

/**
 pausingBycellularNetwork 只能从 YES 到 NO，改变
 */
@implementation TTVNetworkMonitorReducer

- (instancetype)initWithPlayer:(TTVPlayer *)player {
    self = [super init];
    if (self) {
        self.player = player;
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (TTVPlayerState *)executeWithAction:(TTVReduxAction *)action
                                 state:(TTVPlayerState *)state {
    
    if ([action.type isEqualToString:TTVPlayerActionType_ReadyForDisplayChanged]) { // 播放开始判断是否改变
        BOOL isReady = self.player.readyForDisplay;
        if (isReady) {
            [self pausePlayerIfNeeded];
            [self addNotification];
        }
    }
    else if ([action.type isEqualToString:TTVPlayerActionType_PlaybackStateDidChanged]) {
        TTVPlaybackState playbackState = self.player.playbackState;
        if (playbackState == TTVPlaybackState_Playing ) {
            if (state.networkState.pausingBycellularNetwork ) { // 之前被暂停过了
                // 设置过 no 之后，就无法再弹出了
                state.networkState.pausingBycellularNetwork = NO;
                _ignoreInterrupt = YES;
                TTNetworkStopNotifier();
            }
            else if (self.player.readyForDisplay ){
                [self pausePlayerIfNeeded];
            }
        }
        else if (playbackState == TTVPlaybackState_Paused && _pauseByCellularNetwork && !_ignoreInterrupt) {
            state.networkState.pausingBycellularNetwork = YES;
        }
    }
    else if ([action.type isEqualToString:TTVPlayerActionType_CellularNetTipViewShowed]) { // view 是否 show 出来
        BOOL showed = [action.info[TTVPlayerActionInfo_isShowed] boolValue];
        if (showed /*&& [self.player partControlForKey:TTVPlayerPartControlKey_NetworkTipView]*/) {
            state.networkState.flowTipViewShowed = YES;
        }
        else {
            state.networkState.flowTipViewShowed = NO;
        }
    }
    
    return state;
}

- (BOOL)pausePlayerIfNeeded {
    if (_ignoreInterrupt) {
        return NO;
    }
    
    BOOL cellularNetwork = !TTNetworkWifiConnected() && TTNetworkConnected();
//    BOOL currentMovieAllowAlert = !self.allowPlayWithoutWiFi;
    BOOL isLocalVideo = self.player.isLocalVideo;
    if (cellularNetwork && !isLocalVideo) {
        // 暂停当前播放
        BOOL isPlaying = self.player.playbackState == TTVPlaybackState_Playing;
        if (isPlaying) {
            // 一定要放在 pause 之前，否则计算错误
            _pauseByCellularNetwork = YES;
            [self.player.playerStore dispatch:[self.player.playerAction pauseAction]];
            return YES;

        }
        
    }
    return NO;
}

- (void)addNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(connectionChanged:)
                                                 name:TTReachabilityChangedNotification
                                               object:nil];
    TTNetworkStartNotifier();
}

- (void)connectionChanged:(NSNotification *)notification {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(pausePlayerIfNeeded) object:nil];
    if (![self pausePlayerIfNeeded] ) {
        // 网络
        if ([self state].networkState.pausingBycellularNetwork) {
            BOOL connectedAndWifi = TTNetworkWifiConnected() && TTNetworkConnected();
            if (connectedAndWifi) {
                [self.player.playerStore dispatch:[self.player.playerAction resumeAction]];
            }
        }
    }
}

- (TTVPlayerState *)state {
    return (TTVPlayerState *)(self.player.playerStore.state);
}


@end
