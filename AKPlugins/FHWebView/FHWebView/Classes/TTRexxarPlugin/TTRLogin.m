//
//  TTRLogin.m
//  Article
//
//  Created by muhuai on 2017/5/21.
//
//

#import "TTRLogin.h"
#import <TTBaseLib/TTBaseMacro.h>
#import "TTAccount.h"
#import <TTBaseLib/TTUIResponderHelper.h>
#import <TTRexxar/TTRWebViewApplication.h>
#import "TTAccount+Multicast.h"
#import "NSDictionary+TTAdditions.h"
#import "TTRoute.h"
#import "TTAccount+NetworkTasks.h"
#import "FHWebViewConfig.h"
#import <TTAccountSDK/TTAccountAuthDefine.h>

extern NSString * TTAccountPlatformDidAuthorizeCompletionNotification;
@interface TTRLogin()<TTAccountMulticastProtocol>

@property (nonatomic, weak) UIView<TTRexxarEngine> *webview;
@property (nonatomic, copy) TTRJSBResponse response;

@end

@implementation TTRLogin

+ (TTRJSBInstanceType)instanceType {
    return TTRJSBInstanceTypeWebView;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [TTAccount removeMulticastDelegate:self];
}

- (void)loginWithParam:(NSDictionary *)param callback:(TTRJSBResponse)callback webView:(UIView<TTRexxarEngine> *)webview controller:(UIViewController *)controller {
    
    NSString *platform = [param objectForKey:@"platform"];
    NSString *source = [param tt_stringValueForKey:@"login_source"];
    NSString *title = [param tt_stringValueForKey:@"title"];
    NSString *alertTitle = [param tt_stringValueForKey:@"alert_title"];

    // 已登录并且不是qq、微信、weibo等其他登录方式时，直接返回登录成功
    if ([[TTAccount sharedAccount] isLogin] && isEmptyString(platform)) {
        callback(TTRJSBMsgSuccess, @{@"code": @1});
        return;
    }
    
    _response = callback;
    // 确保监听accountStateChanged（详情页不调用addEventListener)，收到通知时callback页面
    [TTAccount removeMulticastDelegate:self];
    [TTAccount addMulticastDelegate:self];
    
    // shareone cancel login
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginClosed:) name:@"notification_share_one_dismiss" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationDidAuthCompletion:) name:TTAccountPlatformDidAuthorizeCompletionNotification object:nil];
    
    BOOL isAK = [param tt_boolValueForKey:@"use_new"];
    if (isAK && [platform isEqualToString:@"weixin"]) {
        NSURL *url = [NSURL URLWithString:@"sslocal://flogin"];
        if ([[TTRoute sharedRoute] canOpenURL:url]) {
            [[TTRoute sharedRoute] openURLByViewController:url userInfo:nil];
            return;
        }
    }
    
    [FHWebViewConfig loginWithParam:param webView:webview];
}

- (void)isLoginWithParam:(NSDictionary *)param callback:(TTRJSBResponse)callback webView:(UIView<TTRexxarEngine> *)webview controller:(UIViewController *)controller {
    callback(TTRJSBMsgSuccess, @{@"is_login": @([[TTAccount sharedAccount] isLogin])});
}

#pragma mark - TTAccountMulticastProtocol

- (void)onAccountStatusChanged:(TTAccountStatusChangedReasonType)reasonType platform:(NSString *)platformName
{
    //忽略从js bridge抛出的通知
    switch (reasonType) {
        case TTAccountStatusChangedReasonTypeLogout:
        case TTAccountStatusChangedReasonTypeSessionExpiration:
        {
            if (self.response) {
                self.response(TTRJSBMsgFailed, @{@"code": @0});
            }
        }
            break;
        case TTAccountStatusChangedReasonTypeAutoSyncLogin:
        case TTAccountStatusChangedReasonTypeFindPasswordLogin:
        case TTAccountStatusChangedReasonTypePasswordLogin:
        case TTAccountStatusChangedReasonTypeSMSCodeLogin:
        case TTAccountStatusChangedReasonTypeEmailLogin:
        case TTAccountStatusChangedReasonTypeTokenLogin:
        case TTAccountStatusChangedReasonTypeSessionKeyLogin:
        case TTAccountStatusChangedReasonTypeAuthPlatformLogin:
        {
            if (self.response) {
                self.response(TTRJSBMsgSuccess, @{@"code": @1});
            }
        }
            break;
    }
    
    self.response = nil;
    [self removeAccountNotification];
}

// 登录成功后，如果再绑定或解绑账号不会发送登录成功通知，而是发送绑定账号发生改变通知
- (void)onAccountAuthPlatformStatusChanged:(TTAccountAuthPlatformStatusChangedReasonType)reasonType platform:(NSString *)platformName error:(NSError *)error
{
    switch (reasonType) {
        case TTAccountAuthPlatformStatusChangedReasonTypeLogin: { // 绑定账号成功
            if (self.response) {
                self.response(TTRJSBMsgSuccess, @{@"code": @1});
            }
            self.response = nil;
            [self removeAccountNotification];
        }
            break;
        case TTAccountAuthPlatformStatusChangedReasonTypeLogout: {
            NSCAssert(NO, @"逻辑错误，正常不会运行到此");
        }
            break;
        case TTAccountAuthPlatformStatusChangedReasonTypeExpiration: {
            NSCAssert(NO, @"逻辑错误，正常不会运行到此");
        }
            break;
    }
}

- (void)loginClosed:(NSNotification*)notification
{
    if(![[TTAccount sharedAccount] isLogin])
    {
        if (self.response) {
            self.response(TTRJSBMsgSuccess, @{@"code": @0});
            self.response = nil;
        }
        [self removeAccountNotification];
    }
}

- (void)notificationDidAuthCompletion:(NSNotification *)notification
{
    NSDictionary *userInfoInNot = notification.userInfo;
    TTAccountAuthErrCode authErrCode = [userInfoInNot[TTAccountStatusCodeKey] integerValue];
    
    if (authErrCode != TTAccountAuthSuccess) {
        [self cancelLogin:notification];
    }
}

- (void)cancelLogin:(NSNotification*)notification
{
    if (self.response) {
        self.response(TTRJSBMsgSuccess, @{@"code": @0});
        self.response = nil;
    }
    [self removeAccountNotification];
}

- (void)removeAccountNotification
{
    [TTAccount removeMulticastDelegate:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"notification_share_one_dismiss" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:TTAccountPlatformDidAuthorizeCompletionNotification object:nil];
}

- (void)logoutAppWithParam:(NSDictionary *)param callback:(TTRJSBResponse)callback webView:(UIView<TTRexxarEngine> *)webview controller:(UIViewController *)controller
{
    // 退出登录
    [TTAccount logoutInScene:TTAccountLogoutSceneNormal completion:^(BOOL success, NSError * _Nullable error) {
        callback(TTRJSBMsgSuccess, @{@"code": @(success ? 1 : 0)});
    }];
}

@end
