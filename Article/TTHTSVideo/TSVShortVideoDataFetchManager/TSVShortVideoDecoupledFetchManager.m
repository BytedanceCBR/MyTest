//
//  TSVShortVideoDecoupledFetchManager.m
//  HTSVideoPlay
//
//  Created by 邱鑫玥 on 2017/12/11.
//

#import "TSVShortVideoDecoupledFetchManager.h"
#import "TTShortVideoModel.h"
#import "ExploreFetchListManager.h"
#import "ListDataHeader.h"
#import "ExploreListHelper.h"
#import "ExploreOrderedData+TTBusiness.h"
#import "TSVChannelDecoupledConfig.h"
#import <ReactiveObjC.h>
#import "TTShortVideoModel+TTAdFactory.h"
#import "TTAdShortVideoModel.h"
#import "TSVMonitorManager.h"

@interface TSVShortVideoDecoupledFetchManager()

@property (nonatomic, strong) ExploreFetchListManager *fetchListManager;

@property (nonatomic, assign) NSInteger listItemsCount;
@property (nonatomic, strong) NSArray<TTShortVideoModel *> *detailItems;
@property (nonatomic, strong) NSString *requestCategoryID;
@property (nonatomic, strong) NSString *trackingCategoryID;
@property (nonatomic, strong) NSString *trackingEnterFrom;
@property (nonatomic, assign) NSString *listEntrance;

@end

@implementation TSVShortVideoDecoupledFetchManager

- (instancetype)initWithItems:(NSArray<TTShortVideoModel *> *)items
            requestCategoryID:(NSString *)requestCategoryID
           trackingCategoryID:(NSString *)trackingCategoryID
                 listEntrance:(NSString *)listEntrance
{
    if (self = [super init]) {
        self.listItemsCount = items.count;
        self.detailItems = [items copy];
        
        self.fetchListManager = [[ExploreFetchListManager alloc] init];
        self.hasMoreToLoad = YES;
        self.shouldShowNoMoreVideoToast = YES;
        self.requestCategoryID = requestCategoryID;
        self.trackingCategoryID = trackingCategoryID;
        self.listEntrance = listEntrance;
        
        [self bindRAC];
    }
    return self;
}

- (void)bindRAC
{
    @weakify(self);
    RAC(self, isLoadingRequest) = RACObserve(self, fetchListManager.isLoading);
    
    RAC(self, listCellCurrentIndex) = [RACObserve(self, currentIndex) map:^NSNumber *(NSNumber *value) {
        @strongify(self);
        NSInteger listItemIndex = value.integerValue;
        
        if (listItemIndex < self.listItemsCount && listItemIndex < self.detailItems.count && [self.detailItems[listItemIndex] isKindOfClass:[TTShortVideoModel class]] && self.detailItems[listItemIndex].listIndex) {
            return self.detailItems[listItemIndex].listIndex;
        }
        
        return @(NSNotFound);
    }];
    
    RAC(self, trackingEnterFrom) = [RACObserve(self, trackingCategoryID) map:^NSString *(NSString *trackingCategoryID) {
        if ([trackingCategoryID isEqualToString:@"__all__"]) {
            return @"click_headline";
        } else {
            return @"click_category";
        }
    }];
    
}

- (void)increaseDetailItemsWithItems:(NSArray<ExploreOrderedData *> *)orderedDataArr
{
    NSMutableArray<TTShortVideoModel *> *detailItems = [NSMutableArray arrayWithArray:self.detailItems];
    
    for (ExploreOrderedData *data in orderedDataArr) {
        if ([data isKindOfClass:[ExploreOrderedData class]]) {
            TTShortVideoModel *item = data.shortVideoOriginalData.shortVideo;
            if ([item isAd]) {
                TTAdShortVideoModel *adModel = item.rawAd;
                if ([adModel isExpire:data.requestTime]) {
                    continue;
                }
                if ([adModel ignoreApp]) {
                    continue;
                }
                if ((adModel.show_type & TTAdShorVideoShowInDraw) != TTAdShorVideoShowInDraw) { // 非draw 广告
                    continue;
                }
            }
            
            if (item) {
                item.categoryName = self.trackingCategoryID;
                item.enterFrom = self.trackingEnterFrom;
                item.listEntrance = self.listEntrance;
                [detailItems addObject:item];
            }
        }
    }
    
    self.detailItems = [detailItems copy];
}

#pragma mark - TSVShortVideoDataFetchManagerProtocol

- (NSUInteger)numberOfShortVideoItems
{
    return self.detailItems.count;
}

- (TTShortVideoModel *)itemAtIndex:(NSInteger)index
{
    return [self itemAtIndex:index replaced:YES];
}

- (TTShortVideoModel *)itemAtIndex:(NSInteger)index replaced:(BOOL)replaced
{
    if (index >= self.detailItems.count) {
        return nil;
    }

    TTShortVideoModel *model;
    
    if (replaced && self.replacedModel && index == self.replacedIndex) {
        model = self.replacedModel;
    } else {
        model = self.detailItems[index];
    }
    
    return model;
}

- (void)requestDataAutomatically:(BOOL)isAutomatically finishBlock:(TTFetchListFinishBlock)finishBlock
{
    ListDataOperationReloadFromType reloadFromType;
    
    if (isAutomatically) {
        reloadFromType = ListDataOperationReloadFromTypePreLoadMoreDraw;
    } else {
        reloadFromType = ListDataOperationReloadFromTypeLoadMoreDraw;
    }
    
    [self trackCategoryRefreshEventForReloadFromType:reloadFromType];
    
    [self.fetchListManager reuserAllOperations];
    
    NSMutableDictionary *condition = [NSMutableDictionary dictionary];

    [condition setValue:self.listEntrance forKey:kExploreFetchListConditionListShortVideoListEntranceKey];
    [condition setValue:self.requestCategoryID forKey:kExploreFetchListConditionListUnitIDKey];
    [condition setValue:@(reloadFromType) forKey:kExploreFetchListConditionReloadFromTypeKey];
    [condition setValue:@(NO) forKey:kExploreFetchListResponseRemoteDataShouldPersistKey];
    
    @weakify(self);
    [self.fetchListManager startExecuteWithCondition:condition
                                       fromLocal:NO
                                      fromRemote:YES
                                         getMore:YES
                                    isDisplyView:YES
                                        listType:ExploreOrderedDataListTypeCategory
                                    listLocation:ExploreOrderedDataListLocationCategory
                                     finishBlock:^(NSArray *increaseItems, id operationContext, NSError *error) {
                                         @strongify(self);
                                         if (!error) {
                                             if ([[operationContext allKeys] containsObject:kExploreFetchListResponseHasMoreKey]) {
                                                 self.hasMoreToLoad = [[operationContext objectForKey:kExploreFetchListResponseHasMoreKey] boolValue];
                                             }
                                             
                                             [self increaseDetailItemsWithItems:increaseItems];
                                             
                                             if (finishBlock) {
                                                 finishBlock([increaseItems count], error);
                                             }
                                         } else {
                                             if (finishBlock) {
                                                 finishBlock(0, error);
                                             }
                                         }
                                         
                                         [[TSVMonitorManager sharedManager] trackCategoryResponseWithCategoryID:self.requestCategoryID listEntrance:self.listEntrance count:[increaseItems count] error:error];
                                     }];
}

#pragma mark - 埋点

- (void)trackCategoryRefreshEventForReloadFromType:(ListDataOperationReloadFromType)reloadFromType
{
    NSString *refreshTypeStr = [[ExploreListHelper class] refreshTypeStrForReloadFromType:reloadFromType];
    
    if (!isEmptyString(refreshTypeStr)) {
        NSMutableDictionary *params = [NSMutableDictionary dictionary];
        
        [params setValue:self.trackingCategoryID forKey:@"category_name"];
        [params setValue:self.trackingEnterFrom forKey:@"list_entrance"];
        [params setValue:refreshTypeStr forKey:@"refresh_type"];
        
//        [TTTrackerWrapper eventV3:@"category_refresh" params:params];
    }
}

@end
