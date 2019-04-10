//
//  TTNotificationActionSyncManager.h
//  Article
//
//  Created by 徐霜晴 on 16/9/9.
//
//

#import <Foundation/Foundation.h>

@class BatchItemActionModel;

@interface TTNotificationActionSyncManager : NSObject

/*
 * 获取本地存储的失败的从通知中心来的收藏请求
 */
+ (NSArray<BatchItemActionModel *> *)fetchAndRemoveUnSynchronizedRepinFromNotification;

/*
 * 添加失败的从通知中心来的收藏请求
 */
+ (void)addUnSynchronizedRepinFromNotification:(BatchItemActionModel *)item;

@end
