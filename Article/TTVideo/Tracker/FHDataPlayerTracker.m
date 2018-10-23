//
//  FHDataPlayerTracker.m
//  Article
//
//  Created by 张静 on 2018/9/19.
//

#import "FHDataPlayerTracker.h"
#import "TTVPlayerStateStore.h"
#import "KVOController.h"
#import "TTVResolutionStore.h"
#import "Bubble-Swift.h"

@interface FHDataPlayerTracker ()
{
    BOOL _hasSendEndTrack;
}
@end


@implementation FHDataPlayerTracker


- (instancetype)init
{
    self = [super init];
    if (self) {
    }
    return self;
}

- (NSString *)enterFromString{
    NSString * enterFrom = self.enterFrom;
    if (isEmptyString(enterFrom)) {
        if (!isEmptyString(self.trackLabel)) {
            enterFrom = self.trackLabel;
        }
    }
    if (!enterFrom) {
        enterFrom = @"click_unknow";
    }
    return enterFrom;
    
}

- (NSString *)categroyNameV3
{
    NSString *categoryName = self.categoryName;
    
    if (!categoryName || [categoryName isEqualToString:@"xx"] ) {
        categoryName = [[self enterFromString] stringByReplacingOccurrencesOfString:@"click_" withString:@""];
        NSLog(@"%@", categoryName);
    }else{
        if (![[self enterFromString] isEqualToString:@"click_headline"]) {
            if ([categoryName hasPrefix:@"_"]) {
                categoryName = [categoryName substringFromIndex:1];
            }
        }
    }
    return categoryName;
    
}

- (void)sendPlayTrackV3{
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithCapacity:10];
    NSString *position = [self.playerStateStore.state ttv_position];
    [dic setValue:[self enterFromString] forKey:@"enter_from"];
    [dic setValue:[self categroyNameV3] forKey:@"category_name"];
    [dic setValue:position forKey:@"position"];
    [dic setValue:self.itemID forKey:@"item_id"];
    [dic setValue:self.groupID forKey:@"group_id"];

    [dic setValue:self.logPb forKey:@"log_pb"];
    if ([self extraFromEvent:@"video_play"].count > 0) {
        [dic addEntriesFromDictionary:[self extraFromEvent:@"video_play"]];
    }
    
    [dic setValue:self.authorId forKey:@"author_id"];
    if (self.playerStateStore.state.playerModel.commonExtra) {
        [dic addEntriesFromDictionary:self.playerStateStore.state.playerModel.commonExtra];
    }
    [TTTrackerWrapper eventV3:@"video_play" params:dic isDoubleSending:YES];
    
}

- (void)sendEndTrackV3{
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithCapacity:20];
    NSString *position = [self.playerStateStore.state ttv_position];
    if (self.playerStateStore.state.duration > 0) {
        [dic setValue:@(self.playerStateStore.state.playPercent) forKey:@"percent"];
    }
    [dic setValue:@"high" forKey:@"version_type"];
    [dic setValue:position forKey:@"position"];
    [dic setValue:@(self.playerStateStore.state.supportedResolutionTypes.count) forKey:@"clarity_num"];
    [dic setValue:[[TTVResolutionStore sharedInstance] lastDefinationStr] forKey:@"clarity_choose"];
    [dic setValue:[[TTVResolutionStore sharedInstance] actualDefinationtr] forKey:@"clarity_actual"];
    [dic setValue:@([TTVResolutionStore sharedInstance].clarity_change_time) forKey:@"clarity_change_time"];
    [dic setValue: [self enterFromString] forKey:@"enter_from"];
    [dic setValue:[self categroyNameV3] forKey:@"category_name"];
    [dic setValue:self.itemID forKey:@"item_id"];
    [dic setValue:self.groupID forKey:@"group_id"];

    [dic setValue:self.logPb forKey:@"log_pb"];
    [dic setValue:self.authorId forKey:@"author_id"];
    [dic setValue:self.playerStateStore.state.playerModel.fromGid forKey:@"from_gid"];
    NSNumber *duration = @(MAX(self.playerStateStore.state.totalWatchTime, 0));
    if (duration.integerValue > 0) {
        [dic setValue:@(MAX(self.playerStateStore.state.totalWatchTime, 0)) forKey:@"duration"];
    }
    if ([self extraFromEvent:@"video_over"].count > 0) {
        [dic addEntriesFromDictionary:[self extraFromEvent:@"video_over"]];
    }
    if (self.playerStateStore.state.playerModel.commonExtra) {
        [dic addEntriesFromDictionary:self.playerStateStore.state.playerModel.commonExtra];
    }
//    [TTTrackerWrapper eventV3:@"video_over" params:dic isDoubleSending:YES];
    
    [self sendTraceVideoOver:dic];
}

- (void)sendTraceVideoOver:(NSDictionary *)dictVideo
{
    NSMutableDictionary *traceParams = [NSMutableDictionary dictionary];
    [traceParams setValue:@"house_app2c_v2" forKey:@"event_type"];

    NSDictionary *dictLogPb = self.playerStateStore.state.playerModel.logPb;
    if ([dictLogPb isKindOfClass:[NSDictionary class]]) {
        [traceParams setValue:dictLogPb[@"impr_id"] forKey:@"impr_id"];
    }
    
    [traceParams setValue:self.enterFrom forKey:@"enter_from"];
    [traceParams setValue:self.categoryName forKey:@"category_name"];
    [traceParams setValue:self.groupID forKey:@"group_id"];
    [traceParams setValue:self.itemID forKey:@"item_id"];
    [traceParams setValue:self.playerStateStore.state.playerModel.fromGid forKey:@"from_gid"];
    [traceParams setValue:self.playerStateStore.state.playerModel.logPb forKey:@"log_pb"];
    [traceParams setValue:[self.playerStateStore.state ttv_position] forKey:@"position"];
    [traceParams setValue:dictVideo[@"duration"] forKey:@"duration"];
    [traceParams setValue:dictVideo[@"percent"] forKey:@"percent"];
    
    [TTTracker eventV3:@"video_over" params:traceParams];
}


- (void)sendPlayTrack
{
    //data track
    if ([self ttv_sendEvenWhenPlayActively]) {
        _hasSendEndTrack = NO;
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [dict setValue:@"house_app2c_v2" forKey:@"event_type"];
        [dict setValue:self.groupID forKey:@"group_id"];
        [dict setValue:self.itemID forKey:@"item_id"];
        [dict setValue:self.playerStateStore.state.playerModel.logPb forKey:@"log_pb"];
        [dict setValue:self.enterFrom forKey:@"enter_from"];
        [dict setValue:self.categoryName forKey:@"category_name"];
        [dict setValue:self.playerStateStore.state.playerModel.fromGid forKey:@"from_gid"];
        [dict setValue:[self.playerStateStore.state ttv_position] forKey:@"position"];

        if (![TTTrackerWrapper isOnlyV3SendingEnable]){
            [[EnvContext shared].tracer writeEvent:@"video_play" params:dict];
        }
    }
}


- (void)sendEndTrack
{
    if ([self ttv_sendEvenWhenPlayActively]) {
        if (!_hasSendEndTrack || self.isReplaying || self.isRetry) {
            NSMutableDictionary *dict = [self ttv_dictWithEvent:@"video_over" label:[self ttv_dataTrackLabel]];
            [dict setValue:self.playerStateStore.state.playerModel.logPb forKey:@"log_pb"];
            if (self.playerStateStore.state.supportedResolutionTypes.count > 0) {
                [dict setValue:@(self.playerStateStore.state.supportedResolutionTypes.count) forKey:@"clarity_num"];
                [dict setValue:[[TTVResolutionStore sharedInstance] lastDefinationStr] forKey:@"clarity_choose"];
                [dict setValue:[[TTVResolutionStore sharedInstance] actualDefinationtr] forKey:@"clarity_actual"];
                [dict setValue:@([TTVResolutionStore sharedInstance].clarity_change_time) forKey:@"clarity_change_time"];
            }
            [dict setValue:@"high" forKey:@"version_type"];
            [dict setValue:[self.playerStateStore.state ttv_position] forKey:@"position"];
            [dict setValue:@(self.playerStateStore.state.playPercent) forKey:@"percent"];
            if ([self extraFromEvent:@"video_over"].count > 0) {
                [dict addEntriesFromDictionary:[self extraFromEvent:@"video_over"]];
            }
            _hasSendEndTrack = YES;
            if (![TTTrackerWrapper isOnlyV3SendingEnable]){
                [TTTrackerWrapper eventData:dict];
            }
            [self sendEndTrackV3];
        }
    }
}

- (void)actionChangeCallbackWithAction:(TTVPlayerStateAction *)action state:(TTVPlayerStateModel *)state
{
    [super actionChangeCallbackWithAction:action state:state];
    if (![action isKindOfClass:[TTVPlayerStateAction class]] || ![state isKindOfClass:[TTVPlayerStateModel class]]) {
        return;
    }
    switch (action.actionType) {
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
            [[TTVResolutionStore sharedInstance] reset];
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
        case TTVPlayerEventTypeShowVideoFirstFrame:{
            [TTVResolutionStore sharedInstance].actual_clarity = self.playerStateStore.state.currentResolution;
        }
            break;
        default:
            break;
    }
}

- (void)ttv_kvo
{
    [super ttv_kvo];
    @weakify(self);
    [self.KVOController observe:self.playerStateStore.state keyPath:@keypath(self.playerStateStore.state,resolutionState) options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld block:^(id  _Nullable observer, id  _Nonnull object, NSDictionary<NSString *,id> * _Nonnull change) {
        @strongify(self);
        if (self.playerStateStore.state.resolutionState == TTVResolutionStateChanging) {
            if (self.playerStateStore.state.duration > 0) {
                [TTVResolutionStore sharedInstance].clarity_change_time = self.playerStateStore.state.currentPlaybackTime/self.playerStateStore.state.duration * 100;
            }
        }else if (self.playerStateStore.state.resolutionState == TTVResolutionStateEnd){
            [TTVResolutionStore sharedInstance].actual_clarity = self.playerStateStore.state.currentResolution;
        }
    }];
    
    [self.KVOController observe:self.playerStateStore.state keyPath:@keypath(self.playerStateStore.state,currentResolution) options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld block:^(id  _Nullable observer, id  _Nonnull object, NSDictionary<NSString *,id> * _Nonnull change) {
        @strongify(self);
        [TTVResolutionStore sharedInstance].actual_clarity = self.playerStateStore.state.currentResolution;
    }];
}

#pragma mark float auto play
- (void)sendVideoAutoPlayTrack
{
    NSMutableDictionary *dict = [self ttv_dictWithEvent:@"video_auto_play" label:[self ttv_dataTrackLabel]];
    [dict setValue:[self.playerStateStore.state ttv_position] forKey:@"position"];
    if ([self extraFromEvent:@"video_auto_play"].count > 0) {
        [dict addEntriesFromDictionary:[self extraFromEvent:@"video_auto_play"]];
    }
    [TTTrackerWrapper eventData:dict];
}

- (void)sendVideoAutoOverTrack
{
    NSMutableDictionary *dict = [self ttv_dictWithEvent:@"video_auto_over" label:[self ttv_dataTrackLabel]];
    if ([self extraFromEvent:@"video_auto_over"].count > 0) {
        [dict addEntriesFromDictionary:[self extraFromEvent:@"video_auto_over"]];
    }
    [dict setValue:[self.playerStateStore.state ttv_position] forKey:@"position"];
    [dict setValue:@"high" forKey:@"version_type"];
    [TTTrackerWrapper eventData:dict];
}


@end
