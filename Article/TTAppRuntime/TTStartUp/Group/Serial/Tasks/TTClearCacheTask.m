//
//  TTClearCacheTask.m
//  Article
//
//  Created by fengyadong on 17/1/18.
//
//

#import "TTClearCacheTask.h"
#import "ArticleModelUpdateHelper.h"
#import "TTDBCenter.h"
//#import "FRAPPDelegateHelper.h"
#import "WDAppLaunchHelper.h"
#import "TTArticleCategoryManager.h"
#import "NetworkUtilities.h"
//#import "TTPostVideoCacheHelper.h"
#import "SSSimpleCache.h"

@implementation TTClearCacheTask

- (NSString *)taskIdentifier {
    return @"ClearCache";
}

- (BOOL)isResident {
    return YES;
}

- (void)startWithApplication:(UIApplication *)application options:(NSDictionary *)launchOptions {
    [super startWithApplication:application options:launchOptions];
    if([TTSandBoxHelper isAPPFirstLaunch])
    {
        [ArticleModelUpdateHelper deleteCoreDataFileIfNeed];
//        [[FRAPPDelegateHelper sharedInstance_tt] dosomethingWhenCurrentVersionFistLaunch];
        [[WDAppLaunchHelper sharedInstance_tt] dosomethingWhenCurrentVersionFistLaunch];
    }
    
    //新版数据库升级检测
    [[TTDBCenter sharedInstance] deleteDBIfNeeded];
    
    //处理频道迁移逻辑, 此处调用顺序不能改变， 先删除，再生成modelManager， 再根据需要插入默认数据
    BOOL deletedCategoryDBFile = [ArticleModelUpdateHelper deleteCategoryCoreDataFilesIfNeed];
    if (deletedCategoryDBFile) {
        [TTArticleCategoryManager insertDefaultData];
    }
    /**
     *  定期清理数据库缓存
     */
    if ([SSCommonLogic shouldUseOptimisedLaunch]) {
        if ([ExploreLogicSetting isNeedCleanOldCache]) {
            if(TTNetworkConnected())
            {
                [[TTMonitor shareManager] trackService:@"clean_old_cache" status:1 extra:nil];
                [ExploreLogicSetting tryClearCoreDataCache];
            }
        }
    }else{
        if(TTNetworkConnected()){
            [[TTMonitor shareManager] trackService:@"clean_old_cache" status:1 extra:nil];
            [ExploreLogicSetting tryClearCoreDataCache];
        }
    }
    
//    [[TTPostVideoCacheHelper sharedHelper] deleteVideoCacheIfNeed];
}

@end
