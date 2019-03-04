//
//  TTVPlayerStateModel.h
//  Pods
//
//  Created by panxiang on 2017/5/23.
//
//

#import <Foundation/Foundation.h>
#import "TTVPlayerControllerState.h"
#import "TTVPlayerModel.h"

@protocol TTVPlayerStateModelDelegate <NSObject>


/**
 业务控制是否需要自动旋转功能
 */
- (BOOL)shouldAutoRotate;//视频重力感应 自动旋转

@end

extern BOOL TTVHasShownNewTrafficAlert;
extern BOOL TTVHasShownOldTrafficAlert;

@class TTVPlayerWatchTimer;

typedef void(^TTVWillResumePlay)(BOOL *shouldPlay);

@interface TTVPlayerStateModel : NSObject

/**
 视频内部delegate合集 ,供外部业务控制使用
 */
@property(nonatomic, weak)NSObject <TTVPlayerStateModelDelegate> *delegate;

//外部传入的参数,统计/控制信息需要.
@property (nonatomic, strong) TTVPlayerModel *playerModel;

/**
 额外自定义数据
 */
@property (nonatomic, strong) NSDictionary *extraDic;

/**
 视频播放第一帧
 */
@property (nonatomic, assign) BOOL showVideoFirstFrame;

/**
 视频播放失败原因
 */
@property (nonatomic, strong) NSError *error;

/**
 当前播放的清晰度下视频二进制大小
 */
@property (nonatomic, assign) NSInteger videoSize;

/**
 最低清晰度下视频二进制大小
 */
@property (nonatomic, assign) NSInteger minVideoSize;

/**
 本地视频播放器地址
 */
@property (nonatomic, assign) BOOL isUsingLocalURL;

// 播放时是否命中缓存(prepare之后可用)
@property (nonatomic, assign) BOOL playingWithCache;

/**
 视频总播放时间
 */
@property (nonatomic, assign) NSTimeInterval duration;

/**
 当前播放的时间
 */
@property (nonatomic, assign) NSTimeInterval currentPlaybackTime;

/**
 可观看时间,缓存好了的时间
 */
@property (nonatomic, assign) NSTimeInterval playableTime;

/**
 观看进度
 */
@property (nonatomic, assign) CGFloat watchedProgress;

/**
 缓存进度
 */
@property (nonatomic, assign) CGFloat cacheProgress;

/**
 是否全屏
*/
@property (nonatomic, assign) BOOL isFullScreen;

/**
 是否是 全屏旋转动画中
 */
@property (nonatomic, assign) BOOL isRotating;

/**
 清晰度按钮是否可以点击
 */
@property(nonatomic, assign)BOOL enableResulutionButtonClicked;

/**
 在详情页
 */
@property(nonatomic, assign)BOOL isInDetail;

/**
 曾经进入过详情页
 */
@property(nonatomic, assign)BOOL hasEnterDetail;


/**
 手动拖动进度条
 */
@property(nonatomic, assign)BOOL isDragging;

/**
 视频播放的状态
 */
@property (nonatomic, assign) TTVVideoPlaybackState playbackState;

/**
 视频加载的状态
 */
@property (nonatomic, assign) TTVPlayerLoadState loadingState;

/**
 当tipViewType为TTVPlayerControlTipViewTypeLoading时，是否禁止loadingView startLoading
 */
@property (nonatomic, assign) BOOL forbidLoadingAnimtaion;

/**
 进度条可拖动状态
 */
@property (nonatomic, assign) BOOL sliderEnableDrag;

/**
 当前的清晰度
 */
@property (nonatomic, assign) TTVPlayerResolutionType currentResolution;

/**
 静音
 */
@property (nonatomic, assign) BOOL muted;

/**
 *开始播放时，禁止出loading
 */
@property (nonatomic, assign) BOOL banLoading;

/**
 始终hidden titlebar 例如在详情页的时候
 */
@property (nonatomic, assign) BOOL titleBarViewAlwaysHide;
/**
 在详情页半屏的时候是否显示标题
 */
@property (nonatomic, assign) BOOL showTitleInNonFullscreen;

/**
 支持的清晰度种类
 */
@property (nonatomic, copy) NSArray <NSNumber *> *supportedResolutionTypes;

/**
 改变清晰度的过程状态
 */
@property (nonatomic, assign) TTVResolutionState resolutionState;

/**
 当前视频展示的tip类型
 */
@property(nonatomic, assign)TTVPlayerControlTipViewType tipType;

/**
 当前toolbar状态
 */
@property(nonatomic, assign)TTVPlayerControlViewToolBarState toolBarState;

/**
 实际观看时间,毫秒计算
 */
@property(nonatomic, assign ,readonly) NSTimeInterval totalWatchTime;

/**
 退出全屏操作方式
 */
@property(nonatomic, assign) TTVPlayerExitFullScreeenType exitFullScreeenType;

/**
 统计使用 ,gdlabel
 */
@property(nonatomic, copy) NSString *trackLabel;

/**
 执行过播放操作
 */
@property(nonatomic, assign) BOOL hasPlayed;

/**
 是否允许旋转
 */
@property(nonatomic, assign) BOOL enableRotate;

/**
 是否是自动播放
 */
@property(nonatomic, assign) BOOL isAutoPlaying;

/**
 详情页播放完毕后,显示的banner的高度
 */
@property(nonatomic, assign)float bannerHeight;

/**
 正在显示流量提示
 */
@property(nonatomic, assign)BOOL isShowingTrafficAlert;

/**
 播放进度占时长的比例
 */
@property(nonatomic, assign ,readonly)NSInteger playPercent;

/**
 是否是播放结束状态,当前的播放时间 == 视频的时长
 */
@property(nonatomic, assign ,readonly)BOOL isPlaybackEnded;

/**
 区分是重力感应,还是手动点击全屏按钮,返回按钮
 */
@property(nonatomic, assign)BOOL isFullScreenButtonType;

/**
 播放/暂停 状态堆栈
 */
@property (nonatomic, assign) NSInteger playStateVirtualStack;

/**
 暂时禁用TrafficAlert
 */
@property(nonatomic, assign)BOOL disableTrafficAlert;

/**
 播放结束会自动退出全屏,通过该参数禁用该功能
 */
@property(nonatomic, assign)BOOL disableExitFullScreenWhenPlayEnd;

/**
 播放结束会禁用自动旋转,通过该参数禁用该功能
 */
@property(nonatomic, assign)BOOL enableRotateWhenPlayEnd;

/**
 特卖 插入时间点
 */
@property (nonatomic, strong) NSArray <NSNumber *> *insertTimes;

/**
 贴片广告数据是否正在进行fade动画（视频播放完成后，贴片广告进入可能需要有一个fade动画）
 */
@property (nonatomic, assign) BOOL pasterFadeAnimationExecuting;

/**
 暂时禁用TrafficAlert,显示过一次后,就不需要在显示了.
 */
@property(nonatomic, assign)BOOL changeResolutionAlertShowed;

/**
 resolutionAlert显示状态
 */
@property(nonatomic, assign)BOOL resolutionAlertShowed;

/**
 禁用平滑切换
 */
@property(nonatomic, assign)BOOL enableSmothlySwitch;

/**
 暂时fix bug ,切换清晰度 ,pause deactive 会有问题
 */
@property (nonatomic, assign) BOOL isChangingResolution;

/**
 logv3 通用统计参数
 */
- (NSMutableDictionary *)ttv_logV3CommonDic;

/**
 当前视频播放的位置 ,统计用 ,detail or list
 */
- (NSString *)ttv_position;

/**
 统计播放时长使用,播放器内部使用,业务禁用
 */
- (void)setPlayerWatchTimer:(TTVPlayerWatchTimer *)watchTimer;

/**
 清晰度enum对应的文案 @"标清", @"高清", @"超清"
 */
+ (NSString *)typeStringForType:(TTVPlayerResolutionType)type;

- (NSNumber *)minResolution;

@end

