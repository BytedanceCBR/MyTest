//
//  TTSDWebImageCacheSettingTask.m
//  Article
//
//  Created by fengyadong on 17/1/17.
//
//

#import "TTSDWebImageCacheSettingTask.h"
#import "UIDevice+TTAdditions.h"
#import "SDImageCache.h"
#import "SDImageCacheConfig.h"
#import "TTWebImageManager.h"

@implementation TTSDWebImageCacheSettingTask

- (NSString *)taskIdentifier {
    return @"SDWebImageCacheSetting";
}

- (void)startWithApplication:(UIApplication *)application options:(NSDictionary *)launchOptions {
    [super startWithApplication:application options:launchOptions];
    if ([SSCommonLogic shouldUseOptimisedLaunch]) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [[self class] setupSDWebImageCacheSize];
        });
    } else {
        [[self class] setupSDWebImageCacheSize];
    }
    
    
    if ([SSCommonLogic enableImageOptimizeStrategy]) {
        [TTWebImageManager shareManger].shouldUseOptimizeStrategy = YES;
    }
    if ([SSCommonLogic enableMonitorFirstHostSuccessRate]) {
        [[TTWebImageManager shareManger] setImgMonitorBlock:^(NSDictionary * monitorItems){
            if (monitorItems) {
                [[TTMonitor shareManager] trackService:@"image_opt_monitor" attributes:monitorItems];
            }
        }];
    }
}

+ (void)setupSDWebImageCacheSize {
    // 图片文件总大小超过设定最大值后，自动清理一半旧文件
    NSNumber * value = [[UIDevice currentDevice] freeDiskSpace];
    CGFloat diskFree = value.doubleValue/1024/1024;
    if (diskFree<500) {
        [[SDImageCache sharedImageCache].config setMaxCacheSize:100 * 1024 * 1024];
    } else {
        if(diskFree<1000) {
            [[SDImageCache sharedImageCache].config setMaxCacheSize:200 * 1024 * 1024];
        } else{
            [[SDImageCache sharedImageCache].config setMaxCacheSize:400 * 1024 * 1024];
        }
    }
}

@end
