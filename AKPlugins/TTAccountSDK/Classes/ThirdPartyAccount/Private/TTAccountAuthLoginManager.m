//
//  TTAccountAuthLoginManager.m
//  TTAccountSDK
//
//  Created by liuzuopeng on 4/26/17.
//  Copyright © 2017 com.bytedance.news. All rights reserved.
//

#import "TTAccountAuthLoginManager.h"
#import "TTAccountAuthResponse.h"
#import "UIAlertView+TTABlocks.h"
#import "TTAccountUserEntity_Priv.h"
#import "TTAccountMulticastDispatcher.h"
#import "TTAccountAuthCallbackTask.h"
#import "TTAccount.h"
#import "TTAccountConfiguration_Priv+PlatformAccount.h"
#import "TTAccountLogDispatcher+ThirdPartyAccount.h"
#import "TTAccountIndicatorView.h"



#define CLASS_CONFORMS_PROTO(cls)       ((Class<TTAccountAuthProtocol>)cls)
#define TTAccountAuthLoginInst(type)    ([[self.class sharedInstance] accountAuthInstanceForPlatformType:type])
#define TTAccountAuthLoginClass(type)   (CLASS_CONFORMS_PROTO([TTAccountAuthLoginInst(type) class]))
#define TTAccountEnumString(enum)       ([@(enum) stringValue])

@interface TTAccountAuthLoginManager ()

@property (nonatomic, strong) NSMutableDictionary<NSString *, Class> *platformAccounts;

@end

@implementation TTAccountAuthLoginManager

TTAccountSingletonImp

- (instancetype)init
{
    if ((self = [super init])) {
        _platformAccounts = [NSMutableDictionary dictionaryWithCapacity:3];
        
#if __has_include("TTAccountAuthWeChat.h")
        [_platformAccounts setValue:[TTAccountAuthWeChat class]
                             forKey:TTAccountEnumString(TTAccountAuthTypeWeChat)];
#endif
        
#if __has_include("TTAccountAuthTencent.h")
        [_platformAccounts setObject:[TTAccountAuthTencent class]
                              forKey:TTAccountEnumString(TTAccountAuthTypeTencentQQ)];
#endif
        
#if __has_include("TTAccountAuthTencentWeibo.h")
        [_platformAccounts setObject:[TTAccountAuthTencentWeibo class]
                              forKey:TTAccountEnumString(TTAccountAuthTypeTencentWB)];
#endif
        
#if __has_include("TTAccountAuthWeibo.h")
        [_platformAccounts setObject:[TTAccountAuthWeibo class]
                              forKey:TTAccountEnumString(TTAccountAuthTypeSinaWeibo)];
#endif
        
#if __has_include("TTAccountAuthTianYi.h")
        [_platformAccounts setObject:[TTAccountAuthTianYi class]
                              forKey:TTAccountEnumString(TTAccountAuthTypeTianYi)];
#endif
        
#if __has_include("TTAccountAuthRenren.h")
        [_platformAccounts setValue:[TTAccountAuthRenren class]
                             forKey:TTAccountEnumString(TTAccountAuthTypeRenRen)];
#endif
        
#if __has_include("TTAccountAuthHuoShan.h")
        [_platformAccounts setValue:[TTAccountAuthHuoShan class]
                             forKey:TTAccountEnumString(TTAccountAuthTypeHuoshan)];
#endif
        
#if __has_include("TTAccountAuthDouYin.h")
        [_platformAccounts setValue:[TTAccountAuthDouYin class]
                             forKey:TTAccountEnumString(TTAccountAuthTypeDouyin)];
#endif
        
#if __has_include("TTAccountAuthToutiao.h")
        [_platformAccounts setValue:[TTAccountAuthToutiao class]
                             forKey:TTAccountEnumString(TTAccountAuthTypeToutiao)];
#endif
        
#if __has_include("TTAccountAuthTTVideo.h")
        [_platformAccounts setValue:[TTAccountAuthTTVideo class]
                             forKey:TTAccountEnumString(TTAccountAuthTypeTTVideo)];
#endif
        
#if __has_include("TTAccountAuthTTCar.h")
        [_platformAccounts setValue:[TTAccountAuthTTCar class]
                             forKey:TTAccountEnumString(TTAccountAuthTypeTTCar)];
#endif
        
#if __has_include("TTAccountAuthTTWukong.h")
        [_platformAccounts setValue:[TTAccountAuthTTWukong class]
                             forKey:TTAccountEnumString(TTAccountAuthTypeTTWukong)];
#endif
        
#if __has_include("TTAccountAuthTTFinance.h")
        [_platformAccounts setValue:[TTAccountAuthTTFinance class]
                             forKey:TTAccountEnumString(TTAccountAuthTypeTTFinance)];
#endif
    }
    return self;
}

+ (void)registerPlatformAuthAccount:(Class<TTAccountAuthProtocol>)cls
{
    [[self sharedInstance] registerPlatformAuthAccount:cls];
}

- (void)registerPlatformAuthAccount:(Class<TTAccountAuthProtocol>)cls
{
    if (!cls) return;
    @synchronized (self.platformAccounts) {
        [_platformAccounts setValue:[cls class]
                             forKey:TTAccountEnumString([CLASS_CONFORMS_PROTO(cls) platformType])];
    }
}

#pragma mark - TTAccountAuthPlatform 相关处理

- (id<TTAccountAuthProtocol>)accountAuthInstanceForPlatformType:(TTAccountAuthType)type
{
    Class platformAuthCls = nil;
    @synchronized (self.platformAccounts) {
        platformAuthCls = [_platformAccounts valueForKey:TTAccountEnumString(type)];
    }
    return [(id<TTAccountAuthProtocol>)platformAuthCls sharedInstance];
}

- (TTAccountAuthType)accountAuthTypeForPlatformName:(NSString *)platformName
{
    if (!platformName) return TTAccountAuthTypeUnsupport;
    
    NSDictionary<NSString *, Class<TTAccountAuthProtocol>> *copiedPlatformAccounts = nil;
    @synchronized (self.platformAccounts) {
        copiedPlatformAccounts = [_platformAccounts copy];
    }
    
    __block TTAccountAuthType type = TTAccountAuthTypeUnsupport;
    [copiedPlatformAccounts enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, Class  _Nonnull obj, BOOL * _Nonnull stop) {
        NSString *clsMapToPlatformName = [CLASS_CONFORMS_PROTO(obj) platformName];
        if ([platformName isEqualToString:clsMapToPlatformName]) {
            type = [CLASS_CONFORMS_PROTO(obj) platformType];
            *stop = YES;
        }
    }];
    return type;
}

#pragma mark - register

+ (void)registerAppId:(NSString *)appId
          forPlatform:(TTAccountAuthType)type
{
    [TTAccountAuthLoginClass(type) registerApp:appId];
}

#pragma mark - handle URL

+ (BOOL)handleOpenURL:(NSURL *)url
{
    return [[self sharedInstance] handleOpenURL:url];
}

- (BOOL)handleOpenURL:(NSURL *)url
{
    if (!url) return NO;
    NSDictionary<NSNumber *, Class> *copiedPlatformAccounts = nil;
    @synchronized (self.platformAccounts) {
        copiedPlatformAccounts = [_platformAccounts copy];
    }
    
    __block BOOL canHandle = NO;
    [copiedPlatformAccounts enumerateKeysAndObjectsUsingBlock:^(NSNumber * _Nonnull key, Class  _Nonnull obj, BOOL * _Nonnull stop) {
        BOOL handled = [CLASS_CONFORMS_PROTO(obj) handleOpenURL:url];
        if (handled) {
            canHandle = YES;
            *stop = YES;
        }
    }];
    
    return canHandle;
}

#pragma mark - platform methods

+ (TTAccountAuthType)accountAuthTypeForPlatform:(NSString *)platformName
{
    return [[self sharedInstance] accountAuthTypeForPlatformName:platformName];
}

+ (NSString *)platformForAccountAuthType:(TTAccountAuthType)platformType
{
    return [TTAccountAuthLoginClass(platformType) platformName];
}

+ (NSString *)platformAppIdForAccountAuthType:(TTAccountAuthType)platformType
{
    return [TTAccountAuthLoginClass(platformType) platformAppID];
}

+ (BOOL)canSSOForPlatform:(TTAccountAuthType)type
{
    return [TTAccountAuthLoginClass(type) isSupportSSO];
}

+ (BOOL)canWebSSOForPlatform:(TTAccountAuthType)type;
{
    return [TTAccountAuthLoginClass(type) isSupportWebSSO];
}

+ (BOOL)canCustomWebSSOForPlatform:(TTAccountAuthType)type
{
    return [TTAccountAuthLoginClass(type) isSupportCustomWebSSO];
}

+ (BOOL)isAppInstalledForPlatform:(TTAccountAuthType)type
{
    return [TTAccountAuthLoginClass(type) isAppInstalled];
}

+ (NSString *)localizedDisplayNameForPlatform:(TTAccountAuthType)type
{
    return [TTAccountAuthLoginClass(type) displayName];
}

+ (NSString *)getAppInstallUrlForPlatform:(TTAccountAuthType)type
{
    return [TTAccountAuthLoginClass(type) getAppInstallUrl];
}

#pragma mark - login/logout

+ (void)requestLogoutForPlatform:(TTAccountAuthType)type
                      completion:(void (^)(BOOL, NSError *))completedBlock
{
    [TTAccountAuthLoginInst(type) requestLogout:completedBlock];
}

+ (void)requestLoginForPlatform:(TTAccountAuthType)type
                      willLogin:(void (^)(NSString *))willLoginBlock
                     completion:(TTAccountLoginCompletedBlock)completedBlock;
{
    BOOL useCustomWebView = NO;
    if ([self canSSOForPlatform:type] || [self canWebSSOForPlatform:type]) {
        useCustomWebView = NO;
    } else {
        useCustomWebView = YES;
    }
    [self requestLoginForPlatform:type inCustomWebView:useCustomWebView willLogin:willLoginBlock completion:completedBlock];
}

+ (void)requestLoginForPlatform:(TTAccountAuthType)type
                inCustomWebView:(BOOL)useCustomWap
                      willLogin:(void (^)(NSString *))willLoginBlock
                     completion:(TTAccountLoginCompletedBlock)completedBlock
{
    if (TTAccountAuthTypeUnsupport == type) {
        NSError *error = [NSError errorWithDomain:TTAccountErrorDomain code:TTAccountAuthTypeUnsupport userInfo:@{NSLocalizedDescriptionKey: @"目前不支持的三方平台"}];
        if (completedBlock) {
            completedBlock(NO, error);
        }
        return;
    }
    
    id<TTAccountAuthProtocol> accountPlatformInst = TTAccountAuthLoginInst(type);
    [accountPlatformInst requestLoginByCustomWebView:useCustomWap willLogin:willLoginBlock completion:^(TTAccountAuthResponse *resp, NSError *error) {
        
        if (error && TTAccountErrCodeAccountBoundForbid == error.code) {
            // logger
            [TTAccountLogDispatcher dispatchAccountAuthPlatformBoundForbidError];
            
            if ([TTAccount accountConf].unbindAlertEnabled) {
                [self.class alertAccountUnbindWithAuthResponse:resp passError:error willLogin:willLoginBlock completion:^(BOOL success, NSError *error) {
                    if (completedBlock) {
                        completedBlock(success, error);
                    }
                    
                    // 授权平台登录埋点
                    if (!error && (resp.errCode == TTAccountAuthSuccess)) {
                        [TTAccountLogDispatcher dispatchAccountLoginSuccessWithReason:TTAccountStatusChangedReasonTypeAuthPlatformLogin platform:resp.platformName];
                    } else {
                        [TTAccountLogDispatcher dispatchAccountLoginFailureWithReason:TTAccountStatusChangedReasonTypeAuthPlatformLogin platform:resp.platformName];
                    }
                }];
                return;
            }
        }
        
        BOOL blockToRetryLogin = NO;
        if (resp.errCode != TTAccountAuthSuccess &&
            resp.errCode != TTAccountAuthErrCodeUserCancel &&
            resp.errCode != TTAccountErrCodeAccountBoundForbid &&
            resp.errCode != TTAccountErrCodeAuthPlatformBoundForbid &&
            resp.errCode != TTAccountSuccess) {
            blockToRetryLogin = [self.class alertWhenAuthLoginFailWithResponse:resp willLogin:willLoginBlock completion:completedBlock];
        }
        
        if (!blockToRetryLogin) {
            if (completedBlock) {
                completedBlock((!error && (resp.errCode == TTAccountAuthSuccess)), error);
            }
        }
        
        // 授权平台登录埋点
        if (!error && (resp.errCode == TTAccountAuthSuccess)) {
            [TTAccountLogDispatcher dispatchAccountLoginSuccessWithReason:TTAccountStatusChangedReasonTypeAuthPlatformLogin platform:resp.platformName];
        } else {
            [TTAccountLogDispatcher dispatchAccountLoginFailureWithReason:TTAccountStatusChangedReasonTypeAuthPlatformLogin platform:resp.platformName];
        }
    }];
}

#pragma mark - alert error and retry login by custom TTACustomWapAuthViewController

+ (BOOL)alertWhenAuthLoginFailWithResponse:(TTAccountAuthResponse *)response willLogin:(void (^)(NSString *))willLoginBlock completion:(TTAccountLoginCompletedBlock)completedBlock
{
    if ([TTAccount accountConf].showAlertWhenLoginFail) {
        NSString *platformDisplayName = [TTAccountAuthLoginClass(response.platformType) displayName];
        NSString *msg = [NSString stringWithFormat:@"%@账号%@异常", platformDisplayName, ([[TTAccount sharedAccount] isLogin] ? @"绑定" : @"登录")];
        if (response.errCode == TTAccountErrCodeSessionExpired) {
            msg = NSLocalizedString(@"获取授权信息出错，建议在WiFi下尝试", nil);
        }
        
        [TTAccountIndicatorView showWithIndicatorStyle:kTTAccountIndicatorViewStyleImage
                                         indicatorText:msg
                                        indicatorImage:[UIImage tta_imageNamed:@"tta_close_popup_textpage"]
                                           autoDismiss:YES
                                        dismissHandler:nil];
    }
    
    if ([response isSDKAuth]) {
        // 仅仅使用SDK授权登录失败才重试，否则使用非SDK登录失败不能重试登录
        
        // 默认值
        BOOL retryLoginEnabled   = [TTAccountAuthLoginManager canCustomWebSSOForPlatform:response.platformType];
        BOOL retryCustomWAPLogin = [[TTAccount accountConf] tta_tryCustomWAPLoginWhenSDKFailureForPlatformType:response.platformType];
        retryLoginEnabled = retryCustomWAPLogin && retryLoginEnabled;
        
        if (retryLoginEnabled) {
            // SDK授权登录失败，尝试使用自定义WAP授权登录
            [self.class requestLoginForPlatform:response.platformType inCustomWebView:YES willLogin:willLoginBlock completion:completedBlock];
            return YES;
        }
    }
    
    return NO;
}

#pragma mark - bind/unbind auth platform

+ (void)requestBindForPlatform:(TTAccountAuthType)type
                      willBind:(void (^)(NSString *))willBindBlock
                    completion:(TTAccountLoginCompletedBlock)completedBlock
{
    [self.class requestLoginForPlatform:type willLogin:willBindBlock completion:completedBlock];
}

+ (void)requestBindForPlatform:(TTAccountAuthType)type
               inCustomWebView:(BOOL)useCustomWap
                      willBind:(void (^)(NSString *))willBindBlock
                    completion:(TTAccountLoginCompletedBlock)completedBlock
{
    [self.class requestLoginForPlatform:type inCustomWebView:useCustomWap willLogin:willBindBlock completion:completedBlock];
}

+ (void)requestUnbindForPlatform:(TTAccountAuthType)type
                      completion:(void (^)(BOOL success, NSError *error))completedBlock
{
    [self.class requestLogoutForPlatform:type completion:completedBlock];
}


#pragma mark - callback about switch bind

/**
 *  Alert提示账号已被绑定，是否解绑
 */
+ (void)alertAccountUnbindWithAuthResponse:(TTAccountAuthResponse *)authResp
                                 passError:(NSError *)passError
                                 willLogin:(void (^)(NSString *))willLoginBlock
                                completion:(TTAccountLoginCompletedBlock)completedBlock
{
    NSDictionary *userInfoInError = passError.userInfo;
    NSString *dialogTitle = [userInfoInError valueForKey:@"error_description"];
    NSString *dialogDesp  = [userInfoInError valueForKey:@"dialog_tips"];
    NSString *authToken   = [userInfoInError valueForKey:@"auth_token"];
    UIAlertView *dropAccountAlertView = [[UIAlertView alloc] initWithTitle:dialogTitle message:nil delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:@"放弃原账号", nil];
    [dropAccountAlertView show];
    dropAccountAlertView.tta_tapBlock = ^(UIAlertView *alertView, NSInteger buttonIndex) {
        BOOL cancelled = (buttonIndex == alertView.cancelButtonIndex);
        
        // logger
        [TTAccountLogDispatcher dispatchDropOriginalAccountAlertViewDidCancel:cancelled forPlatform:authResp.platformType];
        
        if (!cancelled) {
            // 切换绑定
            UIAlertView *unbindAlertView = [[UIAlertView alloc] initWithTitle:dialogDesp message:nil delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:@"确认", nil];
            [unbindAlertView show];
            unbindAlertView.tta_tapBlock = ^(UIAlertView *alertView, NSInteger buttonIndex) {
                BOOL cancelled = (buttonIndex == alertView.cancelButtonIndex);
                
                // logger
                [TTAccountLogDispatcher dispatchSwitchBindAlertViewDidCancel:cancelled forPlatform:authResp.platformType];
                
                //绑定第三方账号时提示已绑定其他账号， 确认放弃原账号
                if (!cancelled) {
                    /**
                     *  走sso_callback在返回已绑定错误时，同时返回auth_token; 客户端通过auth_token，请求新的API（sso_switch_bind）
                     */
                    if (authToken && [authResp isSDKAuth]) {
                        // 通过SNSSDK登录第三方平台时，解绑操作
                        TTASNSSDKAuthSwitchBindReqModel *unbindReqMdl = [TTASNSSDKAuthSwitchBindReqModel new];
                        unbindReqMdl.mid = [[TTAccount accountConf] tta_ssMID];
                        unbindReqMdl.platform = authResp.platformName;
                        unbindReqMdl.auth_token = authToken;
                        
                        [TTAccountAuthCallbackTask startSNSSDKAuthSwitchBindWithReq:unbindReqMdl completedBlock:^(TTASNSSDKAuthSwitchBindRespModel *aRespMdl, NSError *respError) {
                            // 绑定第三方账号时提示已绑定其他账号，成功放弃原账号
                            
                            if (!respError && [aRespMdl isRespSuccess]) {
                                // SNSSDK SwitchBind成功
                                // 1. 保存用户信息
                                TTAccountUserEntity *user = [[TTAccountUserEntity alloc] initWithUserModel:aRespMdl.data];
                                if (user) {
                                    if ([[TTAccount sharedAccount] respondsToSelector:@selector(setUser:)]) {
                                        [[TTAccount sharedAccount] performSelector:@selector(setUser:) withObject:user];
                                    }
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
                                    if ([[TTAccount sharedAccount] respondsToSelector:@selector(setIsLogin:)]) {
                                        [[TTAccount sharedAccount] setIsLogin:YES];
                                    }
#pragma clang diagnostic pop
                                }
                                
                                // 2. 广播消息
                                BOOL isSignOn = [[TTAccount sharedAccount] isLogin];
                                if (!isSignOn) {
                                    // 登录
                                    [TTAccountMulticastDispatcher dispatchAccountLoginSuccess:user platform:authResp.platformName reason:TTAccountStatusChangedReasonTypeAuthPlatformLogin bisectBlock:^{
                                        // 3. callback
                                        if (completedBlock) {
                                            completedBlock(YES, nil);
                                        }
                                    }];
                                } else {
                                    // 绑定账号
                                    [TTAccountMulticastDispatcher dispatchAccountLoginAuthPlatform:authResp.platformName error:nil bisectBlock:^{
                                        // 3. callback
                                        if (completedBlock) {
                                            completedBlock(YES, nil);
                                        }
                                    }];
                                }
                                
                            } else {
                                if (completedBlock) {
                                    completedBlock(NO, respError ? : passError);
                                }
                            }
                            
                            // logger
                            [TTAccountLogDispatcher dispatchSSOSwitchBindDidCompleteWithError:(respError ? : passError)];
                        }];
                    } else if (authToken) {
                        // 通过自定义WAP登录第三方平台时，解绑操作
                        TTACustomWAPAuthSwitchBindReqModel *unbindReqMdl = [TTACustomWAPAuthSwitchBindReqModel new];
                        unbindReqMdl.mid = [[TTAccount accountConf] tta_ssMID];
                        unbindReqMdl.platform     = authResp.platformName;
                        unbindReqMdl.unbind_exist = YES;
                        unbindReqMdl.auth_token   = authToken;
                        
                        [TTAccountAuthCallbackTask startWAPAuthSwitchBindWithReq:unbindReqMdl completedBlock:^(TTACustomWAPAuthSwitchBindRespModel *aRespMdl, NSError *error, NSInteger httpStatusCode) {
                            // 绑定第三方账号时提示已绑定其他账号，成功放弃原账号
                            if (!error || labs(error.code) == 302 || labs(httpStatusCode) == 302) {
                                // Retry Use Custom WAP ReLogin
                                [self.class requestLoginForPlatform:authResp.platformType inCustomWebView:YES willLogin:willLoginBlock completion:^(BOOL success, NSError *error) {
                                    if (completedBlock) {
                                        completedBlock(success, error ? : (success ? nil : passError));
                                    }
                                }];
                            } else {
                                if (completedBlock) {
                                    completedBlock(NO, error ? : passError);
                                }
                            }
                            
                            // logger
                            [TTAccountLogDispatcher dispatchCustomWebSSOSwitchBindDidCompleteWithError:(error ? : passError)];
                        }];
                    } else {
                        // authToken = nil
                        if (completedBlock) {
                            completedBlock(NO, passError);
                        }
                    }
                } else {
                    if (completedBlock) {
                        completedBlock(NO, passError);
                    }
                }
            };
        } else {
            if (completedBlock) {
                completedBlock(NO, passError);
            }
        }
    };
}

#pragma mark - sso_callback

+ (id<TTAccountSessionTask>)loginWithSSOCallback:(NSDictionary *)params
                                     forPlatform:(NSInteger)platformType
                                       willLogin:(void (^)(NSString *))willLoginBlock
                                      completion:(void(^)(BOOL success, BOOL loginOrBind, NSError *error))completedBlock
{
    NSString *platformName = params[@"platform_name"];
    if (!platformName) platformName = [self.class platformForAccountAuthType:platformType];
    
    NSCAssert(platformType != TTAccountAuthTypeUnsupport, @"必须指定第三方授权平台类型");
    NSAssert(platformName, @"platform_name cann't be nil");
    
    NSMutableDictionary *postParams = [NSMutableDictionary dictionaryWithCapacity:2];
    [postParams setValue:[[TTAccount accountConf] tta_ssAppID] forKey:@"aid"];
    [postParams setValue:[[TTAccount accountConf] tta_ssMID] forKey:@"mid"];
    [postParams setValue:platformName forKey:@"platform"];
    [postParams setValue:params[@"platform_app_id"] forKey:@"platform_app_id"];
    [postParams setValue:params[@"code"] forKey:@"code"];
    [postParams setValue:params[@"openid"] forKey:@"openid"];
    [postParams setValue:params[@"access_token"] forKey:@"access_token"];
    [postParams setValue:params[@"refresh_token"] forKey:@"refresh_token"];
    [postParams setValue:params[@"expires_in"] forKey:@"expires_in"];
    [postParams setValue:params[@"uid"] forKey:@"uid"];
    
    id<TTAccountSessionTask> loginTask = [TTAccountAuthCallbackTask startSNSSDKSSOAuthCallbackWithParams:postParams completedBlock:^(TTASNSSDKAuthCallbackRespModel *aRespMdl, NSError *error) {
        
        BOOL isSignOn = [[TTAccount sharedAccount] isLogin];
        BOOL containsPlatform = (nil != [[TTAccount sharedAccount] connectedAccountForPlatform:platformName]);
        BOOL isLoginByPlatform = !isSignOn || containsPlatform;
        if (!error) {
            TTAccountUserEntity *updatedUser = [[TTAccountUserEntity alloc] initWithUserModel:aRespMdl.data];
            updatedUser.sessionKey = updatedUser.sessionKey ? : aRespMdl.session_key;
            
            if (updatedUser) {
                // 保存或更新用户信息
                [[TTAccount sharedAccount] setUser:updatedUser];
                [[TTAccount sharedAccount] setIsLogin:YES];
                
                if (!isSignOn) {
                    // 通过第三方平台授权登录头条
                    [TTAccountMulticastDispatcher dispatchAccountLoginSuccess:updatedUser platform:platformName reason:TTAccountStatusChangedReasonTypeAuthPlatformLogin bisectBlock:^{
                        if (completedBlock) {
                            completedBlock(YES, YES, nil);
                        }
                    }];
                } else {
                    // 绑定账号
                    [TTAccountMulticastDispatcher dispatchAccountLoginAuthPlatform:platformName error:nil bisectBlock:^{
                        if (completedBlock) {
                            completedBlock(YES, isLoginByPlatform, nil);
                        }
                    }];
                }
                return;
            }
            
            NSMutableDictionary *userInfoInError = [NSMutableDictionary dictionary];
            [userInfoInError setValue:aRespMdl.errorDescription ? : TTAccountGetErrorCodeDescription(TTAccountErrCodeServerDataFormatInvalid)
                               forKey:TTAccountErrMsgKey];
            error = [NSError errorWithDomain:TTAccountErrorDomain code:aRespMdl.errorCode userInfo:userInfoInError];
        }
        
        TTAccountAuthResponse *baseAuthResp = [TTAccountAuthResponse new];
        baseAuthResp.sdkAuth = YES;
        baseAuthResp.ssoAuth = YES;
        baseAuthResp.platformType = platformType;
        baseAuthResp.platformName = platformName;
        baseAuthResp.platformAppId = params[@"platform_app_id"];
        baseAuthResp.errCode = error.code;
        
        // 处理错误CASE
        if (error && TTAccountErrCodeAccountBoundForbid == error.code) {
            // logger
            [TTAccountLogDispatcher dispatchAccountAuthPlatformBoundForbidError];
            
            if ([TTAccount accountConf].unbindAlertEnabled) {
                [self.class alertAccountUnbindWithAuthResponse:baseAuthResp passError:error willLogin:willLoginBlock completion:^(BOOL success, NSError *error) {
                    if (completedBlock) {
                        completedBlock(success, isLoginByPlatform, error);
                    }
                    
                    // 授权平台登录埋点
                    if (!error && (baseAuthResp.errCode == TTAccountAuthSuccess)) {
                        [TTAccountLogDispatcher dispatchAccountLoginSuccessWithReason:TTAccountStatusChangedReasonTypeAuthPlatformLogin platform:platformName];
                    } else {
                        [TTAccountLogDispatcher dispatchAccountLoginFailureWithReason:TTAccountStatusChangedReasonTypeAuthPlatformLogin platform:platformName];
                    }
                }];
                return;
            }
        }
        
        if (error &&
            error.code != TTAccountAuthSuccess &&
            error.code != TTAccountAuthErrCodeUserCancel &&
            error.code != TTAccountErrCodeAccountBoundForbid &&
            error.code != TTAccountErrCodeAuthPlatformBoundForbid &&
            error.code != TTAccountSuccess) {
            [self.class alertWhenAuthLoginFailWithResponse:baseAuthResp willLogin:willLoginBlock completion:^(BOOL success, NSError *error) {
                if (completedBlock) {
                    completedBlock(success, isLoginByPlatform, error);
                }
            }];
        }
        
        // 授权平台登录埋点
        if (!error || (error.code == TTAccountAuthSuccess)) {
            [TTAccountLogDispatcher dispatchAccountLoginSuccessWithReason:TTAccountStatusChangedReasonTypeAuthPlatformLogin platform:platformName];
        } else {
            [TTAccountLogDispatcher dispatchAccountLoginFailureWithReason:TTAccountStatusChangedReasonTypeAuthPlatformLogin platform:platformName];
        }
        
        if (completedBlock) {
            completedBlock(NO, isLoginByPlatform, error);
        }
    }];
    
    return loginTask;
}

@end
