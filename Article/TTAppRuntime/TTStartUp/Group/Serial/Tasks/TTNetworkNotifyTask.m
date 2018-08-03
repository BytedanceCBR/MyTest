//
//  TTNetworkNotifyTask.m
//  Article
//
//  Created by fengyadong on 17/1/18.
//
//

#import "TTNetworkNotifyTask.h"
#import "NetworkUtilities.h"

@implementation TTNetworkNotifyTask

- (NSString *)taskIdentifier {
    return @"NetworkNotify";
}

- (void)startWithApplication:(UIApplication *)application options:(NSDictionary *)launchOptions {
    [super startWithApplication:application options:launchOptions];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        TTNetworkStartNotifier();
    });
}

@end
