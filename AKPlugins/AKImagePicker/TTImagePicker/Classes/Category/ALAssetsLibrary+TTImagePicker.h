//
//  ALAssetsLibrary+TTImagePicker.h
//  Pods
//
//  Created by SongChai on 15/06/2017.
//
//

#import <AssetsLibrary/AssetsLibrary.h>

typedef void(^TTImagePickerSaveImageCompletion)(NSError* error);

@interface ALAssetsLibrary (TTImagePicker)

+ (instancetype)tt_defaultAssetsLibrary;

/*
 *  默认使用应用程序名字作为相册名
 */

/**
 请存gif图使用该方法

 @param imgData 图片的imageData，注意要符合格式
 */
- (void)tt_saveImageData:(NSData *)imgData;
- (void)tt_saveImage:(UIImage *)img;
- (void)tt_saveImage:(UIImage *)img withCompletionBlock:(TTImagePickerSaveImageCompletion)completionBlock;
- (void)tt_saveImage:(UIImage *)img toAlbum:(NSString *)albumName withCompletionBlock:(TTImagePickerSaveImageCompletion)completionBlock;

+ (UIImage *)tt_getBigImageFromAsset:(ALAsset *)asset;

+ (UIImage *)tt_fullResolutionImageFromAsset:(ALAsset *)asset;

@end
