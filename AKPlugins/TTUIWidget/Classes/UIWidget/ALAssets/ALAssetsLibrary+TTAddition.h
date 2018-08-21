//
//  ALAssetsLibrary+SSAddition.h
//  Article
//
//  Created by Zhang Leonardo on 13-3-18.
//
//

#import <Foundation/Foundation.h>
#import <AssetsLibrary/AssetsLibrary.h>

typedef void(^TTSaveImageCompletion)(NSError* error);

@interface ALAssetsLibrary (TTAddition)

+ (instancetype)defaultAssetsLibrary;

/*
 *  默认使用应用程序名字作为相册名
 */
- (void)saveImg:(UIImage *)img;
- (void)saveImg:(UIImage *)img withCompletionBlock:(TTSaveImageCompletion)completionBlock;
- (void)saveImg:(UIImage *)img toAlbum:(NSString *)albumName withCompletionBlock:(TTSaveImageCompletion)completionBlock;

+ (UIImage *)ttGetBigImageFromAsset:(ALAsset *)asset;

+ (UIImage *)fullResolutionImageFromAsset:(ALAsset *)asset;

@end
