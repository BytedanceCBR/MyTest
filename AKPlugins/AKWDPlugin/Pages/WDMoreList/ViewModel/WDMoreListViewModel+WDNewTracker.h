//
//  WDMoreListViewModel+WDNewTracker.h
//  Pods
//
//  Created by wangqi.kaisa on 2017/9/6.
//
//

#import "WDMoreListViewModel.h"

@interface WDMoreListViewModel (WDNewTracker)

- (void)addTrackerWithName:(NSString *)eventName trackerInfo:(NSDictionary *)trackerInfo;

@end
