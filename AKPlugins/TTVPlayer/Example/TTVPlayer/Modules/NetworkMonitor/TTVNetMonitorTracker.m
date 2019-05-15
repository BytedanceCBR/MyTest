//
//  TTVNetMonitorTracker.m
//  Article
//
//  Created by panxiang on 2018/11/15.
//

#import "TTVNetMonitorTracker.h"

@implementation TTVNetMonitorTracker

- (void)setStore:(TTVPlayerStore *)store
{
    if (store != _store) {
        _store = store;
        @weakify(self);
        [self.store subscribe:^(id<TTVRActionProtocol> action, id<TTVRStateProtocol> state) {
            @strongify(self);
            if ([action.type isEqualToString:TTVNetMonitorManagerActionTypeShow]) {
                [TTVTracker eventV3:@"continue_button_show" params:[self ttv_params]];
                [TTVTracker eventV3:@"purchase_button_show" params:[self ttv_params]];
            }else if ([action.type isEqualToString:TTVNetMonitorManagerActionTypeContinuePlay]){
                [TTVTracker eventV3:@"continue_button_click" params:[self ttv_params]];
            }else if ([action.type isEqualToString:TTVNetMonitorManagerActionTypeSubscrib]){
                [TTVTracker eventV3:@"purchase_button_click" params:[self ttv_params]];
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
