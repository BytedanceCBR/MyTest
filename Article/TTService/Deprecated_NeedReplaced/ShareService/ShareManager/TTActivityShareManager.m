//
//  TTActivityShareManager.m
//  Article
//
//  Created by 王霖 on 15/9/20.
//
//

#import "TTActivityShareManager.h"
#import "TTQQShare.h"
#import <TTWeChatShare.h>
//#import <TTAliShare.h>
//#import <TTDingTalkShare.h>
//#import <TTMailShare.h>
//#import <TTMessageShare.h>
#import "TTShareConstants.h"

#import <Social/Social.h>
#import <TTAccountBusiness.h>
#import <TTPlatformExpiration.h>
#import "TTThemedAlertController.h"
#import "NetworkUtilities.h"
#import "TTNavigationController.h"

#import "DetailActionRequestManager.h"
#import "CommentInputViewController.h"

#import "TTBaseMacro.h"
#import "SSCommonLogic.h"
#import "TTIndicatorView.h"
#import "UIImage+TTThemeExtension.h"
#import "TTProjectLogicManager.h"
#import "TTDeviceHelper.h"

#import "ExploreMomentDefine.h"

#import "TTRoute.h"

#import "TTInstallIDManager.h"
#import "UIView+SupportFullScreen.h"

#import "TTVShareActionsTracker.h"
#import "TTVShareDetailTracker.h"
#import "TTActivityShareSequenceManager.h"
#import "TTVSettingsConfiguration.h"
#import "TTRShare.h"
#import "TTWeChatShare+TTService.h"

#define kWeixinExtShareLocalUrlKey  @"localUrl"

extern BOOL ttvs_isShareIndividuatioEnable(void);
extern BOOL ttvs_isTitanVideoBusiness(void);
extern NSInteger ttvs_isShareTimelineOptimize(void);

@interface _TTShareManagerSendSNSObject : NSObject<CommentInputViewControllerDelegate>

@property(nonatomic, retain)UIViewController * controller;

@property(nonatomic, retain)NSString * uniqueId;
@property(nonatomic, retain)NSString * adID;
@property(nonatomic, retain)TTGroupModel *groupModel;
@property(nonatomic, copy)NSString *mediaID;
@property(nonatomic, copy)NSString * itemTag;
@property(nonatomic, copy)NSString * platformKey;
@property(nonatomic, copy)NSString * message;
@property(nonatomic, copy)NSString * shareURL;
@property(nonatomic, copy)NSString * shareImageURL;
@property(nonatomic, assign)BOOL hasImage;
@property(nonatomic, assign)BOOL isSharePGCUser;
@property(nonatomic, assign)TTShareSourceObjectType sourceType;
@property(nonatomic, assign)TTSharePlatformType platformType;

@property(nonatomic, retain) TTThirdPartyAccountInfoBase *accountInfoBase;

@property(nonatomic, retain)CommentInputViewController *phoneCommentInputController;

@property(nonatomic, assign)TTActivityType currentActivityType;

- (void)clear;

- (void)sendMessage;

@end

@implementation _TTShareManagerSendSNSObject

- (instancetype)init {
    self = [super init];
    if (self) {
    }
    return self;
}

- (void)dealloc {
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
}

- (void)clear {
    self.isSharePGCUser = NO;
    
    [_accountInfoBase removeObserver:self forKeyPath:@"accountStatus"];
    
    self.uniqueId = nil;
    self.adID = nil;
    self.groupModel = nil;
    self.mediaID = nil;
    self.itemTag = nil;
    self.platformKey = nil;
    self.message = nil;
    self.shareURL = nil;
    self.shareImageURL = nil;
    self.hasImage = NO;
    
    self.accountInfoBase = nil;
    self.controller = nil;
    self.phoneCommentInputController = nil;
}

- (void)sendMessage {
    if (![[TTPlatformAccountManager sharedManager] isBoundedPlatformForKey:_platformKey]) {
        [self login];
    }
    else {
        [self _sendMessage];
    }
}

- (void)_sendMessage {
    
    if (!TTNetworkConnected()) {
        [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:NSLocalizedString(@"没有网络连接，不能转发", nil) indicatorImage:[UIImage themedImageNamed:@"close_popup_textpage.png"] autoDismiss:YES dismissHandler:nil];
        return;
    }
    
    if (isEmptyString(_platformKey)
        || (_platformType == TTSharePlatformTypeOfMain && _groupModel.groupID == 0 && self.sourceType != TTShareSourceObjectTypeWap && self.sourceType != TTShareSourceObjectTypeProfile)
        || (_platformType == TTSharePlatformTypeOfHTSLivePlugin && _groupModel.groupID == 0)
        || _controller == nil) {
        return;
    }
    
    NSMutableDictionary * condition = [NSMutableDictionary dictionaryWithCapacity:10];
    
    if (_isSharePGCUser) {
        [condition setValue:_mediaID forKey:kQuickInputViewConditionMediaID];
        [condition  setValue:_message forKey:kQuickInputViewConditionInputViewText];
        [condition setValue:@1 forKey:kQuickInputViewConditionIsSharePGCUser];
    }
    else {
        if (_groupModel.groupID != 0) {
            [condition setValue:_groupModel forKey:kQuickInputViewConditionGroupModel];
        }
        [condition setValue:_itemTag forKey:kQuickInputViewConditionItemTag];
        [condition  setValue:_message forKey:kQuickInputViewConditionInputViewText];
        [condition setValue:@(_hasImage) forKey:kQuickInputViewConditionHasImageKey];
        [condition setValue:_adID forKey:kQuickInputViewConditionADIDKey];
        [condition setValue:_uniqueId forKey:kQuickInputViewConditionUniqueId];
        [condition setValue:@(_platformType) forKey:kQuickInputViewCOnditionPlatformType];
        [condition setValue:@(_sourceType) forKey:kQuickInputViewConditionShareSourceObjectType];
    }
    [condition setValue:_shareURL forKey:kQuickInputViewConditionShareUrl];
    [condition setValue:_shareImageURL forKey:kQuickInputViewConditionShareImageUrl];
    
    if (!_phoneCommentInputController) {
        Class class = NSClassFromString(TTLogicStringNODefault(@"ArticleShareViewController"));
        if (!class) {
            class = [CommentInputViewController class];
        }
        NSInteger maxSinaWeiboWordsCount = 140;
        self.phoneCommentInputController = [[class alloc] initWithMaxWordsCount:maxSinaWeiboWordsCount];
    }
    
    if ([self.phoneCommentInputController respondsToSelector:@selector(commentInputView)]) {
        [_phoneCommentInputController.commentInputView setInputTypeByPlatformKey:_platformKey];
        [_phoneCommentInputController.commentInputView setCondition:condition];
        _phoneCommentInputController.commentInputView.topMostViewController = _controller;
    }
    if ([self.phoneCommentInputController respondsToSelector:@selector(setDelegate:)]) {
        _phoneCommentInputController.delegate = self;
    }
    TTNavigationController *nav = [[TTNavigationController alloc] initWithRootViewController:_phoneCommentInputController];
    nav.ttDefaultNavBarStyle = @"White";
    [_controller presentViewController:nav animated:YES completion:NULL];
    
    [self clear];
}

- (void)login {
    [_accountInfoBase removeObserver:self forKeyPath:@"accountStatus"];
    self.accountInfoBase = nil;
    
    for (TTThirdPartyAccountInfoBase * infoBase in [[TTPlatformAccountManager sharedManager] platformAccounts]) {
        if ([infoBase.keyName isEqualToString:_platformKey]) {
            self.accountInfoBase = infoBase;
            break;
        }
    }
    
    [_accountInfoBase addObserver:self forKeyPath:@"accountStatus" options:NSKeyValueObservingOptionNew context:nil];
    
    [TTAccountLoginManager requestLoginPlatformByName:_platformKey completion:^(BOOL success, NSError *error) {
        
    }];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if([keyPath isEqualToString:@"accountStatus"]) {
        TTThirdPartyAccountStatus status = [[change objectForKey:NSKeyValueChangeNewKey] intValue];
        if (status == TTThirdPartyAccountStatusBounded || status == TTThirdPartyAccountStatusChecked) {
            [self performSelector:@selector(_sendMessage) withObject:nil afterDelay:1.f];//等登录框退出
        }
        [_accountInfoBase removeObserver:self forKeyPath:@"accountStatus"];
        self.accountInfoBase = nil;
    }
}

#pragma mark - CommentInputViewControllerDelegate
- (void)commentInputViewController:(CommentInputViewController*)controller responsedReceived:(NSNotification*)notification {
    
    if (controller == _phoneCommentInputController) {
        
        [_phoneCommentInputController dismissViewControllerAnimated:YES completion:NULL];
        
        _phoneCommentInputController.commentInputView.delegate = nil;
        _phoneCommentInputController.commentInputView = nil;
        
        _phoneCommentInputController.delegate = nil;
        self.phoneCommentInputController = nil;
        
    }
    
}
@end

@interface TTActivityShareManager ()<TTWeChatShareDelegate, TTWeChatShareTTServiceDelegate, TTQQShareDelegate>
//@interface TTActivityShareManager ()<TTWeChatShareDelegate, TTWeChatShareTTServiceDelegate, TTQQShareDelegate, TTAliShareDelegate, TTDingTalkShareDelegate, TTMailShareDelegate>


@property(nonatomic, strong)NSMutableArray * customActivities;

@property(nonatomic, strong)DetailActionRequestManager *actionManager;

@property(nonatomic, retain)DetailActionRequestManager * itemRequestManager;
//send to sns
@property(nonatomic, retain)_TTShareManagerSendSNSObject * sendSNSObject;

@property(nonatomic, assign)TTActivityType activityType;
@property(nonatomic, assign)TTShareSourceObjectType sourceType;
@property(nonatomic, assign)TTSharePlatformType platformType;
@property(nonatomic, copy)NSString *uniqueId;

@property (nonatomic, strong) UIPopoverController * popOverController;

@end

@implementation TTActivityShareManager


- (instancetype)init {
    self = [super init];
    if (self) {
        self.customActivities = [NSMutableArray arrayWithCapacity:20];
        self.sendItemActionStatistics = YES;
    }
    return self;
}

- (NSMutableArray *)defaultShareItems {
    return _customActivities;
}

- (void)clearCondition {
    self.isShareMedia = NO;
    self.sendItemActionStatistics = YES;
    self.weixinText = nil;
    self.weixinTitleText = nil;
    self.weixinMomentText = nil;
    self.qqShareText = nil;
    self.sinaWeiboText = nil;
    self.messageText = nil;
    self.mailSubject = nil;
    self.mailBody = nil;
    self.mailData = nil;
    self.mailBodyIsHTML = NO;
    self.systemShareUrl = nil;
    self.systemShareText = nil;
    self.systemShareImage = nil;
    self.copyText = nil;
    self.facebookText = nil;
    self.twitterText = nil;
    self.copyText = nil;
    self.copyContent = nil;
    self.hasImg = NO;
    self.itemTag = nil;
    self.mediaID = nil;
    self.groupModel = nil;
    self.shareImage = nil;
    self.shareToWeixinMomentOrQZoneImage = nil;
    self.shareURL = nil;
    self.qqZoneText = nil;
    [_customActivities removeAllObjects];
}

- (void)refreshActivitys
{
    [self refreshActivitysWithReport:YES];
}

- (void)refreshActivitysForProfileWithAccountUser:(BOOL)isAccountUser isBlocking:(BOOL)isBlocking {
    if ((isEmptyString(_mediaID) && isEmptyString(_groupModel.groupID)) || isEmptyString(_shareURL)) {
        SSLog(@"%@", NSLocalizedString(@"TTActivityShareManager 参数丢失", nil));
    }
    [_customActivities removeAllObjects];
    
    if(ttvs_isShareIndividuatioEnable()) {
        NSArray *activityArray = [[TTActivityShareSequenceManager sharedInstance_tt] getAllShareActivitySequence];
        [activityArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj isKindOfClass:[NSNumber class]]) {
                TTActivityType objType = [obj integerValue];
                
                if (objType == TTActivityTypeWeixinMoment) {
                    if (!isEmptyString(_weixinMomentText)) {
                        TTActivity * weixinMomentActivity = [TTActivity activityOfWeixinMoment];
                        [_customActivities addObject:weixinMomentActivity];
                    }
                }
                if (objType == TTActivityTypeWeixinShare) {
                    if (!isEmptyString(_weixinText) && !isEmptyString(_weixinTitleText)) {
                        TTActivity * weixinActivity = [TTActivity activityOfWeixin];
                        [_customActivities addObject:weixinActivity];
                    }
                    
                }
                if (objType == TTActivityTypeQQShare){
                    if (!isEmptyString(_qqShareText) && !isEmptyString(_qqShareTitleText)) {
                        TTActivity * qqActivity = [TTActivity activityOfQQShare];
                        [_customActivities addObject:qqActivity];
                    }
                }
                if (objType == TTActivityTypeQQZone) {
                    if (!isEmptyString(_qqShareText) && !isEmptyString(_qqShareTitleText) ) {
                        TTActivity * qqZoneActivity = [TTActivity activityOfQQZoneShare];
                        [_customActivities addObject:qqZoneActivity];
                    }
                }
                if (objType == TTActivityTypeDingTalk) {
                    if (!isEmptyString(_dingtalkText) && !isEmptyString(_dingtalkTitleText)) {
                        TTActivity *dingtalkActivity = [TTActivity activityOfDingTalk];
                        [_customActivities addObject:dingtalkActivity];
                    }
                }
            }
        }];
        
    }else{
        //微信动态
        if (!isEmptyString(_weixinMomentText)) {
            TTActivity * weixinMomentActivity = [TTActivity activityOfWeixinMoment];
            [_customActivities addObject:weixinMomentActivity];
        }
        //微信好友
        if (!isEmptyString(_weixinText) && !isEmptyString(_weixinTitleText)) {
            TTActivity * weixinActivity = [TTActivity activityOfWeixin];
            [_customActivities addObject:weixinActivity];
        }
        //qq好友
        if (!isEmptyString(_qqShareText) && !isEmptyString(_qqShareTitleText) && [[TTQQShare sharedQQShare] isAvailable]) {
            TTActivity * qqActivity = [TTActivity activityOfQQShare];
            [_customActivities addObject:qqActivity];
        }
        //qq空间
        if (!isEmptyString(_qqShareText) && !isEmptyString(_qqShareTitleText) && [[TTQQShare sharedQQShare] isAvailable]) {
            TTActivity * qqZoneActivity = [TTActivity activityOfQQZoneShare];
            [_customActivities addObject:qqZoneActivity];
        }
        
//        // 钉钉
//        if (!isEmptyString(_dingtalkText) && !isEmptyString(_dingtalkTitleText) && [[TTDingTalkShare sharedDingTalkShare] isAvailable]) {
//            TTActivity *dingtalkActivity = [TTActivity activityOfDingTalk];
//            [_customActivities addObject:dingtalkActivity];
//        }
        
    }
    //系统分享
    if (!isEmptyString(_systemShareUrl)) {
        TTActivity * systemActivity = [TTActivity activityOfSystem];
        [_customActivities addObject:systemActivity];
    }
    
    //短信
    if (!isEmptyString(_messageText) && ![TTDeviceHelper isPadDevice]) {
        TTActivity * message = [TTActivity activityOfMessageShare];
        [_customActivities addObject:message];
    }
    //邮件
    if (!isEmptyString(_mailBody)) {
        TTActivity * mail = [TTActivity activityOfMailShare];
        [_customActivities addObject:mail];
    }
    
    if (TTLogicBool(@"isI18NVersion", NO)) {
        //facebook
        if (!isEmptyString(_facebookText) && [SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook]) {
            TTActivity * facebook = [TTActivity activityOfFacebookShare];
            [_customActivities addObject:facebook];
        }
        //twitter
        if (!isEmptyString(_twitterText) && [SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter]) {
            TTActivity * facebook = [TTActivity activityOfTwitterShare];
            [_customActivities addObject:facebook];
        }
    }
    //复制正文
    if (!isEmptyString(_copyContent)) {
        TTActivity * copyActivity = [TTActivity activityOfCopyContent];
        [_customActivities addObject:copyActivity];
    }
    //复制链接
    if (!isEmptyString(_copyText)) {
        TTActivity * copyActivity = [TTActivity activityOfCopy];
        [_customActivities addObject:copyActivity];
    }
    
    if (!isAccountUser) {
        //举报
        TTActivity *reportActivity = [TTActivity activityOfReport];
        [_customActivities addObject:reportActivity];
        
        // 拉黑
        if (!isBlocking) {
            TTActivity *blockUserActivity = [TTActivity activityOfBlockUser];
            [_customActivities addObject:blockUserActivity];
        } else {
            TTActivity *unblockUserActivity = [TTActivity activityOfUnBlockUser];
            [_customActivities addObject:unblockUserActivity];
        }
        
        // 夜间模式
        TTActivity *nightMode = [TTActivity activityOfNightMode];
        [_customActivities addObject:nightMode];
        
        //        // 字体设置
        //        TTActivity *fontSetting = [TTActivity activityOfFontSetting];
        //        [_customActivities addObject:fontSetting];
    } else {
        // 夜间模式
        TTActivity *nightMode = [TTActivity activityOfNightMode];
        [_customActivities addObject:nightMode];
        
        //        // 字体设置
        //        TTActivity *fontSetting = [TTActivity activityOfFontSetting];
        //        [_customActivities addObject:fontSetting];
    }
    
    //如果没有图片， 微信分享将有问题
    if (self.shareImage == nil) {
        self.shareImage = [UIImage imageNamed:@"Icon.png"];
    }
}

- (void)refreshActivitysWithReport:(BOOL)containReport
{
    [self refreshActivitysWithReport:containReport withQQ:NO];
}

- (void)refreshActivitysWithReport:(BOOL)containReport withQQ:(BOOL)qq
{
    
    if ((isEmptyString(_mediaID) && isEmptyString(_groupModel.groupID)) || isEmptyString(_shareURL)) {
        SSLog(@"%@", NSLocalizedString(@"TTActivityShareManager 参数丢失", nil));
    }
    
    [_customActivities removeAllObjects];
    
    if(ttvs_isShareIndividuatioEnable()) {
        NSArray *activityArray = [[TTActivityShareSequenceManager sharedInstance_tt] getAllShareActivitySequence];
        [activityArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj isKindOfClass:[NSNumber class]]) {
                TTActivityType objType = [obj integerValue];
                if (objType == TTActivityTypeWeitoutiao) {
                    if (self.forwardToWeitoutiao) {
                        TTActivity * weitoutiao = [TTActivity activityOfWeitoutiao];
                        [_customActivities addObject:weitoutiao];
                    }
                }
                if (objType == TTActivityTypeWeixinMoment) {
                    if (!isEmptyString(_weixinMomentText)) {
                        TTActivity * weixinMomentActivity = [TTActivity activityOfWeixinMoment];
                        [_customActivities addObject:weixinMomentActivity];
                    }
                }
                if (objType == TTActivityTypeWeixinShare) {
                    if (!isEmptyString(_weixinText) && !isEmptyString(_weixinTitleText)) {
                        TTActivity * weixinActivity = [TTActivity activityOfWeixin];
                        [_customActivities addObject:weixinActivity];
                    }
                    
                }
                if (objType == TTActivityTypeQQShare){
                    if (!isEmptyString(_qqShareText) && !isEmptyString(_qqShareTitleText)) {
                        TTActivity * qqActivity = [TTActivity activityOfQQShare];
                        [_customActivities addObject:qqActivity];
                    }
                }
                if (objType == TTActivityTypeQQZone) {
                    if (!isEmptyString(_qqShareText) && !isEmptyString(_qqShareTitleText) ) {
                        TTActivity * qqZoneActivity = [TTActivity activityOfQQZoneShare];
                        [_customActivities addObject:qqZoneActivity];
                    }
                }
                if (objType == TTActivityTypeDingTalk) {
                    if (!isEmptyString(_dingtalkText) && !isEmptyString(_dingtalkTitleText)) {
                        TTActivity *dingtalkActivity = [TTActivity activityOfDingTalk];
                        [_customActivities addObject:dingtalkActivity];
                    }
                }
            }
        }];
        
    }else{
        //微头条
        if (self.forwardToWeitoutiao) {
            TTActivity * weitoutiao = [TTActivity activityOfWeitoutiao];
            [_customActivities addObject:weitoutiao];
        }
        
        //微信动态
        if (!isEmptyString(_weixinMomentText)) {
            TTActivity * weixinMomentActivity = [TTActivity activityOfWeixinMoment];
            [_customActivities addObject:weixinMomentActivity];
        }
        //微信好友
        if (!isEmptyString(_weixinText) && !isEmptyString(_weixinTitleText)) {
            TTActivity * weixinActivity = [TTActivity activityOfWeixin];
            [_customActivities addObject:weixinActivity];
        }
        // qq:无论安装qq与否都生成qq／qq空间分享activity
        if (qq) {
            if (!isEmptyString(_qqShareText) && !isEmptyString(_qqShareTitleText)) {
                TTActivity * qqActivity = [TTActivity activityOfQQShare];
                [_customActivities addObject:qqActivity];
            }
            //qq空间 && [[TTQQShare sharedQQShare] isAvailable]
            if (!isEmptyString(_qqShareText) && !isEmptyString(_qqShareTitleText) ) {
                TTActivity * qqZoneActivity = [TTActivity activityOfQQZoneShare];
                [_customActivities addObject:qqZoneActivity];
            }
        }else {
            if (!isEmptyString(_qqShareText) && !isEmptyString(_qqShareTitleText) && [[TTQQShare sharedQQShare] isAvailable]) {
                TTActivity * qqActivity = [TTActivity activityOfQQShare];
                [_customActivities addObject:qqActivity];
            }
            //qq空间
            if (!isEmptyString(_qqShareText) && !isEmptyString(_qqShareTitleText) && [[TTQQShare sharedQQShare] isAvailable]) {
                TTActivity * qqZoneActivity = [TTActivity activityOfQQZoneShare];
                [_customActivities addObject:qqZoneActivity];
            }
            
        }
        //    新浪微博
        //        if (!isEmptyString(_sinaWeiboText)) {
        //            TTActivity * sinaWeiboActivity = [TTActivity activityOfSinaWeiboShare];
        //            [_customActivities addObject:sinaWeiboActivity];
        //        }
        //    腾讯微博
        //        if (!isEmptyString(_tencentWeiboText)) {
        //            TTActivity * qqWeiboActivity = [TTActivity activityOfQQWeiboShare];
        //            [_customActivities addObject:qqWeiboActivity];
        //        }
        
//        //钉钉
//        if (!isEmptyString(_dingtalkText) && !isEmptyString(_dingtalkTitleText) && [[TTDingTalkShare sharedDingTalkShare] isAvailable]) {
//            TTActivity *dingtalkActivity = [TTActivity activityOfDingTalk];
//            [_customActivities addObject:dingtalkActivity];
//        }
        
        //支付宝
        //    if (!isEmptyString(_zhifubaoText) && !isEmptyString(_zhifubaoTitleText) && [[TTAliShare sharedAliShare] isAvailable]) {
        //        TTActivity * zhifubaoActivity = [TTActivity activityOfZhiFuBao];
        //        [_customActivities addObject:zhifubaoActivity];
        //    }
        
    }
    //系统分享
    if (!isEmptyString(_systemShareUrl)) {
        TTActivity * systemActivity = [TTActivity activityOfSystem];
        [_customActivities addObject:systemActivity];
    }
    
    //短信
    if (!isEmptyString(_messageText) && ![TTDeviceHelper isPadDevice]) {
        TTActivity * message = [TTActivity activityOfMessageShare];
        [_customActivities addObject:message];
    }
    //邮件
    if (!isEmptyString(_mailBody)) {
        TTActivity * mail = [TTActivity activityOfMailShare];
        [_customActivities addObject:mail];
    }
    
    if (TTLogicBool(@"isI18NVersion", NO)) {
        //facebook
        if (!isEmptyString(_facebookText) && [SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook]) {
            TTActivity * facebook = [TTActivity activityOfFacebookShare];
            [_customActivities addObject:facebook];
        }
        //twitter
        if (!isEmptyString(_twitterText) && [SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter]) {
            TTActivity * facebook = [TTActivity activityOfTwitterShare];
            [_customActivities addObject:facebook];
        }
    }
    //复制正文
    if (!isEmptyString(_copyContent)) {
        TTActivity * copyActivity = [TTActivity activityOfCopyContent];
        [_customActivities addObject:copyActivity];
    }
    //复制链接
    if (!isEmptyString(_copyText)) {
        TTActivity * copyActivity = [TTActivity activityOfCopy];
        [_customActivities addObject:copyActivity];
    }
    
    if (containReport) {
        //举报
        TTActivity * reportActivity = [TTActivity activityOfReport];
        [_customActivities addObject:reportActivity];
    }
    
    //如果没有图片， 微信分享将有问题
    if (self.shareImage == nil) {
        self.shareImage = [UIImage imageNamed:@"Icon.png"];
    }
}

- (void)refreshActivitysForSingleGallery
{
    [_customActivities removeAllObjects];
    
    if(ttvs_isShareIndividuatioEnable()) {
        NSArray *activityArray = [[TTActivityShareSequenceManager sharedInstance_tt] getAllShareActivitySequence];
        [activityArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj isKindOfClass:[NSNumber class]]) {
                TTActivityType objType = [obj integerValue];
                
                if (objType == TTActivityTypeWeixinMoment) {
                    if (_shareImageStyleImage || !isEmptyString(_shareImageStyleImageURL)) {
                        TTActivity * weixinMomentActivity = [TTActivity activityOfWeixinMoment];
                        [_customActivities addObject:weixinMomentActivity];
                    }
                }
                if (objType == TTActivityTypeWeixinShare) {
                    if (_shareImageStyleImage || !isEmptyString(_shareImageStyleImageURL)) {
                        TTActivity * weixinActivity = [TTActivity activityOfWeixin];
                        [_customActivities addObject:weixinActivity];
                    }
                    
                }
                if (objType == TTActivityTypeQQShare){
                    if (_shareImageStyleImage) {
                        TTActivity * qqActivity = [TTActivity activityOfQQShare];
                        [_customActivities addObject:qqActivity];
                    }
                }
                if (objType == TTActivityTypeDingTalk) {
                    if (_shareImageStyleImage) {
                        TTActivity *dingtalkActivity = [TTActivity activityOfDingTalk];
                        [_customActivities addObject:dingtalkActivity];
                    }
                }
            }
        }];
        
    }else{
        
        //微信动态
        if (_shareImageStyleImage || !isEmptyString(_shareImageStyleImageURL)) {
            TTActivity * weixinMomentActivity = [TTActivity activityOfWeixinMoment];
            [_customActivities addObject:weixinMomentActivity];
        }
        //微信好友
        if (_shareImageStyleImage || !isEmptyString(_shareImageStyleImageURL)) {
            TTActivity * weixinActivity = [TTActivity activityOfWeixin];
            [_customActivities addObject:weixinActivity];
        }
        //qq好友,不支持url分享
        if (_shareImageStyleImage && [[TTQQShare sharedQQShare] isAvailable]) {
            TTActivity * qqActivity = [TTActivity activityOfQQShare];
            [_customActivities addObject:qqActivity];
        }
        //    //qq空间
        //    if (_shareImageStyleImage && [TTQQShare checkQQSupport]) {
        //        TTActivity * qqZoneActivity = [TTActivity activityOfQQZoneShare];
        //        [_customActivities addObject:qqZoneActivity];
        //    }
        //支付宝
        //    if ((_shareImageStyleImage || !isEmptyString(_shareImageStyleImageURL)) && [[TTAliShare sharedAliShare] isAvailable]) {
        //        TTActivity * zhifubaoActivity = [TTActivity activityOfZhiFuBao];
        //        [_customActivities addObject:zhifubaoActivity];
        //    }
        //    //支付宝生活圈
        //    if ((_shareImageStyleImage || !isEmptyString(_shareImageStyleImageURL)) && [TTZhiFuBao isSupportShareTimeLine]) {
        //        TTActivity * zhifubaoActivity = [TTActivity activityOfZhiFuBaoMoment];
        //        [_customActivities addObject:zhifubaoActivity];
        //    }
        
//        // 钉钉
//        if (_shareImageStyleImage && [[TTDingTalkShare sharedDingTalkShare] isAvailable]) {
//            TTActivity *dingtalkActivity = [TTActivity activityOfDingTalk];
//            [_customActivities addObject:dingtalkActivity];
//        }
        
    }
}

//无uniqueId,无adID,无platform
- (void)performActivityActionByType:(TTActivityType)activityType inViewController:(UIViewController *)tController sourceObjectType:(TTShareSourceObjectType)sourceType {
    [self performActivityActionByType:activityType
                     inViewController:tController
                     sourceObjectType:sourceType
                             uniqueId:nil];
}
//无adID,无platform
- (void)performActivityActionByType:(TTActivityType)activityType inViewController:(UIViewController *)tController sourceObjectType:(TTShareSourceObjectType)sourceType uniqueId:(NSString *)uniqueId {
    [self performActivityActionByType:activityType inViewController:tController sourceObjectType:sourceType uniqueId:uniqueId adID:nil];
}
//无platform
- (void)performActivityActionByType:(TTActivityType)activityType inViewController:(UIViewController *)tController sourceObjectType:(TTShareSourceObjectType)sourceType uniqueId:(NSString *)uniqueId adID:(NSString *)adID {
    [self performActivityActionByType:activityType inViewController:tController sourceObjectType:sourceType uniqueId:uniqueId adID:adID platform:TTSharePlatformTypeOfMain groupFlags:nil];
}

- (void)performActivityActionByType:(TTActivityType)activityType inViewController:(UIViewController *)tController sourceObjectType:(TTShareSourceObjectType)sourceType uniqueId:(NSString *)uniqueId adID:(NSString *)adID platform:(TTSharePlatformType)platformType groupFlags:(NSNumber *)flags {
    [self performActivityActionByType:activityType inViewController:tController sourceObjectType:sourceType uniqueId:uniqueId adID:adID platform:platformType groupFlags:flags isFullScreenShow:NO];
}

static BOOL isMovieFullScreen;
- (void)performActivityActionByType:(TTActivityType)activityType inViewController:(nonnull UIViewController *)tController sourceObjectType:(TTShareSourceObjectType)sourceType uniqueId:(nullable NSString *)uniqueId adID:(nullable NSString *)adID platform:(TTSharePlatformType)platformType groupFlags:(nullable NSNumber *)flags isFullScreenShow:(BOOL)isFullScreen{
    isMovieFullScreen = isFullScreen;
    DetailActionRequestType requestType = DetailActionTypeNone;
    self.adID = adID;
    self.activityType = activityType;
    
    NSString * questionMarkOrAmpersand = nil;
    if ([_shareURL rangeOfString:@"?"].location == NSNotFound) {
        questionMarkOrAmpersand = @"?";
    }else {
        questionMarkOrAmpersand = @"&";
    }
    
    if (activityType == TTActivityTypeQQShare || activityType == TTActivityTypeWeixinMoment || activityType == TTActivityTypeWeixinShare) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kShareToPlatformNeedEnterBackground object:self];
    }
//    if (activityType == TTActivityTypeEMail) {
//        [self sendByMailWithSubject:_mailSubject mailBody:_mailBody mailData:_mailData showInController:tController bodyIsHTML:_mailBodyIsHTML];
//        requestType = DetailActionTypeSystemShare;
//    }
//    else if (activityType == TTActivityTypeSystem) {
//        [self sendBySystemWithSubject:_systemShareText url:_systemShareUrl image:_systemShareImage showInController:tController];
//        requestType = DetailActionTypeSystemShare;
//    }
//    else if (activityType == TTActivityTypeMessage) {
//
//        [self sendByMessageWithBody:_messageText showInController:tController];
//
//        requestType = DetailActionTypeSystemShare;
//    }
//    else if (activityType == TTActivityTypeFacebook) {
//        [self sendByFacebookWithText:_facebookText showInController:tController];
//        requestType = DetailActionTypeSystemShare;
//    }
//    else if (activityType == TTActivityTypeTwitter) {
//        [self sendByTwitterWithText:_twitterText showInController:tController];
//        requestType = DetailActionTypeSystemShare;
//    }
    if (activityType == TTActivityTypeCopy) {
        if ([_copyText length] > 0) {
            [[self class] copyText:_copyText isFullScreenShow:isFullScreen];
        }
        else if ([_copyContent length] > 0) {
            [[self class] copyText:_copyContent isFullScreenShow:isFullScreen];
        }
        else {
            [[self class] copyText:@"" isFullScreenShow:isFullScreen];
        }
    }
    else if (activityType == TTActivityTypeWeixinShare) {
        
        NSString * weixinShareURL = [NSString stringWithFormat:@"%@%@%@", _shareURL, questionMarkOrAmpersand, kShareChannelFromWeixin];
        [self weixinSendWithImage:_shareImage title:_weixinTitleText description:_weixinText webURLStr:weixinShareURL shareSourceObjectType:sourceType platformType:platformType shareUniqueId:uniqueId groupFlags:flags];
        requestType = DetailActionTypeWeixinShare;
    }
    else if (activityType == TTActivityTypeWeixinMoment) {
        
        NSString * weixinMomentShareURL = [NSString stringWithFormat:@"%@%@%@", _shareURL, questionMarkOrAmpersand, kShareChannelFromWeixinMoment];
        
        UIImage *shareImage = _shareToWeixinMomentOrQZoneImage ? _shareToWeixinMomentOrQZoneImage : _shareImage;
        [self weixinTimelineSendWithImage:shareImage title:_weixinMomentText description:_weixinMomentText webURLStr:weixinMomentShareURL shareSourceObjectType:sourceType platformType:platformType shareUniqueId:uniqueId];
        requestType = DetailActionTypeWeixinFriendShare;
    }
    else if (activityType == TTActivityTypeQQShare) {
        NSString * shareURL = [NSString stringWithFormat:@"%@%@%@", _shareURL, questionMarkOrAmpersand, kShareChannelFromQQ];
        [self sendQQShareWithImage:_shareImage imageURL:_shareImageURL title:_qqShareTitleText description:_qqShareText webURLStr:shareURL sourceType:sourceType platformType:platformType uniqueID:uniqueId];
        requestType = DetailActionTypeQQShare;
    }
    else if (activityType == TTActivityTypeQQZone) {
        NSString * shareURL = [NSString stringWithFormat:@"%@%@%@", _shareURL, questionMarkOrAmpersand, kShareChannelFromQQZone];
        NSString * qqZoneText = _qqZoneText;
        if (isEmptyString(qqZoneText)) {
            qqZoneText = _qqShareText;
        }
        NSString *title = self.qqZoneTitleText;
        if (isEmptyString(title)) {
            title = _qqShareTitleText;
        }
        if (isEmptyString(title)) {
            //只有QQ空间写死了title。 TOTO:// 未来改成云控
            title = NSLocalizedString(@"好多房", nil);
        }
        
        UIImage *shareImage = _shareToWeixinMomentOrQZoneImage ? _shareToWeixinMomentOrQZoneImage : _shareImage;
        [self sendSDKQQZoneShareWithImage:shareImage imageURL:_shareImageURL title:title description:qqZoneText webURLStr:shareURL sourceType:sourceType platformType:platformType uniqueID:uniqueId];
        requestType = DetailActionTypeQQZoneShare;
    }
//    else if (activityType == TTActivityTypeDingTalk) {
//        NSString *dingtalkShareURL = [NSString stringWithFormat:@"%@%@%@", _shareURL, questionMarkOrAmpersand, kShareChannelFromDingTalk];
//        [self dingtalkSendWithImage:_shareImage title:_dingtalkTitleText description:_dingtalkText webURLStr:dingtalkShareURL shareSourceObjectType:sourceType platformType:platformType shareUniqueID:uniqueId scene:DTSceneSession];
//        requestType = DetailActionTypeDingTalkShare;
//    }
    else if (activityType == TTActivityTypeBlockUser) {
        if(!isEmptyString(uniqueId)) {
            [[NSNotificationCenter defaultCenter] postNotificationName:kTTJSOrRNBlockOrUnBlockUserNotificationName object:self userInfo:@{@"user_id": uniqueId, @"is_blocking": @(YES)}];
        }
    }
    else if (activityType == TTActivityTypeUnBlockUser) {
        if(!isEmptyString(uniqueId)) {
            [[NSNotificationCenter defaultCenter] postNotificationName:kTTJSOrRNBlockOrUnBlockUserNotificationName object:self userInfo:@{@"user_id": uniqueId, @"is_blocking": @(NO)}];
        }
    }
    else if (activityType == TTActivityTypeReport) {
        if(!isEmptyString(uniqueId)) {
            [[NSNotificationCenter defaultCenter] postNotificationName:kTTJSOrRNReportUserNotificationName object:self userInfo:@{@"user_id": uniqueId}];
        }
    }
    
    if(!_actionManager) {
        self.actionManager = [[DetailActionRequestManager alloc] init];
    }
    
    
    if(requestType != DetailActionTypeNone && _sendItemActionStatistics) {
        TTDetailActionReuestContext *context = [TTDetailActionReuestContext new];
        context.groupModel = _groupModel;
        context.mediaID = _mediaID;
        if (_adID) {
            context.adID = [NSString stringWithFormat:@"%@", _adID];
        }
        [_actionManager setContext:context];
        
        [_actionManager startItemActionByType:requestType];
    }
    
}
#pragma mark - share action
#pragma mark -- weixin

- (void)weixinSendWithImage:(UIImage *)image
                      title:(NSString *)title
                description:(NSString *)desc
                  webURLStr:(NSString *)urlStr
      shareSourceObjectType:(TTShareSourceObjectType)sourceType
               platformType:(TTSharePlatformType)platformType
              shareUniqueId:(NSString *)uniqueId {
    [self weixinSendWithImage:image title:title description:desc webURLStr:urlStr shareSourceObjectType:sourceType platformType:platformType shareUniqueId:uniqueId groupFlags:nil];
}

- (void)weixinSendWithImage:(UIImage *)image
                      title:(NSString *)title
                description:(NSString *)desc
                  webURLStr:(NSString *)urlStr
      shareSourceObjectType:(TTShareSourceObjectType)sourceType
               platformType:(TTSharePlatformType)platformType
              shareUniqueId:(NSString *)uniqueId
                 groupFlags:(NSNumber *)flags {
    BOOL miniProgramShareEnable = !isEmptyString([SSCommonLogic miniProgramID]) && !isEmptyString([SSCommonLogic miniProgramPathTemplate]) && (sourceType == TTShareSourceObjectTypeVideoList || sourceType == TTShareSourceObjectTypeArticle || sourceType == TTShareSourceObjectTypeArticleTop || sourceType == TTShareSourceObjectTypeArticleNatant) && isEmptyString(_adID) && self.miniProgramEnable && ![TTDeviceHelper isPadDevice] && ![TTSandBoxHelper isInHouseApp]; // 内测版因appid的问题无法在小程序中注册
    
    self.activityType = TTActivityTypeWeixinShare;
    
    self.sourceType = sourceType;
    self.platformType = platformType;
    self.uniqueId = uniqueId;
    
    if (sourceType == TTShareSourceObjectTypeVideoList) {
        CGFloat scale = 1.5;
        if (miniProgramShareEnable){
            image = [image imageScaleAspectToMaxSize:150];
            scale = 4;
        }
        UIImage *videoImage = [UIImage imageNamed:@"toutiaovideo"];
        videoImage = [videoImage imageScaleAspectToMaxSize:image.size.height / scale];
        image = [UIImage drawImage:videoImage inImage:image atPoint:CGPointMake(image.size.width / 2, image.size.height / 2)];
    }
    
    TTWeChatShare *weixin = [TTWeChatShare sharedWeChatShare];
    [weixin setDelegate:self];
    weixin.ttServiceDelegate = self;
    
    if (sourceType == TTShareSourceObjectTypeSingleGallery || sourceType == TTShareSourceObjectTypeScreenshot) {
        //走微信图片分享方式
        [weixin sendImageToScene:WXSceneSession withImage:_shareImageStyleImage customCallbackUserInfo:nil];
    }
    else {
        if ([urlStr rangeOfString:@"wxshare_count"].location == NSNotFound) {
            if ([urlStr rangeOfString:@"?"].location == NSNotFound) {
                urlStr = [urlStr stringByAppendingFormat:@"?wxshare_count=1"];
            } else {
                urlStr = [urlStr stringByAppendingFormat:@"&wxshare_count=1"];
            }
        }
        if (miniProgramShareEnable){
            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
            NSString *page_type = @"0";
            if (sourceType == TTShareSourceObjectTypeVideoList){
                page_type = @"1";
            }
            [dict setValue:page_type forKey:@"page_type"];
            [dict setValue:_groupModel.groupID forKey:@"group_id"];
            [dict setValue:_groupModel.itemID forKey:@"id"];
            [dict setValue:[[TTInstallIDManager sharedInstance] installID] forKey:@"iid"];
            [weixin sendWebpageWithMiniProgramShareInScene:WXSceneSession withParameterDict:dict WebpageURL:urlStr thumbnailImage:image title:title description:desc customCallbackUserInfo:nil];
        }else{
            [weixin sendWebpageToScene:WXSceneSession withWebpageURL:urlStr thumbnailImage:image title:title description:desc customCallbackUserInfo:nil];
        }
    }
}

/*
 * 分享到朋友圈， 仅显示title， 此时一般使用desc作为title
 */
- (void)weixinTimelineSendWithImage:(UIImage *)image
                              title:(NSString *)title
                        description:(NSString *)desc
                          webURLStr:(NSString *)urlStr
              shareSourceObjectType:(TTShareSourceObjectType)sourceType
                       platformType:(TTSharePlatformType)platformType
                      shareUniqueId:(NSString *)uniqueId {
    self.activityType = TTActivityTypeWeixinMoment;
    self.sourceType = sourceType;
    self.platformType = platformType;
    self.uniqueId = uniqueId;
    
    TTWeChatShare *weixin = [TTWeChatShare sharedWeChatShare];
    [weixin setDelegate:self];
    
    if ([urlStr rangeOfString:@"wxshare_count"].location == NSNotFound) {
        if ([urlStr rangeOfString:@"?"].location == NSNotFound) {
            urlStr = [urlStr stringByAppendingFormat:@"?wxshare_count=1"];
        } else {
            urlStr = [urlStr stringByAppendingFormat:@"&wxshare_count=1"];
        }
    }
    
    if (sourceType == TTShareSourceObjectTypeVideoList || sourceType == TTShareSourceObjectTypeVideoDetail) {
        if (!isEmptyString(self.adID)) {
            [weixin sendVideoToScene:WXSceneTimeline withVideoURL:urlStr thumbnailImage:image title:title description:desc customCallbackUserInfo:nil];
        }
        else{
            [self videoWeixinTimeLinesendWithTTWeChatShare:weixin image:image title:title description:desc webURLStr:urlStr];
        }
    } else if (sourceType == TTShareSourceObjectTypeSingleGallery || sourceType == TTShareSourceObjectTypeScreenshot) {
        if (_shareImageStyleImage) {
            [weixin sendImageToScene:WXSceneTimeline withImage:_shareImageStyleImage customCallbackUserInfo:nil];
        }
    } else {
        if (_shareToWeixinMomentScreenQRCodeImage) {
            [weixin sendImageToScene:WXSceneTimeline withImage:_shareToWeixinMomentScreenQRCodeImage customCallbackUserInfo:nil];
        } else {
            [weixin sendWebpageToScene:WXSceneTimeline withWebpageURL:urlStr thumbnailImage:image title:title description:desc customCallbackUserInfo:nil];
        }
    }
}

- (void)videoWeixinTimeLinesendWithTTWeChatShare:weixin
                                           image:(UIImage *)image
                                           title:(NSString *)title
                                     description:(NSString *)desc
                                       webURLStr:(NSString *)urlStr
{
    UIImage *shareImg = image;
    UIImageView *originalImageView = [[UIImageView alloc] initWithImage:image];
    if (ttvs_isShareTimelineOptimize() == 2) {
        shareImg = [self imageWithView:originalImageView];
    }
    
    if (ttvs_isShareTimelineOptimize() > 0 )
    {
        [weixin sendWebpageToScene:WXSceneTimeline withWebpageURL:urlStr thumbnailImage:shareImg title:title description:desc customCallbackUserInfo:nil];
    }
    else{
        [weixin sendVideoToScene:WXSceneTimeline withVideoURL:urlStr thumbnailImage:shareImg title:title description:desc customCallbackUserInfo:nil];
    }
    
}

- (UIImage *)imageWithView:(UIView *)view
{
    UIImage *iconImg = [UIImage imageNamed:@"video_play_share_icon.png"];
    UIImageView *iconImgView = [[UIImageView alloc] initWithImage:iconImg];
    iconImgView.contentMode = UIViewContentModeScaleAspectFit;
    //iconImgView 方形 和view高度形同大小
    view.frame = CGRectMake(0, 0, view.size.width, view.size.height);
    iconImgView.size = CGSizeMake(view.size.height, view.size.height);
    [view addSubview:iconImgView];
    iconImgView.center = view.center;
    CGSize pageSize = view.bounds.size;
    
    UIGraphicsBeginImageContextWithOptions(pageSize, NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [view.layer renderInContext:context];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

//#pragma mark -- zhifubao
//// 分享到支付宝
//- (void)zhifubaoSendWithImage:(UIImage *)image
//                        title:(NSString *)title
//                  description:(NSString *)desc
//                    webURLStr:(NSString *)urlStr
//        shareSourceObjectType:(TTShareSourceObjectType)sourceType
//                 platformType:(TTSharePlatformType)platformType
//                shareUniqueId:(NSString *)uniqueId
//                      apScene:(APScene)apScene
//{
//    self.activityType = (apScene == APSceneTimeLine ? TTActivityTypeZhiFuBaoMoment : TTActivityTypeZhiFuBao);
//    self.groupModel = _groupModel;
//    self.sourceType = sourceType;
//    self.platformType = platformType;
//    self.uniqueId = uniqueId;
//
//    if (sourceType == TTShareSourceObjectTypeVideoList) {
//        UIImage *videoImage = [UIImage imageNamed:@"toutiaovideo"];
//        videoImage = [videoImage imageScaleAspectToMaxSize:image.size.height / 1.5];
//        image = [UIImage drawImage:videoImage inImage:image atPoint:CGPointMake(image.size.width / 2, image.size.height / 2)];
//    }
//
//    TTAliShare *zhifubao = [TTAliShare sharedAliShare];
//    [zhifubao setDelegate:self];
//
//    if ([urlStr rangeOfString:@"zfbshare_count"].location == NSNotFound) {
//        if ([urlStr rangeOfString:@"?"].location == NSNotFound) {
//            urlStr = [urlStr stringByAppendingFormat:@"?zfbshare_count=1"];
//        } else {
//            urlStr = [urlStr stringByAppendingFormat:@"&zfbshare_count=1"];
//        }
//    }
//    if (sourceType == TTShareSourceObjectTypeSingleGallery || sourceType == TTShareSourceObjectTypeScreenshot) {
//        if (_shareImageStyleImage) {
//            [zhifubao sendImageToScene:apScene withImage:_shareImageStyleImage customCallbackUserInfo:nil];
//        }else if (_shareImageStyleImageURL) {
//            [zhifubao sendImageToScene:apScene withImageURL:_shareImageStyleImageURL customCallbackUserInfo:nil];
//        }
//    }else {
//        [zhifubao sendWebpageToScene:apScene withWebpageURL:urlStr thumbnailImage:image thumbnailImageURL:nil title:title description:desc customCallbackUserInfo:nil];
//    }
//}
//
//#pragma mark -- dingtalk
//- (void)dingtalkSendWithImage:(UIImage *)image
//                        title:(NSString *)title
//                  description:(NSString *)description
//                    webURLStr:(NSString *)urlStr
//        shareSourceObjectType:(TTShareSourceObjectType)sourceType
//                 platformType:(TTSharePlatformType)platformType
//                shareUniqueID:(NSString *)uniqueID
//                        scene:(DTScene)scene {
//    self.activityType = TTActivityTypeDingTalk;
//    self.groupModel = _groupModel;
//    self.sourceType = sourceType;
//    self.platformType = platformType;
//    self.uniqueId = uniqueID;
//
//    TTDingTalkShare *dingtalk = [TTDingTalkShare sharedDingTalkShare];
//    [dingtalk setDelegate:self];
//
//    if (sourceType == TTShareSourceObjectTypeVideoList) {
//        UIImage *videoImage = [UIImage imageNamed:@"toutiaovideo"];
//        videoImage = [videoImage imageScaleAspectToMaxSize:image.size.height / 1.5];
//        image = [UIImage drawImage:videoImage inImage:image atPoint:CGPointMake(image.size.width / 2, image.size.height / 2)];
//    }
//    if ([urlStr rangeOfString:@"dtshare_count"].location == NSNotFound) {
//        if ([urlStr rangeOfString:@"?"].location == NSNotFound) {
//            urlStr = [urlStr stringByAppendingFormat:@"?dtshare_count=1"];
//        } else {
//            urlStr = [urlStr stringByAppendingFormat:@"&dtshare_count=1"];
//        }
//    }
//    if (sourceType == TTShareSourceObjectTypeSingleGallery || sourceType == TTShareSourceObjectTypeScreenshot) {
//        if (_shareImageStyleImage) {
//            [dingtalk sendImageToScene:scene withImage:_shareImageStyleImage customCallbackUserInfo:nil];
//        }else if (_shareImageStyleImageURL) {
//            [dingtalk sendImageToScene:scene withImageURL:_shareImageStyleImageURL customCallbackUserInfo:nil];
//        }
//    } else {
//        [dingtalk sendWebpageToScene:scene withWebpageURL:urlStr thumbnailImage:image thumbnailImageURL:nil title:title description:description customCallbackUserInfo:nil];
//    }
//}


#pragma mark -- qq

- (void)sendQQShareWithImage:(UIImage *)image
                    imageURL:(NSString *)imageURL
                       title:(NSString *)title
                 description:(NSString *)desc
                   webURLStr:(NSString *)urlStr
                  sourceType:(TTShareSourceObjectType)sourceType
                platformType:(TTSharePlatformType)platformType
                    uniqueID:(NSString *)uniqueID {
    self.activityType = TTActivityTypeQQShare;
    self.sourceType = sourceType;
    self.platformType = platformType;
    self.uniqueId = uniqueID;
    if ([imageURL hasSuffix:@".webp"]) {
        imageURL = [imageURL stringByReplacingOccurrencesOfString:@".webp" withString:@".jpg" options:0 range:NSMakeRange(imageURL.length - 5, 5)];
    }
    
    if (sourceType == TTShareSourceObjectTypeVideoList) {
        UIImage *videoImage = [UIImage imageNamed:@"toutiaovideo"];
        videoImage = [videoImage imageScaleAspectToMaxSize:image.size.height / 1.5];
        image = [UIImage drawImage:videoImage inImage:image atPoint:CGPointMake(image.size.width / 2, image.size.height / 2)];
    }
    
    TTQQShare *qqShare = [TTQQShare sharedQQShare];
    qqShare.delegate = self;
    if (sourceType == TTShareSourceObjectTypeSingleGallery || sourceType == TTShareSourceObjectTypeScreenshot) {
        if (_shareImageStyleImage) {
            [qqShare sendImage:_shareImageStyleImage withTitle:nil description:nil customCallbackUserInfo:nil];
        }
    }else {
        [qqShare sendNewsWithURL:urlStr thumbnailImage:image thumbnailImageURL:imageURL title:title description:desc customCallbackUserInfo:nil];
    }
}

#pragma mark -- qzone

- (void)sendSDKQQZoneShareWithImage:(UIImage *)image
                           imageURL:(NSString *)imageURL
                              title:(NSString *)title
                        description:(NSString *)desc
                          webURLStr:(NSString *)urlStr
                         sourceType:(TTShareSourceObjectType)sourceType
                       platformType:(TTSharePlatformType)platformType
                           uniqueID:(NSString *)uniqueID {
    self.activityType = TTActivityTypeQQZone;
    self.sourceType = sourceType;
    self.platformType = platformType;
    self.uniqueId = uniqueID;
    
    if (sourceType == TTShareSourceObjectTypeVideoList) {
        UIImage *videoImage = [UIImage imageNamed:@"toutiaovideo"];
        videoImage = [videoImage imageScaleAspectToMaxSize:image.size.height / 1.5];
        image = [UIImage drawImage:videoImage inImage:image atPoint:CGPointMake(image.size.width / 2, image.size.height / 2)];
    }
    
    TTQQShare *qqShare = [TTQQShare sharedQQShare];
    qqShare.delegate = self;
    if (sourceType == TTShareSourceObjectTypeSingleGallery || sourceType == TTShareSourceObjectTypeScreenshot) {
        if (_shareImageStyleImage) {
            [qqShare sendImageToQZoneWithImage:_shareImageStyleImage title:nil customCallbackUserInfo:nil];
        }
    }else {
        [qqShare sendNewsToQZoneWithURL:urlStr thumbnailImage:nil thumbnailImageURL:imageURL title:title description:desc customCallbackUserInfo:nil];
    }
}

#pragma mark -- send to SNS

- (void)sendToSNSPlatform:(NSString *)platformKey
                  message:(NSString *)message
                 hasImage:(BOOL)hasImg
                 uniqueId:(NSString *)uniqueId
                 shareURL:(NSString *)shareURL
            shareImageURL:(NSString *)shareImageURL
         sourceObjectType:(TTShareSourceObjectType)sourceType
             platformType:(TTSharePlatformType)platformType
     showInViewController:(UIViewController *)controller {
    
    if (_sendSNSObject == nil) {
        self.sendSNSObject = [[_TTShareManagerSendSNSObject alloc] init];
    }
    [_sendSNSObject clear];
    
    _sendSNSObject.uniqueId = uniqueId;
    _sendSNSObject.adID = _adID;
    _sendSNSObject.groupModel = _groupModel;
    _sendSNSObject.mediaID = nil;
    _sendSNSObject.itemTag = _itemTag;
    _sendSNSObject.platformKey = platformKey;
    _sendSNSObject.message = message;
    _sendSNSObject.hasImage = hasImg;
    _sendSNSObject.shareURL = shareURL;
    _sendSNSObject.shareImageURL = shareImageURL;
    _sendSNSObject.isSharePGCUser = NO;
    _sendSNSObject.controller = controller;
    _sendSNSObject.sourceType = sourceType;
    _sendSNSObject.platformType = platformType;
    [_sendSNSObject sendMessage];
}

- (void)sharePGCUserToSNSPlatform:(NSString *)platformKey message:(NSString *)message mediaID:(NSString *)mID showInViewController:(UIViewController *)controller {
    if (_sendSNSObject == nil) {
        self.sendSNSObject = [[_TTShareManagerSendSNSObject alloc] init];
    }
    [_sendSNSObject clear];
    
    _sendSNSObject.uniqueId = nil;
    _sendSNSObject.adID = nil;
    _sendSNSObject.groupModel = nil;
    _sendSNSObject.mediaID = mID;
    _sendSNSObject.itemTag = nil;
    _sendSNSObject.platformKey = platformKey;
    _sendSNSObject.message = message;
    _sendSNSObject.hasImage = NO;
    _sendSNSObject.isSharePGCUser = YES;
    _sendSNSObject.controller = controller;
    [_sendSNSObject sendMessage];
    
}

//#pragma mark -- Other
//- (void)sendByMailWithSubject:(NSString *)subject mailBody:(NSString *)body mailData:(NSData *)data showInController:(UIViewController *)controller {
//    [self sendByMailWithSubject:subject mailBody:body mailData:data showInController:controller bodyIsHTML:NO];
//}
//
//- (void)sendByMailWithSubject:(NSString *)subject mailBody:(NSString *)body mailData:(NSData *)data showInController:(UIViewController *)controller bodyIsHTML:(BOOL)isHTML {
//    TTMailShare *sharedMail = [TTMailShare sharedMailShare];
//    sharedMail.delegate = self;
//    [sharedMail sendMailWithSubject:subject
//                       toRecipients:nil
//                       ccRecipients:nil
//                       bcRecipients:nil
//                        messageBody:body
//                             isHTML:isHTML
//                  addAttachmentData:data
//                           mimeType:@"image/png"
//                           fileName:@"share.png"
//                   inViewController:controller
//         withCustomCallbackUserInfo:nil];
//}
//
//- (void)sendByMessageWithBody:(NSString *)body showInController:(UIViewController *)controller {
//    TTMessageShare *sharedMessage = [TTMessageShare sharedMessageShare];
//    sharedMessage.delegate = nil;
//    [sharedMessage sendMessageWithBody:body inViewController:controller customCallbackUserInfo:nil];
//}
//
//- (void)sendBySystemWithSubject:(NSString *)subject url:(NSString *)urlStr image:(UIImage *)img showInController:(UIViewController *)controller {
//    NSString *text = subject;
//    NSURL *url = [NSURL URLWithString:urlStr];
//    UIImage *image = img;
//
//    NSMutableArray * ary = [NSMutableArray array];
//    if (text) {
//        [ary addObject:text];
//    }
//    if (url) {
//        [ary addObject:url];
//    }
//    if (image) {
//        [ary addObject:image];
//    }
//
//    UIActivityViewController * aController = [[UIActivityViewController alloc] initWithActivityItems:ary applicationActivities:nil];
//
//    if ([TTDeviceHelper isPadDevice]) {
//        self.popOverController = [[UIPopoverController alloc] initWithContentViewController:aController];
//        [self.popOverController presentPopoverFromRect:CGRectMake(controller.view.frame.size.width/2, controller.view.frame.size.height * 3.f/4.f, 0, 0) inView:controller.view permittedArrowDirections:UIPopoverArrowDirectionDown animated:YES];
//    }
//    else {
//        [controller presentViewController:aController animated:YES completion:nil];
//    }
//}
//- (void)sendByFacebookWithText:(NSString *)text showInController:(UIViewController *)controller {
//    SLComposeViewController * facebookController = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
//    if ([text length] > 0) {
//        [facebookController setInitialText:text];
//    }
//    [controller presentViewController:facebookController animated:YES completion:nil];
//
//}
//
//- (void)sendByTwitterWithText:(NSString *)text showInController:(UIViewController *)controller {
//    SLComposeViewController * twitterController = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
//    if ([text length] > 0) {
//        [twitterController setInitialText:text];
//    }
//    [controller presentViewController:twitterController animated:YES completion:nil];
//}
#pragma mark - TTWeChatShareTTServiceDelegate
- (void)weChatShare:(TTWeChatShare *)weChatShare oldSharedWithError:(NSError *)error customCallbackUserInfo:(NSDictionary *)customCallbackUserInfo {
    BOOL fromSwizzled = NO;
    if (!SSIsEmptyDictionary(customCallbackUserInfo)) {
        if ([customCallbackUserInfo objectForKey:@"from_swzziled"]) {
            fromSwizzled = [customCallbackUserInfo tt_boolValueForKey:@"from_swzziled"];
        }
    }
    
    if (fromSwizzled) {
        //截断操作 直接回调
        if ([self.delegate respondsToSelector:@selector(activityShareManager:completeWithActivityType:error:)] && [self.delegate isKindOfClass:[TTRShare class]]) {
            [self.delegate activityShareManager:self
                       completeWithActivityType:self.activityType
                                          error:error];
        }
    }
}

#pragma mark -- TTWeChatShareDelegate
- (void)weChatShare:(TTWeChatShare *)weChatShare sharedWithError:(NSError *)error customCallbackUserInfo:(NSDictionary *)customCallbackUserInfo {
    NSString *errMsg = nil;
    
    BOOL needSequence = YES;
    if (self.activityType == TTActivityTypeWeixinShare) {
        if (error == nil) {
            if (self.sourceType == TTShareSourceObjectTypeVideoList || self.sourceType == TTShareSourceObjectTypeVideoDetail) {
                [self sendTrackEventWithResult:YES recommentedLabel:@"share_weixin_done"];
            } else {
                [self sendTrackEventWithResult:YES recommentedLabel:nil];
            }
        } else {
            if (self.sourceType == TTShareSourceObjectTypeVideoList || self.sourceType == TTShareSourceObjectTypeVideoDetail) {
                [self sendTrackEventWithResult:NO recommentedLabel:@"share_weixin_fail"];
            } else {
                [self sendTrackEventWithResult:NO recommentedLabel:nil];
            }
        }
    } else if (self.activityType == TTActivityTypeWeixinMoment) {
        if (error == nil) {
            if (self.sourceType == TTShareSourceObjectTypeVideoList || self.sourceType == TTShareSourceObjectTypeVideoDetail) {
                [self sendTrackEventWithResult:YES recommentedLabel:@"share_weixin_moments_done"];
            } else {
                [self sendTrackEventWithResult:YES recommentedLabel:nil];
            }
        } else {
            if (self.sourceType == TTShareSourceObjectTypeVideoList || self.sourceType == TTShareSourceObjectTypeVideoDetail) {
                [self sendTrackEventWithResult:NO recommentedLabel:@"share_weixin_moments_fail"];
            } else {
                [self sendTrackEventWithResult:NO recommentedLabel:nil];
            }
        }
    }
    
    if(error) {
        switch (error.code) {
            case kTTWeChatShareErrorTypeNotInstalled:
                errMsg = NSLocalizedString(@"您未安装微信", nil);
                needSequence = NO;
                break;
            case kTTWeChatShareErrorTypeNotSupportAPI:
                errMsg = NSLocalizedString(@"您的微信版本过低，无法支持分享", nil);
                break;
            case kTTWeChatShareErrorTypeExceedMaxImageSize:
                errMsg = NSLocalizedString(@"图片过大，分享图片不能超过10M", nil);
                break;
            default:
                errMsg = NSLocalizedString(@"分享失败", nil);
                break;
        }
    }else {
        errMsg = NSLocalizedString(@"分享成功", nil);
        if (_activityType == TTActivityTypeWeixinMoment && _groupModel.groupID > 0) {
            self.itemRequestManager = [[DetailActionRequestManager alloc] init];
            
            TTDetailActionReuestContext *context = [TTDetailActionReuestContext new];
            context.groupModel = _groupModel;
            [_itemRequestManager setContext:context];
            
            [_itemRequestManager startItemActionByType:DetailActionTypeShare];
        }
    }
    
    if(!isEmptyString(errMsg)) {
        [[self class] showIndicatorViewWithTip:errMsg andImage:[UIImage themedImageNamed:error ? @"close_popup_textpage.png" : @"doneicon_popup_textpage.png"] dismissHandler:nil isFullScreenShow:isMovieFullScreen];
        //[TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:errMsg indicatorImage:[UIImage themedImageNamed:error ? @"close_popup_textpage.png" : @"doneicon_popup_textpage.png"] autoDismiss:YES dismissHandler:nil];
    }
    
    if (needSequence && ttvs_isShareIndividuatioEnable()) {
        [[TTActivityShareSequenceManager sharedInstance_tt] instalAllShareActivitySequenceFirstActivity:self.activityType];
    }
    
    if ([self.delegate respondsToSelector:@selector(activityShareManager:completeWithActivityType:error:)]) {
        [self.delegate activityShareManager:self
                   completeWithActivityType:self.activityType
                                      error:error];
        
    }
}

//#pragma mark -- TTAliShareDelegate
//
//- (void)aliShare:(TTAliShare *)aliShare sharedWithError:(NSError *)error customCallbackUserInfo:(NSDictionary *)customCallbackUserInfo {
//    if (error) {
//        NSString * errStr = nil;
//        switch (error.code) {
//            case kTTAliShareErrorTypeNotInstalled:
//                errStr = NSLocalizedString(@"您未安装支付宝", nil);
//                break;
//            case kTTAliShareErrorTypeNotSupportAPI:
//                errStr = NSLocalizedString(@"您的支付宝版本过低，无法支持分享", nil);
//                break;
//            default:
//                errStr = NSLocalizedString(@"分享失败", nil);
//                break;
//        }
//        if (!isEmptyString(errStr)) {
//            [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:errStr indicatorImage:[UIImage themedImageNamed:@"close_popup_textpage.png"] autoDismiss:YES dismissHandler:nil];
//        }
//        [self sendTrackEventWithResult:NO recommentedLabel:nil];
//        if (self.sourceType == TTShareSourceObjectTypeScreenshot && !isEmptyString([TTScreenshotShareManager shareManager].label)){
//            wrapperTrackEvent(@"screenshot_share_failed", [TTScreenshotShareManager shareManager].label);
//            [TTScreenshotShareManager shareManager].label = nil;
//        }
//    } else {
//        [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:@"分享成功" indicatorImage:[UIImage themedImageNamed:@"doneicon_popup_textpage.png"] autoDismiss:YES dismissHandler:nil];
//        [self sendTrackEventWithResult:YES recommentedLabel:nil];
//        if (self.sourceType == TTShareSourceObjectTypeScreenshot && !isEmptyString([TTScreenshotShareManager shareManager].label)){
//            wrapperTrackEvent(@"screenshot_share_success", [TTScreenshotShareManager shareManager].label);
//            [TTScreenshotShareManager shareManager].label = nil;
//        }
//    }
//    if ([self.delegate respondsToSelector:@selector(activityShareManager:completeWithActivityType:error:)]) {
//        [self.delegate activityShareManager:self
//                   completeWithActivityType:self.activityType
//                                      error:error];
//    }
//}
//
//#pragma mark -- TTDingTalkDelegate
//
//- (void)dingTalkShare:(TTDingTalkShare *)dingTalkShare sharedWithError:(NSError *)error customCallbackUserInfo:(NSDictionary *)customCallbackUserInfo {
//    BOOL needSequence = YES;
//    if (error) {
//        NSString *errStr = nil;
//        switch (error.code) {
//            case kTTDingTalkShareErrorTypeNotInstalled:
//                errStr = NSLocalizedString(@"您未安装钉钉", nil);
//                needSequence = NO;
//                break;
//            case kTTDingTalkShareErrorTypeNotSupportAPI:
//                errStr = NSLocalizedString(@"您的钉钉版本过低，无法支持分享", nil);
//                break;
//            default:
//                errStr = NSLocalizedString(@"分享失败", nil);
//                break;
//        }
//        if (!isEmptyString(errStr)) {
//            [[self class] showIndicatorViewWithTip:errStr andImage:[UIImage themedImageNamed:@"close_popup_textpage.png"] dismissHandler:nil isFullScreenShow:isMovieFullScreen];
//            //            [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:errStr indicatorImage:[UIImage themedImageNamed:@"close_popup_textpage.png"] autoDismiss:YES dismissHandler:nil];
//            [self sendTrackEventWithResult:NO recommentedLabel:nil];
//        }
//        if (self.sourceType == TTShareSourceObjectTypeScreenshot && !isEmptyString([TTScreenshotShareManager shareManager].label)){
//            wrapperTrackEvent(@"screenshot_share_failed", [TTScreenshotShareManager shareManager].label);
//            [TTScreenshotShareManager shareManager].label = nil;
//        }
//    } else {
//        [[self class] showIndicatorViewWithTip:@"分享成功"  andImage:[UIImage themedImageNamed:@"doneicon_popup_textpage.png"] dismissHandler:nil isFullScreenShow:isMovieFullScreen];
//        //        [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:@"分享成功" indicatorImage:[UIImage themedImageNamed:@"doneicon_popup_textpage.png"] autoDismiss:YES dismissHandler:nil];
//        [self sendTrackEventWithResult:YES recommentedLabel:nil];
//        if (self.sourceType == TTShareSourceObjectTypeScreenshot && !isEmptyString([TTScreenshotShareManager shareManager].label)){
//            wrapperTrackEvent(@"screenshot_share_success", [TTScreenshotShareManager shareManager].label);
//            [TTScreenshotShareManager shareManager].label = nil;
//        }
//    }
//    if (needSequence && ttvs_isShareIndividuatioEnable()) {
//        [[TTActivityShareSequenceManager sharedInstance_tt] instalAllShareActivitySequenceFirstActivity:self.activityType];
//    }
//    if ([self.delegate respondsToSelector:@selector(activityShareManager:completeWithActivityType:error:)]) {
//        [self.delegate activityShareManager:self
//                   completeWithActivityType:self.activityType
//                                      error:error];
//
//    }
//}


#pragma mark -- TTQQShareDelegate

- (void)qqShare:(TTQQShare *)qqShare sharedWithError:(NSError *)error customCallbackUserInfo:(NSDictionary *)customCallbackUserInfo {
    // umeng
    BOOL needSequence = YES;
    NSString * recommentedLabel = nil;
    if (self.sourceType == TTShareSourceObjectTypeVideoList) {
        if (self.activityType == TTActivityTypeQQShare) {
            recommentedLabel = nil == error? @"share_qq_done":@"share_qq_fail";
        }else if (self.activityType == TTActivityTypeQQZone) {
            recommentedLabel = nil == error? @"share_qzone_done":@"share_qzone_fail";
        }
    }
    [self sendTrackEventWithResult:nil == error?YES:NO recommentedLabel:recommentedLabel];
    
    if (!error) {
        [[self class] showIndicatorViewWithTip:@"QQ分享成功"  andImage:[UIImage themedImageNamed:@"doneicon_popup_textpage.png"] dismissHandler:nil isFullScreenShow:isMovieFullScreen];
        //        [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:@"QQ分享成功" indicatorImage:[UIImage themedImageNamed:@"doneicon_popup_textpage.png"] autoDismiss:YES dismissHandler:nil];
    }else{
        NSString *errStr = nil;
        switch (error.code) {
            case kTTQQShareErrorTypeNotInstalled:
                errStr = NSLocalizedString(@"您未安装QQ", nil);
                needSequence = NO;
                break;
            case kTTQQShareErrorTypeNotSupportAPI:
                errStr = NSLocalizedString(@"您的QQ版本过低，无法支持分享", nil);
                break;
            default:
                errStr = NSLocalizedString(@"分享失败", nil);
                break;
        }
        
        if(!isEmptyString(errStr)) {
            [[self class] showIndicatorViewWithTip:errStr  andImage:[UIImage themedImageNamed:@"close_popup_textpage.png"] dismissHandler:nil isFullScreenShow:isMovieFullScreen];
            
            //            [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:errStr indicatorImage:[UIImage themedImageNamed:error ? @"close_popup_textpage.png" : @"doneicon_popup_textpage.png"] autoDismiss:YES dismissHandler:nil];
        }
    }
    if (needSequence && ttvs_isShareIndividuatioEnable()) {
        [[TTActivityShareSequenceManager sharedInstance_tt] instalAllShareActivitySequenceFirstActivity:self.activityType];
    }
    
    if ([self.delegate respondsToSelector:@selector(activityShareManager:completeWithActivityType:error:)]) {
        [self.delegate activityShareManager:self
                   completeWithActivityType:self.activityType
                                      error:error];
        
    }
}

//#pragma mark - TTMailShareDelegate
//
//- (void)mailShare:(TTMailShare *)mailShare sharedWithError:(NSError *)error customCallbackUserInfo:(NSDictionary *)customCallbackUserInfo {
//    if (error && error.code == kTTMailShareErrorTypeNotSupport) {
//        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"无邮件帐户" message:@"请设置邮件帐户来发送电子邮件" delegate:nil cancelButtonTitle:@"好" otherButtonTitles:nil, nil];
//        [alertView show];
//    }
//}


#pragma mark - Trace


- (void)sendTrackEventWithResult:(BOOL)success recommentedLabel:(NSString *)recomLabel {
    NSString *tag = [TTActivityShareManager tagNameForShareSourceObjectType:self.sourceType];
    TTActivityType activityType = _activityType;
    
    NSString *label = isEmptyString(recomLabel) ? [TTActivityShareManager labelNameForShareActivityType:activityType shareState:success] : recomLabel;
    
    NSMutableDictionary *extraDict = [NSMutableDictionary dictionary];
    [extraDict setValue:self.adID forKey:@"ad_id"];
    [extraDict setValue:_groupModel.itemID forKey:@"item_id"];
    [extraDict setValue:self.mediaID forKey:@"media_id"];
    if (_platformType == TTSharePlatformTypeOfMain) {
        
        if (_sourceType == TTShareSourceObjectTypeUGCFeed) {
            [extraDict setValue:@1 forKey:@"refer"];
            [extraDict setValue:@1 forKey:@"gtype"];
            tag = @"list_share";
        }
        [extraDict setValue:_clickSource forKey:@"source"];
        if ( self.sourceType == TTShareSourceObjectTypeVideoList)
        {
            [extraDict setValue:@"video" forKey:@"source"];
            [extraDict setValue:@"video" forKey:@"article_type"];
            [extraDict setValue:self.authorId forKey:@"author_id"];
            if (activityType == TTActivityTypeQQShare || activityType == TTActivityTypeQQZone || activityType == TTActivityTypeWeixinShare|| activityType == TTActivityTypeWeixinMoment) {
                if ([_clickSource rangeOfString:@"_direct"].location != NSNotFound)
                {
                    [extraDict setValue:@"exposed" forKey:@"icon_seat"];
                }else{
                    [extraDict setValue:@"inside" forKey:@"icon_seat"];
                }
            }
            NSString *section = [_clickSource stringByReplacingOccurrencesOfString:@"_direct" withString:@""];
            [extraDict setValue:section forKey:@"section"];
            if ([_clickSource isEqualToString:@"player_more"] || [_clickSource isEqualToString:@"player_share"]) {
                [extraDict setValue:@"fullscreen" forKey:@"fullscreen"];
            }
            NSString *eventName = @"share_done";
            if ([recomLabel rangeOfString:@"fail"].location != NSNotFound){
                eventName = @"share_fail";
            }
            if (!ttvs_isTitanVideoBusiness()) {
                wrapperTrackEventWithCustomKeys(tag, label, self.uniqueId, nil, extraDict);
            }
            SAFECALL_MESSAGE(TTVShareActionTrackMessage, @selector(message_shareTrackActivityWithGroupID:ActivityType:FromSource:eventName:),message_shareTrackActivityWithGroupID:self.uniqueId ActivityType:_activityType FromSource: _clickSource eventName:eventName);
            
        } else if(self.sourceType == TTShareSourceObjectTypeVideoDetail)
        {
            [extraDict setValue:@"video" forKey:@"source"];
            [extraDict setValue:@"video" forKey:@"article_type"];
            [extraDict setValue:self.authorId forKey:@"author_id"];
            if (activityType == TTActivityTypeQQShare || activityType == TTActivityTypeQQZone || activityType == TTActivityTypeWeixinShare|| activityType == TTActivityTypeWeixinMoment) {
                if ([_clickSource rangeOfString:@"_direct"].location != NSNotFound)
                {
                    [extraDict setValue:@"exposed" forKey:@"icon_seat"];
                }else{
                    [extraDict setValue:@"inside" forKey:@"icon_seat"];
                }
            }
            NSString *sectionName = [_clickSource stringByReplacingOccurrencesOfString:@"_direct" withString:@""];
            if ([_clickSource isEqualToString:@"no_full_more"]) {
                [extraDict setValue:@"notfullscreen" forKey:@"fullscreen"];
                [extraDict setValue:@"player_more" forKey:@"section"];
            }else if ([_clickSource isEqualToString:@"centre_button"]){
                [extraDict setValue:@"notfullscreen" forKey:@"fullscreen"];
                [extraDict setValue:sectionName forKey:@"section"];
                
            }else{
                [extraDict setValue:@"video" forKey:@"source"];
                [extraDict setValue:sectionName forKey:@"section"];
                if ([_clickSource isEqualToString:@"player_more"] || [_clickSource isEqualToString:@"player_share"]) {
                    [extraDict setValue:@"fullscreen" forKey:@"fullscreen"];
                }
            }
            NSString *eventName = @"share_done";
            if ([recomLabel rangeOfString:@"fail"].location != NSNotFound){
                eventName = @"share_fail";
            }
            if (!ttvs_isTitanVideoBusiness()) {
                wrapperTrackEventWithCustomKeys(tag, label, self.uniqueId, nil, extraDict);
            }
            SAFECALL_MESSAGE(TTVShareDetailTrackerMessage, @selector(message_detailshareTrackActivityWithGroupID:ActivityType:FromSource:eventName:), message_detailshareTrackActivityWithGroupID:self.uniqueId ActivityType:activityType FromSource:_clickSource eventName:eventName);
        }else{
            wrapperTrackEventWithCustomKeys(tag, label, self.uniqueId, nil, extraDict);
        }
        
    }else if (_platformType == TTSharePlatformTypeOfForumPlugin) {
        [TTTrackerWrapper category:@"umeng" event:tag label:label dict:@{@"source":self.uniqueId}];
    }
}
+ (void)copyText:(NSString *)text
{
    [self copyText:text isFullScreenShow:NO];
}

+ (void)copyText:(NSString *)text isFullScreenShow:(BOOL)isFullScreen {
    NSString *message = nil;
    UIImage * image = nil;
    if ([text isKindOfClass:[NSString class]]) {
        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
        [pasteboard setString:text];
        message = NSLocalizedString(@"复制成功", nil);
        image = [UIImage themedImageNamed:@"doneicon_popup_textpage.png"];
    } else {
        message = NSLocalizedString(@"无法复制", nil);
        image = [UIImage themedImageNamed:@"close_popup_textpage.png"];
    }
    [self showIndicatorViewWithTip:message andImage:nil dismissHandler:nil isFullScreenShow:isFullScreen];
    //    [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:message indicatorImage:image autoDismiss:YES dismissHandler:nil];
}

+ (NSString *)tagNameForShareSourceObjectType:(TTShareSourceObjectType)sourceType {
    if (sourceType == TTShareSourceObjectTypeArticle || sourceType == TTShareSourceObjectTypeVideoDetail) {
        return @"detail_share";
    }
    else if (sourceType == TTShareSourceObjectTypeEssay ||
             sourceType == TTShareSourceObjectTypeVideoList) {
        return @"list_share";
    }
    else if (sourceType == TTShareSourceObjectTypeMoment) {
        return @"share_update_post";
    }
    else if (sourceType == TTShareSourceObjectTypeForum) {
        return @"share_topic";
    }
    else if (sourceType == TTShareSourceObjectTypeForumPost) {
        return @"share_topic_post";
    }
    else if (sourceType == TTShareSourceObjectTypeComment) {
        return @"comment_share";
    }
    else if (sourceType == TTShareSourceObjectTypePGC) {
        return @"pgc_profile";
    }
    else if (sourceType == TTShareSourceObjectTypeWendaAnswer) {
        return @"answer_detail";
    }
    else if (sourceType == TTShareSourceObjectTypeWendaQuestion) {
        return @"question";
    }
    else if (sourceType == TTShareSourceObjectTypeArticleNatant) {
        return @"detail_mid_share";
    }
    else if (sourceType == TTShareSourceObjectTypeArticleTop) {
        return @"detail_more_share";
    }
    else if (sourceType == TTShareSourceObjectTypeSingleGallery) {
        return @"slide_long_press_share";
    }else if (sourceType == TTShareSourceObjectTypeFeedForumPost) {
        return @"share_topic_post_list";
    }else if (sourceType == TTShareSourceObjectTypeLiveChatRoom) {
        return @"share_live";
    }
    else if (sourceType == TTShareSourceObjectTypeVideoSubject) {
        return @"video_subject";
    }
    else if (sourceType == TTShareSourceObjectTypeVideoFloat) {
        return @"video_float";
    }
    else if (sourceType == TTShareSourceObjectTypeWap) {
        return @"wap_share";
    }
    else if (sourceType == TTShareSourceObjectTypeProfile) {
        return @"profile";
    } else if (sourceType == TTShareSourceObjectTypeScreenshot){
        return @"screenshot";
    } else{
        return nil;
    }
}

+ (NSString *)labelNameForShareActivityType:(TTActivityType)activityType {
    if (activityType == TTActivityTypeEMail) {
        return @"share_email";
    }
    else if (activityType == TTActivityTypeMessage) {
        return @"share_sms";
    }
    else if (activityType == TTActivityTypeFacebook) {
        return @"share_facebook";
    }
    else if (activityType == TTActivityTypeTwitter) {
        return @"share_twitter";
    }
    else if (activityType == TTActivityTypeCopy) {
        return @"share_copy_link";
    }
    else if (activityType == TTActivityTypeWeixinShare) {
        return @"weixin";
    }
    else if (activityType == TTActivityTypeWeixinMoment) {
        return @"weixin_moments";
    }
    else if (activityType == TTActivityTypeSinaWeibo) {
        return @"share_weibo";
    }
    else if (activityType == TTActivityTypeQQWeibo) {
        return @"share_tweibo";
    }
    else if (activityType == TTActivityTypeQQZone) {
        return @"qzone";
    }
    else if (activityType == TTActivityTypeKaiXin) {
        return @"share_kaixin";
    }
    else if (activityType == TTActivityTypeRenRen) {
        return @"share_renren";
    }
    else if (activityType == TTActivityTypeQQShare) {
        return @"qq";
    }
    else if (activityType == TTActivityTypeMyMoment) {
        return @"share_update";
    }
    else if (activityType == TTActivityTypeNone) {
        return @"share_cancel_button";
    }
    else if (activityType == TTActivityTypeShareButton) {
        return @"share_button";
    }
    else if (activityType == TTActivityTypeSystem) {
        return @"share_system";
    }
    else if (activityType == TTActivityTypeZhiFuBao) {
        return @"share_zhifubao";
    }
    else if (activityType == TTActivityTypeZhiFuBaoMoment) {
        return @"share_zhifubao_shenghuoquan";
    }
    else if (activityType == TTActivityTypeDingTalk) {
        return @"share_dingding";
    }
    else {
        return nil;
    }
}

+ (NSString *)shareTargetStrForTTLogWithType:(TTActivityType)activityType{
    NSString * target = @"unkown";
    if (activityType == TTActivityTypeEMail) {
        target = @"email";
    }
    else if (activityType == TTActivityTypeSystem) {
        target = @"system";
    }
    else if (activityType == TTActivityTypeMessage) {
        target = @"sms";
    }
    else if (activityType == TTActivityTypeFacebook) {
        target = @"system";
    }
    else if (activityType == TTActivityTypeTwitter) {
        target = @"system";
    }
    else if (activityType == TTActivityTypeCopy) {
        target = @"copy";
    }
    else if (activityType == TTActivityTypeWeixinShare) {
        target = @"weixin";
    }
    else if (activityType == TTActivityTypeWeixinMoment) {
        target = @"weixin_moments";
    }
    else if (activityType == TTActivityTypeSinaWeibo) {
        target = @"weibo";
    }
    else if (activityType == TTActivityTypeQQWeibo) {
        target = @"DetailActionTypeSystemShare";
    }
    else if (activityType == TTActivityTypeQQShare) {
        target = @"qq";
    }
    else if (activityType == TTActivityTypeQQZone) {
        target = @"qq";
    }
    else if (activityType == TTActivityTypeKaiXin) {
        target = @"system";
    }
    else if (activityType == TTActivityTypeRenRen) {
        target = @"system";
    }
    else if (activityType == TTActivityTypeZhiFuBao) {
        target = @"zhifubao";
    }
    else if (activityType == TTActivityTypeZhiFuBaoMoment) {
        target = @"zhifubao_moments";
    }
    else if (activityType == TTActivityTypeDingTalk) {
        target = @"dingtalk";
    }
    else if (activityType == TTActivityTypeShareButton){
        return @"share_button";
    }
    return [NSString stringWithFormat:@"share_%@", target];
}

+ (NSString *)labelNameForShareActivityType:(TTActivityType)activityType shareState:(BOOL)success {
    NSString *activityDesc = [[self class] labelNameForShareActivityType:activityType];
    NSString *suffix = success ? @"_done" : @"_fail";
    if (activityType == TTActivityTypeWeixinShare &&
        [SSCommonLogic weixinSharedExtendedObjectEnabled]) {
        suffix = [NSString stringWithFormat:@"_extend%@", suffix];
    }
    return [activityDesc stringByAppendingString:suffix];
}

#pragma mark - Utils
//文章分享链接
- (void)setShareURL:(NSString *)shareURL {
    if ([shareURL rangeOfString:@"?"].location == NSNotFound) {
        _shareURL = [NSString stringWithFormat:@"%@?",shareURL];
    }
    else {
        _shareURL = shareURL;
    }
}

#pragma mark - toast: 复制 适配全屏
//默认Image类类型
+ (void) showIndicatorViewWithTip:(NSString *)tipMsg andImage:(UIImage *)indicatorImage dismissHandler:(DismissHandler)handler isFullScreenShow:(BOOL)isFullScreen{
    TTIndicatorView *indicateView = [[TTIndicatorView alloc] initWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:tipMsg indicatorImage:indicatorImage dismissHandler:handler];
    [indicateView addTransFormIsFullScreen:isFullScreen];
    indicateView.autoDismiss = YES;
    [indicateView showFromParentView:[[indicateView class] defaultParentView]];
    [indicateView changeFrameIsFullScreen:isFullScreen];
}

@end

