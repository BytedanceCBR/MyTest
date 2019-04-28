//
//  TTVideoPasterADViewController.h
//  Article
//
//  Created by Dai Dongpeng on 5/25/16.
//
//

#import "SSViewControllerBase.h"
#import "ExploreMovieViewTracker.h"
#import "TTVideoPasterADModel.h"
#import "TTVideoPasterADService.h"

/**
 *  视频贴片广告控制器
    1. 需求 https://wiki.bytedance.com/pages/viewpage.action?pageId=55138177
    2. API文档：https://wiki.bytedance.com/pages/viewpage.action?pageId=55939299
               https://docs.google.com/spreadsheets/d/10O5PDpqm6TcOcFV72Bual8GgCYj2sYJgZGc3sLKF8kg/edit#gid=0
 */

typedef void (^TTVideoPasterADPlayCompletionBlock)(void);

@class TTVideoPasterADModel, ExploreMoviePlayerController;
@protocol TTVideoPasterADDelegate;

@interface TTVideoPasterADViewController : SSViewControllerBase

@property (nonatomic, weak) id <TTVideoPasterADDelegate>delegate;

@property (nonatomic, strong) TTVideoPasterADModel *playingADModel;

@property (nonatomic, assign) BOOL enterDetailFlag; // 标记详情页展示广告

- (void)setupPasterADData:(TTVideoPasterADURLRequestInfo *)requestInfo;

@end

@interface TTVideoPasterADViewController (ExploreMovieView)

- (void)startPlayVideoList:(NSArray *)videoList WithCompletionBlock:(TTVideoPasterADPlayCompletionBlock)completion;

- (BOOL)isPlayingMovie;
- (BOOL)isPlayingImage;
- (BOOL)isPaused;
- (BOOL)hasPasterView;
- (void)setIsFullScreen:(BOOL)fullScreen;
- (ExploreMovieViewType)currentViewType;

- (BOOL)shouldPauseCurrentAd;
- (void)pauseCurrentAD;
- (void)resumeCurrentAD;
- (void)stopCurrentADVideo;
- (ExploreMoviePlayerController *)getMoviePlayerController;

@end

@protocol TTVideoPasterADDelegate <NSObject>

- (void)videoPasterADViewControllerToggledToFullScreen:(BOOL)fullScreen animationed:(BOOL)animationed completionBlock:(void(^)(BOOL finished))completionBlock;
- (BOOL)isMovieFullScreen;
- (ExploreMovieViewType)currentViewType;

- (void)replayOriginalVideo;

@end
