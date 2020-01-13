//
//  TTAccountLoggerImp.m
//  Article
//
//  Created by liuzuopeng on 01/08/2017.
//
//

#import "TTAccountLoggerImp.h"
#import "TTAccountBusiness.h"
#import <TTInstallIDManager.h>
#import "TTAccountTestSettings.h"
#import <UIAlertView+Blocks.h>
#import <BDTSharedHeaders/SSCommonDefines.h>
#import "FHUserInfoManager.h"
#import <FHHouseBase/FHMainApi.h>

#define DEFULT_ERROR @"请求错误"
#define API_ERROR_CODE  10000
#define API_NO_DATA     10001
#define API_WRONG_DATA  10002


@implementation TTAccountLoggerImp : NSObject

#pragma mark - TTAccountLogger

- (void)accountLoginSuccess:(TTAccountStatusChangedReasonType)reasonType
                   platform:(NSString *)platformName
{
    NSMutableDictionary *extraDict = [NSMutableDictionary dictionary];
    [extraDict setValue:@(1) forKey:@"status"]; // 登录成功
    [[TTMonitor shareManager] trackService:@"tt_account_login_success" attributes:extraDict];
    
    /** 各个子事件 */
    switch (reasonType) {
        case TTAccountStatusChangedReasonTypeLogout: // use `accountLogoutSuccess`
        case TTAccountStatusChangedReasonTypeSessionExpiration: { // none
            
        }
            break;
        case TTAccountStatusChangedReasonTypeAutoSyncLogin: {
            NSMutableDictionary *extraDict = [NSMutableDictionary dictionary];
            [extraDict setValue:@(1) forKey:@"status"];
            [[TTMonitor shareManager] trackService:@"tt_account_auto_sync_login" attributes:extraDict];
        }
            break;
        case TTAccountStatusChangedReasonTypeFindPasswordLogin: {
            NSMutableDictionary *extraDict = [NSMutableDictionary dictionary];
            [extraDict setValue:@(1) forKey:@"status"];
            [[TTMonitor shareManager] trackService:@"tt_account_find_password_login" attributes:extraDict];
        }
            break;
        case TTAccountStatusChangedReasonTypePasswordLogin: {
            NSMutableDictionary *extraDict = [NSMutableDictionary dictionary];
            [extraDict setValue:@(1) forKey:@"status"];
            [[TTMonitor shareManager] trackService:@"tt_account_phone_password_login" attributes:extraDict];
        }
            break;
        case TTAccountStatusChangedReasonTypeSMSCodeLogin: {
            NSMutableDictionary *extraDict = [NSMutableDictionary dictionary];
            [extraDict setValue:@(1) forKey:@"status"];
            [[TTMonitor shareManager] trackService:@"tt_account_phone_smscode_login" attributes:extraDict];
        }
            break;
        case TTAccountStatusChangedReasonTypeEmailLogin: {
            NSMutableDictionary *extraDict = [NSMutableDictionary dictionary];
            [extraDict setValue:@(1) forKey:@"status"];
            [[TTMonitor shareManager] trackService:@"tt_account_email_password_login" attributes:extraDict];
        }
            break;
        case TTAccountStatusChangedReasonTypeTokenLogin: {
            NSMutableDictionary *extraDict = [NSMutableDictionary dictionary];
            [extraDict setValue:@(1) forKey:@"status"];
            [[TTMonitor shareManager] trackService:@"tt_account_token_password_login" attributes:extraDict];
        }
            break;
        case TTAccountStatusChangedReasonTypeSessionKeyLogin: {
            NSMutableDictionary *extraDict = [NSMutableDictionary dictionary];
            [extraDict setValue:@(1) forKey:@"status"];
            [[TTMonitor shareManager] trackService:@"tt_account_session_key_login" attributes:extraDict];
        }
            break;
        case TTAccountStatusChangedReasonTypeAuthPlatformLogin: {
            NSMutableDictionary *extraDict = [NSMutableDictionary dictionary];
            [extraDict setValue:@(1) forKey:@"status"];
            [extraDict setValue:platformName forKey:@"platform"];
            
            if (platformName) {
                NSString *platformNameStatus = [platformName stringByAppendingString:@"_platform_status"];
                [extraDict setValue:@(1) forKey:platformNameStatus ? : @"***_platform_status"];
            } else {
                [extraDict setValue:@(1) forKey:@"unknown_platform_status"];
            }
            
            [[TTMonitor shareManager] trackService:@"tt_account_platform_auth_login" attributes:extraDict];
        }
            break;
    }
}

- (void)accountLoginFailure:(TTAccountStatusChangedReasonType)reasonType
                   platform:(NSString *)platformName
{
    NSMutableDictionary *extraDict = [NSMutableDictionary dictionary];
    [extraDict setValue:@(0) forKey:@"status"]; // 登录成功
    [[TTMonitor shareManager] trackService:@"tt_account_login_success" attributes:extraDict];
    
    /** 各个子事件 */
    switch (reasonType) {
        case TTAccountStatusChangedReasonTypeLogout: // use `accountLogoutSuccess`
        case TTAccountStatusChangedReasonTypeSessionExpiration: { // none
            
        }
            break;
        case TTAccountStatusChangedReasonTypeAutoSyncLogin: {
            NSMutableDictionary *extraDict = [NSMutableDictionary dictionary];
            [extraDict setValue:@(0) forKey:@"status"];
            [[TTMonitor shareManager] trackService:@"tt_account_auto_sync_login" attributes:extraDict];
        }
            break;
        case TTAccountStatusChangedReasonTypeFindPasswordLogin: {
            NSMutableDictionary *extraDict = [NSMutableDictionary dictionary];
            [extraDict setValue:@(0) forKey:@"status"];
            [[TTMonitor shareManager] trackService:@"tt_account_find_password_login" attributes:extraDict];
        }
            break;
        case TTAccountStatusChangedReasonTypePasswordLogin: {
            NSMutableDictionary *extraDict = [NSMutableDictionary dictionary];
            [extraDict setValue:@(0) forKey:@"status"];
            [[TTMonitor shareManager] trackService:@"tt_account_phone_password_login" attributes:extraDict];
        }
            break;
        case TTAccountStatusChangedReasonTypeSMSCodeLogin: {
            NSMutableDictionary *extraDict = [NSMutableDictionary dictionary];
            [extraDict setValue:@(0) forKey:@"status"];
            [[TTMonitor shareManager] trackService:@"tt_account_phone_smscode_login" attributes:extraDict];
        }
            break;
        case TTAccountStatusChangedReasonTypeEmailLogin: {
            NSMutableDictionary *extraDict = [NSMutableDictionary dictionary];
            [extraDict setValue:@(0) forKey:@"status"];
            [[TTMonitor shareManager] trackService:@"tt_account_email_password_login" attributes:extraDict];
        }
            break;
        case TTAccountStatusChangedReasonTypeTokenLogin: {
            NSMutableDictionary *extraDict = [NSMutableDictionary dictionary];
            [extraDict setValue:@(0) forKey:@"status"];
            [[TTMonitor shareManager] trackService:@"tt_account_token_password_login" attributes:extraDict];
        }
            break;
        case TTAccountStatusChangedReasonTypeSessionKeyLogin: {
            NSMutableDictionary *extraDict = [NSMutableDictionary dictionary];
            [extraDict setValue:@(0) forKey:@"status"];
            [[TTMonitor shareManager] trackService:@"tt_account_session_key_login" attributes:extraDict];
        }
            break;
        case TTAccountStatusChangedReasonTypeAuthPlatformLogin: {
            NSMutableDictionary *extraDict = [NSMutableDictionary dictionary];
            [extraDict setValue:@(0) forKey:@"status"];
            [extraDict setValue:platformName forKey:@"platform"];
            
            if (platformName) {
                NSString *platformNameStatus = [platformName stringByAppendingString:@"_platform_status"];
                [extraDict setValue:@(0) forKey:platformNameStatus ? : @"***_platform_status"];
            } else {
                [extraDict setValue:@(0) forKey:@"unknown_platform_status"];
            }
            
            [[TTMonitor shareManager] trackService:@"tt_account_platform_auth_login" attributes:extraDict];
        }
            break;
    }
}

- (void)accountLogoutSuccess
{
    NSMutableDictionary *extraDict = [NSMutableDictionary dictionary];
    [extraDict setValue:@(1) forKey:@"status"]; // 退出成功
    
    [[TTMonitor shareManager] trackService:@"tt_account_logout_success" attributes:extraDict];
}

- (void)accountLogoutFailure
{
    NSMutableDictionary *extraDict = [NSMutableDictionary dictionary];
    [extraDict setValue:@(0) forKey:@"status"]; // 退出失败
    
    [[TTMonitor shareManager] trackService:@"tt_account_logout_success" attributes:extraDict];
}

- (void)accountSessionExpired:(NSError *)error withUserID:(NSString *)userIDString
{
    // 老的监控
    NSString *errDesp = error.userInfo[TTAccountErrMsgKey] ? : error.userInfo[NSLocalizedDescriptionKey];
    NSMutableDictionary *errExtra = error.userInfo ? [error.userInfo mutableCopy] : [NSMutableDictionary dictionary];
    [errExtra setValue:userIDString forKey:@"user_id"];
    [errExtra setValue:([userIDString length] > 0 ? @(YES) : @(NO)) forKey:@"is_login"];
    [errExtra setValue:(errDesp ? : error.description) forKey:@"error_description"];
    [errExtra setValue:@(error.code) forKey:@"error_code"];
    [[TTMonitor shareManager] trackService:@"account_forced_logout" status:1 extra:errExtra];
}

- (void)accountPlatformExpired:(NSError *)error withPlatform:(NSString *)joinedPlatformString
{
    NSMutableDictionary *userInfo = error.userInfo ? [error.userInfo mutableCopy] : [NSMutableDictionary dictionary];
    [userInfo setValue:joinedPlatformString forKey:@"expired_platforms"];
    [[TTMonitor shareManager] trackService:@"account_coerced_logout" status:3 extra:userInfo];
}

- (void)tencentSDKSSOAuthDidFailureWithResp:(NSDictionary *)respContext
{
    NSMutableDictionary *extraDict = [[NSMutableDictionary alloc] initWithDictionary:respContext];
    [extraDict setValue:[[TTInstallIDManager sharedInstance] deviceID] forKey:@"device_id"];
    
    if ([respContext objectForKey:@"error_code"]) {
        NSInteger errCode = [[respContext objectForKey:@"error_code"] integerValue];
        [extraDict setValue:((errCode == TTAccountAuthErrCodeUserCancel) ? @"1" : @"0") forKey:@"is_cancelled"];
    }
    
    [[TTMonitor shareManager] trackService:@"account_sso_login" status:2 extra:extraDict];
}

- (void)weChatSDKSSOAuthDidFailureWithResp:(NSDictionary *)respContext
{
    NSMutableDictionary *extraDict = [[NSMutableDictionary alloc] initWithDictionary:respContext];
    [extraDict setValue:[[TTInstallIDManager sharedInstance] deviceID] forKey:@"device_id"];
    
    if ([respContext objectForKey:@"error_code"]) {
        NSInteger errCode = [[respContext objectForKey:@"error_code"] integerValue];
        [extraDict setValue:((errCode == TTAccountAuthErrCodeUserCancel) ? @"1" : @"0") forKey:@"is_cancelled"];
    }
    
    [[TTMonitor shareManager] trackService:@"account_sso_login" status:3 extra:extraDict];
}

- (void)weiboSDKSSOAuthDidFailureWithResp:(NSDictionary *)respContext
{
    NSMutableDictionary *extraDict = [[NSMutableDictionary alloc] initWithDictionary:respContext];
    [extraDict setValue:[[TTInstallIDManager sharedInstance] deviceID] forKey:@"device_id"];
    
    if ([respContext objectForKey:@"error_code"]) {
        NSInteger errCode = [[respContext objectForKey:@"error_code"] integerValue];
        [extraDict setValue:((errCode == TTAccountAuthErrCodeUserCancel) ? @"1" : @"0") forKey:@"is_cancelled"];
    }
    
    [[TTMonitor shareManager] trackService:@"account_sso_login" status:1 extra:extraDict];
}

- (void)customWapLoginDidTapSNSBarWithChecked:(BOOL)selected
                                  forPlatform:(TTAccountAuthType)type
{
    NSString *labelName = selected ? @"auth_recommend_on" : @"auth_recommend_off";
    wrapperTrackEvent(@"xiangping", labelName);
}

/**
 *  `auth/login_success` redirect to `snssdk**://`
 */
- (void)customWapAuthCallbackAndRedirectToURL:(NSString *)urlString
                                  forPlatform:(TTAccountAuthType)platformType
                                        error:(NSError *)error
                                      context:(NSDictionary *)contextDict
{
    if (error) {
        NSInteger status = [contextDict objectForKey:@"context_source"] ? [[contextDict objectForKey:@"context_source"] integerValue] : 2;
        NSString *platformName = [TTAccount platformNameForAccountAuthType:platformType];
        
        NSMutableDictionary *extra = [NSMutableDictionary dictionary];
        NSString *message = error.userInfo[kErrorDisplayMessageKey] ? : error.userInfo[TTAccountErrMsgKey];
        if(!isEmptyString(message)) {
            [extra setValue:message forKey:@"message"];
        }
        NSString *errorCode = [NSString stringWithFormat:@"%zd", error.code];
        [extra setObject:errorCode forKey:@"error_code"];
        NSString *deviceID  = [[TTInstallIDManager sharedInstance] deviceID];
        if(!isEmptyString(deviceID)) {
            [extra setValue:deviceID forKey:@"device_id"];
        }
        if(!isEmptyString(platformName)) {
            [extra setValue:platformName forKey:@"platform"];
        }
        if(!isEmptyString(urlString)) {
            [extra setValue:urlString forKey:@"url"];
        }
        [[TTMonitor shareManager] trackService:@"account_oauth_login" status:status extra:extra];
    }
}

- (void)accountAuthPlatformBoundForbidError
{
    wrapperTrackEvent(@"login", @"binding_third_error");
}

- (void)dropOriginalAccountAlertViewDidCancel:(BOOL)cancelled
                                  forPlatform:(TTAccountAuthType)type
{
    if (!cancelled) {
        wrapperTrackEvent(@"login", @"binding_third_abandon");
    } else {
        wrapperTrackEvent(@"login", @"binding_third_cancel");
    }
}

- (void)switchBindAlertViewDidCancel:(BOOL)cancelled
                         forPlatform:(TTAccountAuthType)type
{
    if (!cancelled) {
        wrapperTrackEvent(@"login", @"binding_third_abandon_confirm");
    } else {
        
    }
}

- (void)SSOSwitchBindDidCompleteWithError:(NSError *)error
{
    wrapperTrackEvent(@"login", @"binding_third_abandon_success");
}

- (void)customWebSSOSwitchBindDidCompleteWithError:(NSError *)error
{
    wrapperTrackEvent(@"login", @"binding_third_abandon_success");
}


#pragma mark - TTAccountMonitorProtocol

- (void)onReceiveHttpResp:(id)jsonObj
                    error:(NSError *)error
              originalURL:(NSString *)urlString
{
    NSString *jsonObjDesp = nil;
    if ([jsonObj isKindOfClass:[NSDictionary class]]) {
        jsonObjDesp = [jsonObj description];
        [jsonObjDesp length] > 1000 ? (jsonObjDesp = [jsonObjDesp substringToIndex:1000]) : nil;
    }
    
    NSError *doRespError = error;
    if ([TTAccountTestSettings filterNormalHTTPServerRespErrorEnabled]) {
        if ([self.class isFilterableHttpRespError:doRespError]) {
            doRespError = nil;
        }
    }
    
    NSMutableDictionary *extraDict = [NSMutableDictionary dictionary];
    [extraDict setValue:urlString forKey:@"request_url"];
    [extraDict setValue:jsonObjDesp forKey:@"json_object"];
    [extraDict setValue:doRespError.description forKey:@"error_description"];
    
    NSMutableDictionary *enumValueDict = [NSMutableDictionary dictionary];
    [enumValueDict setValue:@(doRespError.code) forKey:@"error_code"];
    if (urlString) {
        NSURL *url = [NSURL URLWithString:urlString];
        NSString *urlPathErrorCodeKey = [NSString stringWithFormat:@"%@_error_code", url.path];
        if (url) {
            if (doRespError && ![self.class isCaptchaError:doRespError]) { // 非图形验证码错误
                [enumValueDict setValue:@(0) forKey:url.path ? : @"error_url_path"];
                [enumValueDict setValue:@(doRespError.code) forKey:urlPathErrorCodeKey];
            } else {
                [enumValueDict setValue:@(1) forKey:url.path ? : @"error_url_path"];
            }
        } else {
            [enumValueDict setValue:@(1) forKey:@"invalid_url"];
        }
        
        if ([url.path hasPrefix:@"/2/user/info"] ||
            [url.path hasPrefix:@"/user/profile/audit_info"]) {
            NSString *key = [NSString stringWithFormat:@"%@_%ld", url.path, (long)[TTAccountTestSettings delayTimeInterval]];
            if (doRespError) {
                [enumValueDict setValue:@(0) forKey:key];
            } else {
                [enumValueDict setValue:@(1) forKey:key];
            }
            
            //by xsm ,这里是因为服务器在这个接口的返回时增加了我们F自己的字段，这个接口本来返回的模型是在TTAcount sdk里面，不方便修改，所以这里把接口返回保存到我们自己的数据模型中，方便以后字段扩展。
            if([url.path hasPrefix:@"/2/user/info"]){
                __block NSError *backError = error;
                Class cls = NSClassFromString(@"FHUserInfoModel");
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                    id<FHBaseModelProtocol> model = (id<FHBaseModelProtocol>)[self generateModel:jsonObj class:cls error:&backError];
                    if([model isKindOfClass:[FHUserInfoModel class]]){
                        [FHUserInfoManager sharedInstance].userInfo = (FHUserInfoModel *)model;
                    }
                });
            }
        }
    }
    
    [[TTMonitor shareManager] trackService:@"tt_account_request_url" value:enumValueDict extra:extraDict];
}

- (void)onReceiveSessionExpirationWithUser:(NSString *)userIdString
                                     error:(NSError *)error
                               originalURL:(NSString *)urlString
{
    NSString *errDesp = (error.userInfo[TTAccountErrMsgKey] ? : error.userInfo[NSLocalizedDescriptionKey]);
    if (!errDesp) errDesp = error.description;
    NSMutableDictionary *extraDict = [NSMutableDictionary dictionary];
    [extraDict setValue:userIdString forKey:@"user_id"];
    [extraDict setValue:errDesp forKey:@"error_description"];
    
    NSMutableDictionary *enumValueDict = [NSMutableDictionary dictionary];
    [enumValueDict setValue:([userIdString length] > 0 ? @(YES) : @(NO)) forKey:@"is_login"];
    [enumValueDict setValue:urlString forKey:@"request_url"];
    [enumValueDict setValue:@(error.code) forKey:@"error_code"];
    if (error) {
        [enumValueDict setValue:@(0) forKey:@"status"];
    } else {
        [enumValueDict setValue:@(1) forKey:@"status"];
    }
    
    [[TTMonitor shareManager] trackService:@"tt_account_session_expiration" value:enumValueDict extra:extraDict];
}

- (void)onReceivePlatformExpirationWithUser:(NSString *)userIdString
                                   platform:(NSString *)joinedPlatformString
                                      error:(NSError *)error
                                originalURL:(NSString *)urlString
{
    NSString *errDesp = (error.userInfo[TTAccountErrMsgKey] ? : error.userInfo[NSLocalizedDescriptionKey]);
    if (!errDesp) errDesp = error.description;
    NSMutableDictionary *extraDict = [NSMutableDictionary dictionary];
    [extraDict setValue:joinedPlatformString forKey:@"expired_platform"];
    [extraDict setValue:userIdString forKey:@"user_id"];
    [extraDict setValue:errDesp forKey:@"error_description"];
    
    NSMutableDictionary *enumValueDict = [NSMutableDictionary dictionary];
    [enumValueDict setValue:joinedPlatformString forKey:@"expired_platform"];
    [enumValueDict setValue:urlString forKey:@"request_url"];
    [enumValueDict setValue:@(error.code) forKey:@"error_code"];
    if (error) {
        [enumValueDict setValue:@(0) forKey:@"status"];
    } else {
        [enumValueDict setValue:@(1) forKey:@"status"];
    }
    
    [[TTMonitor shareManager] trackService:@"tt_account_platform_expiration" value:enumValueDict extra:extraDict];
}

- (void)onReceiveLoginWrongUser:(NSString *)userIdString
                 wrongUserPhone:(NSString *)userPhoneString
                  originalPhone:(NSString *)inputtedPhoneString
                    originalURL:(NSString *)urlString
{
    NSMutableDictionary *enumValueDict = [NSMutableDictionary dictionary];
    [enumValueDict setValue:urlString forKey:@"request_url"];
    [enumValueDict setValue:userIdString forKey:@"user_id"];
    [enumValueDict setValue:userPhoneString forKey:@"user_phone"];
    [enumValueDict setValue:inputtedPhoneString forKey:@"inputted_phone"];
    if (userPhoneString && inputtedPhoneString && ![userPhoneString isEqualToString:inputtedPhoneString]) {
        [enumValueDict setValue:@(1) forKey:@"status"]; // 手机号登录串号
    } else {
        [enumValueDict setValue:@(2) forKey:@"status"]; // 其他方式登录串号
    }
    
    [[TTMonitor shareManager] trackService:@"tt_account_login_wrong_user" value:enumValueDict extra:nil];
    
#if defined(DEBUG)
    NSString *msgString = @"串号啦，请保持现场，截图钉钉联系研发哥哥->liuzuopeng，谢谢！";
    msgString = [msgString stringByAppendingFormat:@"\nuser_id = %@,\nuser_phone = %@,\ninputted_phone = %@", userIdString, userPhoneString, inputtedPhoneString];
    [UIAlertView showWithTitle:@"串号提醒" message:msgString cancelButtonTitle:@"取消" otherButtonTitles:nil tapBlock:^(UIAlertView * _Nonnull alertView, NSInteger buttonIndex) {

    }];
#endif
}

+ (BOOL)isFilterableHttpRespError:(NSError *)error
{
    if (!error) return NO;
    
    static NSArray *filteredErrCodes = nil;
    if (!filteredErrCodes) {
        filteredErrCodes = // 非错误（是服务端返回的错误提示信息，过滤掉）
        @[
          @(-302                                    ), // URL redirect
          @(TTAccountErrCodeHasRegistered           ), // (1001) 已注册  仅type=1,2时返回
          @(TTAccountErrCodePhoneIsEmpty            ), // (1002) 手机号为空
          @(TTAccountErrCodePhoneError              ), // (1003) 手机号错误
          @(TTAccountErrCodeBindPhoneError          ), // (1004) 手机号绑定错误
          @(TTAccountErrCodeUnbindPhoneError        ), // (1005) 解绑手机号错误
          @(TTAccountErrCodeBindPhoneNotExist       ), // (1006) 绑定不存在
          @(TTAccountErrCodePhoneHasBound           ), // (1007) 该手机号已绑定
          @(TTAccountErrCodeUnregistered            ), // (1008) 未注册
          @(TTAccountErrCodePasswordError           ), // (1009) 密码错误
          @(TTAccountErrCodePasswordIsEmpty         ), // (1010) 密码为空
          @(TTAccountErrCodeUserNotExist            ), // (1011) 用户不存在
          @(TTAccountErrCodePasswordAuthFailed      ), // (1012) 密码验证失败
          @(TTAccountErrCodeUserIdIsEmpty           ), // (1013) 用户id为空
          @(TTAccountErrCodeEmailIsEmpty            ), // (1014) 邮箱为空
          @(TTAccountErrCodeGetSMSCodeTypeError     ), // (1015) 获取验证码类型错误
          @(TTAccountErrCodeSMSCodeNotExistOrExpired), // (1016) 验证码不存在或已过期
          
          @(TTAccountErrCodeThirdPartyUnauthorized  ), // (1021) 未认证的第三方
          @(TTAccountErrCodeClientAuthParamIsEmpty  ), // (1023) 未传入认证client参数
          @(TTAccountErrCodeThirdSecretMissing      ), // (1024) 缺少第三方secret
          
          // 图片验证码错误类型 (1101-1199)
          @(TTAccountErrCodeCaptchaMissing          ), // (1101) 需要图片验证码 同时返回captcha的值
          @(TTAccountErrCodeCaptchaError            ), // (1102) 图片验证码错误 同时返回新的captcha的值
          
          // 短信验证码错误类型 (1201-1299)
          @(TTAccountErrCodeSMSCodeMissing          ), // (1201) 缺少验证码
          @(TTAccountErrCodeSMSCodeError            ), // (1202) 验证码错误
          @(TTAccountErrCodeSMSCodeExpired          ), // (1203) 验证码过期
          @(TTAccountErrCodeSMSCodeTypeError        ), // (1204) 验证码类型错误
          @(TTAccountErrCodeSMSCodeSendError        ), // (1205) 验证码发送错误
          @(TTAccountErrCodeSMSCodeFreqError        ), // (1206) 验证码频率控制错误
          
          /** Custom Error Code  [-5000~-6000] */
          // 网络不可用
          // TTAccountErrCodeNetworkFailure           // (-5000) 当前网络不可用，请稍后重试
          
          // 服务端数据格式不正确类型
          // TTAccountErrCodeServerDataFormatInvalid     ), // (-5001) 一般为服务端返回异常, 返回的json数据不是dict
          // TTAccountErrCodeServerOldVerisonDataInvalid ), // (-5002) 服务端旧版本的JSON数据返回异常
          // TTAccountErrCodeServerDataFormatNotComplyAPI), // (-5003) API未按照约定格式返回
          // TTAccountErrCodeServerException             ), // (-5004)
          // TTAccountErrCodeServerUnavailable           ), // (-5005)
          // TTAccountErrCodeUnresolveServerData         ), // (-5006)
          
          /** 认证/授权 失败 */
          // TTAccountErrCodeAuthorizationFailed           = -5010, // 对应服务端 auth_failed
          /** 头条的登录过期 */
          // TTAccountErrCodeSessionExpired                = -5011, // 对应服务端 session_expired
          /** 第三方授权是否过期，防止用户因某个平台登出而导致账户退出（仅用在话题中） */
          // TTAccountErrCodePlatformExpired               = -5012, // 对应服务端 expired_platform
          
          // TTAccountErrCodeUserNotExisted                = -5013, // 对应服务端 user_not_exist
          // TTAccountErrCodeNameExisted                   = -5014, // 对应服务端 name_existed
          
          
          /** 禁止绑定切换 */
          @(TTAccountErrCodeAccountBoundForbid          ), // -5021, // 对应服务端 connect_switch
          ];
    }
    
    if ([filteredErrCodes containsObject:@(error.code)]) {
        return YES;
    }
    
    return NO;
}

// 判断是否是图形验证码错误
+ (BOOL)isCaptchaError:(NSError *)error
{
    if (!error || ![error isKindOfClass:[NSError class]]) return NO;
    if (!error.userInfo) return NO;
    NSString *captchaString = error.userInfo[@"captcha"];
    if (!captchaString || ![captchaString isKindOfClass:[NSString class]]) return NO;
    return (captchaString.length > 0);
}

- (JSONModel *)generateModel:(NSDictionary *)jsonData class:(Class)class error:(NSError *__autoreleasing *)error {
    if (*error) {
        //there is error
        return nil;
    }
    
    if (!jsonData) {
        *error = [NSError errorWithDomain:@"未请求到数据" code:API_NO_DATA userInfo:nil];
        return nil;
    }
    
    NSError *jerror = nil;
    JSONModel *model = [[class alloc]initWithDictionary:jsonData error:&jerror];

    if (jerror) {
#if DEBUG
        NSLog(@" %s %ld API [%@] make json failed",__FILE__,__LINE__,NSStringFromClass(class));
#endif
        *error = [NSError errorWithDomain:@"数据异常" code:API_WRONG_DATA userInfo:nil];
        return nil;
    }
    
    if ([model respondsToSelector:@selector(status)]) {
        NSString *status = [model performSelector:@selector(status)];
        if (![@"0" isEqualToString:status]) {
            NSString *message = nil;
            if ([model respondsToSelector:@selector(message)]) {
                message = [model performSelector:@selector(message)];
            }
            *error = [NSError errorWithDomain:message?:DEFULT_ERROR code:[status integerValue] userInfo:nil];
        }
    }
    return model;
}

@end

