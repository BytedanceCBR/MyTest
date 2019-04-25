//
//  TTWebImageHEIFCoder.m
//  Article
//
//  Created by fengyadong on 2017/10/27.
//  Copyright © 2017年 Bytedance. All rights reserved.
//

#import "TTWebImageHEIFCoder.h"
#import "ttheif_dec.h"

@implementation TTWebImageHEIFCoder

+ (instancetype)sharedCoder
{
    static TTWebImageHEIFCoder *coder;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        coder = [[TTWebImageHEIFCoder alloc] init];
    });
    return coder;
}

- (BOOL)supportCustomHeifDecoderForData:(nullable NSData *)data {
#ifndef TARGET_OS_SIMULATOR
    //原生方法只在iOS11以上生效
    if (@available(iOS 11.0, *)) {
        return NO;
    }
#endif
    
    return [self isHeifData:data];
}

- (BOOL)isHeifData:(nullable NSData *)data {
    uint32_t dataSize = (uint32_t)data.length;
    uint8_t *heifData = (uint8_t *)data.bytes;
    
    if(heifData == NULL || dataSize <= 0) {
        return NO;
    }
    
    return heif_judge_file_type(heifData,dataSize);
}

- (UIImage *)decodedImageWithData:(NSData *)data
{
    if (!data) {
        return nil;
    }
    
    uint32_t dataSize = (uint32_t)data.length;
    uint8_t *heifData = (uint8_t *)data.bytes;
    if (!heifData) {
        return nil;
    }
    
    uint32_t width = 0;
    uint32_t height = 0;
    if (!heif_parse_size(heifData, dataSize, &width, &height)) {
        // parse error
        return nil;
    }
        
    BOOL alpha = YES; //RGBA未实现，直接是塞的一行255完全不透明。按理论来说，应该有一个方法能判断当前图片是否含有alpha通道
    HeifOutputStream outputStream;
    if (alpha) {
        outputStream = heif_decode_to_rgba(heifData, dataSize, &width, &height);
    } else {
        outputStream = heif_decode_to_rgb(heifData, dataSize, &width, &height);
    }
    if (!outputStream.data) {
        return nil;
    }
    
    uint8_t *rgba = outputStream.data;
    uint32_t rgbaSize = outputStream.size;
    
    CGSize imageSize = CGSizeMake(width, height);
    UIImage *image = [self tt_rawImageWithBitmap:rgba rgbaSize:rgbaSize alpha:alpha imageSize:imageSize];
    image = [self tt_decompressedImageWithImage:image alpha:alpha];
    
    return image;
}

// 其实这个应该叫做render for display（SD这个起名有点诡异，YY就叫做display），因为编码和显示屏的byteorder或者rgba顺序不同，需要用CGBitmapContext重新画一次
- (nullable UIImage *)tt_decompressedImageWithImage:(nullable UIImage *)image alpha:(BOOL)alpha
{
    if (!image) {
        return nil;
    }
    int canvasWidth = image.size.width;
    int canvasHeight = image.size.height;
    CGBitmapInfo bitmapInfo;
    if (!alpha) {
        bitmapInfo = kCGBitmapByteOrder32Big | kCGImageAlphaNoneSkipLast;
    } else {
        bitmapInfo = kCGBitmapByteOrder32Big | kCGImageAlphaPremultipliedLast;
    }
    
    CGContextRef canvas = CGBitmapContextCreate(NULL, canvasWidth, canvasHeight, 8, 0, TTCGColorSpaceGetDeviceRGB(), bitmapInfo);
    if (!canvas) {
        return nil;
    }
    
    CGImageRef imageRef = image.CGImage;
    size_t width = CGImageGetWidth(imageRef);
    size_t height = CGImageGetHeight(imageRef);
    CGContextDrawImage(canvas, CGRectMake(0, 0, width, height), imageRef);
    CGImageRef newImageRef = CGBitmapContextCreateImage(canvas);
    image = [[UIImage alloc] initWithCGImage:newImageRef];
    CGImageRelease(newImageRef);
    CGContextRelease(canvas);
    
    return image;
}

// 直接通过rgba，创建一个CGImage并生成UIImage
- (nullable UIImage *)tt_rawImageWithBitmap:(uint8_t *)rgba rgbaSize:(uint32_t)rgbaSize alpha:(BOOL)alpha imageSize:(CGSize)imageSize {
    
    int width = imageSize.width;
    int height = imageSize.height;
    
    // Construct a UIImage from the decoded RGBA value array
    CGDataProviderRef provider =
    CGDataProviderCreateWithData(NULL, rgba, rgbaSize, FreeImageData);
    CGColorSpaceRef colorSpaceRef = TTCGColorSpaceGetDeviceRGB();
    CGBitmapInfo bitmapInfo = alpha ? kCGBitmapByteOrder32Big | kCGImageAlphaPremultipliedLast : kCGBitmapByteOrder32Big | kCGImageAlphaNoneSkipLast;
    size_t components = alpha ? 4 : 3;
    CGColorRenderingIntent renderingIntent = kCGRenderingIntentDefault;
    CGImageRef imageRef = CGImageCreate(width, height, 8, components * 8, components * width, colorSpaceRef, bitmapInfo, provider, NULL, NO, renderingIntent);
    
    CGDataProviderRelease(provider);
    
    UIImage *image = [[UIImage alloc] initWithCGImage:imageRef];
    CGImageRelease(imageRef);
    
    return image;
}

// 检测HEIF格式是否为解码库所识别的
+ (BOOL)isSupportedHEIFFormatForImage:(nullable NSData *)data
{
    if (!data) {
        return NO;
    }
    
    // File signatures table: http://www.garykessler.net/library/file_sigs.html
    uint8_t c;
    [data getBytes:&c length:1];
    switch (c) {
        case 0x00: {
            if (data.length >= 12) {
                NSString *testString = [[NSString alloc] initWithData:[data subdataWithRange:NSMakeRange(4, 8)] encoding:NSASCIIStringEncoding];
                if ([testString isEqualToString:@"ftypheic"]) {
                    //....ftypheic
                    return YES;
                } else if ([testString isEqualToString:@"ftypmif1"]) {
                    //....ftypmsf1
                    return YES;
                } else if ([testString isEqualToString:@"ftyphevc"]) {
                    //....ftyphevc
                    return YES;
                }
            }
            break;
        }
    }
    return NO;
}

// 这是用于在rgba渲染到CGImageRef后，销毁rgba数据用的，不free的话会内存泄漏
static void FreeImageData(void *info, const void *data, size_t size) {
    free((void *)data);
}

// 性能优化，设备当前的colorSpace不用频繁创建，一次到位
static CGColorSpaceRef TTCGColorSpaceGetDeviceRGB(void) {
    static CGColorSpaceRef colorSpace;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        colorSpace = CGColorSpaceCreateDeviceRGB();
    });
    return colorSpace;
}

@end
