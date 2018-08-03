//
//  FRThreadSmartDetailCommentManager.m
//  Article
//
//  Created by 王霖 on 4/22/16.
//
//

#import "FRThreadSmartDetailCommentManager.h"
#import "TTNetworkManager.h"
#import "FRRequestManager.h"
#import "FRApiModel.h"
#import <TTKitchenHeader.h>

@implementation FRThreadSmartDetailCommentManager

+ (void)requestArticleCommentWithThreadID:(int64_t)threadID forumID:(int64_t)forumID msgID:(NSString *)msgID offset:(NSInteger)offset count:(NSInteger)count apiParameter:(NSString *)apiParameter callback:(void (^)(NSError * _Nullable, NSObject<TTResponseModelProtocol> * _Nullable,FRForumMonitorModel *_Nullable))callback{
    [self requestV2ArticleCommentWithThreadID:threadID forumID:forumID msgID:msgID offset:offset count:count apiParameter:apiParameter callback:callback];
}

+ (void)requestV2ArticleCommentWithThreadID:(int64_t)threadID forumID:(int64_t)forumID msgID:(NSString *)msgID offset:(NSInteger)offset count:(NSInteger)count apiParameter:(NSString *)apiParameter callback:(void (^)(NSError * _Nullable, NSObject<TTResponseModelProtocol> * _Nullable,FRForumMonitorModel *_Nullable))callback {
    FRArticleV2TabCommentsRequestModel *commentRequest = [[FRArticleV2TabCommentsRequestModel alloc]init];
    commentRequest.group_id = @(threadID).stringValue;
    commentRequest.item_id = @"0";
    commentRequest.msg_id = [msgID copy];
    commentRequest.group_type = FRCommentsGroupTypeThread;
    commentRequest.offset = @(offset);
    commentRequest.count = @(count);
    commentRequest.forum_id = @(forumID).stringValue;
//    if ([SSCommonLogic foldCommentEnabled]) {
//        commentRequest.fold = @(1);
//    }
    if ([[TTKitchenMgr sharedInstance] getBOOL:kKCFoldCommentsEnabled]) {
//        if (options & TTCommentLoadOptionsFold) {
//            [commentParam setValue:@(2) forKey:@"fold"]; //非折叠区评论
//        } else {
//            [commentParam setValue:@(1) forKey:@"fold"]; //非折叠区评论
//        }
        commentRequest.fold = @(1);
    }
    [FRRequestManager requestModel:commentRequest callBackWithMonitor:^(NSError *error, NSObject<TTResponseModelProtocol> *responseModel, FRForumMonitorModel *monitorModel) {
        
        if (callback) {
            callback(error,responseModel,monitorModel);
        }
    }];
    
}

@end
