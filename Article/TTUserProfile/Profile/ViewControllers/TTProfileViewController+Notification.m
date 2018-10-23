//
//  TTProfileViewController+Notification.m
//  Article
//
//  Created by yuxin on 7/20/15.
//
//


#import "TTProfileViewController+Notification.h"
#import "TTNavigationController.h"
#import "TTProfileFunctionCell.h"

#import <TTAccountBusiness.h>
#import "TTThirdPartyAccountsHeader.h"
#import "ArticleBadgeManager.h"
#import "PGCAccountManager.h"
#import "TTSettingMineTabGroup.h"
#import "TTSettingMineTabManager.h"
#import "TTSettingMineTabEntry.h"
#import "ArticleFetchSettingsManager.h"
#import "SSWebViewController.h"

//push to next VC
#import "SSFeedbackViewController.h"
#import "TTIndicatorView.h"
#import "TTDeviceHelper.h"
#import "TTThemeManager.h"
#import "TTBaseMacro.h"
#import "UIImage+TTThemeExtension.h"

@implementation TTProfileViewController (Notification)

- (void)registerNotifications
{
    [TTAccount addMulticastDelegate:self];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reportSSEditUserProfileViewAvatarChangedNotification:) name:SSEditUserProfileViewAvatarChangedNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveMineTabbarClickedNotification:) name:kMineTabbarKeepClickedNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reportArticleBadgeManagerRefreshedNotification:) name:kArticleBadgeManagerRefreshedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pgcAccountChangedNotification:) name:kLoginPGCAccountChangedNotification object:nil];
    
    [[TTThemeManager sharedInstance_tt] addObserver:self forKeyPath:@"currentMode" options:NSKeyValueObservingOptionNew context:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(customThemeChanged:)
                                                 name:TTThemeManagerThemeModeChangedNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ttSettingMineTabManagerRefreshedNotification:) name:kTTSettingMineTabManagerRefreshedNotification object:nil];
}

- (void)reportAccountBoundForbidAlertShowNotification:(NSNotification *)notification
{
    if ([TTDeviceHelper isPadDevice]) {
    } else {
        SSWebViewController * controller = [[SSWebViewController alloc] init];
        NSString * aidStr = isEmptyString([TTSandBoxHelper ssAppID]) ? @"" : [NSString stringWithFormat:@"&aid=%@",[TTSandBoxHelper ssAppID]];
        NSString * urlStr = [NSString stringWithFormat:@"%@?app_name=%@&device_platform=iphone%@", [CommonURLSetting feedbackFAQURLString], [TTSandBoxHelper appName], aidStr];
        urlStr = [NSString stringWithFormat:@"%@#faq-76", urlStr];
        [controller requestWithURLString:urlStr];
        
        TTNavigationController * nav = [[TTNavigationController alloc] initWithRootViewController: controller];
        nav.ttDefaultNavBarStyle = @"White";
        
        [self presentViewController:nav animated:YES completion:nil];
        [controller setDismissType:SSWebViewDismissTypePresent];
        [controller setTitleText:NSLocalizedString(@"常见问题", nil)];
    }
}

- (void)receiveMineTabbarClickedNotification:(NSNotification *)notification
{
    [self.tableView setContentOffset:CGPointMake(0,-self.tableView.contentInset.top) animated:YES];
}

- (void)reportSSEditUserProfileViewAvatarChangedNotification:(NSNotification*)notification
{
    [self reloadTableViewLater];
}

#pragma mark - TTAccountMulticastProtocol

- (void)onAccountStatusChanged:(TTAccountStatusChangedReasonType)reasonType platform:(NSString *)platformName
{
    [self updateHeaderControls];
    [self refreshUserInfoView];
    [self refreshCommonwealView];
    
    if ([TTSettingMineTabManager sharedInstance_tt].reloadSectionsIfNeeded) {
        [self reloadTableViewLater];
    }
    
    if (platformName) {
        // 统计
        if ([platformName isEqualToString:PLATFORM_SINA_WEIBO]) {
            wrapperTrackEvent(@"mine_tab", @"login_sina_success");
        } else if ([platformName isEqualToString:PLATFORM_QZONE]) {
            wrapperTrackEvent(@"mine_tab", @"login_qzone_success");
        } else if ([platformName isEqualToString:PLATFORM_WEIXIN]) {
            wrapperTrackEvent(@"mine_tab", @"login_weixin_success");
        }
    }
}

- (void)onAccountUserProfileChanged:(NSDictionary *)changedFields error:(NSError *)error
{
    if (!error) {
        [self updateHeaderControls];
        [self refreshUserInfoView];
    }
}

- (void)onAccountGetUserInfo
{
    [self updateHeaderControls];
    [self refreshUserInfoView];
}

- (void)pgcAccountChangedNotification:(NSNotification *)notification
{
    if ([TTSettingMineTabManager sharedInstance_tt].reloadSectionsIfNeeded) {
        [self reloadTableViewLater];
    }
}

- (void)reportArticleBadgeManagerRefreshedNotification:(NSNotification *)notification {
    dispatch_main_async_safe(^{
        [[TTSettingMineTabManager sharedInstance_tt] reloadSectionsIfNeeded];
        [self reloadTableViewLater];
    })
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    [self reloadTableViewLater];
}

- (void)applicationDidBecomeActive:(NSNotification *)notification
{
    [self refreshUserInfoView];
}

- (void)customThemeChanged:(NSNotification *)notification {
    if ([TTDeviceHelper isPadDevice]) {
        [self.tableView reloadData];
    }
}

- (void)ttSettingMineTabManagerRefreshedNotification:(NSNotification *)notification{
    [self reloadTableViewLater];
}

@end
