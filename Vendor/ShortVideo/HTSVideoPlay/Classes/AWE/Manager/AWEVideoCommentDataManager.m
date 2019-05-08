//
//  HTSVideoCommentDataManager.m
//  LiveStreaming
//
//  Created by lym on 16/10/19.
//  Copyright © 2016年 Bytedance. All rights reserved.
//

#import "AWEVideoCommentDataManager.h"
#import "AWEVideoPlayNetworkManager.h"
#import "AWECommentModel.h"
#import "AWEActionSheetModel.h"
#import "AWEActionSheetCellModel.h"
#import "TSVMonitorManager.h"

#define DefaultTopModelCount 20  //取前20条remote数据与fake比较

extern NSString * const TTCommentSuccessForPushGuideNotification;

static NSString * const TT_DOMAIN = @"http://i.haoduofangs.com";

static NSString * const AWEIllegalParameterDomain = @"AWEIllegalParameterDomain";

@interface AWEVideoCommentDataManager()

@property (nonatomic, assign) BOOL hasMore;
@property (nonatomic, assign) NSInteger totalCount;
@property (nonatomic, assign) BOOL isLoadingComments;
@property (nonatomic, assign) BOOL isSendingComments;
@property(nonatomic, strong) NSMutableArray<AWECommentModel *> *commentArray;

@end

@implementation AWEVideoCommentDataManager

- (instancetype)init
{
    self = [super init];
    if (self) {
        _hasMore = YES;
        _criticismInput = @"";
        _commentArray = [NSMutableArray new];
    }
    return self;
}

- (BOOL)canLoadMore
{
    return self.hasMore;
}

- (void)addActionSheetMode:(AWEActionSheetModel *)model {
    NSMutableArray *mutableArray = [[NSMutableArray alloc] init];
    for (NSDictionary *dictionary in model.dataArray) {
        AWEActionSheetCellModel *cellModel = [[AWEActionSheetCellModel alloc] init];
        cellModel.identifier = dictionary[@"type"];
        cellModel.text = dictionary[@"text"];
        cellModel.isSelected = NO;
        [mutableArray addObject:cellModel];
    }
    model.dataArray = mutableArray;
    _reportModel = model;
}

- (AWECommentModel *)commentForIndexPath:(NSIndexPath *)indexPath
{
    if (!indexPath || [self isEmpty] || indexPath.row >= self.commentArray.count) {
        return nil;
    }
    
    return self.commentArray[indexPath.row];
}

- (BOOL)isEmpty
{
    return self.totalCount == 0;
}

- (NSInteger)totalCommentCount
{
    return self.totalCount;
}

- (NSInteger)currentCommentCount
{
    return self.commentArray.count;
}

- (void)commentAwemeItemWithID:(NSString *)itemID
                       groupID:(NSString *)groupID
                       content:(NSString *)content
                    completion:(AWEAwemeAddCommentResponseBlock)block
{
    [self commentAwemeItemWithID:itemID groupID:groupID content:content replyCommentID:nil completion:block];
}

- (void)commentAwemeItemWithID:(NSString *)itemID
                       groupID:(NSString *)groupID
                       content:(NSString *)content
                replyCommentID:(NSNumber *)commentID
                    completion:(AWEAwemeAddCommentResponseBlock)block
{
    if (!itemID || !content) {
        return;
    }
    
    if (self.isSendingComments) {
        return;
    }
    self.isSendingComments = YES;
    
    NSString *urlString = [NSString stringWithFormat:@"%@/2/data/v3/post_message/", TT_DOMAIN];
    NSMutableDictionary *commentParam = [NSMutableDictionary dictionaryWithCapacity:10];
    [commentParam setValue:groupID forKey:@"group_id"];
    [commentParam setValue:itemID forKey:@"item_id"];
    [commentParam setValue:content forKey:@"text"];
    [commentParam setValue:@0 forKey:@"aggr_type"];
    [commentParam setValue:@1 forKey:@"is_comment"];
    [commentParam setValue:@1128 forKey:@"service_id"];
    
    if(commentID){
        [commentParam setValue:commentID forKey:@"reply_to_comment_id"];
    }
    
    NSString *monitorIdentifier = [[TSVMonitorManager sharedManager] startMonitorNetworkService:TSVMonitorNetworkServicePostComment key:itemID];
    
    __weak typeof(self) weakSelf = self;
    [[AWEVideoPlayNetworkManager sharedInstance] requestJSONFromURL:urlString params:commentParam method:@"POST" needCommonParams:YES callback:^(NSError *error, id jsonObj) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        
        [[TSVMonitorManager sharedManager] endMonitorNetworkService:TSVMonitorNetworkServicePostComment identifier:monitorIdentifier error:error];
        
        if (!strongSelf) {
            return;
        }
        strongSelf.isSendingComments = NO;

        if(error || (jsonObj[@"message"] && [jsonObj[@"message"] isEqualToString:@"error"])){
            NSMutableDictionary *errorInfo = [NSMutableDictionary dictionary];
            errorInfo[@"prompts"] = jsonObj[@"data"][@"description"];
            block(nil, [NSError errorWithDomain:@"com.bytedance.douyin" code:[((NSNumber *)jsonObj[@"errno"]) integerValue] userInfo:errorInfo]);
            return;
        }
        
        NSError *mappingError = nil;
        NSDictionary *dataDic = [jsonObj objectForKey:@"data"];
        AWECommentModel *model = [MTLJSONAdapter modelOfClass:[AWECommentModel class]
                                           fromJSONDictionary:dataDic
                                                        error:&mappingError];
        if(model){
            [strongSelf.commentArray insertObject:model atIndex:0];
            strongSelf.totalCount = strongSelf.totalCount + 1;
        }
        //success
        !block ?: block(model, mappingError);
        
        [[NSNotificationCenter defaultCenter] postNotificationName:TTCommentSuccessForPushGuideNotification object:nil userInfo:@{@"reason": @(3)}];
    }];

}

- (void)deleteCommentItemWithId:(NSNumber *)commentId
                     completion:(AWEAwemeDetailCommonBlock)block
{
    if (!commentId) {
        return;
    }
    
    NSString *urlString = [NSString stringWithFormat:@"%@/2/comment/v1/delete_comment/", TT_DOMAIN];
    NSDictionary *params = @{
                            @"id" : commentId,
                          };
    
    NSString *monitorIdentifier = [[TSVMonitorManager sharedManager] startMonitorNetworkService:TSVMonitorNetworkServiceDeleteComment key:commentId];
    
    __weak typeof(self) weakSelf = self;
    [[AWEVideoPlayNetworkManager sharedInstance] requestJSONFromURL:urlString params:params method:@"POST" needCommonParams:YES callback:^(NSError *error, id jsonObj) {
        __strong typeof(weakSelf) strongSelf = weakSelf;

        [[TSVMonitorManager sharedManager] endMonitorNetworkService:TSVMonitorNetworkServiceDeleteComment identifier:monitorIdentifier error:error];
        
        if(!error){
            for (AWECommentModel *model in strongSelf.commentArray) {
                if ([model.id isEqualToNumber:commentId]) {
                    [strongSelf.commentArray removeObject:model];
                    break;
                }
            }
            strongSelf.totalCount = strongSelf.totalCount - 1;
        }
        !block ?: block(jsonObj, error);
    }];
}

- (void)requestCommentListWithID:(NSString *)itemID
                         groupID:(NSString *)groupID
                           count:(NSNumber *)count
                          offset:(NSNumber *)offset
                      completion:(AWEAwemeCommentDataBlock)block
{
    if (!itemID ||!count) {
        return;
    }

    if (self.isLoadingComments) {
        return;
    }
    self.isLoadingComments = YES;
    
    NSMutableDictionary *commentParam = [NSMutableDictionary dictionaryWithCapacity:10];
    [commentParam setValue:groupID forKey:@"group_id"];
    [commentParam setValue:itemID forKey:@"item_id"];
    [commentParam setValue:offset forKey:@"offset"];
    [commentParam setValue:count forKey:@"count"];
    [commentParam setValue:@(0) forKey:@"fold"]; //非折叠区评论
    [commentParam setValue:@(0) forKey:@"aggr_type"];
    [commentParam setValue:@1128 forKey:@"service_id"];
   
    NSString *monitorIdentifier = [[TSVMonitorManager sharedManager] startMonitorNetworkService:TSVMonitorNetworkServiceCommentList key:itemID];
    
    __weak typeof(self) weakSelf = self;
    NSString *urlString = [NSString stringWithFormat:@"%@/article/v2/tab_comments/", TT_DOMAIN];
    [[AWEVideoPlayNetworkManager sharedInstance] requestJSONFromURL:urlString params:commentParam method:@"GET" needCommonParams:YES callback:^(NSError *error, id jsonObj) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        
        [[TSVMonitorManager sharedManager] endMonitorNetworkService:TSVMonitorNetworkServiceCommentList identifier:monitorIdentifier error:error];
        
        strongSelf.isLoadingComments = NO;
        
        if (error) {
            if (block) {
                block(nil, error);
            }
            return;
        }
        NSError *mappingError = nil;
        AWECommentResponseModel *response = [MTLJSONAdapter modelOfClass:[AWECommentResponseModel class]
                                                      fromJSONDictionary:jsonObj
                                                                   error:&mappingError];
        if (mappingError) {
            if (block) {
                block(nil, mappingError);
            }
            return;
        }

        self.hasMore = response.hasMore;
        self.totalCount = [response.totalNumber integerValue];
        for (AWECommentWrapper *commentWrapper in response.data) {
            if (commentWrapper.comment && ![strongSelf.commentArray containsObject:commentWrapper.comment]) {
                [strongSelf.commentArray addObject:commentWrapper.comment];
            }
        }

        !block ?: block(response, nil);
    }];
}

- (void)diggCommentItemWithCommentId:(NSNumber *)commentID
                              itemID:(NSString *)itemID
                             groupID:(NSString *)groupID
                              userID:(NSString *)userID
                          cancelDigg:(BOOL)cancelDigg
                          completion:(AWEAwemeDetailDiggBlock)block
{
    NSParameterAssert(commentID);
    NSParameterAssert(itemID);

    NSString *actionName = cancelDigg ? @"cancel_digg" : @"digg";
    NSString *urlString = [NSString stringWithFormat:@"%@/2/data/comment_action/", TT_DOMAIN];
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:10];
    [params setValue:commentID forKey:@"comment_id"];
    [params setValue:groupID forKey:@"group_id"];
    [params setValue:itemID forKey:@"item_id"];
    [params setValue:@0 forKey:@"aggr_type"];
    [params setValue:actionName forKey:@"action"];
    [params setValue:userID forKey:@"user_id"];
    
    NSString *monitorIdentifier = [[TSVMonitorManager sharedManager] startMonitorNetworkService:TSVMonitorNetworkServiceDiggComment key:commentID];
    
    [[AWEVideoPlayNetworkManager sharedInstance] requestJSONFromURL:urlString params:params method:@"POST" needCommonParams:YES callback:^(NSError *error, id jsonObj) {
        
        [[TSVMonitorManager sharedManager] endMonitorNetworkService:TSVMonitorNetworkServiceDiggComment identifier:monitorIdentifier error:error];
        
        if (error) {
            !block?:block(nil,error);
            return;
        }
        
        NSError *mappingError = nil;
        AWECommentDiggStatus *response = [MTLJSONAdapter modelOfClass:[AWECommentDiggStatus class]
                                                      fromJSONDictionary:jsonObj
                                                                   error:&mappingError];
        if (mappingError) {
            !block?:block(nil,mappingError);
            return;
        }
        //这里后端会user_digg返回0 表示用户之前没点赞过，而不是点赞过的状态，所以这里重置一下
        response.userDigg = !cancelDigg;
        !block ?: block(response, nil);
    }];
}

- (void)reportCommentWithType:(NSString *)reportType
                userInputText:(NSString *)inputText
                       userID:(NSString *)userID
                    commentID:(NSNumber *)commentID
                     momentID:(NSString *)momentID
                      groupID:(NSString *)groupID
                       postID:(NSString *)postID
                   completion:(AWEAwemeDetailCommonBlock)block {
    
    if (!userID || !reportType) {
        return;
    }
    
    NSMutableDictionary * params = [NSMutableDictionary dictionaryWithCapacity:10];
    [params setValue:userID forKey:@"user_id"];
    [params setValue:momentID forKey:@"update_id"];
    [params setValue:commentID forKey:@"comment_id"];
    [params setValue:groupID forKey:@"group_id"];
    [params setValue:postID forKey:@"post_id"];
    [params setValue:reportType forKey:@"report_type"];
    [params setValue:inputText forKey:@"report_content"];
    [params setValue:@1 forKey:@"source"];
    
    NSString * url = [NSString stringWithFormat:@"%@/feedback/1/report_user/", TT_DOMAIN];
    
    NSString *monitorIdentifier = [[TSVMonitorManager sharedManager] startMonitorNetworkService:TSVMonitorNetworkServiceReportComment key:commentID];
    
    [[AWEVideoPlayNetworkManager sharedInstance] requestJSONFromURL:url params:params method:@"POST" needCommonParams:YES callback:^(NSError *error, id jsonObj) {
        [[TSVMonitorManager sharedManager] endMonitorNetworkService:TSVMonitorNetworkServiceReportComment identifier:monitorIdentifier error:error];
        
        !block ?: block(jsonObj, error);
    }];
}


@end
