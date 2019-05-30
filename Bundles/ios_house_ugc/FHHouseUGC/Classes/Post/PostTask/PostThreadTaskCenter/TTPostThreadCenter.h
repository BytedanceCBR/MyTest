//
//  TTPostThreadCenter.h
//  Article
//
//  Created by 王霖 on 3/16/16.
//
//

#import <Foundation/Foundation.h>
#import "TTPostThreadTask.h"
#import <TTBaseLib/NSObject+TTAdditions.h>
#import <TTUGCFoundation/TTUGCDefine.h>
#import "TTPostThreadModel.h"

@class TTUGCImageCompressManager;
@class TTRepostThreadModel;
@interface TTPostThreadCenter : NSObject<Singleton>

// 请账号切换时候需要
- (void)onAccountStatusChanged;

- (void)postThreadWithPostThreadModel:(TTPostThreadModel *)postThreadModel
                          finishBlock:(void (^)(TTPostThreadTask *task))finishBlock;

- (void)postEditedThreadWithPostThreadModel:(TTPostThreadModel *)postThreadModel
                                finishBlock:(nullable void (^)(void))finishBlock;

- (void)repostWithRepostThreadModel:(nullable TTRepostThreadModel *)repostThreadModel
                      withConcernID:(nullable NSString *)concernID
                     withCategoryID:(nullable NSString *)categoryID
                              refer:(NSUInteger)refer
                         extraTrack:(nullable NSDictionary *)extraTrack
                        finishBlock:(nullable void(^)(void))finishBlock;

//从磁盘获取tasks，用于启动时加载草稿
- (nullable NSArray <TTPostTask *> *)fetchTasksFromDiskForConcernID:(nonnull NSString *)concernID;

- (void)resentThreadForFakeThreadID:(int64_t)fakeTID concernID:(nonnull NSString *)cid;
- (void)removeTaskForFakeThreadID:(int64_t)fakeTID concernID:(nonnull NSString *)cid;
@end
