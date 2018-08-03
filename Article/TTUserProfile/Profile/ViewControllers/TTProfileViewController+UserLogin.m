//
//  TTProfileViewController+UserLogin.m
//  Article
//
//  Created by yuxin on 7/20/15.
//
//

#import "TTProfileViewController+UserLogin.h"
#import <TTAccountBusiness.h>
#import "ArticleBadgeManager.h"
#import "PGCAccountManager.h"
#import "TTSettingMineTabGroup.h"
#import "TTSettingMineTabManager.h"
#import "TTSettingMineTabEntry.h"
#import "ArticleFetchSettingsManager.h"
#import "TTThirdPartyAccountsHeader.h"
#import "SSWebViewController.h"
#import "ArticleMobileLoginViewController.h"
#import "ArticleAddressBridger.h"
#import "TTEditUserProfileViewController.h"

#import "AKProfileHeaderView.h"
#import "AKProfileBenefitModel.h"
#import "AKProfileBenefitManager.h"
#import "AKProfileHeaderBeneficialButton.h"
#import <TTNetworkManager.h>
@implementation TTProfileViewController (UserLogin)

- (void)beneficalButtonClickedWithModel:(AKProfileBenefitModel *)model beneficButton:(AKProfileHeaderBeneficialButton *)button
{
    [[AKProfileBenefitManager shareInstance] trackForBenefitKey:button.benefitType hasTip:model.reddotInfo.needShow.boolValue];
    if (model.reddotInfo.needShow.boolValue) {
        model.reddotInfo.needShow = @NO;
        [[AKProfileBenefitManager shareInstance] postBadgeUpdateNotification];
        [button refreshContentWithModel:model];
        [[TTNetworkManager shareInstance] requestForJSONWithURL:model.reddotInfo.postUrl params:nil method:@"POST" needCommonParams:YES callback:^(NSError *error, id jsonObj) {
            if (error) {
                //再发一次
                [[TTNetworkManager shareInstance] requestForJSONWithURL:model.reddotInfo.postUrl params:nil method:@"GET" needCommonParams:YES callback:^(NSError *error, id jsonObj) {
                    [self updateHeaderBenefitInfo];
                }];
            } else {
                [self updateHeaderBenefitInfo];
            }
        }];
    }
    if (!isEmptyString(model.openURL)) {
        NSURL *url = [[NSURL alloc] initWithString:model.openURL];
        if ([[TTRoute sharedRoute] canOpenURL:url]) {
            [[TTRoute sharedRoute] openURLByPushViewController:url];
        }
    }
}

- (void)infoViewRegionClicked
{
    if([TTAccountManager isLogin]) {
        TTEditUserProfileViewController *profileVC = [TTEditUserProfileViewController new];
        profileVC.userType = [TTAccountManager accountUserType];
        profileVC.delegate = self;
        
        UINavigationController *navController = [TTUIResponderHelper topNavigationControllerFor:self];
        [navController pushViewController:profileVC animated:YES];
    }
}

- (void)loginButtonClicked:(NSString *)platform
{
    if ([platform isEqualToString:PLATFORM_WEIXIN]) {
        [self weixinButtonClicked:nil];
    } else if ([platform isEqualToString:@"profile_more_login"]) {
        [self moreButtonClicked:nil];
    }
}

- (void)phoneButtonClicked:(id)sender
{
    // LogV1
    if (![TTTrackerWrapper isOnlyV3SendingEnable]) {
        wrapperTrackEvent(@"mine_tab", @"login_mobile");
    }
    // LogV3
    NSMutableDictionary *extraDict = [NSMutableDictionary dictionaryWithCapacity:2];
    [extraDict setValue:@"mine_tab" forKey:@"source"];
    [extraDict setValue:@"mobile" forKey:@"action_type"];
    [TTTrackerWrapper eventV3:@"login_mine_tab_click" params:extraDict isDoubleSending:YES];
    
    //跳转至登录页
    [TTAccountManager presentQuickLoginFromVC:self.navigationController type:TTAccountLoginDialogTitleTypeRegister source:@"mine" isPasswordStyle:NO completion:^(TTAccountLoginState state) {

    }];
}

- (void)weixinButtonClicked:(id)sender
{
    // LogV1
    if (![TTTrackerWrapper isOnlyV3SendingEnable]) {
        wrapperTrackEvent(@"mine_tab", @"login_weixin");
    }
    // LogV3
    NSMutableDictionary *extraDict = [NSMutableDictionary dictionaryWithCapacity:2];
    [extraDict setValue:@"mine_tab" forKey:@"source"];
    [extraDict setValue:@"weixin" forKey:@"action_type"];
    [TTTrackerWrapper eventV3:@"login_mine_tab_click" params:extraDict isDoubleSending:YES];
    
    [TTAccountLoginManager requestLoginPlatformByName:PLATFORM_WEIXIN completion:^(BOOL success, NSError * _Nonnull error) {
        if (success) {
            // LogV3
            NSMutableDictionary *extraDict = [NSMutableDictionary dictionaryWithCapacity:2];
            [extraDict setValue:@"mine_tab" forKey:@"source"];
            [extraDict setValue:@"weixin" forKey:@"type"];
            [TTTrackerWrapper eventV3:@"login_mine_tab_success" params:extraDict isDoubleSending:YES];
        }
    }];
}

- (void)huoshanButtonClicked:(id)sender
{
    // LogV3
    NSMutableDictionary *extraDict = [NSMutableDictionary dictionaryWithCapacity:2];
    [extraDict setValue:@"mine_tab" forKey:@"source"];
    [extraDict setValue:@"hotsoon" forKey:@"action_type"];
    [TTTrackerWrapper eventV3:@"login_mine_tab_click" params:extraDict];
    
    [TTAccountLoginManager requestLoginPlatformByName:PLATFORM_HUOSHAN completion:^(BOOL success, NSError * _Nonnull error) {
        if (success) {
            // LogV3
            NSMutableDictionary *extraDict = [NSMutableDictionary dictionaryWithCapacity:2];
            [extraDict setValue:@"mine_tab" forKey:@"source"];
            [extraDict setValue:@"hotsoon" forKey:@"type"];
            [TTTrackerWrapper eventV3:@"login_mine_tab_success" params:extraDict];
        }
    }];
}

- (void)douyinButtonClicked:(id)sender
{
    // LogV3
    NSMutableDictionary *extraDict = [NSMutableDictionary dictionaryWithCapacity:2];
    [extraDict setValue:@"mine_tab" forKey:@"source"];
    [extraDict setValue:@"douyin" forKey:@"action_type"];
    [TTTrackerWrapper eventV3:@"login_mine_tab_click" params:extraDict];
    
    [TTAccountLoginManager requestLoginPlatformByName:PLATFORM_DOUYIN completion:^(BOOL success, NSError * _Nonnull error) {
        if (success) {
            // LogV3
            NSMutableDictionary *extraDict = [NSMutableDictionary dictionaryWithCapacity:2];
            [extraDict setValue:@"mine_tab" forKey:@"source"];
            [extraDict setValue:@"douyin" forKey:@"type"];
            [TTTrackerWrapper eventV3:@"login_mine_tab_success" params:extraDict];
        }
    }];
}

- (void)qqButtonClicked:(id)sender
{
    // LogV1
    if (![TTTrackerWrapper isOnlyV3SendingEnable]) {
        wrapperTrackEvent(@"mine_tab", @"login_qzone");
    }
    // LogV3
    NSMutableDictionary *extraDict = [NSMutableDictionary dictionaryWithCapacity:2];
    [extraDict setValue:@"mine_tab" forKey:@"source"];
    [extraDict setValue:@"qq" forKey:@"action_type"];
    [TTTrackerWrapper eventV3:@"login_mine_tab_click" params:extraDict isDoubleSending:YES];
    
    [TTAccountLoginManager requestLoginPlatformByName:PLATFORM_QZONE completion:^(BOOL success, NSError * _Nonnull error) {
        if (success) {
            // LogV3
            NSMutableDictionary *extraDict = [NSMutableDictionary dictionaryWithCapacity:2];
            [extraDict setValue:@"mine_tab" forKey:@"source"];
            [extraDict setValue:@"qq" forKey:@"type"];
            [TTTrackerWrapper eventV3:@"login_mine_tab_success" params:extraDict isDoubleSending:YES];
        }
    }];
}

//- (void)sinaButtonClicked:(id)sender
//{
//    // LogV1
//    if (![TTTrackerWrapper isOnlyV3SendingEnable]) {
//        wrapperTrackEvent(@"mine_tab", @"login_sina");
//    }
//    // LogV3
//    NSMutableDictionary *extraDict = [NSMutableDictionary dictionaryWithCapacity:2];
//    [extraDict setValue:@"mine_tab" forKey:@"source"];
//    [extraDict setValue:@"sinaweibo" forKey:@"action_type"];
//    [TTTrackerWrapper eventV3:@"login_mine_tab_click" params:extraDict isDoubleSending:YES];
//
//    NSString *platform = PLATFORM_SINA_WEIBO;
//    if (![TTAccountAuthWeibo isSupportSSO]){
//        platform = @"sina_weibo";
//    }
//
//    [TTAccountLoginManager requestLoginPlatformByName:platform completion:^(BOOL success, NSError * _Nonnull error) {
//        if (success) {
//            // LogV3
//            NSMutableDictionary *extraDict = [NSMutableDictionary dictionaryWithCapacity:2];
//            [extraDict setValue:@"mine_tab" forKey:@"source"];
//            [extraDict setValue:@"sinaweibo" forKey:@"type"];
//            [TTTrackerWrapper eventV3:@"login_mine_tab_success" params:extraDict isDoubleSending:YES];
//        }
//    }];
//}

- (void)moreButtonClicked:(id)sender
{
    if ([TTAccountManager isLogin]) {
        [self openProfileViewControllerWithSource:@"arrow"];
    } else {
        // LogV1
        if (![TTTrackerWrapper isOnlyV3SendingEnable]) {
            wrapperTrackEvent(@"mine_tab", @"login_more");
        }
        // LogV3
        NSMutableDictionary *extraDict = [NSMutableDictionary dictionaryWithCapacity:2];
        [extraDict setValue:@"mine_tab" forKey:@"source"];
        [extraDict setValue:@"more" forKey:@"action_type"];
        [TTTrackerWrapper eventV3:@"login_mine_tab_click" params:extraDict isDoubleSending:YES];
        
        [TTAccountManager presentQuickLoginFromVC:self.navigationController type:TTAccountLoginDialogTitleTypeRegister source:@"mine" isPasswordStyle:NO completion:^(TTAccountLoginState state) {
            
        }];
    }
}

- (IBAction)headerContainerTapped:(UIGestureRecognizer*)recognizer
{
    [self openProfileViewControllerWithSource:@"name"];
}

- (void)openProfileViewControllerWithSource:(NSString *)source
{
    
}

#pragma mark - TTEditUserProfileViewControllerDelegate

- (BOOL)hideDescriptionCellInEditUserProfileController:(TTEditUserProfileViewController *)aController {
    return NO;
}

- (void)editUserProfileController:(TTEditUserProfileViewController *)aController goBack:(id)sender {
    if (![TTAccountManager isLogin]) {
        UINavigationController *nav = nil;
        UIViewController *topController = [TTUIResponderHelper topNavigationControllerFor:self];
        if ([topController isKindOfClass:[UINavigationController class]]) {
            nav = (UINavigationController *)topController;
        } else {
            nav = topController.navigationController;
        }
        [nav popToRootViewControllerAnimated:YES];
    } else {
        UINavigationController *nav = [TTUIResponderHelper topViewControllerFor: aController].navigationController;
        [nav popViewControllerAnimated:YES];
    }
}

@end
