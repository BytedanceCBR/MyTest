//
//  TSVShortVideoListFetchManager.m
//  Article
//
//  Created by 王双华 on 2017/6/20.
//
//

#import "TSVShortVideoFeedFetchManager.h"

#import "ExploreFetchListManager.h"
#import "ExploreOrderedData+TTBusiness.h"
#import "ListDataHeader.h"
#import <extobjc.h>
#import "TTShortVideoModel.h"
#import "TTShortVideoModel+TTAdFactory.h"
#import "ExploreOrderedData+TTBusiness.h"
#import "TSVShortVideoOriginalData.h"
#import "TTAdShortVideoModel.h"
#import <ReactiveObjC.h>


@interface TSVShortVideoFeedFetchManager ()
@property (nonatomic, strong) ExploreFetchListManager *listManager;
@property (nonatomic, strong) NSArray<ExploreOrderedData *> *items;
@property (nonatomic, strong) NSSet *specialOriginalDataClass;
@end

@implementation TSVShortVideoFeedFetchManager

- (instancetype)init {
    self = [super init];
    if (self) {
        _listManager = [[ExploreFetchListManager alloc] init];
        [self bindRAC];
    }
    return self;
}

- (void)bindRAC
{
    RAC(self, isLoadingRequest) = RACObserve(self, listManager.isLoading);
    RAC(self, hasMoreToLoad) = RACObserve(self, listManager.loadMoreHasMore);
    RAC(self, lastFetchRiseError) = RACObserve(self, listManager.lastFetchRiseError);
}

#pragma mark -- TSVShortVideoDataFetchManagerProtocol

- (void)replaceObjectAtIndex:(NSInteger)index withObject:(id)item
{
    if (index < [_items count]) {
        NSMutableArray * array = [NSMutableArray arrayWithArray:_items];
        id originObject = _items[index];
        [array replaceObjectAtIndex:index withObject:item];
        self.items = [NSArray arrayWithArray:array];
        // syn list manager
        NSInteger sourceIndex = [self.listManager.items indexOfObject:originObject];
        [self.listManager replaceObjectAtIndex:sourceIndex withObject:item];
    }
}

#pragma mark -
- (void)updateListModels {
    NSUInteger index = 0;
    NSMutableArray<ExploreOrderedData *> *niceItems = [[NSMutableArray alloc] initWithCapacity:self.listManager.items.count];
    NSMutableArray *viceItems = [[NSMutableArray alloc] init];
    
    NSArray *items = self.listManager.items;
    for (; index < items.count; index++) {
        ExploreOrderedData *orderedData = items[index];
        if (![orderedData isKindOfClass:[ExploreOrderedData class]]) { // 数据错误
            continue;
        }
        if (orderedData.originalData.notInterested.boolValue) { // dislike
            [viceItems addObject:orderedData];
            continue;
        }
        if ([orderedData.shortVideoOriginalData.shortVideo isAd]) {
            TTAdShortVideoModel *adModel = orderedData.shortVideoOriginalData.shortVideo.rawAd;
            if ([adModel isExpire:orderedData.requestTime]) {
                continue;
            }
            if ([adModel ignoreApp]) {
                continue;
            }
            if ((adModel.show_type & TTAdShorVideoShowInFeed) != TTAdShorVideoShowInFeed ||
                adModel.show_type == TTAdShorVideoShowInFeed) { // 非Feed广告, 暂时屏蔽 1 的广告
                continue;
            }
        }
        [niceItems addObject:orderedData];
    }
    self.items = niceItems.copy;
    [self.listManager removeItemArray:viceItems];
}

/*
 在小视频频道内，推人卡片的之前必须是偶数个小视频，否则会有空白，这个方法调整推人卡片在列表中的位置
 */
#pragma mark - 特殊的调整频道items排序的逻辑
- (void)registerSpecialOriginalDataClass:(NSSet *)specialOriginalDataClass
{
    self.specialOriginalDataClass = [specialOriginalDataClass copy];
}

- (void)adjustTSVItemsOrder
{
    [self adjustTSVItemsOrderWithDeleteItems:nil finishBlock:nil];
}

- (void)adjustTSVItemsOrderWithInsertItems:(NSArray <ExploreOrderedData *>*)insertItems atIndex:(NSInteger)insertIndex finishBlock:(TSVAdjustItemsOrderFinishBlock)finishBlock
{
    NSParameterAssert(insertItems.count >= 0 && insertIndex >= 0 && insertIndex <= self.items.count);
    if (insertItems.count <= 0 || insertIndex < 0 || insertIndex > self.items.count) {
        return;
    }
    
    // 调整后的数组
    NSMutableArray *adjustedItems = [NSMutableArray array];
    // 待删除的index、待插入的index
    NSMutableArray *deleteIndexArray = [NSMutableArray array];
    NSMutableArray *insertIndexArray = [NSMutableArray array];
    // 数组插入后，记录需要调整的special item的位置
    NSMutableArray *specialItemRecordArr = [NSMutableArray array];
    
    NSInteger currentItemIndex = 0;
    for (ExploreOrderedData *data in self.items) {
        if ([self isSpecialItemForOrderedData:data]) {
            if (currentItemIndex < insertIndex) {
                // 特殊的之前没有要插入的元素
                [adjustedItems addObject:data];
            } else if (currentItemIndex == insertIndex) {
                // 刚好位置相等
                [adjustedItems addObject:data];
                insertIndex++;
            } else {
                [deleteIndexArray addObject:@(currentItemIndex)];
                [specialItemRecordArr addObject:@{
                                                  @"data" : data,
                                                  @"index" : @(currentItemIndex)
                                                  }];
            }
        } else {
            [adjustedItems addObject:data];
        }
        currentItemIndex++;
    }
    
    NSInteger toInsertIndex = insertIndex;
    for (ExploreOrderedData *insertItem in insertItems) {
        // 完成插入操作
        [adjustedItems insertObject:insertItem atIndex:insertIndex];
        [insertIndexArray addObject:@(toInsertIndex)];
        toInsertIndex++;
    }
    
    // 需要插入的每个special item的原始位置
    for (NSDictionary *dict in specialItemRecordArr) {
        ExploreOrderedData *specialItem = dict[@"data"];
        NSInteger index = [dict[@"index"] integerValue];
        
        [adjustedItems insertObject:specialItem atIndex:index];
        [insertIndexArray addObject:@(index)];
    }
    
    long long topItemIndex = [[NSDate date] timeIntervalSince1970] * kFeedItemIndexUnixTimeMultiplyPara;
    for (ExploreOrderedData *topData in adjustedItems) {
        if ([self isSpecialItemForOrderedData:topData]) {
            topData.itemIndex = topItemIndex;
            topItemIndex--;
            [topData save];
        } else {
            break;
        }
    }
    
    // 同步到list manager
    ExploreOrderedData *listItem = nil;
    if (insertIndex < self.items.count) {
        listItem = self.items[insertIndex];
    }
    NSInteger listIndex = 0;
    if (listItem == nil) {
        listIndex = self.listManager.items.count;
    } else {
        listIndex = [self.listManager.items indexOfObject:listItem];
    }
    self.items = [adjustedItems copy];
    [self.listManager insertItems:insertItems atIndex:listIndex];
    [[ExploreFetchListHistoryManager sharedInstance] saveFeedHistoryForCategoryID:self.categoryID withItems:[adjustedItems copy]];
    
    if (finishBlock) {
        finishBlock([deleteIndexArray copy], [insertIndexArray copy]);
    }
}

- (void)adjustTSVItemsOrderWithDeleteItems:(NSArray *)deleteItems finishBlock:(TSVAdjustItemsOrderFinishBlock)finishBlock
{
    // 调整后的数组
    NSMutableArray *adjustedItems = [NSMutableArray array];
    // 待删除的index、待插入的index
    NSMutableArray *deleteIndexArray = [NSMutableArray array];
    NSMutableArray *insertIndexArray = [NSMutableArray array];
    // 数组删除后，记录相邻special item之间普通数据个数
    NSMutableArray *specialItemRecordArr = [NSMutableArray array];
    // 当前相邻special item之间普通数据个数
    NSInteger curSectionNormalItemsCount = 0;
    
    // 先遍历一遍，把该删的删了，特殊的也先删了，后面再插入，adjustedItems只留下普通的Items
    NSInteger currentItemIndex = 0;
    // 需要插入的special item的section起始位置
    NSInteger specialItemInsertSectionBeginIndex = 0;
    
    for (ExploreOrderedData *data in self.items) {
        if ([deleteItems containsObject:data] || ![self isSupportInShortVideoCollectionViewForOrderedData:data]) {
            // 在待删除的数组里
            [deleteIndexArray addObject:@(currentItemIndex)];
        } else if ([self isSpecialItemForOrderedData:data]) {
            // special item
            // 遇见特殊的时候是否需要删除特殊的：1.之前已经有需要调整的特殊的 2.当前区域普通item的个数是奇数
            BOOL shouldAdjustSpecialItem = (specialItemRecordArr.count > 0 || curSectionNormalItemsCount % 2 == 1);
            
            if (!shouldAdjustSpecialItem) {
                [adjustedItems addObject:data];
                specialItemInsertSectionBeginIndex = currentItemIndex + 1;
            } else {
                [deleteIndexArray addObject:@(currentItemIndex)];
                [specialItemRecordArr addObject:@{
                                                  @"data" : data,
                                                  @"count" : @(curSectionNormalItemsCount)
                                                  }];
            }
            curSectionNormalItemsCount = 0;
        } else {
            [adjustedItems addObject:data];
            curSectionNormalItemsCount++;
        }
        currentItemIndex++;
    }
    
    for (NSDictionary *dict in specialItemRecordArr) {
        ExploreOrderedData *specialItem = dict[@"data"];
        NSInteger preItemsCount = [dict[@"count"] integerValue];
        
        NSInteger targetIndex = specialItemInsertSectionBeginIndex + preItemsCount;
        
        // 如果要插入的位置超过当前数组元素的个数
        if (targetIndex > adjustedItems.count) {
            targetIndex = adjustedItems.count;
            preItemsCount = targetIndex - specialItemInsertSectionBeginIndex;
        }
        
        if (preItemsCount % 2 == 1) {
            // 前面奇数个
            if (targetIndex < adjustedItems.count) {
                // 后面还有可以摆放的普通的，把特殊的后移
                targetIndex ++;
            } else {
                // 把特殊的前移
                targetIndex --;
            }
        }
        
        [adjustedItems insertObject:specialItem atIndex:targetIndex];
        [insertIndexArray addObject:@(targetIndex)];
        specialItemInsertSectionBeginIndex = targetIndex + 1;
    }
    
    self.items = [adjustedItems copy];
    [self.listManager removeItemArray:deleteItems];
    
    if (finishBlock) {
        finishBlock([deleteIndexArray copy], [insertIndexArray copy]);
    }
}

- (BOOL)isSpecialItemForOrderedData:(ExploreOrderedData *)data
{
    if ([self.specialOriginalDataClass containsObject:[data.originalData class]]) {
        return YES;
    }
    return NO;
}

///小视频列表支持展示的数据
- (BOOL)isSupportInShortVideoCollectionViewForOrderedData:(ExploreOrderedData *)data
{
    switch (data.cellType) {
        case ExploreOrderedDataCellTypeShortVideoStory:
        case ExploreOrderedDataCellTypeShortVideo:
        case ExploreOrderedDataCellTypeShortVideoRecommendUserCard:
        case ExploreOrderedDataCellTypeShortVideoPublishStatus:
        case ExploreOrderedDataCellTypeShortVideoActivityEntrance:
        case ExploreOrderedDataCellTypeShortVideoActivityBanner:
        case ExploreOrderedDataCellTypeShortVideo_AD:
            return YES;
            break;
        default:
            NSAssert(NO, @"小视频列表不支持这种cell_type的数据");
            break;
    }
    return NO;
}

- (void)resetManager {
    [self.listManager resetManager];
}

- (void)cancelAllOperations {
    [self.listManager cancelAllOperations];
}

- (void)reuserAllOperations {
    [self.listManager reuserAllOperations];
}

- (void)deleteOrderedDataIfNeedWithComplete:(TSVDeleteItemsFinishBlock)completeBlock {
    if (self.items.count <= 0){
        return;
    }
    BOOL hasNotInterestedData = NO;
    NSMutableArray *shouldDeleteDataArray = [NSMutableArray array];
    for (ExploreOrderedData *orderedData in self.listManager.items) {
        if ([orderedData.originalData.notInterested boolValue]) {
            [shouldDeleteDataArray addObject:orderedData];
            hasNotInterestedData = YES;
        } else if (orderedData.shortVideoOriginalData.shortVideo.shouldDelete) {
            [shouldDeleteDataArray addObject:orderedData];
        }
    }
    if (completeBlock) {
        completeBlock(shouldDeleteDataArray, hasNotInterestedData);
    }
}

/**
 *  请求stream数据
 *
 *  @param condition        condition
 *  @param fromLocal        从本地加载
 *  @param fromRemote       从网络加载
 *  @param getMore          YES： 加载更多，  NO： 刷新
 *  @param display          是否是当前显示的
 *  @param listType         列表类型
 *  @param fetchFinishBlock 完成的Block
 */
- (void)startExecuteWithCondition:(nonnull NSDictionary*)condition
                        fromLocal:(BOOL)fromLocal
                       fromRemote:(BOOL)fromRemote
                          getMore:(BOOL)getMore
                     isDisplyView:(BOOL)display
                         listType:(ExploreOrderedDataListType)listType
                     listLocation:(ExploreOrderedDataListLocation)listLocation
                      finishBlock:(nullable ExploreFetchListFinishBlock)fetchFinishBlock {
    
    [self.listManager startExecuteWithCondition:condition fromLocal:fromLocal fromRemote:fromRemote getMore:getMore isDisplyView:display listType:listType listLocation:listLocation finishBlock:fetchFinishBlock];
}

@end
