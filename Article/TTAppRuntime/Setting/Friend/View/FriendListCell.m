
//  RelationUserCell.m
//  Article
//
//  Created by Yu Tianhang on 12-11-2.
//
//

#import "FriendListCell.h"
#import <TTAccountBusiness.h>
#import "TTThirdPartyAccountsHeader.h"
#import "NetworkUtilities.h"
#import "TTIndicatorView.h"
#import "SSCommonLogic.h"
#import <TTVerifyKit/TTVerifyIconHelper.h>
#import "TTIndicatorView.h"
#import "UIImage+TTThemeExtension.h"
#import "ArticleProfileFollowConst.h"


@interface FriendListCell () {
}
@end


@implementation FriendListCell

@synthesize currentFriend;
@synthesize friendDataManager;

- (void)dealloc
{
    self.umengEventName = nil;
    self.listCellUnit = nil;
    self.currentFriend = nil;
    self.friendDataManager = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier type:(FriendDataListType)type
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _type = type;
        
        if (_type == FriendDataListTypeSuggestUser || _type == FriendDataListTypeWidgetSuggestUser) {
            self.umengEventName = @"add_friends";
        }
        else {
            self.umengEventName = @"friends";
        }
        
        [self loadView];
    }
    
    return self;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    return [self initWithStyle:style reuseIdentifier:reuseIdentifier type:FriendDataListTypeFowllowing];
}

#pragma mark - ViewLifecycles

- (void)loadView
{
    self.friendDataManager = [[FriendDataManager alloc] init];
    friendDataManager.delegate = self;
    
    self.listCellUnit = [[FriendListCellUnit alloc] initWithFrame:self.bounds];
    [_listCellUnit.relationButton addTarget:self action:@selector(relationButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_listCellUnit];
}

- (void)refreshListCellUnitRelationButtonType
{
    if ([currentFriend isAccountUser]) {
        _listCellUnit.relationButtonType = FriendListCellUnitRelationButtonHide;
    }
    else {
        if (_type == FriendDataListTypePlatformFriends) {
            if ([currentFriend.hasInvited boolValue]) {
                _listCellUnit.relationButtonType = FriendListCellUnitRelationButtonInvitedFriend;
            }
            else {
                _listCellUnit.relationButtonType = FriendListCellUnitRelationButtonInviteFriend;
            }
        }
        else {
            if ([currentFriend.isFollowed boolValue] && [currentFriend.isFollowing boolValue]) {
                _listCellUnit.relationButtonType = FriendListCellUnitRelationButtonFollowingFollowed;
            }
            else if ([currentFriend.isFollowing boolValue]) {
                _listCellUnit.relationButtonType = FriendListCellUnitRelationButtonCancelFollow;
            }
            else {
                _listCellUnit.relationButtonType = FriendListCellUnitRelationButtonFollow;
            }
        }
    }
}

#pragma mark - public

- (void)setCurrentFriend:(ArticleFriend *)currentFriend_
{
    currentFriend = currentFriend_;
    if (currentFriend) {
        [_listCellUnit setAvatarURLString:currentFriend.avatarURLString];
        [_listCellUnit setTitleText:currentFriend.screenName];
        [_listCellUnit setDesc:currentFriend.lastUpdate];
        _listCellUnit.verifyType = [TTVerifyIconHelper isVerifiedOfVerifyInfo:currentFriend.userAuthInfo] ? FriendListCellUnitVerifyUserVerify : FriendListCellUnitVerifyTypeHide;
        
        if ((_type == FriendDataListTypeSuggestUser || _type == FriendDataListTypeWidgetSuggestUser) && currentFriend.isTipNew) {
            [_listCellUnit showTipNew:YES];
        }
        else {
            [_listCellUnit showTipNew:NO];
        }
        
        if ((_type == FriendDataListTypeSuggestUser || _type == FriendDataListTypeWidgetSuggestUser || _type == FriendDataListTypePlatformFriends) || !isEmptyString(currentFriend.platform)) {
            if ([currentFriend.platform isEqualToString:PLATFORM_QQ_WEIBO]) {
                [_listCellUnit setPlatformType:FriendListCellUnitPlatformTypeTencentWeibo];
            }
            else if ([currentFriend.platform isEqualToString:PLATFORM_QZONE]) {
                [_listCellUnit setPlatformType:FriendListCellUnitPlatformTypeQQZone];
            }
            else if ([currentFriend.platform isEqualToString:PLATFORM_KAIXIN_SNS]) {
                [_listCellUnit setPlatformType:FriendListCellUnitPlatformTypeKaixin];
            }
            else if ([currentFriend.platform isEqualToString:PLATFORM_RENREN_SNS]) {
                [_listCellUnit setPlatformType:FriendListCellUnitPlatformTypeRenRen];
            }
            else if ([currentFriend.platform isEqualToString:PLATFORM_SINA_WEIBO]) {
                [_listCellUnit setPlatformType:FriendListCellUnitPlatformTypeSinaWeibo];
            }
            else {
                [_listCellUnit setPlatformType:FriendListCellUnitPlatformTypeHide];
            }
        }
        else {
            [_listCellUnit setPlatformType:FriendListCellUnitPlatformTypeHide];
        }
        
        
        [self refreshListCellUnitRelationButtonType];
    }
}

- (void)refreshUI
{
    CGRect vFrame = self.bounds;
    vFrame.size.height = FriendListCellHeight;
    
    _listCellUnit.frame = self.bounds;
    [_listCellUnit refreshFrame];
}

#pragma mark - Actions

- (void)relationButtonClicked:(id)sender
{
    if ([TTAccountManager isLogin]) {
        _listCellUnit.relationButtonType = FriendListCellUnitRelationButtonLoading;
        
        NSString *from = nil;
        
        if (_type == FriendDataListTypePlatformFriends) {
            if ([self.currentFriend.hasInvited boolValue]) {
                return;
            }
            self.currentFriend.hasInvited = @(YES);
            _listCellUnit.relationButtonType = FriendListCellUnitRelationButtonInvitedFriend;
            WeakSelf;
            [[TTFollowManager sharedManager] startFollowAction:FriendActionTypeInvite userID:self.currentFriend.userID platform:self.currentFriend.platform name:self.currentFriend.name from:nil reason:nil newReason:nil newSource:nil completion:^(FriendActionType type, NSError * _Nullable error, NSDictionary * _Nullable result) {
                [wself friendDataManager:wself.friendDataManager finishActionType:FriendActionTypeInvite error:error result:({
                    NSMutableDictionary *mutableResult = [result mutableCopy];
                    [mutableResult setValue:wself.currentFriend.userID forKey:@"id"];
                    [mutableResult copy];
                })];

            }];
        }
        else if ([currentFriend.isFollowing boolValue]) {
            
            if ((_type == FriendDataListTypeSuggestUser || _type == FriendDataListTypeWidgetSuggestUser)) {
                if (![self.currentFriend.hasSNS boolValue]) {
                    wrapperTrackEvent(_umengEventName, @"unfollow_recommended");
                }
                else {
                    wrapperTrackEvent(_umengEventName, @"unfollow_joined_friends");
                }
                from = kAddFriend;
            }
            else if (_type == FriendDataListTypeFollower){
                wrapperTrackEvent(_umengEventName, @"followers_unfollow");
                from = self.isMyList ? kMyFans : kOtherFans;
            }
            else if (_type == FriendDataListTypeFowllowing) {
                wrapperTrackEvent(_umengEventName, @"followings_unfollow");
                from = self.isMyList ? kMyFollowers : kOtherFollowers;
            }
            
            WeakSelf;
            [[TTFollowManager sharedManager] startFollowAction:FriendActionTypeUnfollow userID:self.currentFriend.userID platform:nil name:self.currentFriend.name from:from reason:nil newReason:nil newSource:nil completion:^(FriendActionType type, NSError * _Nullable error, NSDictionary * _Nullable result) {
                [wself friendDataManager:wself.friendDataManager finishActionType:FriendActionTypeUnfollow error:error result:({
                    NSMutableDictionary *mutableResult = [result mutableCopy];
                    [mutableResult setValue:wself.currentFriend.userID forKey:@"id"];
                    [mutableResult copy];
                })];
            }];
        }
        else {
            
            if ((_type == FriendDataListTypeSuggestUser || _type == FriendDataListTypeWidgetSuggestUser)) {
                if (![self.currentFriend.hasSNS boolValue]) {
                    wrapperTrackEvent(_umengEventName, @"follow_recommended");
                }
                else {
                    wrapperTrackEvent(_umengEventName, @"follow_joined_friends");
                }
                from = kAddFriend;
            }
            else if (_type == FriendDataListTypeFollower) {
                from = self.isMyList ? kMyFans : kOtherFans;
            }
            else if (_type == FriendDataListTypeFowllowing) {
                from = self.isMyList ? kMyFollowers : kOtherFollowers;
            }

            WeakSelf;
            [[TTFollowManager sharedManager] startFollowAction:FriendActionTypeFollow userID:self.currentFriend.userID platform:nil name:self.currentFriend.name from:from reason:nil newReason:nil newSource:nil completion:^(FriendActionType type, NSError * _Nullable error, NSDictionary * _Nullable result) {
                [wself friendDataManager:wself.friendDataManager finishActionType:FriendActionTypeFollow error:error result:({
                    NSMutableDictionary *mutableResult = [result mutableCopy];
                    [mutableResult setValue:wself.currentFriend.userID forKey:@"id"];
                    [mutableResult copy];
                })];
            }];
        }
    }
    else {
        [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:@"请先登录" indicatorImage:[UIImage themedImageNamed:@"close_popup_textpage"] autoDismiss:YES dismissHandler:nil];
        
        [TTAccountManager showLoginAlertWithType:TTAccountLoginAlertTitleTypeDefault source:nil completion:^(TTAccountAlertCompletionEventType type, NSString *phoneNum) {
            if (type == TTAccountAlertCompletionEventTypeTip) {
                [TTAccountManager presentQuickLoginFromVC:[TTUIResponderHelper topNavigationControllerFor:self] type:TTAccountLoginDialogTitleTypeDefault source:nil completion:^(TTAccountLoginState state) {
                }];
            }
        }];
    }
}

#pragma mark - FriendDataManagerDelegate

- (void)friendDataManager:(FriendDataManager *)dataManager finishActionType:(FriendActionType)type error:(NSError *)error result:(NSDictionary *)result
{
    if (error) {
        NSString *notify = [[error userInfo] objectForKey:kErrorDisplayMessageKey];
        if(isEmptyString(notify)) notify = NSLocalizedString(@"操作失败，稍后再试", nil);
        [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:notify indicatorImage:[UIImage themedImageNamed:@"close_popup_textpage"] autoDismiss:YES dismissHandler:nil];
    }
    else {
        NSString *notify = nil;
        switch (type) {
            case FriendActionTypeInvite:
                currentFriend.hasInvited = @YES;
                notify = NSLocalizedString(@"已发送", nil);
                break;
            case FriendActionTypeFollow:
                currentFriend.isFollowing = @YES;
                break;
            case FriendActionTypeUnfollow:
                currentFriend.isFollowing = @NO;
            default:
                break;
        }
        
        if (!isEmptyString(notify)) {
            [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:notify indicatorImage:[UIImage themedImageNamed:@"doneicon_popup_textpage"] autoDismiss:YES dismissHandler:nil];
        }
    }
    [self refreshListCellUnitRelationButtonType];
    [currentFriend postFriendModelChangedNotification];
}

@end
