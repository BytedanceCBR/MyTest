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

@interface FHUGCShortVideoFullScreenCell()<TTVDemandPlayerDelegate>
@property (nonatomic, strong) TTVPlayerModel *playerModel;
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
        [self.playerView.player setScaleMode:TTVPlayerScalingModeAspectFill];
    }else{
        [self.playerView.player setScaleMode:TTVPlayerScalingModeAspectFit];
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
    TTVPlayerSP sp =  TTVPlayerSPToutiao;
    TTVPlayerModel *model = [[TTVPlayerModel alloc] init];
    model.enableCache = NO;
    model.categoryID = self.cellModel.categoryId;
    model.groupID = [NSString stringWithFormat:@"%@",self.cellModel.groupId];
    model.itemID = [NSString stringWithFormat:@"%@",self.cellModel.itemId];
    model.isLoopPlay = YES;
    model.disableFinishUIShow = YES;
    model.disableControlView = YES;
    model.videoID = [NSString stringWithFormat:@"%@",self.cellModel.video.videoId];
    model.sp = sp;
    model.enterFrom = @"test";
    model.categoryName = self.cellModel.categoryId;
    model.authorId = self.cellModel.user.userId;
    model.extraDic = self.cellModel.tracerDic;
    model.defaultResolutionType = TTVPlayerResolutionTypeFullHD;
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
        [self.playerView readyToPlay];
}

- (void)reset {
    [self.playerView reset];
    self.playImage.hidden = YES;
}

- (void)pause {
    [self.playerView pause];
}

- (void)stop {
    [self.playerView stop];
}

- (void)play
{
    [self.playerView play];
    self.overlayViewController.playerStateStore = self.playerView.player.playerStateStore;
}

- (void)cellWillDisplay {
    
}

- (void)resetPlayerModel {
    TTVPlayerModel *model = [[TTVPlayerModel alloc] init];
    [self.playerView resetPlayerModel:model];
}
#pragma mark TTVDemandPlayerDelegate

- (void)willMoveToSuperview:(UIView *)newSuperview
{
    [super willMoveToSuperview:newSuperview];

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
        self.playImage.hidden = YES;
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


- (void)moviePlayFinishedAction{
    NSTimeInterval totalPlayTime = self.playerView.player.playerStateStore.state.currentPlaybackTime;
    if (totalPlayTime > 0  ){
        NSString *duration = [NSString stringWithFormat:@"%.0f", totalPlayTime * 1000];
        NSInteger rank = [self.cellModel.tracerDic btd_integerValueForKey:@"rank" default:0];
        [FHShortVideoTracerUtil videoOverWithModel:self.cellModel eventIndex:rank forStayTime:duration];
    }
    if (self.playerView.playerModel.isLoopPlay) {
        [self.playerView.player setLogoImageViewHidden:YES];
        [self.playerView.player play];
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
