//
//  FRUploadImageManager.m
//  Forum
//
//  Created by Zhang Leonardo on 15-4-30.
//
//

#import "FRUploadImageManager.h"
#import <TTNetworkManager/TTNetworkManager.h>
#import <TTUGCFoundation/FRCommonURLSetting.h>
#import <TTKitchen/TTKitchen.h>
#import <TTBaseLib/TTBaseMacro.h>
#import "TTSandBoxHelper.h"
#import <TTBaseLib/NSDictionary+TTAdditions.h>
#import <TTBaseLib/NSObject+TTAdditions.h>
#import "TTUGCRequestManager.h"
#import "TTUGCImageKitchen.h"
/**
 *  同时允许上传的数量
 */
#define kSynchronizedCount 2
#define kMaxDataSize (1 * 1024.f)

@interface FRUploadImageManager()
{
    BOOL _isCanceled;
    NSInteger _retryCount; //自动重复上传的判断
}

@property(nonatomic, copy)FRUploadImageManagerProgressBlock progressBlock;
@property(nonatomic, copy)FRUploadImageManagerFinishBlock finishBlock;

@property(nonatomic, strong)NSMutableArray *images;
@property(nonatomic, assign)BOOL isLoading;
@property(nonatomic, assign)NSUInteger expectedCount;
/**
 *  还未上传的model
 */
@property(nonatomic, strong)NSMutableArray<FRUploadImageModel *> * needUploadModels;
/**
 *  已经上传的model
 */
@property(nonatomic, strong)NSMutableArray<FRUploadImageModel *> * finishUpLoadModels;

/**
 *  上传图片需要带的额外参数
 */
@property(nonatomic, strong)NSDictionary *extraParameter;
@end

@interface FRUploadImageManager(Error)
+ (NSError *)isLoadingError;
+ (NSError *)compressError;
+ (NSError *)imageDataNULLError;
+ (NSError *)imageURLNULLError;
+ (NSError *)cancelError;
@end

@implementation FRUploadImageManager

- (void)dealloc
{
    [self cancel];
    self.progressBlock = nil;
    self.finishBlock = nil;
    
}

- (id)init
{
    self = [super init];
    if (self) {
        self.images = [NSMutableArray arrayWithCapacity:10];
        self.isLoading = NO;
        _isCanceled = NO;
        _retryCount = [TTKitchen getInt:kTTKUGCImageUploadRetryCount];
    }
    return self;
}

- (void)cancel
{
    _retryCount = 0;
    _expectedCount = 0;
    _isCanceled = YES;
    [_needUploadModels removeAllObjects];
    [_finishUpLoadModels removeAllObjects];
}

- (void)uploadPhotos:(NSArray<FRUploadImageModel *> *)photoModels
        extParameter:(NSDictionary *)extParameters
       progressBlock:(FRUploadImageManagerProgressBlock)progressBlock
         finishBlock:(FRUploadImageManagerFinishBlock)finishBlock
{
    if (_isLoading) {
        if (finishBlock) {
            finishBlock([FRUploadImageManager isLoadingError], nil);
        }
        return;
    }
    _retryCount = [TTKitchen getInt:kTTKUGCImageUploadRetryCount];
    _isCanceled = NO;
    
    self.extraParameter = extParameters;
    
    [_needUploadModels removeAllObjects];
    [_finishUpLoadModels removeAllObjects];
    
    self.progressBlock = progressBlock;
    self.finishBlock = finishBlock;
    
    _isLoading = YES;
    
    self.needUploadModels = (NSMutableArray<FRUploadImageModel*> *)[NSMutableArray arrayWithCapacity:10];
    self.finishUpLoadModels = (NSMutableArray<FRUploadImageModel*> *)[NSMutableArray arrayWithCapacity:10];
    
    for (FRUploadImageModel * model in photoModels) {
        if (!isEmptyString(model.webURI)) {
            [_finishUpLoadModels addObject:model];
        } else {
            if (model.cacheTask) {
                [_needUploadModels addObject:model];
            }
        }
    }
    _expectedCount = _needUploadModels.count + _finishUpLoadModels.count;
    if (_expectedCount == 0) {
        [self callFinishModels:_finishUpLoadModels error:nil];
    } else {
        FHMainSafeExecuteBlock(^{
            for (int i = 0; i < kSynchronizedCount; i ++) {
                [self upLoadNext];
            }
        });
    }
}

- (void)callFinishModels:(NSArray<FRUploadImageModel*> *)resultModels error:(NSError *)error{
    NSArray<FRUploadImageModel *> *models = [resultModels copy];
    [_needUploadModels removeAllObjects];
    [_finishUpLoadModels removeAllObjects];
   
    if (_retryCount > 0) {
        _retryCount--;
        for (FRUploadImageModel *model in models) {
            if (isEmptyString(model.webURI)) {
                [_needUploadModels addObject:model];
            } else {
                [_finishUpLoadModels addObject:model];
            }
        }
        if (_needUploadModels.count > 0) {
            _expectedCount = _needUploadModels.count + _finishUpLoadModels.count;
            FHMainSafeExecuteBlock(^{
                for (int i = 0; i < kSynchronizedCount; i ++) {
                    [self upLoadNext];
                }
            });
            return;
        }
    }
    
    if (_finishBlock) {
        _finishBlock(error, models);
    }
    
    _isLoading = NO;
    _isCanceled = NO;
    
    self.extraParameter = nil;
    [_needUploadModels removeAllObjects];
    [_finishUpLoadModels removeAllObjects];
    
    self.progressBlock = nil;
    self.finishBlock = nil;
    _expectedCount = 0;
}

- (void)upLoadNext
{
    if (_expectedCount <= [_finishUpLoadModels count]) {
        [self callFinishModels:_finishUpLoadModels error:nil];
        return;
    }
    
    if ([_needUploadModels count] == 0) {
        return;
    }
    
    FRUploadImageModel * model = [_needUploadModels firstObject];
    model.uploadCount = model.uploadCount + 1;
    [_needUploadModels removeObject:model];
    __weak FRUploadImageManager * weakSelf = self;
    __block uint64_t startTime = [NSObject currentUnixTime];
    [[TTUGCImageCompressManager sharedInstance] queryFilePathWithTask:model.cacheTask complete:^(NSString *filePath) {
        __block uint64_t endTime = [NSObject currentUnixTime];
        __block uint64_t total = [NSObject machTimeToSecs:endTime - startTime] * 1000;
        model.localCompressConsume = total;
        
        void (^finishBlock)(NSError * resultError, NSString * webURI, uint64_t width, uint64_t height, NSString * format) = ^(NSError * resultError, NSString * webURI, uint64_t width, uint64_t height, NSString * format) {
            endTime = [NSObject currentUnixTime];
            total = [NSObject machTimeToSecs:endTime - startTime] * 1000;
            model.networkConsume = total;
            if (!isEmptyString(webURI)) {
                model.error = nil;
                model.webURI = webURI;
                model.imageOriginWidth = width;
                model.imageOriginHeight = height;
                model.imageFormat = format;
                model.isUploaded = YES;
            } else { //webURI为空都是错误
                model.isUploaded = NO;
                model.error = resultError;
            }
            [weakSelf.finishUpLoadModels addObject:model];
            if ([weakSelf progressBlock]) {
                weakSelf.progressBlock((int)weakSelf.expectedCount, (int)[weakSelf.finishUpLoadModels count]);
            }
            [weakSelf upLoadNext];
        };
        
        if (filePath == nil) {
            if (model.cacheTask.assetModel.imageURL) {
                //要上传的图片为网络资源
                NSString *url = model.cacheTask.assetModel.imageURL.absoluteString;
                startTime = endTime;
                NSDictionary *extParams;
                if (model.cacheTask.assetModel.imageURI) {
                    extParams = @{@"uri" : model.cacheTask.assetModel.imageURI};
                }
                [FRUploadImageManager uploadPhotoURL:url withExtParameter:extParams finishBlock:finishBlock];
            } else {
                model.error = [FRUploadImageManager compressError];
                weakSelf.expectedCount = weakSelf.expectedCount - 1; //本地没能找到这张图，直接不传了
                [weakSelf upLoadNext];
                if ([weakSelf progressBlock]) {
                    weakSelf.progressBlock((int)weakSelf.expectedCount, (int)[weakSelf.finishUpLoadModels count]);
                }
            }
        } else {
            startTime = endTime;
            NSData* imageData = [NSData dataWithContentsOfFile:filePath];
            model.size = (imageData.length/1024);
           
            [FRUploadImageManager uploadPhoto:imageData withExtParameter:_extraParameter finishBlock:finishBlock];
        }
    }];
}

+ (void)uploadPhoto:(NSData *)imageData
   withExtParameter:(NSDictionary *)extParameter
        finishBlock:(void (^)(NSError * resultError, NSString * webURI, uint64_t width, uint64_t height, NSString * format))finishBlock {
    if (imageData == nil) { //各种错误导致的图片没能正确获取到，可能是压缩失败，io错误，或者kill后清理了缓存
        if (finishBlock) {
            finishBlock([FRUploadImageManager imageDataNULLError], nil, 0, 0, nil);
        }
        return;
    }
    
    NSMutableDictionary * postParams = [NSMutableDictionary dictionaryWithCapacity:10];
    [postParams setValue:[TTSandBoxHelper ssAppID] forKey:@"aid"];
    [postParams setValue:[TTSandBoxHelper appName] forKey:@"app_name"];
    [postParams setValue:[NSNumber numberWithInteger:0] forKey:@"watermark"];
    if (extParameter.count > 0) {
        [postParams addEntriesFromDictionary:extParameter];
    }
    
    [[TTNetworkManager shareInstance] uploadWithResponse:[FRCommonURLSetting uploadImageURL]
                                              parameters:postParams
                                             headerField:nil
                               constructingBodyWithBlock:^(id<TTMultipartFormData> formData) {
                                   if (imageData) {
                                       [formData appendPartWithFileData:imageData
                                                                   name:@"image"
                                                               fileName:@"image.jpeg"
                                                               mimeType:@"image/jpeg"];
                                   }
                               }
                                                progress:nil
                                        needcommonParams:YES
                                       requestSerializer:nil
                                      responseSerializer:nil
                                              autoResume:YES
                                                callback:^(NSError *error, id data, TTHttpResponse *response) {
                                                    NSString * webURI = nil;
                                                    int64_t width = 0;
                                                    int64_t height = 0;

                                                    NSString *format;
                                                    if (!error) {
                                                        if ([data isKindOfClass:[NSData class]]) {
                                                            NSDictionary * jsonObj = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
                                                            NSDictionary * data = [jsonObj objectForKey:@"data"];
                                                            if ([data isKindOfClass:[NSDictionary class]]) {
                                                                NSString * uri = [data objectForKey:@"web_uri"];
                                                                if (!isEmptyString(uri)) {
                                                                    webURI = uri;
                                                                }

                                                                NSString *widthString = [data tt_stringValueForKey:@"width"];
                                                                width = widthString.longLongValue;

                                                                NSString *heightString = [data tt_stringValueForKey:@"height"];
                                                                height = heightString.longLongValue;

                                                                NSString *formateString = [data tt_stringValueForKey:@"format"];
                                                                if (!isEmptyString(formateString)) {
                                                                    format = formateString;
                                                                }
                                                            }
                                                        }
                                                    }
                                                    if (finishBlock) {
                                                        finishBlock(error, webURI, width, height, format);
                                                    }
                                                }
                                                 timeout:[TTKitchen getInt:kTTKUGCImageUploadTimeout]];
}

+ (void)uploadPhotoURL:(NSString *)url
      withExtParameter:(NSDictionary *)extParameter
           finishBlock:(void (^)(NSError * resultError, NSString * webURI, uint64_t width, uint64_t height, NSString * format))finishBlock {
    if (url == nil) {
        if (finishBlock) {
            finishBlock([FRUploadImageManager imageURLNULLError], nil, 0, 0, nil);
        }
        return;
    }
    
    NSMutableDictionary * postParams = [NSMutableDictionary dictionaryWithCapacity:10];
    [postParams setValue:url forKey:@"url"];
    [postParams setValue:[TTSandBoxHelper ssAppID] forKey:@"aid"];
    [postParams setValue:[TTSandBoxHelper appName] forKey:@"app_name"];
    [postParams setValue:[NSNumber numberWithInteger:0] forKey:@"watermark"];
    if (extParameter.count > 0) {
        [postParams addEntriesFromDictionary:extParameter];
    }

    [TTUGCRequestManager requestForJSONWithURL:[FRCommonURLSetting uploadWithUrlOfImageURL] params:postParams method:@"POST" needCommonParams:NO callBackWithMonitor:^(NSError *error, id obj, TTHttpResponse *response) {
        NSString * webURI = nil;
        int64_t width = 0;
        int64_t height = 0;
        
        NSString *format;
        if (!error) {
            if ([obj isKindOfClass:[NSDictionary class]]) {
                NSDictionary *jsonObj = (NSDictionary *)obj;
                NSDictionary *data = [jsonObj objectForKey:@"data"];
                if ([data isKindOfClass:[NSDictionary class]]) {
                    NSString *uri = [data objectForKey:@"web_uri"];
                    if (!isEmptyString(uri)) {
                        webURI = uri;
                    }
                    
                    NSString *widthString = [data tt_stringValueForKey:@"width"];
                    width = widthString.longLongValue;
                    
                    NSString *heightString = [data tt_stringValueForKey:@"height"];
                    height = heightString.longLongValue;
                    
                    NSString *formateString = [data tt_stringValueForKey:@"format"];
                    if (!isEmptyString(formateString)) {
                        format = formateString;
                    }
                }
            }
        }
        if (finishBlock) {
            finishBlock(error, webURI, width, height, format);
        }
    }];
}

@end

@implementation FRUploadImageManager(Error)

+ (NSError *)isLoadingError {
    return [NSError errorWithDomain:FRUploadImageErrorDomain code:FRUploadImageErrorIsLoading userInfo:@{@"msg" : @"正在上传"}];
}

+ (NSError *)compressError {
    return [NSError errorWithDomain:FRUploadImageErrorDomain code:FRUploadImageErrorLocalCompress userInfo:@{@"msg" : @"读取本地localPath为空"}];
}

+ (NSError *)imageDataNULLError {
    return [NSError errorWithDomain:FRUploadImageErrorDomain code:FRUploadImageErrorImageDataNULL userInfo:@{@"msg" : @"读取本地图片为空"}];
}

+ (NSError *)imageURLNULLError {
    return [NSError errorWithDomain:FRUploadImageErrorDomain code:FRUploadImageErrorImageURLNULL userInfo:@{@"msg" : @"上传图片URL为空"}];
}

+ (NSError *)cancelError {
    return [NSError errorWithDomain:FRUploadImageErrorDomain code:FRUploadImageErrorCancel userInfo:@{@"msg" : @"用户主动cancel"}];
}
@end
