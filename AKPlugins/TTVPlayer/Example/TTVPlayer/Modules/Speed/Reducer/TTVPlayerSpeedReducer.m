//
//  TTVPlayerReducerSpeed.m
//  TTVPlayer
//
//  Created by lisa on 2018/12/26.
//

#import "TTVPlayerSpeedReducer.h"
#import "TTVPlayerState.h"
#import "TTVPlayerAction.h"

@implementation TTVPlayerSpeedReducer

- (TTVRPlayerState *)executeWithAction:(TTVReduxAction *)action
                                         state:(TTVRPlayerState *)state {
    
    if ([action.type isEqualToString:TTVPlayerActionType_ChangeSpeed]) {
        // 修改 speed
        state.speedState.currentSpeed = MAX(1, [action.info[TTVPlayerActionInfo_Speed] floatValue]);
    }
    
    return state;
    
}

@end
