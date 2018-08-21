//
//  TTImagePickerCacheManager.h
//  Article
//
//  Created by tyh on 2017/4/23.
//
//

#import <Foundation/Foundation.h>

@interface TTImagePickerCacheManager : NSObject

/// 最大缓存大小
@property (nonatomic, assign) UInt64 memoryCapacity;
/// 内存溢出时保留大小
@property (nonatomic, assign) UInt64 preferredMemoryUsageAfterPurge;

/// 添加缓存
- (void)setImage:(UIImage *)image withAssetID:(NSString *)assetID;

/// 获得缓存
- (UIImage *)getImageWithAssetID:(NSString *)assetID;

/// 移除缓存
- (BOOL)removeImageWithAssetID:(NSString *)assetID;
- (BOOL)removeAllImages;


@end
