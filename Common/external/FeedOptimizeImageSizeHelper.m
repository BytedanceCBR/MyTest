//
//  FeedOptimizeImageSizeHelper.m
//  Article
//
//  Created by tyh on 2017/11/27.
//

#import "FeedOptimizeImageSizeHelper.h"
#import "YYDispatchQueuePool.h"
#import "FLAnimatedImageView+WebCache.h"
#import "UIView+WebCache.h"
#import "UIImage+ForceDecode.h"
#import "NSData+ImageContentType.h"
#import "UIImageView+WebCache.h"
#import "TTFeedCollectionViewController.h"
#import "TTSettingsManager.h"

@interface UIView (FeedOptimizeImageViewController)
@end

@implementation UIView (FeedOptimizeImageViewController)

//是否有必要优化图片Size,只在Feed中进行
- (BOOL)isNeedOptimizeImageSize
{
    BOOL hasTableViewWithParent = NO;
    UIResponder *topResponder = self;
    while(topResponder &&
          ![topResponder isKindOfClass:[UIViewController class]])
    {
        topResponder = [topResponder nextResponder];
        if ([topResponder isKindOfClass:[UITableView class]]) {
            hasTableViewWithParent = YES;
        }
    }
    if (hasTableViewWithParent && topResponder && [topResponder isKindOfClass:[TTFeedCollectionViewController class]]) {
        return YES;
    }
    return NO;
}

@end

@implementation FeedOptimizeImageSizeHelper

static void MethodSwizzleForClass(Class class, SEL originalSelector, SEL swizzledSelector)
{
    Method originalMethod = class_getInstanceMethod(class, originalSelector);
    Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);

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


// 等比缩放
+ (void)cropEqualScaleImage:(UIImage *)image toSize:(CGSize)size completeBlock:(void(^)(UIImage *targetImage))completeBlock {

    dispatch_async(YYDispatchQueueGetForQOS(NSQualityOfServiceDefault), ^{
        CGFloat scale =  [UIScreen mainScreen].scale;

        //指定sclae,指定不透明，不发生图层混合
        UIGraphicsBeginImageContextWithOptions(size, YES, scale);

        //是否固定宽
        BOOL isFixedWidth = NO;
        if (image.size.width != 0 && image.size.height != 0) {
            CGFloat rateWidth = size.width / image.size.width;
            CGFloat rateHeight = size.height / image.size.height;
            if (rateWidth > rateHeight) {
                isFixedWidth = YES;
            }
        }
        float targetWidth;
        float targetHeight;

        if (isFixedWidth) {
            targetWidth = size.width;
            targetHeight = targetWidth * image.size.height/image.size.width;
        }else{
            targetHeight = size.height;
            targetWidth = targetHeight * image.size.width/image.size.height;
        }

        float x = isFixedWidth? 0 : (size.width - targetWidth)/2.0;
        float y = isFixedWidth? (size.height - targetHeight)/2.0 : 0;

        [image drawInRect:CGRectMake(x, y, targetWidth,targetHeight)];
        UIImage *targetImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();

        UIImage *decodeImg = [UIImage decodedImageWithImage:targetImage];

        dispatch_async(dispatch_get_main_queue(), ^{
            if (completeBlock) {
                completeBlock(decodeImg);
            }
        });
    });
}
@end




@interface FLAnimatedImageView (OptimizeWebCache)

@end

@implementation FLAnimatedImageView (OptimizeWebCache)

+ (void)load
{
    NSDictionary *fps_info = [[TTSettingsManager sharedManager] settingForKey:@"tt_optimize_fps_enable" defaultValue:[NSDictionary dictionary] freeze:YES];
    if (fps_info[@"tt_optimize_img_size"] && [fps_info[@"tt_optimize_img_size"] boolValue]) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            MethodSwizzleForClass([self class], @selector(sd_setImageWithURL:placeholderImage:options:progress:completed:), @selector(optimize_sd_setImageWithURL:placeholderImage:options:progress:completed:));
        });
    }
}

- (void)optimize_sd_setImageWithURL:(nullable NSURL *)url
                   placeholderImage:(nullable UIImage *)placeholder
                            options:(SDWebImageOptions)options
                           progress:(nullable SDWebImageDownloaderProgressBlock)progressBlock
                          completed:(nullable SDExternalCompletionBlock)completedBlock {
    __weak typeof(self)weakSelf = self;

    if ([self isNeedOptimizeImageSize]) {
        options |= SDWebImageCacheMemoryOnly;
        [self sd_internalSetImageWithURL:url
                        placeholderImage:placeholder
                                 options:options
                            operationKey:nil
                           setImageBlock:^(UIImage *image, NSData *imageData) {
                               SDImageFormat imageFormat = [NSData sd_imageFormatForImageData:imageData];
                               if (imageFormat == SDImageFormatGIF) {
                                   weakSelf.animatedImage = [FLAnimatedImage animatedImageWithGIFData:imageData];
                                   weakSelf.image = nil;
                               } else {
                                   if (image) {

                                       if (image.size.width == weakSelf.frame.size.width || image.size.height == weakSelf.frame.size.height) {
                                           weakSelf.image = image;

                                       }else{
                                           [FeedOptimizeImageSizeHelper cropEqualScaleImage:image toSize:weakSelf.frame.size completeBlock:^(UIImage *targetImage) {
                                               [[SDWebImageManager sharedManager].imageCache storeImage:targetImage forKey:[[SDWebImageManager sharedManager] cacheKeyForURL:url] toDisk:YES completion:nil];

                                               weakSelf.image = targetImage;

                                           }];
                                       }

                                   }else{
                                       weakSelf.image = image;
                                   }
                                   weakSelf.animatedImage = nil;

                               }
                           }
                                progress:progressBlock
                               completed:completedBlock];
    }else{
        [self sd_internalSetImageWithURL:url
                        placeholderImage:placeholder
                                 options:options
                            operationKey:nil
                           setImageBlock:^(UIImage *image, NSData *imageData) {
                               SDImageFormat imageFormat = [NSData sd_imageFormatForImageData:imageData];
                               if (imageFormat == SDImageFormatGIF) {
                                   weakSelf.animatedImage = [FLAnimatedImage animatedImageWithGIFData:imageData];
                                   weakSelf.image = nil;
                               } else {
                                   weakSelf.image = image;
                                   weakSelf.animatedImage = nil;
                               }
                           }
                                progress:progressBlock
                               completed:completedBlock];

    }

}

@end

@interface UIImageView (OptimizeWebCache)

@end

@implementation UIImageView (OptimizeWebCache)

+ (void)load
{
    NSDictionary *fps_info = [[TTSettingsManager sharedManager] settingForKey:@"tt_optimize_fps_enable" defaultValue:[NSDictionary dictionary] freeze:YES];
    if (fps_info[@"tt_optimize_img_size"] && [fps_info[@"tt_optimize_img_size"] boolValue]) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            MethodSwizzleForClass([self class], @selector(sd_setImageWithURL:placeholderImage:options:progress:completed:), @selector(optimize_sd_setImageWithURL:placeholderImage:options:progress:completed:));
        });
    }
}

- (void)optimize_sd_setImageWithURL:(nullable NSURL *)url
                   placeholderImage:(nullable UIImage *)placeholder
                            options:(SDWebImageOptions)options
                           progress:(nullable SDWebImageDownloaderProgressBlock)progressBlock
                          completed:(nullable SDExternalCompletionBlock)completedBlock {
    __weak typeof(self)weakSelf = self;

    if ([self isNeedOptimizeImageSize]) {
        options |= SDWebImageCacheMemoryOnly;
        options |= SDWebImageAvoidAutoSetImage;
        [self sd_internalSetImageWithURL:url
                        placeholderImage:placeholder
                                 options:options
                            operationKey:nil
                           setImageBlock:nil
                                progress:progressBlock
                               completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {

                                   if (image) {
                                       if (image.size.width == weakSelf.frame.size.width || image.size.height == weakSelf.frame.size.height) {
                                           self.image = image;
                                           if (completedBlock) {
                                               completedBlock(image,error,cacheType,imageURL);
                                           }
                                       }else{
                                           [FeedOptimizeImageSizeHelper cropEqualScaleImage:image toSize:weakSelf.frame.size completeBlock:^(UIImage *targetImage) {
                                               [[SDWebImageManager sharedManager].imageCache storeImage:targetImage forKey:[[SDWebImageManager sharedManager] cacheKeyForURL:url] toDisk:YES completion:nil];
                                               self.image = targetImage;
                                               if (completedBlock) {
                                                   completedBlock(targetImage,error,cacheType,imageURL);
                                               }
                                           }];

                                       }
                                   }else{
                                       self.image = nil;
                                       if (completedBlock) {
                                           completedBlock(nil,error,cacheType,imageURL);
                                       }
                                   }
                               }];
    }else{
        [self sd_internalSetImageWithURL:url
                        placeholderImage:placeholder
                                 options:options
                            operationKey:nil
                           setImageBlock:nil
                                progress:progressBlock
                               completed:completedBlock];

    }


}

@end





