//
//  TTFollowingViewController.m
//  Article
//
//  Created by liuzuopeng on 8/9/16.
//
//

#import "TTFollowingViewController.h"
#import "SSThemed.h"
#import "ArticleFriend.h"
#import <TTAccountBusiness.h>
#import "FriendDataManager.h"
#import "TTFollowingDetailCell.h"
#import "TTFollowingMergeCell.h"

#import "TTProfileThemeConstants.h"

#import "TTFollowingModel.h"
#import "TTInterestViewController.h"
#import "ArticleProfileFollowConst.h"
#import "ArticleMomentProfileViewController.h"
#import "TTNewFollowingManager.h"
#import "TTRoute.h"
//#import "TTAddFriendViewController.h"

typedef NS_ENUM(NSUInteger, TTSectionType) {
    kTTSectionTypeNone,
    kTTSectionTypeMergeData, // 聚合频道（包括我的兴趣）
    kTTSectionTypeFollowingUser, // 关注用户（PGC和UGC）
};
@interface TTFollowingViewController ()
<
TTSocialBaseCellDelegate,
TTAccountMulticastProtocol
>
/**
 *  当前访问用户的models
 */
@property (nonatomic, strong) NSMutableArray<TTFollowingModel *> *followingModels;
@property (nonatomic, strong) NSMutableArray<TTFollowingMergeResponseModel *> *followingMergeModels;
@property (nonatomic,   copy) NSString *cursor;
@property (nonatomic, assign) BOOL hasMore;
/**
 *  映射用户id到对应的model index
 */
@property (nonatomic, strong) NSMutableDictionary<NSString *, NSNumber *> *userIdToIndexs;
@end

@implementation TTFollowingViewController
- (instancetype)init
{
    if ((self = [super init])) {
        self.relationType = FriendDataListTypeFowllowing;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleFriendModelChangedNotification:) name:KFriendModelChangedNotification object:nil];
        
        [TTAccount addMulticastDelegate:self];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [TTAccount removeMulticastDelegate:self];
}

#pragma mark - notifications

/**
 *  h5/RN页面点击关注或取消关注向Native发送通知，当Native接收到通知，我的关注数和当前用户的粉丝数会发生变化
 *
 *  @param notification 通知
 */
- (void)handleFriendModelChangedNotification:(NSNotification *)notification
{
    NSDictionary *userInfo      = [[notification userInfo] tt_dictionaryValueForKey:@"user_data"];
    FriendActionType actionType = [[notification userInfo] tt_intValueForKey:@"action_type"];
    if (!userInfo) return;
    
    NSString  *userID   = [userInfo tt_stringValueForKey:@"user_id"];
    NSUInteger modelIdx = [_userIdToIndexs[userID] unsignedIntegerValue];
    TTFollowingModel *userModel = modelIdx < [_followingModels count] ? _followingModels[modelIdx] : nil;
    
    if (userModel) {
        if ([userInfo valueForKey:@"is_following"]) {
            userModel.isFollowing = [userInfo tt_boolValueForKey:@"is_following"];
        }
        if ([userInfo valueForKey:@"is_followed"]) {
            userModel.isFollowed  = [userInfo tt_boolValueForKey:@"is_followed"];
        }
        
        switch (actionType) {
            case FriendActionTypeFollow: {
                [TTAccountManager currentUser].followingsCount += 1;
                [TTAccountManager sharedManager].myUser.followingCount += 1;
                
                userModel.followingCount += 1;
                break;
            }
            case FriendActionTypeUnfollow: {
                [TTAccountManager currentUser].followingsCount = MAX(0, [TTAccountManager currentUser].followingsCount - 1);
                [TTAccountManager sharedManager].myUser.followingCount = MAX(0,  [TTAccountManager sharedManager].myUser.followingCount);
                
                userModel.followingCount = MAX(0, userModel.followingCount);
                break;
            }
            default:
                break;
        }
        @try {
            TTFollowingDetailCell *cell = (TTFollowingDetailCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:modelIdx inSection:1]];
            if (![cell isKindOfClass:[TTFollowingDetailCell class]]) return;
            [cell updateFollowButtonStatus];
        } @catch (NSException *exception) {
        } @finally {
        }
    }
}

#pragma mark - TTAccountMulticastProtocol

- (void)onAccountStatusChanged:(TTAccountStatusChangedReasonType)reasonType platform:(NSString *)platformName
{
    self.hasMore = NO;
    self.offset = 0;
    self.cursor = nil;
    self.currentFriend.userID = [TTAccountManager userID];
    if (self.followingModels) [self.followingModels removeAllObjects];
    if (self.followingMergeModels) [self.followingMergeModels removeAllObjects];
    if (self.friendModels) [self.friendModels removeAllObjects];
    if (self.userIdToIndexs) [self.userIdToIndexs removeAllObjects];
    
    [self loadRequest];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    wrapperTrackEvent(@"followings", @"followings_pull_refresh");
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)rebuildIndexes
{
    if (!_followingModels) {
        _followingModels = [NSMutableArray array];
    } else {
        [_followingModels removeAllObjects];
    }
    if (!_userIdToIndexs) {
        _userIdToIndexs = [NSMutableDictionary dictionary];
    } else {
        [_userIdToIndexs removeAllObjects];
    }
    [self.friendModels enumerateObjectsUsingBlock:^(TTFollowingModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [_followingModels addObject:obj];
        if (!isEmptyString(obj.ID)) [_userIdToIndexs setValue:@(idx) forKey:obj.ID];
    }];
}

- (void)finishGotNewFollowingListWithModel:(TTNewFollowingResponseModel *)model error:(NSError *)error
{
    self.offset += (model.data && [model.data isKindOfClass:[NSArray class]] && [model.data count] > 0) ? [model.data count] : 0;
    if (!self.followingMergeModels) {
        self.followingMergeModels = [NSMutableArray array];
    } else if ([self isRefreshing]) {
        [self.followingMergeModels removeAllObjects];
        [self.friendModels removeAllObjects];
    }
    
    if (!error) {
        NSArray<TTFollowingResponseModel *> *followingArray = model.data;
        NSArray<TTFollowingMergeResponseModel *> *followingMergeArray = model.mergeData;
        
        if (followingMergeArray && followingMergeArray.count > 0) {
            [followingMergeArray enumerateObjectsUsingBlock:^(TTFollowingMergeResponseModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if (![self.followingMergeModels containsObject:obj]) {
                    [self.followingMergeModels addObject:obj];
                }
            }];
        }
        self.hasMore = [model.hasMore boolValue];
        self.cursor = model.cursor;
        
        [followingArray enumerateObjectsUsingBlock:^(TTFollowingResponseModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            TTFollowingModel *tempModel = [TTFollowingModel new];
            tempModel.media_id = obj.mediaID; // mediaID
            tempModel.ID = obj.userID; // userID
            tempModel.name = obj.name; // titleString
            tempModel.recommendReason = obj.midDescription; // subtitle1
            tempModel.userDescription = obj.userDescription; // subtitle2
            tempModel.tipsCount = obj.tipsCount; // tipsCount
            tempModel.avatarURLString = obj.avatarURLString; // icon
            tempModel.visitorUID = !isEmptyString(self.currentFriend.userID) ? self.currentFriend.userID : @"0"; // visitorID
            tempModel.userAuthInfo = obj.userAuthInfo; // 头条认证展现
            tempModel.isFollowing = YES; //我的关注均为已关注
            tempModel.userDecoration = obj.userDecoration;
            [self.friendModels addObject:tempModel];
        }];
    }
    
    if ([self.followingModels count] == 0 && [self.followingMergeModels count] == 0) {
        if ([self isMe]) { // 错误页面
            self.ttViewType = TTFullScreenErrorViewTypeNoFriends;
        } else {
            self.ttViewType = TTFullScreenErrorViewTypeOtherNoFriends;
        }
    } else {
        self.ttViewType = TTFullScreenErrorViewTypeEmpty;
    }
    
    [self reloadWithError:error];
}

- (BOOL)hasMoreData
{
    if ([self isNewFollowingEnable]) {
        return self.hasMore;
    } else {
        return [super hasMoreData];
    }
}

- (void)triggerReload
{
    if ([self isNewFollowingEnable]) {
        if (self.reloadEnabled) {
            self.cursor = nil;
            [super triggerReload];
        }
    } else {
        [super triggerReload];
    }
}

- (BOOL)tt_hasValidateData
{
    if ([self isNewFollowingEnable]) {
        return [self.followingMergeModels count] > 0 || [self.followingModels count] > 0;
    } else {
        return [super tt_hasValidateData];
    }
}

- (BOOL)isMe
{
    // 如果未登陆且currentFriend的userID为nil，也为自己（匿名访问我的关注）
    return [self.currentFriend isAccountUser] || (!self.currentFriend.userID && ![TTAccountManager isLogin]);
}

- (BOOL)isNewFollowingEnable
{
    return [self isMe];
}

- (void)loadRequest {
    [super loadRequest];
    
    NSString *userId = self.currentFriend.userID ? : [TTAccountManager userID];
    if ([self isNewFollowingEnable]) {
        WeakSelf;
        [[TTNewFollowingManager sharedInstance] fetchFollowingListWithUserID:userId cursor:self.cursor completion:^(NSError *error, TTNewFollowingResponseModel *model) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [wself finishGotNewFollowingListWithModel:model error:error];
            });
        }];
    } else {
        [self.friendDataManager startGetFriendListType:FriendDataListTypeFowllowing friendModelClass:[TTFollowingModel class] userID:userId count:50 offset:(int)self.offset];
    }
}

#pragma mark - helper of UITableView

- (TTSectionType)sectionTypeAtIndex:(NSUInteger)index
{
    TTSectionType sectionType = kTTSectionTypeNone;
    if ([self isMe]) { // 访问他人不显示聚合信息
        if (index == 0) {
            sectionType = kTTSectionTypeMergeData;
        } else if (index == 1) {
            sectionType = kTTSectionTypeFollowingUser;
        }
    } else {
        sectionType = kTTSectionTypeFollowingUser;
    }
    return sectionType;
}

- (TTBaseUserProfileCell *)reusedCellInTableView:(UITableView *)tableView atIndexPath:(NSIndexPath *)indexPath
{
    NSString *identifier = @"kTTFollowingTitleCellIdentifier";
    switch ([self sectionTypeAtIndex:indexPath.section]) {
        case kTTSectionTypeMergeData: {
            identifier = @"kTTFollowingMergeCellIdentifier";
            break;
        }
        case kTTSectionTypeFollowingUser: {
            identifier = @"kTTFollowingDetailCellIdentifier";
            break;
        }
        default:
            break;
    }
    
    TTBaseUserProfileCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if(!cell) {
        switch ([self sectionTypeAtIndex:indexPath.section]) {
            case kTTSectionTypeMergeData: {
                cell = [[TTFollowingMergeCell alloc] initWithReuseIdentifier:identifier];
                break;
            }
            case kTTSectionTypeFollowingUser: {
                cell = [[TTFollowingDetailCell alloc] initWithReuseIdentifier:identifier];
                break;
            }
            default:
                break;
        }
    }
    return cell;
}

#pragma mark - UITableViewDelegate and UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if ([self isMe]) {
        return 1 + ([_followingModels count] > 0 ? 1 : 0);
    } else {
        return [_followingModels count] > 0 ? 1 : 0;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSUInteger numberOfRows = 0;
    switch ([self sectionTypeAtIndex:section]) {
        case kTTSectionTypeMergeData: {
            if ([self isNewFollowingEnable]) {
                numberOfRows = self.followingMergeModels ? [self.followingMergeModels count]: 0;
            } else {
                numberOfRows = 1; // 旧版需要保留兴趣
            }
            break;
        }
        case kTTSectionTypeFollowingUser: {
            numberOfRows = [_followingModels count];
            break;
        }
        default:
            break;
    }
    return numberOfRows;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat height = 0.f;
    switch ([self sectionTypeAtIndex:indexPath.section]) {
        case kTTSectionTypeMergeData: {
            height = [TTFollowingMergeCell cellHeight];
            break;
        }
        case kTTSectionTypeFollowingUser: {
            if (indexPath.row < _followingModels.count) {
                height = [TTFollowingDetailCell cellHeightOfModel:_followingModels[indexPath.row]];
            }
            break;
        }
        default:
            break;
    }
    return height;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    CGFloat height = 0.f;
    switch ([self sectionTypeAtIndex:section]) {
        case kTTSectionTypeMergeData: {
            break;
        }
        case kTTSectionTypeFollowingUser: {
            if ([self.followingMergeModels count] > 0 && [self.followingModels count] > 0) {
                height = [TTDeviceUIUtils tt_padding:kTTProfileSpacingOfSection];
            }
            break;
        }
        default:
            break;
    }
    return height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self reusedCellInTableView:tableView atIndexPath:indexPath];
    switch ([self sectionTypeAtIndex:indexPath.section]) {
        case kTTSectionTypeMergeData: {
            TTFollowingMergeCell *mergeCell = (TTFollowingMergeCell *)cell;
            mergeCell.delegate = self;
            if ([self isNewFollowingEnable]) {
                [mergeCell reloadWithFollowingModel:self.followingMergeModels[indexPath.row]];
            } else {
                mergeCell.titleLabel.text = @"兴趣";
                mergeCell.subtitle2Label.text = @"频道、话题等";
                [mergeCell.avatarView setLocalAvatarImage:[UIImage themedImageNamed:@"friend_interesting"]];
                [mergeCell updateFollowButtonForType:FriendListCellUnitRelationButtonHide];
                [mergeCell layoutIfNeeded];
            }
            break;
        }
        case kTTSectionTypeFollowingUser: {
            TTFollowingDetailCell *detailCell =(TTFollowingDetailCell *)cell;
            detailCell.delegate = self;
            
            if (indexPath.row < [_followingModels count]) {
                [detailCell reloadWithFollowingModel:_followingModels[indexPath.row]];
            }
            break;
        }
        default:
            break;
    }
    
    return cell ? : [UITableViewCell new];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    switch ([self sectionTypeAtIndex:indexPath.section]) {
        case kTTSectionTypeMergeData: {
            TTFollowingMergeResponseModel *model = self.followingMergeModels[indexPath.row];
            NSString *type = model.type;
            if ([type isEqualToString:@"interest"] || ![self isNewFollowingEnable]) {
                wrapperTrackEvent(@"followings", @"enter_xingqu");
                
                TTInterestViewController *interestVC = [[TTInterestViewController alloc] initWithUID:self.currentFriend.userID];
                [self.topNavigationController pushViewController:interestVC animated:YES];
            } else {
                NSString *urlString = self.followingMergeModels[indexPath.row].url;
                NSURL *url = [NSURL URLWithString:urlString];
                if ([[TTRoute sharedRoute] canOpenURL:url]) {
                    TTFollowingMergeCell *cell = [tableView cellForRowAtIndexPath:indexPath];
                    if ([self isNewFollowingEnable]) {
                        //从卡片进入落地页各个关注对象点击量-点击时该对象为ugc还是pgc，以及未读条数
                        NSMutableDictionary *extra = [NSMutableDictionary dictionaryWithCapacity:2];
                        extra[@"type"] = !isEmptyString(model.type) ? model.type : @"";
                        extra[@"tips"] = [model.tips boolValue] ? @YES : @NO;
                        wrapperTrackEventWithCustomKeys(@"followings_list", @"item_click", nil, nil, [extra copy]);
                    }
                    if ([cell isKindOfClass:[TTFollowingMergeCell class]]) {
                        [cell setTipsCount:@"0"];
                        [cell setTips:NO];
                        model.tips = [NSNumber numberWithBool:NO];
                        model.tipsCount = @"0";
                    }
                    [[TTRoute sharedRoute] openURLByPushViewController:url];
                }
            }
            break;
        }
        case kTTSectionTypeFollowingUser: {
            TTFollowingModel *model;
            if ([self isNewFollowingEnable]) {
                model = self.followingModels[indexPath.row];
                TTFollowingDetailCell *cell = [tableView cellForRowAtIndexPath:indexPath];
                if ([cell isKindOfClass:[TTFollowingDetailCell class]]) {
                    [cell setTipsCount:@"0"];
                    model.tipsCount = @"0";
                }
            } else {
                model = self.friendModels[indexPath.row];
            }
            NSString *fromString = [self isMe] ? kFromMyFollowers : kFromOtherFollowers;
            
            if ([self isNewFollowingEnable]) {
                //从卡片进入落地页各个关注对象点击量-点击时该对象为ugc还是pgc，以及未读条数
                NSMutableDictionary *extra = [NSMutableDictionary dictionaryWithCapacity:2];
                extra[@"user_id"] = !isEmptyString(model.ID) ? model.ID : @"0";
                extra[@"media_id"] = !isEmptyString(model.media_id) ? model.media_id : @"0";
                extra[@"tips_count"] = !isEmptyString(model.tipsCount) ? model.tipsCount : @"0";
                wrapperTrackEventWithCustomKeys(@"followings_list", @"item_click", nil, nil, [extra copy]);
            } else {
                /* old */
                NSString *umengEventlabelPrefix = @"followings";
                if ([umengEventlabelPrefix length] > 0) {
                    wrapperTrackEvent(self.umengEventName, [NSString stringWithFormat:@"%@_profile", umengEventlabelPrefix]);
                }
                if (!model.isFollowing) {
                    // 未关注对方
                    wrapperTrackEvent(@"friends", @"follow_profile");
                }
                wrapperTrackEvent(@"followings", @"enter_followings_profile"); /* new */
            }
            
            ArticleMomentProfileViewController *controller = [[ArticleMomentProfileViewController alloc] initWithFriendModel:[model articleFriend]];
            controller.from = fromString;
            controller.categoryName = @"mine_tab";
            if (self.currentFriend.userID && ![self.currentFriend.userID isEqualToString:[TTAccountManager userID]]) {//他人粉丝列表
                controller.fromPage = @"other_following_list";
                controller.profileUserId = self.currentFriend.userID;
            } else {
                controller.fromPage = @"mine_followings_list";
            }
            [self.topNavigationController pushViewController:controller animated:YES];
            break;
        }
        default: {
            break;
        }
    }
}

#pragma mark - TTTableRefreshEventPageProtocol

- (NSString *)eventPageKey
{
    return @"followings";
}

#pragma mark - UIViewControllerErrorHandler delegate

//- (void)emptyViewBtnAction
//{
//    wrapperTrackEvent(@"followings", @"enter_add_friends");
//
//    TTAddFriendViewController *addFriendVC = [[TTAddFriendViewController alloc] init];
//    [self.topNavigationController pushViewController:addFriendVC animated:YES];
//}

#pragma mark - TTSocialBaseCellDelegate

/**
 *  以前的关注和取消关注都需要用户登录，导致用户转化率特别低；为了增加用户浏览转化率，新的业务逻辑是不需要登录，用device_id来标记
 *
 *  @param cell   当前点击的cell
 *  @param sender 发送者
 */
- (void)socialBaseCell:(TTSocialBaseCell *)cell didTapFollowButton:(id)sender
{
    TTFriendModel *currentFriend = cell.currentFriend;
    BOOL isMyList = [TTAccountManager isLogin] && [self.currentFriend.userID isEqualToString:[TTAccountManager userID]];
    NSNumber *newSource = [self.currentFriend isAccountUser] ? nil : @(TTFollowNewSourceOtherFollowingList);
    
    NSString * followEvent = nil;
    if (currentFriend.isFollowing) {
        followEvent = @"rt_unfollow";
    }else {
        followEvent = @"rt_follow";
    }
    NSMutableDictionary * extraDic = @{}.mutableCopy;
    [extraDic setValue:currentFriend.ID
                forKey:@"to_user_id"];
    [extraDic setValue:@"from_others"
                forKey:@"follow_type"];
    if (isMyList) {
        [extraDic setValue:@"my_following_list"
                    forKey:@"source"];
    }else {
        [extraDic setValue:@"other_following_list"
                    forKey:@"source"];
    }
    [extraDic setValue:newSource
                forKey:@"server_source"];
    [TTTrackerWrapper eventV3:followEvent
                       params:extraDic];
    
    if (!TTNetworkConnected()) {
        [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:@"无网络链接" indicatorImage:[UIImage themedImageNamed:@"close_popup_textpage.png"] autoDismiss:YES dismissHandler:nil];
        return;
    }
    
    [cell startLoading];
    FriendActionType actionType = (currentFriend.isFollowing ? FriendActionTypeUnfollow : FriendActionTypeFollow);
    NSString *from   =  ([self isMe] ? kMyFollowers : kOtherFollowers);
    NSNumber *reason = @(currentFriend.reasonType);
    NSNumber *newReason = @(currentFriend.newReason);
    
    // request network and refresh follow status when network is responsed
    [[TTFollowManager sharedManager] startFollowAction:actionType userID:currentFriend.ID platform:nil name:currentFriend.name from:from reason:reason newReason:newReason newSource:newSource completion:^(FriendActionType type, NSError * _Nullable error, NSDictionary * _Nullable result) {
        [cell stopLoading];
        
        if (error) {
            NSString *hint = [[[result tt_dictionaryValueForKey:@"result"] tt_dictionaryValueForKey:@"data"] tt_stringValueForKey:@"description"];
            if (isEmptyString(hint)) {
                hint = NSLocalizedString(type == FriendActionTypeFollow ?  @"关注失败" : @"取消关注失败", nil);
            }
            [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:hint indicatorImage:[UIImage themedImageNamed:@"close_popup_textpage"] autoDismiss:YES dismissHandler:nil];
        } else {
            NSString *hint = nil;
            switch (type) {
                case FriendActionTypeFollow: {
                    hint = NSLocalizedString(@"关注成功", nil);
                    currentFriend.isFollowing = YES;
                    break;
                }
                case FriendActionTypeUnfollow: {
                    currentFriend.isFollowing = NO;
                    break;
                }
                default:
                    break;
            }
            
            if (!isEmptyString(hint)) {
                [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:hint indicatorImage:[UIImage themedImageNamed:@"doneicon_popup_textpage"] autoDismiss:YES dismissHandler:nil];
            }
        }
        
        [cell updateFollowButtonForType:[cell.class friendRelationTypeOfModel:currentFriend]];
    }];
}
@end

