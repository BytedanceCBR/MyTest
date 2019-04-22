//
//  TSVShortVideoCategoryFetchManager.h
//  Article
//
//  Created by 王双华 on 2017/7/17.
//
//

#import <Foundation/Foundation.h>
#import "TSVShortVideoDataFetchManagerProtocol.h"
#import "ListDataHeader.h"
#import "TSVDataFetchManager.h"

typedef NS_ENUM(NSInteger, TSVShortVideoCardPreFetchType){
    TSVShortVideoCardPreFetchTypeNone,       //卡片不预加载
    TSVShortVideoCardPreFetchTypeOnce,       //滑动卡片load more一次
    TSVShortVideoCardPreFetchTypeInfinite,   //滑动卡片load more无限多次
};

typedef BOOL (^TTFetchListShouldLoadMoreBlock)();

@interface TSVShortVideoCategoryFetchManager : TSVDataFetchManager<TSVShortVideoDataFetchManagerProtocol>

@property (nonatomic, copy) NSString *cardID;
@property (nonatomic, assign) BOOL cardItemsHasMoreToLoad;
@property (nonatomic, copy) TTFetchListShouldLoadMoreBlock cardItemsShouldLoadMore;

- (instancetype)init;

- (instancetype)initWithOrderedDataArray:(NSArray *)orderedDataArray cardID:(NSString *)cardID;

- (instancetype)initWithOrderedDataArray:(NSArray *)orderedDataArray cardID:(NSString *)cardID preFetchType:(TSVShortVideoCardPreFetchType)prefetchType;

- (void)requestDataAutomatically:(BOOL)isAutomatically
                    refreshTyppe:(ListDataOperationReloadFromType)refreshType
                     finishBlock:(TTFetchListFinishBlock)finishBlock;

- (void)insertCardItemsIfNeeded:(NSArray *)array;

- (NSArray *)horizontalCardItems;
- (NSUInteger)indexOfItem:(id)orderedData;

- (BOOL)shouldShowLoadingCell;

@end
