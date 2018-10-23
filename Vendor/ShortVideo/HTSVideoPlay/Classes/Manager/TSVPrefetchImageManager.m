//
//  TSVPrefetchImageManager.m
//  HTSVideoPlay
//
//  Created by 邱鑫玥 on 2017/12/20.
//

#import "TSVPrefetchImageManager.h"
#import "AWEVideoDetailFirstFrameConfig.h"
#import "TTShortVideoModel.h"
#import "SDWebImagePrefetcher.h"

@implementation TSVPrefetchImageManager

+ (void)prefetchDetailImageWithDataFetchManager:(id<TSVShortVideoDataFetchManagerProtocol>)dataFetchManager forward:(BOOL)isForward
{
    NSInteger prefetchImageCount = 5;
    if ([AWEVideoDetailFirstFrameConfig firstFrameEnabled]) {
        NSInteger currentIndex = dataFetchManager.currentIndex;
        NSMutableArray *prefetchImageURLs = [NSMutableArray array];
        if (isForward) {
            for (NSInteger i = currentIndex; i < MIN([dataFetchManager numberOfShortVideoItems], currentIndex + prefetchImageCount); i++) {
                NSURL *url = [self prefetchImageURLWithDataFetchManager:dataFetchManager index:i];
                if (url) {
                    [prefetchImageURLs addObject:url];
                }
            }
            
            if (currentIndex > 0) {
                NSURL *url = [self prefetchImageURLWithDataFetchManager:dataFetchManager index:currentIndex - 1];
                if (url) {
                    [prefetchImageURLs addObject:url];
                }
            }
        } else {
            for (NSInteger i = currentIndex; i >= MAX(0, currentIndex - prefetchImageCount + 1); i--) {
                NSURL *url = [self prefetchImageURLWithDataFetchManager:dataFetchManager index:i];
                if (url) {
                    [prefetchImageURLs addObject:url];
                }
            }
            
            if (currentIndex < [dataFetchManager numberOfShortVideoItems] - 1) {
                NSURL *url = [self prefetchImageURLWithDataFetchManager:dataFetchManager index:currentIndex + 1];
                if (url) {
                    [prefetchImageURLs addObject:url];
                }
            }
        }
        [[SDWebImagePrefetcher sharedImagePrefetcher] prefetchURLs:prefetchImageURLs];
    }
}

+ (NSURL *)prefetchImageURLWithDataFetchManager:(id<TSVShortVideoDataFetchManagerProtocol>)dataFetchManager index:(NSInteger)index
{
    NSURL *url;
    
    if (index < [dataFetchManager numberOfShortVideoItems]) {
        TTShortVideoModel *model = [dataFetchManager itemAtIndex:index];
        if (model) {
            NSString *imageUrl = [model.firstFrameImageModel.urlWithHeader firstObject][@"url"];
            if (imageUrl) {
                url = [NSURL URLWithString:imageUrl];
            }
        }
    }
    return url;
}

@end
