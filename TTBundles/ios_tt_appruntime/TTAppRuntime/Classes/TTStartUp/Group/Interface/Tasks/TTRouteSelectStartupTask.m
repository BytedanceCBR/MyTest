//
//  TTRouteSelectStartupTask.m
//  Article
//
//  Created by fengyadong on 17/1/19.
//
//

#import "TTRouteSelectStartupTask.h"
// #import "TTLCSManager.h"
#import <TTNetBusiness/TTRouteSelectionManager.h>

@implementation TTRouteSelectStartupTask

- (NSString *)taskIdentifier {
    return @"RouteSelect";
}

- (void)startWithApplication:(UIApplication *)application options:(NSDictionary *)launchOptions {
    [super startWithApplication:application options:launchOptions];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // [TTLCSManager sharedTTLCSManager];
        [[TTRouteSelectionManager sharedTTRouteSelectionManager] doRouteSelection:ROUTE_SELECTION_SOURCE_COLD_START];
    });
}

@end
