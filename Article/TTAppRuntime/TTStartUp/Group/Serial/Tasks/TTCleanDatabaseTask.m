//
//  TTCleanDatabaseTask.m
//  Article
//
//  Created by fengyadong on 17/1/17.
//
//

#import "TTCleanDatabaseTask.h"
#import "ArticleModelUpdateHelper.h"
#import "TTArticleCategoryManager.h"
#import "TTDBCenter.h"
#import "ExploreOrderedData.h"
#import <TTSettingsManager/TTSettingsManager.h>
#import <TTEntityBase/GYDataContext.h>

@implementation TTCleanDatabaseTask

- (NSString *)taskIdentifier {
    return @"CleanDatabase";
}

- (void)startWithApplication:(UIApplication *)application options:(NSDictionary *)launchOptions {
    [super startWithApplication:application options:launchOptions];
    [[self class] cleanCoreDataIfNeeded];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSNumber *enbaled = [[TTSettingsManager sharedManager] settingForKey:@"tt_auto_transaction_enabled" defaultValue:@(YES) freeze:NO];
        [[GYDataContext sharedInstance] setAutoTransactionEnabled:enbaled.boolValue];
    });
    [self deleteFeedDataBase];
}

+ (void)cleanCoreDataIfNeeded {
    BOOL needCleanDB = [[NSUserDefaults standardUserDefaults] boolForKey:@"SSSafeMode"];
    if (needCleanDB) {
        [SSCommonLogic setNeedCleanCoreData:YES];
        [ArticleModelUpdateHelper deleteCoreDataFileIfNeed];
        [TTDBCenter deleteAllDBFiles];
        [ExploreLogicSetting tryClearCoreDataCache];
        
        // 清理与频道数据关联的UserDefalts数据，否则会导致用户频道重置为默认频道
        [TTArticleCategoryManager clearHasGotRemoteData];
        [TTArticleCategoryManager setGetCategoryVersion:nil];
        
        [[NSUserDefaults standardUserDefaults] setValue:@(NO) forKey:@"SSSafeMode"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (void)deleteFeedDataBase {
    NSArray *categories = [SSCommonLogic clearLocalFeedDataList];
    if (!SSIsEmptyArray(categories)) {
        //适配Android设置的settings
        NSString *firstCategory = [NSString stringWithFormat:@"%@", [categories firstObject]];
        if ([firstCategory isEqualToString:@"*"]) {
            //干掉tt_news.db
            [ExploreOrderedData deleteDBFile];
        }
    }
}

@end

