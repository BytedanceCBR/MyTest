//
//  TTVPlayerState.h
//  Article
//
//  Created by lisa on 2018/7/22.
//

#import "TTVReduxKit.h"
#import "TTVPlayerDefine.h"
#import "TTVPlaybackTime.h"
#import "TTVPlayFinishStatus.h"

// state
#import "TTVFullScreenState.h"
#import "TTVPlayerControlViewState.h"
#import "TTVSeekState.h"
#import "TTVNetworkMonitorState.h"
#import "TTVLoadingState.h"
#import "TTVGestureState.h"
#import "TTVPlayerFinishViewState.h"
#import "TTVSpeedState.h"

/**
 反应出目前播放器应该处在的状态，内核相关的状态, 以及由内核计算出的播放器 UI 的状态；
 @todo 如何解决不能直接修改的问题
 */
@interface TTVPlayerState : TTVReduxState<NSCopying>
///-----------------------------------------------------------------
/// @name 内核相关的状态
///-----------------------------------------------------------------
@property (nonatomic, assign) TTVPlaybackState      playbackState; // play/stop/pause/error
@property (nonatomic, strong) TTVPlaybackTime       *playbackTime; // 内核所有跟播放时间相关的进度
@property (nonatomic, strong) TTVPlayFinishStatus   *finishStatus; // 结束状态
@property (nonatomic, assign) TTVPlayerDataLoadState    loadState;     // loading状态
@property (nonatomic, copy)   NSString              *videoTitle;   // 视频标题
@property (nonatomic, assign) BOOL                  readyForDisplay;// 展示第一帧
@property (nonatomic, getter=isSeeking) BOOL        seeking;       //  播放器正在 seeking

// lock mute speed resolution
// 这里应该放 engine 的状态，而不应该再列举出来，导致重复

///-----------------------------------------------------------------
/// @name 播放器由内核计算出的UI状态
///-----------------------------------------------------------------
/// controlview 应该有的状态
@property (nonatomic, strong) TTVPlayerControlViewState *controlViewState;

/// 应该出 loadingView，此状态应该对应 playerVC 有 delegate
@property (nonatomic, strong) TTVLoadingState       *loadingViewState;

/// 应该出现播放完成界面
@property (nonatomic, strong) TTVPlayerFinishViewState *finishViewState;

/// 进度条状态
@property (nonatomic, strong) TTVSeekState        * seekStatus;

@property (nonatomic, strong) TTVSpeedState       * speedState;

///-----------------------------------------------------------------
/// @name 播放器整体UI 状态
///-----------------------------------------------------------------
/// 播放器目前的展示模式，其中全屏切换模块，可以改变此状态
@property (nonatomic, assign) TTVPlayerDisplayMode  displayMode;
/// 手势相关的状态
@property (nonatomic, strong) TTVGestureState       *gestureState;

///-----------------------------------------------------------------
/// @name 非内核相关状态
///-----------------------------------------------------------------
@property (nonatomic, strong) TTVFullScreenState    *fullScreenState;   // 屏幕旋转全屏
@property (nonatomic, strong) TTVNetworkMonitorState *networkState;


@end

