//
//  ExploreFetchListManager.m
//  Article
//
//  Created by Zhang Leonardo on 14-9-10.
//
//

#import "ExploreFetchListManager.h"
#import "ArticleGetLocalDataOperation.h"
#import "ArticleGetRemoteDataOperation.h"
#import "ArticleInsertDataOperation.h"
#import "ArticleSaveRemoteOperation.h"
#import "ArticlePostSaveOperation.h"

#import "ExploreOrderedData+TTBusiness.h"

#import "Article+TTADComputedProperties.h"
#import "ExploreOrderedData+TTAd.h"
#import "SSADEventTracker.h"
#import "TTAdFeedModel.h"

#import "ArticlePreInsertOperation.h"
#import "ExploreFetchListDefines.h"
#import "ExploreListHelper.h"
#import "LastRead.h"

#import "TTStringHelper.h"
#import "NSObject+MultiDelegates.h"
#import "NSObject+TTAdditions.h"
#import "NSStringAdditions.h"
#import "Article.h"
#import "Card+CoreDataClass.h"
#import "ExploreCellHelper.h"
#import "HorizontalCard.h"

#import "TSVRecUserCardOriginalData.h"
#import <TTKitchen/TTKitchen.h>
//#import "TTFollowCategoryFetchExtraManager.h"


@interface ExploreFetchListManager()<SSDataOperationDelegate>

@property (nonatomic, retain, readwrite) NSArray * items;
@property (nonatomic, retain, readwrite) NSArray * silentFetchedItems;
@property (nonatomic, assign, readwrite) BOOL loadMoreHasMore;
@property (nonatomic, assign, readwrite) BOOL isLoading;
@property (nonatomic, assign, readwrite) BOOL lastFetchRiseError;
@property (nonatomic, retain, readwrite) NSString * categoryID;
@property (nonatomic, copy)ExploreFetchListFinishBlock fetchFinishBlock;
@property (nonatomic, copy)ExploreFetchListFinishBlock silentFetchFinishBlock;

@property (nonatomic, assign, readwrite) NSInteger silentFetchTimes;
@property (nonatomic, assign, readwrite) NSTimeInterval silentFetchTimeInterval;
@property (nonatomic, assign, readwrite) NSTimeInterval lastSilentFetchInsertTime;

@property (nonatomic, assign, readwrite) ExploreMixedListRefreshType refrshType;

@property (nonatomic, strong) NSSet *specialOriginalDataClass;
@end


@implementation ExploreFetchListManager

- (void)dealloc
{
    self.fetchFinishBlock = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)startExecuteWithCondition:(NSDictionary *)condition
                        fromLocal:(BOOL)fromLocal
                       fromRemote:(BOOL)fromRemote
                          getMore:(BOOL)getMore
                     isDisplyView:(BOOL)display
                         listType:(ExploreOrderedDataListType)listType
                     listLocation:(ExploreOrderedDataListLocation)listLocation
                      finishBlock:(nullable ExploreFetchListFinishBlock)fetchFinishBlock
{
    if (self.isLoading) {
        if (condition[kExploreFetchListSilentFetchFromRemoteKey]) {
            if (fetchFinishBlock) {
                fetchFinishBlock(nil, nil, nil);
            }
            return;
        }
        
        if (fetchFinishBlock) {
            fetchFinishBlock(nil, nil, [NSError errorWithDomain:kExploreFetchListErrorDomainKey code:kExploreFetchListCategoryIDChangedCode userInfo:nil]);
        }
        return;
    }
    self.isLoading = YES;

    if (!getMore) {
        _loadMoreHasMore = YES;
    }
    
    if (condition[kExploreFetchListSilentFetchFromRemoteKey]) {
        self.silentFetchFinishBlock = fetchFinishBlock;
    } else {
        self.fetchFinishBlock = fetchFinishBlock;
    }
    
    NSString * categoryID = [condition objectForKey:kExploreFetchListConditionListUnitIDKey];
    if (!isEmptyString(_categoryID) && ![_categoryID isEqualToString:categoryID]) {
        [self resetManager];
        [self reuserAllOperations];
//        if (_fetchFinishBlock) {
//            _fetchFinishBlock(nil, nil, [NSError errorWithDomain:kExploreFetchListErrorDomainKey code:kExploreFetchListCategoryIDChangedCode userInfo:nil]);
//        }
    }
    self.categoryID = categoryID;
    
    NSMutableDictionary *context = [NSMutableDictionary dictionaryWithCapacity:5];
    NSMutableDictionary *mCondition = [NSMutableDictionary dictionaryWithDictionary:condition];
    
    if(getMore)
    {
        if([[self items] count] > 0)
        {
            [mCondition setValue:@([(ExploreOrderedData *)[[self items] lastObject] behotTime]) forKey:kExploreFetchListConditionBeHotTimeKey];
        }
    }
    else
    {
        if([[self items] count] > 0)
        {
            [mCondition setValue:@([(ExploreOrderedData *)[[self items] objectAtIndex:0] behotTime]) forKey:kExploreFetchListConditionBeHotTimeKey];
        }
        
        [mCondition setValue:@(self.refrshType) forKey:kExploreFetchListRefreshTypeKey];
        self.refrshType = ExploreMixedListRefreshTypeDefault;
    }
    
    if (mCondition[kExploreFetchListSilentFetchFromRemoteKey]) {
        NSInteger lastWitnessedIndex = [self lastWitnessedIndex];
        if (lastWitnessedIndex >= 0 && lastWitnessedIndex < [self items].count) {
            [mCondition setValue:@([[[self items] objectAtIndex:lastWitnessedIndex] behotTime]) forKey:kExploreFetchListConditionBeHotTimeKey];
        }
    }
    
    //[mCondition setValue:self forKey:kExploreListOpManagerKey];
    [context setObject:[NSNumber numberWithBool:fromLocal] forKey:kExploreFetchListFromLocalKey];
    [context setObject:[NSNumber numberWithBool:fromRemote] forKey:kExploreFetchListFromRemoteKey];
    [context setObject:[NSNumber numberWithBool:getMore] forKey:kExploreFetchListGetMoreKey];
    [context setObject:[NSNumber numberWithBool:display] forKey:kExploreFetchListIsDisplayViewKey];
    [context setValue:@(listType) forKey:kExploreFetchListListTypeKey];
    [context setValue:@(listLocation) forKey:kExploreFetchListListLocationKey];
    [context setValue:@(1) forKey:kExploreFetchListConditionIsStrictKey];

    [context setObject:mCondition forKey:kExploreFetchListConditionKey];
    [context setValue:_items forKey:kExploreFetchListItemsKey];
    [self startExecute:context];
}

- (void)resetManager
{
    [self cancelAllOperations];
    _loadMoreHasMore = YES;
    self.isLoading = NO;
    _lastFetchRiseError = NO;
    self.items = nil;
    
}

- (id)init
{
    self = [super init];
    if(self)
    {
        _loadMoreHasMore = YES;
        self.isLoading = NO;
        _lastFetchRiseError = NO;
        
        ArticleGetLocalDataOperation *localOp = [[ArticleGetLocalDataOperation alloc] init];
        localOp.opDelegate = self;
        ArticleGetRemoteDataOperation *remoteOp = [[ArticleGetRemoteDataOperation alloc] init];
        remoteOp.opDelegate = self;
        ArticlePreInsertOperation *preInsertOp = [[ArticlePreInsertOperation alloc] init];
        preInsertOp.opDelegate = self;
        ArticleInsertDataOperation *insertOp = [[ArticleInsertDataOperation alloc] init];
        insertOp.opDelegate = self;
        ArticleSaveRemoteOperation *saveOp = [[ArticleSaveRemoteOperation alloc] init];
        saveOp.opDelegate = self;
        ArticlePostSaveOperation *postSaveOp = [[ArticlePostSaveOperation alloc] init];
        postSaveOp.opDelegate = self;
        
        [self addOperation:localOp];
        [self addOperation:remoteOp];
        [self addOperation:preInsertOp];
        [self addOperation:insertOp];
        [self addOperation:saveOp];
        [self addOperation:postSaveOp];
        
        [self setupSilentFetchSettings];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateRefreshPara:) name:kExploreMixedListRefreshTypeNotification object:nil];
    }
    
    return self;
}

- (void)updateRefreshPara:(NSNotification *)notification
{
    ExploreMixedListRefreshType refreshType = [[[notification userInfo] objectForKey:@"refresh_reason"] unsignedIntegerValue];
    self.refrshType = refreshType;
}

- (void)reloadSilentFetchSettings
{
    [self setupSilentFetchSettings];
}

- (void)setupSilentFetchSettings
{
    if ([SSCommonLogic feedAutoInsertEnable]) {
        self.silentFetchTimes = [SSCommonLogic feedAutoInsertTimes];
        self.silentFetchTimeInterval = [SSCommonLogic feedAutoInsertTimeInterval];
    } else {
        self.silentFetchTimes = 0;
        self.silentFetchTimeInterval = 0;
    }
}

- (BOOL)canSilentFetchItems
{
    BOOL res = NO;
    NSDate *now = [NSDate date];
    if (!self.isLoading && [SSCommonLogic feedAutoInsertEnable] && self.silentFetchTimes > 0 && ([now timeIntervalSince1970] - self.lastSilentFetchInsertTime + 5 > self.silentFetchTimeInterval / 1000.)) {
        res = YES;
    }
    
    return res;
}

- (void)cancelAllOperations
{
    [super cancelAllOperations];
    self.isLoading = NO;
}

- (NSInteger)lastWitnessedIndex
{
    if (self.items.count > 0) {
        for (NSInteger i = 0; i < self.items.count - 1; ++i) {
            ExploreOrderedData *curObj = self.items[i];
            ExploreOrderedData *nextObj = self.items[i + 1];
            if (curObj.witnessed && !nextObj.witnessed) {
                return i;
            }
        }
        
        return self.items.count - 1;
    }
    
    return -1;
}

- (void)updateLastSilentFetchTime
{
    NSDate *now = [NSDate date];
    self.lastSilentFetchInsertTime = [now timeIntervalSince1970];
}

- (void)tryInsertSilentFetchedItem
{
    if (self.silentFetchedItems.count > 0 && self.items.count > 0) {
        ExploreOrderedData * objToInsert = [self.silentFetchedItems objectAtIndex:0];
        
        BOOL canInsert = NO;
        for (int i = 0; (i + 1) < self.items.count; ++i) {
            ExploreOrderedData *curObj = self.items[i];
            ExploreOrderedData *nextObj = self.items[i + 1];
            if (curObj.witnessed && !nextObj.witnessed) {
                if (objToInsert.orderIndex < curObj.orderIndex) {
                    canInsert = YES;
                }
            }
        }
        
        BOOL exsit = NO;
        for (ExploreOrderedData * obj in self.items) {
            if ([obj.primaryID isEqualToString:objToInsert.primaryID]) {
                exsit = YES;
            }
        }
        
        if (!exsit && canInsert) {
            [self addOrderedData:objToInsert listType:ExploreOrderedDataListTypeCategory];
            [objToInsert save];
            
            if (self.silentFetchTimes > 0) {
                self.silentFetchTimes--;
            }
        }
        
        self.silentFetchedItems = nil;
    }
}

#pragma mark -- SSDataOperationDelegate

- (void)dataOperationStartExecute:(SSDataOperation *)op
{
    if ([op isKindOfClass:[ArticleGetRemoteDataOperation class]]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.isLoading = YES;
        });
    }
}

- (void)dataOperationInterruptExecute:(SSDataOperation *)op {
    self.isLoading = NO;
}

- (void)dataOperation:(SSDataOperation *)op increaseData:(NSArray *)increaseData error:(NSError *)error userInfo:(NSDictionary *)userInfo
{
    void(^dataBlock)(void) = ^{
        if ([userInfo[@"tableviewOffset"] floatValue] > 1) {
            self.tableviewOffset = [userInfo[@"tableviewOffset"] floatValue];
        }
        
        if ([userInfo objectForKey:kExploreFetchListConditionKey][kExploreFetchListSilentFetchFromRemoteKey]) {

            self.silentFetchedItems = increaseData;
            if (_silentFetchFinishBlock) {
                _silentFetchFinishBlock(increaseData, userInfo, error);
            }
            
            BOOL fromRemote = [[userInfo objectForKey:kExploreFetchListFromRemoteKey] boolValue];
            if (!([op isKindOfClass:[ArticleGetLocalDataOperation class]] && fromRemote)) {
                self.isLoading = NO;
            }
            return;
        }
        
        NSMutableDictionary * exploreMixedListConsumeTimeStamps = [[userInfo objectForKey:kExploreFetchListConditionKey] objectForKey:kExploreFetchListRefreshOrLoadMoreConsumeTimeStampsKey];
        
        [exploreMixedListConsumeTimeStamps setValue:@([NSObject currentUnixTime]) forKey:kExploreFetchListManagerCallbackOperationBeginTimeStampKey];
        
        BOOL fromRemote = [[userInfo objectForKey:kExploreFetchListFromRemoteKey] boolValue];
        BOOL fromLocal = [[userInfo objectForKey:kExploreFetchListFromLocalKey] boolValue];
        BOOL isGetMore= [[userInfo objectForKey:kExploreFetchListGetMoreKey] boolValue];
    
        if (error) {
            self.lastFetchRiseError = YES;
        }
        else {
            self.lastFetchRiseError = NO;
        }
        BOOL needUpdateItems = NO;
        if ([op isKindOfClass:[ArticleGetLocalDataOperation class]]) {
            //self.isLoading = NO;
            needUpdateItems = YES;
        }
        
        if ([op isKindOfClass:[ArticlePostSaveOperation class]]) {
            //self.isLoading = NO;
            needUpdateItems = YES;

            BOOL fromRemote = [[userInfo objectForKey:kExploreFetchListFromRemoteKey] boolValue];
            BOOL isLoadMore = [[userInfo objectForKey:kExploreFetchListGetMoreKey] boolValue];
            
           
            if (fromRemote && !error) {
                _loadMoreHasMore = [[userInfo objectForKey:kExploreFetchListResponseHasMoreKey] boolValue];
            }
            
            NSUInteger uniqueIncreaseCount = [[userInfo objectForKey:kExploreFetchListResponseMergeUniqueIncreaseCountKey] intValue];
            if (fromRemote && isLoadMore && uniqueIncreaseCount == 0) {
                _lastFetchRiseError = YES;
            }
        }

        NSString * categoryID = [(NSDictionary *)[userInfo objectForKey:kExploreFetchListConditionKey] objectForKey:kExploreFetchListConditionListUnitIDKey];
        
        if (needUpdateItems && !isEmptyString(categoryID) && !isEmptyString(self.categoryID) && ![categoryID isEqualToString:self.categoryID]) {
            //返回的是数据与当前显示的categoryID不一致，不更新数据
            needUpdateItems = NO;
        }
        
//        ExploreOrderedDataListType listType = [[userInfo objectForKey:kExploreFetchListListTypeKey] intValue];
//        ExploreOrderedDataListLocation listLocaton = [[userInfo objectForKey:kExploreFetchListListLocationKey] intValue];

        
        if (needUpdateItems) {

//            __block NSInteger index = 0;
            
            NSMutableArray * mutableItems = [NSMutableArray arrayWithCapacity:100];
//            NSMutableArray * unusedItems = [NSMutableArray arrayWithCapacity:2];
            
//            NSMutableSet * gIDs = [NSMutableSet setWithCapacity:10];
           
//            NSLog(@">>>> pre pfetchListItemsKey : %zd",self.items.count);
            BOOL fromRemote = [[userInfo objectForKey:kExploreFetchListFromRemoteKey] boolValue];
            BOOL isLoadMore = [[userInfo objectForKey:kExploreFetchListGetMoreKey] boolValue];
            if (fromRemote && !isLoadMore) {
                if ([SSCommonLogic feedRefreshClearAllEnable] && ![self.categoryID isEqualToString:kTTFollowCategoryID]) {
                    self.items = [userInfo objectForKey:kExploreFetchListInsertedPersetentDataKey];
                } else {
                    self.items = [userInfo objectForKey:kExploreFetchListItemsKey];
                }
            } else {
                self.items = [userInfo objectForKey:kExploreFetchListItemsKey];
            }
//            NSLog(@">>>> after pfetchListItemsKey : %zd",self.items.count);
            
            __block ExploreOrderedData *lastObj = nil;
            [self.items enumerateObjectsUsingBlock:^(ExploreOrderedData * obj, NSUInteger idx, BOOL *stop) {
                if ([lastObj respondsToSelector:@selector(setNextCellType:)]) {
                    if ([obj respondsToSelector:@selector(cellType)]) {
                        lastObj.nextCellType = obj.cellType;
                        lastObj.nextCellHasTopPadding = obj.hasTopPadding;
                    }
                }
                if ([obj isKindOfClass:[ExploreOrderedData class]]) {
                    
                    if (!obj.managedObjectContext || !obj.originalData.managedObjectContext) {
                        return;
                    }
                    
                    ExploreOrderedData * orderedData = ((ExploreOrderedData *)obj);
                    if (fromLocal) {
                        obj.comefrom |= ExploreOrderedDataFromOptionFile;
                    } else if (isGetMore) {
                        obj.comefrom |= ExploreOrderedDataFromOptionPullUp;
                    } else {
                        obj.comefrom |= ExploreOrderedDataFromOptionPullDown;
                    }
                    
                    BOOL needIgnore = NO;
                    if (!isEmptyString(categoryID) && ![orderedData.categoryID isEqualToString:categoryID]) {
                        needIgnore = YES;
                    }
                    if (!orderedData.originalData) {//保证数据有效性
                        needIgnore = YES;
                    }
                    
                    if ([orderedData isAdExpire]) {
                        NSMutableDictionary *extra = @{}.mutableCopy;
                        [extra setValue:@(orderedData.cellType) forKey:@"cell_type"];
                        [extra setValue:@"feed" forKey:@"source"];
                        [extra setValue:orderedData.ad_id forKey:@"ad_id"];
                        [extra setValue:@(fromLocal) forKey:@"come_from"];
                        [[TTMonitor shareManager] trackService:@"ad_data_error" status:4 extra:extra];
                        needIgnore = YES;
                    }
                    
                    if (!needIgnore) {
                        if (obj.cellType == ExploreOrderedDataCellTypeAppDownload) {
                            id<TTAdFeedModel> adModel = orderedData.adModel;
                            // 如果不 hideIfExists 或者 hideIfExists但是设备没有安装该应用，则显示
                            if (![adModel.hideIfExists isKindOfClass:[NSNumber class]] ||
                                ![adModel.hideIfExists boolValue] ||
                                isEmptyString(adModel.open_url) ||
                                ([adModel.hideIfExists boolValue] &&
                                 ![[UIApplication sharedApplication] canOpenURL:[TTStringHelper URLWithURLString:adModel.open_url]])) {
                                [mutableItems addObject:orderedData];
                                } else {
                                    
                                }
                        }
                        else if (orderedData.originalData.uniqueID > 0) {
                            //gid消重
//                            if (![gIDs containsObject:@(orderedData.originalData.uniqueID)]) {
                                [mutableItems addObject:orderedData];
//                                [gIDs addObject:@(orderedData.originalData.uniqueID)];
//                            }
                        }
                    }
                }
                else {
                    if (obj) {
                        [mutableItems addObject:obj];
                    }
                }
                
                lastObj = mutableItems.lastObject;
            }];
            
            if ([lastObj respondsToSelector:@selector(setNextCellType:)]) {
                lastObj.nextCellType = ExploreOrderedDataCellTypeNull;
                lastObj.nextCellHasTopPadding = YES;
            }
            
            self.items = [NSArray arrayWithArray:mutableItems];
//            NSLog(@">>>> after filter mutableItems : %zd",self.items.count);
            
            // 调整置顶
            NSMutableArray *fixedItems = [NSMutableArray arrayWithCapacity:[mutableItems count]];
            NSMutableArray *stickItems = [[NSMutableArray alloc] init];
            NSMutableArray *normalItems = [[NSMutableArray alloc] init];
            for (ExploreOrderedData * data in mutableItems) {
                if (data.stickStyle > 0) {
                    [stickItems addObject:data];
                } else {
                    [normalItems addObject:data];
                }
            }
            [fixedItems addObjectsFromArray:stickItems];
            [fixedItems addObjectsFromArray:normalItems];
            self.items = fixedItems;
            
            [self updateAllItemsForNextCellType];
            
            //<< 新增对象清空类型和高度缓存，之前缓存过得类型和服务端再次下发的类型不一定匹配
            if ([op isKindOfClass:[ArticlePostSaveOperation class]]) {
                [increaseData enumerateObjectsUsingBlock:^(ExploreOrderedData * obj, NSUInteger idx, BOOL *stop) {
                    if ([obj isKindOfClass:[ExploreOrderedData class]]) {
                        ExploreOrderedData * orderedData = ((ExploreOrderedData *)obj);
                        // 列表变化时清空类型缓存
                        [orderedData clearCachedCellType];
                        [orderedData clearCacheHeight];
                        
                        ExploreOriginalData * originalData = orderedData.originalData;
                        if ([originalData isKindOfClass:[Article class]]) {
                            Article * article = (Article *)originalData;
                            if (orderedData.cellType == ExploreOrderedDataCellTypeAppDownload) {
                                article.hasRead = @(NO);
                                [article save];
                            }
                            
                            [article clearCachedModels];
                        }
                        else if ([originalData isKindOfClass:[Card class]]) {
                            Card *card = (Card *)originalData;
                            [card clearCachedCardItems];
                            card.notInterested = @(NO);
                            [card save];
                        }
                        else if ([originalData isKindOfClass:[HorizontalCard class]]) {
                            HorizontalCard *horizontalCard = (HorizontalCard *)originalData;
                            [horizontalCard clearCachedCardItems];
                            horizontalCard.notInterested = @(NO);
                            [horizontalCard save];
                        } else if ([originalData isKindOfClass:[TSVRecUserCardOriginalData class]]) {
                            originalData.notInterested = @(NO);
                            [originalData save];
                        }

                    }
                }];
            }
            //<<
            
        }
        
        // 设置itemIndex，存储可视的顺序
        // [[ExploreFetchListHistoryManager sharedInstance] saveFeedHistoryForCategoryID:categoryID withItems:self.items];
        if (![SSCommonLogic newItemIndexStrategyEnable]) {
            NSUInteger itemCount = self.items.count;
            uint64_t time = [[NSDate date] timeIntervalSince1970] * kFeedItemIndexUnixTimeMultiplyPara;
            for (ExploreOrderedData *data in self.items) {
                data.itemIndex = time + itemCount;
                [data save];
                itemCount--;
            }
        }
        
        NSMutableArray *savedItems = [[NSMutableArray alloc] init];
        NSUInteger itemCount = self.items.count > 20 ? 20 : self.items.count;
        for (int i = 0; i < itemCount; ++i) {
            [savedItems addObject:[self.items objectAtIndex:i]];
        }
        [[ExploreFetchListHistoryManager sharedInstance] saveFeedHistoryForCategoryID:categoryID withItems:savedItems];
        
        [exploreMixedListConsumeTimeStamps setValue:@([NSObject currentUnixTime]) forKey:kExploreFetchListManagerCallbackOperationEndTimeStampKey];
        if (_fetchFinishBlock) {
            _fetchFinishBlock(increaseData, userInfo, error);
        }
        
        if ([op isKindOfClass:[ArticlePostSaveOperation class]]) {
            self.isLoading = NO;
        }
        else if ([op isKindOfClass:[ArticleGetLocalDataOperation class]] && !fromRemote && self.items.count > 0) {
            self.isLoading = NO;
        }
        else if ([op isKindOfClass:[ArticleGetRemoteDataOperation class]] && error) {
            self.isLoading = NO;
        }
        else if (op.cancelled) {
            self.isLoading = NO;
        }
        else {
            self.isLoading = YES;
        }
    };
    
//    NSLog(@">>>> incrreaseData: %zd",increaseData.count);
    if ([NSThread isMainThread]) {
        dataBlock();
    } else {
        dispatch_async(dispatch_get_main_queue(), dataBlock);
    }
}

- (void)refreshItemsForListType:(ExploreOrderedDataListType)listType
{
    if (listType == ExploreOrderedDataListTypeFavorite) {
        self.items = [ExploreListHelper filterFavoriteItems:_items];
        [self updateAllItemsForNextCellType];
    }
    else if (listType == ExploreOrderedDataListTypeCategory){
        [self updateAllItemsForNextCellType];
    }
}

- (void)removeItemIfExist:(id)item
{
    if ([_items containsObject:item]) {
        NSMutableArray * array = [NSMutableArray arrayWithArray:_items];
        [array removeObject:item];
        self.items = [NSArray arrayWithArray:array];
        [self updateAllItemsForNextCellType];
    }
}

- (void)removeItemForIndexIfExist:(NSUInteger)index
{
    if (index < [_items count]) {
        NSMutableArray * array = [NSMutableArray arrayWithArray:_items];
        [array removeObjectAtIndex:index];
        self.items = [NSArray arrayWithArray:array];
        [self updateAllItemsForNextCellType];
    }
}

- (void)removeItemArray:(NSArray *)itemArray
{
    if ([itemArray count] > 0){
        NSMutableArray * array = [NSMutableArray arrayWithArray:_items];
        [array removeObjectsInArray:itemArray];
        self.items = [NSArray arrayWithArray:array];
        [self updateAllItemsForNextCellType];
    }
}

- (void)replaceObjectAtIndex:(NSInteger)index withObject:(id)item
{
    if (index < [_items count]) {
        NSMutableArray * array = [NSMutableArray arrayWithArray:_items];
        [array replaceObjectAtIndex:index withObject:item];
        self.items = [NSArray arrayWithArray:array];
        [self updateAllItemsForNextCellType];
    }
}

- (void)prependObjects:(NSArray<ExploreOrderedData *> *)objects
{
    if (objects.count > 0) {
        NSMutableArray * array = [NSMutableArray arrayWithArray:_items];
        [array insertObjects:objects atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, objects.count)]];
        self.items = [NSArray arrayWithArray:array];
        [self updateAllItemsForNextCellType];
    }
}

- (void)addOrderedData:(ExploreOrderedData *)orderedData listType:(ExploreOrderedDataListType)listType
{
    //for lastread 确保列表中只有一条last read cell
    NSMutableArray *lastReadArray = [NSMutableArray arrayWithCapacity:5];
    if ([orderedData.originalData isKindOfClass:[LastRead class]] && orderedData.orderIndex > 0) {
        for (id item in self.items) {
            if ([item isKindOfClass:[ExploreOrderedData class]]) {
                ExploreOrderedData * orderItem = (ExploreOrderedData *)item;
                if ([orderItem.originalData isKindOfClass:[LastRead class]]) {
                    [lastReadArray addObject:orderItem];
                }
            }
        }
    }
    for (ExploreOrderedData *lastRead in lastReadArray) {
        if (lastRead && [_items containsObject:lastRead]) {
            NSMutableArray * array = [NSMutableArray arrayWithArray:_items];
            [array removeObject:lastRead];
            self.items = [NSArray arrayWithArray:array];
        }
    }
    ///////////
    
    if (orderedData.originalData && orderedData.orderIndex > 0) {
        NSMutableArray * array = [NSMutableArray arrayWithArray:_items];
        [array addObject:orderedData];
        self.items = [ExploreListHelper sortByIndexForArray:array listType:listType];
        [self updateAllItemsForNextCellType];
    }
}

- (void)removeAllItems
{
    self.items = nil;
}

- (void)updateAllItemsForNextCellType
{
    __block ExploreOrderedData *lastObj = nil;
    
    [self.items enumerateObjectsUsingBlock:^(ExploreOrderedData *obj, NSUInteger idx, BOOL *stop) {
        if ([lastObj respondsToSelector:@selector(setNextCellType:)]) {
            if ([obj respondsToSelector:@selector(cellType)]) {
                lastObj.nextCellType = obj.cellType;
                lastObj.nextCellHasTopPadding = obj.hasTopPadding;
            }
        }
        if ([lastObj respondsToSelector:@selector(cellType)]) {
            if ([obj respondsToSelector:@selector(setPreCellType:)]) {
                obj.preCellType = lastObj.cellType;
            }
        }
        if (lastObj == nil) {//第一个cell的preCellType = ExploreOrderedDataCellTypeNull
            if ([obj respondsToSelector:@selector(setPreCellType:)]) {
                obj.preCellType = ExploreOrderedDataCellTypeNull;
            }
        }
        lastObj = obj;
    }];
    
    if ([lastObj respondsToSelector:@selector(setNextCellType:)]) {
        lastObj.nextCellType = ExploreOrderedDataCellTypeNull;
        lastObj.nextCellHasTopPadding = YES;
    }
}

- (BOOL)isExistInItems:(NSDictionary *)dict{
    
    if (!dict) {
        return NO;
    }
    
    NSString *uniqueID = [dict tt_stringValueForKey:@"uniqueID"];
    if (isEmptyString(uniqueID)) {
        return NO;
    }
    
    __block BOOL hasFound= NO;
    __block ExploreOrderedData *founData = nil;
    [self.items enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj && [obj isKindOfClass:[ExploreOrderedData class]]) {
            
            ExploreOrderedData *orderData = (ExploreOrderedData *)obj;
            if (orderData.uniqueID && [orderData.uniqueID isEqualToString:uniqueID]) {
                founData = orderData;
                hasFound = YES;
                *stop = YES;
            }
        }
    }];
    
    if (founData && founData.orderIndex < 1) {
        [self removeItemIfExist:founData];
        hasFound = NO;
    }
    
    return hasFound;
}

//- (void)checkFollowCategoryFollowStatus{
//
//    if ([self.categoryID isEqualToString:kTTFollowCategoryID]) {
//        self.items = [[TTFollowCategoryFetchExtraManager shareInstance] checkFollowStatusArray:self.items];
//        [self updateAllItemsForNextCellType];
//    }
//}

// 将帖子插到第一条，如果第一条是webCell或置顶文章，则插到其后面
- (ExploreOrderedData *)insertObjectToTopFromDict:(NSDictionary *)dict listType:(ExploreOrderedDataListType)listType {
    
    //增加去重逻辑，如果列表内存中已经有了这条数据了，就不插入，也不置顶了
    if ([self isExistInItems:dict]) {
        return nil;
    }

    BOOL postThreadInsertEnable = [TTKitchen getBOOL:kTTKUGCPostThreadInsertEnable];
    if (!postThreadInsertEnable) {
        return nil;
    }
    
    NSMutableDictionary *muDict = [NSMutableDictionary dictionaryWithDictionary:dict];
    __block NSNumber *insertIndex = @(0);
    __block NSNumber *behotTime = @(0);
    
    [self.items enumerateObjectsUsingBlock:^(ExploreOrderedData *obj, NSUInteger idx, BOOL *stop) {
        if ([obj isKindOfClass:[ExploreOrderedData class]]) {
            if (!obj.managedObjectContext || !obj.originalData.managedObjectContext) {
                return;
            }
            
            if (obj.cellType != ExploreOrderedDataCellTypeWeb && obj.stickStyle == 0) {
                //原先orderIndex+1会导致插入cell的orderIndex值和置顶orderIndex值一样，故改为0.4，0.4也防止和lastRead撞到
                insertIndex = @(obj.orderIndex + 0.4);
                behotTime = @(obj.behotTime);
                *stop = YES;
            }
        } else {
            if ([obj respondsToSelector:@selector(orderIndex)] &&
                [obj respondsToSelector:@selector(behotTime)]) {
                
                insertIndex = @(obj.orderIndex + 0.4);
                behotTime = @(obj.behotTime);
                *stop = YES;
            }
        }
    }];
    
    if (SSIsEmptyArray(self.items)) {
        insertIndex = @(0.4);//未防止频道页面无数据时，若insetrindex = 0，无法获取数据展示，所以定为>0的数值
        behotTime = @(0);
    }
    
    [muDict setValue:insertIndex forKey:@"orderIndex"];
    [muDict setValue:behotTime forKey:@"behot_time"];

    ExploreOrderedData *insertData = [ExploreOrderedData objectWithDictionary:muDict];
    if (insertData) {

        __block uint64_t time = [[NSDate date] timeIntervalSince1970] * kFeedItemIndexUnixTimeMultiplyPara;
        insertData.itemIndex = time;
        [insertData save];

        NSMutableArray *stickArray = [[NSMutableArray alloc] init];
        NSMutableArray *unStickArray = [[NSMutableArray alloc] init];

        [self.items enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {

            if ([obj isKindOfClass:[ExploreOrderedData class]]) {

                ExploreOrderedData *orderData = (ExploreOrderedData *)obj;
                if (!orderData.managedObjectContext || !orderData.originalData.managedObjectContext) {
                    return;
                }

                if (orderData.stickStyle != 0) {
                    [stickArray addObject:orderData];
                }
                else {
                    [unStickArray addObject:orderData];
                }
            }
        }];

        __block NSInteger stickCount = 0;
        [stickArray enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            ExploreOrderedData *stickOrderData = (ExploreOrderedData *)obj;
            stickOrderData.itemIndex = time + stickCount;
            stickCount += 1;
        }];

        NSMutableArray *itemMutableArray = [[NSMutableArray alloc] init];
        [itemMutableArray addObjectsFromArray:stickArray];
        [itemMutableArray addObject:insertData];
        [itemMutableArray addObjectsFromArray:unStickArray];

        self.items = [itemMutableArray copy];
        [self updateAllItemsForNextCellType];
    }

    return insertData;
}

//插入上次看到这
- (void)insertObjectFromDict:(NSDictionary *)dict listType:(ExploreOrderedDataListType)listType {
    NSMutableDictionary *muDict = [NSMutableDictionary dictionaryWithDictionary:dict];
    //在数据库插入
    NSArray * insertedlistData = [ExploreOrderedData insertObjectsWithDataArray:@[muDict]];
    //如果不是最后一条，在列表中插入
    if ([insertedlistData count] > 0 && [_items count] > 0) {
        id orderedData = [insertedlistData firstObject];
        if ([orderedData isKindOfClass:[ExploreOrderedData class]] && [((ExploreOrderedData *)orderedData).originalData isKindOfClass:[LastRead class]]) {
            ExploreOrderedData *lastData = [_items lastObject];
            // 这里先打个注释
            if (lastData /*&& lastData.orderIndex < ((ExploreOrderedData *)orderedData).orderIndex*/) {
                //[self addOrderedData:orderedData listType:listType];
                NSMutableArray *newItems = [[NSMutableArray alloc] init];
                BOOL inserted = NO;
                for (id item in self.items) {
                    if ([item isKindOfClass:[ExploreOrderedData class]]) {
                        ExploreOrderedData * orderItem = (ExploreOrderedData *)item;
                        if (![orderItem.originalData isKindOfClass:[LastRead class]]) {
                            if (orderedData && orderItem.orderIndex < ((ExploreOrderedData *)orderedData).orderIndex && !inserted) {
                                [newItems addObject:orderedData];
                                inserted = YES;
                            }
                            [newItems addObject:item];
                        }
                    } else {
                        [newItems addObject:item];
                    }
                }
                
                if ([SSCommonLogic feedRefreshClearAllEnable] && [SSCommonLogic showRefreshHistoryTip]) {
                    if (!inserted) {
                        [newItems addObject:orderedData];
                        inserted = YES;
                        if ([SSCommonLogic showRefreshHistoryTip]) {
                            ((ExploreOrderedData *)orderedData).behotTime = lastData.behotTime;
                            ((ExploreOrderedData *)orderedData).itemIndex = lastData.itemIndex - 1;
                        }
                    }
                }
                
                self.items = newItems;
                [self updateAllItemsForNextCellType];
            } else {
                if ([SSCommonLogic feedLoadMoreWithNewData] && [SSCommonLogic feedLastReadCellShowEnable]) {
                    NSMutableArray *newItems = [[NSMutableArray alloc] init];
                    BOOL inserted = NO;
                    for (id item in self.items) {
                        if ([item isKindOfClass:[ExploreOrderedData class]]) {
                            ExploreOrderedData * orderItem = (ExploreOrderedData *)item;
                            if (![orderItem.originalData isKindOfClass:[LastRead class]]) {
                                if (orderedData && orderItem.orderIndex < ((ExploreOrderedData *)orderedData).orderIndex && !inserted) {
                                    [newItems addObject:orderedData];
                                    inserted = YES;
                                }
                                [newItems addObject:item];
                            }
                        } else {
                            [newItems addObject:item];
                        }
                    }
                    self.items = newItems;
                    [self updateAllItemsForNextCellType];
                }
            }
        }
    }
}

- (void)insertItems:(NSArray <ExploreOrderedData *>*)insertItems atIndex:(NSInteger)insertIndex{
    NSParameterAssert(insertItems.count >= 0 && insertIndex >= 0 && insertIndex <= self.items.count);
    if (insertItems.count <= 0 || insertIndex < 0 || insertIndex > self.items.count) {
        return;
    }
    // 调整后的数组
    NSMutableArray *adjustedItems = self.items.mutableCopy;
    NSInteger toInsertIndex = insertIndex;
    for (ExploreOrderedData *insertItem in insertItems) {
        // 完成插入操作
        [adjustedItems insertObject:insertItem atIndex:insertIndex];
        toInsertIndex++;
    }
    self.items = [adjustedItems copy];
}

@end


@interface ExploreFetchListRefreshSessionManager ()

@property (nonatomic, strong) NSMutableDictionary *sessionDic;

@end

@implementation ExploreFetchListRefreshSessionManager : NSObject

+ (nullable instancetype)sharedInstance
{
    static ExploreFetchListRefreshSessionManager* s_instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        s_instance = [[ExploreFetchListRefreshSessionManager alloc] init];
        s_instance.sessionDic = [[NSMutableDictionary alloc] init];
    });
    return s_instance;
}

- (void)updateSessionCountForCategoryID:(nullable NSString *)categoryID
{
    if (self.sessionDic && [self.sessionDic isKindOfClass:[NSMutableDictionary class]] && categoryID && [categoryID isKindOfClass:[NSString class]] && categoryID.length > 0) {
        NSNumber *res = [self.sessionDic valueForKey:categoryID];
        if (res && [res isKindOfClass:[NSNumber class]]) {
            NSInteger count = [res integerValue];
            [self saveRefreshSessionForCategoryID:categoryID withCount:(count + 1)];
        } else {
            [self saveRefreshSessionForCategoryID:categoryID withCount:1];
        }
    } else {
        // do nothing
    }
}

- (NSInteger)sessionCountForCategoryID:(nullable NSString *)categoryID
{
    if (self.sessionDic && [self.sessionDic isKindOfClass:[NSMutableDictionary class]] && categoryID && [categoryID isKindOfClass:[NSString class]] && categoryID.length > 0) {
        NSNumber *res = [self.sessionDic valueForKey:categoryID];
        if (res && [res isKindOfClass:[NSNumber class]]) {
            return [res integerValue];
        } else {
            return 0;
        }
    } else {
        return 0;
    }
}

- (void)saveRefreshSessionForCategoryID:(nullable NSString *)categoryID withCount:(NSInteger)count
{
    if (self.sessionDic && [self.sessionDic isKindOfClass:[NSMutableDictionary class]] && categoryID && [categoryID isKindOfClass:[NSString class]] && categoryID.length > 0) {
        [self.sessionDic setValue:@(count) forKey:categoryID];
    }
}

@end


@interface ExploreFetchListHistoryManager ()

@property (nonatomic, strong) NSMutableDictionary *historyDic;

@end

@implementation ExploreFetchListHistoryManager

+ (nullable instancetype)sharedInstance
{
    static ExploreFetchListHistoryManager* s_instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        s_instance = [[ExploreFetchListHistoryManager alloc] init];
        
    });
    return s_instance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _historyDic = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (nullable NSArray *)fetchFeedHistoryForCategoryID:(nullable NSString *)categoryID
{
    NSArray *items = nil;
    if (_historyDic && [_historyDic isKindOfClass:[NSMutableDictionary class]]) {
        items = [_historyDic valueForKey:categoryID];
    }
    
    return items;
}

- (void)saveFeedHistoryForCategoryID:(nullable NSString *)categoryID withItems:(nullable NSArray *)items
{
    if (![SSCommonLogic loadLocalUseMemoryCache]) {
        return;
    }
    
    if (_historyDic && [_historyDic isKindOfClass:[NSMutableDictionary class]] && categoryID && items) {
        [_historyDic setValue:items forKey:categoryID];
    }
}
@end
