//
//  UIImage+Normalization.m
//  Article
//
//  Created by lizhuoli on 16/12/21.
//
//

#import "UIImage+Normalization.h"

@implementation UIImage (Normalization)

- (UIImage *)normalizedImage {
    if (self.imageOrientation == UIImageOrientationUp) return self;
    
    UIGraphicsBeginImageContextWithOptions(self.size, NO, self.scale);
    [self drawInRect:(CGRect){0, 0, self.size}];
    UIImage *normalizedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return normalizedImage;
}

- (UIImage *)croppedImageWithFrame:(CGRect)frame
{
    UIImage *normalizaedImage = [self normalizedImage];
    
    CGImageRef imageRef = CGImageCreateWithImageInRect([normalizaedImage CGImage], frame);
    UIImage *croppedImage = [UIImage imageWithCGImage:imageRef scale:normalizaedImage.scale orientation:normalizaedImage.imageOrientation]; // 注意Scale 和 EXIF格式的旋转值
    CGImageRelease(imageRef);
    
    return croppedImage;
}

@end
