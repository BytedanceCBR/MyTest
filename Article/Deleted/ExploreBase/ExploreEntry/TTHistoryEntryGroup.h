//
//  TTHistoryEntryGroup.h
//  Article
//
//  Created by fengyadong on 16/11/16.
//
//

#import "TTEntityBase.h"

@class SSModelManager;
@class ExploreOrderedData;

@interface TTHistoryEntryGroup : TTEntityBase

@property (nonatomic, strong, nonnull)  NSString *primaryKey;
@property (nonatomic, assign) long long dateIdentifier;
@property (nonatomic, strong, nonnull)  NSString *headerText;
@property (nonatomic, assign) long long totalCount;
@property (nonatomic, strong, nonnull)  NSArray<ExploreOrderedData *> *orderedDataList;
@property (nonatomic, assign)           BOOL isDeleting;//这组数据已经被标记全选删除
@property (nonatomic, assign)           BOOL isEntireDeleting;//这组被标记为全选删除 仅做视觉展示使用
@property (nonatomic, strong, nullable) NSMutableSet<ExploreOrderedData *> *excludeItems;//整组除了某项不被删除
@property (nonatomic, strong, nullable) NSMutableSet<ExploreOrderedData *> *deletingItems;//被标记删除的单项

@end
