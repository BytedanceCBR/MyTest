//
//  TTVDetailNatantADPlayerTracker.m
//  Article
//
//  Created by rongyingjie on 2017/10/31.
//

#import "TTVDetailNatantADPlayerTracker.h"
#import "TTVPlayerStateStore.h"


@interface TTVDetailNatantADPlayerTracker ()
{
}
@end

@implementation TTVDetailNatantADPlayerTracker
- (instancetype)init
{
    self = [super init];
    if (self) {
    }
    return self;
}


- (void)actionChangeCallbackWithAction:(TTVPlayerStateAction *)action state:(TTVPlayerStateModel *)state
{
    if (![action isKindOfClass:[TTVPlayerStateAction class]] || ![state isKindOfClass:[TTVPlayerStateModel class]]) {
        return;
    }
    switch (action.actionType) {
        case TTVPlayerEventTypeShowVideoFirstFrame:{
        }
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
        case TTVPlayerEventTypeTrafficFreeFlowPlay:
        case TTVPlayerEventTypeTrafficPlay:{
            [self sendContinueTrack];
        }
            break;
        case TTVPlayerEventTypePlayerBeginPlay:{
            [self sendPlayTrack];
        }
            break;
        case TTVPlayerEventTypePlayerResume:{
            [self sendContinueTrack];
        }
            break;
        case TTVPlayerEventTypePlayerPause:{
            if ([action.payload isKindOfClass:[NSDictionary class]]) {
                NSString *key = [action.payload tt_objectForKey:@"TTVPauseAction"];
                if ([key isEqualToString:TTVPauseActionDefault]) {
                    [self sendEndTrack];
                } else if ([key isEqualToString:TTVPauseActionUserAction]) {
                    [self sendPauseTrack];
                }
            }
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
        case TTVPlayerEventTypeControlViewClickScreen:
            break;
        case TTVPlayerEventTypeFinishUIShow:
            break;
        case TTVPlayerEventTypeFinishUIShare:
            break;
        case TTVPlayerEventTypeControlViewDragSlider:{
        }
            break;
            
        default:
            break;
    }
}


- (void)sendPlayTrack
{
    if (!isEmptyString(self.adID)) {
        NSString *label = self.isAutoPlay ? @"auto_play" : @"detail_play";
        [self ttv_sendDetailAdWithlabel:label];
    }
}


- (void)sendEndTrack
{
    BOOL watchOver = self.playerStateStore.state.isPlaybackEnded;
    if (watchOver) {
        if (!isEmptyString(self.adID)) {
            NSString *label = self.isAutoPlay ? @"auto_over" : @"detail_over";
            NSMutableDictionary *dict = [self ttv_dictWithEvent:@"detail_ad" label:label];
            [dict setValue:@"high" forKey:@"version_type"];
            [dict setValue:[self.playerStateStore.state ttv_position] forKey:@"position"];
            [dict setValue:@(self.playerStateStore.state.playPercent) forKey:@"percent"];
            [dict setValue:@(self.playerStateStore.state.duration * 1000) forKey:@"duration"];
            [TTTrackerWrapper eventData:dict];
        }
    }else{
        if (!isEmptyString(self.adID)) {
            NSString *label = self.isAutoPlay ? @"auto_break" : @"detail_break";
            NSMutableDictionary *dict = [self ttv_dictWithEvent:@"detail_ad" label:label];
            [dict setValue:@"high" forKey:@"version_type"];
            [dict setValue:[self.playerStateStore.state ttv_position] forKey:@"position"];
            [dict setValue:@(self.playerStateStore.state.playPercent) forKey:@"percent"];
            [dict setValue:@(self.playerStateStore.state.totalWatchTime) forKey:@"duration"];
            if ([self ttv_sendEvenWhenPlayActively]) {
                [TTTrackerWrapper eventData:dict];
            }
        }
    }
    if (self.isAutoPlay) {
        self.isAutoPlay = NO;
    }
}

- (void)sendPauseTrack
{
    NSString *label = self.isAutoPlay ? @"auto_break" : @"detail_pause";
    [self ttv_sendDetailAdWithlabel:label];
    if (self.isAutoPlay) {
        self.isAutoPlay = NO;
    }
}

- (void)sendContinueTrack
{
    [self ttv_sendDetailAdWithlabel:@"detail_continue"];
}

- (void)sendEnterFullScreenTrack
{
    [self ttv_sendDetailAdWithlabel:@"feed_fullscreen"];
}

- (void)ttv_sendDetailAdWithlabel:(NSString *)label
{
    [TTTrackerWrapper eventData:[self ttv_dictWithEvent:@"detail_ad" label:label]];
}

@end

