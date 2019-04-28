//
//  TTUGCPermissionStartupTask.m
//  Article
//
//  Created by fengyadong on 17/1/18.
//
//

#import "TTUGCPermissionStartupTask.h"
#import "TTUGCPermissionService.h"
#import <TTServiceKit/TTServiceCenter.h>

@implementation TTUGCPermissionStartupTask

- (NSString *)taskIdentifier {
    return @"UGCPermission";
}

- (void)startWithApplication:(UIApplication *)application options:(NSDictionary *)launchOptions {
    [super startWithApplication:application options:launchOptions];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [GET_SERVICE_BY_PROTOCOL(TTUGCPermissionService) startFetchPostUGCPermission];
    });
}

@end
