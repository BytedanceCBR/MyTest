//
//  ExploreMovieViewTracker.m
//  Article
//
//  Created by Chen Hong on 15/9/21.
//
//

#import "ExploreMovieViewTracker.h"
#import "TTTrackerWrapper.h"
//#import "SSURLTracker.h"
#import "TTURLTracker.h"
#import "TTCategoryDefine.h"
#import "TTAVPlayerItemAccessLog.h"
#import "TTVideoDefinationTracker.h"
#import <TTTracker/TTTrackerProxy.h>
#import "MZMonitor.h"
#import "SSMoviePlayerController.h"
//#import "Bubble-Swift.h"
#import "FHEnvContext.h"

@implementation ExploreMovieViewTracker {
    NSUInteger _watchDurationLogIndex;
    NSMutableDictionary *_extraValue;
    NSMutableDictionary *_extraValueOnEvent;
    NSTimeInterval _oneFrameDuration;
    NSTimeInterval _getUrlTime;
    NSTimeInterval _playUrlTime;
    NSTimeInterval _clickVideoTime;
    BOOL _hasSendEndTrack;//广告第三方监测链接已发送
    BOOL _useTotalWatchDuration;
}

- (void)setType:(ExploreMovieViewType)type
{
    _type = type;
    self.wasInDetail = _type == ExploreMovieViewTypeDetail;
    if (_type == ExploreMovieViewTypeDetail) {
        self.hasEnterDetail = YES;//自动播放埋点需要判断是不是在直接在列表上自动播放，还是从详情页返回列表后续播
    }
}

//主动播放
- (BOOL)sendEvenWhenPlayActively
{
    return !self.isAutoPlaying || self.wasInDetail || self.isReplaying;
}

- (void)sendPlayOneFrameTrack
{
    [self sendVideoThirdMonitorUrl];
    if (_playUrlTime > 0) //广告没有 _playUrlTime 排除广告
    {
        _oneFrameDuration = [[NSDate date] timeIntervalSince1970] - _playUrlTime + _getUrlTime - _clickVideoTime;
        //data track
        NSString * dataLabel = [self dataTrackLabel];
        if (_subType == ExploreMovieViewTypeFloatRelated) {
            dataLabel = @"click_related";
        }
        [self event:@"go_start_play" label:dataLabel value:_gModel.groupID extValue:_aID logExtra:_logExtra needPosition:YES needPercent:NO duration:NO groupModel:_gModel];
        _oneFrameDuration = - 1;
    }
}

- (void)sendGetUrlTrack
{
    _getUrlTime = [[NSDate date] timeIntervalSince1970];
}

- (void)sendPlayUrlTrack
{
    _playUrlTime = [[NSDate date] timeIntervalSince1970];
}

- (void)sendPlayTrack
{
    [self resetStatus];
    _clickVideoTime = [[NSDate date] timeIntervalSince1970];

    BOOL hasSendPlayTrack = NO;
    //umeng track
    if (_type == ExploreMovieViewTypeList) {
        if ([self sendEvenWhenPlayActively]) {
            [self event:@"video" label:@"feed_play" value:_gModel.groupID extValue:_aID logExtra:_logExtra needPosition:NO needPercent:NO duration:NO groupModel:_gModel];
        }
    }
    else if (_type == ExploreMovieViewTypeDetail || _type == ExploreMovieViewTypeVideoFloat_main) {
        [self event:@"video" label:@"detail_play" value:_gModel.groupID extValue:_aID logExtra:_logExtra needPosition:NO needPercent:NO duration:NO groupModel:_gModel];
    }
    else if (_type == ExploreMovieViewTypeVideoFloat_related) {
        [self event:@"video" label:@"float_play" value:_gModel.groupID extValue:_aID logExtra:_logExtra needPosition:NO needPercent:NO duration:NO groupModel:_gModel];
    }
    else if (_type == ExploreMovieViewTypeLiveChatRoom) {
        [self liveTrackLabel:@"video_play" needPercent:NO duration:NO];
        hasSendPlayTrack = YES;
    }
    
    //ad track
    if (!isEmptyString(_aID)) {
        if (_type == ExploreMovieViewTypeList) {
            if ([self sendEvenWhenPlayActively]) {
                [self event:@"embeded_ad" label:@"feed_play" value:_aID extValue:_gModel.groupID logExtra:_logExtra needPosition:NO needPercent:NO duration:NO groupModel:_gModel];
                [self mzTrackVideoUrls:self.playTrackUrls adView:self.movieView];
            }
        }
        else if (_type == ExploreMovieViewTypeDetail) {
            [self event:@"embeded_ad" label:@"detail_play" value:_aID extValue:_gModel.groupID logExtra:_logExtra needPosition:NO needPercent:NO duration:NO groupModel:_gModel];
            [self mzTrackVideoUrls:self.playTrackUrls adView:self.movieView];
        }
    }
    
    //ad click track url

    if (![self sendPlayVideoTrackURL]) {
        [self sendADVideoClickTrackURLIfNeed];
    }
    //主动播放
    if ([self sendEvenWhenPlayActively]) {
        [self sendActivePlayVideoTrackURL];
    }

    //data track
    if (!hasSendPlayTrack) {
        if ([self sendEvenWhenPlayActively]) {
            if(_type == ExploreMovieViewTypeUnknow){
                return;
            }
            [self sendVideoPlayTrack];
        }
        else//浮层,自动播放发video_auto_play ,包括主视频的非第一次播放都是video_auto_play
        {
            [self sendVideoAutoPlayTrack];
        }
    }
}

- (void)sendPlayTrackInDetailByAutoPlay
{
    if (!isEmptyString(_aID)) {
        if (_type == ExploreMovieViewTypeDetail) {
            [self event:@"embeded_ad" label:@"detail_play" value:_aID extValue:_gModel.groupID logExtra:_logExtra needPosition:NO needPercent:NO duration:NO groupModel:_gModel];
        }
    }
}

- (void)sendVideoAutoPlayTrack
{
    if ((_type == ExploreMovieViewTypeVideoFloat_main || _type == ExploreMovieViewTypeVideoFloat_related) && !self.wasInDetail) {
        NSString * dataLabel = nil;
        NSString * event = nil;
        if (_isAutoPlaying) {
            event = @"video_auto_play";
            dataLabel = [self dataTrackLabel];
        }
        if (event) {
            [self event:event label:dataLabel value:_gModel.groupID extValue:_aID logExtra:_logExtra needPosition:YES needPercent:NO duration:NO groupModel:_gModel];
        }
    }
}

- (void)resetStatus
{
    _watchDurationLogIndex = 0;
    [_moviePlayerController.accessLog clearEvent];
    self.hasSendPlayEndEvent = NO;
}

- (void)sendEndTrack
{
    if (_hasSendPlayEndEvent) {
        return;
    }
    _hasSendEndTrack = NO;
    BOOL watchOver = _isPlaybackEnded;
    BOOL hasSendVideoOver = NO;
    if (watchOver) {
        //umeng track
        if (_type == ExploreMovieViewTypeList) {
            if ([self sendEvenWhenPlayActively]) {
                [self event:@"video" label:@"feed_over" value:_gModel.groupID extValue:_aID logExtra:_logExtra needPosition:NO needPercent:NO duration:NO groupModel:_gModel];
            }
            else if(self.hasEnterDetail){
                [self event:@"video" label:@"feed_over" value:_gModel.groupID extValue:_aID logExtra:_logExtra needPosition:NO needPercent:NO duration:NO groupModel:_gModel];
            }
        }
        else if (_type == ExploreMovieViewTypeDetail) {
            [self event:@"video" label:@"detail_over" value:_gModel.groupID extValue:_aID logExtra:_logExtra needPosition:NO needPercent:NO duration:NO groupModel:_gModel];
        }
        else if (_type == ExploreMovieViewTypeLiveChatRoom) {
            [self liveTrackLabel:@"video_over" needPercent:NO duration:NO];
            hasSendVideoOver = YES;
        }
        //ad track
        if (!isEmptyString(_aID)) {
            if (_type == ExploreMovieViewTypeList) {
                if ([self sendEvenWhenPlayActively]) {
                    [self event:@"embeded_ad" label:@"feed_over" value:_aID extValue:_gModel.groupID logExtra:_logExtra needPosition:NO needPercent:YES duration:YES groupModel:_gModel];
                    [self mzStopTrack];
                }
            }
            else if (_type == ExploreMovieViewTypeDetail) {
                [self event:@"embeded_ad" label:@"detail_over" value:_aID extValue:_gModel.groupID  logExtra:_logExtra needPosition:NO needPercent:YES duration:YES groupModel:_gModel];
                [self mzStopTrack];
            }

        }
        //data track
        NSString * dataLabel = nil;
        if (_type != ExploreMovieViewTypeVideoFloat_related &&
            _type != ExploreMovieViewTypeVideoFloat_main) {
            
            dataLabel = [self dataTrackLabel];
            if ([self sendEvenWhenPlayActively] || (_type == ExploreMovieViewTypeList && self.hasEnterDetail)) {
                if (!hasSendVideoOver) {
                    [self event:@"video_over" label:dataLabel value:_gModel.groupID extValue:_aID logExtra:_logExtra needPosition:YES needPercent:YES duration:YES groupModel:_gModel];
                    hasSendVideoOver = YES;
                }
            }
        }


    }
    else {
        //video_break 只要播放完毕就发
        //umeng track
        if (_type == ExploreMovieViewTypeList) {
            if (!self.isAutoPlaying) {
                [self event:@"video" label:@"feed_break" value:_gModel.groupID extValue:_aID logExtra:_logExtra needPosition:NO needPercent:NO duration:NO groupModel:_gModel];
            }
        }
        else if (_type == ExploreMovieViewTypeDetail) {
            [self event:@"video" label:@"detail_break" value:_gModel.groupID extValue:_aID logExtra:_logExtra needPosition:NO needPercent:NO duration:NO groupModel:_gModel];
        }
        else if (_type == ExploreMovieViewTypeVideoFloat_main || _type == ExploreMovieViewTypeVideoFloat_related) {
            [self event:@"video" label:@"float_break" value:_gModel.groupID extValue:_aID logExtra:_logExtra needPosition:NO needPercent:NO duration:NO groupModel:_gModel];
        }
        else if (_type == ExploreMovieViewTypeLiveChatRoom) {
            [self liveTrackLabel:@"video_break" needPercent:NO duration:NO];
        }
        //ad track
        if (!isEmptyString(_aID)) {
            if (_type == ExploreMovieViewTypeList) {
                if (!self.isAutoPlaying) {
                    [self event:@"embeded_ad" label:@"feed_break" value:_aID extValue:_gModel.groupID logExtra:_logExtra needPosition:NO needPercent:YES duration:YES groupModel:_gModel];
                    [self mzStopTrack];
                }
            }
            else if (_type == ExploreMovieViewTypeDetail) {
                [self event:@"embeded_ad" label:@"detail_break" value:_aID extValue:_gModel.groupID logExtra:_logExtra needPosition:NO needPercent:YES duration:YES groupModel:_gModel];
                [self mzStopTrack];
            }
        }
        if ([self sendEvenWhenPlayActively] ||
            _type == ExploreMovieViewTypeVideoFloat_related ||
            _type == ExploreMovieViewTypeVideoFloat_main ||
            (_type == ExploreMovieViewTypeList && self.hasEnterDetail)) {
            //data track
            NSString * dataLabel = [self dataTrackLabel];
            if (_type == ExploreMovieViewTypeVideoFloat_related) {
                [self event:@"video_auto_over" label:@"click_related" value:_gModel.groupID extValue:_aID logExtra:_logExtra needPosition:YES needPercent:YES duration:YES groupModel:_gModel];
                hasSendVideoOver = YES;
            }
            else
            {
                [self event:@"video_over" label:dataLabel value:_gModel.groupID extValue:_aID logExtra:_logExtra needPosition:YES needPercent:YES duration:YES groupModel:_gModel];
                hasSendVideoOver = YES;
            }
        }
    }

    if (!hasSendVideoOver) {
        [self sendEndTrackWhenBreak];
    }

    if (_type == ExploreMovieViewTypeVideoFloat_main) {
        self.hasPlayEndMainVideo = YES;
    }

    if (!_hasSendEndTrack && ![self sendEvenWhenPlayActively])
    {
        if ([self totalWatchedDuration] >= self.effectivePlayTime) {
            [self sendEffectivePlayVideoTrackURL];
        }
        if (_isPlaybackEnded) {
            [self sendPlayOverVideoTrackURL];
            _hasSendEndTrack = YES;
        }
    }
    _hasSendEndTrack = NO;
}

- (BOOL)sendEndTrackWhenBreak
{
    NSString *dataLabel = [self dataTrackLabel];
    if (_type == ExploreMovieViewTypeDetail) {
        if (self.subType == ExploreMovieViewTypeFloatRelated) {
            [self event:@"video_over" label:@"click_related" value:_gModel.groupID extValue:_aID logExtra:_logExtra needPosition:YES needPercent:YES duration:YES groupModel:_gModel];
            return YES;
        }
        else if (self.subType == ExploreMovieViewTypeFloatMain) {
            [self event:@"video_over" label:dataLabel value:_gModel.groupID extValue:_aID logExtra:_logExtra needPosition:YES needPercent:YES duration:YES groupModel:_gModel];
            return YES;
        }
    }

    //data track
    if ([self sendEvenWhenPlayActively]) {
        [self event:@"video_over" label:dataLabel value:_gModel.groupID extValue:_aID logExtra:_logExtra needPosition:YES needPercent:YES duration:YES groupModel:_gModel];
        return YES;
    }
    else if (_type == ExploreMovieViewTypeVideoFloat_related ||
             _type == ExploreMovieViewTypeVideoFloat_main)
    {
        if (_isAutoPlaying) {
            if (_type == ExploreMovieViewTypeVideoFloat_related) {
                [self event:@"video_auto_over" label:@"click_related" value:_gModel.groupID extValue:_aID logExtra:_logExtra needPosition:YES needPercent:YES duration:YES groupModel:_gModel];
            }
            else if(_type == ExploreMovieViewTypeVideoFloat_main)
            {
                [self event:@"video_auto_over" label:dataLabel value:_gModel.groupID extValue:_aID logExtra:_logExtra needPosition:YES needPercent:YES duration:YES groupModel:_gModel];
            }
            return YES;
        }
    }
    return NO;
}

- (NSTimeInterval)totalWatchedDuration
{
    [_moviePlayerController.accessLog willReadWatchedDuration];
    NSTimeInterval durationWatched = 0;
    for (TTAVPlayerItemAccessLogEvent * event in _moviePlayerController.accessLog.events) {
        durationWatched += event.durationWatched;
    }
    return durationWatched;
}

- (void)sendPauseTrack
{
    //umeng track
    if (_type == ExploreMovieViewTypeList) {
        if ([self sendEvenWhenPlayActively]) {
            [self event:@"video" label:@"feed_pause" value:_gModel.groupID extValue:_aID logExtra:_logExtra needPosition:NO needPercent:NO duration:NO groupModel:_gModel];
        }
    }
    else if (_type == ExploreMovieViewTypeDetail) {
        [self event:@"video" label:@"detail_pause" value:_gModel.groupID extValue:_aID logExtra:_logExtra needPosition:NO needPercent:NO duration:NO groupModel:_gModel];
    }
    else if (_type == ExploreMovieViewTypeVideoFloat_main || _type == ExploreMovieViewTypeVideoFloat_related) {
        [self event:@"video" label:@"float_pause" value:_gModel.groupID extValue:_aID logExtra:_logExtra needPosition:NO needPercent:NO duration:NO groupModel:_gModel];
    }
    else if (_type == ExploreMovieViewTypeLiveChatRoom) {
        [self liveTrackLabel:@"video_pause" needPercent:NO duration:NO];
    }
    //ad track
    if (!isEmptyString(_aID)) {
        if (_type == ExploreMovieViewTypeList) {
            if ([self sendEvenWhenPlayActively]) {
                [self event:@"embeded_ad" label:@"feed_pause" value:_aID extValue:_gModel.groupID logExtra:_logExtra needPosition:NO needPercent:NO duration:NO groupModel:_gModel];
            }
        }
        else if (_type == ExploreMovieViewTypeDetail) {
            [self event:@"embeded_ad" label:@"detail_pause" value:_aID extValue:_gModel.groupID logExtra:_logExtra needPosition:NO needPercent:NO duration:NO groupModel:_gModel];
        }
    }
    //data track
    
    //    NSLog(@"pause");
}

- (void)sendContinueTrack
{
    //umeng track
    if (_type == ExploreMovieViewTypeList) {
        if ([self sendEvenWhenPlayActively]) {
            [self event:@"video" label:@"feed_continue" value:_gModel.groupID extValue:_aID logExtra:_logExtra needPosition:NO needPercent:NO duration:NO groupModel:_gModel];
        }
    }
    else if (_type == ExploreMovieViewTypeDetail) {
        [self event:@"video" label:@"detail_continue" value:_gModel.groupID extValue:_aID logExtra:_logExtra needPosition:NO needPercent:NO duration:NO groupModel:_gModel];
    }
    else if (_type == ExploreMovieViewTypeVideoFloat_main || _type == ExploreMovieViewTypeVideoFloat_related)
    {
        [self event:@"video" label:@"float_continue" value:_gModel.groupID extValue:_aID logExtra:_logExtra needPosition:NO needPercent:NO duration:NO groupModel:_gModel];
    }
    else if (_type == ExploreMovieViewTypeLiveChatRoom)
    {
        [self liveTrackLabel:@"video_fullscreen_play" needPercent:NO duration:NO];
    }
    //ad track
    if (!isEmptyString(_aID)) {
        if (_type == ExploreMovieViewTypeList) {
            if ([self sendEvenWhenPlayActively]) {
                [self event:@"embeded_ad" label:@"feed_continue" value:_aID extValue:_gModel.groupID logExtra:_logExtra needPosition:NO needPercent:NO duration:NO groupModel:_gModel];
            }
        }
        else if (_type == ExploreMovieViewTypeDetail) {
            [self event:@"embeded_ad" label:@"detail_continue" value:_aID extValue:_gModel.groupID logExtra:_logExtra needPosition:NO needPercent:NO duration:NO groupModel:_gModel];
        }
    }
    //data track
}

- (void)sendEnterFullScreenTrack
{
    
    [self sendFHEnterFullScreenTrack];
    
    NSString *type = _enableRotate ? @"landscape" : @"portrait";
    [self addExtraValue:type forKey:@"fullscreen_type"];
    //umeng track
    if (_type == ExploreMovieViewTypeList) {
        [self event:@"video" label:@"feed_fullscreen" value:_gModel.groupID extValue:_aID logExtra:_logExtra needPosition:NO needPercent:NO duration:NO groupModel:_gModel];
    }
    else if (_type == ExploreMovieViewTypeDetail) {
        [self event:@"video" label:@"detail_fullscreen" value:_gModel.groupID extValue:_aID logExtra:_logExtra needPosition:NO needPercent:NO duration:NO groupModel:_gModel];
    }
    else if (_type == ExploreMovieViewTypeVideoFloat_main || _type == ExploreMovieViewTypeVideoFloat_related) {
        [self event:@"video" label:@"float_fullscreen" value:_gModel.groupID extValue:_aID logExtra:_logExtra needPosition:NO needPercent:NO duration:NO groupModel:_gModel];
    }
    else if (_type == ExploreMovieViewTypeLiveChatRoom) {
        [self liveTrackLabel:@"video_fullscreen" needPercent:NO duration:NO];
    }
    //ad track
    if (!isEmptyString(_aID)) {
        if (_type == ExploreMovieViewTypeList) {
            [self event:@"embeded_ad" label:@"feed_fullscreen" value:_aID extValue:_gModel.groupID logExtra:_logExtra needPosition:NO needPercent:NO duration:NO groupModel:_gModel];
        }
        else if (_type == ExploreMovieViewTypeDetail) {
            [self event:@"embeded_ad" label:@"detail_fullscreen" value:_aID extValue:_gModel.groupID logExtra:_logExtra needPosition:NO needPercent:NO duration:NO groupModel:_gModel];
        }
    }
    [self removeExtraValueForKey:@"fullscreen_type"];
    //data track
}

- (void)sendFHEnterFullScreenTrack
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setValue:@"list" forKey:@"position"];
    [dict setValue:[_extraValue tt_dictionaryValueForKey:@"log_pb"]  forKey:@"log_pb"];
    [dict setValue:[self enterFrom] forKey:@"enter_from"];
    [dict setValue:_gModel.groupID forKey:@"group_id"];
    [dict setValue:_gModel.itemID forKey:@"item_id"];
    [dict setValue:[self categroyNameV3] forKey:@"category_name"];
    NSDictionary *log_pb = [_extraValue tt_dictionaryValueForKey:@"log_pb"];
    NSString *from_gid = [log_pb tt_stringValueForKey:@"from_gid"];
    [dict setValue: from_gid forKey:@"from_gid"];

//    [[EnvContext shared].tracer writeEvent:@"enter_fullscreen" params:dict];
    [FHEnvContext recordEvent:dict andEventKey:@"enter_fullscreen"];
}

- (void)sendExistFullScreenTrack:(BOOL)sendByFullScreenButton
{
    //umeng track
    if (_type == ExploreMovieViewTypeLiveChatRoom) {
        [self liveTrackLabel:@"video_fullscreen_exit" needPercent:NO duration:NO];
    }
    else {
        NSString *label = @"fullscreen_exit";
        if (sendByFullScreenButton) {
            if (self.type == ExploreMovieViewTypeList) {
                label = @"fullscreen_exit_normal_list";
            } else if (self.type == ExploreMovieViewTypeDetail) {
                label = @"fullscreen_exit_normal_detail";
            }
            else if (_type == ExploreMovieViewTypeVideoFloat_main || _type == ExploreMovieViewTypeVideoFloat_related) {
                label = @"fullscreen_exit_normal_float";
            }
        } else {
            if (self.type == ExploreMovieViewTypeList) {
                label = @"fullscreen_exit_back_button_list";
            } else if (self.type == ExploreMovieViewTypeDetail) {
                label = @"fullscreen_exit_back_button_detail";
            }
            else if (_type == ExploreMovieViewTypeVideoFloat_main || _type == ExploreMovieViewTypeVideoFloat_related) {
                label = @"fullscreen_exit_back_button_float";
            }
        }
        [self event:@"video" label:label value:_gModel.groupID extValue:_aID logExtra:_logExtra needPosition:NO needPercent:NO duration:NO groupModel:_gModel];
    }
    
    //ad track
    
    //data track
}

- (void)sendMoveProgressBarTrackFromTime:(NSTimeInterval)fromTime toTime:(NSTimeInterval)toTime
{
    //umeng track
    
    if (_type == ExploreMovieViewTypeList) {
        [self event:@"video" label:@"feed_move_bar" value:_gModel.groupID extValue:_aID logExtra:_logExtra needPosition:NO needPercent:NO duration:NO groupModel:_gModel];
    }
    else if (_type == ExploreMovieViewTypeDetail) {
        [self event:@"video" label:@"detail_move_bar" value:_gModel.groupID extValue:_aID logExtra:_logExtra needPosition:NO needPercent:NO duration:NO groupModel:_gModel];
    }
    else if (_type == ExploreMovieViewTypeVideoFloat_main || _type == ExploreMovieViewTypeVideoFloat_related) {
        [self event:@"video" label:@"float_move_bar" value:_gModel.groupID extValue:_aID logExtra:_logExtra needPosition:NO needPercent:NO duration:NO groupModel:_gModel];
    }
    else if (_type == ExploreMovieViewTypeLiveChatRoom) {
        [self liveTrackLabel:@"video_drag_bar" needPercent:NO duration:NO];
    }
    
    [self trackDragEventFromTime:fromTime toTime:toTime groupModel:_gModel type:_type];

}

- (void)sendVideoPlayTrack
{
    NSString * dataLabel = [self dataTrackLabel];
    NSString * event = nil;

    if (_type == ExploreMovieViewTypeVideoFloat_main) {
        event = @"video_play";
        dataLabel = [self dataTrackLabel];
    }
    else if (_type == ExploreMovieViewTypeVideoFloat_related) {
        event = self.isReplaying ? @"video_play" : @"video_auto_play";
        dataLabel = @"click_related";
    }
    else
    {
        event = @"video_play";
    }
    
   

    if (event) {
        if ([event isEqualToString:@"video_play"]) {
            
            [self sendFHVideoPlayEventWithLabel:dataLabel];
//            [self sendVideoPlayEventV3WithLabel:dataLabel isDoubleSending:YES];
        }
        if ([TTTrackerWrapper isOnlyV3SendingEnable] && [event isEqualToString:@"video_play"]) {
        } else {
//            [self event:event label:dataLabel value:_gModel.groupID extValue:_aID logExtra:_logExtra needPosition:YES needPercent:NO duration:NO groupModel:_gModel];
            
        }
    }

}

- (void)sendTraceVideoOver:(NSDictionary *)dictVideo
{
    NSMutableDictionary *traceParams = [NSMutableDictionary dictionary];
    [traceParams setValue:@"house_app2c_v2" forKey:@"event_type"];
    [traceParams setValue:dictVideo[@"group_id"] forKey:@"group_id"];
    
    [traceParams setValue:dictVideo[@"item_id"] forKey:@"item_id"];
    
    NSDictionary *dictLogPb = dictVideo[@"log_pb"];
    if ([dictLogPb isKindOfClass:[NSDictionary class]]) {
        [traceParams setValue:dictLogPb[@"impr_id"] forKey:@"impr_id"];
    }
    
    [traceParams setValue:@"click_category" forKey:@"enter_from"];
    [traceParams setValue:[self categroyNameV3] forKey:@"category_name"];
    
    [traceParams setValue:dictVideo[@"log_pb"] forKey:@"log_pb"];
    [traceParams setValue:dictVideo[@"position"] forKey:@"position"];
    [traceParams setValue:dictVideo[@"duration"] forKey:@"duration"];
    [traceParams setValue:dictVideo[@"percent"] forKey:@"percent"];
    
    [TTTracker eventV3:@"video_over" params:traceParams];
}

- (void)sendFHVideoPlayEventWithLabel:(NSString *)dataLabel{
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setValue:_gModel.groupID forKey:@"group_id"];
    [dict setValue:_gModel.itemID forKey:@"item_id"];
    
    [dict setValue:[self enterFrom] forKey:@"enter_from"];
    [dict setValue:[self categroyNameV3] forKey:@"category_name"];
    
    NSString *position = [self positionString];
    [dict setValue:position forKey:@"position"];

    NSDictionary *log_pb = [_extraValue dictionaryValueForKey:@"log_pb" defalutValue:@{}];
    if (log_pb.count > 0) {
        
        [dict setValue:log_pb forKey:@"log_pb"];
    }

//    [[EnvContext shared].tracer writeEvent:@"video_play" params:dict];
    [FHEnvContext recordEvent:dict andEventKey:@"video_play"];
}

- (void)sendVideoPlayEventV3WithLabel:(NSString *)dataLabel isDoubleSending:(BOOL)animation{
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithCapacity:10];
    NSString *position = [self positionString];
    [dic setValue:[self enterFrom] forKey:@"enter_from"];
    [dic setValue:[self categroyNameV3] forKey:@"category_name"];
    [dic setValue:position forKey:@"position"];
    [dic addEntriesFromDictionary:_extraValue];
    [dic setValue:self.authorId forKey:@"author_id"];
    [TTTrackerWrapper eventV3:@"video_play" params:dic isDoubleSending:animation];
}

- (void)sendVideoOverEventV3WithLabel:(NSString *)label andDuration:(NSInteger)duration isDoubleSend:(BOOL)animation{
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithCapacity:20];
    NSString *position = [self positionString];
    if (self.moviePlayerController.duration > 0) {
        NSInteger percent = [self playPercent];
        [dic setValue:@(percent) forKey:@"percent"];
    }
    if ((duration + self.preResolutionWatchingDuration) >= 0) {
        [dic setValue:@(MAX(duration, 0) + self.preResolutionWatchingDuration) forKey:@"duration"];
    }
    
    [dic setValue:@"high" forKey:@"vertion_type"];
    [dic setValue:position forKey:@"position"];
    [dic setValue:@([TTVideoDefinationTracker sharedTTVideoDefinationTracker].definationNumber) forKey:@"clarity_num"];
    [dic setValue:[[TTVideoDefinationTracker sharedTTVideoDefinationTracker] lastDefinationStr] forKey:@"clarity_choose"];
    [dic setValue:[[TTVideoDefinationTracker sharedTTVideoDefinationTracker] actualDefinationtr] forKey:@"clarity_actual"];
    [dic setValue:@([TTVideoDefinationTracker sharedTTVideoDefinationTracker].clarity_change_time) forKey:@"clarity_change_time"];
    [dic setValue: [self enterFrom] forKey:@"enter_from"];
    [dic setValue:[self categroyNameV3] forKey:@"category_name"];
    [dic addEntriesFromDictionary:_extraValue];
    [dic setValue:self.authorId forKey:@"author_id"];
    
    [self sendTraceVideoOver:dic];
    
    [TTTrackerWrapper eventV3:@"video_over" params:dic isDoubleSending:animation];
}

- (void)trackDragEventFromTime:(NSTimeInterval)fromTime
                toTime:(NSTimeInterval)toTime
            groupModel:(TTGroupModel *)model
                  type:(ExploreMovieViewType)type
{
    if (self.moviePlayerController.duration <= 0) {
        return;
    }
    NSMutableDictionary *extra = [NSMutableDictionary dictionary];
    NSTimeInterval interval = toTime - fromTime;
    [extra setValue:model.itemID forKey:@"item_id"];
    [extra setValue:@((int)interval) forKey:@"drag_time"];
    [extra setValue:@((int)(interval / self.moviePlayerController.duration * 100)) forKey:@"drag_pct"];
    if (_type == ExploreMovieViewTypeVideoFloat_main || _type == ExploreMovieViewTypeVideoFloat_related) {
        [extra setValue:@"float" forKey:@"video_position"];
    }
    [extra setValue:[self positionWithType:type] forKey:@"position"];

    wrapperTrackEventWithCustomKeys(@"drag_bar", @"video_bar", model.groupID, nil, extra);
}

- (NSString *)positionWithType:(ExploreMovieViewType)type
{
    if (type == ExploreMovieViewTypeDetail) {
        return @"detail";
    }
    else if (_type == ExploreMovieViewTypeVideoFloat_main || _type == ExploreMovieViewTypeVideoFloat_related) {
        return @"detail";
    }
    else if (type == ExploreMovieViewTypeList) {
        return @"list";
    }
    return nil;
}

- (NSString *)dataTrackLabel
{
    NSString * dataLabel = nil;
    if (!isEmptyString(_gdLabel)) {
        dataLabel = _gdLabel;
    }
    else {
        if ([_cID isEqualToString:kTTMainCategoryID]) {
            dataLabel = [NSString stringWithFormat:@"click_headline"];
        }
        else
        {
            if (!isEmptyString(_cID)) {
                BOOL hasPrefix = [_cID hasPrefix:@"_"]; //特殊处理cID是_favorite的情况
                NSString *click = hasPrefix ? @"click" : @"click_";
                dataLabel = [NSString stringWithFormat:@"%@%@", click,_cID];

            }
        }
    }
    if (!dataLabel) {
        dataLabel = @"click_unknown";
    }
    return dataLabel;
}

- (NSString *)enterFrom{
    NSString * enterFrom = nil;
    if (!isEmptyString(_cID) && ![_cID isEqualToString:@"xx"]) {
        if ([_cID isEqualToString:@"__all__"]) {
            enterFrom = @"click_headline";
        }else{
            enterFrom = @"click_category";
        }
    }
    if (isEmptyString(enterFrom)) {
        if (!isEmptyString(_gdLabel)) {
            enterFrom = _gdLabel;
        }
    }
    if (!enterFrom) {
        enterFrom = @"click_unknow";
    }
    return enterFrom;
}

- (NSString *)categroyNameV3
{
    NSString *categoryName = _cID;
    if (isEmptyString(categoryName) || [_cID isEqualToString:@"xx"]){
        categoryName = [[self enterFrom] stringByReplacingOccurrencesOfString:@"click_" withString:@""];
    }
    return categoryName;
}

- (NSTimeInterval)watchedDuration
{
    [_moviePlayerController.accessLog willReadWatchedDuration];
    NSTimeInterval durationWatched = 0;
    NSUInteger logIndex = 0;

    for (TTAVPlayerItemAccessLogEvent * event in _moviePlayerController.accessLog.events) {
        if (logIndex++ < _watchDurationLogIndex) {
            // 忽略之前已发送过的时长
            continue;
        }
        durationWatched += event.durationWatched;
    }
    return durationWatched;
}

- (void)updateWatchDurationLogIndex {
    _watchDurationLogIndex = _moviePlayerController.accessLog.events.count;
}

- (void)event:(NSString *)event
        label:(NSString *)label
        value:(NSString *)value
     extValue:(NSString *)extValue
     logExtra:(NSString *)logExtra
 needPosition:(BOOL)needPosition
  needPercent:(BOOL)needPercent
     duration:(BOOL)duration
   groupModel:(TTGroupModel *)groupModel
{
    [self event:event label:label value:value extValue:extValue logExtra:logExtra needPosition:needPosition needPercent:needPercent needOneFrameTime:NO duration:duration groupModel:groupModel];
}

- (NSString *)positionString
{
    if (_type == ExploreMovieViewTypeDetail ||
        _type == ExploreMovieViewTypeVideoFloat_main ||
        _type == ExploreMovieViewTypeVideoFloat_related) {
        return @"detail";
    }
    else if (_type == ExploreMovieViewTypeList) {
        return @"list";
    }
    return nil;
}

- (NSInteger)playPercent
{
    NSInteger percent = 0;
    if (_isPlaybackEnded) {
        percent = 100;
    } else {
        percent = (NSInteger)((((CGFloat)self.moviePlayerController.playbackTime / (CGFloat)self.moviePlayerController.duration)) * 100.f);
    }
    return percent;
}

- (void)event:(NSString *)event
        label:(NSString *)label
        value:(NSString *)value
     extValue:(NSString *)extValue
     logExtra:(NSString *)logExtra
 needPosition:(BOOL)needPosition
  needPercent:(BOOL)needPercent
needOneFrameTime:(BOOL)needOneFrameTime
     duration:(BOOL)duration
   groupModel:(TTGroupModel *)groupModel
{
    NSString *position = nil;
    if (needPosition) {
        position = [self positionString];
    }
    
    NSInteger percent = -1;
    if (needPercent && self.moviePlayerController.duration > 0) {
        percent = [self playPercent];
    }
    
    NSUInteger watchDuration = -1;
    if (duration) {
        watchDuration = 0;
        watchDuration = (NSUInteger)([self watchedDuration] * 1000.f);
        // 记录下次统计开始的accessLogIndex
        BOOL isOver = ([event rangeOfString:@"_break"].location != NSNotFound || [event rangeOfString:@"_over"].location != NSNotFound ||
                       [label rangeOfString:@"_break"].location != NSNotFound || [label rangeOfString:@"_over"].location != NSNotFound);
        //可能会发多个种over,所以不能 updateWatchDurationLogIndex
        if (!isOver) {
            [self updateWatchDurationLogIndex];
        }
    }
    [self event:event label:label value:value extValue:extValue logExtra:logExtra position:position percent:percent duration:watchDuration groupModel:groupModel];
}

- (BOOL)canSendValidADTrackWithLabel:(NSString *)label duration:(CGFloat)duration
{
    return ([label rangeOfString:@"_over"].location != NSNotFound
            || [label rangeOfString:@"_break"].location != NSNotFound) && duration >= self.effectivePlayTime;
}

- (void)event:(NSString *)event
        label:(NSString *)label
        value:(NSString *)value
     extValue:(NSString *)extValue
     logExtra:(NSString *)logExtra
     position:(NSString *)position
      percent:(NSInteger)percent
     duration:(NSInteger)duration
   groupModel:(TTGroupModel *)groupModel
{
//    if (self.cancelSendEnd &&
//        (([event rangeOfString:@"_over"].location != NSNotFound || [label rangeOfString:@"_over"].location != NSNotFound) || ([event rangeOfString:@"_play"].location != NSNotFound || [label rangeOfString:@"_play"].location != NSNotFound)) &&
//        (_type == ExploreMovieViewTypeVideoFloat_main)) {
//        return;
//    }
    if (isEmptyString(event) || isEmptyString(label)) {
        return;
    }
    if ([self canSendValidADTrackWithLabel:label duration:duration]) {
        [self sendEffectivePlayVideoTrackURL];
    }
    if ([event rangeOfString:@"_over"].location != NSNotFound ||
        [label rangeOfString:@"_break"].location != NSNotFound) {
        self.hasSendPlayEndEvent = YES;
    }

    if (!_hasSendEndTrack) {
        if ([label rangeOfString:@"_over"].location != NSNotFound) {
            [self sendPlayOverVideoTrackURL];
            _hasSendEndTrack = YES;
        }
    }
    NSMutableDictionary * dict = [NSMutableDictionary dictionaryWithCapacity:10];
    [dict setValue:@"umeng" forKey:@"category"];
    [dict setValue:event forKey:@"tag"];
    [dict setValue:extValue forKey:@"ext_value"];
    [dict setValue:label forKey:@"label"];
    [dict setValue:value forKey:@"value"];
    [dict setValue:groupModel.itemID forKey:@"item_id"];
    [dict setValue:@(groupModel.aggrType) forKey:@"aggr_type"];
    TTInstallNetworkConnection connectionType = [[TTTrackerProxy sharedProxy] connectionType];
    [dict setValue:@(connectionType) forKey:@"nt"];
    if (_oneFrameDuration > 0) {
        [dict setValue:@((long long)(_oneFrameDuration * 1000.)) forKey:@"load_time"];
    }

    if (_aID.length > 0) {
        if ([event rangeOfString:@"_over"].location != NSNotFound
            || [event rangeOfString:@"_play"].location != NSNotFound) {
            [dict setValue:_aID forKey:@"ad_id"];
        }
        [dict setValue:@"1" forKey:@"is_ad_event"];
    }

    if ([event isEqualToString:@"video_over"] || [event isEqualToString:@"video_auto_over"]) {
        [dict setValue:@"high" forKey:@"version_type"];
    }
    if (logExtra) {
        [dict setValue:logExtra forKey:@"log_extra"];
    }
    else {
        [dict setValue:@"" forKey:@"log_extra"];
    }
    
    if ([event rangeOfString:@"_over"].location != NSNotFound
        || [event rangeOfString:@"_play"].location != NSNotFound) {
        [dict setValue:self.authorId forKey:@"author_id"];
    }

    if ([event isEqualToString:@"video_over"]) {
        if ([TTVideoDefinationTracker sharedTTVideoDefinationTracker].definationNumber > 0) {
            [dict setValue:@([TTVideoDefinationTracker sharedTTVideoDefinationTracker].definationNumber) forKey:@"clarity_num"];
            [dict setValue:[[TTVideoDefinationTracker sharedTTVideoDefinationTracker] lastDefinationStr] forKey:@"clarity_choose"];
            [dict setValue:[[TTVideoDefinationTracker sharedTTVideoDefinationTracker] actualDefinationtr] forKey:@"clarity_actual"];
            [dict setValue:@([TTVideoDefinationTracker sharedTTVideoDefinationTracker].clarity_change_time) forKey:@"clarity_change_time"];
        }
        [self sendVideoOverEventV3WithLabel:label andDuration:duration isDoubleSend:YES];
    }

    if (position) {
        [dict setValue:position forKey:@"position"];
        if (([event rangeOfString:@"_over"].location != NSNotFound
             || [event rangeOfString:@"_play"].location != NSNotFound) &&
            (_type == ExploreMovieViewTypeVideoFloat_main || _type == ExploreMovieViewTypeVideoFloat_related) &&
            !self.wasInDetail) {
            [dict setValue:@"float" forKey:@"video_position"];
        }
    }

    if (percent >= 0) {
        [dict setValue:@(percent) forKey:@"percent"];
    }

    if ((duration + self.preResolutionWatchingDuration) >= 0) {
        [dict setValue:@(MAX(duration, 0) + self.preResolutionWatchingDuration) forKey:@"duration"];
//        if ([event rangeOfString:@"_over"].location != NSNotFound) {
//            NSLog(@"%@",dict);
//        }
    }

    if ([[_extraValue allKeys] count] > 0) {
        [dict addEntriesFromDictionary:_extraValue];
    }
    
    if ([[[_extraValueOnEvent valueForKey:event] allKeys] count] > 0) {
        [dict addEntriesFromDictionary:[_extraValueOnEvent valueForKey:event]];
    }
    
    if (TTVideoPlayTypeLive == self.videoPlayType || TTVideoPlayTypeLivePlayback == self.videoPlayType) {
        [dict setValue:(TTVideoPlayTypeLive == self.videoPlayType ? @"0" : @"1")
                forKey:@"is_video_live_replay"];
    }
    [dict setValue:self.liveStatus forKey:@"live_status"];
    
    if (self.ssTrackerDic) {
        [dict addEntriesFromDictionary:self.ssTrackerDic];
    }
    
    
    if([TTTrackerWrapper isOnlyV3SendingEnable] && [event isEqualToString:@"video_over"]) {
    } else {
        [TTTrackerWrapper eventData:dict];
    }

    if ([event rangeOfString:@"_over"].location != NSNotFound) {
        self.preResolutionWatchingDuration = 0;
    }
}

- (void)liveTrackLabel:(NSString *)label
           needPercent:(BOOL)percent
              duration:(BOOL)duration
{
    
    NSString *event = [self.ssTrackerDic objectForKey:@"event"];
    
    if (isEmptyString(event)) {
        event = [self.ssTrackerDic objectForKey:@"tag"];
    }
    
    if (isEmptyString(event) || isEmptyString(label)) {
        return;
    }
    
    NSMutableDictionary * dict = [[NSMutableDictionary alloc] init];
    [dict setValue:@"umeng" forKey:@"category"];
    [dict setValue:label forKey:@"tag"];
    [dict addEntriesFromDictionary:self.ssTrackerDic];
    
    
    if (percent && self.moviePlayerController.duration > 0) {
        int p = 0;
        if (_isPlaybackEnded) {
            p = 100;
        } else {
            p =  (int)((((CGFloat)self.moviePlayerController.playbackTime / (CGFloat)self.moviePlayerController.duration)) * 100.f);
        }
        [dict setValue:@(p) forKey:@"percent"];
    }
    if (duration) {
        NSUInteger watchDuration = 0;
        watchDuration = (NSUInteger)([self watchedDuration] * 1000.f);
        [dict setValue:@(watchDuration) forKey:@"duration"];
        
        // 记录下次统计开始的accessLogIndex
        [self updateWatchDurationLogIndex];
    }
    
    [TTTrackerWrapper eventData:dict];
}

- (void)sendADVideoClickTrackURLIfNeed
{
//    NSLog(@"**************** sendADVideoClickTrackURLIfNeed");
    if (!SSIsEmptyArray(self.clickTrackURLs)) {
        
//        [[SSURLTracker shareURLTracker] trackURLs:self.clickTrackURLs model:self.adBaseModel];
        ttTrackURLsModel(self.clickTrackURLs, self.trackUrlModel);
    } else {
        if (!isEmptyString(self.clickTrackUrl)) {
            ttTrackURLModel(self.clickTrackUrl, self.trackUrlModel);
//            [[SSURLTracker shareURLTracker] trackURL:self.clickTrackUrl model:self.adBaseModel];
        }
    }
}

- (BOOL)sendPlayVideoTrackURL
{
//    NSLog(@"**************** start play");
    if (!SSIsEmptyArray(self.playTrackUrls)) {
        ttTrackURLsModel(self.playTrackUrls, self.trackUrlModel);
//        [[SSURLTracker shareURLTracker] trackURLs:self.playTrackUrls model:self.adBaseModel];
        return YES;
    }
    return NO;
}

- (void)sendActivePlayVideoTrackURL
{
//    NSLog(@"**************** active play");
    if (!SSIsEmptyArray(self.activePlayTrackUrls)) {
//        [[SSURLTracker shareURLTracker] trackURLs:self.activePlayTrackUrls model:self.adBaseModel];
        ttTrackURLsModel(self.activePlayTrackUrls, self.trackUrlModel);
    }
}

- (void)sendEffectivePlayVideoTrackURL
{
//    NSLog(@"**************** valid play");
    if (!SSIsEmptyArray(self.effectivePlayTrackUrls)) {
//        [[SSURLTracker shareURLTracker] trackURLs:self.effectivePlayTrackUrls model:self.adBaseModel];
        ttTrackURLsModel(self.effectivePlayTrackUrls, self.trackUrlModel);
    }
}

- (void)sendPlayOverVideoTrackURL
{
//    NSLog(@"**************** play over");
    if (!SSIsEmptyArray(self.playOverTrackUrls)) {
//        [[SSURLTracker shareURLTracker] trackURLs:self.playOverTrackUrls model:self.adBaseModel];
        ttTrackURLsModel(self.playOverTrackUrls , self.trackUrlModel);
    }
}

- (void)sendVideoThirdMonitorUrl
{
//    NSLog(@"**************** sendVideoThirdMonitorUrl");
    if (!isEmptyString(self.videoThirdMonitorUrl) && isEmptyString(self.aID)) {
//        [[SSURLTracker shareURLTracker] thirdMonitorUrl:self.videoThirdMonitorUrl];
        [[TTURLTracker shareURLTracker] thirdMonitorUrl:self.videoThirdMonitorUrl];
        [TTTrackerWrapper event:@"video_track_url" label:@"play_track_url" value:_gModel.groupID extValue:nil extValue2:nil];
    }
}

- (void)sendNetAlertWithLabel:(NSString *)label
{
    [self event:@"video" label:label value:_gModel.groupID extValue:_aID logExtra:_logExtra needPosition:NO needPercent:NO duration:NO groupModel:_gModel];
}

- (void)sendControlViewClickTrack
{
    //主视频发两次,一个浮层一个原有的.
    if (_type == ExploreMovieViewTypeList) {
        wrapperTrackEvent(@"video", @"feed_click_screen");
    } else if (_type == ExploreMovieViewTypeDetail) {
        wrapperTrackEvent(@"video", @"detail_click_screen");
    }
    else if (_type == ExploreMovieViewTypeVideoFloat_main || _type == ExploreMovieViewTypeVideoFloat_related) {
        wrapperTrackEvent(@"video", @"float_click_screen");
    }
    else if (_type == ExploreMovieViewTypeLiveChatRoom) {
        [self liveTrackLabel:@"video_click_screen" needPercent:NO duration:NO];
    }
}

//- (void)addExtraValue:(id)value forKey:(NSString *)key onEvent:(NSString *)event
//{
//    if (!value || ![key isKindOfClass:[NSString class]] || ![event isKindOfClass:[NSString class]]) return;
//    
//    if (!_extraValueOnEvent) {
//        _extraValueOnEvent = [NSMutableDictionary dictionary];
//    }
//    NSMutableDictionary *eventDic = [_extraValueOnEvent valueForKey:event];
//    if (!eventDic) {
//        eventDic = [NSMutableDictionary dictionary];
//        [_extraValueOnEvent setValue:eventDic forKey:event];
//    }
//    [eventDic setValue:value forKey:key];
//}


- (void)addExtraValueFromDic:(NSDictionary *)dic
{
    for (NSString *key in dic.allKeys) {
        [self addExtraValue:dic[key] forKey:key];
    }
}
- (void)addExtraValue:(id)value forKey:(NSString *)key
{
    if (!value || ![key isKindOfClass:[NSString class]]) return;
    
    if (!_extraValue) {
        _extraValue = [NSMutableDictionary dictionary];
    }
    [_extraValue setValue:value forKey:key];
}

- (void)removeExtraValueForKey:(NSString *)key
{
    if (![key isKindOfClass:[NSString class]]) {
        return;
    }
    [_extraValue setValue:nil forKey:key];
}

- (void)sendContinuePlayTrack
{
    NSString *label = @"list_continue";
    if (self.type == ExploreMovieViewTypeDetail) {
        label = @"detail_continue";
    }
    wrapperTrackEvent(@"list_over", label);
}

- (void)sendContinuePlayTrack:(NSString *)stopEvent
{
    NSString *label = @"list_continue";
    if (self.type == ExploreMovieViewTypeDetail) {
        label = @"detail_continue";
    }
    wrapperTrackEvent(stopEvent, label);
}

- (void)sendVideoFinishUITrackWithEvent:(NSString *)event prefix:(NSString *)prefix
{
    NSString *position = nil;
    if (self.type == ExploreMovieViewTypeList) {
        position = @"list_video_over";
    } else if (self.type == ExploreMovieViewTypeDetail) {
        position = @"detail_video_over";
    }
    NSString *label = [self dataTrackLabel];
    if ([prefix isEqualToString:@"show"]) {
        label = [label stringByReplacingOccurrencesOfString:@"click" withString:prefix];
    }
    [self event:event label:label value:_gModel.groupID extValue:_aID logExtra:_logExtra position:position percent:-1 duration:-1 groupModel:_gModel];
}

- (void)sendPrePlayBtnClickTrack {
    
    NSString * dataLabel = [self dataTrackLabel];

    [self event:@"last_button" label:dataLabel value:_gModel.groupID extValue:nil logExtra:_logExtra needPosition:NO needPercent:NO needOneFrameTime:NO duration:NO groupModel:_gModel];
}

- (TTURLTrackerModel*)trackUrlModel
{
    TTURLTrackerModel* model = [[TTURLTrackerModel alloc] initWithAdId:self.aID logExtra:self.logExtra];
    return model;
}


- (void)mzTrackVideoUrls:(NSArray*)trackUrls adView:(UIView*)adView
{
    if ([SSCommonLogic isMZSDKEnable]) {
        if (self.trackSDK == 1) {
            UIView* superView = adView.superview;
            while (superView) {
                if ([superView isKindOfClass:NSClassFromString(@"TTLayOutCellViewBase")]) {
                    self.trackSDKView = superView;
                    break;
                }
                superView = superView.superview;
            }
            if (self.trackSDKView) {
                if (!SSIsEmptyArray(trackUrls)) {
                    self.timerId = [MZMonitor adTrackVideo:trackUrls.firstObject adView:self.trackSDKView];
                    
                }
            }
        }
    }
}

- (void)mzStopTrack
{
    if ([SSCommonLogic isMZSDKEnable]) {
        if (self.trackSDK == 1) {
            if (self.trackSDKView) {
                [MZMonitor adTrackStop:self.timerId];
                [MZMonitor retryCachedRequests];
            }
        }
    }
}

@end
