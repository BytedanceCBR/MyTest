//
//  TTRecommendRedpacketCellView.m
//  Article
//
//  Created by lipeilun on 2017/11/2.
//

#import <TTAvatar/TTAsyncCornerImageView+VerifyIcon.h>
#import <TTAvatar/SSAvatarView+VerifyIcon.h>
#import <TTImpression/SSImpressionManager.h>
#import "TTRecommendRedpacketCellView.h"
#import "RecommendRedpacketData.h"
#import "ExploreOrderedData+TTBusiness.h"
#import "TTArticleCellConst.h"
#import "TTRecommendRedpacketAction.h"
#import "TTAsyncCornerImageView.h"
#import "TTContactsRedPacketManager.h"
#import "TTFollowThemeButton.h"
#import "TTUISettingHelper.h"
#import "TTColorAsFollowButton.h"
#import "TTRoute.h"
#import "TTAlphaThemedButton.h"
#import "SSAvatarView.h"


#define kDislikeButtonWidth 60
#define kDislikeButtonHeight 44

@interface TTRecommendRedpacketCellView () <SSImpressionProtocol>

@property (nonatomic, strong) SSThemedImageView *backgroundImageView;
@property (nonatomic, assign) BOOL isDisplay; // 卡片可见性

@end

@implementation TTRecommendRedpacketCellView

+ (CGFloat)heightForData:(id)data cellWidth:(CGFloat)width listType:(ExploreOrderedDataListType)listType {
    if ([data isKindOfClass:[ExploreOrderedData class]]) {
        ExploreOrderedData *orderedData = (ExploreOrderedData *) data;
        if (orderedData.recommendRedpacketData.state == RecommendRedpacketCardStateUnfollow) {
            return [TTDeviceUIUtils tt_newPadding:154.f];
        } else if (orderedData.recommendRedpacketData.state == RecommendRedpacketCardStateFollowed) {
            return [TTDeviceUIUtils tt_newPadding:103.f];
        }
    }
    return [TTDeviceUIUtils tt_newPadding:154.f];
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self addSubview:self.showMoreLabel];
        [self addSubview:self.showMoreButton];

        [self addSubview:self.backgroundImageView];
        [self addSubview:self.avatarContainerView];
        [self addSubview:self.redpacketImageView];
        [self addSubview:self.titleLabel];
        [self addSubview:self.moreButton];
        [self addSubview:self.followButton];
        [self addSubview:self.dislikeButton];
        [self addSubview:self.bottomLineView];

        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(receiveRedpacketSuccessNotification:)
                                                     name:kNotificationFollowAndGainMoneySuccessNotification
                                                   object:nil];
    }

    return self;
}

- (void)willAppear {
    [super willAppear];

    _isDisplay = YES;

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self trackTheShowEvent];
    });

    [[SSImpressionManager shareInstance] enterRecommendUserListWithCategoryName:self.orderedData.categoryID cellId:self.orderedData.uniqueID];

    [self needRerecordImpressions]; // 手动调用 record 方法，记录 impr

    [[SSImpressionManager shareInstance] addRegist:self];
}

- (void)trackTheShowEvent {
    NSInteger friendNumber = 0;
    NSString *recommendType = @"0";
    for (FRRecommendUserLargeCardStructModel *model in self.recommendRedpacketData.userDataList) {
        if ([model.selected boolValue]) {
            friendNumber++;
        }

        recommendType = [model.recommend_type stringValue];
    }
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setValue:@"show" forKey:@"action_type"];
    [dict setValue:@"all_follow_card" forKey:@"card_type"];
    [dict setValue:@(self.recommendRedpacketData.numberOfAvatars) forKey:@"head_image_num"];
    [dict setValue:@(self.recommendRedpacketData.hasRedPacket) forKey:@"is_redpacket"];
    [dict setValue:self.recommendRedpacketData.relationTypeValue forKey:@"relation_type"];
    [dict setValue:self.orderedData.categoryID forKey:@"category_name"];
    [dict setValue:@(friendNumber) forKey:@"show_num"];
    [dict setValue:recommendType forKey:@"recommend_type"];
    [TTTrackerWrapper eventV3:@"vert_follow_card" params:dict];
}

- (void)didDisappear {
    [super didDisappear];

    _isDisplay = NO;

    [[SSImpressionManager shareInstance] leaveRecommendUserListWithCategoryName:self.orderedData.categoryID cellId:self.orderedData.uniqueID];
}

/**
 * 此回调方法会在从后台恢复的时候被调用
 **/
- (void)needRerecordImpressions {
    if (self.recommendRedpacketData.numberOfAvatars == 0 || self.recommendRedpacketData.userDataList.count == 0) {
        return;
    }

    NSInteger numberOfAvatars = self.recommendRedpacketData.numberOfAvatars;
    NSArray <FRRecommendUserLargeCardStructModel *> *recommendUsers = self.recommendRedpacketData.userDataList;
    for (int i = 0; i < MIN(MIN(numberOfAvatars, 5), recommendUsers.count); ++i) {
        FRRecommendUserLargeCardStructModel *userModel = recommendUsers[i];
        NSMutableDictionary *extra = @{}.mutableCopy;
        [extra setValue:@"all_follow_card" forKey:@"source"];
        if ([userModel isKindOfClass:[FRRecommendUserLargeCardStructModel class]]) {
            [[SSImpressionManager shareInstance] recordRecommendUserListImpressionUserID:userModel.user.info.user_id
                                                                            categoryName:self.orderedData.categoryID
                                                                                  cellId:self.orderedData.uniqueID
                                                                                  status:_isDisplay ? SSImpressionStatusRecording : SSImpressionStatusSuspend
                                                                                   extra:extra.copy];
        }
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[SSImpressionManager shareInstance] removeRegist:self];
}

- (void)refreshUI {
    self.backgroundColorThemeName = kColorBackground4;

    CGFloat cellHeight;
    if (self.recommendRedpacketData.state == RecommendRedpacketCardStateUnfollow) {
        cellHeight = [TTDeviceUIUtils tt_newPadding:154.f];
    } else if (self.recommendRedpacketData.state == RecommendRedpacketCardStateFollowed) {
        cellHeight = [TTDeviceUIUtils tt_newPadding:103.f];
    }

    CGFloat backgroundTop = [TTDeviceUIUtils tt_newPadding:10];
    CGFloat backgroundHeight = cellHeight - backgroundTop * 2;
    CGFloat backgroundWidth = backgroundHeight * 656.f / 198.f;
    self.backgroundImageView.frame = CGRectMake((self.width - backgroundWidth) / 2, backgroundTop, backgroundWidth, backgroundHeight);

    self.redpacketImageView.frame = CGRectMake(0, [TTDeviceUIUtils tt_newPadding:13], 59, 44);
    self.redpacketImageView.centerX = self.backgroundImageView.centerX;
    self.avatarContainerView.top = [TTDeviceUIUtils tt_newPadding:10];
    self.avatarContainerView.centerX = self.backgroundImageView.centerX;

    [self.titleLabel sizeToFit];
    CGFloat titleWidth = self.titleLabel.width <= (self.width - 52) ? self.titleLabel.width : (self.width - 52);
    self.titleLabel.frame = CGRectMake((self.width - titleWidth - 12) / 2, [TTDeviceUIUtils tt_newPadding:67], titleWidth, 24);

    self.moreButton.frame = CGRectMake(self.titleLabel.right + 4, self.titleLabel.top + 6, 8, 12);
    self.moreButton.hitTestEdgeInsets = UIEdgeInsetsMake(-6, -(self.titleLabel.width + 5), -6, -8);
    self.dislikeButton.frame = CGRectMake(self.width - kDislikeButtonWidth + 7, 0, kDislikeButtonWidth, kDislikeButtonHeight);

    self.followButton.frame = CGRectMake(0, cellHeight - 36 - [TTDeviceUIUtils tt_newPadding:14.f], 200, 36);
    self.followButton.centerX = self.backgroundImageView.centerX;

    self.bottomLineView.frame = CGRectMake(kPaddingLeft(), cellHeight - [TTDeviceHelper ssOnePixel], SSScreenWidth - kPaddingLeft() - kPaddingRight(), [TTDeviceHelper ssOnePixel]);
    if ([(ExploreOrderedData *) self.orderedData nextCellHasTopPadding] || self.hideBottomLine) {
        self.bottomLineView.hidden = YES;
    } else {
        self.bottomLineView.hidden = NO;
    }

    self.showMoreLabel.frame = CGRectMake(30, [TTDeviceUIUtils tt_newPadding:15], self.width - 30 * 2, [TTDeviceUIUtils tt_newPadding:22]);
    self.showMoreButton.frame = CGRectMake((self.width - [TTDeviceUIUtils tt_newPadding:160]) / 2, [TTDeviceUIUtils tt_newPadding:52], [TTDeviceUIUtils tt_newPadding:160], [TTDeviceUIUtils tt_newPadding:36]);

    if (self.recommendRedpacketData.state == RecommendRedpacketCardStateUnfollow) {
        self.backgroundImageView.hidden = NO;
        if (self.recommendRedpacketData.numberOfAvatars == 0) {
            self.redpacketImageView.hidden = NO;
            self.avatarContainerView.hidden = YES;
        } else {
            self.redpacketImageView.hidden = YES;
            self.avatarContainerView.hidden = NO;
        }
        self.titleLabel.hidden = NO;
        self.moreButton.hidden = NO;
        self.followButton.hidden = NO;
        self.showMoreLabel.hidden = YES;
        self.showMoreButton.hidden = YES;
        self.dislikeButton.hidden = NO;
    } else if (self.recommendRedpacketData.state == RecommendRedpacketCardStateFollowed) {
        self.backgroundImageView.hidden = YES;
        self.avatarContainerView.hidden = YES;
        self.redpacketImageView.hidden = YES;
        self.titleLabel.hidden = YES;
        self.moreButton.hidden = YES;
        self.followButton.hidden = YES;
        self.showMoreLabel.hidden = NO;
        self.showMoreButton.hidden = NO;
        self.dislikeButton.hidden = YES;
    }
}

- (void)refreshWithData:(id)data {
    if ([data isKindOfClass:[ExploreOrderedData class]]) {
        self.orderedData = data;
    } else {
        self.orderedData = nil;
        return;
    }

    if ([self.orderedData.originalData isKindOfClass:[RecommendRedpacketData class]]) {
        self.recommendRedpacketData = (RecommendRedpacketData *)self.orderedData.originalData;
    } else {
        self.recommendRedpacketData = nil;
        return;
    }

    if (self.recommendRedpacketData.numberOfAvatars == 0) {
        self.redpacketImageView.hidden = NO;
        self.avatarContainerView.hidden = YES;
    } else {
        self.redpacketImageView.hidden = YES;
        self.avatarContainerView.hidden = NO;
        [self generateAvatarViews:self.recommendRedpacketData.numberOfAvatars recommendUsers:self.recommendRedpacketData.userDataList];
    }

    self.titleLabel.text = self.recommendRedpacketData.centerText;
    [self.followButton setTitle:self.recommendRedpacketData.buttonText forState:UIControlStateNormal];

    self.showMoreLabel.text = self.recommendRedpacketData.showMoreTitle;
    [self.showMoreButton setTitle:self.recommendRedpacketData.showMoreText forState:UIControlStateNormal];

    if (self.recommendRedpacketData.hasRedPacket && self.recommendRedpacketData.numberOfAvatars > 0) {
        self.followButton.imageName = @"feed_redpacket_double_packet_button";
        self.followButton.highlightedImageName = @"feed_redpacket_double_packet_button";
        [self.followButton setImageEdgeInsets:UIEdgeInsetsMake(0, -5, 0, 0)];
        [self.followButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 5, 0, 0)];
    } else {
        self.followButton.imageName = nil;
        self.followButton.highlightedImageName = nil;
        [self.followButton setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
        [self.followButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    }
}

- (id)cellData {
    return self.orderedData;
}

- (void)setOrderedData:(ExploreOrderedData *)orderedData {
    if (_orderedData != orderedData) {
        _orderedData = orderedData;
        _action.orderedData = orderedData;
    }
}

- (void)didSelectWithContext:(TTFeedCellSelectContext *)context {
    // 关注之后, 全卡片可点
    if (self.recommendRedpacketData.state == RecommendRedpacketCardStateFollowed) {
        [self showMoreAction:nil];
    } else {
        [self onClickFollowButton:nil];
    }
}

- (void)onClickFollowButton:(id)sender {
    WeakSelf;

    NSInteger friendNumber = 0;
    NSString *recommendType = @"0";
    for (FRRecommendUserLargeCardStructModel *model in self.recommendRedpacketData.userDataList) {
        if ([model.selected boolValue]) {
            friendNumber++;
        }

        recommendType = [model.recommend_type stringValue];
    }

    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setValue:@(self.recommendRedpacketData.numberOfAvatars) forKey:@"head_image_num"];
    [dict setValue:@(self.recommendRedpacketData.hasRedPacket) forKey:@"is_redpacket"];
    [dict setValue:self.recommendRedpacketData.relationTypeValue forKey:@"relation_type"];
    [dict setValue:self.orderedData.categoryID forKey:@"category_name"];
    [dict setValue:@"all_follow_card" forKey:@"source"];
    [dict setValue:@(friendNumber) forKey:@"show_num"];
    [dict setValue:recommendType forKey:@"recommend_type"];
    [TTTrackerWrapper eventV3:@"all_button_click" params:dict];

    [self.action presentRecommendUsersViewControllerWithTitle:[self.recommendRedpacketData.friendsListInfo tt_stringValueForKey:@"title"]
                                                 buttonFormat:[self.recommendRedpacketData.friendsListInfo tt_stringValueForKey:@"button_text"]
                                       recommendRedpacketData:self.recommendRedpacketData
                                              completionBlock:^(NSSet *userSet) {
                                                  StrongSelf;
                                                  NSMutableArray *newUserDataList = [NSMutableArray array];
                                                  for (FRRecommendUserLargeCardStructModel *model in self.recommendRedpacketData.userDataList) {
                                                      if ([userSet containsObject:model.user.info.user_id]) {
                                                          model.selected = @(YES);
                                                      } else {
                                                          model.selected = @(NO);
                                                      }
                                                      [newUserDataList addObject:model];
                                                  }
                                                  self.recommendRedpacketData.userDataList = newUserDataList;
                                                  [self.recommendRedpacketData save];
                                              }];
}

- (void)receiveRedpacketSuccessNotification:(NSNotification *)notification {
    NSString *showMoreTitle = [notification.userInfo tt_stringValueForKey:@"show_label"];
    NSString *showMoreText = [notification.userInfo tt_stringValueForKey:@"button_text"];
    NSString *showMoreJumpURL = [notification.userInfo tt_stringValueForKey:@"button_schema"];

    [self.recommendRedpacketData setCardState:RecommendRedpacketCardStateFollowed];
    [self.recommendRedpacketData setShowMoreTitle:showMoreTitle showMoreText:showMoreText showMoreJumpURL:showMoreJumpURL];

    [self multiFollowRecommendUsersCompleted];
}

- (void)multiFollowRecommendUsersCompleted {
    self.showMoreLabel.text = self.recommendRedpacketData.showMoreTitle;
    [self.showMoreButton setTitle:self.recommendRedpacketData.showMoreText forState:UIControlStateNormal];

    // 卡片在未复用之前，存在 tableView 为空的情况
    UITableView *tableView = self.tableView;
    if (!tableView) {
        UIResponder *obj = self.nextResponder;
        while (obj && ![obj isKindOfClass:[UITableView class]]) {
            obj = obj.nextResponder;
        }
        if (obj) {
            tableView = (UITableView *)obj;
        }
    }

    NSIndexPath *indexPath = [tableView indexPathForCell:self.cell];
    CGRect rectInTableView = [tableView rectForRowAtIndexPath:indexPath];
    CGRect rectInSuperview = [tableView convertRect:rectInTableView toView:tableView.superview];

    // 如果超出了屏幕，滚动到对应 cell，因为 cell 尺寸会发生变化
    if (rectInSuperview.origin.y < 0) {
        [tableView scrollToRowAtIndexPath:indexPath
                         atScrollPosition:UITableViewScrollPositionTop
                                 animated:NO];
    }

    [self.orderedData clearCacheHeight];

    [tableView beginUpdates];
    [tableView endUpdates];

    [UIView animateWithDuration:0.5f delay:0.1f options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.backgroundColor = [UIColor colorWithHexString:@"FFFDD5"];
    }                completion:^(BOOL finished) {
        self.backgroundColor = [TTUISettingHelper cellViewBackgroundColor];

        self.avatarContainerView.hidden = YES;
        self.redpacketImageView.hidden = YES;
        self.titleLabel.hidden = YES;
        self.moreButton.hidden = YES;
        self.followButton.hidden = YES;
        self.showMoreLabel.hidden = NO;
        self.showMoreButton.hidden = NO;
    }];

    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setValue:@(self.recommendRedpacketData.numberOfAvatars) forKey:@"head_image_num"];
    [dict setValue:@(self.recommendRedpacketData.hasRedPacket) forKey:@"is_redpacket"];
    [dict setValue:self.recommendRedpacketData.relationTypeValue forKey:@"relation_type"];
    [dict setValue:self.orderedData.categoryID forKey:@"category_name"];
    [dict setValue:@"all_follow_card" forKey:@"source"];
    [dict setValue:@"show" forKey:@"action"];
    [TTTrackerWrapper eventV3:@"follow_more" params:dict];
}

- (void)generateAvatarViews:(NSInteger)numberOfAvatars recommendUsers:(NSArray <FRRecommendUserLargeCardStructModel *> *)recommendUsers {
    [self.avatarContainerView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];

    for (int i = 0; i < MIN(MIN(numberOfAvatars, 5), recommendUsers.count); ++i) {
        CGFloat left = i * ([TTDeviceUIUtils tt_newPadding:44] + [TTDeviceUIUtils tt_newPadding:5]);
        SSAvatarView *avatarView = [[SSAvatarView alloc] initWithFrame:CGRectMake(left, 0, [TTDeviceUIUtils tt_newPadding:44], [TTDeviceUIUtils tt_newPadding:44])];
        avatarView.avatarImgPadding = 0;
        avatarView.avatarButton.userInteractionEnabled = NO;
        avatarView.avatarStyle = SSAvatarViewStyleRound;
        [avatarView setupVerifyViewForLength:50.f adaptationSizeBlock:nil];

        UIView *coverView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 44.f, 44.f)];
        coverView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.05];
        coverView.layer.cornerRadius = 44.f / 2;
        coverView.layer.masksToBounds = YES;
        coverView.userInteractionEnabled = NO;
        coverView.layer.borderColor = [SSGetThemedColorWithKey(kColorLine1) CGColor];
        [avatarView addSubview:coverView];

        [self.avatarContainerView addSubview:avatarView];

        FRRecommendUserLargeCardStructModel *recommendUser = recommendUsers[i];

        [avatarView showAvatarByURL:recommendUser.user.info.avatar_url];
        [avatarView showOrHideVerifyViewWithVerifyInfo:recommendUser.user.info.user_auth_info decoratorInfo:recommendUser.user.info.user_decoration sureQueryWithID:YES userID:recommendUser.user.info.user_id];
    }

    self.avatarContainerView.width = [TTDeviceUIUtils tt_newPadding:44] * numberOfAvatars + [TTDeviceUIUtils tt_newPadding:5] * (numberOfAvatars - 1);
    self.avatarContainerView.height = [TTDeviceUIUtils tt_newPadding:44];
}

- (void)showMoreAction:(id)sender {
    if (self.recommendRedpacketData.showMoreJumpURL) {
        NSURL *openURL = [TTStringHelper URLWithURLString:self.recommendRedpacketData.showMoreJumpURL];
        if ([[TTRoute sharedRoute] canOpenURL:openURL]) {
            [[TTRoute sharedRoute] openURLByPushViewController:openURL];
        }
    }

    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setValue:@(self.recommendRedpacketData.numberOfAvatars) forKey:@"head_image_num"];
    [dict setValue:@(self.recommendRedpacketData.hasRedPacket) forKey:@"is_redpacket"];
    [dict setValue:self.recommendRedpacketData.relationTypeValue forKey:@"relation_type"];
    [dict setValue:self.orderedData.categoryID forKey:@"category_name"];
    [dict setValue:@"all_follow_card" forKey:@"source"];
    [dict setValue:@"click" forKey:@"action"];
    [TTTrackerWrapper eventV3:@"follow_more" params:dict];
}

#pragma mark - GET

- (TTRecommendRedpacketAction *)action {
    if (!_action) {
        _action = [[TTRecommendRedpacketAction alloc] init];
    }
    return _action;
}

- (SSThemedView *)avatarContainerView {
    if (!_avatarContainerView) {
        _avatarContainerView = [[SSThemedView alloc] init];
    }
    return _avatarContainerView;
}

- (SSThemedImageView *)redpacketImageView {
    if (!_redpacketImageView) {
        _redpacketImageView = [[SSThemedImageView alloc] init];
        _redpacketImageView.imageName = @"feed_redpacket_double_packeticon";
        _redpacketImageView.enableNightCover = NO;
        _redpacketImageView.hidden = YES;
    }
    return _redpacketImageView;
}

- (SSThemedLabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[SSThemedLabel alloc] init];
        _titleLabel.font = [UIFont boldSystemFontOfSize:17];
        _titleLabel.textColorThemeKey = kColorText1;
        _titleLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _titleLabel;
}

- (SSThemedButton *)moreButton {
    if (!_moreButton) {
        _moreButton = [SSThemedButton buttonWithType:UIButtonTypeCustom];
        _moreButton.imageName = @"feed_redpacket_black_arrow";
        [_moreButton addTarget:self action:@selector(onClickFollowButton:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _moreButton;
}

- (SSThemedButton *)followButton {
    if (!_followButton) {
        _followButton = [[SSThemedButton alloc] init];
        _followButton.titleColorThemeKey = kColorText12;
        _followButton.titleLabel.font = [UIFont systemFontOfSize:14];
        _followButton.titleLabel.textAlignment = NSTextAlignmentCenter;
        _followButton.backgroundColorThemeKey = kColorBackground7;
        _followButton.layer.cornerRadius = 4;
        _followButton.clipsToBounds = YES;
        [_followButton addTarget:self action:@selector(onClickFollowButton:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _followButton;
}

- (TTAlphaThemedButton *)dislikeButton {
    if (!_dislikeButton) {
        _dislikeButton = [[TTAlphaThemedButton alloc] init];
        [_dislikeButton setImage:[UIImage themedImageNamed:@"add_textpage.png"] forState:UIControlStateNormal];

        _dislikeButton.backgroundColor = [UIColor clearColor];
        [_dislikeButton addTarget:self.action action:@selector(dislikeAction:) forControlEvents:UIControlEventTouchUpInside];
    }

    return _dislikeButton;
}

- (SSThemedView *)bottomLineView {
    if (!_bottomLineView) {
        _bottomLineView = [[SSThemedView alloc] init];
        _bottomLineView.backgroundColorThemeKey = kColorLine1;
    }
    return _bottomLineView;
}

- (SSThemedImageView *)backgroundImageView {
    if (!_backgroundImageView) {
        _backgroundImageView = [[SSThemedImageView alloc] init];
        _backgroundImageView.contentMode = UIViewContentModeCenter;
        _backgroundImageView.clipsToBounds = YES;
        _backgroundImageView.imageName = @"feed_redpacket_bg_white_all";
        _backgroundImageView.enableNightCover = NO;
    }
    return _backgroundImageView;
}

- (SSThemedLabel *)showMoreLabel {
    if (!_showMoreLabel) {
        _showMoreLabel = [[SSThemedLabel alloc] init];
        _showMoreLabel.font = [UIFont boldSystemFontOfSize:[TTDeviceUIUtils tt_fontSize:16]];
        _showMoreLabel.textColorThemeKey = kColorText1;
        _showMoreLabel.textAlignment = NSTextAlignmentCenter;
    }

    return _showMoreLabel;
}

- (TTColorAsFollowButton *)showMoreButton {
    if (!_showMoreButton) {
        _showMoreButton = [[TTColorAsFollowButton alloc] init];
        [_showMoreButton setTitle:@"添加更多好友" forState:UIControlStateNormal];
        _showMoreButton.layer.cornerRadius = [TTDeviceUIUtils tt_newPadding:4];
        _showMoreButton.layer.masksToBounds = YES;
        _showMoreButton.enableNightMask = YES;
        _showMoreButton.titleLabel.font = [UIFont systemFontOfSize:[TTDeviceUIUtils tt_fontSize:14]];
        _showMoreButton.titleColorThemeKey = kColorText12;
        _showMoreButton.backgroundColorThemeKey = kColorBackground8;
        [_showMoreButton addTarget:self action:@selector(showMoreAction:) forControlEvents:UIControlEventTouchUpInside];
    }

    return _showMoreButton;
}

@end
