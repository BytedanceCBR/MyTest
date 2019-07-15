//
//  TTPostDraftManager.h
//  TTPostThread
//
//  Created by SongChai on 2018/7/31.
//

#import <TTServiceKit/TTServiceCenter.h>

@class BDDiskBehaviorManager;

typedef void(^BDDiskClearCompletionBlock)(NSError * _Nullable error);

typedef void(^BDDiskCalculateSizeBlock)(NSUInteger fileCount, NSUInteger totalSize);

@protocol BDDiskBehavior <NSObject>

/**
 返回所有磁盘文件的路径，可以为文件或者目录
 */
- (NSArray<NSURL *> *)tt_URLsOnDiskOfDiskBehaviorManager:(BDDiskBehaviorManager *)diskBehaviorManager;

/**
 异步计算tt_URLsOnDisk中所有文件总的占用空间
 */
- (void)tt_calculateSizeWithCompletion:(BDDiskCalculateSizeBlock)completionBlock diskBehaviorManager:(BDDiskBehaviorManager *)diskBehaviorManager;

/**
 [BDDiskBehaviorManager clearDiskWithCompletion:]被调用时会调用此方法，清除tt_URLsOnDisk中包含的所有文件
 */
- (void)tt_clearDiskWithCompletion:(BDDiskClearCompletionBlock)completion diskBehaviorManager:(BDDiskBehaviorManager *)diskBehaviorManager;

/**
 所有Behavior的总磁盘占用空间达到阈值BDDiskBehaviorManager.maxDiskSize时会调用此方法，根据自己的业务情况，选择清除一部分磁盘缓存，如果调用后总的磁盘空间依然高于阈值不会递归调用
 */
- (void)tt_autoClearDiskWithCompletion:(BDDiskClearCompletionBlock)completion diskBehaviorManager:(BDDiskBehaviorManager *)diskBehaviorManager;

@end

@interface TTPostDraftManager : NSObject<TTService, BDDiskBehavior>

- (void)saveRepostDraftWithFwID:(NSString *)fwID optID:(NSString *)optID draft:(NSDictionary *)dict;

- (NSDictionary *)repostDraftWithFwID:(NSString *)fwID optID:(NSString *)optID;

- (void)clearRepostDraftWithFwID:(NSString *)fwID optID:(NSString *)optID;

- (void)clearAllDraft;
@end
