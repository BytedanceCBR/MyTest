//
//  TTVDemanderPlayerTracker.m
//  Article
//
//  Created by panxiang on 2017/6/2.
//
//

#import "TTVDemanderPlayerTracker.h"
#import "TTVResolutionStore.h"
#import "TTVPlayerStateStore.h"
#import "KVOController.h"

@interface TTVDemanderPlayerTracker ()
{
    BOOL _hasEnterFullScreen;
    NSTimeInterval _oneFrameDuration;
    NSDate *_clickVideoTime;
}
@end

@implementation TTVDemanderPlayerTracker
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

- (void)sendPlayOneFrameTrack
{
    NSMutableDictionary *dict = [self ttv_dictWithEvent:@"go_start_play" label:[self ttv_dataTrackLabel]];
    if (_oneFrameDuration > 0) {
        [dict setValue:@((long long)(_oneFrameDuration * 1000.)) forKey:@"load_time"];
    }
    [dict setValue:@"high" forKey:@"version_type"];
    [TTTrackerWrapper eventData:dict];
    _oneFrameDuration = - 1;
}

- (void)sendPlayTrack
{
    if ([self ttv_sendEvenWhenPlayActively]) {
        if (self.playerStateStore.state.isInDetail) {
            [self ttv_sendUmengWithlabel:@"detail_play"];
        }else{
            [self ttv_sendUmengWithlabel:@"feed_play"];
        }
    }
}

- (void)sendEndTrack
{
    BOOL watchOver = self.playerStateStore.state.isPlaybackEnded;
    if (watchOver) {
        //umeng track
        if (self.playerStateStore.state.isInDetail) {
            [self ttv_sendUmengWithlabel:@"detail_over"];
        }else{
            if ([self ttv_sendEvenWhenPlayActively]) {
                [self ttv_sendUmengWithlabel:@"feed_over"];
            }
        }
    }
    else {
        //video_break 只要播放完毕就发
        //umeng track
        if (self.playerStateStore.state.isInDetail) {
            [self ttv_sendUmengWithlabel:@"detail_break"];
        }else {
            if (!self.playerStateStore.state.isAutoPlaying) {
                [self ttv_sendUmengWithlabel:@"feed_break"];
            }

        }
    }
}

- (void)sendPauseTrack
{
    if (self.playerStateStore.state.isInDetail) {
        [self ttv_sendUmengWithlabel:@"detail_pause"];
    }else {
        if ([self ttv_sendEvenWhenPlayActively]) {
            [self ttv_sendUmengWithlabel:@"feed_pause"];
        }
    }
}

- (void)sendContinueTrack
{
    if (self.playerStateStore.state.isInDetail) {
        [self ttv_sendUmengWithlabel:@"detail_continue"];
    }else {
        if ([self ttv_sendEvenWhenPlayActively]) {
            [self ttv_sendUmengWithlabel:@"feed_continue"];
        }
    }
}

- (void)changeClarityTipsClickWithPayload:(NSDictionary *)payload
{
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithCapacity:20];
    [dic setValue:@"internet_lag" forKey:@"info"];
    [dic setValue:self.playerStateStore.state.isFullScreen ? @"fullscreen" : @"notfullscreen"  forKey:@"fullscreen"];
    [dic setValue:[[TTVResolutionStore sharedInstance] actualDefinationtr] forKey:@"clarity_before"];
    [dic setValue:[[TTVResolutionStore sharedInstance] stringWithDefination:[[payload valueForKey:@"resolution_type"] integerValue]] forKey:@"clarity_actual"];
    if (self.playerStateStore.state.extraDic) {
        [dic addEntriesFromDictionary:self.playerStateStore.state.extraDic];
    }
    if ([self extraFromEvent:@"change_clarity_tips_click"].count > 0) {
        [dic addEntriesFromDictionary:[self extraFromEvent:@"change_clarity_tips_click"]];
    }
    [TTTrackerWrapper eventV3:@"change_clarity_tips_click" params:dic isDoubleSending:NO];
}

- (void)changeClarityTipsShow
{
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithCapacity:20];
    [dic setValue:@"internet_lag" forKey:@"info"];
    [dic setValue:self.playerStateStore.state.isFullScreen ? @"fullscreen" : @"notfullscreen"  forKey:@"fullscreen"];
    [dic setValue:[[TTVResolutionStore sharedInstance] actualDefinationtr] forKey:@"clarity_actual"];
    if (self.playerStateStore.state.playerModel.commonExtra) {
        [dic addEntriesFromDictionary:self.playerStateStore.state.playerModel.commonExtra];
    }
    if ([self extraFromEvent:@"change_clarity_tips_show"].count > 0) {
        [dic addEntriesFromDictionary:[self extraFromEvent:@"change_clarity_tips_show"]];
    }
    [TTTrackerWrapper eventV3:@"change_clarity_tips_show" params:dic isDoubleSending:NO];
}

- (void)sendSwitchResolutionAutoTrack
{
    NSString *str = nil;
    if (self.playerStateStore.state.currentResolution == TTVPlayerResolutionTypeHD) {
        str = @"480P";
    } else if (self.playerStateStore.state.currentResolution == TTVPlayerResolutionTypeFullHD) {
        str = @"720P";
    }
    if (str) {
        NSMutableDictionary *extra = [[NSMutableDictionary alloc] initWithCapacity:2];
        str = [str uppercaseString];
        [extra setValue:str forKey:@"select_type"];
        [extra addEntriesFromDictionary:self.playerStateStore.state.playerModel.commonExtra];
        [TTTrackerWrapper ttTrackEventWithCustomKeys:@"video" label:@"clarity_auto_select" value:self.playerStateStore.state.playerModel.groupID source:nil extraDic:extra];
    }
}

- (void)sendEnterFullScreenTrack
{
    if (self.playerStateStore.state.playerModel.enableResolution) {
        NSDictionary *extra = @{@"num" : [@(self.playerStateStore.state.supportedResolutionTypes.count) stringValue]};
        wrapperTrackEventWithCustomKeys(@"video", @"clarity_show", self.groupID, nil, extra);
    }

    NSString *type = self.playerStateStore.state.enableRotate ? @"landscape" : @"portrait";
    NSString *lable = self.playerStateStore.state.isInDetail ? @"detail_fullscreen" : @"feed_fullscreen";
    NSMutableDictionary *dict = [self ttv_dictWithEvent:@"video" label:lable];
    [dict setValue:type forKey:@"fullscreen_type"];
    [TTTrackerWrapper eventData:dict];
}

- (void)existFullScreenTrack:(TTVPlayerExitFullScreeenType)type
{
    NSString *label = @"fullscreen_exit";
    switch (type) {
        case TTVPlayerExitFullScreeenTypeBackButton:
            label = self.playerStateStore.state.isInDetail ? @"fullscreen_exit_back_button_detail" : @"fullscreen_exit_back_button_list";
            break;
        case TTVPlayerExitFullScreeenTypeFullButton:
        case TTVPlayerExitFullScreeenTypeGravity:
            label = self.playerStateStore.state.isInDetail ? @"fullscreen_exit_normal_detail" : @"fullscreen_exit_normal_list";
            break;
        default:
            break;
    }
    [self ttv_sendUmengWithlabel:label];
}

- (void)sendMoveProgressBarTrackFromTime:(NSTimeInterval)fromTime toTime:(NSTimeInterval)toTime
{
    //umeng track
    NSTimeInterval duration = self.playerStateStore.state.duration;
    if (duration <= 0) {
        return;
    }
    if (self.playerStateStore.state.isInDetail) {
        [self ttv_sendUmengWithlabel:@"detail_move_bar"];
    }else {
        [self ttv_sendUmengWithlabel:@"feed_move_bar"];
    }

    NSMutableDictionary *extra = [NSMutableDictionary dictionary];
    NSTimeInterval interval = toTime - fromTime;
    [extra setValue:self.itemID forKey:@"item_id"];
    [extra setValue:@((int)interval) forKey:@"drag_time"];
    [extra setValue:@((int)(interval / duration * 100)) forKey:@"drag_pct"];
    [extra setValue:[self.playerStateStore.state ttv_position] forKey:@"position"];
    wrapperTrackEventWithCustomKeys(@"drag_bar", @"video_bar", self.groupID, nil, extra);
}


- (void)sendVideoFinishUITrackWithEvent:(NSString *)event prefix:(NSString *)prefix
{
    NSString *label = [self ttv_dataTrackLabel];
    if ([prefix isEqualToString:@"show"]) {
        label = [label stringByReplacingOccurrencesOfString:@"click" withString:prefix];
    }
    NSString *position = nil;
    if (self.playerStateStore.state.isInDetail) {
        position = @"detail_video_over";
    } else{
        position = @"list_video_over";
    }

    NSMutableDictionary *dict = [self ttv_dictWithEvent:event label:label];
    [dict setValue:position forKey:@"position"];
    [TTTrackerWrapper eventData:dict];
}

- (void)sendControlViewClickTrack
{
    //主视频发两次,一个浮层一个原有的.
    if (self.playerStateStore.state.isInDetail) {
        wrapperTrackEvent(@"video", @"detail_click_screen");
    } else{
        wrapperTrackEvent(@"video", @"feed_click_screen");
    }
}

- (void)actionChangeCallbackWithAction:(TTVPlayerStateAction *)action state:(TTVPlayerStateModel *)state
{
    [super actionChangeCallbackWithAction:action state:state];
    if (![action isKindOfClass:[TTVPlayerStateAction class]] || ![state isKindOfClass:[TTVPlayerStateModel class]]) {
        return;
    }
    switch (action.actionType) {
        case TTVPlayerEventTypeShowVideoFirstFrame:{
            _oneFrameDuration = [[NSDate date] timeIntervalSinceDate:_clickVideoTime];
            [self sendPlayOneFrameTrack];
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
        case TTVPlayerEventTypeSwitchResolution:{
            NSMutableDictionary *dic = action.payload;
            if (!dic) {
                return;
            }
            NSNumber *numberAuto = [dic valueForKey:@"is_auto_switch"];
            if ([numberAuto isKindOfClass:[NSNumber class]] &&
                [numberAuto boolValue]) {
                [self sendSwitchResolutionAutoTrack];
            }
        }
            break;
        case TTVPlayerEventTypePlaybackChangeToLowResolutionShow:{
            [self changeClarityTipsShow];
        }
        break;
        case TTVPlayerEventTypePlaybackChangeToLowResolutionClick:{
            NSMutableDictionary *dic = action.payload;
            [self changeClarityTipsClickWithPayload:dic];
        }
        break;
        
        case TTVPlayerEventTypePlayerBeginPlay:{
            _clickVideoTime = [NSDate date];
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
            _clickVideoTime = [NSDate date];
            [self sendPlayTrack];
            [self sendVideoFinishUITrackWithEvent:@"replay" prefix:@"click"];
        }
            break;
        case TTVPlayerEventTypeGoToDetail:{
            [self sendPlayTrack];
        }
            break;
        case TTVPlayerEventTypeRetry:{
            _clickVideoTime = [NSDate date];
            [self sendPlayTrack];
        }
            break;
        case TTVPlayerEventTypeControlViewClickScreen:
            [self sendControlViewClickTrack];
            break;
        case TTVPlayerEventTypeFinishUIShow:
            if (self.playerStateStore.state.playbackState == TTVVideoPlaybackStateFinished) {
                [self sendVideoFinishUITrackWithEvent:@"replay" prefix:@"show"];
                [self sendVideoFinishUITrackWithEvent:@"share" prefix:@"show"];
            }
            break;
        case TTVPlayerEventTypeFinishUIShare:
//            [self sendVideoFinishUITrackWithEvent:@"share" prefix:@"click"];
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

#pragma mark private

- (void)ttv_sendUmengWithlabel:(NSString *)label
{
    [TTTrackerWrapper eventData:[self ttv_dictWithEvent:@"video" label:label]];
}

@end
