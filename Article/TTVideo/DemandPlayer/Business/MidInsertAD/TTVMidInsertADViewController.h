//
//  TTVMidInsertADViewController.h
//  Article
//
//  Created by lijun.thinker on 05/09/2017.
//
//

#import "TTVBaseViewController.h"
#import "TTMoviePlayerDefine.h"
#import "TTVMidInsertADModel.h"
#import "TTVPlayVideo.h"

typedef void (^TTVMidInsertADPlayCompletionBlock)(void);

@class TTVMidInsertADModel, ExploreMoviePlayerController;
@protocol TTVMidInsertADDelegate;

@interface TTVMidInsertADViewController : SSViewControllerBase

@property (nonatomic, weak) id <TTVMidInsertADDelegate>delegate;

@property (nonatomic, strong) TTVMidInsertADModel *playingADModel;

@property (nonatomic, assign) BOOL enterDetailFlag; // 标记详情页展示广告
@property (nonatomic, strong, readonly) TTVPlayVideo *playerView;

- (void)setupMidInsertADDataWithADModel:(TTVMidInsertADModel *)adModel;

+ (CGFloat)ttv_pasterFadeInTimeInterval;

@end

@interface TTVMidInsertADViewController (ExploreMovieView)

- (void)startPlayVideoList:(NSArray *)videoList WithCompletionBlock:(TTVMidInsertADPlayCompletionBlock)completion;

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

@protocol TTVMidInsertADDelegate <NSObject>
@optional
- (void)videoPasterADViewControllerToggledToFullScreen:(BOOL)fullScreen animationed:(BOOL)animationed completionBlock:(void(^)(BOOL finished))completionBlock;
- (BOOL)isMovieFullScreen;
- (BOOL)isInDetail;

- (void)replayOriginalVideo;

- (void)setPasterADRotateState:(BOOL)state;

- (void)sendHostPlayerPauseAction;

@end
