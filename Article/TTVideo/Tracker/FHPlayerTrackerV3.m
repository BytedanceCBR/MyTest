//
//  FHPlayerTrackerV3.m
//  Article
//
//  Created by 张静 on 2018/9/20.
//

#import "FHPlayerTrackerV3.h"
#import "TTVPlayerStateStore.h"
#import "KVOController.h"
//#import "Bubble-Swift.h"
#import "FHEnvContext.h"

@interface FHPlayerTrackerV3 ()
{
    BOOL _hasEnterFullScreen;
    NSTimeInterval _oneFrameDuration;
    NSDate *_clickVideoTime;
}
@end

@implementation FHPlayerTrackerV3

- (instancetype)init
{
    self = [super init];
    if (self) {
    }
    return self;
}

- (void)ttv_kvo
{
    [super ttv_kvo];
    __weak typeof(self) wself = self;
    [self.KVOController observe:self.playerStateStore.state keyPath:@keypath(self.playerStateStore.state,isFullScreen) options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld block:^(id  _Nullable observer, id  _Nonnull object, NSDictionary<NSString *,id> * _Nonnull change) {
        __strong typeof(wself) self = wself;
        if (self.playerStateStore.state.isFullScreen) {
            [self sendEnterFullScreenTrack];
        }else{
            if (self.playerStateStore.state.exitFullScreeenType != TTVPlayerExitFullScreeenTypeUnknow) {
                [self existFullScreenTrack:self.playerStateStore.state.exitFullScreeenType];
            }else{//自动旋转的
                [self existFullScreenTrack:TTVPlayerExitFullScreeenTypeGravity];
            }
        }
        
    }];
}

- (void)sendPauseTrack
{
    [TTTrackerWrapper eventV3:@"video_pause" params:[self commonDicWithEvent:@"video_pause"] isDoubleSending:YES];
}

- (NSMutableDictionary *)commonDicWithEvent:(NSString *)event
{
    NSMutableDictionary *dic = [self.playerStateStore.state ttv_logV3CommonDic];
    if ([self extraFromEvent:event].count > 0) {
        [dic addEntriesFromDictionary:[self extraFromEvent:event]];
    }
    return dic;
}

- (void)sendContinueTrack
{
    if (self.playerStateStore.state.isInDetail || [self ttv_sendEvenWhenPlayActively]) {
        [TTTrackerWrapper eventV3:@"video_continue" params:[self commonDicWithEvent:@"video_continue"] isDoubleSending:YES];
    }
}

- (void)sendEnterFullScreenTrack
{
    NSMutableDictionary *dic = [self commonDicWithEvent:@"enter_fullscreen"];
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setValue:[dic tt_stringValueForKey:@"position"] forKey:@"position"];
    [dict setValue:[dic tt_dictionaryValueForKey:@"log_pb"] forKey:@"log_pb"];
    [dict setValue:[dic tt_stringValueForKey:@"enter_from"] forKey:@"enter_from"];
    [dict setValue:[dic tt_stringValueForKey:@"group_id"] forKey:@"group_id"];
    [dict setValue:[dic tt_stringValueForKey:@"item_id"] forKey:@"item_id"];
    [dict setValue:[dic tt_stringValueForKey:@"category_name"] forKey:@"category_name"];

    NSDictionary *log_pb = [dic tt_dictionaryValueForKey:@"log_pb"];
    NSString *from_gid = [log_pb tt_stringValueForKey:@"from_gid"];
    [dict setValue: from_gid forKey:@"from_gid"];
    
//    [[EnvContext shared].tracer writeEvent:@"enter_fullscreen" params:dict];
    [FHEnvContext recordEvent:dic andEventKey:@"enter_fullscreen"];
}

- (void)existFullScreenTrack:(TTVPlayerExitFullScreeenType)type
{
    NSMutableDictionary *dic = [self commonDicWithEvent:@"exit_fullscreen"];
    [dic setValue:[self ttv_exitFullscreenAction] forKey:@"action_type"];
    [dic setValue:@"landscape" forKey:@"fullscreen_type"];
//    [TTTrackerWrapper eventV3:@"exit_fullscreen" params:dic isDoubleSending:YES];
//    [[EnvContext shared].tracer writeEvent:@"exit_fullscreen" params:dic];
    [FHEnvContext recordEvent:dic andEventKey:@"exit_fullscreen"];

}

- (void)sendMoveProgressBarTrackFromTime:(NSTimeInterval)fromTime toTime:(NSTimeInterval)toTime
{
    //umeng track
    NSTimeInterval duration = self.playerStateStore.state.duration;
    if (duration <= 0) {
        return;
    }
    
    NSMutableDictionary *dic = [self commonDicWithEvent:@"drag_bar"];
    NSTimeInterval interval = toTime - fromTime;
    [dic setValue:@((int)interval) forKey:@"drag_time"];
    [dic setValue:@((int)(interval / duration * 100)) forKey:@"drag_pct"];
    [dic setValue:[self.playerStateStore.state ttv_position] forKey:@"position"];
    [TTTrackerWrapper eventV3:@"drag_bar" params:dic isDoubleSending:YES];
}

- (NSString *)ttv_positionOnVideoOver
{
    if (self.playerStateStore.state.isInDetail) {
        return @"detail_video_over";
    }else{
        return @"list_video_over";
    }
    return nil;
}

- (void)sendVideoFinishUIShowTrack
{
    NSMutableDictionary *dic_replay = [self commonDicWithEvent:@"replay_show"];
    NSMutableDictionary *share_replay = [self commonDicWithEvent:@"share_show"];
    [dic_replay setValue:[self ttv_positionOnVideoOver] forKey:@"position"];
    if (isEmptyString(self.adID)) {
        [TTTrackerWrapper eventV3:@"replay_show" params:dic_replay isDoubleSending:YES];
        [TTTrackerWrapper eventV3:@"share_show" params:share_replay isDoubleSending:YES];
    }
}

- (void)sendControlViewClickTrack
{
    NSMutableDictionary *dic = [self commonDicWithEvent:@"video_click_screen"];
    [TTTrackerWrapper eventV3:@"video_click_screen" params:dic isDoubleSending:@"YES"];
}

- (void)actionChangeCallbackWithAction:(TTVPlayerStateAction *)action state:(TTVPlayerStateModel *)state
{
    [super actionChangeCallbackWithAction:action state:state];
    if (![action isKindOfClass:[TTVPlayerStateAction class]] || ![state isKindOfClass:[TTVPlayerStateModel class]]) {
        return;
    }
    switch (action.actionType) {
        case TTVPlayerEventTypeTrafficFreeFlowPlay:
        case TTVPlayerEventTypeTrafficPlay:{
            [self sendContinueTrack];
        }
            break;
        case TTVPlayerEventTypePlayerContinuePlay:{
            [self sendContinueTrack];
        }
            break;
            
        case TTVPlayerEventTypePlayerPause:{
            [self sendPauseTrack];
        }
            break;
        case TTVPlayerEventTypeFinishUIReplay:{
            NSMutableDictionary *dic = [self commonDicWithEvent:@"replay_click"];
            [dic setValue:[self ttv_positionOnVideoOver] forKey:@"position"];
            [TTTrackerWrapper eventV3:@"replay_click" params:dic isDoubleSending:YES];
        }
            break;
        case TTVPlayerEventTypeControlViewClickScreen:
            [self sendControlViewClickTrack];
            break;
        case TTVPlayerEventTypeFinishUIShow:
            if (self.playerStateStore.state.playbackState == TTVVideoPlaybackStateFinished) {
                [self sendVideoFinishUIShowTrack];
            }
            break;
        case TTVPlayerEventTypeControlViewDragSlider:{
            NSDictionary *object = action.payload;
            if([object isKindOfClass:[NSDictionary class]]){
                NSTimeInterval from = [[object valueForKey:@"fromTime"] doubleValue];
                NSTimeInterval to = [[object valueForKey:@"toTime"] doubleValue];
                [self sendMoveProgressBarTrackFromTime:from toTime:to];
            }
        }
            break;
            
        default:
            break;
    }
}

@end
