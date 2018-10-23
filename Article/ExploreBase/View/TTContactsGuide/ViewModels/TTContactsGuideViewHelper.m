//
//  TTContactsGuideViewModel.m
//  Article
//
//  Created by Zuopeng Liu on 7/24/16.
//
//

#import "TTContactsGuideViewHelper.h"
#import <TTBaseLib/NSObject+TTAdditions.h>
#import <MBProgressHUD/MBProgressHUD.h>
#import <TTBaseLib/TTUIResponderHelper.h>
#import <TTBaseLib/TTDeviceUIUtils.h>
#import <TTNetworkManager/TTNetworkManager.h>
#import <TTUIWidget/TTNavigationController.h>
#import "TTNPopupView.h"
#import "TTContactsNetworkManager.h"
#import <TTAddressBookSDK.h>
#import "TTABAuthorizationManager.h"
#import "TTGuideDispatchManager.h"
#import "TTABContact.h"
#import "TTContactsAddFriendsViewController.h"
#import "TTContactsUserDefaults.h"
#import <TTThemedAlertController.h>
#import <TTDialogDirector/TTDialogDirector.h>
#import "TTContactsGuideManager.h"
#import <TTFollowManager.h>

static BOOL kHasGuideViewDisplayed = NO;

@interface TTContactsGuideViewHelper ()

@property (nonatomic, strong) TTNPopupView *contactsView;

@end

@implementation TTContactsGuideViewHelper

+ (BOOL)hasGuideViewDisplayedAfterLaunching {
    return kHasGuideViewDisplayed;
}

- (void)dealloc {
    _contactsView = nil;
}

- (instancetype)init {
    if ((self = [super init])) {
        if ([self shouldDisplay:nil]) {
            // 1. get dialog texts
            NSDictionary *dialogTexts = [TTContactsUserDefaults contactDialogTexts];
            if ([TTThemeManager sharedInstance_tt].currentThemeMode == TTThemeModeDay && dialogTexts[TTContactsDialogStyleImageURLKey]) {
                _contactsView = [[TTNPopupView alloc] initWithFrame:CGRectZero imageURL:[NSURL URLWithString:dialogTexts[TTContactsDialogStyleImageURLKey]] title:dialogTexts[TTContactsDialogStyleMinorTextKey] content:dialogTexts[TTContactsDialogStyleMajorTextKey] description:dialogTexts[TTContactsDialogStylePrivacyTextKey] confirmButtonTitle:dialogTexts[TTContactsDialogStyleButtonTextKey] otherButtonTitles:nil];
            } else if ([TTThemeManager sharedInstance_tt].currentThemeMode == TTThemeModeNight && dialogTexts[TTContactsDialogStyleNightImageURLKey]) {
                _contactsView = [[TTNPopupView alloc] initWithFrame:CGRectZero imageURL:[NSURL URLWithString:dialogTexts[TTContactsDialogStyleNightImageURLKey]] title:dialogTexts[TTContactsDialogStyleMinorTextKey] content:dialogTexts[TTContactsDialogStyleMajorTextKey] description:dialogTexts[TTContactsDialogStylePrivacyTextKey] confirmButtonTitle:dialogTexts[TTContactsDialogStyleButtonTextKey] otherButtonTitles:nil];
            } else {
                _contactsView = [[TTNPopupView alloc] initWithFrame:CGRectZero image:[UIImage imageNamed:dialogTexts[TTContactsDialogStyleImageNameKey]] title:dialogTexts[TTContactsDialogStyleMinorTextKey] content:dialogTexts[TTContactsDialogStyleMajorTextKey] description:dialogTexts[TTContactsDialogStylePrivacyTextKey] confirmButtonTitle:dialogTexts[TTContactsDialogStyleButtonTextKey] otherButtonTitles:nil];
            }
            _contactsView.touchDismissEnabled = NO;
            __weak typeof(self) wself = self;
            _contactsView.didDismissHandler = ^(NSInteger idx) {
                __strong typeof(wself) sself = wself;
             
                if (idx >= 0) { // 点击现在看看
                    [[sself class] uploadContactsFromAddFriendViewController:NO];

                    // 自定义的通讯录框授权后，开始电信取号
                    // [TTTelecomManager getMobile];
                } else { // 点击取消【关闭】
                    [TTTrackerWrapper eventV3:@"upload_concat_list_guide_click" params:@{
                        @"action_type" : @"cancel",
                        @"frequency" : @([[TTContactsGuideManager sharedManager] contactsGuidePresentingTimes])
                    }];
                    [TTABAuthorizationManager setAuthorizationStatusForValue:kTTABAuthorizationStatusDenied];

                    [sself.class removeAddressBookNotifications];
                }
                
                // 显示完成，通知显示下一个
                [TTDialogDirector dequeueDialog:sself];
            };
        }

        [self.class addAddressBookNotifications];
    }
    return self;
}

#pragma mark - notifications

+ (void)addAddressBookNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:[self class] selector:@selector(addressBookRequestAccess:) name:TTAddressBookRequestAccessNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:[self class] selector:@selector(addressBookRequestAccessGranted:) name:TTAddressBookRequestAccessGrantedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:[self class] selector:@selector(addressBookRequestAccessDenied:) name:TTAddressBookRequestAccessDeniedNotification object:nil];
}

+ (void)removeAddressBookNotifications
{
    [[NSNotificationCenter defaultCenter] removeObserver:[self class]];
}

+ (void)addressBookRequestAccess:(NSNotification *)notification {
    [TTTrackerWrapper eventV3:@"upload_concat_list_permission_show" params:@{
        @"frequency" : @([[TTContactsGuideManager sharedManager] contactsGuidePresentingTimes])
    }];
}

+ (void)addressBookRequestAccessGranted:(NSNotification *)notification {
    [TTTrackerWrapper eventV3:@"upload_concat_list_permission_click" params:@{
        @"action_type": @"confirm",
        @"frequency" : @([[TTContactsGuideManager sharedManager] contactsGuidePresentingTimes])
    }];

    [[NSNotificationCenter defaultCenter] removeObserver:[self class]];
}

+ (void)addressBookRequestAccessDenied:(NSNotification *)notification {
    [TTTrackerWrapper eventV3:@"upload_concat_list_permission_click" params:@{
        @"action_type": @"cancel",
        @"frequency" : @([[TTContactsGuideManager sharedManager] contactsGuidePresentingTimes])
    }];

    [[NSNotificationCenter defaultCenter] removeObserver:[self class]];
}

+ (void)showDoneHud {
    // 延时为了错开 indicatorView 隐藏动画
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^(void) {
        MBProgressHUD *doneHud = [MBProgressHUD showHUDAddedTo:[TTUIResponderHelper mainWindow] animated:YES];
        doneHud.mode = MBProgressHUDModeText;
        doneHud.removeFromSuperViewOnHide = YES;
        doneHud.labelFont = [UIFont systemFontOfSize:[TTDeviceUIUtils tt_padding:14.f]];
        doneHud.labelText = @"同步成功";
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t) (0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^(void) {
            [doneHud hide:YES];

            // 用户只有在推荐频道上传通讯录逻辑失败，加 sfl 参数，第一刷显示好友正在读标签
            [[NSNotificationCenter defaultCenter] postNotificationName:kMainTabbarKeepClickedNotification object:nil userInfo:@{
                kMainTabbarClickedNotificationUserInfoShowFriendLabelKey : @YES
            }];
        });
    });
}

+ (void)requestContactFriends:(BOOL)fromAddFriendViewController {
    FRUserRelationContactfriendsRequestModel *requestModel = [[FRUserRelationContactfriendsRequestModel alloc] init];
    if (fromAddFriendViewController) {
        requestModel.auto_follow = @0;
    } else {
        requestModel.auto_follow = @1;
    }

    WeakSelf;
    FRMonitorNetworkModelFinishBlock block = ^(NSError *error, NSObject<TTResponseModelProtocol> *responseModel, FRForumMonitorModel *monitorModel) {
        StrongSelf;
        if (error) {
            [TTTrackerWrapper eventV3:@"upload_concat_list_status_show" params:@{
                                                                                 @"type" : @"failure",
                                                                                 @"reason" : @2001,
                                                                                 @"frequency" : @([[TTContactsGuideManager sharedManager] contactsGuidePresentingTimes])
                                                                                 }];
            
            [[self class] showDoneHud];
            return;
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kUploadContactsSuccessForInvitePageNotification object:nil];
        
        FRUserRelationContactfriendsResponseModel *model = (FRUserRelationContactfriendsResponseModel *)responseModel;
        
        if (model && model.data && model.data.users && model.data.users.count > 0) {
            [[NSNotificationCenter defaultCenter] postNotificationName:kPresentAddFriendsViewNotification object:nil userInfo:@{
                                                                                                                                @"users" : model.data.users,
                                                                                                                                @"from_add_friend_view_controller" : @(fromAddFriendViewController)
                                                                                                                                }];
        } else {
            [TTTrackerWrapper eventV3:@"upload_concat_list_status_show" params:@{
                                                                                 @"type" : @"failure",
                                                                                 @"reason" : @2002,
                                                                                 @"frequency" : @([[TTContactsGuideManager sharedManager] contactsGuidePresentingTimes])
                                                                                 }];
            
            [[self class] showDoneHud];
        }
    };
    
    if (requestModel.auto_follow.boolValue) {
        [[TTFollowManager sharedManager] tt_requestWrapperChangedUsersFollowStateModel:requestModel
                                                                            actionType:FriendActionTypeFollow
                                                                         responseClass:[FRUserRelationContactfriendsResponseModel class]
                                                                               keypath:@keypath(FRUserRelationContactfriendsResponseModel.new, data.users)
                                                                        finalClassPair:@{NSStringFromClass([FRUserRelationContactFriendsUserStructModel class]) : @keypath(FRUserRelationContactFriendsUserStructModel.new, user_id)}
                                                                            completion:block];
    } else {
        [FRRequestManager requestModel:requestModel callBackWithMonitor:block];
    }
}

+ (void)uploadContactsFromAddFriendViewController:(BOOL)fromAddFriendViewController {
    [TTContactsGuideViewHelper uploadContactsFromAddFriendViewController:fromAddFriendViewController showTipsIfDenied:NO];
}

+ (void)uploadContactsFromAddFriendViewController:(BOOL)fromAddFriendViewController showTipsIfDenied:(BOOL)showTips {
    void (^TTUploadContactsBlock)(void (^)(), void(^)(NSError *), void (^)(NSError *)) = ^(void (^TTWillRequestAddressBook)(), void (^TTDidAccessAddressBook)(NSError *error), void (^TTDidFinishUploading)(NSError *)) {
        // read and upload contacts
        [[TTAddressBookService sharedService] loadContactsForProperties:kTTContactsOfPropertiesV2 startBlock:TTWillRequestAddressBook finishBlock:^(NSArray<TTABContact *> *records, NSError *error) {
            if (TTDidAccessAddressBook) TTDidAccessAddressBook(error); // access address book

            if (!error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    // upload addressbook
                    [TTContactsNetworkManager postContacts:records userActive:YES completion:^(NSError *error2, id jsonObj) {
                        if (!error2) {
                            [TTContactsUserDefaults setHasUploadedContacts:YES];
                        }

                        if (TTDidFinishUploading) TTDidFinishUploading(error2);
                    }];
                });
            } else {
                if (TTDidFinishUploading) TTDidFinishUploading(error);
            }
        }];
    };

    [TTTrackerWrapper eventV3:@"upload_concat_list_guide_click" params:@{
        @"action_type": @"confirm",
        @"frequency" : @([[TTContactsGuideManager sharedManager] contactsGuidePresentingTimes])
    }];

    [TTABAuthorizationManager setAuthorizationStatusForValue:kTTABAuthorizationStatusAuthorized];

    NSTimeInterval threshold = 5.f;
    __block BOOL isUploadContactsFinished = NO;
    __block BOOL isTimeIntervalOverThreshold = NO;

    // 上传通讯录
    TTUploadContactsBlock(^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [TTTrackerWrapper eventV3:@"upload_concat_list_status_show" params:@{
                @"type": @"loading",
                @"frequency" : @([[TTContactsGuideManager sharedManager] contactsGuidePresentingTimes])
            }];

            // 一直保留显示，直到上传成功或者重试之后
            [[TTContactsGuideManager sharedManager] showIndicatorView:@"同步中"];
        });
    }, ^(NSError *error) {
        if (!error) { // 这里采用折衷方案，采用数据导入之后开始计时
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(threshold * NSEC_PER_SEC)), dispatch_get_main_queue(), ^(void) {
                isTimeIntervalOverThreshold = YES;

                if (!isUploadContactsFinished) {
                    [TTContactsUserDefaults setUserCompleteUploadContacts];
                    [[TTContactsGuideManager sharedManager] hideIndicatorView];
                    [[self class] showDoneHud];

                    [TTTrackerWrapper eventV3:@"upload_concat_list_status_show" params:@{
                        @"type" : @"failure",
                        @"reason" : @5000,
                        @"frequency" : @([[TTContactsGuideManager sharedManager] contactsGuidePresentingTimes])
                    }];
                }
            });
        }
    }, ^(NSError *error) {
        if (!error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [TTTrackerWrapper eventV3:@"upload_concat_list_status_show" params:@{
                    @"type": @"success",
                    @"frequency" : @([[TTContactsGuideManager sharedManager] contactsGuidePresentingTimes])
                }];

                [[TTContactsGuideManager sharedManager] hideIndicatorView];

                if (!isTimeIntervalOverThreshold) {
                    [TTContactsUserDefaults setUserCompleteUploadContacts];
                    isUploadContactsFinished = YES; // 如果未超时，阻止超时策略

                    [[self class] requestContactFriends:fromAddFriendViewController];
                }
            });
        } else if (error.code == kTTAddressBookErrorUserToBeDenied) { // 用户拒绝授权
            return;
        } else if (error.code == kTTAddressBookErrorDenied || (showTips && error.code == 1)) { // 授权失败
            TTThemedAlertController *alert = [[TTThemedAlertController alloc] initWithTitle:NSLocalizedString(@"没有访问通讯录权限", nil)
                                                                                    message:NSLocalizedString(@"如果要开启此功能，可依次进入［设置－隐私－通讯录］，允许［爱看］访问手机通讯录", nil)
                                                                              preferredType:TTThemedAlertControllerTypeAlert];
            [alert addActionWithTitle:NSLocalizedString(@"确定", nil)
                           actionType:TTThemedAlertActionTypeCancel
                          actionBlock:nil];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunguarded-availability"
            if (&UIApplicationOpenSettingsURLString != NULL) {
#pragma clang diagnostic pop
                [alert addActionWithTitle:NSLocalizedString(@"去设置", nil)
                               actionType:TTThemedAlertActionTypeNormal
                              actionBlock:^{
                                  NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
                                  if ([TTDeviceHelper OSVersionNumber] >= 10.0) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunguarded-availability"
                                      [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
#pragma clang diagnostic pop
                                  } else {
                                      [[UIApplication sharedApplication] openURL:url];
                                  }
                              }];
            }
            [alert showFrom:[TTUIResponderHelper topmostViewController] animated:YES];
            return;
        } else {
            // 重试一次上传
            TTUploadContactsBlock(nil, nil, ^(NSError *error2){
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[TTContactsGuideManager sharedManager] hideIndicatorView];

                    if (!isTimeIntervalOverThreshold) {
                        [TTContactsUserDefaults setUserCompleteUploadContacts];
                        isUploadContactsFinished = YES; // 如果未超时，阻止超时策略

                        if (!error2) {
                            [TTTrackerWrapper eventV3:@"upload_concat_list_status_show" params:@{
                                @"type": @"success"
                            }];
                            [[self class] requestContactFriends:fromAddFriendViewController];
                        } else {
                            [TTTrackerWrapper eventV3:@"upload_concat_list_status_show" params:@{
                                @"type": @"failure",
                                @"reason" : @1051,
                                @"frequency" : @([[TTContactsGuideManager sharedManager] contactsGuidePresentingTimes])
                            }];

                            [[self class] showDoneHud];
                        }
                    }
                });
            });
        }
    });
}

#pragma mark - TTGuideProtocol

- (TTGuidePriority)priority {
    return kTTGuidePriorityHigh;
}

- (BOOL)shouldDisplay:(id)context {
    if (![[TTContactsGuideManager sharedManager] isUserStayInExploreMainViewController]) { // 停留在首页
        return NO;
    }

    if (![[TTContactsGuideManager sharedManager] isCurrentExploreCategoryIdEqualsToMainCategoryId]) { // 停留在推荐频道
        return NO;
    }

    return [[TTContactsGuideManager sharedManager] shouldPresentContactsGuideView];
}

- (void)showWithContext:(id)context {
    [TTDialogDirector enqueueShowDialog:self shouldShowMe:^BOOL(BOOL * _Nullable keepAlive) {
        return [self shouldDisplay:context];
    } showMe:^(id  _Nonnull dialogInst) {
        
        kHasGuideViewDisplayed = YES;
        
        // 记录此次通讯录弹窗已经弹出过，作为此次的服务端检查数据就此终止
        [[TTContactsGuideManager sharedManager] setContactsGuideHasPresented];
        
        // 记录通讯录弹窗弹出时间
        [TTContactsUserDefaults setContactsGuidePresentTimestamp:[[NSDate date] timeIntervalSince1970]];
        
        [_contactsView showWithCompletion:^{
            [TTTrackerWrapper eventV3:@"upload_concat_list_guide_show" params:@{
                                                                                @"type" : @"0",
                                                                                @"frequency" : @([[TTContactsGuideManager sharedManager] contactsGuidePresentingTimes])
                                                                                }];
        }];
    } hideForcedlyMe:nil];
}

- (void)hideInstantlyMe {
    [_contactsView dismiss];
}

- (id)context {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setContext:(id)context {
    objc_setAssociatedObject(self, @selector(context), context, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
