//
//  TSVVideoOverlayViewModel.m
//  AFgzipRequestSerializer
//
//  Created by Zuyang Kou on 10/12/2017.
//

#import "TSVControlOverlayViewModel.h"
#import <ReactiveObjC/ReactiveObjC.h>
#import "TTSettingsManager.h"
#import "AWEVideoShareModel.h"
#import "AWEVideoPlayShareBridge.h"
#import "TTShareManager.h"
#import "TTDeviceHelper.h"
#import "AWEVideoDetailTracker.h"
#import "TTShortVideoModel.h"
#import "TTBaseMacro.h"
#import "TSVVideoDetailPromptManager.h"
#import "TTServiceCenter.h"
#import "TTAdManagerProtocol.h"
#import "TSVLogoAction.h"
#import "AWEVideoPlayAccountBridge.h"
#import "TTRoute.h"
#import "TTBusinessManager+StringUtils.h"
#import "TSVVideoDetailShareHelper.h"
#import "AWEVideoUserInfoManager.h"
#import "HTSVideoPlayToast.h"
#import "AWEUserModel.h"
#import "TSVSlideUpPromptViewController.h"
#import "AWEVideoDetailScrollConfig.h"
#import "AWEVideoPlayTransitionBridge.h"
#import "TSVVideoShareManager.h"
#import "AWEVideoDetailManager.h"
#import "TTUGCAttributedLabel.h"
#import "TSVDetailRouteHelper.h"
#import "TTRichSpanText+Link.h"
#import "AWEVideoPlayTrackerBridge.h"
#import "TSVUIResponderHelper.h"
#import "SSWebViewController.h"
#import "TTNavigationController.h"
#import "TTCustomAnimationNavigationController.h"
#import "TSVRecommendCardViewModel.h"
#import "TTTracker.h"
#import <TTKitchenHeader.h>

NSString *const TSVLastShareActivityName = @"TSVLastShareActivityName";

@interface TSVControlOverlayViewModel () <TTShareManagerDelegate>

@property (nonatomic, assign) NSInteger playCount;
@property (nonatomic, assign) BOOL showShareIconOnBottomBar;
@property (nonatomic, assign) BOOL showOnlyOneShareIconOnBottomBar;
@property (nonatomic, strong) TTShareManager *shareManager;
@property (nonatomic, assign) TSVGroupSource groupSource;
@property (nonatomic, strong) TSVRecommendCardViewModel *recViewModel;
@property (nonatomic, copy) NSString *musicLabelString;
@property (nonatomic, copy) NSString *titleString;
@property (nonatomic, copy) NSString *titleRichTextStyleConfig;
@property (nonatomic, copy) NSURL *avatarImageURL;
@property (nonatomic, assign) BOOL followButtonHidden;
@property (nonatomic, copy) NSString *authorUserName;
@property (nonatomic, copy) NSArray<NSString *> *normalTagArray;
@property (nonatomic, copy) NSString *activityTagString;
@property (nonatomic, copy) NSString *likeCountString;
@property (nonatomic, copy) NSString *commentCountString;
@property (nonatomic, assign) BOOL isFollowing;
@property (nonatomic, assign) BOOL isLiked;
@property (nonatomic, assign) BOOL isStartFollowLoading;
@property (nonatomic, assign) BOOL isRecommendCardFinishFetching;
@property (nonatomic, assign) BOOL showRecommendCard;
@property (nonatomic, assign) BOOL isArrowRotationBackground;

@property (nonatomic, copy) NSString *sharePosition;
@property (nonatomic, copy) NSString *debugInfo;

@end

@implementation TSVControlOverlayViewModel

- (instancetype)init
{
    if (self = [super init]) {
        RAC(self, lastUsedShareActivityName) =
        [[[NSUserDefaults standardUserDefaults] rac_channelTerminalForKey:TSVLastShareActivityName]
         map:^NSString *(NSString *name) {
             if ([name isEqualToString:TTActivityContentItemTypeWechatTimeLine] ||
                 [name isEqualToString:TTActivityContentItemTypeWechat]) {
                 return name;
             } else {
                 return TTActivityContentItemTypeWechat;
             }
         }];
        RAC(self, isFollowing) = [RACObserve(self, model.author.isFollowing) filter:^BOOL(id  _Nullable value) {
            return [value isKindOfClass:[NSNumber class]];
        }];
        RAC(self, isLiked, @NO) = [RACObserve(self, model.userDigg)
                                   filter:^BOOL(NSNumber * _Nullable liked) {
                                       return [liked isKindOfClass:[NSNumber class]];
                                   }];
        RAC(self, likeCountString) = [RACObserve(self, model.diggCount)
                                      map:^id _Nullable(NSNumber *likeCount) {
                                          return [TTBusinessManager formatCommentCount:[likeCount integerValue]];
                                      }];
        RAC(self, commentCountString) = [RACObserve(self, model.commentCount)
                                         map:^id _Nullable(id  _Nullable value) {
                                             return [TTBusinessManager formatCommentCount:[value integerValue]];
                                         }];
        RAC(self, debugInfo) = RACObserve(self, model.debugInfo);
        RAC(self, showRecommendCard) = RACObserve(self, recViewModel.isRecommendCardFinishFetching);

        self.showOnlyOneShareIconOnBottomBar = ![TTDeviceHelper isScreenWidthLarge320];
    }

    return self;
}

- (void (^)(TTRichSpanText * _Nonnull, TTUGCAttributedLabelLink * _Nonnull))titleLinkClickBlock
{
    @weakify(self);
    return ^(TTRichSpanText *richSpanText, TTUGCAttributedLabelLink *curLink) {
        @strongify(self);
        // 如果是白名单外链，则需要加个埋点
        NSArray <TTRichSpanLink *> *links = richSpanText.richSpans.links;
        if (links.count > 0) {
            for (TTRichSpanLink *link in links) {
                if ([link.link isEqualToString:[curLink.linkURL absoluteString]] && link.type == TTRichSpanLinkTypeLink) {
                    NSMutableDictionary *extraDict = [NSMutableDictionary dictionary];
                    [extraDict setValue:self.model.categoryName forKey:@"category_name"];
                    [extraDict setValue:self.model.groupID forKey:@"group_id"];
                    [extraDict setValue:self.model.logPb forKey:@"log_pb"];
                    [AWEVideoPlayTrackerBridge trackEvent:@"external_link_click" params:extraDict];
                    break;
                }
            }
        }

        if ([[TTRoute sharedRoute] canOpenURL:curLink.linkURL]) {
            [TSVDetailRouteHelper openURLByPushViewController:curLink.linkURL userInfo:TTRouteUserInfoWithDict([[self enterConcernParamsWithURLStr:curLink.linkURL.absoluteString] copy])];
        } else {
            NSMutableDictionary *conditions = [NSMutableDictionary dictionary];
            [conditions setValue:@(NO) forKey:@"supportRotate"];
            SSWebViewController *controller = [[SSWebViewController alloc] initWithRouteParamObj:TTRouteParamObjWithDict(conditions)];
            [controller setTitleText:@" "];
            [controller requestWithURL:curLink.linkURL];
            UIViewController *topMostVC = [TSVUIResponderHelper topmostViewController];
            if ([topMostVC.navigationController isKindOfClass:[TTNavigationController class]]) {
                TTNavigationController *nav = (TTNavigationController *)topMostVC.navigationController;
                [nav pushViewControllerByTransitioningAnimation:controller animated:YES];
            }
        }
    };
}

- (TTShareManager *)shareManager {
    if (nil == _shareManager) {
        _shareManager = [[TTShareManager alloc] init];
        _shareManager.delegate = self;
    }
    return _shareManager;
}

- (void)showShareButtonIfNeeded
{
    if ([self showShareIconAfterDigg]) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.6 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            self.showShareIconOnBottomBar = YES;
        });
    }
}

- (void)videoDidPlayOneLoop
{
    self.playCount++;

    if ([self showShareIconAfterPlayCount:self.playCount]) {
        self.showShareIconOnBottomBar = NO;
    }
}

- (BOOL)showShareIconAfterDigg
{
    return NO;
}

- (BOOL)showShareIconAfterPlayCount:(NSInteger)playCount
{
    NSInteger showIconPlayCount = [[self shareIconAppearTimingConfig][@"after_play_times"] integerValue];
    if (!showIconPlayCount) {
        return NO;
    } else {
        return playCount == showIconPlayCount;
    }
}

- (NSDictionary *)shareIconAppearTimingConfig
{
    return [[TTSettingsManager sharedManager] settingForKey:@"tt_huoshan_detail_share_icon_appear_timing"
                                               defaultValue:@{
                                                              @"after_digg": @NO,
                                                              @"after_play_times": @2,
                                                              } freeze:YES];
}

- (void)didShareToActivityNamed:(NSString *)activityName
{
    [[NSUserDefaults standardUserDefaults] setObject:activityName forKey:TSVLastShareActivityName];
}

- (void)shareToActivityNamed:(NSString *)activityName
{
    [[NSUserDefaults standardUserDefaults] setObject:activityName forKey:TSVLastShareActivityName];

    TTShortVideoModel *model = self.model;
    NSString *imageURL = [model.video.originCover.urlList firstObject];
    [AWEVideoPlayShareBridge loadImageWithUrl:imageURL completion:^(UIImage * _Nonnull image) {
        AWEVideoShareModel *shareModel = [[AWEVideoShareModel alloc] initWithModel:model image:image shareType:AWEVideoShareTypeMore];

        id<TTActivityContentItemShareProtocol> activity;
        if ([activityName isEqualToString:TTActivityContentItemTypeWechatTimeLine]) {
            activity = [shareModel wechatMomentsContentItem];
        } else if ([activityName isEqualToString:TTActivityContentItemTypeWechat]) {
            activity = [shareModel wechatContentItem];
        }
        self.sharePosition = @"detail_bottom_bar_out";
        [self.shareManager shareToActivity:activity presentingViewController:nil];
    }];
}

- (void)cellWillDisplay
{
    self.showShareIconOnBottomBar = NO;
    self.playCount = 0;
}

- (void)clickCloseButton
{
    if (self.closeButtonDidClick) {
        self.closeButtonDidClick();
    }
}

#pragma mark - Logo

- (void)clickLogoButton
{
    [[TSVLogoAction sharedInstance] clickLogoWithModel:self.model
                               commonTrackingParameter:self.commonTrackingParameter
                                   detailPromptManager:self.detailPromptManager
                                              position:@"detail_top_bar"];
}

- (void)clickMoreButton
{
    if (self.moreButtonDidClick) {
        self.moreButtonDidClick();
    }
}

- (void)clickWriteCommentButton
{
    if (self.writeCommentButtonDidClick) {
        self.writeCommentButtonDidClick();
    }
}

- (void)clickActivityTag
{
    [TSVDetailRouteHelper openURLByPushViewController:[NSURL URLWithString:self.model.activity.openURL] userInfo:TTRouteUserInfoWithDict([[self enterConcernParamsWithURLStr:self.model.activity.openURL] copy])];
}

- (void)clickChallengeTag
{
    [AWEVideoDetailTracker trackEvent:@"shortvideo_pk_click"
                                model:self.model
                      commonParameter:self.commonTrackingParameter
                       extraParameter:nil];
    
    NSMutableDictionary *params = [@{
                                     @"style":@"shortvideo",
                                     @"shoot_entrance":@"shortvideo_detail", //入口
                                     } mutableCopy];
    [params setValue:self.model.activity.concernID forKey:@"cid"];
    NSString *hashTag = self.model.activity.name;
    if (hashTag.length > 0) {
        hashTag = [NSString stringWithFormat:@"#%@#",hashTag];
    }
    [params setValue:hashTag forKey:@"title"];
    [params setValue:self.model.activity.openURL forKey:@"schema"];
    [params setValue:self.model.groupID forKey:@"challenge_group_id"];
    [params setValue:self.model.challengeInfo.challengeRule forKey:@"challenge_rule"];
    [params setValue:self.model.challengeInfo.challengeSchemaUrl forKey:@"challenge_schema_url"];
    [params setValue:self.model.music.musicId forKey:@"music_id"];
    [params setValue:@(-1) forKey:@"request_red_packet_type"];
    UIViewController *topMostVC = [TSVUIResponderHelper topmostViewController];
    [params setValue:topMostVC.view forKey:@"presenting_vc_view"];
    NSURL *url = [NSURL URLWithString:@"sslocal://record_import_video"];
    if ([[TTRoute sharedRoute] canOpenURL:url]) {
        [[TTRoute sharedRoute] openURL:url userInfo:TTRouteUserInfoWithDict(params) objHandler:^(TTRouteObject *routeObj) {
            TTCustomAnimationNavigationController *nav = [[TTCustomAnimationNavigationController alloc] initWithRootViewController:(UIViewController *)routeObj.instance animationStyle:TTCustomAnimationStyleUGCPostEntrance];
            nav.ttDefaultNavBarStyle = @"White";
            if (topMostVC) {
                [topMostVC presentViewController:nav animated:YES completion:nil];
            }
        }];
    }
}

- (NSDictionary *)enterConcernParamsWithURLStr:(NSString *)urlStr
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    if ([urlStr containsString:@"sslocal://concern"]) {
        //进关心主页需要这些参数
        NSString *categoryName = self.commonTrackingParameter[@"category_name"];
        if (!isEmptyString(self.model.categoryName)) {
            categoryName = self.model.categoryName;
        }
        if (!isEmptyString(categoryName)) {
            [params setValue:categoryName forKey:@"category_name"];
        }

        NSString *enterFrom = self.commonTrackingParameter[@"category_name"];
        if (!isEmptyString(self.model.enterFrom)) {
            enterFrom = self.model.enterFrom;
        }
        if (!isEmptyString(enterFrom)) {
            [params setValue:enterFrom forKey:@"enter_from"];
        }
        [params setValue:self.model.listEntrance forKey:@"list_entrance"];
        [params setValue:self.model.activity.forumID forKey:@"forum_id"];
        [params setValue:@"shortvideo_detail_bottom_bar" forKey:@"from_page"];
    }
    return [params copy];
}

- (void)clickFollowButton
{
    NSString *userId = self.model.author.userID;

    NSString *position = @"detail";

    if ([AWEVideoPlayAccountBridge isCurrentLoginUser:self.model.author.userID]) {
        return;
    }
    
    self.isStartFollowLoading = YES;
    self.isArrowRotationBackground = YES;
    if (!self.model.author.isFollowing) {
        [self.recViewModel fetchRecommendArrayWithUserID:userId];
        @weakify(self);
        //关注
        [AWEVideoDetailTracker trackEvent:@"rt_follow"
                                    model:self.model
                          commonParameter:self.commonTrackingParameter
                           extraParameter:@{
                                            @"position": position,
                                            @"follow_type": @"from_group",
                                            @"to_user_id": self.model.author.userID ?: @"",
                                            }];

        [AWEVideoUserInfoManager followUser:self.model.author.userID completion:^(AWEUserModel *user, NSError *error) {
            @strongify(self);
            if (self && error) {
                NSString *prompts = error.userInfo[@"prompts"] ?: @"关注失败，请稍后重试";
                [HTSVideoPlayToast show:prompts];
            } else if (self) {
                self.model.author.isFollowing = user.isFollowing;
                [self.model save];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"RelationActionSuccessNotification" object:self
                                                                  userInfo:@{
                                                                             @"kRelationActionSuccessNotificationUserIDKey": userId ?: @"",
                                                                             @"kRelationActionSuccessNotificationActionTypeKey": @11
                                                                             }
                 ];
            }
            self.isStartFollowLoading = NO;
        }];
    } else { //取消关注
        self.showRecommendCard = NO;
        [self.recViewModel resetContentOffsetIfNeed];
        [AWEVideoDetailTracker trackEvent:@"rt_unfollow"
                                    model:self.model
                          commonParameter:self.commonTrackingParameter
                           extraParameter:@{
                                            @"position": position,
                                            @"follow_type": @"from_group",
                                            @"to_user_id": userId,
                                            }];

        @weakify(self);
        [AWEVideoUserInfoManager unfollowUser:userId completion:^(AWEUserModel *user, NSError *error) {
            @strongify(self);
            if (self && error) {
                NSString *prompts = error.userInfo[@"prompts"] ?: @"取消关注失败，请稍后重试";
                [HTSVideoPlayToast show:prompts];
            } else if (self) {
                self.model.author.isFollowing = user.isFollowing;
                [self.model save];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"RelationActionSuccessNotification" object:self
                                                                  userInfo:@{
                                                                             @"kRelationActionSuccessNotificationUserIDKey": userId ?: @"",
                                                                             @"kRelationActionSuccessNotificationActionTypeKey": @12 }
                 ];
            }
            self.isStartFollowLoading = NO;
        }];
    }
}
- (void)clickUserNameButton
{
    NSString *position = @"detail";

    [AWEVideoDetailTracker trackEvent:@"rt_click_nickname"
                                model:self.model
                      commonParameter:self.commonTrackingParameter
                       extraParameter:@{
                                        @"position": position,
                                        @"user_id": self.model.author.userID ?: @"",
                                        }];
    [self handleAvatarOrUserNameClick];
}

- (void)clickAvatarButton
{
    NSString *position = @"detail";

    [AWEVideoDetailTracker trackEvent:@"rt_click_avatar"
                                model:self.model
                      commonParameter:self.commonTrackingParameter
                       extraParameter:@{
                                        @"position": position,
                                        @"user_id": self.model.author.userID ?: @"",
                                        }];
    [self handleAvatarOrUserNameClick];
}

- (void)handleAvatarOrUserNameClick
{
    NSMutableDictionary *paramsDict = [NSMutableDictionary dictionary];
    [paramsDict setValue:self.model.categoryName forKey:@"category_name"];
    [paramsDict setValue:@"detail_short_video" forKey:@"from_page"];
    [paramsDict setValue:self.model.groupID forKey:@"group_id"];
    [AWEVideoPlayTransitionBridge openProfileViewWithUserId:self.model.author.userID params:paramsDict];
}

- (void)clickLikeButton
{
    NSString *eventName;
    if (!self.model.userDigg) {
        eventName = @"rt_like";
    } else {
        eventName = @"rt_unlike";
    }
    [AWEVideoDetailTracker trackEvent:eventName
                                model:self.model
                      commonParameter:self.commonTrackingParameter
                       extraParameter:@{
                                        @"user_id": self.model.author.userID ?: @"",
                                        @"position": @"detail",
                                        }];

    if (!self.model.userDigg) {
        self.model.diggCount++;
        self.model.userDigg = YES;
        [self.model save];
        [AWEVideoDetailManager diggVideoItemWithID:self.model.groupID
                                       groupSource:self.model.groupSource
                                        completion:nil];
    } else {
        self.model.diggCount--;
        self.model.userDigg = NO;
        [self.model save];
        [AWEVideoDetailManager cancelDiggVideoItemWithID:self.model.groupID
                                              completion:nil];
    }
}

- (void)doubleTapView
{
    if (!self.isLiked) {
        [AWEVideoDetailTracker trackEvent:@"rt_like"
                                    model:self.model
                          commonParameter:self.commonTrackingParameter
                           extraParameter:@{
                                            @"user_id": self.model.author.userID,
                                            @"position": @"double_like",
                                            }];

        [self markLikeDirectly];
    }
}

- (void)singleTapView
{
    if (self.showRecommendCard) {
        self.isArrowRotationBackground = NO;
        self.showRecommendCard = NO;
    }
}

- (void)markLikeDirectly
{
    // Legacy
    [self showShareButtonIfNeeded];

    self.model.diggCount++;
    self.model.userDigg = YES;
    [self.model save];

    [AWEVideoDetailManager diggVideoItemWithID:self.model.groupID
                                   groupSource:self.model.groupSource
                                    completion:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"TSVShortVideoDiggCountSyncNotification"
                                                        object:nil
                                                      userInfo:@{@"group_id" : self.model.groupID ?:@"",
                                                                 @"user_digg" : @(self.model.userDigg),}];


}

- (void)clickCommentButton
{
    [AWEVideoDetailTracker trackEvent:@"enter_comment"
                                model:self.model
                      commonParameter:self.commonTrackingParameter
                       extraParameter:@{
                                        @"user_id": self.model.author.userID ?: @"",
                                        @"position": @"detail",
                                        }];
    if (self.showCommentPopupBlock) {
        self.showCommentPopupBlock();
    }
}

- (void)clickShareButton
{
    [AWEVideoDetailTracker trackEvent:@"share_button"
                                model:self.model
                      commonParameter:self.commonTrackingParameter
                       extraParameter:@{@"position": @"detail"}];

    [self.detailPromptManager updateVisibleFloatingViewCountForVisibility:YES];
    //小视频暂时不出分享广告
    id<TTAdManagerProtocol> adManagerInstance = [[TTServiceCenter sharedInstance] getServiceByProtocol:@protocol(TTAdManagerProtocol)];
    [adManagerInstance share_showInAdPage:@"1" groupId:self.model.groupID];
    NSString *imageURL = [self.model.video.originCover.urlList firstObject];
    @weakify(self);
    [AWEVideoPlayShareBridge loadImageWithUrl:imageURL completion:^(UIImage * _Nonnull image) {
        @strongify(self);
        AWEVideoShareModel *shareModel = [[AWEVideoShareModel alloc] initWithModel:self.model image:image shareType:AWEVideoShareTypeDefault];

        self.sharePosition = @"detail";
//        if ([[TTKitchenMgr sharedInstance] getBOOL:kKCShareBoardDisplayRepost]) {
//            [self.shareManager displayForwardSharePanelWithContent:[shareModel forwardSharePanelContentItems]];
//        } else {
            [self.shareManager displayActivitySheetWithContent:[shareModel shareContentItems]];
//        }
        
    }];
}

- (void)clickCheckChallengeButton
{
    [AWEVideoDetailTracker trackEvent:@"shortvideo_pk_check"
                                model:self.model
                      commonParameter:self.commonTrackingParameter
                       extraParameter:nil];
    
    [TSVDetailRouteHelper openURLByPushViewController:[NSURL URLWithString:self.model.checkChallenge.challengeSchemaUrl]];
}

- (void)setModel:(TTShortVideoModel *)model
{
    _model = model;

    if ([self.model.groupSource isEqualToString:@"16"]) {
        self.groupSource = TSVGroupSourceHuoshan;
    } else if ([self.model.groupSource isEqualToString:@"19"]) {
        self.groupSource = TSVGroupSourceDouyin;
    } else if ([self.model.groupSource isEqualToString:@"21"]) {
        self.groupSource = TSVGroupSourceToutiao;
    } else if ([self.model.groupSource isEqualToString:@"3"]) {
        self.groupSource = TSVGroupSourceAd;
    } else {
//        NSAssert(NO, @"Unknown Group Source");
        self.groupSource = TSVGroupSourceUnknown;
    }

    self.titleString = self.model.title;
    if (self.groupSource == TSVGroupSourceDouyin) {
        self.musicLabelString = [NSString stringWithFormat:@"%@ - %@",
                                 isEmptyString(self.model.music.title) ? @"视频原声" : self.model.music.title ,
                                 isEmptyString(self.model.music.author) ? [NSString stringWithFormat:@"@%@", self.model.author.name]: self.model.music.author];
    } else if (!isEmptyString(self.model.music.title)){
        self.musicLabelString = [NSString stringWithFormat:@"%@ - %@",
                                 self.model.music.title ,
                                 isEmptyString(self.model.music.author) ? [NSString stringWithFormat:@"@%@", self.model.author.name]: self.model.music.author];
    } else {
        self.musicLabelString = nil;
    }

    self.avatarImageURL = [NSURL URLWithString:self.model.author.avatarURL];
    self.followButtonHidden = [self.model isAuthorMyself];
    self.authorUserName = self.model.author.name;

    NSMutableArray *tagArray = [NSMutableArray array];
    if ([self.model.labelForDetail length]) {
        [tagArray addObject:self.model.labelForDetail];
    }
    if ([self.model.labelForInteract length]) {
        [tagArray addObject:self.model.labelForInteract];
    }
    self.normalTagArray = [tagArray copy];

    self.activityTagString = self.model.activity.name;
    self.titleRichTextStyleConfig = self.model.titleRichSpanJSONString;
}

#pragma TTShareManagerDelegate

/* 目前详情页有三个地方可以出分享，顶部的更多按钮、底部的分享按钮和自动弹出的微信/朋友圈按钮。目前，分享按钮的全部逻辑和自动弹出按钮的部分逻辑在 VM 里面，更多按钮的目前还在 AWEVideoDetailViewController 中，应当都统一到 VM 里面。 */

- (void)shareManager:(TTShareManager *)shareManager
         clickedWith:(id<TTActivityProtocol>)activity
          sharePanel:(id<TTActivityPanelControllerProtocol>)panelController
{
    [self.detailPromptManager updateVisibleFloatingViewCountForVisibility:NO];
    [self didShareToActivityNamed:activity.contentItemType];

    id<TTActivityContentItemProtocol> contentItem = activity.contentItem;
//    if ([contentItem.contentItemType isEqualToString:TTActivityContentItemTypeSaveVideo]) {
//        [AWEVideoDetailTracker trackEvent:@"video_cache"
//                                    model:self.model
//                          commonParameter:self.commonTrackingParameter
//                           extraParameter:nil];
//        [TSVVideoDetailShareHelper handleSaveVideoWithModel:self.model];
//    }
    if ([contentItem.contentItemType isEqualToString:TTActivityContentItemTypeForwardWeitoutiao]) {

        NSMutableDictionary *params = @{}.mutableCopy;
        params[@"enter_from"] = self.commonTrackingParameter[@"enter_from"];
        params[@"category_name"] = self.commonTrackingParameter[@"category_name"];
        params[@"group_id"] = self.model.groupID;
        params[@"item_id"] = self.model.itemID;
        params[@"log_pb"] = self.model.logPb ?: @{};
        params[@"share_platform"] = @"weitoutiao";
        params[@"event_type"] = @"house_app2c_v2";

        [AWEVideoPlayTrackerBridge trackEvent:@"rt_share_to_platform"
                                       params:params];
        [TSVVideoDetailShareHelper handleForwardUGCVideoWithModel:self.model];
    } else if (!isEmptyString(contentItem.contentItemType)){
        NSString *type = [AWEVideoShareModel labelForContentItemType:contentItem.contentItemType];
        if (!isEmptyString(type)) {
            [AWEVideoDetailTracker trackEvent:@"rt_share_to_platform"
                                        model:self.model
                              commonParameter:self.commonTrackingParameter
                               extraParameter:@{
                                                @"position": @"detail",
                                                @"share_platform": type ?: @"",
                                                @"event_type": @"house_app2c_v2"
                                                }];
        }
        
    } else {
        [AWEVideoDetailTracker trackEvent:@"share_button_cancel"
                                    model:self.model
                          commonParameter:self.commonTrackingParameter
                           extraParameter:nil];
    }
}

- (void)shareManager:(TTShareManager *)shareManager
       completedWith:(id<TTActivityProtocol>)activity
          sharePanel:(id<TTActivityPanelControllerProtocol>)panelController
               error:(NSError *)error
                desc:(NSString *)desc
{
    NSString *eventName = error ? @"share_fail" : @"share_done";
    NSString *sharePlatform = [AWEVideoShareModel labelForContentItemType:activity.contentItemType] ?: @"";
    id<TTActivityContentItemProtocol> contentItem = activity.contentItem;
    NSArray *shareContentItemTypes = @[
                                       TTActivityContentItemTypeWechat,
                                       TTActivityContentItemTypeWechatTimeLine,
                                       TTActivityContentItemTypeForwardWeitoutiao,
                                       TTActivityContentItemTypeQQFriend,
                                       TTActivityContentItemTypeQQZone
//                                       TTActivityContentItemTypeSystem,
                                       ];
    if ([shareContentItemTypes containsObject:contentItem.contentItemType]) {
        [AWEVideoDetailTracker trackEvent:eventName
                                    model:self.model
                          commonParameter:self.commonTrackingParameter
                           extraParameter:@{
                                            @"share_platform": sharePlatform,
                                            @"position": self.sharePosition,
                                            @"event_type": @"house_app2c_v2"
                                            }];
    }
    [TSVVideoShareManager synchronizeUserDefaultsWithAvtivityType:activity.contentItemType];
}

#pragma mark - recommend card

- (void)clickRecommendArrow
{
    self.isArrowRotationBackground = NO;
    self.showRecommendCard = !self.showRecommendCard;
}

- (TSVRecommendCardViewModel *)recViewModel
{
    if (!_recViewModel) {
        _recViewModel = [[TSVRecommendCardViewModel alloc] init];
        RAC(_recViewModel, detailPageUserID) = RACObserve(self, model.author.userID);
        RAC(_recViewModel, listEntrance) = RACObserve(self, model.listEntrance);
        RAC(_recViewModel, logPb) = RACObserve(self, model.logPb);
        RAC(_recViewModel, commonParameter) = RACObserve(self, commonTrackingParameter);
    }
    return _recViewModel;
}

- (void)trackFollowCardEvent
{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithDictionary:self.commonTrackingParameter];
    [params setValue:self.model.listEntrance forKey:@"list_entrance"];
    [params setValue:@"show" forKey:@"action_type"];
    [params setValue:@0 forKey:@"is_direct"];
    [params setValue:self.model.author.userID forKey:@"profile_user_id"];
    [params setValue:[NSNumber numberWithInteger:self.recViewModel.userCards.count] forKey:@"show_num"];
    [params setValue:@"shortvideo_detail_follow_card" forKey:@"source"];
    [TTTracker eventV3:@"follow_card" params:[params copy]];
}
@end
