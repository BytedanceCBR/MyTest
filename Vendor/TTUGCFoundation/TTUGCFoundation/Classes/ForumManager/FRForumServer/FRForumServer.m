//
//  FRForumServer.m
//  Article
//
//  Created by 王霖 on 4/25/16.
//
//

#import "FRForumServer.h"
#import "TTNetworkManager.h"
#import "FRRequestManager.h"
#import "FRApiModel.h"

extern NSString * const TTCommentSuccessForPushGuideNotification;

@implementation FRForumServer


- (void)authorDeleteComment:(int64_t)commentID groupID:(int64_t)groupID finish:(void(^)(NSError * error))finish {
    FRUgcCommentAuthorActionV2DeleteRequestModel *request = [[FRUgcCommentAuthorActionV2DeleteRequestModel alloc] init];
    request.comment_id = @(commentID);
    request.group_id = @(groupID);
    request.action_type = @(1);

    [FRRequestManager requestModel:request callBackWithMonitor:^(NSError *error, NSObject<TTResponseModelProtocol> *responseModel, FRForumMonitorModel *monitorModel) {
        if (finish) {
            finish(error);
        }
    }];
}

- (void)authorDeleteReply:(int64_t)replyID commentID:(int64_t)commentID finish:(nullable void(^)(NSError * _Nullable error))finish {
    FRUgcCommentAuthorActionV2DeleteRequestModel *request = [[FRUgcCommentAuthorActionV2DeleteRequestModel alloc] init];
    request.comment_id = @(commentID);
    request.reply_id = @(replyID);
    request.action_type = @(2);

    [FRRequestManager requestModel:request callBackWithMonitor:^(NSError *error, NSObject<TTResponseModelProtocol> *responseModel, FRForumMonitorModel *monitorModel) {
        if (finish) {
            finish(error);
        }
    }];
}

- (void)deleteThreadWithThreadID:(int64_t)threadID finish:(nullable void (^)(NSError * _Nullable error, NSString * _Nullable tips))finish {
    FRTtdiscussV1CommitThreaddeleteRequestModel *request = [[FRTtdiscussV1CommitThreaddeleteRequestModel alloc] init];
    request.thread_id = @(threadID);
    
    [[TTNetworkManager shareInstance] requestModel:request callback:^(NSError *error, NSObject<TTResponseModelProtocol> *responseModel) {
        if (finish) {
            NSString * tips = nil;
            if (error) {
                tips = [[error userInfo] objectForKey:@"description"];
            } else {
                tips = [(FRTtdiscussV1CommitOpcommentResponseModel*)responseModel err_tips];
            }
            finish(error, tips);
        }
    }];
}

@end
