//
//  TTPostThreadManager.m
//  Article
//
//  Created by 王霖 on 3/16/16.
//
//

#import "TTPostThreadManager.h"
#import "TTPostThreadDefine.h"

#import <TTUGCFoundation/FRApiModel.h>
#import <TTBaseLib/TTBaseMacro.h>
#import <TTBaseLib/NSObject+TTAdditions.h>
#import "TTRichSpanText.h"
#import <TTPostBase/TTPostTask.h>
#import <TTUGCFoundation/TTUGCRequestManager.h>
#import <Heimdallr/HMDTTMonitor.h>
#import <TTUGCFoundation/TTUGCMonitorDefine.h>

@interface  FRPublishPostResponseModel : JSONModel<TTResponseModelProtocol>
//@property (strong, nonatomic) NSNumber *err_no;
//@property (strong, nonatomic) NSDictionary<Optional> *thread;
//@property (strong, nonatomic) NSString<Optional> *err_tips;
//@property (strong, nonatomic) FRUGCPublishGuideInfoStructModel<Optional> *guide_info;
@property (nonatomic, copy , nullable) NSString *status;
@property (nonatomic, copy , nullable) NSString *message;
@property (nonatomic, strong , nullable) NSDictionary *data ;
@end

@implementation FRPublishPostResponseModel

+ (BOOL)propertyIsOptional:(NSString *)propertyName
{
    return YES;
}

@end

@interface FRPublishRePostResponseModel : JSONModel<TTResponseModelProtocol>

@property (strong, nonatomic) NSNumber *err_no;
@property (strong, nonatomic) NSString<Optional> *err_tips;
@property (strong, nonatomic) NSDictionary<Optional> *thread;
@property (strong, nonatomic) NSDictionary<Optional> *comment;
@property (strong, nonatomic) NSString<Optional> *reply_id;
@property (strong, nonatomic) NSDictionary<Optional> *reply;

@end

@implementation FRPublishRePostResponseModel

@end


@implementation TTPostThreadManager

+ (BOOL)isTaskValid:(TTPostThreadTask *)task {
    
    if (task == nil) {
        return NO;
    }
    
    switch (task.taskType) {
        case TTPostTaskTypeThread:
        {
            if (isEmptyString(task.content) && isEmptyString([self imageURLsForTask:task])) {
                return NO;
            }
        }
            break;
        default:
        {
            return NO;
        }
    }
    
    return YES;
}

+ (NSString *)imageURLsForTask:(TTPostThreadTask *)task {
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

+ (void)postRepostTask:(TTPostThreadTask *)task finishBlock:(void(^)(NSError * error, id respondObj, TTUGCRequestMonitorModel *monitorModel,uint64_t networkConsume))finishBlock{

    FRUgcPublishRepostV8CommitRequestModel *request = [[FRUgcPublishRepostV8CommitRequestModel alloc] init];
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
    request.fw_native_schema = task.fw_native_schema;
    request.fw_share_url = task.fw_share_url;
    request.sdk_params = task.sdkParams;
    request.forum_names = task.forumNames;
    request.business_payload = task.businessPayload;
    request._response = NSStringFromClass([FRPublishRePostResponseModel class]);

    [[HMDTTMonitor defaultManager] hmdTrackService:kTTUGCPublishBehaviorMonitor metric:nil category:@{@"status" : @(kTTBehaviorFunnelBeforeRequest)} extra:@{kTTUGCMonitorType : kTTPostBehaviorTypeRepost}];

    [TTUGCRequestManager requestModel:request callBackWithMonitor:^(NSError *error, NSObject<TTResponseModelProtocol> * responseModel,TTUGCRequestMonitorModel *monitorModel) {

        if (!error && [responseModel isKindOfClass:[FRPublishRePostResponseModel class]]) {
            [[HMDTTMonitor defaultManager] hmdTrackService:kTTUGCPublishBehaviorMonitor metric:nil category:@{@"status" : @(kTTBehaviorFunnelRequestSuccess)} extra:@{kTTUGCMonitorType : kTTPostBehaviorTypeRepost}];
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
                error = [NSError errorWithDomain:kFRPostThreadErrorDomain code:TTPostThreadErrorCodeError userInfo:nil];
            }
            if (finishBlock) {
                finishBlock(error, nil, monitorModel, 0);
            }
        }
    }];
}

+ (void)postThreadTask:(TTPostThreadTask *)task finishBlock:(void(^)(NSError * error, id respondObj, TTUGCRequestMonitorModel *monitorModel ,uint64_t networkConsume))finishBlock{
    if (![self isTaskValid:task]) {
        if (finishBlock) {
            finishBlock([NSError errorWithDomain:kFRPostForumErrorDomain code:TTPostThreadErrorCodeError userInfo:nil], nil, nil, 0);
        }
        return;
    }
    
    FRUgcPublishPostV5CommitRequestModel *publishModel = [[FRUgcPublishPostV5CommitRequestModel alloc] init];
    publishModel.title = task.title;
    publishModel.content = task.content;
    publishModel.social_group_id = task.social_group_id;
    publishModel.bind_type = @(task.bindType);
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
    publishModel.community_id = task.communityID;
    publishModel.business_payload = task.businessPayload;
    publishModel.forum_names = task.forumNames;
    publishModel.flipchat_sync = @(task.syncToRocket);
    publishModel.promotion_id = task.promotionID;
    publishModel._response = NSStringFromClass([FRPublishPostResponseModel class]);
    publishModel.sdk_params = task.sdkParams;
    publishModel.extraTrack = task.extraTrack;
    publishModel.neighborhoodTags = task.neighborhoodTags;
    publishModel.scores = task.scores;
    publishModel.source = task.pubSource;
    publishModel.neighborhoodId = task.neighborhoodId;
    
    uint64_t startTime = [NSObject currentUnixTime];

    [[HMDTTMonitor defaultManager] hmdTrackService:kTTUGCPublishBehaviorMonitor metric:nil category:@{@"status" : @(kTTBehaviorFunnelBeforeRequest)} extra:@{kTTUGCMonitorType : kTTPostBehaviorTypePost}];

    [TTUGCRequestManager requestModel:publishModel callBackWithMonitor:^(NSError *error, NSObject<TTResponseModelProtocol> *responseModel, TTUGCRequestMonitorModel *monitorModel) {
        
        uint64_t endTime = [NSObject currentUnixTime];
        uint64_t total = [NSObject machTimeToSecs:endTime - startTime] * 1000;
        if (error) {
            if (finishBlock) {
                finishBlock(error, nil, monitorModel,total);
            }
        }
        else if ([responseModel isKindOfClass:[FRPublishPostResponseModel class]]) {
            [[HMDTTMonitor defaultManager] hmdTrackService:kTTUGCPublishBehaviorMonitor metric:nil category:@{@"status" : @(kTTBehaviorFunnelRequestSuccess)} extra:@{kTTUGCMonitorType : kTTPostBehaviorTypePost}];

            FRPublishPostResponseModel *publishResponse = (FRPublishPostResponseModel *)responseModel;
//            if (publishResponse.thread.count == 0) {
//                publishResponse.thread = nil;
//            }
            if (finishBlock) {
                finishBlock(error, [publishResponse toDictionary], monitorModel,total);
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:@"TTUGCPublishSuccessForPushGuideNotification" object:nil userInfo:@{@"reason": @(22)}];
        }
        else {
            if (finishBlock) {
                finishBlock([NSError errorWithDomain:kFRPostForumErrorDomain code:TTPostThreadErrorCodeError userInfo:nil], nil, monitorModel,total);
            }
        }
        
    }];
    
}

+ (void)postEditedThreadTask:(TTPostThreadTask *)task finishBlock:(void (^)(NSError *error, id respondObj, TTUGCRequestMonitorModel *monitorModel, uint64_t networkConsume))finishBlock {
    if (![self isTaskValid:task]) {
        if (finishBlock) {
            finishBlock([NSError errorWithDomain:kFRPostForumErrorDomain code:TTPostThreadErrorCodeError userInfo:nil], nil, nil, 0);
        }
        return;
    }
    FRUgcPublishPostV1ModifyRequestModel *publishEditedModel = [[FRUgcPublishPostV1ModifyRequestModel alloc] init];
    publishEditedModel.title = task.title;
    publishEditedModel.content = task.content;
    publishEditedModel.content_rich_span = [TTRichSpans filterValidRichSpanString:task.contentRichSpans];
    publishEditedModel.mention_user = task.mentionUser;
    publishEditedModel.mention_concern = task.mentionConcern;
    publishEditedModel.image_uris = [self imageURLsForTask:task];
    publishEditedModel.concern_id = task.concernID;
    publishEditedModel.category_id = task.categoryID;
    publishEditedModel.post_id = task.postID;
    publishEditedModel.latitude = @(task.latitude);
    publishEditedModel.longitude = @(task.longitude);
    publishEditedModel.city = task.city;
    publishEditedModel.detail_pos = task.detail_pos;
    publishEditedModel.is_forward = @(task.forward);
    publishEditedModel.from_where = task.fromWhere;
    publishEditedModel.phone = task.phone;
    publishEditedModel.score = @(task.score);
    publishEditedModel.enter_from = @(task.postUGCEnterFrom);
    publishEditedModel.forum_names = task.forumNames;
    publishEditedModel._response = NSStringFromClass([FRPublishPostResponseModel class]);
    publishEditedModel.sdk_params = task.sdkParams;
    
    uint64_t startTime = [NSObject currentUnixTime];

    [[HMDTTMonitor defaultManager] hmdTrackService:kTTUGCPublishBehaviorMonitor metric:nil category:@{@"status" : @(kTTBehaviorFunnelBeforeRequest)} extra:@{kTTUGCMonitorType : kTTPostBehaviorTypePost}];

    [TTUGCRequestManager requestModel:publishEditedModel callBackWithMonitor:^(NSError *error, NSObject<TTResponseModelProtocol> *responseModel, TTUGCRequestMonitorModel *monitorModel) {
        
        uint64_t endTime = [NSObject currentUnixTime];
        uint64_t total = [NSObject machTimeToSecs:endTime - startTime] * 1000;
        if (error) {
            if (finishBlock) {
                finishBlock(error, nil, monitorModel,total);
            }
        }
        else if ([responseModel isKindOfClass:[FRPublishPostResponseModel class]]) {
            [[HMDTTMonitor defaultManager] hmdTrackService:kTTUGCPublishBehaviorMonitor metric:nil category:@{@"status" : @(kTTBehaviorFunnelRequestSuccess)} extra:@{kTTUGCMonitorType : kTTPostBehaviorTypePost}];

            FRPublishPostResponseModel *publishEidtedResponse = (FRPublishPostResponseModel *)responseModel;
//            if (publishEidtedResponse.thread.count == 0) {
//                publishEidtedResponse.thread = nil;
//            }
            if (finishBlock) {
                finishBlock(error, [publishEidtedResponse toDictionary], monitorModel,total);
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:@"TTUGCPublishSuccessForPushGuideNotification" object:nil userInfo:@{@"reason": @(22)}];
        }
        else {
            if (finishBlock) {
                finishBlock([NSError errorWithDomain:kFRPostForumErrorDomain code:TTPostThreadErrorCodeError userInfo:nil], nil, monitorModel,total);
            }
        }
        
    }];
}

+ (void)checkPostNeedBindPhoneOrNotWithCompletion:(void(^ _Nullable)(FRPostBindCheckType checkType))completion{
    
    FRUgcPublishPostV1CheckRequestModel *checkBindModel = [[FRUgcPublishPostV1CheckRequestModel alloc] init];
    [TTUGCRequestManager requestModel:checkBindModel callBackWithMonitor:^(NSError *error, id<TTResponseModelProtocol> responseModel, TTUGCRequestMonitorModel *monitorModel) {
        if (error) {
            if (completion) {
                completion(FRPostBindCheckTypePostBindCheckTypeNone);
            }
        }
        else if ([responseModel isKindOfClass:[FRUgcPublishPostV1CheckResponseModel class]]) {
            FRUgcPublishPostV1CheckResponseModel *checkResponse = (FRUgcPublishPostV1CheckResponseModel *)responseModel;
            if (completion) {
                completion(checkResponse.bind_mobile);
            }
            
        }
        else {
            if (completion) {
                completion(FRPostBindCheckTypePostBindCheckTypeNone);
            }
        }
    }];
}
@end
