//
//  UIImageView+SimpleWebImage.m
//  Article
//
//  Created by xushuangqing on 2017/6/21.
//
//

#import "UIImageView+SimpleWebImage.h"
#import <objc/runtime.h>

@implementation UIImageView (SimpleWebImage)

#pragma mark - NSCache

+ (NSCache *)sharedCache {
    static NSCache *cache = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        cache = [[NSCache alloc] init];
    });
    return cache;
}

#pragma mark - accessors

- (NSURLSessionDataTask *)currentDataTask {
    return (NSURLSessionDataTask *)objc_getAssociatedObject(self, &(@selector(currentDataTask)));
}

- (void)setCurrentDataTask:(NSURLSessionDataTask *)task {
    objc_setAssociatedObject(self, &(@selector(currentDataTask)), task, OBJC_ASSOCIATION_RETAIN);
}

#pragma mark - image

- (void)simple_setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholderImage completed:(void (^)(UIImage *image, BOOL cached, NSURLResponse *response, NSError * error))completed {
    
    [[self currentDataTask] cancel];
    
    BOOL cached = NO;
    id cachedObj = [[[self class] sharedCache] objectForKey:[url absoluteString]];
    if (cachedObj && [cachedObj isKindOfClass:[UIImage class]]) {
        cached = YES;
        self.image = cachedObj;
        if (completed) {
            completed(cachedObj, cached, nil, nil);
        }
        return;
    }
    
    [self setImage:placeholderImage];
    
    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            UIImage *image = nil;
            if (!error) {
                image = [UIImage imageWithData:data];
                if (image) {
                    self.image = image;
                    [[[self class] sharedCache] setObject:image forKey:[url absoluteString]];
                }
            }
            if (completed) {
                completed(image, cached, response, error);
            }
        });
    }];
    [self setCurrentDataTask:task];
    [task resume];
}

@end
