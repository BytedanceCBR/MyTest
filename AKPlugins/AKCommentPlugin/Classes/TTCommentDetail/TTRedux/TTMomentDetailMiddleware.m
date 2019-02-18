//
//  TTMomentDetailMiddleware.m
//  Article
//
//  Created by muhuai on 16/8/21.
//
//

#import "TTMomentDetailMiddleware.h"
#import "TTMomentDetailAction.h"
#import "TTMomentDetailStore.h"
#import "TTCommentDataManager.h"
#import "TTCommentDetailModel+TTCommentDetailModelProtocolSupport.h"
#import "TTCommentDetailReplyCommentModel+TTCommentDetailReplyCommentModelProtocolSupport.h"
#import "TTCommentWriteView.h"
#import <TTFriendRelation/TTBlockManager.h>
#import <TTFriendRelation/TTFollowManager.h>
#import <TTBaseLib/SSIndicatorTipsManager.h>
#import <TTBaseLib/TTUIResponderHelper.h>
#import <TTUIWidget/TTIndicatorView.h>
#import <TTNewsAccountBusiness/TTAccountBusiness.h>
#import <TTUGCFoundation/TTRichSpanText+Comment.h>
#import <TTUGCAttributedLabel.h>
#import <TTShare/TTShareManager.h>
#import <TTShare/TTWechatTimelineContentItem.h>
#import <TTShare/TTWechatContentItem.h>
#import <TTShare/TTQQFriendContentItem.h>
#import <TTShare/TTQQZoneContentItem.h>
//#import <TTShare/TTDingTalkContentItem.h>
#import <AKShareServicePlugin/TTForwardWeitoutiaoContentItem.h>
#import <SDWebImage/SDImageCache.h>
#import <TTKitchen/TTKitchen.h>


@interface TTMomentDetailMiddleware () <UIActionSheetDelegate, TTShareManagerDelegate>

@property (nonatomic, strong) TTShareManager *shareManager;
@property (nonatomic, strong) TTMomentDetailAction *deleteAction;
@property (nonatomic, strong) TTMomentDetailAction *shareAction;
@property (nonatomic, strong) TTCommentWriteView *replyView;

@end


@implementation TTMomentDetailMiddleware
@synthesize store;

- (void)handleAction:(Action *)action {
    TTMomentDetailAction *detailAction = (TTMomentDetailAction *)action;
    switch (detailAction.type) {
        case TTMomentDetailActionTypeInit:
            [self handleInitAction:detailAction];
            break;
        case TTMomentDetailActionTypeLoadComment:
            [self handleLoadCommentAction:detailAction];
            break;
        case TTMomentDetailActionTypeLoadDig:
            [self handleLoadDigAction:detailAction];
            break;
        case TTMomentDetailActionTypeFollow:
            [self handleFollowAction:detailAction];
            break;
        case TTMomentDetailActionTypeUnfollow:
            [self handleUnfollowAction:detailAction];
            break;
        case TTMomentDetailActionTypePublishComment:
            [self handlePublishCommentAction:detailAction];
            break;
        case TTMomentDetailActionTypeReplyCommentDig:
            [self handleReplyCommentDigAction:detailAction];
            break;
        case TTMomentDetailActionTypeCommentDig:
            [self handleCommentDigAction:detailAction];
            break;
        case TTMomentDetailActionTypeDeleteComment:
            [self handleDeleteCommentAction:detailAction];
            break;
        case TTMomentDetailActionTypeUnblock:
            [self handleUnBlockAction:detailAction];
            break;
        case TTMomentDetailActionTypeShare:
            [self handleShareAction:detailAction];
            break;
        case TTMomentDetailActionTypeBanEmojiInput:
            [self handleBanEmojiInputAction:detailAction];
            break;
        default:
            break;
    }
}

- (void)handleInitAction:(TTMomentDetailAction *)action {
    TTMomentDetailAction *detailAction = [TTMomentDetailAction actionWithType:TTMomentDetailActionTypeInit comment:action.commentModel];
    [self.store dispatch:detailAction];

    if (!TTNetworkConnected()) {
        [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:@"网络不给力，请稍后重试" indicatorImage:[UIImage themedImageNamed:@"close_popup_textpage"] autoDismiss:YES dismissHandler:nil];
        return;
    }

    WeakSelf;
    [[TTCommentDataManager sharedManager] fetchCommentDetailWithCommentID:((TTMomentDetailIndependenceState *) self.store.state).commentID
                                                              finishBlock:^(TTCommentDetailModel *model, NSError *error) {
        StrongSelf;
        if (error || !model) {
            TTMomentDetailAction *initAction = [TTMomentDetailAction actionWithType:TTMomentDetailActionTypeInit comment:action.commentModel];
            initAction.payload = @{@"commentDetailError": @(YES)};
            [self.store dispatch:initAction];
            return;
        }
        model.groupModel = action.payload[@"groupModel"]? :model.groupModel;
        model.diggCount = MAX([action.commentModel.digCount integerValue], model.diggCount);
        model.userDigg = model.userDigg || action.commentModel.userDigged;

        TTMomentDetailAction *initAction = [TTMomentDetailAction actionWithType:TTMomentDetailActionTypeInit comment:action.commentModel];
        initAction.payload = @{@"commentDetail": model};
        [self.store dispatch:initAction];
    }];

    TTMomentDetailAction *loadCommentAction = [TTMomentDetailAction actionWithType:TTMomentDetailActionTypeLoadComment comment:action.commentModel];
    loadCommentAction.shouldMiddlewareHandle = YES;
    [self.store dispatch:loadCommentAction];

    TTMomentDetailAction *loadDiggAction = [TTMomentDetailAction actionWithType:TTMomentDetailActionTypeLoadDig comment:action.commentModel];
    loadDiggAction.shouldMiddlewareHandle = YES;
    [self.store dispatch:loadDiggAction];
}

- (void)handleLoadCommentAction:(TTMomentDetailAction *)action {
    ((TTMomentDetailIndependenceState *)self.store.state).isLoadingComment = YES;

    BOOL isStickAction = !isEmptyString([self pageState].stickID) && [self pageState].hasMoreStickComment;
    NSString *msgId = isStickAction ? [self pageState].stickID : nil;

    [[TTCommentDataManager sharedManager] fetchCommentReplyListWithCommentID:((TTMomentDetailIndependenceState *)self.store.state).commentID
                                                              loadMoreOffset:((TTMomentDetailIndependenceState *)self.store.state).offset
                                                               loadMoreCount:20
                                                                       msgID:msgId
                                                                    isRepost:NO
                                                                 finishBlock:^(id jsonObj, NSError *error) {
        NSDictionary *dataDict = [jsonObj isKindOfClass:[NSDictionary class]] ? [(NSDictionary *)jsonObj tt_dictionaryValueForKey:@"data"] : nil;

        NSArray *hotComments = [dataDict arrayValueForKey:@"hot_comments" defaultValue:nil];
        NSArray *allComments = [dataDict arrayValueForKey:@"data" defaultValue:nil];
        NSArray *stickComments = [dataDict arrayValueForKey:@"stick_comments" defaultValue:nil];

        NSArray<TTCommentDetailReplyCommentModel *> *stickCommentModels = [TTCommentDetailReplyCommentModel arrayOfModelsFromDictionaries:stickComments];

        NSArray<TTCommentDetailReplyCommentModel *> *hotCommentModels = [TTCommentDetailReplyCommentModel arrayOfModelsFromDictionaries:hotComments];

        NSArray<TTCommentDetailReplyCommentModel *> *allCommentModels = [TTCommentDetailReplyCommentModel arrayOfModelsFromDictionaries:allComments];

        NSMutableDictionary *payload = [[NSMutableDictionary alloc] initWithCapacity:7];
        [payload setValue:stickCommentModels forKey:@"stickCommentModels"];
        [payload setValue:hotCommentModels forKey:@"hotCommentModels"];
        [payload setValue:allCommentModels forKey:@"allCommentModels"];

        [payload setValue:@([dataDict tt_boolValueForKey:@"stick_has_more"]) forKey:@"stickHasMore"];
        [payload setValue:dataDict[@"has_more"] forKey:@"hasMore"];
        [payload setValue:@(!!error) forKey:@"isFailedLoadComment"];
        [payload setValue:@(isStickAction) forKey:@"isStickAction"];
        [payload setValue:[dataDict tt_stringValueForKey:@"total_count"] forKey:@"totalCount"];
        [payload setValue:[dataDict tt_stringValueForKey:@"placeholder"] forKey:@"commentPlaceholder"];

        TTMomentDetailAction *newAction = [TTMomentDetailAction actionWithType:TTMomentDetailActionTypeLoadComment payload:[payload mutableCopy]];
        newAction.shouldMiddlewareHandle = NO;
        newAction.from = action.from;
        [self.store dispatch:newAction];

    }];
}

- (void)handleLoadDigAction:(TTMomentDetailAction *)action {
    [[TTCommentDataManager sharedManager] fetchCommentDiggListWithCommentID:((TTMomentDetailIndependenceState *) self.store.state).commentID
                                                                finishBlock:^(NSMutableOrderedSet<SSUserModel *> *diggUsers, NSInteger diggCount, NSError *error) {
        NSMutableDictionary *payload = [[NSMutableDictionary alloc] init];
        [payload addEntriesFromDictionary:action.payload];
        [payload setValue:diggUsers forKey:@"diggUsers"];
        [payload setValue:@(diggCount) forKey:@"diggCount"];
        action.payload = payload;
        [self.store dispatch:action];
    }];
}

- (void)handleFollowAction:(TTMomentDetailAction *)action {
    if (isEmptyString(action.commentDetailModel.user.ID)) {
        return;
    }
    
    NSMutableDictionary * extraDic = @{}.mutableCopy;
    [extraDic setValue:action.commentDetailModel.user.ID
                forKey:@"to_user_id"];
    [extraDic setValue:@"from_group"
                forKey:@"follow_type"];
    [extraDic setValue:action.commentDetailModel.groupModel.groupID
                forKey:@"group_id"];
    [extraDic setValue:action.commentDetailModel.groupModel.itemID
                forKey:@"item_id"];
    [extraDic setValue:action.commentDetailModel.commentID
                forKey:@"comment_id"];
    
    NSString * enterFrom = nil;
    switch (action.from) {
        case TTCommentDetailSourceTypeDetail:
            enterFrom = @"article";
            break;
        case TTCommentDetailSourceTypeThread:
            enterFrom = @"weitoutiao";
            break;
        case TTCommentDetailSourceTypeMessage:
            enterFrom = @"message";
            break;
        default:
            enterFrom = @"unknown";
            break;
    }
    [extraDic setValue:enterFrom
                forKey:@"enter_from"];
    [extraDic setValue:@"comment_detail"
                forKey:@"source"];
    [extraDic setValue:@(TTFollowNewSourceMomentDetail)
                forKey:@"server_source"];
    [extraDic setValue:@"avatar_right"
                forKey:@"position"];
    [extraDic setValue:[action.payload tt_stringValueForKey:@"category_name"]
                forKey:@"category_name"];
    [TTTrackerWrapper eventV3:@"rt_follow"
                       params:extraDic];
    
    if (!TTNetworkConnected()) {
        [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:@"网络不给力，请稍后重试" indicatorImage:[UIImage themedImageNamed:@"close_popup_textpage"] autoDismiss:YES dismissHandler:nil];
        return;
    }
    
    NSMutableDictionary *followDic = [NSMutableDictionary dictionary];
    [followDic setValue:action.commentDetailModel.user.ID forKey:@"id"];
    [followDic setValue:@(32) forKey:@"new_reason"]; // FriendFollowNewReasonUnknown
    [followDic setValue:@(TTFollowNewSourceMomentDetail) forKey:@"new_source"];
    [[TTFollowManager sharedManager] follow:followDic completion:^(NSError * _Nullable error, NSDictionary * _Nullable result) {
        if (error) {
            [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:@"关注失败" indicatorImage:[UIImage themedImageNamed:@"close_popup_textpage"] autoDismiss:YES dismissHandler:nil];
            return;
        }
        [self.store dispatch:action];
    }];
}

- (void)handleUnfollowAction:(TTMomentDetailAction *)action {
    
    if (isEmptyString(action.commentDetailModel.user.ID)) {
        return;
    }
    
    NSMutableDictionary * extraDic = @{}.mutableCopy;
    [extraDic setValue:action.commentDetailModel.user.ID
                forKey:@"to_user_id"];
    [extraDic setValue:@"from_group"
                forKey:@"follow_type"];
    [extraDic setValue:action.commentDetailModel.groupModel.groupID
                forKey:@"group_id"];
    [extraDic setValue:action.commentDetailModel.groupModel.itemID
                forKey:@"item_id"];
    [extraDic setValue:action.commentDetailModel.commentID
                forKey:@"comment_id"];
    
    NSString * enterFrom = nil;
    switch (action.from) {
        case TTCommentDetailSourceTypeDetail:
            enterFrom = @"article";
            break;
        case TTCommentDetailSourceTypeThread:
            enterFrom = @"weitoutiao";
            break;
        case TTCommentDetailSourceTypeMessage:
            enterFrom = @"message";
            break;
        default:
            enterFrom = @"unknown";
            break;
    }
    [extraDic setValue:enterFrom
                forKey:@"enter_from"];
    [extraDic setValue:@"comment_detail"
                forKey:@"source"];
    [extraDic setValue:@(TTFollowNewSourceMomentDetail)
                forKey:@"server_source"];
    [extraDic setValue:@"avatar_right"
                forKey:@"position"];
    [extraDic setValue:[action.payload tt_stringValueForKey:@"category_name"]
                forKey:@"category_name"];
    [TTTrackerWrapper eventV3:@"rt_unfollow"
                       params:extraDic];
    
    if (!TTNetworkConnected()) {
        [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:@"网络不给力，请稍后重试" indicatorImage:[UIImage themedImageNamed:@"close_popup_textpage"] autoDismiss:YES dismissHandler:nil];
        return;
    }
    NSMutableDictionary *followDic = [NSMutableDictionary dictionary];
    [followDic setValue:action.commentDetailModel.user.ID forKey:@"id"];
    [followDic setValue:@(32) forKey:@"new_reason"]; // FriendFollowNewReasonUnknown
    [followDic setValue:@(TTFollowNewSourceMomentDetail) forKey:@"new_source"];
    [[TTFollowManager sharedManager] unfollow:followDic completion:^(NSError * _Nullable error, NSDictionary * _Nullable result) {
        if (error) {
            [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:@"取消关注失败" indicatorImage:[UIImage themedImageNamed:@"close_popup_textpage"] autoDismiss:YES dismissHandler:nil];
            return;
        }
        [self.store dispatch:action];
    }];
    
}

- (void)handlePublishCommentAction:(TTMomentDetailAction *)action {
    NSAssert(action.commentDetailModel, @"commentDetailModel不能为空");
    BOOL (^handleBlock)(BOOL, BOOL) = ^(BOOL isBlocking, BOOL isBlocked){
        NSString * description = nil;
        if (isBlocked) {
            description = [[SSIndicatorTipsManager shareInstance] indicatorTipsForKey:kTipForActionToBlockedUser]? :@" 根据对方设置，您不能进行此操作";
        } else if (isBlocking) {
            description = [[SSIndicatorTipsManager shareInstance] indicatorTipsForKey:kTipForActionToBlockingUser]? :@"您已拉黑此用户，不能进行此操作";
        }
        if (!description) {
            return NO;
        }
        [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:NSLocalizedString(description, nil) indicatorImage:[UIImage themedImageNamed:@"close_popup_textpage.png"] autoDismiss:YES dismissHandler:nil];
        return YES;
    };
    if ((action.source == TTMomentDetailActionSourceTypeComment) && handleBlock(action.replyCommentModel.user.isBlocking, action.replyCommentModel.user.isBlocked)) {
        return;
    }
    if (action.source != TTMomentDetailActionSourceTypeComment && handleBlock(action.commentDetailModel.user.isBlocking, action.commentDetailModel.user.isBlocked)) {
        return;
    }

    WeakSelf;
    TTCommentDetailReplyWriteManager *replyManager = [[TTCommentDetailReplyWriteManager alloc] initWithCommentDetailModel:action.commentDetailModel replyCommentModel:action.replyCommentModel? :[self pageState].defaultRelyModel commentRepostBlock:^(NSString *__autoreleasing *willRepostFwID) {

        *willRepostFwID = [action.commentDetailModel.repost_params tt_stringValueForKey:@"fw_id"];

    } publishCallback:^(id<TTCommentDetailReplyCommentModelProtocol>replyModel, NSError *error) {
        StrongSelf;
        if (error) {
            return;
        }
        TTMomentDetailAction *publishAction = [TTMomentDetailAction actionWithType:TTMomentDetailActionTypePublishComment comment:nil];
        publishAction.replyCommentModel = replyModel;
        publishAction.shouldMiddlewareHandle = NO;
        [self.store dispatch:publishAction];

    } getReplyCommentModelClassBlock:nil commentRepostWithPreRichSpanText:nil commentSource:nil];

    replyManager.enterFrom = self.enterFrom;
    replyManager.categoryID = self.categoryID;
    replyManager.logPb = self.logPb;
    
    replyManager.serviceID = self.pageState.serviceID;
    TTCommentWriteView *replyView = [[TTCommentWriteView alloc] initWithCommentManager:replyManager];

    self.replyView = replyView;

    NSNumber *switchToEmojiInput = action.payload[@"switchToEmojiInput"];
    replyView.emojiInputViewVisible = [switchToEmojiInput boolValue];
    // writeCommentView 禁表情
    if (action.commentDetailModel) {
        replyView.banEmojiInput = action.commentDetailModel.banEmojiInput;
    }

    UIView *view = action.payload[@"view"];
    [replyView showInView:view animated:YES];

    action.replyCommentModel = nil;
    [self.store dispatch:action];
}

- (void)handleCommentDigAction:(TTMomentDetailAction *)action {
    TTCommentDetailModel *detailModel = action.payload[@"commentDetailModel"];
    
    DetailActionRequestManager *commentActionManager = ((TTMomentDetailIndependenceState *)self.store.state).commentActionManager;
    [commentActionManager startItemActionByType:detailModel.userDigg? DetailActionCommentUnDigg:DetailActionCommentDigg];
    
    action.shouldMiddlewareHandle = NO;
    [self.store dispatch:action];
}

- (void)handleReplyCommentDigAction:(TTMomentDetailAction *)action {
    TTCommentDetailReplyCommentModel *commentModel = action.replyCommentModel;

    [[TTCommentDataManager sharedManager] diggCommentReplyWithCommentReplyID:commentModel.commentID
                                                                   commentID:action.commentDetailModel.commentID
                                                                      isDigg:commentModel.userDigg];

    [self.store dispatch:action];
}

- (void)handleDeleteCommentAction:(TTMomentDetailAction *)action {
    self.deleteAction = action;
    UIActionSheet * sheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"确定删除此评论?", nil) delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"确认删除" otherButtonTitles:nil, nil];
    
    [sheet showInView:[TTUIResponderHelper topNavigationControllerFor:nil].view];
    
    if (self.deleteAction.source == TTMomentDetailActionSourceTypeComment
        && !isEmptyString(self.deleteAction.replyCommentModel.commentID)) { //评论区的删除
        BOOL deleteSelfComment = NO;
        NSString *selfUID = [TTAccountManager userID];
        if (!isEmptyString(selfUID)) {
            if ([self.deleteAction.replyCommentModel.user.ID isEqualToString:selfUID]) { //自己的评论
                deleteSelfComment = YES;
            }
        }
        NSMutableDictionary *trackDict = [NSMutableDictionary new];
        [trackDict setValue:self.deleteAction.replyCommentModel.groupID forKey:@"group_id"];
        [trackDict setValue:self.deleteAction.replyCommentModel.commentID forKey:@"comment_id"];
        [trackDict setValue:deleteSelfComment?@"own":@"others" forKey:@"comment_type"];
        [TTTrackerWrapper eventV3:@"comment_delete" params:trackDict];
    }
}

- (void)handleUnBlockAction:(TTMomentDetailAction *)action {
    NSString *userID = action.payload[@"userID"];
    TTBlockManager *manager = [[TTBlockManager alloc] init];
    [manager unblockUser:userID];
    
    TTMomentDetailAction *newAction = [TTMomentDetailAction actionWithType:TTMomentDetailActionTypeUnblock payload:action.payload];
    [self.store dispatch:newAction];
}

- (void)handleBanEmojiInputAction:(TTMomentDetailAction *)action {
    if (self.replyView) {
        self.replyView.banEmojiInput = action.commentDetailModel.banEmojiInput;
    }
}

- (void)handleShareAction:(TTMomentDetailAction *)action {
    [self.shareManager displayActivitySheetWithContent:[self shareContentItems:action.commentDetailModel]];
    self.shareAction = action;
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == actionSheet.cancelButtonIndex) {
        
        return;
    }
    if (!self.deleteAction) {
        return;
    }
    if (!TTNetworkConnected()) {
        [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:@"没有网络连接" indicatorImage:[UIImage themedImageNamed:@"close_popup_textpage.png"] autoDismiss:YES dismissHandler:nil];
        return;
    }
    
    if (self.deleteAction.source == TTMomentDetailActionSourceTypeComment) {
        BOOL deleteSelfComment = NO;
        NSString *selfUID = [TTAccountManager userID];
        if (!isEmptyString(selfUID)) {
            if ([self.deleteAction.replyCommentModel.user.ID isEqualToString:selfUID]) { //自己的评论
                deleteSelfComment = YES;
            }
        }
        
        NSMutableDictionary *trackDict = [NSMutableDictionary new];
        [trackDict setValue:self.deleteAction.replyCommentModel.groupID forKey:@"group_id"];
        [trackDict setValue:self.deleteAction.replyCommentModel.commentID forKey:@"comment_id"];
        [trackDict setValue:deleteSelfComment?@"own":@"others" forKey:@"comment_type"];
        [TTTrackerWrapper eventV3:@"comment_delete_confirm" params:trackDict];

        if (deleteSelfComment) {
            [[TTCommentDataManager sharedManager] deleteCommentReplyWithCommentReplyID:self.deleteAction.replyCommentModel.commentID
                                                                             commentID:self.deleteAction.commentDetailModel.commentID
                                                                           finishBlock:nil];
        } else { //别人的评论删除走另一个接口，自见逻辑。此处不需要做保护，会在“删除”按钮显示时做权限判断，后续只需要走后端的保护
            [[TTCommentDataManager sharedManager] deleteCommentReplyByAuthorWithCommentReplyID:self.deleteAction.replyCommentModel.commentID
                                                                                     commentID:self.deleteAction.commentDetailModel.commentID
                                                                                   finishBlock:nil];
        }
    } else {
        [[TTCommentDataManager sharedManager] deleteCommentWithCommentID:self.deleteAction.commentDetailModel.commentID finishBlock:nil];
    }
    
    self.deleteAction.shouldMiddlewareHandle = NO;
    [self.store dispatch:self.deleteAction];
    self.deleteAction = nil;
}

- (nullable NSArray<id<TTActivityContentItemProtocol>> *)shareContentItems:(TTCommentDetailModel *)commentDetailModel {
    NSMutableArray *shareActivityContentItemTypes = [NSMutableArray array];

    NSString *shareTitle = [TTKitchen getString:kTTKUGCFeedNamesShare];
    NSString *shareDescription = isEmptyString(commentDetailModel.content) ? NSLocalizedString(@"发现你感兴趣的新鲜事", nil) : [NSString stringWithFormat:@"%@: %@", commentDetailModel.user.name, commentDetailModel.content];
    UIImage *shareImage = [self wechatImageWithGroupThumbnailURLString:commentDetailModel.groupThumbURL avatarURLString:commentDetailModel.user.avatarURLString];
    NSString *shareImageUrl = commentDetailModel.groupThumbURL ?: commentDetailModel.user.avatarURLString;
    NSString *shareWebPageUrl = commentDetailModel.shareURL;

    TTForwardWeitoutiaoContentItem *forwardWeitoutiaoContentItem = [[TTForwardWeitoutiaoContentItem alloc] init];
    WeakSelf;
    forwardWeitoutiaoContentItem.customAction = ^{
        StrongSelf;
        [self forwardToWeitoutiao];
    };
    [shareActivityContentItemTypes addObject:forwardWeitoutiaoContentItem];

    //微信朋友圈分享
    TTWechatTimelineContentItem *wechatTimelineContentItem = [[TTWechatTimelineContentItem alloc] initWithTitle:shareTitle
                                                                                                           desc:shareDescription
                                                                                                     webPageUrl:shareWebPageUrl
                                                                                                     thumbImage:shareImage
                                                                                                      shareType:TTShareWebPage];
    [shareActivityContentItemTypes addObject:wechatTimelineContentItem];

    //微信好友分享
    TTWechatContentItem *wechatContentItem = [[TTWechatContentItem alloc] initWithTitle:shareTitle desc:shareDescription
                                                                             webPageUrl:shareWebPageUrl
                                                                             thumbImage:shareImage
                                                                              shareType:TTShareWebPage];
    [shareActivityContentItemTypes addObject:wechatContentItem];

    //QQ好友分享
    TTQQFriendContentItem *qqFriendContentItem = [[TTQQFriendContentItem alloc] initWithTitle:shareTitle
                                                                                         desc:shareDescription
                                                                                   webPageUrl:shareWebPageUrl
                                                                                   thumbImage:shareImage
                                                                                     imageUrl:shareImageUrl
                                                                                     shareTye:TTShareWebPage];
    [shareActivityContentItemTypes addObject:qqFriendContentItem];

    //QQ空间分享
    TTQQZoneContentItem *qqZoneContentItem = [[TTQQZoneContentItem alloc] initWithTitle:shareTitle desc:shareDescription
                                                                             webPageUrl:shareWebPageUrl
                                                                             thumbImage:shareImage
                                                                               imageUrl:shareImageUrl
                                                                               shareTye:TTShareWebPage];
    [shareActivityContentItemTypes addObject:qqZoneContentItem];

//    //钉钉分享
//    TTDingTalkContentItem *dingTalkContentItem = [[TTDingTalkContentItem alloc] initWithTitle:shareTitle
//                                                                                         desc:shareDescription
//                                                                                   webPageUrl:shareWebPageUrl
//                                                                                   thumbImage:shareImage
//                                                                                    shareType:TTShareWebPage];
//    [shareActivityContentItemTypes addObject:dingTalkContentItem];

    return [shareActivityContentItemTypes copy];
}

- (UIImage *)wechatImageWithGroupThumbnailURLString:(NSString *)groupThumbnailURLString avatarURLString:(NSString *)avatarURLString {
    UIImage *wechatImage = nil;

    //其次尝试显示上一级帖子(原文章或上一级动态)第一张缩略图
    if (groupThumbnailURLString) {
        wechatImage = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:groupThumbnailURLString];
    }

    //否则显示当前动态作者头像
    if (!wechatImage && avatarURLString) {
        wechatImage = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:avatarURLString];
    }

    //优先使用share_icon.png分享
    if (!wechatImage) {
        wechatImage = [UIImage imageNamed:@"share_icon.png"];
    }
    //否则使用icon
    if(!wechatImage) {
        wechatImage = [UIImage imageNamed:@"Icon.png"];
    }

    return wechatImage;
}

- (void)shareManager:(TTShareManager *)shareManager clickedWith:(id <TTActivityProtocol>)activity
          sharePanel:(id <TTActivityPanelControllerProtocol>)panelController {

    id<TTActivityContentItemProtocol> contentItem = activity.contentItem;
    if ([contentItem.contentItemType isEqualToString:TTActivityContentItemTypeForwardWeitoutiao]) {
        NSMutableDictionary *extraDic = [[NSMutableDictionary alloc] init];
        [extraDic setValue:[self.shareAction.payload tt_stringValueForKey:@"category_name"] forKey:@"category_name"];
        [extraDic setValue:self.shareAction.commentDetailModel.groupModel.groupID forKey:@"group_id"];
        [extraDic setValue:self.shareAction.commentDetailModel.groupModel.itemID forKey:@"item_id"];
        [extraDic setValue:self.shareAction.commentDetailModel.commentID forKey:@"comment_id"];
        [extraDic setValue:@"" forKey:@"log_pb"];
        [extraDic setValue:@"weitoutiao" forKey:@"share_platform"];
        extraDic[@"event_type"] = @"house_app2c_v2";

        [TTTrackerWrapper eventV3:@"rt_share_to_platform" params:extraDic];
    }
}

- (void)shareManager:(TTShareManager *)shareManager completedWith:(id <TTActivityProtocol>)activity
          sharePanel:(id <TTActivityPanelControllerProtocol>)panelController error:(NSError *)error
                desc:(NSString *)desc {
    self.shareAction = nil;
}

- (void)forwardToWeitoutiao {
    //文章新版评论的转发，实际转发对象为文章，操作对象为评论
    NSDictionary *repostParameters = [[self commonRepostParameters] copy];
    if (!SSIsEmptyDictionary(repostParameters)) {
        [[TTRoute sharedRoute] openURLByPresentViewController:[NSURL URLWithString:@"sslocal://repost_page"] userInfo:TTRouteUserInfoWithDict(repostParameters)];
    }
}

- (NSDictionary *)commonRepostParameters {
    TTCommentDetailModel *commentDetailModel = self.shareAction.commentDetailModel;

    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    if (!SSIsEmptyDictionary(commentDetailModel.repost_params)) {
        [parameters addEntriesFromDictionary:commentDetailModel.repost_params];
    }

    TTRichSpanText *repostRichSpanText = [[TTRichSpanText alloc] initWithText:@"" richSpans:nil];

    if (!isEmptyString(commentDetailModel.content)) {
        TTRichSpanText *commentRichSpanText = [[TTRichSpanText alloc] initWithText:commentDetailModel.content
                                                               richSpansJSONString:commentDetailModel.contentRichSpanJSONString];
        [repostRichSpanText appendCommentQuotedUserName:commentDetailModel.user.name userId:commentDetailModel.user.ID];
        [repostRichSpanText appendRichSpanText:commentRichSpanText];
    }

    if (!isEmptyString(commentDetailModel.qutoedCommentModel.commentContent)) {
        TTRichSpanText *quotedRichSpanText = [[TTRichSpanText alloc] initWithText:commentDetailModel.qutoedCommentModel.commentContent
                                                              richSpansJSONString:commentDetailModel.qutoedCommentModel.commentContentRichSpanJSONString];
        [repostRichSpanText appendCommentQuotedUserName:commentDetailModel.qutoedCommentModel.userName userId:commentDetailModel.qutoedCommentModel.userID];
        [repostRichSpanText appendRichSpanText:quotedRichSpanText];
    }

    if (!isEmptyString(commentDetailModel.groupContent)) {
        TTRichSpanText *groupRichSpanText = [[TTRichSpanText alloc] initWithText:commentDetailModel.groupContent
                                                             richSpansJSONString:commentDetailModel.groupContentRichSpan];
        [repostRichSpanText appendCommentQuotedUserName:commentDetailModel.groupUserName userId:commentDetailModel.groupUserId];
        [repostRichSpanText appendRichSpanText:groupRichSpanText];
    }

    NSString *content = repostRichSpanText.text;
    NSString *contentRichSpans = [TTRichSpans JSONStringForRichSpans:repostRichSpanText.richSpans];

    [parameters setValue:@(commentDetailModel.groupMediaType == 2) forKey:@"is_video"];
    [parameters setValue:content forKey:@"content"];
    [parameters setValue:contentRichSpans forKey:@"content_rich_span"];

    return parameters;
}

#pragma mark - TTShareManager

- (TTShareManager *)shareManager {
    if (_shareManager == nil) {
        _shareManager = [[TTShareManager alloc] init];
    }
    _shareManager.delegate = self;

    return _shareManager;
}

#pragma mark - Utils

- (TTMomentDetailIndependenceState *)pageState {
    return (TTMomentDetailIndependenceState *)self.store.state;
}

@end
