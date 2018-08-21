//
//  SSImageUtil.m
//  Essay
//
//  Created by Zhang Leonardo on 13-2-6.
//  Copyright (c) 2013年 Bytedance. All rights reserved.
//

#import "SSImageUtil.h"

CGFloat aspectRatioForSize(CGSize size);
CGFloat ssRadiansToDegrees(CGFloat radians);
CGFloat ssDegreesToRadians(CGFloat degrees);

@implementation SSImageUtil

+ (UIImage *)cutImage:(UIImage *)img withRect:(CGRect)rect
{
    CGImageRef sourceImageRef = [img CGImage];

    CGImageRef newImagRef = CGImageCreateWithImageInRect(sourceImageRef, rect);

    if (newImagRef == NULL) {
        return img;
    }
    UIImage * newImage = [UIImage imageWithCGImage:newImagRef];
    CGImageRelease(newImagRef);
    return newImage;
}

+ (UIImage *)cutImage:(UIImage *)img withCutWidth:(CGFloat)sideWidth withSideHeight:(CGFloat)sideHeight cutPosition:(SSImageUtilCutType)cutType
{
    CGFloat borderSizeW = sideWidth;
    CGFloat borderSizeH = sideHeight;
    CGFloat imageWidth = img.size.width;
    CGFloat imageHeight = img.size.height;
    
    if ((borderSizeW == imageWidth && borderSizeH == imageHeight) || cutType == SSImageUtilCutTypeNone) {
        return img;
    }

    UIImage * fixImageData;
    
    if (img && cutType != SSImageUtilCutTypeNone) {
        
        CGRect imgRect = CGRectZero;
        
        if ((borderSizeW / borderSizeH) < (imageWidth / imageHeight)) {
            // ___________
            //|   |////|  |
            //------------
            imgRect = CGRectMake((imageWidth - (borderSizeW * imageHeight / borderSizeH)) / 2, 0, (borderSizeW * imageHeight / borderSizeH), imageHeight);
        }
        else if((borderSizeW / borderSizeH) >= (imageWidth / imageHeight) && cutType == SSImageUtilCutTypeTop){
            //the image w/h is less than border w/h like the
            //   -- --
            //   |////|
            //   __ __
            //    | |
            //    | |
            //    --   cow!!! don`t delete this annotation
            CGFloat clipH = imageWidth * borderSizeH / borderSizeW;
            //                    CGFloat clipY = (imageHeight - clipH) / 2;
            imgRect = CGRectMake(0, 0, imageWidth, clipH);
        }
        else {
            //the image w/h is less than border w/h like the
            //    --
            //    | |
            //   -- --
            //   |////|
            //   __ __
            //    | |
            //    --   cow!!! don`t delete this annotation
            CGFloat clipH = imageWidth * borderSizeH / borderSizeW;
            CGFloat clipY = (imageHeight - clipH) / 2;
            
            imgRect = CGRectMake(0, clipY, imageWidth, clipH);
        }
        
        fixImageData = [self cutImage:img withRect:imgRect];
    }
    else {
        fixImageData = img;
    }
    
    UIImage * fImageData = nil;
    
    if (fixImageData.imageOrientation != UIImageOrientationUp) {
        fImageData = [UIImage imageWithCGImage:fixImageData.CGImage scale:1.f orientation:UIImageOrientationUp];
    }
    else {
        fImageData = fixImageData;
    }
    return fImageData;
}

+ (UIImage *)fixImgOrientation:(UIImage *)aImage
{
    
    // No-op if the orientation is already correct
    if (aImage.imageOrientation == UIImageOrientationUp)
        return aImage;
    
    // We need to calculate the proper transformation to make the image upright.
    // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (aImage.imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, aImage.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, aImage.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        default:
            break;
    }
    
    switch (aImage.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        default:
            break;
    }
    
    // Now we draw the underlying CGImage into a new context, applying the transform
    // calculated above.
    CGContextRef ctx = CGBitmapContextCreate(NULL, aImage.size.width, aImage.size.height,
                                             CGImageGetBitsPerComponent(aImage.CGImage), 0,
                                             CGImageGetColorSpace(aImage.CGImage),
                                             CGImageGetBitmapInfo(aImage.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (aImage.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            // Grr...
            CGContextDrawImage(ctx, CGRectMake(0,0,aImage.size.height,aImage.size.width), aImage.CGImage);
            break;
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,aImage.size.width,aImage.size.height), aImage.CGImage);
            break;
    }
    
    // And now we just create a new UIImage from the drawing context
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
}

+ (UIImage *)compressImage:(UIImage *)sourceImage withTargetSize:(CGSize)targetSize
{
    UIImage * targetImage = nil;
    UIGraphicsBeginImageContext(targetSize);
    [sourceImage drawInRect:CGRectMake(0, 0, targetSize.width, targetSize.height)];
    targetImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return targetImage;
}

+ (UIImage *)tryCompressImage:(UIImage *)sourceImage ifImageSizeLargeTargetSize:(CGSize)targetSize
{
    if (sourceImage == nil || targetSize.height == 0 || targetSize.width == 0) {
        return sourceImage;
    }
    if (sourceImage.size.width < targetSize.width && sourceImage.size.height < targetSize.height) {
        return sourceImage;
    }
    
    if (aspectRatioForSize(sourceImage.size) == aspectRatioForSize(targetSize)) {
        return  [self compressImage:sourceImage withTargetSize:targetSize];
    }
    else if (aspectRatioForSize(sourceImage.size) > aspectRatioForSize(targetSize) && sourceImage.size.width > 0) {
        CGSize size = CGSizeZero;
        size.width = targetSize.width;
        size.height = (size.width * sourceImage.size.height) / sourceImage.size.width;
        return [self compressImage:sourceImage withTargetSize:size];
    }
    else if (aspectRatioForSize(sourceImage.size) < aspectRatioForSize(targetSize) && sourceImage.size.height > 0) {
        CGSize size = CGSizeZero;
        size.height = targetSize.height;
        size.width = (sourceImage.size.width * size.height ) / sourceImage.size.height;
        return [self compressImage:sourceImage withTargetSize:size];
    }
    return sourceImage;
}

//求纵横比
CGFloat aspectRatioForSize(CGSize size)
{
    if (size.height == 0) {
        return 0.f;
    }
    return size.width / size.height;
}

CGFloat ssRadiansToDegrees(CGFloat radians)
{
    return radians * 180/M_PI;
};

CGFloat ssDegreesToRadians(CGFloat degrees)
{
    return degrees * M_PI / 180;
};

+ (UIImage *)imageRotatedByRadians:(CGFloat)radians originImg:(UIImage *)originImg
{
    return [self imageRotatedByDegrees:ssRadiansToDegrees(radians) originImg:originImg];
}

+ (UIImage *)imageRotatedByDegrees:(CGFloat)degrees originImg:(UIImage *)originImg
{
    // calculate the size of the rotated view's containing box for our drawing space
    UIView *rotatedViewBox = [[UIView alloc] initWithFrame:CGRectMake(0,0,originImg.size.width, originImg.size.height)];
    CGAffineTransform t = CGAffineTransformMakeRotation(ssDegreesToRadians(degrees));
    rotatedViewBox.transform = t;
    CGSize rotatedSize = rotatedViewBox.frame.size;
    [rotatedViewBox release];
    
    // Create the bitmap context
    UIGraphicsBeginImageContext(rotatedSize);
    CGContextRef bitmap = UIGraphicsGetCurrentContext();
    
    // Move the origin to the middle of the image so we will rotate and scale around the center.
    CGContextTranslateCTM(bitmap, rotatedSize.width/2, rotatedSize.height/2);
    
    //   // Rotate the image context
    CGContextRotateCTM(bitmap, ssDegreesToRadians(degrees));
    
    // Now, draw the rotated/scaled image into the context
    CGContextScaleCTM(bitmap, 1.0, -1.0);
    CGContextDrawImage(bitmap, CGRectMake(-originImg.size.width / 2, -originImg.size.height / 2, originImg.size.width, originImg.size.height), [originImg CGImage]);
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
    
}

//+ (UIImage *)compressImageIfNeed:(UIImage *)sourceImage maxFileSize:(CGFloat)fileSize
//{
//    NSData * originData = UIImagePNGRepresentation(sourceImage);
//    float originFileSize = [originData length] / 1024.f;
//    if ( originFileSize > fileSize) {
//        
//    }
//    else return sourceImage;
//}

@end
