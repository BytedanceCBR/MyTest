//
//  WDUploadImageManager.h
//  Article
//
//  Created by 王霖 on 15/12/30.
//
//

#import <Foundation/Foundation.h>

@protocol WDUploadImageModelProtocol;
@class WDUploadImageManager;

@protocol WDUploadImageManagerDelegate <NSObject>

@optional
- (void)uploadManagerProgressUpdate:(WDUploadImageManager *)manager
                        finishCount:(NSUInteger)finishCount
                        expectCount:(NSUInteger)expectCount;

- (void)uploadManager:(WDUploadImageManager *)manager
    finishUploadImage:(id<WDUploadImageModelProtocol>)imageModel;

- (void)uploadManager:(WDUploadImageManager *)manager
    failedUploadImage:(id<WDUploadImageModelProtocol>)imageModel
                error:(NSError *)error;

- (void)uploadManagerTaskHasFinished:(WDUploadImageManager *)manager failedImageModels:(NSArray<id<WDUploadImageModelProtocol>> *)failedModels;

@end

@interface WDUploadImageManager : NSObject

@property (nonatomic, weak) id<WDUploadImageManagerDelegate> delegate;

@property (nonatomic, readonly, assign) BOOL sandboxCompressImgMiss;

- (void)uploadImages:(NSArray <id<WDUploadImageModelProtocol>>*)imageModels;

+ (void)uploadImage:(id<WDUploadImageModelProtocol>)imageModel
        finishBlock:(void(^)(NSError *error, BOOL sandboxCompressImgMiss))finishBlock;

- (void)cancelUploadImage;
- (void)clearRetryTimes;

@end
