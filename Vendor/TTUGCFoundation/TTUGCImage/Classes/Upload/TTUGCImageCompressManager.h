//
//  TTUGCImageCompressManager.h
//  Article
//
//  Created by SongChai on 05/06/2017.
//
//

#import <Foundation/Foundation.h>
#import <TTAssetModel.h>

//子线程串行处理
//所有数据同步全部主线程处理
static void TTMainSafeSyncExecuteBlock(dispatch_block_t block) {
    if ([NSThread isMainThread]) {
        block();
    } else {
        dispatch_sync(dispatch_get_main_queue(), block);
    }
}

static void TTMainSafeExecuteBlock(dispatch_block_t block) {
    if ([NSThread isMainThread]) {
        block();
    } else {
        dispatch_async(dispatch_get_main_queue(), block);
    }
}

typedef enum : NSUInteger {
    iCloudSyncStatusNone,      //不需要icloud
    iCloudSyncStatusExecuting, //进行中
    iCloudSyncStatusFailed,    //失败
    iCloudSyncStatusSuccess,   //完成
} iCloudSyncStatus;

typedef void(^TTUGCImageCompressCompleteBlock)(NSString *path); //nil表示压缩失败
typedef void(^iCloudSyncCompletion)(BOOL success);
typedef void(^iCloudSyncProgressHandler)(double progress, NSError *error, BOOL *stop, NSDictionary *info);


@interface TTUGCImageCompressTask : NSObject

@property (nonatomic, strong) NSString *key;

@property (nonatomic, strong) id originalSource;

@property (nonatomic, strong) TTAssetModel *assetModel;

@property (nonatomic, assign) iCloudSyncStatus status;

@property (nonatomic, strong) NSString *preCompressFilePath; //压缩前本地存储

- (BOOL)isCompressed; // 是否已经压缩完成

- (void)iCloud_addCompleteBlock:(iCloudSyncCompletion)block;

- (void)iCloud_addProgressBlock:(iCloudSyncProgressHandler)block;

@end

@interface TTUGCImageCompressManager : NSObject

+ (TTUGCImageCompressManager *)sharedInstance;

// 以下3个工厂方法
- (TTUGCImageCompressTask *)generateTaskWithImage:(UIImage *)image;

- (TTUGCImageCompressTask *)generateTaskWithAssetModel:(TTAssetModel *)assetModel;

- (TTUGCImageCompressTask *)generateTaskWithFilePath:(NSString *)filePath; // filePath形如: "/Library/Cache/***"

- (void)queryFilePathWithTask:(TTUGCImageCompressTask *)task complete:(TTUGCImageCompressCompleteBlock)block;

- (void)removeCompressTask:(TTUGCImageCompressTask *)task;

@end
