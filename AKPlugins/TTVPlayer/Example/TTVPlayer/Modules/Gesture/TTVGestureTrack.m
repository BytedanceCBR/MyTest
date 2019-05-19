//
//  TTVGestureTrack.m
//  Article
//
//  Created by panxiang on 2018/11/27.
//

#import "TTVGestureTrack.h"
#import "TTVPlayerStateFullScreen.h"

@implementation TTVGestureTrack
- (instancetype)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (void)setStore:(TTVPlayerStore *)store
{
    if (_store != store) {
        _store = store;
        @weakify(self);
        [self.store subscribe:^(id<TTVRActionProtocol> action, id<TTVRStateProtocol> state) {
            @strongify(self);
            if ([action.type isEqualToString:TTVGestureManagerActionTypeVolumeDidChanged]) {
                NSDictionary *info = (NSDictionary *)action.info;
                if ([info isKindOfClass:[NSDictionary class]] && info[@"isSystemVolumeButton"] && [info[@"isSystemVolumeButton"] boolValue]) {
                    [self sendDragVolumeTrackWithSection:@"system_sensing"];
                }
            }else if ([action.type isEqualToString:TTVGestureManagerActionTypeDoubleTapClick]){
                if (self.store.state.play.showPlayButton) {
                    [self sendDoubleTapPlayTrack];
                } else {
                    [self sendDoubleTapPauseTrack];
                }
            }else if ([action.type isEqualToString:TTVGestureManagerActionTypeSingleTapClick]){
                [self sendControlViewClickTrack];
            }else if ([action.type isEqualToString:TTVGestureManagerActionTypeChangeBrightnessClick]){
                [self sendFullScreenDragBrightnessTrack];
            }else if ([action.type isEqualToString:TTVGestureManagerActionTypeChangeVolumeClick]){
                [self sendDragVolumeTrackWithSection:@"fullscreen_right"];
            }
        }];
    }
}

- (void)sendFullScreenDragBrightnessTrack {
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:2];
    params[@"item_id"] = self.store.state.model.itemID;
    params[@"group_id"] = self.store.state.model.groupID;
    params[@"log_pb"] = self.store.state.model.logPb;
    params[@"section"] = @"fullscreen_left";
    [TTVTracker eventV3:@"adjust_brightness" params:params];
}

- (void)sendControlViewClickTrack
{
    NSString *position = nil;
    if (self.store.state.model.source == TTVPlayerSourceList) {
        position = @"list";
    } else if (self.store.state.model.source == TTVPlayerSourceDetail) {
        position = @"detail";
    }
    if (position) {
        [self logClickScreen:position];
    }
}

- (void)logClickScreen:(NSString *)position
{
    NSMutableDictionary * eventContext = [[NSMutableDictionary alloc] init];
    eventContext[@"group_id"] = self.store.state.model.groupID;
    eventContext[@"item_id"] = self.store.state.model.itemID;
    eventContext[@"ad_id"] = self.store.state.model.adID;
    eventContext[@"group_id"] = self.store.state.model.groupID;
    // 0 是item_id 聚合  1 是gid 聚合
    eventContext[@"aggr_type"] = self.store.state.model.aggrType;
    eventContext[@"position"] = self.store.state.position;
    
    // full screen
    eventContext[@"fullscreen"] = self.store.state.fullScreen.isFullScreen ? @"fullscreen" : @"notfullscreen";
    
    [TTVTracker eventV3:@"click_screen" params:eventContext];
}

- (void)sendDragScreenProgessTrack:(CGFloat)progress fromProgress:(CGFloat)fromProgress isSwipe:(BOOL)isSwipe {
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:2];
    params[@"item_id"] = self.store.state.model.itemID;
    params[@"group_id"] = self.store.state.model.groupID;
    params[@"log_pb"] = self.store.state.model.logPb;
    params[@"section"] = @"player_screen_slide";
    params[@"direction"] = progress > fromProgress ? @"forward" : @"backward";
    params[@"from_percent"] = @(fromProgress * 100.f);
    params[@"percent"] = @(progress * 100.f);
    params[@"adjust_type"] = isSwipe ? @"swipe" : @"seek";
    [TTVTracker eventV3:@"adjust_progress" params:params];
}

- (void)sendDragVolumeTrackWithSection:(NSString *)section {
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:2];
    params[@"item_id"] = self.store.state.model.itemID;
    params[@"group_id"] = self.store.state.model.groupID;
    params[@"log_pb"] = self.store.state.model.logPb;
    params[@"section"] = section;
    [TTVTracker eventV3:@"adjust_volume" params:params];
}

- (void)sendDoubleTapPlayTrack
{
    [TTVTracker eventV3:@"click_screen" params:@{@"combo_count": @(2), @"play_status": @"play"}];
}

- (void)sendDoubleTapPauseTrack
{
    [TTVTracker eventV3:@"click_screen" params:@{@"combo_count": @(2), @"play_status": @"pause"}];
}

@end
