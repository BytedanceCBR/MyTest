//
//  TTUGCImageCompressManager.h
//  Article
//
//  Created by SongChai on 05/06/2017.
//
//

#import <Foundation/Foundation.h>
#import "TTAssetModel.h"
#import <ios_house_im/FHUGCImageCompressManager.h>

@interface TTUGCImageCompressTask : NSObject

@property (nonatomic, strong) NSString *key;

@property (nonatomic, strong) id originalSource;

@property (nonatomic, strong) TTAssetModel *assetModel;

@property (nonatomic, assign) FHiCloudSyncStatus status;

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
