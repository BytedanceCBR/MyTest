//
//  TTLiveHeaderView+Video.m
//  Article
//
//  Created by matrixzk on 8/11/16.
//
//

#import "TTLiveHeaderView+Video.h"

#import "TTLiveStreamDataModel.h"
#import "TTImageView.h"
#import "TTLiveAudioManager.h"
#import "TVLApiRequestInfo.h"
#import "TTLivePlayerControlView.h"
#import "SSCommonLogic.h"


#define TTLivePlayerViewFrame CGRectMake(self.left, self.top + self.heightOffset, self.width, self.height - self.heightOffset)

@implementation TTLiveHeaderView (Video)

- (void)setupSubviews4LiveTypeVideo
{
    // 初始化直播view
    TTLiveStreamDataModel *model = [TTLiveStreamDataModel new];
    model.status = self.dataModel.status;
    model.status_display = self.dataModel.status_display;
    model.participated = self.dataModel.participated;
    
	// videoLiveSDK 开关
    self.useLiveSDK = [SSCommonLogic chatroomVideoLiveSDKEnable];
    
//#if DEBUG
//    model.status = @(2);
//#endif

    [self refreshLiveVideoViewWithModel:model];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(rateChanged:) name:TTMediaPlaybackRateChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(unknowNotification:) name:TTMediaPlaybackUnknowNotification object:nil];
}

- (void)refreshLiveVideoViewWithModel:(TTLiveStreamDataModel *)model
{
    [self removeExistingVideoViewIfNeeded];
    // 重置两个状态view
    [self refreshStatusViewWithModel:model];
    
    [self.chatroom.fakeNavigationBar hideTitleView:NO];
    
//#if DEBUG
//    model.status = @(2);
//#endif
    self.backgroundColor = [UIColor clearColor];
    
    switch (model.status.integerValue) {
            
        case TTLiveStatusPlaying:
            self.backgroundColor = [UIColor blackColor];
            [self addVideoViewWithLiveStatus:TTLiveStatusPlaying];
            break;
            
        case TTLiveStatusOver:
            self.backgroundColor = [UIColor blackColor];
            if (self.dataModel.background.video.playbackEnable) {
                [self.statusView removeFromSuperview];
                [self.numOfParticipantsView removeFromSuperview];
                [self addVideoViewWithLiveStatus:TTLiveStatusOver];
            }
            break;
            
        default:
            break;
    }
}

- (void)viewWillAppear
{
    [self playVideo];
}

- (void)viewWillDisappear
{
    [self pauseVideo];
}

- (void)removeExistingVideoViewIfNeeded
{
    if (self.chatroomVideoView) {
        [self.chatroomVideoView stopMovie];
        self.chatroomVideoView.didExitFullScreenHandler = nil;
        self.chatroomVideoView.moviePlayerController.controlView.toolBarHiddenBlock = nil;
        self.chatroomVideoView.playStartBlock = nil;
        self.chatroomVideoView.clickPlayButtonToPlayBlock = nil;
        [self.chatroomVideoView removeFromSuperview];
        // 这里要释放掉，因为结束状态时没有回放就不显示该控件了
        self.chatroomVideoView = nil;
    }
    
    if (self.livePlayerView) {
        [self.livePlayerView pause];
        [self.livePlayerView removeFromSuperview];
        self.livePlayerView = nil;
    }
}

- (void)addVideoViewWithLiveStatus:(TTLiveStatus)status
{
    
    if (self.useLiveSDK) {
        [self _addNewVideoViewWithLiveStatus:status];
    } else {
        [self _addOldVideoViewWithLiveStatus:status];
    }
}

- (void)_addNewVideoViewWithLiveStatus:(TTLiveStatus)status
{
    if (TTLiveStatusPlaying == status) {
        
        TVLApiRequestInfo *reqInfo = [TVLApiRequestInfo new];
        reqInfo.liveID = self.dataModel.background.video.videoId;
        reqInfo.userID = kTVLUserChat;
        reqInfo.playType = TVLPlayTypeLive;
        
        self.livePlayerView = [[TTLivePlayerView alloc] initWithFrame:TTLivePlayerViewFrame liveInfo:reqInfo];
        [self.livePlayerView setTitle:self.dataModel.title];
        [self.livePlayerView setStatusView:self.statusView numOfParticipantsView:self.numOfParticipantsView];
        WeakSelf;
        self.livePlayerView.shouldRotatePlayerViewBlock = ^BOOL(void) {
            StrongSelf;
            return ![self.chatroom.messageBoxView currentIsEditing];
        };
        self.livePlayerView.controlView.controlViewHiddenAnimationBlock = ^(BOOL hidden) {
            StrongSelf;
            [self.chatroom.fakeNavigationBar hideTitleView:hidden];
        };
        self.livePlayerView.startPlayBlock = ^(void) {
            [TTLiveAudioManager stopCurrentPlayingAudioIfNeeded];
        };
        [self insertSubview:self.livePlayerView aboveSubview:self.backgroundImageView];
        
    } else if (TTLiveStatusOver == status) {
        
        [self addChatroomMovieView];
        
        // App Log 3.0 埋点
        NSMutableDictionary *log3Dict = [NSMutableDictionary dictionaryWithCapacity:5];
        [log3Dict setValue:self.chatroom.overallModel.liveId forKey:@"group_id"];
        [log3Dict setValue:self.chatroom.overallModel.groupSource forKey:@"group_source"];
        [log3Dict setValue:self.chatroom.overallModel.enterFrom forKey:@"enter_from"];
        [log3Dict setValue:self.chatroom.overallModel.categoryName forKey:@"category_name"];
        [log3Dict setValue:self.chatroom.overallModel.logPb forKey:@"log_pb"];
        [log3Dict setValue:(TTVideoPlayTypeLive == status ? @"0" : @"1") forKey:@"is_video_live_replay"];
        [self.chatroomVideoView.tracker addExtraValueFromDic:[log3Dict copy]];
    }
}

- (void)addChatroomMovieView
{
    // 生成该model完全为了事件统计
    NSString *liveId = self.chatroom.overallModel.liveId;
    TTChatroomMovieViewModel *movieViewModel = [TTChatroomMovieViewModel new];
    movieViewModel.type = ExploreMovieViewTypeDetail;
    movieViewModel.gModel = [[TTGroupModel alloc] initWithGroupID:liveId itemID:liveId impressionID:nil aggrType:1];
    movieViewModel.logExtra = self.chatroom.overallModel.logExtra;
    movieViewModel.aID = self.chatroom.overallModel.adId;
    movieViewModel.cID = self.chatroom.overallModel.categoryID;
    if (!isEmptyString(self.chatroom.overallModel.referFrom)) {
        movieViewModel.gdLabel = [NSString stringWithFormat:@"click_%@",self.chatroom.overallModel.referFrom];
    }
    movieViewModel.videoPlayType = TTVideoPlayTypeLivePlayback;
    
    self.chatroomVideoView = [[TTChatroomMovieView alloc] initWithFrame:TTLivePlayerViewFrame type:ExploreMovieViewTypeDetail trackerDic:nil movieViewModel:movieViewModel];
    self.chatroomVideoView.movieViewDelegate = (id<TTChatroomMovieViewDelegate>)self;
    [self.chatroomVideoView playVideoForVideoID:self.dataModel.background.video.videoId // @"a834808a672840718b169366a2662d6b"
                                 exploreVideoSP:ExploreVideoSPToutiao
                                  videoPlayType:TTVideoPlayTypeLivePlayback]; // 直播回放type
    // [liveMovieView playVideoForVideoURL:@"http://live6a.pstatp.com/live/a834808a672840718b169366a2662d6b/index.m3u8"];
    [self.chatroomVideoView.moviePlayerController.controlView reLayoutToolBar4ReplayVideoOfLiveRoom];
    [self.chatroomVideoView setVideoTitle:self.dataModel.title fontSizeStyle:TTVideoTitleFontStyleNormal showInNonFullscreenMode:NO];
    self.refreshPlayCount = -1;
    [self.chatroomVideoView markAsDetail];
    WeakSelf;
    self.chatroomVideoView.willAttemptRoateBlock = ^BOOL{
        StrongSelf;
        return ![self.chatroom.messageBoxView currentIsEditing];
    };
    self.chatroomVideoView.didExitFullScreenHandler = ^(UIView *movieView) {
        StrongSelf;
        [self insertSubview:movieView aboveSubview:self.backgroundImageView];
    };
    self.chatroomVideoView.playStartBlock = ^{
        StrongSelf;
        if ([self.chatroom headerViewIsFolded]) {
            [self pauseVideo];
        }
    };
    self.chatroomVideoView.clickPlayButtonToPlayBlock = ^(UIView *movieView) {
        [TTLiveAudioManager stopCurrentPlayingAudioIfNeeded];
    };
    self.chatroomVideoView.moviePlayerController.controlView.toolBarHiddenBlock = ^(BOOL hidden) {
        StrongSelf;
        [self.chatroom.fakeNavigationBar hideTitleView:hidden];
    };
    
    [self insertSubview:self.chatroomVideoView aboveSubview:self.backgroundImageView];
}

- (void)_addOldVideoViewWithLiveStatus:(TTLiveStatus)status
{
    // 生成该model完全为了事件统计
    NSString *liveId = self.chatroom.overallModel.liveId;
    TTChatroomMovieViewModel *movieViewModel = [TTChatroomMovieViewModel new];
    movieViewModel.type = ExploreMovieViewTypeDetail;
    movieViewModel.gModel = [[TTGroupModel alloc] initWithGroupID:liveId itemID:liveId impressionID:nil aggrType:1];
    movieViewModel.logExtra = self.chatroom.overallModel.logExtra;
    movieViewModel.aID = self.chatroom.overallModel.adId;
    movieViewModel.cID = self.chatroom.overallModel.categoryID;
    
    if (!isEmptyString(self.chatroom.overallModel.referFrom)) {
        movieViewModel.gdLabel = [NSString stringWithFormat:@"click_%@", self.chatroom.overallModel.referFrom];
    }
    if (TTLiveStatusPlaying == status) {
        
        movieViewModel.videoPlayType = TTVideoPlayTypeLive;
        // CGRect movieViewFrame = CGRectMake(self.left, self.top + self.heightOffset, self.width, self.height - self.heightOffset);
        self.chatroomVideoView = [[TTChatroomMovieView alloc] initWithFrame:TTLivePlayerViewFrame type:ExploreMovieViewTypeDetail trackerDic:nil movieViewModel:movieViewModel];
        self.chatroomVideoView.movieViewDelegate = (id<TTChatroomMovieViewDelegate>)self;
        [self.chatroomVideoView markAsDetail];
        WeakSelf;
        self.chatroomVideoView.willAttemptRoateBlock  = ^BOOL{
            StrongSelf;
            return ![self.chatroom.messageBoxView currentIsEditing];
        };
        self.refreshPlayCount = -1;
        [self.chatroomVideoView playVideoForVideoID:self.dataModel.background.video.videoId
                                     exploreVideoSP:ExploreVideoSPToutiao
                                      videoPlayType:TTVideoPlayTypeLive];
        
        [self.chatroomVideoView.moviePlayerController.controlView resetToolBar4LiveVideoWithStatusView:self.statusView
                                                                                 numOfParticipantsView:self.numOfParticipantsView];
        
    } else if (TTLiveStatusOver == status) {
        
        movieViewModel.videoPlayType = TTVideoPlayTypeLivePlayback;
        // CGRect movieViewFrame = CGRectMake(self.left, self.top + self.heightOffset, self.width, self.height - self.heightOffset);
        self.chatroomVideoView = [[TTChatroomMovieView alloc] initWithFrame:TTLivePlayerViewFrame type:ExploreMovieViewTypeDetail trackerDic:nil movieViewModel:movieViewModel];
        self.chatroomVideoView.movieViewDelegate = (id<TTChatroomMovieViewDelegate>)self;
        [self.chatroomVideoView markAsDetail];
        WeakSelf;
        self.chatroomVideoView.willAttemptRoateBlock = ^BOOL{
            StrongSelf;
            return ![self.chatroom.messageBoxView currentIsEditing];
        };
        self.refreshPlayCount = -1;
        [self.chatroomVideoView playVideoForVideoID:self.dataModel.background.video.videoId // @"a834808a672840718b169366a2662d6b"
                                     exploreVideoSP:ExploreVideoSPToutiao
                                      videoPlayType:TTVideoPlayTypeLivePlayback]; // 直播回放type
        // [liveMovieView playVideoForVideoURL:@"http://live6a.pstatp.com/live/a834808a672840718b169366a2662d6b/index.m3u8"];
        [self.chatroomVideoView.moviePlayerController.controlView reLayoutToolBar4ReplayVideoOfLiveRoom];
        
    }
    
    [self.chatroomVideoView setVideoTitle:self.dataModel.title fontSizeStyle:TTVideoTitleFontStyleNormal showInNonFullscreenMode:NO];
    
    WeakSelf;
    self.chatroomVideoView.didExitFullScreenHandler = ^(UIView *movieView) {
        StrongSelf;
        [self insertSubview:movieView aboveSubview:self.backgroundImageView];
    };
    self.chatroomVideoView.playStartBlock = ^{
        StrongSelf;
        if ([self.chatroom headerViewIsFolded]) {
            [self pauseVideo];
        }
    };
    self.chatroomVideoView.clickPlayButtonToPlayBlock = ^(UIView *movieView) {
        [TTLiveAudioManager stopCurrentPlayingAudioIfNeeded];
    };
    
    self.chatroomVideoView.moviePlayerController.controlView.toolBarHiddenBlock = ^(BOOL hidden) {
        StrongSelf;
        [self.chatroom.fakeNavigationBar hideTitleView:hidden];
    };
    
    // App Log 3.0 埋点
    NSMutableDictionary *log3Dict = [NSMutableDictionary dictionaryWithCapacity:5];
    [log3Dict setValue:self.chatroom.overallModel.liveId forKey:@"group_id"];
    [log3Dict setValue:self.chatroom.overallModel.groupSource forKey:@"group_source"];
    [log3Dict setValue:self.chatroom.overallModel.enterFrom forKey:@"enter_from"];
    [log3Dict setValue:self.chatroom.overallModel.categoryName forKey:@"category_name"];
    [log3Dict setValue:self.chatroom.overallModel.logPb forKey:@"log_pb"];
    [log3Dict setValue:(TTVideoPlayTypeLive == status ? @"0" : @"1") forKey:@"is_video_live_replay"];
    [self.chatroomVideoView.tracker addExtraValueFromDic:[log3Dict copy]];
    
    [self insertSubview:self.chatroomVideoView aboveSubview:self.backgroundImageView];
}


#pragma mark - Action

- (void)playVideo
{
    if (self.useLiveSDK) {
        if (self.livePlayerView.superview) {
            [self.livePlayerView play];
        } else {
            [self _playVideo_chatroomVideoView];
        }
    } else {
        [self _playVideo_chatroomVideoView];
    }
}

- (void)pauseVideo
{
    if (self.useLiveSDK) {
        if (self.livePlayerView.superview) {
            [self.livePlayerView pause];
        } else {
            [self.chatroomVideoView pauseLive];
        }
    } else {
        [self.chatroomVideoView pauseLive];
    }
}

- (void)stopVideo
{
    if (self.useLiveSDK) {
        if (self.livePlayerView.superview) {
            [self.livePlayerView pause];
        } else {
            [self _stopVideo_chatroomVideoView];
        }
    } else {
        [self _stopVideo_chatroomVideoView];
    }
}

- (void)_stopVideo_chatroomVideoView
{
    if (self.chatroomVideoView.superview) {
        [self.chatroomVideoView stopMovie];
    }
}

- (void)_playVideo_chatroomVideoView
{
    if (!self.chatroomVideoView.superview) {
        return;
    }
    
    if (TTLiveStatusOver == self.currentLiveStatus) {
        if (self.chatroomVideoView.isPaused) {
            [self.chatroomVideoView playMovie];
        } else {
            self.refreshPlayCount = -1;
            [self.chatroomVideoView pauseLive];
            [self.chatroomVideoView playVideoForVideoID:self.dataModel.background.video.videoId
                                         exploreVideoSP:ExploreVideoSPToutiao
                                          videoPlayType:TTVideoPlayTypeLivePlayback];
        }
    } else {
        if (self.chatroomVideoView.isPaused) {
            [self.chatroomVideoView playMovie];
        } else {
            self.refreshPlayCount = -1;
            [self.chatroomVideoView pauseLive];
            [self.chatroomVideoView playVideoForVideoID:self.dataModel.background.video.videoId
                                         exploreVideoSP:ExploreVideoSPToutiao
                                          videoPlayType:TTVideoPlayTypeLive];
        }
    }
}


#pragma mark - ExploreMovieViewDelegate

- (CGRect)movieViewFrameAfterExitFullscreen
{
    return self.bounds;
}

- (void)rateChanged:(NSNotification *)notification
{
    CGFloat rate = [notification.object doubleValue];
    if (rate != 0) {
        self.refreshPlayCount = 0;
    }
}

- (void)unknowNotification:(NSNotification *)notification
{
    if (self.refreshPlayCount >= 0) {
        if (self.refreshPlayCount >= 3) {
            [self.chatroomVideoView.moviePlayerController play];
            self.refreshPlayCount = 0;
        } else {
            self.refreshPlayCount++;
        }
    }
}

- (BOOL)shouldDisableUserInteraction
{
    return NO;
}

@end
