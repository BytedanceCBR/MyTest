//
//  UIImageView+fhUgcImage.m
//  AKCommentPlugin
//
//  Created by 谢思铭 on 2020/6/22.
//

#import "UIImageView+fhUgcImage.h"
#import "ExploreCellHelper.h"
#import <BDWebImage/SDWebImageAdapter.h>
#import "TTDeviceHelper.h"
#import "FHBlockTransformer.h"
#import "UIDevice+BTDAdditions.h"

@implementation UIImageView (fhUgcImage)

- (nullable BDWebImageRequest *)fh_setImageWithURL:(nonnull NSURL *)imageURL placeholder:(nullable UIImage *)placeholder {
    [self.layer removeAnimationForKey:@"contents"];
    WeakSelf;
    return [self bd_setImageWithURL:imageURL placeholder:placeholder options:BDImageRequestSetDelaySetImage completion:^(BDWebImageRequest *request, UIImage *image, NSData *data, NSError *error, BDWebImageResultFrom from) {
        StrongSelf;
        NSMutableDictionary *imageData = [NSMutableDictionary dictionary];
        imageData[@"image"] = image;
        imageData[@"from"] = @(from);
        
        if([UIDevice btd_is568Screen] || [UIDevice btd_is480Screen] || ([UIDevice btd_is667Screen] && [UIDevice btd_OSVersionNumber] < 13.0)){
            [self performSelector:@selector(setImageWithData:) withObject:imageData afterDelay:0 inModes:@[NSDefaultRunLoopMode]];
        }else{
            [self setImageWithData:imageData];
        }
    }];
}

- (nullable BDWebImageRequest *)fh_setImageWithURLs:(nonnull NSArray *)imageURLs placeholder:(nullable UIImage *)placeholder {
    [self.layer removeAnimationForKey:@"contents"];
    WeakSelf;
    return [self bd_setImageWithURLs:imageURLs placeholder:placeholder options:BDImageRequestSetDelaySetImage transformer:nil progress:nil completion:^(BDWebImageRequest *request, UIImage *image, NSData *data, NSError *error, BDWebImageResultFrom from) {
        StrongSelf;
        NSMutableDictionary *imageData = [NSMutableDictionary dictionary];
        imageData[@"image"] = image;
        imageData[@"from"] = @(from);
        
        if([UIDevice btd_is568Screen] || [UIDevice btd_is480Screen] || ([UIDevice btd_is667Screen] && [UIDevice btd_OSVersionNumber] < 13.0)){
            [self performSelector:@selector(setImageWithData:) withObject:imageData afterDelay:0 inModes:@[NSDefaultRunLoopMode]];
        }else{
            [self setImageWithData:imageData];
        }
    }];
}

- (nullable BDWebImageRequest *)fh_setImageWithURLs:(nonnull NSArray *)imageURLs placeholder:(nullable UIImage *)placeholder reSize:(CGSize)reSize{
    [self.layer removeAnimationForKey:@"contents"];
    WeakSelf;
    FHBlockTransformer *transform = [FHBlockTransformer transformWithBlock:^UIImage * _Nullable(UIImage * _Nullable image) {
        StrongSelf;
        return [self compressImage:image toSize:reSize];
    }];
    return [self bd_setImageWithURLs:imageURLs placeholder:placeholder options:BDImageRequestSetDelaySetImage transformer:transform progress:nil completion:^(BDWebImageRequest *request, UIImage *image, NSData *data, NSError *error, BDWebImageResultFrom from) {
        StrongSelf;
        NSMutableDictionary *imageData = [NSMutableDictionary dictionary];
        imageData[@"image"] = image;
        imageData[@"from"] = @(from);
        
        if([UIDevice btd_is568Screen] || [UIDevice btd_is480Screen] || ([UIDevice btd_is667Screen] && [UIDevice btd_OSVersionNumber] < 13.0)){
            [self performSelector:@selector(setImageWithData:) withObject:imageData afterDelay:0 inModes:@[NSDefaultRunLoopMode]];
        }else{
            [self setImageWithData:imageData];
        }
    }];
}

- (nullable BDWebImageRequest *)fh_setImageWithURL:(nonnull NSURL *)imageURL placeholder:(nullable UIImage *)placeholder reSize:(CGSize)reSize {
    [self.layer removeAnimationForKey:@"contents"];
    WeakSelf;
    FHBlockTransformer *transform = [FHBlockTransformer transformWithBlock:^UIImage * _Nullable(UIImage * _Nullable image) {
        StrongSelf;
        return [self compressImage:image toSize:reSize];
    }];
    
    return [self bd_setImageWithURL:imageURL placeholder:placeholder options:BDImageRequestSetDelaySetImage transformer:transform progress:nil completion:^(BDWebImageRequest *request, UIImage *image, NSData *data, NSError *error, BDWebImageResultFrom from) {
        StrongSelf;
        NSMutableDictionary *imageData = [NSMutableDictionary dictionary];
        imageData[@"image"] = image;
        imageData[@"from"] = @(from);
        
        if([UIDevice btd_is568Screen] || [UIDevice btd_is480Screen] || ([UIDevice btd_is667Screen] && [UIDevice btd_OSVersionNumber] < 13.0)){
            [self performSelector:@selector(setImageWithData:) withObject:imageData afterDelay:0 inModes:@[NSDefaultRunLoopMode]];
        }else{
            [self setImageWithData:imageData];
        }
    }];
}

- (void)setImageWithData:(NSDictionary *)imageData {
    UIImage *image = imageData[@"image"];
    BDWebImageResultFrom from = [imageData[@"from"] integerValue];
    
    if(image){
        self.image = image;
    }
    
    if(image && from == BDWebImageResultFromDownloading){
        CATransition *transition = [CATransition animation];
        transition.duration = 0.15;
        transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        transition.type = kCATransitionFade;
        [self.layer addAnimation:transition forKey:@"contents"];
    }
}

- (UIImage*)compressImage:(UIImage*)sourceImage toSize:(CGSize)size {
    //获取原图片的大小尺寸
    CGFloat scale = [UIScreen mainScreen].scale;
    
    CGSize imageSize = sourceImage.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    
    if(width == 0 || height == 0){
        return sourceImage;
    }
    
    //开启图片上下文
    UIGraphicsBeginImageContextWithOptions(size, YES, scale);
    //根据目标图片的宽度计算目标图片的高度
    CGFloat targetWidth = size.width;
    CGFloat targetHeight = size.height;
    CGFloat scaleFactor = 0.0;
    CGFloat widthFactor = size.width / width;
    CGFloat heightFactor = size.height / height;
    
    if(widthFactor > heightFactor){
        scaleFactor = widthFactor;
    }else{
        scaleFactor = heightFactor;
    }
    
    targetWidth = ceilf(width * scaleFactor);
    targetHeight = ceilf(height * scaleFactor);
    
    CGFloat x = 0;
    CGFloat y = 0;
    if(widthFactor <= heightFactor){
        x = ceilf((size.width - targetWidth)/2);
    }else if(targetHeight > size.height){
        y = ceilf((size.height - targetHeight)/2);
    }
    
    //绘制图片
    [sourceImage drawInRect:CGRectMake(x, y, targetWidth, targetHeight)];
    //从上下文中获取绘制好的图片
    UIImage*newImage = UIGraphicsGetImageFromCurrentImageContext();
    //关闭图片上下文
    UIGraphicsEndImageContext();
    
    return newImage;
}

@end
