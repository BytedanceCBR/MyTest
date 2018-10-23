//
//  TTImageIcloudDownloaderOperation.m
//  Pods
//
//  Created by tyh on 2017/7/11.
//
//

#import "TTImagePickerIcloudDownloaderOperation.h"
#import "TTImagePickerManager.h"
#import "TTBaseMacro.h"

static NSString *const KIcloudProgressCallbackKey = @"progress";
static NSString *const KIcloudCompletedCallbackKey = @"completed";

typedef NSMutableDictionary<NSString *, id> IcloudCallbacksDictionary;

@interface TTImagePickerIcloudDownloaderOperation()

@property (nonatomic,strong)PHAsset *asset;
@property (nonatomic,assign)PHImageRequestID requestID;
@property (nonatomic, strong) dispatch_queue_t barrierQueue;
@property (nonatomic, strong) NSMutableArray<IcloudCallbacksDictionary *> *callbackBlocks;

@end

@implementation TTImagePickerIcloudDownloaderOperation

@synthesize executing = _executing;
@synthesize finished = _finished;

- (instancetype)initWithAsset:(PHAsset *)asset
{
    self = [super init];
    if (self) {
        _asset = [asset copy];
        _executing = NO;
        _finished = NO;
        _callbackBlocks = [NSMutableArray new];
        _barrierQueue = dispatch_queue_create("TTImagePickerIcloudDownloaderOperationBarrierQueue", DISPATCH_QUEUE_CONCURRENT);
        self.requestID = 0;
    }
    return self;
}


#pragma mark - Status
- (void)start
{
    @synchronized (self) {
        if (self.isCancelled) {
            self.finished = YES;
            [self reset];
            return;
        }
        self.executing = YES;
    }
    
    
    PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
    options.progressHandler = ^(double progress, NSError *error, BOOL *stop, NSDictionary *info) {
        [self callProgressBlocksWithProgress:progress error:error isStop:stop info:info];
    };
    options.networkAccessAllowed = YES;
    options.resizeMode = PHImageRequestOptionsResizeModeFast;
    
    WeakSelf;
    self.requestID = [[PHImageManager defaultManager] requestImageDataForAsset:self.asset options:options resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
        
        if (wself) {
            [self callCompletionBlocksWithData:imageData dataUTI:dataUTI orientation:orientation info:info];
            [self done];
        }
    }];
    

}

- (void)cancel
{
    @synchronized (self) {
        if (self.isFinished || !self.isExecuting) return;
        [super cancel];
        //太坑了...
        if (self.requestID != 0) {
            [[PHImageManager defaultManager] cancelImageRequest:self.requestID];
        }
        if (self.isExecuting) self.executing = NO;
        if (!self.isFinished) self.finished = YES;
        [self reset];
    }
}

- (void)done
{
    self.finished = YES;
    self.executing = NO;
    [self reset];
}

- (void)reset
{
    dispatch_barrier_async(self.barrierQueue, ^{
        [self.callbackBlocks removeAllObjects];
    });
    self.asset = nil;
}

- (BOOL)isConcurrent {
    return YES;
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

- (void)addCompletion:(IcloudCompletion)completion progressHandler:(IcloudProgressHandler)progressHandler
{
    IcloudCallbacksDictionary *callbacks = [NSMutableDictionary new];
    if (progressHandler) callbacks[KIcloudProgressCallbackKey] = [progressHandler copy];
    if (completion) callbacks[KIcloudCompletedCallbackKey] = [completion copy];
    dispatch_barrier_async(self.barrierQueue, ^{
        [self.callbackBlocks addObject:callbacks];
    });
}


- (nullable NSArray<id> *)callbacksForKey:(NSString *)key {
    __block NSMutableArray<id> *callbacks = nil;
    dispatch_sync(self.barrierQueue, ^{
        //容错
        callbacks = [[self.callbackBlocks valueForKey:key] mutableCopy];
        [callbacks removeObjectIdenticalTo:[NSNull null]];
    });
    return [callbacks copy];
}


- (void)callCompletionBlocksWithData:(NSData * _Nullable)imageData
                             dataUTI:(NSString * _Nullable)dataUTI
                         orientation:(UIImageOrientation)orientation
                                info:(NSDictionary * _Nullable)info
{
    NSArray<id> *completionBlocks = [self callbacksForKey:KIcloudCompletedCallbackKey];
    dispatch_main_async_safe_ttImagePicker(^{
        for (IcloudCompletion completedBlock in completionBlocks) {
            completedBlock (imageData,dataUTI,orientation,info);
        }
    });
}


- (void)callProgressBlocksWithProgress:(double)progress
                                 error:(NSError *)error
                                isStop:(BOOL *)stop
                                  info:(NSDictionary *)info
{
    NSArray<id> *progressBlocks = [self callbacksForKey:KIcloudProgressCallbackKey];
    dispatch_main_async_safe_ttImagePicker(^{
        for (IcloudProgressHandler progressBlock in progressBlocks) {
            progressBlock (progress,error,stop,info);
        }
    });
}

- (void)dealloc
{
    NSLog(@"TTImagePickerIcloudDownloaderOperation dealloc");
}

@end
