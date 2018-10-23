//
//  ArticleInsertDataOperation.m
//  Article
//
//  Created by Dianwei on 12-11-18.
//
//

#import "ArticleInsertDataOperation.h"
#import "ExploreOrderedData+TTBusiness.h"
#import "ListDataHeader.h"

#import "ExploreFetchListDefines.h"
#import "ExploreOrderedData+TTBusiness.h"
#import "ExploreOriginalData.h"
#import "Article.h"
#import "Card+CoreDataClass.h"
#import "NSObject+TTAdditions.h"


@implementation ArticleInsertDataOperation

- (Class)orderedDataClass
{
    return [ExploreOrderedData class];
}

- (void)execute:(NSMutableDictionary *)operationContext
{    
    //持久数据
    NSDictionary *mCondition = [operationContext objectForKey:kExploreFetchListConditionKey];
    NSMutableDictionary * exploreMixedListConsumeTimeStamps = [mCondition objectForKey:kExploreFetchListRefreshOrLoadMoreConsumeTimeStampsKey];
    [exploreMixedListConsumeTimeStamps setValue:@([NSObject currentUnixTime]) forKey:kExploreFetchListInsertDataOperationBeginTimeStampKey];
     
    NSArray *responseRemotePersistentData = [operationContext objectForKey:kExploreFetchListResponseRemotePersistantDataKey];
    BOOL shouldPersist = YES;
    if ([mCondition objectForKey:kExploreFetchListResponseRemoteDataShouldPersistKey]) {
        //详情页无限loadmore时不需要持久化
        shouldPersist = [mCondition tt_boolValueForKey:kExploreFetchListResponseRemoteDataShouldPersistKey];
    }
    
    NSArray *cardArticles = [operationContext objectForKey:kExploreFetchListResponseArticleInCardDataKey];
    NSArray *cardStockDatas = [operationContext objectForKey:kExploreFetchListResponseStockDataInCardDataKey];
    NSArray *cardBookDatas = [operationContext objectForKey:kExploreFetchListResponseBookDataInCardDataKey];
    
    NSArray *horizontalCardShortVideoDatas = [operationContext objectForKey:kExploreFetchListResponseShortVideoDataInCardDataKey];
    
    BOOL isSilentFetchFromRemote = NO;
    if ([operationContext objectForKey:kExploreFetchListConditionKey][kExploreFetchListSilentFetchFromRemoteKey]) {
        isSilentFetchFromRemote = YES;
    }
    
    NSMutableArray *objectsToBeSaved = [NSMutableArray arrayWithCapacity:20];
    
    if ([SSCommonLogic newItemIndexStrategyEnable]) {
        NSArray *allItems = [operationContext objectForKey:kExploreFetchListItemsKey];
        long long itemIndex = 0;
        if (allItems && allItems.count > 0) {
            ExploreOrderedData *lastData = [allItems lastObject];
            itemIndex = lastData.itemIndex;
        }
        
        BOOL onlyLastRead = NO;
        if ([allItems count] == 1) {
            ExploreOrderedData *orderedData = allItems.firstObject;
            if ([orderedData isKindOfClass:[ExploreOrderedData class]] && orderedData.cellType == ExploreOrderedDataCellTypeLastRead) {
                onlyLastRead = YES;
            }
        }
        
        NSUInteger newCount = responseRemotePersistentData.count;
        NSMutableArray *updatedData = [[NSMutableArray alloc] initWithCapacity:newCount];
        BOOL getMore = [[operationContext objectForKey:kExploreFetchListGetMoreKey] boolValue];
        if (getMore && itemIndex > 0 && !onlyLastRead) {
            NSInteger index = 1;
            if (newCount > 0) {
                for (NSDictionary *dic in responseRemotePersistentData) {
                    NSMutableDictionary *newDic = [[NSMutableDictionary alloc] initWithDictionary:dic];
                    [newDic setValue:@(itemIndex - index) forKey:@"itemIndex"];
                    index++;
                    [updatedData addObject:newDic];
                }
            }
        } else {
            NSInteger itemCount = newCount;
            uint64_t time = [[NSDate date] timeIntervalSince1970] * kFeedItemIndexUnixTimeMultiplyPara;
            for (NSDictionary *dic in responseRemotePersistentData) {
                NSMutableDictionary *newDic = [[NSMutableDictionary alloc] initWithDictionary:dic];
                [newDic setValue:@(time + itemCount) forKey:@"itemIndex"];
                itemCount--;
                [updatedData addObject:newDic];
            }
        }
        
        responseRemotePersistentData = updatedData;
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        if (cardArticles.count > 0) {
            NSArray *insertedCardArticles =
            [ExploreOrderedData insertObjectsWithDataArray:cardArticles];
            LOGD(@"insertedCardArticles %ld", (long)(insertedCardArticles.count));
            [objectsToBeSaved addObjectsFromArray:insertedCardArticles];
        }
        
        if (cardStockDatas.count > 0) {
            NSArray *stocks = [ExploreOrderedData insertObjectsWithDataArray:cardStockDatas];
            [objectsToBeSaved addObjectsFromArray:stocks];
        }
        
        if (cardBookDatas.count > 0) {
            NSArray *books = [ExploreOrderedData insertObjectsWithDataArray:cardBookDatas];
            [objectsToBeSaved addObjectsFromArray:books];
        }
        
        if (horizontalCardShortVideoDatas.count > 0) {
            NSArray *shortVideoDatas = [ExploreOrderedData insertObjectsWithDataArray:horizontalCardShortVideoDatas];
            [objectsToBeSaved addObjectsFromArray:shortVideoDatas];
        }
        
        NSArray *insertedArray = nil;
        
        if (isSilentFetchFromRemote) {

            NSMutableArray *results = [NSMutableArray array];
            if (responseRemotePersistentData.count > 0) {
                [responseRemotePersistentData enumerateObjectsUsingBlock:^(NSDictionary *dict, NSUInteger idx, BOOL *stop) {
                    if (idx == 0) {
                        NSMutableDictionary *mdic = [NSMutableDictionary dictionaryWithDictionary:dict];
                        TTEntityBase *entity = [ExploreOrderedData objectWithDictionary:mdic];
                        [results addObject:entity];
                        *stop = YES;
                    }
                }];
            }
            
            insertedArray = results;
        } else {
            insertedArray = [ExploreOrderedData insertObjectsWithDataArray:responseRemotePersistentData save:shouldPersist];
        }
        
        NSUInteger newNumber = insertedArray.count;
        [objectsToBeSaved addObjectsFromArray:insertedArray];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [operationContext setObject:insertedArray forKey:kExploreFetchListInsertedPersetentDataKey];
            [operationContext setObject:@(newNumber) forKey:@"new_number"];
            [operationContext setObject:objectsToBeSaved forKey:@"objectsToBeSaved"];
            [exploreMixedListConsumeTimeStamps setValue:@([NSObject currentUnixTime]) forKey:kExploreFetchListInsertDataOperationEndTimeStampKey];
            [self executeNext:operationContext];
        });
    });
}


@end
