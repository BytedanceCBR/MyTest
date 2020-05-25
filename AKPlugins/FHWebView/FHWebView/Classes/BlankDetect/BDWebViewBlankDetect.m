//
//  BDWebViewDetectBlankContent.m
//  BDWebKit
//
//  Created by 杨牧白 on 2020/3/13.
//

#import "BDWebViewBlankDetect.h"
#import <WebKit/WebKit.h>


@implementation BDWebViewBlankDetect

//wk iOS 11 新检测接口
+ (void)detectBlankByNewSnapshotWithWKWebView:(WKWebView *)wkWebview CompleteBlock:(void(^)(BOOL isBlank, UIImage *image, NSError *error)) block {
    if (!block) {
        return;
    }
    if (@available(iOS 11.0, *)) {
        if ([wkWebview isKindOfClass:[WKWebView class]]) {
            [wkWebview takeSnapshotWithConfiguration:nil completionHandler:^(UIImage * _Nullable snapshotImage, NSError * _Nullable error) {
                if (error) {
                    block(NO, nil, error);
                } else if (snapshotImage) {
                    UIColor *color = wkWebview.backgroundColor;
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                        BOOL isBlank = [self checkWebContentBlank:snapshotImage withBlankColor:color];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            block(isBlank, snapshotImage, nil);
                        });
                    });
                }
            }];
            return;
        }
    }
    
    NSError *error = [NSError errorWithDomain:@"BDWebViewDetectBlank" code:eBDDetectBlankUnsupportError userInfo:@{NSLocalizedDescriptionKey:@"no support detect blank"}];
    block ? block(NO, nil, error) : nil;
    
}

//旧检测接口
+ (void)detectBlankByOldSnapshotWithView:(UIView *)view CompleteBlock:(void(^)(BOOL isBlank, UIImage *image, NSError *error)) block {
    if (!block) {
        return;
    }
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, true, [UIScreen mainScreen].scale);
    [view drawViewHierarchyInRect:view.bounds afterScreenUpdates:NO];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    if (image == nil) {
        NSError *error = [NSError errorWithDomain:@"BDWebViewDetectBlank" code:eBDDetectBlankStatusImageError userInfo:@{NSLocalizedDescriptionKey:@"image is nil"}];
        block(NO, nil, error);
        return ;
    }
    
    UIColor *color = view.backgroundColor;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        BOOL blank = [self checkWebContentBlank:image withBlankColor:color];
        dispatch_async(dispatch_get_main_queue(), ^{
            block(blank, image, nil);
        });
    });
}

+ (BOOL)checkWebContentBlank:(UIImage *)image withBlankColor:(UIColor *)color
{
//    if ([BDWebKitSettingsManger useNewBlankCheck]) {
        return [self _newCheckWebContentBlank:image withBlankColor:color];
//    } else {
//        return [self _oldCheckWebContentBlank:image withBlankColor:color];
//    }
}

+ (BOOL)_oldCheckWebContentBlank:(UIImage *)image withBlankColor:(UIColor *)color {
    CGFloat r, g, b;
    [color getRed:&r green:&g blue:&b alpha:NULL];
    UInt32 ri = r*255;
    UInt32 gi = g*255;
    UInt32 bi = b*255;
    // 缩小到原来的 1/6 大，在保证准确率的情况下减少需要遍历像素点的数量
    size_t width = image.size.width/6;
    size_t height = image.size.height/6;
    CGImageRef imageRef = [image CGImage];
    if (width == 0 || height == 0 || imageRef == NULL) {
        return NO;
    }
    CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceRGB();
    CGContextRef bitmap = CGBitmapContextCreate(NULL,
                                                width,
                                                height,
                                                CGImageGetBitsPerComponent(imageRef),
                                                0,
                                                colorSpaceRef,
                                                kCGBitmapByteOrder32Big | kCGImageAlphaNoneSkipLast);
    CGContextDrawImage(bitmap, CGRectMake(0, 0, width, height), imageRef);
    UInt8* data = CGBitmapContextGetData(bitmap);
    
    if (data == NULL) {
        CGContextRelease(bitmap);
        CGColorSpaceRelease(colorSpaceRef);
        return NO;
    }
    
    NSUInteger clearColorCount = 0;
    NSUInteger otherCount = 0;
    // 如果存在大于总像素点的5%个非背景像素点则认为不是白屏
    long availableCount = (width * height) * 0.05;
    // 如果存在大于总像素点的50%个透明像素点则认为是白屏
    long limitCount = (width * height) * 0.5;
    for (size_t i = 0; i < height; i++) {
        for (size_t j = 0; j < width; j++) {
            size_t pixelIndex = i * width * 4 + j * 4;
            UInt32 r = data[pixelIndex];
            UInt32 g = data[pixelIndex + 1];
            UInt32 b = data[pixelIndex + 2];
            UInt32 a = data[pixelIndex + 3];
            
            if (r != ri || g != gi || b != bi) {
                otherCount++;
            }
            
            if (r == 0 && g == 0 && b == 0 && a == 0) {
                clearColorCount++;
            }
            
            if (otherCount > availableCount && clearColorCount != otherCount) {
                CGColorSpaceRelease(colorSpaceRef);
                CGContextRelease(bitmap);
                return NO;
            }
            
            if (clearColorCount >= limitCount) {
                CGColorSpaceRelease(colorSpaceRef);
                CGContextRelease(bitmap);
                return YES;
            }
        }
    }
    
    CGColorSpaceRelease(colorSpaceRef);
    CGContextRelease(bitmap);
    return YES;
}


+ (BOOL)_newCheckWebContentBlank:(UIImage *)image withBlankColor:(UIColor *)color {
    CGFloat r, g, b, a;
    [color getRed:&r green:&g blue:&b alpha:&a];
    UInt32 ri = r*255;
    UInt32 gi = g*255;
    UInt32 bi = b*255;
    UInt32 ai = a*255;
    // 缩小到原来的 1/6 大，在保证准确率的情况下减少需要遍历像素点的数量
    size_t width = image.size.width/6;
    size_t height = image.size.height/6;
    CGImageRef imageRef = [image CGImage];
    if (width == 0 || height == 0 || imageRef == NULL) {
        return NO;
    }
    CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceRGB();
    CGContextRef bitmap = CGBitmapContextCreate(NULL,
                                                width,
                                                height,
                                                CGImageGetBitsPerComponent(imageRef),
                                                0,
                                                colorSpaceRef,
                                                kCGBitmapByteOrder32Big | kCGImageAlphaPremultipliedLast);
    CGContextDrawImage(bitmap, CGRectMake(0, 0, width, height), imageRef);
    UInt8* data = CGBitmapContextGetData(bitmap);
    
    if (data == NULL) {
        CGContextRelease(bitmap);
        CGColorSpaceRelease(colorSpaceRef);
        return NO;
    }
    
    NSUInteger clearColorCount = 0;
    NSUInteger otherCount = 0;
    // 如果存在大于总像素点的5%个非背景像素点则认为不是白屏
    long availableCount = (width * height) * 0.05;
    // 如果存在大于总像素点的95%个透明像素点则认为是白屏
    long limitCount = (width * height) * 0.95;
    for (size_t i = 0; i < height; i++) {
        for (size_t j = 0; j < width; j++) {
            size_t pixelIndex = i * width * 4 + j * 4;
            UInt32 r = data[pixelIndex];
            UInt32 g = data[pixelIndex + 1];
            UInt32 b = data[pixelIndex + 2];
            UInt32 a = data[pixelIndex + 3];
            
            if (r != ri || g != gi || b != bi || a != ai) {
                otherCount++;
            }
            
            if (r == 0 && g == 0 && b == 0 && a == 0) {
                clearColorCount++;
            }
            
            if (otherCount > availableCount && clearColorCount != otherCount) {
                CGColorSpaceRelease(colorSpaceRef);
                CGContextRelease(bitmap);
                return NO;
            }
            
            if (clearColorCount >= limitCount) {
                CGColorSpaceRelease(colorSpaceRef);
                CGContextRelease(bitmap);
                return YES;
            }
        }
    }
    
    CGColorSpaceRelease(colorSpaceRef);
    CGContextRelease(bitmap);
    return YES;
}

@end
