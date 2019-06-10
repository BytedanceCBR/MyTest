//
//  TTVideoFloatViewController+Action.m
//  Article
//
//  Created by panxiang on 16/7/14.
//
//

#import "TTVideoFloatViewController+Action.h"
#import "TTVideoFloatCellEntity.h"
#import "TTIndicatorView.h"
#import "NewsDetailConstant.h"
#import "TTVideoFloatProtocol.h"
#import "TTVideoFloatViewController+Share.h"
#import "TTVideoCommon.h"
#import "Article+TTADComputedProperties.h"
#import "TTVideoFloatViewController+Impression.h"
#import "NSDictionary+TTGeneratedContent.h"
#import "ArticleMomentProfileViewController.h"
#import "ExploreEntryManager.h"
#import "TTNetworkManager.h"
#import "FriendDataManager.h"
#import "TTRoute.h"

#import <objc/runtime.h>

@implementation TTVideoFloatViewController (Action)
#pragma mark cell action

- (void)actionInit
{
    self.itemActionManager = [[ExploreItemActionManager alloc] init];
}

- (void)userInfoActionWithCellEntity:(TTVideoFloatCellEntity *)cellEntity
{
    self.movieView.isPlayingWhenBackToFloat = [self.movieView isPlaying];
//    [self logClickPGCWithCellEntity:cellEntity];
    NSString *openPGCURL = [TTVideoCommon PGCOpenURLWithMediaID:[cellEntity.article.mediaInfo[@"media_id"] stringValue]
                                                      enterType:kPGCProfileEnterSourceFacebookFloat];
    NSMutableString *string = [NSMutableString stringWithString:openPGCURL];
    [string appendFormat:@"&item_id=%@",cellEntity.article.itemID];
    [string appendFormat:@"&group_id=%@",cellEntity.article.groupModel.groupID];
    [[TTRoute sharedRoute] openURLByPushViewController:[TTStringHelper URLWithURLString:string]];
    Article *article = cellEntity.article;
    wrapperTrackEventWithCustomKeys(@"pgc_profile", @"float_enter", [article.mediaInfo[@"media_id"] stringValue], cellEntity.article.groupModel.itemID, [[self class] baseExtraWithArticle:article]);
    [self leaverPageStay];
}

- (void)subscribeActionWithCellEntity:(TTVideoFloatCellEntity *)cellEntity callbackBlock:(TTCellActionCallback)callbackBlock
{
    Article *article = cellEntity.article;
    NSString *contentID = [self.contentInfo ttgc_contentID];
    BOOL hasSubscribed = [self.contentInfo ttgc_isSubCribed];

    if (hasSubscribed) {
        wrapperTrackEventWithCustomKeys(@"video", @"float_unsubscribe_pgc", contentID, cellEntity.article.groupModel.itemID, [[self class] baseExtraWithArticle:article]);
    }
    else {
//        if ([TTFirstConcernManager firstTimeGuideEnabled]) {
//            TTFirstConcernManager *manager = [[TTFirstConcernManager alloc] init];
//            [manager showFirstConcernAlertViewWithDismissBlock:nil];
//        }
        wrapperTrackEventWithCustomKeys(@"video", @"float_subscribe_pgc", contentID, cellEntity.article.groupModel.itemID, [[self class] baseExtraWithArticle:article]);
    }
    
    cellEntity.startActivity = YES;
    self.canImmerse = NO;
    [self.immerseTimer invalidate];
    FriendActionType actionType;
    if (hasSubscribed) {
        actionType = FriendActionTypeUnfollow;
    }
    else {
        actionType = FriendActionTypeFollow;
    }
    __weak typeof(self) __weakSelf = self;
    [[TTFollowManager sharedManager] startFollowAction:actionType userID:contentID platform:nil name:nil from:nil reason:nil newReason:nil newSource:@(31) completion:^(FriendActionType type, NSError * _Nullable error, NSDictionary * _Nullable result) {
        [__weakSelf p_finishChangeSubscribeStatus:error hasSubscribed:hasSubscribed conentType:[self.contentInfo ttgc_contentType] result:result action:actionType cellEntity:cellEntity];
    }];
}

- (NSDictionary *)contentInfo
{
    Article *article = self.toPlayCell.cellEntity.article;
    if ([article hasVideoSubjectID]) {
        if (article.detailUserInfo) {
            return article.detailUserInfo;
        } else {
            return article.detailMediaInfo;
        }
    } else {
        if (article.userInfo) {
            return article.userInfo;
        } else {
            return article.mediaInfo;
        }
    }
}

- (void)setContentInfo:(NSDictionary *)contentInfo
{
    Article *article = self.toPlayCell.cellEntity.article;

    NSDictionary *_contentInfo = objc_getAssociatedObject(self, @selector(contentInfo));
    if (_contentInfo != contentInfo) {
        if ([article hasVideoSubjectID]) {
            if ([contentInfo ttgc_contentType] == TTGeneratedContentTypeUGC) {
                article.detailUserInfo = contentInfo;
            } else {
                article.detailMediaInfo = contentInfo;
            }
        } else {
            if ([contentInfo ttgc_contentType] == TTGeneratedContentTypeUGC) {
                article.userInfo = contentInfo;
            } else {
                article.mediaInfo = contentInfo;
            }
        }
        [article save];
        objc_setAssociatedObject(self, @selector(contentInfo), contentInfo, OBJC_ASSOCIATION_COPY_NONATOMIC);
    }
}

- (void)setItemActionManager:(ExploreItemActionManager *)itemActionManager
{
    objc_setAssociatedObject(self, @selector(itemActionManager), itemActionManager, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (ExploreItemActionManager *)itemActionManager
{
    return objc_getAssociatedObject(self, @selector(itemActionManager));
}

- (void)p_finishChangeSubscribeStatus:(NSError *)error hasSubscribed:(BOOL)hasSubscribed conentType:(TTGeneratedContentType)contentType result:(NSDictionary *)result action:(FriendActionType)actionType cellEntity:(TTVideoFloatCellEntity *)cellEntity
{
    if (!error) {
        NSMutableDictionary *saveDic = [NSMutableDictionary dictionaryWithDictionary:self.contentInfo];
        if ([saveDic ttgc_contentType] == TTGeneratedContentTypeUGC) {
            [saveDic setValue:@(!hasSubscribed) forKey:@"follow"];
        } else {
            [saveDic setValue:@(!hasSubscribed) forKey:@"subcribed"];
        }
        [saveDic setValue:cellEntity.article.videoID forKey:@"video_id"];
        self.contentInfo = [saveDic copy];
        if (contentType == TTGeneratedContentTypePGC) {
            [[NSNotificationCenter defaultCenter] postNotificationName:kVideoDetailPGCSubscribeStatusChangedNotification object:saveDic];
        }
    }
    else {
        NSString *hint = [[[result tt_dictionaryValueForKey:@"result"] tt_dictionaryValueForKey:@"data"] tt_stringValueForKey:@"description"];
        if (isEmptyString(hint)) {
            hint = NSLocalizedString(actionType == FriendActionTypeFollow ? @"关注失败" : @"取消关注失败", nil);
        }
        [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:hint indicatorImage:[UIImage themedImageNamed:@"close_popup_textpage"] autoDismiss:YES dismissHandler:nil];
    }

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        cellEntity.startActivity = NO;
        self.canImmerse = YES;
        self.immerseTimer = [NSTimer scheduledTimerWithTimeInterval:kImmerseTime target:self selector:@selector(immerseHalf) userInfo:nil repeats:NO];
    });
}

- (void)commentActionWithCellEntity:(TTVideoFloatCellEntity *)cellEntity
{
    self.movieView.isPlayingWhenBackToFloat = [self.movieView isPlaying];

    Article *article = cellEntity.article;
    NewsGoDetailFromSource fromSource = [article.videoID isEqualToString:[self.detailModel.article videoID]] ? NewsGoDetailFromSourceVideoFloat : NewsGoDetailFromSourceVideoFloatRelated;
    NSMutableDictionary *statParams = [NSMutableDictionary dictionary];
    [statParams setValue:self.detailModel.categoryID forKey:kNewsDetailViewConditionCategoryIDKey];
    [statParams setValue:@(fromSource) forKey:kNewsGoDetailFromSourceKey];
    [statParams setValue:[NSNumber numberWithLongLong:article.uniqueID] forKey:@"groupid"];
    [statParams setValue:article.itemID forKey:@"item_id"];
    [statParams setValue:article.aggrType forKey:@"aggr_type"];
    // TODO: 评论页面传入 ordered_data
//    [statParams setValue:orderedData forKey:@"ordered_data"];
    [statParams setValue:[NSNumber numberWithBool:YES] forKey:@"showcomment"];
    [statParams setValue:[NSNumber numberWithBool:YES] forKey:@"ttDragToRoot"];
    
    //打开详情页：优先判断openURL是否可以用外部schema打开，否则判断内部schema
    
    BOOL canOpenURL = NO;
    
    if (!isEmptyString(article.openURL)) {
        NSURL *url = [TTStringHelper URLWithURLString:article.openURL];
        if ([[UIApplication sharedApplication] canOpenURL:url]) {
            canOpenURL = YES;
            [[UIApplication sharedApplication] openURL:url];
        }
        else if ([[TTRoute sharedRoute] canOpenURL:url]) {
            canOpenURL = YES;
            [[TTRoute sharedRoute] openURLByPushViewController:url userInfo:TTRouteUserInfoWithDict(statParams)];
        }
    }
    if(!canOpenURL) {
        NSString *detailURL = [NSString stringWithFormat:@"sslocal://detail?groupid=%lld", article.uniqueID];
        if ([article.adIDStr longLongValue] > 0) {
            detailURL = [detailURL stringByAppendingFormat:@"&ad_id=%@", article.adIDStr];
        }
        
        NSNumber *videoType = 0;
        if ([[article.videoDetailInfo allKeys] containsObject:@"video_type"]) {
            videoType = (NSNumber *)[article.videoDetailInfo objectForKey:@"video_type"];
        }
        
        [statParams setValue:videoType forKey:@"video_type"];
        self.shareMovie.posterView = self.movieShotView;
        self.shareMovie.movieView = self.movieView;
        if ([self.movieView isStoped]) {
            self.shareMovie.movieView = nil;
        }

        [statParams setValue:self.shareMovie forKey:@"movie_shareMovie"];

        [self tt_enterCommentLog:cellEntity];
        
        [[TTRoute sharedRoute] openURLByPushViewController:[TTStringHelper URLWithURLString:detailURL] userInfo:TTRouteUserInfoWithDict(statParams)];
    }
}

- (void)tt_enterCommentLog:(TTVideoFloatCellEntity *)cellEntity
{
    Article *article = cellEntity.article;

    wrapperTrackEventWithCustomKeys(@"xiangping", @"video_float_enter_comment", article.groupModel.groupID, article.groupModel.itemID, [[self class] baseExtraWithArticle:article]);
    wrapperTrackEventWithCustomKeys(@"video", @"detail_play",article.groupModel.groupID, article.groupModel.itemID, [[self class] baseExtraWithArticle:article]);
    [self leaverPageStay];
    [self endCellStay:YES];
}

- (void)diggBuryAction:(TTVideoFloatCellAction)action withCellEntity:(TTVideoFloatCellEntity *)cellEntity callbackBlock:(TTCellActionCallback)callbackBlock
{
    
    Article *article = self.toPlayCell.cellEntity.article;
    if (article.managedObjectContext == nil) {
        if (!isNull(callbackBlock)) {
            callbackBlock(NO,nil);
        }
        return;
    }
    
    if (action == TTVideoFloatCellAction_Digg || action == TTVideoFloatCellAction_Bury) {
        if (article.userDigg) {
            [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:@"您已经赞过" indicatorImage:nil autoDismiss:YES dismissHandler:nil];
            if (!isNull(callbackBlock)) {
                callbackBlock(NO,nil);
            }
            return;
        }
        else if (article.userBury) {
            [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:@"您已经踩过" indicatorImage:nil autoDismiss:YES dismissHandler:nil];
            if (!isNull(callbackBlock)) {
                callbackBlock(NO,nil);
            }
            return;
        }
    }
    
    if (action == TTVideoFloatCellAction_Digg) {
        article.userDigg = YES;
        article.diggCount = article.diggCount + 1;
        [self.itemActionManager sendActionForOriginalData:article adID:nil actionType:DetailActionTypeDig finishBlock:^(id userInfo, NSError *error) {
            
        }];
        [article save];
        wrapperTrackEventWithCustomKeys(@"xiangping", @"video_float_digg",cellEntity.article.groupModel.groupID, cellEntity.article.groupModel.itemID, [[self class] baseExtraWithArticle:article]);
        if (!isNull(callbackBlock)) {
            callbackBlock(YES,nil);
        }

    }
    else if (action == TTVideoFloatCellAction_Bury) {
        article.userBury = YES;
        article.buryCount = article.buryCount + 1;
        [self.itemActionManager sendActionForOriginalData:article adID:nil actionType:DetailActionTypeBury finishBlock:^(id userInfo, NSError *error) {
        }];
        [article save];
        wrapperTrackEventWithCustomKeys(@"xiangping", @"video_float_bury",cellEntity.article.groupModel.groupID, cellEntity.article.groupModel.itemID, [[self class] baseExtraWithArticle:article]);
        if (!isNull(callbackBlock)) {
            callbackBlock(YES,nil);
        }
    }
    else
    {
        if (!isNull(callbackBlock)) {
            callbackBlock(NO,nil);
        }
    }
}

- (void)doAction:(TTVideoFloatCellAction)action withCellEntity:(TTVideoFloatCellEntity *)cellEntity callbackBlock:(TTCellActionCallback)callbackBlock
{
    self.action = action;
    if ([cellEntity isKindOfClass:[TTVideoFloatCellEntity class]])
    {
        switch (action) {
            case TTVideoFloatCellAction_Subscribe:
                [self subscribeActionWithCellEntity:cellEntity callbackBlock:callbackBlock];
                break;
            case TTVideoFloatCellAction_unSubscribe:
                [self subscribeActionWithCellEntity:cellEntity callbackBlock:callbackBlock];
                break;
            case TTVideoFloatCellAction_Digg:
            case TTVideoFloatCellAction_Bury:
                [self diggBuryAction:action withCellEntity:cellEntity callbackBlock:callbackBlock];
                break;
            case TTVideoFloatCellAction_Comment:
                self.playNextInterrupt = YES;
                [self commentActionWithCellEntity:cellEntity];
                break;
            case TTVideoFloatCellAction_Share:
                self.playNextInterrupt = YES;
                [self shareActionWithCellEntity:cellEntity];
                break;
            case TTVideoFloatCellAction_UserInfo:
                self.playNextInterrupt = YES;
                [self userInfoActionWithCellEntity:cellEntity];
                break;
            case TTVideoFloatCellAction_Play:
                self.playNextInterrupt = YES;
                [self tt_playButtonClicked];
                break;
            default:
                break;
        }
    }
}


@end
