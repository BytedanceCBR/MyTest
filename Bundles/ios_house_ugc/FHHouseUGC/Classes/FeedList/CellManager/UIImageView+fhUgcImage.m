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

@implementation UIImageView (fhUgcImage)

- (nullable BDWebImageRequest *)fh_setImageWithURL:(nonnull NSURL *)imageURL placeholder:(nullable UIImage *)placeholder {
    [self.layer removeAnimationForKey:@"contents"];
    return [self bd_setImageWithURL:imageURL placeholder:placeholder options:BDImageRequestSetDelaySetImage completion:^(BDWebImageRequest *request, UIImage *image, NSData *data, NSError *error, BDWebImageResultFrom from) {
        
        NSMutableDictionary *imageData = [NSMutableDictionary dictionary];
        imageData[@"image"] = image;
        imageData[@"from"] = @(from);
        
        if([TTDeviceHelper is568Screen] || [TTDeviceHelper is480Screen] || ([TTDeviceHelper is667Screen] && [TTDeviceHelper OSVersionNumber] < 13.0)){
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
        transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
        transition.type = kCATransitionFade;
        [self.layer addAnimation:transition forKey:@"contents"];
    }
}

- (void)fh_setImageWithURLStringInTrafficSaveMode:(NSString *)URLString placeholder:(UIImage *)placeholder
{
    if ([ExploreCellHelper shouldDownloadImage]) {
        [self fh_setImageWithURL:URLString placeholder:placeholder];
    } else {
        [self setImageFromCacheWithURLString:URLString atIndex:0 placeholder:placeholder];
    }
}

- (void)setImageFromCacheWithURLString:(NSString *)URLString atIndex:(int)index placeholder:(UIImage *)placeholder
{
    NSString *url = URLString;
    
    [[SDWebImageAdapter sharedAdapter] diskImageExistsWithKey:url completion:^(BOOL isInCache) {
        if (isInCache) {
            [self fh_setImageWithURL:URLString placeholder:placeholder];
        } else {
            [self setImageFromCacheWithURLString:URLString atIndex:(index + 1) placeholder:placeholder];
        }
    }];
}

@end
