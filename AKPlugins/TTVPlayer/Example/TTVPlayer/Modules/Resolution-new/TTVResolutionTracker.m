//
//  TTVResolutionTracker.m
//  Article
//
//  Created by panxiang on 2018/12/11.
//

#import "TTVResolutionTracker.h"
#import "TTVideoResolutionService.h"
#import "TTVPlayer.h"

@implementation TTVResolutionTracker


- (void)setStore:(TTVPlayerStore *)store
{
//    if (store != _store) {
//        _store = store;
//        @weakify(self);
//        [self.store subscribe:^(id<TTVRActionProtocol> action, id<TTVRStateProtocol> state) {
//            @strongify(self);
//            if ([action.type isEqualToString:TTVPlayerActionTypeSwitchResolutionFinished]){
//                TTVideoEngineResolutionType resolutionType = [action.info[TTVPlayerActionTypeSwitchResolutionFinishedKeyResolution] integerValue];
//                BOOL isbegin = [action.info[TTVPlayerActionTypeSwitchResolutionFinishedKeyisBegin] boolValue];
//                BOOL isDegrade = [action.info[TTVPlayerActionTypeSwitchResolutionFinishedKeyisDegrading] boolValue];
//                if (isbegin) {
//                    [self sendResolutionSelectTrack:resolutionType isDegrade:isDegrade];
//                }
//            }
//        }];
//    }
}

- (void)sendResolutionSelectTrack:(TTVideoEngineResolutionType)type isDegrade:(BOOL)isDegrade
{
//    NSString *supportedResolutionCounts = [@([self.store.player.supportedResolutionTypes count]) stringValue];
//    NSString *definition = [TTVideoResolutionService stringForType:type];
//    NSMutableDictionary *extra = [[NSMutableDictionary alloc] initWithCapacity:2];
//    if (supportedResolutionCounts) {
//        [extra setObject:supportedResolutionCounts forKey:@"num"];
//    }
//    if (definition) {
//        [extra setObject:definition forKey:@"definition"];
//    }
//    extra[@"action_type"] = isDegrade ? @"auto" : @"select";
//    extra[@"log_pb"] = self.store.state.model.logPb;
//    extra[@"group_id"] = self.store.state.model.groupID;
//    [TTVTracker eventV3:@"clarity_switch" params:extra];
}
@end
