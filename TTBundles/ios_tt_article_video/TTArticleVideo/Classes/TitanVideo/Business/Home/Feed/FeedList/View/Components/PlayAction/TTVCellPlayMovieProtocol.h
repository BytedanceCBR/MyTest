//
//  TTVCellPlayMovieProtocol.h
//  Article
//
//  Created by panxiang on 2017/5/12.
//
//

#import <Foundation/Foundation.h>
#import "ExploreVideoSP.h"
#import "ExploreCellBase.h"
#import "TTVideoFeedListEnum.h"

@protocol TTVCellPlayMovieDelegate <NSObject>

@optional
- (void)playerPlaybackStopped;
- (void)playerPlaybackBreak;
- (void)playerPlaybackFailed;
- (void)playerPlaybackPlaying;
- (void)playerPlaybackPause;

- (void)ttv_shareButtonOnMovieTopViewDidPress;
- (void)ttv_moreButtonOnMovieTopViewDidPress;
- (void)ttv_shareButtonOnMovieFinishViewDidPress;
- (void)ttv_directShareActionWithActivityType:(NSString *)activityType;
- (void)ttv_directShareActionOnMovieWithActivityType:(NSString *)activityType;
- (void)ttv_invalideMovieView;
- (void)ttv_movieViewDidExitFullScreen;
- (void)ttv_movieViewWillMoveTosuperView:(UIView *)supView;
- (void)ttv_commodityViewClosed;
- (void)ttv_commodityViewShowed;
- (void)ttv_moviePlayFinished;
- (void)ttv_movieReplayAction;
@end

@protocol TTVCellPlayMovieProtocol <NSObject>
@property (nonatomic, strong) UIView *movieView;
@property (nonatomic, strong) UIView *logo;
@property (nonatomic, weak) NSObject <TTVCellPlayMovieDelegate> *delegate;

- (void)play;
- (UIView *)currentMovieView;
- (BOOL)isFullScreen;
- (BOOL)isRotating;
- (BOOL)isPlaying;
- (void)invalideMovieViewAfterDelay:(BOOL)afterDelay;
- (void)didEndDisplaying;
- (BOOL)isPaused;
- (BOOL)isPlayingFinished;
- (BOOL)isPlayingError;
- (void)viewWillAppear;
- (void)viewWillDisappear;
- (void)cellInListWillDisappear:(TTCellDisappearType)context;
- (void)addCommodity;
/**
 设置title font 以及在非全屏下是否显示title
 */
@optional
- (void)setVideoTitle:(NSString *)title;
- (void)setVideoWatchCount:(NSInteger)watchCount;
@end
