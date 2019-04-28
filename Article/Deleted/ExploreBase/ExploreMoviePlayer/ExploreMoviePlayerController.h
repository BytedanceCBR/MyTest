//
//  ExploreMoviePlayerController.h
//  Article
//
//  Created by Chen Hong on 15/5/12.
//
//

#import "SSMoviePlayerController.h"
#import "ExploreMoviePlayerControlView.h"
#import "ExploreVideoSP.h"
#import "TTGroupModel.h"

@class ExploreMoviePlayerController;

@protocol ExploreMoviePlayerControllerDelegate <NSObject>

@property (nonatomic) BOOL isFullScreenButtonAction;

// 点击播放按钮
- (void)movieControllerPlayButtonClicked:(ExploreMoviePlayerController *)movieController replay:(BOOL)replay;

// 点击分享按钮
- (void)movieControllerShareButtonClicked:(ExploreMoviePlayerController *)movieController;

// 全屏切换
- (BOOL)movieControllerFullScreenButtonClicked:(ExploreMoviePlayerController *)movieController isFullScreen:(BOOL)fullScreen completion:(void (^)(BOOL finished))completion;

// 点击播放重试按钮
- (void)movieControlViewRetryButtonClicked:(ExploreMoviePlayerController *)movieController;

- (void)movieControllerRemainderTime:(NSTimeInterval)remainderTime;

// 是否支持旋转
- (BOOL)movieControllerCanRotate:(ExploreMoviePlayerController *)movieController;

// LandscapeLeft <-> LandscapeRight旋转
- (void)movieControllerLandscapeLeftRightRotate:(ExploreMoviePlayerController *)movieController;

// 是否后台进前台暂停播放
- (BOOL)movieControllerShouldPauseWhenEnterForeground:(ExploreMoviePlayerController *)movieController;

- (void)controlViewTouched:(ExploreMoviePlayerControlView *)controlView;
// 播放上一个
- (void)movieControllerPrePlayButtonClicked:(ExploreMoviePlayerController *)movieController;
@optional
//点击更多按钮
- (void)movieControllerMoreButtonClicked:(ExploreMoviePlayerController *)movieController;
- (void)movieControllerShareActionClicked:(ExploreMoviePlayerController *)movieController withActivityType:(NSString *) activityType;


- (NSArray <NSNumber *> *)supportedResolutionTypes;
- (void)movieController:(ExploreMoviePlayerController *)movieController
ResolutionButtonClickedWithType:(ExploreVideoDefinitionType)type
             typeString:(NSString *)typeString;

- (NSString *)currentCDNHost;

- (BOOL)shouldResumePlayWhenInterruptionEnd;
- (BOOL)movieHasFirstFrame;

@end


@interface ExploreMoviePlayerController : SSMoviePlayerController

@property(nonatomic, weak)id<ExploreMoviePlayerControllerDelegate> moviePlayerDelegate;

@property(nonatomic, strong)ExploreMoviePlayerControlView *controlView;

@property(nonatomic, strong) TTGroupModel * gModel;

@property(nonatomic, strong) NSString * adId;

@property(nonatomic, assign) ExploreVideoDefinitionType definitionType;
@property(nonatomic, assign) BOOL enableMultiResolution;

@property(nonatomic, assign) TTVideoPlayType videoPlayType;
@property(nonatomic, assign ,readonly) BOOL isOwnPlayer;
@property (nonatomic, assign) NSInteger         shouldShowShareMore;
@property(nonatomic, copy ,readonly) NSURL *playUrl;
@property (nonatomic, assign) BOOL  isVideoBusiness;


- (BOOL)isMovieFullScreen;

- (void)refreshPlayButton;

- (void)showRetryTipView;

- (void)showRetryTipViewWithTipString:(NSString *)tipString;

- (void)showLoadingTipView;

- (void)hideLoadingTipView;

- (ExploreMoviePlayerControlViewTipType)tipViewType;

- (void)showMovieFinishView;

- (void)enterFullscreen;

- (void)exitFullscreen;

- (void)refreshSlider;

- (BOOL)hasShowTipView;

- (void)refreshTimeLabel:(NSTimeInterval)duration currentPlaybackTime:(NSTimeInterval)currentPlaybackTime;

- (void)refreshResolutionButton;

- (BOOL)hasTipType;

- (void)reuse;
//直播
- (void)showLiveOverTipView;
- (void)showLiveWaitingTipView;
@end
