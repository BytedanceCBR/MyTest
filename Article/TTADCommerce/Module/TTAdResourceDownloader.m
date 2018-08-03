//
//  TTAdResourceDownloader.m
//  Article
//
//  Created by carl on 2017/5/28.
//
//

#import "TTAdResourceDownloader.h"

#import "SSSimpleCache.h"
#import "TTAdLog.h"
#import "TTNetworkManager.h"
#import <TTImage/TTImageInfosModel.h>

static NSTimeInterval const defaultTimeout = 3 * 24 * 3600; //默认资源过期时间，单位second

@interface TTAdResourceDownloader ()
@property (nonatomic, strong, nullable) NSOperationQueue *downloadQueue;
@property (nonatomic, weak, nullable) NSOperation *lastAddedOperation;
@end

@implementation TTAdResourceDownloader
+ (instancetype)sharedManager {
    static dispatch_once_t onceToken;
    static id instance;
    dispatch_once(&onceToken, ^{
        instance = [self new];
    });
    return instance;
}

- (nonnull instancetype)init {
    self = [super init];
    if (self) {
        _downloadQueue = [NSOperationQueue new];
        _downloadQueue.maxConcurrentOperationCount = 1;
        _downloadQueue.name = @"com.toutiao.ad_resource";
        if (@available(iOS 8.0, *)) {
            _downloadQueue.qualityOfService = NSQualityOfServiceBackground;
        }
    }
    return self;
}

- (void)dealloc {
    DLog(@"RESOURCE %s image", __PRETTY_FUNCTION__);
    [_downloadQueue cancelAllOperations];
}

- (void)preloadResource:(NSArray<TTAdResourceModel *> *)models {
    [self preloadResource:models timeout:defaultTimeout];
}

- (void)preloadResource:(NSArray<TTAdResourceModel *> *)models timeout:(NSTimeInterval)timeout {
    timeout = MAX(timeout, 10);
    
    [models enumerateObjectsUsingBlock:^(TTAdResourceModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [self downloadDataWithModel:obj timeout:timeout];
    }];
}

- (void)downloadDataWithModel:(TTAdResourceModel *)model timeout:(NSTimeInterval)timeout {
    NSString *cacheKey = model.uri;
    if([[SSSimpleCache sharedCache] isCacheExist:cacheKey]) {
        DLog(@"RESOURCE  %s chached resource %@", __PRETTY_FUNCTION__, model.uri);
    } else {
        TTAdResourceOperation *operation = [TTAdResourceOperation opertationWithModel:model];
        if (operation) {
            __weak typeof(self) weakSelf = self;
            operation.completedBlock = ^(NSData * _Nullable data, NSError * _Nullable error, BOOL finished) {
              __unused __strong typeof(self) strongSelf = weakSelf;
                if (data && finished) {
                    [[SSSimpleCache sharedCache] setData:data forKey:cacheKey withTimeoutInterval:timeout];
                    DLog(@"RESOURCE  %s saved resource %@", __PRETTY_FUNCTION__, model.uri);
                } else {
                    //???
                    DLog(@"RESOURCE  %s error resource %@", __PRETTY_FUNCTION__, model.uri);
                }
            };
            [self.downloadQueue addOperation:operation];
            self.lastAddedOperation = operation;
        } else {
            DLog(@"RESOURCE  %s passed resource %@", __PRETTY_FUNCTION__, model.uri);
        }
    }
}

@end

@interface TTAdResourceOperation ()

@property (nonatomic, assign, getter=isExecuting) BOOL executing;
@property (nonatomic, assign, getter=isFinished) BOOL finished;
@property (nonatomic, strong) TTAdResourceModel *model;
@property (nonatomic, strong) NSError *combineError;

@end

@implementation TTAdResourceOperation

@synthesize executing = _executing;
@synthesize finished = _finished;

- (nonnull instancetype)initWith:(TTAdResourceModel *)model {
    self = [super init];
    if (self) {
        _model = model;
        _executing = NO;
        _finished = NO;
        
    }
    return self;
}

- (void)dealloc {
    DLog(@"RESOURCE %s ", __PRETTY_FUNCTION__);
}

- (void)done {
    self.finished = YES;
    self.executing = NO;
    [self reset];
}

- (void)reset {
    
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

@end

@interface TTAdResourceImageOperation ()
@end

@implementation TTAdResourceImageOperation


- (void)start {
    @synchronized (self) {
        if (self.isCancelled) {
            self.finished = YES;
            return;
        }
        NSDictionary *imageInfo = [self.model.resource copy];
        TTImageInfosModel *model = [[TTImageInfosModel alloc] initWithDictionary:imageInfo];
        [self startDownloadImageWithImageInfoModel:model index:0];
        self.executing = YES;
    }
}

- (void)startDownloadImageWithImageInfoModel:(TTImageInfosModel *)imageInfoModel index:(NSUInteger)index {
    NSString *urlString = [imageInfoModel urlStringAtIndex:index];
    __block NSUInteger _index = index;
    if (urlString == nil) {
        if (self.completedBlock) {
            self.completedBlock(nil, self.combineError, NO);
        }
        [self done];
        return;
    }
    [[TTNetworkManager shareInstance] requestForBinaryWithURL:urlString params:nil method:@"GET" needCommonParams:NO callback:^(NSError *error, id obj) {
        if (error) {
            [self startDownloadImageWithImageInfoModel:imageInfoModel index:++_index];
            return;
        }
        if (obj && [obj isKindOfClass:[NSData class]]) {
            if (self.completedBlock) {
                self.completedBlock(obj, nil, YES);
            }
            [self done];
        }
    }];
}

@end

@interface TTAdResourceVideoOperation ()
@end

@implementation TTAdResourceVideoOperation

- (void)start {
    @synchronized (self) {
        if (self.isCancelled) {
            self.finished = YES;
            return;
        }
        NSArray *urls = self.model.video_urls;
        [self startDownloadVideo:urls index:0];
        self.executing = YES;
    }
}

- (void)startDownloadVideo:(NSArray<NSString *> *)urls index:(NSUInteger)index {
    NSString *urlString;
    if (index < urls.count) {
        urlString = urls[index];
    } else {
        if (self.completedBlock) {
            self.completedBlock(nil, self.combineError, YES);
        }
        [self done];
        return;
    }
    __block NSUInteger _index = index;
    [[TTNetworkManager shareInstance] requestForBinaryWithURL:urlString params:nil method:@"GET" needCommonParams:NO callback:^(NSError *error, id obj) {
        if (error) {
            [self startDownloadVideo:urls index:++_index];
            return;
        }
        if (obj && [obj isKindOfClass:[NSData class]]) {
            if (self.completedBlock) {
                self.completedBlock(obj, self.combineError, YES);
            }
            [self done];
        }
    }];
}

@end

@interface TTAdResourceFileOperation ()
@end

@implementation TTAdResourceFileOperation

- (void)start {
    @synchronized (self) {
        if (self.isCancelled) {
            self.finished = YES;
            return;
        }
        if (![self.model.resource isKindOfClass:[NSDictionary class]]) {
            [self done];
            return;
        }
        NSString *url = self.model.resource[@"url"];
        [self startDownloadFile:url];
        self.executing = YES;
    }
}

- (void)startDownloadFile:(NSString *)url {
    if (!([url isKindOfClass:[NSString class]] && url.length > 0)) {
        [self done];
    }
    
    [[TTNetworkManager shareInstance] requestForBinaryWithURL:url params:nil method:@"GET" needCommonParams:NO callback:^(NSError *error, id obj) {
        if (error) {
            if (self.completedBlock) {
                self.completedBlock(nil, self.combineError, YES);
            }
            [self done];
            return;
        }
        if (obj && [obj isKindOfClass:[NSData class]]) {
            if (self.completedBlock) {
                self.completedBlock(obj, self.combineError, YES);
            }
            [self done];
        }
    }];
}

@end


@implementation TTAdResourceOperation (TTAdResourcrOperationFactory)

+ (instancetype)opertationWithModel:(TTAdResourceModel *)model {
    NSCParameterAssert([model isKindOfClass:[TTAdResourceModel class]]);
    if (![model isKindOfClass:[TTAdResourceModel class]]) {
        return nil;
    }
    TTAdResourceOperation *operation = nil;
    if ([model.contentType hasPrefix:@"image"]) {
        operation = [[TTAdResourceImageOperation alloc] initWith:model];
    } else if ([model.contentType hasPrefix:@"video"]) {
         //operation = [[TTAdResourceVideoOperation alloc] initWith:model];
    } else if ([model.contentType containsString:@"json"]) {
        operation = [[TTAdResourceFileOperation alloc] initWith:model];
        operation.queuePriority = NSOperationQueuePriorityHigh;
    } else {
        operation = [[TTAdResourceFileOperation alloc] initWith:model];
    }
    return operation;
}

@end
