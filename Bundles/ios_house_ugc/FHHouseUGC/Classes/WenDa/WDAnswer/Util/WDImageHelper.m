//
//  WDImageHelper.m
//  Article
//
//  Created by 延晋 张 on 16/8/1.
//
//

#import "WDImageHelper.h"
#import <YYImage/YYImageCoder.h>

@implementation WDImageHelper

+ (NSData *)processImageDataForUploadImage:(UIImage *)image
{
    if (!image) {
        return nil;
    }
    
    CGFloat width = image.size.width;
    CGFloat height = image.size.height;
    NSData *data = UIImageJPEGRepresentation(image, 1);
    while (data.length > [self imgLimitValue]) {
        width *= 0.7;
        height *= 0.7;
        data = [self compressImage:image size:[self imgLimitValue] limitWidth:width limitHeight:height];
    }
    return data;
}

+ (NSData *)webpForImage:(UIImage *)image
{
    if (image == nil) {
        return nil;
    }
    
    YYImageEncoder* encoder = [[YYImageEncoder alloc] initWithType:YYImageTypeWebP];
    [encoder addImage:image duration:0];
    NSData* resultData = [encoder encode];
    return resultData;
}

+ (UIImage *)scaledImageWithImage:(UIImage *)image limitHeight:(CGFloat)height limitWidth:(CGFloat)width
{
    if (!image) {
        return nil;
    }
    CGSize size = image.size;
    if (size.width == 0 || size.height == 0) {
        return nil;
    }
    
    if (height == 0 && width == 0) {
        // Case 1
        return nil;
    } else if (height != 0 && width == 0) {
        // Case 2
        CGFloat ratio = size.width / size.height;
        width = height * ratio;
    } else if (height == 0 && width != 0) {
        // Case 3
        CGFloat ratio = size.height / size.width;
        height = width * ratio;
    } else {
        // Case 4, Use the limit height and width
    }
    CGRect rect = CGRectMake(0, 0, width, height);
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0);
    [image drawInRect:rect]; // drawInRect has already considerated the image orientation
    image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

#pragma mark - Private

+ (CGFloat)imgLimitValue
{
    return 2 * 1024 * 1024;
}

//width，height限制如果都设置，优先考虑height
+ (NSData *)compressImage:(UIImage *)image
                     size:(long long)size
               limitWidth:(CGFloat)limitWidth
              limitHeight:(CGFloat)limitHeight
{
    NSData *resultData = nil;
    if (image == nil) {
        return nil;
    }
    @autoreleasepool {
        NSData * data = UIImageJPEGRepresentation(image, 1);
        if ([data length] < size) {
            return data;
        }
        CGSize needDealSize = CGSizeZero;
        if (limitHeight > 0) {
            if (image.size.height > limitHeight) {
                CGFloat resizeWidth = (image.size.width / image.size.height) * limitHeight;
                needDealSize = CGSizeMake(resizeWidth, limitHeight);
            }
        }
        else if(limitWidth > 0) {
            if (image.size.width > limitWidth) {
                CGFloat resizeHeight = (image.size.height / image.size.width) * limitWidth;
                needDealSize = CGSizeMake(limitWidth, resizeHeight);
            }
        }
        UIImage * dealedImg = image;
        if (needDealSize.width > 0 && needDealSize.height > 0) {
            @autoreleasepool {
                UIGraphicsBeginImageContext(needDealSize);
                [image drawInRect:CGRectMake(0, 0, needDealSize.width, needDealSize.height)];
                dealedImg = UIGraphicsGetImageFromCurrentImageContext();
                UIGraphicsEndImageContext();
            }
        }
        data = UIImageJPEGRepresentation(dealedImg, 1);
        resultData = data;
    }
    return resultData;
}

@end
