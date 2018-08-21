//
//  TTCollectDiskSpaceTask.m
//  Article
//
//  Created by fengyadong on 17/1/22.
//
//

#import "TTCollectDiskSpaceTask.h"
#import "TTAssetCountHelper.h"

@implementation TTCollectDiskSpaceTask

- (NSString *)taskIdentifier {
    return @"TimeInterval";
}

- (BOOL)isResident {
    return YES;
}

#pragma mark - UIApplicationDelegate Method

- (void)startWithApplication:(UIApplication *)application options:(NSDictionary *)launchOptions {
    if ([SSCommonLogic isCollectDiskSpaceEnable]) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            NSMutableDictionary *photoInfo = [[NSMutableDictionary alloc] init];
            [photoInfo setObject:@([TTDeviceHelper getFreeDiskSpace]) forKey:@"free_space"];
            [photoInfo setObject:@([TTDeviceHelper getTotalDiskSpace]) forKey:@"total_space"];
            if ([TTSandBoxHelper hasValidAssetCountSavedLastTime]) {
                [photoInfo setObject:@([TTSandBoxHelper assetCountSavedLastTime]) forKey:@"photo_count"];
            }
            [TTTracker eventV3:@"user_disk_space_collection" params:photoInfo];
        });
    }
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    if ([SSCommonLogic isCollectDiskSpaceEnable]) {
        [TTAssetCountHelper saveAssetCount];
    }
}

@end
