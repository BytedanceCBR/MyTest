//
//  UIImage+HEIF.m
//  Article
//
//  Created by fengyadong on 2017/11/2.
//

#import "UIImage+HEIF.h"
#import <RSSwizzle/RSSwizzle.h>
#import "UIImage+MultiFormat.h"
#import "UIImage+GIF.h"
#import "UIImage+WebP.h"
#import "TTWebImageHEIFCoder.h"

@implementation UIImage (HEIF)

+ (void)load {
    /* swizzle imageNamed:方法 */
    RSSwizzleClassMethod(UIImage,
                         @selector(sd_imageWithData:),
                         RSSWReturnType(UIImage *),
                         RSSWArguments(NSData *data),
                         RSSWReplacement(
                                         {
                                             if (!data) {
                                                 return nil;
                                             }

                                             UIImage *image;
                                             SDImageFormat imageFormat = [NSData sd_imageFormatForImageData:data];
                                             if (imageFormat == SDImageFormatGIF) {
                                                 image = [UIImage sd_animatedGIFWithData:data];
                                             }
#ifdef SD_WEBP
                                             else if (imageFormat == SDImageFormatWebP)
                                             {
                                                 image = [UIImage sd_imageWithWebPData:data];
                                             }
#endif
                                             else if([[TTWebImageHEIFCoder sharedCoder] supportCustomHeifDecoderForData:data]) {
                                                 image = [[TTWebImageHEIFCoder sharedCoder] decodedImageWithData:data];
                                             }
                                             else {
                                                 image = [[UIImage alloc] initWithData:data];
#if SD_UIKIT || SD_WATCH
                                                 SEL selector = NSSelectorFromString(@"sd_imageOrientationFromImageData:");
                                                 if ([self respondsToSelector:selector]) {
                                                     UIImageOrientation orientation = (UIImageOrientation)[self performSelector:selector withObject:data];
                                                     if (orientation != UIImageOrientationUp) {
                                                         image = [UIImage imageWithCGImage:image.CGImage
                                                                                     scale:image.scale
                                                                               orientation:orientation];
                                                     }
                                                 }
#endif
                                             }


                                             return image;
                                         }));
}

+(UIImageOrientation)sd_imageOrientationFromImageData:(nonnull NSData *)imageData {
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
                result = [self sd_exifOrientationToiOSOrientation:exifOrientation];
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
+ (UIImageOrientation) sd_exifOrientationToiOSOrientation:(int)exifOrientation {
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


@end
