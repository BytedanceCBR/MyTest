//
//  TTIMUtils.m
//  EyeU
//
//  Created by matrixzk on 11/8/16.
//  Copyright © 2016 Toutiao.EyeU. All rights reserved.
//

#import "TTIMUtils.h"
// System
#import <Photos/Photos.h>
#import <AssetsLibrary/AssetsLibrary.h>


@implementation TTIMUtils

+ (void)fetchImageWithIdentifier:(NSString *)identifier resultHandler:(void(^)(UIImage *image, NSString *identifier))resultHandler
{
    if (!([identifier isKindOfClass:[NSString class]] && identifier.length > 0) ||
        !resultHandler) {
        return;
    }
    
    if ([UIDevice currentDevice].systemVersion.floatValue >= 8.0f) { // iOS8 later
        PHFetchResult<PHAsset *> *fetchResult = [PHAsset fetchAssetsWithLocalIdentifiers:@[identifier] options:nil];
        [fetchResult enumerateObjectsUsingBlock:^(PHAsset * _Nonnull assert, NSUInteger idx, BOOL * _Nonnull stop) {
            if (assert) {
                CGFloat aspectRatio = assert.pixelWidth / (CGFloat)assert.pixelHeight;
                CGFloat pixelWidth = CGRectGetWidth([UIScreen mainScreen].bounds)*2;
                CGSize imageSize = CGSizeMake(pixelWidth, pixelWidth / aspectRatio);
                PHImageRequestOptions *option = [[PHImageRequestOptions alloc] init];
                option.resizeMode = PHImageRequestOptionsResizeModeFast;
                option.synchronous = YES;
                [[PHImageManager defaultManager] requestImageForAsset:assert targetSize:imageSize contentMode:PHImageContentModeAspectFill options:nil resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
                    if (![info[PHImageResultIsDegradedKey] boolValue]) {
                        resultHandler(result, identifier);
                    }
                }];
            }
        }];
    } else {
        NSURL *assertURL = [NSURL URLWithString:identifier];
        if (assertURL) {
            ALAssetsLibrary *assetsLib = [[ALAssetsLibrary alloc] init];
            [assetsLib assetForURL:assertURL resultBlock:^(ALAsset *asset) {
                
                UIImage *image = [UIImage imageWithCGImage:[[asset defaultRepresentation] fullScreenImage]];
                resultHandler(image, identifier);
                
            } failureBlock:nil];
        }
    }
}

+ (NSString *)jsonStringFromDictionary:(NSDictionary *)dictionary
{
    if (!dictionary) return @"{}";
    NSData* data = [NSJSONSerialization dataWithJSONObject:dictionary
                                                   options:0 error:nil];
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

+ (NSDictionary *)dictionaryFromJSONString:(NSString *)jsonString
{
    if (!([jsonString isKindOfClass:[NSString class]] && jsonString.length > 0)) {
        return nil;
    }
    NSData *data = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    if (data) {
        return [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    }
    return nil;
}

+ (NSData *)imageDataWithImage:(UIImage *)image targetSize:(CGSize)targetSize maxDataSize:(CGFloat)dataSize
{
    UIImage *currentImage;
    if (CGSizeEqualToSize(image.size, targetSize)) {
        currentImage = image;
    } else {
        NSUInteger intWidth = targetSize.width, intHeight = targetSize.height;
        /* // 试下奇数是否也不会产生白边，先注掉
        if (intWidth % 2 == 1) {
            intWidth += 1;
        }
        if (intHeight % 2 == 1) {
            intHeight += 1;
        }
         */
        targetSize = CGSizeMake(intWidth, intHeight);
        
        UIGraphicsBeginImageContextWithOptions(targetSize, NO, 0.0);
        [image drawInRect:CGRectMake(0, 0, targetSize.width, targetSize.height)];
        currentImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    
    CGFloat compression = 1.f;
    NSData *currentData = UIImageJPEGRepresentation(currentImage, compression);
    CGFloat sizeInKB = currentData.length / 1024;
    
    SSLog(@"original image size:%@, file size:%fkb", NSStringFromCGSize(image.size), sizeInKB);
    
    if(sizeInKB <= dataSize)
    {
        return currentData;
    }
    
    NSUInteger end = 9, middle;
    NSUInteger len = 10, half;
    while (len > 0)
    {
        @autoreleasepool {
            half = len >> 1;
            middle = end - half;
            currentData = UIImageJPEGRepresentation(currentImage, (CGFloat)middle / 10.f);
            sizeInKB = currentData.length / 1024;
            if (sizeInKB > dataSize) {
                end = middle - 1;
                len = len - half - 1;
            } else {
                len = half;
            }
        }
    }
    
    compression = MAX(end, 0) / 10.f;
    currentData = UIImageJPEGRepresentation(currentImage, compression);
    return  currentData;
}

@end
