//
//  UIImage+GIFBugFix.m
//  Article
//
//  Created by lizhuoli on 2017/10/15.
//

#import "UIImage+GIFBugFix.h"
#import <SDWebImage/UIImage+GIF.h>

@implementation UIImage (GIFBugFix)

+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class classClass = object_getClass(self);
        MethodSwizzleForClass(classClass, @selector(sd_animatedGIFWithData:), @selector(TTSwizzleSD_animatedGIFWithData:));
    });
}

+ (UIImage *)TTSwizzleSD_animatedGIFWithData:(NSData *)data {
    if (!data) {
        return nil;
    }
    
#if SD_MAC
    return [[UIImage alloc] initWithData:data];
#endif
    
    CGImageSourceRef source = CGImageSourceCreateWithData((__bridge CFDataRef)data, NULL);
    
    size_t count = CGImageSourceGetCount(source);
    
    UIImage *staticImage;
    
    if (count <= 1) {
        staticImage = [[UIImage alloc] initWithData:data];
    } else {
        // we will only retrieve the 1st frame. the full GIF support is available via the FLAnimatedImageView category.
        // this here is only code to allow drawing animated images as static ones
#if SD_WATCH
        CGFloat scale = 1;
        scale = [WKInterfaceDevice currentDevice].screenScale;
#elif SD_UIKIT
        CGFloat scale = 1;
        scale = [UIScreen mainScreen].scale;
#endif
        
        CGImageRef CGImage = CGImageSourceCreateImageAtIndex(source, 0, NULL);
#if SD_UIKIT || SD_WATCH
        UIImage *frameImage = [UIImage imageWithCGImage:CGImage scale:scale orientation:UIImageOrientationUp];
        if (frameImage) { // nil protect if GIF data is not valid
            staticImage = [UIImage animatedImageWithImages:@[frameImage] duration:0.0f];
        }
#endif
        CGImageRelease(CGImage);
    }
    
    CFRelease(source);
    
    return staticImage;
}

static void MethodSwizzleForClass(Class class, SEL originalSelector, SEL swizzledSelector)
{
    Method originalMethod = class_getClassMethod(class, originalSelector);
    Method swizzledMethod = class_getClassMethod(class, swizzledSelector);
    
    BOOL didAddMethod =
    class_addMethod(class,
                    originalSelector,
                    method_getImplementation(swizzledMethod),
                    method_getTypeEncoding(swizzledMethod));
    
    if (didAddMethod) {
        class_replaceMethod(class,
                            swizzledSelector,
                            method_getImplementation(originalMethod),
                            method_getTypeEncoding(originalMethod));
    } else {
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}

@end
