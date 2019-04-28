//
//  TTVPlayerAction.h
//  TTVideoEngine
//
//  Created by lisa on 2019/1/4.
//

#import "TTVReduxAction.h"
#import "TTVPlayerDefine.h"

NS_ASSUME_NONNULL_BEGIN

/// 通用的 actionInfoKey
extern NSString * const TTVPlayerActionInfo;
/// 通用的 actionInfoKey == show
extern NSString * const TTVPlayerActionInfo_isShowed;
extern NSString * const TTVPlayerActionInfo_Enabled;/// 通用的 actionInfoKey == show

///-----------------------------------------------------------------
/// @name 内核状态变化事件：主要是Engine 提供的事件
///-----------------------------------------------------------------
/// 起播
extern NSString * const TTVPlayerActionType_StartPlay;
/// 起播重试
extern NSString * const TTVPlayerActionType_RetryStartPlay;
/// 暂停
extern NSString * const TTVPlayerActionType_Pause;
/// resume
extern NSString * const TTVPlayerActionType_Resume;

/// 播放状态变化
extern NSString * const TTVPlayerActionType_PlaybackStateDidChanged;
/// 第一帧播放变化
extern NSString * const TTVPlayerActionType_ReadyForDisplayChanged;
/// loading 状态变化
extern NSString * const TTVPlayerActionType_LoadStateChanged;
/// 播放时间变化
extern NSString * const TTVPlayerActionType_PlayBackTimeChanged;
/// 播放完成状态变化
extern NSString * const TTVPlayerActionType_FinishStatusChanged;
extern NSString * const TTVPlayerActionInfo_FinishStatus;
/// 开始 seek
extern NSString * const TTVPlayerActionType_Seeking_Start;
/// 结束 seek
extern NSString * const TTVPlayerActionType_Seeking_End;
/// title 变化
extern NSString * const TTVPlayerActionType_VideoTitleChanged;

///-----------------------------------------------------------------
/// @name 手势
///-----------------------------------------------------------------
/// 初始化手势配置
extern NSString * const TTVPlayerActionType_InitGestureSetting;
/// 单击手势
extern NSString * const TTVPlayerActionType_SingleTap;
/// 双击手势
extern NSString * const TTVPlayerActionType_DoubleTap;
/// controlView 拖动手势
extern NSString * const TTVPlayerActionType_Pan;
extern NSString * const TTVPlayerActionInfo_Pan_Direction;
extern NSString * const TTVPlayerActionInfo_Pan_GestureRecogizer;
extern NSString * const TTVPlayerActionInfo_Pan_ViewAddedPanGesture;
extern NSString * const TTVPlayerActionInfo_IsSwiped;
/// 手势是否enabled
extern NSString * const TTVPlayerActionType_GestureEnabled;
extern NSString * const TTVPlayerActionInfo_GestureEnabledMergeSetting;
///-----------------------------------------------------------------
/// @name controlView
///-----------------------------------------------------------------
/// 是否要显示或者隐藏 controlView
extern NSString * const TTVPlayerActionType_ShowControlView;

///-----------------------------------------------------------------
/// @name fullscreen
///-----------------------------------------------------------------
/// 切换到全屏横屏的
extern NSString * const TTVPlayerActionType_RotateToLandscapeFullScreen;
/// 回退到 inline 屏
extern NSString * const TTVPlayerActionType_RotateToInlineScreen;

///-----------------------------------------------------------------
/// @name 界面展示后的 action
///-----------------------------------------------------------------
/// 界面已经展示播放错误
extern NSString * const TTVPlayerActionType_PlayerErrorViewShowed;
/// 界面已经展示 loading view
extern NSString * const TTVPlayerActionType_LoadingShowed;
/// 界面已经展示 tipview
extern NSString * const TTVPlayerActionType_CellularNetTipViewShowed;
/// slider 控件 是否正在拖动
extern NSString * const TTVPlayerActionType_SliderPan;
extern NSString * const TTVPlayerActionInfo_isSliderPanning;
/// 界面已经展示 slider 的抬头显示
extern NSString * const TTVPlayerActionType_SliderHudShowed;
/// 返回
extern NSString * const TTVPlayerActionType_Back;

///-----------------------------------------------------------------
/// @name 锁屏
///-----------------------------------------------------------------
extern NSString * const TTVPlayerActionType_Lock;
extern NSString * const TTVPlayerActionType_UnLock;
///-----------------------------------------------------------------
/// @name 倍速
///-----------------------------------------------------------------
extern NSString * const TTVPlayerActionType_ChangeSpeed;
extern NSString * const TTVPlayerActionType_SpeedSelectViewShowed;
extern NSString * const TTVPlayerActionType_ShowSpeedSelectView;

#pragma mark - action 类，更方便使用
///-----------------------------------------------------------------
/// @name action 类，更方便使用
///-----------------------------------------------------------------

@class TTVPlayer;
@interface TTVPlayerAction : TTVReduxAction

- (instancetype)initWithPlayer:(TTVPlayer *)player;

- (TTVReduxAction *)actionForKey:(NSString *)key;



///-----------------------------------------------------------------
/// @name action 返回
///-----------------------------------------------------------------
- (TTVReduxAction *)backAction;
///-----------------------------------------------------------------
/// @name 手势
///-----------------------------------------------------------------
/// 开关手势功能 @see TTVPlayerGestureOn
/**
 手势功能禁用与解禁

 @param onGesture @see TTVPlayerGestureOn
 @param mergeWithSetting 是否跟 setting 进行 merge，当跟 setting 出现不同值，以 setting 为主
 @return TTVReduxAction
 */
- (TTVReduxAction *)enableGesture:(TTVPlayerGestureOn)onGesture mergeWithSetting:(BOOL)mergeWithSetting;

- (TTVReduxAction *)startPlayAction;
- (TTVReduxAction *)retryStartPlayAction;

- (TTVReduxAction *)pauseAction;
- (TTVReduxAction *)resumeAction;

///-----------------------------------------------------------------
/// @name speed
///-----------------------------------------------------------------
- (TTVReduxAction *)changeSpeedToAction:(CGFloat)speed;
- (TTVReduxAction *)showSpeedSelectViewAction:(BOOL)show;

- (TTVReduxAction *)showControlViewAction:(BOOL)show;

@end


NS_ASSUME_NONNULL_END
