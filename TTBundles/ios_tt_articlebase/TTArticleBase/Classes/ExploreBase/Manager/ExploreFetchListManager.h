//
//  ExploreFetchListManager.h
//  Article
//
//  Created by Zhang Leonardo on 14-9-10.
//
//

#import <Foundation/Foundation.h>
#import "ListDataOperationManager.h"
#import "ExploreOrderedData+TTBusiness.h"
#import "ExploreFetchListDefines.h"

#define kExploreFetchListErrorDomainKey @"kExploreFetchListErrorDomainKey"
#define kExploreFetchListCategoryIDChangedCode 9001

typedef void(^ExploreFetchListFinishBlock)(NSArray * _Nullable  increaseItems, __nullable id operationContext,  NSError * _Nullable error);
typedef void(^TSVAdjustItemsOrderFinishBlock)(NSArray * _Nullable deleteArray, NSArray * _Nullable insertArray);

@interface ExploreFetchListManager : ListDataOperationManager


/**
 *  全量列表, 对列表的写操作， 一律需要确保再主线程
 */
@property (nonatomic, retain, readonly, nullable) NSArray * items;
@property (nonatomic, assign, readonly) BOOL loadMoreHasMore;
@property (nonatomic, assign, readonly) BOOL isLoading;
@property (nonatomic, retain, readonly, nullable) NSString * categoryID;
/**
 *  最近的一次请求是否发生了异常
 */
@property (nonatomic, assign, readonly) BOOL lastFetchRiseError;

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
                      finishBlock:(nullable ExploreFetchListFinishBlock)fetchFinishBlock;
/**
 *  刷新列表，去除非法数据
 */
- (void)refreshItemsForListType:(ExploreOrderedDataListType)listType;
/**
 *  如果item存在，删除item
 *
 *  @param item 指定的item
 */
- (void)removeItemIfExist:(nonnull id)item;
/**
 *  如果index存在，删除item
 *
 *  @param index 指定的index
 */
- (void)removeItemForIndexIfExist:(NSUInteger)index;
/**
 *  如果index存在，删除item
 *
 *  @param index 指定的index
 */
- (void)removeItemArray:(nullable NSArray *)itemArray;
/**
 *  如果index存在，替换item
 *
 *  @param index 指定的index
 */
- (void)replaceObjectAtIndex:(NSInteger)index withObject:(nullable id)item;
/**
 *  在头部插入item
 *
 *  @param objects 插入的数组
 */
- (void)prependObjects:(nullable NSArray<ExploreOrderedData *> *)objects;
/**
 *  添加一个ExploreOrderedData类型item到items中
 *
 *  @param orderedData orderedData的originalData不能为空，并且必须有orderIndex, 否则将不能添加
 */
- (void)addOrderedData:(nonnull ExploreOrderedData *)orderedData listType:(ExploreOrderedDataListType)listType;

- (void)removeAllItems;

- (void)resetManager;

- (nonnull ExploreOrderedData *)insertObjectToTopFromDict:(nonnull NSDictionary *)dict listType:(ExploreOrderedDataListType)listType;
- (void)insertObjectFromDict:(nonnull NSDictionary *)dict listType:(ExploreOrderedDataListType)listType;

//关注频道根据关注状态更新要展示的帖子
//- (void)checkFollowCategoryFollowStatus;

- (void)tryInsertSilentFetchedItem;
- (BOOL)canSilentFetchItems;
- (void)reloadSilentFetchSettings;
- (void)updateLastSilentFetchTime;

- (void)insertItems:(nullable NSArray <ExploreOrderedData *>*)insertItems atIndex:(NSInteger)insertIndex;


// items更新后可能致使tableview的offset调整
@property (nonatomic, assign) CGFloat tableviewOffset;

@end


@interface ExploreFetchListRefreshSessionManager : NSObject

+ (nullable instancetype)sharedInstance;
- (void)updateSessionCountForCategoryID:(nullable NSString *)categoryID;
- (NSInteger)sessionCountForCategoryID:(nullable NSString *)categoryID;
- (void)saveRefreshSessionForCategoryID:(nullable NSString *)categoryID withCount:(NSInteger)count;

@end


@interface ExploreFetchListHistoryManager : NSObject

+ (nullable instancetype)sharedInstance;
- (nullable NSArray *)fetchFeedHistoryForCategoryID:(nullable NSString *)categoryID;
- (void)saveFeedHistoryForCategoryID:(nullable NSString *)categoryID withItems:(nullable NSArray *)items;

@end
