//
//  WDWendaMoreListLightCell.m
//  TTWenda
//
//  Created by wangqi.kaisa on 2018/1/4.
//

#import "WDWendaMoreListLightCell.h"
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
#import "WDMoreListTrackerEventDefines.h"
#import "WDMoreListCellLayoutModel.h"
#import "WDMoreListCellViewModel.h"
#import "WDListCellDataModel.h"
#import "WDAnswerService.h"
#import "WDAnswerEntity.h"
#import "TTIndicatorView.h"
#import "WDMoreListViewModel.h"
#import "WDTrackerHelper.h"
#import "WDFollowDefines.h"
#import "WDAdapterSetting.h"
#import "WDUIHelper.h"

@interface WDWendaMoreListLightCell ()<WDWendaListCellUserHeaderViewDelegate,WDWendaListCellActionFooterViewDelegate>

@property (nonatomic, strong) WDWendaListCellUserHeaderView *headerView;
@property (nonatomic, strong) WDWendaListCellActionFooterView *actionView;
@property (nonatomic, strong) WDWendaListCellPureCharacterView *characterView;

@property (nonatomic, strong) SSThemedLabel *bottomLabel;
@property (nonatomic, strong) SSThemedView  *footerView;

@property (nonatomic, strong) WDMoreListCellLayoutModel *cellLayoutModel;
@property (nonatomic, strong, readonly) WDMoreListCellViewModel *cellViewModel;
@property (nonatomic, strong, readonly) WDAnswerEntity *ansEntity;
@property (nonatomic, copy) NSDictionary *gdExtJson;
@property (nonatomic, copy) NSDictionary *apiParams;

@property (nonatomic, assign) CGFloat cellWidth;
@property (nonatomic, assign) BOOL isViewHighlighted;
@property (nonatomic, assign) BOOL isSelfFollow;

@end

@implementation WDWendaMoreListLightCell

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
            [self.headerView setHighlighted:highlighted];
            [self.characterView setHighlighted:highlighted];
            self.isViewHighlighted = YES;
        }
    } else {
        if (self.isViewHighlighted) {
            self.contentView.backgroundColor = [UIColor tt_themedColorForKey:kColorBackground4];
            self.bottomLabel.backgroundColor = [UIColor tt_themedColorForKey:kColorBackground4];
            [self.headerView setHighlighted:highlighted];
            [self.characterView setHighlighted:highlighted];
            self.isViewHighlighted = NO;
        }
    }
}

- (void)cellDidSelected {
    [self.cellViewModel cellDidSelectedWithGdExtJson:self.gdExtJson];
}

#pragma mark - Refresh & Layout

- (void)refreshWithCellLayoutModel:(WDMoreListCellLayoutModel *)cellLayoutModel cellWidth:(CGFloat)cellWidth {
    self.cellWidth = cellWidth;
    self.cellLayoutModel = cellLayoutModel;
    if (self.cellViewModel.isInvalidData) {
        return;
    }
    [self createSubviewsIfNeeded];
    self.headerView.width = self.cellWidth;
    self.actionView.width = self.cellWidth;
    self.characterView.width = self.cellWidth;
    if (self.cellLayoutModel.cellCacheHeight == 0) {
        [cellLayoutModel calculateLayoutIfNeedWithCellWidth:cellWidth];
    }
    [self refreshSubviewsContentAndLayout];
}

- (void)refreshSubviewsContentAndLayout {
    CGFloat originY = [self refreshUserInfoViewContentAndLayout];
    originY = [self refreshAnswerTextContentAndLayout:originY];
    originY = [self refreshBottomViewContentAndLayout:originY];
//    originY = [self refreshActionViewContentAndLayout:originY];
    [self refreshFooterViewLayout:originY];
    
    [self addObserveKVO];
    [self addObserveNotification];
}

- (CGFloat)refreshUserInfoViewContentAndLayout {
    [self.headerView refreshUserInfoContent:self.ansEntity.user descInfo:self.cellViewModel.secondLineContent followButtonHidden:self.cellViewModel.isFollowButtonHidden];
    [self refreshFollowButtonState];
    
    return SSMaxY(self.headerView);
}

- (CGFloat)refreshAnswerTextContentAndLayout:(CGFloat)top {
    self.characterView.top = top;
    [self.characterView updateAbstContentLabelText:self.cellViewModel.answerContentAbstract numberOfLines:self.cellLayoutModel.answerLinesCount];
    [self.characterView refreshAbstContentLabelLayout:self.cellLayoutModel.contentLabelHeight];
    return (self.characterView.bottom);
}

- (CGFloat)refreshBottomViewContentAndLayout:(CGFloat)top {
    [self refreshBottomLabelContent];
    self.bottomLabel.top = top + self.cellLayoutModel.bottomLabelTopPadding;
    self.bottomLabel.left = kWDCellLeftPadding;
    
    return self.bottomLabel.bottom + self.cellLayoutModel.bottomLabelBottomPadding;
}

- (CGFloat)refreshActionViewContentAndLayout:(CGFloat)top {
    self.actionView.top = top;
    [self.actionView refreshForwardCount:self.cellViewModel.forwardCount commentCount:self.cellViewModel.commentCount diggCount:self.cellViewModel.diggCount isDigg:self.cellViewModel.ansEntity.isDigg];
    return self.actionView.bottom;
}

- (void)refreshFooterViewLayout:(CGFloat)top {
    self.footerView.frame = CGRectMake(0, top, self.cellWidth, [WDMoreListCellLayoutModel heightForFooterView]);
}

#pragma mark - Refresh Content

- (void)updateFollowStateWithNewIsFollowing:(BOOL)isFollowing {
    if (self.ansEntity.user.isFollowing == isFollowing) {
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
}

- (void)refreshBottomLabelContent {
    self.bottomLabel.text = self.cellViewModel.bottomLabelContent;
    [self.bottomLabel sizeToFit];
    self.bottomLabel.width = ceilf(self.bottomLabel.width);
    self.bottomLabel.height = [WDMoreListCellLayoutModel answerReadCountsLineHeight];
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
    [self.contentView addSubview:self.bottomLabel];
//    [self.contentView addSubview:self.actionView];
//    [self.contentView addSubview:self.footerView];
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
    NSString *label = @"fold_name";
    NSInteger extValue = isEmptyString(self.ansEntity.user.userIntro) ? 0 : 1;
    
    NSMutableDictionary *dict = [self.gdExtJson mutableCopy];
    [dict setValue:self.ansEntity.user.userID forKey:@"value"];
    [dict setValue:@(extValue) forKey:@"ext_value"];
    [WDMoreListViewModel trackEvent:kWDWendaMoreListViewControllerUMEventName label:label gdExtJson:[dict copy]];
    
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
    BOOL isFollowed = self.ansEntity.user.isFollowing;
    NSString *event = isFollowed ? WDMoreListCellUnFollowButtonClickTrackerEvent : WDMoreListCellFollowButtonClickTrackerEvent;
    NSDictionary *dict = [self.cellViewModel followButtonTappedTrackDict];
    NSMutableDictionary *fullDict = [NSMutableDictionary dictionaryWithDictionary:self.gdExtJson];
    [fullDict addEntriesFromDictionary:dict];
    [TTTracker eventV3:event params:fullDict];
    self.isSelfFollow = YES;
    [followBtn startLoading];
    WeakSelf;
    [[TTFollowManager sharedManager] startFollowAction:isFollowed? FriendActionTypeUnfollow: FriendActionTypeFollow
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
                                                 [self updateFollowStateWithNewIsFollowing:!isFollowed];
                                                 [self refreshFollowButtonState];
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
            NSDictionary *dict = [self.cellViewModel diggButtonTappedTrackDict];
            NSMutableDictionary *fullDict = [NSMutableDictionary dictionaryWithDictionary:self.gdExtJson];
            [fullDict addEntriesFromDictionary:dict];
            [TTTracker eventV3:WDMoreListCellDiggButtonClickTrackerEvent params:fullDict];
        } else {
            NSDictionary *dict = [self.cellViewModel diggButtonTappedTrackDict];
            NSMutableDictionary *fullDict = [NSMutableDictionary dictionaryWithDictionary:self.gdExtJson];
            [fullDict addEntriesFromDictionary:dict];
            [TTTracker eventV3:WDMoreListCellUnDiggButtonClickTrackerEvent params:fullDict];
            if (diggButton.selected) {
                diggButton.selected = NO;
            }
            self.ansEntity.diggCount = (self.ansEntity.diggCount.longLongValue >= 1) ? @(self.ansEntity.diggCount.longLongValue - 1) : @0;
            self.ansEntity.isDigg = NO;
            [self.ansEntity save];
            digType = WDDiggTypeUnDigg;
        }
        [WDAnswerService digWithAnswerID:self.ansEntity.ansid diggType:digType enterFrom:kWDWendaMoreListViewControllerUMEventName apiParam:self.apiParams finishBlock:nil];
    }
}

- (void)listCellActionFooterViewCommentButtonClick {
    [self.cellViewModel enterAnswerDetailPageFromComment];
    NSDictionary *dict = [self.cellViewModel commentButtonTappedTrackDict];
    NSMutableDictionary *fullDict = [NSMutableDictionary dictionaryWithDictionary:self.gdExtJson];
    [fullDict addEntriesFromDictionary:dict];
    [TTTracker eventV3:WDMoreListCellCommentButtonClickTrackerEvent params:fullDict];
}

- (void)listCellActionFooterViewForwardButtonClick {
    [self.cellViewModel forwardCurrentAnswerToUGC];
    NSDictionary *dict = [self.cellViewModel forwardButtonTappedTrackDict];
    NSMutableDictionary *fullDict = [NSMutableDictionary dictionaryWithDictionary:self.gdExtJson];
    [fullDict addEntriesFromDictionary:dict];
    [TTTracker eventV3:WDMoreListCellForwardButtonClickTrackerEvent params:fullDict];
}

#pragma mark - Notification

- (void)themeChanged:(NSNotification *)notification
{
    [super themeChanged:notification];
    
    self.bottomLabel.backgroundColor = [UIColor tt_themedColorForKey:kColorBackground4];
}

- (void)followNotification:(NSNotification *)notify
{
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
        } else if (actionType == FriendActionTypeUnfollow) {
            isFollowedState = NO;
        }
        [self updateFollowStateWithNewIsFollowing:isFollowedState];
    }
}

- (void)answerForwardToUGCSuccess:(NSNotification *)notification
{
    // TTRepostOperationItemTypeWendaAnswer == 6
    if ([notification.userInfo[@"repostOperationItemType"] integerValue] == 6 && [notification.userInfo[@"repostOperationItemID"] isEqualToString:self.ansEntity.ansid]) {
        if ([notification.userInfo[@"is_repost_to_comment"] boolValue]) {
            self.ansEntity.commentCount = @([self.ansEntity.commentCount longLongValue] + 1);
        }
        self.ansEntity.forwardCount = @([self.ansEntity.forwardCount longLongValue] + 1);
        [self.ansEntity save];
    }
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

- (SSThemedLabel *)bottomLabel {
    if (!_bottomLabel) {
        CGFloat fontSize = [WDMoreListCellLayoutModel answerReadCountsFontSize];
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

- (WDMoreListCellViewModel *)cellViewModel {
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
    } else {
        self.ansEntity.diggCount = @([self.ansEntity.diggCount longLongValue] + 1);
        self.ansEntity.isDigg = YES;
        [self.ansEntity save];
    }
}

@end
