//
//  TTPushMsgAuthLoginManager.m
//  Article
//
//  Created by zuopengliu on 26/11/2017.
//

#import "TTPushMsgAuthLoginManager.h"
#import <Bytedancebase/BDSDKApi.h>
#import <Bytedancebase/BDSDKApi+CompanyProduct.h>
#import <Bytedancebase/BDSDKUserPromotionInteractor.h>
#import <TTAccountSDK/TTAccountSDK.h>
#import <TTAccountLoginViewController.h>
#import "TTProjectLogicManager.h"
#import <TTTrackerWrapper.h>
#import "SSCommonLogic.h"
#import "TTProfileViewController.h"
#import "TTArticleTabBarController.h"
#import <TTIndicatorView.h>
#import <TTAccountLoginManager.h>
#import "TTTabBarProvider.h"

@interface TTPushMsgAuthLoginManager ()
<
BDSDKApiDelegate
>
@property (nonatomic, assign) BOOL canHandled;
@end

@implementation TTPushMsgAuthLoginManager

+ (instancetype)sharedManager
{
    static TTPushMsgAuthLoginManager *sharedInst;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInst = [self new];
    });
    return sharedInst;
}

- (instancetype)init
{
    if ((self = [super init])) {
        _canHandled = NO;
    }
    return self;
}

+ (BOOL)handleOpenURL:(NSURL *)url
{
    return [[self sharedManager] handleOpenURL:url];
}

- (BOOL)handleOpenURL:(NSURL *)url
{
    BOOL hotsoonHandled = [BDSDKApi application:[UIApplication sharedApplication]
                                        openURL:url
                                       delegate:self
                                     forProduct:BDSDKProductTypeHuoshan];
    if (hotsoonHandled && _canHandled) return YES;
    
    BOOL awemeHandled = [BDSDKApi application:[UIApplication sharedApplication]
                                      openURL:url
                                     delegate:self
                                   forProduct:BDSDKProductTypeDouyin];
    if (awemeHandled && _canHandled) return YES;
    
    return NO;
}

#pragma mark - BDSDKApiDelegate

+ (BOOL)usingNewLogic
{
    return YES;
}

- (void)didReceiveRequest:(BDSDKBaseReq *)req 
{
    NSLog(@"<SEL: %@> <ReqClass: %@ - %@>, sessionId = %@, userId = %@", NSStringFromSelector(_cmd), NSStringFromClass(req.class), req, [req valueForKey:@"sessionId"],  [req valueForKey:@"userId"]);
    
    if (![req isKindOfClass:[BDSDKGetUserPromotionReq class]]) {
        self.canHandled = NO;
        return;
    } else {
        self.canHandled = YES;
    }
    
    BDSDKGetUserPromotionReq *userPromotionReq = (BDSDKGetUserPromotionReq *)req;
    
    if ([self.class usingNewLogic]) {
        [self handleNewLoginBindWithUserPromotion:userPromotionReq];
    } else {
        [self handleOldLoginBindWithUserPromotion:userPromotionReq];
    }
}

#pragma mark - account login/bind `new logic1

- (void)handleNewLoginBindWithUserPromotion:(BDSDKGetUserPromotionReq *)userPromotionReq
{
    if (!userPromotionReq) return;
    
    NSInteger platformType = [self.class platformTypeFromBDProductType:userPromotionReq.platformProductType];
    
    BOOL isLoginDidLaunch = [[TTAccount sharedAccount] isLogin];
    BOOL showToast = isLoginDidLaunch;
    if (!isLoginDidLaunch) {
        // 未登录则执行登录操作，登录完成后进行绑定
        
        NSString *platformName = [TTAccount platformNameForAccountAuthType:platformType];
        
        [self.class dismissLoginPanelForPlatformName:platformName];
        
        [self tryLoginDirectlyWithUserPromotion:userPromotionReq forPlatform:platformType showToast:showToast];
        
    } else {
        NSString *platformName = [TTAccount platformNameForAccountAuthType:platformType];
        TTAccountPlatformEntity *connectedAccount = [[TTAccount sharedAccount] connectedAccountForPlatform:platformName];
        
        if (connectedAccount && [connectedAccount.platformUID isEqualToString:userPromotionReq.userId]) {
            // 已有当前第三方平台账号绑定
            showToast = NO;
        }
        [self handleAccountBindWithUserPromotion:userPromotionReq forPlatform:platformType showToast:showToast];
    }
}

/** 弹出登录面板，登录成功后绑定 */
- (void)tryLoginDirectlyWithUserPromotion:(BDSDKGetUserPromotionReq *)userPromotionReq
                              forPlatform:(NSInteger)platformType
                                showToast:(BOOL)toastEnabled
{
    if (!userPromotionReq) return;
    
    NSString *platformName  = [TTAccount platformNameForAccountAuthType:platformType];
    NSArray  *platformNames = (platformName.length > 0) ? @[platformName] : nil;
    //    NSString *platformAppId = [self.class platformAppIdForPlatformType:platformType];
    
    //    [BDSDKUserPromotionInteractor handleUserPromotionReq:userPromotionReq completion:^(NSString *code, NSString *state, NSError *authError) {
    //        userPromotionReq.code = code;
    //
    //        if (code && TTAccountAuthTypeUnsupport != platformType) {
    //            NSMutableDictionary *mutDict = [NSMutableDictionary dictionary];
    //            [mutDict setValue:userPromotionReq.code forKey:@"code"];
    //            [mutDict setValue:platformName forKey:@"platform_name"];
    //            [mutDict setValue:platformAppId forKey:@"platform_app_id"];
    //
    //            [TTAccount tryloginWithSSOCallback:[mutDict copy] forPlatform:platformType userValidation:^BOOL(TTAccountUserEntity *user) {
    //                if (!user) return NO;
    //                if (user.mobile.length <= 0 &&
    //                    user.email.length  <= 0 &&
    //                    user.connects.count <= 1) {
    //                    return NO;
    //                }
    //                return YES;
    //            } completion:^(BOOL success, NSError * _Nullable ssocallbackError) {
    //                if (ssocallbackError || !success) {
    //                    __weak typeof(self) wself = self;
    //                    [TTAccountLoginManager presentLoginViewControllerFromVC:[TTUIResponderHelper topmostViewController] title:@"登录/创建账号" source:@"pushmsg_auth" excludedPlatforms:platformNames completion:^(TTAccountLoginState state) {
    //                        BOOL isLogin = [[TTAccount sharedAccount] isLogin];
    //
    //                        if (isLogin) {
    //                            [wself handleAccountBindWithUserPromotion:userPromotionReq forPlatform:platformType showToast:toastEnabled];
    //                        }
    //                    }];
    //                } else {
    //                    // 合法的登录《没有手机号、邮箱和其他账号绑定》
    //                    [self.class handlePromotionLoginSuccessForLogin:YES showToast:YES];
    //                }
    //            }];
    //        } else {
    // 直接登录
    __weak typeof(self) wself = self;
    [TTAccountLoginManager presentLoginViewControllerFromVC:[TTUIResponderHelper topmostViewController] title:@"登录/创建爱看账号" source:@"pushmsg_auth" excludedPlatforms:platformNames completion:^(TTAccountLoginState state) {
        BOOL isLogin = [[TTAccount sharedAccount] isLogin];
        
        if (isLogin) {
            [wself handleAccountBindWithUserPromotion:userPromotionReq forPlatform:platformType showToast:toastEnabled];
        }
    }];
    //        }
    //    }];
}

- (void)handleAccountBindWithUserPromotion:(BDSDKGetUserPromotionReq *)userPromotionReq
                               forPlatform:(NSInteger)platformType
                                 showToast:(BOOL)toastEnabled
{
    if (!userPromotionReq) return;
    
    NSString *platformName = [TTAccount platformNameForAccountAuthType:platformType];
    NSString *platformDisplayName = [TTAccount localizedDisplayNameForPlatform:platformType];
    NSString *platformAppId = [self.class platformAppIdForPlatformType:platformType];
    
    if (TTAccountAuthTypeHuoshan == platformType) platformDisplayName = @"火山";
    
    [BDSDKUserPromotionInteractor handleUserPromotionReq:userPromotionReq completion:^(NSString *code, NSString *state, NSError *authError) {
        userPromotionReq.code = code;
        
        BOOL isLoginAction = YES;
        TTAccountPlatformEntity *connectedAccount __unused = [[TTAccount sharedAccount] connectedAccountForPlatform:platformName];
        if ([[TTAccount sharedAccount] isLogin] /** && !connectedAccount */) {
            isLoginAction = NO;
        }
        
        if (code) {
            if (userPromotionReq.code && TTAccountAuthTypeUnsupport != platformType) {
                NSMutableDictionary *mutDict = [NSMutableDictionary dictionary];
                [mutDict setValue:userPromotionReq.code forKey:@"code"];
                [mutDict setValue:platformName forKey:@"platform_name"];
                [mutDict setValue:platformAppId forKey:@"platform_app_id"];
                
                [TTAccount loginWithSSOCallback:[mutDict copy] forPlatform:platformType willLogin:nil completion:^(BOOL success, BOOL loginOrBind, NSError * _Nullable ssocallbackError) {
                    if (ssocallbackError) {
                        if (ssocallbackError.code == TTAccountErrCodeAuthPlatformBoundForbid) {
                            NSString *hintText = platformDisplayName ? [NSString stringWithFormat:@"该%@账号已有绑定，请先解绑", platformDisplayName] : ssocallbackError.userInfo[NSLocalizedDescriptionKey];
                            [TTIndicatorView dismissIndicators];
                            [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:hintText indicatorImage:[UIImage themedImageNamed:@"doneicon_popup_textpage.png"] autoDismiss:YES dismissHandler:nil];
                        } else {
                            [self.class handlePromotionLoginError:ssocallbackError forLogin:isLoginAction showToast:toastEnabled];
                        }
                    } else {
                        [self.class dismissLoginPanelForPlatformName:platformName];
                        [self.class handlePromotionLoginSuccessForLogin:isLoginAction showToast:toastEnabled];
                        [self.class trackPromotionLoginSuccessLogForPlatform:platformType];
                    }
                }];
            } else {
                NSString *errMsg = !userPromotionReq.code ? @"code is nil" : @"不支持的平台";
                NSError *error = [NSError errorWithDomain:@"TTUserPromotionErrorDomain" code:BDSDKErrorCodeAuthDenied userInfo:@{NSLocalizedDescriptionKey: errMsg}];
                [self.class handlePromotionLoginError:error forLogin:isLoginAction showToast:toastEnabled];
            }
        } else {
            [self.class handlePromotionLoginError:authError forLogin:isLoginAction showToast:toastEnabled];
        }
    }];
}

#pragma mark - account login/bind `old logic`

- (void)handleOldLoginBindWithUserPromotion:(BDSDKGetUserPromotionReq *)userPromotionReq
{
    if (!userPromotionReq) return;
    
    NSInteger platformType = [self.class platformTypeFromBDProductType:userPromotionReq.platformProductType];
    
    [BDSDKUserPromotionInteractor handleUserPromotionReq:userPromotionReq completion:^(NSString *code, NSString *state, NSError *authError) {
        userPromotionReq.code = code;
        
        NSString *platformName = [TTAccount platformNameForAccountAuthType:platformType];
        NSString *platformDisplayName = [TTAccount localizedDisplayNameForPlatform:platformType];
        NSString *platformAppId = [self.class platformAppIdForPlatformType:platformType];
        
        if (TTAccountAuthTypeHuoshan == platformType) platformDisplayName = @"火山";
        
        BOOL isLoginAction = YES;
        TTAccountPlatformEntity *connectedAccount = [[TTAccount sharedAccount] connectedAccountForPlatform:platformName];
        if ([[TTAccount sharedAccount] isLogin] && !connectedAccount) {
            // 仅仅已登录并且没绑定显示绑定成功|失败，否则显示绑定成功|失败
            isLoginAction = NO;
        }
        
        if (code) {
            if (userPromotionReq.code && TTAccountAuthTypeUnsupport != platformType) {
                NSMutableDictionary *mutDict = [NSMutableDictionary dictionary];
                [mutDict setValue:userPromotionReq.code forKey:@"code"];
                [mutDict setValue:platformName forKey:@"platform_name"];
                [mutDict setValue:platformAppId forKey:@"platform_app_id"];
                
                [TTAccount loginWithSSOCallback:[mutDict copy] forPlatform:platformType willLogin:nil  completion:^(BOOL success, BOOL loginOrBind, NSError *ssocallbackError) {
                    if (ssocallbackError) {
                        if (ssocallbackError.code == TTAccountErrCodeAuthPlatformBoundForbid) {
                            NSString *hintText = platformDisplayName ? [NSString stringWithFormat:@"该%@账号已有绑定，请先解绑", platformDisplayName] : ssocallbackError.userInfo[NSLocalizedDescriptionKey];
                            [TTIndicatorView dismissIndicators];
                            [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:hintText indicatorImage:[UIImage themedImageNamed:@"doneicon_popup_textpage.png"] autoDismiss:YES dismissHandler:nil];
                        } else {
                            [self.class handlePromotionLoginError:ssocallbackError forLogin:isLoginAction showToast:YES];
                        }
                    } else {
                        [self.class dismissLoginPanelForPlatformName:platformName];
                        [self.class handlePromotionLoginSuccessForLogin:isLoginAction showToast:YES];
                        [self.class trackPromotionLoginSuccessLogForPlatform:platformType];
                    }
                }];
            } else {
                NSString *errMsg = !userPromotionReq.code ? @"code is nil" : @"不支持的平台";
                NSError *error = [NSError errorWithDomain:@"TTUserPromotionErrorDomain" code:BDSDKErrorCodeAuthDenied userInfo:@{NSLocalizedDescriptionKey: errMsg}];
                [self.class handlePromotionLoginError:error forLogin:isLoginAction showToast:YES];
            }
        } else {
            [self.class handlePromotionLoginError:authError forLogin:isLoginAction showToast:YES];
        }
    }];
}


#pragma mark - handle login callback

+ (void)handlePromotionLoginError:(NSError *)error forLogin:(BOOL)loginOrBind /** 登录还是绑定 */ showToast:(BOOL)toastEnabled
{
    if (toastEnabled) {
        NSString *hintText = loginOrBind ? NSLocalizedString(@"登录失败", nil) : NSLocalizedString(@"绑定失败", nil);
        [TTIndicatorView dismissIndicators];
        [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:hintText indicatorImage:[UIImage themedImageNamed:@"doneicon_popup_textpage.png"] autoDismiss:YES dismissHandler:nil];
    }
}

+ (void)dismissLoginPanelForPlatformName:(NSString *)platformName
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"DISMISS_MASK_AFTER_LOGIN_SUCCESS" object:nil userInfo:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:TTForceToDismissLoginViewControllerNotification object:nil userInfo:nil];
}

+ (void)handlePromotionLoginSuccessForLogin:(BOOL)loginOrBind /** 登录还是绑定 */ showToast:(BOOL)toastEnabled
{
    if (toastEnabled) {
        NSString *hintText = loginOrBind ? NSLocalizedString(@"登录成功", nil) : NSLocalizedString(@"绑定成功", nil);
        [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:hintText indicatorImage:[UIImage themedImageNamed:@"doneicon_popup_textpage.png"] autoDismiss:YES dismissHandler:nil];
    }
    
    // 跳到我的页面
    [self openMine];
}

+ (void)openMine
{
    UINavigationController *topNavVC = [TTUIResponderHelper topNavigationControllerFor:nil];
    if (topNavVC) {
        TTProfileViewController *profileVC =
        (TTProfileViewController *)[self.class findViewControllerClass:[TTProfileViewController class] inVC:topNavVC];
        if (profileVC) {
            [topNavVC popToViewController:profileVC animated:NO];
            return;
        }
    }
    
    if (![TTTabBarProvider isMineTabOnTabBar] || [TTDeviceHelper isPadDevice]) {
        // 第四个tab是火山或者是PAD
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Profile" bundle:nil];
        TTProfileViewController *profileVC = [sb instantiateInitialViewController];
        [[TTUIResponderHelper topNavigationControllerFor:nil] pushViewController:profileVC animated:YES];
    } else {
        // 跳到我的TAB(第四个TAB)
        UIViewController *controller = [[[UIApplication sharedApplication] keyWindow] rootViewController];
        if ([controller isKindOfClass:[TTArticleTabBarController class]]) {
            TTArticleTabBarController *tabBarController = (TTArticleTabBarController *)controller;
            UIViewController *selectedVC = tabBarController.selectedViewController;
            NSInteger targetIndex = tabBarController.viewControllers.count - 1;
            if (tabBarController.selectedIndex != targetIndex && [selectedVC isKindOfClass:[UINavigationController class]]) {
                [(UINavigationController *)selectedVC popToRootViewControllerAnimated:NO];
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:TTArticleTabBarControllerChangeSelectedIndexNotification object:nil userInfo:@{@"tag":kTTTabMineTabKey}];
        }
    }
}

+ (void)trackPromotionLoginSuccessLogForPlatform:(NSInteger)platformType
{
    switch (platformType) {
        case TTAccountAuthTypeHuoshan: {
            [TTTrackerWrapper eventV3:@"login_out_success" params:@{@"action_type": @"hotsoon"}];
        }
            break;
        case TTAccountAuthTypeDouyin: {
            [TTTrackerWrapper eventV3:@"login_out_success" params:@{@"action_type": @"douyin"}];
        }
            break;
            
        default:
            break;
    }
}

#pragma mark - helper

+ (NSString *)platformAppIdForPlatformType:(NSInteger)platformType
{
    NSString *platformAppID = nil;
    switch (platformType) {
        case TTAccountAuthTypeHuoshan: {
            platformAppID = TTLogicString(@"hotsoonPlatformAppID", nil);
            break;
        }
        case TTAccountAuthTypeDouyin: {
            platformAppID = TTLogicString(@"awemePlatformAppID", nil);
            break;
        }
        default: {
            
        }
    }
    return platformAppID ? : [TTAccount platformAppIdForAccountAuthType:platformType];
}

+ (NSInteger)platformTypeFromBDProductType:(NSInteger)productType
{
    NSInteger platformType = TTAccountAuthTypeUnsupport;
    switch (productType) {
        case BDSDKProductTypeDouyin: {
            platformType = TTAccountAuthTypeDouyin;
        }
            break;
        case BDSDKProductTypeHuoshan: {
            platformType = TTAccountAuthTypeHuoshan;
        }
            break;
        default:
            break;
    }
    return platformType;
}

+ (UIViewController *)findViewControllerClass:(Class)cls inVC:(UIViewController *)topVC
{
    if (!cls || !topVC) return nil;
    
    UIResponder *curResponder = topVC;
    __block UIViewController *targetVC = nil;
    while (curResponder) {
        if ([curResponder isKindOfClass:[UIViewController class]] && [curResponder isKindOfClass:[TTProfileViewController class]]) {
            targetVC = (UIViewController *)curResponder;
        } else if ([curResponder isKindOfClass:[UIViewController class]]) {
            UINavigationController *navVC = (UINavigationController *)curResponder;
            [navVC.viewControllers enumerateObjectsUsingBlock:^(__kindof UIViewController * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if ([obj isKindOfClass:[UIViewController class]] && [obj isKindOfClass:[TTProfileViewController class]]) {
                    targetVC = (UIViewController *)obj;
                    *stop = YES;
                }
            }];
        } else if ([curResponder isKindOfClass:[UITabBarController class]]) {
            UITabBarController *tabVC = (UITabBarController *)curResponder;
            targetVC = [self.class findViewControllerClass:cls inVC:tabVC.selectedViewController];
        }
        
        if (targetVC) break;
        curResponder = curResponder.nextResponder;
    }
    
    return targetVC;
}

@end
