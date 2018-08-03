//
//  AWEVideoPlayView.m
//  Pods
//
//  Created by 01 on 17/5/3.
//
//

//
//  HTSVideoPlayView.m
//  LiveStreaming
//
//  Created by SongLi.02 on 10/19/16.
//  Copyright © 2016 Bytedance. All rights reserved.
//

#import "AWEVideoPlayView.h"
// View
#import "SSThemed.h"
// Model
#import "TTShortVideoModel.h"
// Manager Service
#import "TTFlowStatisticsManager+Helper.h"
// Track
#import "HTSVideoTimingTracker.h"
// Util
#import <Masonry/Masonry.h>
#import "HTSVideoPlayToast.h"
#import "HTSVideoPlayColor.h"
#import "UIImageView+WebCache.h"
#import "AWEVideoConstants.h"
#import "BTDMacros.h"
#import "NetworkUtilities.h"
#import "TTMonitor+Timing.h"
#import "YYWebImage.h"

// IES Video Play
#import "IESVideoPlayer.h"
#import "IESVideoPlayerProtocol.h"
#import "IESVideoCacheProtocol.h"
#import "IESSysPlayerWrapper.h"
#import "AWEVideoDetailFirstFrameConfig.h"
#import "TTHTSVideoConfiguration.h"
#import "TTImageInfosModel.h"
#import "TTNetworkHelper.h"
#import "YYCache.h"
#import "TSVMonitorManager.h"
#import <BDWebImage/SDWebImageAdapter.h>

static NSString * const VideoPlayTimeKey =  @"video_play_time";
static NSString * const VideoStallTimeKey =  @"video_stall_time";
static NSString * const VideoPrepareTimeTechKey = @"prepare_time_tech";

@interface AWEVideoPlayView () <IESVideoPlayerDelegate>

// 详情页数据
@property (nonatomic, strong) TTShortVideoModel *model;
// 视频播放器
@property (nonatomic, strong) id<IESVideoPlayerProtocol> playerController;
// UI交互组件
@property (nonatomic, strong) SSThemedImageView *backgroundView;
@property (nonatomic, strong) UIImageView *loadingIndicatorView;
@property (nonatomic, strong) UILabel *flowStatisticsLabel;
// 辅助数据结构
@property (nonatomic, assign) BOOL isPlaying;
@property (nonatomic, assign) BOOL isVideoDeleted;
@property (nonatomic, assign) BOOL isFirstInit;
@property (nonatomic, strong) HTSVideoTimingTracker *timingTracker;

// observers
@property (nonatomic, strong) NSMutableArray *observerArray;

@property (nonatomic, assign) NSInteger videoStalledCount;
@property (nonatomic, assign) BOOL usingFirstFrameCover;
@property (nonatomic, readwrite, assign) NSTimeInterval videoDuration;

@end


@implementation AWEVideoPlayView

- (void)dealloc
{
    [self _removeObservers];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor blackColor];
        self.clipsToBounds = YES;
        
        _isPlaying = NO;
        _isVideoDeleted = NO;
        _observerArray = [NSMutableArray array];
        _isFirstInit = YES;
        _autoAdjustViewFrame = YES;
        _videoStalledCount = 0;
        _timingTracker = [[HTSVideoTimingTracker alloc] init];
        _videoDuration = 0;
        
        [self _loadView];
        [self _addObservers];
    }
    return self;
}

- (void)setContentMode:(UIViewContentMode)contentMode
{
    [super setContentMode:contentMode];

    if (self.contentMode == UIViewContentModeScaleAspectFit) {
        self.playerController.scalingMode = IESVideoScaleModeAspectFit;
    } else if (self.contentMode == UIViewContentModeScaleAspectFill) {
        self.playerController.scalingMode = IESVideoScaleModeAspectFill;
    }
    self.backgroundView.contentMode = self.contentMode;
}

#pragma mark - Public Methods

- (void)updateWithModel:(TTShortVideoModel *)model usingFirstFrameCover:(BOOL)usingFirstFrameCover
{
    _backgroundView.hidden = NO;
    //避免复用时首帧时长统计不对
    [TTMonitor cancelTimingForKey:[NSString stringWithFormat:@"%p-FirstFrame", self]];
    [TTMonitor cancelTimingForKey:[NSString stringWithFormat:@"%p-FirstFrame-Display", self]];
    [self.timingTracker endTimingForKey:VideoPrepareTimeTechKey];
    
    BOOL widthChanged = self.model.video.width != model.video.width;
    BOOL heightChanged = self.model.video.height != model.video.height;

    self.model = model;
    self.usingFirstFrameCover = usingFirstFrameCover;

    if (self.usingFirstFrameCover && [AWEVideoDetailFirstFrameConfig firstFrameEnabled]) {
        // 滑动切换视频时，背景图使用首帧图
        if ([model.firstFrameImageModel.urlWithHeader count] > 0) {
            NSURL *url = [NSURL URLWithString:[model.firstFrameImageModel.urlWithHeader firstObject][@"url"] ?:@""];
            [self.backgroundView sda_setImageWithURL:url placeholderImage:[UIImage imageNamed:@"img_video_loading"] completed:nil];
        }
    } else {
        NSURL *URL = [NSURL URLWithString:[model.animatedImageModel.urlWithHeader firstObject][@"url"] ?:@""];
        NSString *cacheKey = [[YYWebImageManager sharedManager] cacheKeyForURL:URL];
        if ([[[YYWebImageManager sharedManager] cache] containsImageForKey:cacheKey]) {
            [self.backgroundView yy_setImageWithURL:URL placeholder:nil];
        } else if (model.detailCoverImageModel.urlWithHeader) {
            NSURL *stillImageURL = [NSURL URLWithString:[model.detailCoverImageModel.urlWithHeader firstObject][@"url"] ?:@""];
            NSString *stillImageCacheKey = [[YYWebImageManager sharedManager] cacheKeyForURL:stillImageURL];
            if ([[[YYWebImageManager sharedManager] cache] containsImageForKey:stillImageCacheKey]) {
                [self.backgroundView yy_setImageWithURL:stillImageURL placeholder:nil];
            } else {
                [self.backgroundView sda_setImageWithURL:stillImageURL placeholderImage:[UIImage imageNamed:@"img_video_loading"] completed:nil];
            }
        }
    }

    self.isVideoDeleted = self.model.isDelete;

    if ((widthChanged || heightChanged) && self.autoAdjustViewFrame) {
        [self _updateFrame];
    }

    self.playerController.useCache = YES;
    self.videoStalledCount = 0;
    self.videoDuration = 0;
}

- (void)prepareToPlay
{
    if (self.isPlaying) {
        return;
    }
    
    [self resetVideoPlayAddress];
        
    if (IESVideoPlayerTypeSpecify == IESVideoPlayerTypeSystem) {
        if (![self.timingTracker hasTimingForKey:VideoPrepareTimeTechKey]) {
            [self.timingTracker startTimingForKey:VideoPrepareTimeTechKey ignoreBackgroundTime:NO];
        }
    }
}

- (void)resetVideoPlayAddress
{
    NSString *videoLocalPlayAddr = self.model.videoLocalPlayAddr;
    if (!isEmptyString(videoLocalPlayAddr)) {
         [self.playerController resetLocalVideoURLPath:videoLocalPlayAddr];
    } else {
        if (self.model.video.playAddr.uri.length > 0 || self.model.video.playAddr.urlList.count > 0) {
            [self.playerController resetVideoID:self.model.video.playAddr.uri andPlayURLs:self.model.video.playAddr.urlList];
        }
    }
    // 如果不prepareToPlay，playerController不会发开始播放的Notification，会导致菊花不消失、首帧端监控不结束
    [self.playerController prepareToPlay];
}

- (void)play
{
    if ([UIApplication sharedApplication].applicationState != UIApplicationStateActive) {
        return;
    }
    
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    
    if (!self.isPlaying) {
        if (self.model) {
            self.isPlaying = YES;
            [self _doPlay];
        } else {
            [HTSVideoPlayToast show:(self.isVideoDeleted ? @"视频已删除，播放失败" : @"视频信息加载失败")];
            
            if (!self.isVideoDeleted) {
                [[TSVMonitorManager sharedManager] trackVideoPlayStatus:TSVMonitorVideoPlayFailed model:self.model error:[[NSError alloc] initWithDomain:@"TSVVideoPlayFailed" code:1 userInfo:@{NSLocalizedDescriptionKey : @"视频信息加载失败"}]];
            }
        }
    }
}

- (void)pause
{
    if (self.isPlaying) {
        self.isPlaying = NO;
        [self _showLoadingIndicator:NO];
        [self.playerController pause];
    }
}

- (void)stop
{
    [self _doStop];
}

#pragma mark - Private Methods

- (void)_addObservers
{
    @weakify(self)
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    
    [self.observerArray addObject:[notificationCenter addObserverForName:UIApplicationWillTerminateNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
        @strongify(self);
        // 播放时长统计
        static NSString *playTimeKey = VideoPlayTimeKey;
        NSTimeInterval playDuration = [self.timingTracker endTimingForKey:playTimeKey];
        if (playDuration != NSNotFound && [self.delegate respondsToSelector:@selector(playView:didStopPlayWithModel:duration:)]) {
            [self.delegate playView:self didStopPlayWithModel:self.model duration:playDuration];
        }
        
        // 卡顿统计
        if (playDuration != 0 && playDuration != NSNotFound) {
            NSTimeInterval duration = [self.timingTracker endTimingForKey:VideoStallTimeKey];
            if (duration == NSNotFound) {
                duration = 0;
            }
            CGFloat stallTimeRate = duration / playDuration;
            CGFloat stallCountRate = self.videoStalledCount * 1000.0 / playDuration;
            NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:5];
            [dict setValue:@"video_block" forKey:@"service"];
            [dict setValue:@(stallTimeRate) forKey:@"duration_rate"];
            [dict setValue:@(stallCountRate) forKey:@"count_rate"];
            [dict setValue:@(duration) forKey:@"block_duration"];
            [dict setValue:@(self.videoStalledCount) forKey:@"block_count"];
            [dict setValue:self.model.itemID.description forKey:@"mediaId"];
            [dict setValue:self.model.video.playAddr.uri forKey:@"videoUri"];
            [dict setValue:@(IESVideoPlayerTypeSpecify) forKey:@"playerType"];
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [dict setValue:[TTNetworkHelper connectMethodName] forKey:@"app_network_type"];
                [[TTMonitor shareManager] trackService:@"short_video_media_play_log" attributes:dict];
            });
        }
    }]];
}

- (void)_removeObservers
{
    for (id observer in self.observerArray) {
        [[NSNotificationCenter defaultCenter] removeObserver:observer];
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)_doPlay
{
    //不隐藏的话做优化的时候会闪
    self.playerController.view.hidden = NO;

    //开始记录首帧时长
    [TTMonitor startTimingForKey:[NSString stringWithFormat:@"%p-FirstFrame", self]];
    [TTMonitor startTimingForKey:[NSString stringWithFormat:@"%p-FirstFrame-Display", self]];
    
    [self performSelector:@selector(_showLoadingIndicator) withObject:nil afterDelay:1.0];
    
    if (self.playerController.actionState == IESVideoActionStateInit) {
        [self resetVideoPlayAddress];
    }
    
    [self.playerController play];
    self.isPlaying = YES;
}

- (void)_doStop
{
    self.playerController.view.hidden = YES;

    // 更改状态
    self.isPlaying = NO;
    [self _showLoadingIndicator:NO];
    
    // 关闭缓存
    [self.playerController stop];
    
    // 结束播放时清理首帧时长
    [TTMonitor cancelTimingForKey:[NSString stringWithFormat:@"%p-FirstFrame", self]];
    [TTMonitor cancelTimingForKey:[NSString stringWithFormat:@"%p-FirstFrame-Display", self]];
}

- (void)_didStartDisplayFrames
{
    // 去掉菊花
    [self _showLoadingIndicator:NO];
    
    // 统计首帧时间，readyForDisplay变为yes时记结束 比short_video_prepare_time晚
    [TTMonitor endTimingForKey:[NSString stringWithFormat:@"%p-FirstFrame-Display", self] serviceName:@"short_video_prepare_time_display"];
   
    [[TSVMonitorManager sharedManager] trackVideoPlayStatus:TSVMonitorVideoPlaySucceed model:self.model error:nil];
}

- (void)_didPlayFailedWithError:(NSError *)error
{
    // 清空当前视频缓存
    NSString *urlStr = [self.playerController.videoPlayURLs firstObject];
    if (!isEmptyString(urlStr) && !isEmptyString(self.model.video.playAddr.uri)) {
        id<IESVideoCacheProtocol> AWEVideoCache = [IESVideoCache cacheWithType:IESVideoPlayerTypeSpecify];
        [AWEVideoCache clearCacheForVideoID:self.model.video.playAddr.uri URLString:urlStr];
    }
    
    if (self.playerController.useCache) { // 尝试无缓存播放
        self.playerController.useCache = NO;
        [self resetVideoPlayAddress];
        if (self.isPlaying) {
            [self.playerController play];
        }
    } else { // 无缓存播放失败
        // 更改状态
        self.isPlaying = NO;
        [self _showLoadingIndicator:NO];
        [HTSVideoPlayToast show:@"播放失败"];
        
        // 停止并关闭缓存
        [self.playerController stop];
        
        [TTMonitor cancelTimingForKey:[NSString stringWithFormat:@"%p-FirstFrame", self]];
        [TTMonitor cancelTimingForKey:[NSString stringWithFormat:@"%p-FirstFrame-Display", self]];
        
        // 统计播放失败率（失败）
        [[TSVMonitorManager sharedManager] trackVideoPlayStatus:TSVMonitorVideoPlayFailed model:self.model error:error];
    }
}


#pragma mark - Actions

- (void)_onPlayerDoubleTap:(UITapGestureRecognizer *)recognizer
{
    if ([self.delegate respondsToSelector:@selector(playView:didDoubleTapWithModel:)]) {
        [self.delegate playView:self didDoubleTapWithModel:self.model];
    }
    
    // digg动画
    CGPoint location = [recognizer locationInView:recognizer.view];
    [self _showDiggAnimation:location];
}

# pragma mark - UI

- (void)_loadView
{
    // 背景图层
    _backgroundView = [[SSThemedImageView alloc] initWithFrame:self.bounds];
    _backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    _backgroundView.backgroundColor = [UIColor blackColor];
    _backgroundView.enableNightCover = NO;

    // 播放视图层
    _playerController = [IESVideoPlayer playerWithType:IESVideoPlayerTypeSpecify];
    _playerController.scalingMode = IESVideoScaleModeAspectFit;
    _playerController.view.backgroundColor = [UIColor clearColor];
    _playerController.view.frame = self.bounds;
    _playerController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    _playerController.enhancementType = IESVideoEnhancementTypeNone;
    _playerController.repeated = YES;
    _playerController.useCache = YES;
    _playerController.ignoreAudioInterruption = YES;
    _playerController.deleagte = self;
    [self addSubview:_playerController.view];
    [self addSubview:_backgroundView];

    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        //老版本小视频缓存 升级时需要清理
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
            NSString *aweVideoCachePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"AWEVideoCache"];
            YYCache *aweVideoCache = [YYCache cacheWithPath:aweVideoCachePath];
            [aweVideoCache removeAllObjects];
        });
    });
}

- (void)_updateFrame
{
    if (self.model.video.width > 0) {
        CGFloat height = self.model.video.height / self.model.video.width * CGRectGetWidth(self.frame);
        CGFloat dHeight = CGRectGetHeight(self.superview.bounds) - height;
        if (dHeight > 0 && dHeight < 5) { // 兼容视频与屏幕宽高比差一点点引起的底部白条问题
            height += dHeight;
        }
        if (!self.isFirstInit && fabs(CGRectGetHeight(self.bounds) - height) < 0.1) {
            return;
        }
        self.isFirstInit = NO;
        
        self.frame = CGRectMake(CGRectGetMinX(self.frame), CGRectGetMinY(self.frame), CGRectGetWidth(self.frame), height);
        self.playerController.view.frame = self.bounds;
        
        if ([self.delegate respondsToSelector:@selector(playView:didUpdateFrame:)]) {
            [self.delegate playView:self didUpdateFrame:self.frame];
        }
    }
}

- (void)_showLoadingIndicator
{
    [self _showLoadingIndicator:YES];
}

- (void)_showLoadingIndicator:(BOOL)show
{
    if (!self.loadingIndicatorView) {
        self.loadingIndicatorView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 60, 60)];
        self.loadingIndicatorView.image = [UIImage imageNamed:@"hts_video_loading"];
        [self addSubview:self.loadingIndicatorView];
        [self.loadingIndicatorView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self);
        }];
    }
    if (!self.flowStatisticsLabel) {
        self.flowStatisticsLabel = [[UILabel alloc] init];
        self.flowStatisticsLabel.textColor = [UIColor colorWithHexString:@"ffffff"];
        self.flowStatisticsLabel.font = [UIFont systemFontOfSize:12];
        self.flowStatisticsLabel.text = @"免流播放中";
        [self.flowStatisticsLabel sizeToFit];
        [self addSubview:self.flowStatisticsLabel];
        [self.flowStatisticsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self);
            make.top.mas_equalTo(self.loadingIndicatorView.mas_bottom).offset(4);
        }];
    }
    
    if (show) {
        self.loadingIndicatorView.hidden = NO;
        
        if (!TTNetworkWifiConnected() && TTNetworkConnected() && [[TTFlowStatisticsManager sharedInstance] hts_isFreeFlow]){
            self.flowStatisticsLabel.hidden = NO;
        }else{
            self.flowStatisticsLabel.hidden = YES;
        }
        
        
        [self.loadingIndicatorView.layer removeAllAnimations];
        CABasicAnimation *rotateAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
        rotateAnimation.duration = 1.0f;
        rotateAnimation.repeatCount = CGFLOAT_MAX;
        rotateAnimation.toValue = @(M_PI * 2);
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.loadingIndicatorView.layer addAnimation:rotateAnimation forKey:@"rotateAnimation"];
        });
    }
    else{
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(_showLoadingIndicator) object:nil];
        self.loadingIndicatorView.hidden = YES;
        self.flowStatisticsLabel.hidden = YES;
        [self.loadingIndicatorView.layer removeAllAnimations];
    }
}

# pragma mark - Digg Animation

- (CGRect)_scaleRect:(CGRect)rect scale:(CGFloat)scale
{
    CGFloat addedWidth = rect.size.width * (scale - 1);
    CGFloat addedHeight = rect.size.height * (scale - 1);
    return CGRectMake(rect.origin.x - addedWidth * 0.5,
                      rect.origin.y - addedHeight * 0.5,
                      rect.size.width + addedWidth,
                      rect.size.height + addedHeight);
}

- (void)_showDiggAnimation:(CGPoint)origin
{
    UIImageView *view = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"hts_vp_big_like"]];
    view.contentMode = UIViewContentModeScaleAspectFill;
    view.frame = CGRectMake(0, 0, view.image.size.width, view.image.size.height);
    view.center = origin;
    [self addSubview:view];
    
    CGRect originRect = view.frame;
    view.frame = [self _scaleRect:originRect scale:1.8];
    CGFloat randomRotation = (NSInteger)(arc4random() % 61) - 30;
    view.layer.transform = CATransform3DMakeRotation(randomRotation / 180.0 * M_PI, 0.0, 0.0, 1.0);
    
    @weakify(self)
    [UIView animateWithDuration:0.3 delay:0 usingSpringWithDamping:0.5 initialSpringVelocity:5 options:UIViewAnimationOptionCurveEaseIn animations:^{
        view.frame = originRect;
    } completion:^(BOOL finished) {
        @strongify(self)
        if (!self) {
            return;
        }
        [UIView animateWithDuration:0.5 delay:0.2 options:UIViewAnimationOptionCurveEaseOut animations:^{
            @strongify(self)
            const CGFloat scaleValue = ((CGFloat)(arc4random() % 100)) / 100 + 2;
            view.frame = [self _scaleRect:originRect scale:scaleValue];
            view.center = CGPointMake(view.center.x, view.center.y - 50);
            view.alpha = 0;
        } completion:^(BOOL finished) {
            [view removeFromSuperview];
        }];
    }];
}

#pragma mark - IESVideoPlayerDelegate
/**
 *  代码的搬运工🙂
 */

/**
 *  播放器将要开始下一个播放循环
 */
- (void)playerWillLoopPlaying:(id<IESVideoPlayerProtocol>)player
{
    if ([self.delegate respondsToSelector:@selector(playView:didPlayNextLoopWithModel:)]) {
        [self.delegate playView:self didPlayNextLoopWithModel:self.model];
    }
}

/**
 *  无论手动停止还是自动停止，从IESVideoPlaybackActionStart到IESVideoPlaybackActionStop是一个完整的播放周期。
 *  stop之后播放器可能被重置，所有操作和回调会等同于新建一个播放器。
 *  ⚠️IESVideoPlaybackActionStart事件用作首帧时间(prepare_time)的统一口径⚠️
 */
- (void)player:(id<IESVideoPlayerProtocol>)player didChangePlaybackStateWithAction:(IESVideoPlaybackAction)playbackAction
{
    switch (playbackAction) {
        case IESVideoPlaybackActionStart:
        {
            self.videoDuration = [self.playerController videoDuration];
            
            self.backgroundView.hidden = YES;
            
            [self.timingTracker startTimingForKey:VideoPlayTimeKey ignoreBackgroundTime:YES];
            
            [self _didStartDisplayFrames];
            
            if ([self.delegate respondsToSelector:@selector(playView:didStartPlayWithModel:)]) {
                [self.delegate playView:self didStartPlayWithModel:self.model];
            }
        }
            break;
        case IESVideoPlaybackActionStop:
        {
            // 播放时长统计
            NSTimeInterval playDuration = [self.timingTracker endTimingForKey:VideoPlayTimeKey];
            if (playDuration != NSNotFound && [self.delegate respondsToSelector:@selector(playView:didStopPlayWithModel:duration:)]) {
                [self.delegate playView:self didStopPlayWithModel:self.model duration:playDuration];
            }
            
            // 卡顿统计
            if (playDuration != 0 && playDuration != NSNotFound) {
                NSTimeInterval duration = [self.timingTracker endTimingForKey:VideoStallTimeKey];
                if (duration == NSNotFound) {
                    duration = 0;
                }
                CGFloat stallTimeRate = duration / playDuration;
                CGFloat stallCountRate = self.videoStalledCount * 1000.0 / playDuration;
                NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:5];
                [dict setValue:@"video_block" forKey:@"service"];
                [dict setValue:@(stallTimeRate) forKey:@"duration_rate"];
                [dict setValue:@(stallCountRate) forKey:@"count_rate"];
                [dict setValue:@(duration) forKey:@"block_duration"];
                [dict setValue:@(self.videoStalledCount) forKey:@"block_count"];
                [dict setValue:self.model.itemID.description forKey:@"mediaId"];
                [dict setValue:self.model.video.playAddr.uri forKey:@"videoUri"];
                [dict setValue:@(IESVideoPlayerTypeSpecify) forKey:@"playerType"];
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    [dict setValue:[TTNetworkHelper connectMethodName] forKey:@"app_network_type"];
                    [[TTMonitor shareManager] trackService:@"short_video_media_play_log" attributes:dict];
                });
            }
        }
            break;
        case IESVideoPlaybackActionPause:
        {
            NSTimeInterval playDuration = [self.timingTracker pauseTimingForKey:VideoPlayTimeKey];
            if (playDuration != NSNotFound && [self.delegate respondsToSelector:@selector(playView:didPausePlayWithModel:duration:)]) {
                [self.delegate playView:self didPausePlayWithModel:self.model duration:playDuration];
            }
        }
            break;
        case IESVideoPlaybackActionResume:
        {
        
            NSTimeInterval playDuration = [self.timingTracker resumeTimingForKey:VideoPlayTimeKey];
            if (playDuration != NSNotFound && [self.delegate respondsToSelector:@selector(playView:didResumePlayWithModel:duration:)]) {
                [self.delegate playView:self didResumePlayWithModel:self.model duration:playDuration];
            }
            [self _showLoadingIndicator:NO];
            //从暂停状态返回时，清理首帧时长
            [TTMonitor cancelTimingForKey:[NSString stringWithFormat:@"%p-FirstFrame", self]];
            [TTMonitor cancelTimingForKey:[NSString stringWithFormat:@"%p-FirstFrame-Display", self]];
        }
            break;
        default:
            break;
    }
    
    
}

/**
 *  播放失败
 */
- (void)player:(id<IESVideoPlayerProtocol>)player playbackFailedWithError:(NSError *)error
{
    [self _didPlayFailedWithError:error];
}

/**
 *  已准备好显示，用作首帧时间(prepare_time_display)的统一口径
 *  实际含义：(自研)自研官方首帧回调，实际测试中与开始播放基本一致，时间差<10ms
 (系统)系统播放器layer的readyForDisplay事件回调，可能已显示首帧但未开始播放
 */
- (void)playerDidReadyForDisplay:(id<IESVideoPlayerProtocol>)player
{
    [TTMonitor endTimingForKey:[NSString stringWithFormat:@"%p-FirstFrame", self] serviceName:@"short_video_prepare_time"];
    
    if (IESVideoPlayerTypeSpecify == IESVideoPlayerTypeSystem) {
        NSTimeInterval duration = [self.timingTracker endTimingForKey:VideoPrepareTimeTechKey];
        if (duration != NSNotFound) {
            [[TTMonitor shareManager] trackService:@"short_video_prepare_time_tech" value:@(duration) extra:nil];
        }
    }
}

/**
 *  播放器卡顿状态变化，用作卡顿统计的统一口径。
 *  由播放到卡顿、由卡顿到播放会调用
 */
- (void)player:(id<IESVideoPlayerProtocol>)player didChangeStallState:(IESVideoStallAction)stallState
{
    switch (stallState) {
        case IESVideoStallActionBegin:
        {
            if ([self.timingTracker hasTimingForKey:VideoStallTimeKey]) {
                [self.timingTracker resumeTimingForKey:VideoStallTimeKey];
            } else {
                [self.timingTracker startTimingForKey:VideoStallTimeKey ignoreBackgroundTime:YES];
            }
            self.videoStalledCount++;
        }
            break;
        case IESVideoStallActionEnd:
        {
            [self.timingTracker pauseTimingForKey:VideoStallTimeKey];
        }
            break;
        default:
            break;
    }
}

@end
