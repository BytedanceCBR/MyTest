//
//  ExploreMovieView.m
//  Article
//
//  Created by Zhang Leonardo on 15-3-5.
//
//

#import "ExploreMovieView.h"
#import "ExploreMovieManager.h"
#import "ExploreVideoModel.h"
#import "TTIndicatorView.h"
#import "NetworkUtilities.h"
#import "TTReachability.h"
#import "SSURLTracker.h"
#import "TTCategoryDefine.h"
#import "TTThemedAlertController.h"
#import "TTImageView+TrafficSave.h"
#import "SSLogDataManager.h"
#import "TTAlphaThemedButton.h"
#import "TTIndicatorView.h"
#import "TTAudioWaveView.h"
#import "TTVideoAutoPlayManager.h"
#import "TTModuleBridge.h"
#import "TTAudioSessionManager.h"
#import "TTVideoPasterADViewController.h"
#import "TTMovieViewCacheManager.h"
#import "Article.h"
#import "UIImage+TTThemeExtension.h"
#import "TTStringHelper.h"
#import "TTDeviceHelper.h"
#import "TTNetworkHelper.h"
#import "TTMovieFullscreenViewController.h"
#import "TTMovieEnterFullscreenAnimatedTransitioning.h"
#import "TTMovieExitFullscreenAnimatedTransitioning.h"
#import "UIViewController+TTMovieUtil.h"
#import <StoreKit/StoreKit.h>
#import "TTIndicatorView.h"
#import "TTMovieNetTrafficView.h"
#import "TTMovieResolutionSelectView.h"
#import "TTAdVideoRelateAdModel.h"
#import "TTVideoDefinationTracker.h"

#import "TTVFeedListCell.h"
#import "TTMovieStore.h"
#import "TTUIResponderHelper.h"
#import "TTNetworkHelper.h"
#import "TTHTTPDNSManager.h"
#import "TTVPlayVideo.h"
#import "TTVVideoRotateScreenWindow.h"
#import "TTVAudioActiveCenter.h"
#import "TTVNetTrafficFreeFlowTipView.h"
#import "TTFlowStatisticsManager.h"
#import "TTRoute.h"
#import "TTVPalyerTrafficAlert.h"
#import "ExploreOrderedData+MovieDelegateData.h"
#import <TTSettingsManager/TTSettingsManager.h>
#import "TTAPPIdleTime.h"

#define kSnapViewTag 10003
#define kFirstFrameView 10001
#define kFullScreenChangeAnimationTime 0.3f

#define kAlertTitle @"您当前正在使用移动网络，继续播放将消耗流量"
#define kAlertStop @"停止播放"
#define kAlertPlay @"继续播放"

extern BOOL ttvs_isVideoNewRotateEnabled(void);

typedef NS_ENUM(NSInteger, TTVideoPlayRequestStatus) {
    TTVideoPlayRequestStatusSuccess = 0,
    TTVideoPlayRequestStatusFail,
//    TTVideoPlayRequestStatusApiFail,
//    TTVideoPlayRequestStatusResourceFail,
//    TTVideoPlayRequestStatusResourceTimeout,
};

typedef NS_ENUM(NSInteger, TTVideoTrafficViewStatus) {
    TTVideoTrafficViewStatusStart = 0,
    TTVideoTrafficViewStatusDuring,
    TTVideoTrafficViewStatusReplay,
};


typedef void(^videoPlayFinishBlock)();

static BOOL kAlwaysCloseAlert = NO;
static BOOL kHasAlreadyShownAlert = NO; //如果已经显示过流量提示则置为YES
static BOOL isFullScreenInternal__ = NO;

static int hasShowAlertNumber = 0;

static NSString *const video_play_request_status = @"video_play_request_status";
static NSString *const video_play_first_frame_interval = @"video_play_first_frame_interval";
static NSString *const video_play_load_size = @"video_play_load_size";
static NSString *const video_play_error = @"video_play_error";
NSString *const kExploreMovieViewDidChangeFullScreenNotifictaion = @"kExploreMovieViewDidChangeFullScreenNotifictaion";
static __weak ExploreMovieView *currentFullScreenMovieView_ = nil;

@interface ExploreMovieView()<SSMoviePlayerControllerDelegate, ExploreMoviePlayerControllerDelegate, ExploreMovieManagerDelegate, SSMoviePlayerTrackManagerDelegate, TTVideoPasterADDelegate, UIViewControllerTransitioningDelegate, TTMovieFullscreenViewControllerDelegate>
{
    BOOL _enableRotate ;      //控制是否旋转为横屏，否则直接竖屏显示
    BOOL _noNetWorkIndicator;
    BOOL _isPlaybackEnded;
    BOOL _hasSendTrackLog;

    int  _playURLIndex;
    
    BOOL _isRotateAnimating;
    
    BOOL _resignActive;
    BOOL _isPlayingBeforeResignActive; //切出app前是否处于暂停状态
    BOOL _isPrepared;
    BOOL _isPauseOnNetworkChanged;
    BOOL _hasPlayLocalFailed; //是否播放本地视频失败
    BOOL _isShowingConnectAlert;
    BOOL _isNormalDetailMovieView; //是否是常规的详情页视频，不包含webView中嵌套的和文章详情页下的广告视频
    NSTimeInterval _playRequestTimestamp;
    BOOL _shouldExitFullScreenLater; //为了解决播放结束时可能无法退出全屏
    BOOL _autoPause;
    BOOL _userPause;
    BOOL _viewIsAppear;
    BOOL _hasError;
    NSTimeInterval _preResolutionWatchingDuration;
    BOOL _isNewRotate;
}

@property(nonatomic, strong)TTVideoURLRequestInfo *urlRequestInfo;

@property(nonatomic, strong)ExploreMovieManager * movieManager;
@property(nonatomic, strong)ExploreVideoModel * letvVideoModel;
@property(nonatomic, copy)NSString *hostName;
@property(nonatomic, strong)TTGroupModel *gModel;
@property(nonatomic, copy)NSString *aID;
@property(nonatomic, copy)NSString *cID;
@property(nonatomic, assign)BOOL showedOneFrame;
@property(nonatomic, assign)BOOL isStoppedAfterDelay;
@property(nonatomic, assign)BOOL isStoped;
@property(nonatomic, assign)BOOL isSwitchMultiResolution;
@property(nonatomic, assign)BOOL hasAlreadyStopped;//已经stop了,再次调用stop不在发sendEndTrack

//4.7 列表页播放时传入
@property(nonatomic, copy)NSDictionary *logoImageDict;

@property (nonatomic, assign, readwrite) BOOL isPlaying;
@property (nonatomic, strong) TTAudioWaveView *audioWave;

@property (nonatomic, assign) BOOL alwaysShowDetailButton;

@property (nonatomic, strong) TTVideoPasterADViewController *pasterADController;

@property (nonatomic, assign) BOOL liveVideoRestartOnce;

//视频全屏时的容器viewController
@property (nonatomic, weak) TTMovieFullscreenViewController *fullscreenViewController;
@property (nonatomic, strong) TTVideoRotateScreenController *rotateController;
//流量提示视图
@property (nonatomic, strong) TTMovieNetTrafficView *trafficView;
@property (nonatomic, strong) TTVNetTrafficFreeFlowTipView *freeFlowTipView;
@property (nonatomic, assign) BOOL hasShowTrafficToast;

@property (nonatomic, assign) BOOL notShowTraffic;

@property (nonatomic, assign) BOOL playPasterADSuccess;
@property (nonatomic, assign) BOOL disablePlayPasterAD;
@end

@implementation ExploreMovieView

@synthesize baseTableView = _baseTableView;
@synthesize indexPath = _indexPath;
@synthesize rotateViewRect = _rotateViewRect;
@synthesize rotateSuperView = _rotateSuperView;
@synthesize isFullScreenButtonAction = _isFullScreenButtonAction;

@synthesize hasMovieFatherCell = _hasMovieFatherCell;
@synthesize movieFatherCellTableView = _movieFatherCellTableView;
@synthesize movieFatherCellIndexPath = _movieFatherCellIndexPath;
@synthesize movieFatherView = _movieFatherView;
@synthesize movieInFatherViewFrame = _movieInFatherViewFrame;

- (void)dealloc
{

    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(checkLoadingTimeout) object:nil];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(removeTheMovieView) object:nil];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(showNetworkAlertIfNeeded) object:nil];

    [[NSNotificationCenter defaultCenter] removeObserver:self];

    _movieManager.delegate = nil;
    _moviePlayerController.movieDelegate = nil;
    _moviePlayerController.moviePlayerDelegate = nil;
    [_movieManager cancelOperation];
    [_moviePlayerController stop];
    _moviePlayerController = nil;
    [[NSNotificationCenter defaultCenter] postNotificationName:kExploreMovieViewDeallocNotification object:nil];
}

+ (void)load
{
    //停止其他播放器
    [[TTModuleBridge sharedInstance_tt] registerAction:@"exploreMovieView.removeAllExploreMovieView" withBlock:^id(id object,NSDictionary *params) {
        
        [ExploreMovieView removeAllExploreMovieView];
        
        return nil;
    }];
    
    [[TTModuleBridge sharedInstance_tt] registerAction:@"exploreMovieView.videoID" withBlock:^id _Nullable(id  _Nullable object, id  _Nullable params) {
        if (![object isKindOfClass:[ExploreMovieView class]]) {
            return nil;
        }
        NSString *videoID = ((ExploreMovieView *)object).videoID;
        return videoID;
    }];
    
    [[TTModuleBridge sharedInstance_tt] registerAction:@"exploreMovieView.playMainURL" withBlock:^id _Nullable(id  _Nullable object, id  _Nullable params) {
        if (![object isKindOfClass:[ExploreMovieView class]]) {
            return nil;
        }
        NSString *playMainURL = ((ExploreMovieView *)object).playMainURL;
        return playMainURL;
    }];
    
    [[TTModuleBridge sharedInstance_tt] registerAction:@"exploreMovieView.initDetailMovieView" withBlock:^id(id object,NSDictionary *params) {
        ExploreMovieViewModel *movieViewModel = params[@"viewModel"];
        CGRect frame = [params[@"frame"] CGRectValue];
        NSDictionary *extra = [params tt_dictionaryValueForKey:@"extra"];
        NSString *posterUrl = [params tt_stringValueForKey:@"posterUrl"];
        ExploreMovieView *movieView = [[ExploreMovieView alloc] initWithFrame:frame
                                                  movieViewModel:movieViewModel];
        movieView.moviePlayerController.shouldShowShareMore = NO;
        movieView.stopMovieWhenFinished = YES;
        [movieView setVideoTitle:movieViewModel.movieTitle
                        fontSizeStyle:TTVideoTitleFontStyleNormal
              showInNonFullscreenMode:NO];
        
        movieView.tracker.type = ExploreMovieViewTypeDetail;
        
        //额外信息,比如统计等
        if (extra && extra.allKeys.count > 0) {
            movieView.tracker.cID = [extra stringValueForKey:@"category_id" defaultValue:@""];
            movieView.tracker.ssTrackerDic = extra;
            //video_play&video_over 3.0埋点数据
            for (NSString *key in extra.allKeys) {
                [movieView.tracker addExtraValue:[extra valueForKey:key] forKey:key];
            }
        }
        
        if (!isEmptyString(posterUrl)) {
            [movieView setLogoImageUrl:posterUrl];
        }
        
        return movieView;
    }];
    
    [[TTModuleBridge sharedInstance_tt] registerAction:@"exploreMovieView.updateMovieInFatherViewFrame" withBlock:^id _Nullable(id  _Nullable object, NSDictionary   * _Nullable params) {
        if (![object isKindOfClass:[ExploreMovieView class]]) {
            return nil;
        }
        CGRect frame = [params[@"frame"] CGRectValue];
        [((ExploreMovieView *)object) updateMovieInFatherViewFrame:frame];
        return nil;
    }];
    
    [[TTModuleBridge sharedInstance_tt] registerAction:@"exploreMovieView.isMovieFullScreen" withBlock:^id _Nullable(id  _Nullable object, NSDictionary   * _Nullable params) {
        if (![object isKindOfClass:[ExploreMovieView class]]) {
            return nil;
        }
        
        return @([((ExploreMovieView *)object) isMovieFullScreen]);
    }];
    
    [[TTModuleBridge sharedInstance_tt] registerAction:@"exploreMovieView.playVID" withBlock:^id _Nullable(id  _Nullable object, NSDictionary   * _Nullable params) {
        if (![object isKindOfClass:[ExploreMovieView class]]) {
            return nil;
        }
        
        return [((ExploreMovieView *)object) playVID];
    }];
    
    [[TTModuleBridge sharedInstance_tt] registerAction:@"exploreMovieView.enterFullScreen" withBlock:^id(id object,NSDictionary *params) {
        
         id finishBlock = [params objectForKey:@"finishBlock"];
        if ([object isKindOfClass:[ExploreMovieView class]]) {
            ExploreMovieView *view = (ExploreMovieView *)object;
            [view enterFullscreen:YES completion:^(BOOL finished) {
                if (finishBlock) {
                    ((void(^)())finishBlock)();
                }
            }];
        }
        
        return nil;
    }];
    
    [[TTModuleBridge sharedInstance_tt] registerAction:@"exploreMovieView.exitFullScreen" withBlock:^id(id object,NSDictionary *params) {
        
        id finishBlock = [params objectForKey:@"finishBlock"];
        
        if ([object isKindOfClass:[ExploreMovieView class]]) {
            ExploreMovieView *view = (ExploreMovieView *)object;
            [view exitFullScreen:YES completion:^(BOOL finished) {
                if (finishBlock) {
                    ((void(^)())finishBlock)();
                }
            }];
        }
        
        return nil;
    }];
    
    [[TTModuleBridge sharedInstance_tt] registerAction:@"exploreMovieView.exitFullScreenIfNeed" withBlock:^id(id object,NSDictionary *params) {
        
        if ([object isKindOfClass:[ExploreMovieView class]]) {
            ExploreMovieView *view = (ExploreMovieView *)object;
            [view exitFullScreenIfNeed:NO];
        }
        
        return nil;
    }];
    
    [[TTModuleBridge sharedInstance_tt] registerAction:@"exploreMovieView.playVideoID" withBlock:^id(id object,NSDictionary *params) {
        
        NSString *videoId = [params objectForKey:@"videoId"];
        TTVideoPlayType videoPlayType = (TTVideoPlayType)[params tt_integerValueForKey:@"videoPlayType"];
        ExploreVideoSP sp = [params tt_integerValueForKey:@"sp"];
        if ([object isKindOfClass:[ExploreMovieView class]]) {
            ExploreMovieView *view = (ExploreMovieView *)object;
            [view playVideoForVideoID:videoId exploreVideoSP:sp videoPlayType:videoPlayType];
        }
        
        return nil;
    }];
    
    
    [[TTModuleBridge sharedInstance_tt] registerAction:@"exploreMovieView.playVideoForVideoURL" withBlock:^id(id object,NSDictionary *params) {
        
        if ([object isKindOfClass:[ExploreMovieView class]]) {
            ExploreMovieView *view = (ExploreMovieView *)object;
            [view playVideoFromURL:[params objectForKey:@"videoUrl"]];
        }
        
        return nil;
    }];
    
    
    [[TTModuleBridge sharedInstance_tt] registerAction:@"exploreMovieView.stopMovie" withBlock:^id(id object,NSDictionary *params) {
        
        if ([object isKindOfClass:[ExploreMovieView class]]) {
            ExploreMovieView *view = (ExploreMovieView *)object;
            [view stopMovie];
        }
        
        return nil;
    }];
    
    [[TTModuleBridge sharedInstance_tt] registerAction:@"exploreMovieView.pauseMovie" withBlock:^id(id object,NSDictionary *params) {
        
        if ([object isKindOfClass:[ExploreMovieView class]]) {
            ExploreMovieView *view = (ExploreMovieView *)object;
            [view pauseMovie];
        }
        
        return nil;
    }];
    
    [[TTModuleBridge sharedInstance_tt] registerAction:@"exploreMovieView.pauseMovieAndShowToolbar" withBlock:^id(id object,NSDictionary *params) {
        
        if ([object isKindOfClass:[ExploreMovieView class]]) {
            ExploreMovieView *view = (ExploreMovieView *)object;
            [view pauseMovieAndShowToolbar];
        }
        
        return nil;
    }];
    
    [[TTModuleBridge sharedInstance_tt] registerAction:@"exploreMovieView.playMovie" withBlock:^id(id object,NSDictionary *params) {
        
        if ([object isKindOfClass:[ExploreMovieView class]]) {
            ExploreMovieView *view = (ExploreMovieView *)object;
            [view.moviePlayerController seekToProgress:0.0];
            [view playMovie];
        }
        
        return nil;
    }];
    
    [[TTModuleBridge sharedInstance_tt] registerAction:@"exploreMovieView.isPlaying" withBlock:^id(id object,NSDictionary *params) {
        
        if ([object isKindOfClass:[ExploreMovieView class]]) {
            ExploreMovieView *view = (ExploreMovieView *)object;
            return [NSNumber numberWithBool:[view isPlaying]];
        }
        
        return nil;
    }];
    
    [[TTModuleBridge sharedInstance_tt] registerAction:@"exploreMovieView.isPaused" withBlock:^id(id object,NSDictionary *params) {
        
        if ([object isKindOfClass:[ExploreMovieView class]]) {
            ExploreMovieView *view = (ExploreMovieView *)object;
            return [NSNumber numberWithBool:[view isPaused]];
        }
        
        return nil;
    }];
    
    [[TTModuleBridge sharedInstance_tt] registerAction:@"exploreMovieView.resumeMovieView" withBlock:^id(id object,NSDictionary *params) {
        
        if ([object isKindOfClass:[ExploreMovieView class]]) {
            ExploreMovieView *view = (ExploreMovieView *)object;
            [view resumeMovie];
        }
        
        return nil;
    }];
}


- (instancetype)initWithFrame:(CGRect)frame
                         type:(ExploreMovieViewType)type
                   trackerDic:(NSDictionary *)trackerDic
               movieViewModel:(ExploreMovieViewModel *)movieViewModel
{
    self = [super initWithFrame:frame];
    if (self) {
        if (!movieViewModel.shouldNotRemoveAllMovieView) {
            [ExploreMovieView removeAllExploreMovieView];
        }
        [[TTMovieStore shareTTMovieStore] addMovie:self];
        _viewIsAppear = YES;
        _isPlayingBeforeResignActive = YES;
        self.clipsToBounds = YES;
        movieViewModel.lastDefinitionType = ExploreVideoDefinitionTypeUnknown;
        self.liveVideoRestartOnce = NO;
        _enableRotate = YES;
        _noNetWorkIndicator = YES;
        _alwaysTouchScreenToExit = NO;
        self.showDetailButtonWhenFinished = isEmptyString(movieViewModel.aID) ? YES : NO;
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

        self.pasterADEnableOptions = TTVideoEnablePasterALL;

         // 友盟+数据组统计
        self.tracker = [[ExploreMovieViewTracker alloc] init];
        self.tracker.enableRotate = YES;
        self.tracker.movieView = self;
        self.tracker.authorId = movieViewModel.auithorId;
        BOOL isOwnPlayer = [SSCommonLogic isVideoOwnPlayerEnabled] && [UIDevice currentDevice].systemVersion.floatValue >= 8;

        if ([SSCommonLogic isLiveUseOwnPlayerEnabled]) {
            if (movieViewModel.useSystemPlayer) {
                isOwnPlayer = NO;
            }
        }
        else
        {
            if (movieViewModel.videoPlayType == TTVideoPlayTypeLive ||
                movieViewModel.videoPlayType == TTVideoPlayTypeLivePlayback ||
                movieViewModel.useSystemPlayer) {
                isOwnPlayer = NO;
            }
        }

        //直播聊天室控件不同
        if (type == ExploreMovieViewTypeLiveChatRoom) {
            self.moviePlayerController = [[ExploreMoviePlayerController alloc] initWithOwnPlayer:isOwnPlayer];
        }
        //其他地方点播直播通用
        else {
            self.moviePlayerController = [[ExploreMoviePlayerController alloc] initWithOwnPlayer:isOwnPlayer];
        }

        self.moviePlayerController.frame = self.bounds;
        self.videoModel = movieViewModel;
        [self.moviePlayerController prepareInit];

        if (type == ExploreMovieViewTypeLiveChatRoom) {
            _stayFullScreenWhenFinished = YES;
            self.tracker.type = type;
            self.tracker.ssTrackerDic = trackerDic;
            self.moviePlayerController.videoPlayType = TTVideoPlayTypeNormal;
        }

        _moviePlayerController.movieDelegate = self;
        _moviePlayerController.moviePlayerDelegate = self;
        _moviePlayerController.definitionType = [[self class] selectedDefinitionType];


        [self addSubview:_moviePlayerController.view];
        [self.moviePlayerController.controlView.showDetailButton addTarget:self action:@selector(showDetailButtonClicked) forControlEvents:UIControlEventTouchUpInside];

        self.tracker.moviePlayerController = self.moviePlayerController;

        // 视频质量统计
        SSMoviePlayerTrackManager *trackManager = [[SSMoviePlayerTrackManager alloc] init];
        trackManager.logReceiver = (id<SSMovieLogReceiver>)[SSLogDataManager shareManager];
        trackManager.trackDelegate = self;
        _moviePlayerController.trackManager = trackManager;
        
        // 根据vid请求视频url
        self.movieManager = [[ExploreMovieManager alloc] init];
        _movieManager.delegate = self;

        _isPlaybackEnded = NO;
        self.isPlaying = NO;
        
        _pauseMovieWhenEnterForground = YES;
        
        _trafficView = [[TTMovieNetTrafficView alloc] initWithFrame:self.bounds];
        _trafficView.hidden = YES;
        [self addSubview:_trafficView];
        
        _rotateController = [[TTVideoRotateScreenController alloc] initWithRotateView:self];
        
//        if(movieViewModel.videoPlayType != TTVideoPlayTypePasterAD) {
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(connectionChanged:)
                                                         name:kReachabilityChangedNotification
                                                       object:nil];
//        }
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(applicationDidEnterBackground:)
                                                     name:UIApplicationDidEnterBackgroundNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillResignActive:) name:UIApplicationWillResignActiveNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
    }
    return self;
}

- (void)updateTrackWithMovieViewModel:(ExploreMovieViewModel *)movieViewModel
{
    self.gModel = movieViewModel.gModel;
    self.aID = movieViewModel.aID;
    self.cID = movieViewModel.cID;
    self.tracker.type = movieViewModel.type;
    self.tracker.aID = movieViewModel.aID;
    self.tracker.cID = movieViewModel.cID;
    self.tracker.clickTrackURLs = movieViewModel.clickTrackURLs;
    self.tracker.clickTrackUrl = movieViewModel.clickTrackUrl;
    self.tracker.playTrackUrls = movieViewModel.playTrackUrls;
    self.tracker.activePlayTrackUrls = movieViewModel.activePlayTrackUrls;
    self.tracker.playOverTrackUrls = movieViewModel.playOverTrackUrls;
    self.tracker.effectivePlayTrackUrls = movieViewModel.effectivePlayTrackUrls;
    self.tracker.videoThirdMonitorUrl = movieViewModel.videoThirdMonitorUrl;
    self.tracker.gModel = movieViewModel.gModel;
    self.tracker.logExtra = movieViewModel.logExtra;
    self.tracker.gdLabel = movieViewModel.gdLabel;
    self.tracker.videoPlayType = movieViewModel.videoPlayType;
    self.tracker.trackSDK = movieViewModel.trackSDK;
    self.moviePlayerController.gModel = self.gModel;
    self.moviePlayerController.adId = self.aID;
    self.moviePlayerController.videoPlayType = movieViewModel.videoPlayType;
    self.showDetailButtonWhenFinished = isEmptyString(movieViewModel.aID) ? YES : NO;
    movieViewModel.currentDefinitionType = [[self class] selectedDefinitionType];
}

- (void)setVideoModel:(ExploreMovieViewModel *)videoModel
{
    _videoModel = videoModel;
    [self updateTrackWithMovieViewModel:videoModel];
    
}

- (void)setLiveStatus:(NSNumber *)liveStatus {
    _liveStatus = liveStatus;
    self.tracker.liveStatus = liveStatus;
}

- (instancetype)initWithFrame:(CGRect)frame movieViewModel:(ExploreMovieViewModel *)movieViewModel
{
    return [self initWithFrame:frame type:ExploreMovieViewTypeList trackerDic:nil movieViewModel:movieViewModel];
}

- (void)setEnableMultiResolution:(BOOL)enableMultiResolution
{
    _enableMultiResolution = enableMultiResolution;
    if (self.enableMultiResolution) {
        _moviePlayerController.enableMultiResolution = YES;
    }
    else
    {
        _moviePlayerController.enableMultiResolution = NO;
    }
}

- (TTAudioWaveView *)audioWave
{
    if (!_audioWave) {
        _audioWave = [[TTAudioWaveView alloc] init];
        _audioWave.alpha = 0.9;
        [_audioWave finish];
    }
    return _audioWave;
}

- (void)setUserInteractionEnabled:(BOOL)userInteractionEnabled
{
    [super setUserInteractionEnabled:userInteractionEnabled];
    self.moviePlayerController.muted = !userInteractionEnabled;
    [self setupAudioSessionIsMuted:!userInteractionEnabled];
    if (self.audioWave.superview != self) {
        [self.audioWave removeFromSuperview];
        [self addSubview:self.audioWave];
        self.audioWave.right = self.width - 6;
        self.audioWave.bottom = self.height - 4;
        self.audioWave.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
    }
    if (userInteractionEnabled) {
        [self.audioWave finish];
    } else {
        [self.audioWave wave];
    }
}

- (BOOL)hasValidAfterParserAD {
    BOOL afterPasterIsValid = (self.pasterADEnableOptions & TTVideoEnableAfterPaster) && (self.letvVideoModel.afterVideoADList.count > 0);
    return afterPasterIsValid;
}

- (BOOL)isLiveVideo
{
    if (self.videoModel.videoPlayType == TTVideoPlayTypeLive /* || self.letvVideoModel.liveInfo */) {
        return YES;
    }
    
    return NO;
}

- (BOOL)isPlayingPasterADVideo
{
    if (self.pasterADController) {
        return YES;
    }
    return NO;
}

- (BOOL)isPasterADVideo
{
    if (self.videoModel.videoPlayType == TTVideoPlayTypePasterAD || self.letvVideoModel.adInfo) {
        return YES;
    }
    return NO;
}

- (void)setMovieViewDelegate:(id<ExploreMovieViewDelegate>)movieViewDelegate
{
    _movieViewDelegate = movieViewDelegate;
    if ([_movieViewDelegate respondsToSelector:@selector(orderedData)]) {
        self.movieDelegateData = [_movieViewDelegate performSelector:@selector(orderedData) withObject:nil];
    }else{
        self.movieDelegateData = nil;
    }

    if (self.movieDelegateData) {
        if (self.movieDelegateData.isFakePlayCount) {
            NSString *countStr = [TTBusinessManager formatPlayCount:self.movieDelegateData.article.readCount];
            [self.moviePlayerController.controlView setVideoPlayTimesText:[countStr stringByAppendingString:@"次阅读"]];
        }else{
            long count = [self.movieDelegateData.article.videoDetailInfo longValueForKey:VideoWatchCountKey defaultValue:0];
            NSString *countStr = [TTBusinessManager formatPlayCount:count];
            [self.moviePlayerController.controlView setVideoPlayTimesText:[countStr stringByAppendingString:@"次播放"]];
        }
        if ([self isAdMovie]) {
            if ([self.movieDelegateData isKindOfClass:[ExploreOrderedData class]]) {
                [self.moviePlayerController.controlView configureFinishAd:(ExploreOrderedData *)self.movieDelegateData];
            }
        }
    }
    [self checkUserInteraction];
    [self showDetailButtonIfNeeded];
}

- (void)checkUserInteraction
{
    if ([self isAdMovie] && _isPlaybackEnded) {
        self.userInteractionEnabled = YES;
    } else if ([self.movieViewDelegate respondsToSelector:@selector(shouldDisableUserInteraction)]) {
        self.userInteractionEnabled = ![self.movieViewDelegate shouldDisableUserInteraction];
    }
}

- (void)showDetailButtonIfNeeded
{
    if ([self.movieViewDelegate respondsToSelector:@selector(shouldShowDetailButton)]) {
        self.alwaysShowDetailButton = [self.movieViewDelegate shouldShowDetailButton];
    } else {
        self.alwaysShowDetailButton = NO;
    }
}

- (void)hiddenMiniSliderView:(BOOL)hidden
{
    [self.moviePlayerController.controlView setHiddenMiniSliderView:hidden];
}

- (void)showLoadingView:(ExploreMoviePlayerControlViewTipType)type
{
    [self.moviePlayerController.controlView showTipView:type];
}

- (void)hiddenLoadingView
{
    [self.moviePlayerController.controlView hideTipView];
}

- (void)setToolbarHidden:(BOOL)hidden autoHide:(BOOL)autoHide
{
    [self.moviePlayerController.controlView setToolBarHidden:hidden needAutoHide:autoHide];
}

- (void)pauseMovieAndShowToolbar
{
    if (_moviePlayerController.playbackState != TTMoviePlaybackStatePaused && _moviePlayerController.playbackState != TTMoviePlaybackStateStopped) {
        [self pauseMovie];
        [self.moviePlayerController.controlView setToolBarHidden:NO needAutoHide:NO];
    }
}

- (void)setAlwaysShowDetailButton:(BOOL)alwaysShowDetailButton
{
    if (_alwaysShowDetailButton != alwaysShowDetailButton) {
        _alwaysShowDetailButton = alwaysShowDetailButton;
        self.moviePlayerController.controlView.alwaysShowDetailButton = alwaysShowDetailButton;
    }
}

- (void)setAlwaysHideTitleBarView:(BOOL)alwaysHideTitleBarView
{
    if (_alwaysHideTitleBarView != alwaysHideTitleBarView) {
        _alwaysHideTitleBarView = alwaysHideTitleBarView;
        [self.moviePlayerController.controlView hideTitleBarView:alwaysHideTitleBarView];
    }
}

- (void)setAlwaysTouchScreenToExit:(BOOL)alwaysTouchScreenToExit
{
    if (_alwaysTouchScreenToExit != alwaysTouchScreenToExit) {
        _alwaysTouchScreenToExit = alwaysTouchScreenToExit;
        [self.moviePlayerController.controlView touchScreenToExit:alwaysTouchScreenToExit];
    }
}

- (void)setAlwaysHideFullscreenStatusBar:(BOOL)alwaysHideFullscreenStatusBar {
    [self.moviePlayerController.controlView hideFullscreenStatusBar:alwaysHideFullscreenStatusBar];
}

- (void)stopMovieWhenInBackgroundIfNeeded
{
    if ([self.movieViewDelegate respondsToSelector:@selector(shouldStopMovieWhenInBackground)] &&
        [self.movieViewDelegate shouldStopMovieWhenInBackground] && !([self isAdMovie] && _isPlaybackEnded)) {
        [self stopMovieAfterDelay];
    }
}

- (void)setupAudioSessionIsMuted:(BOOL)isMuted
{
    if (isMuted) {//静音的时候不打断其他app音乐的播放
        [[TTAudioSessionManager sharedInstance] setCategory:AVAudioSessionCategoryAmbient];
        [[TTAudioSessionManager sharedInstance] setActive:NO];
    }
    else
    {
        [[TTAudioSessionManager sharedInstance] setCategory:AVAudioSessionCategoryPlayback];
        [[TTAudioSessionManager sharedInstance] setActive:YES];
    }

}

- (void)willAppear {
    _viewIsAppear = YES;
    if ([self.movieViewDelegate respondsToSelector:@selector(shouldPlayWhenViewWillAppear)]) {
        if ([self.movieViewDelegate shouldPlayWhenViewWillAppear]) {
            [self resumeMovie];
        }
    }
}

- (void)didAppear {
    _viewIsAppear = YES;
}

- (void)willDisappear {
    _viewIsAppear = NO;
}

- (void)didDisappear {
    _viewIsAppear = NO;
}

- (NSString *)playVID
{
    return self.urlRequestInfo.videoID;
}

- (NSString *)playMainURL
{
    return _letvVideoModel.videoInfo.videoURLInfoMap.video1.mainURLStr;
}

- (BOOL)isMovieFullScreen
{
    return _moviePlayerController.isMovieFullScreen;
}

- (void)updateMovieInFatherViewFrame:(CGRect)frame
{
    self.movieInFatherViewFrame = frame;
    self.rotateViewRect = frame;
}

- (void)setVideoTitle:(nullable NSString *)title fontSizeStyle:(TTVideoTitleFontStyle)style showInNonFullscreenMode:(BOOL)bShow
{
    [_moviePlayerController.controlView setVideoTitle:title fontSizeStyle:style showInNonFullscreenMode:bShow];
}

- (void)setVideoDuration:(NSTimeInterval)duration
{
    [_moviePlayerController refreshTimeLabel:duration currentPlaybackTime:0];
}

- (void)showLogo
{
    if (_logoImageDict) {
        TTImageInfosModel * model = [[TTImageInfosModel alloc] initWithDictionary:_logoImageDict];
        TTImageView *logoView = self.moviePlayerController.controlView.logoView;
        [self.moviePlayerController.controlView hideTipView];
        [self.moviePlayerController.controlView showLogoView:self.showDetailButtonWhenFinished];
        logoView.backgroundColor = [UIColor tt_defaultColorForKey:kColorBackground5];
        [logoView setImageWithModelInTrafficSaveMode:model placeholderImage:nil];
    }
}

- (UIView *)coverImageViewWithModel:(TTImageInfosModel *)model
{
    if (!model) {
        return nil;
    }
    TTImageView *firstFrame = [[TTImageView alloc] initWithFrame:self.bounds]; //loading的时候显示封面图
    firstFrame.imageContentMode = TTImageViewContentModeScaleAspectFill;
    firstFrame.backgroundColor = [UIColor blackColor];
    [firstFrame setImageWithModelInTrafficSaveMode:model placeholderImage:nil];
    return firstFrame;
}

- (UIView *)coverImageViewWithUrl:(NSString *)url
{
    if (url.length <= 0) {
        return nil;
    }
    TTImageView *firstFrame = [[TTImageView alloc] initWithFrame:self.bounds]; //loading的时候显示封面图
    firstFrame.backgroundColor = [UIColor blackColor];
    [firstFrame setImageWithURLString:url];
    return firstFrame;
}

- (void)addCoverImageView:(UIView *)firstFrame
{
    UIView *aView = [self.moviePlayerController.controlView.logoView viewWithTag:kFirstFrameView];
    if (aView) {
        [aView removeFromSuperview];
    }
    
    BOOL controlViewHidden = self.moviePlayerController.controlView.hidden;
    self.moviePlayerController.controlView.hidden = NO;
    BOOL logoHidden = self.moviePlayerController.controlView.logoView.hidden;
    self.moviePlayerController.controlView.logoView.hidden = NO;
    
    [self.moviePlayerController.controlView.logoView addSubview:firstFrame];
    firstFrame.tag = kFirstFrameView;
    firstFrame.frame = self.bounds;
    
    WeakSelf;
    self.willPlayableBlock = ^{
        StrongSelf;
        self.moviePlayerController.controlView.logoView.hidden = YES;
        self.moviePlayerController.controlView.hidden = controlViewHidden;
        [firstFrame removeFromSuperview];
    };
    
    self.willFinishBlock = ^{
        StrongSelf;
        if (!self.showedOneFrame && !self.isStoppedAfterDelay && !self.isStoped) {
            return ;
        }
        self.moviePlayerController.controlView.logoView.hidden = logoHidden;
        self.moviePlayerController.controlView.hidden = controlViewHidden;
        [firstFrame removeFromSuperview];
    };
}


- (void)setLogoImageModel:(TTImageInfosModel *)model
{
    if (model) {
        UIView *firstFrame = [self coverImageViewWithModel:model];
        if (firstFrame) {
            [self addCoverImageView:firstFrame];
        }
    }
}

- (void)setLogoImageUrl:(NSString *)url
{
    UIView *firstFrame = [self coverImageViewWithUrl:url];
    if (firstFrame) {
        [self addCoverImageView:firstFrame];
    }
}

- (void)setLogoImageDict:(NSDictionary *)imageDict
{
    _logoImageDict = imageDict;
    if (_logoImageDict) {

        if (imageDict.count <= 0) {
            return;
        }
        TTImageInfosModel * model = [[TTImageInfosModel alloc] initWithDictionary:_logoImageDict];
        [self setLogoImageModel:model];
    }
}

- (void)playVideoWithVideoInfo:(nonnull NSDictionary *)videoInfo exploreVideoSP:(ExploreVideoSP)sp videoPlayType:(TTVideoPlayType)type
{
    if (!videoInfo) {
        return;
    }
    if (self.isPlaying) {
        [self stopMovie];
    }
    
    [self.moviePlayerController.trackManager userClickPlayButtonForID:[videoInfo valueForKey:@"video_id"] fetchURL:nil isClearALl:YES];
    TTVideoInfoModel *info = [[TTVideoInfoModel alloc] initWithDictionary:videoInfo error:nil];
    ExploreVideoModel *model = [[ExploreVideoModel alloc] init];
    model.videoInfo = info;
    [self playVideoForVideoID:[videoInfo valueForKey:@"video_id"] exploreVideoSP:sp videoPlayType:type videoModel:model isFeedUrl:YES];
    _playRequestTimestamp = [[NSDate date] timeIntervalSince1970];
}

- (void)playVideoForVideoID:(NSString *)videoID exploreVideoSP:(ExploreVideoSP)sp
{
    [self playVideoForVideoID:videoID exploreVideoSP:sp videoPlayType:TTVideoPlayTypeNormal];
}

- (void)playVideoForVideoID:(nullable NSString *)videoID exploreVideoSP:(ExploreVideoSP)sp videoPlayType:(TTVideoPlayType)type
{
    [self playVideoForVideoID:videoID exploreVideoSP:sp videoPlayType:type videoModel:nil isFeedUrl:NO];
}

- (void)playVideoForVideoURL:(NSString *)videoURL
{
    // 使用本地播放器播放第三方wap页内视频时不发track统计
    self.moviePlayerController.trackManager = nil;

    ExploreVideoModel *tvModel = [[ExploreVideoModel alloc] init];
    tvModel.videoInfo = [[TTVideoInfoModel alloc] init];
    tvModel.videoInfo.videoURLInfoMap = [[TTVideoURLInfoMap alloc] init];
    tvModel.videoInfo.videoURLInfoMap.video1 = [[TTVideoURLInfo alloc] init];
    tvModel.videoInfo.videoURLInfoMap.video1.mainURLStr = videoURL;
    
    [self playVideoForVideoID:nil exploreVideoSP:ExploreVideoSPUnknown videoPlayType:TTVideoPlayTypeNormal videoModel:tvModel isFeedUrl:NO];
    
}

- (void)playPasterADForVideoModel:(nullable ExploreVideoModel *)videoModel
{
    [self playVideoForVideoID:nil exploreVideoSP:ExploreVideoSPUnknown videoPlayType:TTVideoPlayTypePasterAD videoModel:videoModel isFeedUrl:NO];
}

- (void)playVideoForVideoID:(NSString *)videoID exploreVideoSP:(ExploreVideoSP)sp videoPlayType:(TTVideoPlayType)playType videoModel:(ExploreVideoModel *)videoModel isFeedUrl:(BOOL)isFeedUrl
{
    if (![self notNeedCacheBusiness]) {
        [[TTMovieViewCacheManager sharedInstance] setCacheBlock:self videoID:videoID];
        if (self.currentPlayingTime > 0) {
            [self p_cacheMovieViewProgress];
            [_moviePlayerController reuse];
        }
    }
    [[TTVideoDefinationTracker sharedTTVideoDefinationTracker] reset];
    _moviePlayerController.definitionType = [[self class] selectedDefinitionType];
    self.videoModel.currentDefinitionType = [[self class] selectedDefinitionType];

    self.videoDidPlayable = NO;
    [self clearStatus];
    _autoPause = NO;
    //每次播放视频时记录当前的视频id
    [TTMovieViewCacheManager sharedInstance].currentPlayingVideoID = videoID;
    [self.tracker sendPlayTrack];

    self.movieManager.isFeedUrl = isFeedUrl;
    if (self.isPlaying) {
        [self stopMovie];
    }

    TTVideoURLRequestInfo *info = [[TTVideoURLRequestInfo alloc] init];
    info.videoID = videoID;
    info.sp = sp;
    info.playType = playType;
    info.categoryID = self.cID;
    info.itemID = self.gModel.itemID;
    info.adID = self.aID;
    self.urlRequestInfo = info;
    
    if (TTNetworkWifiConnected() || kAlwaysCloseAlert || [self p_shouldShowTrafficView:NO]) {
        if (videoModel) {
            [self playVideoFromVideoModel:videoModel];
        } else {
            // 根据vid获取url播放
            [self _fetchVideoURLInfo];
        }
        
        [ExploreMovieView setCurrentVideoPlaying:YES];
    }
    else if (TTNetworkConnected()) {
        if ([self canShowAlert]) {
            hasShowAlertNumber++;
            [self.tracker sendNetAlertWithLabel:@"net_alert_show"];
            TTThemedAlertController *alert = [[TTThemedAlertController alloc] initWithTitle:NSLocalizedString(kAlertTitle, nil) message:nil preferredType:TTThemedAlertControllerTypeAlert];
            [alert addActionWithTitle:NSLocalizedString(kAlertStop, nil) actionType:TTThemedAlertActionTypeNormal actionBlock:^{
                hasShowAlertNumber--;
                [self.tracker sendNetAlertWithLabel:@"net_alert_cancel"];
                [[self class] removeAllExploreMovieView];
            }];
            [alert addActionWithTitle:NSLocalizedString(kAlertPlay, nil) actionType:TTThemedAlertActionTypeNormal actionBlock:^{
                kAlwaysCloseAlert = YES;
                kHasAlreadyShownAlert = YES;
                hasShowAlertNumber--;
                if (videoModel) {
                    [self playVideoFromVideoModel:videoModel];
                } else {
                    // 根据vid获取url播放
                    [self _fetchVideoURLInfo];
                }
                [self.tracker sendNetAlertWithLabel:@"net_alert_confirm"];
            }];
            [alert showFrom:[TTUIResponderHelper topmostViewController] animated:YES];
        }
        
        [ExploreMovieView setCurrentVideoPlaying:YES];
    }
    else {
        if ([self hasLocalUrl])
        {
            [self manager:nil errorDict:nil videoModel:nil];
            if (_noNetWorkIndicator)
            {
                [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:@"没有网络" indicatorImage:[UIImage themedImageNamed:@"close_popup_textpage"] autoDismiss:YES dismissHandler:nil];
            }
        }
        else
        {
            if (_noNetWorkIndicator) {
                [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:@"没有网络" indicatorImage:[UIImage themedImageNamed:@"close_popup_textpage"] autoDismiss:YES dismissHandler:nil];
            }
            [self showRetryTipView];
        }
        
        [ExploreMovieView setCurrentVideoPlaying:NO];
    }
}

- (void)playVideoFromURL:(NSString *)videoURL
{
    ExploreVideoModel *tvModel = [[ExploreVideoModel alloc] init];
    tvModel.videoInfo = [[TTVideoInfoModel alloc] init];
    tvModel.videoInfo.videoURLInfoMap = [[TTVideoURLInfoMap alloc] init];
    tvModel.videoInfo.videoURLInfoMap.video1 = [[TTVideoURLInfo alloc] init];
    tvModel.videoInfo.videoURLInfoMap.video1.mainURLStr = videoURL;

    [self manager:_movieManager errorDict:nil videoModel:tvModel];
    
    
    [ExploreMovieView setCurrentVideoPlaying:YES];
}

- (void)playVideoFromVideoModel:(ExploreVideoModel *)videoModel
{
    _autoPause = NO;
    [self manager:_movieManager errorDict:nil videoModel:videoModel];
    
    [ExploreMovieView setCurrentVideoPlaying:YES];
}

- (void)_fetchVideoURLInfo
{
    _playURLIndex = 0;
    _hasSendTrackLog = NO;
    [_movieManager fetchURLInfoWithRequestInfo:self.urlRequestInfo];
    [self.moviePlayerController.trackManager userClickPlayButtonForID:self.urlRequestInfo.videoID fetchURL:_movieManager.videoRequestUrl isClearALl:YES];
    _playRequestTimestamp = [[NSDate date] timeIntervalSince1970];
}

- (void)playPasterADs:(NSArray *)pasters completionBlock:(void(^)(void))block
{
    if (self.pasterADController) {
        
        self.pasterADController.delegate = self;
//        self.pasterADController.view.frame = self.frame;
        [self addSubview:self.pasterADController.view];
    } else {
        
        return ;
    }

    if ([self isMovieFullScreen]) {
//        ExploreMovieView *v = [self.pasterADController performSelector:@selector(movieView)];
//        [v enterFullscreen:NO completion:nil];
        [self.pasterADController setIsFullScreen:[self isMovieFullScreen]];
    }
    self.pasterADController.view.frame = self.bounds;

//    self.pasterADController.view.hidden = NO;
    _playPasterADSuccess = YES;
    __weak typeof(self) wself = self;
    [self.pasterADController startPlayVideoList:pasters WithCompletionBlock:^{
        __strong typeof(wself) self = wself;
        [self.pasterADController.view removeFromSuperview];
        self.pasterADController = nil;
        if (block) {
            block();
        }
    }];
}

- (void)showRetryTipView
{
    [self showRetryTipViewWithTipString:nil];
}

- (void)showRetryTipViewWithTipString:(NSString *)tipString
{
    if ([self.pasterADDelegate respondsToSelector:@selector(pasterADNeedsRetry)]) {
        [self.pasterADDelegate pasterADNeedsRetry];
    }
    [self.moviePlayerController showRetryTipViewWithTipString:tipString];
}


- (void)layoutSubviews
{
    [super layoutSubviews];
    if (_forbidLayout) {
        return;
    }
    [self updateFrame];
}

- (void)updateFrame {
    _moviePlayerController.view.frame = self.bounds;
    CGRect targetFrame = self.bounds;
    CGFloat paddingToAvoidConflictHomeIndicatorInteract = 0;
    if ([TTDeviceHelper isIPhoneXDevice] && [self.moviePlayerController isMovieFullScreen]) {
        if (_enableRotate) {
            targetFrame = UIEdgeInsetsInsetRect(targetFrame, UIEdgeInsetsMake(0, 44, 21 + paddingToAvoidConflictHomeIndicatorInteract, 44));
        } else {
            targetFrame = UIEdgeInsetsInsetRect(targetFrame, UIEdgeInsetsMake(20, 0, 21 + paddingToAvoidConflictHomeIndicatorInteract, 0));
        }
    }
    _moviePlayerController.controlView.frame = targetFrame;
    _moviePlayerController.controlView.dimAreaEdgeInsetsWhenFullScreen = UIEdgeInsetsMake(-targetFrame.origin.y, -targetFrame.origin.x, - self.bounds.size.height + targetFrame.origin.y + targetFrame.size.height, - self.bounds.size.width + targetFrame.origin.x + targetFrame.size.width);
    
    self.pasterADController.view.frame = self.bounds;
    _trafficView.frame = self.bounds;
    [_moviePlayerController.controlView updateFrame];
    [self.moviePlayerController.controlView.tipView updateFrame];
    UIView *aView = [self.moviePlayerController.controlView.logoView viewWithTag:kFirstFrameView];
    if (aView) {
        aView.frame = self.bounds;
    }
}

- (NSArray *)allPlayURLs
{
    BOOL isSDType = self.videoModel.currentDefinitionType == ExploreVideoDefinitionTypeSD;
    ExploreVideoDefinitionType currentType = self.videoModel.currentDefinitionType;
    
    NSArray *urls = [self.letvVideoModel allURLWithDefinitionType:currentType];
    ExploreVideoDefinitionType nextType = currentType;
    //如果没有对应清晰度的url，则按照超清->高清->标清的优先级获取
    while (urls.count == 0 && !isSDType) {
        if (nextType == ExploreVideoDefinitionTypeFullHD) {
            nextType = ExploreVideoDefinitionTypeHD;
        } else if (nextType == ExploreVideoDefinitionTypeHD) {
            nextType = ExploreVideoDefinitionTypeSD;
            isSDType = YES;
        }else if (nextType == ExploreVideoDefinitionTypeUnknown) {
            nextType = ExploreVideoDefinitionTypeFullHD;
        }
        urls = [self.letvVideoModel allURLWithDefinitionType:nextType];
    }
    self.moviePlayerController.definitionType = nextType;
    self.videoModel.currentDefinitionType = nextType;
    [TTVideoDefinationTracker sharedTTVideoDefinationTracker].actual_clarity = nextType;
    return urls;
}

- (BOOL)hasLocalUrl
{
    return !_hasPlayLocalFailed && !isEmptyString([self.movieDelegateData ttv_videoLocalURL]);
}

- (NSString *)getPlayURL
{
    if ([self hasLocalUrl]) {
        NSString *absoluteURLStr = [NSString stringWithFormat:@"file://%@%@", NSHomeDirectory(), [self.movieDelegateData ttv_videoLocalURL]];
        return absoluteURLStr;
    }
    NSArray *urlArray = [self allPlayURLs];
    if (_playURLIndex < urlArray.count) {
        
        // 根据重试策略判断是否返回URL
        switch ([ExploreMovieManager videoPlayRetryPolicy]) {
            case TTVideoPlayRetryPolicyNone:
                if (_playURLIndex > 0) {
                    return nil;
                }
                break;
                
            case TTVideoPlayRetryPolicyRetryOne:
                if (_playURLIndex > 1) {
                    return nil;
                }
                break;
                
            case TTVideoPlayRetryPolicyRetryAll:
                break;
                
            default:
                break;
        }
        
        return [urlArray objectAtIndex:_playURLIndex];
    }
    return nil;
}

- (void)playVideoWithUrl:(NSURL *)playURL
{
    //视频质量监控日志相关
    [self.moviePlayerController.trackManager setMovieDuration:[self.movieDelegateData ttv_videoDuration]];
    if (self.videoModel.lastDefinitionType != ExploreVideoDefinitionTypeUnknown) {
        [self.moviePlayerController.trackManager setMovieLastDefinition:[self.letvVideoModel.videoInfo definitionStrForType:self.videoModel.lastDefinitionType]];
    }
    [self.moviePlayerController.trackManager setMovieDefinition:[self.letvVideoModel.videoInfo definitionStrForType:self.videoModel.currentDefinitionType]];
    [self.moviePlayerController.trackManager setMovieSize:[self.letvVideoModel.videoInfo videoSizeForType:self.videoModel.currentDefinitionType]];
    if ([self isAdMovie]) {
        [self.moviePlayerController.trackManager setVideoType:SSVideoTypeAdVideo];
    } else {
        if (self.videoModel.videoPlayType == TTVideoPlayTypeLive) {
            [self.moviePlayerController.trackManager setVideoType:SSVideoTypeLiveVideo];
        } else if (self.videoModel.videoPlayType == TTVideoPlayTypeLivePlayback) {
            [self.moviePlayerController.trackManager setVideoType:SSVideoTypeLiveReplay];
        } else {
            [self.moviePlayerController.trackManager setVideoType:SSVideoTypeVideo];
        }
    }

    @try {
        [_moviePlayerController moviePlayContentForURL:playURL];
    }
    @catch (NSException *exception) {
        LOGD(@"moviePlayContentForURL: %@", exception);
        wrapperTrackEvent(@"video", @"play_url_exception");
    }

    if (playURL == nil) {
        LOGD(@"showRetryTipView");
        [self showRetryTipView];
        [_moviePlayerController movieStop];
    }
    else
    {
        @try {
            [self userPlay];
        }
        @catch (NSException *exception) {
            LOGD(@"playMovie: %@", exception);
            wrapperTrackEvent(@"video", @"play_movie_exception");
        }
    }
}

- (void)_playContent
{
    if (_resignActive) {
        return;
    }
    _isPrepared = NO;
    NS_VALID_UNTIL_END_OF_SCOPE ExploreMovieView *strongSelf = self;
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(checkLoadingTimeout) object:nil];

    NSString *url = [self getPlayURL];
    NSURL *playURL = [TTStringHelper URLWithURLString:url];
    BOOL playUseIp = [[[TTSettingsManager sharedManager] settingForKey:@"tt_play_use_ip" defaultValue:@NO freeze:NO] boolValue];
    self.hostName = nil;
    BOOL isHTTPS = [[url lowercaseString] rangeOfString:@"https"].location != NSNotFound;
    if ([self hasLocalUrl] || [[url lowercaseString] rangeOfString:@"file://"].location != NSNotFound || self.videoModel.videoPlayType == TTVideoPlayTypeLive || !playUseIp || !self.moviePlayerController.isOwnPlayer || isHTTPS) {
        [self playUrlWithoutipAddress:playURL];
    }
    else
    {
        self.hostName = playURL.host;
        if (playURL && !isEmptyString(self.hostName)) {
            NSString *ipAddress = [[TTHTTPDNSManager shareInstance] resolveHost:playURL];
            if (isEmptyString(ipAddress)) {
                [self playUrlWithoutipAddress:playURL];
            }else{
                [self playUrl:playURL ipAddress:ipAddress];
            }
        }
    }

}

- (void)playUrlWithoutipAddress:(NSURL *)playURL
{
    [self trackManagerExecuteWithOriginUrl:playURL];
    [self playVideoWithUrl:playURL];
}

- (void)playUrl:(NSURL *)playURL ipAddress:(NSString *)ipAddress
{
    NSString *ipUrl = [playURL absoluteString];
    if (!isEmptyString(playURL.host) && !isEmptyString(ipAddress)) {
        ipUrl = [ipUrl stringByReplacingOccurrencesOfString:playURL.host withString:ipAddress];
    }
    [self trackManagerExecuteWithOriginUrl:playURL];
    [self playVideoWithUrl:[NSURL URLWithString:ipUrl]];
}

- (void)trackManagerExecuteWithOriginUrl:(NSURL *)playURL
{
    if (playURL) {
        LOGD(@"checkLoadingTimeout");
        [self performSelector:@selector(checkLoadingTimeout) withObject:nil afterDelay:[ExploreMovieManager videoPlayRetryInterval] inModes:@[NSRunLoopCommonModes]];
        [self.moviePlayerController.trackManager setMovieOriginVideoURL:playURL.absoluteString];
    }
}

- (UIWindow *)mainWindow
{
    UIWindow *window = nil;
    if (!window) {
        window = [UIApplication sharedApplication].keyWindow;
    }
    if (!window && [[UIApplication sharedApplication].delegate respondsToSelector:@selector(window)]) {
        window = [UIApplication sharedApplication].delegate.window;
    }
    return window;
}

- (UIInterfaceOrientation)fullscreenOrientation
{
    UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
    if (orientation == UIDeviceOrientationLandscapeLeft) {
        return UIInterfaceOrientationLandscapeRight;
    }
    else if (orientation == UIDeviceOrientationLandscapeRight) {
        return UIInterfaceOrientationLandscapeLeft;
    }
    else {
        return UIInterfaceOrientationLandscapeRight;
    }
}

- (UITableView *)tableViewWithCell:(id)cell
{
    if ([cell isKindOfClass:[ExploreCellBase class]]) {
        return ((ExploreCellBase *)cell).tableView;
    }
    if ([cell isKindOfClass:[TTVFeedListCell class]]) {
        return ((TTVFeedListCell *)cell).tableView;
    }
    return nil;
}

- (id)containerMovieViewCell {

    UIView *superView = self.superview;

    while (superView) {
        if (([superView isKindOfClass:[ExploreCellBase class]] && [superView conformsToProtocol:@protocol(ExploreMovieViewCellProtocol)]) ||
            ([superView isKindOfClass:[TTVFeedListCell class]] && [superView conformsToProtocol:@protocol(TTVFeedPlayMovie)]))
            return superView;
        superView = superView.superview;
    }
    return nil;

}

- (void)ttv_newRotateTip
{
    if ([SSCommonLogic isRotateTipEnabled]) {
        TTIndicatorView *toast = [[TTIndicatorView alloc] initWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:@"新转屏" indicatorImage:nil dismissHandler:^(BOOL isUserDismiss) {

        }];
        [toast showFromParentView:self];
        [SSCommonLogic setVideoNewRotateTipEnabled:NO];
    }
}

- (BOOL)enterFullscreen:(BOOL)animation completion:(void (^)(BOOL finished))completion
{
    void (^finishedBlock)(BOOL) = ^(BOOL finished) {
        [ExploreMovieView setFullScreen:YES];
        [ExploreMovieView setCurrentFullScreenMovieView:self];
        completion ? completion(finished) : nil;
    };
    if (_forbidLayout || _isChangingMovieSize) {
        return NO;
    }
    if ([UIApplication sharedApplication].applicationState == UIApplicationStateBackground) {
        return NO;
    }
    
    //如果正在显示流量提示页面不能转屏
    if ([self p_isShowingTrafficView]) {
        return NO;
    }
    if (_forbidFullScreenWhenPresentAd && _moviePlayerController.playbackState != TTMoviePlaybackStatePlaying) {
        return NO;
    }
    if (_isRotateAnimating || _moviePlayerController.isMovieFullScreen) {
        return NO;
    }
    _isRotateAnimating = YES;
    UIView *enterSuperView = self.superview;
    enterSuperView.userInteractionEnabled = NO;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        enterSuperView.userInteractionEnabled = YES;
    });

    if (ttvs_isVideoNewRotateEnabled()) {
        _isNewRotate = YES;
        [self ttv_newRotateTip];
        return [self newEnterFullscreen:animation completion:finishedBlock];
    }
    _isNewRotate = NO;
    
    dispatch_block_t dismissBlock = ^ {
        id  containerMovieViewCell = [self containerMovieViewCell];
        if (containerMovieViewCell) {
            self.hasMovieFatherCell = YES;
            NSIndexPath *indexPath = [[self tableViewWithCell:containerMovieViewCell] indexPathForCell:containerMovieViewCell];
            self.movieFatherCellIndexPath = indexPath;
            self.movieFatherCellTableView = [self tableViewWithCell:containerMovieViewCell];
        }
        else {
            self.hasMovieFatherCell = NO;
            self.movieInFatherViewFrame = self.frame;
            self.movieFatherView = [self superview];
        }
        
        [self.moviePlayerController enterFullscreen];
        
        [self.moviePlayerController.controlView setToolBarHidden:[self.moviePlayerController.controlView toolBarViewHidden]];
      //  presentingView 需要是rootVC避免旋转布局错乱
        UIViewController *topMost = [TTUIResponderHelper topNavigationControllerFor:self];
        UIInterfaceOrientation orientationBeforePresented = topMost.interfaceOrientation;
        UIInterfaceOrientation orientationAfterPresented = topMost.interfaceOrientation;
        UIInterfaceOrientationMask supportedOriendtation = UIInterfaceOrientationMaskAll;
        if (![TTDeviceHelper isPadDevice]) {
            if (_enableRotate) {
                supportedOriendtation = UIInterfaceOrientationMaskLandscape;
                orientationAfterPresented = [self fullscreenOrientation];
            }
            else {
                supportedOriendtation = UIInterfaceOrientationMaskPortrait;
            }
        }
        
        TTMovieFullscreenViewController *fullscreenViewController = [[TTMovieFullscreenViewController alloc] initWithOrientationBeforePresented:orientationBeforePresented orientationAfterPresented:orientationAfterPresented supportedOrientations:supportedOriendtation];
        fullscreenViewController.transitioningDelegate = self;
        fullscreenViewController.delegate = self;
        if ([TTDeviceHelper OSVersionNumber] < 8.0) {
            fullscreenViewController.modalPresentationStyle = UIModalPresentationCustom;
        }
        else {
            fullscreenViewController.modalPresentationStyle = UIModalPresentationOverFullScreen;
        }
        fullscreenViewController.animatedDuringTransition = animation;
        [topMost presentViewController:fullscreenViewController animated:YES completion:^{

            if (finishedBlock) {
                finishedBlock(YES);
            }
            if ([self.movieViewDelegate respondsToSelector:@selector(movieDidEnterFullScreen)]) {
                [self.movieViewDelegate movieDidEnterFullScreen];
            }
            _isRotateAnimating = NO;
            if (_shouldExitFullScreenLater) {
                //iOS8上，在presentViewController的completionBlock中dismiss，会crash
                //http://stackoverflow.com/questions/25762466/trying-to-dismiss-the-presentation-controller-while-transitioning-already
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    _shouldExitFullScreenLater = NO;
                    [self exitFullScreen:YES completion:nil];
                });
            }
        }];
        self.fullscreenViewController = fullscreenViewController;
        
        if (animation) {
            if (![TTDeviceHelper isPadDevice]) {
                [UIView animateWithDuration:kFullScreenChangeAnimationTime delay:0 options:UIViewAnimationOptionLayoutSubviews animations:^{
                    [self.moviePlayerController.controlView refreshSliderFrame];
                } completion:nil];
            }
        }
        else {
            if (![TTDeviceHelper isPadDevice]) {
                [self.moviePlayerController.controlView refreshSliderFrame];
            }
        }
        
        [self.tracker sendEnterFullScreenTrack];
    };
    
    if ([TTDeviceHelper OSVersionNumber] < 8.0) {
        UIViewController *vc = [UIViewController ttmu_currentViewController];
        if ([vc isKindOfClass:[SKStoreProductViewController class]]) {
            [vc dismissViewControllerAnimated:YES completion:^{
                [[NSNotificationCenter defaultCenter] postNotificationName:@"StoreVCDismissFromVideoDetailViewController" object:nil];
                dismissBlock();
            }];
        } else {
            dismissBlock();
        }
    } else {
        dismissBlock();
    }
    
    return YES;
}

- (BOOL)newEnterFullscreen:(BOOL)animation completion:(void (^)(BOOL finished))completion {
    dispatch_block_t block = ^ {
        id  cell = [self containerMovieViewCell];
        if (cell) {
            NSIndexPath *indexPath = [[self tableViewWithCell:cell] indexPathForCell:cell];
            self.indexPath = indexPath;
            self.baseTableView = [self tableViewWithCell:cell];
        }
        self.rotateSuperView = self.superview;
        self.rotateViewRect = self.frame;
        [self.moviePlayerController enterFullscreen];
        [self.moviePlayerController.controlView setToolBarHidden:[self.moviePlayerController.controlView toolBarViewHidden]];
        if (![TTDeviceHelper isPadDevice]) {
            self.rotateController.enableRotate = _enableRotate;
        }
        [self.rotateController enterFullScreen:animation completion:^{
            completion ? completion(YES) : nil;
            _isRotateAnimating = NO;
            if (_shouldExitFullScreenLater) {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    _shouldExitFullScreenLater = NO;
                    [self exitFullScreen:YES completion:completion];
                });
            }
        }];
        [self.tracker sendEnterFullScreenTrack];
    };
    if ([TTDeviceHelper OSVersionNumber] < 8.0) {
        UIViewController *vc = [UIViewController ttmu_currentViewController];
        if ([vc isKindOfClass:[SKStoreProductViewController class]]) {
            [vc dismissViewControllerAnimated:YES completion:^{
                [[NSNotificationCenter defaultCenter] postNotificationName:@"StoreVCDismissFromVideoDetailViewController" object:nil];
                block();
            }];
        } else {
            block();
        }
    } else {
        block();
    }
    return YES;
}

- (NSString *)ttv_playerUniqueId
{
    if ([self playVID]) {
        return [self playVID];
    }
    if ([self playMainURL]) {
        return [self playMainURL];
    }
    return @"";
}

- (BOOL)exitFullScreenIfNeed:(BOOL)animation
{
    if (!_moviePlayerController.isMovieFullScreen) {
        return NO;
    }
    return [self exitFullScreen:animation completion:nil];
}

- (BOOL)exitFullScreen:(BOOL)animation completion:(void (^)(BOOL finished))completion
{
    void (^finishedBlock)(BOOL) = ^(BOOL finished) {
        [ExploreMovieView setFullScreen:NO];
        [ExploreMovieView setCurrentFullScreenMovieView:self];
        completion ? completion(finished) : nil;
    };
    if ([UIApplication sharedApplication].applicationState == UIApplicationStateBackground) {
        return NO;
    }
    
    if (_isRotateAnimating || !_moviePlayerController.isMovieFullScreen) {
        return NO;
    }
    _isRotateAnimating = YES;


    [self.moviePlayerController exitFullscreen];

    BOOL isPad = [TTDeviceHelper isPadDevice];
    
    if (isPad && _movieViewDelegate && [_movieViewDelegate respondsToSelector:@selector(movieViewFrameAfterExitFullscreen)]) {
        self.movieInFatherViewFrame = [_movieViewDelegate movieViewFrameAfterExitFullscreen];
        self.rotateViewRect =[_movieViewDelegate movieViewFrameAfterExitFullscreen];
    }
    
    if (_isNewRotate) {
        return [self newExitFullScreen:animation completion:finishedBlock];
    }

    self.fullscreenViewController.animatedDuringTransition = animation;
    [self.fullscreenViewController dismissViewControllerAnimated:YES completion:^{
        
        self.hasMovieFatherCell = NO;
        self.movieFatherCellTableView = nil;
        self.movieFatherCellIndexPath = nil;
        self.movieFatherView = nil;
        self.movieInFatherViewFrame = CGRectZero;
        if (finishedBlock) {
            finishedBlock(YES);
        }
        if ([self.movieViewDelegate respondsToSelector:@selector(movieDidExitFullScreen)]) {
            [self.movieViewDelegate movieDidExitFullScreen];
        }

        _isRotateAnimating = NO;
        if (_videoFinishBlock) {
            _videoFinishBlock();
        }
        
        if (_didExitFullScreenHandler) {
            _didExitFullScreenHandler(self);
        }
        
        if (_alwaysTouchScreenToExit) {
            [self pauseMovie];
        }
    }];
    
    if (animation) {
        if (![TTDeviceHelper isPadDevice]) {
            [UIView animateWithDuration:kFullScreenChangeAnimationTime delay:0 options:UIViewAnimationOptionLayoutSubviews animations:^{
                [self.moviePlayerController.controlView refreshSliderFrame];
            } completion:nil];
        }
    }
    else {
        if (![TTDeviceHelper isPadDevice]) {
            [self.moviePlayerController.controlView refreshSliderFrame];
        }
    }
    
    return YES;
}

- (BOOL)newExitFullScreen:(BOOL)animation completion:(void (^)(BOOL finished))completion {
    [self.rotateController exitFullScreen:animation completion:^{
        
        self.baseTableView = nil;
        self.indexPath = nil;
        self.rotateViewRect = CGRectZero;
        if (completion) {
            completion(YES);
        }
        _isRotateAnimating = NO;
        if (_videoFinishBlock) {
            _videoFinishBlock();
        }
        if (_didExitFullScreenHandler) {
            _didExitFullScreenHandler(self);
        }
        if (_alwaysTouchScreenToExit) {
            [self pauseMovie];
        }
    }];
    if (animation) {
        if (![TTDeviceHelper isPadDevice]) {
            [UIView animateWithDuration:kFullScreenChangeAnimationTime delay:0 options:UIViewAnimationOptionLayoutSubviews animations:^{
                [self.moviePlayerController.controlView refreshSliderFrame];
            } completion:nil];
        }
    }
    else {
        if (![TTDeviceHelper isPadDevice]) {
            [self.moviePlayerController.controlView refreshSliderFrame];
        }
    }
    return YES;
}

- (void)markAsDetail
{
    _isNormalDetailMovieView = YES;
    TTMovieNetTrafficViewModel *viewModel = [[TTMovieNetTrafficViewModel alloc] init];
    viewModel.videoSize = self.trafficView.viewModel.videoSize;
    viewModel.videoDuration = self.trafficView.viewModel.videoDuration;
    viewModel.isInDetail = YES;
    self.trafficView.viewModel = viewModel;
    self.tracker.type = ExploreMovieViewTypeDetail;
    if (self.tracker.isAutoPlaying && !_isPlaybackEnded && self.isAdMovie) {
        [self.tracker sendPlayTrackInDetailByAutoPlay];
    }
    
    [self.moviePlayerController.controlView setIsDetail:YES];
    
    self.pasterADController.enterDetailFlag = YES;
}

- (void)unMarkAsDetail {
    [self.moviePlayerController.controlView setIsDetail:NO];
}

- (void)enableRotate:(BOOL)bEnable
{
    _enableRotate = bEnable;
    self.tracker.enableRotate = bEnable;
}
- (void)enableNetWorkIndicator:(BOOL)bEnable
{
    _noNetWorkIndicator = bEnable;
}

- (BOOL)isTopMostView
{
    NSArray *windows = [UIApplication sharedApplication].windows;
    for (UIWindow *w in windows) {
        // 分享
        Class cls = NSClassFromString(@"TTPanelControllerWindow");
        Class clsNew = NSClassFromString(@"TTNewPanelControllerWindow");
        if ((cls && [w isKindOfClass:cls] && ([w isKeyWindow] || !w.isHidden)) || (clsNew && [w isKindOfClass:clsNew] && ([w isKeyWindow] || !w.isHidden))) {
            return NO;
        }
    }

    if ([[UIApplication sharedApplication].keyWindow isKindOfClass:[TTVVideoRotateScreenWindow class]]) {
        return YES;
    }
    UIWindow *keyWindow = [self mainWindow];
    
    CGPoint pt = [self.superview convertPoint:self.center toView:keyWindow];
    UIView *topView = [keyWindow hitTest:pt withEvent:nil];
    
    while (topView) {
        if (topView.superview == self) {
            return YES;
        }
        topView = topView.superview;
    }
    
    return NO;
}

- (void)didReusePlayer
{
    [self.moviePlayerController didReusePlayer];
}

- (void)willReusePlayer
{
    [self.moviePlayerController willReusePlayer];
}

- (BOOL)isPlaying
{
    return _isPlaying || self.pasterADController.isPlayingMovie;
}

- (BOOL)isPaused
{
    return (!_isPlaying && _moviePlayerController.playbackState == TTMoviePlaybackStatePaused) || ([self isPlayingPasterADVideo] && [self.pasterADController isPaused]);
}

- (BOOL)isPlayingFinished
{
    return _isPlaybackEnded;
}

- (BOOL)isPlayingError
{
    return _hasError;
}

- (NSString *)videoID
{
    return self.playVID;
}

- (NSTimeInterval)currentPlayingTime
{
    return self.moviePlayerController.currentPlaybackTime;
}

- (NSTimeInterval)duration
{
    return self.moviePlayerController.duration;
}

- (BOOL)isAdMovie {
    return self.videoModel.aID.length > 0;
}

- (BOOL)notNeedCacheBusiness
{
    //不需要缓存播放进度的业务：1.自动播放且不在详情页的视频；2.直播视频或者贴片广告
    BOOL notNeedCacheBusiness = ([self.movieDelegateData ttv_couldAutoPlay] && !self.tracker.wasInDetail) || self.videoModel.videoPlayType != TTVideoPlayTypeNormal;
    return notNeedCacheBusiness;
}

//旋转180度时并且同时播放结束,会出现view remove 后,看见下面布局混乱的界面
- (void)removeFromSuperview
{
    if (self.isRotateAnimating && self.isMovieFullScreen && _isPlaybackEnded) {
        return;
    }
    [super removeFromSuperview];
}

- (void)p_cacheMovieViewProgress {

    if (_showedOneFrame && ![self notNeedCacheBusiness] && self.currentPlayingTime < self.duration) {
        [[TTMovieViewCacheManager sharedInstance] cacheMovieView:self forVideoID:self.videoID];
    }
}

- (void)p_showTrafficToastIfNeed {
    if (!kAlwaysCloseAlert) {
        return;
    }
    if (TTNetworkWifiConnected() || !TTNetworkConnected()) {
        return;
    }
    if (self.videoModel.videoPlayType == TTVideoPlayTypeLive || self.videoModel.videoPlayType == TTVideoPlayTypeLivePlayback) {
        return;
    }
    if (_hasShowTrafficToast) {
        return;
    }
    // 不弹流量浮层的情况下 免流切高清逻辑
    if ([TTVPlayerFreeFlowTipStatusManager shouldSwithToHDForFreeFlow]) {
        
        [self p_convertVideoToSDAndPlayWithSelectedDefinitionType:ExploreVideoDefinitionTypeHD];
        return;
    }
    
    _hasShowTrafficToast = YES;
    CGFloat size = [self.letvVideoModel.videoInfo videoSizeForType:self.videoModel.currentDefinitionType] / 1024.f / 1024.f;
    TTIndicatorView *trafficToast = [[TTIndicatorView alloc] initWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:[NSString stringWithFormat:@"%@%.2fM", @"正在使用流量播放，本视频约", size] indicatorImage:nil dismissHandler:^(BOOL isUserDismiss) {
    }];
    SEL selector = NSSelectorFromString(@"indicatorTextLabel");
    if ([trafficToast respondsToSelector:selector]) {
        IMP imp = [trafficToast methodForSelector:selector];
        UILabel* (*func)(id, SEL) = (void *)imp;
        UILabel *toastLabel = func(trafficToast, selector);
        toastLabel.font = [UIFont systemFontOfSize:14.f];
    }
    [trafficToast showFromParentView:[UIViewController ttmu_currentViewController].view];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [trafficToast dismissFromParentView];
    });
}

#pragma mark -- ExploreMoviePlayerControllerDelegate

- (BOOL)shouldResumePlayWhenInterruptionEnd
{
    if ([self.movieViewDelegate respondsToSelector:@selector(shouldResumePlayWhenActive)]) {
        return [self.movieViewDelegate shouldResumePlayWhenActive];
    }
    return YES;
}


- (void)controlViewTouched:(ExploreMoviePlayerControlView *)controlView
{
    [self.tracker sendControlViewClickTrack];
    if ([self.movieViewDelegate respondsToSelector:@selector(controlViewTouched:)]) {
        [self.movieViewDelegate controlViewTouched:controlView];
    }
}

- (void)controlView:(ExploreMoviePlayerControlView *)controlView didAppear:(BOOL)appear
{

}

- (void)controlView:(ExploreMoviePlayerControlView *)controlView willAppear:(BOOL)appear
{

}

- (void)movieController:(ExploreMoviePlayerController *)movieController seekToTime:(NSTimeInterval)afterTime fromTime:(NSTimeInterval)beforeTime
{
    if (_isPlaybackEnded && afterTime < self.duration) {
        _isPlaybackEnded = NO;
        _isPlaying = YES;
        self.tracker.isPlaybackEnded = _isPlaybackEnded;
    }
    
    if (movieController == _moviePlayerController && !_isSwitchMultiResolution) {
        [self.tracker sendMoveProgressBarTrackFromTime:beforeTime toTime:afterTime];
    }
    if ([self.movieViewDelegate respondsToSelector:@selector(movieSeekTime:)]) {
        [self.movieViewDelegate movieSeekTime:afterTime];
    }
}

- (void)movieControllerRemainderTime:(NSTimeInterval)remainderTime
{
    if ([self.movieViewDelegate respondsToSelector:@selector(movieRemainderTime:)]) {
        [self.movieViewDelegate movieRemainderTime:remainderTime];
    }
    
    CGFloat requestPercent = [[[TTSettingsManager sharedManager] settingForKey:@"video_ad_request_percent" defaultValue:@0 freeze:YES] floatValue];
    requestPercent = (requestPercent > 0 && requestPercent < 1) ? requestPercent: 0.8;
    
    if (!_disablePlayPasterAD &&
        (TTNetworkGetFlags() & TTNetworkFlagWifi) &&
        remainderTime > 0 &&
        self.moviePlayerController.duration > 0 &&
        remainderTime / self.moviePlayerController.duration <= 1 - requestPercent) {
        
        if (!(self.videoModel.aID.integerValue > 0) &&
            (self.videoModel.videoPlayType == TTVideoPlayTypeDefault || self.videoModel.videoPlayType == TTVideoPlayTypeNormal) &&
            !self.pasterADController &&
            (ExploreMovieViewTypeList == [self currentViewType] || ExploreMovieViewTypeDetail == [self currentViewType])) {
            
            self.pasterADController = [[TTVideoPasterADViewController alloc] init];
            self.pasterADController.delegate = self;

            TTVideoPasterADURLRequestInfo *requestInfo = [[TTVideoPasterADURLRequestInfo alloc] init];
            requestInfo.itemID = self.gModel.itemID;
            requestInfo.category = self.cID;
            requestInfo.groupID = self.gModel.groupID;
//            requestInfo.concernID = self.videoModel.concernID;// 该字段无效
            
            [self.pasterADController setupPasterADData:requestInfo];
        }
    }
}

- (void)movieControlViewRetryButtonClicked:(ExploreMoviePlayerController *)movieController
{
    _autoPause = NO;
    if (movieController == _moviePlayerController) {
        [self _fetchVideoURLInfo];
        [self setLogoImageDict:self.logoImageDict];
        if ([self.movieViewDelegate respondsToSelector:@selector(retryButtonClicked)]) {
            [self.movieViewDelegate retryButtonClicked];
        }
    }
}

- (void)movieControllerPrePlayButtonClicked:(ExploreMoviePlayerController *)movieController {
    
    [self.tracker sendPrePlayBtnClickTrack];
    
    if ([_movieViewDelegate respondsToSelector:@selector(prePlayButtonClicked)]) {
        
        [_movieViewDelegate prePlayButtonClicked];
    }
}

- (BOOL)movieControllerCanRotate:(ExploreMoviePlayerController *)movieController {
    return !_isRotateAnimating && !_isStoppedAfterDelay && !_isPlaybackEnded && _enableRotate && [self isTopMostView];
}

- (BOOL)movieControllerShouldPauseWhenEnterForeground:(ExploreMoviePlayerController *)movieController {
    return self.pauseMovieWhenEnterForground;
}

- (void)movieControllerPlayButtonClicked:(ExploreMoviePlayerController *)movieController replay:(BOOL)replay
{
    if (replay && _playPasterADSuccess) { // 只在重播时做修改
        _disablePlayPasterAD = YES;
    }
    
    _autoPause = NO;
    if (replay && [self p_shouldShowTrafficView:YES]) {
        //如果显示播放结束页面并且是非wifi情况下，要执行显示流量窗逻辑
        [self p_showNetTrafficView:TTVideoTrafficViewStatusReplay];
        [self.tracker sendVideoFinishUITrackWithEvent:@"replay" prefix:@"click"];
        [self.tracker sendContinueTrack];
        [self.moviePlayerController replayComplete:^(BOOL success) {

        }];
        if (_movieViewDelegate && [_movieViewDelegate respondsToSelector:@selector(replayButtonClickedInTrafficView)]) {
            [_movieViewDelegate replayButtonClickedInTrafficView];
        }
        return;
    }
    if (_moviePlayerController.playbackState == TTMoviePlaybackStatePlaying) {
        [[TTVideoAutoPlayManager sharedManager] markTargetMoviePause:YES];
        _userPause = YES;
        [self userPause];
        [self.tracker sendPauseTrack];
    }
    else {
        [[TTVideoAutoPlayManager sharedManager] markTargetMoviePause:NO];
        BOOL isPlaybackEnded = _isPlaybackEnded;

        if (replay) {
            [self.tracker sendVideoFinishUITrackWithEvent:@"replay" prefix:@"click"];
            [self.moviePlayerController replayComplete:^(BOOL success) {

            }];
            [self p_showTrafficToastIfNeed];
            if (_movieViewDelegate && [_movieViewDelegate respondsToSelector:@selector(replayButtonClicked)]) {
                [_movieViewDelegate replayButtonClicked];
            }
            if ([self.moviePlayerController isCustomPlayer]) {
                self.moviePlayerController.controlView.hasFinished = NO;
                [self showLoadingView:ExploreMoviePlayerControlViewTipTypeLoading];
            }
        }
        
        if (self.clickPlayButtonToPlayBlock) {
            self.clickPlayButtonToPlayBlock(self);
        }
        
        if (!isPlaybackEnded) { // 没有结束，继续播
            if ([_moviePlayerController isCustomPlayer]) {
                if (_moviePlayerController.playbackState == TTMoviePlaybackStateStopped) {
                    [self.moviePlayerController showLoadingTipView];
                }
            }
            _userPause = NO;
            [self userPlay];
            [self.tracker sendContinueTrack];

            return;
        }
        
        BOOL enablePrePaster = NO;//(self.pasterADEnableOptions & TTVideoEnablePrePaster) && self.letvVideoModel.preVideoADList.count > 0;
        if (!enablePrePaster) { //播放结束后再播一遍时，不再播广告

            _userPause = NO;
            [self userPlay];
            [self.tracker sendPlayTrack];
            return;
        }
        
        __weak typeof(self) wself = self; //播放结束后再播一遍时，再播一遍广告
        [self playPasterADs:self.letvVideoModel.preVideoADList completionBlock:^{
            __strong typeof(wself) self = wself;
            self.pasterADEnableOptions &= ~TTVideoEnablePrePaster;
            if (replay) {
                if ([self.moviePlayerController isCustomPlayer]) {
                    WeakSelf;
                    [self.moviePlayerController replayComplete:^(BOOL success) {
                        StrongSelf;
                        _userPause = NO;
                        [self userPlay];
                    }];
                }
                else
                {
                    self.moviePlayerController.currentPlaybackTime = 0;
                    _userPause = NO;
                    [self userPlay];
                }
            }
            else
            {
                _userPause = NO;
                [self userPlay];
            }
        }];
        [self.tracker sendPlayTrack];
    }
}

- (void)movieControllerShareButtonClicked:(ExploreMoviePlayerController *)movieController
{
    BOOL isfullScreen = _moviePlayerController.isMovieFullScreen;
    if (isfullScreen) {
        if (_movieViewDelegate && [_movieViewDelegate respondsToSelector:@selector(FullScreenshareButtonClicked)]) {
                [self.movieViewDelegate FullScreenshareButtonClicked];
            }
        }
    else{
        if (_movieViewDelegate && [_movieViewDelegate respondsToSelector:@selector(shareButtonClicked)]) {
            [self.movieViewDelegate shareButtonClicked];
        }
    }
}

- (void)movieControllerMoreButtonClicked:(ExploreMoviePlayerController *)movieController
{
    if (_movieViewDelegate && [_movieViewDelegate respondsToSelector:@selector(moreButtonClicked)]) {
        [self.movieViewDelegate moreButtonClicked];
    }
}

- (void)movieControllerShareActionClicked:(ExploreMoviePlayerController *)movieController withActivityType:(NSString *)activityType
{
    if (_movieViewDelegate && [_movieViewDelegate respondsToSelector:@selector(shareActionClickedWithActivityType:)]) {
        [self.movieViewDelegate shareActionClickedWithActivityType:activityType];
    }
}

- (BOOL)movieControllerFullScreenButtonClicked:(SSMoviePlayerController *)movieController isFullScreen:(BOOL)fullScreen completion:(void (^)(BOOL finished))completion
{
    if (movieController == _moviePlayerController) {
        [self.pasterADController setIsFullScreen:fullScreen];
        BOOL isAD = self.urlRequestInfo.playType == TTVideoPlayTypePasterAD;
        if (isAD) {
            if ([self.pasterADDelegate respondsToSelector:@selector(pasterADNeedsToFullScreen:)]) {
                [self.pasterADDelegate pasterADNeedsToFullScreen:fullScreen];
            }
            return NO;
        }
        
        if (fullScreen) {
            BOOL result = [self enterFullscreen:YES completion:completion];
            return result;
        }
        else {
            BOOL canChange = [self exitFullScreen:YES completion:completion];
            if (canChange) {
                [self.tracker sendExistFullScreenTrack:self.isFullScreenButtonAction];
                [self showDetailButtonIfNeeded];
            }
            return canChange;
        }
    }
    return NO;
}

- (NSArray <NSNumber *> *)supportedResolutionTypes
{
    NSMutableArray *types = [[NSMutableArray alloc] initWithCapacity:3];
    if (self.letvVideoModel.videoInfo.videoURLInfoMap.video1) {
        [types addObject:@(ExploreVideoDefinitionTypeSD)];
    }
    if (self.letvVideoModel.videoInfo.videoURLInfoMap.video2) {
        [types addObject:@(ExploreVideoDefinitionTypeHD)];
    }
    if (self.letvVideoModel.videoInfo.videoURLInfoMap.video3) {
        [types addObject:@(ExploreVideoDefinitionTypeFullHD)];
    }
    return types.copy;
}

- (void)movieController:(ExploreMoviePlayerController *)movieController
ResolutionButtonClickedWithType:(ExploreVideoDefinitionType)type
             typeString:(NSString *)typeString
{
    [ExploreMovieView setSelectedDefinitionType:type];
    _moviePlayerController.definitionType = type;

    NSTimeInterval progress = [self progress];
    if (progress < 0) {
        return;
    }
    [self removeSnapViewIfNeeded];
    if (self.videoModel.currentDefinitionType != [[self class] selectedDefinitionType]) {
        _isSwitchMultiResolution = YES;
        [self.moviePlayerController showLoadingTipView];
        self.videoModel.lastDefinitionType = self.videoModel.currentDefinitionType;
        self.videoModel.currentDefinitionType = type;
        UIView *snapView = [self snapshotViewAfterScreenUpdates:YES];
        if (snapView) {
            [self.moviePlayerController.controlView insertSubview:snapView aboveSubview:self.moviePlayerController.controlView.logoView];
            snapView.tag =  kSnapViewTag;
        }
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            WeakSelf;
            self.playStartBlock =^{
                StrongSelf;
                [self.moviePlayerController seekToProgress:progress];
                self.isSwitchMultiResolution = NO;
            };
            
            self.willPlayableBlock = ^{
                StrongSelf;
                [self removeSnapViewIfNeeded];
            };
            
            self.willFinishBlock = ^{
                StrongSelf;
                if (!self.showedOneFrame && !self.isStoppedAfterDelay && !self.isStoped) {
                    self.isSwitchMultiResolution = NO;
                }
            };

            if (self.duration > 0) {
                [TTVideoDefinationTracker sharedTTVideoDefinationTracker].clarity_change_time = self.currentPlayingTime/self.duration * 100;
            }
            [self pauseMovie];
            _preResolutionWatchingDuration = [self.tracker watchedDuration] * 1000 + self.tracker.preResolutionWatchingDuration;

            [self.tracker resetStatus];
            [self stopMovie];
            [self _playContent];
            [self playMovie];
            self.tracker.preResolutionWatchingDuration = _preResolutionWatchingDuration;
            _hasSendTrackLog = NO;
            [self.moviePlayerController.trackManager userClickPlayButtonForID:self.urlRequestInfo.videoID fetchURL:nil isClearALl:NO];
        });
    }
}


- (void)movieControllerPlaybackPrepareToPlay:(SSMoviePlayerController *)movieController
{
    if (movieController == _moviePlayerController)
    {
        if ([self.moviePlayerController isCustomPlayer]) {
            if (!_isPrepared) {
                [self playStart];
                _isPrepared = YES;
            }
        }
    }
}

- (void)playStart
{
    if (self.playStartBlock) {
        __weak typeof(self) wself = self;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            StrongSelf;
            if (self.playStartBlock) {
                self.playStartBlock();
                self.playStartBlock = nil;
            }
        });
    }
    if (self.playStartShowCacheLabelBlock) {
        __weak typeof(self) wself = self;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            StrongSelf;
            if (self.playStartShowCacheLabelBlock) {
                self.playStartShowCacheLabelBlock();
                self.playStartShowCacheLabelBlock = nil;
            }
        });
    }

}

- (NSTimeInterval)progress
{
    NSTimeInterval currentPlayTime = self.moviePlayerController.currentPlaybackTime;
    NSTimeInterval duration = self.moviePlayerController.duration;
    if (currentPlayTime < 0 || duration <= 0) {
        return -1;
    }
    return (currentPlayTime * 100) / duration;
}

- (void)removeSnapViewIfNeeded
{
    UIView *snapView = ([self.moviePlayerController.controlView viewWithTag:kSnapViewTag]);
    if (snapView) {
        [snapView removeFromSuperview];
    }
}

+ (ExploreVideoDefinitionType)selectedDefinitionType
{
    return [TTMovieViewCacheManager sharedInstance].lastDefinitionType;
}

+ (void)setSelectedDefinitionType:(ExploreVideoDefinitionType)type
{
    [TTMovieViewCacheManager sharedInstance].lastDefinitionType = type;
}

- (NSString *)currentCDNHost
{
    return self.hostName;
}

- (void)movieControllerLandscapeLeftRightRotate:(ExploreMoviePlayerController *)movieController
{
    if (_isNewRotate) {
        [self.rotateController changeRotationOfLandscape];
    }
    [[self class] setFullScreen:YES];
}

+ (void)changeAlwaysCloseAlert {
    NSInteger idx = [[NSUserDefaults standardUserDefaults] integerForKey:@"TTVideoTrafficTipSettingKey"];
    if (idx == 0) { //如果每次都显示提示，则关掉开关
        kAlwaysCloseAlert = NO;
    } else {
        if (kHasAlreadyShownAlert) { //如果已经显示过提示页面，则打开开关
            kAlwaysCloseAlert = YES;
        } else {
            kAlwaysCloseAlert = NO;
        }
    }
}

- (BOOL)isUrlPlayFailed
{
    return !_showedOneFrame && !_isStoppedAfterDelay && !_isStoped;
}

- (void)definationNumber
{
    NSInteger num = 0;
    if (self.letvVideoModel.videoInfo.videoURLInfoMap.video1) {
        num++;
    }
    if (self.letvVideoModel.videoInfo.videoURLInfoMap.video2) {
        num++;
    }
    if (self.letvVideoModel.videoInfo.videoURLInfoMap.video3) {
        num++;
    }
    [[TTVideoDefinationTracker sharedTTVideoDefinationTracker] definationNumber:num];
}
#pragma mark - SSMoviePlayerControllerDelegate

- (void)movieControllerShowedOneFrame:(SSMoviePlayerController *)movieController
{
    if (_playRequestTimestamp > 0) {
        NSTimeInterval interval = [[NSDate date] timeIntervalSince1970] - _playRequestTimestamp;
        _playRequestTimestamp = 0;
        [[TTMonitor shareManager] trackService:video_play_first_frame_interval value:@(interval) extra:nil];
    }
    [[TTMonitor shareManager] trackService:video_play_request_status status:TTVideoPlayRequestStatusSuccess extra:nil];
    if (!_isSwitchMultiResolution) {
        [self.tracker sendPlayOneFrameTrack];
    }

    if (movieController == _moviePlayerController) {
        _showedOneFrame = YES;
        NS_VALID_UNTIL_END_OF_SCOPE ExploreMovieView *strongSelf = self;
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(checkLoadingTimeout) object:nil];

        if ([self.pasterADDelegate respondsToSelector:@selector(pasterADWillStart)]) {
            [self.pasterADDelegate pasterADWillStart];
        }

        LOGD(@"movieControllerShowedOneFrame");
        [self playStart];
    }
}

- (BOOL)movieHasFirstFrame
{
    return self.showedOneFrame;
}

- (void)movieStateChanged:(SSMoviePlayerController * _Nullable)movieController
{
    
}

- (void)movieController:(SSMoviePlayerController *)movieController playbackHasError:(NSError *)error
{
    _hasError = YES;
    [self.moviePlayerController.trackManager setPlayError:error];
    [[TTMonitor shareManager] trackService:video_play_error value:@(1) extra:nil];
    [[TTMonitor shareManager] trackService:@"video_play_player_error" value:@(1) extra:nil];
    [self p_cacheMovieViewProgress];

    NSArray *urls = [self allPlayURLs];

    if (urls.count <= (_playURLIndex + 1) || ![self isUrlPlayFailed]) {//url都播放失败 + 如果能播放 但是播放中失败了
        NSTimeInterval progress = [self progress];
        if ([self.moviePlayerController isCustomPlayer]) {
            [ExploreMovieView stopAllExploreMovieView];
        }
        [self.moviePlayerController.controlView setToolBarHidden:YES needAutoHide:NO];
        [self.moviePlayerController showRetryTipView];
        if (progress < 0) {
            return;
        }
        WeakSelf;
        self.playStartBlock =^{
            StrongSelf;
            [self.moviePlayerController seekToProgress:progress];
        };
    }
    else
    {
        // 如果不能播放则尝试加载备选URL
        if ([self isUrlPlayFailed]) {
            [self movieControllerPlaybackDidFinish:movieController];
        }
    }

}

- (void)movieControllerMovieStalled:(SSMoviePlayerController *)movieController
{
    if (movieController == _moviePlayerController) {
        if ([self.pasterADDelegate respondsToSelector:@selector(pasterADWillStalle)]) {
            [self.pasterADDelegate pasterADWillStalle];
        }
        
        if ([UIDevice currentDevice].systemVersion.floatValue >= 10.0)
        {
            if (!_resignActive) {
                [_moviePlayerController showLoadingTipView];
            }
        }
        else
        {
            [_moviePlayerController showLoadingTipView];
        }
    }
}

- (void)movieControllerMoviePlayable:(SSMoviePlayerController *)movieController
{
    if (movieController == _moviePlayerController) {
        self.videoDidPlayable = YES;
        LOGD(@"movieControllerMoviePlayable");
        if (!self.willPlayableBlock) {
            [_moviePlayerController hideLoadingTipView];
        }
        if ([self.pasterADDelegate respondsToSelector:@selector(pasterADWillPlayable)]) {
            [self.pasterADDelegate pasterADWillPlayable];
        }
        
        if (self.willPlayableBlock) {
            WeakSelf;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(),
                           ^{
                StrongSelf;
                if (!self) {
                    return ;
                }
                if (![self.moviePlayerController isCustomPlayer]) {
                    float rate = [self.moviePlayerController currentRate];
                    if (rate < 0 || fabsf(rate) <= 0.00001f) { //rate <= 0
                        return ;
                    }
                }
                if (self.willPlayableBlock) {
                    self.willPlayableBlock();
                    self.willPlayableBlock = nil;
                }
                [self afterPlayable];
            });
        }
        else
        {
            [self afterPlayable];
        }


    }
}

- (void)movieControllerPlaybackDidFinish:(SSMoviePlayerController *)movieController
{
    if (movieController == _moviePlayerController) {
        self.videoDidPlayable = NO;
        [self removeSnapViewIfNeeded];
        if (!self->_isSwitchMultiResolution) {
            [self removeSnapViewIfNeeded];
        }
        if (self.willFinishBlock) {
            self.willFinishBlock();
            self.willFinishBlock = nil;
        }
        
        // 如果不能播放则尝试加载备选URL
        if ([self isUrlPlayFailed]) {
            // 加开关控制，定位二次失败率升高的问题
            if ([ExploreMovieManager isRetryLoadWhenFailed]) {
                [[TTMonitor shareManager] trackService:video_play_request_status status:TTVideoPlayRequestStatusFail extra:nil];
                NSString *playURL = [self getPlayURL];
                if (!isEmptyString(playURL)) {
                    [self tryLoadNextURL];
                }
                if (!_hasAlreadyStopped) {
                    [self.moviePlayerController.trackManager sendEndTrack];
                }
            }
            else
            {
                [self showRetryTipView];
            }
            return;
        }

        //直播
        if ([self isLiveVideo]) {
            
            [_moviePlayerController showLoadingTipView];
            
            //中断与结束状态区分
            if (self.letvVideoModel.liveInfo.status.integerValue == 3) {
                
                if (!self.liveVideoRestartOnce) {
                    self.liveVideoRestartOnce = YES;
                    [self _fetchVideoURLInfo];
                }
                else {
                    [_moviePlayerController showRetryTipView];
                }
            }
            else {
                [_moviePlayerController showLiveOverTipView];
                
            }
            
            //退出全屏
            if (self.isMovieFullScreen) {
                [self exitFullScreen:YES completion:nil];
            }

            
            if (self.videoModel.videoPlayType == TTVideoPlayTypeLivePlayback) {
                self.tracker.isPlaybackEnded = _isPlaybackEnded;
            } else {
                self.tracker.isPlaybackEnded = YES;
            }

            [self movieAutoPlay];
            if (!_hasAlreadyStopped) {
                [self.tracker sendEndTrack];
            }
        }
        
        //点播
        else {
            
            _isPlaybackEnded = (_moviePlayerController.duration > 0 && [self currentPlayingTime] + 2 > _moviePlayerController.duration);
            
            self.tracker.isPlaybackEnded = _isPlaybackEnded;
            
            self.isPlaying = NO;
            
            if (self.shouldShowNewFinishUI && ![self isAdMovie]) {
                if (_isPlaybackEnded) {
                    [self checkUserInteraction];
                    [self.tracker sendVideoFinishUITrackWithEvent:@"replay" prefix:@"show"];
                    [self.tracker sendVideoFinishUITrackWithEvent:@"share" prefix:@"show"];
                    [_moviePlayerController showMovieFinishView];
                }
            } else if ([self isAdMovie] && _isPlaybackEnded) {
                [self checkUserInteraction];
                [_moviePlayerController showMovieFinishView];
                [_moviePlayerController.controlView hideTitleBarView:YES];
            } else {
                [_moviePlayerController refreshPlayButton];
            }

            [self movieAutoPlay];
            
            if (!_isSwitchMultiResolution) {
                if (self.moviePlayerController.duration && self.moviePlayerController.playableDuration && [self.letvVideoModel.videoInfo videoSizeForType:self.videoModel.currentDefinitionType]) {
                    CGFloat loadSize = [self.letvVideoModel.videoInfo videoSizeForType:self.videoModel.currentDefinitionType] * self.moviePlayerController.playableDuration / self.moviePlayerController.duration;
                    CGFloat playSize = [self.letvVideoModel.videoInfo videoSizeForType:self.videoModel.currentDefinitionType] * self.moviePlayerController.currentPlaybackTime / self.moviePlayerController.duration;
                    [self.moviePlayerController.trackManager setVideoDownloadSize:(NSInteger)loadSize];
                    [self.moviePlayerController.trackManager setVideoPlaySize:(NSInteger)playSize];
                    [[TTMonitor shareManager] trackService:video_play_load_size value:@(loadSize) extra:nil];
                }
                if (!_hasAlreadyStopped) {
                    [self.tracker sendEndTrack];
                }

                [self p_cacheMovieViewProgress];
            }
            
            if (!_hasSendTrackLog) {
                // 视频结束播放后拖动进度条重新播放，不再发送视频质量统计
                _hasSendTrackLog = YES;
                if (!_hasAlreadyStopped) {
                    if (_isStoppedAfterDelay) {
                        [self.moviePlayerController.trackManager flushTrack];
                    } else {
                        [self.moviePlayerController.trackManager sendEndTrack];
                    }
                }
                // 清空日志，避免trackManager释放时再次发送
                [self.moviePlayerController.trackManager clearAll];
            }
            
            
            [_moviePlayerController refreshSlider];
            
            //全屏逻辑
            if (!_isPlaybackEnded || self.stopMovieWhenFinished || ([self.movieDelegateData ttv_couldAutoPlay] && !self.tracker.wasInDetail)) { // Stopped
                if (!_isSwitchMultiResolution) {
                    if ([self exitFullScreenIfNeed:YES]) {
                        [self.tracker sendExistFullScreenTrack:YES];
                    };

                }
                if ([self isAdMovie] && _isPlaybackEnded) {
                    [self showLogo];
                }
                dispatch_block_t notiBlock = ^ {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [[NSNotificationCenter defaultCenter] postNotificationName:kExploreMovieViewPlaybackFinishNotification object:self];
                    });
                };
                if (self.stopMovieWhenFinished && !([self isAdMovie] && _isPlaybackEnded) && !_isSwitchMultiResolution) {
                    notiBlock();
                } else if ([self.movieDelegateData ttv_couldAutoPlay] && !self.tracker.wasInDetail && !_isSwitchMultiResolution && ![self isAdMovie]) {
                    notiBlock();
                }
            } else {
                
                BOOL afterPasterIsValid = ([self.pasterADController.playingADModel.videoPasterADInfoModel.duration integerValue] > 0 && !_disablePlayPasterAD & (TTNetworkGetFlags() & TTNetworkFlagWifi));
                
                if (self.isMovieFullScreen && !self.stayFullScreenWhenFinished && !afterPasterIsValid) {
                    if (_isRotateAnimating) {
                        _shouldExitFullScreenLater = YES;
                    } else {
                        if ([self exitFullScreen:YES completion:nil]) {
                            [self.tracker sendExistFullScreenTrack:YES];
                        };
                    }
                }
                
                __weak typeof(self) wself = self;
                if (afterPasterIsValid) {
                    [self playPasterADs:self.letvVideoModel.afterVideoADList completionBlock:^{
                        __strong typeof(wself) self = wself;
                        self.pasterADEnableOptions &= ~TTVideoEnableAfterPaster;
                        if (self.isMovieFullScreen && !self.stayFullScreenWhenFinished) {
                            if ([self exitFullScreen:YES completion:nil]) {
                                [self.tracker sendExistFullScreenTrack:YES];
                            };
                        }
                    }];
                } else {
                    
                    self.pasterADController = nil;
                }
                [self showLogo];
            }

            [_moviePlayerController reset];

            if ([self.pasterADDelegate respondsToSelector:@selector(pasterADWillFinishWithPlayEnd:)]) {
                [self.pasterADDelegate pasterADWillFinishWithPlayEnd:_isPlaybackEnded];
            }

            if (_isPlaybackEnded) {
                [[NSNotificationCenter defaultCenter] postNotificationName:kExploreMovieViewPlaybackFinishNormallyNotification object:self];
            }
        }
    }
    _hasAlreadyStopped = YES;
    self.tracker.isReplaying = NO;
}

#pragma mark - SSMoviePlayerTrackManagerDelegate

- (void)afterPlayable
{
    [_moviePlayerController hideLoadingTipView]; // 延迟hide
    if (_autoPause) {
        DLog(@"afterPlayable");
        [self pauseMovieAndShowToolbar];
    }
}

//当前网络
- (NSString *)connectMethodName
{
    return [TTNetworkHelper connectMethodName];
}

//当前运营商
- (NSString *)carrierMNC
{
    return [TTNetworkHelper carrierMNC];
}

#pragma mark - 


// 点击播放结束后封面图上的‘查看详情’
- (void)showDetailButtonClicked
{
    if (_movieViewDelegate && [_movieViewDelegate respondsToSelector:@selector(showDetailButtonClicked)]) {
        if (_moviePlayerController.isMovieFullScreen) {
            [self exitFullScreen:YES completion:^(BOOL finished) {
                [self.movieViewDelegate showDetailButtonClicked];
            }];
        } else {
            [self.movieViewDelegate showDetailButtonClicked];
        }
    }
}

#pragma mark -- ExploreMovieManagerDelegate

- (void)manager:(ExploreMovieManager *)manager errorDict:(NSDictionary *)errorDict videoModel:(ExploreVideoModel *)videoModel
{
    [TTVideoDefinationTracker sharedTTVideoDefinationTracker].lastDefination = [[self class] selectedDefinitionType];
    DLog(@"manager errorDict %@ videoModel %@",errorDict,videoModel);
    if (_autoPause) {
        return;
    }
    [self.tracker sendGetUrlTrack];
    
    if ([errorDict isKindOfClass:[NSDictionary class]] && errorDict.count > 0) {
        _hasError = YES;
        [[TTMonitor shareManager] trackService:video_play_request_status status:TTVideoPlayRequestStatusFail extra:nil];
        [[TTMonitor shareManager] trackService:video_play_error value:@(1) extra:nil];
        [self.moviePlayerController.trackManager setApiErrorDict:errorDict];
    }
    
    if (!videoModel) {
        if ([self hasLocalUrl]) {
            if (!self.movieManager.isFeedUrl) {
                [self.moviePlayerController.trackManager fetchedVideoStartPlay];
            }
            [self.tracker sendPlayUrlTrack];
            [self _playContent];
        } else {
           NSString *tipstring = [[self class] tipStringWithURLStatus:[errorDict valueForKey:@"status"]];
            [self showRetryTipViewWithTipString:tipstring];
            // api失败，立即发 统计
            [self.moviePlayerController.trackManager sendEndTrack];
            [self.moviePlayerController.trackManager clearAll];
        }
    } else {
        
        self.letvVideoModel = videoModel;
        [self definationNumber];
        _fetchURLTime = CACurrentMediaTime();
        
        //直播，暂时无广告
        if ([self isLiveVideo]) {
            
            switch (videoModel.liveInfo.liveStatus.integerValue) {
                case 0://未知错误
                    [_moviePlayerController showRetryTipView];
                    
                    if (self.isMovieFullScreen) {
                        [self exitFullScreen:YES completion:nil];
                    }
                    //统计
                    wrapperTrackEventWithCustomKeys(@"live", @"loadingfail", self.gModel.groupID, nil, nil);

                    break;
                case 1:
                    
                    //直播结束
                    [_moviePlayerController showLiveOverTipView];
                    if (self.isMovieFullScreen) {
                        [self exitFullScreen:YES completion:nil];
                    }
                    
                    //统计
                    wrapperTrackEventWithCustomKeys(@"live",@"over",  self.gModel.groupID, nil, nil);
                    
                    self.tracker.isPlaybackEnded = YES;
                    [self movieAutoPlay];
                    [self.tracker sendEndTrack];
                    
                    break;
                case 2://等待直播
                    [_moviePlayerController showLiveWaitingTipView];
                    
                    //统计
                    wrapperTrackEventWithCustomKeys(@"live",@"waiting",  self.gModel.groupID, nil, nil);
                    break;
                case 3://直播中
                default:
                    [self _playContent];
                    
                    //统计
                    wrapperTrackEventWithCustomKeys(@"live",@"loading",  self.gModel.groupID, nil, nil);
                    
                    break;
            }
            
            return;
        }
        
        //点播，有广告
        BOOL enablePrePaster = self.pasterADEnableOptions & TTVideoEnablePrePaster;  
        if (enablePrePaster && videoModel.preVideoADList.count > 0) {
            __weak typeof(self) wself = self;
            
            [self playPasterADs:videoModel.preVideoADList completionBlock:^{
                __strong typeof(wself) self = wself;
                self.pasterADEnableOptions &= ~TTVideoEnablePrePaster;
                if (!self.movieManager.isFeedUrl) {
                    [self.moviePlayerController.trackManager fetchedVideoStartPlay];
                }
                [self _playContent];
            }];
        }
        else {
            if (!self.movieManager.isFeedUrl) {
                [self.moviePlayerController.trackManager fetchedVideoStartPlay];
            }
            [self.tracker sendPlayUrlTrack];
            //当获得视频url并且处于非wifi下，要执行显示流量窗逻辑
            if ([self p_shouldShowTrafficView:NO]) {
                [self p_showNetTrafficView:TTVideoTrafficViewStatusStart];
            } else {
                if (!_isShowingConnectAlert) {
                    [self _playContent];
                    [self p_showTrafficToastIfNeed];
                }
            }
        }
    }
    [self.moviePlayerController refreshResolutionButton];
    
}

- (void)movieAutoPlay
{
    //这里delegate可能是视频详情页，也可能是cell的movieViewDelegate
    if (self.movieDelegateData) {
        if ([self.movieDelegateData isKindOfClass:[ExploreOrderedData class]]) {
            ExploreOrderedData *data = (ExploreOrderedData *)self.movieDelegateData;
            if ([[TTVideoAutoPlayManager sharedManager] dataIsAutoPlaying:data]) {
                if (_isPlaybackEnded) {
                    if (self.tracker.type == ExploreMovieViewTypeList) {
                        if (self.tracker.hasEnterDetail) {
                            [[TTVideoAutoPlayManager sharedManager] trackForFeedBackPlayOver:data movieView:self];
                        } else {
                            [[TTVideoAutoPlayManager sharedManager] trackForFeedPlayOver:data movieView:self];
                        }
                    } else if (self.tracker.type == ExploreMovieViewTypeDetail) {
                        [[TTVideoAutoPlayManager sharedManager] trackForAutoDetailPlayOver:data movieView:self];
                    }
                }
                [[TTVideoAutoPlayManager sharedManager] dataStopAutoPlay:data];
            }
        }
    }
}

#pragma mark -- notification

+ (void)removeAllExploreMovieView
{
    
    [ExploreMovieView setCurrentVideoPlaying:NO];
    
    [TTVPlayVideo removeAll];
    //点击了别的视频，当前的view被remove掉
    [TTMovieViewCacheManager sharedInstance].currentPlayingVideoID = @"";
    [[NSNotificationCenter defaultCenter] postNotificationName:kExploreNeedStopAllMovieViewPlaybackNotification object:nil];
}

+ (void)stopAllExploreMovieView
{
    
    [ExploreMovieView setCurrentVideoPlaying:NO];
    [[TTAPPIdleTime sharedInstance_tt] lockScreen:YES later:YES];
    [[NSNotificationCenter defaultCenter] postNotificationName:kExploreStopMovieViewPlaybackWithoutRemoveMovieViewNotification object:nil];
}

- (void)removeTheMovieView
{
    if ([[TTMovieViewCacheManager sharedInstance].currentPlayingVideoID isEqualToString:self.playVID] && self.tracker.type == ExploreMovieViewTypeList) {
        //当前的view划出屏幕
        [TTMovieViewCacheManager sharedInstance].currentPlayingVideoID = @"";
    }
    [self exitFullScreenIfNeed:NO];
    [self stopMovie];
    [self removeFromSuperview];
    [[NSNotificationCenter defaultCenter] postNotificationName:kExploreStopMovieViewPlaybackNotification object:self];
}

#pragma mark - net traffic related

- (BOOL)p_shouldUseNewTrafficView {
    if (self.videoModel.videoPlayType != TTVideoPlayTypeNormal &&
        self.videoModel.videoPlayType != TTVideoPlayTypeDefault &&
        self.videoModel.videoPlayType != TTVideoPlayTypePasterAD) {
        return NO;
    }
    if (self.notShowTraffic) {
        return NO;
    }
    return YES;
}

- (BOOL)p_shouldShowTrafficView:(BOOL)isReplay {
    if (![self p_shouldUseNewTrafficView]) {
        return NO;
    }
    if (TTNetworkWifiConnected()) {
        return NO;
    }
    if (!TTNetworkConnected()) {
        return NO;
    }
    if (!kAlwaysCloseAlert && !_isShowingConnectAlert && !hasShowAlertNumber && (!_isPlaybackEnded || isReplay) && self.superview) {
        return YES;
    }
    return NO;
}

- (BOOL)p_isShowingTrafficView {
    if ([self p_shouldUseNewTrafficView] && _isShowingConnectAlert) {
        return YES;
    }
    return NO;
}

- (void)p_showNetTrafficView:(TTVideoTrafficViewStatus)status {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        NSString *position = self.tracker.wasInDetail ? @"detail" : @"list";
        if ([self isAdMovie]) {
            position = @"others";
        }
        
        ExploreVideoDefinitionType type = ([TTMovieViewCacheManager sharedInstance].userSelected) ? [TTMovieViewCacheManager sharedInstance].lastDefinitionType:ExploreVideoDefinitionTypeHD;
        
        if ([TTVPlayerFreeFlowTipStatusManager shouldShowDidOverFlowTip]) {
            CGFloat videoSize = [self.letvVideoModel.videoInfo videoSizeForType:ExploreVideoDefinitionTypeSD] / 1024.f / 1024.f;
            [self p_changeTrafficTipPreCondition];
            
            NSString *tipText = [NSString stringWithFormat:@"本月免费流量已不足，继续播放将消耗%.2fMB流量", videoSize];
            self.freeFlowTipView = [[TTVNetTrafficFreeFlowTipView alloc] initWithFrame:self.bounds tipText:tipText isSubscribe:NO];
            [self addSubview:self.freeFlowTipView];
            WeakSelf;
            self.freeFlowTipView.continuePlayBlock = ^{
                StrongSelf;
                
                [self p_changeTrafficTipEndCondition];
                
                [self p_convertVideoToSDAndPlayWithSelectedDefinitionType:ExploreVideoDefinitionTypeSD];
                [self.freeFlowTipView removeFromSuperview];
            };
            
            return ;
        }
        
        if ([TTVPlayerFreeFlowTipStatusManager shouldShowFreeFlowSubscribeTip]) {
            
            [self p_changeTrafficTipPreCondition];
            
            CGFloat videoSize = [self.letvVideoModel.videoInfo videoSizeForType:ExploreVideoDefinitionTypeSD] / 1024.f / 1024.f;
            NSString *tipText = [TTVPlayerFreeFlowTipStatusManager getSubscribeTitleTextWithVideoSize:videoSize];
            self.freeFlowTipView = [[TTVNetTrafficFreeFlowTipView alloc] initWithFrame:self.bounds tipText:tipText isSubscribe:YES];
            [self addSubview:self.freeFlowTipView];
            NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithCapacity:4];
            params[@"category_name"] = self.cID;
            params[@"position"] = position;
            params[@"group_id"] = self.gModel.groupID;
            params[@"source"] = @"data_package_tip";
            [TTTrackerWrapper eventV3:@"continue_button_show" params:params];
            [TTTrackerWrapper eventV3:@"purchase_button_show" params:params];
            
            WeakSelf;
            self.freeFlowTipView.continuePlayBlock = ^{
                StrongSelf;
                [TTTrackerWrapper eventV3:@"continue_button_click" params:params];
                
                [self p_changeTrafficTipEndCondition];
                
                [self p_convertVideoToSDAndPlayWithSelectedDefinitionType:ExploreVideoDefinitionTypeSD];
                [self.freeFlowTipView removeFromSuperview];
            };
            self.freeFlowTipView.subscribeBlock = ^{
                StrongSelf;
                [TTTrackerWrapper eventV3:@"purchase_button_click" params:params];
                
                NSString *webURL = [[TTFlowStatisticsManager sharedInstance] freeFlowEntranceURL];
                if (!isEmptyString(webURL)) {
                    
                    TTAppPageCompletionBlock block = ^(id obj) {
                        
                        if ([[TTFlowStatisticsManager sharedInstance] flowStatisticsEnable] &&
                            [TTFlowStatisticsManager sharedInstance].isSupportFreeFlow &&
                            [TTFlowStatisticsManager sharedInstance].isOpenFreeFlow) {
                            
                            [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:@"免流量服务中" indicatorImage:nil autoDismiss:YES dismissHandler:nil];
                            [self p_changeTrafficTipEndCondition];
                            [self p_convertVideoToSDAndPlayWithSelectedDefinitionType:type];
                            [self.freeFlowTipView removeFromSuperview];
                        }
                    };
                    NSMutableDictionary *condition = [[NSMutableDictionary alloc] initWithCapacity:2];
                    condition[@"completion_block"] = [block copy];
                    [[TTRoute sharedRoute] openURLByPushViewController:[TTStringHelper URLWithURLString:webURL] userInfo:TTRouteUserInfoWithDict(condition)];
                }
            };
            
            return ;
           }
        
        if ([TTVPlayerFreeFlowTipStatusManager shouldShowWillOverFlowTip:[self.letvVideoModel.videoInfo videoSizeForType:type] / 1024.f]) {
               
            CGFloat videoSize = [self.letvVideoModel.videoInfo videoSizeForType:type] / 1024.f / 1024.f;
            [self p_changeTrafficTipPreCondition];
            
            NSString *tipText = [NSString stringWithFormat:@"本月免费流量已不足，继续播放将消耗%.2fMB流量", videoSize];
            self.freeFlowTipView = [[TTVNetTrafficFreeFlowTipView alloc] initWithFrame:self.bounds tipText:tipText isSubscribe:NO];
            [self addSubview:self.freeFlowTipView];
            WeakSelf;
            self.freeFlowTipView.continuePlayBlock = ^{
                StrongSelf;
                
                [self p_changeTrafficTipEndCondition];
                
                [self p_convertVideoToSDAndPlayWithSelectedDefinitionType:type];
                [self.freeFlowTipView removeFromSuperview];
            };
            
            return ;
        }
        
        if ([TTVPlayerFreeFlowTipStatusManager shouldShowFreeFlowLoadingTip]) {
            
            [self p_convertVideoToSDAndPlayWithSelectedDefinitionType:type];
            
            return ;
        }
            
        
        {
            [self p_changeTrafficTipPreCondition];
            
            NSInteger isInitial = 1;
            if (status == TTVideoTrafficViewStatusDuring) {
                isInitial = 0;
            }
            wrapperTrackEventWithCustomKeys(@"video", @"net_alert_show", self.gModel.groupID, nil, @{@"is_initial":@(isInitial),@"position":position});
            
            TTMovieNetTrafficViewModel *viewModel = [[TTMovieNetTrafficViewModel alloc] init];
            viewModel.videoSize = [self.letvVideoModel.videoInfo videoSizeForType:ExploreVideoDefinitionTypeSD];
            viewModel.videoDuration = [self.letvVideoModel.videoInfo.videoDuration integerValue];
            viewModel.isInDetail = _isNormalDetailMovieView;
            self.trafficView.viewModel = viewModel;
            
            if (TTVideoPlayTypePasterAD == self.videoModel.videoPlayType) {
                // 解决流量窗口和倒计时窗口显示异常问题
                [_trafficView removeFromSuperview];
                [self addSubview:_trafficView];
            }
            _trafficView.hidden = NO;
            WeakSelf;
            _trafficView.continuePlayBlock = ^ {
                StrongSelf;
                [self p_changeTrafficTipEndCondition];
                wrapperTrackEventWithCustomKeys(@"video", @"net_alert_confirm", self.gModel.groupID, nil, @{@"is_initial":@(isInitial),@"position":position});
                self.trafficView.hidden = YES;
                [self p_convertVideoToSDAndPlayWithSelectedDefinitionType:ExploreVideoDefinitionTypeSD];
            };
        }
    });
}

- (void)p_changeTrafficTipPreCondition {
    
    _isShowingConnectAlert = YES;
    hasShowAlertNumber++;
    
    _isPauseOnNetworkChanged = YES;
    [_moviePlayerController moviePause];
    
    if (TTVideoPlayTypePasterAD == self.videoModel.videoPlayType) {
        
        if ([self.pasterADDelegate respondsToSelector:@selector(pasterADWillPause)]) {
            [self.pasterADDelegate pasterADWillPause];
        }
    }
    
    if (_moviePlayerController.isMovieFullScreen) {
        [self exitFullScreen:YES completion:^(BOOL finished) {
        }];
    }
}

- (void)p_changeTrafficTipEndCondition {
    
    //如果在设置页面设置只显示一次，则把kAlwaysCloseAlert置为YES
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"TTVideoTrafficTipSettingKey"]) {
        [[NSUserDefaults standardUserDefaults] setInteger:1 forKey:@"TTVideoTrafficTipSettingKey"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    if ([[NSUserDefaults standardUserDefaults] integerForKey:@"TTVideoTrafficTipSettingKey"]) {
        kAlwaysCloseAlert = YES;
    }
    kHasAlreadyShownAlert = YES;
    self->_isPauseOnNetworkChanged = NO;
    self->_isShowingConnectAlert = NO;
    hasShowAlertNumber--;
}

- (void)p_resumeToPlay {
    kHasAlreadyShownAlert = YES;
    _isPauseOnNetworkChanged = NO;
    _isShowingConnectAlert = NO;
    hasShowAlertNumber--;
//    self.trafficView.hidden = YES;
    [self setTrafficTipViewHidden:YES];
    if (!_showedOneFrame) {
        [self _playContent];
    } else {
        [self userPlay];
    }
}

- (void)clearStatus
{
    _hasError = NO;
    self.showedOneFrame = NO;
    self.isPlaying = NO;
    self.isRotateAnimating = NO;
    self.isStoppedAfterDelay = NO;
    self.isSwitchMultiResolution = NO;
    self.isPlayingWhenBackToFloat = NO;
    self.isStoped = NO;
    [self p_clearNetTrafficView];
}

- (void)p_clearNetTrafficView {
    _hasShowTrafficToast = NO;
    _isShowingConnectAlert = NO;
    _isPauseOnNetworkChanged = NO;
    hasShowAlertNumber = 0;
    _trafficView.hidden = YES;
}

- (void)setTrafficTipViewHidden:(BOOL)hidden {
    
    _trafficView.hidden = hidden;
    _freeFlowTipView.hidden = hidden;
    
    [_freeFlowTipView removeFromSuperview];
}

- (void)p_convertVideoToSDAndPlayWithSelectedDefinitionType:(ExploreVideoDefinitionType)type {
    [ExploreMovieView setSelectedDefinitionType:type];
    if (!_showedOneFrame) {
        _moviePlayerController.definitionType = [[self class] selectedDefinitionType];
        _videoModel.lastDefinitionType = _videoModel.currentDefinitionType;
        _videoModel.currentDefinitionType = [[self class] selectedDefinitionType];
        [self _playContent];
    } else if (self.videoModel.currentDefinitionType == type) {
        //如果原来就是标清，则继续播放
        [self userPlay];
    } else {
        NSString *str = [NSString stringWithFormat:@"%@_360p", [self.letvVideoModel.videoInfo definitionStrForType:self.videoModel.currentDefinitionType]];
        str = [str uppercaseString];
        wrapperTrackEventWithCustomKeys(@"video", @"clarity_auto_select", [self.movieDelegateData ttv_groupModel].groupID, nil, @{@"select_type":str});
        //需要切换到标清，再继续播放
        [self movieController:_moviePlayerController ResolutionButtonClickedWithType:type typeString:[TTMovieResolutionSelectView typeStringForType:type]];
    }
    
    if ([self.pasterADDelegate respondsToSelector:@selector(pasterADWillResume)]) {
        [self.pasterADDelegate pasterADWillResume];
    }
}

+ (BOOL)hasShownTrafficView {
    return kAlwaysCloseAlert;
}

#pragma mark - kReachabilityChangedNotification

- (void)connectionChanged:(NSNotification *)notification
{
    NS_VALID_UNTIL_END_OF_SCOPE __strong typeof(self) strongSelf = self;
    //延迟2s，防止网络抖动
    [NSObject cancelPreviousPerformRequestsWithTarget:strongSelf selector:@selector(showNetworkAlertIfNeeded) object:nil];
    
    [strongSelf performSelector:@selector(showNetworkTipViewIfNeeded) withObject:nil afterDelay:2];
}

- (void)showNetworkTipViewIfNeeded {
    
    if ([TTVPlayerFreeFlowTipStatusManager shouldShowFreeFlowToastTip:[self.letvVideoModel.videoInfo videoSizeForType:ExploreVideoDefinitionTypeSD] / 1024.f]) {
        
        if (!_moviePlayerController.isMovieFullScreen) {
            [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:@"免流量服务中" indicatorImage:nil autoDismiss:YES dismissHandler:nil];
        }
        
        if (![TTMovieViewCacheManager sharedInstance].userSelected) {
            
            [self p_convertVideoToSDAndPlayWithSelectedDefinitionType:ExploreVideoDefinitionTypeHD];
        }
    } else {
        [self showNetworkAlertIfNeeded];
    }
}

- (BOOL)canShowAlert
{
    return !TTNetworkWifiConnected() && TTNetworkConnected() && !kAlwaysCloseAlert && hasShowAlertNumber == 0
    && !_isStoped && !self.disableNetworkAlert && (![[TTFlowStatisticsManager sharedInstance] flowStatisticsEnable] || ![[TTFlowStatisticsManager sharedInstance] isSupportFreeFlow] || ![[TTFlowStatisticsManager sharedInstance] isOpenFreeFlow]);
}

- (void)showNetworkAlertIfNeeded
{
    if (self.pasterADController.isPlayingImage || self.pasterADController.isPlayingMovie) {
        // 贴片广告时 原视频不进行流量弹窗提醒
//        _trafficView.hidden = YES;
        [self setTrafficTipViewHidden:YES];
        return ;
    }
    
    [self p_showTrafficToastIfNeed];
    if ([self p_shouldShowTrafficView:NO]) {
        [self p_showNetTrafficView:TTVideoTrafficViewStatusDuring];
        return;
    }
    
    //如果正在显示流量提示并且回复到wifi，则继续播放
    if ([self p_shouldUseNewTrafficView] && TTNetworkWifiConnected() && _isShowingConnectAlert) {
        [self p_resumeToPlay];
        return;
    }
    if ([self canShowAlert]) {
        _isPauseOnNetworkChanged = YES;
        hasShowAlertNumber++;
            //统计
        _isPauseOnNetworkChanged = YES;
        [_moviePlayerController moviePause];
        wrapperTrackEventWithCustomKeys(@"network_hint", @"live", self.gModel.groupID, nil, nil);
        [self.tracker sendNetAlertWithLabel:@"net_alert_show"];
        
        TTThemedAlertController *alert = [[TTThemedAlertController alloc] initWithTitle:NSLocalizedString(kAlertTitle, nil) message:nil preferredType:TTThemedAlertControllerTypeAlert];
        [alert addActionWithTitle:NSLocalizedString(kAlertStop, nil) actionType:TTThemedAlertActionTypeNormal actionBlock:^{
            self.stopMovieWhenFinished = YES;
            _isPauseOnNetworkChanged = NO;
            hasShowAlertNumber--;
            if (self.moviePlayerController.isMovieFullScreen) {
                [self exitFullScreen:YES completion:^(BOOL finished) {
                    [[self class] removeAllExploreMovieView];
                }];
            }
            else
            {
                [[self class] removeAllExploreMovieView];
            }

            [self.tracker sendNetAlertWithLabel:@"net_alert_cancel"];
        }];
        [alert addActionWithTitle:NSLocalizedString(kAlertPlay, nil) actionType:TTThemedAlertActionTypeNormal actionBlock:^{
            kAlwaysCloseAlert = YES;
            kHasAlreadyShownAlert = YES;
            _isPauseOnNetworkChanged = NO;
            [self userPlay];
            [self.tracker sendNetAlertWithLabel:@"net_alert_confirm"];
            hasShowAlertNumber--;
        }];
        [alert showFrom:[TTUIResponderHelper topmostViewController] animated:YES];
    }
}

- (void)applicationDidEnterBackground:(NSNotification *)notification
{
    NS_VALID_UNTIL_END_OF_SCOPE ExploreMovieView *strongSelf = self;
    if (![strongSelf p_isShowingTrafficView]) {
        // api请求未完成时退到后台，取消请求，立即发送log
        // 视频在加载中，还未显示第一帧时退到后台，立即发送log
        if ((!strongSelf.letvVideoModel && isEmptyString([self.movieDelegateData ttv_videoLocalURL])) || !_showedOneFrame) {
            if (![self isPlayingPasterADVideo]) {
                [strongSelf showRetryTipView];
            }
            [strongSelf.moviePlayerController.trackManager sendEndTrack];
            [strongSelf.moviePlayerController.trackManager clearAll];
        }
    }
    
    if (!strongSelf.letvVideoModel) {
        [strongSelf.movieManager cancelOperation];
    }
    else if (!_showedOneFrame) {
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(checkLoadingTimeout) object:nil];
        [strongSelf.moviePlayerController moviePlayContentForURL:nil];
    }
    
    [strongSelf stopMovieWhenInBackgroundIfNeeded];
}

- (void)applicationWillResignActive:(NSNotification *)notification
{
    _resignActive = YES;

    if (self.pasterADController) {
        
        [self.pasterADController pauseCurrentAD];
        return ;
    }

    if (self.moviePlayerController.playbackState != TTMoviePlaybackStatePaused && self.moviePlayerController.playbackState != TTMoviePlaybackStateStopped) {
        _isPlayingBeforeResignActive = YES;
    } else {
        _isPlayingBeforeResignActive = NO;
    }
    [self pauseMovie];
}

- (void)applicationDidBecomeActive:(NSNotification *)notification
{
    _resignActive = NO;

    if (self.pasterADController) {
        
        if ([self.movieViewDelegate respondsToSelector:@selector(shouldResumePlayWhenActive)] &&
            [self.movieViewDelegate shouldResumePlayWhenActive]) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self.pasterADController resumeCurrentAD];
            });
        }
        
        return ;
    }
    
    if (_isPlayingBeforeResignActive && !_isPauseOnNetworkChanged) {
        if (![self p_isShowingTrafficView]) {
            if ([self.movieViewDelegate respondsToSelector:@selector(shouldResumePlayWhenActive)]) {
                if ([self.movieViewDelegate shouldResumePlayWhenActive] &&
                    self.moviePlayerController.controlView.tipViewType != ExploreMoviePlayerControlViewTipTypeRetry) {
                    [self resumeMovie];
                }
            }
            else
            {
                [self resumeMovie];
            }
        }
        _isPlayingBeforeResignActive = NO;
    } else {
        BOOL shouldDisableUserInteraction = [self.movieViewDelegate respondsToSelector:@selector(shouldDisableUserInteraction)] && [self.movieViewDelegate shouldDisableUserInteraction];
        if (!_isPlaybackEnded &&  !shouldDisableUserInteraction && ![self.moviePlayerController hasShowTipView]) {
            if (![self p_isShowingTrafficView] && !([self.pasterADController hasPasterView])) {
                [self.moviePlayerController.controlView setToolBarHidden:NO needAutoHide:NO];
            }
        }
    }
}

- (void)userPlay
{
    _hasAlreadyStopped = NO;
    [[TTAPPIdleTime sharedInstance_tt] lockScreen:NO later:NO];
    [_moviePlayerController moviePlay];
    _isPlaybackEnded = NO;
    self.isPlaying = YES;
    self.tracker.isPlaybackEnded = _isPlaybackEnded;
    [[NSNotificationCenter defaultCenter] postNotificationName:kExploreMovieViewStartPlaybackNotification object:self];
    
    [ExploreMovieView setCurrentVideoPlaying:YES];
}

- (void)userPause
{
    [ExploreMovieView setCurrentVideoPlaying:NO];
    [[TTAPPIdleTime sharedInstance_tt] lockScreen:YES later:YES];
    [_moviePlayerController moviePause];
//    _isPlaybackEnded = NO;
    self.isPlaying = NO;
//    self.tracker.isPlaybackEnded = _isPlaybackEnded;
    [self.pasterADController pauseCurrentAD];
    if ([self.pasterADDelegate respondsToSelector:@selector(pasterADWillPause)]) {
        [self.pasterADDelegate pasterADWillPause];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:kExploreMovieViewPauseNotification object:self];
}

#pragma mark -- public
- (void)pauseMovie
{
    
    if (!_userPause) {
        _autoPause = YES;
    }

    if ([self isLiveVideo]) {
        [ExploreMovieView setCurrentVideoPlaying:NO];
        [self pauseLive];
        return;
    }
    if (_moviePlayerController.playbackState != TTMoviePlaybackStatePaused && _moviePlayerController.playbackState != TTMoviePlaybackStateStopped) {
        [self userPause];
        [ExploreMovieView setCurrentVideoPlaying:NO];
    }
}

- (void)pauseLive
{
    if (!_userPause) {
        _autoPause = YES;
    }
    if (_moviePlayerController.playbackState != TTMoviePlaybackStatePaused) {
        [self userPause];
        [ExploreMovieView setCurrentVideoPlaying:NO];
    }
}

- (void)playMovie
{
    if (_viewIsAppear) {
        if (!_autoPause) {
            return;
        }
        _autoPause = NO;
        if (_moviePlayerController.playbackState != TTMoviePlaybackStatePlaying && !_isPauseOnNetworkChanged) {
            if (_moviePlayerController && isEmptyString([self getPlayURL])) {
                [self showRetryTipView];
            }
            else
            {
                [self userPlay];
            }
        }
    }
}

- (void)resumeMovie
{
    if (!_autoPause) {
        return;
    }
    if (self.pasterADController) {
        [self.pasterADController resumeCurrentAD];
    } else {
        if (!_isPlaybackEnded) {
            [self playMovie];
        }
    }
    
    if ([self.pasterADDelegate respondsToSelector:@selector(pasterADWillResume)]) {
        [self.pasterADDelegate pasterADWillResume];
    }
}

- (ExploreMoviePlayerController *)getMoviePlayerController
{
    if ([self.pasterADController getMoviePlayerController]) {
        return [self.pasterADController getMoviePlayerController];
    }
    return _moviePlayerController;
}

- (BOOL)isStoped
{
    return _isStoped;
}

- (void)stopMovie
{
    [[TTAPPIdleTime sharedInstance_tt] lockScreen:YES later:YES];
    NS_VALID_UNTIL_END_OF_SCOPE ExploreMovieView *strongSelf = self;
    // 因为从cell到详情页，只有tracker.type会变成detail，videoModel.type不会变
    [self p_cacheMovieViewProgress];
    [self _stopMovieIndeed];
    
    [ExploreMovieView setCurrentVideoPlaying:NO];
}

- (void)_stopMovieIndeed
{
    NS_VALID_UNTIL_END_OF_SCOPE ExploreMovieView *strongSelf = self;
    _isStoped = YES;
    __weak typeof(self) wself = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        __strong typeof(wself) self = wself;
        if (!self) return;
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(checkLoadingTimeout) object:nil];
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(showNetworkAlertIfNeeded) object:nil];
    });
    
    [strongSelf.movieManager cancelOperation];
    if(_moviePlayerController.playbackState != TTMoviePlaybackStateStopped || _moviePlayerController.loadState == TTMovieLoadStateUnknown) {
        [_moviePlayerController movieStop];
    }
    [strongSelf.pasterADController stopCurrentADVideo];
    if ([strongSelf.pasterADDelegate respondsToSelector:@selector(pasterADWillStop)]) {
        [strongSelf.pasterADDelegate pasterADWillStop];
    }
    //将流量提示窗的字段恢复到初始状态
    [self p_clearNetTrafficView];
    
    [ExploreMovieView setCurrentVideoPlaying:NO];
}

// 列表中播放视频，cell划出屏幕时播放器调用pause，以减少stop引起的卡顿
// 列表滚动停止时调用stop
- (void)stopMovieAfterDelay {
    [self stopMovieAfterDelayWithNotification:YES];
}

- (void)stopMovieAfterDelayWithNotification:(BOOL)hasNotification {

    if (!_isStoppedAfterDelay) {
        _isStoppedAfterDelay = YES;
        NS_VALID_UNTIL_END_OF_SCOPE ExploreMovieView *strongSelf = self;

        [self p_cacheMovieViewProgress];

        [strongSelf.movieManager cancelOperation];
        if (![strongSelf isPlayingFinished]) {
            [strongSelf pauseMovie];
        }

        [_moviePlayerController cancelPlaying];
        [strongSelf.moviePlayerController.trackManager endTrack];

        [NSObject cancelPreviousPerformRequestsWithTarget:strongSelf selector:@selector(checkLoadingTimeout) object:nil];

        // stopMove有时候停止不了正在加载中的视频，所以使用removeAllMovieView
        if (hasNotification) {
            [strongSelf performSelector:@selector(removeTheMovieView) withObject:nil afterDelay:0];
        }
        
        [ExploreMovieView setCurrentVideoPlaying:NO];
    }
    
}

- (void)stopMovieAfterDelayNoNotification
{
    [self stopMovieAfterDelayWithNotification:NO];
}

- (BOOL)shouldPasterADPause
{
    return [self.pasterADController shouldPauseCurrentAd];
}

// 超时检测
- (void)checkLoadingTimeout {
    if (self.moviePlayerController.isPauseWhenNotReady) {
        return;
    }
    if (!_showedOneFrame && !_isStoppedAfterDelay) {
        [self.moviePlayerController.trackManager setError:@"timeout"];
        [self.moviePlayerController.trackManager sendEndTrack];
        [[TTMonitor shareManager] trackService:video_play_request_status status:TTVideoPlayRequestStatusFail extra:nil];
        [self tryLoadNextURL];
    }
}

- (void)p_checkLoadingTimeout {
    if (!_showedOneFrame && !_isStoppedAfterDelay) {
        [self.moviePlayerController.trackManager setError:@"timeout"];
        [self.moviePlayerController.trackManager sendEndTrack];
        [self p_tryLoadNextURL];
    }
}

- (void)p_tryLoadNextURL {
    if (_resignActive) {
        return;
    }
    if (!isEmptyString([self.movieDelegateData ttv_videoLocalURL]) && !_hasPlayLocalFailed) {
        _hasPlayLocalFailed = YES;
    } else {
        ++_playURLIndex;
    }

    [self.moviePlayerController.trackManager clearAll];
    [self _playContent];
}

- (void)tryLoadNextURL {
    if (_resignActive) {
        return;
    }
    if (!isEmptyString([self.movieDelegateData ttv_videoLocalURL]) && !_hasPlayLocalFailed) {
        _hasPlayLocalFailed = YES;
    } else {
        ++_playURLIndex;
    }
    NSString *playURL = [self getPlayURL];
    
    if (playURL) {
        // 重试播放
        [self.moviePlayerController.trackManager autoRetryPlay];
    } else {
        [self.moviePlayerController.trackManager clearAll];
    }
    [self _playContent];
    
}

#pragma mark - TTVideoPasterADDelegate
- (void)videoPasterADViewControllerToggledToFullScreen:(BOOL)fullScreen animationed:(BOOL)animationed completionBlock:(void(^)(BOOL))completionBlock
{
    if (fullScreen) {
        [self enterFullscreen:animationed completion:completionBlock];
    } else {
        [self exitFullScreen:animationed completion:completionBlock];
    }
}

- (ExploreMovieViewType)currentViewType
{
    ExploreMovieViewType type = ExploreMovieViewTypeList;
    if (self.tracker) {
        type = self.tracker.type;
    }
    return type;
}

- (void)replayOriginalVideo {
    
    [self movieControllerPlayButtonClicked:self.moviePlayerController replay:YES];
}

#pragma mark - UIViewControllerTransitioningDelegate
- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    if ([presented isKindOfClass:[TTMovieFullscreenViewController class]]) {
        return [[TTMovieEnterFullscreenAnimatedTransitioning alloc] initWithSmallMovieView:self];
    }
    return nil;
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    if ([dismissed isKindOfClass:[TTMovieFullscreenViewController class]]) {
        return [[TTMovieExitFullscreenAnimatedTransitioning alloc] initWithFullscreenMovieView:self];
    }
    return nil;
}

#pragma mark - TTVideoRotateViewProtocol

- (void)forceStop {
    [self stopMovie];
}

#pragma mark - TTMovieFullscreenViewControllerDelegate

- (void)movieFullscreenVC:(TTMovieFullscreenViewController *)vc willRotateToOrientation:(UIInterfaceOrientation)orientation {
    if (!vc.isBeingDismissed && !vc.isBeingPresented) {
        self.isRotateAnimating = YES;
    }
}

- (void)movieFullscreenVC:(TTMovieFullscreenViewController *)vc didRotateFromOrientation:(UIInterfaceOrientation)orientation {
    if (!vc.isBeingDismissed && !vc.isBeingPresented) {
        self.isRotateAnimating = NO;
        if (self.isPlayingFinished && self.isMovieFullScreen && !self.stayFullScreenWhenFinished && !self.pasterADController) {
            [self exitFullScreen:YES completion:NULL];
        }
    }
}

#pragma mark  TTMovieStoreAction

- (void)stop
{
    [self stopMovie];
}

#pragma mark - TTFullscreenMovieViewProtocol

- (void)forceStoppingMovie {
    [self stopMovie];
}

#pragma mark - getter & setter

- (void)setForbidLayout:(BOOL)forbidLayout {
    _forbidLayout = forbidLayout;
    self.moviePlayerController.controlView.forbidLayout = forbidLayout;
}

#pragma mark - setFullScreen

+ (BOOL)isFullScreen
{
    return isFullScreenInternal__;
}

+ (void)setFullScreen:(BOOL)fullScreen
{
    isFullScreenInternal__ = fullScreen;
    [[NSNotificationCenter defaultCenter] postNotificationName:kExploreMovieViewDidChangeFullScreenNotifictaion object:self];
}

+ (void)setCurrentFullScreenMovieView:(ExploreMovieView *)movieView
{
    NSAssert([NSThread isMainThread], @"must be called in main thread");
    currentFullScreenMovieView_ = movieView;
}

+ (void)removeCurrentFullScreenMovieView:(ExploreMovieView *)movieView
{
    NSAssert([NSThread isMainThread], @"must be called in main thread");
    if (currentFullScreenMovieView_ == movieView) {
        currentFullScreenMovieView_ = nil;
    }
}

+ (ExploreMovieView *)currentFullScreenMovieView
{
    NSAssert([NSThread isMainThread], @"must be called in main thread");
    return currentFullScreenMovieView_;
}

//是否有正在播放
+ (BOOL)currentVideoPlaying
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"ExploreMovieViewCurrentVideoPlaying"];
}

+ (void)setCurrentVideoPlaying:(BOOL)play
{
    [[NSUserDefaults standardUserDefaults] setBool:play forKey:@"ExploreMovieViewCurrentVideoPlaying"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark - UrlStatusHelper

+ (NSString *)tipStringWithURLStatus:(NSString *)URLStatus{
    NSString *status = [NSString  stringWithFormat:@"%@", URLStatus];
    NSDictionary *mappings = @{@"3"      :@"转码中，视频暂时无法播放",
                               @"4"      :@"转码中，视频暂时无法播放",
                               @"20"     :@"转码中，视频暂时无法播放",
                               @"30"     :@"转码中，视频暂时无法播放",
                               @"40"     :@"视频已删除，无法播放",
                               @"1000"   :@"转码中，视频暂时无法播放",
                               @"1002"   :@"视频已删除，无法播放"
                               };
    if ([mappings valueForKey:status]) {
        return [mappings valueForKey:status];
    }
    return nil;
}

- (void)willMoveToSuperview:(UIView *)newSuperview{
    if (self.movieViewDelegate && [self.movieViewDelegate respondsToSelector:@selector(movieViewWillMoveToSuperView:)]) {
        [self.movieViewDelegate movieViewWillMoveToSuperView:newSuperview];
    }
}
@end
