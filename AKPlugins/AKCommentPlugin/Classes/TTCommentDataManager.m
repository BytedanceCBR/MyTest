//
//  TTCommentDataManager.m
//  Article
//
//  Created by 冯靖君 on 16/4/7.
//
//

#import "TTCommentDataManager.h"
#import "TTCommentDetailModel.h"
#import "TTAccountBusiness.h"
#import <TTBatchItemAction/BatchItemActionModel.h>
#import <TTBatchItemAction/SSBatchItemActionManager.h>
#import <TTNetworkManager/TTNetworkManager.h>
#import <TTPlatformBaseLib/TTURLDomainHelper.h>
#import <TTBaseLib/NSDictionary+TTAdditions.h>
#import <TTUGCFoundation/FRApiModel.h>
#import <TTUGCFoundation/FRRequestManager.h>
#import <Crashlytics/Crashlytics/Answers.h>
#import <TTUGCFoundation/FRActionDataService.h>
#import <TTUGCFoundation/TTRichSpanText.h>


extern NSString * const TTCommentSuccessForPushGuideNotification;

static TTCommentDataManager *sharedManager;

@implementation TTCommentDataManager

+ (instancetype)sharedManager {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[TTCommentDataManager alloc] init];
    });

    return sharedManager;
}

- (void)startFetchCommentsWithGroupModel:(TTGroupModel *)groupModel
                             forLoadMode:(TTCommentLoadMode)loadMode
                          loadMoreOffset:(NSNumber *)offset
                           loadMoreCount:(NSNumber *)loadMoreCount
                                   msgID:(NSString *)msgID
                                 options:(TTCommentLoadOptions)options
                             finishBlock:(TTCommentLoadFinishBlock)finishBlock {
    NSString *groupID = groupModel.groupID;
    NSString *itemID = groupModel.itemID;
    NSInteger aggrType = groupModel.aggrType;

    [self startFetchCommentsWithGroupID:groupID
                                 itemID:itemID
                                forumID:nil
                              aggreType:aggrType
                         loadMoreOffset:[offset integerValue]
                          loadMoreCount:[loadMoreCount integerValue]
                                  msgID:msgID
                                options:options
                            finishBlock:finishBlock];
}

- (void)startFetchCommentsWithGroupModel:(TTGroupModel *)groupModel
                               serviceID:(NSString *)serviceID
                             forLoadMode:(TTCommentLoadMode)loadMode
                          loadMoreOffset:(NSNumber *)offset
                           loadMoreCount:(NSNumber *)loadMoreCount
                                   msgID:(NSString *)msgID
                                 options:(TTCommentLoadOptions)options
                             finishBlock:(TTCommentLoadFinishBlock)finishBlock {

    NSString *groupID = groupModel.groupID;
    NSString *itemID = groupModel.itemID;
    NSInteger aggrType = groupModel.aggrType;

    [self startFetchCommentsWithGroupID:groupID
                                 itemID:itemID
                                forumID:nil
                              serviceID:serviceID
                              aggreType:aggrType
                         loadMoreOffset:[offset integerValue]
                          loadMoreCount:[loadMoreCount integerValue]
                                  msgID:msgID
                                options:options
                            finishBlock:finishBlock];
}


- (void)startFetchCommentsWithGroupID:(NSString *)groupID
                               itemID:(NSString *)itemID
                              forumID:(NSString *)forumID
                            aggreType:(NSInteger)aggreType
                       loadMoreOffset:(NSInteger)offset
                        loadMoreCount:(NSInteger)loadMoreCount
                                msgID:(NSString *)msgID
                              options:(TTCommentLoadOptions)options
                          finishBlock:(TTCommentLoadFinishBlock)finishBlock {

    NSMutableDictionary *commentParam = [NSMutableDictionary dictionaryWithCapacity:10];
    [commentParam setValue:groupID forKey:@"group_id"];
    [commentParam setValue:itemID forKey:@"item_id"];
    [commentParam setValue:@(aggreType) forKey:@"aggr_type"];
    [commentParam setValue:forumID forKey:@"forum_id"];

    [commentParam setValue:@(offset) forKey:@"offset"];
    NSInteger loadMoreCountParam = loadMoreCount ?: TTCommentDefaultLoadMoreFetchCount;
    [commentParam setValue:@(loadMoreCountParam) forKey:@"count"];
    BOOL isStickComment = NO;
    if (options & TTCommentLoadOptionsStick) {
        [commentParam setValue:msgID forKey:@"msg_id"];
        isStickComment = !isEmptyString(msgID);
    }

    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"SSCommonLogicDetailFoldCommentSettingKey"]) {
        if (options & TTCommentLoadOptionsFold) {
            [commentParam setValue:@(2) forKey:@"fold"]; //非折叠区评论
        } else {
            [commentParam setValue:@(1) forKey:@"fold"]; //非折叠区评论
        }
    }

    [[TTNetworkManager shareInstance] requestForJSONWithURL:[TTCommentDataManager tabCommentsURLString]
                                                     params:commentParam
                                                     method:@"GET"
                                           needCommonParams:YES
                                                   callback:^(NSError *error, id jsonObj) {
                                                       if (finishBlock) {
                                                           finishBlock(jsonObj, error, isStickComment);
                                                       }
                                                   }];
}

- (void)startFetchCommentsWithGroupID:(NSString *)groupID
                               itemID:(NSString *)itemID
                              forumID:(NSString *)forumID
                            serviceID:(NSString *)serviceID
                            aggreType:(NSInteger)aggreType
                       loadMoreOffset:(NSInteger)offset
                        loadMoreCount:(NSInteger)loadMoreCount
                                msgID:(NSString *)msgID
                              options:(TTCommentLoadOptions)options
                          finishBlock:(TTCommentLoadFinishBlock)finishBlock {

    NSMutableDictionary *commentParam = [NSMutableDictionary dictionaryWithCapacity:10];
    [commentParam setValue:groupID forKey:@"group_id"];
    [commentParam setValue:itemID forKey:@"item_id"];
    [commentParam setValue:@(aggreType) forKey:@"aggr_type"];
    [commentParam setValue:forumID forKey:@"forum_id"];

    [commentParam setValue:@(offset) forKey:@"offset"];
    NSInteger loadMoreCountParam = loadMoreCount ?: TTCommentDefaultLoadMoreFetchCount;
    [commentParam setValue:@(loadMoreCountParam) forKey:@"count"];
    BOOL isStickComment = NO;
    if (options & TTCommentLoadOptionsStick) {
        [commentParam setValue:msgID forKey:@"msg_id"];
        isStickComment = !isEmptyString(msgID);
    }

    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"SSCommonLogicDetailFoldCommentSettingKey"]) {
        if (options & TTCommentLoadOptionsFold) {
            [commentParam setValue:@(2) forKey:@"fold"]; //非折叠区评论
        } else {
            [commentParam setValue:@(1) forKey:@"fold"]; //非折叠区评论
        }
    }

    // NOTICE service_id 的含义参考
    // https://wiki.bytedance.net/pages/viewpage.action?pageId=149704582
    [commentParam setValue:serviceID forKey:@"service_id"];

    [[TTNetworkManager shareInstance] requestForJSONWithURL:[TTCommentDataManager tabCommentsURLString]
                                                     params:commentParam
                                                     method:@"GET"
                                           needCommonParams:YES
                                                   callback:^(NSError *error, id jsonObj) {
                                                       if (finishBlock) {
                                                           finishBlock(jsonObj, error, isStickComment);
                                                       }
                                                   }];
}

- (void)fetchCommentDetailWithCommentID:(NSString *)commentID
                            finishBlock:(void (^)(TTCommentDetailModel *, NSError *))finishBlock {
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    [param setValue:commentID forKey:@"comment_id"];

    [[TTNetworkManager shareInstance] requestForJSONWithURL:[TTCommentDataManager commentDetailURLString] params:param method:@"GET" needCommonParams:YES callback:^(NSError *error, id jsonObj) {
        TTCommentDetailModel *model = [[TTCommentDetailModel alloc] initWithDictionary:jsonObj[@"data"] error:nil];
        if (error || !model) {
            if (finishBlock) {
                finishBlock(nil, error);
            }
            return;
        }

        model.banEmojiInput = [jsonObj tt_boolValueForKey:@"ban_face"];
        model.banForwardToWeitoutiao = @(![jsonObj tt_boolValueForKey:@"show_repost_entrance"]);
        model.show_repost_weitoutiao_entrance = [jsonObj tt_boolValueForKey:@"show_repost_weitoutiao_entrance"];

        if (finishBlock) {
            finishBlock(model, nil);
        }
    }];
}

- (void)fetchCommentReplyListWithCommentID:(NSString *)commentID
                            loadMoreOffset:(NSInteger)loadMoreOffset
                             loadMoreCount:(NSInteger)loadMoreCount
                                     msgID:(NSString *)msgID
                                  isRepost:(BOOL)isRepost
                               finishBlock:(void (^)(id jsonObj, NSError *error))finishBlock {

    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    [param setValue:commentID forKey:@"id"];
    [param setValue:@(loadMoreCount) forKey:@"count"];
    [param setValue:@(loadMoreOffset) forKey:@"offset"];
    [param setValue:msgID forKey:@"msg_id"];
    [param setValue:@(isRepost) forKey:@"is_repost"];

    [[TTNetworkManager shareInstance] requestForJSONWithURL:[TTCommentDataManager commentReplyListURLString] params:param method:@"GET" needCommonParams:YES callback:^(NSError *error, id jsonObj) {
        if (!error) {
            if (finishBlock) {
                finishBlock(jsonObj, error);
            }
        } else {
            if (finishBlock) {
                finishBlock(nil, error);
            }
        }
    }];
}

#pragma mark - POST

- (BOOL)postCommentWithGroupID:(NSString *)groupID
                      aggrType:(NSInteger)aggrType
                       itemTag:(NSString *)itemTag
                       content:(NSString *)content
              replyToCommentID:(NSString *)replyToCommentID
                       context:(id)context {
    return [self postCommentWithGroupID:groupID
                              serviceID:nil
                               aggrType:aggrType
                                itemTag:itemTag
                                content:content
                        contentRichSpan:nil
                            mentionUser:nil
                       replyToCommentID:replyToCommentID
                                replyID:nil
                               isRepost:NO
                          repostContent:nil
                  repostContentRichSpan:nil
                             repostFwID:nil
                    commentTimeInterval:nil
                             staytimeMs:nil
                                readPct:nil
                                context:context
                               callback:nil];
}

- (BOOL)postCommentWithGroupID:(NSString *)groupID
                     serviceID:(NSString *)serviceID
                      aggrType:(NSInteger)aggrType
                       itemTag:(NSString *)itemTag
                       content:(NSString *)content
               contentRichSpan:(NSString *)contentRichSpan
                   mentionUser:(NSString *)mentionUser
              replyToCommentID:(NSString *)replyToCommentID
                       replyID:(NSString *)replyID
                      isRepost:(BOOL)isRepost
                 repostContent:(NSString *)repostContent
         repostContentRichSpan:(NSString *)repostContentRichSpan
                    repostFwID:(NSString *)repostFwID
           commentTimeInterval:(NSString *)interval
                    staytimeMs:(NSNumber *)staytimeMs
                       readPct:(NSNumber *)readPct
                       context:(id)context
                      callback:(TTNetworkJSONFinishBlock)callback {
    BOOL result = NO;
    if ([TTAccountManager isLogin]) {
        NSString *platform = [[TTPlatformAccountManager sharedManager] sharePlatformsJoinedString];

        NSMutableDictionary * mutableDict = [[NSMutableDictionary alloc] initWithCapacity:2];
        [mutableDict setValue:content forKey:@"text"];
        [mutableDict setValue:contentRichSpan forKey:@"text_rich_span"];
        [mutableDict setValue:mentionUser forKey:@"mention_user"];
        [mutableDict setValue:platform forKey:@"platform"];
        [mutableDict setValue:replyToCommentID forKey:@"reply_to_comment_id"];
        [mutableDict setValue:groupID forKey:@"group_id"];
        [mutableDict setValue:groupID forKey:@"item_id"];
        [mutableDict setValue:@(aggrType) forKey:@"aggr_type"];
        [mutableDict setValue:replyID forKey:@"dongtai_comment_id"];
        [mutableDict setValue:staytimeMs forKey:@"staytime_ms"];
        [mutableDict setValue:readPct forKey:@"read_pct"];

        if (!isEmptyString(replyID)) {
            isRepost = YES;
        }

        [mutableDict setValue:@(isRepost) forKey:@"repost"];
        [mutableDict setValue:@(isRepost) forKey:@"share_tt"];
        [mutableDict setValue:@(0) forKey:@"zz"];

        [mutableDict setValue:@(!(isEmptyString(content))) forKey:@"is_comment"];
        [mutableDict setValue:itemTag forKey:@"tag"];
        if ([interval length] > 0) {
            [mutableDict setValue:interval forKey:@"comment_duration"];
        }

        [mutableDict setValue:repostContent forKey:@"content"];

        NSString *optimizedContentRichSpanString = [TTRichSpans filterValidRichSpanString:repostContentRichSpan];
        [mutableDict setValue:optimizedContentRichSpanString forKey:@"content_rich_span"];

        // NOTICE service_id 的含义参考
        // https://wiki.bytedance.net/pages/viewpage.action?pageId=149704582
        [mutableDict setValue:serviceID forKey:@"service_id"];

        NSDictionary *params = [mutableDict copy];
        [[TTNetworkManager shareInstance] requestForJSONWithURL:[TTCommentDataManager postCommentURLString] params:params method:@"POST" needCommonParams:YES callback:^(NSError *error, id jsonObj) {
            if (error == nil && [params tt_boolValueForKey:@"repost"]) {
                NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];

                NSString *optId = replyToCommentID;
                NSString *fwId = repostFwID;
                if (isEmptyString(optId) || [optId isEqualToString:@"0"]) {
                    optId = groupID;
                    [Answers logCustomEventWithName:@"ugc_post" customAttributes:@{@"sence" : @"CommentRepost一级"}];
                } else {
                    [Answers logCustomEventWithName:@"ugc_post" customAttributes:@{@"sence" : @"CommentRepost二级"}];
                }
                if (isEmptyString(repostFwID)) {
                    fwId = optId;
                }

                [userInfo setValue:optId forKey:kCommentRepostOptID];
                [userInfo setValue:repostFwID forKey:kCommentRepostFwID];

                if (jsonObj && [jsonObj isKindOfClass:[NSDictionary class]]) {
                    NSDictionary *result = (NSDictionary *)jsonObj;
                    NSDictionary *data = [result tt_dictionaryValueForKey:@"data"];
                    [userInfo setValue:data forKey:@"data"];
                }

                //只在勾选了转发时发通知（包括评论并转发 以及 回复并转发）
                id<FRActionDataProtocol> optActionDataModel = [GET_SERVICE(FRActionDataService) modelWithUniqueID:optId];
                optActionDataModel.repostCount = optActionDataModel.repostCount + 1;
                if (fwId && ![fwId isEqualToString:optId]) {
                    id<FRActionDataProtocol> fwActionDataModel = [GET_SERVICE(FRActionDataService) modelWithUniqueID:fwId];
                    fwActionDataModel.repostCount = fwActionDataModel.repostCount + 1;
                }

                [[NSNotificationCenter defaultCenter] postNotificationName:kCommentRepostSuccessNotification object:nil userInfo:userInfo];
            }

            if (callback) {
                callback(error, jsonObj);
            }

            [self postCommentFinishedResult:jsonObj isRepost:isRepost context:context error:error];
        }];

        result = YES;
    } else {
        [self postCommentFinishedResult:nil isRepost:isRepost context:context error:[NSError errorWithDomain:@"kCommonErrorDomain" code:1003 userInfo:nil]];
    }

    return result;
}

- (void)postCommentFinishedResult:(NSDictionary *)result isRepost:(BOOL)isRepost context:(id)context error:(NSError *)error {
    NSMutableDictionary *mDict = [NSMutableDictionary dictionaryWithCapacity:5];

    NSString *groupID = nil;
    NSString *commentID = nil;
    NSString *commentText = nil;

    if (error) {
        [mDict setValue:context forKey:kAccountManagerUserInfoKey];
    }

    NSDictionary *data = [result tt_dictionaryValueForKey:@"data"];
    if (data) {
        [mDict setValue:context forKey:kAccountManagerUserInfoKey];
        [mDict setValue:data forKey:@"data"];
        groupID = [data tt_stringValueForKey:@"group_id"];
        commentText = [data tt_stringValueForKey:@"text"];
        commentID = [data tt_stringValueForKey:@"id"];
    }

    if ([context isKindOfClass:[NSDictionary class]]) {
        [mDict setValue:[context objectForKey:@"userInfo"] forKey:@"userInfo"];
    }

    [mDict setValue:@(isRepost) forKey:@"is_zz"];
    [mDict setValue:@(isRepost) forKey:@"is_repost"];
    [mDict setValue:groupID forKey:@"group_id"];
    [mDict setValue:commentText forKey:@"text"];
    [mDict setValue:commentID forKey:@"comment_id"];
    //TODO: 此方法没有判断session expire
    [mDict setValue:error forKey:@"error"];

    FR2DataV4PostMessageResponseModel *response = [[FR2DataV4PostMessageResponseModel alloc] initWithDictionary:result error:nil];
    [mDict setValue:response.data forKey:@"comment"];

    [[NSNotificationCenter defaultCenter] postNotificationName:kPostMessageFinishedNotification
                                                        object:self
                                                      userInfo:mDict];

    if (!error) {
        [[NSNotificationCenter defaultCenter] postNotificationName:TTCommentSuccessForPushGuideNotification object:nil userInfo:@{@"reason": @(3)}];
    }
}

- (void)postCommentReplyWithCommentID:(NSString *)commentID
                       replyCommentID:(NSString *)replyCommentID
                          replyUserID:(NSString *)replyUserID
                              content:(NSString *)content
                      contentRichSpan:(NSString *)contentRichSpan
                         mentionUsers:(NSString *)mentionUsers
                          finishBlock:(void (^)(id jsonObj, NSError *error))finishBlock {

    NSMutableDictionary *postParams = [[NSMutableDictionary alloc] init];
    [postParams setValue:commentID forKey:@"id"];
    [postParams setValue:replyCommentID forKey:@"reply_comment_id"];
    [postParams setValue:replyUserID forKey:@"reply_user_id"];
    [postParams setValue:content forKey:@"content"];

    NSString *optimizedContentRichSpanString = [TTRichSpans filterValidRichSpanString:contentRichSpan];
    [postParams setValue:optimizedContentRichSpanString forKey:@"content_rich_span"];

    [postParams setValue:mentionUsers forKey:@"mention_user"];
    [postParams setValue:@"0" forKey:@"forward"];

    [[TTNetworkManager shareInstance] requestForJSONWithURL:[TTCommentDataManager postCommentReplyURLString] params:postParams method:@"POST" needCommonParams:YES callback:^(NSError *error, id jsonObj) {
        if (!error) {
            if (finishBlock) {
                finishBlock(jsonObj, error);
            }
        } else {
            if (finishBlock) {
                finishBlock(jsonObj, error);
            }
        }
    }];
}


#pragma mark - DELETE

- (void)deleteCommentWithCommentID:(NSString *)commentID finishBlock:(void (^)(NSError *error))finishBlock {
    if ([commentID longLongValue] == 0) {
        LOGI(@"删除文章评论的ID不能为0");
        return;
    }

    if (![TTAccountManager isLogin]) {
        LOGI(@"删除评论必须登录");
        return;
    }

    NSMutableDictionary *postParams = [[NSMutableDictionary alloc] initWithCapacity:10];
    [postParams setValue:commentID forKey:@"id"];

    WeakSelf;
    [[TTNetworkManager shareInstance] requestForJSONWithURL:[TTCommentDataManager deleteCommentURLString] params:postParams method:@"POST" needCommonParams:YES callback:^(NSError *error, id jsonObj) {
        StrongSelf;
        if (error) {
            BatchItemActionModel *model = [[BatchItemActionModel alloc] init];
            model.groupID = @([commentID longLongValue]);
            model.actionName = BatchItemActionTypeNewVersionDeleteArticleComment;
            model.versionType = BatchItemVersionTypeNewVersionDelete;
            model.timestamp = @([[NSDate date] timeIntervalSince1970]);
            [[SSBatchItemActionManager shareManager] addUnSynchronizedItem:model];
            [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:NSLocalizedString(@"删除失败", nil) indicatorImage:[UIImage themedImageNamed:@"close_popup_textpage"] autoDismiss:YES dismissHandler:nil];
        } else {
            NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] initWithCapacity:1];
            [userInfo setValue:commentID forKey:@"id"];
            [[NSNotificationCenter defaultCenter] postNotificationName:kDeleteCommentNotificationKey object:nil userInfo:userInfo];
        }

        if (finishBlock) {
            finishBlock(error);
        }
    }];
}

- (void)deleteCommentReplyWithCommentReplyID:(NSString *)commentReplyID commentID:(NSString *)commentID finishBlock:(void (^)(NSError *error))finishBlock {
    if ([commentReplyID longLongValue] == 0 || [commentID longLongValue] == 0) {
        LOGI(@"删除文章评论的ID不能为0");
        return;
    }

    if (![TTAccountManager isLogin]) {
        LOGI(@"删除评论必须登录");
        return;
    }

    NSMutableDictionary *postParams = [[NSMutableDictionary alloc] initWithCapacity:2];
    [postParams setValue:commentID forKey:@"id"];
    [postParams setValue:commentReplyID forKey:@"reply_id"];
    [[TTNetworkManager shareInstance] requestForJSONWithURL:[TTCommentDataManager deleteCommentReplyURLString] params:postParams method:@"POST" needCommonParams:YES callback:^(NSError *error, id jsonObj) {
        if (finishBlock) {
            finishBlock(error);
        }
    }];
}

- (void)deleteCommentByAuthorWithCommentID:(NSString *)commentID groupID:(NSString *)groupID finishBlock:(void (^)(NSError *error))finishBlock {
    FRUgcCommentAuthorActionV2DeleteRequestModel *request = [[FRUgcCommentAuthorActionV2DeleteRequestModel alloc] init];
    request.comment_id = @(commentID.longLongValue);
    request.group_id = @(groupID.longLongValue);
    request.action_type = @(1);

    [FRRequestManager requestModel:request callBackWithMonitor:^(NSError *error, NSObject <TTResponseModelProtocol> *responseModel, FRForumMonitorModel *monitorModel) {
        if (finishBlock) {
            finishBlock(error);
        }
    }];
}

- (void)deleteCommentReplyByAuthorWithCommentReplyID:(NSString *)commentReplyID commentID:(NSString *)commentID finishBlock:(void (^)(NSError *error))finishBlock {
    FRUgcCommentAuthorActionV2DeleteRequestModel *request = [[FRUgcCommentAuthorActionV2DeleteRequestModel alloc] init];
    request.comment_id = @(commentID.longLongValue);
    request.reply_id = @(commentReplyID.longLongValue);
    request.action_type = @(2);

    [FRRequestManager requestModel:request callBackWithMonitor:^(NSError *error, NSObject <TTResponseModelProtocol> *responseModel, FRForumMonitorModel *monitorModel) {
        if (finishBlock) {
            finishBlock(error);
        }
    }];
}

#pragma mark - DIGG

- (void)fetchCommentDiggListWithCommentID:(NSString *)commentID finishBlock:(TTCommentDiggListFinishBlock)finishBlock {
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    [param setValue:commentID forKey:@"id"];
    [param setValue:@"10" forKey:@"count"];
    [param setValue:@"0" forKey:@"offset"];

    [[TTNetworkManager shareInstance] requestForJSONWithURL:[TTCommentDataManager commentDiggListURLString] params:param method:@"GET" needCommonParams:YES callback:^(NSError *error, id jsonObj) {
        if (!error) {
            NSArray *diggUsers = [[jsonObj tt_dictionaryValueForKey:@"data"] tt_arrayValueForKey:@"data"];
            NSInteger diggCount = [[jsonObj tt_dictionaryValueForKey:@"data"] tt_integerValueForKey:@"total_count"];
            NSMutableOrderedSet *userModels = [[NSMutableOrderedSet alloc] init];
            for (NSDictionary *diggUser in diggUsers) {
                SSUserModel *userModel = [[SSUserModel alloc] initWithDictionary:diggUser];
                if (userModel) {
                    [userModels addObject:userModel];
                }
            }

            if (finishBlock) {
                finishBlock(userModels, diggCount, nil);
            }
        } else {
            if (finishBlock) {
                finishBlock(nil, 0, error);
            }
        }
    }];

}

- (void)diggCommentReplyWithCommentReplyID:(NSString *)commentReplyID commentID:(NSString *)commentID isDigg:(BOOL)isDigg {
    NSMutableDictionary *param = [[NSMutableDictionary alloc] initWithCapacity:3];
    [param setValue:commentID forKey:@"id"];
    [param setValue:commentReplyID forKey:@"reply_id"];
    [param setValue:isDigg ? @"cancel_digg": @"digg" forKey:@"action"];
    [[TTNetworkManager shareInstance] requestForJSONWithURL:[TTCommentDataManager diggCommentReplyURLString] params:param method:@"GET" needCommonParams:YES callback:nil];
}

#pragma mark - URLString

+ (NSString *)baseURLString {
    return [[TTURLDomainHelper shareInstance] domainFromType:TTURLDomainTypeNormal];
}

+ (NSString *)tabCommentsURLString {
    return [NSString stringWithFormat:@"%@/f100/article/v2/tab_comments/", [TTCommentDataManager baseURLString]];
}

+ (NSString *)commentDetailURLString {
    return [NSString stringWithFormat:@"%@/2/comment/v1/detail/", [TTCommentDataManager baseURLString]];
}

+ (NSString *)commentReplyListURLString {
    return [NSString stringWithFormat:@"%@/2/comment/v1/reply_list/", [TTCommentDataManager baseURLString]];
}

+ (NSString*)postCommentURLString {
    return [NSString stringWithFormat:@"%@/f100/2/data/v4/post_message/", [TTCommentDataManager baseURLString]];
}

+ (NSString*)postCommentReplyURLString {
    return [NSString stringWithFormat:@"%@/2/comment/v3/create_reply/", [TTCommentDataManager baseURLString]];
}

+ (NSString *)deleteCommentURLString {
    return [NSString stringWithFormat:@"%@/2/comment/v1/delete_comment/", [TTCommentDataManager baseURLString]];
}

+ (NSString *)deleteCommentReplyURLString {
    return [NSString stringWithFormat:@"%@/2/comment/v1/delete_reply/", [TTCommentDataManager baseURLString]];
}

+ (NSString *)commentDiggListURLString {
    return [NSString stringWithFormat:@"%@/2/comment/v1/digg_list/", [TTCommentDataManager baseURLString]];
}

+ (NSString *)diggCommentReplyURLString {
    return [NSString stringWithFormat:@"%@/2/comment/v1/digg_reply/", [TTCommentDataManager baseURLString]];
}

@end
