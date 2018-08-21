//
//  TTMomentsRecommendUserCell.m
//  Article
//
//  Created by Jiyee Sheng on 15/08/2017.
//
//

#import <TTThemed/UIImage+TTThemeExtension.h>
#import "ExploreCellViewBase.h"
#import "TTMomentsRecommendUserCell.h"
#import "TTFeedDislikeView.h"
#import "SSImpressionProtocol.h"
#import "ExploreOrderedData+TTBusiness.h"
#import "MomentsRecommendUserData.h"
#import "TTUISettingHelper.h"
#import "SSImpressionManager.h"
#import "ExploreMixListDefine.h"
#import "TTRoute.h"
#import "TTAlphaThemedButton.h"
#import "TTMomentsRecommendUserTableView.h"
#import "TTIndicatorView.h"
#import "NetworkUtilities.h"
#import "ExploreEntryManager.h"
#import "TTFollowNotifyServer.h"
#import <TTNetworkUtil.h>
#import "ExploreOrderedData+TTAd.h"

#define kLeftPadding 15
#define kRightPadding 15
#define kHeaderViewHeight ([TTDeviceUIUtils tt_newPadding:56])
#define kDislikeButtonWidth 60
#define kDislikeButtonHeight 44
#define kTableViewCellHeight ([TTDeviceUIUtils tt_newPadding:97])

#pragma mark - TTMomentsRecommendUserCell

@interface TTMomentsRecommendUserCell ()

@property (nonatomic, strong) TTMomentsRecommendUserCellView *momentsRecommendUserCellView;

@end

@implementation TTMomentsRecommendUserCell

+ (Class)cellViewClass {
    return [TTMomentsRecommendUserCellView class];
}

- (ExploreCellViewBase *)createCellView {
    if (!_momentsRecommendUserCellView) {
        self.momentsRecommendUserCellView = [[TTMomentsRecommendUserCellView alloc] initWithFrame:self.bounds];
    }
    
    return _momentsRecommendUserCellView;
}

- (void)willDisplay {
    [(TTMomentsRecommendUserCellView *)self.cellView willAppear];
}

- (void)didEndDisplaying {
    [(TTMomentsRecommendUserCellView *)self.cellView didDisappear];
}

@end

#pragma mark - TTMomentsRecommendUserCellView

@interface TTMomentsRecommendUserCellView () <TTMomentsRecommendUserTableViewDelegate,SSImpressionProtocol>

@property (nonatomic, strong) UIButton *dislikeButton; // 不感兴趣，直接关闭
@property (nonatomic, strong) TTMomentsRecommendUserTableView *momentsRecommendUserTableView;

@property (nonatomic, strong) ExploreOrderedData *orderedData;
@property (nonatomic, strong) MomentsRecommendUserData *momentsRecommendUserData;

@property (nonatomic, strong) SSThemedView *topRect;
@property (nonatomic, strong) SSThemedView *bottomRect;

@property (nonatomic, assign) BOOL isDisplay; // 卡片可见性

@end

@implementation TTMomentsRecommendUserCellView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self addSubview:self.momentsRecommendUserTableView];
        [self addSubview:self.dislikeButton];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshFollowState:) name:kEntrySubscribeStatusChangedNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshFollowState:) name:RelationActionSuccessNotification object:nil];
    }
    
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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
        
        NSUInteger count = orderedData.momentsRecommendUserData.follows.count;
        if (count == 0) {
            return 0;
        }
        
        CGFloat height = 0;
        
        height += kHeaderViewHeight;
        height += kTableViewCellHeight * count;
        
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
    if ([[self momentsRecommendUserData] needRefreshUI]) {
        return [[self momentsRecommendUserData] needRefreshUI];
    }
    
    return NO;
}

- (void)refreshDone {
    if ([self momentsRecommendUserData]) {
        [[self momentsRecommendUserData] setNeedRefreshUI:YES];
    }
}

- (void)refreshFollowState:(NSNotification *)notification {
    NSDictionary *userInfo = [notification userInfo];
    ExploreEntry *entry = [userInfo objectForKey:kEntrySubscribeStatusChangedNotificationUserInfoEntryKey];
    NSString *uid = [userInfo stringValueForKey:kRelationActionSuccessNotificationUserIDKey defaultValue:@""];
    NSNumber *type = [userInfo tt_objectForKey:kRelationActionSuccessNotificationActionTypeKey];
    BOOL isFollowing = type.unsignedIntegerValue == FriendActionTypeFollow;
    
    NSInteger index = -1;
    for (NSUInteger i = 0; i < self.momentsRecommendUserData.userCardModels.count; ++i) {
        FRMomentsRecommendUserStructModel *userModel = self.momentsRecommendUserData.userCardModels[i];
        
        if (!entry || [entry.mediaID longLongValue] == 0) {
            if ([uid isEqualToString:userModel.user.info.user_id]) {
                if (userModel.user.relation.is_following.boolValue != isFollowing) {
                    index = i;
                    break;
                }
            }
        } else {
            if ([[entry.mediaID stringValue] isEqualToString:userModel.user.info.user_id]) {
                if (userModel.user.relation.is_following.boolValue != entry.subscribed.boolValue) {
                    index = i;
                    break;
                }
            }
        }
    }
    
    if (index > -1) {
        [self.momentsRecommendUserData setFollowing:isFollowing atIndex:index];
        [self.momentsRecommendUserTableView configUserModels:self.momentsRecommendUserData.userCardModels];
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
    
    self.dislikeButton.frame = CGRectMake(self.width - kDislikeButtonWidth, (kHeaderViewHeight - kDislikeButtonHeight) / 2, kDislikeButtonWidth, kDislikeButtonHeight);
    self.momentsRecommendUserTableView.frame = CGRectMake(0, 0, self.width, kHeaderViewHeight + kTableViewCellHeight * self.momentsRecommendUserData.follows.count);
    
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
        // 切换频道数据更新之后清空卡片高度缓存
        if (self.orderedData) {
            [self.orderedData clearCacheHeight];
        }
        
        self.orderedData = data;
    } else {
        self.orderedData = nil;
        return;
    }
    
    if ([self.orderedData.originalData isKindOfClass:[MomentsRecommendUserData class]]) {
        self.momentsRecommendUserData = (MomentsRecommendUserData *)self.orderedData.originalData;
    } else {
        self.momentsRecommendUserData = nil;
        return;
    }
    
    if ([self.orderedData.categoryID isEqualToString:kTTMainCategoryID]) {
        self.momentsRecommendUserTableView.followSource = TTFollowNewSourceMomentsRecommendUserMainCategory;
    } else if ([self.orderedData.categoryID isEqualToString:kTTFollowCategoryID]) {
        self.momentsRecommendUserTableView.followSource = TTFollowNewSourceMomentsRecommendUserFollowCategory;
    } else {
        self.momentsRecommendUserTableView.followSource = TTFollowNewSourceMomentsRecommendUserOtherCategory;
    }
    
    [self.momentsRecommendUserTableView configTitle:self.momentsRecommendUserData.title
                                    friendUserModel:self.momentsRecommendUserData.friendUserModel];
    [self.momentsRecommendUserTableView configUserModels:self.momentsRecommendUserData.userCardModels];
}

- (void)trackWithEvent:(NSString *)event extraDic:(NSDictionary *)extraDic {
    if (isEmptyString(event)) {
        return;
    }
    
    NSMutableDictionary *dict = [@{
                                   @"category_name": self.orderedData.categoryID ?: @"",
                                   } mutableCopy];
    
    if (extraDic) {
        [dict addEntriesFromDictionary:extraDic];
    }
    
    [TTTrackerWrapper eventV3:event params:dict];
}

- (void)willAppear {
    [super willAppear];
    
    _isDisplay = YES;
    
    [[SSImpressionManager shareInstance] enterMomentsRecommendUserListWithCategoryName:self.orderedData.categoryID cellId:self.orderedData.uniqueID];
    
    [self needRerecordImpressions]; // 手动调用 record 方法，记录 impr
    
    [[SSImpressionManager shareInstance] addRegist:self];
}

- (void)didDisappear {
    [super didDisappear];
    
    _isDisplay = NO;
    
    [[SSImpressionManager shareInstance] leaveMomentsRecommendUserListWithCategoryName:self.orderedData.categoryID cellId:self.orderedData.uniqueID];
}

/**
 * 此回调方法会在从后台恢复的时候被调用
 **/
- (void)needRerecordImpressions {
    if (self.momentsRecommendUserData.userCardModels.count == 0) {
        return;
    }
    
    NSMutableArray *stats = [[NSMutableArray alloc] init];
    for (FRMomentsRecommendUserStructModel *userModel in self.momentsRecommendUserData.userCardModels) {
        if (!isEmptyString(userModel.stats_place_holder)) {
            [stats addObject:userModel.stats_place_holder];
        }
    }
    
    NSString *impr_events = [@"user_recommend_multiple_impression_events:" stringByAppendingString:[stats componentsJoinedByString:@","]];
    
    for (FRMomentsRecommendUserStructModel *userModel in self.momentsRecommendUserData.userCardModels) {
        if ([userModel isKindOfClass:[FRMomentsRecommendUserStructModel class]]) {
            [[SSImpressionManager shareInstance] recordMomentsRecommendUserListImpressionUserID:userModel.user.info.user_id
                                                                                   categoryName:self.orderedData.categoryID
                                                                                         cellId:self.orderedData.uniqueID
                                                                                         status:_isDisplay ? SSImpressionStatusRecording : SSImpressionStatusSuspend
                                                                                          extra:@{
                                                                                                  @"category_name" : self.orderedData.categoryID ?: @"",
                                                                                                  @"user_recommend_multiple_impression_events" : impr_events ?: @""
                                                                                                  }];
        }
    }
}

- (NSString *)trackSource {
    return self.orderedData.categoryID;
}

- (void)onCardEmpty {
    
}

- (void)didSelectWithContext:(TTFeedCellSelectContext *)context {
    
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

- (void)didClickAvatarView:(FRMomentsRecommendUserStructModel *)userModel atIndex:(NSInteger)index {
    NSString *schema = [TTUGCTrackerHelper schemaTrackForPersonalHomeSchema:userModel.user.info.schema categoryName:self.orderedData.categoryID fromPage:index > -1 ? @"list_subscriber_behavior_card_subv" : @"list_subscriber_behavior_card_host" groupId:nil profileUserId:self.momentsRecommendUserData.friendUserModel.info.user_id];
    if (!isEmptyString(schema)) {
        [[TTRoute sharedRoute] openURLByPushViewController:[TTNetworkUtil URLWithURLString:schema]];
    }
}

- (void)didChangeFollowing:(FRMomentsRecommendUserStructModel *)userModel atIndex:(NSInteger)index {
    if (!TTNetworkConnected()) {
        [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:@"网络不给力，请稍后重试" indicatorImage:[UIImage themedImageNamed:@"close_popup_textpage"] autoDismiss:YES dismissHandler:nil];
        return;
    }
    
    [self.momentsRecommendUserTableView startFollowLoadingAtIndex:index];
    
    FriendDataManager *dataManager = [FriendDataManager sharedManager];
    FriendActionType actionType;
    NSString *event = nil;
    if (userModel.user.relation.is_following.boolValue) {
        actionType = FriendActionTypeUnfollow;
        event = @"rt_unfollow";
    } else {
        actionType = FriendActionTypeFollow;
        event = @"rt_follow";
    }
    
    TTFollowNewSource follow_source = self.momentsRecommendUserTableView.followSource;
    
    
    NSMutableDictionary *extraDict = [NSMutableDictionary dictionary];
    [extraDict setValue:userModel.user.info.user_id forKey:@"to_user_id"];
    [extraDict setValue:self.momentsRecommendUserData.friendUserModel.info.user_id forKey:@"profile_user_id"];
    //    media_id: 头条号作者id（是头条号页面就传，不是不用传）
    //    [extraDict setValue: forKey:@"media_id"];
    [extraDict setValue:@"others" forKey:@"follow_type"];
    [extraDict setValue:@"list_subscriber_behavior_card" forKey:@"source"];
    if (userModel.user.relation.is_following.boolValue) {
        NSString *follow_events = [@"user_recommend_unfollow_event:" stringByAppendingString:userModel.stats_place_holder];
        [extraDict setValue:follow_events forKey:@"user_recommend_unfollow_event"];
    } else {
        NSString *follow_events = [@"user_recommend_follow_event:" stringByAppendingString:userModel.stats_place_holder];
        [extraDict setValue:follow_events forKey:@"user_recommend_follow_event"];
    }
    [extraDict setValue:@(follow_source) forKey:@"server_source"];
    [extraDict setValue:userModel.recommend_type forKey:@"recommend_type"];
    [extraDict setValue:self.orderedData.logPb forKey:@"log_pb"];
    
    [self trackWithEvent:event extraDic:extraDict]; //该埋点一定要不删除，外部delegate使用@"follow"和 @"unfollow"字段判断follow的打点时机！
    
    WeakSelf;
    [[TTFollowManager sharedManager] startFollowAction:actionType
                                             userID:userModel.user.info.user_id
                                           platform:nil
                                               name:nil
                                               from:nil
                                             reason:nil
                                          newReason:userModel.recommend_type ?: @0
                                          newSource:@(follow_source)
                                         completion:^(FriendActionType type, NSError * _Nullable error, NSDictionary * _Nullable result) {
                                             StrongSelf;
                                             if (!error) {
                                                 NSDictionary *response = [result tt_dictionaryValueForKey:@"result"];
                                                 NSDictionary *data = [response tt_dictionaryValueForKey:@"data"];
                                                 NSDictionary *user = [data tt_dictionaryValueForKey:@"user"];
                                                 BOOL isFollowing = [user tt_boolValueForKey:@"is_following"];
                                                 NSString *followId = [user tt_stringValueForKey:@"user_id"];
                                                 
                                                 [self.momentsRecommendUserData setFollowing:isFollowing atIndex:index];
                                                 userModel.user.relation.is_following = @(isFollowing);
                                                 
                                                 [[TTFollowNotifyServer sharedServer] postFollowNotifyWithID:followId actionType:TTFollowActionTypeFollow itemType:TTFollowItemTypeDefault userInfo:nil];
                                             }
                                             
                                             [self.momentsRecommendUserTableView stopFollowLoadingAtIndex:index];
                                         }];
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
    viewModel.groupID = [NSString stringWithFormat:@"%lld", self.orderedData.momentsRecommendUserData.uniqueID];
    viewModel.logExtra = self.orderedData.log_extra;
    [dislikeView refreshWithModel:viewModel];
    CGPoint point = sender.center;
    [dislikeView showAtPoint:point
                    fromView:sender
             didDislikeBlock:^(TTFeedDislikeView * _Nonnull view) {
                 [self exploreDislikeViewOKBtnClicked:view];
             }];
    
    
    [self trackWithEvent:@"rt_dislike" extraDic:@{
                                                  @"source": @"list_subscriber_behavior_card",
                                                  @"card_content": @"follow",
                                                  @"subv_num": @(self.momentsRecommendUserData.userCardModels.count),
                                                  @"user_id": self.momentsRecommendUserData.friendUserModel.info.user_id ?: @""
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

- (TTMomentsRecommendUserTableView *)momentsRecommendUserTableView {
    if (!_momentsRecommendUserTableView) {
        _momentsRecommendUserTableView = [[TTMomentsRecommendUserTableView alloc] init];
        _momentsRecommendUserTableView.delegate = self;
    }
    
    return _momentsRecommendUserTableView;
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
        _dislikeButton = [[TTAlphaThemedButton alloc] initWithFrame:CGRectMake(self.width - kDislikeButtonWidth, (kHeaderViewHeight - kDislikeButtonHeight) / 2, kDislikeButtonWidth, kDislikeButtonHeight)];
        [_dislikeButton setImageEdgeInsets:UIEdgeInsetsMake(0, 10, 0, 0)];
        [_dislikeButton setImage:[UIImage themedImageNamed:@"add_textpage.png"] forState:UIControlStateNormal];
        
        _dislikeButton.backgroundColor = [UIColor clearColor];
        [_dislikeButton addTarget:self action:@selector(dislikeAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _dislikeButton;
}

@end

