//
//  SSADSplashDownloadManager.m
//  Article
//
//  Created by Zhang Leonardo on 12-11-19.
//
//

#import "SSADSplashDownloadManager.h"

#import "SSADModel.h"
#import "SSSimpleCache.h"
#import "TTAdMonitorManager.h"
#import <TTBaseLib/NetworkUtilities.h>
#import <TTBaseLib/TTStringHelper.h>
#import <TTImage/TTImageInfosModel.h>
#import <TTNetworkManager/TTNetworkManager.h>

static NSString  *const kImageFailureMointor = @"ad_splashpreload_imagefailure";
static NSString  *const kVideoFailureMointor = @"ad_splashpreload_videofailure";

@interface SSADSplashDownloadManager()
@property (nonatomic, strong) NSMutableDictionary *errors;
@end

@implementation SSADSplashDownloadManager

- (NSMutableDictionary *)errors {
    if (!_errors) {
        _errors = [NSMutableDictionary dictionaryWithCapacity:4];
    }
    return _errors;
}

- (void)fetchADResourceWithModels:(NSArray<SSADModel *> *)models
{
    if ([models count] == 0 || !TTNetworkConnected()) {
        return;
    }
    
    NSUInteger maximumNumberOfDownloadAds = [models count];
    
    /*
     *   开屏逻辑调整
     * 1.检查是否能下载.
     * 2.非wifi最多只预加载一张
     * 3.分时广告资源只在WIFI环境下下载
     *
     */
    
    if (TTNetworkWifiConnected() ||
        SSADModelTypeChannelRefresh == [models.firstObject adModelType]) {
        [models enumerateObjectsUsingBlock:^(SSADModel *adModel, NSUInteger idx, BOOL *stop) {
            // NSLog(@"将要尝试下载第 %@ 组分时图片。。。", @(idx));
            NSArray *intervalCreativeModels = adModel.intervalCreatives;
//            [self downloadImagesWithADModels:intervalCreativeModels
//                           limitedImageCount:[intervalCreativeModels count]];
            [self attemptToDownloadADResourceWithADModels:intervalCreativeModels
                                             limitedCount:intervalCreativeModels.count];
        }];
    } else {
        if ([TTDeviceHelper isPadDevice]) {
            maximumNumberOfDownloadAds = MIN(2, [models count]);
        } else {
            maximumNumberOfDownloadAds = MIN(1, [models count]);
        }
    }
    // NSLog(@"将要尝试下载默认图片。。。");
    
    // 下载默认广告图片
//    [self downloadImagesWithADModels:models
//                   limitedImageCount:maximumNumberOfDownloadAds];
    [self attemptToDownloadADResourceWithADModels:models
                                     limitedCount:maximumNumberOfDownloadAds];
}

#pragma mark -- private

- (void)attemptToDownloadADResourceWithADModels:(NSArray *)adModels limitedCount:(NSUInteger)limitedCount
{
    if (adModels.count == 0 || limitedCount == 0) {
        return;
    }
    
    NSUInteger processedCount = 0;
    for (SSADModel *model in adModels) {
        
        BOOL isVideo = (SSSplashADTypeVideoFullscreen == model.splashADType ||
                        SSSplashADTypeVideoCenterFit_16_9 == model.splashADType);
        
        if (TTNetworkWifiConnected() && isVideo) {
            // 全屏视频不需要下载底图
            BOOL downloadVideoONLY = (SSSplashADTypeVideoFullscreen == model.splashADType);
            
            if ([self downloadVideoWithADModelIfNeeded:model] && downloadVideoONLY) {
                processedCount ++;
            }
            
            if (downloadVideoONLY) {
                continue;
            }
        }
        
        if ([self downloadImageWithADModelIfNeeded:model]) {
            processedCount ++;
        }
        
        if (processedCount >= limitedCount) {
            return;
        }
    }
}

/// 下载图片，若需要下载，返回YES。
- (BOOL)downloadImageWithADModelIfNeeded:(SSADModel *)model
{
    
    TTImageInfosModel *imageModel = [[TTImageInfosModel alloc] initWithDictionary:model.imageInfo];
    
    TTImageInfosModel *landscapeImageModel = [[TTImageInfosModel alloc] initWithDictionary:model.landscapeImageInfo];

    NSString *splashURLString = model.splashURLString;
    
    if (SSADModelTypeChannelRefresh != model.adModelType) {
        // 开屏广告逻辑：predownload 是可以下载的网络类型，TTNetworkFlags是目前的网络类型，如果两个有交集，则下载
        if ((splashURLString.length == 0 && !imageModel) || !(TTNetworkGetFlags() & model.predownload.integerValue)) {
            
            return NO;
        }
    }
    
    if ([TTDeviceHelper isPadDevice]) {
        
        //如果横竖屏图的model 不完整 就不去下载该广告的图
        if (!imageModel || !landscapeImageModel) {
            return NO;
        }
        //检查缓存1 如何横竖屏都下载了 认为下载完整 不需要去下载
        if ([[SSSimpleCache sharedCache] isImageInfosModelCacheExist:imageModel] && [[SSSimpleCache sharedCache] isImageInfosModelCacheExist:landscapeImageModel]) {
            return NO;
        }
        
        BOOL landscapeIsMissing = NO;
        BOOL portraitIsMissing = NO;

        if (![[SSSimpleCache sharedCache] isImageInfosModelCacheExist:imageModel]) {
            portraitIsMissing = YES;
        }
        if (![[SSSimpleCache sharedCache] isImageInfosModelCacheExist:landscapeImageModel]) {
            landscapeIsMissing = YES;
        }

        if (portraitIsMissing) {
            if (imageModel) {
                
                [self startDownloadImageWithImageInfoModel:imageModel index:0];
                
            } else {
                
                [[TTNetworkManager shareInstance] requestForBinaryWithURL:splashURLString params:nil method:@"GET" needCommonParams:NO callback:^(NSError *error, id obj) {
                    if (error) {
                        return;
                    }
                    
                    if (obj && [obj isKindOfClass:[NSData class]]) {
                        [[SSSimpleCache sharedCache] setData:obj forKey:splashURLString];
                    }
                }];
            }

        }
        if (landscapeIsMissing) {
            
            if (landscapeImageModel) {
                [self startDownloadImageWithImageInfoModel:landscapeImageModel index:0];
            }
        }
        
    } else {
        // 检查是否下载过
        if (imageModel && [[SSSimpleCache sharedCache] isImageInfosModelCacheExist:imageModel]) {
            
            return NO;
            
        } else {
            NSURL *url = [TTStringHelper URLWithURLString:splashURLString];
            if ([[SSSimpleCache sharedCache] isCacheExist:url.absoluteString]) {
                return NO;
            }
        }
      
        if (imageModel) {
            [self startDownloadImageWithImageInfoModel:imageModel index:0];
        } else {
            
            [[TTNetworkManager shareInstance] requestForBinaryWithURL:splashURLString params:nil method:@"GET" needCommonParams:NO callback:^(NSError *error, id obj) {
                if (error) {
                    return;
                }
                
                if (obj && [obj isKindOfClass:[NSData class]]) {
                    [[SSSimpleCache sharedCache] setData:obj forKey:splashURLString];
                }
            }];
        }
    }
    
    return YES;
}

/// 下载视频，若需要下载，返回YES。
- (BOOL)downloadVideoWithADModelIfNeeded:(SSADModel *)model
{
    if (model.videoURLArray.count == 0 || [SSSimpleCache isVideoCacheExistWithVideoId:model.videoId]) {
        return NO;
    }
    
    [self startDownloadVideoWithADModel:model index:0];
    
    return YES;
}

- (void)startDownloadVideoWithADModel:(SSADModel *)adModel index:(NSUInteger)index
{
    NSString *urlString;
    if (index < adModel.videoURLArray.count) {
        urlString = [TTStringHelper decodeStringFromBase64Str:adModel.videoURLArray[index]];
    }

    if (isEmptyString(urlString)) {
        [self monitor4Video:adModel];
        return;
    }
    __block NSUInteger _index = index;
    [[TTNetworkManager shareInstance] requestForBinaryWithURL:urlString params:nil method:@"GET" needCommonParams:NO callback:^(NSError *error, id obj) {
        if (error) {
            [self.errors setValue:error.localizedDescription forKey:urlString];
            [self startDownloadVideoWithADModel:adModel index:++_index];
            return;
        }
        
        if (obj && [obj isKindOfClass:[NSData class]]) {
            [[SSSimpleCache sharedCache] setData:(NSData *)obj forVideoId:adModel.videoId];
            [self markSuccessWithService:kVideoFailureMointor];
        }
    }];
}

- (void)startDownloadImageWithImageInfoModel:(TTImageInfosModel *)imageInfoModel index:(NSUInteger)index
{
    NSString *urlString = [imageInfoModel urlStringAtIndex:index];
    if (isEmptyString(urlString)) {
        [self monitor4Image:imageInfoModel];
        return;
    }
    
    __block NSUInteger _index = index;
    [[TTNetworkManager shareInstance] requestForBinaryWithURL:urlString params:nil method:@"GET" needCommonParams:NO callback:^(NSError *error, id obj) {
        if (error) {
            [self.errors setValue:error.localizedDescription forKey:urlString];
            [self startDownloadImageWithImageInfoModel:imageInfoModel index:++_index];
            return;
        }
        
        if (obj && [obj isKindOfClass:[NSData class]]) {
            [[SSSimpleCache sharedCache] setData:(NSData *)obj forImageInfosModel:imageInfoModel];
            [self markSuccessWithService:kImageFailureMointor];
        }
    }];
}

- (void)markSuccessWithService:(NSString *)service {
    NSParameterAssert(service != nil);
    
    [TTAdMonitorManager trackService:service status:0 extra:nil];
}

- (void)monitor4Image:(TTImageInfosModel *) model {
    NSMutableDictionary *extra = [NSMutableDictionary dictionaryWithCapacity:3];
    NSInteger index = 0;
    NSString *urlString = [model urlStringAtIndex:index];
    for (; urlString != nil && index < 3; index ++) {
        [extra setValue:self.errors[urlString] forKey:[NSString stringWithFormat:@"error%@", @(index)]];
        [extra setValue:urlString forKey:[NSString stringWithFormat:@"url%@", @(index)]];
        [self.errors removeObjectForKey:urlString];
        urlString = [model urlStringAtIndex:index];
    }
    [extra setValue:@"ad_splash" forKey:@"source"];
    [TTAdMonitorManager trackService:kImageFailureMointor status:1 extra:extra];
}

- (void)monitor4Video:(SSADModel *)model {
    NSMutableDictionary *extra = [NSMutableDictionary dictionaryWithCapacity:2];
    [extra setValue:model.splashID forKey:@"ad_id"];
    [extra setValue:model.videoId forKey:@"video_id"];
    NSString *urlString;
    NSInteger index = 0;
    for (index = 0; index < model.videoURLArray.count; index ++) {
        urlString = model.videoURLArray[index];
        urlString = [TTStringHelper decodeStringFromBase64Str:model.videoURLArray[index]];
        [extra setValue:self.errors[urlString] forKey:[NSString stringWithFormat:@"error%@", @(index)]];
        [extra setValue:urlString forKey:[NSString stringWithFormat:@"url%@", @(index)]];
        if (urlString) {
            [self.errors removeObjectForKey:urlString];
        }
    }
    [extra setValue:@"ad_splash" forKey:@"source"];
    [TTAdMonitorManager trackService:kVideoFailureMointor status:1 extra:extra];
}

@end
