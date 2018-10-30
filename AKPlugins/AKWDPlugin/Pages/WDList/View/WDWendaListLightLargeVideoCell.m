//
//  WDWendaListLightLargeVideoCell.m
//  TTWenda
//
//  Created by wangqi.kaisa on 2018/1/3.
//

#import "WDWendaListLightLargeVideoCell.h"
#import "WDWendaListCellUserHeaderView.h"
#import "WDWendaListCellActionFooterView.h"
#import "WDWendaListCellPureCharacterView.h"
#import "WDCommonLogic.h"
#import "NSObject+FBKVOController.h"
#import <TTFriendRelation/TTFollowThemeButton.h>
#import <TTFriendRelation/TTFollowManager.h>
#import <TTUIWidget/SSMotionRender.h>
#import <TTUIWidget/TTAlphaThemedButton.h>
#import <TTBaseLib/NetworkUtilities.h>
#import <TTRoute/TTRoute.h>
#import <TTImage/TTImageView.h>
#import <TTShare/TTShareManager.h>
#import "WDListCellLayoutModel.h"
#import "WDListCellViewModel.h"
#import "WDListCellDataModel.h"
#import "WDAnswerService.h"
#import "WDAnswerEntity.h"
#import "TTIndicatorView.h"
#import "WDListViewModel.h"
#import "WDTrackerHelper.h"
#import "WDFollowDefines.h"
#import "WDAdapterSetting.h"
#import "TTVideoDurationView.h"
#import "WDWendaListCell+Share.h"
#import "WDShareUtilsHelper.h"
#import "WDUIHelper.h"
#import <BDTBasePlayer/TTVFullscreenProtocol.h>

@interface WDWendaListLightLargeVideoCell ()<WDWendaListCellUserHeaderViewDelegate,WDWendaListCellActionFooterViewDelegate,WDVideoPlayerTransferReceiver,TTVFullscreenCellProtocol,TTShareManagerDelegate>

@property (nonatomic, strong) WDWendaListCellUserHeaderView *headerView;
@property (nonatomic, strong) WDWendaListCellActionFooterView *actionView;
@property (nonatomic, strong) WDWendaListCellPureCharacterView *characterView;

@property (nonatomic, strong) TTImageView *videoCoverPicView;
@property (nonatomic, strong) TTAlphaThemedButton *videoPlayButton;
@property (nonatomic, strong) TTVideoDurationView *videoDurationView;

@property (nonatomic, strong) UIView *videoPlayView;
@property (nonatomic, strong) TTShareManager *shareManager;

@property (nonatomic, strong) TTImageView *rewardIconImageView;
@property (nonatomic, strong) SSThemedLabel *rewardLabel;
@property (nonatomic, strong) SSThemedLabel *bottomLabel;
@property (nonatomic, strong) SSThemedView  *footerView;

@property (nonatomic, strong) WDListCellLayoutModel *cellLayoutModel;
@property (nonatomic, strong, readonly) WDListCellViewModel *cellViewModel;
@property (nonatomic, strong, readonly) WDAnswerEntity *ansEntity;
@property (nonatomic, copy) NSDictionary *gdExtJson;
@property (nonatomic, copy) NSDictionary *apiParams;

@property (nonatomic, assign) CGFloat cellWidth;
@property (nonatomic, assign) BOOL isViewHighlighted;
@property (nonatomic, assign) BOOL isSelfFollow;
@property (nonatomic, assign) BOOL needSendRedPackFlag;

@end

@implementation WDWendaListLightLargeVideoCell

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style
              reuseIdentifier:(NSString *)reuseIdentifier
                    gdExtJson:(NSDictionary *)gdExtJson
                    apiParams:(NSDictionary *)apiParams {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _gdExtJson = [gdExtJson copy];
        _apiParams = [apiParams copy];
        
        self.backgroundColorThemeKey = kColorBackground4;
        if (![WDCommonLogic transitionAnimationEnable]){
            self.backgroundSelectedColorThemeKey = kColorBackground4Highlighted;
        }
    }
    return self;
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    if (highlighted) {
        if (!self.isViewHighlighted) {
            self.contentView.backgroundColor = [UIColor tt_themedColorForKey:kColorBackground3];
            self.bottomLabel.backgroundColor = [UIColor tt_themedColorForKey:kColorBackground3];
            self.rewardLabel.backgroundColor = [UIColor tt_themedColorForKey:kColorBackground3];
            [self.headerView setHighlighted:highlighted];
            [self.characterView setHighlighted:highlighted];
            self.isViewHighlighted = YES;
        }
    } else {
        if (self.isViewHighlighted) {
            self.contentView.backgroundColor = [UIColor tt_themedColorForKey:kColorBackground4];
            self.bottomLabel.backgroundColor = [UIColor tt_themedColorForKey:kColorBackground4];
            self.rewardLabel.backgroundColor = [UIColor tt_themedColorForKey:kColorBackground4];
            [self.headerView setHighlighted:highlighted];
            [self.characterView setHighlighted:highlighted];
            self.isViewHighlighted = NO;
        }
    }
}

- (void)prepareForReuse {
    [super prepareForReuse];
    
    self.headerView.followButton.unfollowedType = TTUnfollowedType102;
    self.needSendRedPackFlag = NO;
}

- (void)cellDidSelected {
    [self.cellViewModel cellDidSelectedWithGdExtJson:self.gdExtJson];
} 

#pragma mark - Refresh & Layout

- (void)refreshWithCellLayoutModel:(WDListCellLayoutModel *)cellLayoutModel cellWidth:(CGFloat)cellWidth {
    self.cellWidth = cellWidth;
    self.cellLayoutModel = cellLayoutModel;
    if (self.cellViewModel.isInvalidData) {
        return;
    }
    [self createSubviewsIfNeeded];
    self.headerView.width = cellWidth;
    self.actionView.width = cellWidth;
    self.characterView.width = cellWidth;
    if (self.cellLayoutModel.cellCacheHeight == 0) {
        [cellLayoutModel calculateLayoutIfNeedWithCellWidth:cellWidth];
    }
    [self refreshSubviewsContentAndLayout];
}

- (void)refreshSubviewsContentAndLayout {
    CGFloat originY = [self refreshUserInfoViewContentAndLayout];
    originY = [self refreshAnswerTextContentAndLayout:originY];
    originY = [self refreshAnswerVideoContentAndLayout:originY + self.cellLayoutModel.videoCoverTopPadding];
    originY = [self refreshBottomViewContentAndLayout:originY];
//    originY = [self refreshActionViewContentAndLayout:originY];
    [self refreshFooterViewLayout:originY];
    
    [self addObserveKVO];
    [self addObserveNotification];
}

- (CGFloat)refreshUserInfoViewContentAndLayout {
    [self.headerView refreshUserInfoContent:self.ansEntity.user descInfo:self.cellViewModel.secondLineContent followButtonHidden:self.cellViewModel.isFollowButtonHidden];
    [self refreshFollowButtonState];
    //
    if (self.ansEntity.user.redPack) {
        NSMutableDictionary *showEventExtraDic = [NSMutableDictionary dictionaryWithDictionary:self.gdExtJson];
        [showEventExtraDic setValue:self.ansEntity.user.userID forKey:@"user_id"];
        [showEventExtraDic setValue:@"show" forKey:@"action_type"];
        [showEventExtraDic setValue:@"answer_list_answer_cell" forKey:@"source"];
        [showEventExtraDic setValue:@"answer_list" forKey:@"position"];
        [TTTrackerWrapper eventV3:@"red_button" params:showEventExtraDic];
        self.needSendRedPackFlag = YES;
    }
    return SSMaxY(self.headerView);
}

- (CGFloat)refreshAnswerTextContentAndLayout:(CGFloat)top {
    self.characterView.top = top;
    [self.characterView updateAbstContentLabelText:self.cellViewModel.answerContentAbstract numberOfLines:self.cellLayoutModel.answerLinesCount];
    [self.characterView refreshAbstContentLabelLayout:self.cellLayoutModel.contentLabelHeight];
    return (self.characterView.bottom);
}

- (CGFloat)refreshAnswerVideoContentAndLayout:(CGFloat)top {
    long long duration = [self.cellViewModel.videoModel.duration longLongValue];
    if (duration > 0) {
        int minute = (int)duration / 60;
        int second = (int)duration % 60;
        [self.videoDurationView setDurationText:[NSString stringWithFormat:@"%02i:%02i", minute, second]];
    } else {
        [self.videoDurationView setDurationText:@"00:00"];
    }
    [self.videoDurationView showLeftImage:NO];
    @try {
        TTImageInfosModel *model = [[TTImageInfosModel alloc] initWithDictionary:[self.cellViewModel.videoModel.cover_pic toDictionary]];
        [self.videoCoverPicView setImageWithModel:model];
    }
    @catch (NSException *exception) {
        // nothing to do...
    }
    
    self.videoCoverPicView.frame = self.cellLayoutModel.largeVideoFrame;
    self.videoCoverPicFrame = self.cellLayoutModel.largeVideoFrame;
    
    self.videoPlayButton.centerX = self.videoCoverPicView.width/2;
    self.videoPlayButton.centerY = self.videoCoverPicView.height/2;
    
    self.videoDurationView.right = self.videoCoverPicView.width - 4;
    self.videoDurationView.bottom = self.videoCoverPicView.height - 4;
    
    return self.videoCoverPicView.bottom;
}

- (CGFloat)refreshBottomViewContentAndLayout:(CGFloat)top {
    [self refreshBottomLabelContent];
    self.bottomLabel.top = top + self.cellLayoutModel.bottomLabelTopPadding;
    CGFloat bottomOriginX = kWDCellLeftPadding;
    self.rewardIconImageView.hidden = YES;
    self.rewardLabel.hidden = !self.cellViewModel.isAnswerGetReward;
    if (self.cellViewModel.isAnswerGetReward) {
        CGFloat rewardLabelLeft = bottomOriginX;
        NSString *urlString = (TTThemeModeDay == [[TTThemeManager sharedInstance_tt] currentThemeMode]) ? self.ansEntity.profitLabel.icon_day_url : self.ansEntity.profitLabel.icon_night_url;
        if (!isEmptyString(urlString)) {
            self.rewardIconImageView.hidden = NO;
            [self.rewardIconImageView setImageWithURLString:urlString];
            self.rewardIconImageView.left = bottomOriginX;
            self.rewardIconImageView.centerY = self.bottomLabel.centerY;
            rewardLabelLeft = self.rewardIconImageView.right + 4;
        }
        self.rewardLabel.text = self.ansEntity.profitLabel.text;
        [self.rewardLabel sizeToFit];
        self.rewardLabel.height = [WDListCellLayoutModel answerReadCountsLineHeight];
        self.rewardLabel.origin = CGPointMake(rewardLabelLeft, self.bottomLabel.top);
        bottomOriginX = self.rewardLabel.right + 12;
    }
    self.bottomLabel.left = bottomOriginX;
    return self.bottomLabel.bottom + self.cellLayoutModel.bottomLabelBottomPadding;
}

- (CGFloat)refreshActionViewContentAndLayout:(CGFloat)top {
    self.actionView.top = top;
    [self.actionView refreshForwardCount:self.cellViewModel.forwardCount commentCount:self.cellViewModel.commentCount diggCount:self.cellViewModel.diggCount isDigg:self.cellViewModel.ansEntity.isDigg];
    return self.actionView.bottom;
}

- (void)refreshFooterViewLayout:(CGFloat)top {
    self.footerView.frame = CGRectMake(0, top, self.cellWidth, [WDListCellLayoutModel heightForFooterView]);
}

#pragma mark - Refresh Content

- (void)updateFollowStateWithNewIsFollowing:(BOOL)isFollowing {
    if (self.ansEntity.user.isFollowing == isFollowing) {
        if (isFollowing) {
            self.cellViewModel.ansEntity.user.redPack = nil;
        }
        return;
    }
    self.ansEntity.user.isFollowing = isFollowing;
    [self.ansEntity save];
}

- (void)refreshIntroLabelContent {
    [self.headerView refreshDescInfoContent:self.cellViewModel.secondLineContent];
    self.isSelfFollow = NO;
}

- (void)refreshFollowButtonState {
    [self.headerView refreshFollowButtonState:self.ansEntity.user.isFollowing];
    self.isSelfFollow = NO;
    if (self.ansEntity.user.redPack) {
        self.headerView.followButton.unfollowedType = [TTFollowThemeButton redpacketButtonUnfollowTypeButtonStyle:self.ansEntity.user.redPack.button_style.integerValue defaultType:TTUnfollowedType202];
        [self.headerView.followButton refreshUI];
    } else {
        self.headerView.followButton.unfollowedType = TTUnfollowedType102;
    }
}

- (void)refreshBottomLabelContent {
    self.bottomLabel.text = self.cellViewModel.bottomLabelContent;
    [self.bottomLabel sizeToFit];
    self.bottomLabel.width = ceilf(self.bottomLabel.width);
    self.bottomLabel.height = [WDListCellLayoutModel answerReadCountsLineHeight];
}

- (void)refreshDiggCount {
    [self.actionView refreshDiggCount:self.cellViewModel.diggCount isDigg:self.cellViewModel.ansEntity.isDigg];
}

- (void)refreshCommentCount {
    [self.actionView refreshCommentCount:self.cellViewModel.commentCount];
}

- (void)refreshForwardCount {
    [self.actionView refreshForwardCount:self.cellViewModel.forwardCount];
}

#pragma mark - Create & Add Obbserve

- (void)createSubviewsIfNeeded {
    if (_headerView) return;
    [self.contentView addSubview:self.headerView];
    [self.contentView addSubview:self.characterView];
    [self.contentView addSubview:self.videoCoverPicView];
    [self.contentView addSubview:self.rewardIconImageView];
    [self.contentView addSubview:self.rewardLabel];
    [self.contentView addSubview:self.bottomLabel];
//    [self.contentView addSubview:self.actionView];
    [self.contentView addSubview:self.footerView];
}

- (void)addObserveKVO {
    WeakSelf;
    [self.KVOController unobserveAll];
    [self.KVOController observe:self.ansEntity.user keyPath:NSStringFromSelector(@selector(isFollowing)) options:NSKeyValueObservingOptionNew block:^(id  _Nullable observer, id  _Nonnull object, NSDictionary<NSString *,id> * _Nonnull change) {
        StrongSelf;
        if (!self.cellViewModel.isFollowButtonHidden) {
            if (!self.isSelfFollow) {
                [self refreshFollowButtonState];
            }
        } else {
            [self refreshIntroLabelContent];
        }
    }];
    [self.KVOController observe:self.ansEntity keyPath:NSStringFromSelector(@selector(readCount)) options:NSKeyValueObservingOptionNew block:^(id  _Nullable observer, id  _Nonnull object, NSDictionary<NSString *,id> * _Nonnull change) {
        StrongSelf;
        [self refreshBottomLabelContent];
    }];
//    [self.KVOController observe:self.ansEntity keyPath:NSStringFromSelector(@selector(isDigg)) options:NSKeyValueObservingOptionNew block:^(id  _Nullable observer, id  _Nonnull object, NSDictionary<NSString *,id> * _Nonnull change) {
//        StrongSelf;
//        [self refreshDiggCount];
//    }];
//    [self.KVOController observe:self.ansEntity keyPath:NSStringFromSelector(@selector(diggCount)) options:NSKeyValueObservingOptionNew block:^(id  _Nullable observer, id  _Nonnull object, NSDictionary<NSString *,id> * _Nonnull change) {
//        StrongSelf;
//        [self refreshDiggCount];
//    }];
//    [self.KVOController observe:self.ansEntity keyPath:NSStringFromSelector(@selector(commentCount)) options:NSKeyValueObservingOptionNew block:^(id  _Nullable observer, id  _Nonnull object, NSDictionary<NSString *,id> * _Nonnull change) {
//        StrongSelf;
//        [self refreshCommentCount];
//    }];
//    [self.KVOController observe:self.ansEntity keyPath:NSStringFromSelector(@selector(forwardCount)) options:NSKeyValueObservingOptionNew block:^(id  _Nullable observer, id  _Nonnull object, NSDictionary<NSString *,id> * _Nonnull change) {
//        StrongSelf;
//        [self refreshForwardCount];
//    }];
}

- (void)addObserveNotification {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:RelationActionSuccessNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(followNotification:) name:RelationActionSuccessNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"kTTForumRePostThreadSuccessNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(answerForwardToUGCSuccess:) name:@"kTTForumRePostThreadSuccessNotification" object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"kExploreNeedStopAllMovieViewPlaybackNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stopPlayingMovie) name:@"kExploreNeedStopAllMovieViewPlaybackNotification" object:nil];
}

#pragma mark - WDWendaListCellUserHeaderViewDelegate

- (void)listCellUserHeaderViewAvatarClick {
    NSString *label = @"name";
    NSInteger extValue = isEmptyString(self.ansEntity.user.userIntro) ? 0 : 1;
    
    NSMutableDictionary *dict = [self.gdExtJson mutableCopy];
    [dict setValue:self.ansEntity.user.userID forKey:@"value"];
    [dict setValue:@(extValue) forKey:@"ext_value"];
    [WDListViewModel trackEvent:kWDWendaListViewControllerUMEventName label:label gdExtJson:[dict copy]];
    
    NSString *categoryName = [self.gdExtJson objectForKey:@"category_name"];
    NSString *schema = [NSString stringWithFormat:@"sslocal://profile?uid=%@&refer=wenda", self.ansEntity.user.userID];
    NSString *result = [WDTrackerHelper schemaTrackForPersonalHomeSchema:schema categoryName:categoryName fromPage:@"list_answer_wenda" groupId:self.ansEntity.ansid profileUserId:self.ansEntity.user.userID];
    
    // add by zjing 去掉个人主页跳转
//    [[TTRoute sharedRoute] openURLByViewController:[NSURL URLWithString:result] userInfo:nil];
}

- (void)listCellUserHeaderViewFollowButtonClick:(TTFollowThemeButton *)followBtn {
    if (followBtn.isLoading) {
        return;
    }
    BOOL isFollowing = self.ansEntity.user.isFollowing;
    NSString *event = isFollowing ? @"rt_unfollow" : @"rt_follow";
    NSString *severSource = [NSString stringWithFormat:@"%ld",WDFriendFollowNewSourceWendaListCell];
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:self.gdExtJson];
    [dict setValue:@"answer_list_answer_cell" forKey:@"source"];
    [dict setValue:@"answer_list" forKey:@"position"];
    [dict setValue:self.ansEntity.ansid forKey:@"group_id"];
    [dict setValue:self.ansEntity.user.userID forKey:@"to_user_id"];
    [dict setValue:@"from_group" forKey:@"follow_type"];
    [dict setValue:severSource forKey:@"sever_source"];
    if (self.needSendRedPackFlag) {
        if (isFollowing) {
            self.needSendRedPackFlag = NO;
        }
        [dict setValue:@1 forKey:@"is_redpacket"];
    }
    [TTTracker eventV3:event params:[dict copy]];
    
    self.isSelfFollow = YES;
    [followBtn startLoading];
    WeakSelf;
    [[TTFollowManager sharedManager] startFollowAction:isFollowing ? FriendActionTypeUnfollow: FriendActionTypeFollow
                                             userID:self.ansEntity.user.userID
                                           platform:nil
                                               name:nil
                                               from:nil
                                             reason:nil
                                          newReason:nil
                                          newSource:@(WDFriendFollowNewSourceWendaListCell)
                                         completion:^(FriendActionType type, NSError * _Nullable error, NSDictionary * _Nullable result) {
                                             StrongSelf;
                                             if (!error) {
                                                 [followBtn stopLoading:^{}];
                                                 [self updateFollowStateWithNewIsFollowing:!isFollowing];
                                                 [self refreshFollowButtonState];
                                                 
                                                 if (self.cellViewModel.ansEntity.user.redPack && !isFollowing) {
                                                     NSMutableDictionary *extraDict = @{}.mutableCopy;
                                                     [extraDict setValue:self.cellViewModel.ansEntity.user.userID forKey:@"user_id"];
                                                     [extraDict setValue:[self.gdExtJson tt_stringValueForKey:@"category_name"] forKey:@"category"];
                                                     [extraDict setValue:@"answer_list_answer_cell" forKey:@"source"];
                                                     [extraDict setValue:@"answer_list" forKey:@"position"];
                                                     [extraDict setValue:self.gdExtJson forKey:@"gd_ext_json"];
                                                     
                                                     [[WDAdapterSetting sharedInstance] showRedPackViewWithRedPackModel:self.cellViewModel.ansEntity.user.redPack extraDict:[extraDict copy] viewController:[TTUIResponderHelper topViewControllerFor:self]];
                                                 }
                                             } else {
                                                 NSString *hint = [[[result tt_dictionaryValueForKey:@"result"] tt_dictionaryValueForKey:@"data"] tt_stringValueForKey:@"description"];
                                                 if (!TTNetworkConnected()) {
                                                     hint = @"网络不给力，请稍后重试";
                                                 }
                                                 if (isEmptyString(hint)) {
                                                     hint = NSLocalizedString(type == FriendActionTypeFollow ? @"关注失败" : @"取消关注失败", nil);
                                                 }
                                                 [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:hint indicatorImage:[UIImage imageNamed:@"close_popup_textpage.png"] autoDismiss:YES dismissHandler:nil];
                                                 [followBtn stopLoading:^{}];
                                                 [self refreshFollowButtonState];
                                             }
                                         }];
}

#pragma mark - WDWendaListCellActionFooterViewDelegate

- (void)listCellActionFooterViewDiggButtonClick:(TTAlphaThemedButton *)diggButton {
    if ([self.ansEntity isBuryed]) {
        [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:NSLocalizedString(@"您已经反对过", nil) indicatorImage:nil autoDismiss:YES dismissHandler:nil];
    } else {
        WDDiggType digType = WDDiggTypeDigg;
        if (![self.ansEntity isDigg]) {
            [self diggAnimationWith:diggButton];
            NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:self.gdExtJson];
            [dict setValue:@"answer_list_answer_cell" forKey:@"source"];
            [dict setValue:@"answer_list" forKey:@"position"];
            [dict setValue:self.ansEntity.ansid forKey:@"group_id"];
            [TTTracker eventV3:@"rt_like" params:[dict copy]];
        } else {
            NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:self.gdExtJson];
            [dict setValue:@"answer_list_answer_cell" forKey:@"source"];
            [dict setValue:@"answer_list" forKey:@"position"];
            [dict setValue:self.ansEntity.ansid forKey:@"group_id"];
            [TTTracker eventV3:@"rt_unlike" params:[dict copy]];
            if (diggButton.selected) {
                diggButton.selected = NO;
            }
            self.ansEntity.diggCount = (self.ansEntity.diggCount.longLongValue >= 1) ? @(self.ansEntity.diggCount.longLongValue - 1) : @0;
            self.ansEntity.isDigg = NO;
            [self.ansEntity save];
            digType = WDDiggTypeUnDigg;
        }
        [WDAnswerService digWithAnswerID:self.ansEntity.ansid diggType:digType enterFrom:kWDWendaListViewControllerUMEventName apiParam:self.apiParams finishBlock:nil];
    }
}

- (void)listCellActionFooterViewCommentButtonClick {
    [self.cellViewModel enterAnswerDetailPageFromComment];
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:self.gdExtJson];
    [dict setValue:@"answer_list_answer_cell" forKey:@"source"];
    [dict setValue:@"answer_list" forKey:@"position"];
    [dict setValue:self.ansEntity.ansid forKey:@"group_id"];
    [TTTracker eventV3:@"cell_comment" params:[dict copy]];
}

- (void)listCellActionFooterViewForwardButtonClick {
    [self.cellViewModel forwardCurrentAnswerToUGC];
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:self.gdExtJson];
    [dict setValue:@"answer_list_answer_cell" forKey:@"source"];
    [dict setValue:@"answer_list" forKey:@"position"];
    [dict setValue:self.ansEntity.ansid forKey:@"group_id"];
    [dict setValue:@"weitoutiao" forKey:@"share_platform"];
    dict[@"event_type"] = @"house_app2c_v2";

    [TTTracker eventV3:@"rt_share_to_platform" params:[dict copy]];
}

#pragma mark - WDVideoPlayerTransferReceiver

- (void)playerPlaybackState:(TTVVideoPlaybackState)state {

}

- (void)actionChangeCallbackWithAction:(TTVPlayerStateAction *)action {
    switch (action.actionType) {
            case TTVPlayerEventTypeFinishDirectShare:{
                if ([action.payload isKindOfClass:[NSString class]]) {
                    [self triggerShareActionWithActivityType:action.payload];
                    
                }
            }
            break;
            case TTVPlayerEventTypePlayingDirectShare:{
                if ([action.payload isKindOfClass:[NSString class]]) {
                    [self triggerShareActionWithActivityType:action.payload];
                }
            }
            break;
        default:
            break;
    }
}

#pragma mark - TTVFullscreenCellProtocol

- (UIView *)ttv_playerSuperView {
    return self.videoCoverPicView;
}

#pragma mark - Share

- (void)triggerShareActionWithActivityType:(NSString *)activityTypeString {
    if (self.ansEntity.shareData == nil) {
        return;
    }
    WDWendaListCellShareHelper *shareHelper = [[WDWendaListCellShareHelper alloc] initWithAnswerEntity:self.ansEntity];
    id<TTActivityContentItemProtocol> shareItem = [shareHelper getItemWithActivityType:activityTypeString];
    if (shareItem) {
        [self.shareManager shareToActivity:shareItem presentingViewController:nil];
    }
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:self.gdExtJson];
    [params setValue:@"answer_share_video" forKey:@"source"];
    [params setValue:@"list" forKey:@"position"];
    [params setValue:self.ansEntity.ansid forKey:@"group_id"];
    [params setValue:shareHelper.sharePlatform forKey:@"share_platform"];
    params[@"event_type"] = @"house_app2c_v2";
    [TTTrackerWrapper eventV3:@"rt_share_to_platform" params:params];
}

#pragma mark - TTShareManagerDelegate

- (void)shareManager:(TTShareManager *)shareManager
       completedWith:(id<TTActivityProtocol>)activity
          sharePanel:(id<TTActivityPanelControllerProtocol>)panelController
               error:(NSError *)error
                desc:(NSString *)desc {
    
}

#pragma mark - Notification

- (void)themeChanged:(NSNotification *)notification
{
    [super themeChanged:notification];
    
    self.bottomLabel.backgroundColor = [UIColor tt_themedColorForKey:kColorBackground4];
    self.rewardLabel.backgroundColor = [UIColor tt_themedColorForKey:kColorBackground4];
    NSString *colorString = ([[TTThemeManager sharedInstance_tt] currentThemeMode] == TTThemeModeDay) ? @"E8E8E8" : @"464646";
    self.videoCoverPicView.layer.borderWidth = [TTDeviceHelper ssOnePixel];
    self.videoCoverPicView.layer.borderColor = [UIColor colorWithHexString:colorString].CGColor;
    
    if (self.cellViewModel.isAnswerGetReward) {
        NSString *urlString = (TTThemeModeDay == [[TTThemeManager sharedInstance_tt] currentThemeMode]) ? self.ansEntity.profitLabel.icon_day_url : self.ansEntity.profitLabel.icon_night_url;
        if (!isEmptyString(urlString)) {
            [self.rewardIconImageView setImageWithURLString:urlString];
            self.rewardIconImageView.backgroundColor = [UIColor clearColor];
        }
    }
}

- (void)followNotification:(NSNotification *)notify {
    if (self.isSelfFollow) {
        return;
    }
    NSString *userID = notify.userInfo[kRelationActionSuccessNotificationUserIDKey];
    NSString *userIDOfSelf = self.ansEntity.user.userID;
    if (!isEmptyString(userID) && [userID isEqualToString:userIDOfSelf]) {
        NSInteger actionType = [(NSNumber *)notify.userInfo[kRelationActionSuccessNotificationActionTypeKey] integerValue];
        BOOL isFollowedState = self.ansEntity.user.isFollowing;
        if (actionType == FriendActionTypeFollow) {
            isFollowedState = YES;
        }else if (actionType == FriendActionTypeUnfollow) {
            isFollowedState = NO;
        }
        [self updateFollowStateWithNewIsFollowing:isFollowedState];
    }
}

- (void)answerForwardToUGCSuccess:(NSNotification *)notify {
    if ([notify.userInfo[@"repostOperationItemType"] integerValue] == 6 && [notify.userInfo[@"repostOperationItemID"] isEqualToString:self.ansEntity.ansid]) {
        if ([notify.userInfo[@"is_repost_to_comment"] boolValue]) {
            self.ansEntity.commentCount = @([self.ansEntity.commentCount longLongValue] + 1);
        }
        self.ansEntity.forwardCount = @([self.ansEntity.forwardCount longLongValue] + 1);
        [self.ansEntity save];
    }
}

- (void)stopPlayingMovie {
    if (self.videoPlayView) {
        [WDAdapterSetting stopCurrentVideoPlayViewPlaying:self.videoPlayView];
        [self.videoPlayView removeFromSuperview];
        self.videoPlayView = nil;
        [WDAdapterSetting sharedInstance].receiver = nil;
    }
}

#pragma mark - Action

- (void)videoPlayButtonClicked {
    NSMutableDictionary *trackerDic = [NSMutableDictionary dictionaryWithDictionary:self.gdExtJson];
    [trackerDic setValue:@"list" forKey:@"position"];
    [trackerDic setValue:self.ansEntity.ansid forKey:@"value"];
    [trackerDic setValue:self.cellViewModel.videoModel.video_id forKey:@"video_id"];
    NSString *tag = [self.gdExtJson objectForKey:@"category_name"];
    if (isEmptyString(tag)) {
        tag = @"unknown";
    }
    NSString *clickTag = [NSString stringWithFormat:@"click_%@",tag];
    [trackerDic setValue:clickTag forKey:@"label"];
    [trackerDic setValue:@(10) forKey:@"group_source"];
    [trackerDic setValue:self.ansEntity.ansid forKey:@"group_id"];
    
    [WDAdapterSetting removeOtherVideoPlayViews];
    
    NSMutableDictionary *allParams = [NSMutableDictionary dictionary];
    [allParams setValue:self.ansEntity.ansid forKey:@"groupID"];
    [allParams setValue:kWDCategoryId forKey:@"categoryID"];
    [allParams setValue:self.cellViewModel.videoModel.video_id forKey:@"videoID"];
    [allParams setValue:NSStringFromCGRect(self.videoCoverPicView.bounds) forKey:@"frame"];
    [allParams setValue:self.ansEntity.questionTitle forKey:@"videoTitle"];
    [allParams setValue:[self.cellViewModel.videoModel.cover_pic toDictionary] forKey:@"logoImageDict"];
    [allParams setValue:@(0) forKey:@"isInDetail"];
    [allParams setValue:trackerDic forKey:@"fullTrack"];
    
    self.videoPlayView = [WDAdapterSetting createNewVideoPlayViewWithParams:allParams];
    [self.videoCoverPicView addSubview:self.videoPlayView];
    
    [WDAdapterSetting sharedInstance].receiver = self;
}

#pragma mark - Get

- (WDWendaListCellUserHeaderView *)headerView {
    if (!_headerView) {
        _headerView = [[WDWendaListCellUserHeaderView alloc] initWithFrame:CGRectMake(0, 0, self.width, 0)];
        _headerView.delegate = self;
    }
    return _headerView;
}

- (WDWendaListCellActionFooterView *)actionView {
    if (!_actionView) {
        _actionView = [[WDWendaListCellActionFooterView alloc] initWithFrame:CGRectMake(0, 0, self.width, 0) answerEntity:self.ansEntity];
        _actionView.delegate = self;
    }
    return _actionView;
}

- (WDWendaListCellPureCharacterView *)characterView {
    if (!_characterView) {
        _characterView = [[WDWendaListCellPureCharacterView alloc] initWithFrame:CGRectMake(0, 0, self.width, 0)];
    }
    return _characterView;
}

- (TTImageView *)videoCoverPicView {
    if (!_videoCoverPicView) {
        _videoCoverPicView = [[TTImageView alloc] initWithFrame:CGRectZero];
        _videoCoverPicView.imageView.contentMode = UIViewContentModeScaleAspectFill;
        _videoCoverPicView.layer.borderWidth = [TTDeviceHelper ssOnePixel];
        NSString *colorString = ([[TTThemeManager sharedInstance_tt] currentThemeMode] == TTThemeModeDay) ? @"E8E8E8" : @"464646";
        _videoCoverPicView.layer.borderColor = [UIColor colorWithHexString:colorString].CGColor;
        [_videoCoverPicView addSubview:self.videoPlayButton];
        [_videoCoverPicView addSubview:self.videoDurationView];
    }
    return _videoCoverPicView;
}

- (SSThemedButton *)videoPlayButton {
    if (!_videoPlayButton) {
        _videoPlayButton = [TTAlphaThemedButton buttonWithType:UIButtonTypeCustom];
        _videoPlayButton.imageName = [TTDeviceHelper isPadDevice] ? @"FullPlay" : @"Play";
        [_videoPlayButton sizeToFit];
        [_videoPlayButton setHitTestEdgeInsets:UIEdgeInsetsMake(-20, -20, -20, -20)];
        [_videoPlayButton addTarget:self action:@selector(videoPlayButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    }
    return _videoPlayButton;
}

- (TTVideoDurationView *)videoDurationView {
    if (!_videoDurationView) {
        _videoDurationView = [[TTVideoDurationView alloc] initWithFrame:CGRectZero];
        _videoDurationView.isLightStyle = YES;
    }
    return _videoDurationView;
}

- (TTImageView *)rewardIconImageView {
    if (!_rewardIconImageView) {
        _rewardIconImageView = [[TTImageView alloc] initWithFrame:CGRectMake(0, 0, WDPadding(20), WDPadding(20))];
        _rewardIconImageView.imageView.contentMode = UIViewContentModeScaleAspectFill;
        _rewardIconImageView.backgroundColor = [UIColor clearColor];
        _rewardIconImageView.enableNightCover = NO;
    }
    return _rewardIconImageView;
}

- (SSThemedLabel *)rewardLabel {
    if (!_rewardLabel) {
        CGFloat fontSize = [WDListCellLayoutModel answerReadCountsFontSize];
        _rewardLabel = [[SSThemedLabel alloc] initWithFrame:CGRectZero];
        _rewardLabel.font = [UIFont systemFontOfSize:fontSize];
        _rewardLabel.textColorThemeKey = kColorText1;
        _rewardLabel.backgroundColor = [UIColor tt_themedColorForKey:kColorBackground4];
    }
    return _rewardLabel;
}

- (SSThemedLabel *)bottomLabel {
    if (!_bottomLabel) {
        CGFloat fontSize = [WDListCellLayoutModel answerReadCountsFontSize];
        _bottomLabel = [[SSThemedLabel alloc] initWithFrame:CGRectZero];
        _bottomLabel.font = [UIFont systemFontOfSize:fontSize];
        _bottomLabel.textColorThemeKey = kColorText3;
        _bottomLabel.backgroundColor = [UIColor tt_themedColorForKey:kColorBackground4];
    }
    return _bottomLabel;
}

- (SSThemedView *)footerView {
    if (!_footerView) {
        _footerView = [[SSThemedView alloc] init];
        _footerView.backgroundColorThemeKey = ([TTDeviceHelper isPadDevice]) ? kColorLine1 : kColorBackground3;
    }
    return _footerView;
}

- (TTShareManager *)shareManager {
    if (!_shareManager) {
        _shareManager = [[TTShareManager alloc] init];
        _shareManager.delegate = self;
    }
    return _shareManager;
}

- (WDListCellViewModel *)cellViewModel {
    return self.cellLayoutModel.viewModel;
}

- (WDAnswerEntity *)ansEntity {
    return self.cellViewModel.ansEntity;
}

#pragma mark - Animation

- (void)diggAnimationWith:(TTAlphaThemedButton *)sender
{
    [SSMotionRender motionInView:sender.imageView
                          byType:SSMotionTypeZoomInAndDisappear
                           image:[UIImage themedImageNamed:@"add_all_dynamic"]
                     offsetPoint:CGPointMake(4.f, -9.f)];
    if (!sender.selected){
        sender.imageView.transform = CGAffineTransformMakeScale(1.f, 1.f);
        sender.imageView.contentMode = UIViewContentModeCenter;
        [UIView animateWithDuration:0.1f delay:0.f options:UIViewAnimationOptionCurveEaseOut animations:^{
            sender.imageView.transform = CGAffineTransformMakeScale(0.6f, 0.6f);
        } completion:^(BOOL finished) {
            sender.selected = YES;
            sender.alpha = 0;
            
            self.ansEntity.diggCount = @([self.ansEntity.diggCount longLongValue] + 1);
            self.ansEntity.isDigg = YES;
            [self.ansEntity save];
            
            [UIView animateWithDuration:0.2f delay:0.f options:UIViewAnimationOptionCurveEaseIn animations:^{
                sender.imageView.transform = CGAffineTransformMakeScale(1.f, 1.f);
                sender.alpha = 1;
            } completion:nil];
        }];
    }else {
        self.ansEntity.diggCount = @([self.ansEntity.diggCount longLongValue] + 1);
        self.ansEntity.isDigg = YES;
        [self.ansEntity save];
    }
}

@end
