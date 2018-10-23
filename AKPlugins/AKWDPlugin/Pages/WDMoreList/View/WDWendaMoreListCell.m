//
//  WDWendaMoreListCell.m
//  Pods
//
//  Created by wangqi.kaisa on 2017/8/21.
//
//

#import "WDWendaMoreListCell.h"
#import "WDDefines.h"
#import "WDFollowDefines.h"
#import "WDFontDefines.h"
#import "WDSettingHelper.h"
#import "WDLayoutHelper.h"
#import "WDUIHelper.h"
#import "WDCommonLogic.h"
#import "TTDeviceHelper.h"
#import "TTStringHelper.h"
#import "WDAnswerService.h"
#import "WDMoreListTrackerEventDefines.h"

#import "NSObject+FBKVOController.h"
#import "TTAlphaThemedButton.h"
#import "TTTAttributedLabel.h"
#import "UIButton+TTAdditions.h"
#import "UIImage+TTThemeExtension.h"
#import "TTIndicatorView.h"
#import "TTImageView.h"
#import "UIImageView+WebCache.h"
#import <TTFriendRelation/TTFollowThemeButton.h>
#import <TTFriendRelation/TTFollowManager.h>
#import <TTUIWidget/SSMotionRender.h>
#import <TTBaseLib/NetworkUtilities.h>
#import <TTTracker/TTTracker.h>
#import <TTRoute/TTRoute.h>
#import "WDTrackerHelper.h"
#import "WDQuestionEntity.h"
#import "WDAnswerEntity.h"
#import "WDMoreListViewModel.h"
#import "WDMoreListCellViewModel.h"
#import "WDMoreListCellLayoutModel.h"
#import "WDWendaListCellUserHeaderView.h"

NSString * const WDMoreListCellCommentButtonClickTrackerEvent = @"cell_comment";
NSString * const WDMoreListCellForwardButtonClickTrackerEvent = @"rt_share_to_platform";
NSString * const WDMoreListCellFollowButtonClickTrackerEvent = @"rt_follow";
NSString * const WDMoreListCellUnFollowButtonClickTrackerEvent = @"rt_unfollow";
NSString * const WDMoreListCellDiggButtonClickTrackerEvent = @"rt_like";
NSString * const WDMoreListCellUnDiggButtonClickTrackerEvent = @"rt_unlike";

@interface WDWendaMoreListCell ()<WDWendaListCellUserHeaderViewDelegate>

@property (nonatomic, strong) WDWendaListCellUserHeaderView *headerView;

@property (nonatomic, strong) TTTAttributedLabel *abstContentLabel;
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

@implementation WDWendaMoreListCell

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
            self.abstContentLabel.backgroundColor = [UIColor tt_themedColorForKey:kColorBackground3];
            self.bottomLabel.backgroundColor = [UIColor tt_themedColorForKey:kColorBackground3];
            [self.headerView setHighlighted:highlighted];
            self.isViewHighlighted = YES;
        }
    } else {
        if (self.isViewHighlighted) {
            self.contentView.backgroundColor = [UIColor tt_themedColorForKey:kColorBackground4];
            self.abstContentLabel.backgroundColor = [UIColor tt_themedColorForKey:kColorBackground4];
            self.bottomLabel.backgroundColor = [UIColor tt_themedColorForKey:kColorBackground4];
            [self.headerView setHighlighted:highlighted];
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
    if (self.cellLayoutModel.cellCacheHeight == 0) {
        [cellLayoutModel calculateLayoutIfNeedWithCellWidth:cellWidth];
    }
    [self refreshSubviewsContentAndLayout];
}

- (void)refreshSubviewsContentAndLayout {
    [self.headerView refreshUserInfoContent:self.ansEntity.user descInfo:self.cellViewModel.secondLineContent followButtonHidden:self.cellViewModel.isFollowButtonHidden];
    [self refreshFollowButtonState];
    
    [self updateAbstContentLabel];
    [self refreshAbstContentLabelFrameWithTop:SSMaxY(self.headerView)];
    
    CGFloat bottomLineOriginY = (self.abstContentLabel.bottom);
    
    [self refreshBottomLabelContent];
    self.bottomLabel.top = bottomLineOriginY + self.cellLayoutModel.bottomLabelTopPadding;
    self.bottomLabel.left = self.abstContentLabel.left;
    
    bottomLineOriginY = self.bottomLabel.bottom + self.cellLayoutModel.bottomLabelBottomPadding;
    
    self.footerView.frame = CGRectMake(0, bottomLineOriginY, self.cellWidth, [WDMoreListCellLayoutModel heightForFooterView]);
    
    [self addObserveKVO];
    [self addObserveNotification];
}

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

#pragma mark - Private

- (void)createSubviewsIfNeeded {
    if (_headerView) return;
    [self.contentView addSubview:self.headerView];
    [self.contentView addSubview:self.bottomLabel];
    [self.contentView addSubview:self.abstContentLabel];
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
    [self.KVOController observe:self.ansEntity keyPath:NSStringFromSelector(@selector(diggCount)) options:NSKeyValueObservingOptionNew block:^(id  _Nullable observer, id  _Nonnull object, NSDictionary<NSString *,id> * _Nonnull change) {
        StrongSelf;
        [self refreshBottomLabelContent];
    }];
}

- (void)addObserveNotification {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:RelationActionSuccessNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(followNotification:) name:RelationActionSuccessNotification object:nil];
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

#pragma mark - Notification

- (void)themeChanged:(NSNotification *)notification
{
    [super themeChanged:notification];
    
    self.abstContentLabel.textColor = [UIColor tt_themedColorForKey:kColorText1];
    self.abstContentLabel.backgroundColor = [UIColor tt_themedColorForKey:kColorBackground4];
    self.bottomLabel.backgroundColor = [UIColor tt_themedColorForKey:kColorBackground4];
    [self updateAbstContentLabel];
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

#pragma mark -- setter abstContentLabel

- (void)updateAbstContentLabel
{
    CGFloat fontSize = [WDMoreListCellLayoutModel answerAbstractContentFontSize];
    CGFloat lineHeight = [WDMoreListCellLayoutModel answerAbstractContentLineHeight];
    NSMutableAttributedString * attributedString = [WDLayoutHelper attributedStringWithString:self.cellViewModel.answerContentAbstract fontSize:fontSize lineHeight:lineHeight];
    [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor tt_themedColorForKey:kColorText1] range:NSMakeRange(0, [attributedString.string length])];
    self.abstContentLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    self.abstContentLabel.attributedTruncationToken = [self tokenAttributeString];
    self.abstContentLabel.attributedText = attributedString;
}

- (void)refreshAbstContentLabelFrameWithTop:(CGFloat)top
{
    self.abstContentLabel.frame = CGRectMake(kWDCellLeftPadding, top, self.cellWidth - kWDCellLeftPadding - kWDCellRightPadding , self.cellLayoutModel.contentLabelHeight);
}

#pragma mark - getter

- (NSAttributedString *)tokenAttributeString {
    NSString *textColor = kColorText1;
    CGFloat fontSize = [WDMoreListCellLayoutModel answerAbstractContentFontSize];
    NSMutableAttributedString *token = [[NSMutableAttributedString alloc] initWithString:@"...全文"
                                                                              attributes:@{
                                                                                           NSFontAttributeName : [UIFont systemFontOfSize:fontSize],
                                                                                           NSForegroundColorAttributeName : [UIColor tt_themedColorForKey:textColor]}
                                        ];
    
    NSAttributedString *opaqueToken = [[NSAttributedString alloc] initWithString:@"透明的字" attributes:@{
                                                                                                       NSFontAttributeName : [UIFont systemFontOfSize:fontSize],
                                                                                                       NSForegroundColorAttributeName : [UIColor clearColor]} ];
    [token appendAttributedString:opaqueToken];
    
    return token;
}

- (WDWendaListCellUserHeaderView *)headerView {
    if (!_headerView) {
        _headerView = [[WDWendaListCellUserHeaderView alloc] initWithFrame:CGRectMake(0, 0, self.width, 0)];
        _headerView.delegate = self;
    }
    return _headerView;
}

- (TTTAttributedLabel *)abstContentLabel {
    if (!_abstContentLabel) {
        CGFloat fontSize = [WDMoreListCellLayoutModel answerAbstractContentFontSize];
        _abstContentLabel = [[TTTAttributedLabel alloc] initWithFrame:CGRectZero];
        _abstContentLabel.attributedTruncationToken = [self tokenAttributeString];
        _abstContentLabel.numberOfLines = [[WDSettingHelper sharedInstance_tt] moreListAnswerTextMaxCount];
        _abstContentLabel.font = [UIFont systemFontOfSize:fontSize];
        _abstContentLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        _abstContentLabel.clipsToBounds = YES;
        _abstContentLabel.backgroundColor = [UIColor tt_themedColorForKey:kColorBackground4];
    }
    return _abstContentLabel;
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

@end

