//
//  TSVShortVideoListFetchManager.h
//  Article
//
//  Created by 王双华 on 2017/6/20.
//
//

#import "ExploreFetchListManager.h"

NS_ASSUME_NONNULL_BEGIN

@class ExploreOrderedData;

typedef void(^TSVAdjustItemsOrderFinishBlock)(NSArray * _Nullable deleteArray, NSArray * _Nullable insertArray);
typedef void(^TSVDeleteItemsFinishBlock)(NSArray * _Nullable deletedArray, BOOL hasNotInterestedData);

@interface TSVShortVideoFeedFetchManager : NSObject

@property (nonatomic, strong, readonly) ExploreFetchListManager *listManager;

@property (nonatomic, strong, readonly) NSArray<ExploreOrderedData *> *items; // feed stream
@property (nonatomic, assign) BOOL hasMoreToLoad;//是否还能loadmore
@property (nonatomic, assign) BOOL isLoadingRequest;//是否正在加载中
@property (nonatomic, assign) BOOL lastFetchRiseError;
@property (nonatomic, copy) NSString *categoryID;

- (instancetype)init;

- (void)replaceObjectAtIndex:(NSInteger)index withObject:(id)item;
- (void)updateListModels;

- (void)registerSpecialOriginalDataClass:(NSSet *)specialOriginalDataClass;
- (void)adjustTSVItemsOrder;
- (void)adjustTSVItemsOrderWithInsertItems:(NSArray <ExploreOrderedData *>*)insertItems atIndex:(NSInteger)insertIndex finishBlock:(TSVAdjustItemsOrderFinishBlock _Nullable)finishBlock;
- (void)adjustTSVItemsOrderWithDeleteItems:(NSArray * _Nullable)deleteItems finishBlock:(TSVAdjustItemsOrderFinishBlock _Nullable)finishBlock;

- (void)resetManager;
- (void)cancelAllOperations;
- (void)reuserAllOperations;
- (void)deleteOrderedDataIfNeedWithComplete:(TSVDeleteItemsFinishBlock _Nullable)completeBlock;
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

@end

NS_ASSUME_NONNULL_END
