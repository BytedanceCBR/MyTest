//
//  WDUploadImageManager.m
//  Article
//
//  Created by 王霖 on 15/12/30.
//
//

#import "WDUploadImageManager.h"
#import "WDImageHelper.h"
#import "WDUploadImageModelProtocol.h"
#import "WDPublisherAdapterSetting.h"
#import <TTNetworkManager/TTNetworkManager.h>
#import <TTBaseLib/TTSandBoxHelper.h>
#import <TTBaseLib/NetworkUtilities.h>
#import <TTBaseLib/TTBaseMacro.h>
#import "UIImage+WDUploadIdentify.h"
#import "HMDTTMonitor.h"

#ifndef dispatch_main_async_safe
#define dispatch_main_async_safe(block)\
if (strcmp(dispatch_queue_get_label(DISPATCH_CURRENT_QUEUE_LABEL), dispatch_queue_get_label(dispatch_get_main_queue())) == 0) {\
    block();\
} else {\
    dispatch_async(dispatch_get_main_queue(), block);\
}
#endif


static NSUInteger const kSingleImageMaxImageRetryTime = 2;
static NSUInteger const kAllImageMaxImageRetryTime = 10;

@interface WDUploadImageManager ()

@property (nonatomic, strong) NSMutableArray<id<WDUploadImageModelProtocol>> *uploadQueueList;
@property (nonatomic, strong) NSMutableArray<id<WDUploadImageModelProtocol>> *failedModelList;

@property (nonatomic, strong) NSMutableDictionary *memoryCache;
@property (nonatomic, strong) NSMutableDictionary *uploadFailedTimeRecoder;
@property (nonatomic, assign) NSInteger retryTimes;

@property (nonatomic, assign) BOOL sandboxCompressImgMiss;
@property (nonatomic, assign) BOOL isCancel;

@property(nonatomic, strong) dispatch_queue_t serialQueue;

@end

@implementation WDUploadImageManager

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)init
{
    if (self = [super init]) {
        _uploadFailedTimeRecoder = @{}.mutableCopy;
        _uploadQueueList = @[].mutableCopy;
        _failedModelList = @[].mutableCopy;
        _memoryCache = @{}.mutableCopy;
        
        self.serialQueue = dispatch_queue_create("com.ss.ios.queue.uploadImage", DISPATCH_QUEUE_SERIAL);

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(connectionChanged:) name:@"kNetworkReachabilityChangedNotification" object:nil];
    }
    return self;
}

#pragma mark - UploadQueue

- (void)addUploadModelToQueue:(id<WDUploadImageModelProtocol>)imageModel
{
    switch (imageModel.sourceType) {
        case WDUploadImageSourceTypePath: {
            NSString *uniqueUri = imageModel.thirdImgUri ?: [imageModel.compressImgUri lastPathComponent];
            if (![self.uploadQueueList containsObject:imageModel] && isEmptyString(imageModel.remoteImgUri) && [self isImageNeedRetryUpload:uniqueUri]) {
                [self.uploadQueueList addObject:imageModel];
            }
        }
            break;
        case WDUploadImageSourceTypeImage: {
            if (![self.uploadQueueList containsObject:imageModel] && isEmptyString(imageModel.remoteImgUri)) {
                [self.uploadQueueList addObject:imageModel];
            }
        }
        default: {
            //必须指定sourceType，否则啥也不干
        }
            break;
    }
}

- (void)addUploadModelToFailedList:(id<WDUploadImageModelProtocol>)imageModel
{
    if (![self.failedModelList containsObject:imageModel]) {
        [self.failedModelList addObject:imageModel];
    }
}

- (id<WDUploadImageModelProtocol>)nextUploadModel
{
    return [self.uploadQueueList firstObject];
}

#pragma mark - Public Methods

- (void)uploadImages:(NSArray <id<WDUploadImageModelProtocol>>*)imageModels
{
    self.isCancel = NO;
    
    for (id<WDUploadImageModelProtocol> imageModel in imageModels) {
        [self addUploadModelToQueue:imageModel];
    }
    
    [self uploadNextImage];
}

#pragma mark - UploadMethods

- (void)uploadNextImage
{
    id<WDUploadImageModelProtocol> nextModel = [self nextUploadModel];
    if (!nextModel) {
        dispatch_main_async_safe(^{
            if ([self.delegate respondsToSelector:@selector(uploadManagerTaskHasFinished:failedImageModels:)]) {
                [self.delegate uploadManagerTaskHasFinished:self failedImageModels:[self.failedModelList copy]];
            }
        });
        
        return;
    }
    
    if ([self uriForImageModel:nextModel]) {
        nextModel.remoteImgUri = [self uriForImageModel:nextModel];
        [self.uploadQueueList removeObject:nextModel];
        dispatch_main_async_safe(^{
            if ([self.delegate respondsToSelector:@selector(uploadManager:finishUploadImage:)]) {
                [self.delegate uploadManager:self finishUploadImage:nextModel];
            }
        });
        
        dispatch_async(self.serialQueue, ^{
            [self uploadNextImage];
        });
        
        return;
    }
    
    dispatch_async(self.serialQueue, ^{
        NSData *imageData = [self webpDataForCompressUri:nextModel];
        if (imageData) {
            [WDUploadImageManager executeUpload:imageData
                                 extraParameter:nil
                                    finishBlock:^(NSError *resultError, NSString *webURI) {
                                        //判断当前的上传任务是否被取消
                                        if (!self.isCancel) {
                                            [self.uploadQueueList removeObject:nextModel];

                                            if (resultError == nil) {
                                                nextModel.remoteImgUri = webURI;
                                                [self saveUri:webURI forImageModel:nextModel];
                                                dispatch_main_async_safe(^{
                                                    if ([self.delegate respondsToSelector:@selector(uploadManager:finishUploadImage:)]) {
                                                        [self.delegate uploadManager:self finishUploadImage:nextModel];
                                                    }
                                                });
                                            } else {
                                                self.retryTimes++;
                                                [self addUploadModelToFailedList:nextModel];
                                                
                                                dispatch_main_async_safe(^{
                                                    if ([self.delegate respondsToSelector:@selector(uploadManager:failedUploadImage:error:)]) {
                                                        [self.delegate uploadManager:self failedUploadImage:nextModel error:resultError];
                                                    }
                                                });
                                            }
                                        } else {
                                            [self.uploadQueueList removeAllObjects];
                                        }
                                        
                                        dispatch_async(self.serialQueue, ^{
                                            [self uploadNextImage];
                                        });
                                    }];
        } else {
            //沙盒中压缩文件丢失
            self.sandboxCompressImgMiss = YES;
            [self addUploadModelToFailedList:nextModel];
            
            [self uploadNextImage];
        }
    });
}

#pragma mark - 实际的Upload接口

+ (void)uploadImage:(id<WDUploadImageModelProtocol>)imageModel
        finishBlock:(void(^)(NSError *error, BOOL sandboxCompressImgMiss))finishBlock
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSData *imageData = [self webpDataForCompressUri:imageModel];
        if (imageData) {
            [WDUploadImageManager executeUpload:imageData
                                 extraParameter:nil
                                    finishBlock:^(NSError *resultError, NSString *webURI) {
                                        if (resultError == nil) {
                                            imageModel.remoteImgUri = webURI;
                                            if (finishBlock) {
                                                finishBlock(nil, NO);
                                            }
                                        } else {
                                            if (finishBlock) {
                                                finishBlock(resultError, NO);
                                            }
                                        }
                                    }];
        } else {
            if (finishBlock) {
                finishBlock(nil, YES);
            }
        }
    });
}

+ (void)executeUpload:(NSData *)imageData
       extraParameter:(NSDictionary *)extraParameter
          finishBlock:(void (^)(NSError * resultError, NSString * webURI))finishBlock {
    
    NSMutableDictionary * postParams = [NSMutableDictionary dictionaryWithCapacity:10];
    [postParams setValue:[TTSandBoxHelper ssAppID] forKey:@"aid"];
    [postParams setValue:[TTSandBoxHelper appName] forKey:@"app_name"];
    [postParams setValue:[NSNumber numberWithInteger:0] forKey:@"watermark"];
    if (extraParameter.count > 0) {
        [postParams addEntriesFromDictionary:extraParameter];
    }
    
    [[TTNetworkManager shareInstance] uploadWithURL:[[WDPublisherAdapterSetting sharedInstance] uploadImageURL] parameters:postParams constructingBodyWithBlock:^(id<TTMultipartFormData> formData) {
        [formData appendPartWithFileData:imageData name:@"image" fileName:@"image.jpeg" mimeType:@"image/jpeg"];
    } progress:nil needcommonParams:YES callback:^(NSError *error, id jsonObj) {
        NSString * webURI = nil;
        
        if (!error) {
            // 上传图片成功
            [[HMDTTMonitor defaultManager] hmdTrackService:@"ugc_write_answer_upload_image" metric:nil category:@{@"status":@(0)} extra:nil];
            if ([jsonObj isKindOfClass:[NSDictionary class]]) {
                NSDictionary * data = [jsonObj objectForKey:@"data"];
                if ([data isKindOfClass:[NSDictionary class]]) {
                    NSString * uri = [data objectForKey:@"web_uri"];
                    if (!isEmptyString(uri)) {
                        webURI = uri;
                    }
                }
            }
        } else {
            // 上传图片失败
            [[HMDTTMonitor defaultManager] hmdTrackService:@"ugc_write_answer_upload_image" metric:nil category:@{@"status":@(1)} extra:nil];
        }
        
        if (finishBlock) {
            finishBlock(error, webURI);
        }
    }];
}

- (void)cancelUploadImage
{
    self.isCancel = YES;
}

#pragma mark - Actions & Reponse

-(void)connectionChanged:(NSNotification *)notify
{
    @synchronized (self) {
        [self clearRetryTimes];
    }
}

#pragma mark - URICache

- (void)saveUri:(NSString *)uri forImageModel:(id<WDUploadImageModelProtocol>)imageModel
{
    if (isEmptyString(uri)) {
        return;
    }
    
    NSString *imageModelKey = [self memoryKeyForImageModel:imageModel];
    if (!isEmptyString(imageModelKey)) {
        [self.memoryCache setValue:uri forKey:imageModelKey];
    }
}

- (NSString *)uriForImageModel:(id<WDUploadImageModelProtocol>)imageModel
{
    NSString *imageModelKey = [self memoryKeyForImageModel:imageModel];
    if (!isEmptyString(imageModelKey)) {
        return [self.memoryCache objectForKey:imageModelKey];
    } else {
        return nil;
    }
}

- (NSString *)memoryKeyForImageModel:(id<WDUploadImageModelProtocol>)imageModel
{
    NSString *imageModelKey = nil;
    switch (imageModel.sourceType) {
        case WDUploadImageSourceTypePath: {
            imageModelKey = imageModel.compressImgUri;
        }
            break;
        case WDUploadImageSourceTypeImage: {
            imageModelKey = [imageModel.image uploadIdentifier];
        }
        default:
            break;
    }
    return imageModelKey;
}

#pragma mark - WebpCache

- (NSData *)webpDataForCompressUri:(id<WDUploadImageModelProtocol>)model
{
    switch (model.sourceType) {
        case WDUploadImageSourceTypePath: {
            NSString *uri = model.compressImgUri;
            if (isEmptyString(uri)) {
                return nil;
            }
            
            NSData *simpleImageData = [NSData dataWithContentsOfFile:uri];
            NSData *imageData;
            if (simpleImageData) {  // 转成webp
                UIImage *image = [UIImage imageWithData:simpleImageData];
                if (image) {
                    imageData = [WDImageHelper webpForImage:image];
                }
            }
            if (!imageData) {
                imageData = simpleImageData;
            }
            
            return imageData;
        }
            break;
        case WDUploadImageSourceTypeImage: {
            NSData *webpData = model.webpImage;
            if (webpData == nil) {
                webpData = UIImageJPEGRepresentation(model.image, 1);
            }
            return webpData;
        }
            break;
        default: {
            return nil;
        }
            break;
    }
}

+ (NSData *)webpDataForCompressUri:(id<WDUploadImageModelProtocol>)model
{
    switch (model.sourceType) {
        case WDUploadImageSourceTypePath: {
            NSString *uri = model.compressImgUri;
            if (isEmptyString(uri)) {
                return nil;
            }
            
            NSData *simpleImageData = [NSData dataWithContentsOfFile:uri];
            NSData *imageData;
            if (simpleImageData) {
                UIImage *image = [UIImage imageWithData:simpleImageData];
                if (image) {
                    imageData = [WDImageHelper webpForImage:image];
                }
            }
            if (!imageData) {
                imageData = simpleImageData;
            }
            
            return imageData;
        }
            break;
        case WDUploadImageSourceTypeImage: {
            NSData *webpData = model.webpImage;
            if (webpData == nil) {
                webpData = UIImageJPEGRepresentation(model.image, 1);
            }
            return webpData;
        }
            break;
        default: {
            return nil;
        }
            break;
    }
}

#pragma mark - Monitor Record

- (void)clearRetryTimes
{
    self.retryTimes = 0;
    [self.uploadFailedTimeRecoder removeAllObjects];
}

- (BOOL)isImageNeedRetryUpload:(NSString *)uri
{
    if (self.retryTimes >= kAllImageMaxImageRetryTime) {
        return NO;
    }
    //todo 有问题
    if (isEmptyString(uri)) {
        return NO;
    }
    
    if ([self.uploadFailedTimeRecoder objectForKey:uri]) {
        NSNumber *retryTime = [self.uploadFailedTimeRecoder objectForKey:uri];
        if (retryTime.integerValue >= kSingleImageMaxImageRetryTime) {
            return NO;
        } else {
            retryTime = @([retryTime intValue] + 1);
            [self.uploadFailedTimeRecoder setValue:retryTime forKey:uri];
            return YES;
        }
    }
    [self.uploadFailedTimeRecoder setValue:@0 forKey:uri];
    return YES;
}

@end
