//
//  TTDefaultJSONResponseSerializer.m
//  Article
//
//  Created by Huaqing Luo on 10/9/15
//
//

#import "TTDefaultJSONResponseSerializer.h"
#import "TTNetworkTouTiaoDefine.h"

#import <TTBaseMacro.h>
#import <TTAccountMulticastDispatcher.h>
#import <TTAccountMonitorDispatcher.h>
#import <TTAccountManager.h>

#import "SSHTTPProcesser.h"
#import "SSCommonLogic.h"
#import "TTAccountTestSettings.h"


/**
  * 将新版api的后端业务错误放在userinfo里返回，约定key，用于上层业务的获取和处理，
  * 用以解决业务层不能正确拿到err_no和err_tips的问题
 */
NSString * const kTTNetworkErrorResponseErrorCodeKey = @"server_error_code"; //兼容旧版本的key，原来该值key为server_error_code，为空则不是业务错误
NSString * const kTTNetworkErrorResponseErrorTipsKey = @"description"; //兼容旧版本的key，原来该值key为description，可能为空
NSString * const kTTNetworkErrorOldResponseErrorCodeKey = @"server_old_error_code";

/**
 *  新版本api通过error code确认是否成功
 */
NSString * const SSRemoteResponseErrorCodeKey = @"err_no";

NSString * const SSRemoteResponseErrorMessageKey = @"err_msg";

NSString * const SSRemoteResponseErrorTipsKey = @"err_tips";
NSString * const SSRemoteResponseErrorTipKey = @"err_tip";
NSString * const SSRemoteResponseErrorTipsTotalKey = @"error_tips";

/**
 *  就版本api通过message确认是否成功
 */
NSString * const SSRemoteResponseMessageKey = @"message";

/**
 *  error的userInfo中包含的http状态码所对应的key
 */
NSString * const SSResponeStatusCodeKey = @"status_code";

@implementation TTDefaultJSONResponseSerializer

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        self.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript", @"application/octet-stream", nil];
        
        NSMutableSet *acceptableContentTypes = [self.acceptableContentTypes mutableCopy];
        [acceptableContentTypes addObject:@"text/html"];
        [acceptableContentTypes addObject:@"text/plain"];
        self.acceptableContentTypes = acceptableContentTypes;
    }
    return self;
}

- (id)responseObjectForResponse:(TTHttpResponse *)response
                        jsonObj:(id)jsonObj
                  responseError:(NSError *)responseError
                    resultError:(NSError *__autoreleasing *)resultError
{
    if (responseError) {
        if (resultError) {
            *resultError = responseError;
            [self error:resultError addHTTPStatusCodeWithResponse:response];
        }
        return nil;
    }
    NSData *originData = nil;
    if ([jsonObj isKindOfClass:[NSData class]]) {
        
        originData = [jsonObj copy];
#warning todo 将SSHTTPProcesser 替换为 TTHTTPProcesser
        
        //文章下架在response header里 所以header先行处理
        SSHTTPResponseProtocolItem *item = [[SSHTTPResponseProtocolItem alloc] init];
        item.responseData = jsonObj;
        NSDictionary *allHeaderFields = nil;
        if ([response respondsToSelector:@selector(allHeaderFields)]) {
            allHeaderFields = [response allHeaderFields];
        }
        item.allHeaderFields = allHeaderFields;
        
        //传入SSHTTPProcesser做预处理
        int64_t total = 0;
        Class chromRespClass = NSClassFromString(@"TTHttpResponseChromium");
        if ([response isKindOfClass:chromRespClass]) {
            if ([response respondsToSelector:NSSelectorFromString(@"timingInfo")]) {
                id timingInfo = [response valueForKey:@"timingInfo"];
                if ([timingInfo respondsToSelector:NSSelectorFromString(@"wait")]) {
                    total += [[timingInfo valueForKey:@"wait"] longLongValue];
                }
                if ([timingInfo respondsToSelector:NSSelectorFromString(@"receive")]) {
                    total += [[timingInfo valueForKey:@"receive"] longLongValue];
                }
            }
        }
        [[SSHTTPProcesser sharedProcesser] preprocessHTTPResponse:item requestTotalTimeInterval:total requestURL:response.URL];
        
        //将处理后的rawData 给jsonObj
        jsonObj = item.responseData;
        
        //stream里 对data有混淆 所以上面一步先位运算处理一下 下面再解析
        jsonObj = [super responseObjectForResponse:response jsonObj:jsonObj responseError:responseError resultError:resultError];
    }
    
    NSError *parseError = nil;
    
    if (![jsonObj isKindOfClass:[NSDictionary class]]) {
        if (resultError) {
            // NSDictionary * userInfo = @{ @"TTNetworkErrorOriginalDataKey" : jsonObj };
            // jsonObj可能为空，setValue加保护
            NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
            if (jsonObj) {
                [userInfo setValue:jsonObj forKey:@"TTNetworkErrorOriginalDataKey"];
            } else {
                if (originData) {
                    NSString *dataStr = [[NSString alloc] initWithData:originData encoding:NSUTF8StringEncoding];
                    [userInfo setValue:dataStr forKey:@"TTNetworkErrorOriginalDataKey"];
                } else {
                    [userInfo setValue:@"data is null" forKey:@"TTNetworkErrorOriginalDataKey"];
                }
            }
            [userInfo setValue:@(response.statusCode) forKey:@"response_code"];
            
            *resultError =[NSError errorWithDomain:kTTNetworkErrorDomain code:kTTNetworkManagerJsonResultNotDictionaryErrorCode userInfo:userInfo];
            [self error:resultError addHTTPStatusCodeWithResponse:response];
            LOGD(@"url: %@ return failed http result error: %@, json obj: %@", response.URL.absoluteString, parseError, jsonObj);
        }
        return jsonObj;
    }
    
    //先判断是否包含errorCode，来确认是否是新版本, 如果是，按照新版本逻辑处理
    if ([[jsonObj allKeys] containsObject:SSRemoteResponseErrorCodeKey]) {
        
        NSNumber *errorCode = jsonObj[SSRemoteResponseErrorCodeKey];
        
        NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithCapacity:2];
        [userInfo setValue:jsonObj[SSRemoteResponseErrorMessageKey] forKey:@"message"];
        if ([[jsonObj allKeys] containsObject:SSRemoteResponseErrorTipKey]) {
            [userInfo setValue:jsonObj[SSRemoteResponseErrorTipKey] forKey:kTTNetworkErrorResponseErrorTipsKey];
        }
        else if ([[jsonObj allKeys] containsObject:SSRemoteResponseErrorTipsKey]) {
            [userInfo setValue:jsonObj[SSRemoteResponseErrorTipsKey] forKey:kTTNetworkErrorResponseErrorTipsKey];
        }
        
        if (errorCode && ![errorCode isEqualToNumber:@0]) {
            [userInfo setValue:errorCode forKey:kTTNetworkErrorResponseErrorCodeKey];//由于业务导致的错误
            parseError = [NSError errorWithDomain:kTTNetworkErrorDomain code:errorCode.integerValue userInfo:userInfo];
            LOGD(@"url: %@ return failed http result error: %@, json obj: %@", response.URL.absoluteString, parseError, jsonObj);
        }
        
    }
    //按照旧版本api，判断message是否是包含， 如果包含， 按照旧版本api处理
    else if ([[jsonObj allKeys] containsObject:SSRemoteResponseMessageKey]) {
        NSString * str = jsonObj[SSRemoteResponseMessageKey];
        NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithCapacity:2];
        if ([[jsonObj allKeys] containsObject:SSRemoteResponseErrorTipKey]) {
            [userInfo setValue:jsonObj[SSRemoteResponseErrorTipKey] forKey:@"description"];
        }
        else if ([[jsonObj allKeys] containsObject:SSRemoteResponseErrorTipsKey]) {
            [userInfo setValue:jsonObj[SSRemoteResponseErrorTipsKey] forKey:@"description"];
        }
        else if ([[jsonObj allKeys] containsObject:SSRemoteResponseErrorTipsTotalKey]) {
            [userInfo setValue:jsonObj[SSRemoteResponseErrorTipsTotalKey] forKey:@"description"];
        }
        if ([jsonObj[@"data"] isKindOfClass:[NSDictionary class]]) {
            [userInfo addEntriesFromDictionary:[jsonObj valueForKey:@"data"]];
        }
        
        
        if (isEmptyString(str) || ![str isEqualToString:@"success"]) {
            
            if (str) {
                [userInfo setValue:str forKey:kTTNetworkErrorOldResponseErrorCodeKey];
            }
            else {
                [userInfo setValue:kTTNetworkErrorOldResponseErrorCodeKey forKey:kTTNetworkErrorOldResponseErrorCodeKey];
            }
            
            parseError = [NSError errorWithDomain:kTTNetworkErrorDomain code:kTTNetworkManagerOldJSONResultErrorErrorCode userInfo:userInfo];
            LOGD(@"url: %@ return failed http result error: %@, json obj: %@", response.URL.absoluteString, parseError, jsonObj);
        }
    }
    else {
        
        //parseError = [NSError errorWithDomain:kTTNetworkErrorDomain code:kTTNetworkManagerJSONResultFormatErrorErrorCode userInfo:nil];
        //UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"JSON 数据不符合头条API的错误规则" message:[NSString stringWithFormat:@"%@",response.URL] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        //[alert show];
        NSLog(@"=======JSON 数据不符合头条API的错误规则======");
    }
    
    // 将SSCommonLogic中特殊处理的代码搬过来了
    if ([jsonObj isKindOfClass:[NSDictionary class]]) {
        NSString *status = [[jsonObj tt_dictionaryValueForKey:@"result"] tt_stringValueForKey:@"message"];
        NSString *errorMessage = nil;
        NSInteger errorCode = 0;
        
        // parse specific error
        if (!isEmptyString(status) && [status isEqualToString:@"error"]) {
            NSDictionary *dataDict = [jsonObj objectForKey:@"data"];
            
            if ([dataDict isKindOfClass:[NSDictionary class]] &&
                [dataDict.allKeys containsObject:@"name"]) {
                NSString *expNameString = [dataDict objectForKey:@"name"];
                
                if ([expNameString isEqualToString:@"auth_failed"]) {
                    errorCode = kAuthenticationFailCode;
                    errorMessage = kUserAuthErrorTipMessage;
                } else if ([expNameString isEqualToString:@"session_expired"]) {
                    errorCode = kSessionExpiredErrorCode;
                    errorMessage = kSessionExpiredTipMessage;
                } else if ([expNameString isEqualToString:@"name_existed"]) {
                    errorCode = kChangeNameExistsErrorCode;
                } else if ([expNameString isEqualToString:@"user_not_exist"]) {
                    errorCode = kUserNotExistErrorCode;
                    errorMessage = kUserNotExistTipMessage;
                } else if ([expNameString isEqualToString:@"antispam_error"]) {
                    errorCode = kUGCAntispamErrorCode;
                    if ([dataDict.allKeys containsObject:@"description"]) {
                        errorMessage = [dataDict objectForKey:@"description"];
                    } else {
                        errorMessage = kUGCAntispamTipMessage;
                    }
                } else if ([expNameString isEqualToString:@"ugc_post_too_fast"]) {
                    errorCode = kUGCUserPostTooFastErrorCode;
                    if ([dataDict.allKeys containsObject:@"description"]) {
                        errorMessage = [dataDict objectForKey:@"description"];
                    } else {
                        errorMessage = kUGCUserPostTooFastTipMessage;
                    }
                } else if ([expNameString isEqualToString:@"connect_switch"]) {
                    errorCode = kAccountBoundForbidCode;
                    errorMessage = kAccountBountForbidMessage;
                } else {
                    errorCode = kUndefinedErrorCode;
                    errorMessage = [dataDict objectForKey:@"description"];
                    if (isEmptyString(errorMessage)) errorMessage = @"";
                }
                
                //如果错误里包含description 那没用他来做 errorMsg -- 5.3 nick
                if (dataDict[@"description"]) {
                    errorMessage = dataDict[@"description"];
                }
            } else if ([dataDict isKindOfClass:[NSDictionary class]] &&
                       [dataDict.allKeys containsObject:@"error_code"]) {
                NSInteger parsedErrCode = [[dataDict valueForKey:@"error_code"] integerValue];
                switch (parsedErrCode) {
                    case 1101: {
                        errorCode = kPRNeedCaptchaCode;
                    }
                        break;
                    case 1102: {
                        errorCode = kPRWrongCaptchaErrorCode;
                    }
                        break;
                    case 1103: {
                        errorCode = kPRExpiredCaptchaErrorCode;
                    }
                        break;
                    case 1001: {
                        errorCode = kPRHasRegisteredErrorCode;
                    }
                        break;
                    case 1002: {
                        errorCode = kPRPhoneNumberEmptyErrorCode;
                    }
                        break;
                    default: {
                        errorCode = kPROtherErrorCode;
                    }
                        break;
                }
                
                errorMessage = [dataDict objectForKey:@"description"];
                if (isEmptyString(errorMessage)) errorMessage = @"";
            } else {
                errorCode = kUndefinedErrorCode;
                errorMessage = [dataDict valueForKey:@"description"];
                if (isEmptyString(errorMessage)) errorMessage = @"";
            }
            
            // 新的监控在此处上报，与老的监控在SSCommonLogic形成对比，以找出问题
            if ([[(NSDictionary *)jsonObj allKeys] containsObject:@"expired_platform"]) {
                NSString *joinedPlatformString = [jsonObj objectForKey:@"expired_platform"];
                NSArray  *platforms = [joinedPlatformString componentsSeparatedByString:@","];
                NSString *userIdString = [[TTAccountManager userID] copy];
                
                if ([TTAccountTestSettings httpResponseSerializerHandleAccountMsgEnabled]) {
                    [[TTPlatformAccountManager sharedManager] cleanExpiredPlatformAccountsByNames:platforms];
                    
                    // 老的监控
                    // [[TTMonitor shareManager] trackService:@"account_coerced_logout" status:3 extra:jsonObj];移到TTAccountLoggerImp:accountPlatformExpired:withPlatform:中
                    
                    NSMutableDictionary *errorUserInfo = parseError.userInfo ? [parseError.userInfo mutableCopy] :[NSMutableDictionary dictionaryWithCapacity:5];
                    [errorUserInfo setValue:platforms forKey:kExpiredPlatformKey];
                    [errorUserInfo setValue:joinedPlatformString forKey:TTAccountAuthPlatformNameKey];
                    [errorUserInfo setValue:userIdString forKey:@"user_id"];
                    [errorUserInfo setValue:parseError.description forKey:@"error_description"];
                    [errorUserInfo setValue:@(TTAccountErrCodePlatformExpired) forKey:TTAccountStatusCodeKey];
                    NSError *platformExpirationError = [NSError errorWithDomain:(parseError.domain ? : TTAccountErrorDomain) code:parseError.code userInfo:errorUserInfo];
                    
                    // 发送平台过期消息
                    [TTAccountMulticastDispatcher dispatchAccountExpireAuthPlatform:joinedPlatformString error:platformExpirationError bisectBlock:nil];
                }
                
                // 新的监控
                [TTAccountMonitorDispatcher dispatchHttpResp:jsonObj error:parseError originalURL:response.URL.absoluteString];
                
                [TTAccountMonitorDispatcher dispatchPlatformExpirationWithUser:userIdString platform:joinedPlatformString error:parseError originalURL:response.URL.absoluteString];
            }
            
            // if has platform expired, session_expired should be ignored ???
            if (errorCode == kSessionExpiredErrorCode) {
                BOOL loggedOnCurrently = [TTAccountManager isLogin];
                NSString *userIdString = [[TTAccountManager userID] copy];
                
                NSMutableDictionary *errorUserInfo = parseError.userInfo ? [parseError.userInfo mutableCopy] :[NSMutableDictionary dictionaryWithCapacity:5];
                [errorUserInfo setValue:userIdString forKey:@"user_id"];
                [errorUserInfo setValue:@(loggedOnCurrently) forKey:@"is_login"];
                [errorUserInfo setValue:response.URL.absoluteString forKey:@"request_url"];
                [errorUserInfo setValue:jsonObj forKey:@"response"];
                [errorUserInfo setValue:parseError.description forKey:@"error_description"];
                [errorUserInfo setValue:@(parseError.code != 0 ? parseError.code : errorCode) forKey:@"error_code"];
                
                if ([TTAccountTestSettings httpResponseSerializerHandleAccountMsgEnabled]) {
                    // 老的监控
                    [[TTMonitor shareManager] trackService:@"account_forced_logout" status:1 extra:errorUserInfo];
                    
                    [errorUserInfo setValue:@(TTAccountErrCodeSessionExpired) forKey:TTAccountStatusCodeKey];
                    NSError *sessionExpirationError = [NSError errorWithDomain:(parseError.domain ? : TTAccountErrorDomain) code:errorCode userInfo:errorUserInfo];
                    // 发送会话过期消息
                    [TTAccountMulticastDispatcher dispatchAccountSessionExpirationWithUser:userIdString error:sessionExpirationError bisectBlock:nil];
                    
                    // 目前会话过期会自动清理用户信息
                    [TTAccountManager setIsLogin:NO];
                }
                
                // 新的监控
                [TTAccountMonitorDispatcher dispatchHttpResp:jsonObj error:parseError originalURL:response.URL.absoluteString];
                
                [TTAccountMonitorDispatcher dispatchSessionExpirationWithUser:userIdString error:parseError originalURL:response.URL.absoluteString];
            }
        }
    }
    
    if (parseError) {
        if (resultError) {
            *resultError = parseError;
            [self error:resultError addHTTPStatusCodeWithResponse:response];
        }
        return jsonObj;
    }
    
    return jsonObj;
}

- (void)error:(NSError *__autoreleasing *)error addHTTPStatusCodeWithResponse:(TTHttpResponse *)response {
    if (error == nil || *error == nil || ![response isKindOfClass:[TTHttpResponse class]]) {
        return;
    }
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithCapacity:5];
    if ((*error).userInfo.count > 0) {
        [userInfo addEntriesFromDictionary:(*error).userInfo];
    }
    [userInfo setValue:@(response.statusCode) forKey:SSResponeStatusCodeKey];
    *error = [NSError errorWithDomain:(*error).domain code:(*error).code userInfo:userInfo];
}

+ (NSObject<TTJSONResponseSerializerProtocol> *)serializer
{
    return [[[self class] alloc] init];
}


@end
