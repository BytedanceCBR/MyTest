//
//  TTVPlayerDefine.h
//  Pods
//
//  Created by lisa on 2019/1/4.
//
#ifndef TTVPlayerDefine_h
#define TTVPlayerDefine_h

#ifdef DEBUG
#define Debug_NSLog(...) NSLog(__VA_ARGS__)
#else
#define Debug_NSLog(...) void
#endif

#define TTVPlayerBundleName @"TTVPlayerResource"
#define TTVPlayerBundlePath [NSString stringWithFormat:@"%@/%@.bundle", [NSBundle mainBundle].resourcePath, TTVPlayerBundleName]
#define TTVPlayerResouceName(name) [NSString stringWithFormat:@"%@/%@", TTVPlayerBundlePath, name]

///-----------------------------------------------------------------
/// @name Player UI
///-----------------------------------------------------------------
/**
 播放器UI风格：
 TTVPlayerStyle_Simple：对应 TTVPlayerStyle_Simple.plist 和 simple 布局
 TTVPlayerStyle_XiGua：对应 TTVPlayerStyle_XiGua.plist 和 xigua 布局
 */
typedef NS_ENUM(NSUInteger, TTVPlayerStyle) { // player的布局风格, 是否应该改成 TTVPlayerUIStyle？？？
    TTVPlayerStyle_None = 0,    // 没设置 style，默认值
    // 带播放，进度相关，手势，播放错误，loading，流量提示
    TTVPlayerStyle_Simple_NoRotate = 1,
    // 在上面的基础上，增加全屏
    TTVPlayerStyle_Simple_CanRotate = 2,
    // 西瓜的布局+配置
    TTVPlayerStyle_XiGua = 3
};

/**
 当前播放器处于的展示模式，其中内嵌和全屏的 displaymode 可以相互切换的
 */
typedef NS_OPTIONS(NSUInteger, TTVPlayerDisplayMode) {
    TTVPlayerDisplayMode_Inline = 1 << 0,    // 内嵌，比如在列表中
    TTVPlayerDisplayMode_Fullscreen = 1 << 1,// 全屏, 竖屏和横屏都可以全屏展示
    TTVPlayerDisplayMode_Float = 1 << 2,     // 浮动展示
    TTVPlayerDisplayMode_All = TTVPlayerDisplayMode_Inline | TTVPlayerDisplayMode_Fullscreen | TTVPlayerDisplayMode_Float
};

typedef NS_ENUM(NSUInteger, TTVPlayerLayoutVerticalAlign) {
    TTVPlayerLayoutVerticalAlign_Top = 0,   // 垂直对齐-顶对齐
    TTVPlayerLayoutVerticalAlign_Center = 1,// 垂直对齐-中间对齐
    TTVPlayerLayoutVerticalAlign_bottom = 2 // 垂直对齐-底部对齐
};

///-----------------------------------------------------------------
/// @name player engine 的状态
///-----------------------------------------------------------------

/**
 播放状态, 播放内核状态
 */
typedef NS_ENUM(NSUInteger, TTVPlaybackState) {
    TTVPlaybackState_Stopped = 0,// 停止，也是默认状态
    TTVPlaybackState_Playing = 1,// 播放中
    TTVPlaybackState_Paused = 2, // 暂停
    TTVPlaybackState_Error = 3   // 播放错误
};

/// 视频清晰度
typedef NS_ENUM(NSUInteger, TTVPlayerResolutionTypes) {
    
    TTVPlayerResolutionType_SD = 0, //标清
    TTVPlayerResolutionType_HD = 1, //高清
    TTVPlayerResolutionType_FullHD = 2, //超清
    TTVPlayerResolutionType_1080P = 3,//1080P
    TTVPlayerResolutionType_4K = 4, //4K
    TTVPlayerResolutionType_Auto = 5, //自动调节
    TTVPlayerResolutionType_Unknown = 6 //未知
};

/**
 *  播放器engine的状态
 */
typedef NS_ENUM(NSUInteger, TTVPlayerEngineState) {
    TTVPlayerEngineState_Unknown = 0,
    TTVPlayerEngineState_FetchingInfo,
    TTVPlayerEngineState_ParsingDNS,
    TTVPlayerEngineState_PlayerRunning,
    TTVPlayerEngineState_Error
};

/**
 *  播放器加载的状态
 */
typedef NS_ENUM(NSUInteger, TTVPlayerDataLoadState) {
    TTVPlayerLoadState_Unknown = 0,
    TTVPlayerLoadState_Playable,
    TTVPlayerLoadState_Stalled,
    TTVPlayerLoadState_Error,
};

typedef NS_ENUM(NSUInteger, TTVPlayerAPIVersion) {
    TTVPlayerAPIVersion_0 = 0,
    TTVPlayerAPIVersion_1 = 1,
};

///-----------------------------------------------------------------
/// @name part
///-----------------------------------------------------------------

/// player pod 库现有支持的所有的 part
typedef NS_OPTIONS(NSUInteger, TTVPlayerPartKey) {
    /// 播放控制功能 1
    TTVPlayerPartKey_Play = 1 << 0,
    /// 进度控制功能 2
    TTVPlayerPartKey_Seek = 1 << 1,             // 进度拖动    0000 0010  2
    TTVPlayerPartKey_Back = 1 << 2,             // 返回 4

    TTVPlayerPartKey_Bar = 1 << 3,       // 导航栏配置   0000 1000  8
    TTVPlayerPartKey_Title = 1 << 4,    // 标题   0001 0000 16
    TTVPlayerPartKey_Full = 1 << 5,            // 全屏切换 32
    /// 锁屏功能 64
    TTVPlayerPartKey_Lock = 1 << 6,
    TTVPlayerPartKey_Loading = 1 << 7,          // 加载中      1000 0000 128
    TTVPlayerPartKey_PlayerFinish = 1 << 8,     // 播放器错误  256
    TTVPlayerPartKey_NetworkMonitor = 1 << 9,   // 弱网，无网络等提示功能 512
    TTVPlayerPartKey_Gesture = 1 << 10,         // 手势功能 1024
    
    /// 倍速播放功能，2048
    TTVPlayerPartKey_Speed = 1 << 11,
    /// 清晰度切换 4096
    TTVPlayerPartKey_Resolution = 1 << 12
};

typedef NS_OPTIONS(NSUInteger, TTVPlayerPartType) {
    TTVPlayerPartType_PlaybackControl = 1 << 0,// 播放控制：TTVPlayerPartKey_Play，TTVPlayerPartKey_Seek，TTVPlayerPartKey_Full
    TTVPlayerPartType_AfterPlay = 1 << 1,    // 播放器状态：TTVPlayerPartKey_Loading，TTVPlayerPartKey_PlayerFinish，TTVPlayerPartKey_NetworkMonitor
    TTVPlayerPartType_BeforePlay = 1 << 2,
};

/// 应该是一个 string ？？？？
typedef NS_OPTIONS(NSUInteger, TTVPlayerPartLoadTiming) {
    TTVPlayerPartLoadTiming_PlaybackControlShow = 1 << 0,
    TTVPlayerPartLoadTiming_AfterPlay = 1 << 1,
    TTVPlayerPartLoadTiming_BeforePlay = 1 << 2,
};

///**
// player pod 库
// 1、player 是否支持全屏， 可以通过 part 来设置是否支持全屏哈
// 2、现有 UI part 支持的布局位置，一个 UI 可以布局到 normal 也可以布局到 full，也可以都有【默认都有】
//    当player 是都有支持的，UI part 才会设置这个 Layout 的两种
// */

/**
 part 上 control 对应的 key
 */
//#define ttv_isTipView(tag) (tag >= 77700)?YES:NO

typedef NS_ENUM(NSUInteger, TTVPlayerPartControlKey) {
    TTVPlayerView_Tag = 6999,
    // TTVPlayerPartKey_Play
    TTVPlayerPartControlKey_PlayCenterToggledButton = 7771,          // 位于中间的播放按钮
    TTVPlayerPartControlKey_PlayBottomToggledButton = 7772,          // 位于底部的播放条按钮
    
    // TTVPlayerPartKey_Full
    TTVPlayerPartControlKey_FullToggledButton = 7774,                // 全屏按钮，位于底部 seek 旁边
    
    // TTVPlayerPartKey_Time
    TTVPlayerPartControlKey_TimeCurrentAndTotalLabel = 7775, // 当前和整体时间一起的控件
    TTVPlayerPartControlKey_TimeCurrentLabel = 7776,         // 当前时间
    TTVPlayerPartControlKey_TimeTotalLabel = 7777,           // 整体时间
    
    ///-----------------------------------------------------------------
    /// @name player TTVPlayerPartKey_Seek下的 control
    ///-----------------------------------------------------------------
    /// 控制态下的进度条
    TTVPlayerPartControlKey_Slider = 7778,              // progress view
    /// 沉浸式下的进度条，没有进度条点
    TTVPlayerPartControlKey_ImmersiveSlider = 7779,
    TTVPlayerPartControlKey_SeekingHUD = 77779,          // 当 seeking 的时候展示 HUD  也是 Tip
    
    // TTVNavigationPart
    TTVPlayerPartControlKey_TitleLabel = 7780,               // 展示 title
    TTVPlayerPartControlKey_BackButton = 7781,                // 返回按钮
    
    // bar
    TTVPlayerPartControlKey_TopBar = 7782,       // 顶部导航栏
    TTVPlayerPartControlKey_BottomBar = 7783,       // 底部工具栏
    
    /// 锁屏切换 button
    TTVPlayerPartControlKey_LockToggledButton = 7784,
    
    /// speed
    TTVPlayerPartControlKey_SpeedChangeButton = 7785,
    
    /// 非 control 的 都是 > 77700
    // TTVPlayerPartKey_Loading
    TTVPlayerPartControlKey_LoadingView = 77701,         // loading View
    
    // TTVPlayerPartKey_Tip
    TTVPlayerPartControlKey_PlayerErrorStayView = 77702, // 播放结束错误提示，会一直停留
    
    // NetWork
    TTVPlayerPartControlKey_FlowTipView = 77704, // 蜂窝网络，阻塞选择提示，TODO，全局提示都使用这个
    
    
};

/// 播放器中的 control 的 type
#define TTVPlayerPartControlType_ToggledButton  @"toggled_button"  // 可切换按钮，比如播放按钮
#define TTVPlayerPartControlType_Button         @"button"           // 不可切换点击的 button
#define TTVPlayerPartControlType_Label          @"label"            // label
#define TTVPlayerPartControlType_Slider         @"slider"
#define TTVPlayerPartControlType_SliderHUD      @"slider_hud"
#define TTVPlayerPartControlType_ProgressView   @"progress_view"   // 沉浸态下的slider
#define TTVPlayerPartControlType_ErrorView      @"errorview"
#define TTVPlayerPartControlType_LoadingView    @"loadingview"
#define TTVPlayerPartControlType_FlowView       @"flowview"

/// Add to playcontrolView， 可以作为 container 添加容器的几种类型
#define TTVPlayerPartControlType_None           @"none"// 交给 part 逻辑自己添加，config 不做处理

#define TTVPlayerPartControlType_TopNavBar      @"top_bar"
#define TTVPlayerPartControlType_BottomToolBar  @"bottom_bar"
#define TTVPlayerPartControlType_Content        @"content"

//
#define TTVPlayerPartControlType_OverlayControl @"overlay_control"
#define TTVPlayerPartControlType_UnderlayControl @"underlay_control"



///-----------------------------------------------------------------
/// @name 手势
///-----------------------------------------------------------------
typedef NS_OPTIONS(NSUInteger, TTVPlayerGestureOn) {
    TTVPlayerGestureOn_None = 0,
    TTVPlayerGestureOn_SingleTap = 1 << 0,
    TTVPlayerGestureOn_DoubleTap = 1 << 1,
    TTVPlayerGestureOn_Pan = 1 << 2,
    TTVPlayerGestureOn_All = TTVPlayerGestureOn_SingleTap | TTVPlayerGestureOn_DoubleTap | TTVPlayerGestureOn_Pan,
};
#endif /* TTVPlayerDefine_h */


