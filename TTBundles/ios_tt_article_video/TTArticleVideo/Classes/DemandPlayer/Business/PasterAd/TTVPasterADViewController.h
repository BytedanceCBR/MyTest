//
//  TTVPasterADViewController.h
//  Article
//
//  Created by Dai Dongpeng on 5/25/16.
//
//

#import "SSViewControllerBase.h"
#import "ExploreMovieViewTracker.h"
#import "TTVPasterADModel.h"
#import "TTVPasterADService.h"
#import "TTVPlayVideo.h"

/**
 *  视频贴片广告控制器
    1. 需求 https://wiki.bytedance.com/pages/viewpage.action?pageId=55138177
    2. API文档：https://wiki.bytedance.com/pages/viewpage.action?pageId=55939299
               https://docs.google.com/spreadsheets/d/10O5PDpqm6TcOcFV72Bual8GgCYj2sYJgZGc3sLKF8kg/edit#gid=0
 */

typedef void (^TTVPasterADPlayCompletionBlock)(void);

@class TTVPasterADModel, ExploreMoviePlayerController;
@protocol TTVPasterADDelegate;

@interface TTVPasterADViewController : SSViewControllerBase

@property (nonatomic, weak) id <TTVPasterADDelegate>delegate;

@property (nonatomic, strong) TTVPasterADModel *playingADModel;
@property (nonatomic, strong, readonly) TTVPlayVideo *playerView;

@property (nonatomic, assign) BOOL enterDetailFlag; // 标记详情页展示广告

- (void)setupPasterADData:(TTVPasterADURLRequestInfo *)requestInfo completionBlock:(void (^)(BOOL success))block;

+ (CGFloat)ttv_pasterFadeInTimeInterval;

@end

@interface TTVPasterADViewController (ExploreMovieView)

- (void)startPlayVideoList:(NSArray *)videoList WithCompletionBlock:(TTVPasterADPlayCompletionBlock)completion;

- (BOOL)isPlayingMovie;
- (BOOL)isPlayingImage;
- (BOOL)isPaused;
- (void)setIsFullScreen:(BOOL)fullScreen;
- (ExploreMovieViewType)currentViewType;

- (BOOL)shouldPauseCurrentAd;
- (void)pauseCurrentAD;
- (void)resumeCurrentAD;
- (void)stopCurrentADVideo;
- (ExploreMoviePlayerController *)getMoviePlayerController;

@end

@protocol TTVPasterADDelegate <NSObject>
@optional
- (void)videoPasterADViewControllerToggledToFullScreen:(BOOL)fullScreen animationed:(BOOL)animationed completionBlock:(void(^)(BOOL finished))completionBlock;
- (BOOL)isMovieFullScreen;
- (BOOL)isInDetail;

- (void)replayOriginalVideo;

- (void)setPasterADRotateState:(BOOL)state;

- (void)sendHostPlayerPauseAction;

@end
