//
//  TTForumPostThreadCenter.m
//  Article
//
//  Created by 王霖 on 3/16/16.
//
//

#import "TTForumPostThreadCenter.h"
#import <TTAccountBusiness.h>
#import "TTUGCDefine.h"
#import "TTReachability.h"
#import "FRPostThreadDefine.h"
#import "TTPostVideoCacheHelper.h"
#import "TTForumPostThreadOperation.h"
#import "TTForumPostThreadTaskCenter.h"
#import "Thread.h"
#import "TTUIResponderHelper.h"
#import "FRForumMonitor.h"
#import "TTKitchenHeader.h"
#import "TTKitchenMgr.h"
#import "TTForumVideoUploaderSDKManager.h"
#import "TTThemedAlertController.h"
#import <TTUIResponderHelper.h>
#import "TTUGCBacktraceLogger.h"
#import "FRActionDataService.h"
#import "TTRepostThreadModel.h"
#import "TTRedPacketManager.h"
//#import "TTPostVideoRedpackDelegate.h"
#import "TTForumUploadVideoModel.h"
#import <Crashlytics/Answers.h>
#import "TTVideoPublishMonitor.h"

NSString * const TTUGCPostCenterClassName = @"TTForumPostThreadCenter";


NSString * const TTPostTaskBeginNotification = kTTForumPostingThreadNotification;
NSString * const TTPostTaskResumeNotification = kTTForumResumeThreadNotification;
NSString * const TTPostTaskdProgressUpdateNotification = kTTForumThreadProgressUpdateNotification;
NSString * const TTPostTaskFailNotification = kTTForumPostThreadFailNotification;
NSString * const TTPostTaskSuccessNotification = kTTForumPostThreadSuccessNotification;
NSString * const TTPostTaskDeletedNotification = kTTForumDeleteFakeThreadNotification;

NSString * const TTPostTaskNotificationUserInfoKeyFakeID = kTTForumPostThreadFakeThreadID;
NSString * const TTPostTaskNotificationUserInfoKeyConcernID = kTTForumPostThreadConcernID;
NSString * const TTPostTaskNotificationUserInfoKeyChallengeGroupID = kTTForumPostThreadChallengeGroupID;

@interface TTForumPostThreadCenter ()
<
TTAccountMulticastProtocol
>
@property (nonatomic, assign) BOOL isNetworkAlertShown;
@property (nonatomic, strong) NSOperationQueue *postThreadOperationQueue;
@property (nonatomic, assign) UIBackgroundTaskIdentifier backgroundTaskIdentifier;

@end

@implementation TTForumPostThreadCenter

+ (instancetype)sharedInstance {
    return [self sharedInstance_tt];
}

- (void)onServiceInit {
    
}

- (void)onServiceClearData {
    
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [TTAccount removeMulticastDelegate:self];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.postThreadOperationQueue = [[NSOperationQueue alloc] init];
        self.postThreadOperationQueue.maxConcurrentOperationCount = 3;
        self.backgroundTaskIdentifier = UIBackgroundTaskInvalid;
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(connectionChanged:)
                                                     name:kReachabilityChangedNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
        
        [TTAccount addMulticastDelegate:self];
    }
    return self;
}

- (void)postTaskWithTaskID:(NSString *)taskID concenID:(NSString *)concernID taskType:(TTForumPostThreadTaskType)taskType suggestedTask:(TTForumPostThreadTask *)suggestedTask {
    
    void (^taskFailureTrackerBlock)(TTForumPostThreadTask *) = ^(TTForumPostThreadTask *failureTask) {
        
        NSString *label = nil;
        if (failureTask.taskType == TTForumPostThreadTaskTypeThread) {
            if ([failureTask.images count] > 0) {
                label = @"post_pic_fail";
            }
            else {
                label = @"post_fail";
            }
        }
        else if (failureTask.taskType == TTForumPostThreadTaskTypeVideo) {
            label = @"post_video_fail";
        }
        
        NSMutableDictionary * dictionary = [NSMutableDictionary dictionaryWithCapacity:10];
        [dictionary setValue:@"umeng" forKey:@"category"];
        [dictionary setValue:@"topic_post" forKey:@"tag"];
        [dictionary setValue:label forKey:@"label"];
        [dictionary setValue:failureTask.concernID forKey:@"concern_id"];
        [dictionary setValue:failureTask.categoryID forKey:@"category_id"];
        [dictionary setValue:@(failureTask.refer) forKey:@"refer"];
        if (failureTask.extraTrack.count > 0) {
            [dictionary setValuesForKeysWithDictionary:failureTask.extraTrack];
        }
        [TTTrackerWrapper eventData:dictionary];
    };
    
    NSOperation<TTForumPostThreadOperationProtocol> *operation = [TTForumPostThreadOperation operationWithPostThreadTaskID:taskID concernID:concernID taskType:taskType suggestedTask:suggestedTask stateUpdatedBlock:^(TTForumPostThreadTask *task, TTForumPostThreadOperationState lastState, TTForumPostThreadOperationState currentState) {
        switch (currentState) {
            case TTForumPostThreadOperationStatePending:
            {
                task.isPosting = YES;
                NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
                [userInfo setValue:task.concernID forKey:kTTForumPostThreadConcernID];
                [userInfo addEntriesFromDictionary:[TTForumPostThreadTask fakeThreadDictionary:task]];
                [[NSNotificationCenter defaultCenter] postNotificationName:kTTForumPostingThreadNotification object:task userInfo:userInfo];
            }
                break;
            case TTForumPostThreadOperationStateResumed:
            {
                task.isPosting = YES;
                [[NSNotificationCenter defaultCenter] postNotificationName:kTTForumResumeThreadNotification object:task userInfo:nil];
            }
                break;
            default:
                break;
        }
        [[TTForumPostThreadTaskCenter sharedInstance] asyncSaveTask:task];
    } successBlock:^(TTForumPostThreadTask *task, NSDictionary *resultModelDict) {
        task.isPosting = NO;
        task.retryCount += 1;
        NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
        [userInfo setValue:task.concernID forKey:kTTForumPostThreadConcernID];
        [userInfo setValue:[NSNumber numberWithLongLong:task.fakeThreadId] forKey:kTTForumPostThreadFakeThreadID];
        [userInfo setValue:[NSNumber numberWithLongLong:task.create_time] forKey:@"create_time"];
        
        [userInfo setValue:[NSNumber numberWithLongLong:[TTForumPostThreadTask repostOperationItemTypeFromOptType:task.opt_id_type]] forKey:@"repostOperationItemType"];
        [userInfo setValue:task.opt_id forKey:@"repostOperationItemID"];
        [userInfo setValue:task.fw_id forKey:@"repost_fw_id"];
        [userInfo setValue:@(task.fw_id_type) forKey:@"repost_fw_id_type"];
        [userInfo setValue:@(task.repostType) forKey:@"repost_type"];
        [userInfo setValue:@(task.repostToComment) forKey:@"is_repost_to_comment"];
        [userInfo addEntriesFromDictionary:task.responseDict];
        
        if (task.taskType == TTForumPostThreadTaskTypeVideo) {
            [GET_SERVICE_BY_PROTOCOL(TTVideoPublishMonitor) trackVideoWithType:task.video.videoSourceType state:TTVideoPublishTrackPublishDone extra:task.extraTrackForVideoPublishDone];
            [TTTracker eventV3:@"video_publish_done" params:[task extraTrackForVideoPublishDone]];
            [GET_SERVICE_BY_PROTOCOL(TTVideoPublishMonitor) trackVideoAction:TTVideoPublishActionDone extra:[task extraTrackForVideoPublishDone]];
        }
        
//        if (task.requestRedPacketType == TTRequestRedPacketTypeFestival) {
//            NSString *groupID = [task.responseDict tt_stringValueForKey:@"id"];
//            [TTPostVideoRedpackDelegate handleSpringFestivalRedPacketWithGroupID:groupID];
//        } else if (task.requestRedPacketType == TTRequestRedPacketTypeDefault){
//            [TTPostVideoRedpackDelegate handlePostTaskSucceeded:task];
//        }

        NSTimeInterval postSucessTime = [[NSDate date] timeIntervalSince1970];
        [userInfo setValue:@(postSucessTime) forKey:kFRPostThreadSucessTime];

        BOOL isRepost = (!isEmptyString(task.opt_id) && task.repostType != TTThreadRepostTypeNone);
        [userInfo setValue:@(isRepost) forKey:kFRPostThreadIsRepost];

        [[NSNotificationCenter defaultCenter] postNotificationName:kTTForumPostThreadSuccessNotification object:task userInfo:userInfo];

        //对于转发帖单独发一堆通知,并且对应的opt_id/fw_id的帖子转发数加1
        if (!isEmptyString(task.opt_id) && task.repostType != TTThreadRepostTypeNone) {
            // 转发的 opt_id 的 repostCount +1
            id<FRActionDataProtocol> optActionDataModel = [GET_SERVICE(FRActionDataService) modelWithUniqueID:task.opt_id];
            optActionDataModel.repostCount = optActionDataModel.repostCount + 1;

            // 评论并转发 opt_id 的 commentCount +1
            if (task.repostToComment) {
                optActionDataModel.commentCount = optActionDataModel.commentCount + 1;
            }

            // 转发的 fw_id 作为二级转发, repostCount +1
            if (task.fw_id && ![task.fw_id isEqualToString:task.opt_id]) {
                id<FRActionDataProtocol> fwActionDataModel = [GET_SERVICE(FRActionDataService) modelWithUniqueID:task.fw_id];
                fwActionDataModel.repostCount = fwActionDataModel.repostCount + 1;
            }

            //转发的逻辑(包括纯转发、转发并评论、转发并回复)
            [[NSNotificationCenter defaultCenter] postNotificationName:kTTForumRePostThreadSuccessNotification object:task userInfo:userInfo];


            //转发并评论/回复的逻辑
            //此时返回的数据实际是一个commentrepost ，需转化为commentmodel
            if (task.repostTaskType == TTForumRepostThreadTaskType_Comment) {

                [[NSNotificationCenter defaultCenter] postNotificationName:kTTForumRePostAndCommentThreadSuccessNotification object:task userInfo:userInfo];

            }
            //此时返回的数据实际是一个commentrepost + replyid，需转化为replymodel
            else if (task.repostTaskType == TTForumRepostThreadTaskType_Reply){
                [[NSNotificationCenter defaultCenter] postNotificationName:kTTForumRePostAndReplyThreadSuccessNotification object:task userInfo:userInfo];
            }

        }

        [[TTForumPostThreadTaskCenter sharedInstance] asyncRemoveTaskFromDiskByTaskID:task.taskID concernID:task.concernID];
    } cancelledBlock:^(TTForumPostThreadTask *task, TTForumPostThreadOperationCancelHint cancelHint) {
        task.isPosting = YES;
        task.retryCount += 1;
        taskFailureTrackerBlock(task);
        if (cancelHint == TTForumPostThreadOperationCancelHintRemove) {
            [GET_SERVICE_BY_PROTOCOL(TTVideoPublishMonitor) trackVideoWithType:task.video.videoSourceType state:TTVideoPublishTrackUploadDeleted extra:task.extraTrackForVideo];
            [[TTForumPostThreadTaskCenter sharedInstance] asyncRemoveTaskFromDiskByTaskID:task.taskID concernID:task.concernID];
            NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] init];
            [userInfo setValue:@(task.fakeThreadId) forKey:kTTForumPostThreadFakeThreadID];
            [userInfo setValue:task.concernID forKey:kTTForumPostThreadConcernID];
            [[NSNotificationCenter defaultCenter] postNotificationName:kTTForumDeleteFakeThreadNotification
                                                                object:nil
                                                              userInfo:userInfo];
        }
        else {
            NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
            [userInfo setValue:[NSNumber numberWithLongLong:task.fakeThreadId] forKey:kTTForumPostThreadFakeThreadID];
            [userInfo setValue:task.concernID forKey:kTTForumPostThreadConcernID];
            [GET_SERVICE_BY_PROTOCOL(TTVideoPublishMonitor) trackVideoWithType:task.video.videoSourceType state:TTVideoPublishTrackUploadFailed extra:task.extraTrackForVideo];
            [[NSNotificationCenter defaultCenter] postNotificationName:kTTForumPostThreadFailNotification object:task userInfo:[userInfo copy]];
            [[TTForumPostThreadTaskCenter sharedInstance] asyncSaveTask:task];
        }
    } failureBlock:^(TTForumPostThreadTask *task, NSError *error) {
        task.isPosting = YES;
        task.retryCount += 1;
        taskFailureTrackerBlock(task);
        NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
        [userInfo setValue:[NSNumber numberWithLongLong:task.fakeThreadId] forKey:kTTForumPostThreadFakeThreadID];
        [userInfo setValue:task.concernID forKey:kTTForumPostThreadConcernID];
        [[NSNotificationCenter defaultCenter] postNotificationName:kTTForumPostThreadFailNotification object:task userInfo:[userInfo copy]];
        [[TTForumPostThreadTaskCenter sharedInstance] asyncSaveTask:task];
        if ([task needUploadVideo]) {
            [GET_SERVICE_BY_PROTOCOL(TTVideoPublishMonitor) trackVideoWithType:task.video.videoSourceType state:TTVideoPublishTrackUploadFailed extra:task.extraTrackForVideo];
        }
        else if ([task needUploadVideoCover]) {
            [GET_SERVICE_BY_PROTOCOL(TTVideoPublishMonitor) trackVideoWithType:task.video.videoSourceType state:TTVideoPublishTrackCoverUploadFailed extra:task.extraTrackForVideo];
        }
        else {
            [GET_SERVICE_BY_PROTOCOL(TTVideoPublishMonitor) trackVideoWithType:task.video.videoSourceType state:TTVideoPublishTrackPublishFailed extra:task.extraTrackForVideo];
        }
    }];
    [self.postThreadOperationQueue addOperation:operation];
}

- (void)postThreadWithContent:(nullable NSString *)content
             contentRichSpans:(nullable NSString *)contentRichSpans
                 mentionUsers:(nullable NSString *)mentionUsers
              mentionConcerns:(nullable NSString *)mentionConcerns
                        title:(nullable NSString *)title
                  phoneNumber:(nullable NSString *)phoneNumber
                    fromWhere:(FRFromWhereType)fromWhere
                    concernID:(nonnull NSString *)concernID
                   categoryID:(nullable NSString *)categoryID
                   taskImages:(nullable NSArray<TTForumPostImageCacheTask *> *)taskImages
                  thumbImages:(nullable NSArray<UIImage *> *)thumbImages
                  needForward:(NSInteger)needForward
                         city:(nullable NSString *)city
                    detailPos:(nullable NSString *)detailPos
                    longitude:(CGFloat)longitude
                     latitude:(CGFloat)latitude
                        score:(CGFloat)score
                        refer:(NSUInteger)refer
             postUGCEnterFrom:(TTPostUGCEnterFrom)postUGCEnterFrom
                   extraTrack:(nullable NSDictionary *)extraTrack
                  finishBlock:(nullable void (^)(void))finishBlock {

    [Answers logCustomEventWithName:@"ugc_post" customAttributes:@{@"sence" : @"post"}];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        TTForumPostThreadTask *task = [[TTForumPostThreadTask alloc] initWithTaskType:TTForumPostThreadTaskTypeThread];
#if DEBUG
        task.debug_currentMethod = [TTUGCBacktraceLogger ttugc_backtraceOfCurrentThread];
#endif
        task.title = title;
        task.content = content;
        task.contentRichSpans = contentRichSpans;
        task.mentionUser = mentionUsers;
        task.mentionConcern = mentionConcerns;
        task.create_time = [[NSDate date] timeIntervalSince1970];
        task.userID = [TTAccountManager userID];
        task.concernID = concernID;
        task.categoryID = categoryID;
        [task addTaskImages:taskImages thumbImages:thumbImages];
        task.source = 2;//来源于话题
        task.forward = needForward;
        task.latitude = latitude;
        task.longitude = longitude;
        task.city = city;
        task.detail_pos = detailPos;
        task.phone = phoneNumber;
        task.fromWhere = fromWhere;
        task.score = score;
        task.refer = refer;
        task.postUGCEnterFrom = postUGCEnterFrom;
        task.extraTrack = extraTrack.copy;
        
        UGCLog(@"taskId:%@", (task? task.taskID: @""));
        
        if (!task) {
            return;
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (finishBlock) {
                finishBlock();
            }
            [self postTaskWithTaskID:task.taskID concenID:task.concernID taskType:TTForumPostThreadTaskTypeThread suggestedTask:task];
        });
    });
}

- (void)repostWithRepostThreadModel:(TTRepostThreadModel *)repostThreadModel
                      withConcernID:(NSString *)concernID
                     withCategoryID:(NSString *)categoryID
                              refer:(NSUInteger)refer
                         extraTrack:(nullable NSDictionary *)extraTrack
                        finishBlock:(nullable void(^)(void))finishBlock{

    [Answers logCustomEventWithName:@"ugc_post" customAttributes:@{@"sence" : @"repost"}];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        TTForumPostThreadTask *task = [[TTForumPostThreadTask alloc] initWithTaskType:TTForumPostThreadTaskTypeThread];
#if DEBUG
        task.debug_currentMethod = [TTUGCBacktraceLogger ttugc_backtraceOfCurrentThread];
#endif
        task.userID = [TTAccountManager userID];
        task.repostType = repostThreadModel.repost_type;
        task.content = repostThreadModel.content;
        task.contentRichSpans = repostThreadModel.content_rich_span;
        task.mentionUser = repostThreadModel.mentionUsers;
        task.coverUrl = repostThreadModel.cover_url;
        task.mentionConcern = repostThreadModel.mentionConcerns;
        task.create_time = [[NSDate date] timeIntervalSince1970];
        task.fw_id = repostThreadModel.fw_id;
        task.fw_id_type = repostThreadModel.fw_id_type;
        task.opt_id = repostThreadModel.opt_id;
        task.opt_id_type = repostThreadModel.opt_id_type;
        task.fw_user_id = repostThreadModel.fw_user_id;
        task.concernID = concernID;
        task.categoryID = categoryID;
        task.refer = refer;
        task.extraTrack = extraTrack.copy;
        task.repostTitle = repostThreadModel.repostTitle;
        task.repostSchema = repostThreadModel.repostSchema;
        task.repostToComment = repostThreadModel.repostToComment;
        
        if (!task) {
            return;
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (finishBlock) {
                finishBlock();
            }
            [self postTaskWithTaskID:task.taskID concenID:task.concernID taskType:TTForumPostThreadTaskTypeThread suggestedTask:task];
        });
    });
    
}

- (void)postVideoThreadWithTitle:(nonnull NSString *)title
               withTitleRichSpan:(nullable NSString *)titleRichSpan
                withMentionUsers:(nullable NSString *)mentionUsers
             withMentionConcerns:(nullable NSString *)mentionConcerns
                       videoPath:(nonnull NSString *)videoPath
                   videoDuration:(NSInteger)videoDuration
                          height:(CGFloat)height
                           width:(CGFloat)width
                       videoName:(nonnull NSString *)videoName
                 videoSourceType:(TTPostVideoSource)videoSourceType
                      coverImage:(nonnull UIImage *)coverImage
             coverImageTimestamp:(NSTimeInterval)coverImageTimestamp
                videoCoverSource:(TTVideoCoverSourceType)videoCoverSource
                         musicID:(nullable NSString *)musicID
                       concernID:(nonnull NSString *)concernID
                      categoryID:(nullable NSString *)categoryID
                           refer:(NSUInteger)refer
                postUGCEnterFrom:(TTPostUGCEnterFrom)postUGCEnterFrom
            requestRedPacketType:(TTRequestRedPacketType)requestRedPacketType
                challengeGroupID:(NSString *)challengeGroupID
                      extraTrack:(nullable NSDictionary *)extraTrack
                     finishBlock:(nullable void(^)(void))finishBlock {
    [Answers logCustomEventWithName:@"ugc_post" customAttributes:@{@"sence" : @"video"}];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        TTForumPostThreadTask *task = [[TTForumPostThreadTask alloc] initWithTaskType:TTForumPostThreadTaskTypeVideo];
#if DEBUG
        task.debug_currentMethod = [TTUGCBacktraceLogger ttugc_backtraceOfCurrentThread];
#endif
        task.title = title;
        task.titleRichSpan = titleRichSpan;
        task.mentionUser = mentionUsers;
        task.mentionConcern = mentionConcerns;
        task.create_time = [[NSDate date] timeIntervalSince1970];
        task.userID = [TTAccountManager userID];
        task.concernID = concernID;
        task.categoryID = categoryID;
        task.refer = refer;
        task.postUGCEnterFrom = postUGCEnterFrom;
        task.requestRedPacketType = requestRedPacketType;
        task.challengeGroupID = challengeGroupID;
        task.extraTrack = extraTrack.copy;
        
        TTForumUploadVideoModel *uploadVideoModel = [[TTForumUploadVideoModel alloc] init];
        uploadVideoModel.videoName = videoName;
        uploadVideoModel.videoPath = videoPath;
        uploadVideoModel.videoDuration = videoDuration;
        uploadVideoModel.videoSourceType = videoSourceType;
        uploadVideoModel.height = height;
        uploadVideoModel.width = width;
        uploadVideoModel.videoCoverSourceType = videoCoverSource;
        uploadVideoModel.coverImageTimestamp = coverImageTimestamp;
        uploadVideoModel.musicID = musicID;
        task.video = uploadVideoModel;
        
        FRUploadImageModel *coverImageModel = [[FRUploadImageModel alloc] initWithCacheTask:[[TTForumPostImageCache sharedInstance] saveCacheSource:coverImage] thumbnail:coverImage];
        coverImageModel.fakeUrl = [FRUploadImageModel fakeUrl:task.taskID index:0];
        uploadVideoModel.coverImage = coverImageModel;
        
        if (!task) {
            return;
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [[TTPostVideoCacheHelper sharedHelper] retainVideoAtPath:task.video.videoPath];
            if (finishBlock) {
                finishBlock();
            }
            [self postTaskWithTaskID:task.taskID concenID:task.concernID taskType:TTForumPostThreadTaskTypeVideo suggestedTask:task];
        });
    });
}


- (void)postVideoThreadWithTitle:(nonnull NSString *)title
               withTitleRichSpan:(nullable NSString *)titleRichSpan
                withMentionUsers:(nullable NSString *)mentionUsers
             withMentionConcerns:(nullable NSString *)mentionConcerns
                       videoPath:(nonnull NSString *)videoPath
                   videoDuration:(NSInteger)videoDuration
                          height:(CGFloat)height
                           width:(CGFloat)width
                       videoName:(nonnull NSString *)videoName
                 videoSourceType:(TTPostVideoSource)videoSourceType
                      coverImage:(nonnull UIImage *)coverImage
             coverImageTimestamp:(NSTimeInterval)coverImageTimestamp
                videoCoverSource:(TTVideoCoverSourceType)videoCoverSource
                         musicID:(nullable NSString *)musicID
                       concernID:(nonnull NSString *)concernID
                      categoryID:(nullable NSString *)categoryID
                           refer:(NSUInteger)refer
                postUGCEnterFrom:(TTPostUGCEnterFrom)postUGCEnterFrom
                      extraTrack:(nullable NSDictionary *)extraTrack
                     finishBlock:(nullable void(^)(void))finishBlock
{
    [self postVideoThreadWithTitle:title
                 withTitleRichSpan:titleRichSpan
                  withMentionUsers:mentionUsers
               withMentionConcerns:mentionConcerns
                         videoPath:videoPath
                     videoDuration:videoDuration
                            height:height
                             width:width
                         videoName:videoName
                   videoSourceType:videoSourceType
                        coverImage:coverImage
               coverImageTimestamp:coverImageTimestamp
                  videoCoverSource:videoCoverSource
                           musicID:musicID
                         concernID:concernID
                        categoryID:categoryID
                             refer:refer
                  postUGCEnterFrom:postUGCEnterFrom
            requestRedPacketType:TTRequestRedPacketTypeDefault
                  challengeGroupID:nil
                        extraTrack:extraTrack
                       finishBlock:finishBlock];
     
}


- (nullable NSArray <TTForumPostThreadTask *> *)fetchTasksFromDiskForConcernID:(nonnull NSString *)concernID {
    return [TTForumPostThreadTask fetchTasksFromDiskForConcernID:concernID];
}

- (void)resentThreadForFakeThreadID:(int64_t)fakeTID concernID:(NSString *)cid {
    NSString * taskID = [TTForumPostThreadTask taskIDFromFakeThreadID:fakeTID];
    [self postTaskWithTaskID:taskID concenID:cid taskType:TTForumPostThreadTaskTypeThread suggestedTask:nil];
}

- (void)resentVideoForFakeThreadID:(int64_t)fakeTID concernID:(NSString *)cid {
    NSString *taskID = [TTForumPostThreadTask taskIDFromFakeThreadID:fakeTID];
    [self postTaskWithTaskID:taskID concenID:cid taskType:TTForumPostThreadTaskTypeVideo suggestedTask:nil];
    [TTForumPostThreadTask fetchTaskFromDiskByTaskID:[TTForumPostThreadTask taskIDFromFakeThreadID:fakeTID] concernID:cid completion:^(TTForumPostThreadTask * _Nonnull task) {
        [GET_SERVICE_BY_PROTOCOL(TTVideoPublishMonitor) trackVideoWithType:task.video.videoSourceType state:TTVideoPublishTrackFailRetry extra:task.extraTrackForVideo];
    }];
}

- (void)removeTaskForFakeThreadID:(int64_t)fakeTID concernID:(NSString *)cid {
    
    __block BOOL taskIsInOperationQueue = NO;
    NSString * taskID = [TTForumPostThreadTask taskIDFromFakeThreadID:fakeTID];
    [self.postThreadOperationQueue.operations enumerateObjectsUsingBlock:^(__kindof NSOperation * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj conformsToProtocol:@protocol(TTForumPostThreadOperationProtocol)]) {
            NSOperation<TTForumPostThreadOperationProtocol> *operation = (NSOperation<TTForumPostThreadOperationProtocol> *)obj;
            if ([operation.taskID isEqualToString:taskID] && [operation.concernID isEqualToString:cid]) {
                taskIsInOperationQueue = YES;
                [operation cancelWithHint:TTForumPostThreadOperationCancelHintRemove];
            }
        }
    }];
    
    if (!taskIsInOperationQueue) {
        TTForumPostThreadTask *task = [TTForumPostThreadTask fetchTaskFromDiskByTaskID:taskID concernID:cid];
        if (task.taskType == TTForumPostThreadTaskTypeVideo) {
            [GET_SERVICE_BY_PROTOCOL(TTVideoPublishMonitor) trackVideoWithType:task.video.videoSourceType state:TTVideoPublishTrackFailDelete extra:task.extraTrackForVideo];
        }
        NSMutableDictionary *userInfo = [NSMutableDictionary new];
        [userInfo setValue:@(fakeTID) forKey:kTTForumPostThreadFakeThreadID];
        [userInfo setValue:cid forKey:kTTForumPostThreadConcernID];
        [userInfo setValue:task.challengeGroupID forKey:kTTForumPostThreadChallengeGroupID];
        [[NSNotificationCenter defaultCenter] postNotificationName:kTTForumDeleteFakeThreadNotification
                                                            object:nil
                                                          userInfo:[userInfo copy]];
        if (!isEmptyString(task.video.videoPath)) {
            [[TTPostVideoCacheHelper sharedHelper] releaseVideoAtPath:task.video.videoPath];
        }
        [[TTForumPostThreadTaskCenter sharedInstance] asyncRemoveTaskFromDiskByTaskID:taskID concernID:cid];
        if ([KitchenMgr getBOOL:kKCVideoUploadSDKEnable]) {
            [[TTForumVideoUploaderSDKManager sharedUploader] cancelAndRemoveUploadWithTaskID:taskID];
        }
    }
}

#pragma mark - TTAccountMulticastProtocol

- (void)onAccountStatusChanged:(TTAccountStatusChangedReasonType)reasonType platform:(NSString *)platformName
{
    [self.postThreadOperationQueue.operations enumerateObjectsUsingBlock:^(__kindof NSOperation * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj conformsToProtocol:@protocol(TTForumPostThreadOperationProtocol)]) {
            NSOperation<TTForumPostThreadOperationProtocol> *operation = (NSOperation<TTForumPostThreadOperationProtocol> *)obj;
            [operation cancelWithHint:TTForumPostThreadOperationCancelHintCancel];
        }
    }];
}

#pragma mark - notification

- (void)connectionChanged:(NSNotification *)notification {
    WeakSelf;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        StrongSelf;
        [self showNetworkAlertIfNeeded];
    });
}

- (void)showNetworkAlertIfNeeded {
    if (self.isNetworkAlertShown) {
        return;
    }
    
    if (!TTNetworkWifiConnected() && TTNetworkConnected()) {
        NSMutableArray<NSOperation<TTForumPostThreadOperationProtocol> *> *cancellableOperations = [[NSMutableArray alloc] init];
        [self.postThreadOperationQueue.operations enumerateObjectsUsingBlock:^(__kindof NSOperation * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj conformsToProtocol:@protocol(TTForumPostThreadOperationProtocol)]) {
                NSOperation<TTForumPostThreadOperationProtocol> *operation = (NSOperation<TTForumPostThreadOperationProtocol> *)obj;
                if (operation.taskType == TTForumPostThreadTaskTypeVideo && operation.cancellable) {
                    [operation cancelWithHint:TTForumPostThreadOperationCancelHintCancel];
                    [cancellableOperations addObject:operation];
                }
            }
        }];
        if ([cancellableOperations count] > 0) {
            TTThemedAlertController *alert = [[TTThemedAlertController alloc] initWithTitle:NSLocalizedString(@"当前使用的是移动网络，是否继续发送", nil) message:nil preferredType:TTThemedAlertControllerTypeAlert];
            [alert addActionWithTitle:NSLocalizedString(@"取消", nil) actionType:TTThemedAlertActionTypeNormal actionBlock:^{
                self.isNetworkAlertShown = NO;
            }];
            [alert addActionWithTitle:NSLocalizedString(@"确认", nil) actionType:TTThemedAlertActionTypeNormal actionBlock:^{
                [cancellableOperations enumerateObjectsUsingBlock:^(NSOperation<TTForumPostThreadOperationProtocol> * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    [self postTaskWithTaskID:obj.taskID concenID:obj.concernID taskType:TTForumPostThreadTaskTypeVideo suggestedTask:nil];
                }];
                self.isNetworkAlertShown = NO;
            }];
            [alert showFrom:[TTUIResponderHelper topmostViewController] animated:YES];
            self.isNetworkAlertShown = YES;
        }
    }
}

- (void)applicationDidEnterBackground:(NSNotification *)notification {
    if ([[self.postThreadOperationQueue operations] count] > 0) {
        
        UIApplication *app = [UIApplication sharedApplication];
        if (self.backgroundTaskIdentifier != UIBackgroundTaskInvalid) {
            
            [app endBackgroundTask:self.backgroundTaskIdentifier];
            self.backgroundTaskIdentifier = UIBackgroundTaskInvalid;
        }
        
        WeakSelf;
        self.backgroundTaskIdentifier = [app beginBackgroundTaskWithExpirationHandler:^{
            StrongSelf;
            [self.postThreadOperationQueue cancelAllOperations];
            [app endBackgroundTask:self.backgroundTaskIdentifier];
            self.backgroundTaskIdentifier = UIBackgroundTaskInvalid;
        }];
    }
}

- (void)applicationWillEnterForeground:(NSNotification *)notification {
    if (self.backgroundTaskIdentifier != UIBackgroundTaskInvalid) {
        UIApplication *app = [UIApplication sharedApplication];
        [app endBackgroundTask:self.backgroundTaskIdentifier];
        self.backgroundTaskIdentifier = UIBackgroundTaskInvalid;
    }
}

#pragma mark - Cache

+ (void)clearCache {
    [TTForumPostThreadTask removeAllDiskTask];
}

@end

@implementation TTForumPostThreadCenter (ProtocolIMP)

- (NSArray *)protocol_fetchDiscTaskForConcernID:(nonnull NSString *)concernID {
    NSArray<TTForumPostThreadTask *> *tasks = [TTForumPostThreadTask fetchTasksFromDiskForConcernID:concernID];
    [tasks enumerateObjectsUsingBlock:^(TTForumPostThreadTask * _Nonnull task, NSUInteger idx, BOOL * _Nonnull stop) {
        task.isPosting = YES;
        if (!task.finishError) {
            //默认错误信息
            task.finishError = [NSError errorWithDomain:kFRPostThreadErrorDomain code:FRPostThreadErrorCodeNoNetwork userInfo:nil];
        }
    }];
    return tasks;
}

- (void)protocol_asyncFetchDiscTaskForConcernID:(NSString *)concernID completion:(void (^)(NSArray *))completion {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSArray<TTForumPostThreadTask *> *tasks = [TTForumPostThreadTask fetchTasksFromDiskForConcernID:concernID];
        dispatch_async(dispatch_get_main_queue(), ^{
            [tasks enumerateObjectsUsingBlock:^(TTForumPostThreadTask * _Nonnull task, NSUInteger idx, BOOL * _Nonnull stop) {
                task.isPosting = YES;
                if (!task.finishError) {
                    //默认错误信息
                    task.finishError = [NSError errorWithDomain:kFRPostThreadErrorDomain code:FRPostThreadErrorCodeNoNetwork userInfo:nil];
                }
            }];
            if (completion) {
                completion(tasks);
            }
        });
    });
}

- (void)protocol_resentShortVideoForFakeID:(int64_t)fakeID concernID:(NSString *)concernID {
    [self resentVideoForFakeThreadID:fakeID concernID:concernID];
    [TTForumPostThreadTask fetchTaskFromDiskByTaskID:[TTForumPostThreadTask taskIDFromFakeThreadID:fakeID] concernID:concernID completion:^(TTForumPostThreadTask * _Nonnull task) {
        [TTTracker eventV3:@"video_publish_fail_retry" params:[task extraTrackForVideo]];
    }];
}

- (void)protocol_removeShortVideoTaskForFakeID:(int64_t)fakeID concernID:(NSString *)concernID {
    WeakSelf;
    [TTForumPostThreadTask fetchTaskFromDiskByTaskID:[TTForumPostThreadTask taskIDFromFakeThreadID:fakeID] concernID:concernID completion:^(TTForumPostThreadTask * _Nonnull task) {
        StrongSelf;
        [TTTracker eventV3:@"video_publish_fail_delete" params:[task extraTrackForVideo]];
        [GET_SERVICE_BY_PROTOCOL(TTVideoPublishMonitor) trackVideoAction:TTVideoPublishActionFailDelete extra:[task extraTrackForVideo]];
        [self removeTaskForFakeThreadID:fakeID concernID:concernID];
    }];
}

- (void)protocol_postShortVideoFromConcernHomepage:(TTRecordedVideo *)video concernID:(NSString *)concernID categoryID:(NSString *)categoryID extraTrack:(NSDictionary *)extraTrack {
    [self postShortVideo:video from:TTPostUGCEnterFromConcernHomepage refer:2 concernID:concernID categoryID:categoryID requestRedPacketType:TTRequestRedPacketTypeDefault challengeGroupID:nil extraTrack:extraTrack];
}

- (void)protocol_postShortVideo:(TTRecordedVideo *)video concernID:(NSString *)concernID categoryID:(NSString *)categoryID extraTrack:(NSDictionary *)extraTrack {
    [self postShortVideo:video from:TTPostUGCEnterFromConcernHomepage refer:1 concernID:concernID categoryID:categoryID requestRedPacketType:TTRequestRedPacketTypeDefault challengeGroupID:nil extraTrack:extraTrack];
}

- (void)postShortVideo:(TTRecordedVideo *)video
                  from:(TTPostUGCEnterFrom)postUGCEnterFrom
                 refer:(NSInteger)refer
             concernID:(NSString *)concernID
            categoryID:(NSString *)categoryID
  requestRedPacketType:(TTRequestRedPacketType)requestRedPacketType
      challengeGroupID:(NSString *)challengeGroupID
            extraTrack:(NSDictionary *)extraTrack
{
    
    AVAssetTrack *videoTrack = [[video.videoAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
    CGSize videoSize = [videoTrack naturalSize];
    CGAffineTransform txf = [videoTrack preferredTransform];
    CGRect nRect = CGRectApplyAffineTransform(CGRectMake(0, 0, videoSize.width, videoSize.height), txf);
    videoSize = nRect.size;
    
    NSString * homeDirectory = NSHomeDirectory();
    NSString * outputVideoRelativeUrl = video.videoURL.path;
    if (homeDirectory.length < outputVideoRelativeUrl.length) {
        outputVideoRelativeUrl = [outputVideoRelativeUrl substringFromIndex:homeDirectory.length];
    }
    
    [self postVideoThreadWithTitle:video.title
                 withTitleRichSpan:video.title_rich_span
                  withMentionUsers:video.mentionUser
               withMentionConcerns:video.mentionConcern
                         videoPath:outputVideoRelativeUrl
                     videoDuration:CMTimeGetSeconds(video.videoAsset.duration)
                            height:videoSize.height
                             width:videoSize.width
                         videoName:[video.videoURL.path lastPathComponent]
                   videoSourceType:video.postVideoSource
                        coverImage:video.coverImage
               coverImageTimestamp:video.coverImageTimestamp
                  videoCoverSource:video.videoCoverSource
                           musicID:video.musicID
                         concernID:concernID
                        categoryID:categoryID
                             refer:refer
                  postUGCEnterFrom:postUGCEnterFrom
              requestRedPacketType:requestRedPacketType
                  challengeGroupID:challengeGroupID
                        extraTrack:extraTrack
                       finishBlock:nil];
}

@end
