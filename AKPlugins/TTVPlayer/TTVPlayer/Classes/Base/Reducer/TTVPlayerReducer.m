//
//  TTVPlayerReducer.m
//  TTVPlayer
//
//  Created by lisa on 2019/1/4.
//

#import "TTVPlayerReducer.h"
#import "TTVPlayerState.h"
#import "TTVPlayerAction.h"
#import "TTVPlayer.h"
#import "TTVSeekStatePrivate.h"
#import "TTVPlayer+Engine.h"

@interface TTVPlayerReducer ()

@property (nonatomic, weak) TTVPlayer * player;

@end


@implementation TTVPlayerReducer

- (instancetype)initWithPlayer:(TTVPlayer *)player {
    self = [super init];
    if (self) {
        self.player = player;
    }
    return self;
}

- (TTVPlayerState *)executeWithAction:(TTVReduxAction *)action
                                 state:(TTVPlayerState *)state {
    
    if ([action.type isEqualToString:TTVPlayerActionType_PlaybackStateDidChanged]) {
        state.playbackState = self.player.playbackState;
    }
    else if ([action.type isEqualToString:TTVPlayerActionType_PlayBackTimeChanged]) {
        if (!state.playbackTime.currentPlaybackTime) {
            state.playbackTime = self.player.playbackTime;
        }
    }
    else if ([action.type isEqualToString:TTVPlayerActionType_FinishStatusChanged]) {
        if (action.info[TTVPlayerActionInfo_FinishStatus]) {
            state.finishStatus = action.info[TTVPlayerActionInfo_FinishStatus];
            // 如果结束有错误
            if (state.finishStatus.type == TTVPlayFinishStatusType_SystemFinish // 如果是结束状态
                && (state.finishStatus.playError || state.finishStatus.sourceErrorStatus != 0)) {
                state.finishViewState.playerErrorViewShouldShow = YES;
            }
        }
        else {
            state.finishStatus = nil;
            state.finishViewState.playerErrorViewShouldShow = NO;
        }
    }
    else if ([action.type isEqualToString:TTVPlayerActionType_VideoTitleChanged]) {
        state.videoTitle = self.player.videoTitle;
    }
    else if ([action.type isEqualToString:TTVPlayerActionType_LoadStateChanged]) {
        state.loadState = self.player.loadState;
    }
    else if ([action.type isEqualToString:TTVPlayerActionType_ReadyForDisplayChanged]) {
        state.readyForDisplay = self.player.readyForDisplay;
    }
    else if ([action.type isEqualToString:TTVPlayerActionType_Seeking_Start]) {
        state.seeking = YES;//self.player.isSeeking;
    }
    else if ([action.type isEqualToString:TTVPlayerActionType_Seeking_End]) {
        state.seeking = NO;//self.player.isSeeking;
    }
    else if ([action.type isEqualToString:TTVPlayerActionType_RetryStartPlay]) {
        state.finishViewState.playerErrorViewShouldShow = NO;
    }
    else if ([action.type isEqualToString:TTVPlayerActionType_PlayerErrorViewShowed]) { // 播放错误界面
        BOOL showed = [action.info[TTVPlayerActionInfo_isShowed] boolValue];
        if (showed/* && [self.player partControlForKey:TTVPlayerPartControlKey_PlayerErrorStayView]*/) {
            state.finishViewState.playerErrorViewShowed = YES;
        }
        else {
            state.finishViewState.playerErrorViewShowed = NO;
        }
    }
    // 锁屏相关
    else if ([action.type isEqualToString:TTVPlayerActionType_Lock]) {
        state.controlViewState.locked = YES;
    }
    else if ([action.type isEqualToString:TTVPlayerActionType_UnLock]) {
        state.controlViewState.locked = NO;
    }
    
    
    return state;
    
}

@end
