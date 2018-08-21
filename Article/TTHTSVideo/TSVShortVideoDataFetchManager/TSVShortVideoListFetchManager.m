//
//  TSVShortVideoListFetchManager.m
//  Article
//
//  Created by 王双华 on 2017/6/20.
//
//

#import "TSVShortVideoListFetchManager.h"
#import "ListDataHeader.h"
#import "ExploreOrderedData+TTBusiness.h"
#import "ExploreFetchListManager.h"
#import "NSObject+FBKVOController.h"
#import <extobjc.h>
#import "TTAdShortVideoModel.h"
#import "TTShortVideoModel+TTAdFactory.h"

@interface TSVShortVideoListFetchManager ()
@property (nonatomic, strong) ExploreFetchListManager *listManager;
@property (nonatomic, assign) NSInteger offsetIndex;
@property (nonatomic, strong) TSVShortVideoListFetchManagerLoadMoreBlock loadMoreBlock;
@property (nonatomic, copy) NSString *listEntrance;
@property (nonatomic, strong) NSArray<ExploreOrderedData *> *detailDataArray;

@end

@implementation TSVShortVideoListFetchManager

- (instancetype)initWithListManager:(ExploreFetchListManager *)listManager listEntrance:(NSString *)listEntrance item:(ExploreOrderedData *)orderedData loadMoreBlock:(TSVShortVideoListFetchManagerLoadMoreBlock)loadMoreBlock
{
    self = [super init];
    if (self) {
        _listEntrance = listEntrance;
        _listManager = listManager;
        NSUInteger offsetIndex = [listManager.items indexOfObject:orderedData];
        _offsetIndex = offsetIndex;
        _loadMoreBlock = loadMoreBlock;
        self.shouldShowNoMoreVideoToast = YES;
        
        [self updateDetailModels];
        
        @weakify(self);
        [self.KVOController observe:self.listManager
                            keyPath:@keypath(self.listManager, isLoading)
                            options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
                              block:^(id  _Nullable observer, id  _Nonnull object, NSDictionary<NSString *,id> * _Nonnull change) {
                                  @strongify(self);
                                  self.isLoadingRequest = self.listManager.isLoading;
                              }];
    }
    return self;
}

#pragma mark -- TSVShortVideoDataFetchManagerProtocol

- (NSUInteger)numberOfShortVideoItems
{
    return self.detailDataArray.count;
}

- (TTShortVideoModel *)itemAtIndex:(NSInteger)index
{
    return [self itemAtIndex:index replaced:YES];
}

- (TTShortVideoModel *)itemAtIndex:(NSInteger)index replaced:(BOOL)replaced
{
    if (replaced && self.replacedModel && index == self.replacedIndex) {
        return self.replacedModel;
    } else {
        ExploreOrderedData *orderedData = [self orderedDataAtIndex:index];
        TTShortVideoModel *model = orderedData.shortVideoOriginalData.shortVideo;
        model.categoryName = orderedData.categoryID;
        model.listEntrance = _listEntrance;
        return model;
    }
}

- (ExploreOrderedData *)orderedDataAtIndex:(NSInteger)index
{
    if (index < self.detailDataArray.count) {
        ExploreOrderedData * orderedData = [self.detailDataArray objectAtIndex:index];
        return orderedData;
    }
    return nil;
}

- (BOOL)hasMoreToLoad
{
    return self.listManager.loadMoreHasMore;
}

- (void)requestDataAutomatically:(BOOL)isAutomatically
                     finishBlock:(TTFetchListFinishBlock)finishBlock
{
    @weakify(self);
    TTFetchListFinishBlock finishBlockWrapper = ^(NSUInteger increaseCount, NSError *error){
        @strongify(self);
        
        [self updateDetailModels];
        
        if (finishBlock) {
            finishBlock(increaseCount, error);
        }
    };
    
    if (_loadMoreBlock) {
        _loadMoreBlock(finishBlockWrapper, isAutomatically);
    }
}

#pragma mark -
- (void)updateDetailModels
{
    NSMutableArray *mutArr = [NSMutableArray new];
    
    NSArray *items = self.listManager.items;
    for (NSInteger idx = self.offsetIndex; idx < items.count; idx ++) {
        ExploreOrderedData *orderedData = items[idx];
        if (![orderedData isKindOfClass:[ExploreOrderedData class]]) {
            continue;
        }
        if (![orderedData.originalData isKindOfClass:[TSVShortVideoOriginalData class]]) {
            continue;
        }
        if ([orderedData.shortVideoOriginalData.shortVideo isAd]) {
            TTAdShortVideoModel *adModel = orderedData.shortVideoOriginalData.shortVideo.rawAd;
            if ([adModel isExpire:orderedData.requestTime]) {
                continue;
            }
            if ((adModel.show_type & TTAdShorVideoShowInDraw) != TTAdShorVideoShowInDraw) {
                continue;
            }
            if ([adModel ignoreApp]) {
                continue;
            }
        }
        [mutArr addObject:orderedData];
    }
    
    self.detailDataArray = [mutArr copy];
}

- (void)setCurrentIndex:(NSInteger)currentIndex
{
    [super setCurrentIndex:currentIndex];
    
    [self updateDetailCellCurrentItem];
}

- (void)updateDetailCellCurrentItem
{
    if (self.currentIndex < self.detailDataArray.count) {
        ExploreOrderedData *orderedData = self.detailDataArray[self.currentIndex];
        self.detailCellCurrentItem = orderedData;
    }
}

@end
