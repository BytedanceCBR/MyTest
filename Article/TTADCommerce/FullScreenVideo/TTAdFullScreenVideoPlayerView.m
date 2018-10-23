//
//  TTAdFullScreenVideoPlayerView.m
//  Article
//
//  Created by matrixzk on 25/07/2017.
//
//

#import "TTAdFullScreenVideoPlayerView.h"
#import "TTAVMoviePlayerController.h"
#import "ExploreMovieManager.h"
#import "UIImageView+WebCache.h"
#import "TTAdFullScreenVideoViewModel.h"
#import "TTIndicatorView.h"
#import <BDWebImage/SDWebImageAdapter.h>

@implementation TTAdFullScreenVideoModel
@end


@interface TTAdFullScreenVideoPlayerView () <TTAVMoviePlayerControllerDelegate, ExploreMovieManagerDelegate>

@property (nonatomic, strong) TTAVMoviePlayerController *moviePlayerController;
@property (nonatomic, strong) UIImageView *coverImgView;
@property (nonatomic, strong) UIActivityIndicatorView *acticityIndicatorView;
@property (nonatomic, strong) ExploreMovieManager *videoInfoFetchManager;

// 用于事件统计
@property (nonatomic, assign) NSInteger playCount;
@property (nonatomic, assign) NSTimeInterval interruptedPlaybackTime;

@end

@implementation TTAdFullScreenVideoPlayerView

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        _coverImgView = [[UIImageView alloc] initWithFrame:self.bounds];
        _coverImgView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _coverImgView.backgroundColor = [UIColor blackColor];
        _coverImgView.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:_coverImgView];
        
        _moviePlayerController = [[TTAVMoviePlayerController alloc] initWithOwnPlayer:NO];
        _moviePlayerController.delegate = self;
        _moviePlayerController.view.frame = self.bounds;
        _moviePlayerController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [(AVPlayerLayer *)_moviePlayerController.view.layer setVideoGravity:AVLayerVideoGravityResize];
        [self addSubview:_moviePlayerController.view];
        _moviePlayerController.view.hidden = YES;
        
        _acticityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        _acticityIndicatorView.center = self.center;
        _acticityIndicatorView.hidesWhenStopped = YES;
        [self addSubview:_acticityIndicatorView];
        
        _videoInfoFetchManager = [ExploreMovieManager new];
        _videoInfoFetchManager.delegate = self;
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _coverImgView.frame = self.bounds;
    _moviePlayerController.view.frame = self.bounds;
     _acticityIndicatorView.center = self.center;
}

- (void)playVideoWithModel:(TTAdFullScreenVideoModel *)videoModel
{
    [_coverImgView sda_setImageWithURL:[NSURL URLWithString:videoModel.coverURL]];
    
    if (isEmptyString(videoModel.videoId)) {
        
        // TODO: show toast
        
        return;
    }
    
    [self.acticityIndicatorView startAnimating];
    
    TTVideoURLRequestInfo *requestInfo = [TTVideoURLRequestInfo new];
    requestInfo.videoID = videoModel.videoId;
    requestInfo.playType = TTVideoPlayTypeNormal;
    [_videoInfoFetchManager fetchURLInfoWithRequestInfo:requestInfo];
    
    
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(handleApplicationDidEnterBackgroundNotification:)
//                                                 name:UIApplicationDidEnterBackgroundNotification
//                                               object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(handleApplicationWillEnterForegroundNotification:)
//                                                 name:UIApplicationWillEnterForegroundNotification
//                                               object:nil];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleApplicationWillResignActiveNotification:)
                                                 name:UIApplicationWillResignActiveNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleApplicationDidBecomeActiveNotification:)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
}

- (void)playVideo
{
    if (self.moviePlayerController.isPlaying) return;
    
    [self.moviePlayerController play];
}

- (void)pauseVideo
{
    if (!self.moviePlayerController.isPlaying) return;
    
    [self.moviePlayerController pause];
}

- (void)stopVideo
{
    [self.moviePlayerController stop];
}

- (void)videoPlayDidInterrupted
{
    NSTimeInterval plabackTime = self.moviePlayerController.duration * self.playCount + self.moviePlayerController.currentPlaybackTime - self.interruptedPlaybackTime;
    [self.eventTracker eventTrackWithLabel:@"detail_break" extraDict:@{@"duration" : @(plabackTime)}];
    [self.eventTracker eventTrack4ThirdPartyMonitorWithType:TTAdFSVideoThirdPartyMonitorTypeBreak];
    
    self.playCount = 0;
    self.interruptedPlaybackTime = self.moviePlayerController.currentPlaybackTime;
}

- (void)videoPlayDidResume
{
    [self.eventTracker eventTrackWithLabel:@"detail_continue"];
}


#pragma mark - TTAVMoviePlayerControllerDelegate

- (void)playerController:(TTAVMoviePlayerController *)playerController playbackDidFinish:(NSDictionary *)reason
{
    switch ([reason[TTMoviePlayerPlaybackDidFinishReasonUserInfoKey] integerValue]) {
        case TTMovieFinishReasonPlaybackEnded: // 播放结束
        {
            if (self.shouldRepeat) {
                [self.moviePlayerController replayComplete:^(BOOL success) {}];
                self.playCount ++;
            }
            
            // event track : 播放完成
            
        } break;
            
        case TTMovieFinishReasonPlaybackError: // 播放失败
        {
            LOGD(@"播放失败 : %@", reason[@"error"]);
            
            // event track : 播放失败
        } break;
            
        default:
            break;
    }
}

- (void)playerControllerIsPrepareToPlay:(TTAVMoviePlayerController *)player
{
    // 开始播放第一帧画面
    self.moviePlayerController.view.hidden = NO;
    [self.acticityIndicatorView stopAnimating];
    
    [self.eventTracker eventTrackWithLabel:@"detail_play"];
    [self.eventTracker eventTrack4ThirdPartyMonitorWithType:TTAdFSVideoThirdPartyMonitorTypePlay];
}


#pragma mark - ExploreMovieManagerDelegate

- (void)manager:(ExploreMovieManager *)manager errorDict:(NSDictionary *)errorDict videoModel:(ExploreVideoModel *)videoModel
{
    if (videoModel) {
        
        NSURL *url = [NSURL URLWithString:[videoModel allURLWithDefinitionType:ExploreVideoDefinitionTypeSD].firstObject];
        
        _moviePlayerController.contentURL = url;
        [_moviePlayerController prepareToPlay];
        [_moviePlayerController play];
        
    } else { // error
        
        [self.acticityIndicatorView stopAnimating];
        
        [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:@"播放失败" indicatorImage:nil autoDismiss:YES dismissHandler:nil];
    }
}


#pragma mark - Notification

- (void)handleApplicationWillResignActiveNotification:(NSNotification *)notification
{
    [self pauseVideo];
    
    [self videoPlayDidInterrupted];
}

- (void)handleApplicationDidBecomeActiveNotification:(NSNotification *)notification
{
    [self playVideo];
    
    [self videoPlayDidResume];
}

//- (void)handleApplicationDidEnterBackgroundNotification:(NSNotification *)notification
//{
//    [self pauseVideo];
//
//    [self videoPlayDidInterrupted];
//}
//
//- (void)handleApplicationWillEnterForegroundNotification:(NSNotification *)notification
//{
//    [self playVideo];
//
//    [self videoPlayDidResume];
//}

@end
