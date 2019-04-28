//
//  TTFeedContainerViewModel.h
//  Article
//
//  Created by fengyadong on 16/11/11.
//
//

#import <Foundation/Foundation.h>
#import "ListDataHeader.h"
#import "ExploreCellBase.h"

@protocol TTFeedContainerViewModelDelegate <NSObject>

@required
- (NSString *)URLStringForHTTPRequst;
- (NSString *)methodForHTTPRequst;
- (NSString *)concernID;
- (NSString *)categoryID;
- (ExploreOrderedDataListType)listType;
- (ExploreOrderedDataListLocation)listLocation;
- (Class)orderedDataClass;
- (NSUInteger)refer;

@optional
- (NSDictionary *)getParamsForHTTPRequest;
- (NSDictionary *)postParamsForHTTPRequest;
- (BOOL)hasPostInterestWords;
- (void)didFetchDataformRemote:(BOOL)formRemote error:(NSError *)error;
- (void)didFinshAllOperations;
- (NSUInteger)loadMoreCount;
- (BOOL)asyncPersistence;
- (BOOL)needPesistence;

@end

@interface TTFeedContainerViewModel : NSObject

@property (nonatomic, weak) id<TTFeedContainerViewModelDelegate> delegate;
@property (nonatomic, weak) UIViewController *targetVC;
@property (nonatomic, copy,   readonly) NSString *categoryID;
@property (nonatomic, assign, readonly) ExploreOrderedDataListType listType;
@property (nonatomic, assign, readonly) NSUInteger refer;
@property (nonatomic, assign, readonly) ListDataOperationReloadFromType reloadType;//刷新方式
@property (nonatomic, assign, readonly) BOOL loadMore;
@property (nonatomic, assign, readonly) BOOL canLoadMore;
@property (nonatomic, assign, readonly) BOOL hasNew;//还有更多内容
@property (nonatomic, strong, readonly) NSNumber *rankKey;
@property (nonatomic, copy, readonly)   NSArray *allItems;
@property (nonatomic, copy, readonly)   NSDictionary *remoteDict;
@property (nonatomic, copy, readonly)   NSArray *flattenList;//还未持久化也没转为Model的展开的没有嵌套的原始数组
@property (nonatomic, copy, readonly)   NSArray *ignoreList;
@property (nonatomic, copy, readonly)   NSArray *increaseItems;
@property (nonatomic, assign, readonly) NSUInteger newNumber;
@property (nonatomic, strong, readonly) NSError *error;

- (instancetype)initWithDelegate:(id<TTFeedContainerViewModelDelegate>)delegate;

- (void)startFetchDataLoadMore:(BOOL)loadMore
                     fromLocal:(BOOL)fromLocal
                    fromRemote:(BOOL)fromRemote
                    reloadType:(ListDataOperationReloadFromType)reloadType;

- (BOOL)removeDataSourceArrayIfNeeded:(NSArray *)deletingArray;
- (BOOL)removeDataSourceItemIfNeeded:(id)deletingItem;
- (void)cleanupDataSource;
- (BOOL)insertDataSourceItem:(id)insertingItem atIndex:(NSUInteger)index;

@end
