//
//  TTVPlayerFullScreenReducer.m
//  TTVPlayer
//
//  Created by lisa on 2019/1/13.
//

#import "TTVFullScreenReducer.h"
#import "TTVPlayerAction.h"
#import "TTVPlayerState.h"

@interface TTVFullScreenReducer ()

@property (nonatomic) BOOL enableFullScreen;


@end

@implementation TTVFullScreenReducer

@synthesize store;

- (TTVPlayerState *)executeWithAction:(TTVReduxAction *)action
                                 state:(TTVPlayerState *)state {
    
    if ([action.type isEqualToString:TTVPlayerActionType_RotateToLandscapeFullScreen]) {
        state.fullScreenState.fullScreen = YES;
    }
    else if ([action.type isEqualToString:TTVPlayerActionType_RotateToInlineScreen]) {
        state.fullScreenState.fullScreen = NO;
    }
    return state;
}


@end
