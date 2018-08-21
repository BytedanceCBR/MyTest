//
//  TTFollowedViewController.m
//  Article
//
//  Created by liuzuopeng on 8/9/16.
//
//

#import "TTFollowedViewController.h"
#import <SSThemed.h>
#import <TTAccountBusiness.h>
#import "TTFollowedCell.h"
#import "TTFirstFollowedCell.h"
#import "TTFollowedModel.h"
#import "ArticleMomentProfileViewController.h"
#import "ArticleProfileFollowConst.h"
#import "TTRelationFooterView.h"


typedef NS_ENUM(NSUInteger, TTFollowedCellType) {
    kTTCellTypeNone,
    kTTCellTypeFirst,
    kTTCellTypeNormal,
};

@interface TTFollowedViewController ()
<
TTSocialBaseCellDelegate
>
/**
 *  当前访问用户的models
 */
@property (nonatomic, strong) NSMutableArray *followedModels;
/**
 *  映射用户id到对应的model index
 */
@property (nonatomic, strong) NSMutableDictionary<NSString *, NSNumber *> *userIdToIndexs;
@property (nonatomic, assign) unsigned long long totalFollowersCount;/*所有粉丝的数量*/
@property (nonatomic, assign) unsigned long long anonymousFollowersCount;/*匿名粉丝的数量*/

@end

@implementation TTFollowedViewController
- (instancetype)init {
    if ((self = [super init])) {
        self.relationType = FriendDataListTypeFollower;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleFriendModelChangedNotification:) name:KFriendModelChangedNotification object:nil];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - notifications

/**
 *  h5/RN页面点击关注或取消关注向Native发送通知，当Native接收到通知，我的关注数和当前用户的粉丝数会发生变化
 *
 *  @param notification 通知
 */
- (void)handleFriendModelChangedNotification:(NSNotification *)notification {
    NSDictionary *userInfo = [[notification userInfo] tt_dictionaryValueForKey:@"user_data"];
    FriendActionType actionType  = [[notification userInfo] tt_intValueForKey:@"action_type"];
    if (!userInfo) return;
    
    NSString  *userID   = [userInfo tt_stringValueForKey:@"user_id"];
    NSUInteger modelIdx = [_userIdToIndexs[userID] unsignedIntegerValue];
    TTFollowedModel *userModel = modelIdx < [_followedModels count] ? _followedModels[modelIdx] : nil;
    
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
            TTFollowedCell *cell = (TTFollowedCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:modelIdx inSection:0]];
            if (!cell || ![cell isKindOfClass:[TTFollowedCell class]]) return;
            [cell updateFollowButtonStatus];
        } @catch (NSException *exception) {
        } @finally {
        }
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    wrapperTrackEvent(@"followers", @"followers_pull_refresh");
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)rebuildIndexes {
    if (!_followedModels) {
        _followedModels = [NSMutableArray array];
    } else {
        [_followedModels removeAllObjects];
    }
    if (!_userIdToIndexs) {
        _userIdToIndexs = [NSMutableDictionary dictionary];
    } else {
        [_userIdToIndexs removeAllObjects];
    }
    
    [self.friendModels enumerateObjectsUsingBlock:^(TTFollowedModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [_followedModels addObject:obj];
        if (!isEmptyString(obj.ID)) [_userIdToIndexs setValue:@(idx) forKey:obj.ID];
    }];
}

- (void)loadRequest {
    [super loadRequest];
    
    NSString *userId = self.currentFriend.userID ? : [TTAccountManager userID];
    [self.friendDataManager startGetFriendListType:FriendDataListTypeFollower friendModelClass:[TTFollowedModel class] userID:userId count:50 offset:(int)self.offset];
}

#pragma mark - table view helper

- (TTFollowedCellType)cellTypeAtIndex:(NSUInteger)index {
    TTFollowedCellType cellType = kTTCellTypeNone;
    if (index == 0) {
        cellType = kTTCellTypeFirst;
    } else {
        cellType = kTTCellTypeNormal;
    }
    return cellType;
}

- (TTFollowedCell *)reusedCellInTableView:(UITableView *)tableView atIndexPath:(NSIndexPath *)indexPath {
    NSString *identifier = @"kTTFollowedDefaultCellIdentifier";
    if (indexPath.row == 0) {
        identifier = @"kTTFollowedFirstCellIdentifier";
    }
    
    TTFollowedCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if(!cell) {
        if (indexPath.row == 0) {
            cell = [[TTFirstFollowedCell alloc] initWithReuseIdentifier:identifier];
        } else {
            cell = [[TTFollowedCell alloc] initWithReuseIdentifier:identifier];
        }
    }
    return cell;
}

#pragma mark - UITableViewDelegate and UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_followedModels count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if (section == 0 && self.anonymousFollowersCount > 0 && !self.hasMoreData) {
        return [TTRelationFooterView height];
    }
    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    if (section == 0 && self.anonymousFollowersCount > 0 && !self.hasMoreData) {
        TTRelationFooterView *footerView = (TTRelationFooterView *)[tableView headerViewForSection:section];
        if (!footerView) {
            footerView = [TTRelationFooterView new];
        }
        
        if([self.currentFriend isAccountUser]) {
            if (self.totalFollowersCount == self.anonymousFollowersCount) {
                [footerView reloadLabelText:[NSString stringWithFormat:@"%lld位游客关注了你", self.anonymousFollowersCount]];
            } else if (self.totalFollowersCount > self.anonymousFollowersCount) {
                [footerView reloadLabelText:[NSString stringWithFormat:@"还有%lld位游客也关注了你", self.anonymousFollowersCount]];
            }
        } else {
            if (self.totalFollowersCount == self.anonymousFollowersCount) {
                [footerView reloadLabelText:[NSString stringWithFormat:@"%lld位游客关注了TA", self.anonymousFollowersCount]];
            } else if (self.totalFollowersCount > self.anonymousFollowersCount) {
                [footerView reloadLabelText:[NSString stringWithFormat:@"还有%lld位游客也关注了TA", self.anonymousFollowersCount]];
            }
        }
        
        return footerView;
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row >= [_followedModels count]) {
        return 0;
    }
    if (indexPath.row == 0) {
        return [TTFirstFollowedCell cellHeightOfModel:_followedModels[indexPath.row]];
    }
    return [TTFollowedCell cellHeightOfModel:_followedModels[indexPath.row]];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row >= [_followedModels count]) return [UITableViewCell new];
    
    TTFollowedCell *cell = [self reusedCellInTableView:tableView atIndexPath:indexPath];
    cell.delegate = self;
    [cell reloadWithModel:_followedModels[indexPath.row]];
    
    return cell ? : [UITableViewCell new];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.row >= [_followedModels count])  return;
    
    ArticleFriendModel *tmpFriend = [self.friendModels objectAtIndex:indexPath.row];
    BOOL isMe = ([TTAccountManager isLogin] && [self.currentFriend isAccountUser]);
    NSString *fromString = isMe ? kFromMyFans : kFromOtherFans;
    NSString *umengEventlabelPrefix = @"followers";
    if ([umengEventlabelPrefix length] > 0) {
        wrapperTrackEvent(self.umengEventName, [NSString stringWithFormat:@"%@_profile", umengEventlabelPrefix]);
    }
    if (!tmpFriend.isFollowing) {
        // 未关注对方
        wrapperTrackEvent(@"friends", @"follow_profile");
    }
    wrapperTrackEvent(@"followers", @"enter_followers_profile"); // new
    
    ArticleMomentProfileViewController *controller = [[ArticleMomentProfileViewController alloc] initWithFriendModel:[tmpFriend articleFriend]];
    controller.from = fromString;
    controller.categoryName = @"mine_tab";
    if (self.currentFriend.userID && ![self.currentFriend.userID isEqualToString:[TTAccountManager userID]]) {//他人粉丝列表
        controller.fromPage = @"other_fan_list";
        controller.profileUserId = self.currentFriend.userID;
    } else {
        controller.fromPage = @"mine_followers_list";
    }
    [self.topNavigationController pushViewController:controller animated:YES];
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

#pragma mark - TTSocialBaseCellDelegate

- (void)socialBaseCell:(TTSocialBaseCell *)cell didTapFollowButton:(id)sender {
    TTFriendModel *currentFriend = cell.currentFriend;
    NSNumber *newSource = [self.currentFriend isAccountUser] ? @(TTFollowNewSourceFollowedList) : @(TTFollowNewSourceOtherFollowedList);
    BOOL isMyList = [TTAccountManager isLogin] && [self.currentFriend.userID isEqualToString:[TTAccountManager userID]];
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
        [extraDic setValue:@"my_fan_list"
                    forKey:@"source"];
    }else {
        [extraDic setValue:@"other_fan_list"
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
    
    BOOL isMyFollowed = ([TTAccountManager isLogin] && [currentFriend isAccountUser]);
    NSString *from = (isMyFollowed ? kMyFans : kOtherFans);
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
                    [TTAccountManager currentUser].followingsCount += 1;
                    [TTAccountManager sharedManager].myUser.followingCount += 1;
                    currentFriend.followingCount += 1;
                    break;
                }
                case FriendActionTypeUnfollow: {
                    currentFriend.isFollowing = NO;
                    [TTAccountManager currentUser].followingsCount = MAX(0, [TTAccountManager currentUser].followingsCount - 1);
                    [TTAccountManager sharedManager].myUser.followingCount = MAX(0,  [TTAccountManager sharedManager].myUser.followingCount);
                    currentFriend.followingCount = MAX(0, currentFriend.followingCount);
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

#pragma mark - TTTableRefreshEventPageProtocol

- (NSString *)eventPageKey {
    return @"followers";
}

#pragma mark - FriendDataManagerDelegate

- (void)friendDataManager:(FriendDataManager*)dataManager finishGotListWithType:(FriendDataListType)type error:(NSError *)error result:(NSArray *)result totalNumber:(unsigned long long)totalNumber anonymousNumber:(unsigned long long)anonymousNumber hasMore:(BOOL)hasMore offset:(int)offset {
    [super friendDataManager:dataManager finishGotListWithType:type error:error result:result totalNumber:totalNumber anonymousNumber:anonymousNumber hasMore:hasMore offset:offset];
    self.totalFollowersCount = totalNumber;
    self.anonymousFollowersCount = anonymousNumber;
    
    // fix view error type
    if (self.totalFollowersCount <= 0) {
        if ([self.currentFriend isAccountUser]) {
            self.ttViewType = TTFullScreenErrorViewTypeNoFollowers;
        } else {
            self.ttViewType = TTFullScreenErrorViewTypeOtherNoFollowers;
        }
    } else {
        self.ttViewType = TTFullScreenErrorViewTypeEmpty;
    }
    
    [self reloadWithError:error];
}

@end
