//
//  TTVGestureReducer.m
//  TTVPlayerPod
//
//  Created by lisa on 2019/3/4.
//

#import "TTVGestureReducer.h"
#import "TTVPlayerState.h"
#import "TTVPlayerAction.h"
#import "TTVPlayer+Engine.h"
#import "TTVPlayer+Part.h"
#import "TTVGesturePart.h"

@interface TTVGestureReducer ()

@property (nonatomic, weak) TTVPlayer * player;
@property (nonatomic, strong) TTVGestureState * normalSetting;// 用于存放 normal 下的设置
@property (nonatomic, strong) TTVGestureState * fullScreenSetting;// 用于存放 full 下的设置

@end

@implementation TTVGestureReducer

- (instancetype)initWithPlayer:(TTVPlayer *)player {
    self = [super init];
    if (self) {
        self.player = player;
    }
    return self;
}

- (TTVPlayerState *)executeWithAction:(TTVReduxAction *)action
                                state:(TTVPlayerState *)state {
    TTVGestureState * setting = state.fullScreenState.isFullScreen?self.fullScreenSetting:self.normalSetting;
    if ([action.type isEqualToString:TTVPlayerActionType_InitGestureSetting]) { // 初始化对
        self.normalSetting = action.info[@"inline"];
        self.fullScreenSetting = action.info[@"fullscreen"];
        setting = state.fullScreenState.isFullScreen?self.fullScreenSetting:self.normalSetting;

        state.gestureState.supportPanDirection = setting.supportPanDirection;
        state.gestureState.panGestureEnabled = setting.panGestureEnabled;
        state.gestureState.singleTapEnabled = setting.singleTapEnabled;
        state.gestureState.doubleTapEnabled = setting.doubleTapEnabled;
    }
    else if ([action.type isEqualToString:TTVPlayerActionType_RotateToLandscapeFullScreen] ||
              [action.type isEqualToString:TTVPlayerActionType_RotateToInlineScreen]) {
        
        TTVGestureState * setting = [action.type isEqualToString:TTVPlayerActionType_RotateToLandscapeFullScreen]?self.fullScreenSetting:self.normalSetting;

        state.gestureState.supportPanDirection = setting.supportPanDirection;
        state.gestureState.panGestureEnabled = setting.panGestureEnabled;
        state.gestureState.singleTapEnabled = setting.singleTapEnabled;
        state.gestureState.doubleTapEnabled = setting.doubleTapEnabled;
    }
    else if ([action.type isEqualToString:TTVPlayerActionType_GestureEnabled]) {
        NSDictionary * gestureEnable = action.info;
        TTVPlayerGestureOn gestureOn = [gestureEnable[TTVPlayerActionInfo_Enabled] integerValue];
        BOOL merge = [gestureEnable[TTVPlayerActionInfo_GestureEnabledMergeSetting] boolValue];
        if (gestureOn & TTVPlayerGestureOn_SingleTap) {
            state.gestureState.singleTapEnabled = merge?setting.singleTapEnabled:YES;
        }
        else {
             state.gestureState.singleTapEnabled = merge?setting.singleTapEnabled:NO;
        }
        if (gestureOn & TTVPlayerGestureOn_DoubleTap) {
            state.gestureState.doubleTapEnabled = merge?setting.doubleTapEnabled:YES;
        }
        else {
            state.gestureState.doubleTapEnabled = merge?setting.doubleTapEnabled:NO;
        }
        if (gestureOn & TTVPlayerGestureOn_Pan) {
            state.gestureState.panGestureEnabled = merge?setting.panGestureEnabled:YES;
        }
        else {
            state.gestureState.panGestureEnabled = merge?setting.panGestureEnabled:NO;
        }
    }
    
    return state;
}

@end
