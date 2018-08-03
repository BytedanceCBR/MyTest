//
//  ExploreSubscribeDataListManager.h
//  Article
//
//  Created by Huaqing Luo on 21/11/14.
//
//

#import <Foundation/Foundation.h>
#import "ExploreSubscribeFetchRemoteListManager.h"

#define kExploreSubscribeFetchFinishedNotification @"kExploreSubscribeFetchFinishedNotification"
#define kExploreSubscribeHasNewUpdatesNotification @"kExploreSubscribeHasNewUpdatesNotification"

@interface ExploreSubscribeDataListManager : NSObject

@property(nonatomic, strong, readonly)  NSArray * items;
// @property(nonatomic, assign)            BOOL itemsDirtyFlag;
@property(nonatomic, assign)            BOOL hasNewUpdatesIndicator;

// 用于判断当前是否正在从remote读取数据 (entries)
@property(nonatomic, assign, readonly) BOOL isLoading;

//- (void)startGetDataWithFullDataIndicator:(BOOL)needGetFullData; // needGetFullData: if NO, only get the indicator of hasNewData(items)

+ (ExploreSubscribeDataListManager *)shareManager;

- (void)fetchEntriesFromLocal:(BOOL)fromLocal fromRemote:(BOOL)fromRemote;
- (void)fetchHasNewUpdatesIndicator;
- (void)removeAllItems;
- (void)cancelAllOperations;

@end
