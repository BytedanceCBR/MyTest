//
//  TTPostThreadBridge.m
//  TTPostImage
//
//  Created by SongChai on 2018/5/18.
//

#import "TTPostThreadBridge.h"
#import "TTPostThreadKitchenConfig.h"
#import "TTPostThreadCenter.h"
#import "TTPostThreadManager.h"

#import <TTMonitor/TTMonitor.h>
#import <TTUGCFoundation/FRApiModel.h>
#import <TTBaseLib/TTBaseMacro.h>
#import <TTPlatformBaseLib/TTTrackerWrapper.h>
#import <TTBaseLib/NetworkUtilities.h>
#import "TTUGCEmojiParser.h"
#import <TTUIWidget/TTIndicatorView.h>
#import <TTThemed/UIImage+TTThemeExtension.h>
#import <TTBaseLib/NSDictionary+TTAdditions.h>
//#import <TTServiceProtocols/TTAccountProvider.h>
#import <TTServiceKit/TTServiceCenter.h>
//#import <BDMobileRuntime/BDMobileRuntime.h>
//#import <TTRegistry/TTRegistryDefines.h>
#import <TTUGCFoundation/TTUGCHashtagModel.h>
#import <TTBaseLib/JSONAdditions.h>
#import <Heimdallr/HMDTTMonitor.h>
#import <TTUGCFoundation/TTUGCMonitorDefine.h>
#import "TTAccountManager.h"

#define __PodBridgeVoid(sel, func)    \
if ([self.postThreadBridgeDelegate respondsToSelector:@selector(sel)]) { [self.postThreadBridgeDelegate func];}

#define __PodBridge(sel, func)    \
if ([self.postThreadBridgeDelegate respondsToSelector:@selector(sel)]) { \
return [self.postThreadBridgeDelegate func]; \
} \
return nil; \

#define __PodBridgeBasic(sel, func)    \
if ([self.postThreadBridgeDelegate respondsToSelector:@selector(sel)]) { \
return [self.postThreadBridgeDelegate func]; \
} \
return 0; \

@implementation TTPostThreadBridge

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    static TTPostThreadBridge *instance;
    dispatch_once(&onceToken, ^{
        instance = [[TTPostThreadBridge alloc] init];
    });
    return instance;
}

- (NSDictionary *)fakeThreadDictionary:(TTPostThreadTask *)task {
    __PodBridge(fakeThreadDictionary:, fakeThreadDictionary:task);
}

- (void)showGuideViewIfNeedWithDictionary:(NSDictionary *)dict {
    __PodBridgeVoid(showGuideViewIfNeedWithDictionary:, showGuideViewIfNeedWithDictionary:dict);
}

- (NSString *)amapKey {
    __PodBridge(amapKey, amapKey)
}

- (UIViewController *)pushBindPhoneNumberWhenPostThreadWithCompletion:(void (^)(void))completionHandler {
    __PodBridge(pushBindPhoneNumberWhenPostThreadWithCompletion:, pushBindPhoneNumberWhenPostThreadWithCompletion:completionHandler);
}

- (BOOL)shouldBindPhone {
    __PodBridgeBasic(shouldBindPhone, shouldBindPhone);
}

- (void)jumpToBindPhonePageWithParams:(NSDictionary *)params {
    __PodBridgeVoid(jumpToBindPhonePageWithParams:, jumpToBindPhonePageWithParams:params);
}

- (void)showLoginAlertWithSource:(NSString *)source superView:(UIView *)view completion:(void (^)(BOOL tips))completionHandler {
    __PodBridgeVoid(showLoginAlertWithSource:superView:completion:, showLoginAlertWithSource:source superView:view completion:completionHandler);
}

- (void)presentQuickLoginFromVC:(UIViewController *)vc source:(NSString *)source {
    __PodBridgeVoid(presentQuickLoginFromVC:source:, presentQuickLoginFromVC:vc source:source);
}

- (id<TTImagePickTrackDelegate>)imagePickerTrackerWithEventName:(NSString *)eventName extraParams:(NSDictionary *)extraParams {
    __PodBridge(imagePickerTrackerWithEventName:extraParams:, imagePickerTrackerWithEventName:eventName extraParams:extraParams);
}

- (void)monitorPostThreadStatus:(TTPostThreadStatus)status extra:(NSDictionary *)extra retry:(BOOL)retry {
     [[TTMonitor shareManager] trackService:retry? @"ugc_thread_post_retry": @"ugc_thread_post" status:status extra:extra];
}

- (void)monitorShareSDKParamsSerializationFailureWithExtra:(NSDictionary *)extra {
    [[TTMonitor shareManager] trackService:@"weitoutiao_share_params_serialization_failure" attributes:extra];
}

- (void)trackRepostWithEvent:(NSString *)event label:(NSString *)label repostModel:(TTRepostThreadModel *)repostModel extra:(NSDictionary *)extra {
//    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
//    [dictionary addEntriesFromDictionary:extra];
//    
//    if (repostModel.opt_id_type == FRUGCTypeCodeCOMMENT) {
//        [dictionary setValue:repostModel.opt_id forKey:@"comment_id"];
//    }
//    
//    if (repostModel.opt_id_type == FRUGCTypeCodeCOMMENT) {
//        [dictionary setValue:repostModel.fw_id forKey:@"value"];
//    } else if (repostModel.repost_type == TTThreadRepostTypeArticle) {
//        [dictionary setValue:repostModel.group_id forKey:@"value"];
//    } else {
//        if (!isEmptyString(repostModel.fw_id)) {
//            [dictionary setValue:repostModel.fw_id forKey:@"value"];
//        } else {
//            [dictionary setValue:@(0) forKey:@"value"];;
//        }
//        
//    }
//    [dictionary setValue:@"umeng" forKey:@"category"];
//    [dictionary setValue:event forKey:@"tag"];
//    [dictionary setValue:label forKey:@"label"];
//    [TTTrackerWrapper eventData:dictionary];
}

- (void)trackRepostV3WithEvent:(NSString *)event repostModel:(TTRepostThreadModel *)repostModel extra:(NSDictionary *)extra {
//    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
//    if (extra) {
//        [dictionary addEntriesFromDictionary:extra];
//    }
//
//    if (repostModel.opt_id_type == FRUGCTypeCodeCOMMENT) {
//        [dictionary setValue:repostModel.fw_id forKey:@"group_id"];
//    } else if (repostModel.repost_type == TTThreadRepostTypeArticle) {
//        [dictionary setValue:repostModel.group_id forKey:@"group_id"];
//    } else {
//        if (!isEmptyString(repostModel.fw_id)) {
//            [dictionary setValue:repostModel.fw_id forKey:@"group_id"];
//        } else {
//            [dictionary setValue:@(0) forKey:@"group_id"];;
//        }
//    }
//
//    [TTTrackerWrapper eventV3:event params:[dictionary copy]];
}


- (void)sendRepostWithRepostModel:(TTRepostThreadModel *)repostModel
                     richSpanText:(TTRichSpanText *)richSpanText
                  isCommentRepost:(BOOL)isCommentRepost
               baseViewController:(UIViewController *)baseViewController
                        trackDict:(NSDictionary *)trackDict
                      finishBlock:(void (^)(void))finishBlock {
    
    NSString *cid = KTTFollowPageConcernID;
    if (!TTNetworkConnected()) {
        [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage
                                  indicatorText:NSLocalizedString(@"没有网络连接", nil)
                                 indicatorImage:[UIImage themedImageNamed:@"close_popup_textpage"]
                                    autoDismiss:YES
                                 dismissHandler:nil];
        
        return ;
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ForumPostThreadFinish" object:nil userInfo:@{@"cid" : cid}];
    
    if (![TTAccountManager isLogin]) {
        WeakSelf;
        [[TTPostThreadBridge sharedInstance] showLoginAlertWithSource:@"repost_publish" superView:baseViewController.navigationController.view completion:^(BOOL tips) {
            StrongSelf;
            if (tips) {
                [[TTPostThreadBridge sharedInstance] presentQuickLoginFromVC:baseViewController
                                                                                source:@"repost_publish"];
            } else {
                [self loginedStateSendRepostWithRepostModel:repostModel
                                               richSpanText:richSpanText
                                            isCommentRepost:isCommentRepost
                                         baseViewController:baseViewController
                                                  trackDict:trackDict
                                                finishBlock:finishBlock];
            }
        }];
    } else {
        [self loginedStateSendRepostWithRepostModel:repostModel
                                       richSpanText:richSpanText
                                    isCommentRepost:isCommentRepost
                                 baseViewController:baseViewController
                                          trackDict:trackDict
                                        finishBlock:finishBlock];
    }
}

- (void)loginedStateSendRepostWithRepostModel:(TTRepostThreadModel *)repostModel
                                 richSpanText:(TTRichSpanText *)richSpanText
                              isCommentRepost:(BOOL)isCommentRepost
                           baseViewController:(UIViewController *)baseViewController
                                    trackDict:(NSDictionary *)trackDict
                                  finishBlock:(void (^)(void))finishBlock {
    if (self && [TTAccountManager isLogin]) {
        
        NSMutableDictionary *userInfoDic = [[NSMutableDictionary alloc] init];
//        [userInfoDic setValue:repostModel.opt_id forKey:@"opt_id"];
//        [userInfoDic setValue:@(repostModel.opt_id_type) forKey:@"opt_id_type"];
//        [userInfoDic setValue:repostModel.fw_id forKey:@"fw_id"];
//        [userInfoDic setValue:@(repostModel.fw_id_type) forKey:@"fw_id_type"];
//        [userInfoDic setValue:@(repostModel.repost_type) forKey:@"repost_type"];
        
        if ([TTKitchen getBOOL:kTTKCommonUgcPostBindingPhoneNumberKey]) {
            
            baseViewController.view.userInteractionEnabled = NO;
            TTIndicatorView *checkBoundPhoneIndicatorView = [[TTIndicatorView alloc] initWithIndicatorStyle:TTIndicatorViewStyleWaitingView
                                                                                              indicatorText:@"发布中..."
                                                                                             indicatorImage:nil
                                                                                             dismissHandler:nil];
            checkBoundPhoneIndicatorView.autoDismiss = NO;
            [checkBoundPhoneIndicatorView showFromParentView:baseViewController.view];
            
            [TTPostThreadManager checkPostNeedBindPhoneOrNotWithCompletion:^(FRPostBindCheckType checkType) {
                
                [checkBoundPhoneIndicatorView dismissFromParentView];
                baseViewController.view.userInteractionEnabled = YES;
                
                if (checkType == FRPostBindCheckTypePostBindCheckTypeNeed) {
                    WeakSelf;
                    UIViewController *bindViewController = [[TTPostThreadBridge sharedInstance] pushBindPhoneNumberWhenPostThreadWithCompletion:^{
                        StrongSelf;
                        [self postContentWithInputText:repostModel
                                          richSpanText:richSpanText
                                       isCommentRepost:isCommentRepost
                                             trackDict:trackDict
                                           finishBlock:finishBlock];
                    }];
                    if (!bindViewController) {
                        [[NSNotificationCenter defaultCenter] postNotificationName:kkRepostActionNotificationKey object:self userInfo:userInfoDic];
                        [self postContentWithInputText:repostModel
                                          richSpanText:richSpanText
                                       isCommentRepost:isCommentRepost
                                             trackDict:trackDict
                                           finishBlock:finishBlock];
                    } else {
                        if ([baseViewController.navigationController isKindOfClass:[UINavigationController class]]) {
                            [baseViewController.navigationController pushViewController:bindViewController animated:YES];
                        }
                    }
                } else {
                    [[NSNotificationCenter defaultCenter] postNotificationName:kkRepostActionNotificationKey object:self userInfo:userInfoDic];
                    [self postContentWithInputText:repostModel
                                      richSpanText:richSpanText
                                   isCommentRepost:isCommentRepost
                                         trackDict:trackDict
                                       finishBlock:finishBlock];
                }
            }];
        } else {
            [[NSNotificationCenter defaultCenter] postNotificationName:kkRepostActionNotificationKey object:self userInfo:userInfoDic];
            [self postContentWithInputText:repostModel
                              richSpanText:richSpanText
                           isCommentRepost:isCommentRepost
                                 trackDict:trackDict
                               finishBlock:finishBlock];
        }
    }
}

- (void)postContentWithInputText:(TTRepostThreadModel *)repostModel
                    richSpanText:(TTRichSpanText *)richSpanText
                 isCommentRepost:(BOOL)isCommentRepost
                       trackDict:(NSDictionary *)trackDict
                     finishBlock:(void(^)(void))finishBlock {
    [[HMDTTMonitor defaultManager] hmdTrackService:kTTUGCPublishBehaviorMonitor metric:nil category:@{@"status" : @(kTTBehaviorFunnelStart)} extra:@{kTTUGCMonitorType : kTTPostBehaviorTypeRepost}];

    NSMutableArray *mentionUsers = [NSMutableArray arrayWithCapacity:richSpanText.richSpans.links.count];
    for (TTRichSpanLink *link in richSpanText.richSpans.links) {
        NSString *userId = [link.userInfo tt_stringValueForKey:@"user_id"];
        if (!isEmptyString(userId)) {
            [mentionUsers addObject:userId];
        }
    }
    
    NSMutableArray *mentionConcerns = [NSMutableArray arrayWithCapacity:richSpanText.richSpans.links.count];
    NSMutableArray *hashtagNames = [NSMutableArray arrayWithCapacity:richSpanText.richSpans.links.count];
    NSMutableArray *forumNames = [NSMutableArray arrayWithCapacity:richSpanText.richSpans.links.count];
    for (TTRichSpanLink *link in richSpanText.richSpans.links) {
        if ([link.link isEqualToString:TTUGCSelfCreateHashtagLinkURLString]) {
            NSString *forumName = [link.userInfo tt_stringValueForKey:@"forum_name"];
            if (!isEmptyString(forumName)) {
                [forumNames addObject:forumName];
            }
        } else {
            NSString *concernId = [link.userInfo tt_stringValueForKey:@"concern_id"];
            if (!isEmptyString(concernId)) {
                [mentionConcerns addObject:concernId];
            }

            NSString *forumName = [link.userInfo tt_stringValueForKey:@"forum_name"];
            if (!isEmptyString(forumName)) {
                [hashtagNames addObject:forumName];
            }
        }
    }
    
    NSDictionary *trackDic = [@{
                                @"is_forward": @(0),
                                @"at_user_id" : [mentionUsers componentsJoinedByString:@","] ?: @"",
                                @"hashtag_name" : [hashtagNames componentsJoinedByString:@","] ?: @""
                                } copy];
    NSMutableDictionary *trackExtra = [[NSMutableDictionary alloc] initWithDictionary:trackDic];
    [trackExtra addEntriesFromDictionary:trackDict];
    [self trackRepostV3WithEvent:@"repost_publish_done" repostModel:repostModel extra:trackExtra];
    
    NSDictionary <NSString *, NSString *> *emojis = [TTUGCEmojiParser parseEmojis:richSpanText.text];
    [TTUGCEmojiParser markEmojisAsUsed:emojis];
    NSArray <NSString *> *emojiIds = emojis.allKeys;
    // 去掉links中fake的自建话题
    TTRichSpans *richSpans = richSpanText.richSpans;
    if (!SSIsEmptyArray(forumNames)) {
        NSMutableArray<TTRichSpanLink *> *links = [NSMutableArray arrayWithCapacity:richSpans.links.count];
        [richSpans.links enumerateObjectsUsingBlock:^(TTRichSpanLink * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (![obj.link isEqualToString:TTUGCSelfCreateHashtagLinkURLString]) {
                [links addObject:obj];
            }
        }];
        richSpans = [[TTRichSpans alloc] initWithRichSpanLinks:[links copy] imageInfoModelsDict:richSpans.imageInfoModesDict];
    }

//    repostModel.content_rich_span = [TTRichSpans JSONStringForRichSpans:richSpans];
//    repostModel.content = richSpanText.text;
//    repostModel.mentionUsers = [mentionUsers componentsJoinedByString:@","];
//    repostModel.mentionConcerns = [mentionConcerns componentsJoinedByString:@","];
//    repostModel.repostToComment = isCommentRepost;
//    repostModel.forumNames = [forumNames tt_JSONRepresentation];
    
    [[TTPostThreadCenter sharedInstance_tt] repostWithRepostThreadModel:repostModel withConcernID:KTTFollowPageConcernID withCategoryID:kTTWeitoutiaoCategoryID refer:1 extraTrack:nil finishBlock:^{
        if (finishBlock) {
            finishBlock();
        }
    }];
}

@end
