//
//  TTAccountManager+LoginPanelPresentor.m
//  Article
//
//  Created by liuzuopeng on 28/05/2017.
//
//

#import "TTAccountManager.h"
#import <TTAccountLoginManager.h>
#import <TTUIResponderHelper.h>
#import <TTModuleBridge.h>
#import "TTAccountManager+HTSAccountBridge.h"



@implementation TTAccountManager (LoginPanelPresentor)

+ (UIViewController *)_validLoginPresentingViewController:(UIViewController *)vc
{
    UIViewController *validVC = vc;
    if (!vc) {
        validVC = [TTUIResponderHelper topmostViewController];
    } else if (![vc isKindOfClass:[UIViewController class]]) {
        if ([vc isKindOfClass:[UIView class]]) {
            validVC = [TTUIResponderHelper topViewControllerFor:(UIView *)vc];
        } else {
            validVC = [TTUIResponderHelper topmostViewController];
        }
    }
    return validVC;
}

+ (void)presentQuickLoginFromVC:(UIViewController *)vc
                           type:(TTAccountLoginDialogTitleType)type
                         source:(NSString *)source
                isPasswordStyle:(BOOL)isPasswordStyle
                     completion:(TTAccountLoginCompletionBlock)completedBlock
{
    vc = [self.class _validLoginPresentingViewController:vc];
    [TTAccountLoginManager presentLoginViewControllerFromVC:vc type:type source:source isPasswordStyle:isPasswordStyle completion:completedBlock];
}

+ (void)presentQuickLoginFromVC:(UIViewController *)vc
                           type:(TTAccountLoginDialogTitleType)type
                         source:(NSString *)source
                     completion:(TTAccountLoginCompletionBlock)completedBlock
{
    vc = [self.class _validLoginPresentingViewController:vc];
    [TTAccountLoginManager presentLoginViewControllerFromVC:vc type:type source:source completion:completedBlock];
}

+ (void)presentQuickLoginFromVC:(UIViewController *)vc
                           type:(TTAccountLoginDialogTitleType)type
                         source:(NSString *)source
            subscribeCompletion:(TTAccountLoginCompletionBlock)completedBlock
{
    vc = [self.class _validLoginPresentingViewController:vc];
    [TTAccountLoginManager presentLoginViewControllerFromVC:vc type:type source:source subscribeCompletion:completedBlock];
}

+ (void)presentQuickLoginFromHTSModuleWithType:(TTAccountLoginDialogTitleType)type
                                        source:(NSString *)source
{
    if (![TTAccountManager isLogin]) {
        UINavigationController *nav = [TTUIResponderHelper topNavigationControllerFor:[TTUIResponderHelper topmostViewController]];
        
        [self.class presentQuickLoginFromVC:nav type:type source:source isPasswordStyle:NO completion:^(TTAccountLoginState state) {
            BOOL success = (state == TTAccountLoginStateLogin);
            if (!success) {
                [self.class notifyHTSLoginFailure];
            }
        }];
    } else {
        // 防止丢失状态
        [self.class notifyHTSLoginSuccess];
    }
}

+ (TTAccountLoginAlert *)showLoginAlertWithType:(TTAccountLoginAlertTitleType)type
                                         source:(NSString *)source
                                     completion:(TTAccountLoginAlertPhoneInputCompletionBlock)completedBlock
{
    TTAccountLoginAlert *loginAlert = [TTAccountLoginManager showLoginAlertWithType:type
                                                                             source:source
                                                                         completion:completedBlock];
    return loginAlert;
}

+ (TTAccountLoginAlert *)showQuickLoginAlertWithType:(TTAccountLoginAlertTitleType)type
                                              source:(NSString *)source
                                          completion:(TTAccountLoginAlertPhoneInputCompletionBlock)completedBlock
{
    TTAccountLoginAlert *loginAlert = [TTAccountLoginManager showLoginAlertWithType:type
                                                                             source:source
                                                                         completion:completedBlock];
    loginAlert.moreButtonRespAction = TTAccountLoginMoreActionRespModeBigLoginPanel;
    return loginAlert;
}


+ (TTAccountLoginAlert *)showLoginAlertWithType:(TTAccountLoginAlertTitleType)type
                                         source:(NSString *)source
                                    inSuperView:(UIView *)superView
                                     completion:(TTAccountLoginAlertPhoneInputCompletionBlock)completedBlock
{
    TTAccountLoginAlert *loginAlert = [TTAccountLoginManager showLoginAlertWithType:type
                                                                             source:source
                                                                        inSuperView:superView
                                                                         completion:completedBlock];
    return loginAlert;
}

+ (TTAccountLoginAlert *)showQuickLoginAlertWithType:(TTAccountLoginAlertTitleType)type
                                              source:(NSString *)source
                                         inSuperView:(UIView *)superView
                                          completion:(TTAccountLoginAlertPhoneInputCompletionBlock)completedBlock
{
    TTAccountLoginAlert *loginAlert = [TTAccountLoginManager showLoginAlertWithType:type
                                                                             source:source
                                                                        inSuperView:superView
                                                                         completion:completedBlock];
    loginAlert.moreButtonRespAction = TTAccountLoginMoreActionRespModeBigLoginPanel;
    return loginAlert;
}

@end

