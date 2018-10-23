//
//  TTAPIClient.m
//  TTEst
//
//  Created by Zhang Leonardo on 15-3-26.
//  Copyright (c) 2015年 t. All rights reserved.
//

#import "TTAPIClient.h"
#import "TTHTTPRequestSerializer.h"
#import "TTResponseSerializer.h"
#import "AFNetworkActivityIndicatorManager.h"
#import "STURLCache.h"
#import "SSHTTPProcesser.h"


@interface TTAPIClient()
@property (nonatomic, strong) TTJSONModelResponseSerializer * modelSerializer;
@property (nonatomic, strong) AFJSONResponseSerializer * JSONSerializer;
@property (nonatomic, strong) NSMutableDictionary *responseSerializersByTypes;
@property (nonatomic, strong) NSMutableDictionary *URLCacheKeyRequestsByTaskIdentifiers;
@property (nonatomic, strong) NSMutableArray *cacheHandlerObservers;
@property (readonly, nonatomic, strong) NSLock *lock;
@end

@implementation TTAPIClient

@dynamic lock;

+ (instancetype)shareAPIClient
{
    static TTAPIClient *_ss_shareAPIClient;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        [NSURLCache setSharedURLCache:[[NSURLCache alloc] initWithMemoryCapacity:4*1024*1024 diskCapacity:64*1024*1024 diskPath:nil]];
        [[AFNetworkActivityIndicatorManager sharedManager] setEnabled:YES];
        NSURL *url = nil;
        NSURLSessionConfiguration *cfg = [NSURLSessionConfiguration defaultSessionConfiguration];
        cfg.URLCache = [STURLCache defaultURLCache];
        cfg.timeoutIntervalForRequest = TTAPIClientTimeoutIntervalForRequest;
        _ss_shareAPIClient = [[self alloc] initWithBaseURL:url sessionConfiguration:cfg];
        [_ss_shareAPIClient.reachabilityManager startMonitoring];
        [_ss_shareAPIClient registerCacheHandlerObservers];
    });
    return _ss_shareAPIClient;
}

- (void)dealloc
{
    [self unregisterCacheHandlerObservers];
}

- (void)unregisterCacheHandlerObservers
{
    [self.cacheHandlerObservers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [[NSNotificationCenter defaultCenter] removeObserver:obj];
    }];
    [self.cacheHandlerObservers removeAllObjects];
}

- (instancetype)initWithBaseURL:(NSURL *)url sessionConfiguration:(NSURLSessionConfiguration *)configuration
{
    self = [super initWithBaseURL:url sessionConfiguration:configuration];
    if (!self) {
        return nil;
    }
    self.URLCacheKeyRequestsByTaskIdentifiers = [[NSMutableDictionary alloc] init];
    self.responseSerializersByTypes = [[NSMutableDictionary alloc] init];
    self.responseSerializersByTypes[@(TTAPIResponseObjectJSONType)] = [SSJSONResponseSerializer serializer];
    self.responseSerializersByTypes[@(TTAPIResponseObjectJSONModelType)] = [TTJSONModelResponseSerializer serializer];
    self.responseSerializersByTypes[@(TTAPIResponseObjectTextType)] = [SSTextResponseSerializer serializer];
    self.responseSerializersByTypes[@(TTAPIResponseObjectTypeOriginalTextType)] =[AFHTTPResponseSerializer serializer];
    self.responseSerializersByTypes[@(TTAPIResponseObjectTypeOriginalJSONType)] = [AFJSONResponseSerializer serializer];
    self.responseSerializersByTypes[@(TTAPIResponseObjectDefaultType)] = [AFHTTPResponseSerializer serializer];
    self.requestSerializer = [TTHTTPRequestSerializer serializer];
    self.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    return self;
}

- (NSURLSessionDataTask *)POST:(NSString *)URLString parameters:(id)parameters responseObjectType:(TTAPIResponseObjectType)type constructingBodyWithBlock:(void (^)(id<AFMultipartFormData>))block success:(void (^)(NSURLSessionDataTask *, id))success failure:(void (^)(NSURLSessionDataTask *, NSError *))failure
{
    return [self POST:URLString parameters:parameters responseObjectType:type constructingBodyWithBlock:block progress:nil success:success failure:failure];
}

- (NSURLSessionDataTask *)POST:(NSString *)URLString
                    parameters:(id)parameters
            responseObjectType:(TTAPIResponseObjectType)type
     constructingBodyWithBlock:(void (^)(id<AFMultipartFormData> formData))block
                      progress:(NSProgress * __autoreleasing *)progress
                       success:(void (^)(NSURLSessionDataTask *, id))success failure:(void (^)(NSURLSessionDataTask *, NSError *))failure
{
    NSError *serializationError = nil;
    NSMutableURLRequest *request = [self.requestSerializer multipartFormRequestWithMethod:@"POST" URLString:[[SSCommon URLWithString:URLString relativeToURL:self.baseURL] absoluteString] parameters:parameters constructingBodyWithBlock:block error:&serializationError];
    if (serializationError) {
        if (failure) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wgnu"
            dispatch_async(self.completionQueue ?: dispatch_get_main_queue(), ^{
                failure(nil, serializationError);
            });
#pragma clang diagnostic pop
        }
        
        return nil;
    }
    
    id <AFURLResponseSerialization> serializer = [self responseSerializerWithResponseObjectType:type];
    
    __block NSURLSessionDataTask *task = [self uploadTaskWithStreamedRequest:request progress:progress completionHandler:^(NSURLResponse * __unused response, id responseObject, NSError *error) {
        
        if (!error && serializer) {
            if (responseObject && !error) {
                if ([responseObject isKindOfClass:[NSData class]]) {
                    responseObject = [serializer responseObjectForResponse:response data:responseObject error:&error];
                }
            }
        }
        
        if (error) {
            if (failure) {
                failure(task, error);
            }
        } else {
            if (success) {
                success(task, responseObject);
            }
        }
    }];
    
    [task resume];
    
    return task;
}

#pragma mark - Cache

- (void)registerCacheHandlerObservers
{
    [self unregisterCacheHandlerObservers];
    __weak __typeof(self) weakSelf = self;
    id taskDidCompleteObserver = [[NSNotificationCenter defaultCenter] addObserverForName:AFNetworkingTaskDidCompleteNotification object:nil queue:nil usingBlock:^(NSNotification *note) {
        NSURLSessionTask *task = note.object;
        NSError *error = note.userInfo[AFNetworkingTaskDidCompleteErrorKey];
        if (error) {
            return;
        }
        
        NSData *data = note.userInfo[AFNetworkingTaskDidCompleteResponseDataKey];
        if (!data) {
            return;
        }
        
        __strong __typeof(weakSelf) strongSelf = weakSelf;
        
        NSURLRequest *URLCacheKeyRequest = [strongSelf URLCacheKeyRequestForTask:task];
        if (!URLCacheKeyRequest) {
            return;
        }
        
        [strongSelf removeURLCacheKeyRequestFoTask:task];
        
        NSURLCache *URLCache = strongSelf.session.configuration.URLCache ?: [NSURLCache sharedURLCache];
        NSCachedURLResponse *cachedURLResponse = [[NSCachedURLResponse alloc] initWithResponse:task.response data:data];
        [URLCache storeCachedResponse:cachedURLResponse forRequest:URLCacheKeyRequest];
    }];
    
    id sessionDidInvalidateObserver = [[NSNotificationCenter defaultCenter] addObserverForName:AFURLSessionDidInvalidateNotification object:nil queue:nil usingBlock:^(NSNotification *note) {
        [weakSelf removeAllURLCacheKeyRequests];
    }];
    
    [self.cacheHandlerObservers addObject:taskDidCompleteObserver];
    [self.cacheHandlerObservers addObject:sessionDidInvalidateObserver];
}

// 给task添加一个可以拉取cache的request，因为POST是非幂等的万万是不能从URLCahce中取缓存了
- (void)addURLCacheKeyRequestForTask:(NSURLSessionTask *)task
{
    NSURLRequest *URLCacheKeyRequest = [(TTHTTPRequestSerializer *)self.requestSerializer URLCacheKeyRequestWithRequest:task.originalRequest];
    if (!URLCacheKeyRequest) {
        return;
    }
    [self.lock lock];
    self.URLCacheKeyRequestsByTaskIdentifiers[@(task.taskIdentifier)] = URLCacheKeyRequest;
    [self.lock unlock];
}

- (NSURLRequest *)URLCacheKeyRequestForTask:(NSURLSessionTask *)task
{
    [self.lock lock];
    NSURLRequest *URLCacheKeyRequest = self.URLCacheKeyRequestsByTaskIdentifiers[@(task.taskIdentifier)];
    [self.lock unlock];
    return URLCacheKeyRequest;
}

- (void)removeURLCacheKeyRequestFoTask:(NSURLSessionTask *)task
{
    [self.lock lock];
    [self.URLCacheKeyRequestsByTaskIdentifiers removeObjectForKey:@(task.taskIdentifier)];
    [self.lock unlock];
}

- (void)removeAllURLCacheKeyRequests
{
    [self.lock lock];
    [self.URLCacheKeyRequestsByTaskIdentifiers removeAllObjects];
    [self.lock unlock];
}

// 取出task对应的cache
- (void)getCachedURLResponseWithTask:(NSURLSessionDataTask *)dataTask responseSerialization:(id<AFURLResponseSerialization>)serializer completionHandler:(void(^)(id cachedObject))completion
{
    id cachedObject = nil;
    if (dataTask) {
        NSURLCache *URLCache = self.session.configuration.URLCache ?: [NSURLCache sharedURLCache];
        NSURLRequest *URLCacheKeyRequest = [self URLCacheKeyRequestForTask:dataTask];
        if (!URLCacheKeyRequest) {
            URLCacheKeyRequest = [(TTHTTPRequestSerializer *)self.requestSerializer URLCacheKeyRequestWithRequest:dataTask.originalRequest];
        }
        
        NSCachedURLResponse *cachedURLResponse = [URLCache cachedResponseForRequest:URLCacheKeyRequest];
        if (cachedURLResponse) {
            if (serializer) {
                cachedObject = [serializer responseObjectForResponse:cachedURLResponse.response data:cachedURLResponse.data error:nil];
            }
            else {
                cachedObject = cachedURLResponse.data;
            }
        }
    }
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wgnu"
    dispatch_async(self.completionQueue ?: dispatch_get_main_queue(), ^{
        completion(cachedObject);
    });
#pragma clang diagnostic pop
    
}

#pragma mark - HTTP
- (id <AFURLResponseSerialization>)responseSerializerWithResponseObjectType:(TTAPIResponseObjectType)type
{
    return self.responseSerializersByTypes[@(type)];
}

- (NSURLSessionDataTask *)HTTPMethod:(NSString *)method
                           URLString:(NSString *)URLString
                          parameters:(id)parameters
                  responseObjectType:(TTAPIResponseObjectType)responseObjectType
                               cache:(void (^)(id))cache
                             success:(void (^)(NSURLSessionDataTask *, id))success
                             failure:(void (^)(NSURLSessionDataTask *, NSError *, id))failure
{
    return [self HTTPMethod:method
                  URLString:URLString
                 parameters:parameters
         responseObjectType:responseObjectType
               requestModel:nil
                      cache:cache
                    success:success
                    failure:failure];
}

- (NSURLSessionDataTask *)HTTPMethod:(NSString *)method
                           URLString:(NSString *)URLString
                          parameters:(id)parameters
                  responseObjectType:(TTAPIResponseObjectType)responseObjectType
                        requestModel:(TTRequestModel *)requestModel
                               cache:(void (^)(id))cache
                             success:(void (^)(NSURLSessionDataTask *, id))success
                             failure:(void (^)(NSURLSessionDataTask *, NSError *, id))failure
{
    NSError *serializationError = nil;
    
    if (![NSURL URLWithString:URLString]) {
        URLString = [URLString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        URLString = [URLString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    }

    NSMutableURLRequest *request = [self.requestSerializer requestWithMethod:method URLString:URLString parameters:parameters error:&serializationError];
    if (serializationError) {
        if (failure) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wgnu"
            dispatch_async(self.completionQueue ?: dispatch_get_main_queue(), ^{
                failure(nil, serializationError, nil);
            });
#pragma clang diagnostic pop
        }
        
        return nil;
    }
    
    id <AFURLResponseSerialization> serializer = [self responseSerializerWithResponseObjectType:responseObjectType];
    
    __block NSURLSessionDataTask *dataTask = nil;
    dataTask = [self dataTaskWithRequest:request completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        id originalResponseObject = responseObject;
        if (!error && serializer) {
            if (responseObject && !error) {
                if ([responseObject isKindOfClass:[NSData class]]) {
                    SSHTTPResponseProtocolItem *item = [[SSHTTPResponseProtocolItem alloc] init];
                    item.responseData = responseObject;
                    NSDictionary *allHeaderFields = nil;
                    if ([response respondsToSelector:@selector(allHeaderFields)]) {
                        allHeaderFields = [(NSHTTPURLResponse *)response allHeaderFields];
                    }
                    item.allHeaderFields = allHeaderFields;
                    [[SSHTTPProcesser sharedProcesser] preprocessHTTPResponse:item];
//                    responseObject = [serializer responseObjectForResponse:response data:item.responseData error:&error];
                    
                    if ([serializer respondsToSelector:@selector(responseObjectForResponse:data:requestModel:error:)]) {
                        responseObject = [((NSObject<TTJSONResponseForwardSerializer> *)serializer) responseObjectForResponse:response data:item.responseData requestModel:requestModel error:&error];
                    }
                    else {
                        responseObject = [serializer responseObjectForResponse:response data:item.responseData error:&error];
                    }

                }
            }
        }
        
        if (error) {
            if (failure) {
                
                NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithDictionary:error.userInfo];
                [userInfo setValue:originalResponseObject forKey:TTNetworkErrorOriginalDataKey];
                //// 在哪定义的errordomain。。。谁看到了替换下domain。
                NSString *domain = error.domain?:@"com.ss.iphone";
                NSError *newError = [NSError errorWithDomain:domain code:error.code userInfo:userInfo];
                failure(dataTask, newError, responseObject);
            }
        } else {
            if (success) {
                success(dataTask, responseObject);
            }
        }
    }];
    
    if (cache) {
        [self addURLCacheKeyRequestForTask:dataTask];
        [self getCachedURLResponseWithTask:dataTask responseSerialization:serializer completionHandler:cache];
    }
    
    return dataTask;
}

@end

#pragma mark - File Data Upload -
NSString * const SSDefaultImageUploadName = @"image";
NSString * const SSDefaultImageUploadFileName = @"image.jpeg";
NSString * const SSDefaultImageUploadMIMEType= @"image/jpeg";

NSString * const SSDefaultAudioUploadName = @"audio";
NSString * const SSDefaultAudioUploadFileName = @"audioFile";
NSString * const SSDefaultAudioUploadMIMEType = @"audio/amr";

@implementation TTAPIClient (TTAPIClientFileDataUpload)
- (NSURLSessionDataTask *)imageUploadWithURLString:(NSString *)URLString parameters:(id)parameters fileData:(NSData *)data progress:(NSProgress **)progress success:(void (^)(NSURLSessionDataTask *, id))success failure:(void (^)(NSURLSessionDataTask *, NSError *))failure
{
    NSURLSessionDataTask * task = [self POST:URLString parameters:parameters responseObjectType:TTAPIResponseObjectJSONType constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        [formData appendPartWithFileData:data name:SSDefaultImageUploadName fileName:SSDefaultImageUploadFileName mimeType:SSDefaultImageUploadMIMEType];
    } progress: progress success:success failure:failure];

    return task;
}

- (NSURLSessionDataTask *)imageUploadWithURLString:(NSString *)URLString parameters:(id)parameters keyName:(NSString *)keyName fileData:(NSData *)data progress:(NSProgress **)progress success:(void (^)(NSURLSessionDataTask *, id))success failure:(void (^)(NSURLSessionDataTask *, NSError *))failure
{
    if (isEmptyString(keyName)) {
        keyName = SSDefaultImageUploadName;
    }

    NSURLSessionDataTask * task = [self POST:URLString parameters:parameters responseObjectType:TTAPIResponseObjectJSONType constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        [formData appendPartWithFileData:data name:keyName fileName:SSDefaultImageUploadFileName mimeType:SSDefaultImageUploadMIMEType];
    } progress:progress success:success failure:failure];
    
    return task;
}

@end

@implementation TTAPIClient (TTAPIClientFileDownload)

- (NSURLSessionDownloadTask *)dowloadFile:(NSString *)URLString
                               parameters:(id)parameters
                             toTargetPath:(NSString *)targetPath
                                  success:(void (^)(NSURLSessionDownloadTask *, NSURL *))success
                                  failure:(void (^)(NSURLSessionDownloadTask *, NSError *))failure
{
    NSError *serializationError = nil;
    NSMutableURLRequest *request = [self.requestSerializer requestWithMethod:@"GET" URLString:[[NSURL URLWithString:URLString relativeToURL:self.baseURL] absoluteString] parameters:nil error:&serializationError];
    if (serializationError) {
        if (failure) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wgnu"
            dispatch_async(self.completionQueue ?: dispatch_get_main_queue(), ^{
                failure(nil, serializationError);
            });
#pragma clang diagnostic pop
        }
        
        return nil;
    }
    
    __block NSURLSessionDownloadTask *downloadTask =
    [self
     downloadTaskWithRequest:request
     progress:nil
     destination:^NSURL *(__unused NSURL *tmpURL, __unused NSURLResponse *response) {
         if ([[NSFileManager defaultManager] fileExistsAtPath:targetPath]) {
             [[NSFileManager defaultManager] removeItemAtPath:targetPath error:nil];
         }
         return [NSURL fileURLWithPath:targetPath];
     }
     completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
         if (error) {
             if (failure) {
                 failure(downloadTask, error);
             }
         } else {
             if (success) {
                 success(downloadTask, filePath);
             }
         }
     }];
    [downloadTask resume];
    return downloadTask;
}

@end


@implementation TTAPIClient (SSFetchCache)
- (id)cachedObjectWithURLString:(NSString *)URLString parameters:(id)parameters responseObjectType:(TTAPIResponseObjectType)type
{
    NSMutableURLRequest *URLCacheKeyRequest = [self.requestSerializer requestWithMethod:@"GET" URLString:[[NSURL URLWithString:URLString relativeToURL:self.baseURL] absoluteString] parameters:parameters error:nil];
    
    NSURLCache *URLCache = self.session.configuration.URLCache ?: [NSURLCache sharedURLCache];
    
    id <AFURLResponseSerialization> serializer = [self responseSerializerWithResponseObjectType:type];
    id cachedObject = nil;
    NSCachedURLResponse *cachedURLResponse = [URLCache cachedResponseForRequest:URLCacheKeyRequest];
    if (cachedURLResponse) {
        if (serializer) {
            cachedObject = [serializer responseObjectForResponse:cachedURLResponse.response data:cachedURLResponse.data error:nil];
        }
        else {
            cachedObject = cachedURLResponse.data;
        }
    }
    return cachedObject;
}

- (id)cachedObjectWithURLString:(NSString *)URLString parameters:(id)parameters
{
    return [self cachedObjectWithURLString:URLString parameters:parameters responseObjectType:TTAPIResponseObjectJSONModelType];
}
@end


//#pragma mark - Old Version Legacy API
//#import <AFNetworking/AFHTTPRequestOperation.h>
//@implementation TTAPIClient (TTAPIClientLegacyAdapter)
//- (void)uploadImage:(NSArray *)images delegate:(id<SSNetworkingAdapterProgressDelegate>)delegate block:(void (^)(BOOL, NSDictionary *))block
//{
//    if (images.count == 0) {
//        dispatch_async(dispatch_get_main_queue(), ^{
//            if (block) {
//                block(NO, nil);
//            }
//        });
//        return;
//    }
//    
//    NSAssert(images.count == 1, @"不可以多图哦，只能是一张！这个是为了迁移旧版代码而留的。");
//    NSString *path = kAskImageUploadUrl;
//    id success = !block ? nil : ^(__unused id op, id responseObject) {
//        NSError *error = nil;
//        id json = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:&error];
//        if (!error) {
//            block(YES, json);
//        }
//        else {
//            block(NO, nil);
//        }
//    };
//    id failure = !block ? nil : ^(__unused id op, NSError *error) {
//        block(NO, nil);
//    };
//    
//    NSData *data = UIImageJPEGRepresentation(images.firstObject, 1.0);
//    
//    NSURLRequest *request = [(AFHTTPRequestSerializer *)[self requestSerializer] multipartFormRequestWithMethod:@"POST" URLString:path parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
//        [formData appendPartWithFileData:data name:@"image" fileName:@"image.jpg" mimeType:@"image/jpeg"];
//        
//    } error:nil];
//    
//    AFHTTPRequestOperation *op = [[AFHTTPRequestOperation alloc] initWithRequest:request];
//    [op setCompletionBlockWithSuccess:success failure:failure];
//    
//    __weak typeof(delegate) weakDelegate = delegate;
//    [op setUploadProgressBlock:^(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite) {
//        if ([weakDelegate respondsToSelector:@selector(setProgress:)]) {
//            [weakDelegate setProgress:(CGFloat)totalBytesWritten/totalBytesExpectedToWrite];
//        }
//    }];
//    
//    dispatch_async(dispatch_get_main_queue(), ^{
//        if ([weakDelegate respondsToSelector:@selector(setProgress:)]) {
//            [weakDelegate setProgress:0];
//        }
//    });
//    [op start];
//}
//@end
//

#pragma mark - Networking Reachability
@implementation TTAPIClient (TTAPIClientReachability)
+ (void)load
{
    @autoreleasepool {
        __block id observer = [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidFinishLaunchingNotification object:nil queue:nil usingBlock:^(NSNotification *note) {
            [TTAPIClient.shareAPIClient.reachabilityManager startMonitoring];
            [[NSNotificationCenter defaultCenter] removeObserver:observer];
        }];
    }
}
+ (BOOL)isReachable
{
    return [TTAPIClient shareAPIClient].reachabilityManager.reachable;
}
+ (BOOL)isReachableViaWiFi
{
    return [TTAPIClient shareAPIClient].reachabilityManager.reachableViaWiFi;
}
+ (BOOL)isReachableViaWWAN
{
    return [TTAPIClient shareAPIClient].reachabilityManager.reachableViaWWAN;
}
@end

