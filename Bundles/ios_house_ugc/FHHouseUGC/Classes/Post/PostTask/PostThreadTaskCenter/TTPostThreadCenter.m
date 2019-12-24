//
//  TTPostThreadCenter.m
//  Article
//
//  Created by 王霖 on 3/16/16.
//
//

#import "TTPostThreadCenter.h"
#import "TTPostThreadDefine.h"
#import "TTPostThreadOperation.h"
#import "TTPostThreadBridge.h"
//#import "TTRepostThreadModel.h"
#import "TTPostThreadKitchenConfig.h"

#import <TTBaseLib/TTUIResponderHelper.h>
//#import <TTServiceProtocols/TTPostService.h>
#import <TTReachability/TTReachability.h>
//#import <TTUGCDataService/TTUGCActionDataService.h>
#import <TTPostBase/TTPostTaskCenter.h>
#import <TTBaseLib/TTUIResponderHelper.h>
#import <TTUIWidget/TTThemedAlertController.h>
#import <TTBaseLib/TTBaseMacro.h>
#import <TTPlatformBaseLib/TTTrackerWrapper.h>
//#import <TTServiceProtocols/TTAccountProvider.h>
#import "TTPostDraftManager.h"
#import "SDWebImageAdapter.h"
#import "UIImage+MultiFormat.h"
#import "FLAnimatedImage.h"
//#import "TTUGCEditedThreadDefine.h"
//#import <BDMobileRuntime/BDMobileRuntime.h>
//#import <TTRegistry/TTRegistryDefines.h>
#import <Heimdallr/HMDTTMonitor.h>
#import <TTUGCFoundation/TTUGCMonitorDefine.h>
#import "TTAccount.h"
#import "TTAccountManager.h"
#import "FHUGCConfig.h"
#import "ToastManager.h"
#import "FHUserTracker.h"
#import "FHFeedUGCContentModel.h"
#import "FHMainApi.h"
#import "FHFeedUGCCellModel.h"
#import "FHEnvContext.h"
#import <FHHouseUGCAPI.h>
#import <FHUGCEditedPostModel.h>
#import <FRUploadImageManager.h>

NSString * const TTPostTaskBeginNotification = kTTForumPostingThreadNotification;
NSString * const TTPostTaskResumeNotification = kTTForumResumeThreadNotification;
NSString * const TTPostTaskdProgressUpdateNotification = kTTForumThreadProgressUpdateNotification;
NSString * const TTPostTaskFailNotification = kTTForumPostThreadFailNotification;
NSString * const TTPostTaskSuccessNotification = kTTForumPostThreadSuccessNotification;
NSString * const TTPostTaskDeletedNotification = kTTForumDeleteFakeThreadNotification;

NSString * const TTPostTaskNotificationUserInfoKeyFakeID = kTTForumPostThreadFakeThreadID;
NSString * const TTPostTaskNotificationUserInfoKeyConcernID = kTTForumPostThreadConcernID;
NSString * const TTPostTaskNotificationUserInfoKeyChallengeGroupID = kTTForumPostThreadChallengeGroupID;

//编辑完成
#define kTTForumBeginPostEditedThreadNotification @"kTTForumBeginPostEditedThreadNotification"
//编辑完成后发布成功
#define kTTForumPostEditedThreadSuccessNotification @"kTTForumPostEditedThreadSuccessNotification"
//编辑帖子发送失败
#define kTTForumPostEditedThreadFailureNotification @"kTTForumPostEditedThreadFailureNotification"

//帖子数据库更新完成
#define kTTThreadEditedManagerDidUpdateThreadDatabaseNotification @"kTTThreadEditedManagerDidUpdateThreadDatabaseNotification"

//取消发布中的被编辑帖子的发送任务
#define kTTForumPostEditedThreadTaskCancelNotification @"kTTForumPostEditedThreadTaskCancelNotification"

@interface TTPostThreadCenter ()
@property (nonatomic, assign) BOOL isNetworkAlertShown;
@property (nonatomic, strong) NSOperationQueue *postThreadOperationQueue;
@property (nonatomic, assign) UIBackgroundTaskIdentifier backgroundTaskIdentifier;
@property (nonatomic, strong) FRUploadImageManager *uploadImageManager;
@end

@implementation TTPostThreadCenter

+ (instancetype)sharedInstance {
    return [self sharedInstance_tt];
}

- (void)onServiceClearData {
    
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        NSOperationQueue *sharedOperationQueue = [[NSOperationQueue alloc] init];
        sharedOperationQueue.maxConcurrentOperationCount = 3;
        if (sharedOperationQueue) {
            self.postThreadOperationQueue = sharedOperationQueue;
        }
        else {
            self.postThreadOperationQueue = [[NSOperationQueue alloc] init];
            self.postThreadOperationQueue.maxConcurrentOperationCount = 3;
        }
        
        self.backgroundTaskIdentifier = UIBackgroundTaskInvalid;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(editedThreadDidDeleted:) name:kTTForumPostEditedThreadTaskCancelNotification object:nil];
    }
    return self;
}

- (void)postTaskWithTaskID:(NSString *)taskID concenID:(NSString *)concernID taskType:(TTPostTaskType)taskType suggestedTask:(TTPostThreadTask *)suggestedTask {
    
    void (^taskFailureTrackerBlock)(TTPostThreadTask *) = ^(TTPostThreadTask *failureTask) {
        
        NSString *label = nil;
        if ([failureTask.images count] > 0) {
            label = @"post_pic_fail";
        }
        else {
            label = @"post_fail";
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
    
    TTPostThreadOperation *operation = [TTPostThreadOperation operationWithPostThreadTaskID:taskID concernID:concernID suggestedTask:suggestedTask stateUpdatedBlock:^(TTPostThreadTask *task, TTPostThreadOperationState lastState, TTPostThreadOperationState currentState) {
        switch (currentState) {
            case TTPostThreadOperationStatePending:
            {
                task.isPosting = YES;
                NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
                [userInfo setValue:task.concernID forKey:kTTForumPostThreadConcernID];
                [userInfo setValue:task.relatedForumSubjectID forKey:kTTForumPostThreadRelatedForumSubjectID];
                [userInfo setValue:@(task.insertMixCardID) forKey:kTTForumPostThreadInsertMixCardID];

                NSDictionary *dict = [[TTPostThreadBridge sharedInstance] fakeThreadDictionary:task];
                if (dict) {
                    [userInfo addEntriesFromDictionary:dict];
                }
                [[NSNotificationCenter defaultCenter] postNotificationName:kTTForumPostingThreadNotification object:task userInfo:userInfo];
            }
                break;
            case TTPostThreadOperationStateResumed:
            {
                task.isPosting = YES;
                [[NSNotificationCenter defaultCenter] postNotificationName:kTTForumResumeThreadNotification object:task userInfo:nil];
            }
                break;
            default:
                break;
        }
        [[TTPostTaskCenter sharedInstance] asyncSaveTask:task];
    } successBlock:^(TTPostThreadTask *task, NSDictionary *resultModelDict) {
        task.isPosting = NO;
        task.retryCount += 1;
        // 成功埋点 status = 0 成功 status = 1 失败 status = 2 取消
        [[HMDTTMonitor defaultManager] hmdTrackService:@"topic_post" metric:nil category:@{@"status":@(0)} extra:nil];
        NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
        [userInfo setValue:task.concernID forKey:kTTForumPostThreadConcernID];
        [userInfo setValue:task.categoryID forKey:@"category_id"];
        [userInfo setValue:@(task.insertMixCardID) forKey:kTTForumPostThreadInsertMixCardID];
        [userInfo setValue:task.relatedForumSubjectID forKey:kTTForumPostThreadRelatedForumSubjectID];
        [userInfo setValue:[NSNumber numberWithLongLong:task.fakeThreadId] forKey:kTTForumPostThreadFakeThreadID];
        [userInfo setValue:[NSNumber numberWithLongLong:task.create_time] forKey:@"create_time"];
        
        [userInfo setValue:[NSNumber numberWithLongLong:[TTPostThreadTask repostOperationItemTypeFromOptType:task.opt_id_type]] forKey:@"repostOperationItemType"];
        [userInfo setValue:task.opt_id forKey:@"repostOperationItemID"];
        [userInfo setValue:task.repostSchema forKey:@"repostSchema"];
        [userInfo setValue:task.fw_id forKey:@"repost_fw_id"];
        [userInfo setValue:@(task.fw_id_type) forKey:@"repost_fw_id_type"];
        [userInfo setValue:@(task.repostType) forKey:@"repost_type"];
        [userInfo setValue:@(task.repostToComment) forKey:@"is_repost_to_comment"];
        [userInfo addEntriesFromDictionary:task.responseDict];
        NSTimeInterval postSucessTime = [[NSDate date] timeIntervalSince1970];
        [userInfo setValue:@(postSucessTime) forKey:kFRPostThreadSucessTime];
        [userInfo setValue:task.communityID forKey:@"community_id"];
        [userInfo setValue:[NSString stringWithFormat:@"%lld", task.fakeThreadId] forKey:kTTForumPostThreadFakeThreadID];
        [userInfo setValue:resultModelDict forKey:@"result_model"];

        BOOL isRepost = (!isEmptyString(task.opt_id) && task.repostType != TTThreadRepostTypeNone);
        [userInfo setValue:@(isRepost) forKey:kFRPostThreadIsRepost];
        [userInfo setValue:task.social_group_id forKey:@"social_group_id"];
        [userInfo setValue:@(FHUGCPublishTypePost) forKey:@"publish_type"];

        // 发帖成功
        if (task.social_group_id.length > 0) {
            
            // 存储发布历史
            NSString* currentUserID = [TTAccountManager currentUser].userID.stringValue;
            NSString *currentCityID = [FHEnvContext getCurrentSelectCityIdFromLocal];
            if(currentCityID.length > 0 && currentUserID.length > 0) {
                FHPostUGCSelectedGroupHistory *selectedGroupHistory = [[FHUGCConfig sharedInstance] loadPublisherHistoryData];
                if(!selectedGroupHistory) {
                    selectedGroupHistory = [FHPostUGCSelectedGroupHistory new];
                    selectedGroupHistory.historyInfos = [NSMutableDictionary dictionary];
                }
                
                FHPostUGCSelectedGroupModel *selectedGroup = [FHPostUGCSelectedGroupModel new];
                selectedGroup.socialGroupId = task.social_group_id;
                selectedGroup.socialGroupName = task.social_group_name;
                NSString *saveKey = [currentUserID stringByAppendingString:currentCityID];
                [selectedGroupHistory.historyInfos setObject:selectedGroup forKey:saveKey];
                
                [[FHUGCConfig sharedInstance] savePublisherHistoryDataWithModel:selectedGroupHistory];
            }
        }
        
        [[ToastManager manager] showToast:@"发帖成功"];
        
        // 数据解析
        NSString *social_group_id = userInfo[@"social_group_id"];
        NSDictionary *result_model = userInfo[@"result_model"];
        if (result_model && [result_model isKindOfClass:[NSDictionary class]]) {
            NSDictionary * thread_cell_dic = result_model[@"data"];
            if (thread_cell_dic && [thread_cell_dic isKindOfClass:[NSDictionary class]]) {
                NSString * thread_cell_data = thread_cell_dic[@"thread_cell"];
                if (thread_cell_data && [thread_cell_data isKindOfClass:[NSString class]]) {
                    // 得到cell 数据
                    NSError *jsonParseError;
                    NSData *jsonData = [thread_cell_data dataUsingEncoding:NSUTF8StringEncoding];
                    if (jsonData) {
                        Class cls = [FHFeedUGCContentModel class];
                        FHFeedUGCContentModel * model = (id<FHBaseModelProtocol>)[FHMainApi generateModel:jsonData class:[FHFeedUGCContentModel class] error:&jsonParseError];
                        if (model && jsonParseError == nil) {
                            FHFeedUGCCellModel *cellModel = [FHFeedUGCCellModel modelFromFeedUGCContent:model];
                            if(cellModel) {
                                userInfo[@"cell_model"] = cellModel;
                            }
                        }
                    }
                }
            }
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kTTForumPostThreadSuccessNotification object:task userInfo:userInfo];
        
        //编辑帖子发送成功
        if (task.postID) {
            NSMutableDictionary *repostModelInfo = [NSMutableDictionary dictionary];
            [repostModelInfo setValue:resultModelDict forKey:@"repostModel"];
            [[NSNotificationCenter defaultCenter] postNotificationName:kTTForumPostEditedThreadSuccessNotification object:nil userInfo:repostModelInfo];
        }
        
        // 发帖成功埋点
        NSString *group_id_str = @"be_null";
        NSDictionary *thread_data_dic = task.responseDict[@"data"];
        NSString * thread_cell_data = nil;
        if ([thread_data_dic isKindOfClass:[NSDictionary class]]) {
            thread_cell_data = thread_data_dic[@"thread_cell"];
        }
        if (thread_cell_data && [thread_cell_data isKindOfClass:[NSString class]]) {
            // 得到cell 数据
            NSError *jsonParseError;
            NSData *jsonData = [thread_cell_data dataUsingEncoding:NSUTF8StringEncoding];
            if (jsonData) {
                Class cls = [FHFeedUGCContentModel class];
                FHFeedUGCContentModel * model = (id<FHBaseModelProtocol>)[FHMainApi generateModel:jsonData class:[FHFeedUGCContentModel class] error:&jsonParseError];
                if (model && jsonParseError == nil && model.threadId.length > 0) {
                    group_id_str = model.threadId;
                }
            }
        }
        NSMutableDictionary *tracerDict = task.extraTrack.mutableCopy;
        tracerDict[@"publish_type"] = @"publish_success";
        tracerDict[@"group_id"] = group_id_str;
        if (task.mentionConcern.length > 0) {
            // 话题id
            tracerDict[@"concern_id"] = task.mentionConcern;
        }
        [FHUserTracker writeEvent:@"feed_publish_success" params:tracerDict];

        //对于转发帖单独发一堆通知,并且对应的opt_id/fw_id的帖子转发数加1
        if (!isEmptyString(task.opt_id) && task.repostType != TTThreadRepostTypeNone) {

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
    
        [[TTPostTaskCenter sharedInstance] asyncRemoveTaskFromDiskByTaskID:task.taskID concernID:task.concernID];
        
        // 弹窗设置
        if ([resultModelDict isKindOfClass:[NSDictionary class]] && [[resultModelDict objectForKey:@"guide_info"] isKindOfClass:[NSDictionary class]]) {
            if (((NSDictionary *)[resultModelDict objectForKey:@"guide_info"]).count > 0) {
                [[TTPostThreadBridge sharedInstance] showGuideViewIfNeedWithDictionary:[resultModelDict objectForKey:@"guide_info"]];
            }
        }
    } cancelledBlock:^(TTPostThreadTask *task, TTPostThreadOperationCancelHint cancelHint) {
        // 成功埋点 status = 0 成功 status = 1 失败 status = 2 取消
        [[HMDTTMonitor defaultManager] hmdTrackService:@"topic_post" metric:nil category:@{@"status":@(2)} extra:nil];
        task.isPosting = YES;
        task.retryCount += 1;
        taskFailureTrackerBlock(task);
        if (cancelHint == TTPostThreadOperationCancelHintRemove) {
            [[TTPostTaskCenter sharedInstance] asyncRemoveTaskFromDiskByTaskID:task.taskID concernID:task.concernID];
            NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] init];
            [userInfo setValue:@(task.fakeThreadId) forKey:kTTForumPostThreadFakeThreadID];
            [userInfo setValue:task.concernID forKey:kTTForumPostThreadConcernID];
            [[NSNotificationCenter defaultCenter] postNotificationName:kTTForumDeleteFakeThreadNotification
                                                                object:nil
                                                              userInfo:userInfo];
        }
        else {
            if (task.postID) {
                NSMutableDictionary *fakeInfo = [NSMutableDictionary dictionary];
                [fakeInfo setValue:task.postID forKey:@"threadId"];
                [[NSNotificationCenter defaultCenter] postNotificationName:kTTForumPostEditedThreadFailureNotification object:nil userInfo:fakeInfo];
            }
            NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
            [userInfo setValue:[NSNumber numberWithLongLong:task.fakeThreadId] forKey:kTTForumPostThreadFakeThreadID];
            [userInfo setValue:task.concernID forKey:kTTForumPostThreadConcernID];
            [userInfo setValue:task.relatedForumSubjectID forKey:kTTForumPostThreadRelatedForumSubjectID];
            [userInfo setValue:task.categoryID forKey:@"category_id"];
            [[NSNotificationCenter defaultCenter] postNotificationName:kTTForumPostThreadFailNotification object:task userInfo:[userInfo copy]];
            [[TTPostTaskCenter sharedInstance] asyncSaveTask:task];
        }
    } failureBlock:^(TTPostThreadTask *task, NSError *error) {
        if (task.postID) {
            NSMutableDictionary *fakeInfo = [NSMutableDictionary dictionary];
            [fakeInfo setValue:task.postID forKey:@"threadId"];
            [[NSNotificationCenter defaultCenter] postNotificationName:kTTForumPostEditedThreadFailureNotification object:nil userInfo:fakeInfo];
        }
        // 成功埋点 status = 0 成功 status = 1 失败 status = 2 取消
        [[HMDTTMonitor defaultManager] hmdTrackService:@"topic_post" metric:nil category:@{@"status":@(1)} extra:nil];
        // 发帖失败埋点
        NSMutableDictionary *tracerDict = task.extraTrack.mutableCopy;
        tracerDict[@"publish_type"] = @"publish_failed";
        [FHUserTracker writeEvent:@"feed_publish_failed" params:tracerDict];
        
        task.isPosting = YES;
        task.retryCount += 1;
        taskFailureTrackerBlock(task);
        NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
        [userInfo setValue:[NSNumber numberWithLongLong:task.fakeThreadId] forKey:kTTForumPostThreadFakeThreadID];
        [userInfo setValue:task.concernID forKey:kTTForumPostThreadConcernID];
        [userInfo setValue:task.relatedForumSubjectID forKey:kTTForumPostThreadRelatedForumSubjectID];
        [userInfo setValue:task.categoryID forKey:@"category_id"];
        [[NSNotificationCenter defaultCenter] postNotificationName:kTTForumPostThreadFailNotification object:task userInfo:[userInfo copy]];
        
        //编辑帖子发送失败
        
        [[TTPostTaskCenter sharedInstance] asyncSaveTask:task];
    }];
    [self.postThreadOperationQueue addOperation:operation];
}

- (void)postThreadWithPostThreadModel:(TTPostThreadModel *)postThreadModel finishBlock:(void (^)(TTPostThreadTask *task))finishBlock {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        TTPostThreadTask *task = [[TTPostThreadTask alloc] initWithTaskType:TTPostTaskTypeThread];
        task.title = postThreadModel.title;
        task.content = postThreadModel.content;
        task.contentRichSpans = postThreadModel.contentRichSpans;
        task.mentionUser = postThreadModel.mentionUsers;
        task.mentionConcern = postThreadModel.mentionConcerns;
        task.create_time = [[NSDate date] timeIntervalSince1970];
        task.userID = [[TTAccount sharedAccount] userIdString];//[[BDContextGet() findServiceByName:TTAccountProviderServiceName] userID];
        task.concernID = postThreadModel.concernID;
        task.social_group_id = postThreadModel.social_group_id;
        task.social_group_name = postThreadModel.social_group_name;
        task.hasSocialGroup = postThreadModel.hasSocialGroup;
        task.categoryID = postThreadModel.categoryID;
        [task addTaskImages:postThreadModel.taskImages thumbImages:postThreadModel.thumbImages];
        task.source = 2;//来源于话题
        task.forward = postThreadModel.needForward;
        task.latitude = postThreadModel.latitude;
        task.longitude = postThreadModel.longitude;
        task.city = postThreadModel.city;
        task.detail_pos = postThreadModel.detailPos;
        task.phone = postThreadModel.phoneNumber;
        task.fromWhere = postThreadModel.fromWhere;
        task.communityID = postThreadModel.communityID;
        task.businessPayload = postThreadModel.payload;
        task.score = postThreadModel.score;
        task.refer = postThreadModel.refer;
        task.postUGCEnterFrom = postThreadModel.postUGCEnterFrom;
        task.forumNames = postThreadModel.forumNames;
        task.extraTrack = postThreadModel.extraTrack;
        task.syncToRocket = postThreadModel.syncToRocket;
        task.promotionID = postThreadModel.promotionId;
        task.insertMixCardID = postThreadModel.insertMixCardID;
        task.relatedForumSubjectID = postThreadModel.relatedForumSubjectID;
        task.sdkParams = postThreadModel.sdkParams;
        if (!task) {
            return;
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (finishBlock) {
                finishBlock(task);
            }
            [self postTaskWithTaskID:task.taskID concenID:task.concernID taskType:TTPostTaskTypeThread suggestedTask:task];
        });
    });
}

- (void)postEditedThreadWithPostThreadModel:(TTPostThreadModel *)postThreadModel finishBlock:(void (^)(void))finishBlock {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (finishBlock) {
                finishBlock();
            }
            // 替换发送逻辑，使用UGC业务方自己提供的方法
            [self postEditedThreadWith:postThreadModel];
        });
    });
}

- (void)repostWithRepostThreadModel:(TTRepostThreadModel *)repostThreadModel
                      withConcernID:(NSString *)concernID
                     withCategoryID:(NSString *)categoryID
                              refer:(NSUInteger)refer
                         extraTrack:(nullable NSDictionary *)extraTrack
                        finishBlock:(nullable void(^)(void))finishBlock{

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        TTPostThreadTask *task = [[TTPostThreadTask alloc] initWithTaskType:TTPostTaskTypeThread];
        task.userID = [[TTAccount sharedAccount] userIdString];//[[BDContextGet() findServiceByName:TTAccountProviderServiceName] userID];
        task.create_time = [[NSDate date] timeIntervalSince1970];
        task.concernID = concernID;
        task.categoryID = categoryID;
        task.refer = refer;
        task.extraTrack = extraTrack.copy;
        
        if (!task) {
            return;
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (finishBlock) {
                finishBlock();
            }
            [self postTaskWithTaskID:task.taskID concenID:task.concernID taskType:TTPostTaskTypeThread suggestedTask:task];
        });
    });
    
}

- (nullable NSArray <TTPostTask *> *)fetchTasksFromDiskForConcernID:(nonnull NSString *)concernID {
    return [TTPostThreadTask fetchTasksFromDiskForConcernID:concernID];
}

- (void)resentThreadForFakeThreadID:(int64_t)fakeTID concernID:(NSString *)cid {
    NSString * taskID = [TTPostThreadTask taskIDFromFakeThreadID:fakeTID];
    [self postTaskWithTaskID:taskID concenID:cid taskType:TTPostTaskTypeThread suggestedTask:nil];
}

- (void)removeTaskForFakeThreadID:(int64_t)fakeTID concernID:(NSString *)cid {
    NSString * taskID = [TTPostThreadTask taskIDFromFakeThreadID:fakeTID];
    NSMutableDictionary *userInfo = [NSMutableDictionary new];
    [userInfo setValue:@(fakeTID) forKey:kTTForumPostThreadFakeThreadID];
    [userInfo setValue:cid forKey:kTTForumPostThreadConcernID];
    [[NSNotificationCenter defaultCenter] postNotificationName:kTTForumDeleteFakeThreadNotification
                                                        object:nil
                                                      userInfo:[userInfo copy]];
    [[TTPostTaskCenter sharedInstance] asyncRemoveTaskFromDiskByTaskID:taskID concernID:cid];
}

- (void)onAccountStatusChanged {
    [self.postThreadOperationQueue.operations enumerateObjectsUsingBlock:^(__kindof NSOperation * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[TTPostThreadOperation class]]) {
            TTPostThreadOperation *operation = (TTPostThreadOperation *)obj;
            [operation cancelWithHint:TTPostThreadOperationCancelHintCancel];
        }
    }];
}

#pragma mark - notification

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

- (void)editedThreadDidDeleted:(NSNotification *)notification {
    NSDictionary *info = notification.userInfo;
    NSString *taskID = [info valueForKey:@"taskID"];
    [self.postThreadOperationQueue.operations enumerateObjectsUsingBlock:^(__kindof NSOperation * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[TTPostThreadOperation class]]) {
            TTPostThreadOperation *operation = (TTPostThreadOperation *)obj;
            if([operation.taskID isEqualToString:taskID]) {
                [operation cancelWithHint:TTPostThreadOperationCancelHintRemove];
            }
        }
    }];
    
}

#pragma mark - 外部带入帖子信息编辑发布

- (FRUploadImageManager *)uploadImageManager {
    if (!_uploadImageManager) {
        _uploadImageManager = [[FRUploadImageManager alloc] init];
    }
    return _uploadImageManager;
}

- (void)uploadImagesWith:(TTPostThreadModel *)postThreadModel {
    
    NSMutableArray<FRUploadImageModel *> * images = (NSMutableArray<FRUploadImageModel*> *)[NSMutableArray array];
    // 图片压缩任务
    NSArray<TTUGCImageCompressTask*> *taskImages = postThreadModel.taskImages;
    // 选中的图片
    NSArray<UIImage*> *thumbImages = postThreadModel.thumbImages;
    
    // 构造图片上传数据模型
    for (int i = 0; i < [taskImages count]; i ++) {
        TTUGCImageCompressTask* task = [taskImages objectAtIndex:i];
        UIImage* thumbImage = nil;
        if (thumbImages.count > i) {
            thumbImage = thumbImages[i];
        }
        FRUploadImageModel * model = [[FRUploadImageModel alloc] initWithCacheTask:task thumbnail:thumbImage];
        model.webURI = task.assetModel.imageURI;
        model.imageOriginWidth = task.assetModel.width;
        model.imageOriginHeight = task.assetModel.height;
        [images addObject:model];
    }
    
    WeakSelf;
    [self.uploadImageManager uploadPhotos:images extParameter:@{} progressBlock:^(int expectCount, int receivedCount) {
        StrongSelf;
        // TODO: 展示进度
        
    } finishBlock:^(NSError *error, NSArray<FRUploadImageModel*> *finishUpLoadModels) {
        StrongSelf;
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
            [monitorDictionary setValue:@(images.count) forKey:@"img_count"];
            NSMutableArray * imageNetworks = [NSMutableArray arrayWithCapacity:images.count];
            
            for (FRUploadImageModel * imageModel in images) {
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
            if (error) {
                [monitorDictionary setValue:@(error.code) forKey:@"error"];
            }
            
            [[ToastManager manager] showToast:@"发布失败！"];
            
            // 更新帖子发布失败
            [[NSNotificationCenter defaultCenter] postNotificationName:kTTForumPostEditedThreadFailureNotification object:nil userInfo:nil];
        }
        else {
            
            // 插入上传完成的图片URIs
            NSMutableDictionary *reqParams = [self constructEditedPostReqParamsFromThreadModel:postThreadModel];
            NSMutableArray<NSString *> *imageUris = [NSMutableArray array];
            [finishUpLoadModels enumerateObjectsUsingBlock:^(FRUploadImageModel * _Nonnull imageModel, NSUInteger idx, BOOL * _Nonnull stop) {
                if(imageModel.webURI.length > 0) {
                    [imageUris addObject:imageModel.webURI];
                }
            }];
            reqParams[@"image_uris"] = [imageUris componentsJoinedByString:@","];
            
            // 带图片链接发布
            [self postEditedPostWith:reqParams];
        }
    }];
}

- (void)postEditedThreadWith: (TTPostThreadModel *)postThreadModel {
    
    // 编辑完成开始发送更新请求
    [[NSNotificationCenter defaultCenter] postNotificationName:kTTForumBeginPostEditedThreadNotification object:nil userInfo:nil];
    
    if(postThreadModel.taskImages.count > 0) {
        [self uploadImagesWith:postThreadModel];
    }
    // 没有选中图片就直接发布
    else {
        NSMutableDictionary *reqParams = [self constructEditedPostReqParamsFromThreadModel:postThreadModel];
        [self postEditedPostWith: reqParams];
    }
}

// 从postThreadModel转换出请求参数
- (NSMutableDictionary *)constructEditedPostReqParamsFromThreadModel:(TTPostThreadModel *)postThreadModel {
    
    NSMutableDictionary *publishParams = [NSMutableDictionary dictionary];
    
    if(postThreadModel) {
        
        if(postThreadModel.postID.length > 0) {
            publishParams[@"post_id"] = @(postThreadModel.postID.longLongValue);
        }
        
        if(postThreadModel.social_group_id.length > 0) {
            publishParams[@"social_group_id"] = @(postThreadModel.social_group_id.longLongValue);
        }
        
        publishParams[@"content"] = postThreadModel.content;
        publishParams[@"content_rich_span"] = postThreadModel.contentRichSpans;
        publishParams[@"mention_concern"] = postThreadModel.mentionConcerns;
        publishParams[@"mention_user"] = postThreadModel.mentionUsers;
    
        // 报数相关
        publishParams[@"enter_from"] = postThreadModel.enterFrom;
        publishParams[@"page_type"] = postThreadModel.pageType;
        publishParams[@"element_from"] = postThreadModel.elementFrom;
    }
    return publishParams;
}

// 真正发送请求
- (void)postEditedPostWith:(NSMutableDictionary *)params {
    
    WeakSelf;
    [FHHouseUGCAPI requestPublishEditedPostWithParam:params completion:^(id<FHBaseModelProtocol>  _Nonnull model, NSError * _Nonnull error) {
        StrongSelf;
        
        if(error) {
            [[ToastManager manager] showToast:error.localizedDescription];
            // 更新帖子发布失败
            [[NSNotificationCenter defaultCenter] postNotificationName:kTTForumPostEditedThreadFailureNotification object:nil userInfo:nil];
            return;
        }
        
        if([model isKindOfClass:[FHUGCEditedPostModel class]]) {
            FHUGCEditedPostModel *editPostModel = model;

            // 数据转换
            NSString *jsonString = editPostModel.data.threadCell;
            if(jsonString.length > 0) {
                // 模型转换
                FHFeedUGCCellModel *cellModel = [FHFeedUGCCellModel modelFromFeed:jsonString];
                
                NSMutableDictionary *userInfo = @{}.mutableCopy;
                userInfo[@"thread_cell"] = jsonString;
                userInfo[@"social_group_id"] = params[@"social_group_id"];
                userInfo[@"publish_type"] = @(FHUGCPublishTypePost);
            
                //编辑成功
                [[NSNotificationCenter defaultCenter] postNotificationName:kTTForumPostEditedThreadSuccessNotification object:nil userInfo:userInfo];
                
                return;
            }
        }
        
        // 更新帖子发布失败
          [[NSNotificationCenter defaultCenter] postNotificationName:kTTForumPostEditedThreadFailureNotification object:nil userInfo:nil];
    }];
    
}

@end
