//
//  TTAppSettingsStartupTask.m
//  Article
//
//  Created by fengyadong on 17/1/18.
//
//

#import "TTAppSettingsStartupTask.h"
#import "ArticleFetchSettingsManager.h"
#import "TTSettingsManager.h"
#import "SDImageCache.h"
#import "TTDeviceHelper.h"
#if __has_include("BDImageCache.h")
#import "BDImageCache.h"
#endif
#import <BDABTestSDK/BDABTestManager.h>

static const NSInteger kSDOptimizeCacheMaxCacheAge = 60 * 60 * 24 * 2; // 2day
static const NSInteger kSDOptimizeCacheMaxSize = 100 * 1024 * 1024; // 100M


@implementation TTAppSettingsStartupTask

- (NSString *)taskIdentifier {
    return @"AppSettings";
}

- (void)startWithApplication:(UIApplication *)application options:(NSDictionary *)launchOptions {
    [super startWithApplication:application options:launchOptions];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        // ABTest 获取命中的实验组
        [self fetchABTestData];
        
        [ArticleFetchSettingsManager startFetchDefaultInfoIfNeed];

        if ([[[TTSettingsManager sharedManager] settingForKey:@"tt_disk_cache_optimize" defaultValue:@1 freeze:YES] boolValue]) {
            float fressDisk = [TTDeviceHelper getFreeDiskSpace]/(1024 *1024);
            if (fressDisk < 500) {
                [SDImageCache sharedImageCache].config.maxCacheSize = kSDOptimizeCacheMaxSize;//缓存设置
                [SDImageCache sharedImageCache].config.maxCacheAge = kSDOptimizeCacheMaxCacheAge;
                //TTUGC 中 SD 暂未替换，故存在两种缓存并存的情况
#if __has_include("BDImageCache.h")
                [BDImageCache sharedImageCache].config.memoryAgeLimit = kSDOptimizeCacheMaxCacheAge;
                [BDImageCache sharedImageCache].config.memorySizeLimit = kSDOptimizeCacheMaxSize;
#endif
            }
        }
    });
}


// 获取命中的实验
- (void)fetchABTestData
{
    [BDABTestManager fetchExperimentDataWithURL:@"https://abtest-ch.haoduofangs.com/common" maxRetryCount:0 completionBlock:^(NSError *error, NSDictionary *data) {
//        NSLog(@"abtest data:%@",data);
    }];
}

@end
