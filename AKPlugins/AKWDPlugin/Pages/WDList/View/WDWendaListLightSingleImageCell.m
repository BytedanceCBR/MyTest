//
//  WDWendaListLightSingleImageCell.m
//  TTWenda
//
//  Created by wangqi.kaisa on 2018/1/3.
//

#import "WDWendaListLightSingleImageCell.h"
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
#import <TTPhotoScrollVC/TTPhotoScrollViewController.h>
#import <TTServiceKit/TTModuleBridge.h>
#import <TTImage/TTImageView.h>
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
#import "WDListTagImageView.h"
#import "WDUIHelper.h"

@interface WDWendaListLightSingleImageCell ()<WDWendaListCellUserHeaderViewDelegate,WDWendaListCellActionFooterViewDelegate,UIGestureRecognizerDelegate>

@property (nonatomic, strong) WDWendaListCellUserHeaderView *headerView;
@property (nonatomic, strong) WDWendaListCellActionFooterView *actionView;
@property (nonatomic, strong) WDWendaListCellPureCharacterView *characterView;

@property (nonatomic, strong) WDListTagImageView *answerImageView;

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

@implementation WDWendaListLightSingleImageCell

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
    originY = [self refreshAnswerImageContentAndLayout:originY + self.cellLayoutModel.imageViewTopPadding];
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

- (CGFloat)refreshAnswerImageContentAndLayout:(CGFloat)top {
    WDImageUrlStructModel *thumbStructModel = self.ansEntity.contentAbstract.thumb_image_list.firstObject;
    TTImageInfosModel *thumbImageModel = [[TTImageInfosModel alloc] initWithDictionary:[thumbStructModel toDictionary]];
    WDImageUrlStructModel *largeStructModel = self.ansEntity.contentAbstract.large_image_list.firstObject;
    TTImageInfosModel *largeImageModel = [[TTImageInfosModel alloc] initWithDictionary:[largeStructModel toDictionary]];
    BOOL isVLongImage = NO;
    BOOL isHLongImage = NO;
    if (largeImageModel.height > 0 && largeImageModel.width > 0) {
        isVLongImage = (largeImageModel.height >= largeImageModel.width * 2);
        isHLongImage = (largeImageModel.width >= largeImageModel.height * 3);
    }
    NSString *tips = @"";
    WDTagImageViewPosition position = WDTagImageViewPositionBottom;
    if (largeImageModel.imageFileType == TTImageFileTypeGIF) {
        tips = @"GIF";
    } else if (isVLongImage) {
        tips = @"长图";
    } else if (isHLongImage) {
        tips = @"横图";
    }
    self.answerImageView.frame = self.cellLayoutModel.singleImageFrame;
    [self.answerImageView setTagLabelText:tips position:position];
    [self.answerImageView setImageWithModel:thumbImageModel];
    return self.answerImageView.bottom;
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

#pragma mark - Private

- (void)createSubviewsIfNeeded {
    if (_headerView) return;
    [self.contentView addSubview:self.headerView];
    [self.contentView addSubview:self.characterView];
    [self.contentView addSubview:self.answerImageView];
    [self.contentView addSubview:self.rewardIconImageView];
    [self.contentView addSubview:self.rewardLabel];
    [self.contentView addSubview:self.bottomLabel];
    [self.contentView addSubview:self.actionView];
    //[self.contentView addSubview:self.footerView];
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

#pragma mark - Notification

- (void)themeChanged:(NSNotification *)notification
{
    [super themeChanged:notification];
    
    self.bottomLabel.backgroundColor = [UIColor tt_themedColorForKey:kColorBackground4];
    self.rewardLabel.backgroundColor = [UIColor tt_themedColorForKey:kColorBackground4];
    NSString *colorString = ([[TTThemeManager sharedInstance_tt] currentThemeMode] == TTThemeModeDay) ? @"E8E8E8" : @"464646";
    self.answerImageView.layer.borderWidth = [TTDeviceHelper ssOnePixel];
    self.answerImageView.layer.borderColor = [UIColor colorWithHexString:colorString].CGColor;
    
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

- (void)answerForwardToUGCSuccess:(NSNotification *)notification {
    if ([notification.userInfo[@"repostOperationItemType"] integerValue] == 6 && [notification.userInfo[@"repostOperationItemID"] isEqualToString:self.ansEntity.ansid]) {
        if ([notification.userInfo[@"is_repost_to_comment"] boolValue]) {
            self.ansEntity.commentCount = @([self.ansEntity.commentCount longLongValue] + 1);
        }
        self.ansEntity.forwardCount = @([self.ansEntity.forwardCount longLongValue] + 1);
        [self.ansEntity save];
    }
}

#pragma mark - Action

- (void)onTapAnswerImageView:(UITapGestureRecognizer *)gesture {
    if ([gesture.view isKindOfClass:[WDListTagImageView class]]) {
        TTPhotoScrollViewController *showImageViewController = [[TTPhotoScrollViewController alloc] init];
        showImageViewController.finishBackView = [self getSuitableFinishBackViewWithCurrentContext];
        NSArray *largeImageUrls = [self largeImageUrls];
        showImageViewController.imageInfosModels = largeImageUrls;
        NSMutableArray *placeHoldersFrames = [[NSMutableArray alloc] init];
        CGRect imageFrame = self.answerImageView.frame;
        CGRect frame = [self convertRect:imageFrame toView:nil];
        [placeHoldersFrames addObject:[NSValue valueWithCGRect:frame]];
        showImageViewController.placeholderSourceViewFrames = placeHoldersFrames;
        [showImageViewController setStartWithIndex:0];
        [showImageViewController presentPhotoScrollView];
        
        NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:self.gdExtJson];
        [params setValue:self.ansEntity.ansid forKey:@"group_id"];
        [TTTrackerWrapper eventV3:@"cell_click_picture" params:params];
    }
}

- (NSArray<TTImageInfosModel *> *)largeImageUrls
{
    NSMutableArray *imageUrls = @[].mutableCopy;
    WDImageUrlStructModel *imageStructModel = self.cellViewModel.ansEntity.contentAbstract.large_image_list.firstObject;
    TTImageInfosModel *imageModel = [[TTImageInfosModel alloc] initWithDictionary:[imageStructModel toDictionary]];
    [imageUrls addObject:imageModel];
    return [imageUrls copy];
}

- (UIView *)getSuitableFinishBackViewWithCurrentContext
{
    __block UIView *view;
    [[TTModuleBridge sharedInstance_tt] triggerAction:@"getSuitableFinishBackViewWithCurrentContext" object:nil withParams:nil complete:^(id  _Nullable result) {
        if ([result isKindOfClass:[UIView class]]) {
            view = result;
        }
    }];
    return view;
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

- (WDListTagImageView *)answerImageView {
    if (!_answerImageView) {
        _answerImageView = [[WDListTagImageView alloc] init];
        _answerImageView.layer.borderWidth = [TTDeviceHelper ssOnePixel];
        NSString *colorString = ([[TTThemeManager sharedInstance_tt] currentThemeMode] == TTThemeModeDay) ? @"E8E8E8" : @"464646";
        _answerImageView.layer.borderColor = [UIColor colorWithHexString:colorString].CGColor;
        _answerImageView.backgroundColor = [UIColor tt_themedColorForKey:kColorBackground3];
        _answerImageView.imageView.contentMode = UIViewContentModeScaleAspectFill;
        _answerImageView.clipsToBounds = YES;
        _answerImageView.userInteractionEnabled = YES;
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTapAnswerImageView:)];
        tapGesture.delegate = self;
        [_answerImageView addGestureRecognizer:tapGesture];
    }
    return _answerImageView;
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
