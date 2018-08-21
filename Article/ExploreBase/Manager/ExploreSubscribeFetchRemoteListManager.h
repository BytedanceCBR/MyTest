//
//  ExploreSubscribeFetchListManager.h
//  Article
//
//  Created by Huaqing Luo on 19/11/14.
//
//

#import "ListDataOperationManager.h"
#import "SubscribeEntryGetRemoteDataOperation.h"

/*
@protocol ExploreSubscribeFetchRemoteListManagerDelegate<NSObject>

- (void)ExploreSubscribeFetchRemoteEntriesFinishedWithError:(NSError *)error;
- (void)ExploreSubscribeFetchRemoteNewUpdatesIndicatorFinishedWithError:(NSError *)error;

@end
*/

typedef void(^FetchFinishBlock)(NSError *error);

@interface ExploreSubscribeFetchRemoteListManager : ListDataOperationManager

@property(nonatomic, strong, readonly) NSArray * items;
@property(nonatomic, assign) BOOL hasNewUpdatesIndicator;
@property(nonatomic, assign, readonly) BOOL getNewItemsIndicator;
@property(nonatomic, copy, readonly) NSString * currentItemsVersion;

@property(nonatomic, assign, readonly) BOOL isLoading;

// @property(nonatomic, weak)id<ExploreSubscribeFetchRemoteListManagerDelegate> delegate;
@property(nonatomic, copy) FetchFinishBlock finishBlock;

- (void)startFetchRemoteDataWithRequestType:(SubscribeEntryRemoteRequestType)requestType lastRequestVersion:(NSString *)lastRequestVersion hasNewUpdates:(BOOL)hasNewUpdates;

- (void)cancelAllOperations;

@end
