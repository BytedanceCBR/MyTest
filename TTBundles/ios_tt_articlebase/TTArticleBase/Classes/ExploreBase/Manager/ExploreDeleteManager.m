//
//  ExploreDeleteManager.m
//  Article
//
//  Created by Zhang Leonardo on 15-1-16.
//
//

#import "ExploreDeleteManager.h"
#import "ArticleURLSetting.h"
#import <TTAccountBusiness.h>
#import "SSBatchItemActionManager.h"
#import "ExploreMomentDefine.h"
#import "NSDictionary+TTAdditions.h"
#import <TTNetworkManager/TTNetworkManager.h>
#import "ExploreOrderedData+TTBusiness.h"
#import "ExploreMixListDefine.h"
//#import "Thread.h"

static ExploreDeleteManager * shareManager;

@implementation ExploreDeleteManager

+ (ExploreDeleteManager *)shareManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareManager = [[ExploreDeleteManager alloc] init];
    });
    return shareManager;
}

- (void)deleteArticleCommentForCommentID:(NSString *)commentID isAnswer:(BOOL)isAnswer isNewComment:(BOOL)isNewComment;
{
    if ([commentID longLongValue] == 0) {
        LOGI(@"删除文章评论的ID不能为0");
        return;
    }
    if (![TTAccountManager isLogin]) {
        LOGI(@"删除评论必须登录");
        return;
    }
    NSMutableDictionary * postParam = [[NSMutableDictionary alloc] initWithCapacity:10];
    [postParam setValue:commentID forKey:@"id"];
    [postParam setValue:@(isAnswer) forKey:@"is_answer"];
    
    WeakSelf;
    NSString *url = isNewComment? [ArticleURLSetting deleteArticleNewCommentURLString]: [ArticleURLSetting deleteArticleCommentURLString];
    [[TTNetworkManager shareInstance] requestForJSONWithURL:url params:postParam method:@"POST" needCommonParams:YES callback:^(NSError *error, id jsonObj) {
        StrongSelf;
        if (error) {
            BatchItemActionModel * model = [[BatchItemActionModel alloc] init];
            model.groupID = @([commentID longLongValue]);
            model.actionName = BatchItemActionTypeNewVersionDeleteArticleComment;
            model.versionType = BatchItemVersionTypeNewVersionDelete;
            model.timestamp = @([[NSDate date] timeIntervalSince1970]);
            [[SSBatchItemActionManager shareManager] addUnSynchronizedItem:model];
            [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:NSLocalizedString(@"删除失败", nil) indicatorImage:[UIImage themedImageNamed:@"close_popup_textpage"] autoDismiss:YES dismissHandler:nil];
        }
        else {
            NSMutableDictionary * data = [jsonObj tt_dictionaryValueForKey:@"data"].mutableCopy;
            [data setValue:commentID forKey:@"comment_id"];
            //我也是日了🐶了. 删除评论返回动态id...
            
            [self postDeleteNotificationIfNeed:data.copy type:kDeleteCommentNotificationKey];
        }
    }];
}

- (void)deleteReplyedComment:(NSString *)replyCommentID InHostComment:(NSString *)hostCommentID {
    if ([replyCommentID longLongValue] == 0 || [hostCommentID longLongValue] == 0) {
        LOGI(@"删除文章评论的ID不能为0");
        return;
    }
    if (![TTAccountManager isLogin]) {
        LOGI(@"删除评论必须登录");
        return;
    }
    
    NSMutableDictionary *param = [[NSMutableDictionary alloc] initWithCapacity:1];
    [param setValue:hostCommentID forKey:@"id"];
    [param setValue:replyCommentID forKey:@"reply_id"];
    [[TTNetworkManager shareInstance] requestForJSONWithURL:[ArticleURLSetting deleteReplyedCommentURLString] params:param method:@"POST" needCommonParams:YES callback:nil];
}

- (void)deleteMomentForMomentID:(NSString *)momentID
{
    if ([momentID longLongValue] == 0) {
        LOGI(@"删除文章评论的ID不能为0");
        return;
    }
    
    if (![TTAccountManager isLogin]) {
        LOGI(@"删除评论必须登录");
        return;
    }
    
    NSMutableDictionary * postParam = [[NSMutableDictionary alloc] initWithCapacity:10];
    [postParam setValue:momentID forKey:@"id"];
    
    WeakSelf;
    [[TTNetworkManager shareInstance] requestForJSONWithURL:[ArticleURLSetting deleteMomentURLString] params:postParam method:@"POST" needCommonParams:YES callback:^(NSError *error, id jsonObj) {
        StrongSelf;
        if (error) {
            BatchItemActionModel * model = [[BatchItemActionModel alloc] init];
            model.groupID = @([momentID longLongValue]);
            model.actionName = BatchItemActionTypeNewVersionDeleteMoment;
            model.versionType = BatchItemVersionTypeNewVersionDelete;
            model.timestamp = @([[NSDate date] timeIntervalSince1970]);
            [[SSBatchItemActionManager shareManager] addUnSynchronizedItem:model];
            [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:NSLocalizedString(@"删除失败", nil) indicatorImage:[UIImage themedImageNamed:@"close_popup_textpage"] autoDismiss:YES dismissHandler:nil];
        }
        else {
            NSDictionary * data = [jsonObj tt_dictionaryValueForKey:@"data"];
            [self postDeleteNotificationIfNeed:data type:kDeleteMomentNotificationKey];
        }
    }];
}

- (void)deleteMomentCommentForCommentID:(NSString *)commentID {
    if ([commentID longLongValue] == 0) {
        LOGI(@"删除动态评论的ID不能为0");
        return;
    }
    if (![TTAccountManager isLogin]) {
        LOGI(@"删除评论必须登录");
        return;
    }
    NSMutableDictionary * postParam = [[NSMutableDictionary alloc] initWithCapacity:10];
    [postParam setValue:commentID forKey:@"id"];
    
    WeakSelf;
    [[TTNetworkManager shareInstance] requestForJSONWithURL:[ArticleURLSetting deleteMomentCommentURLString] params:postParam method:@"POST" needCommonParams:YES callback:^(NSError *error, id jsonObj) {
        StrongSelf;
        if (error) {
            BatchItemActionModel * model = [[BatchItemActionModel alloc] init];
            model.groupID = @([commentID longLongValue]);
            model.actionName = BatchItemActionTypeNewVersionDeleteMomentComment;
            model.versionType = BatchItemVersionTypeNewVersionDelete;
            model.timestamp = @([[NSDate date] timeIntervalSince1970]);
            [[SSBatchItemActionManager shareManager] addUnSynchronizedItem:model];
        }
        else {
            NSDictionary * data = [jsonObj tt_dictionaryValueForKey:@"data"];
            [self postDeleteNotificationIfNeed:data type:kDeleteMomentCommentNotificationKey];
        }
    }];

}

- (void)postDeleteNotificationIfNeed:(NSDictionary *)data type:(NSString *)type {

    long long dongtaiID = [[data objectForKey:@"dongtai_id"] longLongValue];
    if (dongtaiID != 0 && [type isEqualToString:kDeleteMomentNotificationKey]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kDeleteMomentNotificationKey object:nil userInfo:@{@"id":@(dongtaiID)}];
        
        NSArray *results = [ExploreOrderedData objectsWithQuery:@{@"uniqueID":[NSString stringWithFormat:@"%lld",dongtaiID]}];
        [results enumerateObjectsUsingBlock:^(ExploreOrderedData * obj, NSUInteger idx, BOOL *stop) {
            NSMutableDictionary * userInfo1 = [NSMutableDictionary dictionaryWithCapacity:2];
            [userInfo1 setValue:obj forKey:kExploreMixListDeleteItemKey];
            [[NSNotificationCenter defaultCenter] postNotificationName:kExploreMixListItemDeleteNotification object:nil userInfo:userInfo1];
        }];
        for (ExploreOrderedData *obj in results) {
            [obj deleteObject];
        }
//        [Thread setThreadHasBeDeletedWithThreadID:[NSString stringWithFormat:@"%lld",dongtaiID]];
        return;
    }
    
    long long dongtaiCommentID = [[data objectForKey:@"dongtai_comment_id"] longLongValue];
    long long replyDongtaiID = [[data objectForKey:@"reply_dongtai_id"] longLongValue];
    
    if (dongtaiCommentID != 0 && replyDongtaiID != 0 && [type isEqualToString:kDeleteMomentCommentNotificationKey]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kDeleteMomentCommentNotificationKey object:nil userInfo:@{@"cid":@(dongtaiCommentID), @"mid":@(replyDongtaiID)}];
        return;
    }
    if ([type isEqualToString:kDeleteCommentNotificationKey]) {
        NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] initWithCapacity:1];
        [userInfo setValue:data[@"comment_id"] forKey:@"id"];
        [[NSNotificationCenter defaultCenter] postNotificationName:kDeleteCommentNotificationKey object:nil userInfo:userInfo];
        return;
    }
}

@end
