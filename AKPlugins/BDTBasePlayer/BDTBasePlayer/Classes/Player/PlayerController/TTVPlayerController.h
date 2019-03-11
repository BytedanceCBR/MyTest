//
//  TTVPlayerController.h
//  Pods
//
//  Created by panxiang on 2017/5/23.
//
//

#import <Foundation/Foundation.h>
#import "TTVPlayerControllerState.h"
#import "TTVPlayerStateAction.h"
#import "TTVPlayerControllerProtocol.h"
#import "TTVPlayerModel.h"
#import "TTVPlayerView.h"
#import "TTVPlayerEventController.h"

typedef void(^TTVStopFinished)(void);


@protocol TTVPlayerControllerDataSource <NSObject>

@optional
- (UIView<TTVPlayerViewControlView ,TTVPlayerContext> *)videoPlayerControlView;
- (UIView<TTVPlayerViewTrafficView> *)videoPlayerTrafficView;
- (UIView<TTVPlayerControlTipView ,TTVPlayerContext> *)videoPlayerTipView;
@end

@protocol TTVPlayerControllerDelegate <NSObject>

@optional
- (BOOL)shouldAutoRotate;
- (CGRect)ttv_movieViewFrameAfterExitFullscreen;
@end

@interface TTVPlayerController : NSObject

/**
 播放器background view ,view大集合
 */
@property (nonatomic, strong) TTVPlayerView *playerView;

/**
 可定制化,几种播放相关的UI
 */
@property (nonatomic, weak) id<TTVPlayerControllerDataSource> playerDataSource;

/**
 TTVPlayerController delegate
 */
@property (nonatomic, weak) id<TTVPlayerControllerDelegate> delegate;

/**
 视频播放相关的状态合辑
 */
@property (nonatomic, strong) TTVPlayerStateStore *playerStateStore;

/**
 真正执行旋转的view
 */
@property (nonatomic ,weak) UIView *rotateView;

/**
 播放器播放必要信息.
 */
@property (nonatomic, strong) TTVPlayerModel *playerModel;

/**
 静音
 */
@property (nonatomic, assign) BOOL muted;

/**
 *播放器初始播放时，禁止展示loading
 */
@property (nonatomic, assign) BOOL banLoading;

/**
 所有的数据准备好后,调用,初始化相关的类,赋值初始化数据
 */
- (void)readyToPlay;
- (void)playVideo;
- (void)pauseVideo;


/**
@"action" : TTVPlayAction
 @param payload 参数透传
 */
- (void)playVideoFromPayload:(NSDictionary *)payload;
- (void)pauseVideoFromPayload:(NSDictionary *)payload;
- (void)seekVideoToProgress:(CGFloat)progress complete:(void(^)(BOOL success))finised;
- (void)stopVideo;
- (void)releaseAysnc;
- (void)changeResolution:(TTVPlayerResolutionType)type;
- (void)saveCacheProgress;
- (void)exitFullScreen:(BOOL)animated completion:(TTVPlayerOrientationCompletion)completion;
- (void)enterFullScreen:(BOOL)animated completion:(TTVPlayerOrientationCompletion)completion;
+ (TTVPlayerController *)currentPlayerController;

@end
