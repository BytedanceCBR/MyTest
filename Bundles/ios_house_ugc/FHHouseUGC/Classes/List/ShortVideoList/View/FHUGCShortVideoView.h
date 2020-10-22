//
//  FHUGCShortVideoView.h
//  FHHouseUGC
//
//  Created by liuyu on 2020/10/13.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "TTVCellPlayMovieProtocol.h"
#import "TTVDemanderPlayerTracker.h"
#import "TTVPlayerOrientation.h"
#import "TTMovieStore.h"
#import "TTVDemandPlayer.h"
NS_ASSUME_NONNULL_BEGIN
@protocol FHShortPlayVideoDelegate
- (void)movieViewWillMoveToSuperView:(UIView *)newView;
@end


/**
 NOTE: 视频业务专用,其他业务请使用TTVBasePlayVideo
 这个包含视频业务个性化需求.
 */
//@class TTVDemanderTrackerManager;
@class FHDemanderTrackerManager;

@class TTVVideoPlayerModel;
typedef void(^TTVStopFinished)(void);
@interface FHUGCShortVideoView : UIView<TTMovieStoreAction>
@property (nonatomic, strong ,readonly) TTVDemanderTrackerManager *commonTracker;//通用的tracker
@property (nonatomic, weak) NSObject <FHShortPlayVideoDelegate> *delegate;
@property (nonatomic, strong ,readonly) TTVDemandPlayer *player;
@property (nonatomic, strong ) TTVPlayerModel *playerModel;
/**
 切换下一个视频的时候,重置播放器环境数据使用.
 */
- (void)resetPlayerModel:(TTVPlayerModel *)playerModel;
/**
 播放器封面图,可以转化为TTImageInfosModel的videoLargeImageDict,如果非TTImageInfosModel类型的model.
 使用替换 [self.player setLogoImageView:_logoImageView];
 */
- (void)setVideoLargeImageDict:(NSDictionary *)videoLargeImageDict;
/**
 移除所有的正在播放的播放器
 */
+ (void)removeAll;
/**
 移除所有的正在播放的播放器,除了传入的播放器.
 */
+ (void)removeExcept:(UIView <TTMovieStoreAction> *)video;

- (void)exitFullScreen:(BOOL)animated completion:(TTVPlayerOrientationCompletion)completion;

- (void)stopWithFinishedBlock:(TTVStopFinished)finishedBlock;
+ (FHUGCShortVideoView *)currentPlayingPlayVideo;

- (BOOL)isAdMovie;

- (void)removePlayer;

- (void)play;
- (void)pause;
- (void)stop;
- (void)reset;
- (void)readyToPlay;
@end

NS_ASSUME_NONNULL_END
