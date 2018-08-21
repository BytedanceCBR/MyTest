//
//  TTUGCImageCompressHelper.h
//  Article
//
//  Created by SongChai on 08/06/2017.
//
//

#import <Foundation/Foundation.h>

extern __attribute__((overloadable)) NSData * TTImageJPEGRepresentation(UIImage *image, CGFloat compressionQuality);

extern __attribute__((overloadable)) NSData * TTImageAnimatedGIFRepresentation(UIImage *image);

extern __attribute__((overloadable)) NSData * TTImageAnimatedGIFRepresentation(UIImage *image, NSTimeInterval duration, NSUInteger loopCount, NSUInteger maxCount, NSError * __autoreleasing *error);

extern __attribute__((overloadable)) NSData * TTImageWebPRepresentation(UIImage *image);

@interface TTUGCImageCompressHelper : NSObject
//静图返回webp格式，动图会抽帧返回gif格式
+ (NSData*) compress:(NSData*)data;

//认为传入为gifdata
+ (NSData*) compressGif:(NSData*)data;

//静图返回webp格式，动图会抽帧返回gif格式
//静图判断标准为images==nil || images.count == 1。动图标准为images.count > 1。其它表示无图
+ (NSData*) compressImage:(UIImage *)image;
@end

@interface TTUGCImageCompressHelper (Resize)

+ (UIImage *)processImageForUploadImage:(UIImage *)image;


+ (UIImage *)compressImage:(UIImage *)image
                      size:(long long)size
                limitWidth:(CGFloat)limitWidth
               limitHeight:(CGFloat)limitHeight;

+ (CGSize)getLimitSizeWithImageSize:(CGSize)imageSize;

@end
