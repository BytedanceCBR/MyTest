//
//  TTVPlayerAction.m
//  TTVPlayerPod
//
//  Created by lisa on 2019/2/26.
//

#import "TTVPlayerAction.h"
#import "TTVPlayerDefine.h"
#import "TTVPlayer.h"
#import "TTVPlayer+Engine.h"

// part
#import "TTVFullScreenPart.h"


NSString * const TTVPlayerActionInfo                            = @"TTVPlayerActionInfo";/// 通用的 actionInfoKey

NSString * const TTVPlayerActionInfo_isShowed                   = @"TTVPlayerActionInfo_isShowed";/// 通用的 actionInfoKey == show
NSString * const TTVPlayerActionInfo_Enabled                    = @"TTVPlayerActionInfo_Enabled";/// 通用的 actionInfoKey == show

///-----------------------------------------------------------------
/// 内核状态变化事件：主要是Engine 提供的事件
///-----------------------------------------------------------------
NSString * const TTVPlayerActionType_StartPlay                  = @"TTVPlayerActionType_StartPlay";/// 起播
NSString * const TTVPlayerActionType_RetryStartPlay             = @"TTVPlayerActionType_RetryStartPlay";/// 起播重试
NSString * const TTVPlayerActionType_Pause                      = @"TTVPlayerActionType_Pause";
NSString * const TTVPlayerActionType_Resume                     = @"TTVPlayerActionType_Resume";

NSString * const TTVPlayerActionType_PlaybackStateDidChanged    = @"TTVPlayerActionType_PlaybackStateDidChanged";/// 播放状态变化

NSString * const TTVPlayerActionType_ReadyForDisplayChanged     = @"TTVPlayerActionType_ReadyForDisplayChanged";/// 第一帧播放变化

NSString * const TTVPlayerActionType_LoadStateChanged           = @"TTVPlayerActionType_LoadStateChanged";/// loading 状态变化

NSString * const TTVPlayerActionType_PlayBackTimeChanged        = @"TTVPlayerActionType_PlayBackTimeChanged";/// 播放时间变化

NSString * const TTVPlayerActionType_FinishStatusChanged        = @"TTVPlayerActionType_FinishStatusChanged";/// 播放完成状态变化
NSString * const TTVPlayerActionInfo_FinishStatus               = @"TTVPlayerActionInfo_FinishStatus";

NSString * const TTVPlayerActionType_Seeking_Start              = @"TTVPlayerActionType_Seeking_Start";/// 开始 seek

NSString * const TTVPlayerActionType_Seeking_End                = @"TTVPlayerActionType_Seeking_End";/// 结束 seek

NSString * const TTVPlayerActionType_VideoTitleChanged          = @"TTVPlayerActionType_VideoTitleChanged";/// title 变化

///-----------------------------------------------------------------
/// 手势
///-----------------------------------------------------------------

NSString * const TTVPlayerActionType_InitGestureSetting         = @"TTVPlayerActionType_InitGestureSetting";/// 初始化手势配置

NSString * const TTVPlayerActionType_SingleTap                  = @"TTVPlayerActionType_SingleTap";/// 单击手势
/// 双击手势
NSString * const TTVPlayerActionType_DoubleTap                  = @"TTVPlayerActionType_DoubleTap";
/// 拖动手势
NSString * const TTVPlayerActionType_Pan                        = @"TTVPlayerActionType_Pan";
NSString * const TTVPlayerActionInfo_Pan_Direction              = @"TTVPlayerActionInfo_Pan_Direction";
NSString * const TTVPlayerActionInfo_Pan_GestureRecogizer       = @"TTVPlayerActionInfo_Pan_GestureRecogizer";
NSString * const TTVPlayerActionInfo_Pan_ViewAddedPanGesture    = @"TTVPlayerActionInfo_Pan_ViewAddedPanGesture";
NSString * const TTVPlayerActionInfo_IsSwiped                   = @"TTVPlayerActionInfo_IsSwiped";
/// 手势是否enabled
NSString * const TTVPlayerActionType_GestureEnabled             = @"TTVPlayerActionType_GestureEnabled";
NSString * const TTVPlayerActionInfo_GestureEnabledMergeSetting = @"TTVPlayerActionInfo_GestureEnabledMergeSetting";

///-----------------------------------------------------------------
/// controlView
///-----------------------------------------------------------------
/// 是否要显示或者隐藏 controlView
NSString * const TTVPlayerActionType_ShowControlView            = @"TTVPlayerActionType_ShowControlView";

///-----------------------------------------------------------------
/// @name fullscreen
///-----------------------------------------------------------------
/// 切换到全屏横屏的
NSString * const TTVPlayerActionType_RotateToLandscapeFullScreen= @"TTVPlayerActionType_RotateToLandscapeFullScreen";
/// 回退到 inline 屏
NSString * const TTVPlayerActionType_RotateToInlineScreen       = @"TTVPlayerActionType_RotateToInlineScreen";

///-----------------------------------------------------------------
/// @name 界面展示后的 action
///-----------------------------------------------------------------
NSString * const TTVPlayerActionType_PlayerErrorViewShowed      = @"TTVPlayerActionType_PlayerErrorViewShowed";/// 界面已经展示播放错误
NSString * const TTVPlayerActionType_LoadingShowed              = @"TTVPlayerActionType_LoadingShowed";/// 界面已经展示 loading view
NSString * const TTVPlayerActionType_CellularNetTipViewShowed   = @"TTVPlayerActionType_CellularNetTipViewShowed";/// 界面已经展示 tipview
NSString * const TTVPlayerActionType_SliderPan                  = @"TTVPlayerActionType_SliderPan";/// slider 控件 是否正在拖动
NSString * const TTVPlayerActionInfo_isSliderPanning            = @"TTVPlayerActionInfo_isSliderPanning";
NSString * const TTVPlayerActionType_SliderHudShowed            = @"TTVPlayerActionType_SliderHudShowed";/// 界面已经展示 slider 的抬头显示

///-----------------------------------------------------------------
/// @name 返回 action
///-----------------------------------------------------------------
NSString * const TTVPlayerActionType_Back                       = @"TTVPlayerActionType_Back";
///-----------------------------------------------------------------
/// @name 锁屏
///-----------------------------------------------------------------
NSString * const TTVPlayerActionType_Lock                       = @"TTVPlayerActionType_Lock";
NSString * const TTVPlayerActionType_UnLock                     = @"TTVPlayerActionType_UnLock";
///-----------------------------------------------------------------
/// @name 倍速
///-----------------------------------------------------------------
NSString * const TTVPlayerActionType_ChangeSpeed                = @"TTVPlayerActionType_ChangeSpeed";
NSString * const TTVPlayerActionType_SpeedSelectViewShowed      = @"TTVPlayerActionType_SpeedSelectViewShowed";
NSString * const TTVPlayerActionType_ShowSpeedSelectView        = @"TTVPlayerActionType_ShowSpeedSelectView";


@interface TTVPlayerAction ()
@property (nonatomic, weak)TTVPlayer *player;
@end


@implementation TTVPlayerAction
- (instancetype)initWithPlayer:(TTVPlayer *)player {
    self = [super init];
    if (self) {
        self.player = player;
    }
    return self;
}

- (TTVReduxAction *)actionForKey:(NSString *)key {
    if (isEmptyString(key)) {
        return nil;
    }
    else if ([key isEqualToString:TTVPlayerActionType_Back]) {
        return [self backAction];
    }
    else if ([key isEqualToString:TTVPlayerActionType_Pause]) {
        return [self pauseAction];
    }
    else if ([key isEqualToString:TTVPlayerActionType_ChangeSpeed]) {
        return nil;
    }
    return [[TTVReduxAction alloc] initWithType:key];
}

- (TTVReduxAction *)backAction {
    TTVReduxAction * action = [[TTVReduxAction alloc] initWithTarget:TTVPlayerUtility.class selector:@selector(quitCurrentViewController) params:nil actionType:TTVPlayerActionType_Back];
    return action;
}

- (TTVReduxAction *)enableGesture:(TTVPlayerGestureOn)onGesture mergeWithSetting:(BOOL)mergeWithSetting {
    NSMutableDictionary * gestureEnable = @{}.mutableCopy;
    gestureEnable[TTVPlayerActionInfo_Enabled] = @(onGesture);
    gestureEnable[TTVPlayerActionInfo_GestureEnabledMergeSetting] = @(mergeWithSetting);
    TTVReduxAction * action = [[TTVReduxAction alloc] initWithType:TTVPlayerActionType_GestureEnabled info:gestureEnable];
    return action;
}

- (TTVReduxAction *)retryStartPlayAction {
    TTVReduxAction * action = [[TTVReduxAction alloc] initWithType:TTVPlayerActionType_RetryStartPlay];
    return action;
}
- (TTVReduxAction *)startPlayAction {
    TTVReduxAction * action = [[TTVReduxAction alloc] initWithType:TTVPlayerActionType_StartPlay];
    return action;
}
- (TTVReduxAction *)pauseAction {
    TTVReduxAction * action = [[TTVReduxAction alloc] initWithTarget:self.player selector:@selector(pause) params:nil actionType:TTVPlayerActionType_Pause];
    return action;
}
- (TTVReduxAction *)resumeAction {
    TTVReduxAction * action = [[TTVReduxAction alloc] initWithTarget:self.player selector:@selector(resume) params:nil actionType:TTVPlayerActionType_Resume];
    return action;
}

- (TTVReduxAction *)changeSpeedToAction:(CGFloat)speed {
    TTVReduxAction * action = [[TTVReduxAction alloc] initWithType:TTVPlayerActionType_ChangeSpeed];//[[TTVReduxAction alloc] initWithTarget:self.player selector:@selector(setPlaybackSpeed:) params:@[@(speed)] actionType:TTVPlayerActionType_ChangeSpeed];
    self.player.playbackSpeed = speed;
    return action;
}

- (TTVReduxAction *)showSpeedSelectViewAction:(BOOL)show {
    return [TTVReduxAction actionWithType:TTVPlayerActionType_ShowSpeedSelectView info:@{TTVPlayerActionInfo_isShowed:@(show)}];
}
- (TTVReduxAction *)showControlViewAction:(BOOL)show {
    return [TTVReduxAction actionWithType:TTVPlayerActionType_ShowControlView info:@{TTVPlayerActionInfo_isShowed:@(show)}];
}

@end
