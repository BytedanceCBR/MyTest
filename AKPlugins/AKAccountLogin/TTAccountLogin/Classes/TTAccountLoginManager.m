//
//  TTAccountLoginManager.m
//  TTAccountLogin
//
//  Created by liuzuopeng on 24/05/2017.
//
//

#import "TTAccountLoginManager.h"
#import "TTAccountNavigationController.h"
#import "TTAccountPadNavigationController.h"
#import <TTUIResponderHelper.h>
#import <TTDeviceHelper.h>
#import "TTAccountLoginConfLogic.h"
#import <TTSandBoxHelper.h>



@implementation TTAcountFLoginDelegate

- (void)loginSuccessed
{
    if (self.completeAlert)
    {
        self.completeAlert(TTAccountAlertCompletionEventTypeDone,nil);
    }
    
    if (self.completeVC)
    {
        self.completeVC(TTAccountLoginStateLogin);
    }
}

@end

@implementation TTAccountLoginManager

static BOOL s_loginAlertShowing = NO;

+ (BOOL)isLoginAlertShowing
{
    return s_loginAlertShowing;
}

+ (void)showLoginAlert
{
    s_loginAlertShowing = YES;
}

+ (void)hideLoginAlert
{
    s_loginAlertShowing = NO;
}

@end



@implementation TTAccountLoginManager (TTNonUIPlatformAuthLogin)

+ (void)requestLoginPlatformByType:(TTAccountAuthType)platformType
                        completion:(void (^)(BOOL success, NSError *error))completedBlock
{
    [self.class requestLoginPlatformByType:platformType
                           forceUseWebView:!([TTAccount canSSOForPlatform:platformType] || [TTAccount canWebSSOForPlatform:platformType])
                                completion:completedBlock];
}

+ (void)requestLoginPlatformByType:(TTAccountAuthType)platformType
                   forceUseWebView:(BOOL)useWebView
                        completion:(void (^)(BOOL success, NSError *error))completedBlock
{
    if (platformType == TTAccountAuthTypeUnsupport) {
        platformType = TTAccountAuthTypeSinaWeibo;
    }
    
    // <OLD> QQ平台中，探索版和专业版没有和主版本打通
    // <NEW> QQ平台中，探索版和专业版已和主版本打通
    //    if (!useWebView && (TTAccountAuthTypeTencentQQ == platformType)) {
    //        if (![self.class canTencentQQSSOInCurrentTarget]) {
    //            useWebView = YES;
    //        }
    //    }
    if (TTAccountAuthTypeSinaWeibo == platformType) {
        useWebView = YES;
    }
    
    [TTAccount requestLoginForPlatform:platformType
                       inCustomWebView:useWebView
                            completion:completedBlock];
}

+ (void)requestLoginPlatformByName:(NSString *)platformName
                        completion:(void (^)(BOOL success, NSError *error))completedBlock
{
    TTAccountAuthType platformType = [TTAccount accountAuthTypeForPlatform:platformName];
    [self.class requestLoginPlatformByType:platformType
                                completion:completedBlock];
}

+ (void)requestLoginPlatformByName:(NSString *)platformName
                   forceUseWebView:(BOOL)useWebView
                        completion:(void (^)(BOOL success, NSError *error))completedBlock
{
    TTAccountAuthType platformType = [TTAccount accountAuthTypeForPlatform:platformName];
    
    [self.class requestLoginPlatformByType:platformType
                           forceUseWebView:useWebView
                                completion:completedBlock];
}

+ (BOOL)canTencentQQSSOInCurrentTarget
{
    Class projectLogicCls = NSClassFromString(@"TTProjectLogicManager");
    id projectLogicInst = nil;
    if (projectLogicCls && [(id)projectLogicCls respondsToSelector:@selector(sharedInstance_tt)]) {
        projectLogicInst = [(id)projectLogicCls performSelector:@selector(sharedInstance_tt)];
    }
    if (projectLogicInst) {
        if ([projectLogicInst respondsToSelector:@selector(logicIntForKey:)]) {
            int canSSO = [projectLogicInst performSelector:@selector(logicIntForKey:) withObject:@"supportQQSSO"];
            return canSSO;
        }
    }
    return [TTAccount canSSOForPlatform:TTAccountAuthTypeTencentQQ];
}

// 解绑第三方平台
+ (void)requestLogoutPlatformByType:(TTAccountAuthType)platformType
                         completion:(void (^)(BOOL success, NSError *error))completedBlock
{
    [TTAccount requestLogoutForPlatform:platformType
                             completion:completedBlock];
}

+ (void)requestLogoutPlatformByName:(NSString *)platformName
                         completion:(void (^)(BOOL success, NSError *error))completedBlock
{
    [TTAccount requestLogoutForPlatformName:platformName
                                 completion:completedBlock];
}

@end



@implementation TTAccountLoginManager (TTUILoginPanel)

#pragma mark - show login viewController (登录大窗)

+ (TTAccountLoginViewController *)presentLoginViewControllerFromVC:(UIViewController *)vc
                                                              type:(TTAccountLoginDialogTitleType)type
                                                            source:(NSString *)source
                                                        completion:(TTAccountLoginCompletionBlock)completedBlock
{
    return [self.class presentLoginViewControllerFromVC:vc
                                                   type:type
                                                 source:source
                                        isPasswordStyle:NO
                                             completion:completedBlock];
}

+ (TTAccountLoginViewController *)presentLoginViewControllerFromVC:(UIViewController *)vc
                                                             title:(NSString *)titleString
                                                            source:(NSString *)sourceString
                                                 excludedPlatforms:(NSArray<NSString *> *)exPlatformNames
                                                        completion:(TTAccountLoginCompletionBlock)completedBlock
{
    return [self.class presentLoginViewControllerFromVC:vc
                                                  title:titleString
                                                 source:sourceString
                                        isPasswordStyle:NO
                                      excludedPlatforms:exPlatformNames
                                             completion:completedBlock];
    
}

+ (TTAccountLoginViewController *)presentLoginViewControllerFromVC:(UIViewController *)vc
                                                             title:(NSString *)titleString
                                                            source:(NSString *)source
                                                        completion:(TTAccountLoginCompletionBlock)completedBlock
{
    return [self.class presentLoginViewControllerFromVC:vc
                                                  title:titleString
                                                 source:source
                                        isPasswordStyle:NO
                                             completion:completedBlock];
}

+ (TTAccountLoginViewController *)presentLoginViewControllerFromVC:(UIViewController *)vc
                                                              type:(TTAccountLoginDialogTitleType)type
                                                            source:(NSString *)source
                                                   isPasswordStyle:(BOOL)isPasswordStyle
                                                        completion:(TTAccountLoginCompletionBlock)completedBlock
{
    return [self.class presentLoginViewControllerFromVC:vc
                                                  title:[TTAccountLoginConfLogic loginDialogTitleForType:type]
                                                 source:source
                                             completion:completedBlock];
}

+ (TTAccountLoginViewController *)presentLoginViewControllerFromVC:(UIViewController *)vc
                                                             title:(NSString *)titleString
                                                            source:(NSString *)source
                                                   isPasswordStyle:(BOOL)isPasswordStyle
                                                        completion:(TTAccountLoginCompletionBlock)completedBlock
{
    return [self.class presentLoginViewControllerFromVC:vc
                                                  title:titleString
                                                 source:source
                                        isPasswordStyle:isPasswordStyle
                                      excludedPlatforms:nil
                                             completion:completedBlock];
}

+ (TTAccountLoginViewController *)presentLoginViewControllerFromVC:(UIViewController *)vc
                                                             title:(NSString *)titleString
                                                            source:(NSString *)source
                                                   isPasswordStyle:(BOOL)isPasswordStyle
                                                 excludedPlatforms:(NSArray<NSString *> *)exPlatformNames
                                                        completion:(TTAccountLoginCompletionBlock)completedBlock
{
    if ([titleString length] == 0) titleString = NSLocalizedString(@"手机登录", nil);
    if (!vc) vc = [TTUIResponderHelper topNavigationControllerFor:[TTUIResponderHelper topmostViewController]];
    
    TTAccountLoginViewController *accountLoginVC = [[TTAccountLoginViewController alloc] initWithTitle:titleString source:source isPasswordLogin:isPasswordStyle];
    accountLoginVC.loginCompletionHandler = completedBlock;
    accountLoginVC.excludedPlatformNames = exPlatformNames;
    
    if ([TTDeviceHelper isPadDevice]) {
        TTAccountPadNavigationController *navigationController = [[TTAccountPadNavigationController alloc] initWithRootViewController:accountLoginVC];
        navigationController.ttNavBarStyle = @"Image";
        navigationController.ttHideNavigationBar = NO;
        if (![TTNavigationController refactorNaviEnabled]) {
            [navigationController.navigationBar setValue:@(YES) forKey:@"hidesShadow"];
        }
        
        navigationController.modalPresentationStyle = UIModalPresentationFormSheet;
        [vc presentViewController:navigationController animated:YES completion:nil];
        
    } else {
        TTAccountNavigationController *navigationController = [[TTAccountNavigationController alloc] initWithRootViewController:accountLoginVC];
        
        if ([TTDeviceHelper OSVersionNumber] < 8.0f) {
            vc.view.window.rootViewController.modalPresentationStyle = UIModalPresentationCurrentContext;
            [vc presentViewController:navigationController animated:NO completion:nil];
            vc.view.window.rootViewController.modalPresentationStyle = UIModalPresentationFullScreen;
        } else {
            [vc presentViewController:navigationController animated:YES completion:nil];
        }
    }
    
    return accountLoginVC;
}

+ (TTAccountLoginViewController *)presentLoginViewControllerFromVC:(UIViewController *)vc
                                                              type:(TTAccountLoginDialogTitleType)type
                                                            source:(NSString *)source
                                               subscribeCompletion:(TTAccountLoginCompletionBlock)subscribeCompletedBlock
{
    if (!vc) vc = [TTUIResponderHelper topNavigationControllerFor:[TTUIResponderHelper topmostViewController]];
    
    TTAccountLoginViewController *accountLoginVC = [[TTAccountLoginViewController alloc] initWithTitle:[TTAccountLoginConfLogic loginDialogTitleForType:type] source:source isPasswordLogin:YES];
    accountLoginVC.subscribeCompletionHandler = subscribeCompletedBlock;
    
    if ([TTDeviceHelper isPadDevice]) {
        TTAccountPadNavigationController *navigationController = [[TTAccountPadNavigationController alloc] initWithRootViewController:accountLoginVC];
        navigationController.ttNavBarStyle = @"Image";
        navigationController.ttHideNavigationBar = NO;
        if (![TTNavigationController refactorNaviEnabled]) {
            [navigationController.navigationBar setValue:@(YES) forKey:@"hidesShadow"];
        }
        
        navigationController.modalPresentationStyle = UIModalPresentationFormSheet;
        [vc presentViewController:navigationController animated:YES completion:nil];
    } else {
        TTAccountNavigationController *navigationController = [[TTAccountNavigationController alloc] initWithRootViewController:accountLoginVC];
        
        if ([TTDeviceHelper OSVersionNumber] < 8.0f) {
            vc.view.window.rootViewController.modalPresentationStyle = UIModalPresentationCurrentContext;
            [vc presentViewController:navigationController animated:NO completion:nil];
            vc.view.window.rootViewController.modalPresentationStyle = UIModalPresentationFullScreen;
        } else {
            [vc presentViewController:navigationController animated:YES completion:nil];
        }
    }
    
    return accountLoginVC;
}

#pragma mark - 登录小窗

+ (TTAccountLoginAlert *)showLoginAlertWithType:(TTAccountLoginAlertTitleType)type
                                         source:(NSString *)source
                                     completion:(TTAccountLoginAlertPhoneInputCompletionBlock)completedBlock
{
    return [self.class showLoginAlertWithType:type
                                       source:source
                                  inSuperView:nil
                                   completion:completedBlock];
}

+ (TTAccountLoginAlert *)showLoginAlertWithTitle:(NSString *)titleString
                                          source:(NSString *)source
                                      completion:(TTAccountLoginAlertPhoneInputCompletionBlock)completedBlock
{
    return [self.class showLoginAlertWithTitle:titleString
                                        source:source
                                   inSuperView:nil
                                    completion:completedBlock];
}

+ (TTAccountLoginAlert *)showLoginAlertWithType:(TTAccountLoginAlertTitleType)type
                                         source:(NSString *)source
                                 moreActionConf:(TTAccountLoginMoreActionRespMode)moreActionRespMode
                                     completion:(TTAccountLoginAlertPhoneInputCompletionBlock)completedBlock
{
    TTAccountLoginAlert *loginAlert = [self.class showLoginAlertWithType:type
                                                                  source:source
                                                              completion:completedBlock];
    loginAlert.moreButtonRespAction = moreActionRespMode;
    
    return loginAlert;
}

+ (TTAccountLoginAlert *)showLoginAlertWithType:(TTAccountLoginAlertTitleType)type
                                         source:(NSString *)source
                                    inSuperView:(UIView *)superView
                                     completion:(TTAccountLoginAlertPhoneInputCompletionBlock)completedBlock
{
    NSString *titleString = [TTAccountLoginConfLogic loginAlertTitleForType:type];
    if ([titleString length] == 0) titleString = NSLocalizedString(@"手机登录", nil);
    
    TTAccountLoginAlert *accountAlert = [[TTAccountLoginAlert alloc] initPhoneNumberInputAlertWithActionType:TTAccountLoginAlertActionTypeLogin title:titleString placeholder:NSLocalizedString(@"未注册的用户会自动注册", nil) tip:NSLocalizedString(@"其他登录方式 >", nil) cancelBtnTitle:NSLocalizedString(@"取消", nil) confirmBtnTitle:NSLocalizedString(@"确定登录", nil) animated:YES source:source completion:nil];
    accountAlert.phoneInputCompletedHandler = completedBlock;
    // 内测版逻辑:在仅支持手机登陆时，直接跳转
    if (TTAccountLoginPlatformTypeInHouseOnly == [TTAccountLoginConfLogic loginPlatforms]) {
        accountAlert.hidden = YES;
        // 仍然以隐藏方式显示是为了防止在phoneInputCompletedHandler调用中有引用accountAlert的superview或nextresponder的情况
        [accountAlert showInView:superView];
        /**
         少数情况下，phoneInputCompletedHandler 不是通过completedBlock传进来的，
         而是在调用完该方法后，拿到TTAccountLoginAlert
         直接进行 accountAlert.phoneInputCompletedHandler = completedBlock
         所以，对 accountAlert.phoneInputCompletedHandler 的调用要延迟到后面的runloop。
         延迟时间影响界面响应速度，取值0.1（也可选择其它值）
         */
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            UIViewController *vc = [TTUIResponderHelper topmostViewController];
            while (vc.presentedViewController) {
                vc = vc.presentedViewController;
            }
            [TTAccountLoginManager presentLoginViewControllerFromVC:vc type:TTAccountLoginDialogTitleTypeDefault source:source completion:^(TTAccountLoginState state) {
                // 在登陆成功的状态下，会发送通知"DISMISS_MASK_AFTER_LOGIN_SUCCESS"进行后续的逻辑处理
                // 此处仅需在未登陆时隐藏弹窗即可。
                if (TTAccountLoginStateLogin != state) {
                    accountAlert.phoneInputCompletedHandler(TTAccountAlertCompletionEventTypeCancel, @"");
                    [accountAlert hide];
                }
            }];
        });
    } else {
        [accountAlert showInView:superView];
    }
    return accountAlert;
}

+ (TTAccountLoginAlert *)showLoginAlertWithTitle:(NSString *)titleString
                                          source:(NSString *)source
                                     inSuperView:(UIView *)superView
                                      completion:(TTAccountLoginAlertPhoneInputCompletionBlock)completedBlock
{
    if ([titleString length] == 0) titleString = NSLocalizedString(@"手机登录", nil);
    TTAccountLoginAlert *loginAlert =
    [[TTAccountLoginAlert alloc] initPhoneNumberInputAlertWithActionType:TTAccountLoginAlertActionTypeLogin
                                                                   title:titleString
                                                             placeholder:NSLocalizedString(@"未注册的用户会自动注册", nil)
                                                                     tip:NSLocalizedString(@"其他登录方式 >", nil)
                                                          cancelBtnTitle:NSLocalizedString(@"取消", nil)
                                                         confirmBtnTitle:NSLocalizedString(@"确定登录", nil)
                                                                animated:YES
                                                                  source:source
                                                              completion:nil];
    loginAlert.phoneInputCompletedHandler = completedBlock;
    [loginAlert showInView:superView];
    
    return loginAlert;
}

+ (TTAccountLoginAlert *)showLoginAlertWithType:(TTAccountLoginAlertTitleType)type
                                         source:(NSString *)source
                                    inSuperView:(UIView *)superView
                                 moreActionConf:(TTAccountLoginMoreActionRespMode)moreActionRespMode
                                     completion:(TTAccountLoginAlertPhoneInputCompletionBlock)completedBlock
{
    TTAccountLoginAlert *loginAlert = [self.class showLoginAlertWithType:type
                                                                  source:source
                                                             inSuperView:superView
                                                              completion:completedBlock];
    loginAlert.moreButtonRespAction = moreActionRespMode;
    return loginAlert;
}

+ (TTAccountLoginAlert *)showLoginAlertWithTitle:(NSString *)title
                                          source:(NSString *)source
                                     inSuperView:(UIView *)superView
                                  moreActionConf:(TTAccountLoginMoreActionRespMode)moreActionRespMode
                                      completion:(TTAccountLoginAlertPhoneInputCompletionBlock)completedBlock
{
    TTAccountLoginAlert *loginAlert = [self.class showLoginAlertWithTitle:title
                                                                   source:source
                                                              inSuperView:superView
                                                               completion:completedBlock];
    loginAlert.moreButtonRespAction = moreActionRespMode;
    return loginAlert;
}

+ (void)showAlertFLoginVCWithParams:(NSDictionary *)params completeBlock:(TTAccountLoginAlertPhoneInputCompletionBlock)complete {
    TTAcountFLoginDelegate *delegate = [[TTAcountFLoginDelegate alloc] init];
    delegate.completeAlert = complete;
    NSMutableDictionary *dict = @{}.mutableCopy;
    [dict setObject:delegate forKey:@"delegate"];

    if (params.count > 0) {
        if ([params tta_stringForKey:@"enter_from"] != nil) {
            [dict setObject:[params tta_stringForKey:@"enter_from"] forKey:@"enter_from"];
            
        }
        if ([params tta_stringForKey:@"enter_type"] != nil) {
            [dict setObject:[params tta_stringForKey:@"enter_type"] forKey:@"enter_type"];
            
        }
    }

//    NSDictionary *dict = [NSDictionary dictionaryWithObject:delegate forKey:@"delegate"];
    TTRouteUserInfo* userInfo = [[TTRouteUserInfo alloc] initWithInfo:dict];
    [[TTRoute sharedRoute] openURLByPushViewController:[NSURL URLWithString:@"fschema://flogin"] userInfo:userInfo];
}


+ (void)showQuickFLoginVCWithParams:(NSDictionary *)params completeBlock:(TTAccountLoginCompletionBlock)complete
{
    TTAcountFLoginDelegate *delegate = [[TTAcountFLoginDelegate alloc] init];
    delegate.completeVC = complete;
    NSMutableDictionary *dict = @{}.mutableCopy;
    [dict setObject:delegate forKey:@"delegate"];
    if (params.count > 0) {
        if ([params tta_stringForKey:@"enter_from"].length > 0) {
            [dict setObject:[params tta_stringForKey:@"enter_from"] forKey:@"enter_from"];
            
        }
        if ([params tta_stringForKey:@"enter_type"].length > 0) {
            [dict setObject:[params tta_stringForKey:@"enter_type"] forKey:@"enter_type"];
            
        }
    }
//    NSDictionary *dict = [NSDictionary dictionaryWithObject:delegate forKey:@"delegate"];
    TTRouteUserInfo* userInfo = [[TTRouteUserInfo alloc] initWithInfo:dict];
    [[TTRoute sharedRoute] openURLByPushViewController:[NSURL URLWithString:@"fschema://flogin"] userInfo:userInfo];
}

@end




@implementation TTAccountLoginManager (TTLoginUIStyleStore)

static NSString * const kTTAccountLoginUIStyleKey = @"kTTAccountLoginUIStyleKey";

+ (void)setDefaultLoginUIStyleFor:(TTAccountLoginStyle)newStyle
{
    [[NSUserDefaults standardUserDefaults] setObject:@(newStyle) forKey:kTTAccountLoginUIStyleKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

/** 上次登录成功的方式，默认验证码登录，使用第三方登录后也会改成验证码登录 */
+ (TTAccountLoginStyle)defaultLoginUIStyle
{
    NSNumber *loginUIStyle = [[NSUserDefaults standardUserDefaults] objectForKey:kTTAccountLoginUIStyleKey];
    if (loginUIStyle && [loginUIStyle respondsToSelector:@selector(integerValue)]) {
        return [loginUIStyle integerValue];
    }
    return TTAccountLoginStyleCaptcha;
}

@end

