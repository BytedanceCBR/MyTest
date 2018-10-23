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
                                                 UIImageOrientation orientation = [self performSelector:NSSelectorFromString(@"sd_imageOrientationFromImageData:") withObject:data];
                                                 if (orientation != UIImageOrientationUp) {
                                                     image = [UIImage imageWithCGImage:image.CGImage
                                                                                 scale:image.scale
                                                                           orientation:orientation];
                                                 }
#endif
                                             }
                                             
                                             
                                             return image;
                                         }));
}

@end
