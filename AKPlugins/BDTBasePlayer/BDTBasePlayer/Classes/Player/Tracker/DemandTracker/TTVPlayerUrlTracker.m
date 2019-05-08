//
//  TTVPlayerUrlTracker.m
//  Article
//
//  Created by panxiang on 2017/6/19.
//
//

#import "TTVPlayerUrlTracker.h"
#import "TTURLTracker.h"
#import "TTVPlayerStateStore.h"

@interface TTVPlayerUrlTracker ()
@end

@implementation TTVPlayerUrlTracker

- (instancetype)init
{
    self = [super init];
    if (self) {
    }
    return self;
}

- (void)actionChangeCallbackWithAction:(TTVPlayerStateAction *)action state:(TTVPlayerStateModel *)state
{
    [super actionChangeCallbackWithAction:action state:state];
    if (![action isKindOfClass:[TTVPlayerStateAction class]] || ![state isKindOfClass:[TTVPlayerStateModel class]]) {
        return;
    }
    switch (action.actionType) {
        case TTVPlayerEventTypeShowVideoFirstFrame:
            [self sendVideoThirdMonitorUrl];
            break;
        case TTVPlayerEventTypeFinished:
        case TTVPlayerEventTypeFinishedBecauseUserStopped:{
            if (self.playerStateStore.state.resolutionState != TTVResolutionStateChanging) {
                [self sendEndTrack];
            }
        }
            break;
        case TTVPlayerEventTypeEncounterError:{
            if (self.playerStateStore.state.resolutionState != TTVResolutionStateChanging) {
                [self sendEndTrack];
            }
        }
            break;
        case TTVPlayerEventTypePlayerBeginPlay:{
            [self sendPlayTrack];
        }
            break;
        case TTVPlayerEventTypeFinishUIReplay:{
            [self sendPlayTrack];
        }
            break;
        case TTVPlayerEventTypeGoToDetail:{
            [self sendPlayTrack];
        }
            break;
        case TTVPlayerEventTypeRetry:{
            [self sendPlayTrack];
        }
            break;
        default:
            break;
    }
}

- (void)sendPlayTrack
{
    [self sendPlayVideoTrackURL];
    //主动播放
    if ([self ttv_sendEvenWhenPlayActively]) {
        [self sendActivePlayVideoTrackURL];
    }
}

- (void)sendEndTrack
{
    if (self.playerStateStore.state.currentPlaybackTime >= self.effectivePlayTime) {
        [self sendEffectivePlayVideoTrackURL];
    }
    if (self.playerStateStore.state.isPlaybackEnded) {
        [self sendPlayOverVideoTrackURL];
    }
}

- (BOOL)sendPlayVideoTrackURL
{
    if (!SSIsEmptyArray(self.playTrackUrls)) {
        ttTrackURLsModel(self.playTrackUrls, self.trackUrlModel);
        return YES;
    }
    return NO;
}

- (void)sendActivePlayVideoTrackURL
{
    if (!SSIsEmptyArray(self.activePlayTrackUrls)) {
        ttTrackURLsModel(self.activePlayTrackUrls, self.trackUrlModel);
    }
}

- (void)sendEffectivePlayVideoTrackURL
{
    if (!SSIsEmptyArray(self.effectivePlayTrackUrls)) {
        ttTrackURLsModel(self.effectivePlayTrackUrls, self.trackUrlModel);
    }
}

- (void)sendPlayOverVideoTrackURL
{
    if (!SSIsEmptyArray(self.playOverTrackUrls)) {
        ttTrackURLsModel(self.playOverTrackUrls , self.trackUrlModel);
    }
}

- (void)sendVideoThirdMonitorUrl
{
    if (!isEmptyString(self.videoThirdMonitorUrl) && isEmptyString(self.adID)) {
        [[TTURLTracker shareURLTracker] thirdMonitorUrl:self.videoThirdMonitorUrl];
        [TTTrackerWrapper event:@"video_track_url" label:@"play_track_url" value:self.groupID extValue:nil extValue2:nil];
    }
}

- (TTURLTrackerModel *)trackUrlModel
{
    TTURLTrackerModel *model = [[TTURLTrackerModel alloc] initWithAdId:self.adID logExtra:self.logExtra];
    return model;
}


@end



