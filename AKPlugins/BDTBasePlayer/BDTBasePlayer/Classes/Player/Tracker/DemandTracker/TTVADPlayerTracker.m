//
//  TTVADPlayerTracker.m
//  Article
//
//  Created by panxiang on 2017/6/2.
//
//

#import "TTVADPlayerTracker.h"
#import "TTVPlayerStateStore.h"
#import "KVOController.h"
#import "TTTrackerProxy.h"


@interface TTVADPlayerTracker ()
//用来判断自动循环播放打点的标志位 yes:auto_replay   no:**_play
@property (nonatomic, assign) BOOL autoReplayFlag;

@end

@implementation TTVADPlayerTracker
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
        case TTVPlayerEventTypePlayerContinuePlay:{
            [self sendContinueTrack];
        }
            break;

        case TTVPlayerEventTypePlayerPause:{
            if ([action.payload isKindOfClass:[NSDictionary class]]) {
                NSDictionary *dic = action.payload;
                if ([[dic valueForKey:TTVPauseAction] isEqualToString:TTVPauseActionUserAction]) {
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
        if (self.autoReplayFlag) {
            [self ttv_sendEmbedAdWithlabel:@"auto_replay"];
            return;
        }
        if (self.playerStateStore.state.playerModel.isLoopPlay) {
            self.autoReplayFlag = YES;
        }

        if (self.playerStateStore.state.isInDetail) {
            [self ttv_sendEmbedAdWithlabel:@"detail_play"];
        } else {
            if ([self ttv_sendEvenWhenPlayActively]) {
                [self ttv_sendEmbedAdWithlabel:@"feed_play"];
                //主动播放双发click
                //这个埋点没有加ad_extra_data中的event_id和super_id。
                [self ttv_sendEmbedAdWithlabel:@"click"];
            }
        }
    }
}


- (void)sendEndTrack
{
    BOOL watchOver = self.playerStateStore.state.isPlaybackEnded;
    if (watchOver) {
        if (!isEmptyString(self.adID)) {
            NSString *label = self.playerStateStore.state.isInDetail ? @"detail_over" : @"feed_over";
            NSMutableDictionary *dict = [self ttv_dictWithEvent:@"embeded_ad" label:label];
            [dict setValue:@"high" forKey:@"version_type"];
            [dict setValue:[self.playerStateStore.state ttv_position] forKey:@"position"];
            [dict setValue:@(self.playerStateStore.state.playPercent) forKey:@"percent"];
            [dict setValue:@(self.playerStateStore.state.totalWatchTime) forKey:@"duration"];
            if ([self ttv_sendEvenWhenPlayActively]) {
                [TTTrackerWrapper eventData:dict];
            }
        }
    }else{
        if (!isEmptyString(self.adID)) {
            NSString *label = self.playerStateStore.state.isInDetail ? @"detail_break" : @"feed_break";
            NSMutableDictionary *dict = [self ttv_dictWithEvent:@"embeded_ad" label:label];
            [dict setValue:@"high" forKey:@"version_type"];
            [dict setValue:[self.playerStateStore.state ttv_position] forKey:@"position"];
            [dict setValue:@(self.playerStateStore.state.totalWatchTime) forKey:@"duration"];
            [dict setValue:@(self.playerStateStore.state.playPercent) forKey:@"percent"];
            if ([self ttv_sendEvenWhenPlayActively]) {
                [TTTrackerWrapper eventData:dict];
            } else if (self.playerStateStore.state.playerModel.isAutoPlaying){
                if (!self.playerStateStore.state.isInDetail) {
                    //自动播放feed中中断打点
                    [dict setValue:@"feed_auto_over" forKey:@"label"];
                    [TTTrackerWrapper eventData:dict];
                }
            }
        }
    }

}

- (void)sendPauseTrack
{
    if (self.playerStateStore.state.isInDetail) {
        [self ttv_sendEmbedAdWithlabel:@"detail_pause"];
    }else {
        if ([self ttv_sendEvenWhenPlayActively]) {
            [self ttv_sendEmbedAdWithlabel:@"feed_pause"];
        }
    }
}

- (void)sendContinueTrack
{
    if (self.playerStateStore.state.isInDetail) {
        [self ttv_sendEmbedAdWithlabel:@"detail_continue"];
    }else {
        if ([self ttv_sendEvenWhenPlayActively]) {
            [self ttv_sendEmbedAdWithlabel:@"feed_continue"];
        }
    }
}

- (void)sendEnterFullScreenTrack
{
    if (!self.playerStateStore.state.isInDetail) {
        [self ttv_sendEmbedAdWithlabel:@"feed_fullscreen"];
    }else {
        [self ttv_sendEmbedAdWithlabel:@"detail_fullscreen"];
    }
}

- (void)ttv_sendEmbedAdWithlabel:(NSString *)label
{
    NSMutableDictionary *dict = [self ttv_dictWithEvent:@"embeded_ad" label:label];
    NSString *eventpos = self.playerStateStore.state.isInDetail ? @"2" : @"1";
    [dict setValue:eventpos forKey:@"eventpos"];
    [TTTrackerWrapper eventData:dict];
}

- (NSMutableDictionary *)ttv_dictWithEvent:(NSString *)event
                                     label:(NSString *)label
{
    if (isEmptyString(event) || isEmptyString(label) || isEmptyString(self.adID)) {
        return nil;
    }
    NSMutableDictionary * dict = [NSMutableDictionary dictionaryWithCapacity:10];
    [dict setValue:@"umeng" forKey:@"category"];
    [dict setValue:event forKey:@"tag"];
    TTInstallNetworkConnection connectionType = [[TTTrackerProxy sharedProxy] connectionType];
    [dict setValue:@(connectionType) forKey:@"nt"];
    if (!isEmptyString(label)) {
        [dict setValue:label forKey:@"label"];
    }
    if (!isEmptyString(self.adID)) {
        [dict setValue:self.adID forKey:@"value"];
        [dict setValue:self.groupID forKey:@"ext_value"];
        [dict setValue:@"1" forKey:@"is_ad_event"];
        if (!isEmptyString(self.logExtra)) {
            [dict setValue:self.logExtra forKey:@"log_extra"];
        }
    }
    
    [dict setValue:self.itemID forKey:@"item_id"];
    [dict setValue:@(self.aggrType) forKey:@"aggr_type"];
    if ([label rangeOfString:@"_over"].location != NSNotFound ||
        [label rangeOfString:@"_break"].location != NSNotFound) {
        NSNumber *duration = @(MAX(self.playerStateStore.state.totalWatchTime, 0));
        if (duration.integerValue > 0) {
            [dict setValue:@(MAX(self.playerStateStore.state.totalWatchTime, 0)) forKey:@"duration"];
        }
        [dict setValue:@(MAX(self.playerStateStore.state.playPercent, 0)) forKey:@"percent"];
    }
    [dict addEntriesFromDictionary:self.playerStateStore.state.playerModel.commonExtra];
    
    return dict;
}


@end
