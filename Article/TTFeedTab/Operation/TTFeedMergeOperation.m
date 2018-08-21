//
//  TTFeedMergeOperation.m
//  Article
//
//  Created by fengyadong on 16/11/15.
//
//

#import "TTFeedMergeOperation.h"
#import "ExploreOrderedData+TTBusiness.h"
#import "TTFeedContainerViewModel.h"
#import "ExploreFetchListDefines.h"
#import "ExploreListHelper.h"
#import "ExploreOriginalData.h"
#import "TTHistoryEntryGroup.h"
#import "Card+CoreDataClass.h"
#import "TTHistoryEntryGroup.h"
#import <SDWebImage/SDWebImageCompat.h>

@interface TTFeedMergeOperation ()

@property (nonatomic, assign) uint64_t startTime;
@property (nonatomic, assign) uint64_t endTime;
@property (nonatomic, assign) BOOL canLoadMore;
@property (nonatomic, assign) BOOL hasNew;
@property (nonatomic, strong) NSArray *sortedAllItems;
@property (nonatomic, strong) NSArray *sortedIncreaseItems;

@end

@implementation TTFeedMergeOperation

@synthesize startTime = _startTime;
@synthesize endTime = _endTime;

- (instancetype)initWithViewModel:(TTFeedContainerViewModel *)viewModel {
    if (self = [super initWithViewModel:viewModel]) {
    }
    return self;
}

- (void)asyncOperation {
    self.startTime = [NSObject currentUnixTime];
    
    NSArray * allItems = self.viewModel.allItems;

    NSDictionary *result = self.viewModel.remoteDict;
    BOOL hasMore = [[result objectForKey:@"has_more"] boolValue];
    BOOL hasNew = [[result objectForKey:@"has_more_to_refresh"] boolValue];
    
    BOOL canLoadMore = YES;
    if(self.viewModel.loadMore && !hasMore)
    {
        canLoadMore = NO;
    }
    
    self.canLoadMore = canLoadMore;
    
    //增加字段：表示server是否还有新article可供刷新
    if (!self.viewModel.loadMore) {
        self.hasNew = hasNew;
    }

    //action_to_last_stick : 0表示不处理，1表示删除置顶，2表示取消置顶
    NSNumber * actionToLastStick = @([[[result objectForKey:@"result"] objectForKey:@"action_to_last_stick"] intValue]);
    BOOL needSaveDB = NO;
    NSMutableArray * handledAllItems = [NSMutableArray array];
    if ([actionToLastStick intValue] == 1) {
        for (NSObject *item in allItems) {
            if ([item isKindOfClass:[ExploreOrderedData class]] && ((ExploreOrderedData *)item).stickStyle != 0)
            {//跳过，相当于删除
                needSaveDB = YES;
            }
            else{
                [handledAllItems addObject:item];
            }
        }
    }
    else if ([actionToLastStick intValue] == 2){
        NSUInteger cancelStickCount = 0;
        for (NSObject *item in allItems) {
            if ([item isKindOfClass:[ExploreOrderedData class]] && ((ExploreOrderedData *)item).stickStyle != 0) {//取消使用置顶的样式
                needSaveDB = YES;
                ((ExploreOrderedData *)item).isStick = NO;
                ((ExploreOrderedData *)item).stickStyle = 0;
                cancelStickCount ++;
            }
            [handledAllItems addObject:item];
        }
    }
    else{
        handledAllItems = [allItems mutableCopy];
    }
    
    [self sortList:handledAllItems increaseItems:[self.viewModel.increaseItems copy] isGetMore:self.viewModel.loadMore hasMore:hasMore needSaveDB:needSaveDB listType:self.listType];
    
    self.endTime = [NSObject currentUnixTime];
}

- (void )sortList:(NSArray*)showedAllItems increaseItems:(NSArray *)increaseItems isGetMore:(BOOL)getMore hasMore:(BOOL)hasMore needSaveDB:(BOOL)saveDB listType:(ExploreOrderedDataListType)listType
{
    if (!getMore && hasMore) {
        NSArray * sortedIncreaseItems = [ExploreListHelper sortByIndexForArray:increaseItems listType:listType];
        
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
        
        self.sortedAllItems = mutableSortedIncreaseItems;
        self.sortedIncreaseItems = mutableSortedIncreaseItems;
    }
    
    NSMutableArray * mutableShowedAllItems = [NSMutableArray arrayWithArray:showedAllItems];
    NSMutableDictionary * uniqueIDDicts = [NSMutableDictionary dictionaryWithCapacity:20];
    
    NSUInteger uniqueIncreaseItemsCount = 0;    //新增消重后的item数量
    
    for (id item in showedAllItems) {
        if ([item isKindOfClass:[ExploreOrderedData class]]) {
            if (((ExploreOrderedData *)item).cellDeleted) {//如果客户端标记需要在下一刷删除该cell
                [mutableShowedAllItems removeObject:item];
            }
            else{
                NSNumber * uniqueID = @(((ExploreOrderedData *)item).originalData.uniqueID);
                [uniqueIDDicts setObject:item forKey:uniqueID];
            }
        }
    }
    NSMutableArray * mutableSortedIncreaseItems = [NSMutableArray arrayWithCapacity:10];
    BOOL needSaveDB = NO;
    if (saveDB) {//如果前面有修改，需要更新数据库
        needSaveDB = YES;
    }
    for (id item in increaseItems) {
        if ([item isKindOfClass:[TTHistoryEntryGroup class]]) {
            [mutableSortedIncreaseItems addObject:item];
            continue;
        }
        else {
            //判断新增的持久化Model中是否有与之前重复的， 如果有，则删除之前的
            NSNumber * uniqueID = @(((ExploreOrderedData *)item).originalData.uniqueID);
            if ([[uniqueIDDicts allKeys] containsObject:uniqueID]) {//重复
                id repeatItem = [uniqueIDDicts objectForKey:uniqueID];
                [mutableShowedAllItems removeObject:repeatItem];
            }
            else {
                [uniqueIDDicts setObject:item forKey:uniqueID];
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
    }
    
//    if (needSaveDB) {
//        [[SSModelManager sharedManager] save:nil];
//    }
    
    NSMutableArray * result = [NSMutableArray arrayWithCapacity:10];
    
    [self mergeIdenticalDateGroupIfNeededFormerItems:mutableShowedAllItems laterItems:mutableSortedIncreaseItems];
    
    if (getMore) {
        [result addObjectsFromArray:mutableShowedAllItems];
        [result addObjectsFromArray:mutableSortedIncreaseItems];
        
    }
    else {
        [result addObjectsFromArray:mutableSortedIncreaseItems];
        [result addObjectsFromArray:mutableShowedAllItems];
    }
    
    self.sortedAllItems = [ExploreListHelper sortByIndexForArray:result listType:listType];
    self.sortedIncreaseItems = mutableSortedIncreaseItems;
    
    self.endTime = [NSObject currentUnixTime];
    [self didFinishCurrentOperation];
}

- (void)mergeIdenticalDateGroupIfNeededFormerItems:(NSMutableArray *)formerItems laterItems:(NSMutableArray *)laterItems {
    TTHistoryEntryGroup *formerLastGroup= [formerItems lastObject];
    TTHistoryEntryGroup *laterFirstGroup = [laterItems firstObject];
    
    if (![formerLastGroup isKindOfClass:[TTHistoryEntryGroup class]]
        || ![laterFirstGroup isKindOfClass:[TTHistoryEntryGroup class]]) {
        return;
    }
    
    if (formerLastGroup.dateIdentifier == laterFirstGroup.dateIdentifier) {
        NSMutableArray *appendingArray = [NSMutableArray arrayWithArray:formerLastGroup.orderedDataList];
        [appendingArray addObjectsFromArray:laterFirstGroup.orderedDataList];
        formerLastGroup.orderedDataList = [appendingArray copy];
        
        [laterItems removeObjectAtIndex:0];
    }
}

@end
