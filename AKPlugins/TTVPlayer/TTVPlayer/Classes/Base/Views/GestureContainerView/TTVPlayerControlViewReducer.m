//
//  TTVPlayerControlViewReducer.m
//  TTVPlayer
//
//  Created by lisa on 2019/1/15.
//

#import "TTVPlayerControlViewReducer.h"
#import "TTVPlayerAction.h"
#import "TTVPlayerState.h"
#import "TTVPlayer.h"
#import "TTVSeekStatePrivate.h"


@interface TTVPlayerControlViewReducer ()

@property (nonatomic, weak) TTVPlayer * player;
@property (nonatomic) BOOL ignoreFirstShowSetting;

@end


@implementation TTVPlayerControlViewReducer

@synthesize store;

- (instancetype)initWithPlayer:(TTVPlayer *)player {
    self = [super init];
    if (self) {
        self.player = player;
    }
    return self;
}
- (TTVPlayerState *)executeWithAction:(TTVReduxAction *)action
                                 state:(TTVPlayerState *)state {
    
    if ([action.type isEqualToString:TTVPlayerActionType_Pan]) {
        // action.info
        UIPanGestureRecognizer * gestureRecognizer = action.info[TTVPlayerActionInfo_Pan_GestureRecogizer];
        
        switch (gestureRecognizer.state) {
            case UIGestureRecognizerStateBegan: {
                state.controlViewState.panning = YES;
            }
                break;
            
            case UIGestureRecognizerStateEnded:
            case UIGestureRecognizerStateCancelled: {
                state.controlViewState.panning = NO;
            }
                break;
            default:
                break;
        }
    }
    else if ([action.type isEqualToString:TTVPlayerActionType_SingleTap]) {
        if (!state.speedState.speedSelectViewShowed) {
            state.controlViewState.showed = !state.controlViewState.isShowed;
        }
        else {
            [self.store dispatch:[self.player.playerAction showSpeedSelectViewAction:NO]];
        }
    }
    else if ([action.type isEqualToString:TTVPlayerActionType_ShowControlView]) {
        state.controlViewState.showed = [action.info[TTVPlayerActionInfo_isShowed] boolValue];
    }
    
    return state;
    
}

@end
