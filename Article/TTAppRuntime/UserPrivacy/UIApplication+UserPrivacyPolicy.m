//
//  UIApplication+UserPrivacyPolicy.m
//  Article
//
//  Created by liuzuopeng on 26/01/2018.
//

#import "UIApplication+UserPrivacyPolicy.h"
#import "SSWebViewController.h"
#import "AKHelper.h"
#import "Bubble-Swift.h"

#define TT_USER_PRIVACY_PROTECTION_ADDRESS  @"https://www.toutiao.com/privacy_protection/"


@implementation UIApplication (UserPrivacyPolicy) /** short for `upp` */

+ (void)openUserAgreement
{
    [self openUserAgreementFromViewController:nil useBarHeight:YES];
}

+ (void)openUserAgreementFromViewController:(UINavigationController *)navVC
                               useBarHeight:(BOOL)useBarHeight
{
    [self __upp_openWebViewWithUrl:[NSString stringWithFormat:@"%@/f100/download/user_agreement.html&hide_more=1",EnvContext.networkConfig.host]
                             title:NSLocalizedString(@"好多房用户协议", nil)
                fromViewController:navVC
                   useNavBarHeight:useBarHeight];
}

+ (void)openPrivacyProtection
{
    [self openPrivacyProtectionFromViewController:nil useBarHeight:YES];
}

+ (void)openPrivacyProtectionFromViewController:(UINavigationController *)navVC
                                   useBarHeight:(BOOL)useBarHeight
{
    [self __upp_openWebViewWithUrl:TT_USER_PRIVACY_PROTECTION_ADDRESS
                             title:NSLocalizedString(@"好多房隐私政策", nil)
                fromViewController:navVC
                   useNavBarHeight:useBarHeight];
}

+ (void)__upp_openWebViewWithUrl:(NSString *)urlString
                           title:(NSString *)titleString
              fromViewController:(UINavigationController *)navVC
                 useNavBarHeight:(BOOL)useBarHeight
{
    SSWebViewController *webVC = [[SSWebViewController alloc] init];
    
    if ([webVC respondsToSelector:@selector(setTitleText:)]) {
        [webVC performSelector:@selector(setTitleText:)
                    withObject:titleString];
    }
    if ([webVC respondsToSelector:@selector(setUseSystemNavigationbarHeight:)]) {
        [webVC setValue:@(useBarHeight)
                 forKey:@"useSystemNavigationbarHeight"];
    }
    if ([webVC respondsToSelector:@selector(requestWithURLString:)]) {
        [webVC performSelector:@selector(requestWithURLString:)
                    withObject:urlString];
    }
    
    UINavigationController *topNavVC;
    if ([navVC isKindOfClass:[UINavigationController class]]) topNavVC = navVC;
    UIViewController *topVC = ak_top_vc();
    if (!topNavVC && [topVC isKindOfClass:[UINavigationController class]]) {
        topNavVC = (UINavigationController *)topVC;
    }
    if (!topNavVC && topVC.navigationController) {
        topNavVC = topVC.navigationController;
    }
    if (!topNavVC) {
        topNavVC = [TTUIResponderHelper topNavigationControllerFor:nil];
    }
    topNavVC.navigationBarHidden = NO;
    [topNavVC pushViewController:webVC animated:YES];
}

@end
