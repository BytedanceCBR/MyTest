//
//  TTForumPostThreadManager.m
//  Article
//
//  Created by 王霖 on 3/16/16.
//
//

#import "TTForumPostThreadManager.h"
#import "FRPostThreadDefine.h"
#import "TTNetworkManager.h"
#import "PGCAccountManager.h"
#import "FRApiModel.h"
#import "TTForumUploadVideoModel.h"
#import "TTBaseMacro.h"
#import "NSObject+TTAdditions.h"
#import "TTRichSpanText.h"

@interface  FRPublishPostResponseModel : TTResponseModel
@property (strong, nonatomic) NSNumber *err_no;
@property (strong, nonatomic) NSDictionary<Optional> *thread;
@property (strong, nonatomic) NSString<Optional> *err_tips;
@end

@implementation FRPublishPostResponseModel
@end

@interface FRPublishRePostResponseModel : TTResponseModel

@property (strong, nonatomic) NSNumber *err_no;
@property (strong, nonatomic) NSString<Optional> *err_tips;
@property (strong, nonatomic) NSDictionary<Optional> *thread;
@property (strong, nonatomic) NSDictionary<Optional> *comment;
@property (strong, nonatomic) NSString<Optional> *reply_id;

@end

@implementation FRPublishRePostResponseModel

@end


@interface FRPublishPostVideoResponseModel : TTResponseModel
@property (strong, nonatomic) NSNumber *err_no;
@property (strong, nonatomic) NSDictionary<Optional> *data;
@property (strong, nonatomic) NSString<Optional> *err_tips;
@property (strong, nonatomic) NSDictionary<Optional> *pk_status;
@end

@implementation FRPublishPostVideoResponseModel
@end

extern NSString * const TTUGCPublishSuccessForPushGuideNotification; // UGC中发帖成功

@implementation TTForumPostThreadManager

+ (BOOL)isTaskValid:(TTForumPostThreadTask *)task {
    
    if (task == nil) {
        return NO;
    }
    
    switch (task.taskType) {
        case TTForumPostThreadTaskTypeThread:
        {
            if (isEmptyString(task.content) && isEmptyString([self imageURLsForTask:task])) {
                return NO;
            }
        }
            break;
        case TTForumPostThreadTaskTypeVideo:
        {
            if (!task.video || isEmptyString(task.video.videoId)) {
                return NO;
            }
        }
            break;
    }
    
    return YES;
}

+ (NSString *)imageURLsForTask:(TTForumPostThreadTask *)task {
    NSMutableString * strImageUris = [[NSMutableString alloc] init];
    for (FRUploadImageModel * m in task.images) {
        NSString * imageUri = m.webURI;
        if (!isEmptyString(imageUri)) {
            [strImageUris appendString:(NSString *)imageUri];
            [strImageUris appendString:@","];
        }
    }
    if ([strImageUris length] > 0) {
        [strImageUris deleteCharactersInRange:NSMakeRange([strImageUris length] - 1, 1)];
    }
    return strImageUris;
}

+ (void)postRepostTask:(TTForumPostThreadTask *)task finishBlock:(void(^)(NSError * error, id respondObj, FRForumMonitorModel *monitorModel,uint64_t networkConsume))finishBlock{

    FRUgcPublishRepostV6CommitRequestModel *request = [[FRUgcPublishRepostV6CommitRequestModel alloc] init];
    request.repost_type = @(task.repostType);
    request.content = task.content;
    request.content_rich_span = [TTRichSpans filterValidRichSpanString:task.contentRichSpans];
    request.mention_user = task.mentionUser;
    request.cover_url = task.coverUrl;
    request.mention_concern = task.mentionConcern;
    request.fw_id = task.fw_id;
    request.fw_id_type = task.fw_id_type;
    request.opt_id = task.opt_id;
    request.opt_id_type = task.opt_id_type;
    request.fw_user_id = task.fw_user_id;
    request.title = task.repostTitle;
    request.schema = task.repostSchema;
    request.repost_to_comment = @(task.repostToComment);
    request._response = NSStringFromClass([FRPublishRePostResponseModel class]);

    [FRRequestManager requestModel:request callBackWithMonitor:^(NSError *error, NSObject<TTResponseModelProtocol> * responseModel,FRForumMonitorModel *monitorModel) {

        if (!error && [responseModel isKindOfClass:[FRPublishRePostResponseModel class]]) {
            FRPublishRePostResponseModel *response = (FRPublishRePostResponseModel *)responseModel;
            if (response.thread.count == 0) {
                response.thread = nil;
            }
            if (response.comment.count == 0) {
                response.comment = nil;
            }
            if (finishBlock) {
                finishBlock(nil, [response toDictionary], monitorModel,0);
            }
        }
        else {
            if (!error) {
                error = [NSError errorWithDomain:kFRPostThreadErrorDomain code:FRPostThreadErrorCodeError userInfo:nil];
            }
            if (finishBlock) {
                finishBlock(error, nil, monitorModel, 0);
            }
        }
    }];
}

+ (void)postThreadTask:(TTForumPostThreadTask *)task finishBlock:(void(^)(NSError * error, id respondObj, FRForumMonitorModel *monitorModel ,uint64_t networkConsume))finishBlock{
    if (![self isTaskValid:task]) {
        if (finishBlock) {
            finishBlock([NSError errorWithDomain:kFRPostForumErrorDomain code:FRPostThreadErrorCodeError userInfo:nil], nil, nil, 0);
        }
        return;
    }
    
    FRUgcPublishPostV4CommitRequestModel *publishModel = [[FRUgcPublishPostV4CommitRequestModel alloc] init];
    publishModel.title = task.title;
    publishModel.content = task.content;
    publishModel.content_rich_span = [TTRichSpans filterValidRichSpanString:task.contentRichSpans];
    publishModel.mention_user = task.mentionUser;
    publishModel.mention_concern = task.mentionConcern;
    publishModel.image_uris = [self imageURLsForTask:task];
    publishModel.concern_id = task.concernID;
    publishModel.category_id = task.categoryID;
    publishModel.latitude = @(task.latitude);
    publishModel.longitude = @(task.longitude);
    publishModel.city = task.city;
    publishModel.detail_pos = task.detail_pos;
    publishModel.is_forward = @(task.forward);
    publishModel.from_where = task.fromWhere;
    publishModel.phone = task.phone;
    publishModel.score = @(task.score);
    publishModel.enter_from = @(task.postUGCEnterFrom);
    publishModel._response = NSStringFromClass([FRPublishPostResponseModel class]);
    
    uint64_t startTime = [NSObject currentUnixTime];
    
    [FRRequestManager requestModel:publishModel callBackWithMonitor:^(NSError *error, NSObject<TTResponseModelProtocol> *responseModel, FRForumMonitorModel *monitorModel) {
        
        uint64_t endTime = [NSObject currentUnixTime];
        uint64_t total = [NSObject machTimeToSecs:endTime - startTime] * 1000;
        if (error) {
            if (finishBlock) {
                finishBlock(error, nil, monitorModel,total);
            }
        }
        else if ([responseModel isKindOfClass:[FRPublishPostResponseModel class]]) {
            FRPublishPostResponseModel *publishResponse = (FRPublishPostResponseModel *)responseModel;
            if (publishResponse.thread.count == 0) {
                publishResponse.thread = nil;
            }
            if (finishBlock) {
                finishBlock(error, [publishResponse toDictionary], monitorModel,total);
            }
            
            [[NSNotificationCenter defaultCenter] postNotificationName:TTUGCPublishSuccessForPushGuideNotification object:nil userInfo:@{@"reason": @(22)}];
        }
        else {
            if (finishBlock) {
                finishBlock([NSError errorWithDomain:kFRPostForumErrorDomain code:FRPostThreadErrorCodeError userInfo:nil], nil, monitorModel,total);
            }
        }
        
    }];
    
}

+ (void)postVideoThreadTask:(TTForumPostThreadTask *)task finishBlock:(void(^)(NSError *error, id respondObj, FRForumMonitorModel *monitorModel ,uint64_t networkConsume))finishBlock{
    if (![self isTaskValid:task]) {
        if (finishBlock) {
            finishBlock([NSError errorWithDomain:kFRPostForumErrorDomain code:FRPostThreadErrorCodeError userInfo:nil], nil, nil,0);
        }
        return;
    }

    FRUgcPublishVideoV3CommitRequestModel *requestModel = [[FRUgcPublishVideoV3CommitRequestModel alloc] init];
    requestModel.title = task.title;
    requestModel.video_id = task.video.videoId;
    requestModel.video_name = task.video.videoName;
    requestModel.thumb_uri = task.video.coverImage.webURI;
    requestModel.video_type = @(task.video.videoSourceType);
    requestModel.video_duration = @(task.video.videoDuration);
    requestModel.width = @((int)task.video.width);
    requestModel.height = @((int)task.video.height);
    requestModel.thumb_source = @(task.video.videoCoverSourceType);
    requestModel.enter_from = @(task.postUGCEnterFrom);
    requestModel.title_rich_span = task.titleRichSpan;
    requestModel.mention_user = task.mentionUser;
    requestModel.mention_concern = task.mentionConcern;
    requestModel.category = task.categoryID;
    requestModel.challenge_group_id = task.challengeGroupID;
    requestModel.music_id = task.video.musicID;
    requestModel._response = NSStringFromClass([FRPublishPostVideoResponseModel class]);
    uint64_t startTime = [NSObject currentUnixTime];
    
    [FRRequestManager requestModel:requestModel callBackWithMonitor:^(NSError *error, NSObject<TTResponseModelProtocol> *responseModel, FRForumMonitorModel *monitorModel) {
        
        uint64_t endTime = [NSObject currentUnixTime];
        uint64_t total = [NSObject machTimeToSecs:endTime - startTime] * 1000;
        if (error) {
            if (finishBlock) {
                finishBlock(error, nil, monitorModel,total);
            }
        }
        else {
            if ([responseModel isKindOfClass:[FRPublishPostVideoResponseModel class]]) {
                FRPublishPostVideoResponseModel *publishResponseModel = (FRPublishPostVideoResponseModel *)responseModel;
                if (finishBlock) {
                    finishBlock(nil, [publishResponseModel toDictionary],monitorModel, total);
                }
                
                [[NSNotificationCenter defaultCenter] postNotificationName:TTUGCPublishSuccessForPushGuideNotification object:nil userInfo:@{@"reason": @(22)}];
            }
            else {
                if (finishBlock) {
                    finishBlock([NSError errorWithDomain:kFRPostThreadErrorDomain code:FRPostThreadErrorCodeError userInfo:nil], nil, monitorModel,total);
                }
            }
        }
        
    }];
}

@end
