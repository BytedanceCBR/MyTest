//
//  ArticlePostSaveOperation.m
//  Article
//
//  Created by Dianwei on 12-11-18.
//
//

#import "ArticlePostSaveOperation.h"
#import "ListDataHeader.h"

#import "ExploreOrderedData.h"
#import "ExploreOrderedData+TTBusiness.h"
#import "ExploreCellHelper.h"

#import "Article.h"
#import "Card+CoreDataClass.h"
#import "ExploreFetchListDefines.h"
#import "ExploreListHelper.h"
#import "WapData.h"
#import "NSObject+TTAdditions.h"
#import "ExploreOrderedData+TTAd.h"

@implementation ArticlePostSaveOperation
- (Class)orderedDataClass
{
    return [ExploreOrderedData class];
}

- (void)execute:(NSMutableDictionary *)operationContext
{
    if ([operationContext objectForKey:kExploreFetchListConditionKey][kExploreFetchListSilentFetchFromRemoteKey]) {
        NSArray * increasePresentedItems = [operationContext objectForKey:kExploreFetchListInsertedPersetentDataKey];
        NSMutableArray * increaseItems = [NSMutableArray arrayWithArray:increasePresentedItems];
        
        [self notifyWithData:increaseItems error:nil userInfo:operationContext];
        return;
    }
    
    NSMutableDictionary * exploreMixedListConsumeTimeStamps = [[operationContext objectForKey:kExploreFetchListConditionKey] objectForKey:kExploreFetchListRefreshOrLoadMoreConsumeTimeStampsKey];
    [exploreMixedListConsumeTimeStamps setValue:@([NSObject currentUnixTime]) forKey:kExploreFetchListPostSaveOperationBeginTimeStampKey];
    
    NSArray * allItems = [operationContext objectForKey:kExploreFetchListItemsKey];
    NSArray * increasePresentedItems = [operationContext objectForKey:kExploreFetchListInsertedPersetentDataKey];
    
    BOOL getMore = [[operationContext objectForKey:kExploreFetchListGetMoreKey] boolValue];
    NSDictionary *result = [operationContext objectForKey:kExploreFetchListResponseRemoteDataKey];
    BOOL hasMore = [[(NSDictionary *)[result objectForKey:@"result"] objectForKey:@"has_more"] boolValue];
    BOOL hasNew = [[(NSDictionary *)[result objectForKey:@"result"] objectForKey:@"has_more_to_refresh"] boolValue];

    ExploreOrderedDataListType listType = [[operationContext objectForKey:kExploreFetchListListTypeKey] intValue];
    
    NSMutableArray * increaseItems = [NSMutableArray arrayWithArray:increasePresentedItems];
    
    NSDictionary * sortedDicts = [ArticlePostSaveOperation sortList:allItems increaseItems:increaseItems isGetMore:getMore hasMore:hasMore needSaveDB:NO listType:listType];
    
    NSUInteger uniqueIncreaseCount = [[sortedDicts objectForKey:kExploreFetchListResponseMergeUniqueIncreaseCountKey] intValue];
    [operationContext setValue:@(uniqueIncreaseCount) forKey:kExploreFetchListResponseMergeUniqueIncreaseCountKey];
    
    NSArray * originalAllItems = [sortedDicts objectForKey:@"originalAllItems"];
    NSArray * sortedAllItems = [sortedDicts objectForKey:@"resultAllItems"];
    NSArray * mergedSortedIncreaseItems = [sortedDicts objectForKey:@"sortedIncreaseItems"];
        
    BOOL canLoadMore = YES;
    if(getMore && !hasMore)
    {
        canLoadMore = NO;
    }
    
    NSString *unitID = [operationContext objectForKey:kExploreFetchListConditionKey][kExploreFetchListConditionListUnitIDKey];
    BOOL isUGCFollowChannel = [unitID isKindOfClass:[NSString class]] && [unitID isEqualToString:kTTFollowCategoryID];
    if ([SSCommonLogic feedLoadMoreWithNewData] && !isUGCFollowChannel) {
        [operationContext setObject:originalAllItems forKey:kExploreFetchListItemsKey];
    } else {
        // 老的逻辑走这里
        [operationContext setObject:sortedAllItems forKey:kExploreFetchListItemsKey];
    }
    
    [operationContext setObject:[NSNumber numberWithBool:canLoadMore] forKey:kExploreFetchListResponseHasMoreKey];
    
    //增加字段：表示server是否还有新article可供刷新
    if (!getMore) {
        [operationContext setObject:@(hasNew) forKey:kExploreFetchListResponseHasNewKey];
    }
    
    // store to cache
    //忽略 kListDataConditionRankKey
    //    NSDictionary *condition = [operationContext objectForKey:kExploreFetchListConditionKey];
    //    NSMutableDictionary *keyDict = [NSMutableDictionary dictionaryWithDictionary:condition];
    //    [keyDict removeObjectForKey:kExploreFetchListConditionBeHotTimeKey];
    [operationContext setObject:[NSNumber numberWithBool:YES] forKey:kExploreFetchListResponseFinishedkey];
    
    if ([sortedDicts objectForKey:@"tableviewOffset"]) {
        [operationContext setObject:[sortedDicts objectForKey:@"tableviewOffset"] forKey:@"tableviewOffset"];
    }
    
    if (self.didFinishedBlock) {
        self.didFinishedBlock(mergedSortedIncreaseItems, nil, operationContext);
    }
    
    [exploreMixedListConsumeTimeStamps setValue:@([NSObject currentUnixTime]) forKey:kExploreFetchListPostSaveOperationEndTimeStampKey];
    [self notifyWithData:mergedSortedIncreaseItems error:nil userInfo:operationContext];
    
    [self executeNext:operationContext];
}

+ (NSDictionary *)sortList:(NSArray*)showedAllItems increaseItems:(NSArray *)increaseItems isGetMore:(BOOL)getMore hasMore:(BOOL)hasMore needSaveDB:(BOOL)saveDB listType:(ExploreOrderedDataListType)listType
{
    if (!getMore && hasMore) {
        NSArray * sortedIncreaseItems = [ExploreListHelper sortByIndexForArray:increaseItems listType:listType];
        
        NSMutableDictionary * resultDicts = [NSMutableDictionary dictionaryWithCapacity:10];
        
        // 过滤标记为删除的数据(is_deleted)
        NSMutableArray * mutableSortedIncreaseItems = [NSMutableArray arrayWithCapacity:10];

        for (id item in sortedIncreaseItems) {
            BOOL couldAdd = YES;
            if ([item isKindOfClass:[ExploreOrderedData class]]) {
                if (((ExploreOrderedData *)item).cellDeleted) {
                    couldAdd = NO;
                }
            }
            
            if (couldAdd) {
                [mutableSortedIncreaseItems addObject:item];
            }
        }
        
        [resultDicts setValue:mutableSortedIncreaseItems forKey:@"originalAllItems"];
        [resultDicts setValue:mutableSortedIncreaseItems forKey:@"resultAllItems"];
        [resultDicts setValue:mutableSortedIncreaseItems forKey:@"sortedIncreaseItems"];
        [resultDicts setValue:@([mutableSortedIncreaseItems count]) forKey:kExploreFetchListResponseMergeUniqueIncreaseCountKey];
        return resultDicts;
    }
    
    NSMutableArray * mutableShowedAllItems = [NSMutableArray arrayWithArray:showedAllItems];
    NSMutableDictionary * uniqueIDDicts = [NSMutableDictionary dictionaryWithCapacity:20];
    
    NSUInteger uniqueIncreaseItemsCount = 0;    //新增消重后的item数量
    
    // 计算可能消重的offset
    CGFloat delCellHeight = 0;
    
    for (id item in showedAllItems) {
        if ([item isKindOfClass:[ExploreOrderedData class]]) {
            if (((ExploreOrderedData *)item).cellDeleted) {//如果客户端标记需要在下一刷删除该cell
                [mutableShowedAllItems removeObject:item];
            }
            else{
                NSString *ad_id = [(ExploreOrderedData *)item ad_id];
                NSNumber *uniqueID = @(((ExploreOrderedData *)item).originalData.uniqueID);
                NSString *key = [NSString stringWithFormat:@"%@_%@", uniqueID, ad_id != nil ? ad_id : @""];
                [uniqueIDDicts setObject:item forKey:key];
            }
        }
    }
    NSMutableArray * mutableSortedIncreaseItems = [NSMutableArray arrayWithCapacity:10];
    BOOL needSaveDB = NO;
    if (saveDB) {//如果前面有修改，需要更新数据库
        needSaveDB = YES;
    }
    for (id item in increaseItems) {
        //判断新增的持久化Model中是否有与之前重复的， 如果有，则删除之前的
        NSString *adIDStr = [(ExploreOrderedData *)item ad_id];
        NSNumber *uniqueID = @(((ExploreOrderedData *)item).originalData.uniqueID);
        NSString *key = [NSString stringWithFormat:@"%@_%@", uniqueID, adIDStr != nil ? adIDStr : @""];
        
        if ([uniqueIDDicts objectForKey:key]) {//重复
            id repeatItem = [uniqueIDDicts objectForKey:key];
            [mutableShowedAllItems removeObject:repeatItem];
            
            // 累计消重的offset
            if (getMore) {
                delCellHeight += [ExploreCellHelper heightForData:item cellWidth:SSScreenWidth listType:listType];
            }
        }
        else {
            [uniqueIDDicts setObject:item forKey:key];
            uniqueIncreaseItemsCount ++;
        }

        BOOL couldAdd = YES;
        
        //卡片内部cell数量为0时不展示
        ExploreOriginalData * originalData = ((ExploreOrderedData *)item).originalData;
        if ([originalData isKindOfClass:[Card class]]) {
            Card *card = (Card *)originalData;
            if (card.cardItems.count == 0) {
                couldAdd = NO;
            }
        }
            
        if (((ExploreOrderedData *)item).cellDeleted ||//判断删除标记
            [((ExploreOrderedData *)item).originalData.notInterested boolValue])//判断不感兴趣
        {
            couldAdd = NO;
        }
        
        if (couldAdd) {
            [mutableSortedIncreaseItems addObject:item];
        }
    }
        
    NSMutableArray * result = [NSMutableArray arrayWithCapacity:10];
    if (getMore) {
        [result addObjectsFromArray:mutableShowedAllItems];
        [result addObjectsFromArray:mutableSortedIncreaseItems];
    }
    else {
        [result addObjectsFromArray:mutableSortedIncreaseItems];
        [result addObjectsFromArray:mutableShowedAllItems];
    }
    
    // 重要！ 老的逻辑这里使用的[ExploreListHelper sortByIndexForArray:result listType:listType]，现在不用排序了
    NSArray * sortedResult = result;
    
    NSMutableDictionary * resultDicts = [NSMutableDictionary dictionaryWithCapacity:10];
    [resultDicts setValue:result forKey:@"originalAllItems"];
    [resultDicts setValue:sortedResult forKey:@"resultAllItems"];
    [resultDicts setValue:mutableSortedIncreaseItems forKey:@"sortedIncreaseItems"];
    [resultDicts setValue:@(delCellHeight) forKey:@"tableviewOffset"];
    [resultDicts setValue:@(uniqueIncreaseItemsCount) forKey:kExploreFetchListResponseMergeUniqueIncreaseCountKey];
    return resultDicts;
}


@end
