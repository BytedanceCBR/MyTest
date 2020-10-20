//
//  FHUGCShortVideoFullScreenCell.m
//  FHHouseUGC
//
//  Created by liuyu on 2020/10/13.
//

#import "FHUGCShortVideoFullScreenCell.h"
#import "ExploreMovieView.h"
#import "TTVDemandPlayer.h"
#import "Masonry.h"
#import <BDWebImage/SDWebImageAdapter.h>
#import "NSDictionary+BTDAdditions.h"
#import "FHShortVideoTracerUtil.h"
#import "AWEVideoDetailControlOverlayViewController.h"
#import "TTAccountManager.h"

@interface FHUGCShortVideoFullScreenCell()<TTVDemandPlayerDelegate,FHShortPlayVideoDelegate>
@property (nonatomic, strong) TTVVideoPlayerModel *playerModel;
@property (nonatomic, strong) UIImageView *playImage;
@end
@implementation FHUGCShortVideoFullScreenCell
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initView];
        [self initConstains];
    }
    return self;
}

- (void)initView {
    [self playerView];
    UIView *doubleTapMaskView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.contentView.bounds), CGRectGetHeight(self.contentView.bounds) - 50 - 25)];
    doubleTapMaskView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    doubleTapMaskView.backgroundColor = [UIColor clearColor];
    [self.contentView addSubview:doubleTapMaskView];

    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_onPlayerDoubleTap:)];
    doubleTap.numberOfTapsRequired = 2;
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_onPlayerSingleTap:)];
    singleTap.numberOfTapsRequired = 1;
    
    [doubleTapMaskView addGestureRecognizer:doubleTap];
    [doubleTapMaskView addGestureRecognizer:singleTap];

    [singleTap requireGestureRecognizerToFail:doubleTap];
    [self.playImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self);
    }];
}

- (UIImageView *)playImage {
    if (!_playImage) {
        UIImageView *playImage = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 48, 48)];
        playImage.image = [UIImage imageNamed:@"short_video_play"];
        [self.contentView addSubview:playImage];
        playImage.hidden = YES;
        _playImage = playImage;
    }
    return _playImage;
}

- (FHUGCShortVideoView *)playerView {
    if (!_playerView) {
        FHUGCShortVideoView *playerView = [[FHUGCShortVideoView alloc]init];
        playerView.player.delegate = self;
        playerView.delegate = self;
        playerView.player.enableRotate = NO;
        playerView.userInteractionEnabled = NO;
        playerView.player.controlView.miniSlider.hidden = YES;
        [self.contentView addSubview:playerView];
        [playerView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.contentView);
        }];
        _playerView = playerView;
    }
    return _playerView;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat videoAspectRatio = [self.cellModel.video.height floatValue] / [self.cellModel.video.width floatValue];

    CGFloat screenAspectRatio = self.height > self.width ? (self.height / self.width) : (self.width / self.height);

    if(videoAspectRatio >= screenAspectRatio){
        self.playerView.contentMode = UIViewContentModeScaleAspectFill;
    }else{
//            if ([TTDeviceHelper isIPhoneXDevice]) {
//                self.videoPlayView.top = self.tt_safeAreaInsets.top;
//                CGFloat height = CGRectGetHeight(frame) - self.tt_safeAreaInsets.top;
//                self.videoPlayView.height = ceil(CGRectGetWidth(frame) * 16 / 9);
//                if(videoAspectRatio >= (16.0 / 9.0)){
//                    self.videoPlayView.contentMode = UIViewContentModeScaleAspectFill;
//                }else{
//                    self.videoPlayView.contentMode = UIViewContentModeScaleAspectFit;
//                }
//            }else{
            self.playerView.contentMode = UIViewContentModeScaleAspectFit;
//            }
    }
    
}

- (void)initConstains {
    
}

- (void)_onPlayerDoubleTap:(UITapGestureRecognizer *)recognizer
{
    if (!self.cellModel) {
        return;
    }
    if ([self.overlayViewController isKindOfClass:[AWEVideoDetailControlOverlayViewController class]]) {
        if (![TTAccountManager isLogin]) {
            NSMutableDictionary *params = [NSMutableDictionary dictionary];
            NSString *page_type = [FHShortVideoTracerUtil pageType];
            [params setObject:page_type forKey:@"enter_from"];
            [params setObject:@"click_publisher" forKey:@"enter_type"];
            // 登录成功之后不自己Pop，先进行页面跳转逻辑，再pop
            [params setObject:@(YES) forKey:@"need_pop_vc"];
            [TTAccountLoginManager showAlertFLoginVCWithParams:params completeBlock:^(TTAccountAlertCompletionEventType type, NSString * _Nullable phoneNum) {
                if (type == TTAccountAlertCompletionEventTypeDone) {
                    //登录成功 走发送逻辑
                    if ([TTAccountManager isLogin]) {
                        [(AWEVideoDetailControlOverlayViewController *)self.overlayViewController diggShowAnima:YES];
                    }
                }
            }];
            
        }else {
            [(AWEVideoDetailControlOverlayViewController *)self.overlayViewController diggShowAnima:YES];
        }
    }
}

- (void)_onPlayerSingleTap:(UITapGestureRecognizer *)recognizer
{
    if (!self.cellModel) {
        return;
    }
    
    NSInteger rank = [self.cellModel.tracerDic btd_integerValueForKey:@"rank" default:0];
    if (self.isPlaying) {
        [self pause];
         [FHShortVideoTracerUtil videoPlayOrPauseWithName:@"video_pause" eventModel:self.cellModel eventIndex:rank];
          self.playImage.hidden = NO;
    }else {
        [self play];
        self.playImage.hidden = YES;
       [FHShortVideoTracerUtil videoPlayOrPauseWithName:@"video_play" eventModel:self.cellModel eventIndex:rank];
    }
    
}

- (void)updateWithModel:(FHFeedUGCCellModel *)videoDetail
{
         self.cellModel = videoDetail;
        [ExploreMovieView removeAllExploreMovieView];
    //    SAFECALL_MESSAGE(TTVCommodityViewMessage, @selector(ttv_message_removeall_comodityview), ttv_message_removeall_comodityview);

        TTVPlayerSP sp =  TTVPlayerSPToutiao;
    //    TTVFeedItem *feedItem = self.cellEntity.originData;
    //    TTVVideoArticle *article = self.cellEntity.article;
        
        //TTVPlayerModel
        TTVVideoPlayerModel *model = [[TTVVideoPlayerModel alloc] init];
        model.categoryID = self.cellModel.categoryId;
        model.groupID = [NSString stringWithFormat:@"%@",self.cellModel.groupId];
        model.itemID = [NSString stringWithFormat:@"%@",self.cellModel.itemId];
        model.isLoopPlay = YES;
    model.disableFinishUIShow = YES;
    model.disableControlView = YES;
    //    model.aggrType = article.aggrType;
    //    model.adID = article.adId;
    //    model.logExtra = article.logExtra;
        model.videoID = [NSString stringWithFormat:@"%@",self.cellModel.video.videoId];
        model.sp = sp;
        model.enterFrom = @"test";
        model.categoryName = self.cellModel.categoryId;
        model.authorId = self.cellModel.user.userId;
        model.extraDic = self.cellModel.tracerDic;
        
    //    if (feedItem.isVideoSourceUGCVideo) {
    //        model.defaultResolutionType = TTVPlayerResolutionTypeHD;
    //    }
    //    NSDictionary *dic = [feedItem.logPb tt_JSONValue];
    //    if ([dic isKindOfClass:[NSDictionary class]]) {
    //        model.logPb = dic;
    //    }
    //    if (!isEmptyString(article.videoDetailInfo.videoSubjectId)) {
    //        model.videoSubjectID = article.videoDetailInfo.videoSubjectId;
    //    }
    //    if (feedItem.isVideoSourceUGCVideo) {
            model.defaultResolutionType = TTVPlayerResolutionTypeHD;
    //    }
        //只有有admodel才行,号外广告显示正常视频UI
    //    if ([self.cellEntity.originData.adModel isCreativeAd]) {//广告
    //        model.enablePasterAd = NO;
    //    }else{//非广告使用贴片功能
            model.enablePasterAd = YES;
            model.pasterAdFrom = @"feed";
    //    }
    //    BOOL isAutoPlaying = [feedItem couldAutoPlay];
    //    model.isAutoPlaying = isAutoPlaying;
    //    model.showMutedView = isAutoPlaying;
    //    if (isAutoPlaying) {
    //        //广告自动播放时每次从头播放
    //        [[TTVPlayerCacheProgressController sharedInstance] removeCacheForVideoID:article.videoId];
    //        model.mutedWhenStart = YES;
    //        if ([[feedItem rawAdData] tta_boolForKey:@"auto_replay"]) {
    //            model.isLoopPlay = YES;
    //            model.disableFinishUIShow = YES;
    //        }
    //    }
//        model.mutedWhenStart = YES;
        
    //    BOOL isVideoFeedURLEnabled = [[[TTSettingsManager sharedManager] settingForKey:@"video_feed_url" defaultValue:@NO freeze:NO] boolValue];
    //    if (isVideoFeedURLEnabled && [self.cellEntity.originData hasVideoPlayInfoUrl] && [self.cellEntity.originData isVideoUrlValid]) {
    //        model.videoPlayInfo = self.cellEntity.originData.videoPlayInfo;
    //    }
    //    NSInteger isVideoShowOptimizeShare = ttvs_isVideoShowOptimizeShare();
    //    if (isVideoShowOptimizeShare > 0){
    //        if (isEmptyString(model.adID)) {
    //            model.playerShowShareMore = isVideoShowOptimizeShare;
    //        }
    //    }
    _playerModel = model;
    [_playerView resetPlayerModel:_playerModel];
    // 滑动切换视频时，背景图使用首帧图
    if ([self.cellModel.imageList count] > 0) {
        FHFeedContentImageListModel *urlContent = [self.cellModel.imageList firstObject];
        NSURL *url = [NSURL URLWithString:urlContent.url?:@""];
        UIImageView *logoImage = [[UIImageView alloc]init];
        logoImage.contentMode = UIViewContentModeScaleAspectFit;
        [logoImage sda_setImageWithURL:url placeholderImage:[UIImage imageNamed:@"img_video_loading"] completed:nil];
        [self.playerView.player setLogoImageView:logoImage];
    }
}

- (void)readyToPlay {
        [self.playerView.player readyToPlay];
    //    if (isAutoPlaying && self.cellEntity.article.adId.longLongValue > 0) {
    //        self.movieView.player.banLoading = YES;
    //        self.movieView.player.muted = [self.cellEntity.originData couldAutoPlay];
    //    }
//        self.playerView.player.muted = YES;
    //    [self addUrlTrackerOnPlayer:playVideo];
        [self settingMovieView:self.playerView];
}

- (void)reset {
    [self.playerView.player reset];
}

- (void)pause {
    [self.playerView.player pause];
}

- (void)stop {
    [self.playerView.player stopWithFinishedBlock:^{
    }];
}

- (void)play
{

    [self.playerView.player play];
    
    self.overlayViewController.playerStateStore = self.playerView.player.playerStateStore;
    self.playerView.player.controlView.miniSlider.hidden = YES;
//    if(!self.cellEntity.hideTitleAndWatchCount){
//        [playVideo.player setVideoTitle:feedItem.title];
//        [playVideo.player setVideoWatchCount:article.videoDetailInfo.videoWatchCount playText:@"次播放"];
//    }
//    self.logo.userInteractionEnabled = ![feedItem couldAutoPlay];
//    if (![TTDeviceHelper isPadDevice]) {
//        playVideo.player.commodityFloatView.animationToView = self.cellEntity.moreButton;
//        playVideo.player.commodityFloatView.animationSuperView = self.cellEntity.cell;
//        [playVideo.player.commodityFloatView setCommoditys:self.cellEntity.originData.commoditys];
//        playVideo.player.commodityButton.delegate = self;
//    }

//    [self ttv_configADFinishedView:playVideo.player.tipCreator.tipFinishedView];
//
//    [[AKAwardCoinVideoMonitorManager shareInstance] monitorVideoWith:playVideo];
}

- (void)settingMovieView:(FHUGCShortVideoView *)movieView
{
    movieView.player.isInDetail = NO;
    movieView.player.showTitleInNonFullscreen = YES;
}

- (void)setMovieView:(FHUGCShortVideoView *)movieView
{
    if (([movieView isKindOfClass:[FHUGCShortVideoView class]] || !movieView)) {
        _playerView = movieView;
        _playerView.player.delegate = self;
        _playerView.delegate = self;
//        _movieView.player.doubleTap666Delegate = self.doubleTap666Delegate;
        [self settingMovieView:movieView];
    }
}

#pragma mark TTVDemandPlayerDelegate

- (void)playerLoadingState:(TTVPlayerLoadState)state
{
    
}

- (void)playerPlaybackState:(TTVVideoPlaybackState)state
{
    if ([self.delegate respondsToSelector:@selector(playerPlaybackState:)]) {
        [self.delegate playerPlaybackState:state];
    }
    if (state == TTVVideoPlaybackStateFinished ||
        state == TTVVideoPlaybackStateError) {
//        self.logo.userInteractionEnabled = YES;
    }
    if (state == TTVVideoPlaybackStateFinished) {
        [self moviePlayFinishedAction];
    }
    if (state == TTVVideoPlaybackStatePlaying) {
        if (self.videoDidStartPlay) {
            self.videoDidStartPlay();
        }
    }
}

- (void)playerCurrentPlayBackTimeChange:(NSTimeInterval)currentPlayBackTime duration:(NSTimeInterval)duration {
    if ([self.delegate respondsToSelector:@selector(playerCurrentPlayBackTimeChange:duration:)]) {
        [self.delegate playerCurrentPlayBackTimeChange:currentPlayBackTime duration:duration];
    }
}

//- (void)playerOrientationState:(BOOL)isFullScreen {
//    if(self.cellEntity.hideTitleAndWatchCount){
//        if(isFullScreen){
//            [self.movieView.player setVideoTitle:self.cellEntity.originData.title];
//        }else{
//            [self.movieView.player setVideoTitle:nil];
//        }
//    }
//}

- (void)actionChangeCallbackWithAction:(TTVPlayerStateAction *)action
{
    if (![action isKindOfClass:[TTVPlayerStateAction class]]) {
        return;
    }
    switch (action.actionType) {
        case TTVPlayerEventTypePlayerPause:{
//            [self pause];
        }
        case TTVPlayerEventTypePlayerResume:{
//            [self play];
        }
            break;
        default:
            break;
    }
}

- (CGRect)ttv_movieViewFrameAfterExitFullscreen {
//    return self.logo.bounds;
    return CGRectZero;
}

- (void)moviePlayFinishedAction{
    if (self.playerView.playerModel.isLoopPlay) {
        [self.playerView.player setLogoImageViewHidden:YES];
        [self.playerView.player play];
//        self.logo.userInteractionEnabled = NO;
    }
    if ([self.delegate respondsToSelector:@selector(ttv_moviePlayFinished)]) {
        [self.delegate ttv_moviePlayFinished];
    }
}

- (BOOL)isPlaying
{
    if (self.playerView && self.playerView.player && self.playerView.player.context.playbackState == TTVVideoPlaybackStatePlaying) {
        return YES;
    }
    return NO;
}
@end
