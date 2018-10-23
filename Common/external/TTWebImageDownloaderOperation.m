//
//  TTWebImageDownloaderOperation.m
//  Article
//
//  Created by tyh on 2017/5/17.
//
//

#import "TTWebImageDownloaderOperation.h"
#import "SDWebImageDownloaderOperation.h"
#import "SDWebImageDecoder.h"
#import "UIImage+MultiFormat.h"
#import <ImageIO/ImageIO.h>
#import <BDWebImage/SDWebImageAdapter.h>
#import "NSImage+WebCache.h"
#import <objc/runtime.h>
#import "TTNetworkManager.h"
#import "KVOController.h"
#import "TTRouteSelectionServerConfig.h"
#import "SSCommonLogic.h"
#import "SDWebImageDownloaderOperationBugFix.h"
#import "TTStopWatch.h"
#import "UIImageView+BDTSource.h"
#import <TTMonitor.h>
#import "TTImageMonitor.h"
#import "TTWebImageHEIFCoder.h"
#import "TTKitchenHeader.h"

static NSString *const kProgressCallbackKey = @"progress";
static NSString *const kCompletedCallbackKey = @"completed";
static NSString *const kTTWebImageDownloaderOperationErrorDomain = @"TTWebImageDownloaderOperationErrorDomain";
static NSInteger const kTTWebImageDownReadLocalFileFailedCode = 601;

typedef NSMutableDictionary<NSString *, id> SDCallbacksDictionary;

@interface TTWebImageDownloaderOperation ()

@property (strong, nonatomic, nonnull) NSMutableArray<SDCallbacksDictionary *> *callbackBlocks;

@property (assign, nonatomic, getter = isExecuting) BOOL executing;
@property (assign, nonatomic, getter = isFinished) BOOL finished;
@property (strong, nonatomic, nullable) NSMutableData *imageData;
@property (assign, atomic) BOOL hasProgressCallbackBlock;

// This is weak because it is injected by whoever manages this session. If this gets nil-ed out, we won't be able to run
// the task associated with this operation
@property (weak, nonatomic, nullable) NSURLSession *unownedSession;
// This is set if we're using not using an injected NSURLSession. We're responsible of invalidating this one
@property (strong, nonatomic, nullable) NSURLSession *ownedSession;

@property (strong, nonatomic, readwrite, nullable) NSURLSessionTask *dataTask;

@property (SDDispatchQueueSetterSementics, nonatomic, nullable) dispatch_queue_t barrierQueue;

@property (strong, nonatomic) TTHttpTask *ttHttpTask;

//@property (assign, nonatomic) UIBackgroundTaskIdentifier backgroundTaskId;

@end

@implementation TTWebImageDownloaderOperation {
    size_t width, height;
    UIImageOrientation orientation;
    BOOL responseFromCached;
}

@synthesize executing = _executing;
@synthesize finished = _finished;

- (nonnull instancetype)init {
    return [self initWithRequest:nil inSession:nil options:0];
}

- (nonnull instancetype)initWithRequest:(nullable NSURLRequest *)request
                              inSession:(nullable NSURLSession *)session
                                options:(SDWebImageDownloaderOptions)options {
    if ((self = [super init])) {
        
        //change isa
        object_setClass(self, [TTWebImageDownloaderOperation class]);
        
        _request = [request copy];
        _shouldDecompressImages = YES;
        _options = options;
        _callbackBlocks = [NSMutableArray new];
        _executing = NO;
        _finished = NO;
        _hasProgressCallbackBlock = NO;
        _expectedSize = 0;
        _unownedSession = session;
        responseFromCached = YES; // Initially wrong until `- URLSession:dataTask:willCacheResponse:completionHandler: is called or not called
        _barrierQueue = dispatch_queue_create("com.hackemist.SDWebImageDownloaderOperationBarrierQueue", DISPATCH_QUEUE_CONCURRENT);
    }
    return self;
}

- (void)dealloc {

    SDDispatchQueueRelease(_barrierQueue);
}

- (nullable id)addHandlersForProgress:(nullable SDWebImageDownloaderProgressBlock)progressBlock
                            completed:(nullable SDWebImageDownloaderCompletedBlock)completedBlock {
    SDCallbacksDictionary *callbacks = [NSMutableDictionary new];
    if (progressBlock) self.hasProgressCallbackBlock = YES;
    if (progressBlock) callbacks[kProgressCallbackKey] = [progressBlock copy];
    if (completedBlock) callbacks[kCompletedCallbackKey] = [completedBlock copy];
    
    WeakSelf;
    dispatch_barrier_async(self.barrierQueue, ^{
        if (!wself) {
            return ;
        }
        StrongSelf;
        [self.callbackBlocks addObject:callbacks];
    });
    return callbacks;
}

- (nullable NSArray<id> *)callbacksForKey:(NSString *)key {
    __block NSMutableArray<id> *callbacks = nil;
    dispatch_sync(self.barrierQueue, ^{
        // We need to remove [NSNull null] because there might not always be a progress block for each callback
        callbacks = [[self.callbackBlocks valueForKey:key] mutableCopy];
        [callbacks removeObjectIdenticalTo:[NSNull null]];
    });
    return [callbacks copy];    // strip mutability here
}

- (BOOL)cancel:(nullable id)token {
    __block BOOL shouldCancel = NO;
    dispatch_barrier_sync(self.barrierQueue, ^{
        [self.callbackBlocks removeObjectIdenticalTo:token];
        if (self.callbackBlocks.count == 0) {
            shouldCancel = YES;
        }
    });
    if (shouldCancel) {
        [self cancel];
    }
    return shouldCancel;
}

- (void)start {

    @synchronized (self) {
        if (self.isCancelled) {
            self.finished = YES;
            [self reset];
            return;
        }
        
        /*
#if SD_UIKIT·
        Class UIApplicationClass = NSClassFromString(@"UIApplication");
        BOOL hasApplication = UIApplicationClass && [UIApplicationClass respondsToSelector:@selector(sharedApplication)];
        if (hasApplication && [self shouldContinueWhenAppEntersBackground]) {
            __weak __typeof__ (self) wself = self;
            UIApplication * app = [UIApplicationClass performSelector:@selector(sharedApplication)];
            self.backgroundTaskId = [app beginBackgroundTaskWithExpirationHandler:^{
                __strong __typeof (wself) sself = wself;
                if (sself) {
                    [sself cancel];
                    [app endBackgroundTask:sself.backgroundTaskId];
                    sself.backgroundTaskId = UIBackgroundTaskInvalid;
                }
            }];
        }
#endif
         */
        NSURLSession *session = self.unownedSession;
        if (!self.unownedSession) {
            NSURLSessionConfiguration *sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
            sessionConfig.timeoutIntervalForRequest = 15;
            
            /**
             *  Create the session for this task
             *  We send nil as delegate queue so that the session creates a serial operation queue for performing all delegate
             *  method calls and completion handler calls.
             */
            self.ownedSession = [NSURLSession sessionWithConfiguration:sessionConfig
                                                              delegate:self
                                                         delegateQueue:nil];
            session = self.ownedSession;
        }
        
        self.executing = YES;
    }
    [self startLoadImg];

    
    if (self.ttHttpTask) {
        for (SDWebImageDownloaderProgressBlock progressBlock in [self callbacksForKey:kProgressCallbackKey]) {
            progressBlock(0, NSURLResponseUnknownLength, self.request.URL);
        }
        /*
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:SDWebImageDownloadStartNotification object:self];
        });
         */
    } else {
        [self callCompletionBlocksWithError:[NSError errorWithDomain:NSURLErrorDomain code:0 userInfo:@{NSLocalizedDescriptionKey : @"Connection can't be initialized"}]];
    }
    /*
#if SD_UIKIT
    Class UIApplicationClass = NSClassFromString(@"UIApplication");
    if(!UIApplicationClass || ![UIApplicationClass respondsToSelector:@selector(sharedApplication)]) {
        return;
    }
    
    if (self.backgroundTaskId != UIBackgroundTaskInvalid) {
        UIApplication * app = [UIApplication performSelector:@selector(sharedApplication)];
        [app endBackgroundTask:self.backgroundTaskId];
        self.backgroundTaskId = UIBackgroundTaskInvalid;
    }
#endif
    */

}

- (void)cancel {
    @synchronized (self) {
        [self cancelInternal];
    }
}

- (void)cancelInternal {
    if (self.isFinished) return;
    [super cancel];
    
    if (self.ttHttpTask) {
        [self.ttHttpTask cancel];
        /*
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:SDWebImageDownloadStopNotification object:self];
        });
         */
        
        // As we cancelled the connection, its callback won't be called and thus won't
        // maintain the isFinished and isExecuting flags.
        if (self.isExecuting) self.executing = NO;
        if (!self.isFinished) self.finished = YES;
    }
    
    [self reset];
}

- (void)done {
    [self reset];
    self.finished = YES;
    self.executing = NO;
}

- (void)reset {
    
    WeakSelf;
    dispatch_barrier_async(self.barrierQueue, ^{
        if (!wself) {
            return ;
        }
        StrongSelf;
        [self.callbackBlocks removeAllObjects];
    });
    self.ttHttpTask = nil;
    dispatch_async(creat_complete_handle_queue(), ^{
        if (!wself) {
            return ;
        }
        StrongSelf;
        self.imageData = nil;
    });
    if (self.ownedSession) {
        [self.ownedSession invalidateAndCancel];
        self.ownedSession = nil;
    }
}

- (void)setFinished:(BOOL)finished {
    [self willChangeValueForKey:@"isFinished"];
    _finished = finished;
    [self didChangeValueForKey:@"isFinished"];
}

- (void)setExecuting:(BOOL)executing {
    [self willChangeValueForKey:@"isExecuting"];
    _executing = executing;
    [self didChangeValueForKey:@"isExecuting"];
}

- (BOOL)isConcurrent {
    return YES;
}



- (void)startLoadImg
{
    NSString *source = self.request.URL.tt_source;
    if ([TTImageMonitor enableImageMonitorForSource:source]) {
        [TTStopWatch start:self.request.URL.absoluteString];
    }
    //本地图
    if ([self.request.URL.absoluteString hasPrefix:@"file://"]) {
        NSData *localData = [NSData dataWithContentsOfURL:self.request.URL];
        if (localData) {
            [self callbackActionWithError:nil Obj:localData response:nil];
        } else {
            LOGE(@"local file read error: %@",self.request.URL.absoluteString);
            NSError *error = [NSError errorWithDomain:kTTWebImageDownloaderOperationErrorDomain code:kTTWebImageDownReadLocalFileFailedCode userInfo:nil];
            [self callbackActionWithError:error Obj:nil response:nil];
        }
        return;
    }
    
    
    __autoreleasing NSProgress *progress = nil;
    
    WeakSelf;
    
    self.ttHttpTask =  [[TTNetworkManager shareInstance] requestForBinaryWithResponse:self.request.URL.absoluteString
                                                                               params:nil
                                                                               method:@"GET"
                                                                     needCommonParams:NO
                                                                          headerField:self.request.allHTTPHeaderFields
                                                                      enableHttpCache:NO
                                                                    requestSerializer:nil responseSerializer:nil
                                                                             progress:&progress
                                                                             callback:^(NSError *error, id obj, TTHttpResponse *response) {
                                                                                 if (!wself) {
                                                                                     return ;
                                                                                 }
                                                                                 StrongSelf;
                                                                                 [self callbackActionWithError:error Obj:obj response:response];
                                                                             }];
    
    
    if (progress && self.hasProgressCallbackBlock) {
        [self.KVOController observe:progress
                            keyPath:@"completedUnitCount"
                            options:NSKeyValueObservingOptionNew
                              block:^(id  _Nullable observer, id  _Nonnull object, NSDictionary<NSString *,id> * _Nonnull change) {
                                  if (!wself) {
                                      return ;
                                  }
                                  StrongSelf;
                                  
                                  if ([object isKindOfClass:[NSProgress class]] ) {
                                      NSProgress * theProgress = object;
                                      NSInteger completedSize = (NSInteger)theProgress.completedUnitCount;
                                      if (theProgress.completedUnitCount >= theProgress.totalUnitCount) {
                                          [self.KVOController unobserve:theProgress];
                                          completedSize = (NSInteger)theProgress.totalUnitCount;
                                      }
                                      self.expectedSize = (NSInteger)theProgress.totalUnitCount;
                                      
                                      for (SDWebImageDownloaderProgressBlock progressBlock in [self callbacksForKey:kProgressCallbackKey]) {
                                           progressBlock(completedSize, self.expectedSize, self.request.URL);
                                      }
                                  }
                                  
                              }];
    }

}

- (void)callbackActionWithError:(NSError *)error Obj:(id)obj response:(TTHttpResponse *)response
{
    WeakSelf;
    dispatch_async(creat_complete_handle_queue(), ^{
        
        if (!wself) {
            return ;
        }
        StrongSelf;
        
        if (!error && obj && [obj isKindOfClass:[NSData class]]) {
            [self successAction:obj];
        } else {
            if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
                NSUInteger code = ((NSHTTPURLResponse *)response).statusCode;
                if (code == 304) {
                    [self cancelInternal];
                }
            }
            [self.ttHttpTask cancel];
            
            /*
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:SDWebImageDownloadStopNotification object:self];
            });
             */

            [self callCompletionBlocksWithError:error];
            [self done];
        }
    });
    
}

- (void)successAction:(NSData *)obj
{
    BOOL isHeifData = [[TTWebImageHEIFCoder sharedCoder] isHeifData:obj];
    NSString *source = self.request.URL.tt_source;
    if ([TTImageMonitor enableImageMonitorForSource:source]) {
        NSTimeInterval interval = [TTStopWatch stop:self.request.URL.absoluteString];
        double killoBytes = obj.length/1024.f;
       
        NSMutableDictionary *attributes = [NSMutableDictionary dictionary];
        [attributes setValue:@(interval) forKey:@"image_download_time"];
        [attributes setValue:@(killoBytes) forKey:@"image_size"];
        [attributes setValue:isHeifData ? @(0) : @(1) forKey:@"status"];
    
        if ([source isEqualToString:kBDTSourceUGCCell]) { //原来没统计UGC image的下载情况，现在统计，避免脏数据，条件语句换掉
            NSString *host = [self.request.URL host];
            [attributes setValue:host forKey:@"host"];
            SDImageFormat imageFormat = [NSData sd_imageFormatForImageData:obj];
            if (imageFormat == SDImageFormatGIF) {
                [attributes setValue:@(2) forKey:@"status"];
            } else if (imageFormat == SDImageFormatWebP) {
                [attributes setValue:@(3) forKey:@"status"];
            }
            [[TTMonitor shareManager] trackService:@"ugc_cell_image_download" attributes:[attributes copy]];
        } else {
            [[TTMonitor shareManager] trackService:[NSString stringWithFormat:@"image_monitor_%@",source] attributes:[attributes copy]];
        }
    }
    self.expectedSize = obj.length;
    self.imageData = [obj mutableCopy];
    obj = nil;
    
    if (![[NSURLCache sharedURLCache] cachedResponseForRequest:_request]) {
        responseFromCached = NO;
    }

    @synchronized(self) {
        self.ttHttpTask = nil;
        
        /*
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:SDWebImageDownloadStopNotification object:self];
            [[NSNotificationCenter defaultCenter] postNotificationName:SDWebImageDownloadFinishNotification object:self];
        });
         */
    }
    
    if ([self callbacksForKey:kCompletedCallbackKey].count > 0) {
        /**
         *  See #1608 and #1623 - apparently, there is a race condition on `NSURLCache` that causes a crash
         *  Limited the calls to `cachedResponseForRequest:` only for cases where we should ignore the cached response
         *    and images for which responseFromCached is YES (only the ones that cannot be cached).
         *  Note: responseFromCached is set to NO inside `willCacheResponse:`. This method doesn't get called for large images or images behind authentication
         */
        NSData *imageData = [self.imageData copy];
        if (self.options & SDWebImageDownloaderIgnoreCachedResponse && responseFromCached && [[NSURLCache sharedURLCache] cachedResponseForRequest:self.request]) {
            // hack
            [self callCompletionBlocksWithImage:nil imageData:nil error:nil finished:YES];
        } else if (imageData) {
            if ([TTImageMonitor enableImageMonitorForSource:source]) {
                [TTStopWatch start:self.request.URL.absoluteString];
            }
            UIImage *image = [UIImage sd_imageWithData:imageData];
            if ([TTImageMonitor enableImageMonitorForSource:source]) {
                NSTimeInterval interval = [TTStopWatch stop:self.request.URL.absoluteString];
                
                NSMutableDictionary *attributes = [NSMutableDictionary dictionary];
                [attributes setValue:@(interval) forKey:@"image_decode_time"];
                [attributes setValue:isHeifData ? @(0) : @(1) forKey:@"status"];
                if ([source isEqualToString:kBDTSourceUGCCell]) { //原来没统计UGC image的下载情况，现在统计，避免脏数据，条件语句换掉
                    
                } else {
                    [[TTMonitor shareManager] trackService:[NSString stringWithFormat:@"image_monitor_%@",source] attributes:[attributes copy]];
                }
            }
            NSString *key = [[SDWebImageAdapter sharedAdapter] cacheKeyForURL:self.request.URL];
            image = [self scaledImageForKey:key image:image];
            
            // Do not force decoding animated GIFs
            if (!image.images) {
                if (self.shouldDecompressImages) {
                    if (self.options & SDWebImageDownloaderScaleDownLargeImages) {
                        image = [UIImage decodedAndScaledDownImageWithImage:image];
                        imageData = UIImagePNGRepresentation(image);
                    } else {
                        image = [UIImage decodedImageWithImage:image];
                    }
                }
            }
            if (CGSizeEqualToSize(image.size, CGSizeZero)) {
                [self callCompletionBlocksWithError:[NSError errorWithDomain:SDWebImageErrorDomain code:0 userInfo:@{NSLocalizedDescriptionKey : @"Downloaded image has 0 pixels"}]];
            } else {
                [self callCompletionBlocksWithImage:image imageData:imageData error:nil finished:YES];
            }
        } else {
            [self callCompletionBlocksWithError:[NSError errorWithDomain:SDWebImageErrorDomain code:0 userInfo:@{NSLocalizedDescriptionKey : @"Image data is nil"}]];
        }
    }

    [self done];
    
}


#pragma mark Helper methods

+ (UIImageOrientation)orientationFromPropertyValue:(NSInteger)value {
    switch (value) {
        case 1:
            return UIImageOrientationUp;
        case 3:
            return UIImageOrientationDown;
        case 8:
            return UIImageOrientationLeft;
        case 6:
            return UIImageOrientationRight;
        case 2:
            return UIImageOrientationUpMirrored;
        case 4:
            return UIImageOrientationDownMirrored;
        case 5:
            return UIImageOrientationLeftMirrored;
        case 7:
            return UIImageOrientationRightMirrored;
        default:
            return UIImageOrientationUp;
    }
}

- (nullable UIImage *)scaledImageForKey:(nullable NSString *)key image:(nullable UIImage *)image {
    return SDScaledImageForKey(key, image);
}

- (BOOL)shouldContinueWhenAppEntersBackground {
    return self.options & SDWebImageDownloaderContinueInBackground;
}

- (void)callCompletionBlocksWithError:(nullable NSError *)error {
    [self callCompletionBlocksWithImage:nil imageData:nil error:error finished:YES];
}

- (void)callCompletionBlocksWithImage:(nullable UIImage *)image
                            imageData:(nullable NSData *)imageData
                                error:(nullable NSError *)error
                             finished:(BOOL)finished {
    NSArray<id> *completionBlocks = [self callbacksForKey:kCompletedCallbackKey];
    dispatch_main_async_safe(^{
        for (SDWebImageDownloaderCompletedBlock completedBlock in completionBlocks) {
            completedBlock(image, imageData, error, finished);
        }
    });
}


#pragma mark NSURLSessionDelegate

//只有方法，无实现，防止外界错误调用，导致网络库fallback到SD
- (void)URLSession:(NSURLSession *)session
          dataTask:(NSURLSessionDataTask *)dataTask
didReceiveResponse:(NSURLResponse *)response
 completionHandler:(void (^)(NSURLSessionResponseDisposition disposition))completionHandler {}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data {}

- (void)URLSession:(NSURLSession *)session
          dataTask:(NSURLSessionDataTask *)dataTask
 willCacheResponse:(NSCachedURLResponse *)proposedResponse
 completionHandler:(void (^)(NSCachedURLResponse *cachedResponse))completionHandler {}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task willPerformHTTPRedirection:(NSHTTPURLResponse *)response newRequest:(NSURLRequest *)request completionHandler:(void (^)(NSURLRequest * _Nullable))completionHandler {}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential *credential))completionHandler {}



#pragma mark - Swillze

//hook原有的SD初始化方法
+ (void)load
{
    static dispatch_once_t hookToken;
    dispatch_once(&hookToken, ^{
        //Chormium下才切换
        BOOL isChromiumEnabled = [TTRouteSelectionServerConfig sharedTTRouteSelectionServerConfig].isChromiumEnabled;
        BOOL isSDNetworkTransitionEnabled = [TTRouteSelectionServerConfig sharedTTRouteSelectionServerConfig].isSDNetworkTransitionEnabled;
        if (isChromiumEnabled && isSDNetworkTransitionEnabled) {
            SEL originalSelector = @selector(initWithRequest:inSession:options:);
            SEL swizzledSelector = @selector(initWithRequest:inSession:options:);
            Method originalMethod = class_getInstanceMethod([SDWebImageDownloaderOperation class], originalSelector);
            Method swizzledMethod = class_getInstanceMethod([self class], swizzledSelector);
            method_exchangeImplementations(originalMethod, swizzledMethod);
        } else if ([SSCommonLogic enableCustomSDDownloaderOperation]) {
            SEL originalSelector = @selector(initWithRequest:inSession:options:);
            SEL swizzledSelector = @selector(initWithRequest:inSession:options:);
            Method originalMethod = class_getInstanceMethod([SDWebImageDownloaderOperation class], originalSelector);
            Method swizzledMethod = class_getInstanceMethod([SDWebImageDownloaderOperationBugFix class], swizzledSelector);
            method_exchangeImplementations(originalMethod, swizzledMethod);
        }
    });
}


/**
 * fallback机制，万一调用到没覆盖到方法，切换回SD
 */
- (void)forwardInvocation:(NSInvocation *)invocation
{
    if ([self respondsToSelector:[invocation selector]]) {
        [invocation invokeWithTarget:self];
    }else{
        id p = nil;
        [invocation setReturnValue:&p];
        
        NSString *errorDesc = [NSString stringWithFormat:@"TTWebImageDownloaderOperation unrecognized selector :%@",NSStringFromSelector([invocation selector])];
        NSLog(@"%@",errorDesc);
        NSError *error = [[NSError alloc]initWithDomain:@"TTWebImageDownloaderOperation unrecognized selector" code:-10086 userInfo:@{@"errorDesc":errorDesc}];
        [self callCompletionBlocksWithError:error];
        [self recoverSDWebImageDownloaderOperation];
    }
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)selector
{
    NSMethodSignature *sig = [[self class] instanceMethodSignatureForSelector:selector];
    if(sig == nil) {
        sig = [NSMethodSignature signatureWithObjCTypes:"@@:"];
    }
    return sig;
}

- (void)recoverSDWebImageDownloaderOperation
{
    static dispatch_once_t recoverToken;
    dispatch_once(&recoverToken, ^{
        if ([self isKindOfClass:[TTWebImageDownloaderOperation class]]) {
            SEL originalSelector = @selector(initWithRequest:inSession:options:);
            SEL swizzledSelector = @selector(initWithRequest:inSession:options:);
            Method originalMethod = class_getInstanceMethod([SSCommonLogic enableCustomSDDownloaderOperation]?[SDWebImageDownloaderOperationBugFix class]: [SDWebImageDownloaderOperation class], originalSelector);
            Method swizzledMethod = class_getInstanceMethod([self class], swizzledSelector);
            method_exchangeImplementations(originalMethod, swizzledMethod);
        }
    });
}


#pragma mark - 事件回调处理queue
static dispatch_queue_t creat_complete_handle_queue() {
    static dispatch_queue_t complete_handle_queue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        complete_handle_queue = dispatch_queue_create("tt_network_complete_handle_queue", DISPATCH_QUEUE_SERIAL);
    });
    return complete_handle_queue;
}



@end




