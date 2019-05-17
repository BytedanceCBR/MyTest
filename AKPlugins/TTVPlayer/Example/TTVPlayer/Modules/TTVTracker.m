//
//  TTVTracker.m
//  Pods
//
//  Created by panxiang on 2018/12/12.
//

#import "TTVTracker.h"

static Class <TTVTracker> ttv_tracker;
@implementation TTVTracker

+ (void)configTrackerClass:(Class <TTVTracker>)tracker
{
    ttv_tracker = tracker;
}

+ (void)eventV3:(nonnull NSString *)event params:(nullable NSDictionary *)params
{
    if (ttv_tracker) {
        [ttv_tracker eventV3:event params:params];
    }
}
@end
