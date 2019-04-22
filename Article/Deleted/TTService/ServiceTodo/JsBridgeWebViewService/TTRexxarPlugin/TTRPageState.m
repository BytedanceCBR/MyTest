//
//  TTRPageState.m
//  Article
//
//  Created by muhuai on 2017/5/18.
//
//

#import "TTRPageState.h"
#import "FriendDataManager.h"
#import "TTBlockManager.h"
#import "ExploreEntryManager.h"
#import "TTFollowNotifyServer.h"
//#import "FRConcernEntity.h"
#import <TTAccountBusiness.h>
#import <AKWDPlugin/WDAnswerService.h>
#import <AKWDPlugin/WDQuestionService.h>

//extern NSString *const kForumLikeStatusChangeNotification;
//extern NSString *const kForumLikeStatusChangeForumIDKey;
//extern NSString *const kForumLikeStatusChangeForumLikeKey;

//我只是代码的搬运工🙂🙂🙂🙂🙂🙂🙂🙂🙂🙂🙂🙂🙂🙂🙂🙂🙂🙂🙂🙂🙂🙂
@interface TTRPageState ()
<
TTAccountMulticastProtocol,
WDQuestionServiceProtocol,
WDAnswerServiceProtocol
>
@end

@implementation TTRPageState

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [TTAccount removeMulticastDelegate:self];
    [WDQuestionService unRegisterDelegate:self];
    [WDAnswerService unRegisterDelegate:self];
}

+ (TTRJSBInstanceType)instanceType {
    return TTRJSBInstanceTypeWebView;
}

- (void)isVisibleWithParam:(NSDictionary *)param callback:(TTRJSBResponse)callback webView:(UIView<TTRexxarEngine> *)webview controller:(UIViewController *)controller {
    callback(TTRJSBMsgSuccess, @{@"code" : @(!!webview.window)});
}

- (void)pageStateChangeWithParam:(NSDictionary *)param callback:(TTRJSBResponse)callback webView:(UIView<TTRexxarEngine> *)webview controller:(UIViewController *)controller {
    NSString *type = [param objectForKey:@"type"];
    NSString *entryID = [NSString stringWithFormat:@"%@", [param objectForKey:@"id"]];
    NSNumber *status = [param objectForKey:@"status"];
    int code = 1;
    if([type isEqualToString:@"pgc_action"])
    {
        if(!isEmptyString(entryID))
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:kPGCSubscribeStatusChangedNotification object:nil];
            NSArray *entries = [[ExploreEntryManager sharedManager] entryForEntryIDs:@[entryID]];
            
            ExploreEntry *entry;
            
            if(entries.count > 0)
            {
                entry = entries[0];
            } else {
                NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
                [dic setValue:entryID forKey:@"id"];
                [dic setValue:@1 forKey:@"type"];
                [dic setValue:@0 forKey:@"subscribed"];
                [dic setValue:[NSNumber numberWithInteger:entryID.integerValue] forKey:@"media_id"];
                [dic setValue:entryID forKey:@"entry_id"];
                
                entry = [[ExploreEntryManager sharedManager] insertExploreEntry:dic save:YES];
            }
            
            if ([status intValue] == 1)
            {
//                //第一次关注头条号动画
//                if([TTFirstConcernManager firstTimeGuideEnabled]){
//                    TTFirstConcernManager *manager = [[TTFirstConcernManager alloc] init];
//                    [manager showFirstConcernAlertViewWithDismissBlock:nil];
//                }
                
                entry.subscribed = @(NO);
                [[ExploreEntryManager sharedManager] subscribeExploreEntry:entry notify:NO notifyFinishBlock:nil];
                
            }
            else
            {
                //                    ExploreEntry *entry = [self subscribe:param];
                entry.subscribed = @(YES);
                [[ExploreEntryManager sharedManager] unsubscribeExploreEntry:entry notify:NO notifyFinishBlock:nil];
            }
            [[TTFollowNotifyServer sharedServer] postFollowNotifyWithID:entryID
                                                             actionType:[status intValue] == 1?TTFollowActionTypeFollow:TTFollowActionTypeUnfollow
                                                               itemType:TTFollowItemTypeDefault
                                                               userInfo:nil];
        }
    }
    else if ([type isEqualToString:@"donate_action"]) { // 头条号文章赞赏
        if (!isEmptyString(entryID)) {
            
            NSDictionary *userInfo = @{@"type":   type,
                                       @"id":     entryID,
                                       @"status": status ? : @""
                                       };
            [[NSNotificationCenter defaultCenter] postNotificationName:@"kArticleJSBrdigePGCDonateFinishedNotification" object:self userInfo:userInfo];
        }
    }
    else if([type isEqualToString:@"user_action"])
    {
//        //第一次关注用户引导动画
//        if ([status boolValue]) {
//            if ([TTFirstConcernManager firstTimeGuideEnabled]) {
//                TTFirstConcernManager *manager = [[TTFirstConcernManager alloc] init];
//                [manager showFirstConcernAlertViewWithDismissBlock:nil];
//            }
//        }
        [[TTFollowNotifyServer sharedServer] postFollowNotifyWithID:entryID
                                                         actionType:status.boolValue?TTFollowActionTypeFollow:TTFollowActionTypeUnfollow
                                                           itemType:TTFollowItemTypeDefault
                                                           userInfo:nil];
        FriendActionType actionType = ([status intValue] == 0 ? FriendActionTypeUnfollow : FriendActionTypeFollow);
        [[NSNotificationCenter defaultCenter] postNotificationName:RelationActionSuccessNotification object:self userInfo:@{kRelationActionSuccessNotificationActionTypeKey : @(actionType), kRelationActionSuccessNotificationUserIDKey: (isEmptyString(entryID)?@"":entryID)}];
    }
    else if ([type isEqualToString:@"block_action"])
    {
        if (!isEmptyString(entryID)) {
            NSMutableDictionary * userInfo = [NSMutableDictionary dictionaryWithCapacity:2];
            [userInfo setValue:entryID forKey:kBlockedUnblockedUserIDKey];
            [userInfo setValue:status forKey:kIsBlockingKey];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:kHasBlockedUnblockedUserNotification object:self userInfo:userInfo];
        }
    }
//    else if([type isEqualToString:@"forum_action"])
//    {
//        //            NSString *from = [param objectForKey:@"from"];
//        //            [ExploreForumManager trackForumFollow:(status.intValue != 0) forumID:entryID groupModel:nil enterFrom:from];
//
//        [[NSNotificationCenter defaultCenter] postNotificationName:kForumLikeStatusChangeNotification
//                                                            object:self
//                                                          userInfo:@{kForumLikeStatusChangeForumLikeKey: ([status intValue] == 0 ? @NO : @YES),  kForumLikeStatusChangeForumIDKey: (isEmptyString(entryID)?@"":entryID)}];
//    }
    else if ([type isEqualToString:@"concern_action"])
    {
        if (entryID) {
//            //第一次关注实体词引导动画
//            if ([status boolValue]) {
//                if ([TTFirstConcernManager firstTimeGuideEnabled]){
//                    TTFirstConcernManager *manager = [[TTFirstConcernManager alloc] init];
//                    [manager showFirstConcernAlertViewWithDismissBlock:nil];
//                }
//            }
            [[TTFollowNotifyServer sharedServer] postFollowNotifyWithID:entryID
                                                             actionType:status.boolValue?TTFollowActionTypeFollow:TTFollowActionTypeUnfollow
                                                               itemType:TTFollowItemTypeDefault
                                                               userInfo:nil];
//            NSDictionary * userInfo = @{FRNeedUpdateConcernEntityConcernIDKey:entryID,
//                                        FRNeedUpdateConcernEntityConcernStateKey:([status intValue] == 0 ? @NO : @YES)};
//            [[NSNotificationCenter defaultCenter] postNotificationName:FRNeedUpdateConcernEntityCareStateNotification object:self userInfo:userInfo];
        }
    }
    else if ([type isEqualToString:@"wenda_rm"]) {

    }
    else if ([type isEqualToString:@"stock_action"]){
//        if ([status boolValue]){
//            if ([TTFirstConcernManager firstTimeGuideEnabled]){
//                TTFirstConcernManager *manager = [[TTFirstConcernManager alloc] init];
//                [manager showFirstConcernAlertViewWithDismissBlock:nil];
//            }
//        }
        [[TTFollowNotifyServer sharedServer] postFollowNotifyWithID:entryID
                                                         actionType:status.boolValue?TTFollowActionTypeFollow:TTFollowActionTypeUnfollow
                                                           itemType:TTFollowItemTypeDefault
                                                           userInfo:nil];
    }
    else if ([type isEqualToString:@"live_follow_action"]) {
        [[TTFollowNotifyServer sharedServer] postFollowNotifyWithID:entryID
                                                         actionType:status.boolValue?TTFollowActionTypeFollow:TTFollowActionTypeUnfollow
                                                           itemType:TTFollowItemTypeDefault
                                                           userInfo:nil];
    }
    else
    {
        code = 0;
    }
    
    callback(TTRJSBMsgSuccess, @{@"code": @(code)});
    return;
}

#pragma mark - addEventListener
- (void)addEventListenerWithParam:(NSDictionary *)param callback:(TTRJSBResponse)callback webView:(UIView<TTRexxarEngine> *)webview controller:(UIViewController *)controller {
    NSString *event = [param tt_stringValueForKey:@"name"];
    if ([event isEqualToString:@"page_state_change"]) {
        [self registerStatusRelatedNotification];
    } else if ([event isEqualToString:@"login"]) {
        [self registerLoginRelatedNotification];
    }
    callback(TTRJSBMsgSuccess, @{@"code": @"1"});
}

- (void)registerLoginRelatedNotification {
    [TTAccount removeMulticastDelegate:self];
    [TTAccount addMulticastDelegate:self];
}

- (void)registerWendaRelatedNotification {
    [WDQuestionService unRegisterDelegate:self];
    [WDQuestionService registerDelegate:self];
    [WDAnswerService unRegisterDelegate:self];
    [WDAnswerService registerDelegate:self];
    
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kWDServiceHelperQuestionFollowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(questionFollowStatusNotification:) name:kWDServiceHelperQuestionFollowNotification object:nil];
    
}

- (void)registerStatusRelatedNotification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kEntrySubscribeStatusChangedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(subscribeStatusChangedNotification:) name:kEntrySubscribeStatusChangedNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:RelationActionSuccessNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(relationActionNotification:) name:RelationActionSuccessNotification object:nil];
    
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:kForumLikeStatusChangeNotification object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(forumLikeStatusChangedNotification:) name:kForumLikeStatusChangeNotification object:nil];
    
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:FRConcernEntityCareStateChangeNotification object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(concernCareStatusChangedNotification:) name:FRConcernEntityCareStateChangeNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"kArticleJSBrdigePGCDonateFinishedNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pgcArticleDonateFinishedNotification:) name:@"kArticleJSBrdigePGCDonateFinishedNotification" object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kHasBlockedUnblockedUserNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(blockUnblockUserNotification:) name:kHasBlockedUnblockedUserNotification object:nil];
    
    [self registerWendaRelatedNotification];
    [self registerLoginRelatedNotification];
}

- (void)subscribeStatusChangedNotification:(NSNotification*)notification
{
    //    if(![self isAuthorizedForEvent:@"page_state_change"] && ![self isInnerDomain])
    //    {
    //        return;
    //    }
    
    //忽略从js bridge抛出的通知
    if([notification.object isKindOfClass:[self class]]) //从ArticleJSBridge迁移来的
    {
        return;
    }
    
    ExploreEntry *entry = [notification.userInfo objectForKey:kEntrySubscribeStatusChangedNotificationUserInfoEntryKey];
    if(entry)
    {
        NSMutableDictionary *param = [NSMutableDictionary dictionary];
        [param setValue:entry.entryID forKey:@"id"];
        [param setValue:([entry.subscribed boolValue] ? @1 : @0) forKey:@"status"];
        [param setValue:@"pgc_action" forKey:@"type"];
        [self.engine ttr_fireEvent:@"page_state_change" data:param];
    }
}


- (void)relationActionNotification:(NSNotification*)notification
{
    //    if(![self isAuthorizedForEvent:@"page_state_change"] && ![self isInnerDomain])
    //    {
    //        return;
    //    }
    
    //忽略从js bridge抛出的通知
    if([notification.object isKindOfClass:[self class]])
    {
        return;
    }
    
    FriendActionType tType = [[notification.userInfo objectForKey:kRelationActionSuccessNotificationActionTypeKey] intValue];
    if(tType == FriendActionTypeFollow || tType == FriendActionTypeUnfollow)
    {
        NSString *userID = [notification.userInfo objectForKey:kRelationActionSuccessNotificationUserIDKey];
        NSMutableDictionary *param = [NSMutableDictionary dictionary];
        [param setValue:tType == FriendActionTypeFollow ? @1 : @0 forKey:@"status"];
        [param setValue:userID forKey:@"id"];
        [param setValue:@"user_action" forKey:@"type"];
        [self.engine ttr_fireEvent:@"page_state_change" data:param];
    }
}

//- (void)forumLikeStatusChangedNotification:(NSNotification*)notification
//{
//    //    if(![self isAuthorizedForEvent:@"page_state_change"] && ![self isInnerDomain])
//    //    {
//    //        return;
//    //    }
//
//    //忽略从js bridge抛出的通知
//    if (notification.object == self)
//    {
//        return;
//    }
//
//    NSString *forumID = [notification.userInfo objectForKey:kForumLikeStatusChangeForumIDKey];
//    NSNumber *liked = [notification.userInfo objectForKey:kForumLikeStatusChangeForumLikeKey];
//    NSMutableDictionary *param = [NSMutableDictionary dictionary];
//    [param setValue:forumID forKey:@"id"];
//    [param setValue:liked forKey:@"status"];
//    [param setValue:@"forum_action" forKey:@"type"];
//    [self.engine ttr_fireEvent:@"page_state_change" data:param];
//}

//- (void)concernCareStatusChangedNotification:(NSNotification *)notification {
//    //    if(![self isAuthorizedForEvent:@"page_state_change"] && ![self isInnerDomain])
//    //    {
//    //        return;
//    //    }
//    
//    //忽略从js bridge抛出的通知
//    if (notification.object == self)
//    {
//        return;
//    }
//    NSString *concernID = [notification.userInfo objectForKey:FRConcernEntityCareStateChangeConcernIDKey];
//    NSNumber *careState = [notification.userInfo objectForKey:FRConcernEntityCareStateChangeConcernStateKey];
//    NSMutableDictionary *param = [NSMutableDictionary dictionary];
//    [param setValue:concernID forKey:@"id"];
//    [param setValue:careState forKey:@"status"];
//    [param setValue:@"concern_action" forKey:@"type"];
//    [self.engine ttr_fireEvent:@"page_state_change" data:param];
//}

- (void)pgcArticleDonateFinishedNotification:(NSNotification *)notification {
    //    if(![self isAuthorizedForEvent:@"page_state_change"] && ![self isInnerDomain])
    //    {
    //        return;
    //    }
    
    //忽略从js bridge抛出的通知
    if (notification.object == self) {
        return;
    }
    
    NSDictionary *params = @{@"type":   notification.userInfo[@"type"],
                             @"id":     notification.userInfo[@"id"],
                             @"status": notification.userInfo[@"status"]
                             };
    
    [self.engine ttr_fireEvent:@"page_state_change" data:params];
}

- (void)blockUnblockUserNotification:(NSNotification *)notification
{
    //    if(![self isAuthorizedForEvent:@"page_state_change"] && ![self isInnerDomain])
    //    {
    //        return;
    //    }
    
    //忽略从js bridge抛出的通知
    if (notification.object == self) {
        return;
    }
    
    NSDictionary * userInfo = [notification userInfo];
    NSString * userID = [userInfo valueForKey:kBlockedUnblockedUserIDKey];
    NSNumber *isBlocking = [userInfo valueForKey:kIsBlockingKey];
    
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    [param setValue:userID forKey:@"id"];
    [param setValue:isBlocking forKey:@"status"];
    [param setValue:@"block_action" forKey:@"type"];
    
    [self.engine ttr_fireEvent:@"page_state_change" data:param];
}

#pragma mark - WDQuestionServiceProtocol

- (void)questionStatusChangedWithQId:(NSString *)qid
                          actionType:(WDQuestionActionType)actionType
                               error:(NSError *)error {
    if (!error) {
        if (!isEmptyString(qid)) {
            if (actionType == WDQuestionActionTypeDelete) {
                NSMutableDictionary *param = [NSMutableDictionary dictionary];
                [param setValue:qid forKey:@"id"];
                [param setValue:@"delete_question" forKey:@"type"];
                [self.engine ttr_fireEvent:@"page_state_change" data:[param copy]];
            }
        }
    }
}

- (void)draftNeedRefreshNotification:(NSNotification *)notification
{
    if (notification.object == self) {
        return;
    }
    
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    [param setValue:@"refresh_answer_draft" forKey:@"type"];
    [self.engine ttr_fireEvent:@"page_state_change" data:[param copy]];
}

#pragma mark - WDAnswerServiceProtocol

- (void)answerStatusChangedWithAnsId:(NSString *)ansId
                          actionType:(WDAnswerActionType)actionType
                               error:(NSError *)error {
    if (!error) {
        if (!isEmptyString(ansId)) {
            if (actionType == WDAnswerActionTypeDelete) {
                NSMutableDictionary *param = [NSMutableDictionary dictionary];
                [param setValue:ansId forKey:@"id"];
                [param setValue:@"delete_answer" forKey:@"type"];
                [self.engine ttr_fireEvent:@"page_state_change" data:[param copy]];
            }
            else if (actionType == WDAnswerActionTypePost || actionType == WDAnswerActionTypeEdit) {
                NSMutableDictionary *param = [NSMutableDictionary dictionary];
                [param setValue:@"refresh_answer" forKey:@"type"];
                [self.engine ttr_fireEvent:@"page_state_change" data:[param copy]];
            }
            else if (actionType == WDAnswerActionTypeDigg) {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    NSMutableDictionary *param = [NSMutableDictionary dictionary];
                    [param setValue:@"refresh_answer" forKey:@"type"];
                    [self.engine ttr_fireEvent:@"page_state_change" data:[param copy]];
                });
            }
        }
    }
}

- (void)questionFollowStatusNotification:(NSNotification *)notification
{
    if (notification.object == self) {
        return;
    }
    
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    [param setValue:@"question_follow_status" forKey:@"type"];
    NSDictionary *userInfoDictionary = [notification userInfo];
    if (!SSIsEmptyDictionary(userInfoDictionary)) {
        [param setValuesForKeysWithDictionary:userInfoDictionary];
    }
    [self.engine ttr_fireEvent:@"page_state_change" data:[param copy]];
}

- (void)draftHasDeletedNotification:(NSNotification *)notification
{
    if (notification.object == self) {
        return;
    }
    
    NSDictionary *userInfoDictionary = [notification userInfo];
    NSString *qid = userInfoDictionary[@"qid"];
    if (!isEmptyString(qid)) {
        NSMutableDictionary *param = [NSMutableDictionary dictionary];
        [param setValue:qid forKey:@"id"];
        [param setValue:@"answer_draft_delete" forKey:@"type"];
        [self.engine ttr_fireEvent:@"page_state_change" data:[param copy]];
    }
}

#pragma mark - TTAccountMulticastProtocol

- (void)onAccountStatusChanged:(TTAccountStatusChangedReasonType)reasonType platform:(NSString *)platformName
{
    //忽略从js bridge抛出的通知
    BOOL login = [TTAccountManager isLogin];
    if (login) {
        [self.engine ttr_fireEvent:@"login" data:@{@"code":@1}];
    } else {
        [self.engine ttr_fireEvent:@"logout" data:@{@"code":@1}];
    }
}

@end
