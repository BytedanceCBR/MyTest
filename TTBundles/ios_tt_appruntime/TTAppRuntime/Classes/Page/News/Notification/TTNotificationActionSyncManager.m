//
//  TTNotificationActionSyncManager.m
//  Article
//
//  Created by 徐霜晴 on 16/9/9.
//
//

#import "TTNotificationActionSyncManager.h"
#import "BatchItemActionModel.h"

#define kUserDefaultsKeyActionRepinFromNotification @"kUserDefaultsKeyActionRepinFromNotification"

@implementation TTNotificationActionSyncManager

+ (NSArray<BatchItemActionModel *> *)fetchAndRemoveUnSynchronizedRepinFromNotification {
    NSArray * ary = [self fetchBatchItemsByKeyName:kUserDefaultsKeyActionRepinFromNotification];
    [self removeBatchItemsByKey:kUserDefaultsKeyActionRepinFromNotification];
    return ary;
}

+ (void)addUnSynchronizedRepinFromNotification:(BatchItemActionModel *)item {
    if (item.actionName != BatchItemActionTypeRepin || item.actionSource != BatchItemActionSourceNotification) {
        return;
    }
    
    NSArray * ary = [self fetchBatchItemsByKeyName:kUserDefaultsKeyActionRepinFromNotification];
    NSMutableArray * mutableAry = [[NSMutableArray alloc] initWithArray:ary];
    [mutableAry addObject:item];
    [self saveBatchItems:mutableAry saveKeyName:kUserDefaultsKeyActionRepinFromNotification];
}

+ (void)saveBatchItems:(NSArray *)models saveKeyName:(NSString *)keyName
{
    NSMutableArray * ary = [[NSMutableArray alloc] initWithCapacity:100];
    [models enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [ary addObject:[NSKeyedArchiver archivedDataWithRootObject:obj]];
    }];
    
    [[NSUserDefaults standardUserDefaults] setObject:ary forKey:keyName];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (void)removeBatchItemsByKey:(NSString *)keyName
{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:keyName];
}

+ (NSArray *)fetchBatchItemsByKeyName:(NSString *)keyName
{
    NSArray * archiveAry = [[NSUserDefaults standardUserDefaults] objectForKey:keyName];
    
    NSMutableArray * unarchiveAry = [[NSMutableArray alloc] initWithCapacity:30];
    [archiveAry enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        BatchItemActionModel * model = (BatchItemActionModel *)[NSKeyedUnarchiver unarchiveObjectWithData:obj];
        [unarchiveAry addObject:model];
    }];
    
    NSArray * ary = [[NSArray alloc] initWithArray:unarchiveAry];
    return ary;
}

@end
