//
//  TTNewDetailWebviewContainer+JSBridge.m
//  Article
//
//  Created by muhuai on 02/03/2017.
//
//

#import "TTArticleDetailView+JSBridge.h"
#import <TTAccountBusiness.h>
#import "FriendDataManager.h"

#import <TTBaseLib/TTUIResponderHelper.h>
#import <TTEntry/ExploreEntryManager.h>
//#import "TTRedPacketManager.h"

@implementation TTArticleDetailView(JSBridge)
#pragma mark 订阅的JSBridge

- (void)registerJSBridge {
    
    //订阅
    __weak typeof(self) wself = self;
    [self.detailWebView.webView.ttr_staticPlugin registerHandlerBlock:^(NSDictionary *result, TTRJSBResponse callback) {
        
        TTAccountLoginAlertTitleType type = TTAccountLoginAlertTitleTypePGCLike;
        NSString *source = @"article_detail_pgc_like";
        NSInteger subscribeCount = [SSCommonLogic subscribeCount];
        
        if ([SSCommonLogic detailActionType] == 0) {
            // 策略0: 不需要登录
            // 订阅操作都会正常进行,进行订阅操作
            [wself subscribe:result subscribeJSCallback:callback];
        } else if ([SSCommonLogic detailActionType] == 1) {
            // 策略1: 强制登录，需要客户端判断用户的登录状态
            if ([TTAccountManager isLogin]) {
                // 如果用户已经登录，不出现弹窗，订阅操作会正常进行
                [wself subscribe:result subscribeJSCallback:callback];
            } else if (![TTAccountManager isLogin]) {
                // 用户处于未登录状态，需要进行强制登录，用户不登录的话无法使用后续功能
                [TTAccountManager showLoginAlertWithType:type source:source completion:^(TTAccountAlertCompletionEventType type, NSString *phoneNum) {
                    if (type == TTAccountAlertCompletionEventTypeDone) {
                        // 如果登录成功，后续功能会照常进行
                        // 进行订阅操作
                        [wself subscribe:result subscribeJSCallback:callback];
                    } else if (type == TTAccountAlertCompletionEventTypeTip) {
                        [TTAccountManager presentQuickLoginFromVC:[TTUIResponderHelper topNavigationControllerFor:wself] type:TTAccountLoginDialogTitleTypeDefault source:source subscribeCompletion:^(TTAccountLoginState state) {
                            if (state == TTAccountLoginStateLogin) {
                                // 如果登录成功，则进行订阅过程
//                                [wself subscribe:result subscribeJSCallbackID:subscribeJSCallbackID];
                            }
                        }];
                    }
                }];
            }
        } else if ([SSCommonLogic detailActionType] == 2) {
            // 策略2: 非强制登录，需要客户端判断用户的登录状态
            if ([TTAccountManager isLogin]) {
                // 如果用户已登录，不出现弹窗，订阅操作会正常进行
                [wself subscribe:result subscribeJSCallback:callback];
            } else if (![TTAccountManager isLogin]) {
                // 用户处于未登录状态，进行非强制登录弹窗
                // 非强制登录的逻辑，根据当前文章详情页的点击订阅的次数进行弹窗判断的逻辑
                // 得到当前文章详情页的点击订阅的次数，进行判断
                subscribeCount++;
                BOOL countEqual = NO;
                for (NSNumber *tmp in [SSCommonLogic detailActionTick]) {
                    if (subscribeCount == tmp.integerValue) {
                        countEqual = YES;
                        // 如果等于某次非强制登录弹窗的次数，则进行弹窗
                        [TTAccountManager showLoginAlertWithType:type source:source completion:^(TTAccountAlertCompletionEventType type, NSString *phoneNum) {
                            if (type == TTAccountAlertCompletionEventTypeDone) {
                                // 显示弹窗后，才进行订阅过程
                                [wself subscribe:result subscribeJSCallback:callback];
                            } else if (type == TTAccountAlertCompletionEventTypeCancel) {
                                // 显示弹窗后，才进行订阅过程
                                [wself subscribe:result subscribeJSCallback:callback];
                            } else if (type == TTAccountAlertCompletionEventTypeTip) {
                                [TTAccountManager presentQuickLoginFromVC:[TTUIResponderHelper topNavigationControllerFor:wself] type:TTAccountLoginDialogTitleTypeDefault source:source subscribeCompletion:^(TTAccountLoginState state) {
                                    if (state == TTAccountLoginStateLogin) {
                                        // 如果登录成功，则进行订阅过程
//                                        [wself subscribe:result subscribeJSCallbackID:subscribeJSCallbackID];
                                    } else if (state == TTAccountLoginStateCancelled) {
                                        // 显示弹窗后，才进行订阅过程
                                        [wself subscribe:result subscribeJSCallback:callback];
                                    }
                                }];
                            }
                        }];
                        // 找到相等次数时，break跳出循环
                        break;
                    }
                }
                if (!countEqual) {
                    // 如果不是符合的次数，则直接进行订阅操作过程
                    [wself subscribe:result subscribeJSCallback:callback];
                }
            }
        }
        // 将点击订阅数持久化进NSUSerDefaults
        [SSCommonLogic setSubscribeCount:subscribeCount];
    } forMethodName:@"do_media_like"];
    
    
    //取消订阅
    [self.detailWebView.webView.ttr_staticPlugin registerHandlerBlock:^(NSDictionary *result, TTRJSBResponse callback) {
        
        ExploreEntry *entry = nil;
        NSArray *entries = nil;
        NSString *entryID = [result stringValueForKey:@"id" defaultValue:nil];
        NSString *uid = [result stringValueForKey: @"uid" defaultValue:nil];
        
        if (!isEmptyString(entryID)) {
            entries = [[ExploreEntryManager sharedManager] entryForEntryIDs:@[entryID]];
        }
        
        if(entries.count > 0) {
            entry = entries[0];
        }
        else if (!isEmptyString(entryID)) {
            NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
            [dic setValue:entryID forKey:@"id"];
            [dic setValue:@1 forKey:@"type"];
            [dic setValue:@1 forKey:@"subscribed"];
            [dic setValue:[NSNumber numberWithLongLong:entryID.longLongValue] forKey:@"media_id"];
            [dic setValue:entryID forKey:@"entry_id"];
            [dic setValue:uid forKey:@"user_id"];
            
            entry = [[ExploreEntryManager sharedManager] insertExploreEntry:dic save:YES];
        }
        
        //        NSString *userID = self.detailModel.article.mediaUserID;
        NSMutableDictionary *followDic = [NSMutableDictionary dictionary];
        [followDic setValue:uid forKey:@"id"];
        [followDic setValue:@(32) forKey:@"new_reason"]; // FriendFollowNewReasonUnknown
        [followDic setValue:@(TTFollowNewSourceNewsDetail) forKey:@"new_source"];
        
        //        [[ExploreEntryManager sharedManager] exploreEntry:entry
        //                                       changeToSubscribed:NO
        //                                                   notify:YES
        //                                        notifyFinishBlock:^(ExploreEntry * _Nullable entry, NSError * _Nullable error) {
        if (!TTNetworkConnected()) {
            [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage
                                      indicatorText:@"网络不给力，请稍后重试"
                                     indicatorImage:[UIImage themedImageNamed:@"close_popup_textpage"]
                                        autoDismiss:YES
                                     dismissHandler:nil];
            if (callback) {
                callback(TTRJSBMsgFailed, @{@"code":@(0)});
            }
        }
        
        [[TTFollowManager sharedManager] unfollow:followDic completion:^(NSError * _Nullable error, NSDictionary * _Nullable result) {
            if (!wself) {
                return;
            }
            //失败提示
            if (error) {
                if (error.code != TTNetworkErrorCodeNoNetwork) {
                    NSString *hint = [[[result tt_dictionaryValueForKey:@"result"] tt_dictionaryValueForKey:@"data"] tt_stringValueForKey:@"description"];
                    if (isEmptyString(hint)) {
                        hint = @"取消关注失败";
                    }
                    [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:hint indicatorImage:[UIImage themedImageNamed:@"close_popup_textpage"] autoDismiss:YES dismissHandler:nil];
                }else {
                    [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage
                                              indicatorText:@"网络不给力，请稍后重试"
                                             indicatorImage:[UIImage themedImageNamed:@"close_popup_textpage"]
                                                autoDismiss:YES
                                             dismissHandler:nil];
                }
                if (callback) {
                    callback(TTRJSBMsgFailed, @{@"code":@(0)});
                }
                
                return ;
            }
            
            [wself subscribeAction:NO withPGCID:entryID];
            
            TTR_CALLBACK_SUCCESS
        }];
        
    } forMethodName:@"do_media_unlike"];
}

// 订阅操作
- (void)subscribe:(NSDictionary *)result subscribeJSCallback:(TTRJSBResponse)callback {
    __weak typeof(self) wself = self;
    ExploreEntry *entry = nil;
    NSArray *entries = nil;
    NSString *entryID = [result stringValueForKey:@"id" defaultValue:nil];
    NSString *uid = [result stringValueForKey: @"uid" defaultValue:nil];
    
    if (!isEmptyString(entryID)) {
        entries = [[ExploreEntryManager sharedManager] entryForEntryIDs:@[entryID]];
    }
    
    if(entries.count > 0)
    {
        entry = entries[0];
    }
    else if (!isEmptyString(entryID)) {
        NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
        [dic setValue:entryID forKey:@"id"];
        [dic setValue:@1 forKey:@"type"];
        [dic setValue:@0 forKey:@"subscribed"];
        [dic setValue:[NSNumber numberWithLongLong:entryID.longLongValue] forKey:@"media_id"];
        [dic setValue:entryID forKey:@"entry_id"];
        [dic setValue:uid forKey:@"user_id"];
        entry = [[ExploreEntryManager sharedManager] insertExploreEntry:dic save:YES];
    }
    
    //    NSString *userID = self.detailModel.article.mediaUserID;
    NSMutableDictionary *followDic = [NSMutableDictionary dictionary];
    [followDic setValue:uid forKey:@"id"];
    [followDic setValue:@(32) forKey:@"new_reason"]; // FriendFollowNewReasonUnknown
//    [followDic setValue:@([wself followNewSource]) forKey:@"new_source"];

    //    [[ExploreEntryManager sharedManager] exploreEntry:entry
    //                                   changeToSubscribed:YES
    //                                               notify:YES
    //                                    notifyFinishBlock:^(ExploreEntry * _Nullable entry, NSError * _Nullable error) {
    
    if (!TTNetworkConnected()) {
        [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage
                                  indicatorText:@"网络不给力，请稍后重试"
                                 indicatorImage:[UIImage themedImageNamed:@"close_popup_textpage"]
                                    autoDismiss:YES
                                 dismissHandler:nil];
        if (callback) {
            callback(TTRJSBMsgFailed, @{@"code":@(0)});
        }
        return;
    }
    
    [[TTFollowManager sharedManager] follow:followDic completion:^(NSError * _Nullable error, NSDictionary * _Nullable result) {
        if (!wself) {
            if (callback) {
                callback(TTRJSBMsgFailed, @{@"code":@(0)});
            }
            return;
        }
        //失败提示
        if (error) {
            
            if (error.code != TTNetworkErrorCodeNoNetwork) {
                NSString *hint = [[[result tt_dictionaryValueForKey:@"result"] tt_dictionaryValueForKey:@"data"] tt_stringValueForKey:@"description"];
                if (isEmptyString(hint)) {
                    hint = @"关注失败";
                }
                [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:hint indicatorImage:[UIImage themedImageNamed:@"close_popup_textpage"] autoDismiss:YES dismissHandler:nil];
            }
            if (callback) {
                callback(TTRJSBMsgFailed, @{@"code":@(0)});
            }
            return ;
        }
        
        [wself subscribeAction:YES withPGCID:entryID];
            
        BOOL showToast = YES;
//        if ([TTFirstConcernManager firstTimeGuideEnabled]) {
//            showToast = NO;
//            TTFirstConcernManager *manager = [[TTFirstConcernManager alloc] init];
//            [manager showFirstConcernAlertViewWithDismissBlock:nil];
//        }
        
        if (callback) {
            callback(TTRJSBMsgSuccess, @{@"code":@(1),
                                         @"showToast":@(showToast)});
        }
    }];
}

- (void)p_sendSubscribeTrackWithLabel:(NSString *)label concernType:(NSString *)concernType
{
    NSMutableDictionary *dict = nil;
    if (!isEmptyString(self.detailModel.article.itemID)) {
        dict = [NSMutableDictionary dictionary];
        [dict setValue:self.detailModel.article.itemID forKey:@"item_id"];
        [dict setValue:concernType forKey:@"concern_type"];
    }
    
    wrapperTrackEventWithCustomKeys(@"detail", label, [NSString stringWithFormat:@"%@", self.detailModel.article.mediaInfo[@"media_id"]], nil, dict);
}

//- (TTFollowNewSource)followNewSource {
//    if (self.infoManager.activity.redpack) {
//        return TTFollowNewSourceNewsDetailRedPacket;
//    }else {
//        return TTFollowNewSourceNewsDetail;
//    }
//}

- (void)subscribeAction:(BOOL)isSubscribed withPGCID:(nullable NSString*)PGCID  {
    if ([[self.detailModel.article.mediaInfo tt_stringValueForKey:@"media_id"] isEqualToString:PGCID]) {
//        if (isSubscribed && self.infoManager.activity.redpack) {
//            TTRedPacketTrackModel * redPacketTrackModel = [TTRedPacketTrackModel new];
//            redPacketTrackModel.userId = self.detailModel.article.userIDForAction;
//            redPacketTrackModel.mediaId = [self.detailModel.article.mediaInfo tt_stringValueForKey:@"media_id"];
//            redPacketTrackModel.categoryName = self.detailModel.categoryID;
//            redPacketTrackModel.source = @"article_detail";
//            redPacketTrackModel.position = @"title_below";
//            [[TTRedPacketManager sharedManager] presentRedPacketWithRedpacket:self.infoManager.activity.redpack
//                                                                       source:redPacketTrackModel
//                                                               viewController:[TTUIResponderHelper topViewControllerFor:self]];
//            self.infoManager.activity.redpack = nil;
//        }
        
    }
}
@end
