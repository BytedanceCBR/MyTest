//
//  TTForumPostVideoOperation.m
//  Article
//
//  Created by 徐霜晴 on 17/3/5.
//
//

#import "TTForumPostVideoOperation.h"

#import "FRUploadImageManager.h"
#import "NetworkUtilities.h"
#import "FRPostThreadDefine.h"
#import "TTForumPostThreadManager.h"
#import "FRForumMonitor.h"
#import "TTForumUploadVideoModel.h"
#import "TTUGCDefine.h"
#import "FRUploadImageManager.h"
#import "TTPostVideoCacheHelper.h"
#import "TTForumPostThreadTaskCenter.h"
#import "TTForumVideoUploaderSDKManager.h"
#import "TTIndicatorView.h"
#import "TTKitchenHeader.h"
#import "FRForumNetWorkMonitor.h"
#import "TTUGCBacktraceLogger.h"
#import "TTBaseMacro.h"
#import "NSObject+TTAdditions.h"
#import "NSDictionary+TTAdditions.h"
#import "TTVideoPublishMonitor.h"

@interface TTForumPostVideoOperation ()<TTVideoUploadClientProtocol>

@property (nonatomic, assign) TTForumPostThreadOperationState state;
@property (nonatomic, assign) TTForumPostThreadOperationCancelHint cancelHint;
@property (nonatomic, strong) TTForumPostThreadTask *task;
@property (nonatomic, copy) TTForumPostThreadOperationStateUpdatedBlock stateUpdatedBlock;
@property (nonatomic, copy) TTForumPostThreadOperationSuccessBlock successBlock;
@property (nonatomic, copy) TTForumPostThreadOperationFailureBlock failureBlock;
@property (nonatomic, copy) TTForumPostThreadOperationCancelledBlock cancelledBlock;

@property (nonatomic, strong) FRUploadImageManager *uploadImageManager;


@property (nonatomic, assign) int64_t startTime;
@property (nonatomic, assign) uint64_t startUploadTime;

@end

@implementation TTForumPostVideoOperation

@synthesize taskID = _taskID;
@synthesize concernID = _concernID;
@synthesize taskType = _taskType;
@synthesize executing = _executing;
@synthesize finished = _finished;
@synthesize cancellable = _cancellable;

- (instancetype)initWithPostThreadTaskID:(NSString *)taskID
                               concernID:(NSString *)concernID
                           suggestedTask:(TTForumPostThreadTask *)suggestedTask
                       stateUpdatedBlock:(TTForumPostThreadOperationStateUpdatedBlock)stateUpdatedBlock
                            successBlock:(TTForumPostThreadOperationSuccessBlock)successBlock
                          cancelledBlock:(TTForumPostThreadOperationCancelledBlock)cancelledBlock
                            failureBlock:(TTForumPostThreadOperationFailureBlock)failureBlock {
    self = [super init];
    if (self) {
        _cancellable = YES;
        self.taskID = taskID;
        self.concernID = concernID;
        self.stateUpdatedBlock = stateUpdatedBlock;
        self.successBlock = successBlock;
        self.failureBlock = failureBlock;
        self.cancelledBlock = cancelledBlock;
        self.taskType = TTForumPostThreadTaskTypeVideo;
        self.state = TTForumPostThreadOperationStatePending;
        if (suggestedTask) {
            self.task = suggestedTask;
            suggestedTask.finishError = nil;
            [self callStateUpdatedBlockForTask:suggestedTask lastState:TTForumPostThreadOperationStateUnknown currentState:TTForumPostThreadOperationStatePending];
        }
        else {
            WeakSelf;
            [[TTForumPostThreadTaskCenter sharedInstance] asyncGetTaskWithID:taskID concernID:concernID completionBlock:^(TTForumPostThreadTask *task) {
                StrongSelf;
                if (!task) {
                    [self callFailureBlockForTask:nil error:[NSError errorWithDomain:kFRPostThreadErrorDomain code:FRPostThreadErrorCodeCannotFindTask userInfo:nil]];
                    return;
                }
                task.finishError = nil;
                [self callStateUpdatedBlockForTask:task lastState:TTForumPostThreadOperationStateUnknown currentState:TTForumPostThreadOperationStatePending];
                self.task = task;
            }];
        }
        
    }
    return self;
}

- (TTForumPostThreadTask *)task {
#if DEBUG
    _task.debug_currentMethod = [TTUGCBacktraceLogger ttugc_backtraceOfCurrentThread];
#endif
    return _task;
}

- (void)updateToState:(TTForumPostThreadOperationState)updatedState {
    
    @synchronized (self) {
        /*
         * 已经是终极状态
         */
        if (self.state == TTForumPostThreadOperationStateCancelled ||
            self.state == TTForumPostThreadOperationStateFailed ||
            self.state == TTForumPostThreadOperationStateSuccessed) {
            return;
        }
        
        TTForumPostThreadOperationState lastState = self.state;
        self.state = updatedState;
        
        switch (updatedState) {
            case TTForumPostThreadOperationStateSuccessed:
                [self callSuccessBlockForTask:self.task];
                [self done];
                break;
            case TTForumPostThreadOperationStateFailed:
                [self callFailureBlockForTask:self.task error:self.task.finishError];
                [self done];
                break;
            case TTForumPostThreadOperationStateCancelled:
                [self callCancelledBlockForTask:self.task cancelHint:self.cancelHint];
                [self done];
                break;
            case TTForumPostThreadOperationStateResumed:
                [self beginTask];
                [self callStateUpdatedBlockForTask:self.task lastState:lastState currentState:updatedState];
                break;
            default:
                break;
        }
    }
}

#pragma mark - call block

- (void)callStateUpdatedBlockForTask:(TTForumPostThreadTask *)task lastState:(TTForumPostThreadOperationState)lastState currentState:(TTForumPostThreadOperationState)currentState {
    if (self.stateUpdatedBlock) {
        if ([NSThread isMainThread]) {
            self.stateUpdatedBlock(task, lastState, currentState);
        }
        else {
            WeakSelf;
            dispatch_async(dispatch_get_main_queue(), ^{
                StrongSelf;
                if (self.stateUpdatedBlock) {
                    self.stateUpdatedBlock(task, lastState, currentState);
                }
            });
        }
    }
}

- (void)callCancelledBlockForTask:(TTForumPostThreadTask *)task cancelHint:(TTForumPostThreadOperationCancelHint)cancelHint {
    if (self.cancelledBlock) {
        if ([NSThread isMainThread]) {
            self.cancelledBlock(task, cancelHint);
        }
        else {
            WeakSelf;
            dispatch_async(dispatch_get_main_queue(), ^{
                StrongSelf;
                if (self.cancelledBlock) {
                    self.cancelledBlock(task, cancelHint);
                }
            });
        }
    }
}

- (void)callFailureBlockForTask:(TTForumPostThreadTask *)task error:(NSError *)error {
    if (self.failureBlock) {
        if ([NSThread isMainThread]) {
            self.failureBlock(task, error);
        }
        else {
            WeakSelf;
            dispatch_async(dispatch_get_main_queue(), ^{
                StrongSelf;
                if (self.failureBlock) {
                    self.failureBlock(task, error);
                }
            });
        }
    }
}

- (void)callSuccessBlockForTask:(TTForumPostThreadTask *)task {
    if (self.successBlock) {
        if ([NSThread isMainThread]) {
            self.successBlock(task, task.responseDict);
        }
        else {
            WeakSelf;
            dispatch_async(dispatch_get_main_queue(), ^{
                StrongSelf;
                if (self.successBlock) {
                    self.successBlock(task, task.responseDict);
                }
            });
        }
    }
}

#pragma mark - accessors
#pragma mark - override

- (void)start {
    if (self.state != TTForumPostThreadOperationStatePending) {
        [self done];
        return;
    }
    self.executing = YES;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [[TTForumPostThreadTaskCenter sharedInstance] asyncGetTaskWithID:self.taskID concernID:self.concernID completionBlock:^(TTForumPostThreadTask *task) {
            self.task = task;
            if (!self.task) {
                [self callFailureBlockForTask:nil error:[NSError errorWithDomain:kFRPostThreadErrorDomain code:FRPostThreadErrorCodeCannotFindTask userInfo:nil]];
                return;
            }
            self.task.finishError = nil;
            [self updateToState:TTForumPostThreadOperationStateResumed];
        }];
    });
}

- (void)setFinished:(BOOL)finished {
    if (_finished == finished) {
        return;
    }
    [self willChangeValueForKey:@"isFinished"];
    _finished = finished;
    [self didChangeValueForKey:@"isFinished"];
}

- (void)setExecuting:(BOOL)executing {
    if (_executing == executing) {
        return;
    }
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

- (void)done
{
    self.executing = NO;
    self.finished = YES;
}

- (FRUploadImageManager *)uploadImageManager {
    if (!_uploadImageManager) {
        _uploadImageManager = [[FRUploadImageManager alloc] init];
    }
    return _uploadImageManager;
}

#pragma mark - work

- (void)cancelWithHint:(TTForumPostThreadOperationCancelHint)cancelHint {
    if (cancelHint == TTForumPostThreadOperationCancelHintCancel) {
        [GET_SERVICE_BY_PROTOCOL(TTVideoPublishMonitor) trackVideoWithType:self.task.video.videoSourceType state:TTVideoPublishTrack4GNetworkPaused extra:self.task.extraTrackForVideo];
    }
    self.task.finishError = [NSError errorWithDomain:kFRPostThreadErrorDomain code:FRPostThreadErrorCodeUserCancelled userInfo:nil];
    self.cancelHint = cancelHint;
    [self updateToState:TTForumPostThreadOperationStateCancelled];
    
    uint64_t endUploadTime = [NSObject currentUnixTime];
    uint64_t timeConsume = [NSObject machTimeToSecs:endUploadTime - self.startUploadTime] * 1000;
    
    self.task.video.timeConsume = timeConsume;
    
    NSError *finishError = [NSError errorWithDomain:kFRPostForumErrorDomain code:FRPostThreadErrorCodeUserCancelled userInfo:nil];
    
    NSMutableDictionary *monitorDict = [[NSMutableDictionary alloc] init];
    [monitorDict setValue:@(finishError.code) forKey:@"erro_no"];
    [monitorDict setValue:finishError.domain forKey:@"erro_domain"];
    [monitorDict setValue:@(self.task.video.timeConsume) forKey:@"video_networks"];
    [monitorDict setValue:@(self.task.retryCount > 1 ? 1 : 0) forKey:@"is_resend"];
    
    [FRForumMonitor ugcVideoSDKPostThreadMonitorUploadVideoPerformanceWithStatus:TTPostVideoStatusMonitorVideoUploadSdkCancelled
                                                                           extra:[monitorDict copy]
                                                                           retry:self.task.errorPosition != TTForumPostThreadTaskErrorPositionNone
                                                                    isShortVideo:self.task.isShortVideo];
    
    self.task.errorPosition = TTForumPostThreadTaskErrorPositionVideo;
    self.task.finishError = finishError;
    
    if (cancelHint == TTForumPostThreadOperationCancelHintRemove) {
        [[TTForumVideoUploaderSDKManager sharedUploader] cancelAndRemoveUploadWithTaskID:self.taskID];
    }
    else {
        [[TTForumVideoUploaderSDKManager sharedUploader] cancelVideoUploadWithTaskID:self.taskID];
    }
    
    [super cancel];
}

- (void)beginTask {
    
    WeakSelf;
    dispatch_block_t beginBlock = ^(){
        
        if (!TTNetworkConnected()) {
            self.task.finishError = [NSError errorWithDomain:kFRPostThreadErrorDomain code:FRPostThreadErrorCodeNoNetwork userInfo:nil];
            [self updateToState:TTForumPostThreadOperationStateFailed];
            return;
        }
        
        StrongSelf;
        self.startTime = [NSObject currentUnixTime];
        
        if ([self.task needUploadVideo]) {
            [self uploadVideo];
        }
        else if ([self.task needUploadVideoCover]) {
            [self uploadCoverImage];
        }
        else {
            [self postVideoThread];
        }
    };
    
    if (self.task.retryCount == 0 && self.task.video.coverImage) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            if (self.task.retryCount == 0) {
                [self.task compressVideoCoverImage];
            }
            dispatch_async(dispatch_get_main_queue(), beginBlock);
        });
    }
    else {
        beginBlock();
    }
}

- (void)uploadVideo {
    
    if (self.state != TTForumPostThreadOperationStateResumed) {
        return;
    }
    
    self.startUploadTime = [NSObject currentUnixTime];
    
    NSString *videoPath = [NSString stringWithFormat:@"%@%@", NSHomeDirectory(), self.task.video.videoPath];
    BOOL fileExist = [[NSFileManager defaultManager] fileExistsAtPath:videoPath];
    if (fileExist) {
        [[TTForumVideoUploaderSDKManager sharedUploader] uploadVideoWithTaskID:self.task.taskID videoFilePath:videoPath coverImageTimestamp:self.task.video.coverImageTimestamp clientDelegate:self];
    }
    else {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            self.task.finishError = [NSError errorWithDomain:NSCocoaErrorDomain code:NSFileReadNoSuchFileError userInfo:nil];
            [self updateToState:TTForumPostThreadOperationStateFailed];
        });
    }
}

- (void)uploadCoverImage {
    if (self.state != TTForumPostThreadOperationStateResumed) {
        return;
    }
    
    WeakSelf;
    NSMutableArray *images = [[NSMutableArray alloc] initWithObjects:self.task.video.coverImage, nil];
    [self.uploadImageManager uploadPhotos:images withTask:self.task extParameter:@{@"source":@"video"} progressBlock:^(int expectCount, int receivedCount) {
    } finishBlock:^(NSError *error, NSArray<FRUploadImageModel *> *finishUpLoadModels) {
        StrongSelf;
        if (self.state != TTForumPostThreadOperationStateResumed) {
            return;
        }
        NSError *finishError = nil;
        if (isEmptyString([[finishUpLoadModels lastObject] webURI]) || error) {
            finishError = [NSError errorWithDomain:kFRPostThreadErrorDomain code:FRPostThreadErrorCodeUploadImgError userInfo:nil];
        }
        
        if (finishError) {
            NSMutableDictionary *monitorDict = [[NSMutableDictionary alloc] init];
            [monitorDict setValue:@(finishError.code) forKey:@"erro_no"];
            [monitorDict setValue:finishError.domain forKey:@"erro_domain"];
            [FRForumMonitor ugcVideoSDKPostThreadMonitorUploadVideoPerformanceWithStatus:TTPostVideoStatusMonitorImageUploadSDKFailed
                                                                                   extra:[monitorDict copy]
                                                                                   retry:self.task.errorPosition != TTForumPostThreadTaskErrorPositionNone
                                                                            isShortVideo:self.task.isShortVideo];
            self.task.errorPosition = TTForumPostThreadTaskErrorPositionImage;
            self.task.finishError = finishError;
            [self updateToState:TTForumPostThreadOperationStateFailed];
        }
        else {
            self.task.video.coverImage.webURI = [[finishUpLoadModels lastObject] webURI];
            self.task.uploadProgress = TTForumPostVideoThreadTaskBeforePostThreadProgress;
            [self postVideoThread];
        }
    }];
}

- (void)postVideoThread {
    
    if (self.state != TTForumPostThreadOperationStateResumed) {
        return;
    }
    
    _cancellable = NO;
    
    WeakSelf;
    
    NSMutableDictionary *monitorDict = [[NSMutableDictionary alloc] init];
    
    [TTForumPostThreadManager postVideoThreadTask:self.task finishBlock:^(NSError *error, id respondObj, FRForumMonitorModel *monitorModel, uint64_t networkConsume) {
        StrongSelf;
        if (self.state != TTForumPostThreadOperationStateResumed) {
            return;
        }
        NSMutableDictionary *responseDic = nil;
        if ([respondObj isKindOfClass:[NSDictionary class]] && [respondObj[@"data"] isKindOfClass:[NSDictionary class]]) {
            responseDic = [NSMutableDictionary dictionaryWithDictionary:respondObj[@"data"]];
            if ([responseDic objectForKey:@"group_id"]) { //发送UGC视频，uniqueID为group_id
                //JSONModel解析完成的group_id为NSDecimalNumber，转成string然后再转成NSNumber，防止精度溢出
                NSString *groupIDString = [NSString stringWithFormat:@"%@", [responseDic objectForKey:@"group_id"]];
                NSNumber *groupID = @([groupIDString longLongValue]);
                [responseDic setValue:groupID forKey:@"group_id"];
                [responseDic setValue:groupID forKey:@"uniqueID"];
                [responseDic setValue:self.task.video.videoPath forKey:@"video_local_url"];
                [[TTPostVideoCacheHelper sharedHelper] addVideoCacheWith:[groupID stringValue] url:self.task.video.videoPath];
            }
            else if ([responseDic valueForKey:@"id"]) { //发送小视频，uniqueID为id
                NSString *groupIDString = [NSString stringWithFormat:@"%@", [responseDic valueForKey:@"id"]];
                NSNumber *groupID = @([groupIDString longLongValue]);
                [responseDic setValue:groupID forKey:@"uniqueID"];
                [responseDic setValue:self.task.video.videoPath forKey:@"video_local_url"];
            }
            else {
                error = error ?: [NSError errorWithDomain:kFRPostForumErrorDomain code:FRPostThreadErrorCodeError userInfo:nil];
            }
        }
        else {
            error = error ?: [NSError errorWithDomain:kFRPostForumErrorDomain code:FRPostThreadErrorCodeError userInfo:nil];
        }
        
        // 端监控
        uint64_t endTime = [NSObject currentUnixTime];
        uint64_t total = [NSObject machTimeToSecs:endTime - self.startTime] * 1000;
        
        // 发视频任务总耗时
        [monitorDict setValue:@(total) forKey:@"total"];
        // 视频封面耗时
        [monitorDict setValue:@(self.task.video.coverImage.networkConsume) forKey:@"cover_networks"];
        // 视频上传耗时
        [monitorDict setValue:@(self.task.video.timeConsume) forKey:@"video_networks"];
        // 发文接口耗时
        [monitorDict setValue:@(networkConsume) forKey:@"network"];
        // 是否是重试
        [monitorDict setValue:@(self.task.retryCount > 0 ? 1 : 0) forKey:@"is_resend"];
        // 错误码
        [monitorDict setValue:@(error.code) forKey:@"erro_no"];
        [monitorDict setValue:error.domain forKey:@"erro_domain"];

        NSInteger monitorStatus = error? TTPostVideoStatusMonitorPostThreadFailed: TTPostVideoStatusMonitorPostThreadSucceed;
        if ([error.domain isEqualToString:JSONModelErrorDomain]) {
            monitorStatus = TTPostVideoStatusMonitorPostThreadJSONModelFailed;
        }
        
        [FRForumMonitor ugcVideoSDKPostThreadMonitorUploadVideoPerformanceWithStatus:monitorStatus
                                                                               extra:[monitorDict copy]
                                                                               retry:self.task.errorPosition != TTForumPostThreadTaskErrorPositionNone
                                                                        isShortVideo:self.task.isShortVideo];
        
        if (monitorModel) {
            monitorModel.monitorExtra = monitorDict;
            if (error && [error.domain isEqualToString:kFRPostForumErrorDomain]) {
                monitorModel.monitorStatus = kTTNetworkMonitorPostStatusVideoDataError;
            }
        }
        
        
        self.task.finishError = error;
        self.task.errorPosition = monitorStatus == TTPostVideoStatusMonitorPostThreadSucceed? TTForumPostThreadTaskErrorPositionNone: TTForumPostThreadTaskErrorPositionPostThread;
        self.task.responseDict = responseDic.copy;
        if ([respondObj isKindOfClass:[NSDictionary class]] && [respondObj[@"pk_status"] isKindOfClass:[NSDictionary class]]) {
            self.task.pkStatus = [respondObj tt_dictionaryValueForKey:@"pk_status"];
        }
        
        LOGD(@"===== 发帖结束 responseObj : %@", respondObj);
        if (error) {
            [self updateToState:TTForumPostThreadOperationStateFailed];
        }
        else {
            [self updateToState:TTForumPostThreadOperationStateSuccessed];
        }
    }];
}

#pragma mark -- TTVideoUploadClientProtocol

- (void)uploadDidFinish:(TTUploadVideoInfo *)videoInfo error:(NSError *)error{
    
    if (!error) {
        if (self.state != TTForumPostThreadOperationStateResumed) {
            return;
        }
        uint64_t endUploadTime = [NSObject currentUnixTime];
        uint64_t timeConsume = [NSObject machTimeToSecs:endUploadTime - self.startUploadTime] * 1000;
        
        self.task.video.timeConsume = timeConsume;
        self.task.video.videoId = videoInfo.vid;
        self.task.video.isUploaded = YES;
        self.task.video.coverImage.webURI = videoInfo.coverURI;
        
        if ([self.task needUploadVideoCover]) {
            self.task.uploadProgress = TTForumPostVideoThreadTaskBeforeUploadImageProgress;
            [self uploadCoverImage];
        }
        else {
            self.task.uploadProgress = TTForumPostVideoThreadTaskBeforePostThreadProgress;
            [self postVideoThread];
        }
        [[TTForumVideoUploaderSDKManager sharedUploader] removeClientWithTaskId:self.taskID];
    }
    else {
        
        uint64_t endUploadTime = [NSObject currentUnixTime];
        uint64_t timeConsume = [NSObject machTimeToSecs:endUploadTime - self.startUploadTime] * 1000;
        
        self.task.video.timeConsume = timeConsume;
        
        NSMutableDictionary *monitorDict = [[NSMutableDictionary alloc] init];
        [monitorDict setValue:@(error.code) forKey:@"erro_no"];
        [monitorDict setValue:error.domain forKey:@"erro_domain"];
        [monitorDict setValue:@(self.task.video.timeConsume) forKey:@"video_networks"];
        [monitorDict setValue:@(self.task.retryCount > 0 ? 1 : 0) forKey:@"is_resend"];
        
        [FRForumMonitor ugcVideoSDKPostThreadMonitorUploadVideoPerformanceWithStatus:TTPostVideoStatusMonitorVideoUploadSdkFailed
                                                                               extra:[monitorDict copy]
                                                                               retry:self.task.errorPosition != TTForumPostThreadTaskErrorPositionNone
                                                                        isShortVideo:self.task.isShortVideo];
        
         self.task.errorPosition = TTForumPostThreadTaskErrorPositionVideo;
        
        if (self.state != TTForumPostThreadOperationStateResumed) {
            return;
        }
        self.task.finishError = error;
        [self updateToState:TTForumPostThreadOperationStateFailed];
    }
}

- (void)uploadProgressDidUpdate:(NSInteger)progress{
    
    if (self.state != TTForumPostThreadOperationStateResumed) {
        return;
    }
    
    CGFloat progressFloat = ((CGFloat)progress/100 >= 0)? (CGFloat)progress/100 : 0;
    self.task.uploadProgress =progressFloat * TTForumPostVideoThreadTaskBeforeUploadImageProgress;
    
}

@end
