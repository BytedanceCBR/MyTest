//
//  SSCommentInputView.m
//  Article
//
//  Created by Zhang Leonardo on 13-3-20.
//
//

#import "SSCommentInputView.h"
#import "NetworkUtilities.h"
#import "SSCommonLogic.h"
#import "NSStringAdditions.h"
#import "SSShareMessageManager.h"
#import "SSPGCActionManager.h"
#import "TTThemedAlertController.h"
#import "TTActivityShareManager.h"
#import "TTGroupModel.h"
#import <TTNetworkDefine.h>
#import <TTAccountBusiness.h>
#import <AKCommentPlugin/TTCommentDataManager.h>


@interface SSCommentInputView()<SSPGCActionManagerDelegate>

@property(nonatomic, strong) TTGroupModel *groupModel;

@property(nonatomic, copy) NSString  *mediaID;

@property(nonatomic, copy)NSString * itemTag;
@property(nonatomic, copy)NSString * replyToCommentID;
@property(nonatomic, copy)NSString * adID;
@property(nonatomic, copy)NSString * uniqueId;
@property(nonatomic, copy)NSString * shareUrl;
@property(nonatomic, copy)NSString * shareImageUrl;
@property(nonatomic, assign)BOOL hasImage;
@property(nonatomic, assign, getter = isSending)BOOL sending;
@property(nonatomic, assign)BOOL isSharePGCUser;//是否是分享PGC用户
@property(nonatomic, retain)SSPGCActionManager * pgcActionManager;
@property(nonatomic, assign)TTSharePlatformType platformType;
@property(nonatomic, assign)TTShareSourceObjectType sourceType;
@end


@implementation SSCommentInputView

- (void)dealloc
{
    self.adID = nil;
    _pgcActionManager.delegate = nil;
    self.pgcActionManager = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    self.groupModel = nil;
    self.itemTag = nil;
    self.replyToCommentID = nil;
    self.topMostViewController = nil;
    self.delegate = nil;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _hasImage = NO;
        _sending = NO;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(postMessageFinished:) name:kPostMessageFinishedNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(shareMessageFinished:) name:kShareMessageFinishedNotification object:nil];
    }
    return self;
}

#pragma mark -- Protected Method

- (void)backButtonClicked
{
    wrapperTrackEvent(@"comment", @"write_cancel");
    if(_delegate && [_delegate respondsToSelector:@selector(commentInputViewCancelled:)])
    {
        [_delegate performSelector:@selector(commentInputViewCancelled:) withObject:self];
    }
}

- (void)sendButtonClicked
{
    if(!TTNetworkConnected())
    {
        [self showWrongImgIndicatorWithMsg:kNoNetworkTipMessage];
        return;
    }
    if (![self inputContentLegal]) {//非法内容， 不能发送
        [self showContentTooLongTip];
        return;
    }
    if (_isSharePGCUser) {
        if (![TTAccountManager isLogin]) {
            [self showWrongImgIndicatorWithMsg:sNoLoginTip];
            return;
        }
        [_pgcActionManager cancel];
        _pgcActionManager.delegate = nil;
        self.pgcActionManager = [[SSPGCActionManager alloc] init];
        _pgcActionManager.delegate = self;
        [_pgcActionManager sharePGCUser:_mediaID shareMsg:self.inputTextView.text];
        
    }
    else {
        
        if(self.platformType == TTSharePlatformTypeOfMain &&
           self.groupModel.groupID && [self.groupModel.groupID length] == 0 &&
           self.sourceType != TTShareSourceObjectTypeWap && self.sourceType != TTShareSourceObjectTypeProfile) {
            NSLog(@"commentInputView itemID length must large 0");
            return;
        }
        
        BOOL couldSend = YES;
        if (_delegate && [_delegate respondsToSelector:@selector(commentInputViewWillSendMsg:)]) {
            couldSend = [_delegate commentInputViewWillSendMsg:self];
        }
        if (!couldSend) {
            return;
        }
        
        if (![TTAccountManager isLogin]) {
            [self showWrongImgIndicatorWithMsg:sNoLoginTip];
            return;
        }
        
        if (self.inputViewType != SSCommentInputViewTypeAllPlatform) {
            
            _sending = YES;
            
            id className = [SSCommentInputViewBase userAccountClassForCommentInputViewType:self.inputViewType];
            NSString * platformKey = [className platformName];
            
            [[SSShareMessageManager shareManager] shareMessageWithGroupModel:_groupModel shareText:self.inputTextView.text platformKey:platformKey uniqueId:_uniqueId adID:_adID sourceType:_sourceType platform:self.platformType shareUrl:self.shareUrl shareImageUrl:self.shareImageUrl];
            [self showIndicatorMsg:sSending imageName:nil];
        }
        else {
            if([self.inputTextView.text trimmed].length == 0 &&
               [[TTPlatformAccountManager sharedManager] numberOfCheckedAccounts] == 0)//没有内容， 没有勾选平台， 不能发送
            {
                [self showWrongImgIndicatorWithMsg:sInputContentTooShortTip];
            }
            else if (!_sending)
            {
                _sending = YES;
                
                NSMutableDictionary * userInfo = [NSMutableDictionary dictionaryWithCapacity:10];
                [userInfo setValue:@"CommentInputView" forKey:@"ClassName"];
                [userInfo setObject:self forKey:@"inputViewClass"];
                if ([_adID longLongValue] != 0) {
                    [userInfo setValue:_adID forKey:@"ad_id"];
                }
                
                NSString * shareStr = self.inputTextView.text;
                BOOL isComment = isEmptyString(shareStr) ? NO : YES;
                [[TTCommentDataManager sharedManager] postCommentWithGroupID:_groupModel.groupID
                                                                    aggrType:_groupModel.aggrType
                                                                     itemTag:_itemTag
                                                                     content:self.inputTextView.text
                                                            replyToCommentID:_replyToCommentID
                                                                     context:userInfo];
                [self showIndicatorMsg:sSending imageName:nil];
                wrapperTrackEvent(@"comment", @"write_confirm");
            }
        }

    }
}

- (void)showContentTooLongTip
{
    TTThemedAlertController *alert = [[TTThemedAlertController alloc] initWithTitle:[NSString stringWithFormat:sInputContentTooLongTip, self.designatedMaxWordsCount] message:nil preferredType:TTThemedAlertControllerTypeAlert];
    [alert addActionWithTitle:sOK actionType:TTThemedAlertActionTypeNormal actionBlock:nil];
    [alert showFrom:self.viewController animated:YES];
}

- (void)shareMessageFinished:(NSNotification *)notification
{
    _sending = NO;
    NSError * error = [[notification userInfo] objectForKey:@"error"];
    if (error) {
        
        NSString *msg = nil;
        if([error.domain isEqualToString:kCommonErrorDomain])
        {
            msg = [[error userInfo] objectForKey:kErrorDisplayMessageKey];
        }
        else if ([error.domain isEqualToString:kTTNetworkErrorDomain])
        {
            msg = [[error userInfo] objectForKey:@"description"];
        }
        
        if(isEmptyString(msg)) msg = kNetworkConnectionErrorTipMessage;
        [self showWrongImgIndicatorWithMsg:msg];
        [self sendTrackEventWithNotificationInfo:notification.userInfo result:NO];
    }
    else {
        [self showRightImgIndicatorWithMsg:sSendDone];
        [self sendTrackEventWithNotificationInfo:notification.userInfo result:YES];
        
        [self backButtonClicked];
        
    }
    
    if (_delegate != nil && [_delegate respondsToSelector:@selector(commentInputView:responsedReceived:)]) {
        [_delegate commentInputView:self responsedReceived:notification];
    }
}

- (void)postMessageFinished:(NSNotification*)notification
{
    _sending = NO;
    NSError *error = [[notification userInfo] objectForKey:@"error"];
    SSLog(@"%s, error:%@", __PRETTY_FUNCTION__, error);
    
    if ([[[notification userInfo] objectForKey:kAccountManagerUserInfoKey] objectForKey:@"inputViewClass"] != self) {
        return;
    }
    
    if(error)
    {
        NSString *msg = nil;
        if([error.domain isEqualToString:kCommonErrorDomain])
        {
            msg = [[error userInfo] objectForKey:kErrorDisplayMessageKey];
        }
        
        if(isEmptyString(msg)) msg = kNetworkConnectionErrorTipMessage;
        [self showWrongImgIndicatorWithMsg:msg];
    }
    else
    {
        [self showRightImgIndicatorWithMsg:sSendDone];
        
        if (_delegate != nil && [_delegate respondsToSelector:@selector(commentInputView:responsedReceived:)]) {
            [_delegate commentInputView:self responsedReceived:notification];
        }
        [self backButtonClicked];
        
    }
}

#pragma mark -- Track

- (void)sendTrackEventWithNotificationInfo:(NSDictionary *)userInfo result:(BOOL)success
{
    if (self.platformType == TTSharePlatformTypeOfMain || self.platformType == TTSharePlatformTypeOfForumPlugin) {
        if (_isSharePGCUser) {
            NSString *platform;
            if (self.inputViewType == SSCommentInputViewTypeSinaWeibo) {
                platform = @"weibo";
            }
            else if (self.inputViewType == SSCommentInputViewTypeQQWeibo) {
                platform = @"tweibo";
            }
            else if (self.inputViewType == SSCommentInputViewTypeRenren) {
                platform = @"renren";
            }
            else {
                platform = @"others";
            }
            
            NSString *label = [NSString stringWithFormat:@"share_%@", platform];
            if (success) {
                label = [label stringByAppendingString:@"_done"];
            }
            else {
                label = [label stringByAppendingString:@"_fail"];
            }
            wrapperTrackEventWithCustomKeys(@"pgc_profile", label, _mediaID, nil, nil);
        }
        else {
            if (!_topMostViewController) {
                return;
            }
            NSString *tag;
            if (self.platformType == TTSharePlatformTypeOfMain) {
                if ([_topMostViewController isKindOfClass:NSClassFromString(@"NewsDetailViewController")] ||
                    [_topMostViewController isKindOfClass:NSClassFromString(@"EssayDetailViewController")]) {
                    tag = @"detail_share";
                }
                else {
                    tag = @"list_share";
                }
            }else {
                tag = [TTActivityShareManager tagNameForShareSourceObjectType:self.sourceType];
            }
            NSString *platform = userInfo[@"platform"];
            //根据产品需求，新浪微博的统计tag使用weibo，不使用sina_weibo
            if (self.inputViewType == SSCommentInputViewTypeSinaWeibo) {
                platform = @"weibo";
            }
            NSString *label = [NSString stringWithFormat:@"share_%@", platform];
            if (success) {
                label = [label stringByAppendingString:@"_done"];
            }
            else {
                label = [label stringByAppendingString:@"_fail"];
            }
            NSMutableDictionary *extraDic = [NSMutableDictionary dictionary];
            if (!isEmptyString(_adID)) {
                extraDic[@"ad_id"] = _adID;
            }
            if (!isEmptyString(_groupModel.groupID)) {
                [extraDic setValue:_groupModel.itemID forKey:@"item_id"];
                [extraDic setValue:@(_groupModel.aggrType) forKey:@"aggr_type"];
            }
            
            if (userInfo[@"error"]) {
                [extraDic setValue:userInfo[@"error"] forKey:@"error"];
                
            }
            if (self.platformType == TTSharePlatformTypeOfMain) {
                wrapperTrackEventWithCustomKeys(tag, label, _groupModel.groupID, nil, extraDic);
            }else {
                [TTTrackerWrapper category:@"umeng" event:tag label:label dict:@{@"source":self.uniqueId}];
            }
            self.topMostViewController = nil;
        }
    }
    self.topMostViewController = nil;
}

#pragma mark -- life cycle


- (void)willAppear
{
    [super willAppear];
    [self.inputTextView becomeFirstResponder];
}

- (void)setCondition:(NSDictionary *)conditions
{
    self.isSharePGCUser = [[conditions objectForKey:kQuickInputViewConditionIsSharePGCUser] boolValue];
    if (_isSharePGCUser) {
        self.tipLabel.text = sCommentInputViewSharePGCUserTip;
    }
    self.groupModel = [conditions objectForKey:kQuickInputViewConditionGroupModel];
    self.mediaID = conditions[kQuickInputViewConditionMediaID];
    
    if ([conditions objectForKey:kQuickInputViewConditionItemTag]) {
        self.itemTag = [NSString stringWithFormat:@"%@", [conditions objectForKey:kQuickInputViewConditionItemTag]];
    }
    else {
        self.itemTag = nil;
    }
    
    if ([[conditions allKeys] containsObject:kQuickInputViewConditionADIDKey]) {
        self.adID = [NSString stringWithFormat:@"%@", [conditions objectForKey:kQuickInputViewConditionADIDKey]];
    }
    else {
        self.adID = nil;
    }
    
    if ([[conditions allKeys] containsObject:kQuickInputViewConditionUniqueId]) {
        self.uniqueId = [NSString stringWithFormat:@"%@", [conditions objectForKey:kQuickInputViewConditionUniqueId]];
    }else {
        self.uniqueId = nil;
    }
    
    if ([conditions objectForKey:kQuickInputViewConditionReplyToCommentID]) {
        self.replyToCommentID = [conditions objectForKey:kQuickInputViewConditionReplyToCommentID];
    }
    else {
        self.replyToCommentID = nil;
    }
    
    self.hasImage = [[conditions objectForKey:kQuickInputViewConditionHasImageKey] boolValue];
    
    self.platformType = [[conditions objectForKey:kQuickInputViewCOnditionPlatformType] integerValue];
    if (_platformType == TTSharePlatformTypeOfForumPlugin || _platformType == TTSharePlatformTypeOfHTSLivePlugin) {
        //来自话题插件的分享占位符需要为空
        self.inputTextView.placeHolder = nil;
    }
    
    self.sourceType = [[conditions objectForKey:kQuickInputViewConditionShareSourceObjectType] integerValue];
    
    NSString * content = nil;
    if ([conditions objectForKey:kQuickInputViewConditionInputViewText]) {
        content = [conditions objectForKey:kQuickInputViewConditionInputViewText];
    }
    else {
        content = nil;
    }
    
    
    if ([conditions objectForKey:kQuickInputViewConditionShareUrl]) {
        self.shareUrl = [conditions objectForKey:kQuickInputViewConditionShareUrl];
    }
    if ([conditions objectForKey:kQuickInputViewConditionShareImageUrl]) {
        self.shareImageUrl = [conditions objectForKey:kQuickInputViewConditionShareImageUrl];
    }
    self.inputTextView.text = content;
    [self.inputTextView showOrHidePlaceHolderTextView];
}

- (void)setInputViewType:(SSCommentInputViewType)inputViewType
{
    [super setInputViewType:inputViewType];
}

- (void)setHasImage:(BOOL)hasImage
{
    _hasImage = hasImage;
    
    if (!_isSharePGCUser) {
        if (self.inputViewType != SSCommentInputViewTypeAllPlatform) {
            if (_hasImage) {
                self.tipLabel.text = sCommentInputHasLinkAndImgTip;
            }
            else {
                self.tipLabel.text = sCommentInputHasLinkTip;
            }
        }
    }
    else {
        self.tipLabel.text = sCommentInputViewSharePGCUserTip;
    }
}

#pragma mark -- SSPGCActionManagerDelegate

- (void)actionManager:(id)manager shareUserFinished:(NSError *)error
{
    
    if (error) {
        NSString * tip;
        if (!TTNetworkConnected()) {
            tip = kNoNetworkTipMessage;
        }
        else {
            tip = kExceptionTipMessage;
        }
        [self showRightImgIndicatorWithMsg:tip];
        [self sendTrackEventWithNotificationInfo:nil result:NO];
    }
    else {
        [self showRightImgIndicatorWithMsg:sSendDone];
        [self sendTrackEventWithNotificationInfo:nil result:YES];
        
        if (_delegate != nil && [_delegate respondsToSelector:@selector(commentInputView:responsedReceived:)]) {
            [_delegate commentInputView:self responsedReceived:nil];
        }
        
        [self backButtonClicked];
        
    }
}

@end

