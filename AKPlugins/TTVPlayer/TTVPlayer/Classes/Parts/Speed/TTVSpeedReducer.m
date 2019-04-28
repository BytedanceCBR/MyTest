//
//  TTVSpeedReducer.m
//  TTVPlayerPod
//
//  Created by lisa on 2019/4/24.
//

#import "TTVSpeedReducer.h"
#import "TTVPlayer.h"
#import "TTVPlayer+Engine.h"

@interface TTVSpeedReducer ()

@property (nonatomic, weak) TTVPlayer * player;

@end


@implementation TTVSpeedReducer

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
    
    if ([action.type isEqualToString:TTVPlayerActionType_ChangeSpeed]) {
        // 修改 speed
        state.speedState.speed = self.player.playbackSpeed;
    }
    else if ([action.type isEqualToString:TTVPlayerActionType_SpeedSelectViewShowed]) {
        BOOL show = [action.info[TTVPlayerActionInfo_isShowed] boolValue];
        state.speedState.speedSelectViewShowed = show;
        [self.store dispatch:[TTVReduxAction actionWithType:TTVPlayerActionType_ShowControlView info:@{TTVPlayerActionInfo_isShowed:@(!show)}]];
    }
    else if ([action.type isEqualToString:TTVPlayerActionType_ShowSpeedSelectView]) {
        BOOL show = [action.info[TTVPlayerActionInfo_isShowed] boolValue];
        state.speedState.speedSelectViewShouldShow = show;
    }
    
    return state;
    
}

@end
