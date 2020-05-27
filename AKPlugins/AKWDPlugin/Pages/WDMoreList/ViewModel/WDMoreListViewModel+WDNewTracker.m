//
//  WDMoreListViewModel+WDNewTracker.m
//  Pods
//
//  Created by wangqi.kaisa on 2017/9/6.
//
//

#import "WDMoreListViewModel+WDNewTracker.h"
#import <BDTrackerProtocol/BDTrackerProtocol.h>

@implementation WDMoreListViewModel (WDNewTracker)

- (void)addTrackerWithName:(NSString *)eventName trackerInfo:(NSDictionary *)trackerInfo {
    NSMutableDictionary *fullDict = [NSMutableDictionary dictionaryWithDictionary:trackerInfo];
    [fullDict addEntriesFromDictionary:self.gdExtJson];
    [BDTrackerProtocol eventV3:eventName params:fullDict];
}

@end
