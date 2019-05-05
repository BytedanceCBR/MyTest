//
//  TTUGCImageCompressHelper.m
//  Article
//
//  Created by SongChai on 08/06/2017.
//
//

#import "TTUGCImageCompressHelper.h"
#import <ImageIO/ImageIO.h>
#import <TTKitchen/TTKitchenHeader.h>
#import <YYImage/YYImageCoder.h>

//import tgmath.h as suggested by http://stackoverflow.com/questions/5352457/cgfloat-based-math-functions/5352779#5352779
#import <tgmath.h>
#import <MobileCoreServices/MobileCoreServices.h>


NSString * const AnimatedGIFImageErrorDomain = @"com.toutiao.gif.image.error";

__attribute__((overloadable)) NSData * TTImageJPEGRepresentation(UIImage *image, CGFloat compressionQuality) {
    if (compressionQuality > 0.9) {
        compressionQuality = 0.9;
    }
    return UIImageJPEGRepresentation(image, compressionQuality);
}

__attribute__((overloadable)) NSData * TTImageAnimatedGIFRepresentation(UIImage *image) {
    return TTImageAnimatedGIFRepresentation(image, 0.0f, 0, 0, nil);
}

__attribute__((overloadable)) NSData * TTImageAnimatedGIFRepresentation(UIImage *image, NSTimeInterval duration, NSUInteger loopCount, NSUInteger maxCount, NSError * __autoreleasing *error) {
    if (!image.images) {
        return nil;
    }
    
    NSDictionary *userInfo = nil;
    {
        size_t frameCount = image.images.count;
        
        size_t scale = 1;
        //抽帧
        if (maxCount >= [TTKitchen getInt:kKCUGCImageCompressGifMaxFrameCount] && frameCount > maxCount ) {
            //只要开始抽帧，就会把帧数限制在100以内，为了减少抽帧时间
            maxCount = [TTKitchen getInt:kKCUGCImageCompressGifMaxFrameCount] ;
            //向上取整
            scale = ceil(frameCount/(double)maxCount);
        }
        
        //抽帧后的image数组
        NSMutableArray *images = nil;
        if (scale > 1) {
            images = [NSMutableArray array];
            for (size_t idx = 0; idx < image.images.count; idx += scale) {
                [images addObject:[image.images objectAtIndex:idx]];
            }
        }else{
            images = [image.images mutableCopy];
        }
        frameCount = images.count;
        
        //        NSLog(@"抽帧后帧数：%ld",images.count);
        
        NSTimeInterval frameDuration = (duration <= 0.0 ? image.duration / frameCount : duration / frameCount);
        
        
        NSDictionary *frameProperties = @{
                                          (__bridge NSString *)kCGImagePropertyGIFDictionary: @{
                                                  (__bridge NSString *)kCGImagePropertyGIFDelayTime: @(frameDuration)
                                                  }
                                          };
        
        NSMutableData *mutableData = [NSMutableData data];
        
        
        CGImageDestinationRef destination = CGImageDestinationCreateWithData((__bridge CFMutableDataRef)mutableData, kUTTypeGIF, frameCount, NULL);
        
        NSDictionary *imageProperties = @{ (__bridge NSString *)kCGImagePropertyGIFDictionary: @{
                                                   (__bridge NSString *)kCGImagePropertyGIFLoopCount: @(loopCount)
                                                   }
                                           };
        CGImageDestinationSetProperties(destination, (__bridge CFDictionaryRef)imageProperties);
        //        CFAbsoluteTime startTime =CFAbsoluteTimeGetCurrent();
        for (size_t idx = 0; idx < images.count; idx++) {
            CGImageDestinationAddImage(destination, [[images objectAtIndex:idx] CGImage], (__bridge CFDictionaryRef)frameProperties);
        }
        //        CFAbsoluteTime linkTime = (CFAbsoluteTimeGetCurrent() - startTime);
        //        NSLog(@"Gif抽帧运行%f ms", linkTime *1000.0);
        
        BOOL success = CGImageDestinationFinalize(destination);
        CFRelease(destination);
        
        if (!success) {
            userInfo = @{
                         NSLocalizedDescriptionKey: NSLocalizedString(@"Could not finalize image destination", nil)
                         };
            
            goto _error;
        }
        
        return [NSData dataWithData:mutableData];
    }
_error: {
    if (error) {
        *error = [[NSError alloc] initWithDomain:AnimatedGIFImageErrorDomain code:-1 userInfo:userInfo];
    }
    
    return nil;
}
}

extern __attribute__((overloadable)) NSData * TTImageWebPRepresentation(UIImage *image) {
    if (image == nil) {
        return nil;
    }
    
    
    YYImageEncoder* encoder = [[YYImageEncoder alloc] initWithType:YYImageTypeWebP];
    [encoder addImage:image duration:0];
    
    
    NSData* resultData = [encoder encode];
    
    if (resultData == nil) {
        resultData = TTImageJPEGRepresentation(image, 0.9);
    }
    
    return resultData;
}


@implementation TTUGCImageCompressHelper

+ (NSData *)compress:(NSData *)data {
    if (!data) {
        return nil;
    }
    
    NSString *imageContentType = [self contentTypeForImageData:data];
    if ([imageContentType isEqualToString:@"image/gif"]) {
        return [self compressGif:data];
    }
    else if ([imageContentType isEqualToString:@"image/webp"]) {
        return data;//webp不处理
    }
    else {
        UIImage *image = [[UIImage alloc] initWithData:data];
        UIImageOrientation orientation = [self imageOrientationFromImageData:data];
        if (orientation != UIImageOrientationUp) {
            image = [UIImage imageWithCGImage:image.CGImage
                                        scale:image.scale
                                  orientation:orientation];
        }
        image = [TTUGCImageCompressHelper processImageForUploadImage:image]; //图片尺寸调整
        return TTImageWebPRepresentation(image);

    }
}

+ (NSData*) compressGif:(NSData*)imageData {
    if (!imageData) {
        return nil;
    }
    
    //最多100帧
    
    CGImageSourceRef source = CGImageSourceCreateWithData((__bridge CFDataRef)imageData, NULL);
    
    size_t count = CGImageSourceGetCount(source);
    
    if (count == 0) {
        return nil;
    }
    if (count == 1) {
        CFRelease(source);
        
        UIImage *image = [[UIImage alloc] initWithData:imageData];
        image = [TTUGCImageCompressHelper processImageForUploadImage:image]; //图片尺寸调整
        return TTImageWebPRepresentation(image);
    }
    
    int maxCount = 100;
    CGFloat size = (CGFloat) count/maxCount;
    int scale = ceil(size);
    scale = MAX(scale, 1);
    
    if (scale == 1) { //不压缩
        CFRelease(source);
        return imageData;
    }
    
    NSMutableArray *images = [NSMutableArray array];
    
    NSTimeInterval duration = 0.0f;
    for (size_t i = 0; i < count; i++) {
        CGImageRef image = CGImageSourceCreateImageAtIndex(source, i, NULL);
        if (!image) {
            continue;
        }
        
        duration += [self frameDurationAtIndex:i source:source];
        if (i%scale == 0) { //0除以任何值都是0，可以保证至少有1帧
            [images addObject:[UIImage imageWithCGImage:image scale:[UIScreen mainScreen].scale orientation:UIImageOrientationUp]];
        }
        CGImageRelease(image);
    }
    
    if (!duration) {
        duration = (1.0f / 10.0f) * count;
    }
    CFRelease(source);
    
    size_t frameCount = images.count;
    
    if (frameCount == 0) {
        return nil;
    }
    
    if (frameCount == 1) {
        UIImage *image = [TTUGCImageCompressHelper processImageForUploadImage:images.firstObject]; //图片尺寸调整
        return TTImageWebPRepresentation(image);
    }
    
    NSTimeInterval frameDuration = duration / frameCount;
    NSDictionary *frameProperties = @{
                                      (__bridge NSString *)kCGImagePropertyGIFDictionary: @{
                                              (__bridge NSString *)kCGImagePropertyGIFDelayTime: @(frameDuration)
                                              }
                                      };
    
    NSMutableData *mutableData = [NSMutableData data];
    
    CGImageDestinationRef destination = CGImageDestinationCreateWithData((__bridge CFMutableDataRef)mutableData, kUTTypeGIF, frameCount, NULL);
    
    NSDictionary *imageProperties = @{ (__bridge NSString *)kCGImagePropertyGIFDictionary: @{
                                               (__bridge NSString *)kCGImagePropertyGIFLoopCount: @(0)
                                               }
                                       };
    CGImageDestinationSetProperties(destination, (__bridge CFDictionaryRef)imageProperties);
    for (size_t idx = 0; idx < images.count; idx++) {
        CGImageDestinationAddImage(destination, [[images objectAtIndex:idx] CGImage], (__bridge CFDictionaryRef)frameProperties);
    }
    
    BOOL success = CGImageDestinationFinalize(destination);
    CFRelease(destination);
    
    if (!success) {
        return  nil;
    }
    
    return [NSData dataWithData:mutableData];
}


+ (NSData *)compressImage:(UIImage *)image {
    if (image == nil) {
        return nil;
    }
    
    if (image.images == nil || image.images.count == 0) {
        image = [TTUGCImageCompressHelper processImageForUploadImage:image]; //图片尺寸调整
        return TTImageWebPRepresentation(image);
    }
    
    int maxCount = 100;
    size_t frameCount = image.images.count;
    CGFloat size = (CGFloat) frameCount/maxCount;
    int scale = ceil(size);
    scale = MAX(scale, 1);
    
    NSMutableArray *images = [NSMutableArray array];
    
    NSTimeInterval duration = image.duration;
    for (size_t i = 0; i < image.images.count; i++) {
        if (i%scale == 0) { //0除以任何值都是0，可以保证至少有1帧
            [images addObject:[image.images objectAtIndex:i]];
        }
    }
    
    frameCount = images.count;
    
    if (frameCount == 0) {
        return nil;
    }
    
    if (frameCount == 1) {
        image = [TTUGCImageCompressHelper processImageForUploadImage:images.firstObject]; //图片尺寸调整
        return TTImageWebPRepresentation(image);
    }
    
    NSTimeInterval frameDuration = duration / frameCount;
    NSDictionary *frameProperties = @{
                                      (__bridge NSString *)kCGImagePropertyGIFDictionary: @{
                                              (__bridge NSString *)kCGImagePropertyGIFDelayTime: @(frameDuration)
                                              }
                                      };
    
    NSMutableData *mutableData = [NSMutableData data];
    
    CGImageDestinationRef destination = CGImageDestinationCreateWithData((__bridge CFMutableDataRef)mutableData, kUTTypeGIF, frameCount, NULL);
    
    NSDictionary *imageProperties = @{ (__bridge NSString *)kCGImagePropertyGIFDictionary: @{
                                               (__bridge NSString *)kCGImagePropertyGIFLoopCount: @(0)
                                               }
                                       };
    CGImageDestinationSetProperties(destination, (__bridge CFDictionaryRef)imageProperties);
    for (size_t idx = 0; idx < images.count; idx++) {
        CGImageDestinationAddImage(destination, [[images objectAtIndex:idx] CGImage], (__bridge CFDictionaryRef)frameProperties);
    }
    
    BOOL success = CGImageDestinationFinalize(destination);
    CFRelease(destination);
    
    if (!success) {
        return  nil;
    }
    
    return [NSData dataWithData:mutableData];
}



+ (float)frameDurationAtIndex:(NSUInteger)index source:(CGImageSourceRef)source {
    float frameDuration = 0.1f;
    CFDictionaryRef cfFrameProperties = CGImageSourceCopyPropertiesAtIndex(source, index, nil);
    NSDictionary *frameProperties = (__bridge NSDictionary *)cfFrameProperties;
    NSDictionary *gifProperties = frameProperties[(NSString *)kCGImagePropertyGIFDictionary];
    
    NSNumber *delayTimeUnclampedProp = gifProperties[(NSString *)kCGImagePropertyGIFUnclampedDelayTime];
    if (delayTimeUnclampedProp) {
        frameDuration = [delayTimeUnclampedProp floatValue];
    }
    else {
        
        NSNumber *delayTimeProp = gifProperties[(NSString *)kCGImagePropertyGIFDelayTime];
        if (delayTimeProp) {
            frameDuration = [delayTimeProp floatValue];
        }
    }
    
    // Many annoying ads specify a 0 duration to make an image flash as quickly as possible.
    // We follow Firefox's behavior and use a duration of 100 ms for any frames that specify
    // a duration of <= 10 ms. See <rdar://problem/7689300> and <http://webkit.org/b/36082>
    // for more information.
    
    if (frameDuration < 0.011f) {
        frameDuration = 0.100f;
    }
    
    CFRelease(cfFrameProperties);
    return frameDuration;
}

+(UIImageOrientation)imageOrientationFromImageData:(NSData *)imageData {
    UIImageOrientation result = UIImageOrientationUp;
    CGImageSourceRef imageSource = CGImageSourceCreateWithData((__bridge CFDataRef)imageData, NULL);
    if (imageSource) {
        CFDictionaryRef properties = CGImageSourceCopyPropertiesAtIndex(imageSource, 0, NULL);
        if (properties) {
            CFTypeRef val;
            int exifOrientation;
            val = CFDictionaryGetValue(properties, kCGImagePropertyOrientation);
            if (val) {
                CFNumberGetValue(val, kCFNumberIntType, &exifOrientation);
                result = [self exifOrientationToiOSOrientation:exifOrientation];
            } // else - if it's not set it remains at up
            CFRelease((CFTypeRef) properties);
        } else {
            //NSLog(@"NO PROPERTIES, FAIL");
        }
        CFRelease(imageSource);
    }
    return result;
}

#pragma mark EXIF orientation tag converter
// Convert an EXIF image orientation to an iOS one.
// reference see here: http://sylvana.net/jpegcrop/exif_orientation.html
+ (UIImageOrientation) exifOrientationToiOSOrientation:(int)exifOrientation {
    UIImageOrientation orientation = UIImageOrientationUp;
    switch (exifOrientation) {
        case 1:
            orientation = UIImageOrientationUp;
            break;
            
        case 3:
            orientation = UIImageOrientationDown;
            break;
            
        case 8:
            orientation = UIImageOrientationLeft;
            break;
            
        case 6:
            orientation = UIImageOrientationRight;
            break;
            
        case 2:
            orientation = UIImageOrientationUpMirrored;
            break;
            
        case 4:
            orientation = UIImageOrientationDownMirrored;
            break;
            
        case 5:
            orientation = UIImageOrientationLeftMirrored;
            break;
            
        case 7:
            orientation = UIImageOrientationRightMirrored;
            break;
        default:
            break;
    }
    return orientation;
}

+ (NSString *)contentTypeForImageData:(NSData *)data {
    uint8_t c;
    [data getBytes:&c length:1];
    switch (c) {
        case 0xFF:
            return @"image/jpeg";
        case 0x89:
            return @"image/png";
        case 0x47:
            return @"image/gif";
        case 0x49:
        case 0x4D:
            return @"image/tiff";
        case 0x52:
            // R as RIFF for WEBP
            if ([data length] < 12) {
                return nil;
            }
            
            NSString *testString = [[NSString alloc] initWithData:[data subdataWithRange:NSMakeRange(0, 12)] encoding:NSASCIIStringEncoding];
            if ([testString hasPrefix:@"RIFF"] && [testString hasSuffix:@"WEBP"]) {
                return @"image/webp";
            }
            
            return nil;
    }
    return nil;
}

@end

@implementation TTUGCImageCompressHelper(Resize)

//width，height限制如果都设置，优先考虑height
+ (UIImage *)compressImage:(UIImage *)image
                      size:(long long)size
                limitWidth:(CGFloat)limitWidth
               limitHeight:(CGFloat)limitHeight
{
    UIImage * resultImg = image;
    
    if (image == nil) {
        return nil;
    }
    @autoreleasepool {
        CGFloat scale = 1;
        long long currentSize = image.size.width * image.size.height * 4;
        
        if (currentSize > size) {
            scale = (CGFloat) size/currentSize ;
        }
        
        if (limitHeight > 0) {
            if (image.size.height > limitHeight) {
                CGFloat heightScale = (CGFloat) limitHeight/image.size.height;
                scale = MIN(heightScale, scale);
            }
        }
        
        
        if(limitWidth > 0) {
            if (image.size.width > limitWidth) {
                CGFloat widthScale = (CGFloat) limitWidth/image.size.width;
                scale = MIN(widthScale, scale);
            }
        }
        
        if (scale < 1) {
            CGSize needDealSize = CGSizeMake(ceil(image.size.width * scale), ceil(image.size.height * scale));
            if (needDealSize.width > 0 && needDealSize.height > 0) {
                UIGraphicsBeginImageContext(needDealSize);
                [image drawInRect:CGRectMake(0, 0, needDealSize.width, needDealSize.height)];
                resultImg = UIGraphicsGetImageFromCurrentImageContext();
                UIGraphicsEndImageContext();
            }
        }
    }
    return resultImg;
}


+ (UIImage *)processImageForUploadImage:(UIImage *)image
{
    if (!image) {
        return nil;
    }
    if (image.images) {
        return image;
    }
    
    CGSize limitSize = [self getLimitSizeWithImageSize:image.size];
    return [self compressImage:image size:[self noramlImgLimitValue] limitWidth:limitSize.width limitHeight:limitSize.height];
}

+ (CGSize)getLimitSizeWithImageSize:(CGSize)imageSize {
    if ([self isVerticalImageSize:imageSize]) {
        return CGSizeMake([self longImageShortLimitValue], [self longImageLongLimitValue]);
    }
    else if ([self isHorizontalImageSize:imageSize]) {
        return CGSizeMake([self longImageLongLimitValue], [self longImageShortLimitValue]);
    }
    else { // normal
        return CGSizeMake([self normalLimitLength], [self normalLimitLength]);
    }
}

//判断是否是竖直图
+ (BOOL)isVerticalImageSize:(CGSize)imageSize
{
    if (imageSize.width == 0 || imageSize.height == 0) {
        return NO;
    }
    if ((imageSize.height / imageSize.width) >= [self verticalImgCriticalValue]) {
        return YES;
    }
    return NO;
}

//判断是否是水平图
+ (BOOL)isHorizontalImageSize:(CGSize)imageSize
{
    if (imageSize.width == 0 || imageSize.height == 0) {
        return NO;
    }
    if ((imageSize.width / imageSize.height) >= [self horizontalImgCriticalValue]) {
        return YES;
    }
    return NO;
}

//竖直图片临界值
+ (CGFloat)verticalImgCriticalValue
{
    return 3;
}

//水平图片临界值
+ (CGFloat)horizontalImgCriticalValue
{
    return 3;
}

//图片的限定值
+ (CGFloat)noramlImgLimitValue
{
    return FLT_MAX;
}

//水平图片的限定值
+ (CGFloat)longImageLongLimitValue
{
    return [TTKitchen getFloat:kKCUGCImageCompressLongLongPX];
}

//竖直图，限定边长, 短边若大于verticalLimitLength，则等比例压缩
+ (CGFloat)longImageShortLimitValue
{
    return [TTKitchen getFloat:kKCUGCImageCompressLongShortPX];
}

//普通图，限定边长,若短边大于normalLimitLength，则压缩尺寸：
+ (CGFloat)normalLimitLength
{
    return [TTKitchen getFloat:kKCUGCImageCompressNormalPX];
}
@end
