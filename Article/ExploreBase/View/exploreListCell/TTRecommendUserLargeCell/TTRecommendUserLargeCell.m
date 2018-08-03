//
//  TTRecommendUserLargeCell.m
//  Article
//
//  Created by Jiyee Sheng on 7/13/17.
//
//

#import "TTRecommendUserLargeCell.h"
#import "ExploreOrderedData+TTBusiness.h"
#import "RecommendUserLargeCardData.h"
#import "TTUISettingHelper.h"
#import "TTAlphaThemedButton.h"
#import "ExploreMixListDefine.h"
#import "SSImpressionModel.h"
#import "ArticleImpressionHelper.h"
#import "FriendDataManager.h"
#import "TTRoute.h"
#import "TTRecommendUserTableView.h"
#import "TTFollowNotifyServer.h"
#import "TTIndicatorView.h"
#import "TTFeedDislikeView.h"
#import "NetworkUtilities.h"
#import "TTNetworkManager.h"
#import "TTColorAsFollowButton.h"
#import <TTNetworkUtil.h>
#import "ExploreOrderedData+TTAd.h"
#import <TTFollowManager.h>


#define kLeftPadding 15
#define kRightPadding 15
#define kHeaderViewHeight ([TTDeviceUIUtils tt_newPadding:54])
#define kFooterViewHeight ([TTDeviceUIUtils tt_newPadding:66])
#define kDislikeButtonWidth 60
#define kDislikeButtonHeight 44
#define kTableViewCellHeight ([TTDeviceUIUtils tt_newPadding:75])
#define kSubmitButtonWidth 160
#define kSubmitButtonHeight 36
#define kShowMoreTitlePrefix @"你成功关注"

#pragma mark - TTRecommendUserLargeCell

@interface TTRecommendUserLargeCell ()

@property (nonatomic, strong) TTRecommendUserLargeCellView *recommendUserLargeCellView;

@end

@implementation TTRecommendUserLargeCell

+ (Class)cellViewClass {
    return [TTRecommendUserLargeCellView class];
}

- (ExploreCellViewBase *)createCellView {
    if (!_recommendUserLargeCellView) {
        self.recommendUserLargeCellView = [[TTRecommendUserLargeCellView alloc] initWithFrame:self.bounds];
    }

    return _recommendUserLargeCellView;
}

- (void)willDisplay {
    [(TTRecommendUserLargeCellView *)self.cellView willAppear];
}

- (void)didEndDisplaying {
    [(TTRecommendUserLargeCellView *)self.cellView didDisappear];
}

@end

#pragma mark - TTRecommendUserLargeCellView

@interface TTRecommendUserLargeCellView () <TTRecommendUserTableViewDelegate, SSImpressionProtocol>

@property (nonatomic, strong) UIButton *dislikeButton; // 不感兴趣，直接关闭
@property (nonatomic, strong) TTRecommendUserTableView *recommendUserTableView;

@property (nonatomic, strong) ExploreOrderedData *orderedData;
@property (nonatomic, strong) RecommendUserLargeCardData *recommendUserLargeCardData;

@property (nonatomic, strong) SSThemedView *topRect;
@property (nonatomic, strong) SSThemedView *bottomRect;

@property (nonatomic, strong) SSThemedLabel *showMoreLabel; // 操作完成之后展现的 UI
@property (nonatomic, strong) TTColorAsFollowButton *showMoreButton;

@property (nonatomic, assign) BOOL isDisplay; // 卡片可见性

@end

@implementation TTRecommendUserLargeCellView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self addSubview:self.showMoreLabel];
        [self addSubview:self.showMoreButton];
        [self addSubview:self.recommendUserTableView];
        [self addSubview:self.dislikeButton];
    }

    return self;
}

+ (CGFloat)heightForData:(id)data cellWidth:(CGFloat)width listType:(ExploreOrderedDataListType)listType {
    if ([data isKindOfClass:[ExploreOrderedData class]]) {
        ExploreOrderedData *orderedData = (ExploreOrderedData *)data;
        NSUInteger cellViewType = [self cellTypeForCacheHeightFromOrderedData:data];
        CGFloat cacheH = [orderedData cacheHeightForListType:listType cellType:cellViewType];
        if (cacheH > 0) {
            if (cacheH > 0) {
                if ([orderedData nextCellHasTopPadding]){
                    cacheH -= kCellSeprateViewHeight();
                }
                if ([orderedData preCellHasBottomPadding]) {
                    cacheH -= kCellSeprateViewHeight();
                }
                if (cacheH > 0) {
                    return cacheH;
                }
            }
            return 0.f;
        }

        NSUInteger count = orderedData.recommendUserLargeCardData.userCards.count;
        if (count == 0) {
            return 0;
        }

        CGFloat height = 0;

        if (orderedData.recommendUserLargeCardData.state == RecommendUserLargeCardStateUnfollow) {
            height += kHeaderViewHeight;
            height += kTableViewCellHeight * count; // recommendUserTableView 高度
            height += kFooterViewHeight;
        } else if (orderedData.recommendUserLargeCardData.state == RecommendUserLargeCardStateFollowed) {
            height += [TTDeviceUIUtils tt_newPadding:103];
        }

        height += 2 * kCellSeprateViewHeight();

        if (orderedData.cellType == ExploreOrderedDataCellTypeArticle) {
            height += 5;
        }

        height = ceilf(height);

        [orderedData saveCacheHeight:height forListType:listType cellType:cellViewType];

        if (height > 0) {
            if ([orderedData nextCellHasTopPadding]) {
                height -= kCellSeprateViewHeight();
            }
            if ([orderedData preCellHasBottomPadding]) {
                height -= kCellSeprateViewHeight();
            }
            if (height > 0) {
                return height;
            }
        }
    }

    return 0.f;
}

- (NSUInteger)refer {
    return [[self cell] refer];
}

- (id)cellData {
    return self.orderedData;
}

- (BOOL)shouldRefresh {
    if ([[self recommendUserLargeCardData] needRefreshUI]) {
        return [[self recommendUserLargeCardData] needRefreshUI];
    }

    return NO;
}

- (void)refreshDone {
    if ([self recommendUserLargeCardData]) {
        [[self recommendUserLargeCardData] setNeedRefreshUI:YES];
    }
}

- (void)themeChanged:(NSNotification *)notification {
    [super themeChanged:notification];

    self.backgroundColor = [TTUISettingHelper cellViewBackgroundColor];
    [self.dislikeButton setImage:[UIImage themedImageNamed:@"add_textpage.png"] forState:UIControlStateNormal];
}

- (void)refreshUI {
    self.topRect.frame = CGRectMake(0, 0, 0, kCellSeprateViewHeight());
    self.bottomRect.frame = CGRectMake(0, 0, 0, kCellSeprateViewHeight());

    if (self.recommendUserLargeCardData.state == RecommendUserLargeCardStateUnfollow) {
        self.dislikeButton.frame = CGRectMake(self.width - kDislikeButtonWidth, 0, kDislikeButtonWidth, kDislikeButtonHeight);
        self.recommendUserTableView.hidden = NO;
        self.showMoreLabel.hidden = YES;
        self.showMoreButton.hidden = YES;
    } else if (self.recommendUserLargeCardData.state == RecommendUserLargeCardStateFollowed) {
        self.dislikeButton.frame = CGRectMake(self.width - kDislikeButtonWidth, 0, kDislikeButtonWidth, kDislikeButtonHeight);
        self.recommendUserTableView.hidden = YES;
        self.showMoreLabel.hidden = NO;
        self.showMoreButton.hidden = NO;
    }

    self.recommendUserTableView.frame = CGRectMake(0, 0, self.width, kHeaderViewHeight + kTableViewCellHeight * self.recommendUserLargeCardData.userCards.count + kFooterViewHeight);
    self.showMoreLabel.frame = CGRectMake(kDislikeButtonWidth, [TTDeviceUIUtils tt_newPadding:13], self.width - kDislikeButtonWidth * 2, [TTDeviceUIUtils tt_newPadding:24]);
    self.showMoreButton.frame = CGRectMake((self.width - kSubmitButtonWidth) / 2, [TTDeviceUIUtils tt_newPadding:50], kSubmitButtonWidth, kSubmitButtonHeight);

    if ([self.orderedData preCellHasBottomPadding]) {
        CGRect bounds = self.bounds;
        bounds.origin.y = 0;
        self.bounds = bounds;
        self.topRect.hidden = YES;
    } else {
        CGRect bounds = self.bounds;
        bounds.origin.y = - kCellSeprateViewHeight();
        self.bounds = bounds;
        self.topRect.bottom = 0;
        self.topRect.width = self.width;
        self.topRect.hidden = NO;
    }

    if (!([self.orderedData nextCellHasTopPadding])) {
        self.bottomRect.bottom = self.height + self.bounds.origin.y;
        self.bottomRect.width = self.width;
        self.bottomRect.hidden = NO;
    } else {
        self.bottomRect.hidden = YES;
    }
}

- (void)refreshWithData:(id)data {
    if ([data isKindOfClass:[ExploreOrderedData class]]) {
        self.orderedData = data;
    } else {
        self.orderedData = nil;
        return;
    }

    if ([self.orderedData.originalData isKindOfClass:[RecommendUserLargeCardData class]]) {
        self.recommendUserLargeCardData = (RecommendUserLargeCardData *)self.orderedData.originalData;
    } else {
        self.recommendUserLargeCardData = nil;
        return;
    }

    if ([self.orderedData.categoryID isEqualToString:kTTWeitoutiaoCategoryID]) {
        self.recommendUserTableView.followSource = TTFollowNewSourceRecommendUserLargeCardWeitoutiaoCategory;
    } else if ([self.orderedData.categoryID isEqualToString:kTTMainCategoryID]) {
        self.recommendUserTableView.followSource = TTFollowNewSourceRecommendUserLargeCardMainFeed;
    } else if ([self.orderedData.categoryID isEqualToString:kTTFollowCategoryID]) {
        self.recommendUserTableView.followSource = TTFollowNewSourceRecommendUserLargeCardFollowCategory;
    } else {
        self.recommendUserTableView.followSource = TTFollowNewSourceRecommendUserLargeCardOtherCategory;
    }

    self.showMoreLabel.attributedText = self.showMoreTitleAttributedString;
    [self.showMoreButton setTitle:self.recommendUserLargeCardData.showMoreText forState:UIControlStateNormal];

    [self.recommendUserTableView configTitle:self.recommendUserLargeCardData.title];
    [self.recommendUserTableView configUserModels:self.recommendUserLargeCardData.userCardModels];
}

- (void)trackWithEvent:(NSString *)event extraDic:(NSDictionary *)extraDic {
    if (isEmptyString(event)) {
        return;
    }

    NSMutableDictionary *dict = [@{
        @"category_name": self.orderedData.categoryID ?: @"",
        @"recommend_type": @(self.recommendUserLargeCardData.groupRecommendType) ?: @0,
    } mutableCopy];

    if (extraDic) {
        [dict addEntriesFromDictionary:extraDic];
    }

    [TTTrackerWrapper eventV3:event params:dict];
}

- (void)willAppear {
    [super willAppear];

    _isDisplay = YES;

    [[SSImpressionManager shareInstance] enterRecommendUserListWithCategoryName:self.orderedData.categoryID cellId:self.orderedData.uniqueID];

    [self needRerecordImpressions]; // 手动调用 record 方法，记录 impr

    [[SSImpressionManager shareInstance] addRegist:self];
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
    if (self.recommendUserLargeCardData.userCardModels.count == 0) {
        return;
    }
    
    NSMutableString * userRecommendMultipleImpressionEvents = [NSMutableString string];
    for (FRRecommendUserLargeCardStructModel *userModel in self.recommendUserLargeCardData.userCardModels) {
        if (!isEmptyString(userModel.stats_place_holder)) {
            if (isEmptyString(userRecommendMultipleImpressionEvents)) {
                [userRecommendMultipleImpressionEvents appendString:userModel.stats_place_holder];
            }else {
                [userRecommendMultipleImpressionEvents appendFormat:@",%@",userModel.stats_place_holder];
            }
        }
    }
    
    if (!isEmptyString(userRecommendMultipleImpressionEvents)) {
        [userRecommendMultipleImpressionEvents insertString:@"user_recommend_multiple_impression_events:"
                                                    atIndex:0];
    }

    for (FRRecommendUserLargeCardStructModel *userModel in self.recommendUserLargeCardData.userCardModels) {
        NSMutableDictionary * extra = @{}.mutableCopy;
        [extra setValue:self.orderedData.categoryID ?: @""
                 forKey:@"category_name"];
        if (!isEmptyString(userRecommendMultipleImpressionEvents)) {
            [extra setValue:userRecommendMultipleImpressionEvents
                     forKey:@"user_recommend_multiple_impression_events"];
        }
        if ([userModel isKindOfClass:[FRRecommendUserLargeCardStructModel class]]) {
            [[SSImpressionManager shareInstance] recordRecommendUserListImpressionUserID:userModel.user.info.user_id
                                                                            categoryName:self.orderedData.categoryID
                                                                                  cellId:self.orderedData.uniqueID
                                                                                  status:_isDisplay ? SSImpressionStatusRecording : SSImpressionStatusSuspend
                                                                                   extra:extra.copy];
        }
    }
}

- (NSString *)trackSource {
    return self.orderedData.categoryID;
}

- (void)onCardEmpty {

}

- (void)didSelectWithContext:(TTFeedCellSelectContext *)context {
    // 关注之后, 全卡片可点
    if (self.recommendUserLargeCardData.state == RecommendUserLargeCardStateFollowed) {
        [self showMoreAction:nil];
    }
}

#pragma mark TTFeedDislikeView

- (void)exploreDislikeViewOKBtnClicked:(TTFeedDislikeView *)view {
    if (!self.orderedData) {
        return;
    }

    NSArray *filterWords = [view selectedWords];
    NSMutableDictionary *userInfo = @{}.mutableCopy;
    [userInfo setValue:self.orderedData forKey:kExploreMixListNotInterestItemKey];
    if (filterWords.count > 0) {
        userInfo[kExploreMixListNotInterestWordsKey] = filterWords;
    }

    [[NSNotificationCenter defaultCenter] postNotificationName:kExploreMixListNotInterestNotification object:self userInfo:userInfo];
}

#pragma mark - TTRecommendUserTableViewDelegate

- (void)didChangeSelected:(FRRecommendUserLargeCardStructModel *)userModel atIndex:(NSInteger)index {
    BOOL selected = userModel.selected.boolValue;

    [self.recommendUserLargeCardData setSelected:selected atIndex:index];

    [self trackWithEvent:@"vert_follow_card" extraDic:@{
        @"action_type": selected ? @"select" : @"unselect",
        @"order": @(index),
        @"user_id": userModel.user.info.user_id ?: @""
    }];
}

- (void)didClickAvatarView:(FRRecommendUserLargeCardStructModel *)userModel atIndex:(NSInteger)index {
    NSString *schema = [TTUGCTrackerHelper schemaTrackForPersonalHomeSchema:userModel.user.info.schema categoryName:self.orderedData.categoryID fromPage:@"list_follow_card_vertical" groupId:nil profileUserId:nil];
    if (!isEmptyString(schema)) {
        [[TTRoute sharedRoute] openURLByPushViewController:[TTNetworkUtil URLWithURLString:schema]];
    }

    [self trackWithEvent:@"vert_follow_card" extraDic:@{
        @"action_type": @"click_avatar",
        @"user_id": userModel.user.info.user_id ?: @""
    }];
}

- (void)submitMultiFollowRecommendUsersWithRecommendUserLargeCards:(NSArray<FRRecommendUserLargeCardStructModel *> *)recommendUserLargeCards {
    NSMutableArray *userIds = [[NSMutableArray alloc] init];
    for (FRRecommendUserLargeCardStructModel * cardModel in recommendUserLargeCards) {
        if (cardModel.user.info.user_id) {
            [userIds addObject:cardModel.user.info.user_id];
        }
    }

    NSString *to_user_list = [userIds componentsJoinedByString:@","];

    NSMutableDictionary *extraDic = @{}.mutableCopy;
    [extraDic setValue:to_user_list ?: @"" forKey:@"to_user_id_list"];
    [extraDic setValue:@"from_recommend" forKey:@"follow_type"];
    [extraDic setValue:@(userIds.count) ?: @0 forKey:@"follow_num"];
    [extraDic setValue:@"list_follow_card_vertical" forKey:@"source"];
    [extraDic setValue:self.orderedData.logPb ?: @"" forKey:@"log_pb"];
    [extraDic setValue:@(self.recommendUserTableView.followSource) forKey:@"server_source"];
    NSMutableArray *followUsers = @[].mutableCopy;
    NSMutableString *userRecommendMultiFollowEvents = [NSMutableString string];
    [recommendUserLargeCards enumerateObjectsUsingBlock:^(FRRecommendUserLargeCardStructModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (!isEmptyString(obj.stats_place_holder)) {
            if (isEmptyString(userRecommendMultiFollowEvents)) {
                [userRecommendMultiFollowEvents appendString:obj.stats_place_holder];
            }else {
                [userRecommendMultiFollowEvents appendFormat:@",%@", obj.stats_place_holder];
            }
        }
        if (obj.user) {
            [followUsers addObject:obj.user];
        }
    }];
    if (!isEmptyString(userRecommendMultiFollowEvents)) {
        [userRecommendMultiFollowEvents insertString:@"user_recommend_multi_follow_events:" atIndex:0];
        [extraDic setValue:userRecommendMultiFollowEvents.copy forKey:@"user_recommend_multi_follow_events"];
    }
    [self trackWithEvent:@"follow" extraDic:extraDic.copy];
    
    [self trackWithEvent:@"rt_follow" extraDic:extraDic.copy];

    if (recommendUserLargeCards.count == 0) {
        [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:@"至少关注1人" indicatorImage:nil autoDismiss:YES dismissHandler:nil];
        return;
    }

    if (!TTNetworkConnected()) {
        [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:NSLocalizedString(@"没有网络连接", nil) indicatorImage:[UIImage themedImageNamed:@"close_popup_textpage.png"] autoDismiss:YES dismissHandler:nil];
        return;
    }

    // 增加动画, loading 状态不用维持
    [self.recommendUserTableView startFollowButtonAnimation];

    
    [[TTFollowManager sharedManager] multiFollowUserIdArray:userIds source:self.recommendUserTableView.followSource reason:0 completion:^(NSError *error, NSObject<TTResponseModelProtocol> *responseModel, FRForumMonitorModel *monitorModel) {
        [self.recommendUserTableView stopFollowButtonAnimation];
        
        if (error) {
            [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:kNetworkConnectionErrorTipMessage indicatorImage:nil autoDismiss:YES dismissHandler:nil];
            return;
        }
        
        FRUserRelationMfollowResponseModel *model = (FRUserRelationMfollowResponseModel *)responseModel;
        
        if (model.err_no.integerValue == 0) {
            [self multiFollowRecommendUsersCompleted:followUsers.copy];
            
            NSString *followID = userIds.firstObject;
            if (isEmptyString(followID)) {
                followID = kFollowRefreshID;
            }
            [[TTFollowNotifyServer sharedServer] postFollowNotifyWithID:followID actionType:TTFollowActionTypeFollow itemType:TTFollowItemTypeDefault userInfo:nil];
        }
    }];
}

- (void)multiFollowRecommendUsersCompleted:(NSArray *)followUsers {
    [self.recommendUserLargeCardData setCardState:RecommendUserLargeCardStateFollowed];

    NSMutableArray *followUserNames = [[NSMutableArray alloc] init];
    for (FRCommonUserStructModel *userModel in followUsers) {
        if (userModel.info.name) {
            [followUserNames addObject:userModel.info.name];
        }
    }

    NSString *showMoreTitle = [NSString stringWithFormat:@"%@ %@ ", kShowMoreTitlePrefix, [followUserNames componentsJoinedByString:@"、"]];
    if (followUsers.count > 2) { // 超过 2 人附加 `等x人`
        showMoreTitle = [showMoreTitle stringByAppendingFormat:@"等%lu人", followUserNames.count];
    }

    [self.recommendUserLargeCardData setFollowedTitle:showMoreTitle];

    self.showMoreLabel.attributedText = self.showMoreTitleAttributedString;
    [self.showMoreButton setTitle:self.recommendUserLargeCardData.showMoreText forState:UIControlStateNormal];

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

        self.recommendUserTableView.alpha = 0;
    }                completion:^(BOOL finished) {
        self.backgroundColor = [TTUISettingHelper cellViewBackgroundColor];

        self.dislikeButton.frame = CGRectMake(self.width - kDislikeButtonWidth, 0, kDislikeButtonWidth, kDislikeButtonHeight);
        self.recommendUserTableView.alpha = 1;
        self.recommendUserTableView.hidden = YES;
        self.showMoreLabel.hidden = NO;
        self.showMoreButton.hidden = NO;
    }];

    [self trackWithEvent:@"follow_more" extraDic:@{
        @"action_type": @"show",
        @"source": @"list_follow_card_vertical"
    }];
}

- (NSAttributedString *)showMoreTitleAttributedString {
    NSString *showMoreTitle = self.recommendUserLargeCardData.showMoreTitle;
    if (isEmptyString(showMoreTitle)) {
        return nil;
    }

    NSString *ellipsis = @"...";
    NSString *anchorString = @" 等"; // 你成功关注 111、222、333 等3人

    // 按加粗字体简化计算
    NSDictionary *attributes = @{
        NSFontAttributeName: [UIFont boldSystemFontOfSize:[TTDeviceUIUtils tt_fontSize:16]]
    };
    NSMutableString *truncatedString = [showMoreTitle mutableCopy];
    CGFloat constraintsWidth = self.showMoreLabel.width;
    BOOL lessThanThreeUsers = NO;

    // 如果未找到 等x人字样，加粗处理从最后一个字符开始
    NSRange range = [truncatedString rangeOfString:anchorString options:NSBackwardsSearch];
    if (range.location == NSNotFound) {
        lessThanThreeUsers = YES;
        range = NSMakeRange(truncatedString.length, 0);
    }

    // 执行截断操作
    // 如果尺寸符合要求，或者不包含 等x人字样，不执行截断操作
    if ([truncatedString sizeWithAttributes:attributes].width > constraintsWidth) {
        // 首先，对超过 3 用户名裁剪
        if (!lessThanThreeUsers) {
            NSInteger location = range.location;
            while ([truncatedString sizeWithAttributes:attributes].width > constraintsWidth) {
                NSRange pauseMarkRange = [truncatedString rangeOfString:@"、" options:NSBackwardsSearch];
                if (pauseMarkRange.location == NSNotFound) { // 至少保留 1 个用户名，走 ... 裁剪逻辑
                    break;
                } else {
                    [truncatedString deleteCharactersInRange:NSMakeRange(pauseMarkRange.location, location - pauseMarkRange.location)];
                    location = pauseMarkRange.location;
                }
            }

            range = [truncatedString rangeOfString:anchorString options:NSBackwardsSearch];
        }

        if ([truncatedString sizeWithAttributes:attributes].width > constraintsWidth) {
            // 扣除 ellipsis 宽度，这部分之后会加回来
            constraintsWidth -= [ellipsis sizeWithAttributes:attributes].width;

            // 单字符方式从后往前删除
            range.length = 1;

            while ([truncatedString sizeWithAttributes:attributes].width > constraintsWidth && range.location > 0) {
                range.location -= 1;
                [truncatedString deleteCharactersInRange:range];
            }

            // 保证不出现 "、..." 情况
            if (range.location > 0) {
                NSRange charRange = NSMakeRange(range.location - 1, 1);
                if ([[truncatedString substringWithRange:charRange] isEqualToString:@"、"]) {
                    range.location -= 1;
                    [truncatedString deleteCharactersInRange:charRange];
                }
            }

            // 添加 ellipsis
            range.length = 0;
            [truncatedString replaceCharactersInRange:range withString:ellipsis];
        }
    }

    NSMutableAttributedString *showMoreAttributedText = [[NSMutableAttributedString alloc] initWithString:truncatedString];

    range = [truncatedString rangeOfString:anchorString options:NSBackwardsSearch];
    // 如果未找到 等x人字样，加粗处理从最后一个字符开始
    if (range.location == NSNotFound) {
        range = NSMakeRange(truncatedString.length, 0);
    }
    if (range.location != NSNotFound && range.location > kShowMoreTitlePrefix.length) {
        [showMoreAttributedText addAttributes:@{
            NSFontAttributeName : [UIFont boldSystemFontOfSize:[TTDeviceUIUtils tt_fontSize:16]]
        } range:NSMakeRange(kShowMoreTitlePrefix.length, range.location - kShowMoreTitlePrefix.length)];
    }

    return [showMoreAttributedText copy];
}

#pragma mark - action

- (void)dislikeAction:(UIView *)sender {
    if (!self.orderedData) {
        return;
    }

    [TTFeedDislikeView dismissIfVisible];

    TTFeedDislikeView *dislikeView = [[TTFeedDislikeView alloc] init];
    TTFeedDislikeViewModel *viewModel = [[TTFeedDislikeViewModel alloc] init];
    viewModel.keywords = nil;
    viewModel.groupID = [NSString stringWithFormat:@"%lld", self.orderedData.recommendUserLargeCardData.uniqueID];
    viewModel.logExtra = self.orderedData.log_extra;
    [dislikeView refreshWithModel:viewModel];
    CGPoint point = sender.center;
    [dislikeView showAtPoint:point
                    fromView:sender
             didDislikeBlock:^(TTFeedDislikeView * _Nonnull view) {
                 [self exploreDislikeViewOKBtnClicked:view];
             }];

    if (self.orderedData.recommendUserLargeCardData.state == RecommendUserLargeCardStateUnfollow) {
        [self trackWithEvent:@"vert_follow_card" extraDic:@{
            @"action_type": @"close"
        }];
    } else if (self.orderedData.recommendUserLargeCardData.state == RecommendUserLargeCardStateFollowed) {
        [self trackWithEvent:@"follow_more" extraDic:@{
            @"action_type": @"close",
            @"source": @"list_follow_card_vertical"
        }];
    }
}

- (void)showMoreAction:(id)sender {
    if (self.recommendUserLargeCardData.showMoreJumpURL) {
        NSURL *openURL = [TTStringHelper URLWithURLString:self.recommendUserLargeCardData.showMoreJumpURL];
        if ([[TTRoute sharedRoute] canOpenURL:openURL]) {
            [[TTRoute sharedRoute] openURLByPushViewController:openURL];
        }
    }

    [self trackWithEvent:@"follow_more" extraDic:@{
        @"action_type": @"click",
        @"source": @"list_follow_card_vertical"
    }];
}

#pragma mark - getter and setter

/** 顶部分割面 */
- (SSThemedView *)topRect {
    if (_topRect == nil) {
        _topRect = [[SSThemedView alloc] init];
        _topRect.backgroundColorThemeKey = kColorBackground3;
        [self addSubview:_topRect];
    }

    return _topRect;
}

/** 底部分割线 */
- (SSThemedView *)bottomRect {
    if (_bottomRect == nil) {
        _bottomRect = [[SSThemedView alloc] init];
        _bottomRect.backgroundColorThemeKey = kColorBackground3;
        [self addSubview:_bottomRect];
    }

    return _bottomRect;
}

- (TTRecommendUserTableView *)recommendUserTableView {
    if (!_recommendUserTableView) {
        _recommendUserTableView = [[TTRecommendUserTableView alloc] init];
        _recommendUserTableView.delegate = self;
    }

    return _recommendUserTableView;
}

- (UIButton *)dislikeButton {
    if (self.listType == ExploreOrderedDataListTypeFavorite ||
        self.listType == ExploreOrderedDataListTypeReadHistory ||
        self.listType == ExploreOrderedDataListTypePushHistory ||
        (self.orderedData.showDislike && ![self.orderedData.showDislike boolValue])) {
        if (_dislikeButton) {
            [_dislikeButton removeFromSuperview];
            _dislikeButton = nil;
        }
        return nil;
    }

    if (!_dislikeButton) {
        _dislikeButton = [[TTAlphaThemedButton alloc] initWithFrame:CGRectMake(self.width - kDislikeButtonWidth, 0, kDislikeButtonWidth, kDislikeButtonHeight)];
        [_dislikeButton setImageEdgeInsets:UIEdgeInsetsMake(0, 10, 0, 0)];
        [_dislikeButton setImage:[UIImage themedImageNamed:@"add_textpage.png"] forState:UIControlStateNormal];

        _dislikeButton.backgroundColor = [UIColor clearColor];
        [_dislikeButton addTarget:self action:@selector(dislikeAction:) forControlEvents:UIControlEventTouchUpInside];
    }

    return _dislikeButton;
}

- (SSThemedLabel *)showMoreLabel {
    if (!_showMoreLabel) {
        _showMoreLabel = [[SSThemedLabel alloc] initWithFrame:CGRectMake(30, [TTDeviceUIUtils tt_newPadding:15], self.width - kDislikeButtonWidth * 2, [TTDeviceUIUtils tt_newPadding:22])];
        _showMoreLabel.font = [UIFont systemFontOfSize:[TTDeviceUIUtils tt_fontSize:16]];
        _showMoreLabel.textColorThemeKey = kColorText1;
        _showMoreLabel.textAlignment = NSTextAlignmentCenter;
    }

    return _showMoreLabel;
}

- (TTColorAsFollowButton *)showMoreButton {
    if (!_showMoreButton) {
        _showMoreButton = [[TTColorAsFollowButton alloc] initWithFrame:CGRectMake((self.width - [TTDeviceUIUtils tt_newPadding:160]) / 2, [TTDeviceUIUtils tt_newPadding:52], [TTDeviceUIUtils tt_newPadding:160], [TTDeviceUIUtils tt_newPadding:36])];
        [_showMoreButton setTitle:@"查看通讯录好友" forState:UIControlStateNormal];
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

