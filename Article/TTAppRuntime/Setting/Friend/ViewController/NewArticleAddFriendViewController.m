//
//  ArticleAddFriendViewController.m
//  Article
//
//  Created by Zhang Leonardo on 13-12-30.
//
//

#import "NewArticleAddFriendViewController.h"
#import "AddFriendListView.h"
#import "ArticleTitleImageView.h"
#import "ArticleEmptyView.h"
#import "FriendDataManager.h"
#import "ArticleFriendModel.h"
#import "ArticleBadgeManager.h"
#import "ArticleInviteFriendViewController.h"
#import <TTAccountBusiness.h>
#import <TTAddressBookSDK.h>
#import "TTContactsNetworkManager.h"

#import "ArticleMobileNumberViewController.h"
#import "SSNavigationBar.h"
#import "TTAuthorizeManager.h"
#import "UIScrollView+Refresh.h"
#import "UIViewController+Refresh_ErrorHandler.h"
#import "MBProgressHUD.h"

#import "TTRoute.h"
#import "TTContactsUserDefaults.h"

typedef NS_ENUM(NSInteger, GetFriendType){
    GetFriendTypeNormal, //普通刷新
    GetFriendTypeManuallySynchronize, //手动上传通讯录后刷新
    GetFriendTypeGuide // 通过引导，”现在看看“上传通讯录后刷新
};


@interface NewArticleAddFriendViewController ()
<
AddFriendListViewDelegate,
UIViewControllerErrorHandler,
TTAccountMulticastProtocol
>
@property(nonatomic, strong)AddFriendListView *friendListView;
@property(nonatomic, strong)NSMutableArray *joinedFriends;
@property(nonatomic, strong)NSMutableArray *suggestFriends;
@property(nonatomic, strong)FriendDataManager *friendManager;

@property (nonatomic, assign) NSInteger offset;
@property (nonatomic, assign) BOOL isLoading;
@property (nonatomic, assign) BOOL hasLoaded;
@end

@implementation NewArticleAddFriendViewController

+ (void)load {
    RegisterRouteObjWithEntryName(@"addressbook");
}

- (void)dealloc
{
    if (self.isViewLoaded) {
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [TTAccount removeMulticastDelegate:self];
}

- (instancetype)init
{
    self = [super initWithRouteParamObj:nil];
    if(self)
    {
        self.statusBarStyle = SSViewControllerStatsBarDayBlackNightWhiteStyle;
        self.joinedFriends = [NSMutableArray array];
        self.suggestFriends = [NSMutableArray array];
        
        [TTAccount addMulticastDelegate:self];
    }
    
    return self;
}

- (instancetype)initWithRouteParamObj:(TTRouteParamObj *)paramObj
{
    return [self init];
}

#pragma mark - TTAccountMulticastProtocol

- (void)onAccountStatusChanged:(TTAccountStatusChangedReasonType)reasonType platform:(NSString *)platformName
{
    switch (reasonType) {
        case TTAccountStatusChangedReasonTypeLogout:
        case TTAccountStatusChangedReasonTypeSessionExpiration: {
            [_friendManager cancelAllRequests];
            _isLoading = NO;
            [_friendListView stopLoadingInView:self.view];
            
            self.ttViewType = TTFullScreenErrorViewTypeSessionExpired;
            [self tt_endUpdataData:NO error:[NSError errorWithDomain:@"TTErrorDomain" code:kMissingSessionKeyErrorCode userInfo:nil]];
        }
            break;
        case TTAccountStatusChangedReasonTypeAutoSyncLogin:
        case TTAccountStatusChangedReasonTypeFindPasswordLogin:
        case TTAccountStatusChangedReasonTypePasswordLogin:
        case TTAccountStatusChangedReasonTypeSMSCodeLogin:
        case TTAccountStatusChangedReasonTypeEmailLogin:
        case TTAccountStatusChangedReasonTypeTokenLogin:
        case TTAccountStatusChangedReasonTypeSessionKeyLogin:
        case TTAccountStatusChangedReasonTypeAuthPlatformLogin: {
            _offset = 0;
            [self startGetFriendsCausedByPull:NO];
        }
            break;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    self.friendListView = [[AddFriendListView alloc] initWithFrame:self.view.bounds];
    _friendListView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _friendListView.delegate = self;
    [_friendListView.synchornizeButton addTarget:self action:@selector(synchornizeAB:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_friendListView];
    
    if (self.autoSynchronizeAddressBook) {
        [self synchornizeAB:nil];
    }

    wrapperTrackEvent(@"add_friends", @"enter");

    self.navigationItem.titleView = [SSNavigationBar navigationTitleViewWithTitle:NSLocalizedString(@"添加好友", nil)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:[SSNavigationBar navigationButtonOfOrientation:SSNavigationButtonOrientationOfRight withTitle:NSLocalizedString(@"告诉朋友",nil) target:self action:@selector(rightButtonClicked)]];
    
    // 由于允许匿名访问，在未登陆时弹出登录框
    if (![TTAccountManager isLogin]) {
        [self presentAutorityViewController];
    }
}

- (void)presentAutorityViewController
{
    [TTAccountManager showLoginAlertWithType:TTAccountLoginAlertTitleTypeSocial source:@"dongtai_add_friend" completion:^(TTAccountAlertCompletionEventType type, NSString *phoneNum) {
        if (type == TTAccountAlertCompletionEventTypeTip) {
            [TTAccountManager presentQuickLoginFromVC:[TTUIResponderHelper topNavigationControllerFor:self] type:TTAccountLoginDialogTitleTypeDefault source:@"dongtai_add_friend" completion:^(TTAccountLoginState state) {
            }];
        }
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
//    [[ArticleBadgeManager shareManger] clearNeedFollowNumber];
    if([TTAccountManager isLogin]) {
        
        if(!_hasLoaded) {
            [self startGetFriendsCausedByPull:YES];
        }
    }
    else
    {
        self.ttViewType = TTFullScreenErrorViewTypeSessionExpired;
        [self tt_endUpdataData:NO error:[NSError errorWithDomain:@"TTErrorDomain" code:kMissingSessionKeyErrorCode userInfo:nil]];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

#pragma mark - Prompt

- (void)showPromptWithMessage:(NSString *)msg
{
    if (isEmptyString(msg)) {
        return;
    }
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = NSLocalizedString(msg, nil);
}

- (void)dismissPromptWithMessage:(NSString *)msg
{
    [self dismissPromptWithMessage:msg afterDelay:0];
}

- (void)dismissPromptWithMessage:(NSString *)msg afterDelay:(NSTimeInterval)delay
{
    if (delay > 0) {
        [MBProgressHUD hideAllHUDsForView:self.view animated:NO];
        
        MBProgressHUD *HUD = [MBProgressHUD showHUDAddedTo:self.view animated:NO];
        HUD.mode = MBProgressHUDModeCustomView;
        HUD.userInteractionEnabled = NO;
        HUD.cornerRadius = 4;
        UILabel * label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 140, 50)];
        label.backgroundColor = [UIColor clearColor];
        label.font = [UIFont systemFontOfSize:15.];
        label.textColor = [UIColor whiteColor];
        label.numberOfLines = 0;
        label.text = msg;
        [label sizeToFit];
        HUD.margin = 20.;
        HUD.customView = label;
        
        [HUD hide:YES afterDelay:delay];
    } else {
        [MBProgressHUD hideAllHUDsForView:self.view animated:NO];
    }
}

- (void)uploadContactsFailedWithError:(NSError *)error
{
    NSString *errorMsg = error.userInfo[@"description"];
    errorMsg = isEmptyString(errorMsg) ? @"没找到通讯录好友" : errorMsg;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self dismissPromptWithMessage:errorMsg afterDelay:1];
    });
}

#pragma mark UIView+ErrorHandler Stuff

- (BOOL)tt_hasValidateData {
    return _joinedFriends.count > 0 || _suggestFriends.count > 0;
}

- (void)refreshData {
    [self startGetFriendsCausedByPull:YES];
}

- (void)sessionExpiredAction {
    [self presentAutorityViewController];
}

#pragma mark UIView+ErrorHandler Stuff -------

- (void)startGetFriendsCausedByPull:(BOOL) refresh {
    [self startGetFriendsWithDisplaySynchronizeInfo:NO refreshType:GetFriendTypeNormal pull:refresh];
}

- (void)startGetFriendsWithDisplaySynchronizeInfo:(BOOL)displaySynchronizeInfo refreshType:(GetFriendType)refreshType pull:(BOOL) pull {
    @synchronized(self) {
        if(!_friendManager) {
            self.friendManager = [[FriendDataManager alloc] init];
        }
    }
    
    self.ttTargetView = _friendListView.friendView;
    [self tt_startUpdate];
    
    __weak typeof(self) wSelf = self;
    _isLoading = YES;
    [_friendManager startGetJoinFriendsWithOffset:_offset finishBlock:^(NSArray *result, BOOL newAccount, NSInteger newCount, NSInteger originalCount, BOOL hasMore, NSError *error) {
        
        typeof(self) self = wSelf;
        
        NSString *notify = nil;
        
        if(pull)
        {
            [self.friendListView endRefreshing];
            [self.friendListView.friendView finishPullDownWithSuccess:!error];
        }
        else
            [self.friendListView.friendView finishPullUpWithSuccess:!error];
        
        
        self.isLoading = NO;
        if (error) {
            if ([error.domain isEqualToString:kCommonErrorDomain] && error.code == kNoNetworkErrorCode) {
                self.ttViewType = TTFullScreenErrorViewTypeNetWorkError;
            } else {
                if ([error.domain isEqualToString:kCommonErrorDomain]) {
                    if (error.code == kMissingSessionKeyErrorCode) {
                        [self clearAllData];
                        self.ttViewType = TTFullScreenErrorViewTypeSessionExpired;
                    } else if (error.code == kSessionExpiredErrorCode) {
                        [self clearAllData];
//                        [FriendDataManager clearStatistics];
                        self.ttViewType = TTFullScreenErrorViewTypeSessionExpired;
                        notify = kSessionExpiredTipMessage;
                    } else if (error.code == kUserNotExistErrorCode) {
                        notify = [error.userInfo objectForKey:kErrorDisplayMessageKey];
                    } else {
                        notify = [error.userInfo objectForKey:kErrorDisplayMessageKey];
                        if (!notify) {
                            notify = NSLocalizedString(@"获取好友列表失败,请稍后重试", nil);
                        }
                        self.ttViewType = TTFullScreenErrorViewTypeEmpty;
                    }
                } else {
                    self.ttViewType = TTFullScreenErrorViewTypeNetWorkError;
                }
            }
            
            self.friendListView.friendView.hasMore = NO;
        }
        else {
            self.hasLoaded = YES;
            if(self.offset == 0 && result.count > 0) {
                [self clearAllData];
            }
            
            for(ArticleFriendModel *model in result) {
                switch (model.suggestType) {
                    case ArticleFriendSuggestJoinedNone:
                    {}
                        break;
                    case ArticleFriendSuggestJoined:
                    {
                        [self.joinedFriends addObject:model];
                    }
                        break;
                    case ArticleFriendSuggestSuggest:
                    {
                        [self.suggestFriends addObject:model];
                    }
                        break;
                    default:
                        break;
                }
            }
            
            self.offset += originalCount;
            
            self.friendListView.friendView.hasMore = hasMore;
            if(newCount > 0)
            {
                if(displaySynchronizeInfo)
                {
                    notify = [NSString stringWithFormat:NSLocalizedString(@"同步完成，找到%d个新加入的通讯录好友", nil), newCount];
                }
                else
                {
                    notify = [NSString stringWithFormat:NSLocalizedString(@"找到%d个新加入通讯录好友", nil), newCount];
                }
                
                if(refreshType == GetFriendTypeManuallySynchronize)
                {
                    wrapperTrackEvent(@"add_friends", @"found_address_friend");
                }
                else if(refreshType == GetFriendTypeGuide)
                {
                    wrapperTrackEvent(@"add_friends", @"found_friend_now");
                }
            }
            else
            {
                if(displaySynchronizeInfo)
                {
                    notify = NSLocalizedString(@"同步完成，暂时没有新加入的通讯录好友", nil);
                }
                
                if(refreshType == GetFriendTypeManuallySynchronize)
                {
                    wrapperTrackEvent(@"add_friends", @"no_address_friend");
                }
                else if (refreshType == GetFriendTypeGuide)
                {
                    wrapperTrackEvent(@"add_friends", @"no_friend_now");
                }
            }
            if (newAccount) {
                if (newCount == 0) {
                    notify = @"额……没有找到新加入的通讯录好友";
                } else {
                    notify = nil;
                }
            } else {
                if (newCount == 0 && displaySynchronizeInfo) {
                    wrapperTrackEvent(@"add_friends", @"no_new_friend");
                 }
            }
        }
        
        [self tt_endUpdataData:NO error:error];
        
        NSMutableArray *friendsList = [NSMutableArray array];
        NSMutableArray *titles = [NSMutableArray array];
        if(self.joinedFriends.count > 0)
        {
            [friendsList addObject:self.joinedFriends];
            [titles addObject:NSLocalizedString(@"已加入的好友", nil)];
        }
        
        if(self.suggestFriends.count > 0)
        {
            [friendsList addObject:self.suggestFriends];
            [titles addObject:NSLocalizedString(@"值得关注", nil)];
        }
        
        self.friendListView.sectionTitles = titles;
        [self.friendListView reloadFriends:friendsList];
        
        ///...
        if (isEmptyString(notify)) {
            [self dismissPromptWithMessage:notify];
        } else {
            [self dismissPromptWithMessage:notify afterDelay:2];
        }
        
        if(displaySynchronizeInfo && newCount > 0)
        {
            [self.friendListView scrollToTop];
        }
        
        [[TTAuthorizeManager sharedManager].addressObj showAlertAtPageAddFriend:^{
            [self synchornizeAB:nil];
        }];
    }];
}

- (void)startGetFriendsWithDisplaySynchronizeInfo:(BOOL)displaySynchronizeInfo refreshType:(GetFriendType)refreshType {
    [self startGetFriendsWithDisplaySynchronizeInfo:displaySynchronizeInfo refreshType:refreshType pull:NO];
}

- (void)clearAllData
{
    [_joinedFriends removeAllObjects];
    [_suggestFriends removeAllObjects];
}

- (void)rightButtonClicked {
    ArticleInviteFriendViewController * inviteFriendView = [[ArticleInviteFriendViewController alloc] init];
    [[TTUIResponderHelper topNavigationControllerFor: self] pushViewController:inviteFriendView animated:YES];
    wrapperTrackEvent(@"add_friends", @"invite_friend");
}

- (void)addFriendListViewRequestLoadmore {
    [self startGetFriendsCausedByPull:NO];
}

- (void)addFriendListViewRequestRefresh {
    _offset = 0;
    [self startGetFriendsCausedByPull:YES];
}

- (void)synchornizeAB:(id)sender
{
    wrapperTrackEvent(@"add_friends", @"sync_contacts");
    if(![TTAccountManager isLogin]) {
        wrapperTrackEvent(@"add_friends", @"sync_contacts_logoff");
    } else if([TTAddressBook isAddressBookDenied]) {
        wrapperTrackEvent(@"add_friends", @"no_permission");
        TTThemedAlertController *alert = [[TTThemedAlertController alloc] initWithTitle:NSLocalizedString(@"没有访问通讯录权限", nil)
                                                                                message:NSLocalizedString(@"如果要开启此功能，可依次进入［设置－隐私－通讯录］，允许［今日头条］访问手机通讯录", nil)
                                                                          preferredType:TTThemedAlertControllerTypeAlert];
        [alert addActionWithTitle:NSLocalizedString(@"确定", nil)
                       actionType:TTThemedAlertActionTypeCancel
                      actionBlock:nil];
        if (&UIApplicationOpenSettingsURLString != NULL) {
            [alert addActionWithTitle:NSLocalizedString(@"去设置", nil)
                           actionType:TTThemedAlertActionTypeNormal
                          actionBlock:^{
                              NSURL * url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
                              if ([TTDeviceHelper OSVersionNumber] >= 10.0) {
                                  [[UIApplication sharedApplication] openURL:url
                                                                     options:@{}
                                                           completionHandler:nil];
                              }else {
                                  [[UIApplication sharedApplication] openURL:url];
                              }
                          }];
        }
        [alert showFrom:self animated:YES];
    } else if(isEmptyString([TTAccountManager currentUser].mobile)) {
        ArticleMobileNumberViewController * viewController = [[ArticleMobileNumberViewController alloc] initWithMobileNumberUsingType:ArticleMobileNumberUsingTypeBind];
        // 利用当前界面获取通讯录
        WeakSelf;
        viewController.completion = ^(ArticleLoginState state){
            StrongSelf;
            if(state == ArticleLoginStateMobileLogin) {
                [self uploadAB];
            }
        };
        
        [self.navigationController pushViewController:viewController animated:YES];
        
        [viewController showAutoDismissIndicatorWithText:NSLocalizedString(@"请先绑定手机号", nil)];
        
    } else {
        [self uploadAB];
    }
}

- (void)uploadAB {
    WeakSelf;
    [[TTAddressBookService sharedService] loadContactsForProperties:kTTContactsOfPropertiesV2
                                                         startBlock:^{
                                                             dispatch_async(dispatch_get_main_queue(), ^{
                                                                 StrongSelf;
                                                                 [self showPromptWithMessage:NSLocalizedString(@"找呀找朋友...", nil)];
                                                             });
                                                         }
                                                        finishBlock:^(NSArray<TTABContact *> *records, NSError *error) {
                                                            dispatch_async(dispatch_get_main_queue(), ^{
                                                                StrongSelf;
                                                                if (error) {
                                                                    [self uploadContactsFailedWithError:error];
                                                                }else {
                                                                    WeakSelf;
                                                                    [TTContactsNetworkManager postContacts:records
                                                                                                userActive:YES
                                                                                                completion:^(NSError *error, id jsonObj) {
                                                                                                    StrongSelf;
                                                                                                    if (error) {
                                                                                                        [self uploadContactsFailedWithError:error];
                                                                                                    }else {
                                                                                                        [TTContactsUserDefaults setHasUploadedContactsFlagForValue:YES];
                                                                                                        [[self class] cancelPreviousPerformRequestsWithTarget:self selector:@selector(startFetchFriendDataWithType:) object:@(GetFriendTypeManuallySynchronize)];
                                                                                                        [[self class] cancelPreviousPerformRequestsWithTarget:self selector:@selector(startFetchFriendDataWithType:) object:@(GetFriendTypeGuide)];
                                                                                                        [self performSelector:@selector(startFetchFriendDataWithType:) withObject:@(GetFriendTypeManuallySynchronize) afterDelay:1.0];
                                                                                                    }
                                                                                                }];
                                                                }
                                                            });
                                                        }];
}

- (void) startFetchFriendDataWithType:(NSNumber *) type {
    [[self class] cancelPreviousPerformRequestsWithTarget:self selector:@selector(startFetchFriendDataWithType:) object:@(GetFriendTypeManuallySynchronize)];
    [[self class] cancelPreviousPerformRequestsWithTarget:self selector:@selector(startFetchFriendDataWithType:) object:@(GetFriendTypeGuide)];
    _offset = 0;
    [self startGetFriendsWithDisplaySynchronizeInfo:YES refreshType:type.intValue];
}

@end
