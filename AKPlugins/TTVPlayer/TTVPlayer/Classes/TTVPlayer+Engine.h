//
//  TTVPlayer+Engine.h
//  TTVPlayerPod
//
//  Created by lisa on 2019/3/14.
//

#import "TTVPlayer.h"

NS_ASSUME_NONNULL_BEGIN

@interface TTVPlayer (Engine)

/// TTVPlayer 调用TTVideoEngine的初始化
- (void)initializeEngineWithOwnPlayer:(BOOL)isOwnPlayer;
- (void)deallocEngine;

#pragma mark - 视频源传入设置
///-----------------------------------------------------------------
/// @name 视频源传入设置 vid url
///-----------------------------------------------------------------
/**
 设置播放器播放源相关的参数，此方法 将3个参数会拼接一个 url，进行真实播放地址的获取,获取视频地址的url不加密
 
 @param videoID  vid
 @param host  服务端 host
 @param commonParameters url 后添加的通用参数，比如机型等
 */
- (void)setVideoID:(NSString *)videoID host:(NSString *)host commonParameters:(NSDictionary *)commonParameters;

/**
 设置播放器播放源相关的参数，此方法 将3个参数会拼接一个 url，进行真实播放地址的获取,获取视频地址的url加密
 
 @param videoID  vid
 @param host  服务端 host
 @param commonParameters url 后添加的通用参数，比如机型等
 @param businessToken 加密秘钥，用于对此方法形成的 url 进行加密
 */
- (void)setVideoID:(NSString *)videoID host:(NSString *)host commonParameters:(NSDictionary *)commonParameters businessToken:(NSString *)businessToken;

/**
 设置本地视频地址

 @param url 本地 bundle 视频地址
 */
- (void)setLocalURL:(NSString *)url;

/**
 设置远程直接播放的地址，而不是 vid

 @param url remote url
 */
- (void)setDirectPlayURL:(NSString *)url;

/**
 从预加载 item播放视频
 
 @param preloaderItem  预加载 item
 */
- (void)setPreloaderItem:(TTAVPreloaderItem *)preloaderItem;

/// 设置播放器选用哪个 API 的版本进行获取播放地址 @see TTVPlayerAPIVersion
- (void)setPlayAPIVersion:(TTVPlayerAPIVersion)apiVersion auth:(NSString *)auth;

/// 设置获取视频源的网络
@property (nonatomic, strong) id<TTVideoEngineNetClient> netClient; // 设置网络请求 client

/// setVideoID 设置vid 之后，当前播放视频的vid
@property (nonatomic, copy, readonly) NSString* videoID;

/// 当前播放视频是否是本地 bundle 获取的视频
@property (nonatomic, readonly) BOOL isLocalVideo;

#pragma mark - 播放器状态
///-----------------------------------------------------------------
/// @name 播放器状态
///-----------------------------------------------------------------
/// 加载状态 ，用于反馈 loading 的状态
@property (nonatomic, readonly) TTVPlayerLoadStateNew  loadState;
/// 播放状态，调用了 play stop 等改变
@property (nonatomic, readonly) TTVPlaybackState    playbackState;
/// 播放器 整体状态
@property (nonatomic, readonly) TTVPlayerEngineState state;
/// 如果 pause了，return NO, 没明白是干啥的
@property (nonatomic, readonly) BOOL shouldPlay;
/// 是否播放结束
@property (nonatomic, readonly) BOOL isPlaybackEnded;

#pragma mark - 播放相关控制
///-----------------------------------------------------------------
/// @name 播放相关控制
///-----------------------------------------------------------------
/**
 视频播放，尤其用于第一次起播，后面调用 resume 继续播放
 */
- (void)play;

/// 起播从最近一次缓存处开始播放, 默认为 NO
@property (nonatomic) BOOL startPlayFromLastestCache;

/**
 视频继续播放，主要用于起播后，加入了播放调用栈，用于控制前后台切换等无法还原现场等情况
 NOTE：调用此方法，有可能导致 play 方法无法调用，他与 pause 成对出现
 */
- (void)resume;

/**
 视频暂停，主要用于起播后，加入了播放调用栈，用于控制前后台切换等操作错误继续等情况
 同时还缓存了当前进度
 */
- (void)pause;

/**
 停止视频播放
 */
- (void)stop;

/**
 释放播放器
 */
- (void)close;

/**
 异步释放播放器
 */
- (void)closeAysnc;

#pragma mark - 播放时间相关
///-----------------------------------------------------------------
/// @name 播放时间相关
///-----------------------------------------------------------------
/// 播放时间相关的类：常用的有 currentPlaybackTime， duration，progress 等；如果外界不重新设置 timer，那么此对象将500ms 被更新一次 @see - (void)player:(TTVPlayer *)player playbackTimeChanged:(TTVPlaybackTime *)playbackTime;
@property (nonatomic, strong, readonly) TTVPlaybackTime * playbackTime;
/**
  设置播放时间到哪里，起播也可以调用此方法进行播放时间设置

 @param currentPlaybackTime 需要跳播的时间
 @param finished 完成回调 block
 */
- (void)setCurrentPlaybackTime:(NSTimeInterval)currentPlaybackTime complete:(void(^)(BOOL success))finished;

/**
 设置 timer
 
 @param interval timer 通知间隔
 @param queue 通知队列
 @param block 回调
 */
- (void)addPeriodicTimeObserverForInterval:(NSTimeInterval)interval queue:(dispatch_queue_t)queue usingBlock:(dispatch_block_t)block;

/**
 移除掉 addPeriodicTimeObserverForInterval 生成的 timer
 */
- (void)removeTimeObserver;

#pragma mark - 清晰度
///-----------------------------------------------------------------
/// @name 清晰度
///-----------------------------------------------------------------
/// 切换清晰度
- (void)configResolution:(TTVPlayerResolutionTypeNew)resolution completion:(void(^)(BOOL success, TTVPlayerResolutionTypeNew completeResolution))completion;
/// 返回当前的清晰度
@property (nonatomic, readonly) TTVPlayerResolutionTypeNew currentResolution;
/// 支持的清晰度
- (NSArray<NSNumber *> *)supportedResolutionTypes;

#pragma mark - 设置 audio 和声音
///-----------------------------------------------------------------
/// @name 设置 audio 和声音
///-----------------------------------------------------------------
/**
 设置音频是否可以被中断，默认是NO

 @param ignore  是否可以被中断
 */
+ (void)setIgnoreAudioInterruption:(BOOL)ignore;

/// 初始化的时候，占用音轨
@property (nonatomic) BOOL      enableAudioSession;

/// 设置音量大小
@property (nonatomic) CGFloat   volume;
/// 设置静音：默认 NO
@property (nonatomic) BOOL      muted;

#pragma mark - 播放速度
///-----------------------------------------------------------------
/// @name 播放速度
///-----------------------------------------------------------------
/// 播放速度设置与获取
@property (nonatomic) CGFloat playbackSpeed;

#pragma mark -  设置其他播放器配置
///-----------------------------------------------------------------
/// @name 设置其他播放器配置
///-----------------------------------------------------------------
// 是否循环播放，默认 NO, 播放完停止在最后一帧
@property (nonatomic) BOOL looping;
///**
// Get option that you care about.
// Example: get video width.
// NSInteger videoWidth = [[self getOptionBykey:VEKKEY(VEKGetKeyPlayerVideoWidth_NSInteger)] integerValue];
// |                                  |                    |           |
// value                             Gen key               Filed      valueType
// @param key Please use VEKKEY(key) to prodect a valid key.
// @return Value correspod the key. The key include value type.
// */
//- (id)getOptionBykey:(VEKKeyType)key;
//
///**
// Set options by VEKKey
// Example:
// [self setOptions:@{VEKKEY(VEKKeyPlayerTestSpeedMode_ENUM),@(TTVideoEngineTestSpeedModeContinue)}];
// |                   |          |                          |
// Generate key            Filed     valueType                   value
// @param options key is one of VEKKeys, value defined id type.
// */
//- (void)setOptions:(NSDictionary<VEKKeyType, id> *)options;

@end

NS_ASSUME_NONNULL_END
