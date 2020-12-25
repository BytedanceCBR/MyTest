//
//  FHHomePreloadStartupTask.m
//  FHHouseHome
//
//  Created by bytedance on 2020/12/20.
//

#import "FHHomePreloadStartupTask.h"
#import "TTLaunchDefine.h"
#import "FHHomeItemRequestManager.h"

DEC_TASK_N(FHHomePreloadStartupTask, FHTaskTypeUI, TASK_PRIORITY_HIGH - 1);

@implementation FHHomePreloadStartupTask

- (NSString *)taskIdentifier {
    return @"FHHomePreloadStartupTask";
}

- (void)startWithApplication:(UIApplication *)application options:(NSDictionary *)launchOptions {
    [super startWithApplication:application options:launchOptions];
    if ([FHHomeItemRequestManager preloadType] == FHHomepagePreloadTypeStartupTask) {
        [FHHomeItemRequestManager preloadIfNeed];
    }
}

@end
