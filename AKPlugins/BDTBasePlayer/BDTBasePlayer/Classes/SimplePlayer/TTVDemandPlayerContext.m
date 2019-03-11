//
//  TTVDemandPlayerContext.m
//  Article
//
//  Created by panxiang on 2017/6/18.
//
//

#import "TTVDemandPlayerContext.h"
#import "TTVPlayerStateStore.h"
#import "KVOController.h"
#import "TTVPlayerStateModel.h"
@interface TTVDemandPlayerContext ()
@property (nonatomic, weak) TTVPlayerStateModel *state;
@end
@implementation TTVDemandPlayerContext

- (void)setPlayerStateModel:(TTVPlayerStateModel *)state
{
    _state = state;
}

- (NSTimeInterval)duration
{
    return self.state.duration;
}

- (NSTimeInterval)currentPlaybackTime
{
    return self.state.currentPlaybackTime;
}

- (TTVPlayerControlTipViewType)tipType
{
    return self.state.tipType;
}

- (BOOL)showVideoFirstFrame
{
    return self.state.showVideoFirstFrame;
}

- (TTVVideoPlaybackState)playbackState
{
    return self.state.playbackState;
}

- (TTVPlayerLoadState)loadState
{
    return self.state.loadingState;
}

- (BOOL)isShowingTrafficAlert
{
    return self.state.isShowingTrafficAlert;
}

- (BOOL)inIndetail
{
    return self.state.isInDetail;
}

- (BOOL)isFullScreen
{
    return [self.state isFullScreen];
}

- (BOOL)isRotating
{
    return self.state.isRotating;
}

- (BOOL)hasEnterDetail
{
    return self.state.hasEnterDetail;
}

- (NSInteger)playPercent
{
    return self.state.playPercent;
}

- (float)totalWatchTime
{
    return self.state.totalWatchTime;
}

- (BOOL)muted
{
    return self.state.muted;
}
@end
