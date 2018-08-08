//
//  TTRouteService.m
//  Article
//
//  Created by 冯靖君 on 17/2/24.
//
//

#import "TTRouteService.h"
#import "ArticleMobileNumberViewController.h"
#import "ArticleAddressBridger.h"
#import "ArticleMobileLoginViewController.h"
#import "TTProjectLogicManager.h"
#import "TTNavigationController.h"
#import <TTAccountBusiness.h>
#import "Bubble-Swift.h"


@implementation TTRouteService

SINGLETON_GCD(TTRouteService)

+ (void)registerTTRouteService
{
    [TTRoute sharedRoute].datasource = [TTRouteService sharedTTRouteService];
    [TTRoute sharedRoute].delegate = [TTRouteService sharedTTRouteService];
    [TTRoute sharedRoute].designatedNavDatasource = [TTRouteService sharedTTRouteService];
}

#pragma mark - TTRouteLogicDatasource

- (BOOL)ttRouteLogic_isLogin
{
    return [TTAccountManager isLogin];
}

- (BOOL)ttRouteLogic_detailViewABEnabled
{
    return YES;
}

- (NSString *)ttRouteLogic_registeredNavigationControllerClass
{
    return NSStringFromClass([TTNavigationController class]);
}

- (BOOL)ttRouteLogic_isLoginRelatedLogic:(TTRouteParamObj *)paramObj
{
    // 如果是 sslocal://login?[ platform=[ mobile,weibo,weixin,qq ]&register=[ 0,1,others ] ]
    // 根据指定逻辑跳往手机号注册界面 || 手机号登录界面 || 账号管理界面 || 登录界面等.
    return [self _isLoginRelatedLogic:paramObj];
}

- (NSString *)ttRouteLogic_classForKey:(NSString *)key
{
    return [[TTProjectLogicManager sharedInstance_tt] logicStringForKey:key];
}

#pragma mark - TTRouteLogicDelegate

- (void)ttRouteLogic_sendOpenTrackWithFromKey:(NSString *)fromKey
{
    wrapperTrackEvent(@"open", fromKey);
}

- (void)ttRouteLogic_configNavigationController:(UINavigationController *)nav
{
    if ([nav respondsToSelector:@selector(setTtNavBarStyle:)]) {
        [nav performSelectorOnMainThread:@selector(setTtNavBarStyle:) withObject:@"White" waitUntilDone:YES];
    }
}

#pragma mark - TTRouteDesignatedNavProtocol

- (UINavigationController *)designatedRouteNavigationController
{
    id<UIApplicationDelegate> delegate = [UIApplication sharedApplication].delegate;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    if ([delegate respondsToSelector:NSSelectorFromString(@"appTopNavigationController")]) {
        return [delegate performSelector:NSSelectorFromString(@"appTopNavigationController") withObject:nil];
    }
#pragma clang diagnostic pop
    return nil;
}

#pragma mark - Private

- (BOOL)_isLoginRelatedLogic:(TTRouteParamObj *)paramObj
{
    if (![paramObj.host isEqualToString:@"login"]) {
        return NO;
    }
    
    // sslocal://login?[ platform=[ mobile,weibo,weixin,qq ]&register=[ 0,1,others ] ]
    // eg. sslocal://login?platform=mobile&register=0&title=***&alert_title=***
    // title: ViewController文案；alert_title: AlertView文案
    NSString *platform = [paramObj.allParams stringValueForKey:@"platform" defaultValue:nil];
    
    if ([platform isEqualToString:@"mobile"]) {
        
        if (![TTAccountManager isLogin]) { // 未登录
            
            NSString *registerStr = [paramObj.allParams stringValueForKey:@"register" defaultValue:nil];
            
            if ([registerStr isEqualToString:@"0"]) {
                // 0，跳手机号登录页面
                [self _goToMobileLoginVC];
            } else {
                // (default || 1)，跳手机号注册页面
                [self _goToMobileLoginWithType:ArticleMobileNumberUsingTypeRegister];
            }
            
        } else { // 已登录
            
            if ([TTAccountManager currentUser].mobile.length > 0) {
                // 已登录已绑定手机号，跳转到账号管理
                [self _goToAccountBindVC];
            } else {
                // 已登录未绑定手机号，跳转到绑定手机号
                [self _goToMobileLoginWithType:ArticleMobileNumberUsingTypeBind];
            }
        }
        
    } else if ([platform isEqualToString:@"weibo"]) {
        
        [TTAccountLoginManager requestLoginPlatformByName:PLATFORM_SINA_WEIBO completion:^(BOOL success, NSError *error) {
            
        }];
        
    } else if ([platform isEqualToString:@"weixin"]) {
        
        [TTAccountLoginManager requestLoginPlatformByName:PLATFORM_WEIXIN completion:^(BOOL success, NSError *error) {
            
        }];
        
    } else if ([platform isEqualToString:@"qq"]) {
        
        [TTAccountLoginManager requestLoginPlatformByName:PLATFORM_QZONE completion:^(BOOL success, NSError *error) {
            
        }];
        
    } else {
        // platform 不能识别
        if ([TTAccountManager isLogin]) {
            // 已登录，跳账号绑定界面
            [self _goToAccountBindVC];
        } else {
            // 未登录，跳登录界面
            [self _goToLoginVCWithParams:paramObj.allParams];
        }
    }
    
    return YES;
}

- (void)_goToMobileLoginWithType:(ArticleMobileNumberUsingType)type
{
    UINavigationController *navigationController = [self _suitableNavigationController];
    
    ArticleMobileNumberViewController * viewController = [[ArticleMobileNumberViewController alloc] initWithMobileNumberUsingType:type];
    viewController.completion = ^(ArticleLoginState state){
        [[ArticleAddressBridger sharedBridger] setPresentingController:navigationController];
        [[ArticleAddressBridger sharedBridger] tryShowGetAddressBookAlertWithMobileLoginState:state];
    };
    [navigationController pushViewController:viewController animated:YES];
}

- (void)_goToAccountBindVC
{
    Class c =  NSClassFromString(@"TTAccountBindingViewController");
    id controller = [[c alloc] init];
    [[self _suitableNavigationController] pushViewController:controller animated:YES];
}

- (void)_goToMobileLoginVC
{
    UINavigationController *navigationController = [self _suitableNavigationController];
    
    ArticleMobileLoginViewController * viewController = [[ArticleMobileLoginViewController alloc] initWithNibName:nil bundle:nil];
    viewController.completion = ^(ArticleLoginState state) {
        [[ArticleAddressBridger sharedBridger] setPresentingController:navigationController];
        [[ArticleAddressBridger sharedBridger] tryShowGetAddressBookAlertWithMobileLoginState:state];
    };
    [navigationController pushViewController:viewController animated:YES];
}

- (void)_goToLoginVCWithParams:(NSDictionary *)params
{
    NSString *title = [params stringValueForKey:@"title" defaultValue:nil];
    NSString *alertTitle = [params stringValueForKey:@"alert_title" defaultValue:nil];
    [TTAccountLoginManager showLoginAlertWithTitle:alertTitle source:nil completion:^(TTAccountAlertCompletionEventType type, NSString *phoneNum) {
        if (type == TTAccountAlertCompletionEventTypeTip) {
            [TTAccountManager presentQuickLoginFromVC:[self _suitableNavigationController] type:TTAccountLoginDialogTitleTypeDefault source:nil completion:^(TTAccountLoginState state) {
            }];
            
            [TTAccountLoginManager presentLoginViewControllerFromVC:[self _suitableNavigationController] title:title source:nil completion:^(TTAccountLoginState state) {
                
            }];
        }
    }];
}

- (UINavigationController *)_suitableNavigationController
{
    UINavigationController *nav = nil;
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    if ([[[UIApplication sharedApplication] delegate] respondsToSelector:NSSelectorFromString(@"appTopNavigationController")]) {
        nav = [[[UIApplication sharedApplication] delegate] performSelector:NSSelectorFromString(@"appTopNavigationController")];
    }
#pragma clang diagnostic pop
    
    if (nav == nil) {
        nav = (UINavigationController*)[UIApplication sharedApplication].delegate.window.rootViewController;
    }
    if (![nav isKindOfClass:[UINavigationController class]]) {
        nav = nil;
    }
    
    return nav;
}

@end

