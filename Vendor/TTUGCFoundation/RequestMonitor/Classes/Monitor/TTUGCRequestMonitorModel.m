//
//  TTUGCRequestMonitorModel.m
//  News
//
//  Created by ranny_90 on 2017/10/18.
//

#import "TTUGCRequestMonitorModel.h"

@implementation TTUGCRequestMonitorModel

- (void)setCost:(NSTimeInterval)cost {
    _cost = cost;

    if (cost <= 0) {
        return;
    }

    NSMutableDictionary *metric = [NSMutableDictionary dictionary];
    if (self.metric) {
        [metric addEntriesFromDictionary:self.metric];
    }
    [metric setValue:[NSNumber numberWithDouble:cost] forKey:@"cost"];
    self.metric = [metric copy];
}

- (NSDictionary *)categoryContainsMonitorStatus {
    NSMutableDictionary *category = [NSMutableDictionary dictionary];
    if (self.category) {
        [category addEntriesFromDictionary:self.category];
    }
    [category setValue:[NSNumber numberWithInteger:self.monitorStatus] forKey:@"status"];
    return [category copy];
}

@end
