//
//  TSVShortVideoCategoryFetchManager.m
//  Article
//
//  Created by 王双华 on 2017/7/17.
//
//

#import "TSVShortVideoCategoryFetchManager.h"
#import "ExploreFetchListManager.h"
#import "NSObject+FBKVOController.h"
#import <extobjc.h>
#import "ExploreListHelper.h"
#import "TSVChannelDecoupledConfig.h"
#import "TTShortVideoModel.h"
#import "TTAdShortVideoModel.h"
#import "TTShortVideoModel+TTAdFactory.h"
#import "TSVMonitorManager.h"

NSString * const klistEntranceKey = @"more_shortvideo";

@interface TSVShortVideoCategoryFetchManager ()
@property (nonatomic, strong) ExploreFetchListManager *fetchListManager;
@property (nonatomic, assign) NSInteger offsetIndex;
@property (nonatomic, copy) NSArray *orderedDataArray; // draw stream
@property (nonatomic, assign) ListDataOperationReloadFromType refreshFromType;
@property (nonatomic, assign) TSVShortVideoCardPreFetchType preFetchType;

@property (nonatomic, copy) NSArray *cardItems; // Feed card stream

@property (nonatomic, assign) BOOL hasFetchDataSucceed;
@end

@implementation TSVShortVideoCategoryFetchManager

@synthesize dataDidChangeBlock = _dataDidChangeBlock;

- (instancetype)init
{
    return [self initWithOrderedDataArray:nil cardID:nil];
}

- (instancetype)initWithOrderedDataArray:(NSArray *)orderedDataArray cardID:(NSString *)cardID{
    return [self initWithOrderedDataArray:orderedDataArray cardID:cardID preFetchType:TSVShortVideoCardPreFetchTypeNone];
}

- (instancetype)initWithOrderedDataArray:(NSArray *)orderedDataArray cardID:(NSString *)cardID preFetchType:(TSVShortVideoCardPreFetchType)preFetchType
{
    self = [super init];
    if (self){
        _cardID = cardID;
        _fetchListManager = [[ExploreFetchListManager alloc] init];
        _offsetIndex = [orderedDataArray count];
        _orderedDataArray = [NSArray arrayWithArray:orderedDataArray];
        _cardItems = [NSArray arrayWithArray:orderedDataArray];
        _preFetchType = preFetchType;
        _hasFetchDataSucceed = NO;
        
        if (_preFetchType == TSVShortVideoCardPreFetchTypeNone) {
            _cardItemsHasMoreToLoad = NO;
            if ([SSCommonLogic shortVideoDetailInfiniteScrollEnable]) {
                self.hasMoreToLoad = YES;
                self.shouldShowNoMoreVideoToast = YES;
                if ([orderedDataArray count] > 0) {
                    [self requestDataAutomatically:NO refreshTyppe:ListDataOperationReloadFromTypeCardItem finishBlock:nil];
                } else {
                    [self requestDataAutomatically:NO refreshTyppe:ListDataOperationReloadFromTypeCardMore finishBlock:nil];
                }
            } else {
                self.hasMoreToLoad = NO;
                self.shouldShowNoMoreVideoToast = NO;
            }
        } else {
            _cardItemsHasMoreToLoad = YES;
            if (_preFetchType == TSVShortVideoCardPreFetchTypeOnce) {
                if ([SSCommonLogic shortVideoDetailInfiniteScrollEnable]) {
                    self.hasMoreToLoad = YES;
                } else {
                    self.hasMoreToLoad = NO;
                }
            } else {
                self.hasMoreToLoad = YES;
            }
            self.shouldShowNoMoreVideoToast = YES;
            //  暂时取消滑动卡片推荐后的自动预加载
//            [self requestDataAutomatically:YES refreshTyppe:ListDataOperationReloadFromTypeCardDraw finishBlock:nil];
        }
        WeakSelf;
        [self.KVOController observe:self.fetchListManager
                            keyPath:@keypath(self.fetchListManager, isLoading)
                            options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
                              block:^(id  _Nullable observer, id  _Nonnull object, NSDictionary<NSString *,id> * _Nonnull change) {
                                  StrongSelf;
                                  self.isLoadingRequest = self.fetchListManager.isLoading;
                              }];
    }
    return self;
}

#pragma mark -- TSVShortVideoDataFetchManagerProtocol

- (NSUInteger)numberOfShortVideoItems
{
    return [self.orderedDataArray count];
}

- (TTShortVideoModel *)itemAtIndex:(NSInteger)index
{
    return [self itemAtIndex:index replaced:YES];
}

- (TTShortVideoModel *)itemAtIndex:(NSInteger)index replaced:(BOOL)replaced
{
    ExploreOrderedData *orderedData = [self orderedDataAtIndex:index];
    TTShortVideoModel *model = nil;
    if (replaced && self.replacedModel && index == self.replacedIndex) {
        model = self.replacedModel;
    } else if (index < _offsetIndex) {
        model = orderedData.shortVideoOriginalData.shortVideo;
        if (_cardID) {
            model.cardID = _cardID;
            model.cardPosition = [NSString stringWithFormat:@"%ld",index + 1];
        }
    } else {
        model = orderedData.shortVideoOriginalData.shortVideo;
        model.categoryName = kTTUGCVideoCategoryID;
        model.enterFrom = @"click_category";
        model.listEntrance = klistEntranceKey;
    }
    return model;
}

- (ExploreOrderedData *)orderedDataAtIndex:(NSInteger)index
{
    if (index < [self.orderedDataArray count]) {
        ExploreOrderedData * orderedData = [self.orderedDataArray objectAtIndex:index];
        return orderedData;
    }
    return nil;
}

- (NSUInteger)indexOfItem:(id)orderedData {
    return [self.orderedDataArray indexOfObject:orderedData];
}

- (void)requestDataAutomatically:(BOOL)isAutomatically
                     finishBlock:(TTFetchListFinishBlock)finishBlock
{
    [self requestDataAutomatically:isAutomatically refreshTyppe:ListDataOperationReloadFromTypeNone finishBlock:finishBlock];
}

- (void)requestDataAutomatically:(BOOL)isAutomatically
                    refreshTyppe:(ListDataOperationReloadFromType)refreshType
                     finishBlock:(TTFetchListFinishBlock)finishBlock
{
    NSString *cardPosition = nil;
    self.refreshFromType = refreshType;
    if (refreshType == ListDataOperationReloadFromTypeNone) {
        if (isAutomatically) {
            self.refreshFromType = ListDataOperationReloadFromTypePreLoadMoreDraw;
        } else {
            self.refreshFromType = ListDataOperationReloadFromTypeLoadMoreDraw;
        }
    } else if (refreshType == ListDataOperationReloadFromTypeCardItem) {//点卡片部分需要记录card_position
        cardPosition = [NSString stringWithFormat:@"%ld",self.currentIndex + 1];
    }
    
    [_fetchListManager reuserAllOperations];
    
    NSMutableDictionary *condition = [NSMutableDictionary dictionary];

    [condition setValue:@"more_shortvideo" forKey:kExploreFetchListConditionListShortVideoListEntranceKey];
    
    NSString *requestCategoryID;
    if (refreshType == ListDataOperationReloadFromTypeCardDraw && [TSVChannelDecoupledConfig strategy] != TSVChannelDecoupledStrategyDisabled) {
        requestCategoryID = [NSString stringWithFormat:@"%@_feed_card", kTTUGCVideoCategoryID];
    } else {
        requestCategoryID = kTTUGCVideoCategoryID;
    }
    [condition setValue:requestCategoryID forKey:kExploreFetchListConditionListUnitIDKey];
    
    [condition setValue:@(self.refreshFromType) forKey:kExploreFetchListConditionReloadFromTypeKey];
    [condition setValue:@(NO) forKey:kExploreFetchListResponseRemoteDataShouldPersistKey];
    NSString *refreshTypeStr = [[ExploreListHelper class] refreshTypeStrForReloadFromType:self.refreshFromType];
    if (!isEmptyString(refreshTypeStr)) {
        NSMutableDictionary *params = [NSMutableDictionary dictionary];
        [params setValue:kTTUGCVideoCategoryID forKey:@"category_name"];
        [params setValue:refreshTypeStr forKey:@"refresh_type"];
        [params setValue:klistEntranceKey forKey:@"list_entrance"];
        [params setValue:cardPosition forKey:@"card_position"];
//        [TTTrackerWrapper eventV3:@"category_refresh" params:params];
    }
    
    WeakSelf;
    [_fetchListManager startExecuteWithCondition:condition
                                       fromLocal:NO
                                      fromRemote:YES
                                         getMore:YES
                                    isDisplyView:YES
                                        listType:ExploreOrderedDataListTypeCategory
                                    listLocation:ExploreOrderedDataListLocationCategory
                                     finishBlock:^(NSArray *increaseItems, id operationContext, NSError *error) {
                                         StrongSelf;
                                         if (!error) {
                                             if ([[operationContext allKeys] containsObject:kExploreFetchListResponseHasMoreKey]) {
                                                 self.hasMoreToLoad = [[operationContext objectForKey:kExploreFetchListResponseHasMoreKey] boolValue];
                                             }
                                             
                                             if (self.preFetchType == TSVShortVideoCardPreFetchTypeOnce || self.preFetchType == TSVShortVideoCardPreFetchTypeInfinite) {
                                                 if (self.preFetchType == TSVShortVideoCardPreFetchTypeOnce) {
                                                     if (![SSCommonLogic shortVideoDetailInfiniteScrollEnable]) {
                                                         self.hasMoreToLoad = NO;
                                                     }
                                                     self.cardItemsHasMoreToLoad = NO;
                                                     if (!self.hasFetchDataSucceed) {
                                                         NSArray *increase= [self filterAd:increaseItems scene:TTAdShorVideoShowInFeed];
                                                         self.cardItems = [self.cardItems arrayByAddingObjectsFromArray:increase];
                                                     }
                                                 } else {
                                                     self.cardItemsHasMoreToLoad = self.hasMoreToLoad;
                                                     NSArray *increase = [self filterAd:increaseItems scene:TTAdShorVideoShowInFeed];
                                                     self.cardItems = [self.cardItems arrayByAddingObjectsFromArray:increase];
                                                 }
                                             }
                                             
                                             if ([increaseItems count] == 0) {
                                                 [self refreshStatusForError];
                                             } else {
                                                 self.hasFetchDataSucceed = YES;
                                             }
                                             
                                             self.orderedDataArray = [self.orderedDataArray arrayByAddingObjectsFromArray:increaseItems];
                                             
                                             if (finishBlock) {
                                                 finishBlock([increaseItems count],error);
                                             } else if (self.dataDidChangeBlock) {
                                                 self.dataDidChangeBlock();
                                             }
                                         } else {
                                             [self refreshStatusForError];
                                             
                                             if (finishBlock) {
                                                 finishBlock(0, error);
                                             }
                                         }
                                         
                                         [[TSVMonitorManager sharedManager] trackCategoryResponseWithCategoryID:requestCategoryID listEntrance:@"more_shortvideo" count:[increaseItems count] error:error];
                                     }];
}

- (TSVShortVideoListEntrance)entrance
{
    return TSVShortVideoListEntranceFeedCard;
}

- (void)refreshStatusForError
{
    if (self.preFetchType == TSVShortVideoCardPreFetchTypeOnce || self.preFetchType == TSVShortVideoCardPreFetchTypeInfinite) {
        if (self.cardItemsShouldLoadMore) {
            if (!self.cardItemsShouldLoadMore()) {
                self.cardItemsHasMoreToLoad = NO;
            }
        } else {
            self.cardItemsHasMoreToLoad = NO;
        }
    }
}

- (void)insertCardItemsIfNeeded:(NSArray *)array
{
    NSMutableArray *mutArr = [NSMutableArray array];
    
    BOOL hasChange = NO;
    for (id item in array) {
        if (![self.orderedDataArray containsObject:item]) {
            [mutArr addObject:item];
            self.offsetIndex += 1;
            hasChange = YES;
        }
    }
    
    if (hasChange) {
        self.orderedDataArray = [self.orderedDataArray arrayByAddingObjectsFromArray:mutArr];
        self.cardItems = [self.cardItems arrayByAddingObjectsFromArray:mutArr];
    }
}

- (NSArray<ExploreOrderedData *> *)filterAd:(NSArray<ExploreOrderedData *> *)items scene:(TTAdShorVideoShowIn)scene {
    NSMutableArray *niceItems = [[NSMutableArray alloc] initWithCapacity:items.count];
    NSUInteger index = 0;
    for (; index < items.count; index++) {
        ExploreOrderedData *orderedData = items[index];
        if ([orderedData isKindOfClass:[ExploreOrderedData class]] && [orderedData.shortVideoOriginalData.shortVideo isAd]) {
            TTAdShortVideoModel *adModel = orderedData.shortVideoOriginalData.shortVideo.rawAd;
            if ((adModel.show_type & scene) != scene) {
                continue;
            }
        }
        [niceItems addObject:orderedData];
    }
    return niceItems;
}

- (NSArray *)horizontalCardItems
{
    return self.cardItems;
}

- (BOOL)shouldShowLoadingCell
{
    if (_preFetchType == TSVShortVideoCardPreFetchTypeOnce) {
        if (!self.hasFetchDataSucceed) {
            return YES;
        }
    } else if (_preFetchType == TSVShortVideoCardPreFetchTypeInfinite) {
        return YES;
    }
    return NO;
}

- (void)setCurrentIndex:(NSInteger)currentIndex {
    [super setCurrentIndex:currentIndex];
    if (currentIndex >= 0 && currentIndex < self.orderedDataArray.count ) {
        ExploreOrderedData *currentItem = self.orderedDataArray[currentIndex];
        self.listCellCurrentIndex = [self.horizontalCardItems indexOfObject:currentItem];
    }
}

@end
