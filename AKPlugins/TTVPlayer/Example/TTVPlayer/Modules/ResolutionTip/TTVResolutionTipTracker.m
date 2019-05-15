//
//  TTVResolutionTipTracker.m
//  Article
//
//  Created by panxiang on 2018/11/15.
//

#import "TTVResolutionTipTracker.h"
#import "TTVideoResolutionService.h"

@implementation TTVResolutionTipTracker

- (void)setStore:(TTVPlayerStore *)store
{
    if (store != _store) {
        _store = store;
        
        @weakify(self);
        [self.store subscribe:^(id<TTVRActionProtocol> action, id<TTVRStateProtocol> state) {
            @strongify(self);
            if ([action.type isEqualToString:TTVPlayerActionTypeClickResolutionDegrade]) {
                [TTVTracker eventV3:@"continue_button_show"
                                   params:@{@"info"           : @"internet_lag",
                                            @"fullscreen"     : self.store.state.fullScreen.isFullScreen ? @"fullscreen" : @"notfullscreen",
                                            @"clarity_before" : [TTVideoResolutionService stringForType:[action.info[TTVPlayerActionTypeClickResolutionDegradeKeyResolutionTypeBefore] integerValue]],
                                            @"clarity_actual" : @"360P",
                                            }];
            }else if ([action.type isEqualToString:TTVPlayerActionTypeShowResolutionDegrade]) {
                [TTVTracker eventV3:@"change_clarity_tips_show"
                                   params:@{@"info"           : @"internet_lag",
                                            @"fullscreen"     : self.store.state.fullScreen.isFullScreen ? @"fullscreen" : @"notfullscreen",
                                            @"clarity_actual" : [TTVideoResolutionService stringForType:[action.info[TTVPlayerActionTypeShowResolutionDegradeKeyCurrentResolution] integerValue]],
                                            }];
            }
            
            
            
        }];
    }

}

- (NSMutableDictionary *)ttv_params
{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithCapacity:4];
    params[@"category_name"] = self.store.state.model.categoryID;
    params[@"position"] = [self ttv_positionForTracker];
    params[@"group_id"] = self.store.state.model.groupID;
    params[@"source"] = @"data_package_tip";
    return params;
}

- (NSString *)ttv_positionForTracker
{
    NSString *position;
    switch (self.store.state.model.source) {
        case TTVPlayerSourceList:
            position = @"list";
            break;
        case TTVPlayerSourceDetail:
            position = @"detail";
            break;
        default:
            position = @"others";
            break;
    }
    return position;
}

@end
