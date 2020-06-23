//
//  UIImageView+fhUgcImage.m
//  AKCommentPlugin
//
//  Created by 谢思铭 on 2020/6/22.
//

#import "UIImageView+fhUgcImage.h"

@implementation UIImageView (fhUgcImage)

- (nullable BDWebImageRequest *)fh_setImageWithURL:(nonnull NSURL *)imageURL placeholder:(nullable UIImage *)placeholder {
    [self.layer removeAnimationForKey:@"contents"];
    return [self bd_setImageWithURL:imageURL placeholder:placeholder options:BDImageRequestSetDelaySetImage completion:^(BDWebImageRequest *request, UIImage *image, NSData *data, NSError *error, BDWebImageResultFrom from) {
        
        NSMutableDictionary *imageData = [NSMutableDictionary dictionary];
        imageData[@"image"] = image;
        imageData[@"from"] = @(from);

        [self performSelector:@selector(setImageWithData:) withObject:imageData afterDelay:0 inModes:@[NSDefaultRunLoopMode]];
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

@end
