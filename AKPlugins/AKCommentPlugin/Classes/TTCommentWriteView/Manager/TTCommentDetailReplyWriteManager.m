//
//  TTCommentDetailReplyWriteManager.m
//  Article
//
//  Created by ranny_90 on 2018/1/21.
//

#import "TTCommentDetailReplyWriteManager.h"
#import <TTPlatformUIModel/TTGroupModel.h>
#import <TTUGCFoundation/TTRichSpanText+Comment.h>
#import <TTUGCFoundation/TTUGCEmojiParser.h>
#import <TTPersistence/TTPersistence.h>
#import <TTBaseLib/TTUIResponderHelper.h>
#import <TTUIWidget/TTIndicatorView.h>
#import <TTNetworkManager/TTNetworkUtil.h>
#import <TTAccountBusiness.h>
#import "TTCommentDetailReplyCommentModel.h"
#import "TTCommentDefines.h"
#import "TTCommentDataManager.h"
#import "TTCommentWriteView.h"
#import "FHTraceEventUtils.h"

#define Persistence [TTPersistence persistenceWithName:NSStringFromClass(self.class)]
#define PersistenceDraftKey @"PersistenceDraftKey"
#define PersistenceDraftContentKey @"PersistenceDraftContentKey"
#define PersistenceDraftRichSpanKey @"PersistenceDraftRichSpanKey"
#define PersistenceDraftIdentifier @"PersistenceDraftIdentifier"

#define EMOJI_INPUT_VIEW_HEIGHT ([TTDeviceHelper isScreenWidthLarge320] ? 216.f : 193.f)

extern NSString * const TTCommentSuccessForPushGuideNotification;

static bool isTTCommentPublishing = NO;

@interface TTCommentDetailReplyWriteManager ()

@property (nonatomic, copy) TTCommentDetailPublishCommentViewPublishCallback publishCallback;

@property (nonatomic, strong) id<TTCommentDetailModelProtocol> commentDetailModel;

@property (nonatomic, strong) id<TTCommentDetailReplyCommentModelProtocol> replyCommentModel;

@property (nonatomic, copy) TTCommentRepostParamsBlock commentRepostParamsBlock;
@property (nonatomic, assign) BOOL hasUGCBoundMobile; //是否已经绑定手机
@property (nonatomic, copy) NSString *bindPhoneDesc; //绑定手机提示语

@property (nonatomic, copy) TTCommentDetailWriteCommentViewLoginCallback loginCallBack;
@property (nonatomic, copy) TTCommentGetReplyCommentModelClassCallback getReplyClassCallback;

@property (nonatomic, strong) TTCommentWriteView *commentViewStrong; //此处强持有commentview是为了 登录之后进行发布的时候 commentview不至于被释放,注意登陆回来之后要释放

@property (nonatomic, strong) TTRichSpanText *preRichSpanText; //评论并转发时使用的参数，请从 //@名字开始，把所有的都带上。  如果字段不传，则从detailModel和replyCommentModel中读取。

@property (nonatomic, copy) NSString *commentSource;

/**
 YES: 清理草稿
 NO: 写草稿
 */
@property (nonatomic, assign) BOOL needClearDraft;

@end

@implementation TTCommentDetailReplyWriteManager

- (void)dealloc {

    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)initWithCommentDetailModel:(id<TTCommentDetailModelProtocol>)commentDetailModel
                         replyCommentModel:(id<TTCommentDetailReplyCommentModelProtocol> )replyCommentModel
                           publishCallback:(TTCommentDetailPublishCommentViewPublishCallback)publishCallBack
                        commentRepostBlock:(TTCommentRepostParamsBlock)commentRepostBlock {
    
    self = [self initWithCommentDetailModel:commentDetailModel replyCommentModel:replyCommentModel commentRepostBlock:commentRepostBlock publishCallback:publishCallBack getReplyCommentModelClassBlock:nil commentRepostWithPreRichSpanText:nil commentSource:nil];
    return self;
}

- (instancetype)initWithCommentDetailModel:(id<TTCommentDetailModelProtocol>)commentDetailModel
                         replyCommentModel:(id<TTCommentDetailReplyCommentModelProtocol> )replyCommentModel
                        commentRepostBlock:(TTCommentRepostParamsBlock)commentRepostBlock
                           publishCallback:(TTCommentDetailPublishCommentViewPublishCallback)publishCallBack
            getReplyCommentModelClassBlock:(TTCommentGetReplyCommentModelClassCallback)getReplyClassCallback
          commentRepostWithPreRichSpanText:(TTRichSpanText *)preRichSpanText
                             commentSource:(NSString *)commentSource {
    
    self = [super init];
    if (self) {
        self.commentDetailModel = commentDetailModel;
        self.replyCommentModel = replyCommentModel;
        self.commentRepostParamsBlock = commentRepostBlock;
        self.publishCallback = publishCallBack;
        self.preRichSpanText = preRichSpanText;
        if (getReplyClassCallback) {
            self.getReplyClassCallback = [getReplyClassCallback copy];
        }
        else {
            self.getReplyClassCallback = ^Class{
                return [TTCommentDetailReplyCommentModel class];
            };
        }
        self.commentSource = commentSource;

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(bindingMobileCompleted:) name:kAccountBindingMobileNotification object:nil];
    }
    return self;
}

- (void)setCommentWriteView:(TTCommentWriteView *)commentWriteView {
    _commentWriteView = commentWriteView;
    _commentWriteView.inputTextView.source = @"reply_comment";
    if ([self.commentDetailModel respondsToSelector:@selector(banForwardToWeitoutiao)]) {
        NSNumber *banWeitoutiao = [self.commentDetailModel banForwardToWeitoutiao];
        if (banWeitoutiao) {
            self.commentWriteView.banCommentRepost = banWeitoutiao.boolValue;
        } else {
            self.commentWriteView.banCommentRepost = NO;
        }
    } else {
        self.commentWriteView.banCommentRepost = YES;
    }
    [self loadDraftContentIfNeeded];
    [self setupTextViewPlaceholder];
}


#pragma mark -- delegate method

- (void)commentViewClickPublishButton{

    if (isTTCommentPublishing){
        return;
    }
    isTTCommentPublishing = YES;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        isTTCommentPublishing = NO;
    });

    TTRichSpanText *replyRichSpanText = self.commentWriteView.inputTextView.richSpanText;
    NSMutableArray *mentionUsers = [NSMutableArray arrayWithCapacity:replyRichSpanText.richSpans.links.count];
    for (TTRichSpanLink *link in replyRichSpanText.richSpans.links) {
        NSString *userId = [link.userInfo tt_stringValueForKey:@"user_id"];
        if (!isEmptyString(userId)) {
            [mentionUsers addObject:userId];
        }
    }

    [TTTrackerWrapper eventV3:@"at_function_stats" params:@{
                                                            @"group_id" : self.commentDetailModel.groupModel.groupID  ?: @"",
                                                            @"at_user_list" :[mentionUsers componentsJoinedByString:@","],
                                                            @"source" : @"reply_comment"
                                                            }];

    if (![self _shouldPostComment]) {
        return;
    }

    WeakSelf;
    TTCommentDetailWriteCommentViewLoginCallback loginCallback = ^void(id<TTCommentDetailReplyCommentModelProtocol> replyCommentModel, NSDictionary *jsonObj, NSError *error) {
        StrongSelf;
        if (error) {
            NSString *msg = nil;
            if ([error.domain isEqualToString:@"kCommonErrorDomain"]) {
                msg = [[error userInfo] objectForKey:@"message"];
            } else if ([error.domain isEqualToString:@"kTTNetworkErrorDomain"]) {
                msg = [jsonObj tt_stringValueForKey:@"data"];
            }

            if (isEmptyString(msg)) {
                msg = @"网络出现问题，请稍后再试";
            }
            [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:msg indicatorImage:[UIImage themedImageNamed:@"close_popup_textpage.png"] maxLine:0 autoDismiss:YES dismissHandler:nil];
        } else {
            if (self.commentWriteView.isNeedTips) {
                [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:@"发布成功" indicatorImage:[UIImage themedImageNamed:@"doneicon_popup_textpage.png"] autoDismiss:YES dismissHandler:nil];
            }
        
        }

        // 传递给 publishCallback 处理
        if (self.publishCallback) {
            self.publishCallback(replyCommentModel, error);
        }

        [self.commentWriteView dismissAnimated:YES];
    };

    self.loginCallBack = loginCallback;

    if ([TTAccountManager isLogin]) {
        [self postCommentWithLoginCallback:loginCallback];
    } else {

        self.commentViewStrong = self.commentWriteView;
        [self.commentWriteView dismissAnimated:YES];

        
        [TTAccountLoginManager showAlertFLoginVCWithParams:nil completeBlock:^(TTAccountAlertCompletionEventType type, NSString * _Nullable phoneNum) {
            if (type == TTAccountAlertCompletionEventTypeDone) {
                //登录成功 走发送逻辑
                if ([TTAccountManager isLogin]) {
                    [self postCommentWithLoginCallback:loginCallback];
                }
            }
            
            self.commentViewStrong = nil;
        }];
        
//        TTAccountLoginAlert *loginAlertView =
//        [TTAccountManager showLoginAlertWithType:TTAccountLoginAlertTitleTypePost source:@"post_comment" completion:nil];
//        __weak typeof(loginAlertView) weakLoginAlertView = loginAlertView;
//        loginAlertView.phoneInputCompletedHandler = ^(TTAccountAlertCompletionEventType type, NSString * _Nullable phoneNum) {
//
//            if (type == TTAccountAlertCompletionEventTypeDone) {
//                //登录成功 走发送逻辑
//                if ([TTAccountManager isLogin]) {
//                    [self postCommentWithLoginCallback:loginCallback];
//                }
//            } else if (type == TTAccountAlertCompletionEventTypeTip) {
//                UIViewController *topViewController = [TTUIResponderHelper topViewControllerFor:weakLoginAlertView];
//                [TTAccountManager presentQuickLoginFromVC:topViewController type:TTAccountLoginDialogTitleTypeDefault source:@"post_comment" completion:^(TTAccountLoginState state) {
//                    if ([TTAccountManager isLogin]) {
//                        [self postCommentWithLoginCallback:loginCallback];
//                    }
//                }];
//            } else if (type == TTAccountAlertCompletionEventTypeCancel) {
//
//            }
//
//            self.commentViewStrong = nil;
//        };
    }
}

- (void)commentViewShow{

    if (!isEmptyString(self.commentSource)) {
        wrapperTrackEventWithCustomKeys(@"update_detail",  @"comment", nil, self.commentSource, nil);
    }
    else {
        wrapperTrackEvent(@"update_detail", @"comment");
    }

}

- (void)commentViewDismiss{

    if (self.commentWriteView.emojiInputViewVisible) {
        if (!isEmptyString(self.commentSource)) {
            wrapperTrackEventWithCustomKeys(@"update_detail",  self.replyCommentModel ? @"reply_replier_cancel" : @"write_cancel", nil, self.commentSource, nil);
        }
        else {
            wrapperTrackEvent(@"update_detail", self.replyCommentModel ? @"reply_replier_cancel" : @"write_cancel");
        }
    }

    [self saveDraftContent];
}

- (void)commentViewCancelPublish {
    wrapperTrackEvent(@"update_detail", @"reply_replier_cancel");
}

- (void)commentViewClickRepostButton {
    wrapperTrackEvent(@"update_detail", self.commentWriteView.isCommentRepostedChecked? @"comment_to_article": @"comment_to_article_cancel");
}

#pragma mark -- private method

- (void)loadDraftContentIfNeeded {

    NSString *curIdentifier = isEmptyString(self.replyCommentModel.commentID)? self.commentDetailModel.commentID: self.replyCommentModel.commentID;

    NSDictionary *draftDic = [Persistence valueForKey:PersistenceDraftKey];
    NSString *draftContent;
    NSString *draftTextRichSpan;
    NSString *draftIdentifier;

    if (!SSIsEmptyDictionary(draftDic)) {
        draftIdentifier = [draftDic tt_stringValueForKey:PersistenceDraftIdentifier];
        draftContent = [draftDic tt_stringValueForKey:PersistenceDraftContentKey];
        draftTextRichSpan = [draftDic tt_stringValueForKey:PersistenceDraftRichSpanKey];
    }

    if (!isEmptyString(curIdentifier) && !isEmptyString(draftIdentifier) && [curIdentifier isEqualToString:draftIdentifier]) {
        if (!isEmptyString(draftContent)) {
            [self.commentWriteView configureDraftContent:draftContent withDraftContentRichSpan:draftTextRichSpan withDefaultTextPosition:0];
        } else {
            [self.commentWriteView configureDraftContent:@"" withDraftContentRichSpan:nil withDefaultTextPosition:0];
        }
    } else {
        [self.commentWriteView configureDraftContent:@"" withDraftContentRichSpan:nil withDefaultTextPosition:0];
    }
}

- (void)saveDraftContent {
    NSString *draftText =self.commentWriteView.inputTextView.text;

    if(self.needClearDraft) {
        [Persistence setValue:nil forKey:PersistenceDraftKey];
        return;
    }

    NSString *curDraftIdentifier = isEmptyString(self.replyCommentModel.commentID)? self.commentDetailModel.commentID: self.replyCommentModel.commentID;

    NSDictionary *lastDraftDic = [Persistence valueForKey:PersistenceDraftKey];
    NSString * lastDraftIdentifier = [lastDraftDic tt_stringValueForKey:PersistenceDraftIdentifier];

    if (!isEmptyString(draftText) || (!isEmptyString(curDraftIdentifier) && !isEmptyString(lastDraftIdentifier) && [lastDraftIdentifier isEqualToString:curDraftIdentifier])){
        NSString *draftTextRichSpan = [TTRichSpans JSONStringForRichSpans:self.commentWriteView.inputTextView.richSpanText.richSpans];

        NSMutableDictionary *draftDic = [[NSMutableDictionary alloc] init];
        [draftDic setValue:curDraftIdentifier forKey:PersistenceDraftIdentifier];
        [draftDic setValue:draftText forKey:PersistenceDraftContentKey];
        [draftDic setValue:draftTextRichSpan forKey:PersistenceDraftRichSpanKey];

        [Persistence setValue:self.needClearDraft ? nil : [draftDic copy] forKey:PersistenceDraftKey];
        [Persistence save];
    }
}

- (void)setupTextViewPlaceholder {
    NSString *placeholder = nil;
    if (isEmptyString(self.replyCommentModel.user.name)) {
        
        if ([self.commentDetailModel respondsToSelector:@selector(commentPlaceholder)]) {
            
            placeholder = self.commentDetailModel.commentPlaceholder ?: kCommentInputPlaceHolder;
        }else {
            placeholder = kCommentInputPlaceHolder;
        }
    } else {
        placeholder = [NSString stringWithFormat:@"回复 %@：", self.replyCommentModel.user.name];
    }

    [self.commentWriteView setTextViewPlaceholder:placeholder];
}

- (BOOL)hasBoundMobile {
    return !isEmptyString([[[TTAccount sharedAccount] user] mobile]) || self.hasUGCBoundMobile;
}

- (void)showBindingMobileViewController {
    [[TTRoute sharedRoute] openURLByPushViewController:[TTNetworkUtil URLWithURLString:@"sslocal://binding_mobile"]
                                              userInfo:TTRouteUserInfoWithDict(@{@"track_params": @{
                                                  @"source": @"comment"}})];
}

- (void)bindingMobileCompleted:(NSNotification *)notification {
    BOOL finished = [notification.userInfo tt_boolValueForKey:@"finished"];
    BOOL dismissed = [notification.userInfo tt_boolValueForKey:@"dismissed"];

    if (finished) {
        self.hasUGCBoundMobile = YES;
        if (self.loginCallBack) {
            [self postCommentWithLoginCallback:self.loginCallBack];
        }
    } else {
        if (dismissed) {
            self.hasUGCBoundMobile = NO;
            UIViewController *vc = [TTUIResponderHelper correctTopmostViewController];
            while (vc.presentedViewController) {
                vc = vc.presentedViewController;
            }

            [self.commentWriteView showInView:vc.view animated:YES];
        }
    }
}

#pragma mark - post comment

- (NSString *)enterFromString{
    
    NSString * enterFrom = self.enterFrom;
    NSString *categoryName = self.categoryID;
    if (!categoryName || [categoryName isEqualToString:@"xx"] ) {
        return enterFrom;
    }else{
        if (![enterFrom isEqualToString:@"click_headline"] && ![enterFrom isEqualToString:@"click_favorite"]) {
            
            enterFrom = @"click_category";
        }
    }
    
    return enterFrom;
}

- (NSString *)categoryName {
    NSString *categoryName = self.categoryID;
    if (!categoryName || [categoryName isEqualToString:@"xx"] ) {
        categoryName = [self.enterFrom stringByReplacingOccurrencesOfString:@"click_" withString:@""];
    }else{
        if (![self.enterFrom isEqualToString:@"click_headline"]) {
            if ([categoryName hasPrefix:@"_"]) {
                categoryName = [categoryName substringFromIndex:1];
            }
        }
    }
    return categoryName;
}

- (void)postCommentWithLoginCallback:(TTCommentDetailWriteCommentViewLoginCallback)callback  {

    TTRichSpanText *replyRichSpanText = self.commentWriteView.inputTextView.richSpanText;
    [replyRichSpanText trimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

    NSString *replyContent = replyRichSpanText.text;
    NSString *replyContentRichSpan = [TTRichSpans JSONStringForRichSpans:replyRichSpanText.richSpans];

    NSMutableArray *mentionUsers = [NSMutableArray arrayWithCapacity:replyRichSpanText.richSpans.links.count];
    for (TTRichSpanLink *link in replyRichSpanText.richSpans.links) {
        NSString *userId = [link.userInfo tt_stringValueForKey:@"user_id"];
        if (!isEmptyString(userId)) {
            [mentionUsers addObject:userId];
        }
    }

    NSDictionary <NSString *, NSString *> *emojis = [TTUGCEmojiParser parseEmojis:replyContent];
    [TTUGCEmojiParser markEmojisAsUsed:emojis];
    NSArray <NSString *> *emojiIds = emojis.allKeys;
    [TTTrackerWrapper eventV3:@"emoticon_stats" params:@{
                                                         @"item_id" : self.commentDetailModel.groupModel.itemID ?: @"",
                                                         @"group_id" : self.commentDetailModel.groupModel.groupID ?: @"",
                                                         @"with_emoticon_list" : (!emojiIds || emojiIds.count == 0) ? @"none" : [emojiIds componentsJoinedByString:@","],
                                                         @"source" : @"comment"
                                                         }];

    NSMutableDictionary *paramsDict = [[NSMutableDictionary alloc] init];
    [paramsDict setValue:self.commentDetailModel.groupModel.groupID forKey:@"group_id"];
    [paramsDict setValue:self.commentDetailModel.groupModel.itemID forKey:@"item_id"];
    if (self.logPb) {
        
        [paramsDict setValue:self.logPb forKey:@"log_pb"];
    }else {
        [paramsDict setValue:@"be_null" forKey:@"log_pb"];

    }
    [paramsDict setValue:[self categoryName] forKey:@"category_name"];
    [paramsDict setValue:@"house_app2c_v2"  forKey:@"event_type"];
    if (self.enterFrom.length > 0) {
        [paramsDict setValue:[FHTraceEventUtils generateEnterfrom:[self categoryName]]  forKey:@"enter_from"];
    }
    [TTTracker eventV3:@"rt_post_reply" params:paramsDict];
    
    
    NSMutableDictionary *userInfoDic = [[NSMutableDictionary alloc] init];
    if ([self.commentDetailModel respondsToSelector:@selector(groupModel)]) {
        [userInfoDic setValue:self.commentDetailModel.groupModel.groupID forKey:@"group_id"];
        [userInfoDic setValue:self.commentDetailModel.commentID forKey:@"comment_id"];
        [userInfoDic setValue:self.replyCommentModel.commentID forKey:@"reply_id"];
        [[NSNotificationCenter defaultCenter] postNotificationName:kReplyActionNotificationKey object:nil userInfo:userInfoDic];
    }

    if (self.commentWriteView.isNeedTips) {
        [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:kCommentSending indicatorImage:nil autoDismiss:NO dismissHandler:nil];
    }

    [self.commentWriteView configurePublishButtonEnable:NO];


    [[TTCommentDataManager sharedManager] postCommentReplyWithCommentID:self.commentDetailModel.commentID
                                                         replyCommentID:self.replyCommentModel.commentID
                                                            replyUserID:self.replyCommentModel.user.ID
                                                                content:replyContent
                                                        contentRichSpan:replyContentRichSpan
                                                           mentionUsers:[mentionUsers componentsJoinedByString:@","]
                                                            finishBlock:^(id jsonObj, NSError *error) {
                                                                NSDictionary *data = [jsonObj tt_dictionaryValueForKey:@"data"];
                                                                Class replyCommentModelClass = self.getReplyClassCallback ? self.getReplyClassCallback() : nil;
                                                                id <TTCommentDetailReplyCommentModelProtocol> postedCommentReplyModel = [[replyCommentModelClass alloc] initWithDictionary:[data tt_dictionaryValueForKey:@"comment"]
                                                                                                                                                                                     error:nil];
                                                                if (error) {
                                                                    [self.commentWriteView configurePublishButtonEnable:YES];

                                                                    if ([self hasBoundMobile]) { //已绑定手机号，其他错误
                                                                        if (callback) {
                                                                            callback(postedCommentReplyModel, jsonObj, error);
                                                                        }
                                                                    } else { //绑定手机号
                                                                        self.hasUGCBoundMobile = ![data tt_boolValueForKey:@"bind_mobile"];
                                                                        [self showBindingMobileViewController];
                                                                        [TTIndicatorView dismissIndicators];
                                                                    }

                                                                    return;
                                                                }

                                                                // 是否是评论并转发
                                                                BOOL is_repost = [self.commentWriteView isCommentRepostedChecked];
                                                                if (!is_repost) {

                                                                    [self.commentWriteView configurePublishButtonEnable:YES];
                                                                    self.needClearDraft = YES;
                                                                    if (callback) {
                                                                        callback(postedCommentReplyModel, jsonObj, error);
                                                                    }
                                                                } else {
                                                                    [self postCommentRepostWithPostedCommentReplyModel:postedCommentReplyModel
                                                                                                          replyContent:replyContent
                                                                                                  replyContentRichSpan:replyContentRichSpan
                                                                                                          mentionUsers:mentionUsers
                                                                                                              callback:callback];
                                                                }
                                                            }];
}

- (void)postCommentRepostWithPostedCommentReplyModel:(id <TTCommentDetailReplyCommentModelProtocol>)postedCommentReplyModel
                                        replyContent:(NSString *)replyContent
                                replyContentRichSpan:(NSString *)replyContentRichSpan mentionUsers:(NSArray *)mentionUsers
                                            callback:(TTCommentDetailWriteCommentViewLoginCallback)callback {
    NSString *contentString = nil;
    NSString *contentRichSpan = nil;

    TTRichSpanText *postRichSpanText = [[TTRichSpanText alloc] initWithText:@"" richSpans:nil];
    if (self.commentWriteView.inputTextView.richSpanText) {
        [postRichSpanText appendRichSpanText:self.commentWriteView.inputTextView.richSpanText];
    }

    if (self.preRichSpanText) { //外面传了，就用外面的
        [postRichSpanText appendRichSpanText:self.preRichSpanText];
        contentString = postRichSpanText.text;
        if (postRichSpanText.richSpans) {
            contentRichSpan = [TTRichSpans JSONStringForRichSpans:postRichSpanText.richSpans];
        }
    } else { //没有就自己拼
        TTRichSpanText *richSpanText = [[TTRichSpanText alloc] initWithText:@"" richSpans:nil];

        //reply层
        if (self.replyCommentModel && !isEmptyString(self.replyCommentModel.user.name) && !isEmptyString(self.replyCommentModel.user.ID) && !isEmptyString(self.replyCommentModel.content)) {

            [richSpanText appendCommentQuotedUserName:self.replyCommentModel.user.name
                                               userId:self.replyCommentModel.user.ID];

            TTRichSpanText *replyRichSpanContent = [[TTRichSpanText alloc] initWithText:self.replyCommentModel.content
                                                                    richSpansJSONString:self.replyCommentModel.contentRichSpanJSONString];
            [richSpanText appendRichSpanText:replyRichSpanContent];

            //reply引用层
            if (!isEmptyString(self.replyCommentModel.qutoedCommentModel_commentContent) && !isEmptyString(self.replyCommentModel.qutoedCommentModel_userName) && !isEmptyString(self.replyCommentModel.qutoedCommentModel_userID)) {
                [richSpanText appendCommentQuotedUserName:self.replyCommentModel.qutoedCommentModel_userName
                                                   userId:self.replyCommentModel.qutoedCommentModel_userID];

                TTRichSpanText *replyQuotedRichSpanContent = [[TTRichSpanText alloc] initWithText:self.replyCommentModel.qutoedCommentModel_commentContent
                                                                              richSpansJSONString:self.replyCommentModel.qutoedCommentModel_commentContentRichSpan];
                [richSpanText appendRichSpanText:replyQuotedRichSpanContent];
            }
        }

        //comment层
        if (self.commentDetailModel && !isEmptyString(self.commentDetailModel.userName) && !isEmptyString(self.commentDetailModel.userIDStr) && !isEmptyString(self.commentDetailModel.content)) {
            [richSpanText appendCommentQuotedUserName:self.commentDetailModel.userName
                                               userId:self.commentDetailModel.userIDStr];

            TTRichSpanText *commentDetailRichSpanContent = [[TTRichSpanText alloc] initWithText:self.commentDetailModel.content
                                                                            richSpansJSONString:self.commentDetailModel.contentRichSpanJSONString];
            [richSpanText appendRichSpanText:commentDetailRichSpanContent];

            //comment引用层
            if (!isEmptyString(self.commentDetailModel.qutoedCommentModel_commentContent) && !isEmptyString(self.commentDetailModel.qutoedCommentModel_userName) && !isEmptyString(self.commentDetailModel.qutoedCommentModel_userID)) {
                [richSpanText appendCommentQuotedUserName:self.commentDetailModel.qutoedCommentModel_userName
                                                   userId:self.commentDetailModel.qutoedCommentModel_userID];

                TTRichSpanText *commentDetailQuotedRichSpanContent = [[TTRichSpanText alloc] initWithText:self.commentDetailModel.qutoedCommentModel_commentContent
                                                                                      richSpansJSONString:self.commentDetailModel.qutoedCommentModel_commentContentRichSpan];
                [richSpanText appendRichSpanText:commentDetailQuotedRichSpanContent];
            }
        }

        if (richSpanText) {
            [postRichSpanText appendRichSpanText:richSpanText];
        }

        contentString = postRichSpanText.text;
        if (postRichSpanText.richSpans) {
            contentRichSpan = [TTRichSpans JSONStringForRichSpans:postRichSpanText.richSpans];
        }
    }

    if (isEmptyString(contentString)) {
        contentString = replyContent;
    }

    NSString *fwID = nil;
    if (self.commentRepostParamsBlock) {
        self.commentRepostParamsBlock(&fwID);
    } else {
        NSAssert(NO, @"commentRepostParamsBlock 不能为空");
    }

    [[TTCommentDataManager sharedManager] postCommentWithGroupID:self.commentDetailModel.groupModel.groupID
                                                       serviceID:self.serviceID
                                                        aggrType:self.commentDetailModel.groupModel.aggrType
                                                         itemTag:nil
                                                         content:replyContent
                                                 contentRichSpan:replyContentRichSpan
                                                     mentionUser:[mentionUsers componentsJoinedByString:@","]
                                                replyToCommentID:self.commentDetailModel.commentID
                                                         replyID:postedCommentReplyModel.commentID
                                                        isRepost:YES
                                                   repostContent:contentString
                                           repostContentRichSpan:contentRichSpan
                                                      repostFwID:fwID
                                             commentTimeInterval:nil
                                                      staytimeMs:nil
                                                         readPct:nil
                                                         context:nil
                                                        callback:^(NSError *error, id jsonObj) {
                                                            [self.commentWriteView configurePublishButtonEnable:YES];
                                                            self.needClearDraft = !error;
                                                            if (callback) {
                                                                callback(postedCommentReplyModel, jsonObj, error);
                                                            }
                                                            if (!error) {
                                                                // 评论成功
                                                                [[NSNotificationCenter defaultCenter]
                                                                 postNotificationName:TTCommentSuccessForPushGuideNotification
                                                                 object:nil
                                                                 userInfo:@{
                                                                            @"reason" : @(3)
                                                                            }];

                                                            }
                                                        }];
}

- (BOOL)_shouldPostComment {
    NSString *errorMsg;

    TTRichSpanText *contentRichSpanText = self.commentWriteView.inputTextView.richSpanText;
    NSString *content = contentRichSpanText.text;
    TTRichSpans *contentRichSpans = nil;
    if (contentRichSpanText) {
        contentRichSpans = [contentRichSpanText richSpans];
    }
    NSString *trimStr = [content stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];

    if ([self.commentWriteView.inputTextView.text trimmed].length == 0) {
        errorMsg = kCommentInputContentTooShortTip;
    } else if (trimStr.length > kCommentMaxLength) {
        errorMsg = [NSString stringWithFormat:kCommentInputContentTooManyTip];
    } else if (contentRichSpans && contentRichSpans.links && contentRichSpans.links.count > 20) { // TODO 此处得判断 link.type
        errorMsg = [NSString stringWithFormat:kCommentInputContentAtTooManyTip];
    } else if (!TTNetworkConnected()) {
        errorMsg = @"没有网络连接，请稍后再试";
    }

    if (isEmptyString(errorMsg)) {
        return YES;
    } else {

        [self.commentWriteView showContentTooLongTip:errorMsg];
        return NO;
    }
}

@end
