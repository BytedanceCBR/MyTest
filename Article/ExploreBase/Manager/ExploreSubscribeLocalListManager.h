//
//  ExploreSubscribeFetchLocalListManager.h
//  Article
//
//  Created by Huaqing Luo on 21/11/14.
//
//

#import "ListDataOperationManager.h"
#import "ExploreEntry.h"

// Fetch and save the local data
@interface ExploreSubscribeLocalListManager : ListDataOperationManager

@property(nonatomic, strong) NSArray * items;
@property(nonatomic, copy)   NSString * currentItemsVersion;
@property(nonatomic, assign) BOOL itemsDirtyFlag;

- (void)startFetchLocalItems;
- (void)saveLocalData;

@end
