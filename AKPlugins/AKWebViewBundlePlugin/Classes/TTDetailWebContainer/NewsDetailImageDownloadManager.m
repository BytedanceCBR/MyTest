//
//  NewsDetailImageDownloadManager.m
//  Article
//
//  Created by Zhang Leonardo on 13-5-17.
//
//

#import "NewsDetailImageDownloadManager.h"
#import "TTDetailWebViewContainerConfig.h"

#import <TTImage/TTWebImageManager.h>
#import <TTImage/TTImageDownloader.h>
#import <TTBaseLib/NSDictionary+TTAdditions.h>
#import <SDWebImage/UIImage+MultiFormat.h>
#import <SDwebImage/SDImageCache.h>

#define kUserInfoModelKey @"kUserInfoModelKey"


@interface NewsDetailImageDownloadManager()
{
    NSInteger _downloadingCount;
}
@property (nonatomic, assign) NSUInteger maxConcurrentDownloads;
@property (nonatomic, retain) NSMutableArray * prefetchModels;
@end

@implementation NewsDetailImageDownloadManager

static NewsDetailImageDownloadManager *s_manager = nil;
+ (id)sharedManager
{
    @synchronized(self)
    {
        if(!s_manager)
        {
            s_manager = [[NewsDetailImageDownloadManager alloc] init];
        }
        return s_manager;
    }
}

- (void)dealloc
{
    self.delegate = nil;
}


- (id)init
{
    self = [super init];
    if (self) {
        _maxConcurrentDownloads = 3;
        self.prefetchModels = [NSMutableArray arrayWithCapacity:10];
        _downloadingCount = 0;
    }
    return self;
}

- (void)startPrefetchingModel:(TTImageInfosModel *)model
{
    if (model) {
        TTImageInfosModel *webpModel = [self transformToWebPImageModelIfNeed:model];
        [[TTImageDownloader sharedInstance] downloadWithImageModel:webpModel options:TTWebImageDownloaderHighPriority progress:nil completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, BOOL finished, NSString * _Nullable url) {
            if ([NSData sd_imageFormatForImageData:data] == SDImageFormatWebP) {
                [[SDImageCache sharedImageCache] storeImageDataToDisk:[image sd_imageDataAsFormat:SDImageFormatPNG] forKey:[url componentsSeparatedByString:@".webp"][0]];
                [[SDImageCache sharedImageCache] removeImageForKey:url fromDisk:YES withCompletion:nil];
            }
            if ([data length] > 0 && !isEmptyString(url)) {
                        _downloadingCount --;
                        _downloadingCount = MAX(0, _downloadingCount);
                        [self notifyFinish:model success:YES];
                        [self notifyStart];
            }
            else {
                _downloadingCount --;
                _downloadingCount = MAX(0, _downloadingCount);
                [self notifyFinish:model success:NO];
                [self notifyStart];
            }
        }];
    }
}

- (void)fetchImageWithModels:(NSArray *)models insertTop:(BOOL)insert
{
    if ([models count] == 0) {
        return;
    }
    
    if (insert) {
        [_prefetchModels removeObjectsInArray:models];
        [_prefetchModels insertObjects:models atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, [models count])]];
    }
    else {
        [_prefetchModels removeObjectsInArray:models];
        [_prefetchModels addObjectsFromArray:models];
    }
    
    NSInteger notifyCount = _maxConcurrentDownloads - _downloadingCount;
    if (notifyCount > 0) {
        for (int i = 0; i < notifyCount; i ++) {
            [self notifyStart];
        }
    }
}

- (void)fetchImageWithModel:(TTImageInfosModel *)model insertTop:(BOOL)insert
{
    if (!model) {
        return;
    }
    if (insert) {
        if (![_prefetchModels containsObject:model]) {
            [_prefetchModels insertObject:model atIndex:0];
        }
    }
    else {
        if (![_prefetchModels containsObject:model]) {
            [_prefetchModels addObject:model];
        }
    }
    
    NSInteger notifyCount = _maxConcurrentDownloads - _downloadingCount;
    if (notifyCount > 0) {
        for (int i = 0; i < notifyCount; i ++) {
            [self notifyStart];
        }
    }
}

- (void)notifyStart
{
    if (![NSThread isMainThread]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self notifyStart];
        });
        return;
    }
    if ([_prefetchModels count] == 0) {
        return;
    }
    if (_downloadingCount >= _maxConcurrentDownloads) {
        return;
    }
    _downloadingCount ++;
    TTImageInfosModel * model = [_prefetchModels firstObject];
    [_prefetchModels removeObject:model];
    [self startPrefetchingModel:model];
}

- (void)notifyFinish:(TTImageInfosModel *)model success:(BOOL)success
{
    if (_delegate && [_delegate respondsToSelector:@selector(detailImageDownloadManager:finishDownloadImageMode:success:)]) {
        [_delegate detailImageDownloadManager:self finishDownloadImageMode:model success:success];
    }
}

- (void)cancelPrefetching
{
    
    [_prefetchModels removeAllObjects];
    _downloadingCount = 0;
}

- (void)cancelDownloadForImageModel:(TTImageInfosModel*)imageModel
{
    if ([_prefetchModels containsObject:imageModel]) {
        [_prefetchModels removeObject:imageModel];
    }
}

- (void)cancelAll
{
    [self cancelPrefetching];
}

- (TTImageInfosModel *)transformToWebPImageModelIfNeed:(TTImageInfosModel *)imageModel {
    if (![TTDetailWebViewContainerConfig enabledWebPImage]) {
        return imageModel;
    }
    
    if ([imageModel.URI hasSuffix:@".webp"]) {
        return imageModel;
    }
    
    TTImageInfosModel *webpModel = [[TTImageInfosModel alloc] init];
    webpModel.URI = [imageModel.URI stringByAppendingPathExtension:@"webp"];
    webpModel.height = imageModel.height;
    webpModel.width = imageModel.width;
    webpModel.userInfo = imageModel.userInfo;
    webpModel.imageType = imageModel.imageType;
    webpModel.imageFileType = imageModel.imageFileType;
    
    NSMutableArray *webpURLs = [[NSMutableArray alloc] initWithCapacity:imageModel.urlWithHeader.count];
    
    for (NSDictionary *urlDic in imageModel.urlWithHeader) {
        NSString *urlStr = [urlDic tt_stringValueForKey:@"url"];
        if ([urlStr.lastPathComponent rangeOfString:@"."].location != NSNotFound) {
            return imageModel;
        }
        [webpURLs addObject:@{@"url": [urlStr stringByAppendingString:@".webp"]}];
    }
    webpModel.urlWithHeader = [webpURLs copy];

    return webpModel;
}
@end
