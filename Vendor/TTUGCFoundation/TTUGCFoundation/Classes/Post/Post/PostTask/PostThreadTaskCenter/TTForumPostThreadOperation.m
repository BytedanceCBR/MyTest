//
//  TTForumPostThreadOperation.m
//  Article
//
//  Created by 徐霜晴 on 17/3/3.
//
//

#import "TTForumPostThreadOperation.h"
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
#import "FRForumMonitor.h"
#import "TTKitchenMgr.h"
#import "FRForumNetWorkMonitor.h"
#import "TTUGCBacktraceLogger.h"
#import "TTBaseMacro.h"
#import "NSDictionary+TTAdditions.h"
#import "NSObject+TTAdditions.h"
#import "TTTrackerWrapper.h"

@interface TTForumPostThreadOperation ()

@property (nonatomic, assign) TTForumPostThreadOperationState state;
@property (nonatomic, assign) TTForumPostThreadOperationCancelHint cancelHint;

/**
 对task的操作全部在主线程上进行
 */
@property (nonatomic, strong) TTForumPostThreadTask *task;

@property (nonatomic, strong) FRUploadImageManager * uploadImageManager;

@property (nonatomic, copy) TTForumPostThreadOperationStateUpdatedBlock stateUpdatedBlock;
@property (nonatomic, copy) TTForumPostThreadOperationSuccessBlock successBlock;
@property (nonatomic, copy) TTForumPostThreadOperationFailureBlock failureBlock;
@property (nonatomic, copy) TTForumPostThreadOperationCancelledBlock cancelledBlock;

@property (nonatomic, assign) int64_t startTime;

@end

@implementation TTForumPostThreadOperation

@synthesize taskID = _taskID;
@synthesize concernID = _concernID;
@synthesize taskType = _taskType;
@synthesize executing = _executing;
@synthesize finished = _finished;
@synthesize cancellable = _cancellable;

/*
 * 该方法预期在主线程上被调用
 */
+ (NSOperation<TTForumPostThreadOperationProtocol> *)operationWithPostThreadTaskID:(NSString *)taskID
                                                                         concernID:(NSString *)concernID
                                                                          taskType:(TTForumPostThreadTaskType)taskType
                                                                     suggestedTask:(TTForumPostThreadTask *)suggestedTask
                                                                 stateUpdatedBlock:(TTForumPostThreadOperationStateUpdatedBlock)stateUpdatedBlock
                                                                      successBlock:(TTForumPostThreadOperationSuccessBlock)successBlock
                                                                    cancelledBlock:(TTForumPostThreadOperationCancelledBlock)cancelledBlock
                                                                      failureBlock:(TTForumPostThreadOperationFailureBlock)failureBlock {
    if (taskType == TTForumPostThreadTaskTypeThread) {
        return [[TTForumPostThreadOperation alloc] initWithPostThreadTaskID:taskID
                                                                  concernID:concernID
                                                              suggestedTask:suggestedTask
                                                          stateUpdatedBlock:stateUpdatedBlock
                                                               successBlock:successBlock
                                                             cancelledBlock:cancelledBlock
                                                               failureBlock:failureBlock];
    }
    else if (taskType == TTForumPostThreadTaskTypeVideo) {
        return [[TTForumPostVideoOperation alloc] initWithPostThreadTaskID:taskID
                                                                 concernID:concernID
                                                             suggestedTask:suggestedTask
                                                         stateUpdatedBlock:stateUpdatedBlock
                                                              successBlock:successBlock
                                                            cancelledBlock:cancelledBlock
                                                              failureBlock:failureBlock];
    }
    return nil;
}

- (instancetype)initWithPostThreadTaskID:(NSString *)taskID
                               concernID:(NSString *)concernID
                           suggestedTask:(TTForumPostThreadTask *)suggestedTask
                       stateUpdatedBlock:(TTForumPostThreadOperationStateUpdatedBlock)stateUpdatedBlock
                            successBlock:(TTForumPostThreadOperationSuccessBlock)successBlock
                          cancelledBlock:(TTForumPostThreadOperationCancelledBlock)cancelledBlock
                            failureBlock:(TTForumPostThreadOperationFailureBlock)failureBlock {
    self = [super init];
    if (self) {
        _cancellable = NO;
        self.taskID = taskID;
        self.concernID = concernID;
        self.stateUpdatedBlock = stateUpdatedBlock;
        self.successBlock = successBlock;
        self.failureBlock = failureBlock;
        self.cancelledBlock = cancelledBlock;
        self.taskType = TTForumPostThreadTaskTypeThread;
        self.state = TTForumPostThreadOperationStatePending;
        UGCLog(@"operation init %@", self);
        if (suggestedTask) {
            self.task = suggestedTask;
            suggestedTask.finishError = nil;
            [self callStateUpdatedBlockForTask:suggestedTask lastState:TTForumPostThreadOperationStateUnknown currentState:TTForumPostThreadOperationStatePending];
        }
        else {
            WeakSelf;
            [[TTForumPostThreadTaskCenter sharedInstance] asyncGetTaskWithID:taskID concernID:concernID completionBlock:^(TTForumPostThreadTask *task) {
                UGCLog(@"taskId:%@, suggestTask:none, task:%@", taskID, task);
                
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

- (NSString *)description {
    if (isEmptyString(self.taskID)) {
        return [super description];
    }
    return [NSString stringWithFormat:@"[TTForumPostThreadOperation]taskID=%@", self.taskID];
}

- (void)dealloc {
    UGCLog(@"operation dealloc %@", self);
}

- (TTForumPostThreadTask *)task {
#if DEBUG
    _task.debug_currentMethod = [TTUGCBacktraceLogger ttugc_backtraceOfCurrentThread];
#endif
    return _task;
}

- (void)updateToState:(TTForumPostThreadOperationState)updatedState {
    
    UGCLog(@"updatedState:%ld", updatedState);
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
    UGCLog(@"taskId:%@, lastState:%ld, currentState:%ld", self.taskID, lastState, currentState);
    
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

- (FRUploadImageManager *)uploadImageManager {
    if (!_uploadImageManager) {
        _uploadImageManager = [[FRUploadImageManager alloc] init];
    }
    return _uploadImageManager;
}

#pragma mark - override

- (void)start {
    
    UGCLog(@"operation start %@", self);
    
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
    UGCLog(@"finished:%d", finished);
    [self willChangeValueForKey:@"isFinished"];
    _finished = finished;
    [self didChangeValueForKey:@"isFinished"];
}

- (void)setExecuting:(BOOL)executing {
    if (_executing == executing) {
        return;
    }
    UGCLog(@"executing:%d", executing);
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

/*
 * 预期在主线程上调用
 */
- (void)cancelWithHint:(TTForumPostThreadOperationCancelHint)cancelHint {
    self.task.finishError = [NSError errorWithDomain:kFRPostThreadErrorDomain code:FRPostThreadErrorCodeUserCancelled userInfo:nil];
    self.cancelHint = cancelHint;
    [self updateToState:TTForumPostThreadOperationStateCancelled];
    [super cancel];
}

- (void)done
{
    UGCLog(@"operation done %@", self);
    
    self.executing = NO;
    self.finished = YES;
}

#pragma mark - work

- (void)beginTask {
    
    UGCLog(@"operation begintask %@", self);
    
    WeakSelf;
    dispatch_block_t beginBlock = ^(){
        
        if (!TTNetworkConnected()) {
            self.task.finishError = [NSError errorWithDomain:kFRPostThreadErrorDomain code:FRPostThreadErrorCodeNoNetwork userInfo:nil];
            [self updateToState:TTForumPostThreadOperationStateFailed];
            return;
        }
        
        self.task.uploadProgress = 0.2;
        
        StrongSelf;
        self.startTime = [NSObject currentUnixTime];
        
        self.task.uploadProgress = 0.1;
        
        if ([self.task needUploadImg]) {
            [self uploadImages];
        }
        else {
            if (self.task.repostType == TTThreadRepostTypeNone) {
                [self postNormalThread];
            }
            else {
                [self postRepostThread];
            }
        }
    };
    
    beginBlock();
}

- (void)uploadImages {
    
    if (self.state != TTForumPostThreadOperationStateResumed) {
        return;
    }
    
    WeakSelf;
    [self.uploadImageManager uploadPhotos:[self.task needUploadImgModels] withTask:self.task extParameter:@{@"concern_id":self.task.concernID} progressBlock:^(int expectCount, int receivedCount) {
        StrongSelf;
        if (self.state != TTForumPostThreadOperationStateResumed) {
            return;
        }
        self.task.uploadProgress = 0.2 + ((CGFloat)([self.task.images count] - expectCount + receivedCount)/ (CGFloat)[self.task.images count]) * (TTForumPostVideoThreadTaskBeforePostThreadProgress - 0.2);
        
    } finishBlock:^(NSError *error, NSArray<FRUploadImageModel*> *finishUpLoadModels) {
        StrongSelf;
        if (self.state != TTForumPostThreadOperationStateResumed) {
            return;
        }
        NSError *finishError = nil;
        for (FRUploadImageModel *model in finishUpLoadModels) {
            if (isEmptyString(model.webURI)) {
                finishError = [NSError errorWithDomain:kFRPostThreadErrorDomain code:FRPostThreadErrorCodeUploadImgError userInfo:nil];
                break;
            }
        }
        UGCLog(@"taskID: %@, imageUpload finish, error :%@", self.taskID, finishError);
        if (error || finishError) {
            //端监控
            //图片上传失败
            NSMutableDictionary * monitorDictionary = [NSMutableDictionary dictionary];
            [monitorDictionary setValue:@(self.task.images.count) forKey:@"img_count"];
            NSMutableArray * imageNetworks = [NSMutableArray arrayWithCapacity:self.task.images.count];
            for (FRUploadImageModel * imageModel in self.task.images) {
                NSInteger status = isEmptyString(imageModel.webURI)?0:1;
                NSInteger code = 0;
                if (imageModel.error) {
                    code = imageModel.error.code;
                }
                [imageNetworks addObject:@{@"network":@(imageModel.networkConsume)
                                           , @"local":@(imageModel.localCompressConsume)
                                           , @"status":@(status)
                                           , @"code":@(code)
                                           , @"count":@(imageModel.uploadCount)
                                           , @"size":@(imageModel.size)
                                           , @"gif":@(imageModel.isGIF)
                                           }];
            }
            [monitorDictionary setValue:imageNetworks.copy forKey:@"img_networks"];
            [monitorDictionary setValue:@(self.task.retryCount>0?1:0) forKey:@"is_resend"];
            if (error) {
                [monitorDictionary setValue:@(error.code) forKey:@"error"];
            }
            [FRForumMonitor trackPostThreadStatus:TTPostThreadStatusImageUploadFailed
                                            extra:monitorDictionary.copy
                                            retry:self.task.errorPosition != TTForumPostThreadTaskErrorPositionNone];
            self.task.finishError = finishError;
            self.task.errorPosition = TTForumPostThreadTaskErrorPositionImage;
            [self updateToState:TTForumPostThreadOperationStateFailed];
        }
        else {
            [self postNormalThread];
        }
    }];
}

- (void)postNormalThread {
    
    if (self.state != TTForumPostThreadOperationStateResumed) {
        return;
    }
    
    WeakSelf;
    [TTForumPostThreadManager postThreadTask:self.task finishBlock:^(NSError *error, id respondObj,FRForumMonitorModel *monitorModel, uint64_t networkConsume) {
        StrongSelf;
        if (self.state != TTForumPostThreadOperationStateResumed) {
            return;
        }
        //端监控
        NSMutableDictionary * monitorDictionary = [NSMutableDictionary dictionary];
        [monitorDictionary setValue:@(networkConsume) forKey:@"network"];
        [monitorDictionary setValue:@(self.task.images.count) forKey:@"img_count"];
        NSMutableDictionary *responseDic = nil;
        if ([respondObj isKindOfClass:[NSDictionary class]] && [[respondObj objectForKey:@"thread"] isKindOfClass:[NSDictionary class]]) {
            responseDic = [NSMutableDictionary dictionaryWithDictionary:[respondObj objectForKey:@"thread"]];
            if (![responseDic objectForKey:@"thread_id"]) {
                error = error ?: [NSError errorWithDomain:kFRPostForumErrorDomain code:FRPostThreadErrorCodeError userInfo:nil];
            }
        }
        
        if (error) {
            [monitorDictionary setValue:@(0) forKey:@"data_valid"];
            [monitorDictionary setValue:@(0) forKey:@"status"];
            
            NSMutableDictionary * topicPostTrackerDic = [NSMutableDictionary dictionaryWithCapacity:10];
            [topicPostTrackerDic setValue:@"umeng" forKey:@"category"];
            [topicPostTrackerDic setValue:@"topic_post" forKey:@"tag"];
            [topicPostTrackerDic setValue:@"post_fail_api" forKey:@"label"];
            [topicPostTrackerDic setValue:self.task.categoryID forKey:@"category_id"];
            [topicPostTrackerDic setValue:self.task.concernID forKey:@"concern_id"];
            [topicPostTrackerDic setValue:@(self.task.refer) forKey:@"refer"];
            if (self.task.extraTrack.count > 0) {
                [topicPostTrackerDic setValuesForKeysWithDictionary:self.task.extraTrack];
            }
            [TTTrackerWrapper eventData:topicPostTrackerDic];
        } else {
            if ([responseDic isKindOfClass:[NSDictionary class]]) {
                [responseDic setValue:[(NSDictionary *)responseDic objectForKey:@"thread_id"] forKey:@"uniqueID"];
            }
            [monitorDictionary setValue:@(1) forKey:@"data_valid"];
            [monitorDictionary setValue:@(1) forKey:@"status"];
            uint64_t endTime = [NSObject currentUnixTime];
            uint64_t total = [NSObject machTimeToSecs:endTime - self.startTime] * 1000;
            [monitorDictionary setValue:@(total) forKey:@"total"];
        }
        NSMutableArray * imageNetworks = [NSMutableArray arrayWithCapacity:self.task.images.count];
        for (FRUploadImageModel * imageModel in self.task.images) {
            if (imageModel.networkConsume > 0) {
                //图片上传过
                NSInteger status = isEmptyString(imageModel.webURI)?0:1;
                [imageNetworks addObject:@{@"network":@(imageModel.networkConsume), @"status":@(status)}];
            }
        }
        [monitorDictionary setValue:imageNetworks.copy forKey:@"img_networks"];
        [monitorDictionary setValue:@(self.task.retryCount>0?1:0) forKey:@"is_resend"];
        [monitorDictionary setValue:@(error.code) forKey:@"erro_no"];
        [monitorDictionary setValue:error.domain forKey:@"erro_domain"];
        NSInteger monitorStatus = error ? TTPostThreadstatusPostThreadFailed : TTPostThreadStatusPostThreadSucceed;
        if ([error.domain isEqualToString:JSONModelErrorDomain]) {
            monitorStatus = TTPostThreadstatusPostThreadJSONModelFailed;
        }
        [FRForumMonitor trackPostThreadStatus:monitorStatus
                                        extra:monitorDictionary.copy
                                        retry:self.task.errorPosition != TTForumPostThreadTaskErrorPositionNone];
        
        if (monitorModel) {
            monitorModel.monitorExtra = monitorDictionary;
            if (error && [error.domain isEqualToString:kFRPostForumErrorDomain]) {
                monitorModel.monitorStatus = kTTNetworkMonitorPostStatusThreadDataError;
            }
        }
        
        self.task.finishError = error;
        self.task.responseDict = [responseDic copy];
        self.task.errorPosition = monitorStatus == TTPostThreadStatusPostThreadSucceed? TTForumPostThreadTaskErrorPositionNone : TTForumPostThreadTaskErrorPositionPostThread;
        if (error) {
            [self updateToState:TTForumPostThreadOperationStateFailed];
        }
        else {
            [self updateToState:TTForumPostThreadOperationStateSuccessed];
        }
    }];
}

- (void)postRepostThread {
    
    if (self.state != TTForumPostThreadOperationStateResumed) {
        return;
    }
    
    WeakSelf;
    [TTForumPostThreadManager postRepostTask:self.task finishBlock:^(NSError *error, id respondObj,FRForumMonitorModel *monitorModel, uint64_t networkConsume) {
        StrongSelf;

        NSMutableDictionary *responseDic = [[NSMutableDictionary alloc] init];


        if (!error && [respondObj isKindOfClass:[NSDictionary class]]) {

            //打包成功的情况
            if (([respondObj objectForKey:@"thread"] && [[respondObj objectForKey:@"thread"] isKindOfClass:[NSDictionary class]]) || ([respondObj objectForKey:@"comment"] && [[respondObj objectForKey:@"comment"] isKindOfClass:[NSDictionary class]])) {

                NSDictionary *responseThreadDic = nil;
                NSDictionary *responseCommentDic = nil;
                NSMutableDictionary *responseReplyDic = nil;
                NSString *reply_id;

                //获取相关的结果数据
                reply_id = [respondObj tt_stringValueForKey:@"reply_id"];
                responseCommentDic = [respondObj tt_dictionaryValueForKey:@"comment"];
                responseThreadDic = [respondObj tt_dictionaryValueForKey:@"thread"];

                //若reply_id不为空，则视为转发并回复的数据
                if (!isEmptyString(reply_id) && reply_id.longLongValue > 0) {
                    if (!SSIsEmptyDictionary(responseCommentDic)) {
                        responseReplyDic = [[NSMutableDictionary alloc] initWithDictionary:responseCommentDic];
                        [responseReplyDic setValue:reply_id forKey:@"reply_id"];
                    }
                }

                //填充最终的结果数据，并进行结果类型区分
                NSString *uniqueID = nil;

                //此时为转发并回复的数据
                if (!SSIsEmptyDictionary(responseReplyDic)) {
                    uniqueID = [responseReplyDic tt_stringValueForKey:@"id"];
                    [responseDic addEntriesFromDictionary:responseReplyDic];
                    self.task.repostTaskType = TTForumRepostThreadTaskType_Reply;
                }
                //此时为转发并评论的数据
                else if (!SSIsEmptyDictionary(responseCommentDic)) {
                    uniqueID = [responseCommentDic tt_stringValueForKey:@"id"];
                    [responseDic addEntriesFromDictionary:responseCommentDic];
                    self.task.repostTaskType = TTForumRepostThreadTaskType_Comment;
                }
                //此时为纯转发的数据
                else if (!SSIsEmptyDictionary(responseThreadDic)) {
                    uniqueID = [responseThreadDic tt_stringValueForKey:@"thread_id"];
                    [responseDic addEntriesFromDictionary:responseThreadDic];
                    self.task.repostTaskType = TTForumRepostThreadTaskType_Thread;
                }

                if (!isEmptyString(uniqueID)) {
                    [responseDic setValue:uniqueID forKey:@"uniqueID"];
                }
                else {
                    error = error ?: [NSError errorWithDomain:kFRPostForumErrorDomain code:FRPostThreadErrorCodeError userInfo:nil];
                }
            }

        }
        //对于打包失败导致thread以及comment的数据都不返回的情况，暂不做失败的处理
        
        NSMutableDictionary *monitorDic = [[NSMutableDictionary alloc] init];
        [monitorDic setValue:@(self.task.repostToComment) forKey:@"repost_to_comment"];
        [monitorDic setValue:@(self.task.repostType) forKey:@"repost_type"];
        [monitorDic setValue:self.task.fw_id forKey:@"fw_id"];
        [monitorDic setValue:@(self.task.fw_id_type) forKey:@"fw_id_type"];
        [monitorDic setValue:self.task.opt_id forKey:@"opt_id"];
        [monitorDic setValue:@(self.task.opt_id_type) forKey:@"opt_id_type"];
        [monitorDic setValue:self.task.fw_user_id forKey:@"fw_user_id"];
        if (error) {
            [monitorDic setValue:error.description forKey:@"error_desc"];
            [monitorDic setValue:error.domain forKey:@"error_domain"];
            [monitorDic setValue:@(error.code) forKey:@"error_code"];
        }

        if (monitorModel) {
            monitorModel.monitorExtra = monitorDic;
            if (error && [error.domain isEqualToString:kFRPostForumErrorDomain]) {
                monitorModel.monitorStatus = kTTNetworkMonitorPostStatusRepostDataError;
            }
        }

        self.task.finishError = error;
        self.task.responseDict = [responseDic copy];
        if (error) {
            [self updateToState:TTForumPostThreadOperationStateFailed];
        }
        else {
            [self updateToState:TTForumPostThreadOperationStateSuccessed];
        }
    }];
    
}

@end
