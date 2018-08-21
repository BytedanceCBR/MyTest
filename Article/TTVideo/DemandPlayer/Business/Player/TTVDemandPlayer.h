//
//  TTVDemandPlayer.h
//  Article
//
//  Created by panxiang on 2017/5/17.
//
//

#import <UIKit/UIKit.h>
#import "TTVPlayerController.h"
#import "TTVPlayerModel.h"
#import "TTVPlayerControlView.h"
#import "TTVPlayerTracker.h"
#import "TTVPlayerControllerState.h"
#import "TTVDemandPlayerContextVideo.h"
#import "TTVPlayerDoubleTap666Delegate.h"

@class TTVPlayerOrientationController;
@class TTVDemanderTrackerManager;
@class TTVCommodityFloatView;
@class TTVCommodityView;
@class TTVPasterPlayer;
@class TTVMidInsertADPlayer;
@class TTVDemandPlayerContextVideo;
@class TTVCommodityButtonView;
@class TTVVideoPlayerModel;
@class TTVVideoPlayerStateStore;

@protocol TTVDemandPlayerDelegate <NSObject>
@optional;
- (void)playerPlaybackState:(TTVVideoPlaybackState)state;
- (void)playerLoadingState:(TTVPlayerLoadState)state;
- (void)playerOrientationState:(BOOL)isFullScreen;
- (void)actionChangeCallbackWithAction:(TTVPlayerStateAction *)action;
- (CGRect)ttv_movieViewFrameAfterExitFullscreen;
@end

@interface TTVDemandPlayer : UIView
@property (nonatomic, strong) TTVVideoPlayerModel *playerModel;
@property (nonatomic, weak) NSObject <TTVDemandPlayerDelegate> *delegate;//始终保持delegate唯一
@property (nonatomic, weak) id<TTVPlayerDoubleTap666Delegate> doubleTap666Delegate;
@property (nonatomic, strong ,readonly) TTVPasterPlayer *pasterPlayer;
@property (nonatomic, strong ,readonly) TTVMidInsertADPlayer *midInsertADPlayer;
@property (nonatomic, strong ,readonly) TTVCommodityFloatView *commodityFloatView;
@property (nonatomic, strong ,readonly) TTVCommodityButtonView *commodityButton;
@property (nonatomic, strong, readonly) TTVVideoPlayerStateStore *playerStateStore;
@property (nonatomic, strong ,readonly) TTVDemanderTrackerManager *commonTracker;
@property (nonatomic, strong ,readonly) TTVDemandPlayerContextVideo *context;
@property (nonatomic, weak) UIView *rotateView;//真实做旋转的view
/**
 tip工厂  默认 TTVPlayerTipCreator
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
/**
 所有的数据准备好后,调用,初始化相关的类,赋值初始化数据
 */
- (void)readyToPlay;
- (void)reset;
- (void)registerDelegate:(NSObject <TTVDemandPlayerDelegate> *)delegate;
- (void)unregisterDelegate:(NSObject <TTVDemandPlayerDelegate> *)delegate;


/**
 第一次调用play之前必需调用readyToPlay
 */
- (void)play;
- (void)pause;
- (void)releaseAysnc;
- (void)stopWithFinishedBlock:(TTVStopFinished)finishedBlock;
- (void)exitFullScreen:(BOOL)animated completion:(TTVPlayerOrientationCompletion)completion;
- (void)enterFullScreen:(BOOL)animated completion:(TTVPlayerOrientationCompletion)completion;
- (void)sendAction:(TTVPlayerEventType)event payload:(id)payload;
- (void)seekVideoToProgress:(CGFloat)progress complete:(void(^)(BOOL success))finised;
- (void)setVideoTitle:(NSString *)title;
- (void)setLogoImageView:(UIView *)logoImageView;
- (void)setBackgroundView:(UIView *)backgroundView;
- (void)setLogoImageViewHidden:(BOOL)hidden;
- (void)setVideoWatchCount:(NSInteger)watchCount playText:(NSString *)playText;
- (void)saveCacheProgress;
- (void)refreshTotalWatchTime;

/**
 添加自定义功能模块,包括自定义统计
 */
- (void)registerPart:(NSObject <TTVPlayerContext> *)part;

- (void)removeControlView;
- (void)removeBottomBarView;
- (void)setCommodityView:(TTVCommodityView *)commodityView;
@end


@interface TTVDemandPlayer (SetterPropterty)
/**
 是否在详情页
 */
- (void)setIsInDetail:(BOOL)isInDetail;
- (void)setShowTitleInNonFullscreen:(BOOL)showTitleInNonFullscreen;

/**
 静音
 */
- (void)setMuted:(BOOL)muted;

- (void)setBanLoading:(BOOL)banLoading;

- (void)setBannerHeight:(float)bannerHeight;

- (void)setEnableRotate:(BOOL)enableRotate;

@end

