//
//  YYImageDecoder+HEIF.m
//  Article
//
//  Created by fengyadong on 2017/11/2.
//  Copyright © 2017年 DreamPiggy. All rights reserved.
//

#import "YYImageDecoder+HEIF.h"
#import "TTWebImageHEIFCoder.h"
#import <objc/runtime.h>
#import <RSSwizzle/RSSwizzle.h>

@implementation YYImageFrame (HEIF)

- (BOOL)isHEIFImage
{
    NSNumber *value = objc_getAssociatedObject(self, @selector(isHEIFImage));
    return value.boolValue;
}

- (void)setIsHEIFImage:(BOOL)isHEIFImage
{
    objc_setAssociatedObject(self, @selector(isHEIFImage), @(isHEIFImage), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end

@implementation YYImageDecoder (HEIF)

+ (void)load
{
    Class instanceClass = [self class];
    RSSwizzleClassMethod(
                         instanceClass,
                         @selector(decoderWithData:scale:),
                         RSSWReturnType(YYImageDecoder *),
                         RSSWArguments(NSData *data, CGFloat scale),
                         RSSWReplacement({
                                         if ([[TTWebImageHEIFCoder sharedCoder] supportCustomHeifDecoderForData:data]) {
                                             UIImage *heifImage = [[TTWebImageHEIFCoder sharedCoder] decodedImageWithData:data];
                                             if (!heifImage) {
                                                 return nil;
                                             }
                                             YYImageDecoder *decoder = [[YYImageDecoder alloc] initWithScale:scale];
                                             Class _YYImageDecoderFrameClass = NSClassFromString(@"_YYImageDecoderFrame");
                                             YYImageFrame *frame = [_YYImageDecoderFrameClass frameWithImage:heifImage];
                                             frame.isHEIFImage = YES;
                                             [decoder setValue:@[frame] forKey:@"_frames"];
                                             return decoder;
                                         } else {
                                             return RSSWCallOriginal(data,scale);
                                         }
        
    }));
    
    RSSwizzleInstanceMethod(instanceClass, @selector(frameAtIndex:decodeForDisplay:), RSSWReturnType(YYImageFrame *), RSSWArguments(NSUInteger index, BOOL decodeForDisplay),RSSWReplacement({
        YYImageFrame *frame;
        NSArray *array = (NSArray *)[self valueForKey:@"_frames"];
        if (array.count > 0) {
            frame = array.firstObject;
            if (frame.isHEIFImage) {
                return frame;
            }
        }
        return RSSWCallOriginal(index,decodeForDisplay);
    }), RSSwizzleModeAlways, NULL);
}

@end
