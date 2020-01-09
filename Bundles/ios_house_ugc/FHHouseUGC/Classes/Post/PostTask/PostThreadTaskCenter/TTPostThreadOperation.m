//
//  TTPostThreadOperation.m
//  Article
//
//  Created by 徐霜晴 on 17/3/3.
//
//

#import "TTPostThreadOperation.h"
#import "TTPostThreadDefine.h"
#import "TTPostThreadManager.h"
#import "TTPostThreadBridge.h"

#import <TTUGCFoundation/FRUploadImageManager.h>
#import <TTBaseLib/NetworkUtilities.h>
#import <TTBaseLib/TTBaseMacro.h>
#import <TTPostBase/TTPostTaskCenter.h>
#import <TTKitchen/TTKitchen.h>
#import <TTUGCFoundation/TTUGCNetworkMonitor.h>
#import <TTBaseLib/NSDictionary+TTAdditions.h>
#import <TTBaseLib/NSObject+TTAdditions.h>
#import <TTPlatformBaseLib/TTTrackerWrapper.h>
#import <TTUGCFoundation/TTUGCDefine.h>
#import "HMDTTMonitor.h"

@interface TTPostThreadOperation ()

@property (nonatomic, assign) TTPostThreadOperationState state;
@property (nonatomic, assign) TTPostThreadOperationCancelHint cancelHint;

/**
 对task的操作全部在主线程上进行
 */
@property (nonatomic, strong) TTPostThreadTask *task;

@property (nonatomic, strong) FRUploadImageManager * uploadImageManager;

@property (nonatomic, copy) TTPostThreadOperationStateUpdatedBlock stateUpdatedBlock;
@property (nonatomic, copy) TTPostThreadOperationSuccessBlock successBlock;
@property (nonatomic, copy) TTPostThreadOperationFailureBlock failureBlock;
@property (nonatomic, copy) TTPostThreadOperationCancelledBlock cancelledBlock;

@property (nonatomic, assign) int64_t startTime;

@end

@implementation TTPostThreadOperation

@synthesize taskID = _taskID;
@synthesize concernID = _concernID;
@synthesize executing = _executing;
@synthesize finished = _finished;
@synthesize cancellable = _cancellable;

/*
 * 该方法预期在主线程上被调用
 */
+ (TTPostThreadOperation *)operationWithPostThreadTaskID:(NSString *)taskID
                                                    concernID:(NSString *)concernID
                                                suggestedTask:(TTPostThreadTask *)suggestedTask
                                            stateUpdatedBlock:(TTPostThreadOperationStateUpdatedBlock)stateUpdatedBlock
                                                 successBlock:(TTPostThreadOperationSuccessBlock)successBlock
                                               cancelledBlock:(TTPostThreadOperationCancelledBlock)cancelledBlock
                                                 failureBlock:(TTPostThreadOperationFailureBlock)failureBlock {
    return [[TTPostThreadOperation alloc] initWithPostThreadTaskID:taskID
                                                              concernID:concernID
                                                          suggestedTask:suggestedTask
                                                      stateUpdatedBlock:stateUpdatedBlock
                                                           successBlock:successBlock
                                                         cancelledBlock:cancelledBlock
                                                           failureBlock:failureBlock];
}

- (instancetype)initWithPostThreadTaskID:(NSString *)taskID
                               concernID:(NSString *)concernID
                           suggestedTask:(TTPostThreadTask *)suggestedTask
                       stateUpdatedBlock:(TTPostThreadOperationStateUpdatedBlock)stateUpdatedBlock
                            successBlock:(TTPostThreadOperationSuccessBlock)successBlock
                          cancelledBlock:(TTPostThreadOperationCancelledBlock)cancelledBlock
                            failureBlock:(TTPostThreadOperationFailureBlock)failureBlock {
    self = [super init];
    if (self) {
        _cancellable = NO;
        self.taskID = taskID;
        self.concernID = concernID;
        self.stateUpdatedBlock = stateUpdatedBlock;
        self.successBlock = successBlock;
        self.failureBlock = failureBlock;
        self.cancelledBlock = cancelledBlock;
        self.state = TTPostThreadOperationStatePending;
        
        if (suggestedTask) {
            self.task = suggestedTask;
            suggestedTask.finishError = nil;
            [self callStateUpdatedBlockForTask:suggestedTask lastState:TTPostThreadOperationStateUnknown currentState:TTPostThreadOperationStatePending];
        }
        else {
            WeakSelf;
            [[TTPostTaskCenter sharedInstance] asyncGetTaskWithID:taskID concernID:concernID completionBlock:^(TTPostTask *task) {
                if ([task isKindOfClass:[TTPostThreadTask class]]) {
                    
                    StrongSelf;
                    if (!task) {
                        [self callFailureBlockForTask:nil error:[NSError errorWithDomain:kFRPostThreadErrorDomain code:TTPostThreadErrorCodeCannotFindTask userInfo:nil]];
                        return;
                    }
                    ((TTPostThreadTask *)task).finishError = nil;
                    [self callStateUpdatedBlockForTask:(TTPostThreadTask *)task lastState:TTPostThreadOperationStateUnknown currentState:TTPostThreadOperationStatePending];
                    self.task = (TTPostThreadTask *)task;
                }
            }];
        }
    }
    return self;
}

- (NSString *)description {
    if (isEmptyString(self.taskID)) {
        return [super description];
    }
    return [NSString stringWithFormat:@"[TTPostThreadOperation]taskID=%@", self.taskID];
}

- (void)dealloc {
}

- (TTPostThreadTask *)task {
    return _task;
}

- (void)updateToState:(TTPostThreadOperationState)updatedState {
    @synchronized (self) {
        /*
         * 已经是终极状态
         */
        if (self.state == TTPostThreadOperationStateCancelled ||
            self.state == TTPostThreadOperationStateFailed ||
            self.state == TTPostThreadOperationStateSuccessed) {
            return;
        }
        
        TTPostThreadOperationState lastState = self.state;
        self.state = updatedState;
        
        switch (updatedState) {
            case TTPostThreadOperationStateSuccessed:
                [self callSuccessBlockForTask:self.task];
                [self done];
                break;
            case TTPostThreadOperationStateFailed:
                [self callFailureBlockForTask:self.task error:self.task.finishError];
                [self done];
                break;
            case TTPostThreadOperationStateCancelled:
                [self callCancelledBlockForTask:self.task cancelHint:self.cancelHint];
                [self done];
                break;
            case TTPostThreadOperationStateResumed:
                [self beginTask];
                [self callStateUpdatedBlockForTask:self.task lastState:lastState currentState:updatedState];
                break;
            default:
                break;
        }
    }
}

#pragma mark - call block

- (void)callStateUpdatedBlockForTask:(TTPostThreadTask *)task lastState:(TTPostThreadOperationState)lastState currentState:(TTPostThreadOperationState)currentState {
    
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

- (void)callCancelledBlockForTask:(TTPostThreadTask *)task cancelHint:(TTPostThreadOperationCancelHint)cancelHint {
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

- (void)callFailureBlockForTask:(TTPostThreadTask *)task error:(NSError *)error {
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

- (void)callSuccessBlockForTask:(TTPostThreadTask *)task {
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
    
    if (self.state != TTPostThreadOperationStatePending) {
        [self done];
        return;
    }
    
    self.executing = YES;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [[TTPostTaskCenter sharedInstance] asyncGetTaskWithID:self.taskID concernID:self.concernID completionBlock:^(TTPostTask *task) {
            if ([task isKindOfClass:[TTPostThreadTask class]]) {
                self.task = (TTPostThreadTask *)task;
                if (!self.task) {
                    [self callFailureBlockForTask:nil error:[NSError errorWithDomain:kFRPostThreadErrorDomain code:TTPostThreadErrorCodeCannotFindTask userInfo:nil]];
                    return;
                }
                self.task.finishError = nil;
                [self updateToState:TTPostThreadOperationStateResumed];
            }
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

/*
 * 预期在主线程上调用
 */
- (void)cancelWithHint:(TTPostThreadOperationCancelHint)cancelHint {
    self.task.finishError = [NSError errorWithDomain:kFRPostThreadErrorDomain code:TTPostThreadErrorCodeUserCancelled userInfo:nil];
    self.cancelHint = cancelHint;
    [self updateToState:TTPostThreadOperationStateCancelled];
    [super cancel];
}

- (void)done {
    self.executing = NO;
    self.finished = YES;
}

#pragma mark - work

- (void)beginTask {
    
    WeakSelf;
    dispatch_block_t beginBlock = ^(){
        
        if (!TTNetworkConnected()) {
            self.task.finishError = [NSError errorWithDomain:kFRPostThreadErrorDomain code:TTPostThreadErrorCodeNoNetwork userInfo:nil];
            [self updateToState:TTPostThreadOperationStateFailed];
            return;
        }
        
        StrongSelf;
        self.startTime = [NSObject currentUnixTime];
        
        if (self.task.uploadProgress < 0.2) {
            self.task.uploadProgress = 0.2;
        }
        
        if ([self.task needUploadImg]) {
            [self uploadImages];
        }
        else {
            if (self.task.repostType == TTThreadRepostTypeNone) {
                if (!isEmptyString(self.task.postID)) {
                    [self postEditedThread];
                } else {
                    [self postNormalThread];
                }
            }
            else {
                [self postRepostThread];
            }
        }
    };
    
    beginBlock();
}

- (void)uploadImages {
    
    if (self.state != TTPostThreadOperationStateResumed) {
        return;
    }
    
    WeakSelf;
    [self.uploadImageManager uploadPhotos:[self.task needUploadImgModels] extParameter:@{@"concern_id":self.task.concernID} progressBlock:^(int expectCount, int receivedCount) {
        StrongSelf;
        if (self.state != TTPostThreadOperationStateResumed) {
            return;
        }
        self.task.uploadProgress = 0.2 + ((CGFloat)([self.task.images count] - expectCount + receivedCount)/ (CGFloat)[self.task.images count]) * (TTForumPostVideoThreadTaskBeforePostThreadProgress - 0.2);
    } finishBlock:^(NSError *error, NSArray<FRUploadImageModel*> *finishUpLoadModels) {
        StrongSelf;
        if (self.state != TTPostThreadOperationStateResumed) {
            return;
        }
        NSError *finishError = nil;
        for (FRUploadImageModel *model in finishUpLoadModels) {
            if (isEmptyString(model.webURI)) {
                finishError = [NSError errorWithDomain:kFRPostThreadErrorDomain code:TTPostThreadErrorCodeUploadImgError userInfo:nil];
                break;
            }
        }
        
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
            
            // 图片上传失败
            [[HMDTTMonitor defaultManager] hmdTrackService:@"ugc_post_upload_image" metric:monitorDictionary category:@{@"status":@(1)} extra:nil];
            
            [[TTPostThreadBridge sharedInstance] monitorPostThreadStatus:TTPostThreadStatusImageUploadFailed
                                                                   extra:[monitorDictionary copy]
                                                                   retry:self.task.errorPosition != TTPostThreadTaskErrorPositionNone];
            
            self.task.finishError = finishError;
            self.task.errorPosition = TTPostThreadTaskErrorPositionImage;
            [self updateToState:TTPostThreadOperationStateFailed];
        }
        else {
            // 图片上传成功
            [[HMDTTMonitor defaultManager] hmdTrackService:@"ugc_post_upload_image" metric:nil category:@{@"status":@(0)} extra:nil];
            
            if (!isEmptyString(self.task.postID)) {
                [self postEditedThread];
            } else {
                [self postNormalThread];
            }
        }
    }];
}

- (void)postNormalThread {
    
    if (self.state != TTPostThreadOperationStateResumed) {
        return;
    }
    
    WeakSelf;
    [TTPostThreadManager postThreadTask:self.task finishBlock:^(NSError *error, id respondObj,TTUGCRequestMonitorModel *monitorModel, uint64_t networkConsume) {
        StrongSelf;
        if (self.state != TTPostThreadOperationStateResumed) {
            return;
        }
        //端监控
        NSMutableDictionary * monitorDictionary = [NSMutableDictionary dictionary];
        [monitorDictionary setValue:@(networkConsume) forKey:@"network"];
        [monitorDictionary setValue:@(self.task.images.count) forKey:@"img_count"];
        NSMutableDictionary *responseDic = nil;
        if ([respondObj isKindOfClass:[NSDictionary class]]) {
            responseDic = [respondObj mutableCopy];
        } else
        if ([respondObj isKindOfClass:[NSDictionary class]] && [[respondObj objectForKey:@"thread"] isKindOfClass:[NSDictionary class]]) {
            responseDic = [NSMutableDictionary dictionaryWithDictionary:[respondObj objectForKey:@"thread"]];
            if (![responseDic objectForKey:@"thread_id"]) {
                error = error ?: [NSError errorWithDomain:kFRPostForumErrorDomain code:TTPostThreadErrorCodeError userInfo:nil];
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
//            if ([responseDic isKindOfClass:[NSDictionary class]]) {
//                [responseDic setValue:[(NSDictionary *)responseDic objectForKey:@"thread_id"] forKey:@"uniqueID"];
//                if ([respondObj isKindOfClass:[NSDictionary class]] && [[respondObj objectForKey:@"guide_info"] isKindOfClass:[NSDictionary class]]) {
//                    if (((NSDictionary *)[respondObj objectForKey:@"guide_info"]).count > 0) {
//                        [responseDic setValue:[(NSDictionary *)respondObj objectForKey:@"guide_info"] forKey:@"guide_info"];
//                    }
//                }
//            }
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
        
        [[TTPostThreadBridge sharedInstance] monitorPostThreadStatus:monitorStatus
                                                               extra:[monitorDictionary copy]
                                                               retry:self.task.errorPosition != TTPostThreadTaskErrorPositionNone];
        
        if (monitorModel) {
            monitorModel.monitorExtra = monitorDictionary;
            if (error && [error.domain isEqualToString:kFRPostForumErrorDomain]) {
                monitorModel.monitorStatus = kTTNetworkMonitorPostStatusThreadDataError;
            }
        }
        
        self.task.finishError = error;
        self.task.responseDict = [responseDic copy];
        self.task.errorPosition = monitorStatus == TTPostThreadStatusPostThreadSucceed? TTPostThreadTaskErrorPositionNone : TTPostThreadTaskErrorPositionPostThread;
        if (error) {
            [self updateToState:TTPostThreadOperationStateFailed];
        }
        else {
            [self updateToState:TTPostThreadOperationStateSuccessed];
        }
    }];
}

- (void)postEditedThread {
    if (self.state != TTPostThreadOperationStateResumed) {
        return;
    }
    
    WeakSelf;
    [TTPostThreadManager postEditedThreadTask:self.task finishBlock:^(NSError *error, id respondObj,TTUGCRequestMonitorModel *monitorModel, uint64_t networkConsume) {
        StrongSelf;
        if (self.state != TTPostThreadOperationStateResumed) {
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
                error = error ?: [NSError errorWithDomain:kFRPostForumErrorDomain code:TTPostThreadErrorCodeError userInfo:nil];
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
                if ([respondObj isKindOfClass:[NSDictionary class]] && [[respondObj objectForKey:@"guide_info"] isKindOfClass:[NSDictionary class]]) {
                    if (((NSDictionary *)[respondObj objectForKey:@"guide_info"]).count > 0) {
                        [responseDic setValue:[(NSDictionary *)respondObj objectForKey:@"guide_info"] forKey:@"guide_info"];
                    }
                }
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
        
        [[TTPostThreadBridge sharedInstance] monitorPostThreadStatus:monitorStatus
                                                               extra:[monitorDictionary copy]
                                                               retry:self.task.errorPosition != TTPostThreadTaskErrorPositionNone];
        
        if (monitorModel) {
            monitorModel.monitorExtra = monitorDictionary;
            if (error && [error.domain isEqualToString:kFRPostForumErrorDomain]) {
                monitorModel.monitorStatus = kTTNetworkMonitorPostStatusThreadDataError;
            }
        }
        
        self.task.finishError = error;
        self.task.responseDict = [responseDic copy];
        self.task.errorPosition = monitorStatus == TTPostThreadStatusPostThreadSucceed? TTPostThreadTaskErrorPositionNone : TTPostThreadTaskErrorPositionPostThread;
        if (error) {
            [self updateToState:TTPostThreadOperationStateFailed];
        }
        else {
            [self updateToState:TTPostThreadOperationStateSuccessed];
        }
    }];
}

- (void)postRepostThread {
    
    if (self.state != TTPostThreadOperationStateResumed) {
        return;
    }
    
    WeakSelf;
    [TTPostThreadManager postRepostTask:self.task finishBlock:^(NSError *error, id respondObj,TTUGCRequestMonitorModel *monitorModel, uint64_t networkConsume) {
        StrongSelf;

        NSMutableDictionary *responseDic = [[NSMutableDictionary alloc] init];


        if (!error && [respondObj isKindOfClass:[NSDictionary class]]) {

            //打包成功的情况
            if (([respondObj objectForKey:@"thread"] && [[respondObj objectForKey:@"thread"] isKindOfClass:[NSDictionary class]]) || ([respondObj objectForKey:@"comment"] && [[respondObj objectForKey:@"comment"] isKindOfClass:[NSDictionary class]])) {

                NSDictionary *responseThreadDic = nil;
                NSDictionary *responseCommentDic = nil;
                NSMutableDictionary *responseReplyDic = nil;
                NSString *reply_id;
                NSDictionary *responseReplyDataDict = nil;

                //获取相关的结果数据
                reply_id = [respondObj tt_stringValueForKey:@"reply_id"];
                responseCommentDic = [respondObj tt_dictionaryValueForKey:@"comment"];
                responseThreadDic = [respondObj tt_dictionaryValueForKey:@"thread"];
                responseReplyDataDict = [respondObj tt_dictionaryValueForKey:@"reply"];

                //若reply_id不为空，则视为转发并回复的数据
                if (!isEmptyString(reply_id) && reply_id.longLongValue > 0) {
                    if (!SSIsEmptyDictionary(responseCommentDic)) {
                        responseReplyDic = [[NSMutableDictionary alloc] initWithDictionary:responseCommentDic];
                        [responseReplyDic setValue:reply_id forKey:@"reply_id"];
                        [responseReplyDic setValue:responseReplyDataDict forKey:@"reply_response_dict"];
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
                    error = error ?: [NSError errorWithDomain:kFRPostForumErrorDomain code:TTPostThreadErrorCodeError userInfo:nil];
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
            [self updateToState:TTPostThreadOperationStateFailed];
        }
        else {
            [self updateToState:TTPostThreadOperationStateSuccessed];
        }
    }];
    
}

@end
