//
//  TTCommentRepostViewModel+TTActivity.m
//  Article
//
//  Created by ranny_90 on 2017/9/19.
//
//
#import "TTCommentRepostViewModel+TTActivity.h"
#import <objc/Runtime.h>

//Pods
#import <TTWechatTimelineContentItem.h>
#import <TTWechatContentItem.h>
#import <TTQQFriendContentItem.h>
#import <TTQQZoneContentItem.h>
//#import <TTDingTalkContentItem.h>
#import <TTForwardWeitoutiaoContentItem.h>
#import <TTNightModelContentItem.h>
#import <TTFontSettingContentItem.h>
#import <TTBlockContentItem.h>
//#import <TTSystemContentItem.h>
#import <TTAccountManager.h>
#import <TTWebImageManager.h>
#import <Article.h>
#import <TTActionSheetController.h>
#import <TTReportManager.h>
#import <ExploreOrderedData.h>
//#import <TTCopyContentItem.h>
#import <TTDirectForwardWeitoutiaoContentItem.h>
#import "Article.h"
#import <AKCommentPlugin/TTCommentDataManager.h>

//UGCFoundation
#import <TTUGCFoundation/UGCRepostCommonModel.h>
#import "FRCommentRepostDetailModel.h"
#import "Thread.h"
#import "TTKitchenHeader.h"
#import "TTUGCDefine.h"
#import "TTRepostContentSegment.h"
#import "TTUGCPodBridge.h"
#import "TTThreadDeleteContentItem.h"
#import "TTUGCShareUtil.h"
#import "FRForumServer.h"
#import "TTReportUserContentItem.h"
#import "TTRepostViewController.h"
#import "TTRepostService.h"
#import <ExploreMomentDefine_Enums.h>


//feature
#import "TTShareToRepostManager.h"

@implementation TTCommentRepostViewModel (TTActivity)

#pragma mark - Public Methods

- (void)setShareSection:(NSString *)shareSection
{
    objc_setAssociatedObject(self, @selector(shareSection), shareSection, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (NSString *)shareSection
{
    return objc_getAssociatedObject(self, @selector(shareSection));
}

- (nullable NSArray<id<TTActivityContentItemProtocol>> *)forwardSharePanelContentItems
{
    NSMutableArray *mutableArray = [NSMutableArray arrayWithArray:[self allShareContentItems]];
    [mutableArray addObject:[self directForwardWeitoutiaoContentItem]];
    
    return mutableArray;
}

- (nullable NSArray<id<TTActivityContentItemProtocol>> *)shareContentItems {
    NSMutableArray *mutableArray = [NSMutableArray arrayWithCapacity:6];
    for (id<TTActivityContentItemProtocol> object in [self allShareContentItems]) {
//        if (![object isKindOfClass:[TTSystemContentItem class]]) {
//            [mutableArray addObject:object];
//        }
    }
    return mutableArray;
}

- (nullable NSArray<id<TTActivityContentItemProtocol>> *)allShareContentItems {
    NSString *shareTitle = [KitchenMgr getString:kKCUGCFeedNamesShare];
    NSString *shareDescribe = self.commentRepostDetailModel.commentRepostModel.shareInfoModel.share_desc;
    NSString *shareURL = self.commentRepostDetailModel.commentRepostModel.shareInfoModel.share_url;
    UIImage *shareImage = nil;
    NSString *shareImageURL = nil;
    if (!SSIsEmptyArray(self.commentRepostDetailModel.commentRepostModel.shareInfoModel.share_cover.url_list)) {
        shareImageURL = [self.commentRepostDetailModel.commentRepostModel.shareInfoModel.share_cover.url_list objectAtIndex:0];
    }
    
    if (isEmptyString(shareTitle)) {
        shareTitle = NSLocalizedString(@"爱看", nil);
    }
    
    if (isEmptyString(shareDescribe)) {
        shareDescribe = NSLocalizedString(@"发现你感兴趣的新鲜事", nil);
    }
    
    if (self.commentRepostDetailModel.commentRepostModel.originThread) {
        shareImage = [TTUGCShareUtil shareThumbImageForThread:self.commentRepostDetailModel.commentRepostModel.originThread];
        if (isEmptyString(shareImageURL)) {
            shareImageURL = [TTUGCShareUtil shareThumbImageURLForThread:self.commentRepostDetailModel.commentRepostModel.originThread];
        }
    }
    else if (self.commentRepostDetailModel.commentRepostModel.originGroup){
        shareImage = [[TTUGCPodBridge sharedInstance] shareMethodUtilWeixinSharedImageForArticle:self.commentRepostDetailModel.commentRepostModel.originGroup];
        if (isEmptyString(shareImageURL)) {
            shareImageURL = [[TTUGCPodBridge sharedInstance] shareMethodUtilWeixinSharedImageURLForArticle:self.commentRepostDetailModel.commentRepostModel.originGroup];
        }
    }
    
    if (!shareImage) {
        shareImage = [self defaultShareImage];
    }
    
    NSMutableSet * shareActivityContentItemTypes = [NSMutableSet set];
    
    
    
    //微信朋友圈分享
    TTWechatTimelineContentItem * wctlContentItem = [[TTWechatTimelineContentItem alloc] initWithTitle:shareDescribe
                                                                                                  desc:nil
                                                                                            webPageUrl:shareURL
                                                                                            thumbImage:shareImage
                                                                                             shareType:TTShareWebPage];
    [shareActivityContentItemTypes addObject:TTActivityContentItemTypeWechatTimeLine];
    
    //微信好友分享
    TTWechatContentItem *wcContentItem = [[TTWechatContentItem alloc] initWithTitle:shareTitle
                                                                               desc:shareDescribe
                                                                         webPageUrl:shareURL
                                                                         thumbImage:shareImage
                                                                          shareType:TTShareWebPage];
    [shareActivityContentItemTypes addObject:TTActivityContentItemTypeWechat];
    
    //QQ好友分享
    TTQQFriendContentItem * qqContentItem = [[TTQQFriendContentItem alloc] initWithTitle:shareTitle
                                                                                    desc:shareDescribe
                                                                              webPageUrl:shareURL
                                                                              thumbImage:shareImage
                                                                                imageUrl:shareImageURL
                                                                                shareTye:TTShareWebPage];
    [shareActivityContentItemTypes addObject:TTActivityContentItemTypeQQFriend];
    
    //QQ空间分享
    TTQQZoneContentItem * qqZoneContentItem = [[TTQQZoneContentItem alloc] initWithTitle:shareTitle
                                                                                    desc:shareDescribe
                                                                              webPageUrl:shareURL
                                                                              thumbImage:shareImage
                                                                                imageUrl:shareImageURL
                                                                                shareTye:TTShareWebPage];
    [shareActivityContentItemTypes addObject:TTActivityContentItemTypeQQZone];
    
//    //钉钉分享
//    TTDingTalkContentItem * ddContentItem = [[TTDingTalkContentItem alloc] initWithTitle:shareTitle
//                                                                                    desc:shareDescribe
//                                                                              webPageUrl:shareURL
//                                                                              thumbImage:shareImage
//                                                                               shareType:TTShareWebPage];
//    [shareActivityContentItemTypes addObject:TTActivityContentItemTypeDingTalk];
//
//    //系统分享
//    TTSystemContentItem *systemContentItem = [[TTSystemContentItem alloc] initWithDesc:shareDescribe
//                                                                            webPageUrl:shareURL
//                                                                                 image:shareImage];
//    [shareActivityContentItemTypes addObject:TTActivityContentItemTypeSystem];
    
//    //copy
//    TTCopyContentItem * copyContentItem = [[TTCopyContentItem alloc] initWithDesc:shareURL];
//    [shareActivityContentItemTypes addObject:TTActivityContentItemTypeCopy];
    
    self.shareActivityContentItemTypes = shareActivityContentItemTypes.copy;
    
    return @[[self forwardWeitoutiaoContentItem], wctlContentItem, wcContentItem, qqContentItem, qqZoneContentItem];
}

- (UIImage *)defaultShareImage
{
    UIImage * defaultShareImg = nil;
    //优先使用share_icon.png分享
    if (!defaultShareImg) {
        defaultShareImg = [UIImage imageNamed:@"share_icon.png"];
    }
    
    //无图时使用icon
    if(!defaultShareImg)
    {
        defaultShareImg = [UIImage imageNamed:@"Icon.png"];
    }
    return defaultShareImg;
}

- (TTDirectForwardWeitoutiaoContentItem *)directForwardWeitoutiaoContentItem {
    TTDirectForwardWeitoutiaoContentItem *item = [[TTDirectForwardWeitoutiaoContentItem alloc] init];
    item.repostParams = [self commonRepostParameters];
    item.customAction = nil;
    return item;
}

- (TTForwardWeitoutiaoContentItem *)forwardWeitoutiaoContentItem {
    TTForwardWeitoutiaoContentItem * contentItem = [[TTForwardWeitoutiaoContentItem alloc] init];
    WeakSelf;
    contentItem.customAction = ^{
        StrongSelf;
        [self forwardToWeitoutiao];
    };
    contentItem.repostParams = [self commonRepostParameters];
    return contentItem;
}

- (nullable NSArray<id<TTActivityContentItemProtocol>> *)customContentItems {
    NSMutableArray<id<TTActivityContentItemProtocol>> * contentItems = @[].mutableCopy;
    
    [contentItems addObject:[TTNightModelContentItem new]];
    [contentItems addObject:[TTFontSettingContentItem new]];
    
    NSString *userID = self.commentRepostDetailModel.commentRepostModel.userModel.info.user_id;
    BOOL isBlocking = self.commentRepostDetailModel.commentRepostModel.userModel.block.is_blocking.boolValue;
    
    if ([TTAccountManager isLogin] && [[TTAccountManager userID] isEqualToString:userID]) {
        [contentItems addObject:[self deleteContentItem]];
    }else {
        if (isBlocking) {
            [contentItems addObject:[self cancelBlockContentItem]];
        } else {
            [contentItems addObject:[self blockContentItem]];
        }
        [contentItems addObject:[self reportContentItem]];
    }
    
    if (contentItems.count > 0) {
        return [contentItems copy];
    }else {
        return nil;
    }
}

#pragma mark - Private Methods

- (void)forwardToWeitoutiao {
    
    NSDictionary *parameters = [[self commonRepostParameters] copy];
    
    [[TTRoute sharedRoute] openURLByPresentViewController:[NSURL URLWithString:@"sslocal://repost_page"] userInfo:TTRouteUserInfoWithDict(parameters)];
}

- (NSDictionary *)commonRepostParameters {

    NSString *coverURL;
    NSString *title;
    BOOL is_video = NO;
    NSString *group_id;
    
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    if (!SSIsEmptyDictionary(self.commentRepostDetailModel.commentRepostModel.repostParamsDict)) {
        [parameters addEntriesFromDictionary:self.commentRepostDetailModel.commentRepostModel.repostParamsDict];
    }

    if (self.commentRepostDetailModel.commentRepostModel.originRepostCommonModel) {
        UGCRepostCommonModel *originRepostCommonModel = self.commentRepostDetailModel.commentRepostModel.originRepostCommonModel;

        coverURL = [TTRepostService coverURLWithRepostCommonModel:originRepostCommonModel];
        title = originRepostCommonModel.title;
        is_video = originRepostCommonModel.has_video.boolValue;
        group_id = originRepostCommonModel.group_id;
    } else if (self.commentRepostDetailModel.commentRepostModel.originGroup) {
        Article *originArticle = self.commentRepostDetailModel.commentRepostModel.originGroup;

        coverURL = [TTRepostService coverURLWithArticle:originArticle];
        if (!isEmptyString(originArticle.title)) {
            
            NSString *userName = nil;
            if (!isEmptyString([originArticle.userInfo tt_stringValueForKey:@"name"])) {
                userName = [originArticle.userInfo tt_stringValueForKey:@"name"];
            } else if (!isEmptyString([originArticle.userInfo tt_stringValueForKey:@"screen_name"])) {
                userName= [originArticle.userInfo tt_stringValueForKey:@"screen_name"];
            } else if (!isEmptyString(originArticle.source)) {
                userName = originArticle.source;
            }
            
            if (!isEmptyString(userName)) {
                title = [NSString stringWithFormat:@"%@：%@", userName, originArticle.title];
            }
            else {
                title = originArticle.title;
            }
        }
        is_video = [originArticle hasVideo].boolValue;
        group_id = [NSString stringWithFormat:@"%@",@(originArticle.uniqueID)];
    } else if (self.commentRepostDetailModel.commentRepostModel.originThread) {
        Thread *originThread = self.commentRepostDetailModel.commentRepostModel.originThread;

        coverURL = [TTRepostService coverURLWithThread:originThread];
        if (!isEmptyString(originThread.title)) {
            title = originThread.title;
        }
        else if (!isEmptyString(originThread.content)) {
            title = originThread.content;
        }
        else {
            title = NSLocalizedString(@"分享图片", nil);
        }
        
        if (!isEmptyString(title) && !isEmptyString(originThread.screenName)) {
            title = [NSString stringWithFormat:@"%@：%@", originThread.screenName, title];
        }
        
        if (!isEmptyString(originThread.threadId) ) {
            group_id = [originThread.threadId copy];
        }
    }
    
    if (!self.commentRepostDetailModel.commentRepostModel.showOrigin) {
        coverURL = nil;
        if (!isEmptyString(self.commentRepostDetailModel.commentRepostModel.showTips)) {
            title = self.commentRepostDetailModel.commentRepostModel.showTips;
        } else {
            title = [[TTKitchenMgr sharedInstance] getString:kKCUGCRepostDeleteHint];
        }
    }
    
    TTRichSpanText *richSpanText = [TTRepostService richSpanWithContent:[self.commentRepostDetailModel.commentRepostModel getRichContent]
                                                                   user:self.commentRepostDetailModel.commentRepostModel.userModel.info];
    
    [parameters setValue:richSpanText.text forKey:@"content"];
    [parameters setValue:[TTRichSpans JSONStringForRichSpans:richSpanText.richSpans] forKey:@"content_rich_span"];
    [parameters setValue:coverURL forKey:@"cover_url"];
    [parameters setValue:title forKey:@"title"];
    [parameters setValue:@(is_video) forKey:@"is_video"];
    [parameters setValue:group_id forKey:@"group_id"];
    
    return parameters;
}



- (void)blockUser {
    TTThemedAlertController *alert = [[TTThemedAlertController alloc] initWithTitle:@"确定拉黑该用户？" message:@"拉黑后此用户不能关注你，也无法给你发送任何消息" preferredType:TTThemedAlertControllerTypeAlert];
    [alert addActionWithTitle:@"取消" actionType:TTThemedAlertActionTypeCancel actionBlock:nil];
    [alert addActionWithTitle:@"确定" actionType:TTThemedAlertActionTypeNormal actionBlock:^{;
        [self.blockUserManager blockUser:self.commentRepostDetailModel.commentRepostModel.userModel.info.user_id];
        
        [self trackWithEvent:@"talk_detail" label:@"black_confirm" extraDictionary:nil containExtraTracks:YES];
    }];
    [alert showFrom:[TTUIResponderHelper topmostViewController] animated:YES];
}

#pragma mark - Items


- (TTThreadDeleteContentItem *)deleteContentItem {
    WeakSelf;
    TTThreadDeleteContentItem * deleteContentItem = [[TTThreadDeleteContentItem alloc] initWithTitle:NSLocalizedString(@"删除", nil)
                                                                                           imageName:@"delete_allshare"];
    deleteContentItem.customAction = ^{

        [wself trackWithEventV3:@"comment_repost_delect" extraDictionary:@{
                                                                           @"source": @"repost_detail"
                                                                           } isDoubleSending:NO];
        
        
        
        [[TTCommentDataManager sharedManager] deleteCommentWithCommentID:self.commentRepostDetailModel.commentRepostModel.commentId finishBlock:^(NSError * _Nullable error) {
            if (error == nil) {
                
                NSString *tips = NSLocalizedString(@"操作成功", nil);
                [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage
                                          indicatorText:tips
                                         indicatorImage:[UIImage themedImageNamed:@"doneicon_popup_textpage"]
                                            autoDismiss:YES
                                         dismissHandler:nil];
                
                
                //通知混排列表页
                [[NSNotificationCenter defaultCenter] postNotificationName:kDeleteCommentNotificationKey
                                                                    object:wself
                                                                  userInfo:@{@"id":wself.commentRepostDetailModel.commentRepostModel.commentId?:@(0)}];
                //删除混排列表数据库中的数据
                NSString *uniqueID = wself.commentRepostDetailModel.commentRepostModel.commentId;
                NSArray * orderedDataArray = [ExploreOrderedData objectsWithQuery:@{@"uniqueID":uniqueID}];
                [ExploreOrderedData removeEntities:orderedDataArray];
                //数据库中的帖子标识为已删除
                [FRCommentRepost setCommentRepostDeletedWithID:uniqueID];
                
            }else {
                NSString *tips = NSLocalizedString(@"操作失败", nil);
                [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage
                                          indicatorText:tips
                                         indicatorImage:[UIImage themedImageNamed:@"close_popup_textpage"]
                                            autoDismiss:YES
                                         dismissHandler:nil];
            }

        }];
    };
    
    return deleteContentItem;
}

- (TTBlockContentItem *)cancelBlockContentItem {
    WeakSelf;
    TTBlockContentItem * cancelBlockContentItem = [[TTBlockContentItem alloc] initWithTitle:NSLocalizedString(@"取消拉黑", nil)
                                                                                  imageName:@"shield_allshare_selected"];
    cancelBlockContentItem.customAction = ^{
        StrongSelf;
        [wself trackWithEvent:@"talk_detail"
                        label:@"black_cancel"
              extraDictionary:nil
           containExtraTracks:YES];
        [self.blockUserManager unblockUser:self.commentRepostDetailModel.commentRepostModel.userModel.info.user_id];
    };
    return cancelBlockContentItem;
}

- (TTBlockContentItem *)blockContentItem {
    WeakSelf;
    TTBlockContentItem * blockContentItem = [[TTBlockContentItem alloc] initWithTitle:NSLocalizedString(@"拉黑", nil)
                                                                            imageName:@"shield_allshare"];
    blockContentItem.customAction = ^{
        [wself trackWithEvent:@"talk_detail"
                        label:@"black"
              extraDictionary:nil
           containExtraTracks:YES];
        
        if (![TTAccountManager isLogin]) {
            [TTAccountManager showLoginAlertWithType:TTAccountLoginAlertTitleTypeSocial source:@"topic_item_block" completion:^(TTAccountAlertCompletionEventType type, NSString *phoneNum) {
                if (type == TTAccountAlertCompletionEventTypeDone) {
                    if ([TTAccountManager isLogin]) {
                        [wself blockUser];
                    }
                } else if (type == TTAccountAlertCompletionEventTypeTip) {
                    [TTAccountManager presentQuickLoginFromVC:[TTUIResponderHelper topNavigationControllerFor: nil]
                                                         type:TTAccountLoginDialogTitleTypeDefault
                                                       source:@"topic_item_block"
                                                   completion:^(TTAccountLoginState state) {
                                                       
                                                   }];
                }
            }];
            return;
        }
        [wself blockUser];
    };
    return blockContentItem;
}

- (TTReportUserContentItem *)reportContentItem {
    WeakSelf;
    TTReportUserContentItem * reportContentItem = [[TTReportUserContentItem alloc] initWithTitle:NSLocalizedString(@"举报", nil)
                                                                                       imageName:@"report_allshare"];
    reportContentItem.customAction = ^{
        StrongSelf;
        [self trackWithEvent:@"talk_detail"
                       label:@"report"
             extraDictionary:nil
          containExtraTracks:YES];
        
        self.actionSheetController = [[TTActionSheetController alloc] init];
        
        [self.actionSheetController insertReportArray:[TTReportManager fetchReportUserOptions]];
        WeakSelf;
        [self.actionSheetController performWithSource:TTActionSheetSourceTypeUser completion:^(NSDictionary * _Nonnull parameters) {
            if (parameters[@"report"]) {
                TTReportUserModel *model = [[TTReportUserModel alloc] init];
                model.userID = wself.commentRepostDetailModel.commentRepostModel.userModel.info.user_id;
                model.commentID = wself.commentRepostDetailModel.commentRepostModel.commentId;
                model.groupID =  wself.commentRepostDetailModel.commentRepostModel.groupId;
                [[TTReportManager shareInstance] startReportUserWithType:parameters[@"report"] inputText:parameters[@"criticism"] message:nil source:@(TTReportSourceComment).stringValue userModel:model animated:YES];
            }
        }];
    };
    return reportContentItem;
}

#pragma mark - TTShareManagerDelegate

- (void)shareManager:(TTShareManager *)shareManager
         clickedWith:(id<TTActivityProtocol>)activity {
    NSString * contentItemType = activity.contentItem.contentItemType;
    NSMutableDictionary *extraDic = [NSMutableDictionary dictionary];
    [extraDic setValue:self.categoryID forKey:@"source"];
    [extraDic setValue:self.shareSection forKey:@"section"];
    
    if ([self.shareActivityContentItemTypes containsObject:contentItemType]) {
        //分享Activities
        NSString *label = [[TTUGCPodBridge sharedInstance] shareMethodUtilLabelNameForShareActivity:activity];
        [self trackWithEvent:@"share_topic_post"
                       label:label
             extraDictionary:extraDic
          containExtraTracks:YES];
        [self trackWithEventV3:@"detail_share_topic" extraDictionary:nil isDoubleSending:YES];

        TTDetailActionReuestContext *context = [TTDetailActionReuestContext new];
        context.mediaID = self.commentRepostDetailModel.commentRepostModel.commentId;
        [self.actionManager setContext:context];
        
        DetailActionRequestType requestType = [[TTUGCPodBridge sharedInstance] shareMethodUtilRequestTypeForShareActivityType:activity];
        [self.actionManager startItemActionByType:requestType];
    }else if([contentItemType isEqualToString:TTActivityContentItemTypeNightMode]) {
        //日夜间设置Activity
        [self trackWithEvent:@"talk_detail"
                       label:@"change_theme"
             extraDictionary:nil
          containExtraTracks:YES];
    }else if ([contentItemType isEqualToString:TTActivityContentItemTypeFontSetting]) {
        //字体设置Activity
        [self trackWithEvent:@"talk_detail"
                       label:@"set_font"
             extraDictionary:nil
          containExtraTracks:YES];
    } else if ([contentItemType isEqualToString:TTActivityContentItemTypeForwardWeitoutiao]) {
        [self trackWithEvent:@"share_topic_post"
                       label:@"share_weitoutiao"
             extraDictionary:extraDic
          containExtraTracks:YES];
    } else if (activity == nil) {
        [self trackWithEvent:@"share_topic_post"
                       label:@"share_cancel_button"
             extraDictionary:extraDic
          containExtraTracks:YES];
    }
}

- (void)shareManager:(TTShareManager *)shareManager
       completedWith:(id<TTActivityProtocol>)activity
               error:(NSError *)error
                desc:(NSString *)desc {
    NSString * contentItemType = activity.contentItem.contentItemType;
    
    if ([self.shareActivityContentItemTypes containsObject:contentItemType]) {
        //分享Activities
        NSString *label = [[TTUGCPodBridge sharedInstance] shareMethodUtilLabelNameForShareActivity:activity shareState:(error ? NO : YES)];
        [self trackWithEvent:@"share_topic_post"
                       label:label
             extraDictionary:@{@"source" : @"detail_more_button"}
          containExtraTracks:YES];
        
        if(!isEmptyString(desc)) {
            [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage
                                      indicatorText:desc
                                     indicatorImage:[UIImage themedImageNamed:error ? @"close_popup_textpage.png" : @"doneicon_popup_textpage.png"]
                                        autoDismiss:YES
                                     dismissHandler:nil];
        }
        
        if (!error) {
            //分享成功，调用站外分享逻辑
            NSDictionary *repostParameters = [[self commonRepostParameters] copy];
            if (!SSIsEmptyDictionary(repostParameters)) {
                [[TTShareToRepostManager sharedManager] shareToRepostWithActivity:activity withRepostParameters:repostParameters];
            }
        }
    }
    
    //分享成功或失败，触发分享item排序
    [[TTUGCPodBridge sharedInstance] activityShareSequenceManagerSortWithActivity:activity error:error];
}

@end
