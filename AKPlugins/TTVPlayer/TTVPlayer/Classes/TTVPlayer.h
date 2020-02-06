//
//  TTVPlayer.h
//  Article
//
//  Created by lisa on 2018/3/1.
//

#import <UIKit/UIKit.h>
#import "TTVPlayerDefine.h"
#if __has_include(<TTVideoEngineHeader.h>)
#import <TTVideoEngineHeader.h>
#else
#import "TTVideoEngine.h"
#endif

#import "TTVPlayerContexts.h"
#import "TTVPlayerPartProtocol.h"
#import "TTVPlayerState.h"
#import "TTVPlaybackTime.h"
#import "TTVPlayerGestureContainerView.h"
#import "TTVPlaybackControlView.h"
#import "TTVPlayerCustomViewDelegate.h"
#import "TTVPlayerCustomPartDelegate.h"

@protocol TTVPlayerDelegate;

/**
 TTVPlayer 是带有界面功能的播放器，继承自 UIViewController，具体功能如下：
 1、提供 Engine 的视频播放等基础功能；@see TTVPlayer+Engine category
 2、提供播放器整体内置功能 UI 以及 内置功能自定义 UI 功能，@see TTVPlayerCustomViewDelegate @see TTVPlayerDelegate
 3、提供静态动态对播放器模块（part：携带的 UI 相关功能）进行增加以及移除功能；达到使用一个类，配置不同功能的播放器的目的 @see TTVPlayerPartProtocol
 4、自定义 part，当内置 part 不满足需求时，可以在此系统结构上，自定义 part进行功能改造和增加，@see TTVPlayerCustomPartDelegate
 历史都使用TTVideoEngine，TTVPlayer把 videoEngine 包装起来，隐藏内核的一切, 用于未来切换成 TTAVPlayer 或者加入直播 TTLiveVideo, 对外都可以无感知。请大家使用 TTVPlayer，代替 TTVideoEngine.
 请参考接入文档 https://bytedance.feishu.cn/space/doc/doccnG2WtLMqCbYPyNywKV#
 */
@interface TTVPlayer : UIViewController

#pragma mark - Initialization
///-----------------------------------------------------------------
/// @name Initialization
///-----------------------------------------------------------------
/**
 创建 player， 内置的标准化播放器已经可以满足需求，不用写布局函数以及不需要单独引入配置文件进行配置
 一个 style 对应着一个 plist(默认) 配置文件和一个布局样式
 
 @param isOwnPlayer 是否自研
 @param style plist 配置文件和一个布局样式
 @return self
 @see TTVPlayerStyle
 */
- (instancetype)initWithOwnPlayer:(BOOL)isOwnPlayer style:(TTVPlayerStyle)style;

/**
 创建player,内置的播放器无法满足需求，需要通过配置文件进行对功能模块以及 UI 样式的定制, 默认采用一种 @see TTVPlayerStyle  的布局，
 并有必要时同时实现@see TTVPlayerDelegate中viewDidLayoutSubviews 的方法，有必要还需要实现viewDidLayoutSubviews 对 UI 进行布局调整
 
 @param isOwnPlayer  是否自研
 @param configFileName 配置文件的名称（带后缀名称）, 从mainbundle读取 eg:TTVPlayerStyle.plist
 @return self
 */
- (instancetype)initWithOwnPlayer:(BOOL)isOwnPlayer configFileName:(NSString *)configFileName;

/**
 上面函数的 bundle 可以支持从外部传入
 
 @param isOwnPlayer  是否自研
 @param configFileName  配置文件的名称（带后缀名称）eg:TTVPlayerStyle.plist
 @param bundle 不传的版本为 mainbundle，可以支持从别的 bundle 组件传入，注意，后面自定义的图片等资源默认都是来自这个自定义的 bundle
 @return self
 */
- (instancetype)initWithOwnPlayer:(BOOL)isOwnPlayer configFileName:(NSString *)configFileName bundle:(NSBundle *)bundle;

/**
 创建原始的 player，不带 可配置 part 任何功能, 无手势和 control 等相关功能
 不能通过UI 控制播放器，适用于只有一个播放视频的界面的产品
 注意：使用此方式也无法动态加入配置，如果需要自定义配置，需要通过上面两个函数进行修改
 setIgnoreAudioInterruption = YES

 @param isOwnPlayer  是否自研
 @return self
 */
- (instancetype)initWithOwnPlayer:(BOOL)isOwnPlayer;

/**
 激活OpenGLES 环境
 请在- (void)applicationDidBecomeActive:(UIApplication *)application {中调用, 否则会无法展示播放器，如果发现有黑屏，请查看此处设置
 */
+ (void)startOpenGLESActivity;

/**
 关闭OpenGLES 环境
 You should call this method in app delegate's applicationWillResignActive: method, or it may leads to crash
 */
+ (void)stopOpenGLESActivity;

#pragma mark - delegate
///-----------------------------------------------------------------
/// @name delegate
///-----------------------------------------------------------------
///TTVPlayerDelegate 包含了播放器控制器布局时机以及播放器状态相关的回调，如果有需要可以自行实现 @see TTVPlayerDelegate
@property (nonatomic, weak) NSObject<TTVPlayerDelegate> *delegate;

/// 自定义 view 提供内置播放器控件相关的自定义API @see TTVPlayerCustomViewDelegate
@property (nonatomic, weak) NSObject<TTVPlayerCustomViewDelegate> * customViewDelegate;
//- (void)setCustomViewDelegate:(NSObject<TTVPlayerCustomViewDelegate> *)customViewDelegate;
//- (id<TTVPlayerCustomViewDelegate>)customViewDelegate;

/// 自定义 part, 提供自定义 part, 可以覆盖已有的 part 以及新增外部 part @see TTVPlayerCustomPartDelegate
@property (nonatomic, weak) NSObject<TTVPlayerCustomPartDelegate> * customPartDelegate;

#pragma mark - 播放器 UI
///-----------------------------------------------------------------
/// @name 播放器 UI
///-----------------------------------------------------------------
/// 第一帧可以展示
@property (nonatomic, assign, readonly) BOOL  readyForDisplay;
/// 播放视频的 view, Engine提供的
@property (nonatomic, strong, readonly) UIView * playerView;

/// 除了视频播放view之外，看到的所有 view 都加在这个 view 上；这个 view 可以响应单击、双击、滑动等手势以及处理相关冲突 @see TTVPlayerGestureContainerView
@property (nonatomic, strong, readonly) TTVPlayerGestureContainerView * containerView;

/// unlock 状态下可以控制播放的 UI 都加在这个 view 上, 上面的control 可以自动消失，是 containerView 的一个 subview @see TTVPlayerGestureContainerView
@property (nonatomic, strong, readonly) TTVPlaybackControlView * controlView;

/// lock 状态下可以控制播放的 UI 都加在这个 view 上, 上面的control 可以自动消失，是 containerView 的一个 subview @see TTVPlayerGestureContainerView
@property (nonatomic, strong, readonly) TTVPlaybackControlView * controlViewLocked;

/// 在 controlView 和 controlViewLocked 下面的 view
@property (nonatomic, strong, readonly) UIView * controlUnderlayView;

/// 在 controlView 和 controlViewLocked 上面的 view
@property (nonatomic, strong, readonly) UIView * controlOverlayView;

/// 返回 button，默认隐藏，需要外界使用者来控制显示状态 TODO
//@property (nonatomic, strong, readonly) UIButton *backButton;

/**
 在 player 的  TTVPlaybackControlView 上面添加 view， 主要用户添加提示控件
 @see https://bytedance.feishu.cn/space/doc/doccnG2WtLMqCbYPyNywKV#eh7tny 查看 view 层级

 @param view  不可以控制播放器，主要是提示类型的比如 loading 等
 */
- (void)addViewOverlayPlaybackControls:(UIView *)view;
/**
 在 player 的 @see TTVPlaybackControlView (unlock 状态下的)区域添加控件；
 @see https://bytedance.feishu.cn/space/doc/doccnG2WtLMqCbYPyNywKV#eh7tny 查看 view 层级
 
 @param view 需要加入到控制层的 view
 @param containerString
 #define TTVPlayerPartControlType_TopNavBar      @"top_bar"
 #define TTVPlayerPartControlType_BottomToolBar  @"bottom_bar"
 #define TTVPlayerPartControlType_Content        @"content"
 */
- (void)addPlaybackControl:(UIView *)view addToContainer:(NSString *)containerString;

/**
 在 player 的 @see TTVPlaybackControlView (lock 状态下的)区域添加控件；
 @see https://bytedance.feishu.cn/space/doc/doccnG2WtLMqCbYPyNywKV#eh7tny 查看 view 层级
 
 @param view 需要加入到控制层的 view
 @param containerString
 #define TTVPlayerPartControlType_TopNavBar      @"top_bar"
 #define TTVPlayerPartControlType_BottomToolBar  @"bottom_bar"
 #define TTVPlayerPartControlType_Content        @"content"
 */
- (void)addPlaybackControlLocked:(UIView *)view addToContainer:(NSString *)containerString;

/**
 在 Player Control 的下面加入 view
 @see https://bytedance.feishu.cn/space/doc/doccnG2WtLMqCbYPyNywKV#eh7tny 查看 view 层级
 
 @param view 要加入到 Playcontrol 上面的 view，不会随着 playbackControl 的消失而消失
 */
- (void)addViewUnderlayPlaybackControls:(UIView *)view;

/**
 通过 view 的 key 获取到已经加入到 player 的view，key 需要跟 control 可以对应上,系统只认 key
 需要有函数能够使用需要这个 view 的时候提供这个 view 的创建方法
 
 @param key 控件的 key
 @return 已经加入到 player 的 view 上的 控件
 */
- (UIView *)partControlForKey:(TTVPlayerPartControlKey)key;

/// 当第一次load player 的 view 之后，是否展示control 控件，默认是 YES，展示
@property (nonatomic) BOOL showPlaybackControlsOnViewFirstLoaded;

/// 播放控件是否会自动隐藏掉，默认为 YES 会自动隐藏
@property (nonatomic) BOOL supportPlaybackControlAutohide;

/// 没有播放控制层：默认为 NO；如果设置为 YES，将只有沉浸态, 如果是 NO，需要在初始化的时候设置一次，否则会出现
@property (nonatomic) BOOL enableNoPlaybackStatus;

/// 视频标题
@property (nonatomic, copy) NSString *videoTitle;

/**
 获取某个清晰度下，视频的大小，可以用于流量提示

 @param type @see TTVPlayerResolutionTypes
 @return 视频大小，单位是 bit，需要自行转化为 kb 或者 M 进行显示
 */
- (NSInteger)videoSizeForType:(TTVPlayerResolutionTypes)type;

/**
 当前清晰度下，视频尺寸

 @return 视频大小，单位是 bit，需要自行转化为 kb 或者 M 进行显示
 */
- (NSInteger)videoSizeOfCurrentResolution;

#pragma mark - redux
///-----------------------------------------------------------------
/// @name redux（播放器相关的功能模块）状态管理，其他@ TTVPlayer+Part
///-----------------------------------------------------------------
/// 数据节点，Redux 架构进行 part 的状态通知以及改变
@property (nonatomic, strong, readonly) TTVReduxStore  * playerStore;

/// 播放器相关的 action，发送action 之后，可以改变播放器的state，同时改变播放器的行为
@property (nonatomic, strong, readonly) TTVPlayerAction* playerAction;
#pragma mark - 多个 player
/**
 由于可以同时存在多个 player，可以通过这个方法获取全部用本类创建的 player

 @return player
 */
+ (NSArray *)allActivePlayers;

/**
 移除掉 player，停止播放
 */
- (void)removePlayer;

@end

/**
 播放事件，状态，界面相关的回调
 */
@protocol TTVPlayerDelegate <NSObject>
@optional
///-----------------------------------------------------------------
/// @name 界面相关回调
///-----------------------------------------------------------------
/// viewcontroller 回调 viewDidLoad 回调
- (void)viewDidLoad:(TTVPlayer *)player state:(TTVPlayerState *)state;

/// 当 playerViewController中view布局回调，可以在里面进行布局
- (void)playerViewDidLayoutSubviews:(TTVPlayer *)player state:(TTVPlayerState *)state;

/// 播放器展示第一帧
- (void)playerReadyToDisplay:(TTVPlayer *)player;

/// 播放器进入到沉浸态，沉浸态的 view
- (void)playerDidEnterImmersiveStatus:(TTVPlayer *)player immersiveView:(UIView *)sinkView locked:(BOOL)locked;

/// 播放器进入到控制态
- (void)playerDidEnterPlaybackControlStatus:(TTVPlayer *)player playbackControlView:(TTVPlaybackControlView*)controlView locked:(BOOL)locked;

/// 播放器进入锁屏态
- (void)playerDidEnterLockStatus:(TTVPlayer *)player;

/// 播放器离开锁屏态
- (void)playerDidEnterUnlockStatus:(TTVPlayer *)player;

///-----------------------------------------------------------------
/// @name 播放器根据状态计算出来的回调
///-----------------------------------------------------------------
/// 播放器正在 loading，应该出现出现 loadingView
- (void)playerDidStartLoading:(TTVPlayer *)player;

/// 播放器结束 loading，播放器应该移除 loadingView
- (void)playerDidStopLoading:(TTVPlayer *)player;

/// slider 控件本身开始被拖动
- (void)playerSliderDidStartPanning:(UIView<TTVSliderControlProtocol> *)slider;

/// slider 控件本身开始结束
- (void)playerSliderDidStopPanning:(UIView<TTVSliderControlProtocol> *)slider;

/// slider 控件本身正在有 seeking操作，手势+Slider自身
- (void)playerSliderDidProgressSeeking:(UIView<TTVSliderControlProtocol> *)slider;

/// 手势引起的 slider 拖动
- (void)playerGestureDidStartSliderPanning:(UIView<TTVSliderControlProtocol> *)slider;

/// 手势引起 slider 拖动结束
- (void)playerGestureDidStopSliderPanning:(UIView<TTVSliderControlProtocol> *)slider;

/// 开始设置播放时间
- (void)playerDidStartSeeking:(TTVPlayer*)player;

/// 结束设置播放时间
- (void)playerDidStopSeeking:(TTVPlayer *)player;

/// 网络发生变化,出流量提示，应该暂停
- (void)playerDidPauseByCellularNet:(TTVPlayer *)player;

/// 进入全屏
- (void)playerDidEnterFullscreen:(TTVPlayer *)player;

/// 离开全屏
- (void)playerDidExitFullscreen:(TTVPlayer *)player;

///-----------------------------------------------------------------
/// @name 内核的回调，主要封装了 Engine 的回调
///-----------------------------------------------------------------
/**
 播放结束的回调：包含手动调用 stop 和自动播放结束；手动和自动在 status 中有体现
 
 @param player  player
 @param finishStatus status
 */
- (void)player:(TTVPlayer *)player didFinishedWithStatus:(TTVPlayFinishStatus *)finishStatus;

/// 内部 timer，默认500ms 获取回调一次，如果需要修改 回调时间间隔请调用，依旧会得到此回调通知;请调用 - (void)addPeriodicTimeObserverForInterval:(NSTimeInterval)interval queue:(dispatch_queue_t)queue usingBlock:(dispatch_block_t)block;
- (void)player:(TTVPlayer *)player playbackTimeChanged:(TTVPlaybackTime *)playbackTime;

/// 播放器播放状态变化通知
- (void)player:(TTVPlayer *)player playbackStateDidChanged:(TTVPlaybackState)playbackState;

/// 播放器加载状态变化通知
- (void)player:(TTVPlayer *)player loadStateDidChanged:(TTVPlayerDataLoadState)loadState;

/// 播放器获取播放源通知
- (void)player:(TTVPlayer *)player didFetchedVideoModel:(TTVideoEngineModel *)videoModel;

/// 播放器准备好播放
- (void)playerPrepared:(TTVPlayer *)player;

/// 播放器重试回调
- (void)player:(TTVPlayer *)player retryForError:(NSError *)error;

/// 播放器seek 时卡顿回调
- (void)playerStalledExcludeSeek:(TTVPlayer *)player;

/// 当调用 closeAysn,会收到此回调
- (void)playerCloseAysncFinish:(TTVPlayer *)player;

/// 长视频 更新bizToken , 各业务方自己更新,
- (void)player:(TTVPlayer *)player requestPlayTokenCompletion:(void (^)(NSError *error, NSString *authToken, NSString *bizToken))completion;

- (NSString *)playerV2URL:(TTVPlayer *)player path:(NSString *)path;

@end



