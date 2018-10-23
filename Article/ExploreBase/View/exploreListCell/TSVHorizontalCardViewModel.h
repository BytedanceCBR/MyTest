//
//  TSVHorizontalCardViewModel.h
//  HTSVideoPlay
//
//  Created by 邱鑫玥 on 2018/5/3.
//

#import <Foundation/Foundation.h>
#import "TSVShortVideoDataFetchManagerProtocol.h"

@class ExploreOrderedData;
@class TSVShortVideoCategoryFetchManager;

@interface TSVHorizontalCardViewModel : NSObject

@property (nonatomic, readonly, assign) BOOL isLoadingRequest;
@property (nonatomic, readonly, strong) TSVShortVideoCategoryFetchManager *cardFetchManager;
@property (nonatomic, readonly, assign) NSInteger listCellIndex;

- (instancetype)initWithData:(ExploreOrderedData *)data;

- (id<TSVShortVideoDataFetchManagerProtocol>)detailDataFetchManagerWhenClickAtIndex:(NSInteger)index item:(ExploreOrderedData *)orderedData;

- (void)loadMoreDataIfNeeded:(BOOL)isAuto;

- (NSInteger)numberOfItems;

- (NSInteger)numberOfCardItems;

- (ExploreOrderedData *)itemAtIndexPath:(NSIndexPath *)indexPath;

@end
