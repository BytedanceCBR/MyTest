//
//  TTXiguaLiveManager.m
//  Article
//
//  Created by lishuangyang on 2017/12/14.
//

#import "TTXiguaLiveManager.h"
#import "TTAccountManager.h"
#import <BDWebImage/SDWebImageAdapter.h>
#import "TTFlowStatisticsManager.h"
#import "TTActivityShareSequenceManager.h"
#import "TTRoute.h"
#import "TTNetworkUtil.h"
#import "FriendDataManager.h"
#import <TTUIWidget/UIViewController+NavigationBarStyle.h>
//分享相关
#import "TTServiceCenter.h"
#import "TTAdManagerProtocol.h"
#import <TTShareActivity.h>
#import <TTShareManager.h>
#import "TTWechatTimelineContentItem.h"
#import "TTWechatContentItem.h"
#import "TTQQFriendContentItem.h"
#import "TTQQZoneContentItem.h"
#import "TTDingTalkContentItem.h"
#import "TTForwardWeitoutiaoContentItem.h"
#import "TTRepostViewController.h"
#import "TTRepostOriginModels.h"

extern BOOL ttvs_isShareIndividuatioEnable(void);

@interface TTXiguaLiveManager ()<TTShareManagerDelegate>

@property (nonatomic, strong) TTShareManager * ttshareManager;
@property (nonatomic, strong) NSMutableArray * shareItems; //暂时无用
@property (nonatomic, strong) NSMutableDictionary *shareDicSaved;
@property (nonatomic, strong) NSDictionary *extraDic;
@end

@implementation TTXiguaLiveManager

+ (instancetype)sharedManager
{
    static TTXiguaLiveManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[TTXiguaLiveManager alloc] init];
        [TTLRoomManager sharedManager].delegate = manager;
    });
    return manager;
}

- (UIViewController *)boadCastRoomWithExtraInfo:(NSDictionary *)extra {
    self.extraDic = extra;

    NSMutableDictionary *mExtraDic = [NSMutableDictionary dictionaryWithDictionary:self.extraDic];
    if ([TTAccountManager isLogin]) {
        [mExtraDic setValue:[TTAccountManager userID] forKey:@"author_id"];
    }
    UIViewController *boadCastVC  = [[TTLRoomManager sharedManager] broadcastRoomWithExtraInfo:mExtraDic.copy];
    boadCastVC.ttHideNavigationBar = YES;
    boadCastVC.ttDisableDragBack = YES;
    return boadCastVC;
}

- (UIViewController *)audienceRoomWithRoomID:(NSString *)roomID extraInfo:(NSDictionary *)extra{
     //强制退出登录页
    [[NSNotificationCenter defaultCenter] postNotificationName:TTForceToDismissLoginViewControllerNotification object:nil];
    self.extraDic = extra;
    UIViewController *audienceVC = [[TTLRoomManager sharedManager] audienceRoomWithRoomID:roomID extraInfo:self.extraDic];
    audienceVC.ttHideNavigationBar = YES;
    audienceVC.ttDisableDragBack = YES;
    return audienceVC;
}

- (UIViewController *)audienceRoomWithUserID:(NSString *)userID extraInfo:(NSDictionary *)extra{
    //强制退出登录页
    [[NSNotificationCenter defaultCenter] postNotificationName:TTForceToDismissLoginViewControllerNotification object:nil];
    self.extraDic = extra;
    NSMutableDictionary *mExtraDic = [NSMutableDictionary dictionaryWithDictionary:self.extraDic];
    [mExtraDic setValue:userID forKey:@"author_id"];
    UIViewController *audienceVC = [[TTLRoomManager sharedManager] audienceRoomWithUserID:userID extraInfo:mExtraDic.copy];
    audienceVC.ttHideNavigationBar = YES;
    audienceVC.ttDisableDragBack = YES;
    return audienceVC;
}

- (__kindof UIViewController *)walletViewControllerWithExtraInfo:(NSDictionary *)extraInfo{
    self.extraDic = extraInfo;
    UIViewController *walletVC = [[TTLRoomManager sharedManager] walletViewControllerWithExtraInfo:self.extraDic];
    walletVC.ttHideNavigationBar = YES;
    walletVC.ttDisableDragBack = YES;
    return walletVC;
}

- (BOOL)isAlreadyInThisRoom:(NSString *)roomID userID:(NSString *)userID{
    NSArray <id <TTLAudienceViewControllerProtocol>> *audienceVCArr = [[TTLRoomManager sharedManager] allAudienceViewController];
    for (id<TTLAudienceViewControllerProtocol> audienceVC in audienceVCArr) {
        if ([audienceVC.roomID isEqualToString:roomID] ||
            [audienceVC.ownerID isEqualToString:userID]) {
            return YES;
        }
    }
    return NO;
}

#pragma mark -  TTLRoomManagerDelegate

// 弹出登陆弹窗，如果已经登陆直接调completion返回UserID
- (void)ttl_requireLoginWithCompletion:(TTLLoginCompletion)completion
{
    if ([TTAccountManager isLogin]) {
        if (completion) {
            completion([TTAccountManager userID], YES);
        }
        return;
    }
    else{
        [TTAccountManager showLoginAlertWithType:TTAccountLoginAlertTitleTypeSocial source:@"topic_item_block" completion:^(TTAccountAlertCompletionEventType type, NSString *phoneNum) {
            if (type == TTAccountAlertCompletionEventTypeDone) {
                if (completion) {
                    completion([TTAccountManager userID], [TTAccountManager isLogin] ? YES : NO);
                }
            } else if (type == TTAccountAlertCompletionEventTypeTip) {
                [TTAccountManager presentQuickLoginFromVC:[TTUIResponderHelper topNavigationControllerFor: nil]
                                                     type:TTAccountLoginDialogTitleTypeDefault
                                                   source:@"topic_item_block"
                                               completion:^(TTAccountLoginState state){
                       if (completion) {
                           completion([TTAccountManager userID], [TTAccountManager isLogin] ? YES : NO);
                       }
               }];
            }else{
                if (completion){
                    completion(nil, NO);
                }
            }
        }];
    }

}

// 当前是否登陆
- (BOOL)ttl_isLogin
{
    return [TTAccountManager isLogin];
}
// 打开个人主页
- (void)ttl_openUserProfileUserID:(NSString *)userID baseCondition:(NSDictionary *)baseCondition
{
    if (isEmptyString(userID)) {
        return;
    }
    NSString * schema = [NSString stringWithFormat:@"sslocal://profile?uid=%@",userID];
    schema = [TTUGCTrackerHelper schemaTrackForPersonalHomeSchema:schema categoryName:@"profile"  fromPage:@"user_profile" groupId:nil profileUserId:nil];
    [[TTRoute sharedRoute] openURLByPushViewController:[TTNetworkUtil URLWithURLString:schema]];
}

// 打开URLscheme
- (void)ttl_openURLScheme:(NSString *)openURL
{
    if (isEmptyString(openURL)) {
        return;
    }
    NSURL *schema = [TTNetworkUtil URLWithURLString:openURL];
    if ([[TTRoute sharedRoute] canOpenURL:schema]){
        [[TTRoute sharedRoute] openURLByPushViewController:schema];
    }else{
        //todo
    }
}
// 是否是免流用户
- (BOOL)ttl_isFreeFlowUser
{
    BOOL freeFlow = [[TTFlowStatisticsManager sharedInstance] flowStatisticsEnable] &&
    [[TTFlowStatisticsManager sharedInstance] isSupportFreeFlow] &&
    [[TTFlowStatisticsManager sharedInstance] isOpenFreeFlow] &&
    [[TTFlowStatisticsManager sharedInstance] isExcessFlow] == NO;
    return freeFlow;
}

// 处理分享
- (void)ttl_shareLiveWithShareInfo:(NSDictionary *)shareInfo
{
    NSString *shareTitle = [shareInfo tt_stringValueForKey:kTTLLiveShareTitleKey];
    NSString *shareDescribe = [shareInfo tt_stringValueForKey:kTTLLiveShareDescriptionKey];
    NSString *shareURL = [shareInfo tt_stringValueForKey:kTTLLiveShareURLKey];
    NSString *shareImageURL = [shareInfo tt_stringValueForKey:kTTLLiveShareImageURLKey];
//    NSString *shareImageURL = @"http://p3.pstatp.com/video1609/4ff9000df6a8d8f371fa";
    NSString *groupID = [shareInfo tt_stringValueForKey:kTTLLiveShareGroupIDKey];
    NSString *authorID = [shareInfo tt_stringValueForKey:kTTLLiveShareAnchorIDKey];
    BOOL isAuthor = [shareInfo tta_boolForKey:kTTLLiveShareIsAnchorKey];
    
    if (isEmptyString(shareTitle)) {
        shareTitle = NSLocalizedString(@"爱看", nil);
    }
    if (isEmptyString(shareDescribe)) {
        shareDescribe = NSLocalizedString(@"发现你感兴趣的新鲜事", nil);
    }
    UIImage *shareImage = [[SDWebImageAdapter sharedAdapter] imageFromDiskCacheForKey:shareImageURL];
    if (!shareImage){
        shareImage = [UIImage imageNamed:@"share_icon.png"];
    }
    TTRepostOriginArticle *weiTouTiaoArticle = [[TTRepostOriginArticle alloc] init];
    weiTouTiaoArticle.groupID = groupID;
    weiTouTiaoArticle.userID = authorID;
    weiTouTiaoArticle.title = shareTitle;
    FRImageInfoModel *thumbImage = [[FRImageInfoModel alloc] initWithDictionary:@{@"url":shareImageURL}];
    weiTouTiaoArticle.thumbImage = thumbImage;
    weiTouTiaoArticle.isVideo = NO;
    weiTouTiaoArticle.isDeleted = NO;
    NSMutableArray *shareItems = [NSMutableArray array];
    
    //微信朋友圈分享
    TTWechatTimelineContentItem * wctlContentItem = [[TTWechatTimelineContentItem alloc] initWithTitle:shareTitle
                                                                                                  desc:shareDescribe
                                                                                            webPageUrl:shareURL
                                                                                            thumbImage:shareImage
                                                                                             shareType:TTShareWebPage];
    //微信好友分享
    TTWechatContentItem *wcContentItem = [[TTWechatContentItem alloc] initWithTitle:shareTitle
                                                                               desc:shareDescribe
                                                                         webPageUrl:shareURL
                                                                         thumbImage:shareImage
                                                                          shareType:TTShareWebPage];
    //QQ好友分享
    TTQQFriendContentItem * qqContentItem = [[TTQQFriendContentItem alloc] initWithTitle:shareTitle
                                                                                    desc:shareDescribe
                                                                              webPageUrl:shareURL
                                                                              thumbImage:shareImage
                                                                                imageUrl:shareImageURL
                                                                                shareTye:TTShareWebPage];
    //QQ空间分享
    TTQQZoneContentItem * qqZoneContentItem = [[TTQQZoneContentItem alloc] initWithTitle:shareTitle
                                                                                    desc:shareDescribe
                                                                              webPageUrl:shareURL
                                                                              thumbImage:shareImage
                                                                                imageUrl:shareImageURL
                                                                                shareTye:TTShareWebPage];
    //复制
    TTCopyContentItem *copyItem = [[TTCopyContentItem alloc] initWithDesc:shareURL];
    
    //个性化排序
//    if (!ttvs_isShareIndividuatioEnable()){
//        [shareItems addObject:[self forwardWeitoutiaoContentItem:weiTouTiaoArticle]]; //暂时不加微头条
        [shareItems addObject:wctlContentItem];
        [shareItems addObject:wcContentItem];
        [shareItems addObject:qqContentItem];
        [shareItems addObject:qqZoneContentItem];
        [shareItems addObject:copyItem];
//    }else{
//        NSArray *typeArray = [[TTActivityShareSequenceManager sharedInstance_tt] getAllShareServiceSequence];
//        [typeArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//            if ([obj isKindOfClass:[NSString class]]) {
//                NSString *objType = (NSString *)obj;
//                if ([objType isEqualToString:TTActivityContentItemTypeWechatTimeLine]){
//                    [shareItems addObject:wctlContentItem];
//                }else if ([objType isEqualToString:TTActivityContentItemTypeWechat]){
//                    [shareItems addObject:wcContentItem];
//                }else if ([objType isEqualToString:TTActivityContentItemTypeQQFriend]){
//                    [shareItems addObject:qqContentItem];
//                }else if ([objType isEqualToString:TTActivityContentItemTypeQQZone]){
//                    [shareItems addObject:qqZoneContentItem];
//                }
//                else if ([objType isEqualToString: TTActivityContentItemTypeForwardWeitoutiao]){
//                        [shareItems addObject:[self forwardWeitoutiaoContentItem:weiTouTiaoArticle]];
//                }
//            }
//        }];
//        [shareItems addObject:copyItem];
//    }

    //不出广告
    id<TTAdManagerProtocol> adManagerInstance = [[TTServiceCenter sharedInstance] getServiceByProtocol:@protocol(TTAdManagerProtocol)];
    [adManagerInstance share_showInAdPage:@"1" groupId:[self.extraDic tt_stringValueForKey:@"group_id"]];

    NSMutableArray *contentItems = @[].mutableCopy;
    [contentItems addObject:shareItems];
    [self.ttshareManager displayActivitySheetWithContent:[contentItems copy]];
    //埋点
    NSMutableDictionary *shareExtra = [NSMutableDictionary dictionary];
    [shareExtra setValue:@(isAuthor) forKey:@"is_player"];
    [shareExtra setValue:groupID forKey:@"group_id"];
    [shareExtra setValue:authorID forKey:@"author_id"];
    [shareExtra setValue:@"inside" forKey:@"icon_seat"];
    [shareExtra setValue:@"detail_button_bar" forKey:@"section"];
    [shareExtra setValue:@"inside" forKey:@"icon_seat"];
    self.shareDicSaved = shareExtra;
    [self trackShareLogV3WithName:@"share_button"];
}

- (void)ttl_changeFollowStatusForUser:(NSString *)userID roomID:(NSString *)roomID groupID:(NSString *)groupID isFollow:(BOOL)follow extraInfo:(NSDictionary *)extraInfo completion:(TTLFollowUserCompletion)completion {
    FriendActionType actionType;
    if (follow) {
        actionType = FriendActionTypeFollow;
    }
    else {
        actionType = FriendActionTypeUnfollow;
    }
    [[TTFollowManager sharedManager] newStartAction:actionType userID:userID  platform:nil name:nil from:nil reason:nil newReason:nil newSource:@(TTFollowNewSourceXiguaLive) completion:^(FriendActionType type, NSError * _Nullable error, NSDictionary * _Nullable result) {
        if (completion) {
            completion(error ? NO : YES, error );
        }
    }];
    //埋点
    [self trackFollowLogV3WithEventName:follow ? @"rt_follow":@"rt_unfollow" UserID:userID roomID:roomID group:groupID extraInfo:extraInfo];
}

//微头条
 - (TTForwardWeitoutiaoContentItem *)forwardWeitoutiaoContentItem:(TTRepostOriginArticle *)weitoutiao
{
    TTForwardWeitoutiaoContentItem * contentItem = [[TTForwardWeitoutiaoContentItem alloc] init];
    WeakSelf;
    contentItem.customAction = ^{
        StrongSelf;
        [self forwardToWeitoutiao:weitoutiao];
    };
    return contentItem;
}

 - (void)forwardToWeitoutiao:(TTRepostOriginArticle *)weitoutiao {
    //实际转发对象为文章，操作对象为文章
    [TTRepostViewController presentRepostToWeitoutiaoViewControllerWithRepostType:TTThreadRepostTypeArticle
                                                                    originArticle:weitoutiao
                                                                     originThread:nil
                                                     originShortVideoOriginalData:nil
                                                                operationItemType:TTRepostOperationItemTypeNone
                                                                  operationItemID:nil
                                                                   repostSegments:nil];
}


#pragma mark - TTShareManagerDelegate

- (void)shareManager:(TTShareManager *)shareManager
         clickedWith:(id<TTActivityProtocol>)activity
          sharePanel:(id<TTActivityPanelControllerProtocol>)panelController
{
    if (activity) {
        if ([activity.contentItemType isEqualToString:TTActivityContentItemTypeWechatTimeLine]) {
            [self.shareDicSaved setValue:@"weixin_moments" forKey:@"share_platform"];
        }else if ([activity.contentItemType isEqualToString:TTActivityContentItemTypeForwardWeitoutiao]){
            [self.shareDicSaved setValue:@"weitoutiao" forKey:@"share_platform"];
        }else if ([activity.contentItemType isEqualToString:TTActivityContentItemTypeWechat]){
                [self.shareDicSaved setValue:@"weixin" forKey:@"share_platform"];
        }else if ([activity.contentItemType isEqualToString:TTActivityContentItemTypeQQZone]){
            [self.shareDicSaved setValue:@"qzone" forKey:@"share_platform"];
        }else if ([activity.contentItemType isEqualToString:TTActivityContentItemTypeQQFriend]){
            [self.shareDicSaved setValue:@"qq" forKey:@"share_platform"];
        }else if ([activity.contentItemType isEqualToString:TTActivityContentItemTypeCopy]){
            [self.shareDicSaved setValue:@"copy" forKey:@"share_platform"];
        }
        [self trackShareLogV3WithName:@"rt_share_to_platfrom"];
    }else{
//        [self trackShareLogV3WithNamre:@"share_button_cancel"];
        self.shareDicSaved = nil;
    }
}

- (void)shareManager:(TTShareManager *)shareManager
       completedWith:(id<TTActivityProtocol>)activity
          sharePanel:(id<TTActivityPanelControllerProtocol>)panelController
               error:(NSError *)error
                desc:(NSString *)desc
{
    NSString *eventName = nil;
    if(error) {
        TTVActivityShareErrorCode errorCode = [TTActivityShareSequenceManager shareErrorCodeFromItemErrorCode:error WithActivity:activity];
        switch (errorCode) {
            case TTVActivityShareErrorFailed:
//                [[TTActivityShareSequenceManager sharedInstance_tt] instalAllShareServiceSequenceFirstActivity:activity.contentItemType];
                break;
            case TTVActivityShareErrorUnavaliable:
            case TTVActivityShareErrorNotInstalled:
            default:
                break;
        }
        eventName = @"share_fail";
    }else{
//        [[TTActivityShareSequenceManager sharedInstance_tt] instalAllShareServiceSequenceFirstActivity:activity.contentItemType];
        eventName = @"share_done";
    }
    [self trackShareLogV3WithName:eventName];
    self.shareDicSaved = nil;
}

#pragma mark - getter & setter
- (NSMutableArray *)shareItems{
    if (!_shareItems) {
        _shareItems = [NSMutableArray array];
    }
    return _shareItems;
}

- (TTShareManager *)ttshareManager {
    if (nil == _ttshareManager) {
        _ttshareManager = [[TTShareManager alloc] init];
        _ttshareManager.delegate = self;
    }
    return _ttshareManager;
}

- (void)setExtraDic:(NSDictionary *)extraDic
{
    [self setTrackLogDictionary:extraDic];
}

#pragma mark - trackLog

- (void)trackFollowLogV3WithEventName:(NSString *)eventName UserID:(NSString *)userID roomID:(NSString *)roomID group:(NSString *)groupID extraInfo:(NSDictionary *)extra{
    NSMutableDictionary *params = [self.extraDic mutableCopy];
    [params setValue:userID forKey:@"to_user_id"];
    [params setValue:roomID forKey:@"room_id"];
    [params setValue:groupID forKey:@"group_id"];
    [params setValue:@"from_group" forKey:@"follow_type"];
    [params addEntriesFromDictionary:extra];
    [TTTrackerWrapper eventV3:eventName params:params.copy];
}

- (void)trackShareLogV3WithName:(NSString *)name{
    NSMutableDictionary *params = self.extraDic ? [self.extraDic mutableCopy] :[NSMutableDictionary dictionary];
    [params addEntriesFromDictionary:self.shareDicSaved];
    [TTTrackerWrapper eventV3:name params:params.copy];
    //发送过share_button后，增加icon_seat参数
    [self.shareDicSaved setValue:@"inside" forKey:@"icon_seat"];
}

- (void)setTrackLogDictionary:(NSDictionary *)extraTrackDic{
    NSMutableDictionary *meDict = [extraTrackDic mutableCopy];
    if (![meDict.allKeys containsObject:@"enter_from"]) {
        [meDict setValue:[self enterFromStringFromCategoryName:extraTrackDic[@"category_name"]] forKey:@"enter_from"];
    }
    [meDict setValue:@"detail" forKey:@"position"];
    [meDict setValue:TTXiguaGroupSource forKey:@"group_source"];

    _extraDic = [meDict copy];
}

- (NSString *)enterFromStringFromCategoryName:(NSString *)categoryName{
    NSString *enterFrom = nil;
    if(!isEmptyString(categoryName)){
        if ([categoryName isEqualToString:@"__all__"]){
            enterFrom = @"click_headline";
        }else{
            enterFrom = @"click_category";
        }
    }
    return enterFrom;
}

@end
