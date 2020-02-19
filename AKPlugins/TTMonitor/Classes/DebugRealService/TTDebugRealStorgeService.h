//
//  TTDebugRealStorgeService.h
//  Pods
//
//  Created by 苏瑞强 on 17/1/3.
//
//

#import <Foundation/Foundation.h>
#import "TTDebugRealConfig.h"

@interface TTDebugRealStorgeService : NSObject

+ (instancetype)sharedInstance;

- (void)saveData:(NSData *)data storeId:(NSString *)storeId;

- (void)insertNetworkItem:(NSDictionary *)networkItem storeId:(NSString *)storeId;

- (void)insertMonitorItem:(NSDictionary *)monitorItem storeId:(NSString *)storeId;

- (void)insertDevItem:(NSDictionary *)devItem storeId:(NSString *)storeId;

- (void)removeDevItemById:(NSString *)storeId;

- (void)sendDebugRealData:(TTDebugRealConfig *)config;

- (NSArray *)allNetworkItems;

- (NSString *)networkResponseContentForStoreId:(NSString *)storeId;

- (void)handleException:(NSString *)execeptionInfo;

- (void)autoClearDBWithCompletion:(void (^)(NSError *error))completion;

- (void)clearDBWithCompletion:(void (^)(NSError *error))completion;

- (NSString *)debugRealPath;

- (void)calculateDiskSizeWithCompletion:(void (^)(NSInteger fileCount, long long size))completion;

@end
