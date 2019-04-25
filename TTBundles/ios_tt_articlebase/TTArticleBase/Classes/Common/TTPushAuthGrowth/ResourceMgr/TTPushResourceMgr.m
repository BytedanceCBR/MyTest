//
//  TTPushResourceMgr.m
//  Article
//
//  Created by liuzuopeng on 11/07/2017.
//
//

#import "TTPushResourceMgr.h"
//#import <SDWebImageDownloader.h>
#import <BDWebImage/SDWebImageAdapter.h>
//#import <SDWebImageManager.h>
#import <BDWebImage/SDWebImageAdapter.h>


@implementation TTPushResourceMgr

+ (void)prefetchImageWithURLStrings:(NSArray<NSString *> *)imageURLStrings
                         completion:(void (^)(BOOL fullCompleted))completedHandler
{
    [self.class downloadImageWithURLStrings:imageURLStrings completion:^(NSDictionary<NSString *,NSNumber *> *flagsMapper, NSDictionary<NSString *,UIImage *> *imagesMapper) {
        if (completedHandler) {
            completedHandler([imagesMapper count] == [imageURLStrings count]);
        }
    }];
}

+ (void)downloadImageWithURLStrings:(NSArray<NSString *> *)imageURLStrings
                         completion:(void (^)(NSDictionary<NSString *, NSNumber *> *flagsMapper /** url是否下载成功 */,
                                              NSDictionary<NSString *, UIImage *> *imagesMapper /** url下载成功对应的image*/))completedHandler
{
    NSMutableArray<NSURL *> *imageURLs = [NSMutableArray arrayWithCapacity:[imageURLStrings count]];
    [imageURLStrings enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSURL *imageURL = [self.class _validImageURLForString:obj];
        if (imageURL) {
            [imageURLs addObject:imageURL];
        }
    }];
    
    [[SDWebImageAdapter sharedAdapter] prefetchURLs:imageURLs progress:nil completed:^(NSUInteger noOfFinishedUrls, NSUInteger noOfSkippedUrls) {
        
        NSMutableDictionary *downloadFlagMapper  = [NSMutableDictionary dictionaryWithCapacity:5];
        NSMutableDictionary *successImageMapper = [NSMutableDictionary dictionaryWithCapacity:5];
        
        [imageURLStrings enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            UIImage *cachedImage = [self.class cachedImageForURLString:obj];
            if (cachedImage) {
                [downloadFlagMapper setValue:@(YES) forKey:obj];
                [successImageMapper setValue:cachedImage forKey:obj];
            } else {
                [downloadFlagMapper setValue:@(NO) forKey:obj];
            }
        }];
        
        if (completedHandler) {
            completedHandler(downloadFlagMapper, successImageMapper);
        }
    }];
}

+ (void)downloadImageWithURLString:(NSString *)imageURLString
                        completion:(void (^)(UIImage *image, BOOL success))completedHandler;
{
    NSURL *imageURL = [self.class _validImageURLForString:imageURLString];
    if (!imageURL) {
        if (completedHandler) {
            completedHandler(nil, NO);
        }
        return;
    }
    
    UIImage *cachedImage = [self.class cachedImageForURLString:imageURLString];
    if (cachedImage) {
        if (completedHandler) {
            completedHandler(cachedImage, YES);
        }
        return;
    }
    
    [self.class downloadImageWithURL:imageURL completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSURL * _Nullable imageURL, NSError * _Nullable error) {
        if (completedHandler) {
            completedHandler(image, (image && !error ? YES : NO));
        }
    }];
}

+ (UIImage *)cachedImageForURLString:(NSString *)imageURLString
{
    NSURL *imageURL = [self.class _validImageURLForString:imageURLString];
    if (!imageURL) return nil;
    
    NSString *imageURLKey = [[SDWebImageAdapter sharedAdapter] cacheKeyForURL:imageURL];
    UIImage *image = [[SDWebImageAdapter sharedAdapter] imageFromCacheForKey:imageURLKey];
    
    if (!image) {
        [self.class downloadImageWithURL:imageURL completed:nil];
    }
    return image;
}

+ (BOOL)cachedImageExistsForURLString:(NSString *)imageURLString
{
    NSURL *imageURL = [self.class _validImageURLForString:imageURLString];
    if (!imageURL) return YES;
    
    NSString *imageURLKey = [[SDWebImageAdapter sharedAdapter] cacheKeyForURL:imageURL];
    
    return [[SDWebImageAdapter sharedAdapter] imageFromCacheForKey:imageURLKey];
}

#pragma mark - helper

+ (void)downloadImageWithURL:(NSURL *)imageURL completed:(void (^)(UIImage * _Nullable image, NSData * _Nullable data, NSURL * _Nullable imageURL, NSError * _Nullable error))completedHandler
{
    [[SDWebImageAdapter sharedAdapter] loadImageWithURL:imageURL options:0 progress:nil completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, SDImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL) {
        if (completedHandler) {
            completedHandler(image, data, imageURL, error);
        }
    }];
}

+ (NSURL *)_validImageURLForString:(NSString *)imageURLString
{
    if ([imageURLString isKindOfClass:[NSString class]]) {
        return [NSURL URLWithString:imageURLString];
    } else if ([imageURLString isKindOfClass:[NSURL class]]) {
        return (NSURL *)imageURLString;
    }
    return nil;
}

@end
