//
//  ArticleGetLocalDataOperation.m
//  Article
//
//  Created by Dianwei on 12-11-18.
//
//

#import "ArticleGetLocalDataOperation.h"
#import "ExploreOrderedData+TTBusiness.h"
#import "Article.h"
#import "NetworkUtilities.h"

#import "ExploreFetchListDefines.h"
#import "ExploreListHelper.h"
#import "SSRobust.h"
#import "WapData.h"
#import "NSObject+TTAdditions.h"
#import "TTArticleCategoryManager.h"
#import "TTFeedPreloadTask.h"
#import "TTSettingsManager.h"
//#import "Thread.h"
//#import "FRCommentRepost.h"
#import "TTMonitor.h"
//#import "TTFollowCategoryFetchExtraManager.h"
#import "TTKitchenHeader.h"

inline NSInteger getLocalNormalLoadCount() {
    return 20;
}

inline NSInteger getLocalOfflineLoadCount() {
    return 50;
}

#import "ExploreFetchListManager.h"

@interface ArticleGetLocalDataOperation ()
@property(nonatomic, assign) NSUInteger operationIndex;
@end

@implementation ArticleGetLocalDataOperation

- (id)init
{
    self = [super init];
    if(self)
    {
        self.shouldExecuteBlock = ^(NSDictionary *dataContext){
            BOOL fromLocal = [[dataContext objectForKey:kExploreFetchListFromLocalKey] boolValue];
            return fromLocal;
        };
        
        __weak typeof(self) wself = self;
        self.didFinishedBlock = ^(NSArray *newList, NSError *error,  NSMutableDictionary *operationContext)
        {
            BOOL fromRemote = [[operationContext objectForKey:kExploreFetchListFromRemoteKey] boolValue];
            [operationContext setObject:[NSNumber numberWithBool:!fromRemote] forKey:kExploreFetchListResponseFinishedkey];
            [wself notifyWithData:newList error:error userInfo:operationContext];
        };
        
        _operationIndex = 0;
    }
    
    return self;
}

- (Class)orderedDataClass
{
    return [ExploreOrderedData class];
}

- (void)execute:(NSMutableDictionary *)operationContext
{
    _operationIndex++;
    
    self.hasFinished = NO;
    
    if(!self.shouldExecuteBlock(operationContext))
    {
        self.hasFinished = YES;
        [self executeNext:operationContext];
        return;
    }

    NSDictionary *conditions = [operationContext objectForKey:kExploreFetchListConditionKey];
    __block NSArray * allItems = [operationContext objectForKey:kExploreFetchListItemsKey];
    NSMutableDictionary * exploreMixedListConsumeTimeStamps = conditions[kExploreFetchListRefreshOrLoadMoreConsumeTimeStampsKey];
    [exploreMixedListConsumeTimeStamps setValue:@([NSObject currentUnixTime])
                                         forKey:kExploreFetchListGetLocalDataOperationBeginTimeStampKey];
    
    NSMutableDictionary *queryDict = [NSMutableDictionary dictionaryWithCapacity:5];
    
    ExploreOrderedDataListType listType = [[operationContext objectForKey:kExploreFetchListListTypeKey] intValue];
    ExploreOrderedDataListLocation listLocation = [[operationContext objectForKey:kExploreFetchListListLocationKey] intValue];
    NSString *categoryID = [conditions objectForKey:kExploreFetchListConditionListUnitIDKey];
    if (listType == ExploreOrderedDataListTypeCategory) {
        [queryDict setValue:categoryID forKey:@"categoryID"];

        NSString *concernID = [conditions objectForKey:kExploreFetchListConditionListConcernIDKey];
        [queryDict setValue:concernID forKey:@"concernID"];

    }
    
    [queryDict setValue:@(listType) forKey:@"listType"];
    [queryDict setValue:@(listLocation) forKey:@"listLocation"];
    
    if (!allItems.count) {
        BOOL preloaded = NO;
        if ([[[TTSettingsManager sharedManager] settingForKey:@"tt_optimize_start_enabled" defaultValue:@1 freeze:YES] boolValue]) {
            // 先读取启动阶段预加载数据，没有则读数据库
            NSString *categoryID = [conditions objectForKey:kExploreFetchListConditionListUnitIDKey];
            if ([categoryID isEqualToString:[TTArticleCategoryManager mainArticleCategory].categoryID]) {
                // 只在启动阶段尝试一次预加载，因为collection feed有复用，切换频道再回来时会再次请求getLocal，此时需要从数据库获取最新数据
                static dispatch_once_t onceToken;
                dispatch_once(&onceToken, ^{
                    allItems = [TTFeedPreloadTask preloadedFeedItemsFromLocal];
                });
                preloaded = allItems.count > 0;
            }
        }
        
        if (!preloaded) {
            // from store
            if (![TTFeedPreloadTask preloadInvalid]) {
                [TTFeedPreloadTask setPreloadInvalid:YES];
            }
            
            if ([SSCommonLogic loadLocalUseMemoryCache]) {
                allItems = [[ExploreFetchListHistoryManager sharedInstance] fetchFeedHistoryForCategoryID:categoryID];
                if (allItems && [allItems isKindOfClass:[NSArray class]] && allItems.count > 0) {
                    allItems = [ArticleGetLocalDataOperation fixOrderedDataWhenQueryFromDB:allItems withCategoryID:categoryID];
                }
                if (allItems && [allItems isKindOfClass:[NSArray class]] && allItems.count > 0) {
                    // update context
                    BOOL canLoadMore = YES;
                    if (!TTNetworkConnected()) {
                        canLoadMore = NO;
                    }
                    [operationContext setObject:[NSNumber numberWithBool:canLoadMore] forKey:kExploreFetchListResponseHasMoreKey];
                    
                    // 使用itemIndex后，就不用排序了
                    // NSArray * sortedDataList = [ExploreListHelper sortByIndexForArray:allItems listType:listType];
                    [operationContext setValue:allItems forKey:kExploreFetchListItemsKey];
                    //    sortedDataList = SSConvertToRobustObject(sortedDataList, nil);
                    self.didFinishedBlock(allItems, nil, operationContext);
                    self.hasFinished = YES;
                    [exploreMixedListConsumeTimeStamps setValue:@([NSObject currentUnixTime])
                                                         forKey:kExploreFetchListGetLocalDataOperationEndTimeStampKey];
                    [self executeNext:operationContext];
                    return;
                }
            }
            
            if ([SSCommonLogic disableGetLocalData]) {
                self.hasFinished = YES;
                [self executeNext:operationContext];
                return;
            }
            
            NSUInteger count = getLocalNormalLoadCount();
            if (!TTNetworkConnected())
            {
                count = getLocalOfflineLoadCount();
            }
            
            NSUInteger currentOperationIndex = self.operationIndex;
            NSInteger feedLoadLocalStrategy = [SSCommonLogic feedLoadLocalStrategy];
            if (1 == feedLoadLocalStrategy) {
                // 方案一，使用双线程保证能回到主线程
                __block NSArray *sortedDataList = nil;
                __block BOOL pass = NO; // 在主线程标记，是否执行
                __weak typeof(self) wself = self;
                void (^operationBlock)() = ^{
                    if (!pass) {
                        pass = YES;
                        
                        // 确保operationIndex一致，避免快速切换无效回调
                        if (wself.operationIndex == currentOperationIndex) {
                            if (sortedDataList) {
                                sortedDataList = [ArticleGetLocalDataOperation fixOrderedDataWhenQueryFromDB:sortedDataList withCategoryID:categoryID];
                                allItems = [NSArray arrayWithArray:sortedDataList];
                            }
                            // update context
                            BOOL canLoadMore = YES;
                            if (!TTNetworkConnected()) {
                                canLoadMore = NO;
                            }
                            [operationContext setObject:[NSNumber numberWithBool:canLoadMore] forKey:kExploreFetchListResponseHasMoreKey];
                            
                            // 使用itemIndex后，就不用排序了
                            // NSArray * sortedDataList = [ExploreListHelper sortByIndexForArray:allItems listType:listType];
                            [operationContext setValue:allItems forKey:kExploreFetchListItemsKey];
                            //    sortedDataList = SSConvertToRobustObject(sortedDataList, nil);
                            wself.didFinishedBlock(allItems, nil, operationContext);
                            wself.hasFinished = YES;
                            [exploreMixedListConsumeTimeStamps setValue:@([NSObject currentUnixTime])
                                                                 forKey:kExploreFetchListGetLocalDataOperationEndTimeStampKey];
                            [wself executeNext:operationContext];
                        }
                    }
                };
                
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                    sortedDataList = [ExploreOrderedData objectsWithQuery:queryDict orderBy:@"itemIndex DESC" offset:0 limit:count];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        operationBlock();
                    });
                });
                
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    operationBlock();
                });
                
            } else if (2 == feedLoadLocalStrategy) {
                // 方案二，使用等待信号量的方案
                __block NSArray *sortedDataList = nil;
                dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                    sortedDataList = [ExploreOrderedData objectsWithQuery:queryDict orderBy:@"itemIndex DESC" offset:0 limit:count];
                    
                    dispatch_semaphore_signal(semaphore);
                });
                dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC * 1.5));
                
                if (sortedDataList) {
                    sortedDataList = [ArticleGetLocalDataOperation fixOrderedDataWhenQueryFromDB:sortedDataList withCategoryID:categoryID];
                    allItems = [NSArray arrayWithArray:sortedDataList];
                }
                
                // update context
                BOOL canLoadMore = YES;
                if (!TTNetworkConnected()) {
                    canLoadMore = NO;
                }
                [operationContext setObject:[NSNumber numberWithBool:canLoadMore] forKey:kExploreFetchListResponseHasMoreKey];
                
                // 使用itemIndex后，就不用排序了
                // NSArray * sortedDataList = [ExploreListHelper sortByIndexForArray:allItems listType:listType];
                [operationContext setValue:allItems forKey:kExploreFetchListItemsKey];
                //    sortedDataList = SSConvertToRobustObject(sortedDataList, nil);
                self.didFinishedBlock(allItems, nil, operationContext);
                self.hasFinished = YES;
                [exploreMixedListConsumeTimeStamps setValue:@([NSObject currentUnixTime])
                                                     forKey:kExploreFetchListGetLocalDataOperationEndTimeStampKey];
                [self executeNext:operationContext];
                
            } else {
                
                NSArray *sortedDataList = [ExploreOrderedData objectsWithQuery:queryDict orderBy:@"itemIndex DESC" offset:0 limit:count];
                sortedDataList = [ArticleGetLocalDataOperation fixOrderedDataWhenQueryFromDB:sortedDataList withCategoryID:categoryID];
                allItems = [NSArray arrayWithArray:sortedDataList];
                
                // update context
                BOOL canLoadMore = YES;
                if (!TTNetworkConnected()) {
                    canLoadMore = NO;
                }
                [operationContext setObject:[NSNumber numberWithBool:canLoadMore] forKey:kExploreFetchListResponseHasMoreKey];
                
                // 使用itemIndex后，就不用排序了
                // NSArray * sortedDataList = [ExploreListHelper sortByIndexForArray:allItems listType:listType];
                [operationContext setValue:allItems forKey:kExploreFetchListItemsKey];
                //    sortedDataList = SSConvertToRobustObject(sortedDataList, nil);
                self.didFinishedBlock(allItems, nil, operationContext);
                self.hasFinished = YES;
                [exploreMixedListConsumeTimeStamps setValue:@([NSObject currentUnixTime])
                                                     forKey:kExploreFetchListGetLocalDataOperationEndTimeStampKey];
                [self executeNext:operationContext];
            }
            
        } else {
            BOOL canLoadMore = YES;
            if (!TTNetworkConnected()) {
                canLoadMore = NO;
            }
            [operationContext setObject:[NSNumber numberWithBool:canLoadMore] forKey:kExploreFetchListResponseHasMoreKey];
            
            // 使用itemIndex后，就不用排序了
            // NSArray * sortedDataList = [ExploreListHelper sortByIndexForArray:allItems listType:listType];
            [operationContext setValue:allItems forKey:kExploreFetchListItemsKey];
            //    sortedDataList = SSConvertToRobustObject(sortedDataList, nil);
            self.didFinishedBlock(allItems, nil, operationContext);
            self.hasFinished = YES;
            [exploreMixedListConsumeTimeStamps setValue:@([NSObject currentUnixTime])
                                                 forKey:kExploreFetchListGetLocalDataOperationEndTimeStampKey];
            [self executeNext:operationContext];
        }
    } else {
        BOOL canLoadMore = YES;
        if (!TTNetworkConnected()) {
            canLoadMore = NO;
        }
        [operationContext setObject:[NSNumber numberWithBool:canLoadMore] forKey:kExploreFetchListResponseHasMoreKey];
        
        // 使用itemIndex后，就不用排序了
        // NSArray * sortedDataList = [ExploreListHelper sortByIndexForArray:allItems listType:listType];
        [operationContext setValue:allItems forKey:kExploreFetchListItemsKey];
        //    sortedDataList = SSConvertToRobustObject(sortedDataList, nil);
        self.didFinishedBlock(allItems, nil, operationContext);
        self.hasFinished = YES;
        [exploreMixedListConsumeTimeStamps setValue:@([NSObject currentUnixTime])
                                             forKey:kExploreFetchListGetLocalDataOperationEndTimeStampKey];
        [self executeNext:operationContext];
    }
}

+ (NSArray *)fixOrderedDataWhenQueryFromDB:(NSArray *)sortedDataList withCategoryID:(NSString *)categoryID
{
    NSMutableArray * array = [NSMutableArray arrayWithCapacity:[sortedDataList count]];
    
    for (ExploreOrderedData * data in sortedDataList) {
        BOOL couldAdd = YES;
        
        if (!data.originalData) {
            [[TTMonitor shareManager] trackService:@"db_lost_origin_data"
                                             value:@{@"status" : @(1),
                                                     @"category_id" : data.categoryID?:@"unknow",
                                                     @"cell_type" : @(data.cellType)}
                                             extra:nil];
            couldAdd = NO;
        }
        else if ([data.originalData.notInterested boolValue]) {
            couldAdd = NO;
        }
        else if (data.cellDeleted) {
            couldAdd = NO;
        }
//        else if (data.surveyListData) {
//            couldAdd = NO;
//        }
//        else if (data.surveyPairData) {
//            couldAdd = NO;
//        }
        
        if (couldAdd) {
//            if ([data.originalData isKindOfClass:[Thread class]]) {
//                Thread *thread = (Thread *)data.originalData;
//                if ((thread.originThreadID.longLongValue > 0 && thread.originThread == nil)
//                    || (thread.originGroupID.longLongValue > 0 && thread.originGroup == nil)) {
//                    couldAdd = NO;
//                    [[TTMonitor shareManager] trackService:@"db_lost_origin_data"
//                                                     value:@{@"status" : @(2),
//                                                             @"category_id" : data.categoryID?:@"unknow",
//                                                             @"cell_type" : @(data.cellType)}
//                                                     extra:nil];
//                }
//            }
//            if ([data.originalData isKindOfClass:[FRCommentRepost class]]) {
//                FRCommentRepost *commentRepost = (FRCommentRepost *)data.originalData;
//                if ((commentRepost.originThreadID.longLongValue > 0 && commentRepost.originThread == nil)
//                    && (commentRepost.originGroupID.longLongValue > 0 && commentRepost.originGroup == nil)) {
//                    couldAdd = NO;
//                    [[TTMonitor shareManager] trackService:@"db_lost_origin_data"
//                                                     value:@{@"status" : @(3),
//                                                             @"category_id" : data.categoryID?:@"unknow",
//                                                             @"cell_type" : @(data.cellType)}
//                                                     extra:nil];
//                }
//            }
        }

//        if ([categoryID isEqualToString:kTTFollowCategoryID] && [KitchenMgr getBOOL:kKUGCFollowCategoryClearUnFollowThreadEnable]) {
//            if (![[TTFollowCategoryFetchExtraManager shareInstance] isFollowAuthorData:data]) {
//                couldAdd = NO;
//                NSArray * orderedDataArray = [ExploreOrderedData objectsWithQuery:@{@"uniqueID":data.primaryID}];
//                [ExploreOrderedData removeEntities:orderedDataArray];
//            }
//        }

        if (couldAdd) {
            [array addObject:data];
        }
    }
    
    return [NSArray arrayWithArray:array];
}

@end
