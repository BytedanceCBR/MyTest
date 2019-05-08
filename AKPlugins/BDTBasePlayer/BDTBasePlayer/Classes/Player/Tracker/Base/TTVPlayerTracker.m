//
//  TTVPlayerTracker.m
//  Article
//
//  Created by panxiang on 2017/6/2.
//
//

#import "TTVPlayerTracker.h"
#import "TTVPlayerStateStore.h"
#import "KVOController.h"
#import "TTTrackerProxy.h"

@interface TTVPlayerTracker ()
{
}
@property(nonatomic, assign)BOOL isReplaying;
@property(nonatomic, assign)BOOL isRetry;
@property(nonatomic, strong)NSMutableDictionary *extras;
@end

@implementation TTVPlayerTracker
@synthesize trackLabel = _trackLabel;
@synthesize itemID = _itemID;
@synthesize groupID = _groupID;
@synthesize videoSubjectID = _videoSubjectID;
@synthesize categoryID = _categoryID;
@synthesize aggrType = _aggrType;
@synthesize adID = _adID;
@synthesize logExtra = _logExtra;
@synthesize logPb = _logPb;
@synthesize enterFrom = _enterFrom;
@synthesize categoryName = _categoryName;
@synthesize authorId = _authorId;

- (void)dealloc
{
    [_playerStateStore unregisterForActionClass:[TTVPlayerStateAction class] observer:self];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _extras = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)addExtra:(NSDictionary *)extra forEvent:(NSString *)event
{
    if (event) {
        [_extras setValue:extra forKey:event];
    }
}

- (NSMutableDictionary *)extraFromEvent:(NSString *)event
{
    if (event) {
        return [_extras valueForKey:event];
    }
    return nil;
}

- (void)sendEndTrack
{

}

- (void)setPlayerStateStore:(TTVPlayerStateStore *)playerStateStore
{
    if (_playerStateStore != playerStateStore) {
        [self.KVOController unobserve:self.playerStateStore.state];
        [_playerStateStore unregisterForActionClass:[TTVPlayerStateAction class] observer:self];
        _playerStateStore = playerStateStore;
        [_playerStateStore registerForActionClass:[TTVPlayerStateAction class] observer:self];
        [self ttv_kvo];
    }
}


- (void)ttv_kvo
{

}

- (void)actionChangeCallbackWithAction:(TTVPlayerStateAction *)action state:(TTVPlayerStateModel *)state
{
    if (![action isKindOfClass:[TTVPlayerStateAction class]] || ![state isKindOfClass:[TTVPlayerStateModel class]]) {
        return;
    }
    switch (action.actionType) {

        case TTVPlayerEventTypeFinishUIReplay:{
            self.isReplaying = YES;
        }
            break;

        case TTVPlayerEventTypeRetry:{
            self.isRetry = YES;
        }
            break;
        default:
            break;
    }
}

//主动播放
- (BOOL)ttv_sendEvenWhenPlayActively
{
    return !self.playerStateStore.state.isAutoPlaying || self.playerStateStore.state.isInDetail || self.isReplaying || self.playerStateStore.state.hasEnterDetail || self.isRetry;
}


- (NSMutableDictionary *)ttv_dictWithEvent:(NSString *)event
                                     label:(NSString *)label
{
    if (isEmptyString(event) || isEmptyString(label)) {
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
    if (!isEmptyString(self.authorId)) {
        [dict setValue:self.authorId forKey:@"author_id"];
    }
    [dict setValue:self.groupID forKey:@"value"];
    [dict setValue:self.itemID forKey:@"item_id"];
    [dict setValue:@(self.aggrType) forKey:@"aggr_type"];
    if (!isEmptyString(self.videoSubjectID)) {
        [dict setValue:self.videoSubjectID forKey:@"video_subject_id"];
    }
    if ([event rangeOfString:@"_over"].location != NSNotFound ||
        [event rangeOfString:@"_break"].location != NSNotFound) {
        NSNumber *duration = @(MAX(self.playerStateStore.state.totalWatchTime, 0));
        if (duration.integerValue > 0) {
            [dict setValue:@(MAX(self.playerStateStore.state.totalWatchTime, 0)) forKey:@"duration"];
        }
        [dict setValue:@(MAX(self.playerStateStore.state.playPercent, 0)) forKey:@"percent"];
        if (!isEmptyString(self.playerStateStore.state.playerModel.fromGid)) {
            [dict setValue:self.playerStateStore.state.playerModel.fromGid forKey:@"from_gid"];
        }
    }
    [dict addEntriesFromDictionary:self.playerStateStore.state.playerModel.commonExtra];
    
    return dict;
}

- (NSString *)ttv_dataTrackLabel
{
    NSString * dataLabel = nil;
    
    if (!isEmptyString(self.trackLabel)) {
        dataLabel = self.trackLabel;
    }else if (!isEmptyString(self.categoryID)) {
        if ([self.categoryID isEqualToString:@"__all__"]) {
            dataLabel = [NSString stringWithFormat:@"click_headline"];
        }else{
            BOOL hasPrefix = [self.categoryID hasPrefix:@"_"]; //特殊处理cID是_favorite的情况
            NSString *click = hasPrefix ? @"click" : @"click_";
            dataLabel = [NSString stringWithFormat:@"%@%@", click,self.categoryID];
        }
    }
    if (!dataLabel) {
        dataLabel = @"click_unknown";
    }
    return dataLabel;
}

- (NSString *)ttv_enterFullscreenType
{
    if (self.playerStateStore.state.enableRotate) {
        return @"landscape";
    }else{
        return @"portrait";
    }
    return nil;
}

- (NSString *)ttv_fullscreenAction
{
    if (self.playerStateStore.state.isFullScreenButtonType) {
        return @"fullscreen_button";
    }else{
        return @"gravity";
    }
    return nil;
}

- (NSString *)ttv_exitFullscreenAction
{
    switch (self.playerStateStore.state.exitFullScreeenType) {
        case TTVPlayerExitFullScreeenTypeBackButton:
            return @"back_button";
            break;
        case TTVPlayerExitFullScreeenTypeFullButton:
            return @"exit_fullscreen_button";
            break;
        case TTVPlayerExitFullScreeenTypeGravity:
            return @"gravity";
            break;
        default:
            break;
    }
    return nil;
}

@end


