//
//  UIImage+TTVHelper.m
//  Article
//
//  Created by 戚宽 on 2018/9/3.
//

#import "UIImage+TTVHelper.h"
#import "TTVPlayerDefine.h"

@implementation UIImage (TTVHelper)

#pragma mark 生成一张纯色图片
+ (UIImage *)ttv_imageWithColor:(UIColor *)color size:(CGSize)size {
    UIGraphicsBeginImageContext(size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, CGRectMake(0, 0, size.width, size.height));
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

#pragma mark 生成一张新的尺寸图片
- (UIImage *)ttv_resizedImageForSize:(CGSize)size {
    UIGraphicsBeginImageContextWithOptions(size, NO, [UIScreen mainScreen].scale);
    [self drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

#pragma mark 图片着色
- (UIImage *)ttv_imageWithTintColor:(UIColor *)tintColor {
    return [self ttv_imageWithTintColor:tintColor blendMode:kCGBlendModeDestinationIn];
}

- (UIImage *)ttv_imageWithGradientTintColor:(UIColor *)tintColor {
    return [self ttv_imageWithTintColor:tintColor blendMode:kCGBlendModeOverlay];
}

- (UIImage *)ttv_imageWithTintColor:(UIColor *)tintColor blendMode:(CGBlendMode)blendMode {
    UIGraphicsBeginImageContextWithOptions(self.size, NO, 0.0f);
    [tintColor setFill];
    CGRect bounds = CGRectMake(0, 0, self.size.width, self.size.height);
    UIRectFill(bounds);
    
    [self drawInRect:bounds blendMode:blendMode alpha:1.0f];
    
    if (blendMode != kCGBlendModeDestinationIn) {
        [self drawInRect:bounds blendMode:kCGBlendModeDestinationIn alpha:1.0f];
    }
    
    UIImage *tintedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return tintedImage;
}

+ (UIImage *)ttv_ImageNamed:(NSString *)name {
    NSBundle *bundle = [NSBundle bundleWithPath:TTVPlayerBundlePath];
    return [UIImage imageNamed:name inBundle:bundle compatibleWithTraitCollection:nil];
}

@end
