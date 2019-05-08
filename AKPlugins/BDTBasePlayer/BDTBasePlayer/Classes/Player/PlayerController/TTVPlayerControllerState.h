//
//  TTVPlayerControllerState.h
//  Pods
//
//  Created by panxiang on 2017/5/23.
//
//

#ifndef TTVPlayerControllerState_h
#define TTVPlayerControllerState_h

typedef NS_ENUM(NSUInteger, TTVPlayerSP) {
    TTVPlayerSPToutiao,
    TTVPlayerSPLeTV,
    TTVPlayerSPUnkown,
};

typedef NS_ENUM(NSInteger, TTVPlayerExitFullScreeenType) {
    TTVPlayerExitFullScreeenTypeUnknow,
    TTVPlayerExitFullScreeenTypeBackButton,
    TTVPlayerExitFullScreeenTypeFullButton,
    TTVPlayerExitFullScreeenTypeGravity
};

typedef NS_ENUM(NSUInteger, TTVPlayerOrientationState) {
    TTVPlayerOrientationStateNormal,
    TTVPlayerOrientationStateFull,
};


typedef NS_ENUM(NSInteger, TTVPlayerResolutionType) {
    /**
     *  标清
     */
    TTVPlayerResolutionTypeSD = 0,
    /**
     *  高清
     */
    TTVPlayerResolutionTypeHD = 1,
    /**
     *  超清
     */
    TTVPlayerResolutionTypeFullHD = 2,
    /**
     *  自动调节
     */
    TTVPlayerResolutionTypeAuto = 3,
    /**
     *  未知
     */
    TTVPlayerResolutionTypeUnkown = 4,

};

typedef NS_ENUM(NSInteger, TTVResolutionState) {
    TTVResolutionStateUnknow,
    TTVResolutionStateChanging,
    TTVResolutionStateEnd,
    TTVResolutionStateError,
};

typedef NS_ENUM(NSInteger, TTVVideoPlaybackState) {
    TTVVideoPlaybackStateUnknow,
    TTVVideoPlaybackStateFinished,//正常播放完成
    TTVVideoPlaybackStateBreak,//播放中断,stop了但是没有完成
    TTVVideoPlaybackStatePlaying,
    TTVVideoPlaybackStatePaused,
    TTVVideoPlaybackStateError,
};

typedef NS_ENUM(NSUInteger, TTVPlayerLoadState) {
    TTVPlayerLoadStateUnknown        = 0,
    TTVPlayerLoadStatePlayable,
    TTVPlayerLoadStateStalled,
//    TTVPlayerLoadStateError,
};

typedef NS_ENUM(NSUInteger, TTVPlayerControlTipViewType)
{
    TTVPlayerControlTipViewTypeUnknow = 0,
    TTVPlayerControlTipViewTypeNone,//透明,播放/暂停的时候使用.
    TTVPlayerControlTipViewTypeLoading,//loading状态
    TTVPlayerControlTipViewTypeRetry,//失败,重试状态
    TTVPlayerControlTipViewTypeFinished//播放结束状态
};

typedef NS_ENUM(NSUInteger, TTVPlayerControlViewToolBarState)
{
    TTVPlayerControlViewToolBarStateUnknow = 0,
    TTVPlayerControlViewToolBarStateWillShow,
    TTVPlayerControlViewToolBarStateDidShow,
    TTVPlayerControlViewToolBarStateWillHidden,
    TTVPlayerControlViewToolBarStateDidHidden
};

//typedef enum : NSUInteger {
//    TTVPlayActionDefault,
//    TTVPlayActionFromUIFinished,
//    TTVPlayActionTrafficContinue,
//    TTVPlayActionRetry,
//    TTVPlayActionEnterForground,
//} TTVPlayAction;

#define TTVPlayAction @"TTVPlayAction"
#define TTVPlayActionDefault @"TTVPlayActionDefault"
#define TTVPlayActionUserAction @"TTVPlayActionUserAction"
#define TTVPlayActionFromUIFinished @"TTVPlayActionFromUIFinished"
#define TTVPlayActionTrafficContinue @"TTVPlayActionTrafficContinue"
#define TTVPlayActionRetry @"TTVPlayActionRetry"
#define TTVPlayActionEnterForground @"TTVPlayActionEnterForground"

#define TTVPauseAction @"TTVPauseAction"
#define TTVPauseActionDefault @"TTVPauseActionDefault"
#define TTVPauseActionUserAction @"TTVPauseActionUserAction"
#define TTVPauseActionAppEnterBackgroud @"TTVPauseActionAppEnterBackgroud"
//typedef enum : NSUInteger {
//    TTVPauseActionDefault,
//    TTVPauseActionUserAction,
//    TTVPauseActionAppEnterBackgroud
//} TTVPauseAction;

typedef NS_ENUM(NSUInteger, TTVPlayerEventType) {
    //user
    TTVPlayerEventTypeUnknow = 0,
    TTVPlayerEventTypePlayerBeginPlay,//第一次播放才是Play 其余的暂停后播放都是resume
    TTVPlayerEventTypePlayerResume,//任何原因的播放中断后,重新恢复播放
    TTVPlayerEventTypePlayerPause,
    TTVPlayerEventTypePlayerStop,
    TTVPlayerEventTypeRetry, //播放失败后重试
    TTVPlayerEventTypePlayerSeekBegin,
    TTVPlayerEventTypePlayerSeekEnd,
    TTVPlayerEventTypeSwitchResolution,
    TTVPlayerEventTypePlayerContinuePlay,//暂停后,点击Play button 继续播放
    TTVPlayerEventTypeFinishedBecauseUserStopped, //正在播放时退出了，参考videoEngineUserStopped
    TTVPlayerEventTypeControlViewClickFullScreenButton,    //点击全屏按钮

    //player callback
    TTVPlayerEventTypeShowVideoFirstFrame,//播放第一帧
    TTVPlayerEventTypeEncounterError,//播放失败
    TTVPlayerEventTypeFinished,//播放结束
    TTVPlayerEventTypeLoadStateChanged,//loading 状态改变
    TTVPlayerEventTypePlaybackStateChanged,//播放状态改变

    //Traffic alert
    TTVPlayerEventTypeTrafficShow,//显示流量提示
    TTVPlayerEventTypeTrafficPlay, //流量提示点击继续播放
    TTVPlayerEventTypeTrafficStop,//流量提示点击暂停播放

    //横竖屏方向

    TTVPlayerEventTypeFinishUIShow,
    TTVPlayerEventTypeFinishUIReplay, //播放结束后重播
    TTVPlayerEventTypeFinishUIShare, //播放结束后分享
    TTVPlayerEventTypeControlViewClickScreen, //touch 视频播放器
    TTVPlayerEventTypeControlViewDoubleClickScreen, //double Click 视频播放器
    TTVPlayerEventTypeControlViewDragSliderTouchBegin,
    TTVPlayerEventTypeControlViewDragSlider, //drag slider
    /*
       payload     
     NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:@(NO),@"hidden",@(NO),@"autoHidden",nil];
     */
    TTVPlayerEventTypeControlViewHiddenToolBar, //隐藏/显示toolbar
    TTVPlayerEventTypeGoToDetail, //进入详情页
    TTVPlayerEventTypePlayingShare,//播放中的分享
    TTVPlayerEventTypePlayingMore, //播放中的更多
    TTVPlayerEventTypeFinishMore,
    TTVPlayerEventTypeFinishDirectShare, //播放结束的直接分享
    TTVPlayerEventTypePlayingDirectShare,
    //免流相关
    TTVPlayerEventTypeTrafficFreeFlowSubscribeShow, // 免流订阅提示
    TTVPlayerEventTypeTrafficWillOverFreeFlowShow, // 免流播放将要超量提示
    TTVPlayerEventTypeTrafficDidOverFreeFlowShow, // 免流播放已经超量提示
    TTVPlayerEventTypeTrafficFreeFlowPlay, // 免流继续播放
    TTVPlayerEventTypeTrafficFreeFlowSubscribe, // 免流点击进入订阅流程

    TTVPlayerEventTypePlaybackChangeToLowResolutionShow,//网络状态不好(卡顿了3次),提示用户切换到标清
    TTVPlayerEventTypePlaybackChangeToLowResolutionClick,//网络状态不好(卡顿了3次),提示用户切换到标清 ,用户点击操作
    
    TTVPlayerEventTypeVirtualStackValuePause, // 堆栈管理 Pause
    TTVPlayerEventTypeVirtualStackValuePlay, // 堆栈管理 Play
    
    TTVPlayerEventTypeRefreshTotalWatchTime, // 手动更新totalWatchTime
    TTVPlayerEventTypeAdDetailAction, // 视频是全屏的话要退出全屏
};

#endif /* TTVPlayerControllerState_h */



