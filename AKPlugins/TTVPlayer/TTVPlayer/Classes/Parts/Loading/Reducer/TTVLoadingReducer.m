//
//  TTVLoadingReducer.m
//  TTVPlayer
//
//  Created by lisa on 2019/2/15.
//

#import "TTVLoadingReducer.h"
#import "TTVLoadingState.h"
#import "TTVPlayer+Engine.h"


@interface TTVLoadingReducer ()

@property (nonatomic, weak) TTVPlayer * player;

@end

@implementation TTVLoadingReducer

- (instancetype)initWithPlayer:(TTVPlayer *)player {
    self = [super init];
    if (self) {
        self.player = player;
    }
    return self;
}
- (TTVPlayerState *)executeWithAction:(TTVReduxAction *)action
                                 state:(TTVPlayerState *)state {
    
    if ([action.type isEqualToString:TTVPlayerActionType_FinishStatusChanged]) {
        state.loadingViewState.shouldShow = NO;
    }
    else if ([action.type isEqualToString:TTVPlayerActionType_LoadStateChanged]) {
        TTVPlayerLoadStateNew loadState = self.player.loadState;
        if (loadState == TTVPlayerLoadState_Playable) {
            state.loadingViewState.shouldShow = NO;
        }
        else //if (loadState == TTVPlayerLoadState_Stalled || TTVPlayerLoadState_Unknown || TTVPlayerLoadState_Error) {
        {
            state.loadingViewState.shouldShow = YES;
        }
    }
    else if ([action.type isEqualToString:TTVPlayerActionType_StartPlay] ||
             [action.type isEqualToString:TTVPlayerActionType_RetryStartPlay]) {
        state.loadingViewState.shouldShow = (self.player.loadState != TTVPlayerLoadState_Playable)?YES:NO;
    }
//    else if ([action.type isEqualToString:TTVPlayerActionType_RetryStartPlay]) {
//        state.loadingViewState.shouldShow = YES;
//    }
    else if ([action.type isEqualToString:TTVPlayerActionType_LoadingShowed]) {
        BOOL showed = [action.info[TTVPlayerActionInfo_isShowed] boolValue];
        if (showed/* && [self.player partControlForKey:TTVPlayerPartControlKey_LoadingView]*/) {
            state.loadingViewState.showed = YES;
        }
        else {
            state.loadingViewState.showed = NO;
        }
    }
    return state;
}

@end
