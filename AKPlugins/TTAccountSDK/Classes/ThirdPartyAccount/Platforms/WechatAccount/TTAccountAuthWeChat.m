//
//  TTAccountAuthWeChat.m
//  TTAccountSDK
//
//  Created by liuzuopeng on 2/9/17.
//  Copyright © 2017 com.bytedance.news. All rights reserved.
//

#import "TTAccountAuthWeChat.h"
#import "TTAccountConfiguration_Priv+PlatformAccount.h"
#import "TTAccount.h"
#import "TTACustomWapAuthViewController.h"
#import "NSString+TTAccountUtils.h"
#import "NSBundle+TTAResources.h"
#import "TTAccountLogoutTask.h"
#import "TTAccountUserProfileTask.h"
#import "TTAccountAuthCallbackTask.h"
#import "TTAccountUserEntity_Priv.h"
#import "TTAccountMulticastDispatcher.h"
#import "TTAccountLogDispatcher+ThirdPartyAccount.h"
#import <WXApi.h>



@interface TTAccountAuthWeChat ()
<
WXApiDelegate
> {
    BOOL _isSDKAuthorizing; // 是否通过第三方SDK或自定义WAP进行授权
    BOOL _isSSOAuthorizing; // 是否通过SSO进行授权
    BOOL _isInBackground;   // 是否从后台唤醒
    BOOL _isWXAuthResp;     // 是否是微信授权响应（忽略分享、支付等响应）
}
@property (nonatomic,   copy) NSString *appId;
@property (nonatomic,   copy) NSString *scope;
@property (nonatomic, strong) NSDictionary *customUserInfo;

@property (nonatomic,   copy) NSString *code;

@property (nonatomic,   copy) TTAccountAuthWillLoginBlock willLoginHandler;
@property (nonatomic,   copy) TTAccountAuthLoginCompletedBlock loginCompletedHandler;
@end

@implementation TTAccountAuthWeChat

TTAccountSingletonImp

- (instancetype)init
{
    if ((self = [super init])) {
        _isSDKAuthorizing = NO;
        _isSSOAuthorizing = NO;
        _isInBackground   = NO;
        _isWXAuthResp     = NO;
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(tryCancelAuthWhenAppDidBeActive:)
                                                     name:UIApplicationDidBecomeActiveNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(appDidEnterBackground:)
                                                     name:UIApplicationDidEnterBackgroundNotification
                                                   object:nil];
    }
    return self;
}

- (void)dealloc
{
    [self reset];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


#pragma mark - notification

- (void)appDidEnterBackground:(NSNotification *)note
{
    _isInBackground = YES;
}

- (void)tryCancelAuthWhenAppDidBeActive:(NSNotification *)note
{
    /** 只有通过通过跳转至第三方APP进行SSO授权时，回到当前APP前台时会取消操作 */
    if (_isSDKAuthorizing && _isSSOAuthorizing && _isInBackground) {
        [self authorizeDidFinishWithErrCode:TTAccountAuthErrCodeUserCancel error:nil code:nil state:nil];
    }
    {
        _isInBackground = NO;
    }
}


#pragma mark - public methods

+ (void)registerApp:(NSString *)appID
{
    [[self sharedInstance] registerApp:appID];
}

- (void)registerApp:(NSString *)appID
{
    _appId = appID;
    [WXApi registerApp:appID];
}

+ (BOOL)handleOpenURL:(NSURL *)url
{
    [[self sharedInstance] __laziedRegisterSDKIfNeeded__];
    return [[self sharedInstance] handleOpenURL:url];
}

- (BOOL)handleOpenURL:(NSURL *)url
{
    BOOL canHandle = [WXApi handleOpenURL:url delegate:self];
    canHandle = canHandle && _isWXAuthResp;
    
    {
        _isWXAuthResp = NO;
    }
    
    return canHandle;
}

+ (BOOL)isSupportSSO
{
    [[self sharedInstance] __laziedRegisterSDKIfNeeded__];
    return ([WXApi isWXAppInstalled] /* 若没注册[WXApi registerApp:appID]，一定返回NO */ &&
            [WXApi isWXAppSupportApi]);
}

+ (BOOL)isSupportWebSSO
{
    return NO;
}

+ (BOOL)isSupportCustomWebSSO
{
    return NO;
}

+ (BOOL)isAppInstalled
{
    [[self sharedInstance] __laziedRegisterSDKIfNeeded__];
    return [WXApi isWXAppInstalled]; /* 若没注册[WXApi registerApp:appID]，一定返回NO */
}

+ (BOOL)isAppAvailable
{
    [[self sharedInstance] __laziedRegisterSDKIfNeeded__];
    return [WXApi isWXAppInstalled] && [WXApi isWXAppSupportApi];
}

+ (NSString *)currentVersion
{
    return [WXApi getApiVersion];
}

+ (NSString *)platformName
{
    return [[TTAccount accountConf] tta_platformAppNameForPlatformType:[self.class platformType]];
}

+ (NSString *)platformAppID
{
    // 头条内测默认为55
    return [[TTAccount accountConf] tta_platformAppIdForPlatformType:[self.class platformType]];
}

+ (TTAccountAuthType)platformType
{
    return TTAccountAuthTypeWeChat;
}

+ (NSString *)getAppInstallUrl
{
    return [WXApi getWXAppInstallUrl] ? : @"https://itunes.apple.com/cn/app/id414478124";
}

+ (NSString *)displayName
{
    return [[TTAccount accountConf] tta_platformAppDisplayNameForPlatformType:[self.class platformType]] ? : NSLocalizedString(@"微信", nil);
}

- (void)__laziedRegisterSDKIfNeeded__
{
    if (!self.appId) {
        NSString *consumerKey = [[TTAccount accountConf] tta_consumerKeyForPlatformType:[self.class platformType]];
        NSAssert(consumerKey, @"consumerKey is nil, must call [TTAccount registerPlatform:] to register");
        [self registerApp:consumerKey];
    }
}


#pragma mark - helper

- (void)reset
{
    _newPlatform = NO;
    _code = nil;
}


#pragma mark - login/logout

- (void)requestLoginByCustomWebView:(BOOL)useCustomWap
                         completion:(TTAccountAuthLoginCompletedBlock)completedBlock
{
    [self requestLoginByCustomWebView:useCustomWap willLogin:nil completion:completedBlock];
}

- (void)requestLoginByCustomWebView:(BOOL)useCustomWap
                          willLogin:(TTAccountAuthWillLoginBlock)willLoginBlock
                         completion:(TTAccountAuthLoginCompletedBlock)completedBlock
{
    _willLoginHandler = willLoginBlock;
    _loginCompletedHandler = completedBlock;
    
    [self authorizeInCustomWebView:useCustomWap withCustomUserInfo:nil];
}

- (void)requestLogout:(void(^)(BOOL success, NSError *error))completedBlock
{
    static id<TTAccountSessionTask> logoutTask;
    if (logoutTask) [logoutTask cancel];
    logoutTask = [TTAccountLogoutTask requestLogoutPlatform:[self.class platformName] completion:^(BOOL success, NSError *error) {
        
        if (success && !error) {
            [self reset];
        }
        
        if (completedBlock) {
            completedBlock(success, error);
        }
        
        logoutTask = nil;
    }];
}


#pragma mark - authorize

- (void)authorizeInCustomWebView:(BOOL)useCustomWap withCustomUserInfo:(NSDictionary *)userInfo
{
    {
        _isSDKAuthorizing = NO;
        _isSSOAuthorizing = NO;
    }
    
    if (useCustomWap || ![self.class isSupportSSO]) {
        [self customWapAuthorize];
    } else {
        [self sdkAuthorizeWithScope:nil openID:nil customUserInfo:nil];
    }
}

- (void)customWapAuthorize
{
    [self authorizeDidFinishWithErrCode:TTAccountAuthErrCodeUnsupport error:nil code:nil state:nil];
    
    TTALogE(@"微信不支持Wap登录，请使用[authorizeInCustomWebView:NO completion:**]进行登录");
}

- (void)sdkAuthorizeWithScope:(NSString *)scopeString
                       openID:(NSString *)openIdString
               customUserInfo:(NSDictionary *)userInfo
{
    {
        _isSDKAuthorizing = YES;
        if ([self.class isSupportSSO]) {
            _isSSOAuthorizing = YES;
        }
    }
    
    if (!_appId) {
        [self __laziedRegisterSDKIfNeeded__];
    }
    
    if (!_appId) {
        TTALogE(@"appId is nil, [%@ registerApp:***]", NSStringFromClass(self.class));
        [self authorizeDidFinishWithErrCode:TTAccountAuthErrCodeURAppId error:nil code:nil state:nil];
        return;
    }
    
    {
        [self reset];
    }
    
    if (scopeString) {
        _scope = scopeString;
    }
    if (!scopeString) {
        scopeString = [self.class scopeString];
    }
    
    if (userInfo) {
        _customUserInfo = userInfo;
    }
    if (!_customUserInfo) {
        _customUserInfo = [self.class defaultUserInfo];
    }
    
    // 构造SendAuthReq结构体
    SendAuthReq *req = [SendAuthReq new];
    req.scope  = scopeString;
    req.state  = [self.class stateString];
    req.openID = openIdString;
    
    // 客户端向微信终端发送一个SendAuthReq消息结构
    BOOL success = [WXApi sendReq:req];
    if (!success) {
        [self authorizeDidFinishWithErrCode:TTAccountAuthErrCodeSendFail error:nil code:nil state:nil];
    }
}


#pragma mark - WXApiDelegate

- (void)onResp:(BaseResp *)resp
{
    if (![resp isKindOfClass:[SendAuthResp class]]) {
        _isWXAuthResp = NO;
        return;
    } else {
        _isWXAuthResp = YES;
    }
    
    SendAuthResp *authResp   = (SendAuthResp *)resp;
    NSString *stateString    = authResp.state;
    NSString *oldStateString = [self.class stateString];
    if (stateString && oldStateString && ![stateString isEqualToString:oldStateString]) {
        // 验证state字段，防止csrf攻击
        [self authorizeDidFinishWithErrCode:TTAccountAuthErrCodeCSRFAttack error:nil code:nil state:nil];
        return;
    }
    
    // 微信授权
    TTAccountAuthErrCode errCode = TTAccountAuthErrCodeUnknown;
    if (resp.errCode == WXSuccess) {
        errCode = TTAccountAuthSuccess;
    } else if (resp.errCode == WXErrCodeUserCancel) {
        errCode = TTAccountAuthErrCodeUserCancel;
    } else if (resp.errCode == WXErrCodeAuthDeny) {
        errCode = TTAccountAuthErrCodeAuthDeny;
    } else if (resp.errCode == WXErrCodeCommon) {
        errCode = TTAccountAuthErrCodeCommon;
    } else if (resp.errCode == WXErrCodeSentFail) {
        errCode = TTAccountAuthErrCodeSendFail;
    } else if (resp.errCode == WXErrCodeUnsupport) {
        errCode = TTAccountAuthErrCodeUnknown;
    }
    
    NSError *respError = nil;
    if (errCode != TTAccountAuthSuccess) {
        NSMutableDictionary *userInfoInRespError = [NSMutableDictionary dictionaryWithCapacity:2];
        [userInfoInRespError setValue:authResp.errStr forKey:@"wechat_auth_err_msg"];
        [userInfoInRespError setValue:authResp.errStr forKey:TTAccountErrMsgKey];
        [userInfoInRespError setValue:authResp.errStr forKey:NSLocalizedDescriptionKey];
        
        respError = [NSError errorWithDomain:TTAccountErrorDomain code:errCode userInfo:userInfoInRespError];
    }
    [self authorizeDidFinishWithErrCode:errCode error:respError code:authResp.code state:nil];
}


#pragma mark - callled when authorization finished

- (void)authorizeDidFinishWithErrCode:(TTAccountAuthErrCode)statusCode
                                error:(NSError *)error
                                 code:(NSString *)codeString
                                state:(NSString *)stateString
{
    TTAccountWeChatAuthResp *resp = [TTAccountWeChatAuthResp new];
    resp.sdkAuth        = _isSDKAuthorizing;
    resp.ssoAuth        = _isSSOAuthorizing;
    resp.errCode        = (statusCode != TTAccountAuthSuccess) ? statusCode : error.code;
    resp.errmsg         = error.userInfo[TTAccountErrMsgKey] ? : [self.class errMsgForErrCode:resp.errCode];
    resp.appId          = _appId;
    resp.scope          = _scope;
    resp.appSecret      = nil;
    resp.platformName   = [self.class platformName];
    resp.platformType   = [self.class platformType];
    resp.platformAppId  = [self.class platformAppID];
    resp.customUserInfo = _customUserInfo;
    
    resp.code  = codeString;
    resp.state = stateString;
    
    // logger
    NSMutableDictionary *contextInfo = [NSMutableDictionary dictionary];
    [contextInfo setValue:resp.appId forKey:@"app_id"];
    [contextInfo setValue:@(resp.errCode) forKey:@"error_code"];
    [contextInfo setValue:resp.errmsg forKey:@"error_message"];
    [contextInfo setValue:resp.code forKey:@"code"];
    [TTAccountLogDispatcher dispatchAccountAuthPlatform:resp.platformType
                                              bySDKAuth:[resp isSDKAuth]
                                                success:(TTAccountAuthSuccess == resp.errCode)
                                                context:contextInfo];
    
    tta_dispatch_async_main_thread_safe(^{
        NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithCapacity:3];
        [userInfo setValue:@(resp.errCode) forKey:TTAccountStatusCodeKey];
        [userInfo setValue:@(resp.platformType) forKey:TTAccountAuthPlatformTypeKey];
        [userInfo setValue:resp.platformName forKey:TTAccountAuthPlatformNameKey];
        [userInfo setValue:resp forKey:TTAccountAuthPlatformResponseKey];
        if (resp.errCode != TTAccountAuthSuccess) {
            NSError *errorInNot = [NSError errorWithDomain:TTAccountErrorDomain
                                                      code:resp.errCode
                                                  userInfo:@{TTAccountErrMsgKey: resp.errmsg ? : @""}];
            [userInfo setValue:resp.errmsg forKey:TTAccountErrMsgKey];
            [userInfo setValue:errorInNot forKey:TTAccountErrorKey];
        } else {
            [userInfo setValue:codeString forKey:@"code"];
            [userInfo setValue:stateString forKey:@"state"];
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:TTAccountPlatformDidAuthorizeCompletionNotification
                                                            object:nil
                                                          userInfo:userInfo];
    });
    
    if (TTAccountAuthSuccess == resp.errCode) {
        if (self.willLoginHandler) {
            self.willLoginHandler(resp.platformName);
            self.willLoginHandler = nil;
        }
        [self requestLoginCallbackWithAuthResponse:resp];
    } else {
        [self loginDidFinishWithUser:nil error:error response:resp];
    }
    
    {
        _isSDKAuthorizing = NO;
        _isSSOAuthorizing = NO;
    }
}

- (void)loginDidFinishWithUser:(TTAccountUserEntity *)user error:(NSError *)error response:(TTAccountWeChatAuthResp *)response
{
    BOOL isSignOn = [[TTAccount sharedAccount] isLogin];
    
    if (!error && !user && TTAccountSuccess != response.errCode) {
        NSMutableDictionary *userInfoInError = [NSMutableDictionary dictionary];
        [userInfoInError setValue:response.errmsg ? : TTAccountGetErrorCodeDescription(response.errCode) forKey:TTAccountErrMsgKey];
        error = [NSError errorWithDomain:TTAccountErrorDomain code:response.errCode userInfo:userInfoInError];
    }
    
    // 保存用户信息
    if (!error && user) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
        if ([[TTAccount sharedAccount] respondsToSelector:@selector(setUser:)]) {
            [[TTAccount sharedAccount] performSelector:@selector(setUser:) withObject:user];
        }
        
        if ([[TTAccount sharedAccount] respondsToSelector:@selector(setIsLogin:)]) {
            [[TTAccount sharedAccount] setIsLogin:YES];
        }
#pragma clang diagnostic pop
    }
    
    if (!error && user) {
        if (!isSignOn) {
            // 通过第三方平台授权登录
            [TTAccountMulticastDispatcher dispatchAccountLoginSuccess:user platform:response.platformName reason:TTAccountStatusChangedReasonTypeAuthPlatformLogin bisectBlock:^{
                if (_loginCompletedHandler) {
                    _loginCompletedHandler(response, error);
                    _loginCompletedHandler = nil;
                }
            }];
        } else {
            // 绑定账号
            [TTAccountMulticastDispatcher dispatchAccountLoginAuthPlatform:response.platformName error:error bisectBlock:^{
                if (_loginCompletedHandler) {
                    _loginCompletedHandler(response, error);
                    _loginCompletedHandler = nil;
                }
            }];
        }
    } else {
        if (_loginCompletedHandler) {
            _loginCompletedHandler(response, error);
            _loginCompletedHandler = nil;
        }
    }
}


#pragma mark - login callback

- (void)requestLoginCallbackWithAuthResponse:(TTAccountWeChatAuthResp *)response
{
    static id<TTAccountSessionTask> loginTask;
    if (loginTask) [loginTask cancel];
    
    if ([response isSDKAuth]) {
        NSMutableDictionary *postParams = [NSMutableDictionary dictionaryWithCapacity:2];
        [postParams setValue:[[TTAccount accountConf] tta_ssAppID] forKey:@"aid"];
        [postParams setValue:[[TTAccount accountConf] tta_ssMID] forKey:@"mid"];
        [postParams setValue:response.platformName forKey:@"platform"];
        [postParams setValue:response.platformAppId forKey:@"platform_app_id"];
        [postParams setValue:response.code forKey:@"code"];
        
        loginTask = [TTAccountAuthCallbackTask startSNSSDKSSOAuthCallbackWithParams:postParams completedBlock:^(TTASNSSDKAuthCallbackRespModel *aRespMdl, NSError *error) {
            self.newPlatform = aRespMdl.new_platform;
            if (!error) {
                TTAccountUserEntity *updatedUser = [[TTAccountUserEntity alloc] initWithUserModel:aRespMdl.data];
                updatedUser.sessionKey = updatedUser.sessionKey ? : aRespMdl.session_key;
                [self loginDidFinishWithUser:updatedUser error:nil response:response];
            } else {
                [self loginDidFinishWithUser:nil error:error response:response];
            }
            
            loginTask = nil;
        }];
    } else {
        // 是否需要同步登录
        BOOL loginWaited __unused = ![[TTAccount sharedAccount] isLogin];
        
        [self getUserInfoWithAuthResponse:response waitUtilGetUserInfo:YES];
    }
}

- (void)getUserInfoWithAuthResponse:(TTAccountWeChatAuthResp *)response waitUtilGetUserInfo:(BOOL)wait
{
    // 最多尝试三次
    static id<TTAccountSessionTask> getUserInfoTask = nil;
    static NSInteger retryTimes = 0;
    retryTimes++;
    
    if (retryTimes > 3) {
        retryTimes = 0;
        NSMutableDictionary *userInfoInError = [NSMutableDictionary dictionary];
        [userInfoInError setValue:TTAccountGetErrorCodeDescription(TTAccountErrCodeNetworkFailure) forKey:@"error_description"];
        NSError *error = [NSError errorWithDomain:TTAccountErrorDomain code:TTAccountErrCodeNetworkFailure userInfo:userInfoInError];
        [self loginDidFinishWithUser:nil error:error response:response];
        return;
    }
    
    if (getUserInfoTask) [getUserInfoTask cancel];
    
    void (^tta_getAccountUserInfoForLoginBlock)(void(^completedBlock)(TTAccountUserEntity *userEntity, NSError *error)) = ^(void(^completedBlock)(TTAccountUserEntity *userEntity, NSError *error)) {
        // 获取用户信息
        getUserInfoTask = [TTAccountUserProfileTask startGetUserInfoWithCompletion:^(TTAccountUserEntity *userEntity, NSError *error) {
            
            if (!error && userEntity) {
                retryTimes = 0;
            }
            
            if (completedBlock) {
                completedBlock(userEntity, error);
            }
            
            getUserInfoTask = nil;
        }];
    };
    
    // 是否需要同步登录
    if (wait) {
        
        tta_getAccountUserInfoForLoginBlock(^(TTAccountUserEntity *userEntity, NSError *error) {
            if (!error && userEntity) {
                [self loginDidFinishWithUser:userEntity error:nil response:response];
            } else {
                [self getUserInfoWithAuthResponse:response waitUtilGetUserInfo:wait];
            }
        });
        
    } else {
        
        [self loginDidFinishWithUser:nil error:nil response:response];
        
        tta_getAccountUserInfoForLoginBlock(^(TTAccountUserEntity *userEntity, NSError *error) {
            retryTimes = 0;
        });
    }
}


#pragma mark - privates

+ (NSString *)scopeString
{
    return @"snsapi_userinfo";
}

+ (NSString *)stateString
{
    return @"com.toutiao.account.auth.wechat.state";
}

+ (NSDictionary *)defaultUserInfo
{
    return @{@"SSO_From": NSStringFromClass([self class]),
             @"class"   : NSStringFromClass([self class]),
             @"corp"    : @"com.toutiao.bytedance",
             @"state"   : [self stateString]
             };
}

+ (NSString *)errMsgForErrCode:(TTAccountAuthErrCode)errcode
{
    static NSDictionary *msgMapper = nil;
    if (!msgMapper) {
        msgMapper = @{
                      @(TTAccountAuthErrCodeUnknown)           : [NSString stringWithFormat:@"%@-%@", [self.class displayName], @"未知授权错误码"],
                      @(TTAccountAuthSuccess)                  : [NSString stringWithFormat:@"%@-%@", [self.class displayName], @"授权成功"],
                      @(TTAccountAuthErrCodeCommon)            : [NSString stringWithFormat:@"%@-%@", [self.class displayName], @"普通错误"],
                      @(TTAccountAuthErrCodeURAppId)           : [NSString stringWithFormat:@"%@-%@", [self.class displayName], @"没有注册AppID"],
                      @(TTAccountAuthErrCodeUserCancel)        : [NSString stringWithFormat:@"%@-%@", [self.class displayName], @"用户主动取消"],
                      @(TTAccountAuthErrCodeSendFail)          : [NSString stringWithFormat:@"%@-%@", [self.class displayName], @"发送授权请求失败"],
                      @(TTAccountAuthErrCodeNetworkFail)       : [NSString stringWithFormat:@"%@-%@", [self.class displayName], @"网络错误"],
                      @(TTAccountAuthErrCodeAuthDeny)          : [NSString stringWithFormat:@"%@-%@", [self.class displayName], @"授权失败"],
                      @(TTAccountAuthErrCodeUnsupport)         : [NSString stringWithFormat:@"%@-%@", [self.class displayName], @"平台不支持"],
                      @(TTAccountAuthErrCodeCancelInstall)     : [NSString stringWithFormat:@"%@-%@", [self.class displayName], @"取消应用下载"],
                      @(TTAccountAuthErrCodeCSRFAttack)        : [NSString stringWithFormat:@"%@-%@", [self.class displayName], @"csrf攻击"],
                      };
    }
    return msgMapper[@(errcode)] ? : TTAccountGetErrorCodeDescription((TTAccountErrCode)errcode);;
}

@end

