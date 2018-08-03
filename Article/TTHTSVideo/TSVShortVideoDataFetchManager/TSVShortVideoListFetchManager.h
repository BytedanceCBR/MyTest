//
//  TSVShortVideoListFetchManager.h
//  Article
//
//  Created by 王双华 on 2017/6/20.
//
//

#import "TSVShortVideoDataFetchManagerProtocol.h"
#import "TSVShortVideoDetailExitManager.h"
#import "TSVDataFetchManager.h"
#import "ExploreOrderedData.h"

@class ExploreFetchListManager;

typedef void(^TSVShortVideoListFetchManagerLoadMoreBlock)(TTFetchListFinishBlock finishBlock, BOOL isAuto);

@interface TSVShortVideoListFetchManager : TSVDataFetchManager <TSVShortVideoDataFetchManagerProtocol>

- (instancetype)initWithListManager:(ExploreFetchListManager *)listManager listEntrance:(NSString *)listEntrance item:(ExploreOrderedData *)orderedData loadMoreBlock:(TSVShortVideoListFetchManagerLoadMoreBlock)loadMoreBlock;

@property (nonatomic, strong) TSVShortVideoDetailExitManager *exitManager;

@end
