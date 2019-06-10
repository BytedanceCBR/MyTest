//
//  TTVTrackManager.m
//  Article
//
//  Created by panxiang on 2018/8/29.
//

#import "TTVTrackManager.h"
#import "TTVPlayerState.h"
#import "TTVPlayerStateTrackPrivate.h"
#import "TTVideoEnginePlayerDefine.h"
#import <Aspects.h>

@interface TTVTrackManager ()
@property (nonatomic, strong, nonnull) NSMutableArray<id<AspectToken>> *tokens;
@property (nonatomic, assign) BOOL isHooking;
@end

@implementation TTVTrackManager
@synthesize store = _store;
- (void)dealloc {
    [self.tokens enumerateObjectsUsingBlock:^(id<AspectToken>  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj remove];
    }];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.enableCoreTrack = YES;
    }
    return self;
}

- (void)registerPartWithStore:(TTVPlayerStore *)store
{
    if (store == self.store) {
        self.store.state.track.coreTrackExtension = [NSMutableDictionary dictionary];
        @weakify(self);
        [self.store subscribe:^(id<TTVRActionProtocol> action, id<TTVRStateProtocol> state) {
            @strongify(self);
            if ([action.type isEqualToString:TTVPlayerActionTypeVideoEngineUserStopped]) {
                [self _finishAction];
            } else if ([action.type isEqualToString:TTVPlayerActionTypeVideoEngineDidFinish]) {
                [self _finishAction];
            }
        }];
        [self ttv_bind];
    }
}

- (void)ttv_bind
{
    if (self.isHooking) return;
    self.isHooking = YES;
    
    WeakSelf;
    id<AspectToken> playToken = [self.store.player aspect_hookSelector:@selector(play) withOptions:AspectPositionBefore usingBlock:^(id<AspectInfo> aspectInfo) {
        StrongSelf;
        [self _playAction];
    } error:nil];
    
    id<AspectToken> pauseToken = [self.store.player aspect_hookSelector:@selector(pause) withOptions:AspectPositionBefore usingBlock:^(id<AspectInfo> aspectInfo) {
        StrongSelf;
        [self _pauseAction];
    } error:nil];
    
    id<AspectToken> resumeToken = [self.store.player aspect_hookSelector:@selector(resume) withOptions:AspectPositionBefore usingBlock:^(id<AspectInfo> aspectInfo) {
        StrongSelf;
        [self _playAction];
    } error:nil];
    
    
    [self.tokens addObject:playToken];
    [self.tokens addObject:pauseToken];
    [self.tokens addObject:resumeToken];
}

#pragma mark - Set & Get

- (NSMutableArray *)tokens {
    if (!_tokens) {
        _tokens = [NSMutableArray array];
    }
    return _tokens;
}

#pragma mark - Track

- (void)_playAction {
    switch (self.store.player.playbackState) {
            case TTVideoEnginePlaybackStateStopped://stop -> play
            case TTVideoEnginePlaybackStatePaused://pause -> play
            //continue play
            if (self.store.player.readyForRender) {
                [self _sendContinueTrack];
            }
            //play
            else {
                [self _sendVideoPlay];
            }
            break;
        default:
            break;
    }
}

- (void)_pauseAction {
    switch (self.store.player.playbackState) {
            case TTVideoEnginePlaybackStatePlaying: {//play -> pause
                [self _sendPauseVideo];
            }
            break;
        default:
            break;
    }
}

- (void)_finishAction {
    [self _sendVideoOver];
}

- (void)_sendVideoPlay {
    if (!self.enableCoreTrack) return;
    NSString *event = @"video_play";
    if (self.isAutoPlay) {
        event = [event stringByAppendingString:@"_auto"];
    }
    NSDictionary *outExtDic = self.store.state.track.coreTrackExtension[event];
    [self _eventV3:event needPercent:NO needDuration:NO extDict:outExtDic ?: @{}];
}

- (void)_sendPauseVideo {
    if (!self.enableCoreTrack) return;
    NSString *event = @"pause_video";
    NSDictionary *extDict = self.store.state.track.coreTrackExtension[event];
    [self _eventV3:event needPercent:YES needDuration:NO extDict:extDict ?: @{}];
}

- (void)_sendVideoOver {
    if (!self.enableCoreTrack) return;
    NSString *event = @"video_over";
    if (self.isAutoPlay) {
        event = [event stringByAppendingString:@"_auto"];
    }
    NSMutableDictionary *extDic = [NSMutableDictionary dictionary];
    extDic[@"from_percent"] = [NSString stringWithFormat:@"%.1f", MAX((self.store.player.startTime * 100.f / self.store.player.duration), 0)];
    NSDictionary *outExtDic = self.store.state.track.coreTrackExtension[event];
    [extDic addEntriesFromDictionary:outExtDic];
    [self _eventV3:event needPercent:YES needDuration:YES extDict:extDic ?: @{}];
}

- (void)_sendContinueTrack {
    if (!self.enableCoreTrack) return;
    NSString *event = @"continue_video";
    NSDictionary *extDict = self.store.state.track.coreTrackExtension[event];
    [self _eventV3:@"continue_video" needPercent:YES needDuration:NO extDict:extDict ?: @{}];
}

- (void)_eventV3:(NSString *)event needPercent:(BOOL)percent needDuration:(BOOL)duration extDict:(NSDictionary *)extDitc {
    
    NSMutableDictionary * dict = [NSMutableDictionary dictionaryWithCapacity:10];
    dict[@"log_pb"] = self.store.state.model.logPb;
    dict[@"item_id"] = self.store.state.model.itemID;
    dict[@"group_id"] = self.store.state.model.groupID;
    dict[@"category_name"] = self.store.state.model.categoryID;
    NSNumber *percentNum = nil;
    if (percent && self.store.player.duration > 0) {
        if (self.store.player.isPlaybackEnded) {
            percentNum = @(100);
        } else {
            NSTimeInterval currentPlaybackTime = self.store.player.currentPlaybackTime;
            NSString *string = [NSString stringWithFormat:@"%.1f", MAX((currentPlaybackTime * 100.f / self.store.player.duration), 0)];
            percentNum = @([string doubleValue]);
        }
    }
    dict[@"percent"] = percentNum;
    
    NSNumber *durationNum = nil;
    if (duration) {
        durationNum = @(self.store.player.durationWatched ?: 0);
    }
    dict[@"duration"] = durationNum;
    if ([extDitc isKindOfClass:[NSDictionary class]]) {
        [dict addEntriesFromDictionary:extDitc];
    }
    [TTVTracker eventV3:event params:[dict copy]];
}

#pragma mark - Util

- (void)addExtensionParams:(NSDictionary *)params forTrackType:(NSString *)trackType {
    if (![params isKindOfClass:[NSDictionary class]] || isEmptyString(trackType)) {
        return;
    }
    NSDictionary *trackDict = self.store.state.track.coreTrackExtension[trackType];
    if (![trackDict isKindOfClass:[NSDictionary class]]) {
        trackDict = @{};
    }
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:trackDict];
    [dict addEntriesFromDictionary:params];
    self.store.state.track.coreTrackExtension[trackType] = dict;
}

- (NSDictionary *)extensionParamsForPlayerCoreTrackType:(NSString *)trackType {
    if (isEmptyString(trackType)) {
        return nil;
    }
    return self.store.state.track.coreTrackExtension[trackType];
}

- (void)removeExtensionParam:(NSString *)paramKey forTrackType:(NSString *)trackType {
    if (isEmptyString(trackType) || isEmptyString(paramKey)) {
        return;
    }
    NSDictionary *trackDict = self.store.state.track.coreTrackExtension[trackType];
    if ([trackDict isKindOfClass:[NSDictionary class]]) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:trackDict];
        [dict removeObjectForKey:paramKey];
        self.store.state.track.coreTrackExtension[trackType] = dict;
    }
}

- (void)removeAllExtensionParamsForTrackType:(NSString *)trackType {
    if (isEmptyString(trackType)) {
        return;
    }
    [self.store.state.track.coreTrackExtension removeObjectForKey:trackType];
}

@end

@implementation TTVPlayer (TTVTrackManager)

- (TTVTrackManager *)trackManager
{
    return nil;

//    return [self partManagerFromClass:[TTVTrackManager class]];
}

@end
