//
//  TTLiveVideoUploadOperation.m
//  Article
//
//  Created by matrixzk on 9/22/16.
//
//

#import "TTLiveVideoUploadOperation.h"
#import "TTNetworkManager.h"
#import "TTMonitor.h"
#import <KVOController.h>

static NSInteger kSizeOfVideoSlice = 100000;

@interface TTLiveVideoUploadOperation ()

@property (nonatomic, copy) TTLiveVideoUploadProgressBlock  progressBlock;
@property (nonatomic, copy) TTLiveVideoUploadCompletedBlock completedBlock;
@property (nonatomic, copy) NSString *videoPath;

@property (nonatomic) long long totalSizeOfVideo;
@property (nonatomic) NSUInteger totalCountOfVideoSlice;
@property (nonatomic) NSUInteger currentIndexOfVideoSlice;
@property (nonatomic) NSInteger retryCount;
@property (nonatomic) NSUInteger hadUploadedSize;

@property (nonatomic, copy) NSString *videoUplaodURLStr;
@property (nonatomic, copy) NSString *videoId;

@property (nonatomic, strong) TTHttpTask *currentUploadTask;

@property (assign, nonatomic, getter = isExecuting) BOOL executing;
@property (assign, nonatomic, getter = isFinished) BOOL finished;

@end


@implementation TTLiveVideoUploadOperation

@synthesize executing = _executing;
@synthesize finished = _finished;

#ifdef DEBUG
- (void)dealloc
{
    LOGD(@">>>>>>>> TTLiveVideoUploadOperation Dealloc Called !!!!");
}
#endif

- (instancetype)initWithVideoPath:(NSString *)path progress:(TTLiveVideoUploadProgressBlock)progress completed:(TTLiveVideoUploadCompletedBlock)completed
{
    self = [super init];
    if (self) {
        _videoPath = path;
        _progressBlock = progress;
        _completedBlock = completed;
        
        _currentIndexOfVideoSlice = 0;
    }
    return self;
}


#pragma mark - Override

- (void)start
{
    if (self.isCancelled) {
        if (self.completedBlock) {
            self.completedBlock(nil, nil);
        }
        LOGD(@">>>>>>>>>> ######################## 上传 Cancelled !!! 已上传 %@ 个切片 - beginning of start()", @(self.currentIndexOfVideoSlice));
        [self done];
        
        return;
    }
    
    self.executing = YES;
    
    NSString *url = [NSString stringWithFormat:@"%@/upload_video_url/",[CommonURLSetting liveTalkURLString]];
    [[TTNetworkManager shareInstance] requestForJSONWithURL:url params:nil method:@"GET" needCommonParams:YES callback:^(NSError *error, id jsonObj){
        
        if (error) {
            if (self.completedBlock) {
                self.completedBlock(nil, error);
            }
            [self done];
            
            return;
        }
        
        if (self.isCancelled) {
            if (self.completedBlock) {
                self.completedBlock(nil, [NSError new]);
            }
            [self done];
            
            LOGD(@">>>>>>>>>> ######################## 上传 Cancelled !!! 已上传 %@ 个切片 - main(), get URL back, before upload slices", @(self.currentIndexOfVideoSlice));
            return;
        }
        
        NSDictionary *dataDict = [jsonObj tt_dictionaryValueForKey:@"data"];
        self.videoUplaodURLStr = [dataDict tt_stringValueForKey:@"url"];
        self.videoId = [dataDict tt_stringValueForKey:@"id"];
        
        if (isEmptyString(self.videoUplaodURLStr) || isEmptyString(self.videoId)) {
            if (self.completedBlock) {
                self.completedBlock(nil, error);
            }
            [self done];
            
            return;
        }
        
        self.totalSizeOfVideo = [[[NSFileManager defaultManager] attributesOfItemAtPath:self.videoPath error:nil] fileSize];
        self.totalCountOfVideoSlice = MAX(floor(self.totalSizeOfVideo / kSizeOfVideoSlice), 1);
        
        LOGD(@">>>>>>>>>> 开始上传视频(size : %@, totalCount: %@).", @(self.totalSizeOfVideo), @(self.totalCountOfVideoSlice));
        
        [self uploadSingleVideoSlice];
    }];
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

- (BOOL)isAsynchronous {
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
    [self reset];
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


#pragma mark - Upload Logic

- (void)uploadSingleVideoSlice
{
    if (self.isCancelled) {
        if (self.completedBlock) {
            self.completedBlock(nil, nil);
        }
        [self done];
                
        LOGD(@">>>>>>>>>> ######################## 上传 Cancelled !!! 已上传 %@ 个切片 - uploadSingleVideoSlice", @(self.currentIndexOfVideoSlice));
        
        return;
    }
    
    @autoreleasepool {
        
        NSFileHandle *fileHandler = [NSFileHandle fileHandleForReadingAtPath:self.videoPath];
        [fileHandler seekToFileOffset:(unsigned long long)(self.currentIndexOfVideoSlice * kSizeOfVideoSlice)];
        
        long long rangeStart = self.currentIndexOfVideoSlice == 0 ? 0 : (self.currentIndexOfVideoSlice * kSizeOfVideoSlice + 1);
        NSData *fileData;
        long long rangeEnd;
        if (self.currentIndexOfVideoSlice == self.totalCountOfVideoSlice) {
            fileData = [fileHandler readDataToEndOfFile];
            rangeEnd = self.totalSizeOfVideo - 1;
        } else {
            fileData = [fileHandler readDataOfLength:kSizeOfVideoSlice];
            rangeEnd = (self.currentIndexOfVideoSlice + 1 ) * kSizeOfVideoSlice;
        }
        
        LOGD(@">>>>>>>>>> 开始上传视频第  %@  个切片 ......", @(self.currentIndexOfVideoSlice));
        
        NSMutableDictionary *headerField = [[NSMutableDictionary alloc] init];
        [headerField setValue:[NSString stringWithFormat:@"bytes %lld-%lld/%lld", rangeStart, rangeEnd, self.totalSizeOfVideo]
                       forKey:@"content-range"];
        
        __autoreleasing NSProgress *progress = nil;
        self.currentUploadTask = [[TTNetworkManager shareInstance] uploadWithURL:self.videoUplaodURLStr headerField:headerField parameters:nil constructingBodyWithBlock:^(id<TTMultipartFormData> formData) {
            if (fileData) {
                [formData appendPartWithFileData:fileData name:@"file" fileName:@"video" mimeType:@"mp4"];
            }
        } progress:&progress needcommonParams:YES callback:^(NSError *error, id jsonObj) {
            if (error) {
                [self monitorVideoUploadWithError:error result:jsonObj];
            }
            [self singleSliceUploadFinishedWithResult:jsonObj error:error];
        }];
        
        if (progress) {
            WeakSelf;
            [self.KVOController observe:progress keyPath:@"completedUnitCount" options:NSKeyValueObservingOptionNew block:^(id  _Nullable observer, id  _Nonnull object, NSDictionary<NSString *,id> * _Nonnull change) {
                StrongSelf;
                NSProgress *progress = object;
                int64_t intProgress = 0;
                if (progress.completedUnitCount >= progress.totalUnitCount) {
                    intProgress = progress.totalUnitCount;
                } else {
                    intProgress = progress.completedUnitCount;
                }
                
                if (self.progressBlock) {
                    CGFloat progress = (CGFloat)(self.hadUploadedSize + intProgress) / self.totalSizeOfVideo;
                    self.progressBlock(progress);
                }
            }];
            //用KVOController解决progress KVO崩溃的坑
            //[progress addObserver:self forKeyPath:@"completedUnitCount" options:NSKeyValueObservingOptionNew context:nil];
        }
    }
}

- (void)singleSliceUploadFinishedWithResult:(id)jsonObj error:(NSError *)error
{
    if (error) {
LOGD(@">>>>>>>>>> ###### 第  %@  个切片上传 `失败`，第 %@ 次重试。\n error: %@, \n json : %@", @(self.currentIndexOfVideoSlice), @(self.retryCount), error, jsonObj);
        
        // 处理所传字节位置与期望不符的情况
        if ([jsonObj isKindOfClass:[NSDictionary class]] && [jsonObj[@"code"] integerValue] == 10) {
            long long expectBytes = [jsonObj[@"expect_bytes"] longLongValue];
            LOGD(@">>>>>>>>>> ###### 处理所传字节位置与期望不符的情况！expectBytes: %lld", expectBytes);
            self.currentIndexOfVideoSlice = (expectBytes / kSizeOfVideoSlice) - 1;
            [self uploadLaterSlicesContinued];
            return;
        }
        
        // 重试3次
        if (self.retryCount < 3) {
            [self uploadSingleVideoSlice];
        } else {
            if (self.completedBlock) {
                self.completedBlock(nil, error);
            }
            [self done];
        }
        self.retryCount ++;
        
    } else {
        
        [self uploadLaterSlicesContinued];
    }
}

- (void)uploadLaterSlicesContinued
{
    LOGD(@">>>>>>>>>> ###### 第  %@  个切片上传成功!", @(self.currentIndexOfVideoSlice));
    
    self.retryCount = 0;
    self.currentIndexOfVideoSlice ++;
    
    if (self.currentIndexOfVideoSlice <= self.totalCountOfVideoSlice) {
        
        self.hadUploadedSize = self.currentIndexOfVideoSlice * kSizeOfVideoSlice;
        [self uploadSingleVideoSlice];
        
    } else { // 视频上传完成
        
        if (self.completedBlock) {
            self.completedBlock(self.videoId, nil);
        }
        [self done];
        
        LOGD(@">>>>>>>>>> 视频(共%@个切片)上传成功 !!! ", @(self.totalCountOfVideoSlice));
    }
}

- (void)monitorVideoUploadWithError:(NSError *)error result:(id)result
{
    NSString *videoUploadId = self.videoId;
    NSDictionary *info = @{@"video_id"  : videoUploadId ? : @"",
                           @"curr_time" : @((NSInteger)[[NSDate date] timeIntervalSince1970]),
                           @"error_code": @(error.code),
                           @"result_msg": [NSString stringWithFormat:@"%@", result],
                           @"progress"  : [NSString stringWithFormat:@"%lu/%lu", (self.currentIndexOfVideoSlice + 1), self.totalCountOfVideoSlice],
                           @"retry_count": @(self.retryCount)
                           };
    LOGD(@">>>>>>>> info : %@", info);
    
    [[TTMonitor shareManager] trackService:@"ttlive_video_upload" status:1 extra:info];
}


#pragma mark - KVO Progress

//- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
//{
//    if ([object isKindOfClass:[NSProgress class]] && [keyPath isEqualToString:@"completedUnitCount"]) {
//        NSProgress *progress = object;
//        int64_t intProgress = 0;
//        if (progress.completedUnitCount >= progress.totalUnitCount) {
//            intProgress = progress.totalUnitCount;
//            [progress removeObserver:self forKeyPath:@"completedUnitCount"];
//        } else {
//            intProgress = progress.completedUnitCount;
//        }
//
//        if (self.progressBlock) {
//            CGFloat progress = (CGFloat)(self.hadUploadedSize + intProgress) / self.totalSizeOfVideo;
//            self.progressBlock(progress);
//        }
//    }
//}

@end
