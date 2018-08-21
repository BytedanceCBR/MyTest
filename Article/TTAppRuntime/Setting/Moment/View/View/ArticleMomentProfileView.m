//
//  ArticleMomentProfileView.m
//  Article
//
//  Created by Zhang Leonardo on 14-5-26.
//
//

#import "ArticleMomentProfileView.h"
#import "ArticleMomentManager.h"
#import "ArticleMomentUserIntroView.h"
#import <TTAccountBusiness.h>
#import "SSViewControllerBase.h"
#import "TTBlockManager.h"
#import "BlockUsersListViewController.h"
#import "ExploreEntryManager.h"
#import "TTThemedAlertController.h"
#import "TTNavigationController.h"
#import "TTIndicatorView.h"
#import "UIImage+TTThemeExtension.h"



@interface ArticleMomentProfileView()
<
UIActionSheetDelegate,
UIAlertViewDelegate,
ArticleMomentUserIntroViewDelegate,
TTBlockManagerDelegate,
TTAccountMulticastProtocol
>
{
    BOOL _isFirtstShowMessage;
    BOOL _isAccountUser;
}
@property(nonatomic, retain)SSUserModel * userModel;
@property(nonatomic, retain)ArticleMomentManager * manager;
@property(nonatomic, retain)UIButton * backButton;
@property(nonatomic, retain)ArticleMomentUserIntroView * introHeaderView;
@property(nonatomic, retain)SSThemedButton * actionButton;
@property(nonatomic, retain)UIActivityIndicatorView * indicator;

@property(nonatomic, retain)TTBlockManager * blockUserManager;

@end

@implementation ArticleMomentProfileView

- (void)dealloc
{
    _introHeaderView.delegate = nil;
    self.actionButton = nil;
    self.introHeaderView = nil;
    self.backButton = nil;
    self.manager = nil;
    self.userModel = nil;
    self.from = nil;
    self.indicator = nil;
    self.blockUserManager = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [TTAccount removeMulticastDelegate:self];
}

- (instancetype)initWithFrame:(CGRect)frame userModel:(SSUserModel *)model extraTracks:(NSDictionary *)extraTracks
{
    self = [super initWithFrame:frame];
    if (self) {
        _isFirtstShowMessage = YES;
        
        self.userModel = model;
        self.navigationBar.title = NSLocalizedString(@"个人主页", nil);
        
        self.backButton = [SSNavigationBar navigationBackButtonWithTarget:self action:@selector(backButtonClicked)];
        self.navigationBar.leftBarView = self.backButton;
        
        self.actionButton = [SSThemedButton buttonWithType:UIButtonTypeCustom];
        self.actionButton.frame = CGRectMake(0, 0, 60, 60);
        [self.actionButton setImageEdgeInsets:UIEdgeInsetsMake(0, 40, 0, -6)];
        self.actionButton.imageName = @"new_more_titlebar.png";
        self.actionButton.highlightedImageName = @"new_more_titlebar_press.png";
        [self.actionButton addTarget:self action:@selector(actionButtonClicked) forControlEvents:UIControlEventTouchUpInside];
        self.navigationBar.rightBarView = self.actionButton;
        
        _isAccountUser = [TTAccountManager isLogin] && [model.ID isEqualToString:[TTAccountManager userID]];
        if (_isAccountUser) {
            // 统计 - 进入自己的个人主页
            
            [TTAccount addMulticastDelegate:self];

            wrapperTrackEvent(@"mine_tab", @"enter_mine");
        }
        
        self.introHeaderView = [[ArticleMomentUserIntroView alloc] initWithFrame:CGRectZero extraTracks:extraTracks];
        _introHeaderView.delegate = self;
        [_introHeaderView refreshByUserID:model.ID];
        self.headerView = _introHeaderView;
        [self refreshHeaderView];
        
        [self reloadData];
        
        [self refreshListUI];
        
        
        self.blockUserManager = [[TTBlockManager alloc] init];
        self.blockUserManager.delegate = self;
        
        self.indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        _indicator.hidden = YES;
        [self addSubview:_indicator];
    }
    return self;
}

- (void)setFrom:(NSString *)from {
    if (_from != from) {
        _from = [from copy];
        
        self.introHeaderView.from = self.from;
    }
}

#pragma mark - TTAccountMulticastProtocol

- (void)onAccountUserProfileChanged:(NSDictionary *)changedFields error:(NSError *)error
{
    BOOL bAvatar   = [[changedFields objectForKey:@(TTAccountUserProfileTypeUserAvatar)] boolValue];
    BOOL bUserDesp = [[changedFields objectForKey:@(TTAccountUserProfileTypeUserName)] boolValue];
    BOOL bUserName = [[changedFields objectForKey:@(TTAccountUserProfileTypeUserDesp)] boolValue];
    
    if (bAvatar) {
        [self avatarChanged];
    }
    
    if (bUserName) {
        [self descriptionChanged];
    }
    
    if (bUserDesp) {
        [self userNameChanged];
    }
}

- (void)avatarChanged
{
    if([TTAccountManager isLogin])
    {
        [_introHeaderView refreshByUserID:_userModel.ID];
    }
}

- (void)descriptionChanged
{
    if([TTAccountManager isLogin])
    {
        [_introHeaderView refreshByUserID:_userModel.ID];
    }
}

- (void)userNameChanged
{
    if([TTAccountManager isLogin])
    {
        [_introHeaderView refreshByUserID:_userModel.ID];
    }
}


- (CGFloat)tipCellHeight
{
    return 100;
}


- (void)actionButtonClicked
{
    wrapperTrackEvent(@"profile", @"profile_more");
    UIActionSheet * tSheet = nil;
    if (_isAccountUser) {
        tSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:NSLocalizedString(@"取消", nil) destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"黑名单", nil), nil];
    } else {
        NSString * blockUnBlock = _userModel.isBlocking ? @"取消拉黑" : @"拉黑";
        tSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:NSLocalizedString(@"取消", nil) destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(blockUnBlock, nil), NSLocalizedString(@"举报此人", nil), nil];
    }
    
    if (tSheet) {
        //在iOS7越狱设备上会出现the view is not in a window，在此做保护，防止crash
        if ([TTDeviceHelper OSVersionNumber] < 8.0f) {
            UIWindow* window = [[[UIApplication sharedApplication] delegate] window];
            if ([window.subviews containsObject:self]) {
                [tSheet showInView:self];
            } else {
                [tSheet showInView:window];
            }
        }
        else {
            [tSheet showInView:self];
        }
    }
}

- (void)refreshHeaderView
{
    self.listView.tableHeaderView = nil;
    self.listView.tableHeaderView = self.headerView;
}

- (ArticleMomentManager *)currentManager
{
    if (!_manager) {
        self.manager = [[ArticleMomentManager alloc] init];
    }
    return _manager;
}

- (NSString *)currentUserID
{
    return _userModel.ID;
}

- (ArticleMomentSourceType)sourceType
{
    return ArticleMomentSourceTypeProfile;
}

- (void)backButtonClicked
{
    [[TTUIResponderHelper topNavigationControllerFor: self] popViewControllerAnimated:YES];
}

- (NewsGoDetailFromSource)fromSource
{
    return NewsGoDetailFromSourceProfile;
}

- (BOOL)notifyBarCouldShow
{
    if (_isFirtstShowMessage) {
        _isFirtstShowMessage = NO;
        return NO;
    }
    return YES;
}

- (NSString *)currentUmentEventName
{
    return @"profile";
}

- (NSString *)impressionKeyName
{
    return _userModel.ID;
}

- (void)_updateUserBlockStatusWithArticleFriend:(ArticleFriend *)friendModel
{
    if ([_userModel.ID isEqualToString:friendModel.userID]) {
        _userModel.isBlocking = [friendModel.isBlocking boolValue];
        _userModel.isBlocked = [friendModel.isBlocked boolValue];
    }
}

#pragma mark -- ArticleMomentUserIntroViewDelegate

- (void)updateFriendUser:(ArticleFriend *)friendModel introView:(ArticleMomentUserIntroView *)introView
{
    if (_introHeaderView == introView) {
        [self _updateUserBlockStatusWithArticleFriend:friendModel];
        [self refreshHeaderView];
    }
}

- (void)willAppear
{
    [super willAppear];
    
    [_introHeaderView willAppear];
    [_introHeaderView refreshByUserID:_userModel.ID];
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != actionSheet.cancelButtonIndex)
    {
        if (!_isAccountUser) {
            switch (buttonIndex) {
                case 0: // 拉黑/取消拉黑
                    if (![TTAccountManager isLogin]) {
                        [self showLoginView];
                        [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:@"请先登录" indicatorImage:[UIImage themedImageNamed:@"close_popup_textpage.png"] autoDismiss:YES dismissHandler:nil];
                    } else {
                        if (!TTNetworkConnected()) {
                            [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:@"无网络链接" indicatorImage:[UIImage themedImageNamed:@"close_popup_textpage.png"] autoDismiss:YES dismissHandler:nil];
                        } else {
                            if (_userModel.isBlocking) {
                                wrapperTrackEvent(@"profile_more", @"deblacklist");
                                wrapperTrackEvent(@"blacklist", @"click_deblacklist");
                                [self startIndicatorAnimation];
                                [self.blockUserManager unblockUser:_userModel.ID];
                            } else {
                                wrapperTrackEvent(@"profile", @"blacklist");
                                wrapperTrackEvent(@"blacklist", @"click_blacklist");
                                TTThemedAlertController *alert = [[TTThemedAlertController alloc] initWithTitle:@"确定拉黑该用户？" message:@"拉黑后此用户不能关注你，也无法给你发送任何消息" preferredType:TTThemedAlertControllerTypeAlert];
                                [alert addActionWithTitle:@"取消" actionType:TTThemedAlertActionTypeCancel actionBlock:^{
                                    wrapperTrackEvent(@"profile", @"quit_blacklist");
                                    wrapperTrackEvent(@"blacklist", @"quit_blacklist");
                                }];
                                [alert addActionWithTitle:@"确定" actionType:TTThemedAlertActionTypeNormal actionBlock:^{
                                    wrapperTrackEvent(@"profile", @"confirm_blacklist");
                                    wrapperTrackEvent(@"blacklist", @"confirm_blacklist");
                                    [self startIndicatorAnimation];
                                    [self.blockUserManager blockUser:_userModel.ID];
                                }];
                                [alert showFrom:self.viewController animated:YES];
                            }
                        }
                    }
                    break;
                case 1: // 举报
                    break;
                default:
                    break;
            }
        }
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != actionSheet.cancelButtonIndex)
    {
        if (_isAccountUser) { // 目前只支持黑名单；为了支持drag back，需要在actionsheet dismiss animation结束后执行pushViewController
            BlockUsersListViewController *controller = [[BlockUsersListViewController alloc] init];
            UINavigationController *topNav = [TTUIResponderHelper topNavigationControllerFor: self];
            [topNav pushViewController:controller animated:YES];
            wrapperTrackEvent(@"profile", @"enter_blacklist");
            wrapperTrackEvent(@"blacklist", @"list_enter_blacklist");
        }
        else{
            switch (buttonIndex){
                case 1:
                    [_introHeaderView presentReportView];
                    break;
                default:
                    break;
            }
        }
    }
}

- (void)showLoginView
{
    [TTAccountManager showLoginAlertWithType:TTAccountLoginAlertTitleTypeSocial source:@"social_other" completion:^(TTAccountAlertCompletionEventType type, NSString *phoneNum) {
        if (type == TTAccountAlertCompletionEventTypeTip) {
            [TTAccountManager presentQuickLoginFromVC:[TTUIResponderHelper topNavigationControllerFor:self] type:TTAccountLoginDialogTitleTypeDefault source:@"social_other" completion:^(TTAccountLoginState state) {
            }];
        }
    }];
}

- (void)startIndicatorAnimation
{
    _indicator.hidden = NO;
    [_indicator startAnimating];
}

- (void)stopIndicatorAnimation
{
    _indicator.hidden = YES;
    [_indicator stopAnimating];
}

#pragma mark -- TTBlockManagerDelegate

- (void)blockUserManager:(TTBlockManager *)manager blocResult:(BOOL)success blockedUserID:(NSString *)userID error:(NSError *)error errorTip:(NSString *)errorTip;
{
    if (error) {
        NSString * failedDescription = @"操作失败，请重试";
        if (!isEmptyString(errorTip)) {
            failedDescription = errorTip;
        }
        
        [self stopIndicatorAnimation];
        [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:failedDescription indicatorImage:[UIImage themedImageNamed:@"close_popup_textpage.png"] autoDismiss:YES dismissHandler:nil];
    } else {
        _userModel.isBlocking = YES;
        _userModel.isFriend = NO;
        
        ArticleFriend * friend = _introHeaderView.friend;
        if (!friend) {
            friend = [[ArticleFriend alloc] init];
        }
        friend.userID = _userModel.ID;
        friend.isBlocking = @(YES);
        if ([friend.isFollowing boolValue]) {
            friend.followerCount = @(MAX(0, [friend.followerCount intValue] - 1));
            friend.isFollowing = @(NO);
        }
        if ([friend.isFollowed boolValue]) {
            friend.followingCount = @(MAX(0, [friend.followingCount intValue] - 1));
            friend.isFollowed = @(NO);
        }
        
        [_introHeaderView refreshFriendData:friend];
        [self stopIndicatorAnimation];
        [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:@"拉黑成功" indicatorImage:[UIImage themedImageNamed:@"doneicon_popup_textpage.png"] autoDismiss:YES dismissHandler:nil];
        
        [friend postFriendModelChangedNotification];
    }
}

- (void)blockUserManager:(TTBlockManager *)manager unblockResult:(BOOL)success unblockedUserID:(NSString *)userID error:(NSError *)error errorTip:(NSString *)errorTip
{
    if (error) {
        NSString * failedDescription = @"操作失败，请重试";
        if (!isEmptyString(errorTip)) {
            failedDescription = errorTip;
        }
        
        [_introHeaderView refreshByUserID:_userModel.ID];
        [self stopIndicatorAnimation];
        
        [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:failedDescription indicatorImage:[UIImage themedImageNamed:@"close_popup_textpage.png"] autoDismiss:YES dismissHandler:nil];
    } else {
        _userModel.isBlocking = NO;
        ArticleFriend * friend = _introHeaderView.friend;
        friend.isBlocking = @(NO);
        [_introHeaderView refreshFriendData:friend];
        [self stopIndicatorAnimation];
        
        [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:@"已解除黑名单" indicatorImage:[UIImage themedImageNamed:@"doneicon_popup_textpage.png"] autoDismiss:YES dismissHandler:nil];
    }
}

#pragma mark -- UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != alertView.cancelButtonIndex)
    {
        wrapperTrackEvent(@"profile", @"confirm_blacklist");
        wrapperTrackEvent(@"blacklist", @"confirm_blacklist");
        [self startIndicatorAnimation];
        [self.blockUserManager blockUser:_userModel.ID];
    } else {
        wrapperTrackEvent(@"profile", @"quit_blacklist");
        wrapperTrackEvent(@"blacklist", @"quit_blacklist");
    }
}

@end
