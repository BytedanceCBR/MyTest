//
//  FRThreadSmartDetailViewModel+Activity.m
//  Article
//
//  Created by 延晋 张 on 16/4/24.
//
//

#import "FRThreadSmartDetailViewModel+Activity.h"
#import <objc/runtime.h>

//Pods
#import <TTNavigationController.h>
#import <TTPanelControllerItem.h>
#import <TTAccountBusiness.h>
#import <TTBlockManager.h>
#import <TTActivityContentItemProtocol.h>
#import <TTThemeManager.h>
#import <UIImage+TTThemeExtension.h>
#import <TTActionSheetController.h>
#import <TTReportManager.h>
#import <TTWechatTimelineContentItem.h>
#import <TTWechatContentItem.h>
#import <TTQQFriendContentItem.h>
#import <TTQQZoneContentItem.h>
//#import <TTDingTalkContentItem.h>
//#import <TTSystemContentItem.h>
#import <TTFavouriteContentItem.h>
#import <TTNightModelContentItem.h>
#import <TTFontSettingContentItem.h>
#import <TTBlockContentItem.h>
#import <TTArticleCategoryManager.h>
#import <TTForwardWeitoutiaoContentItem.h>
#import <TTDirectForwardWeitoutiaoContentItem.h>
#import <TTAdPromotionManager.h>
#import <TTAdPromotionContentItem.h>
#import <TTWebImageManager.h>
//#import <TTCopyContentItem.h>
#import <TTShortVideoModel.h>
#import <TTRepostServiceProtocol.h>

//UGCFoundation
#import <TTUGCDefine.h>
#import "UGCRepostCommonModel.h"
#import "TTKitchenHeader.h"
#import <TTUGCPodBridge.h>
#import "TTUGCShareUtil.h"
#import "TTThreadStarOperateContentItem.h"
#import "TTThreadTopOperateContentItem.h"
#import "TTThreadRateOperateContentItem.h"
#import "TTThreadOnlyOperateContentItem.h"
#import "TTThreadDeleteContentItem.h"
#import "TTReportUserContentItem.h"
#import "TTUGCFavoriteManager.h"
#import "TTRepostViewController.h"
#import "TTRepostOriginModels.h"
#import "TTRepostService.h"

//UGCFeature
#import "TTShareToRepostManager.h"

extern BOOL ttvs_isShareIndividuatioEnable(void);

@implementation FRThreadSmartDetailViewModel (Activity)

#pragma mark - Public Methods

- (void)setThreadDetailShareSection:(NSString *)threadDetailShareSection
{
    objc_setAssociatedObject(self, @selector(threadDetailShareSection), threadDetailShareSection, OBJC_ASSOCIATION_COPY_NONATOMIC);
}
- (NSString *)threadDetailShareSection
{
    return objc_getAssociatedObject(self, @selector(threadDetailShareSection));
}


- (nullable NSArray<id<TTActivityContentItemProtocol>> *)forwardSharePanelContentItems
{
    NSMutableArray *mutableArray = [NSMutableArray arrayWithArray:[self allShareContentItems]];
    [mutableArray addObject:[self directForwardWeitoutiaoContentItem]];
    
    return mutableArray;
}
- (nullable NSArray<id<TTActivityContentItemProtocol>> *)shareContentItems
{
    NSMutableArray *mutableArray = [NSMutableArray arrayWithCapacity:6];
    for (id<TTActivityContentItemProtocol> object in [self allShareContentItems]) {
//        if (![object isKindOfClass:[TTSystemContentItem class]]) {
//            [mutableArray addObject:object];
//        }
    }
    
    return mutableArray;
}
- (nullable NSArray<id<TTActivityContentItemProtocol>> *)allShareContentItems {
    NSString * shareTitle = nil;
    NSString * shareDescribe = nil;
    NSMutableSet * shareActivityContentItemTypes = [NSMutableSet set];
    if (self.thread.score.doubleValue > 0) {
        //影评分享文案单独控制
        NSString * movieName = [self.thread forumName];
        shareTitle = !isEmptyString(movieName)?movieName:NSLocalizedString(@"爱看", nil);
        NSString * content = !isEmptyString(self.thread.content)?self.thread.content:self.thread.title;
        shareDescribe = [NSString stringWithFormat:@"%@：%@分，%@", NSLocalizedString(@"评分", nil), self.thread.score, !isEmptyString(content) ? content : NSLocalizedString(@"越看越爱看", nil)];
    }else {
        shareTitle = [KitchenMgr getString:kKCUGCFeedNamesShare];
        if (isEmptyString(self.thread.title) && isEmptyString(self.thread.content)) {
            shareDescribe = NSLocalizedString(@"发现你感兴趣的新鲜事", nil);
        }else {
            NSMutableString * mutableShareDescribe = [NSMutableString stringWithFormat:@"%@：", [self.thread screenName]];
            if (!isEmptyString(self.thread.title)) {
                [mutableShareDescribe appendFormat:@"「%@」", self.thread.title];
            }
            if (!isEmptyString(self.thread.content)) {
                [mutableShareDescribe appendString:self.thread.content];
            }
            shareDescribe = mutableShareDescribe.copy;
        }
    }
    
    //微信朋友圈分享
    TTWechatTimelineContentItem * wctlContentItem = [[TTWechatTimelineContentItem alloc] initWithTitle:shareDescribe
                                                                                                  desc:nil
                                                                                            webPageUrl:self.thread.shareURL
                                                                                            thumbImage:[TTUGCShareUtil shareThumbImageForThread:self.thread]
                                                                                             shareType:TTShareWebPage];
    [shareActivityContentItemTypes addObject:TTActivityContentItemTypeWechatTimeLine];
    
    //微信好友分享
    TTWechatContentItem *wcContentItem = [[TTWechatContentItem alloc] initWithTitle:shareTitle
                                                                               desc:shareDescribe
                                                                         webPageUrl:self.thread.shareURL
                                                                         thumbImage:[TTUGCShareUtil shareThumbImageForThread:self.thread]
                                                                          shareType:TTShareWebPage];
    [shareActivityContentItemTypes addObject:TTActivityContentItemTypeWechat];
    
    //QQ好友分享
    TTQQFriendContentItem * qqContentItem = [[TTQQFriendContentItem alloc] initWithTitle:shareTitle
                                                                                    desc:shareDescribe
                                                                              webPageUrl:self.thread.shareURL
                                                                              thumbImage:[TTUGCShareUtil shareThumbImageForThread:self.thread]
                                                                                imageUrl:[TTUGCShareUtil shareThumbImageURLForThread:self.thread]
                                                                                shareTye:TTShareWebPage];
    [shareActivityContentItemTypes addObject:TTActivityContentItemTypeQQFriend];
    
    //QQ空间分享
    TTQQZoneContentItem * qqZoneContentItem = [[TTQQZoneContentItem alloc] initWithTitle:shareTitle
                                                                                    desc:shareDescribe
                                                                              webPageUrl:self.thread.shareURL
                                                                              thumbImage:[TTUGCShareUtil shareThumbImageForThread:self.thread]
                                                                                imageUrl:[TTUGCShareUtil shareThumbImageURLForThread:self.thread]
                                                                                shareTye:TTShareWebPage];
    [shareActivityContentItemTypes addObject:TTActivityContentItemTypeQQZone];
    
//    //钉钉分享
//    TTDingTalkContentItem * ddContentItem = [[TTDingTalkContentItem alloc] initWithTitle:shareTitle
//                                                                                    desc:shareDescribe
//                                                                              webPageUrl:self.thread.shareURL
//                                                                              thumbImage:[TTUGCShareUtil shareThumbImageForThread:self.thread]
//                                                                               shareType:TTShareWebPage];
//    [shareActivityContentItemTypes addObject:TTActivityContentItemTypeDingTalk];
//
//
//    //系统分享
//    TTSystemContentItem *systemContentItem = [[TTSystemContentItem alloc] initWithDesc:shareDescribe
//                                                                            webPageUrl:self.thread.shareURL
//                                                                                 image:[TTUGCShareUtil shareThumbImageForThread:self.thread]];
//    [shareActivityContentItemTypes addObject:TTActivityContentItemTypeSystem];
//
//    //copy
//    TTCopyContentItem * copyContentItem = [[TTCopyContentItem alloc] initWithDesc:self.thread.shareURL];
//    [shareActivityContentItemTypes addObject:TTActivityContentItemTypeCopy];
    
    self.shareActivityContentItemTypes = shareActivityContentItemTypes.copy;
   
    NSMutableArray *SeqArray = @[].mutableCopy;
    if (!ttvs_isShareIndividuatioEnable())
    {
        [SeqArray addObject:[self forwardWeitoutiaoContentItem]];
        [SeqArray addObject: wctlContentItem];
        [SeqArray addObject: wcContentItem];
        [SeqArray addObject: qqContentItem];
        [SeqArray addObject: qqZoneContentItem];
//        [SeqArray addObject:ddContentItem];
        
    }//分享面板个性化排序
    else{
        NSArray *typeArray = [[TTUGCPodBridge sharedInstance] activityShareSequenceManagerGetAllShareServiceSequence];
        [typeArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj isKindOfClass:[NSString class]]) {
                NSString *objType = (NSString *)obj;
                if ([objType isEqualToString:TTActivityContentItemTypeWechatTimeLine]){
                    [SeqArray addObject:wctlContentItem];
                }
                else if ([objType isEqualToString:TTActivityContentItemTypeWechat]){
                    [SeqArray addObject:wcContentItem];
                }
                else if ([objType isEqualToString:TTActivityContentItemTypeQQFriend]){
                    [SeqArray addObject:qqContentItem];
                }
                else if ([objType isEqualToString:TTActivityContentItemTypeQQZone]){
                    [SeqArray addObject:qqZoneContentItem];
                }
//                else if ([objType isEqualToString:TTActivityContentItemTypeDingTalk]){
//                    [SeqArray addObject:ddContentItem];
//                }
                else if ([objType isEqualToString:TTActivityContentItemTypeForwardWeitoutiao]){
                    [SeqArray addObject:[self forwardWeitoutiaoContentItem]];
                }
            }
        }];
    }
//    [SeqArray addObject:systemContentItem];
//    [SeqArray addObject:copyContentItem];
    return [SeqArray copy];
}

- (TTDirectForwardWeitoutiaoContentItem *)directForwardWeitoutiaoContentItem {
    TTDirectForwardWeitoutiaoContentItem *item = [[TTDirectForwardWeitoutiaoContentItem alloc] init];
    item.repostParams = [self repostParams];
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
    contentItem.repostParams = [self repostParams];
    
    return contentItem;
}


- (nullable NSArray<id<TTActivityContentItemProtocol>> *)customContentItems {
    NSMutableArray<id<TTActivityContentItemProtocol>> * contentItems = @[].mutableCopy;
    
    
    
    [contentItems addObject:[self favoriteItem]];
    [contentItems addObject:[TTNightModelContentItem new]];
    [contentItems addObject:[TTFontSettingContentItem new]];
    if ([TTAccountManager isLogin] && [[TTAccountManager userID] isEqualToString:[self.thread userID]]) {
        [contentItems addObject:[self deleteContentItem]];
    }else {
        if ([self.thread isBlocking]) {
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



- (NSDictionary *)repostParams {
    NSDictionary *repostParams;
    if (self.thread.repostOriginType == TTThreadRepostOriginTypeArticle) {
        //当前帖子是转发文章（问答）生成的，则实际转发的是文章（问答），被操作对象为帖子
        TTRepostContentSegment *segment = [[TTRepostContentSegment alloc] init];
        segment.username = [self.thread screenName];
        segment.userID = [self.thread userID];
        segment.content = [[TTRichSpanText alloc] initWithText:self.thread.content richSpans:[TTRichSpans richSpansForJSONString:self.thread.contentRichSpanJSONString]];
        NSArray *segments = [[NSArray alloc] initWithObjects:segment, nil];
        
        repostParams = [TTRepostService repostParamsWithRepostType:[[self.thread repostType] integerValue]
                                      originArticle:[[TTRepostOriginArticle alloc] initWithArticle:self.thread.originGroup]
                                       originThread:nil
                       originShortVideoOriginalData:nil
                                  originWendaAnswer:nil
                                  operationItemType:TTRepostOperationItemTypeThread
                                    operationItemID:self.thread.threadId
                                     repostSegments:segments];
         
        
    }
    else if ([self.thread repostOriginType] == TTThreadRepostOriginTypeThread) { //当前帖子是转发帖子生成的，则实际转发的是原帖，被操作对象为帖子
        TTRepostContentSegment *segment = [[TTRepostContentSegment alloc] init];
        segment.username = [self.thread screenName];
        segment.userID = [self.thread userID];
        segment.content = [[TTRichSpanText alloc] initWithText:self.thread.content richSpans:[TTRichSpans richSpansForJSONString:self.thread.contentRichSpanJSONString]];
        NSArray *segments = [[NSArray alloc] initWithObjects:segment, nil];
        repostParams = [TTRepostService repostParamsWithRepostType:[[self.thread repostType] integerValue]
                                                     originArticle:nil
                                                      originThread:[[TTRepostOriginThread alloc] initWithThread:self.thread.originThread]
                                      originShortVideoOriginalData:nil
                                                 originWendaAnswer:nil
                                                 operationItemType:TTRepostOperationItemTypeThread
                                                   operationItemID:self.thread.threadId
                                                    repostSegments:segments];
        
    }
    else if ([self.thread repostOriginType] == TTThreadRepostOriginTypeShortVideo) {
        
        if (self.thread.repostParameters.count > 0) { //如果后端下发了repostParams，走后端透传字段
            NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
            
            [parameters addEntriesFromDictionary:self.thread.repostParameters];
            
            NSString *content;
            NSString *contentRichSpan;
            
            TTRepostContentSegment *segment = [[TTRepostContentSegment alloc] init];
            segment.username = [self.thread screenName];
            segment.userID = [self.thread userID];
            segment.content = [[TTRichSpanText alloc] initWithText:self.thread.content richSpans:[TTRichSpans richSpansForJSONString:self.thread.contentRichSpanJSONString]];
            NSArray *segments = [[NSArray alloc] initWithObjects:segment, nil];
            
            TTRichSpanText *richSpanText = [TTRepostContentSegment richSpanTextForRepostSegments:segments];
            if (richSpanText) {
                content = richSpanText.text;
                if (richSpanText.richSpans) {
                    contentRichSpan = [TTRichSpans JSONStringForRichSpans:richSpanText.richSpans];
                }
            }
            [parameters setValue:@(1) forKey:@"is_video"];
            [parameters setValue:content forKey:@"content"];
            [parameters setValue:contentRichSpan forKey:@"content_rich_span"];
            
            TTShortVideoModel *shortVideo = [[TTUGCPodBridge sharedInstance] originShortVideoModelForThread:self.thread];
            
            NSString *title = shortVideo.title;
            if (isEmptyString(title)) {
                title = [NSString stringWithFormat:@"%@：%@", shortVideo.author.name, [KitchenMgr getString:kKCUGCShortVideoTitlePlaceholder]];
            }
            if (shortVideo.showOrigin && NO == shortVideo.showOrigin.boolValue){
                if (!isEmptyString(shortVideo.showTips)) {
                    title = shortVideo.showTips;
                }else {
                    title = [[TTKitchenMgr sharedInstance] getString:kKCUGCRepostDeleteHint];
                }
            }
            [parameters setValue:title forKey:@"title"];
            
            FRImageInfoModel *thumbImage = [[FRImageInfoModel alloc] initWithTTImageInfosModel:shortVideo.detailCoverImageModel];
            NSString *coverURL = thumbImage.url;
            [parameters setValue:coverURL forKey:@"cover_url"];
            
            repostParams = parameters.copy;
            
        } else {
            //转发抖音生成的帖子，实际转发对象为抖音，操作对象为帖子
            TTRepostContentSegment *segment = [[TTRepostContentSegment alloc] init];
            segment.username = [self.thread screenName];
            segment.userID = [self.thread userID];
            segment.content = [[TTRichSpanText alloc] initWithText:self.thread.content richSpans:[TTRichSpans richSpansForJSONString:self.thread.contentRichSpanJSONString]];
            NSArray *segments = [[NSArray alloc] initWithObjects:segment, nil];
            repostParams = [TTRepostService repostParamsWithRepostType:self.thread.repostType.integerValue
                                                         originArticle:nil
                                                          originThread:nil
                                          originShortVideoOriginalData:[[TTRepostOriginShortVideoOriginalData alloc] initWithShortVideoOriginalData:self.thread.originShortVideoOriginalData]
                                                     originWendaAnswer:nil
                                                     operationItemType:TTRepostOperationItemTypeThread
                                                       operationItemID:self.thread.threadId
                                                        repostSegments:segments];
            
        }
    }
    else if ([self.thread repostOriginType] == TTThreadRepostOriginTypeCommon){
        
        repostParams = [self commonRepostParameters];
    }
    else if ([self.thread repostOriginType] == TTThreadRepostOriginTypeNone) { //当前帖子是普通帖子，则实际转发的是帖子，被操作对象为帖子
        TTRepostOriginThread *originThread = [[TTRepostOriginThread alloc] init];
        originThread.threadID = self.thread.threadId;
        originThread.title = self.thread.title;
        originThread.content = self.thread.content;
        originThread.contentRichSpanJSONString = self.thread.contentRichSpanJSONString;
        if ([self.thread.getThumbImageModels count] > 0) {
            originThread.thumbImage = [self.thread.getThumbImageModels firstObject];
        }
        originThread.userID = [self.thread userID];
        originThread.userName = [self.thread screenName];
        originThread.userAvatar = [self.thread avatarURL];
        originThread.isDeleted = self.thread.actionDataModel.hasDelete;
        repostParams = [TTRepostService repostParamsWithRepostType:TTThreadRepostTypeThread
                                                     originArticle:nil
                                                      originThread:originThread
                                      originShortVideoOriginalData:nil
                                                 originWendaAnswer:nil
                                                 operationItemType:TTRepostOperationItemTypeThread
                                                   operationItemID:self.thread.threadId
                                                    repostSegments:nil];
        
    }
    return repostParams;
}
- (void)forwardToWeitoutiao
{
    [[TTRoute sharedRoute] openURLByPresentViewController:[NSURL URLWithString:@"sslocal://repost_page"] userInfo:TTRouteUserInfoWithDict([self repostParams])];

}

- (NSDictionary *)commonRepostParameters {
    
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    if (!SSIsEmptyDictionary(self.thread.repostParameters)) {
        [parameters addEntriesFromDictionary:self.thread.repostParameters];
    }

    if (self.thread.originRepostCommonModel) {
        UGCRepostCommonModel *originRepostCommonModel = self.thread.originRepostCommonModel;

        [parameters setValue:[TTRepostService coverURLWithRepostCommonModel:originRepostCommonModel] forKey:@"cover_url"];
        [parameters setValue:@(originRepostCommonModel.has_video.boolValue) forKey:@"is_video"];
        [parameters setValue:originRepostCommonModel.title forKey:@"title"];
        [parameters setValue:originRepostCommonModel.group_id forKey:@"group_id"];
    }

    NSString *content;
    NSString *contentRichSpan;
    
    TTRepostContentSegment *segment = [[TTRepostContentSegment alloc] initWithRichSpanText:self.thread.richContent userID:self.thread.userID username:self.thread.screenName];
    segment.userSchema = [self.thread.user tt_stringValueForKey:@"schema"];

    TTRichSpanText *richSpanText = [TTRepostContentSegment richSpanTextForRepostSegments:@[segment]];
    if (richSpanText) {
        content = richSpanText.text;
        if (richSpanText.richSpans) {
            contentRichSpan = [TTRichSpans JSONStringForRichSpans:richSpanText.richSpans];
        }
    }
    [parameters setValue:content forKey:@"content"];
    [parameters setValue:contentRichSpan forKey:@"content_rich_span"];
    
    return parameters;
}

- (void)blockUser {
    __weak typeof(self) weakSelf = self;
    TTThemedAlertController *alert = [[TTThemedAlertController alloc] initWithTitle:@"确定拉黑该用户？" message:@"拉黑后此用户不能关注你，也无法给你发送任何消息" preferredType:TTThemedAlertControllerTypeAlert];
    [alert addActionWithTitle:@"取消" actionType:TTThemedAlertActionTypeCancel actionBlock:nil];
    [alert addActionWithTitle:@"确定" actionType:TTThemedAlertActionTypeNormal actionBlock:^{;
        [weakSelf.blockUserManager blockUser:[weakSelf.thread userID]];
        [weakSelf trackWithEvent:[weakSelf.dataSource trackEvent] label:@"black_confirm" extraDictionary:nil containExtraTracks:YES];
    }];
    [alert showFrom:[TTUIResponderHelper topmostViewController] animated:YES];
}

#pragma mark - Items

- (TTFavouriteContentItem *)favoriteItem {
    TTFavouriteContentItem * favoriteItem = [[TTFavouriteContentItem alloc] init];
    favoriteItem.selected = self.thread.userRepined;
    __weak TTFavouriteContentItem * weakFavoriteItem = favoriteItem;
    WeakSelf;
    favoriteItem.customAction = ^{
        StrongSelf;
        NSString *label = nil;
        if (self.thread.userRepined){
            label = @"unfavorite_button";
        }else {
            label = @"favorite_button";
        }
        [self trackWithEvent:[self.dataSource trackEvent]
                       label:label
             extraDictionary:nil
          containExtraTracks:YES];
        
        if (!TTNetworkConnected()){
            [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage
                                      indicatorText:NSLocalizedString(@"没有网络连接", nil)
                                     indicatorImage:[UIImage themedImageNamed:@"close_popup_textpage.png"]
                                        autoDismiss:YES
                                     dismissHandler:nil];
            NSString *label = nil;
            if (self.thread.userRepined){
                label = @"unfavorite_fail";
            }else {
                label = @"favorite_fail";
            }
            [self trackWithEvent:[self.dataSource trackEvent]
                           label:label
                 extraDictionary:nil
              containExtraTracks:YES];
            return;
        }
        
        if (!self.thread.userRepined) {
            WeakSelf;
            [TTUGCFavoriteManager favoriteForThread:self.thread
                        finishBlock:^(NSError *error) {
                            StrongSelf;
                            if (error){
                                [self trackWithEvent:[self.dataSource trackEvent]
                                               label:@"favorite_fail"
                                     extraDictionary:nil
                                  containExtraTracks:YES];
                            }else{
                                [self trackWithEvent:[self.dataSource trackEvent]
                                               label:@"favorite_success"
                                     extraDictionary:nil
                                  containExtraTracks:YES];
                                weakFavoriteItem.selected = YES;
                            }
                        }];
        }else {
            WeakSelf;
            [TTUGCFavoriteManager unfavoriteForThread:self.thread
                          finishBlock:^(NSError *error) {
                              StrongSelf;
                              if (error){
                                  [self trackWithEvent:[self.dataSource trackEvent]
                                                 label:@"unfavorite_fail"
                                       extraDictionary:nil
                                    containExtraTracks:YES];
                              }else{
                                  [self trackWithEvent:[self.dataSource trackEvent]
                                                 label:@"unfavorite_success"
                                       extraDictionary:nil
                                    containExtraTracks:YES];
                                  weakFavoriteItem.selected = NO;
                              }
                          }];
        }
        //由于分享面板在pod中，暂时使用string构造class
        __block UIWindow * activityPanelControllerWindow = nil;
        Class activityPanelControllerWindowClass = NSClassFromString(@"TTActivityPanelControllerWindow");
        [[UIApplication sharedApplication].windows enumerateObjectsUsingBlock:^(__kindof UIWindow * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj isKindOfClass:activityPanelControllerWindowClass]) {
                activityPanelControllerWindow = obj;
                *stop = YES;
            }
        }];
        if(self.thread.userRepined) {
            TTIndicatorView * indicatorView = [[TTIndicatorView alloc] initWithIndicatorStyle:TTIndicatorViewStyleImage
                                                                                indicatorText:NSLocalizedString(@"收藏成功", nil)
                                                                               indicatorImage:[UIImage themedImageNamed:@"doneicon_popup_textpage.png"]
                                                                               dismissHandler:nil];
            [indicatorView showFromParentView:activityPanelControllerWindow];
        }else {
            TTIndicatorView * indicatorView = [[TTIndicatorView alloc] initWithIndicatorStyle:TTIndicatorViewStyleImage
                                                                                indicatorText:NSLocalizedString(@"取消收藏", nil)
                                                                               indicatorImage:[UIImage themedImageNamed:@"doneicon_popup_textpage.png"]
                                                                               dismissHandler:nil];
            [indicatorView showFromParentView:activityPanelControllerWindow];
        }
    };
    return favoriteItem;
}

- (TTThreadDeleteContentItem *)deleteContentItem {
    WeakSelf;
    TTThreadDeleteContentItem * deleteContentItem = [[TTThreadDeleteContentItem alloc] initWithTitle:NSLocalizedString(@"删除", nil)
                                                                                           imageName:@"delete_allshare"];
    deleteContentItem.customAction = ^{
        [wself trackWithEvent:[wself.dataSource trackEvent]
                        label:@"delete_self"
              extraDictionary:nil
           containExtraTracks:YES];
        
        [wself deleteThread:^(NSError * _Nullable error, NSString * _Nullable tips) {
            if (error == nil) {
                if (isEmptyString(tips)) {
                    tips = NSLocalizedString(@"操作成功", nil);
                }
                [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage
                                          indicatorText:tips
                                         indicatorImage:[UIImage themedImageNamed:@"doneicon_popup_textpage"]
                                            autoDismiss:YES
                                         dismissHandler:nil];
                //删除混排列表数据库中的数据
                NSString *uniqueID = wself.thread.threadId;
                NSArray * orderedDataArray = [ExploreOrderedData objectsWithQuery:@{@"uniqueID":uniqueID}];
                [ExploreOrderedData removeEntities:orderedDataArray];
                //数据库中的帖子标识为已删除
                [Thread setThreadHasBeDeletedWithThreadID:uniqueID];//通知混排列表页
                [[NSNotificationCenter defaultCenter] postNotificationName:kTTForumDeleteThreadNotification
                                                                    object:wself
                                                                  userInfo:@{kTTForumThreadID:wself.thread.threadId?:@(0)}];
            }else {
                if (isEmptyString(tips)) {
                    tips = NSLocalizedString(@"操作失败", nil);
                }
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
        [wself trackWithEvent:[wself.dataSource trackEvent]
                        label:@"black_cancel"
              extraDictionary:nil
           containExtraTracks:YES];
        [wself.blockUserManager unblockUser:[wself.thread userID]];
    };
    return cancelBlockContentItem;
}

- (TTBlockContentItem *)blockContentItem {
    WeakSelf;
    TTBlockContentItem * blockContentItem = [[TTBlockContentItem alloc] initWithTitle:NSLocalizedString(@"拉黑", nil)
                                                                            imageName:@"shield_allshare"];
    blockContentItem.customAction = ^{
        [wself trackWithEvent:[wself.dataSource trackEvent]
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
        [self trackWithEvent:[self.dataSource trackEvent]
                       label:@"report"
             extraDictionary:nil
          containExtraTracks:YES];
        self.actionSheetController = [[TTActionSheetController alloc] init];
        [self.actionSheetController insertReportArray:[TTReportManager fetchReportArticleOptions]];
        WeakSelf;
        [self.actionSheetController performWithSource:TTActionSheetSourceTypeUser completion:^(NSDictionary * _Nonnull parameters) {
            StrongSelf;
            if (parameters[@"report"]) {
                TTGroupModel *groupModel = [[TTGroupModel alloc] initWithGroupID:[NSString stringWithFormat:@"%lld", self.threadID]];
                NSMutableDictionary *dict = @{@"target_type":@(1)}.mutableCopy;
                if ([self.dataSource extraTracks].count){
                    [dict addEntriesFromDictionary:[self.dataSource extraTracks]];
                }
                NSString *enterFrom = [self.dataSource.extraTracks valueForKey:@"enter_from"];
                NSString *categoryID = [self.dataSource.extraTracks valueForKey:@"category_id"];
                TTReportContentModel *model = [[TTReportContentModel alloc] init];
                model.groupID = groupModel.groupID;
                model.itemID = groupModel.itemID;
                model.aggrType = @(groupModel.aggrType);
                
                [[TTReportManager shareInstance] startReportContentWithType:parameters[@"report"] inputText:parameters[@"criticism"] contentType:kTTReportContentTypeForum reportFrom:TTReportFromByEnterFromAndCategory(enterFrom, categoryID) contentModel:model extraDic:nil animated:YES];
            }
        }];
    };
    return reportContentItem;
}




#pragma mark - TTShareManagerDelegate

- (void)shareManager:(TTShareManager *)shareManager
         clickedWith:(id<TTActivityProtocol>)activity
          sharePanel:(id<TTActivityPanelControllerProtocol>)panelController {
    NSString * contentItemType = activity.contentItem.contentItemType;
    
    NSMutableDictionary *extraDict = [NSMutableDictionary dictionary];
    [extraDict setValue:[self.dataSource.commonV3TrackExtra tt_stringValueForKey:@"category_name"] forKey:@"source"];
    [extraDict setValue:self.threadDetailShareSection forKey:@"section"];
    
    if ([self.shareActivityContentItemTypes containsObject:contentItemType]) {
        //分享Activities
        NSString *label = [[TTUGCPodBridge sharedInstance] shareMethodUtilLabelNameForShareActivity:activity];
        [self trackWithEvent:@"share_topic_post"
                       label:label
             extraDictionary:extraDict
          containExtraTracks:YES];
        [extraDict addEntriesFromDictionary:self.dataSource.commonV3TrackExtra];
        [TTTrackerWrapper eventV3:@"detail_share_topic" params:extraDict   isDoubleSending:YES];
        
        TTDetailActionReuestContext *context = [TTDetailActionReuestContext new];
        context.mediaID = self.thread.threadId;
        [self.actionManager setContext:context];
        
        DetailActionRequestType requestType = [[TTUGCPodBridge sharedInstance] shareMethodUtilRequestTypeForShareActivityType:activity];
        [self.actionManager startItemActionByType:requestType];
    }else if([contentItemType isEqualToString:TTActivityContentItemTypeNightMode]) {
        //日夜间设置Activity
        [self trackWithEvent:[self.dataSource trackEvent]
                       label:@"change_theme"
             extraDictionary:nil
          containExtraTracks:YES];
    }else if ([contentItemType isEqualToString:TTActivityContentItemTypeFontSetting]) {
        //字体设置Activity
        [self trackWithEvent:[self.dataSource trackEvent]
                       label:@"set_font"
             extraDictionary:nil
          containExtraTracks:YES];
    } else if ([contentItemType isEqualToString:TTActivityContentItemTypeForwardWeitoutiao]) {
        
        [self trackWithEvent:@"share_topic_post"
                       label:@"share_weitoutiao"
             extraDictionary:extraDict containExtraTracks:YES];
    } else if (activity == nil) {
        [self trackWithEvent:@"share_topic_post"
                       label:@"share_cancel_button"
             extraDictionary:extraDict containExtraTracks:YES];
    }
}

- (void)shareManager:(TTShareManager *)shareManager
       completedWith:(id<TTActivityProtocol>)activity
          sharePanel:(id<TTActivityPanelControllerProtocol>)panelController
               error:(NSError *)error
                desc:(NSString *)desc {
    NSString * contentItemType = activity.contentItem.contentItemType;
    
    if ([self.shareActivityContentItemTypes containsObject:contentItemType]) {
        //分享Activities
        NSString *label = [[TTUGCPodBridge sharedInstance] shareMethodUtilLabelNameForShareActivity:activity shareState:(error ? NO : YES)];
        NSMutableDictionary *extraDict = [NSMutableDictionary dictionary];
        [extraDict setValue:self.thread.threadId?:@"0" forKey:@"source"];
        [extraDict setValue:self.threadDetailShareSection forKey:@"section"];
        [self trackWithEvent:@"share_topic_post"
                       label:label
             extraDictionary:extraDict
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
            if ([self.thread repostOriginType] == TTThreadRepostOriginTypeArticle) {
                //当前帖子是转发文章（问答）生成的，则实际转发的是文章（问答），被操作对象为帖子
                TTRepostContentSegment *segment = [[TTRepostContentSegment alloc] init];
                segment.username = [self.thread screenName];
                segment.userID = [self.thread userID];
                segment.content = [[TTRichSpanText alloc] initWithText:self.thread.content richSpans:[TTRichSpans richSpansForJSONString:self.thread.contentRichSpanJSONString]];
                NSArray *segments = [[NSArray alloc] initWithObjects:segment, nil];
                [[TTShareToRepostManager sharedManager] shareToRepostWithActivity:activity
                                                                       repostType:[[self.thread repostType] integerValue]
                                                                operationItemType:TTRepostOperationItemTypeThread
                                                                  operationItemID:self.thread.threadId
                                                                    originArticle:[[TTRepostOriginArticle alloc] initWithArticle:self.thread.originGroup]
                                                                     originThread:nil
                                                                   originShortVideoOriginalData:nil
                                                                originWendaAnswer:nil
                                                                   repostSegments:segments];
            }else if ([self.thread repostOriginType] == TTThreadRepostOriginTypeThread) { //当前帖子是转发帖子生成的，则实际转发的是原帖，被操作对象为帖子
                TTRepostContentSegment *segment = [[TTRepostContentSegment alloc] init];
                segment.username = [self.thread screenName];
                segment.userID = [self.thread userID];
                segment.content = [[TTRichSpanText alloc] initWithText:self.thread.content richSpans:[TTRichSpans richSpansForJSONString:self.thread.contentRichSpanJSONString]];
                NSArray *segments = [[NSArray alloc] initWithObjects:segment, nil];
                [[TTShareToRepostManager sharedManager] shareToRepostWithActivity:activity
                                                                       repostType:TTThreadRepostTypeThread
                                                                operationItemType:TTRepostOperationItemTypeThread
                                                                  operationItemID:self.thread.threadId
                                                                    originArticle:nil
                                                                     originThread:[[TTRepostOriginThread alloc] initWithThread:self.thread.originThread]
                                                                   originShortVideoOriginalData:nil
                                                                originWendaAnswer:nil
                                                                   repostSegments:segments];
            }else if ([self.thread repostOriginType] == TTThreadRepostOriginTypeShortVideo) {
                //转发抖音生成的帖子，实际转发对象为抖音，操作对象为帖子
                TTRepostContentSegment *segment = [[TTRepostContentSegment alloc] init];
                segment.username = [self.thread screenName];
                segment.userID = [self.thread userID];
                segment.content = [[TTRichSpanText alloc] initWithText:self.thread.content richSpans:[TTRichSpans richSpansForJSONString:self.thread.contentRichSpanJSONString]];
                NSArray *segments = [[NSArray alloc] initWithObjects:segment, nil];
                [[TTShareToRepostManager sharedManager] shareToRepostWithActivity:activity
                                                                       repostType:TTThreadRepostTypeShortVideo
                                                                operationItemType:TTRepostOperationItemTypeThread
                                                                  operationItemID:self.thread.threadId
                                                                    originArticle:nil
                                                                     originThread:nil
                                                                   originShortVideoOriginalData:[[TTRepostOriginShortVideoOriginalData alloc] initWithShortVideoOriginalData:self.thread.originShortVideoOriginalData]
                                                                originWendaAnswer:nil
                                                                   repostSegments:segments];
            }else if ([self.thread repostOriginType] == TTThreadRepostOriginTypeNone) { //当前帖子是普通帖子，则实际转发的是帖子，被操作对象为帖子
                TTRepostOriginThread *originThread = [[TTRepostOriginThread alloc] init];
                originThread.threadID = self.thread.threadId;
                originThread.title = self.thread.title;
                originThread.content = self.thread.content;
                if ([self.thread.getThumbImageModels count] > 0) {
                    originThread.thumbImage = [self.thread.getThumbImageModels firstObject];
                }
                originThread.userID = [self.thread userID];
                originThread.userName = [self.thread screenName];
                originThread.userAvatar = [self.thread avatarURL];
                originThread.isDeleted = self.thread.actionDataModel.hasDelete;
                [[TTShareToRepostManager sharedManager] shareToRepostWithActivity:activity
                                                                       repostType:TTThreadRepostTypeThread
                                                                operationItemType:TTRepostOperationItemTypeThread
                                                                  operationItemID:self.thread.threadId
                                                                    originArticle:nil
                                                                     originThread:originThread
                                                                   originShortVideoOriginalData:nil
                                                                originWendaAnswer:nil
                                                                   repostSegments:nil];
            }
            else if ([self.thread repostOriginType] == TTThreadRepostOriginTypeCommon){
                NSDictionary *repostParameters = [[self commonRepostParameters] copy];
                if (!SSIsEmptyDictionary(repostParameters)) {
                    [[TTShareToRepostManager sharedManager] shareToRepostWithActivity:activity withRepostParameters:repostParameters];
                }
                
            }
        }
    }
    
    //分享成功或失败，触发分享item排序
    [[TTUGCPodBridge sharedInstance] activityShareSequenceManagerSortWithActivity:activity error:error];
}
@end


