//
//  TTCommentWriteManager.m
//  Article
//
//  Created by ranny_90 on 2018/1/11.
//

#import "TTCommentWriteManager.h"
#import <TTPlatformBaseLib/TTProfileFillManager.h>
#import <TTNetworkManager/TTNetworkUtil.h>
#import <TTUGCFoundation/TTUGCEmojiParser.h>
#import <TTUGCAttributedLabel.h>
#import <TTPlatformUIModel/TTGroupModel.h>
#import <TTUGCFoundation/TTUGCTextViewMediator.h>
//#import <TTUGCFoundation/TTUGCDefine.h>
#import <TTBaseLib/NSObject+MultiDelegates.h>
#import <TTBaseLib/UITextView+TTAdditions.h>
#import <TTPersistence/TTPersistence.h>
#import <TTBaseLib/TTBusinessManager.h>
#import <TTBaseLib/TTBusinessManager+StringUtils.h>
#import <TTBaseLib/TTUIResponderHelper.h>
#import <TTEntry/SSPGCActionManager.h>
#import <TTAccountBusiness.h>
#import "TTCommentDataManager.h"
#import "TTCommentDefines.h"
#import "TTCommentWriteView.h"
#import <TTKitchenHeader.h>

#define Persistence [TTPersistence persistenceWithName:NSStringFromClass(self.class)]
#define PersistenceGroupDraftKey @"PersistenceGroupDraftKey" // 对应文章、帖子
#define PersistenceCommentDraftKey @"PersistenceCommentDraftKey" // 对应评论回复
#define PersistenceDraftIdentifier @"PersistenceDraftIdentifier"
#define PersistenceDraftContentKey @"PersistenceDraftContentKey"
#define PersistenceDraftRichSpanKey @"PersistenceDraftRichSpanKey"
#define PersistenceDraftTextPositionKey @"PersistenceDraftTextPositionKey"

static bool isTTArticleWritePublishing = NO;

// TODO 统统重写
typedef enum {
    TTCommentLoginStateUserCancelled,
    TTCommentLoginStatePlatformLogin,
    TTCommentLoginStateMobileLogin,
    TTCommentLoginStateMobileRegister,
    TTCommentLoginStateMobileBind
} TTCommentLoginState;

typedef void (^TTCommentLoginPipelineCompletion)(TTCommentLoginState state);

@interface TTCommentWriteManager () <SSPGCActionManagerDelegate>

@property (nonatomic, copy) NSDictionary *extraTrackDict;

@property (nonatomic, strong) NSDictionary *bindVCTrackDict;

@property (nonatomic, strong) TTRichSpanText *preRichSpanText;

@property (nonatomic, strong) TTArticleReadQualityModel *readQuality;

@property (nonatomic, strong) TTGroupModel *groupModel;
@property (nonatomic, copy) NSString *mediaID;
@property (nonatomic, copy) NSString *itemTag;
@property (nonatomic, copy) NSString *replyToCommentID;
@property (nonatomic, copy) NSString *adID;
@property (nonatomic, assign) BOOL hasImage;
@property (nonatomic, assign, getter=isSending) BOOL sending;
@property (nonatomic, assign) BOOL isSharePGCUser; //是否是分享PGC用户
@property (nonatomic, strong) SSPGCActionManager *pgcActionManager;

@property (nonatomic, assign) BOOL hasUGCBoundMobile; //是否已经绑定手机号
@property (nonatomic, copy) TTCommentLoginPipelineCompletion sendLogicBlock;

@property (nonatomic, copy) TTCommentRepostParamsBlock commentRepostParamsBlock;

@property (nonatomic, assign) NSInteger publishStatusForTrack; //0为初始值，1表示发送了unlog埋点,2表示发送了unlog_done埋点

@property (nonatomic, strong) NSDictionary *conditions;

@property (nonatomic, strong) TTCommentWriteView *commentViewStrong; //此处强持有commentview是为了 登录之后进行发布的时候 commentview不至于被释放,注意登陆回来之后要释放

@end

@implementation TTCommentWriteManager


#pragma  mark -- life method

- (void)dealloc {
    _pgcActionManager.delegate = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)initWithCommentCondition:(NSDictionary *)conditions
                     commentViewDelegate:(id<TTCommentWriteManagerDelegate>)commentViewDelegate
                      commentRepostBlock:(TTCommentRepostParamsBlock)commentRepostBlock {
    
    
    self = [self initWithCommentCondition:conditions commentViewDelegate:commentViewDelegate commentRepostBlock:commentRepostBlock extraTrackDict:nil bindVCTrackDict:nil commentRepostWithPreRichSpanText:nil readQuality:nil];
    return self;
}

- (instancetype)initWithCommentCondition:(NSDictionary *)conditions
                     commentViewDelegate:(id<TTCommentWriteManagerDelegate>)commentViewDelegate
                      commentRepostBlock:(TTCommentRepostParamsBlock)commentRepostBlock
                          extraTrackDict:(NSDictionary *)extraTrackDict
                         bindVCTrackDict:(NSDictionary *)bindVCTrackDict
        commentRepostWithPreRichSpanText:(TTRichSpanText *)preRichSpanText
                             readQuality:(TTArticleReadQualityModel *)readQuality {

    self = [super init];
    if (self) {
        self.delegate = commentViewDelegate;
        self.commentRepostParamsBlock = [commentRepostBlock copy];
        self.extraTrackDict = [extraTrackDict copy];
        self.bindVCTrackDict = [bindVCTrackDict copy];
        self.preRichSpanText = preRichSpanText;
        self.readQuality = readQuality;
        self.publishStatusForTrack = 0;
        self.commentRepostParamsBlock = [commentRepostBlock copy];

        self.conditions = [conditions copy];

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(postMessageFinished:) name:kPostMessageFinishedNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(bindingMobileCompleted:) name:kAccountBindingMobileNotification object:nil];
    }
    return self;
}

- (void)setCommentWriteView:(TTCommentWriteView *)commentWriteView {
    _commentWriteView = commentWriteView;
    _commentWriteView.inputTextView.source = @"comment";
    [self configureParamsWithConditon:self.conditions];
}

#pragma mark -- private method

- (void)configureParamsWithConditon:(NSDictionary *)conditions {
    if (SSIsEmptyDictionary(conditions)) {
        return;
    }

    self.isSharePGCUser = [[conditions objectForKey:@"kQuickInputViewConditionIsSharePGCUser"] boolValue];
    self.groupModel = [conditions objectForKey:@"kQuickInputViewConditionGroupModel"];
    self.mediaID = conditions[@"kQuickInputViewConditionMediaID"];

    if ([conditions objectForKey:@"kQuickInputViewConditionItemTag"]) {
        self.itemTag = [NSString stringWithFormat:@"%@", [conditions objectForKey:@"kQuickInputViewConditionItemTag"]];
    } else {
        self.itemTag = nil;
    }

    if ([[conditions allKeys] containsObject:@"kQuickInputViewConditionADIDKey"]) {
        self.adID = [NSString stringWithFormat:@"%@", [conditions objectForKey:@"kQuickInputViewConditionADIDKey"]];
    } else {
        self.adID = nil;
    }

    if ([conditions objectForKey:@"kQuickInputViewConditionReplyToCommentID"]) {
        self.replyToCommentID = [conditions objectForKey:@"kQuickInputViewConditionReplyToCommentID"];
    } else {
        self.replyToCommentID = nil;
    }

    self.hasImage = [[conditions objectForKey:@"kQuickInputViewConditionHasImageKey"] boolValue];

    NSString * content = nil;
    if ([conditions objectForKey:@"kQuickInputViewConditionInputViewText"]) {
        content = [conditions objectForKey:@"kQuickInputViewConditionInputViewText"];
    } else {
        content = nil;
    }

    NSString *contentRichSpanJson = nil;
    NSInteger defaultTextPosition = 0;

    if (self.replyToCommentID) {
        NSDictionary *draft = [Persistence valueForKey:PersistenceCommentDraftKey];
        NSString *draftID = [draft valueForKey:PersistenceDraftIdentifier];
        if ([draftID isEqualToString:self.replyToCommentID]) {
            content = [draft tt_stringValueForKey:PersistenceDraftContentKey];
            contentRichSpanJson = [draft tt_stringValueForKey:PersistenceDraftRichSpanKey];
            defaultTextPosition = [draft tt_integerValueForKey:PersistenceDraftTextPositionKey];
        }
    } else {
        NSDictionary *draft = [Persistence valueForKey:PersistenceGroupDraftKey];
        NSString *draftID = [draft valueForKey:PersistenceDraftIdentifier];
        if ([draftID isEqualToString:self.groupModel.groupID]) {
            content = [draft tt_stringValueForKey:PersistenceDraftContentKey];
            contentRichSpanJson = [draft tt_stringValueForKey:PersistenceDraftRichSpanKey];
            defaultTextPosition = [draft tt_integerValueForKey:PersistenceDraftTextPositionKey];
        }
    }

    //settings配置
    BOOL isConfigureShow = [KitchenMgr getBOOL:KKCCommentRepostFirstDetailEnable];

    NSNumber *conditionIsShowRepostEntrance = [conditions tt_objectForKey:@"kQuickInputViewConditionShowRepostEntrance"];
    //外部条件
    BOOL isShowConditionEntrance = YES;
    if (conditionIsShowRepostEntrance) {
        isShowConditionEntrance = conditionIsShowRepostEntrance.boolValue;
    }

    //外加不是广告
    BOOL isShow = isConfigureShow && (self.adID.length == 0) && isShowConditionEntrance;

    if (isShow) {
        self.commentWriteView.banCommentRepost = NO;
    }
    else {
        self.commentWriteView.banCommentRepost = YES;
    }

    [self.commentWriteView configureDraftContent:content withDraftContentRichSpan:contentRichSpanJson withDefaultTextPosition:defaultTextPosition];
}



- (void)saveDraft {

    NSString *content = self.commentWriteView.inputTextView.text;
    NSString *contentRichSpan = [TTRichSpans JSONStringForRichSpans:self.commentWriteView.inputTextView.richSpanText.richSpans];

    NSDictionary *originalDraft = [Persistence valueForKey:PersistenceGroupDraftKey];
    if (!isEmptyString(self.replyToCommentID)) {
        NSDictionary *originalDraft = [Persistence valueForKey:PersistenceCommentDraftKey];
        if ([[originalDraft tt_stringValueForKey:PersistenceDraftIdentifier] isEqual:self.replyToCommentID] || !isEmptyString(content)) {
            NSMutableDictionary *draft = [NSMutableDictionary dictionaryWithCapacity:4];
            [draft setValue:self.replyToCommentID forKey:PersistenceDraftIdentifier];
            [draft setValue:content forKey:PersistenceDraftContentKey];
            [draft setValue:contentRichSpan forKey:PersistenceDraftRichSpanKey];
            [draft setValue:@(self.commentWriteView.inputTextView.selectedRange.location) forKey:PersistenceDraftTextPositionKey];

            [Persistence setValue:[draft copy] forKey:PersistenceCommentDraftKey];
            [Persistence save];
        }
    } else {
        NSDictionary *originalDraft = [Persistence valueForKey:PersistenceGroupDraftKey];
        if ([[originalDraft tt_stringValueForKey:PersistenceDraftIdentifier] isEqual:self.groupModel.groupID] || !isEmptyString(content)) {
            NSMutableDictionary *draft = [NSMutableDictionary dictionaryWithCapacity:4];
            [draft setValue:self.groupModel.groupID forKey:PersistenceDraftIdentifier];
            [draft setValue:content forKey:PersistenceDraftContentKey];
            [draft setValue:contentRichSpan forKey:PersistenceDraftRichSpanKey];
            [draft setValue:@(self.commentWriteView.inputTextView.selectedRange.location) forKey:PersistenceDraftTextPositionKey];

            [Persistence setValue:[draft copy] forKey:PersistenceGroupDraftKey];
            [Persistence save];
        }
    }
}

- (BOOL)hasBoundMobile {
    return !isEmptyString([[[TTAccount sharedAccount] user] mobile]) || self.hasUGCBoundMobile;
}

- (void)showBindingMobileViewController {
    [[TTRoute sharedRoute] openURLByPushViewController:[TTNetworkUtil URLWithURLString:@"sslocal://binding_mobile"] userInfo:TTRouteUserInfoWithDict(@{
                                                                                                                                                       @"track_params" : self.bindVCTrackDict?: @{@"source": @"comment"}
                                                                                                                                                       })];
}

- (void)bindingMobileCompleted:(NSNotification *)notification {
    BOOL finished = [notification.userInfo tt_boolValueForKey:@"finished"];
    BOOL dismissed = [notification.userInfo tt_boolValueForKey:@"dismissed"];

    if (finished) {
        self.hasUGCBoundMobile = YES;
        if (self.sendLogicBlock) {
            self.sendLogicBlock(TTCommentLoginStateMobileRegister);
        }
    } else {
        if (dismissed) {
            self.hasUGCBoundMobile = NO;
        }
    }
}


- (void)showRightImgIndicatorWithMsg:(NSString *)msg {
    [self showIndicatorMsg:msg imageName:@"doneicon_popup_textpage.png"];
}

- (void)showWrongImgIndicatorWithMsg:(NSString *)msg {
    [self showIndicatorMsg:msg imageName:@"close_popup_textpage.png"];
}

- (void)showIndicatorMsg:(NSString *)msg imageName:(NSString *)imgName {
    UIImage *tipImage = nil;
    if (!isEmptyString(imgName)) {
        tipImage = [UIImage themedImageNamed:imgName];
    }
    [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:msg indicatorImage:tipImage maxLine:0 autoDismiss:YES dismissHandler:nil];
}


#pragma mark - kvo method

- (void)postMessageFinished:(NSNotification*)notification {

    [TTIndicatorView dismissIndicators];

    _sending = NO;
    NSError *error = [[notification userInfo] objectForKey:@"error"];
    SSLog(@"%s, error:%@", __PRETTY_FUNCTION__, error);

    if ([[[notification userInfo] objectForKey:kAccountManagerUserInfoKey] objectForKey:@"inputViewClass"] != self) {
        return;
    }

    if (error) {

        NSDictionary *data = [[notification userInfo] objectForKey:@"data"];
        self.hasUGCBoundMobile = ![data tt_boolValueForKey:@"bind_mobile"];

        //其他错误
        if ([self hasBoundMobile]) {
            NSString *msg = nil;
            if ([error.domain isEqualToString:@"kCommonErrorDomain"]) {
                msg = [[error userInfo] objectForKey:@"message"];
                if (isEmptyString(msg) && error.code == 1003) {
                    msg = @"帐号已过期，请重新登录";
                }
            } else if ([error.domain isEqualToString:@"kTTNetworkErrorDomain"]) {
                msg = [data tt_stringValueForKey:@"description"];
            }

            if (isEmptyString(msg)) {
                msg = @"网络出现问题，请稍后再试";
            };

            [self showWrongImgIndicatorWithMsg:msg];
        }

        //绑定手机号
        else {
            [self showBindingMobileViewController];
        }
    }
    else {

        // 发送成功之后就清空draft
        if (!isEmptyString(self.replyToCommentID)) {
            [Persistence setValue:nil forKey:PersistenceCommentDraftKey];
            [Persistence save];
        } else {
            [Persistence setValue:nil forKey:PersistenceGroupDraftKey];
            [Persistence save];
        }

        if (self.commentWriteView.isNeedTips) {
            [self showRightImgIndicatorWithMsg:@"发布成功"];
        }

        [self.commentWriteView configureDraftContent:@"" withDraftContentRichSpan:nil withDefaultTextPosition:0];

        if ([self.delegate respondsToSelector:@selector(commentView:sucessWithCommentWriteManager:responsedData:)]) {
            [self.delegate commentView:self.commentWriteView sucessWithCommentWriteManager:self responsedData:notification.userInfo];
        }

        BOOL isZZ = [[notification userInfo] integerValueForKey:@"is_zz" defaultValue:0];
        BOOL isPGCAccount = [[PGCAccountManager shareManager] hasPGCAccount];
        if (isZZ && isPGCAccount) {

//            [[NSNotificationCenter defaultCenter] postNotificationName:@"kTTPublishCommentSuccessWithZZNotification" object:nil userInfo:notification.userInfo];
        }
    }

}


#pragma mark -- delegate method

#pragma mark -- TTCommentWriteViewDelegate

- (void)commentViewClickPublishButton {

    if (isTTArticleWritePublishing){
        return;
    }
    isTTArticleWritePublishing = YES;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        isTTArticleWritePublishing = NO;
    });

    /// 发布评论
    struct timeval currentTime;

    gettimeofday(&currentTime, NULL);
    CFTimeInterval interval = [TTBusinessManager timeIntervalFromStartTime:[self.commentWriteView commentTimeval] toEndTime:currentTime];

    TTRichSpanText *richSpanText = self.commentWriteView.inputTextView.richSpanText;
    [richSpanText trimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

    NSString *content = richSpanText.text;
    TTRichSpans *contentRichSpans = richSpanText.richSpans;
    NSString *text_rich_span = [TTRichSpans JSONStringForRichSpans:contentRichSpans];

    NSMutableArray *mentionUsers = [NSMutableArray arrayWithCapacity:richSpanText.richSpans.links.count];
    for (TTRichSpanLink *link in richSpanText.richSpans.links) {
        NSString *userId = [link.userInfo tt_stringValueForKey:@"user_id"];
        if (!isEmptyString(userId)) {
            [mentionUsers addObject:userId];
        }
    }

    [TTTrackerWrapper eventV3:@"at_function_stats" params:@{
                                                            @"group_id" : self.groupModel.groupID ?: @"",
                                                            @"at_user_list" :[mentionUsers componentsJoinedByString:@","],
                                                            @"source" : @"comment"
                                                            }];

    if (!TTNetworkConnected()) {
        [self showWrongImgIndicatorWithMsg:NSLocalizedString(@"没有网络连接，请稍后再试", nil)];
        return;
    }

    if (content.length > kCommentMaxLength) { // 非法内容， 不能发送
        [self.commentWriteView showContentTooLongTip:kCommentInputContentTooManyTip];
        return;
    }

    if (contentRichSpans && contentRichSpans.links && contentRichSpans.links.count > 20) {
        [self.commentWriteView showContentTooLongTip:kCommentInputContentAtTooManyTip];
        return;
    }

    if (_isSharePGCUser) {
        if (![TTAccountManager isLogin]) {
            [self showWrongImgIndicatorWithMsg:kCommentNoLoginTip];
            return;
        }
        [_pgcActionManager cancel];
        _pgcActionManager.delegate = nil;
        self.pgcActionManager = [[SSPGCActionManager alloc] init];
        _pgcActionManager.delegate = self;
        [_pgcActionManager sharePGCUser:_mediaID shareMsg:content];
    } else {
        if([self.groupModel.groupID length] == 0) {
            NSLog(@"commentInputView itemID length must large 0");
            return;
        }

        BOOL couldSend = YES;
        if ([self.delegate respondsToSelector:@selector(commentView:shouldCommitWithCommentWriteManager:)]) {
            couldSend = [self.delegate commentView:self.commentWriteView shouldCommitWithCommentWriteManager:self];
        }
        if (!couldSend) {
            return;
        }

        //没有内容， 没有勾选平台， 不能发送
        if([self.commentWriteView.inputTextView.text trimmed].length == 0 &&
           [[TTPlatformAccountManager sharedManager] numberOfCheckedAccounts] == 0) {
            [self showWrongImgIndicatorWithMsg:kCommentInputContentTooShortTip];
            return;
        }
        WeakSelf;
        TTCommentLoginPipelineCompletion sendLogic =  ^(TTCommentLoginState state) {
            StrongSelf;
            if (!self.sending) {
                self.sending = YES;

                if (self.commentWriteView.isNeedTips) {
                    [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleWaitingView indicatorText:kCommentSending indicatorImage:nil autoDismiss:NO dismissHandler:nil];
                }


                NSMutableDictionary * userInfo = [NSMutableDictionary dictionaryWithCapacity:10];
                [userInfo setValue:@"CommentInputView" forKey:@"ClassName"];
                [userInfo setObject:self forKey:@"inputViewClass"];
                if ([self.adID longLongValue] != 0) {
                    [userInfo setValue:self.adID forKey:@"ad_id"];
                }

                NSString *timeInterval = [NSString stringWithFormat:@"%.0f", interval];
                BOOL isRepost = self.commentWriteView.isCommentRepostedChecked;

                NSString *contentString = nil;
                NSString *contentRichSpanString = nil;

                NSString *text = content ? content :@"";

                TTRichSpanText *postRichSpanText = [[TTRichSpanText alloc] initWithText:text richSpans:richSpanText.richSpans];
                if (self.preRichSpanText) {
                    [postRichSpanText appendRichSpanText:self.preRichSpanText];

                }
                contentString = postRichSpanText.text;
                contentRichSpanString = [TTRichSpans JSONStringForRichSpans:postRichSpanText.richSpans];

                NSMutableDictionary *userInfoDic = [[NSMutableDictionary alloc] init];
                [userInfoDic setValue:self.groupModel.groupID forKey:@"group_id"];
                [userInfoDic setValue:self.replyToCommentID forKey:@"comment_id"];
                [[NSNotificationCenter defaultCenter] postNotificationName:kCommentActionNotificationKey object:nil userInfo:userInfoDic];

                NSString *fwID = nil;
                if (self.commentRepostParamsBlock) {
                    self.commentRepostParamsBlock(&fwID);
                } else {
                    NSAssert(NO, @"commentRepostParamsBlock 不能为空");
                }
                [[TTCommentDataManager sharedManager] postCommentWithGroupID:self.groupModel.groupID
                                                                   serviceID:self.serviceID
                                                                    aggrType:self.groupModel.aggrType
                                                                     itemTag:self.itemTag
                                                                     content:content
                                                             contentRichSpan:text_rich_span
                                                                 mentionUser:[mentionUsers componentsJoinedByString:@","]
                                                            replyToCommentID:self.replyToCommentID
                                                                     replyID:nil
                                                                    isRepost:isRepost
                                                               repostContent:contentString
                                                       repostContentRichSpan:contentRichSpanString
                                                                  repostFwID:fwID
                                                         commentTimeInterval:timeInterval
                                                                  staytimeMs:self.readQuality.stayTimeMs
                                                                     readPct:self.readQuality.readPct
                                                                     context:userInfo
                                                                    callback:nil];

                wrapperTrackEventWithCustomKeys(@"comment", @"write_confirm", nil, nil, self.extraTrackDict);

                NSDictionary <NSString *, NSString *> *emojis = [TTUGCEmojiParser parseEmojis:content];
                [TTUGCEmojiParser markEmojisAsUsed:emojis];
                NSArray <NSString *> *emojiIds = emojis.allKeys;
                [TTTrackerWrapper eventV3:@"emoticon_stats" params:@{
                                                                     @"item_id" : self.groupModel.itemID ?: @"",
                                                                     @"group_id" : self.groupModel.groupID ?: @"",
                                                                     @"with_emoticon_list" : (!emojiIds || emojiIds.count == 0) ? @"none" : [emojiIds componentsJoinedByString:@","],
                                                                     @"source" : @"comment"
                                                                     }];

                if (self.publishStatusForTrack == 1) {
                    self.publishStatusForTrack = 2;

                    wrapperTrackEventWithCustomKeys(@"comment", @"write_confirm_unlog_done", nil, nil, self.extraTrackDict);
                }
            }
        };

        self.sendLogicBlock = sendLogic;

        if (![TTAccountManager isLogin]) {
            if (self.publishStatusForTrack <= 1){
                self.publishStatusForTrack = 1;
                wrapperTrackEventWithCustomKeys(@"comment", @"write_confirm_unlog_done", nil, nil, _extraTrackDict);
            }

            self.commentViewStrong = self.commentWriteView;
            [self.commentWriteView.inputTextView resignFirstResponder];
            // [self dismissAnimated:NO];//隐藏键盘的黑罩，否则会导致两个黑罩叠加

            if ([TTDeviceHelper isPadDevice]) {
                [self.commentWriteView dismissAnimated:NO];
            }

            TTAccountLoginAlert *loginAlertView = [TTAccountManager showLoginAlertWithType:TTAccountLoginAlertTitleTypePost source:@"post_comment" completion:nil];
            __weak typeof(loginAlertView) weakLoginAlertView = loginAlertView;

            loginAlertView.phoneInputCompletedHandler = ^(TTAccountAlertCompletionEventType type, NSString *phoneNum) {
                if (type == TTAccountAlertCompletionEventTypeDone) {
                    //登录成功 走发送逻辑
                    if ([TTAccountManager isLogin]) {
                        sendLogic(TTCommentLoginStatePlatformLogin);
                    }
                } else if (type == TTAccountAlertCompletionEventTypeTip) {
                    UIViewController *topViewController = [TTUIResponderHelper topViewControllerFor:weakLoginAlertView];
                    [TTAccountManager presentQuickLoginFromVC:topViewController type:TTAccountLoginDialogTitleTypeDefault source:@"post_comment" isPasswordStyle:YES completion:^(TTAccountLoginState state) {

                    }];
                } else if(type == TTAccountAlertCompletionEventTypeCancel) {
                    [self.commentWriteView.inputTextView becomeFirstResponder];
                    wrapperTrackEvent(@"auth", @"comment_cancel");
                }
                self.commentViewStrong = nil;
            };
        } else {
            sendLogic(TTCommentLoginStatePlatformLogin);
        }
    }

}

- (void)commentViewShow {

    if (!self.commentWriteView.banCommentRepost) {
        NSMutableDictionary *extra = [NSMutableDictionary dictionaryWithCapacity:2];

        // 评论者mediaId,uid
        NSString *mediaID = [PGCAccountManager shareManager].currentLoginPGCAccount.mediaID;
        NSString *uid = [TTAccountManager userID];
        [extra setValue:mediaID forKey:@"media_id"];
        [extra setValue:uid forKey:@"uid"];

        [TTTrackerWrapper event:@"detail" label:@"show_recommend_to_fans" value:_groupModel.groupID extValue:_groupModel.itemID extValue2:nil dict:extra];
    }

}

- (void)commentViewDismiss {
    if (self.delegate && [self.delegate respondsToSelector:@selector(commentView:cancelledWithCommentWriteManager:)]) {
        [self.delegate commentView:self.commentWriteView cancelledWithCommentWriteManager:self];
    }
    [self saveDraft];
}

- (void)commentViewCancelPublish {
    wrapperTrackEvent(@"comment", @"write_cancel");
}


#pragma mark -- SSPGCActionManagerDelegate
- (void)actionManager:(SSPGCActionManager *)manager shareUserFinished:(NSError *)error {
    if (error) {
        NSString * tip;
        if (!TTNetworkConnected()) {
            tip = @"没有网络连接，请稍后再试";
        }
        else {
            tip = @"服务异常，请稍后重试";
        }
        [self showRightImgIndicatorWithMsg:tip];

    }
    else {
        if (self.commentWriteView.isNeedTips) {
            [self showRightImgIndicatorWithMsg:kCommentSendDone];
        }

        if ([self.delegate respondsToSelector:@selector(commentView:sucessWithCommentWriteManager:responsedData:)]) {
            [self.delegate commentView:self.commentWriteView sucessWithCommentWriteManager:self responsedData:nil];
        }
    }
}

@end
