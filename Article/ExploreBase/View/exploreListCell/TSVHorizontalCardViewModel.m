//
//  TSVHorizontalCardViewModel.m
//  HTSVideoPlay
//
//  Created by 邱鑫玥 on 2018/5/3.
//

#import "TSVHorizontalCardViewModel.h"
#import "ReactiveObjC.h"
#import "ExploreOrderedData+TTBusiness.h"
#import "HorizontalCard.h"
#import "TTShortVideoModel.h"
#import "TSVShortVideoOriginalData.h"
#import "TTBaseMacro.h"
#import "TSVShortVideoCategoryFetchManager.h"
#import "TSVChannelDecoupledConfig.h"
#import "TSVShortVideoDecoupledFetchManager.h"

@interface TSVHorizontalCardViewModel()

@property (nonatomic, strong) ExploreOrderedData *orderedData;
@property (nonatomic, strong) HorizontalCard *horizontalCard;
@property (nonatomic, assign) BOOL isFollowStyle;
@property (nonatomic, copy) NSString *categoryName;
@property (nonatomic, copy) NSString *enterFrom;
@property (nonatomic, assign, getter=isInFeed) BOOL inFeed;
@property (nonatomic, strong) TSVShortVideoCategoryFetchManager *cardFetchManager;
@property (nonatomic, assign) BOOL isLoadingRequest;
@property (nonatomic, assign) NSInteger listCellIndex;
@property (nonatomic, strong) id<TSVShortVideoDataFetchManagerProtocol> detailFetchManager;

@end

@implementation TSVHorizontalCardViewModel

- (instancetype)initWithData:(ExploreOrderedData *)data
{
    if (self = [super init]) {
        self.orderedData = data;
        self.horizontalCard = data.horizontalCard;
        self.categoryName = data.categoryID;
        if ([data.categoryID isEqualToString:kTTMainCategoryID]) {
            self.enterFrom = @"click_headline";
            self.inFeed = YES;
        } else {
            self.enterFrom = @"click_category";
            self.inFeed = NO;
        }
        
        if (self.horizontalCard.originalCardItems.count >= 2) {
            TTShortVideoModel *first = ((ExploreOrderedData *)self.horizontalCard.originalCardItems[0]).shortVideoOriginalData.shortVideo;
            TTShortVideoModel *second = ((ExploreOrderedData *)self.horizontalCard.originalCardItems[1]).shortVideoOriginalData.shortVideo;
            
            self.isFollowStyle = ([self isFollowStyleForItem:first] && [self isFollowStyleForItem:second]);
        } else {
            self.isFollowStyle = NO;
        }
        
        if (!self.horizontalCard.prefetchManager) {
            NSString *listEntrance, *categoryName;
            if (self.isInFeed) {
                if (self.isFollowStyle) {
                    categoryName = @"follow_ugc_video";
                    listEntrance = @"more_shortvideo";
                } else {
                    categoryName = kTTUGCVideoCategoryID;
                    listEntrance = @"more_shortvideo";
                }
            } else {
                categoryName = self.orderedData.categoryID;
                listEntrance = @"more_shortvideo_category";
            }
        }
       
        [self bindRAC];
    }
    
    return self;
}

- (void)bindRAC
{
    @weakify(self);
    RAC(self, cardFetchManager) = RACObserve(self, horizontalCard.prefetchManager);
    RAC(self, isLoadingRequest) = RACObserve(self, cardFetchManager.isLoadingRequest);
    RAC(self, listCellIndex) =  [RACObserve(self, detailFetchManager.currentIndex) map:^id _Nullable(NSNumber *index) {
        @strongify(self);
        
        TTShortVideoModel *model = [self.detailFetchManager itemAtIndex:index.integerValue];
        return model.listIndex ?: @(NSNotFound);
    }];
}

- (id<TSVShortVideoDataFetchManagerProtocol>)detailDataFetchManagerWhenClickAtIndex:(NSInteger)index item:(ExploreOrderedData *)item
{
    id<TSVShortVideoDataFetchManagerProtocol> res;
    self.cardFetchManager.currentIndex = 0;
    if ([self isInFeed]) {
        if ([TSVChannelDecoupledConfig strategy] == TSVChannelDecoupledStrategyDisabled) {
            res = self.cardFetchManager;
        } else {
            res = [self decoupledFetchManagerWithClickIndex:index];
        }
    }
    
    self.detailFetchManager = res;
    
    return self.detailFetchManager;
}

- (NSInteger)numberOfItems
{
    return self.horizontalCard.allCardItems.count + ([self.cardFetchManager shouldShowLoadingCell] ? 1 : 0);
}

- (NSInteger)numberOfCardItems
{
    return self.horizontalCard.allCardItems.count;
}

- (ExploreOrderedData *)itemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.item < self.horizontalCard.allCardItems.count && [self.horizontalCard.allCardItems[indexPath.item] isKindOfClass:[ExploreOrderedData class]]) {
        return self.horizontalCard.allCardItems[indexPath.item];
    } else {
        return nil;
    }
}

- (void)loadMoreDataIfNeeded:(BOOL)isAuto
{
    if (self.cardFetchManager.cardItemsHasMoreToLoad && !self.cardFetchManager.isLoadingRequest) {
        [self.cardFetchManager requestDataAutomatically:isAuto refreshTyppe:ListDataOperationReloadFromTypeCardDraw finishBlock:nil];
    }
}

#pragma mark - Private

- (BOOL)isFollowStyleForItem:(TTShortVideoModel *)model
{
    return (model.author.isFriend || model.author.isFollowing) && !isEmptyString(model.labelForList);
}

// 解耦
- (TSVShortVideoDecoupledFetchManager *)decoupledFetchManagerWithClickIndex:(NSInteger)clickIndex
{
    NSInteger maxIndex;
    
    maxIndex = clickIndex + [TSVChannelDecoupledConfig numberOfExtraItemsTakenToDetailPage];
    
    NSMutableArray<TTShortVideoModel *> *mutArr = [NSMutableArray array];
    
    for (NSInteger index = clickIndex; index <= maxIndex; index++) {
        if (index < [self.horizontalCard allCardItems].count) {
            ExploreOrderedData *orderedData = [self.horizontalCard allCardItems][index];
            
            if (!([orderedData isKindOfClass:[ExploreOrderedData class]] && orderedData.shortVideoOriginalData.shortVideo)) {
                return nil;
            }
            
            TTShortVideoModel *model = orderedData.shortVideoOriginalData.shortVideo;
            
            if (model) {
                [mutArr addObject:model];
            }
        }
    }
    
    return [[TSVShortVideoDecoupledFetchManager alloc] initWithItems:[mutArr copy]
                                                   requestCategoryID:[NSString stringWithFormat:@"%@_feed_detail_draw", kTTUGCVideoCategoryID]
                                                  trackingCategoryID:kTTUGCVideoCategoryID
                                                        listEntrance:@"more_shortvideo"];
}

@end
