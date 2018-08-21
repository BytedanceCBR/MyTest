//
//  TTRepostService.m
//  Article
//
//  Created by ranny_90 on 2017/9/12.
//
//

#import <TTUGCFoundation/UGCRepostCommonModel.h>
#import "TTRepostService.h"
#import "TTWebImageManager.h"
#import "Article.h"
#import "TTKitchenHeader.h"
#import "TTRepostOriginModels.h"
#import <TTShortVideoModel.h>
#import <WDAnswerEntity.h>
#import "TTRepostContentSegment.h"

#import <TTCategoryDefine.h>
#import <NetworkUtilities.h>
#import <TTIndicatorView.h>
#import <TTUGCDefine.h>
#import <TTAccountManager.h>
#import <TTUGCEmojiParser.h>
#import <TTModuleBridge.h>

#import "TTRepostThreadModel.h"
#import "TTRepostViewController.h"
//#import "ArticlePostMomentViewController.h"
//#import "ArticleMobileViewController.h"
#import "TTPostCheckBindPhoneViewModel.h"
//#import "ArticleMobileNumberViewController.h"
#import "TTForumPostThreadCenter.h"
#import "TTUGCPodBridge.h"

extern unsigned int g_postMomentMaxCharactersLimit;


@implementation TTRepostService

+ (instancetype)sharedInstance {
    static TTRepostService *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[TTRepostService alloc] init];
    });
    
    return instance;
}

+ (void)showRepostVCWithRepostParams:(NSDictionary *)repostParams {
    [[TTRepostService sharedInstance] showRepostVCWithRepostParams:repostParams];
}



+ (void)directSendRepostWithRepostParams:(NSDictionary *)repostParams
                      baseViewController:(UIViewController *)baseViewController
                               trackDict:(NSDictionary *)trackDict {
    [[TTRepostService sharedInstance] directSendRepostWithRepostParams:repostParams
                                                    baseViewController:baseViewController
                                                             trackDict:trackDict];
}



#pragma mark - 原外部调用方法

+ (NSDictionary *)repostParamsWithRepostType:(TTThreadRepostType)repostType
                               originArticle:(TTRepostOriginArticle *)originArticle
                                originThread:(TTRepostOriginThread *)originThread
                originShortVideoOriginalData:(TTRepostOriginShortVideoOriginalData *)originShortVideoOriginalData
                           originWendaAnswer:(TTRepostOriginTTWendaAnswer *)originWendaAnswer
                           operationItemType:(TTRepostOperationItemType)operationItemType
                             operationItemID:(NSString *)operationItemID
                              repostSegments:(NSArray<TTRepostContentSegment *> *)segments {
    
    return [[TTRepostService sharedInstance] repostParamsWithRepostType:repostType
                                                          originArticle:originArticle
                                                           originThread:originThread
                                           originShortVideoOriginalData:originShortVideoOriginalData
                                                      originWendaAnswer:originWendaAnswer
                                                      operationItemType:operationItemType
                                                        operationItemID:operationItemID
                                                         repostSegments:segments];
}

+ (void)repostAdapterWithRepostType:(TTThreadRepostType)repostType
                      originArticle:(TTRepostOriginArticle *)originArticle
                       originThread:(TTRepostOriginThread *)originThread
       originShortVideoOriginalData:(TTRepostOriginShortVideoOriginalData *)originShortVideoOriginalData
                  originWendaAnswer:(TTRepostOriginTTWendaAnswer *)originWendaAnswer
                  operationItemType:(TTRepostOperationItemType)operationItemType
                    operationItemID:(NSString *)operationItemID
                     repostSegments:(NSArray<TTRepostContentSegment *> *)segments {

    [[self sharedInstance] showRepostVCWithRepostType:repostType
                                        originArticle:originArticle
                                         originThread:originThread
                         originShortVideoOriginalData:originShortVideoOriginalData
                                    originWendaAnswer:originWendaAnswer
                                    operationItemType:operationItemType
                                      operationItemID:operationItemID
                                       repostSegments:segments];
}

+ (NSString *)coverURLWithArticle:(Article *)article {
    TTImageInfosModel *thumbImage = nil;
    if ([[article middleImageDict] count] > 0) {
        thumbImage = [[TTImageInfosModel alloc] initWithDictionary:[article middleImageDict]];
    } else if ([[article largeImageDict] count] > 0) {
        thumbImage = [[TTImageInfosModel alloc] initWithDictionary:[article largeImageDict]];
    } else if ([article.videoDetailInfo tt_dictionaryValueForKey:@"detail_video_large_image"].count > 0) {
        thumbImage = [[TTImageInfosModel alloc] initWithDictionary:[article.videoDetailInfo tt_dictionaryValueForKey:@"detail_video_large_image"]];
    }
    FRImageInfoModel *infoModel = [[FRImageInfoModel alloc] initWithTTImageInfosModel:thumbImage];
    FRImageInfoModel *coverModel = [[[TTWebImageManager shareManger] sortedImageArray:infoModel.url_list] firstObject];
    NSString *url = coverModel.url;
    if (isEmptyString(url)) {
        if (!isEmptyString(article.sourceAvatar)) {
            url = article.sourceAvatar;
        } else if (!isEmptyString([article.userInfo tt_stringValueForKey:@"avatar_url"])) {
            url = [article.userInfo tt_stringValueForKey:@"avatar_url"];
        } else if (!isEmptyString([article.mediaInfo tt_stringValueForKey:@"avatar_url"])) {
            url = [article.mediaInfo tt_stringValueForKey:@"avatar_url"];
        }
    }

    return url;
}

+ (NSString *)coverURLWithThread:(Thread *)thread {
    FRImageInfoModel *thumbImage = nil;
    NSArray<FRImageInfoModel *> *thumbImageModels = [thread getThumbImageModels];
    if ([thumbImageModels count] > 0) {
        thumbImage = [thumbImageModels firstObject];
    }
    FRImageInfoModel *coverModel = [[[TTWebImageManager shareManger] sortedImageArray:thumbImage.url_list] firstObject];
    NSString *url = coverModel.url;
    if (isEmptyString(url)) {
        url = thread.avatarURL;
    }
    
    return url;
}

+ (NSString *)coverURLWithRepostCommonModel:(UGCRepostCommonModel *)repostCommonModel {
    TTImageInfosModel *thumbImage = [[TTImageInfosModel alloc] initWithDictionary:[repostCommonModel cover_image]];
    FRImageInfoModel *infoModel = [[FRImageInfoModel alloc] initWithTTImageInfosModel:thumbImage];
    FRImageInfoModel *coverModel = [[[TTWebImageManager shareManger] sortedImageArray:infoModel.url_list] firstObject];
    NSString *url = coverModel.url;

    return url;
}

+ (TTRichSpanText *)richSpanWithContent:(TTRichSpanText *)richContent user:(FRCommonUserInfoStructModel *)userInfo {
    TTRichSpanText *finalText = [[TTRichSpanText alloc] initWithText:@"" richSpans:nil];
    
    NSString *userName = [NSString stringWithFormat:@"//@%@:", userInfo.name];
    NSString *link = nil;
    if (!isEmptyString(userInfo.schema)) {
        link = userInfo.schema;
    } else {
        link = [NSString stringWithFormat:@"sslocal://profile?uid=%@", userInfo.user_id];
    }
    TTRichSpanLink *userNameRichSpanLink = [[TTRichSpanLink alloc] initWithStart:2 length:(userInfo.name.length + 1) link:link];
    TTRichSpanText *richNameRichSpanText = [[TTRichSpanText alloc] initWithText:userName richSpanLinks:@[userNameRichSpanLink]];
    [finalText appendRichSpanText:richNameRichSpanText];
    [finalText appendRichSpanText:richContent];
    
    return finalText;
}

#pragma mark - RepostViewController调用的方法

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
        [TTAccountManager showLoginAlertWithType:TTAccountLoginAlertTitleTypePost
                                          source:@"repost_publish"
                                     inSuperView:baseViewController.navigationController.view
                                      completion:^(TTAccountAlertCompletionEventType type, NSString *phoneNum) {
                                          StrongSelf;
                                          if (type == TTAccountAlertCompletionEventTypeDone) {
                                              [self loginedStateSendRepostWithRepostModel:repostModel
                                                                             richSpanText:richSpanText
                                                                          isCommentRepost:isCommentRepost
                                                                       baseViewController:baseViewController
                                                                                trackDict:trackDict
                                                                              finishBlock:finishBlock];
                                          } else if (type == TTAccountAlertCompletionEventTypeTip) {
                                              [TTAccountManager presentQuickLoginFromVC:baseViewController
                                                                                   type:TTAccountLoginDialogTitleTypeDefault
                                                                                 source:@"repost_publish"
                                                                             completion:^(TTAccountLoginState state){
                                                                                 
                                                                             }];
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
        [userInfoDic setValue:repostModel.opt_id forKey:@"opt_id"];
        [userInfoDic setValue:@(repostModel.opt_id_type) forKey:@"opt_id_type"];
        [userInfoDic setValue:repostModel.fw_id forKey:@"fw_id"];
        [userInfoDic setValue:@(repostModel.fw_id_type) forKey:@"fw_id_type"];
        [userInfoDic setValue:@(repostModel.repost_type) forKey:@"repost_type"];
        
        if ([KitchenMgr getBOOL:KSSCommonUgcPostBindingPhoneNumberKey]) {
            
            baseViewController.view.userInteractionEnabled = NO;
            TTIndicatorView *checkBoundPhoneIndicatorView = [[TTIndicatorView alloc] initWithIndicatorStyle:TTIndicatorViewStyleWaitingView
                                                                                              indicatorText:@"发布中..."
                                                                                             indicatorImage:nil
                                                                                             dismissHandler:nil];
            checkBoundPhoneIndicatorView.autoDismiss = NO;
            [checkBoundPhoneIndicatorView showFromParentView:baseViewController.view];
            
            [TTPostCheckBindPhoneViewModel checkPostNeedBindPhoneOrNotWithCompletion:^(FRPostBindCheckType checkType) {
                
                [checkBoundPhoneIndicatorView dismissFromParentView];
                baseViewController.view.userInteractionEnabled = YES;
                
                if (checkType == FRPostBindCheckTypePostBindCheckTypeNeed) {
                    WeakSelf;
                    UIViewController *bindViewController = [[TTUGCPodBridge sharedInstance] pushBindPhoneNumberWhenPostThreadWithCompletion:^{
                        StrongSelf;
                        [self postContentWithInputText:repostModel
                                          richSpanText:richSpanText
                                       isCommentRepost:isCommentRepost
                                             trackDict:trackDict
                                           finishBlock:finishBlock];
                    }];

                    if ([baseViewController.navigationController isKindOfClass:[UINavigationController class]]) {
                        [baseViewController.navigationController pushViewController:bindViewController animated:YES];
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
    NSMutableArray *mentionUsers = [NSMutableArray arrayWithCapacity:richSpanText.richSpans.links.count];
    for (TTRichSpanLink *link in richSpanText.richSpans.links) {
        NSString *userId = [link.userInfo tt_stringValueForKey:@"user_id"];
        if (!isEmptyString(userId)) {
            [mentionUsers addObject:userId];
        }
    }
    
    NSMutableArray *mentionConcerns = [NSMutableArray arrayWithCapacity:richSpanText.richSpans.links.count];
    NSMutableArray *hashtagNames = [NSMutableArray arrayWithCapacity:richSpanText.richSpans.links.count];
    for (TTRichSpanLink *link in richSpanText.richSpans.links) {
        NSString *concernId = [link.userInfo tt_stringValueForKey:@"concern_id"];
        if (!isEmptyString(concernId)) {
            [mentionConcerns addObject:concernId];
        }
        
        NSString *forumName = [link.userInfo tt_stringValueForKey:@"forum_name"];
        if (!isEmptyString(forumName)) {
            [hashtagNames addObject:forumName];
        }
    }
    
    NSDictionary *trackDic = [@{
                                @"is_forward": @(0),
                                @"at_user_id" : [mentionUsers componentsJoinedByString:@","] ?: @"",
                                @"hashtag_name" : [hashtagNames componentsJoinedByString:@","] ?: @""
                                } copy];
    NSMutableDictionary *trackExtra = [[NSMutableDictionary alloc] initWithDictionary:trackDic];
    if (repostModel.repost_type == TTThreadRepostTypeLink) {
        [trackExtra setValue:@"public-benefit" forKey:@"source"];
    }
    [trackExtra addEntriesFromDictionary:trackDict];
    [self trackRepostWithEvent:@"repost_publish" label:@"publish" repostModel:repostModel extra:trackExtra];
    
    NSDictionary <NSString *, NSString *> *emojis = [TTUGCEmojiParser parseEmojis:richSpanText.text];
    [TTUGCEmojiParser markEmojisAsUsed:emojis];
    NSArray <NSString *> *emojiIds = emojis.allKeys;
    [TTTrackerWrapper eventV3:@"emoticon_stats" params:@{
                                                         @"item_id" : repostModel.fw_id ?: @"",
                                                         @"group_id" : repostModel.group_id ?: @"",
                                                         @"with_emoticon_list" : (!emojiIds || emojiIds.count == 0) ? @"none" : [emojiIds componentsJoinedByString:@","],
                                                         @"source" : @"repost"
                                                         }];
    
    repostModel.content = richSpanText.text;
    repostModel.content_rich_span = [TTRichSpans JSONStringForRichSpans:richSpanText.richSpans];
    repostModel.mentionUsers = [mentionUsers componentsJoinedByString:@","];
    repostModel.mentionConcerns = [mentionConcerns componentsJoinedByString:@","];
    repostModel.repostToComment = isCommentRepost;
    
    [[TTForumPostThreadCenter sharedInstance_tt] repostWithRepostThreadModel:repostModel withConcernID:KTTFollowPageConcernID withCategoryID:kTTWeitoutiaoCategoryID refer:1 extraTrack:nil finishBlock:^{
        if (finishBlock) {
            finishBlock();
        }
    }];
}

- (void)trackRepostWithEvent:(NSString *)event label:(NSString *)label repostModel:(TTRepostThreadModel *)repostModel extra:(NSDictionary *)extra {
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    [dictionary addEntriesFromDictionary:extra];
    
    if (repostModel.opt_id_type == FRUGCTypeCodeCOMMENT) {
        [dictionary setValue:repostModel.opt_id forKey:@"comment_id"];
    }
    
    if (repostModel.opt_id_type == FRUGCTypeCodeCOMMENT) {
        [dictionary setValue:repostModel.fw_id forKey:@"value"];
    } else if (repostModel.repost_type == TTThreadRepostTypeArticle) {
        [dictionary setValue:repostModel.group_id forKey:@"value"];
    } else {
        if (!isEmptyString(repostModel.fw_id)) {
            [dictionary setValue:repostModel.fw_id forKey:@"value"];
        } else {
            [dictionary setValue:@(0) forKey:@"value"];;
        }
        
    }
    [dictionary setValue:@"umeng" forKey:@"category"];
    [dictionary setValue:event forKey:@"tag"];
    [dictionary setValue:label forKey:@"label"];
    [TTTrackerWrapper eventData:dictionary];
}

#pragma mark - Private


- (NSDictionary *)repostParamsWithRepostType:(TTThreadRepostType)repostType
                               originArticle:(TTRepostOriginArticle *)originArticle
                                originThread:(TTRepostOriginThread *)originThread
                originShortVideoOriginalData:(TTRepostOriginShortVideoOriginalData *)originShortVideoOriginalData
                           originWendaAnswer:(TTRepostOriginTTWendaAnswer *)originWendaAnswer
                           operationItemType:(TTRepostOperationItemType)operationItemType
                             operationItemID:(NSString *)operationItemID
                              repostSegments:(NSArray<TTRepostContentSegment *> *)segments {
    NSString *content;
    NSString *contentRichSpan;
    NSString *coverURL;
    NSString *title;
    NSString *titleRichSpanJSONString;
    NSString *group_id;
    NSString *fw_id;
    FRUGCTypeCode fw_id_type = 0;
    NSString *opt_id;
    FRUGCTypeCode opt_id_type = 0;
    NSString *fw_user_id;
    BOOL is_video = NO;
    
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    [parameters setValue:@(repostType) forKey:@"repost_type"];
    [parameters setValue:@(operationItemType) forKey:@"repost_operation_type"];
    
    if (!SSIsEmptyArray(segments)) {
        
        TTRichSpanText *richSpanText = [TTRepostContentSegment richSpanTextForRepostSegments:segments];
        if (richSpanText) {
            content = richSpanText.text;
            if (richSpanText.richSpans) {
                contentRichSpan = [TTRichSpans JSONStringForRichSpans:richSpanText.richSpans];
            }
        }
    }
    [parameters setValue:content forKey:@"content"];
    [parameters setValue:contentRichSpan forKey:@"content_rich_span"];
    
    opt_id = operationItemID;
    [parameters setValue:opt_id forKey:@"opt_id"];
    
    switch (operationItemType) {
        case TTRepostOperationItemTypeArticle:
            opt_id_type = FRUGCTypeCodeITEM;
            break;
        case TTRepostOperationItemTypeComment:
            opt_id_type = FRUGCTypeCodeCOMMENT;
            break;
        case TTRepostOperationItemTypeReply:
            opt_id_type = FRUGCTypeCodeREPLY;
            break;
        case TTRepostOperationItemTypeThread:
            opt_id_type = FRUGCTypeCodeTHREAD;
            break;
        case TTRepostOperationItemTypeShortVideo:
            opt_id_type = FRUGCTypeCodeUGC_VIDEO;
            break;
        case TTRepostOperationItemTypeWendaAnswer:
            opt_id_type = FRUGCTypeCodeANSWER;
            break;
        default:
            opt_id_type = 0;
            break;
    }
    [parameters setValue:@(opt_id_type) forKey:@"opt_id_type"];
    
    NSArray *coverUrlModelList;
    NSString *userAvatarURL;
    BOOL isHiddenImage = NO;
    if (repostType == TTThreadRepostTypeArticle) {
        
        if (originArticle && originArticle.thumbImage) {
            coverUrlModelList = [[TTWebImageManager shareManger] sortedImageArray:originArticle.thumbImage.url_list];
        }
        userAvatarURL = @"http://p7.pstatp.com/origin/4a340009246b949c3f10"; // 文章不用作者头像
        
        if (!isEmptyString(originArticle.title)) {
            if (!isEmptyString(originArticle.userName)) {
                title = [NSString stringWithFormat:@"%@：%@", originArticle.userName, originArticle.title];
            } else {
                title = originArticle.title;
            }
        }
        
        if (originArticle.isDeleted || (originArticle.showOrigin && NO == originArticle.showOrigin.boolValue)) {
            isHiddenImage = YES;
            if (!isEmptyString(originArticle.showTips)) {
                title = originArticle.showTips;
            } else {
                title = [[TTKitchenMgr sharedInstance] getString:kKCUGCRepostDeleteHint];
            }
        }
        
        group_id = originArticle.groupID;
        
        fw_id = originArticle.itemID;
        if (isEmptyString(fw_id)) {
            fw_id = originArticle.groupID;
        }
        fw_id_type = FRUGCTypeCodeITEM;
        
        fw_user_id = originArticle.userID;
        is_video = originArticle.isVideo;
    } else if (repostType == TTThreadRepostTypeThread){
        
        if (originThread && originThread.thumbImage) {
            coverUrlModelList = [[TTWebImageManager shareManger] sortedImageArray:originThread.thumbImage.url_list];
        }
        userAvatarURL = originThread.userAvatar;
        
        if (!isEmptyString(originThread.title)) {
            title = originThread.title;
        } else if (!isEmptyString(originThread.content)) {
            title = originThread.content;
            if (!isEmptyString(originThread.contentRichSpanJSONString)) {
                titleRichSpanJSONString = originThread.contentRichSpanJSONString;
            }
        } else {
            title = NSLocalizedString(@"分享图片", nil);
        }
        
        TTRichSpans *richSpans = [TTRichSpans richSpansForJSONString:titleRichSpanJSONString];
        TTRichSpanText *richSpanText = [[TTRichSpanText alloc] initWithText:title richSpans:richSpans];
        
        if (!isEmptyString(title) && !isEmptyString(originThread.userName)) {
            title = [NSString stringWithFormat:@"%@：%@", originThread.userName, title];
            
            [richSpanText insertText:[NSString stringWithFormat:@"%@：", originThread.userName] atIndex:0];
        }
        
        titleRichSpanJSONString = [TTRichSpans JSONStringForRichSpans:richSpanText.richSpans];
        
        if (originThread.isDeleted || (originThread.showOrigin && NO == originThread.showOrigin.boolValue)) {
            
            isHiddenImage = YES;
            if (!isEmptyString(originThread.showTips)) {
                title = originThread.showTips;
            } else {
                title = [[TTKitchenMgr sharedInstance] getString:kKCUGCRepostDeleteHint];
            }
            
            titleRichSpanJSONString = nil;
        }
        
        fw_id = originThread.threadID;
        fw_id_type = FRUGCTypeCodeTHREAD;
        fw_user_id = originThread.userID;
        is_video = NO;
    } else if (repostType == TTThreadRepostTypeShortVideo){
        
        if (originShortVideoOriginalData && originShortVideoOriginalData.thumbImage) {
            coverUrlModelList = [[TTWebImageManager shareManger] sortedImageArray:originShortVideoOriginalData.thumbImage.url_list];
        }
        userAvatarURL = originShortVideoOriginalData.userAvatar;
        
        if (!isEmptyString(originShortVideoOriginalData.title)) {
            title = originShortVideoOriginalData.title;
        } else {
            title = [KitchenMgr getString:kKCUGCShortVideoTitlePlaceholder];
        }
        if (!isEmptyString(title) && !isEmptyString(originShortVideoOriginalData.userName)) {
            title = [NSString stringWithFormat:@"%@：%@", originShortVideoOriginalData.userName, title];
        }
        
        if (originShortVideoOriginalData.showOrigin && NO == originShortVideoOriginalData.showOrigin.boolValue){
            isHiddenImage = YES;
            if (!isEmptyString(originShortVideoOriginalData.showTips)) {
                title = originShortVideoOriginalData.showTips;
            } else {
                title = [[TTKitchenMgr sharedInstance] getString:kKCUGCRepostDeleteHint];
            }
        }
        
        fw_id = originShortVideoOriginalData.shortVideoID;
        fw_id_type = FRUGCTypeCodeUGC_VIDEO;
        fw_user_id = originShortVideoOriginalData.userID;
        is_video = YES;
    } else if (repostType == TTThreadRepostTypeWendaAnswer){
        
        if (originWendaAnswer && originWendaAnswer.thumbImage) {
            coverUrlModelList = [[TTWebImageManager shareManger] sortedImageArray:originWendaAnswer.thumbImage.url_list];
        }
        userAvatarURL = originWendaAnswer.userAvatar;
        
        if (!isEmptyString(originWendaAnswer.title)) {
            title = originWendaAnswer.title;
        }
        if (!isEmptyString(title) && !isEmptyString(originWendaAnswer.userName)) {
            title = [NSString stringWithFormat:@"%@%@：%@", originWendaAnswer.userName, @"回答了", title];
        }
        
        if (originWendaAnswer.isDeleted) {
            isHiddenImage = YES;
            title = [[TTKitchenMgr sharedInstance] getString:kKCUGCRepostDeleteHint];
        }
        
        fw_id = originWendaAnswer.wendaAnswerID;
        fw_id_type = FRUGCTypeCodeANSWER;
        fw_user_id = originWendaAnswer.userID;
        is_video = NO;
    }
    
    if (isHiddenImage) {
        coverURL = nil;
    } else {
        if (!SSIsEmptyArray(coverUrlModelList)) {
            FRImageInfoModel *coverModel = [coverUrlModelList objectAtIndex:0];
            coverURL = coverModel.url;
        }
        if (isEmptyString(coverURL)) {
            coverURL = userAvatarURL;
        }
    }
    
    [parameters setValue:coverURL forKey:@"cover_url"];
    [parameters setValue:title forKey:@"title"];
    [parameters setValue:titleRichSpanJSONString forKey:@"title_rich_span"];
    [parameters setValue:group_id forKey:@"group_id"];
    [parameters setValue:fw_id forKey:@"fw_id"];
    [parameters setValue:@(fw_id_type) forKey:@"fw_id_type"];
    [parameters setValue:fw_user_id forKey:@"fw_user_id"];
    [parameters setValue:@(is_video) forKey:@"is_video"];
    
    return parameters;
}

- (void)showRepostVCWithRepostType:(TTThreadRepostType)repostType
                     originArticle:(TTRepostOriginArticle *)originArticle
                      originThread:(TTRepostOriginThread *)originThread
      originShortVideoOriginalData:(TTRepostOriginShortVideoOriginalData *)originShortVideoOriginalData
                 originWendaAnswer:(TTRepostOriginTTWendaAnswer *)originWendaAnswer
                 operationItemType:(TTRepostOperationItemType)operationItemType
                   operationItemID:(NSString *)operationItemID
                    repostSegments:(NSArray<TTRepostContentSegment *> *)segments {
    NSDictionary *repostParams = [self repostParamsWithRepostType:repostType
                                                    originArticle:originArticle
                                                     originThread:originThread
                                     originShortVideoOriginalData:originShortVideoOriginalData
                                                originWendaAnswer:originWendaAnswer
                                                operationItemType:operationItemType
                                                  operationItemID:operationItemID
                                                   repostSegments:segments];
    [self showRepostVCWithRepostParams:repostParams];
}

- (void)showRepostVCWithRepostParams:(NSDictionary *)repostParams {
    [[TTRoute sharedRoute] openURLByPresentViewController:[NSURL URLWithString:@"sslocal://repost_page"] userInfo:TTRouteUserInfoWithDict(repostParams)];
}

- (void)directSendRepostWithRepostParams:(NSDictionary *)repostParams
                      baseViewController:(UIViewController *)baseViewController
                               trackDict:(NSDictionary *)trackDict {
    TTRepostThreadModel *repostModel = [[TTRepostThreadModel alloc] initWithRepostParam:repostParams];
    TTRichSpanText *richSpanText;
    if (!isEmptyString(repostModel.content)) {
        TTRichSpans *richSpans = [TTRichSpans richSpansForJSONString:repostModel.content_rich_span];
        richSpanText = [[TTRichSpanText alloc] initWithText:repostModel.content richSpans:richSpans];
    } else {
        richSpanText = [[TTRichSpanText alloc] initWithText:@"" richSpans:nil];
    }
    //采用repostParams直接转发，若转发文字为空，则添加“转发了”
    if (isEmptyString(richSpanText.text)) {
        [richSpanText insertText:@"转发了" atIndex:0];
    }
    if (richSpanText.text.length > g_postMomentMaxCharactersLimit) {
        [[TTRoute sharedRoute] openURLByPresentViewController:[NSURL URLWithString:@"sslocal://repost_page"] userInfo:TTRouteUserInfoWithDict(repostParams)];
        return ;
    }
    [self sendRepostWithRepostModel:repostModel
                       richSpanText:richSpanText
                    isCommentRepost:NO
                 baseViewController:baseViewController
                          trackDict:trackDict
                        finishBlock:nil];
}
@end
