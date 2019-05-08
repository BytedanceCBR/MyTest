//
//  TTVBaseDemandPlayer.h
//  Article
//
//  Created by panxiang on 2017/9/15.
//
//

#import <UIKit/UIKit.h>
#import "TTVPlayerController.h"
#import "TTVBasePlayerModel.h"
#import "TTVPlayerControlView.h"
#import "TTVPlayerControllerState.h"
#import "TTVDemandPlayerContext.h"

@class TTVPlayerOrientationController;
@class TTVDemanderTrackerManager;

@protocol TTVBaseDemandPlayerDelegate <NSObject>
@optional;
/**
 播放器当前的播放状态
 */
- (void)playerPlaybackState:(TTVVideoPlaybackState)state;
/**
 播放器当前的loading状态
 */
- (void)playerLoadingState:(TTVPlayerLoadState)state;
/**
 播放器改变旋转方向的回调
 */
- (void)playerOrientationState:(BOOL)isFullScreen;
/**
播放器内部各种事件的回掉,比如,点击了播放按钮,点击了全屏按钮,点击了暂停按钮等.
 */
- (void)actionChangeCallbackWithAction:(TTVPlayerStateAction *)action;

/**
 退出全屏,获取父view frame
 */
- (CGRect)ttv_movieViewFrameAfterExitFullscreen;

@end

@interface TTVBaseDemandPlayer : UIView
@property (nonatomic, strong) TTVBasePlayerModel *playerModel;
@property (nonatomic, strong ,readonly) TTVDemanderTrackerManager *commonTracker;
/**
 tip工厂  默认 TTVPlayerTipCreator
 定制化 loading界面 播放失败重试界面 播放结束显示的界面
 */
@property(nonatomic, strong)id <TTVPlayerTipCreator> tipCreator;

/**
 自定义 播放器界面底部工具栏 bottomBarView
 */
@property(nonatomic, strong)UIView <TTVPlayerControlBottomView ,TTVPlayerContext> *bottomBarView;

/**
 自定义整个播放器控制界面
 */
@property(nonatomic, strong)UIView <TTVPlayerViewControlView ,TTVPlayerContext> *controlView;
@property (nonatomic, weak) NSObject <TTVBaseDemandPlayerDelegate> *delegate;
/**
 获取播放器内部各种状态参数
 */
@property (nonatomic, strong ,readonly) TTVDemandPlayerContext *context;
/**
 对rotateView做全屏旋转
 */
@property (nonatomic, weak) UIView *rotateView;
/**
 这个在设置好各种属性参数后,在第一次调用play之前调用. 必现调用,且只需调用一次.
 */
- (void)readyToPlay;
- (void)play;
- (void)pause;

/**
 @param payload 传入的payload会原样在action中返回,以供区分.
 默认会有一个TTVPlayAction.
 */
- (void)playWithPayload:(NSDictionary *)payload;
- (void)pauseWithPayload:(NSDictionary *)payload;
- (void)stop;
- (void)reset;
- (void)releaseAysnc;
- (void)seekVideoToProgress:(CGFloat)progress complete:(void(^)(BOOL success))finised;
/**
 全屏 / 非全屏 切换
 */
- (void)exitFullScreen:(BOOL)animated completion:(TTVPlayerOrientationCompletion)completion;
- (void)enterFullScreen:(BOOL)animated completion:(TTVPlayerOrientationCompletion)completion;

/**
 事件发送
 @param event 事件
 @param payload 数据传递
 */
- (void)sendAction:(TTVPlayerEventType)event payload:(id)payload;

/**
 需要多路代理的时候使用
 */
- (void)registerDelegate:(NSObject <TTVBaseDemandPlayerDelegate> *)delegate;
- (void)unregisterDelegate:(NSObject <TTVBaseDemandPlayerDelegate> *)delegate;

/**
 添加自定义功能模块,包括自定义统计
 */
- (void)registerPart:(NSObject <TTVPlayerContext> *)part;

/**
 设置标题,观看次数,封面
 fontSizeStyle : 0 normal 1 small 2 UltraSmall
 */
- (void)setVideoTitle:(NSString *)title;
- (void)setLogoImageView:(UIView *)logoImageView;
- (void)setBackgroundView:(UIView *)backgroundView;//一直显示在视频画面下面的北京图片,替换黑色背景
- (void)setVideoWatchCount:(NSInteger)watchCount playText:(NSString *)playText;
- (void)removeMiniSliderView;
@end


@interface TTVBaseDemandPlayer (SetterPropterty)
/**
 是否在详情页 ,统计使用
 */
- (void)setIsInDetail:(BOOL)isInDetail;

/**
 非全屏下是否显示标题
 */
- (void)setShowTitleInNonFullscreen:(BOOL)showTitleInNonFullscreen;

/**
 静音
 */
- (void)setMuted:(BOOL)muted;

/**
 非全屏下,播放器底部banner
 */
- (void)setBannerHeight:(float)bannerHeight;

/**
 是否允许旋转
 */
- (void)setEnableRotate:(BOOL)enableRotate;

@end
