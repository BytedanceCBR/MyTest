//
//  TTFeedHistoryViewModel.h
//  Article
//
//  Created by fengyadong on 16/11/24.
//
//

#import "TTFeedMultiDeleteViewModel.h"
#import "TTFeedFavoriteHistoryHeader.h"

@class TTHistoryEntryGroup;
@class ExploreOrderedData;

@interface TTFeedHistoryViewModel : TTFeedMultiDeleteViewModel

@property (nonatomic, strong) NSMutableSet <TTHistoryEntryGroup *> *deletingGroups;//整组中有被标记删除的item无论是整组被全选还是选择了某几条

- (instancetype)initWithDelegate:(id<TTFeedContainerViewModelDelegate>)delegate;
- (void)deleteItemsClearAll:(BOOL)clearAll historyType:(TTHistoryType)historyType finishBlock:(void(^)(NSError *error, id jsonObj))finishBlock;
- (NSString *)headerTextForGroup:(TTHistoryEntryGroup *)group;

- (void)deleteItem:(ExploreOrderedData *)orderedData;

@end
