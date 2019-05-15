//
//  ExploreMovieView.h
//  Article
//
//  Created by Zhang Leonardo on 15-3-5.
//
//

#import "SSViewBase.h"
#import "ExploreVideoSP.h"
#import "ExploreOrderedData+TTBusiness.h"
#import "TTGroupModel.h"
#import "ExploreMovieViewTracker.h"
#import "ExploreMoviePlayerController.h"
#import "TTImageInfosModel.h"
#import "TTVideoRotateScreenController.h"
#import "TTMovieFullscreenProtocol.h"
#import "ExploreMovieViewModel.h"
#import "TTMovieStore.h"
#import "TTMoviePlayerDefine.h"

#define kExploreMovieViewPlaybackFinishNotification @"kExploreMovieViewPlaybackFinishNotification" //包括播放结束 ,4G流量播放,提醒,用户中断播放
#define kExploreMovieViewPlaybackFinishNormallyNotification @"kExploreMovieViewPlaybackFinishNormallyNotification" //看视频播放结束,无其他情况.

#define kExploreNeedStopAllMovieViewPlaybackNotification @"kExploreNeedStopAllMovieViewPlaybackNotification"
#define kExploreStopMovieViewPlaybackNotification @"kExploreStopMovieViewPlaybackNotification"
#define kExploreStopMovieViewPlaybackWithoutRemoveMovieViewNotification @"kExploreStopMovieViewPlaybackWithoutRemoveMovieViewNotification"
#define kExploreMovieViewStartPlaybackNotification @"kExploreMovieViewStartPlaybackNotification"
#define kExploreMovieViewDeallocNotification @"kExploreMovieViewDeallocNotification"
#define kExploreMovieViewPauseNotification @"kExploreMovideViewPauseNotification"

typedef void(^videoPlayFinishBlock)();
extern NSString * _Nonnull const kExploreMovieViewDidChangeFullScreenNotifictaion;

@protocol ExploreMovieViewDelegate, ExploreMovieViewPasterADDelegate, ExploreMovieManagerDelegate;
@class ExploreMoviePlayerController, ExploreVideoModel, ExploreMovieView;

@interface ExploreMovieView : SSViewBase <TTVideoRotateViewProtocol, TTMovieFullscreenProtocol ,TTMovieStoreAction>

@property(nonatomic,weak,nullable)id <ExploreMovieViewDelegate> movieViewDelegate;
@property(nonatomic,weak,nullable)id<ExploreMovieViewPasterADDelegate> pasterADDelegate;
@property(nonatomic,strong,nullable)ExploreMovieViewTracker *tracker;
@property(nonatomic,strong,nullable)ExploreMoviePlayerController *moviePlayerController;

@property (nonatomic, strong, nullable) ExploreOrderedData *movieDelegateData;
@property (nonatomic, strong, nullable) ExploreMovieViewModel *videoModel;
@property (nonatomic, assign, readonly) BOOL isPlaying;
@property (nonatomic, assign) BOOL isPlayingWhenBackToFloat;
@property (nonatomic, assign, readonly) BOOL autoPause;
@property(nonatomic,assign)BOOL showDetailButtonWhenFinished;
@property(nonatomic,assign)BOOL stopMovieWhenFinished;
@property(nonatomic,assign)BOOL pauseMovieWhenEnterForground;
@property(nonatomic,assign)BOOL videoDidPlayable;
@property(nonatomic,assign)BOOL alwaysHideTitleBarView;   //直播室使用
@property(nonatomic,assign)BOOL alwaysTouchScreenToExit;  //直播室使用
@property(nonatomic,assign)BOOL stayFullScreenWhenFinished; //直播室里面，播放完成不退出全屏
@property(nonatomic,assign)BOOL needsSeekToTimeWhenStart; //MovieView刚开始播放的时候是否需要seekToTime，用于缓存上次播放时间后的再次播放
@property(nonatomic,assign)BOOL shouldShowNewFinishUI; //是否应该显示播放结束新UI
@property(nonatomic,assign) TTVideoPasterADEnableOptions pasterADEnableOptions;
@property(nonatomic,assign,readonly) NSTimeInterval fetchURLTime;
@property(nonatomic,assign) BOOL isRotateAnimating;
@property(nonatomic,assign)BOOL enableMultiResolution;
@property(nonatomic,assign)BOOL forbidFullScreenWhenPresentAd; //当进入详情页从屏幕下方present出广告时不允许进入全屏

@property (nullable, nonatomic, copy) EventOfMovieViewMonitorBlock didExitFullScreenHandler;
@property (nullable, nonatomic, copy) EventOfMovieViewMonitorBlock clickPlayButtonToPlayBlock;
@property (nonatomic, copy ,nullable) MoviePlayStatus playStartBlock;
@property (nonatomic, copy ,nullable) MoviePlayStatus playStartShowCacheLabelBlock;
@property (nonatomic, copy ,nullable) MoviePlayStatus willPlayableBlock;
@property (nonatomic, copy ,nullable) MoviePlayStatus willFinishBlock;
@property (nonatomic, copy, nullable) videoPlayFinishBlock videoFinishBlock;

//视频浮层使用
@property (nonatomic, assign) BOOL disableNetworkAlert;

@property(nonatomic, assign) BOOL forbidLayout;
@property(nonatomic, assign) BOOL isChangingMovieSize; //正在改变播放器的大小，详情页拖拽视频
@property (nonatomic, strong, nullable) NSNumber *liveStatus;
@property (nonatomic, assign) BOOL isPasterADSource; // 用于判断播放的是否是贴片广告(因为播放传入的url，无法通过adid判断)
- (nullable instancetype)initWithFrame:(CGRect)frame movieViewModel:(nullable ExploreMovieViewModel *)movieViewModel;

- (void)playVideoForVideoID:(nullable NSString *)videoID exploreVideoSP:(ExploreVideoSP)sp;
- (void)playVideoForVideoID:(nullable NSString *)videoID exploreVideoSP:(ExploreVideoSP)sp videoPlayType:(TTVideoPlayType)type;
- (void)playVideoWithVideoInfo:(nonnull NSDictionary *)videoInfo exploreVideoSP:(ExploreVideoSP)sp videoPlayType:(TTVideoPlayType)type;
//直播室tacker dic include all ---- tag、value、ext_value、extraDic
- (nonnull instancetype)initWithFrame:(CGRect)frame
                         type:(ExploreMovieViewType)type
                   trackerDic:(nullable NSDictionary *)trackerDic
               movieViewModel:(nonnull ExploreMovieViewModel *)movieViewModel;

// 播放第三方网页中的视频时，直接播放url
- (void)playVideoForVideoURL:(nullable NSString *)videoURL;

// 播放贴片广告
- (void)playPasterADForVideoModel:(nullable ExploreVideoModel *)videoModel;

- (nullable ExploreMoviePlayerController *)getMoviePlayerController;

- (void)userPlay;//直接播放,不受_autoPause等变量的影响,
- (void)userPause;//直接暂停,不受_autoPause等变量的影响,

//管理了自动pause ,自动play.
- (void)stopMovie;
- (void)playMovie;
- (void)pauseMovie;
- (void)pauseLive;//临时方法
- (void)resumeMovie;
- (void)stopMovieAfterDelay;
- (void)stopMovieAfterDelayNoNotification;

- (BOOL)shouldPasterADPause;

- (BOOL)isPlaying;//正在播放+点击过播放按钮
- (BOOL)isPaused;
- (BOOL)isStoped;
- (BOOL)isPlayingFinished;
- (BOOL)isPlayingError;
- (void)willReusePlayer;
- (void)didReusePlayer;

- (BOOL)exitFullScreenIfNeed:(BOOL)animation;

+ (void)removeAllExploreMovieView;
+ (void)stopAllExploreMovieView;

- (void)showDetailButtonIfNeeded;
- (void)pauseMovieAndShowToolbar;
- (void)setToolbarHidden:(BOOL)hidden autoHide:(BOOL)autoHide;
- (void)hiddenMiniSliderView:(BOOL)hidden;
- (void)showLoadingView:(ExploreMoviePlayerControlViewTipType)type;
- (void)hiddenLoadingView;

- (nullable NSString *)playVID;
- (nullable NSString *)playMainURL;
- (BOOL)isMovieFullScreen;
- (void)updateMovieInFatherViewFrame:(CGRect)frame;

- (void)setVideoTitle:(nullable NSString *)title fontSizeStyle:(TTVideoTitleFontStyle)style showInNonFullscreenMode:(BOOL)bShow;
- (void)setVideoDuration:(NSTimeInterval)duration;
- (void)setLogoImageDict:(nullable NSDictionary *)imageDict;
- (void)setLogoImageModel:(nullable TTImageInfosModel *)model;
- (void)setLogoImageUrl:(nullable NSString *)url;

- (void)markAsDetail;
- (void)unMarkAsDetail;

- (void)updateFrame;

- (void)enableRotate:(BOOL)bEnable;

- (void)enableNetWorkIndicator:(BOOL)bEnable;

- (nullable NSString *)videoID;

- (NSTimeInterval)currentPlayingTime;

- (NSTimeInterval)duration;

- (BOOL)hasValidAfterParserAD;
- (BOOL)isLiveVideo;
- (BOOL)isPlayingPasterADVideo; // 贴片广告视频是嵌入在点播视频里，这个API用来判断点播视频播放器是否在播放贴片视频
- (BOOL)isPasterADVideo;

- (BOOL)isAdMovie;

//进入全屏
- (BOOL)enterFullscreen:(BOOL)animation completion:(void (^ _Nullable)(BOOL finished))completion;
- (BOOL)exitFullScreen:(BOOL)animation completion:(void (^ _Nullable)(BOOL finished))completion;

//流量提示窗相关
+ (BOOL)hasShownTrafficView; //是否已经显示过流量提示窗
+ (void)changeAlwaysCloseAlert;
- (BOOL)isShowingTrafficView;

//是否全屏
+ (BOOL)isFullScreen;
+ (ExploreMovieView *_Nullable)currentFullScreenMovieView;

//是否有正在播放
+ (BOOL)currentVideoPlaying;
+ (void)setCurrentVideoPlaying:(BOOL)play;

@end

@class TTVFeedItem;
@protocol ExploreMovieViewDelegate <NSObject>

@optional
- (void)showDetailButtonClicked;
- (BOOL)shouldShowDetailButton;
- (CGRect)movieViewFrameAfterExitFullscreen;
- (BOOL)shouldDisableUserInteraction;
- (BOOL)shouldResumePlayWhenActive;
- (BOOL)shouldStopMovieWhenInBackground;
- (void)movieDidExitFullScreen;
- (void)movieDidEnterFullScreen;
- (void)controlViewTouched:(ExploreMoviePlayerControlView * _Nullable)controlView;
- (BOOL)shouldPlayWhenViewWillAppear;
- (void)shareButtonClicked;
- (void)FullScreenshareButtonClicked;
- (void)moreButtonClicked;
- (void)shareActionClickedWithActivityType:(NSString *)activityType;
- (void)replayButtonClicked;
- (void)retryButtonClicked;
- (void)movieRemainderTime:(NSTimeInterval)remainderTime;
- (void)movieSeekTime:(NSTimeInterval)seeekTime;
- (void)replayButtonClickedInTrafficView;
- (void)prePlayButtonClicked;// 播放上一个
- (void)movieViewWillMoveToSuperView:(UIView * _Nonnull)newView;
@end

@protocol ExploreMovieViewPasterADDelegate <NSObject>
@optional
- (void)pasterADWillStart;
- (void)pasterADWillFinishWithPlayEnd:(BOOL)playEnd;
- (void)pasterADWillPause;
- (void)pasterADWillResume;
- (void)pasterADWillStop;
- (void)pasterADWillStalle;
- (void)pasterADWillPlayable;
- (void)pasterADNeedsRetry;
- (void)pasterADNeedsToFullScreen:(BOOL)isFullScreen;
- (void)pasterADWillResignActive;
- (void)pasterADDidBecomeActive;

@end



