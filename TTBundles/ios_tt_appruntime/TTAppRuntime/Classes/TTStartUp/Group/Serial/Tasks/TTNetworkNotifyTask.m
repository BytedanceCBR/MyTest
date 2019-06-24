//
//  TTNetworkNotifyTask.m
//  Article
//
//  Created by fengyadong on 17/1/18.
//
//

#import "TTNetworkNotifyTask.h"
#import "NetworkUtilities.h"
#import "TTLaunchDefine.h"

DEC_TASK("TTNetworkNotifyTask",FHTaskTypeSerial,TASK_PRIORITY_HIGH+11);

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
