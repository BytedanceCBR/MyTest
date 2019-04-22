//
//  TTVideoUploadOperation.m
//  Article
//
//  Created by 徐霜晴 on 16/10/12.
//
//

#import "TTVideoUploadOperation.h"
#import "TTNetworkManager.h"
#import "CommonURLSetting.h"
#import "NSDictionary+TTAdditions.h"
#import "NSObject+FBKVOController.h"
#import "TTUploadVideoNetWorkModel.h"

NSString * const TTVideoUploadErrorDomain = @"TTkVideoUploadErrorDomain";


@interface TTVideoUploadOperation ()

@property (nonatomic, copy) TTVideoUploadProgressBlock progressBlock;
@property (nonatomic, copy) TTVideoUploadCompleteBlock completedBlock;
@property (nonatomic, copy) TTVideoUploadUpdateVideoIdBlock updateVideIdBlock;

@property (nonatomic, copy) NSString *videoPath;
@property (nonatomic, copy) NSString *taskID;

@property (nonatomic, copy) NSString *uploadURL;
@property (nonatomic, copy) NSString *uploadId;

@property (nonatomic, assign) long long sizeOfVideoSlice;
@property (nonatomic, assign) long long uploadedSizeOfVideo;
@property (nonatomic, assign) long long totalSizeOfVideo;
@property (nonatomic, assign) NSInteger retryCount;

@property (nonatomic, strong) TTHttpTask *currentUploadTask;

@property (assign, nonatomic, getter = isExecuting) BOOL executing;
@property (assign, nonatomic, getter = isFinished) BOOL finished;

@property (nonatomic, copy) NSString *uploadApiStr;

@end


@implementation TTVideoUploadOperation

@synthesize executing = _executing;
@synthesize finished = _finished;

#pragma mark - life cycle

- (void)dealloc {
    LOGD(@"====== operation dealloced");
}

- (instancetype)initWithVideoPath:(NSString *)path
                           taskID:(NSString *)taskID
                         uploadId:(NSString *)uploadId
                    updateVideoId:(TTVideoUploadUpdateVideoIdBlock)updateVideoId
                         progress:(TTVideoUploadProgressBlock)progress
                        completed:(TTVideoUploadCompleteBlock)completed {
    self = [super init];
    if (self) {
        self.videoPath = path;
        self.taskID = taskID;
        self.uploadId = uploadId;
        self.updateVideIdBlock = updateVideoId;
        self.progressBlock = progress;
        self.completedBlock = completed;
    }
    return self;
}


- (void)userOtherUploadApi:(NSString *)uploadApiStr
{
    self.uploadApiStr = uploadApiStr;
}

#pragma mark - upload

- (void)start {
    
    if (self.isCancelled) {
        
        [self monitorVideoUploadWithStatus:TTVideoUploadStatusMonitorUploadCancelled error:nil result:nil];
        
        if (self.completedBlock) {
            self.completedBlock(NO, self.uploadId, [NSError errorWithDomain:TTVideoUploadErrorDomain code:TTVideoUploadErrorCodeUserCancelled userInfo:nil]);
        }
        LOGD(@"===== 上传cancelled 已上传 %@", @(self.uploadedSizeOfVideo));
        [self done];
        return;
    }
    
    self.executing = YES;
    
    TTUploadVideoRequestModel *requestModel = [[TTUploadVideoRequestModel alloc] init];
    if (!isEmptyString(self.uploadApiStr)) {
        requestModel._uri =  self.uploadApiStr;
    }
    if (!isEmptyString(self.uploadId)) {
        requestModel.upload_id = self.uploadId;
    }
    WeakSelf;
    [[TTNetworkManager shareInstance] requestModel:requestModel callback:^(NSError *error, NSObject<TTResponseModelProtocol> *responseModel) {
        StrongSelf;
        if (error) {
            
            [self monitorVideoUploadWithStatus:TTVideoUploadStatusMonitorGetUploadIDFailed error:error result:nil];
            
            // 701表示该uploadId已经上传完成
            if ([[error domain] isEqualToString:kTTNetworkErrorDomain] && [error code] == 701) {
                self.uploadId = nil;
            }
            
            if (self.completedBlock) {
                self.completedBlock(NO, self.uploadId, error);
            }
            LOGD(@"===== 获取上传信息失败 %@", error);
            [self done];
            return;
        }
        else {
            if ([responseModel isKindOfClass:[TTUploadVideoResponseModel class]]) {
                TTUploadVideoResponseModel *uploadResponse = (TTUploadVideoResponseModel *)responseModel;
                if (self.isCancelled) {
                    
                    [self monitorVideoUploadWithStatus:TTVideoUploadStatusMonitorUploadCancelled error:nil result:[uploadResponse toDictionary]];
                    
                    if (self.completedBlock) {
                        self.completedBlock(NO, self.uploadId, [NSError errorWithDomain:TTVideoUploadErrorDomain code:TTVideoUploadErrorCodeUserCancelled userInfo:nil]);
                    }
                    LOGD(@"===== 上传cancelled 已上传 %@", @(self.uploadedSizeOfVideo));
                    [self done];
                    return;
                }
                
                self.uploadId = uploadResponse.upload_id;
                self.uploadURL = uploadResponse.upload_url;
                self.sizeOfVideoSlice = uploadResponse.chunk_size.longLongValue;
                self.uploadedSizeOfVideo = uploadResponse.bytes.longLongValue;
                if (self.uploadedSizeOfVideo < 0) {
                    self.uploadedSizeOfVideo = 0;
                }
                
                if (self.updateVideIdBlock) {
                    self.updateVideIdBlock(self.uploadId);
                }
                
                NSError *fileAttributesError = nil;
                NSDictionary<NSFileAttributeKey, id> *fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:self.videoPath error:&fileAttributesError];
                if (fileAttributesError) {
                    
                    [self monitorVideoUploadWithStatus:TTVideoUploadStatusMonitorGetLocalVideoFailed error:fileAttributesError result:nil];
                    
                    if (self.completedBlock) {
                        self.completedBlock(NO, self.uploadId, fileAttributesError);
                    }
                    LOGD(@"===== 获取视频大小失败 %@", fileAttributesError);
                    [self done];
                    return;
                }
                self.totalSizeOfVideo = [fileAttributes fileSize];
                if (self.progressBlock) {
                    self.progressBlock(self.uploadedSizeOfVideo, self.totalSizeOfVideo);
                }
                
                LOGD(@"===== 开始上传视频 uploadId: %@", self.uploadId);
                [self uploadSingleVideoSlice];
            }
            else {
                if (self.completedBlock) {
                    self.completedBlock(NO, self.uploadId, [NSError errorWithDomain:TTVideoUploadErrorDomain code:TTVideoUploadErrorCodeNoUploadID userInfo:nil]);
                }
                [self done];
            }
        }
    }];
}

- (void)uploadVideoDataWithRangStart:(long long)rangeStart rangeEnd:(long long)rangeEnd fileData:(NSData *)fileData {
    LOGD(@"===== 开始上传视频 begin %@, end %@,  file Data %@", @(rangeStart), @(rangeEnd), @(fileData.length));
    
    NSMutableDictionary *headerField = [[NSMutableDictionary alloc] init];
    [headerField setValue:[NSString stringWithFormat:@"bytes %lld-%lld/%lld", rangeStart, rangeEnd-1, self.totalSizeOfVideo]
                   forKey:@"content-range"];
    
    __autoreleasing NSProgress *progress = nil;
    self.currentUploadTask = [[TTNetworkManager shareInstance] uploadWithURL:self.uploadURL headerField:headerField parameters:nil constructingBodyWithBlock:^(id<TTMultipartFormData> formData) {
        if (fileData) {
            [formData appendPartWithFileData:fileData name:@"file" fileName:@"video" mimeType:@"mp4"];
        }
    } progress:&progress needcommonParams:YES callback:^(NSError *error, id jsonObj) {
        
        // 如果调用了[self.currentUploadTask cancel]方法，这个回调会触发，并返回error { NSURLErrorDomain, NSURLErrorCancelled }
        // 由于约定了取消操作不应传出error，所以这里检查operation是否已取消，若取消则complete
        if (self.isCancelled) {
            
            [self monitorVideoUploadWithStatus:TTVideoUploadStatusMonitorUploadCancelled error:error result:jsonObj];
            
            if (self.completedBlock) {
                self.completedBlock(NO, self.uploadId, [NSError errorWithDomain:TTVideoUploadErrorDomain code:TTVideoUploadErrorCodeUserCancelled userInfo:nil]);
            }
            [self done];
            LOGD(@"====== 上传cancelled2 已上传 %@ 总共 %@", @(self.uploadedSizeOfVideo), @(self.totalSizeOfVideo));
            return;
        }
        
        if (error) {
            LOGD(@"上传失败");
        }
        [self singleSliceUploadFinishedWithResult:jsonObj error:error];
    }];
    
    if (progress) {
        LOGD(@"%@ ===== addobserver %@", self, progress);
        WeakSelf;
        [self.KVOController observe:progress keyPath:@"completedUnitCount" options:NSKeyValueObservingOptionNew block:^(id  _Nullable observer, id  _Nonnull object, NSDictionary<NSString *,id> * _Nonnull change) {
            StrongSelf;
            LOGD(@"%@ ===== kvo %@", self, object);
            NSProgress *progress = object;
            long long intProgress = 0;
            if (progress.completedUnitCount >= progress.totalUnitCount) {
                intProgress = progress.totalUnitCount;
                LOGD(@"%@ ======= removeObserver %@", self, progress);
                [self.KVOController unobserve:progress];
            } else {
                intProgress = progress.completedUnitCount;
            }
            
            if (self.progressBlock) {
                self.progressBlock(self.uploadedSizeOfVideo + intProgress, self.totalSizeOfVideo);
            }
        }];
    }
}

- (void)uploadSingleVideoSlice {
    
    if (self.isCancelled) {
        
        [self monitorVideoUploadWithStatus:TTVideoUploadStatusMonitorUploadCancelled error:nil result:nil];
        
        if (self.completedBlock) {
            self.completedBlock(NO, self.uploadId, [NSError errorWithDomain:TTVideoUploadErrorDomain code:TTVideoUploadErrorCodeUserCancelled userInfo:nil]);
        }
        [self done];
        
        LOGD(@"====== 上传cancelled 已上传 %@ 总共 %@", @(self.uploadedSizeOfVideo), @(self.totalSizeOfVideo));
        return;
    }
    
    @autoreleasepool {
        
        NSString *videoPath = self.videoPath;
        unsigned long long uploadedSizeOfVideo = self.uploadedSizeOfVideo;
        long long rangeStart = self.uploadedSizeOfVideo;
        long long rangeEnd = self.uploadedSizeOfVideo + self.sizeOfVideoSlice;
        long long totalSizeOfVideo = self.totalSizeOfVideo;
        long long sizeOfVideoSlice = self.sizeOfVideoSlice;
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSFileHandle *fileHandler = [NSFileHandle fileHandleForReadingAtPath:videoPath];
            [fileHandler seekToFileOffset:(unsigned long long)uploadedSizeOfVideo];
            NSData *fileData = nil;
            long long updatedRangeEnd = rangeEnd;
            if (rangeEnd > totalSizeOfVideo) {
                fileData = [fileHandler readDataToEndOfFile];
                updatedRangeEnd = totalSizeOfVideo;
            }
            else {
                fileData = [fileHandler readDataOfLength:sizeOfVideoSlice];
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self uploadVideoDataWithRangStart:rangeStart rangeEnd:updatedRangeEnd fileData:fileData];
            });
        });
    }
}

- (void)singleSliceUploadFinishedWithResult:(id)jsonObj error:(NSError *)error {
    if (error) {
        LOGD(@"===== 上传失败 第 %@ 次重试 \n error: %@ \n json: %@", @(self.retryCount), error, jsonObj);
        
        // 处理所传字节位置与期望不符的情况
        if ([jsonObj isKindOfClass:[NSDictionary class]] && [jsonObj tt_integerValueForKey:@"code"] == 10) {
            long long expectBytes = [jsonObj tt_longlongValueForKey:@"expect_bytes"];
            LOGD(@">>>>>>>>>> ###### 处理所传字节位置与期望不符的情况！expectBytes: %lld", expectBytes);
            self.uploadedSizeOfVideo = expectBytes;
            [self uploadSingleVideoSlice];
            return;
        }
        
        // 重试3次
        if (self.retryCount < 3) {
            [self uploadSingleVideoSlice];
        } else {
            
            [self monitorVideoUploadWithStatus:TTVideoUploadStatusMonitorUploadFailed error:error result:jsonObj];
            
            if (self.completedBlock) {
                self.completedBlock(NO, self.uploadId, error);
            }
            [self done];
        }
        self.retryCount ++;

    }
    else {
        [self uploadLaterSlicesContinued];
    }
}

- (void)uploadLaterSlicesContinued
{
    self.retryCount = 0;
    self.uploadedSizeOfVideo += self.sizeOfVideoSlice;
    if (self.uploadedSizeOfVideo > self.totalSizeOfVideo) {
        self.uploadedSizeOfVideo = self.totalSizeOfVideo;
    }
    LOGD(@">>>>>>>>>> 切片上传成功! %@", @(self.uploadedSizeOfVideo));
    
    if (self.uploadedSizeOfVideo < self.totalSizeOfVideo) {
        [self uploadSingleVideoSlice];
        
    } else { // 视频上传完成
        
        [self monitorVideoUploadWithStatus:TTVideoUploadStatusMonitorUploadCompleted error:nil result:nil];
        
        if (self.completedBlock) {
            self.completedBlock(YES, self.uploadId, nil);
        }
        [self done];
        
        LOGD(@">>>>>>>>>> 视频上传成功 !!! ");
    }
}

#pragma mark - override

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

- (BOOL)isAsynchronous {
    return YES;
}

- (BOOL)isConcurrent {
    return YES;
}

- (void)cancel
{
    LOGD(@">>>>>>>>>> cancel method called !!!");
    if (self.isFinished) {
        return;
    }
    [super cancel];
    [self.currentUploadTask cancel];
}

#pragma mark - State

- (void)done
{
    self.executing = NO;
    self.finished = YES;
    
    [self reset];
}

- (void)reset
{
    self.progressBlock = nil;
    self.completedBlock = nil;
    self.currentUploadTask = nil;
}

#pragma mark - Monitor

- (void)monitorVideoUploadWithStatus:(TTVideoUploadStatusMonitor)status error:(NSError *)error result:(id)result
{
    NSString *videoUploadId = self.uploadId;
    NSDictionary *info = @{@"video_id"  : videoUploadId ? : @"",
                           @"error_code": @(error.code),
                           @"response": [NSString stringWithFormat:@"%@", result],
                           @"progress"  : [NSString stringWithFormat:@"%lld/%lld", self.uploadedSizeOfVideo, self.totalSizeOfVideo],
                           @"retry_count": @(self.retryCount)
                           };
    LOGD(@">>>>>>>> info : %lu %@", (unsigned long)status, info);
    [[TTMonitor shareManager] trackService:@"ugc_video_upload" status:status extra:info];
}

@end
