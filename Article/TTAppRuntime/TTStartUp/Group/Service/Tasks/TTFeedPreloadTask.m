//
//  TTFeedPreloadTask.m
//  Article
//
//  Created by 冯靖君 on 2017/9/22.
//

#import "TTFeedPreloadTask.h"
#import "ArticleGetLocalDataOperation.h"
#import "ExploreOrderedData.h"
#import "ExploreCellBase.h"
#import "NetworkUtilities.h"
#import "TTArticleCategoryManager.h"

static NSArray *allItems = nil;
static BOOL preloadInvalid = NO;

@implementation TTFeedPreloadTask

- (NSString *)taskIdentifier
{
    return @"feedPreload";
}

- (BOOL)isConcurrent
{
    return YES;
}

- (BOOL)isResident
{
    return YES;
}

+ (NSArray *)preloadedFeedItemsFromLocal
{
    return allItems;
}

+ (BOOL)preloadInvalid
{
    return preloadInvalid;
}

+ (void)setPreloadInvalid:(BOOL)invalid
{
    preloadInvalid = invalid && allItems.count > 0;
}

#pragma mark - UIApplicationDelegate Method
- (void)startWithApplication:(UIApplication *)application options:(NSDictionary *)launchOptions
{
    [super startWithApplication:application options:launchOptions];
    return;
    // 推荐频道数据预加载
    TTCategory *mainCategory = [TTArticleCategoryManager mainArticleCategory];
    
    NSMutableDictionary *queryDict = [NSMutableDictionary dictionaryWithCapacity:5];
    [queryDict setValue:mainCategory.categoryID forKey:@"categoryID"];
    [queryDict setValue:mainCategory.concernID forKey:@"concernID"];
    [queryDict setValue:@(ExploreOrderedDataListTypeCategory) forKey:@"listType"];
    [queryDict setValue:@(ExploreOrderedDataListLocationCategory) forKey:@"listLocation"];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        // get data from db
        NSUInteger count = getLocalNormalLoadCount();
        if (!TTNetworkConnected())
        {
            count = getLocalOfflineLoadCount();
        }
        NSArray *sortedDataList = [ExploreOrderedData objectsWithQuery:queryDict orderBy:@"itemIndex DESC" offset:0 limit:count];

        sortedDataList = [ArticleGetLocalDataOperation fixOrderedDataWhenQueryFromDB:sortedDataList withCategoryID:mainCategory.categoryID];

        allItems = [sortedDataList copy];
    });
}

@end
