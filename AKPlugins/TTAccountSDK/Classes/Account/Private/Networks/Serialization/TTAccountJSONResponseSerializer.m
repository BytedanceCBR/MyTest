//
//  TTAccountJSONResponseSerializer.m
//  TTAccountSDK
//
//  Created by liuzuopeng on 12/5/16.
//  Copyright © 2016 Toutiao. All rights reserved.
//

#import "TTAccountJSONResponseSerializer.h"
#import "TTAccount.h"
#import "TTAccountMulticastDispatcher.h"
#import "TTAccountLogDispatcher.h"
#import "TTAccountMonitorDispatcher.h"



@implementation TTAccountJSONResponseSerializer

- (instancetype)init
{
    if ((self = [super init])) {
        self.acceptableContentTypes = [NSSet setWithObjects:
                                       @"application/json",
                                       @"text/json",
                                       @"text/javascript",
                                       @"application/octet-stream",
                                       @"text/html",
                                       @"text/plain",
                                       nil];
    }
    return self;
}

- (id)responseObjectForResponse:(TTHttpResponse *)response
                        jsonObj:(id)jsonObj
                  responseError:(NSError *)responseError
                    resultError:(NSError *__autoreleasing *)resultError
{
    if (responseError) {
        [self.class normalizeError:&responseError withResponseResult:jsonObj];
        if (resultError) {
            *resultError = responseError;
            [self.class error:resultError addHTTPStatusCodeWithResponse:response];
        }
        return nil;
    }
    
    if ([jsonObj isKindOfClass:[NSData class]]) {
        // stream里 对data有混淆 所以上面一步先位运算处理一下，下面再解析
        jsonObj = [super responseObjectForResponse:response
                                           jsonObj:jsonObj
                                     responseError:responseError
                                       resultError:resultError];
    }
    
    NSError *parseError = nil;
    [self.class handleResponseResult:jsonObj responseError:responseError resultError:&parseError originalURL:response.URL];
    
    if (parseError) {
        if (resultError) {
            *resultError = parseError;
            [self.class error:resultError addHTTPStatusCodeWithResponse:response];
        }
    }
    
    return jsonObj;
}

+ (void)error:(NSError *__autoreleasing *)error addHTTPStatusCodeWithResponse:(TTHttpResponse *)response
{
    if (error == nil || *error == nil || ![response isKindOfClass:[NSHTTPURLResponse class]]) {
        return;
    }
    
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithCapacity:5];
    if ((*error).userInfo.count > 0) {
        [userInfo addEntriesFromDictionary:(*error).userInfo];
    }
    
    /**
     *  error的userInfo中添加http响应状态码
     */
    [userInfo setValue:@(response.statusCode) forKey:@"status_code"];
    *error = [NSError errorWithDomain:(*error).domain code:(*error).code userInfo:userInfo];
}

+ (void)handleResponseResult:(id)responseObject
               responseError:(NSError *)responseError
                 resultError:(NSError *__autoreleasing *)resultError
                 originalURL:(NSURL *)reqURL
{
    // response is nil or responseError exists
    if (!responseObject || responseError) {
        [self.class normalizeError:&responseError withResponseResult:responseObject];
        if (resultError) {
            *resultError = responseError;
        }
        return;
    }
    
    // 序列化
    if ([responseObject isKindOfClass:[NSData class]]) {
        NSError *serializationError = nil;
        NSDictionary *convertDictionary =
        [[self class] dictionaryWithJSONData:responseObject
                                 resultError:&serializationError];
        if (!serializationError && convertDictionary) {
            responseObject = convertDictionary;
        }
        
        if (serializationError) {
            [self.class normalizeError:&responseError withResponseResult:responseObject];
            if (resultError) {
                *resultError = serializationError;
            }
            return;
        }
    }
    
    // 数据格式校验是否符合服务端返回要求
    NSError *validationError = nil;
    [self.class validateResponseResult:responseObject
                           resultError:&validationError];
    if (validationError || !responseObject) {
        [self.class normalizeError:&validationError withResponseResult:responseObject];
        if (resultError) {
            *resultError = validationError;
        }
        return;
    }
    
    // 解析数据
    NSError *parseError = nil;
    [self.class normalParseResponseResult:responseObject
                              resultError:&parseError
                            exceptionInfo:nil
                         exceptionAsError:YES
                              originalURL:reqURL];
    
    [self.class normalizeError:&parseError withResponseResult:responseObject];
    if (resultError) {
        *resultError = parseError;
    }
}

+ (void)normalParseResponseResult:(NSDictionary *)result resultError:(NSError **)resultError exceptionInfo:(NSDictionary **)exceptionInfo exceptionAsError:(BOOL)trictMode originalURL:(NSURL *)reqURL
{
    NSString *errorMessage = nil;
    NSDictionary *userInfo = nil;
    TTAccountErrCode errcode = TTAccountErrCodeUnknown;
    
    /**
     *  新版本API通过error code确认是否成功
     */
    if ([[result allKeys] containsObject:@"err_no"]) {
        NSNumber *errcodeNumber = result[@"err_no"];
        
        userInfo = [NSMutableDictionary dictionaryWithCapacity:2];
        [userInfo setValue:result[@"err_msg"] forKey:@"message"];
        
        if ([[result allKeys] containsObject:@"err_tip"]) {
            [userInfo setValue:result[@"err_tip"] forKey:@"description"];
        } else if ([[result allKeys] containsObject:@"err_tips"]) {
            [userInfo setValue:result[@"err_tips"] forKey:@"description"];
        }
        
        errcode = [errcodeNumber integerValue];
    }
    
    if ([[result allKeys] containsObject:@"message"]) {
        /**
         *  旧版本API通过message确认是否成功
         */
        NSString *statusString = [result objectForKey:@"message"];
        if ([statusString isEqualToString:@"success"]) {
            errcode = TTAccountSuccess;
        } else if([statusString isEqualToString:@"exception"]) {
            errcode = TTAccountErrCodeServerException;
        } else if ([statusString isEqualToString:@"error"]) { // specail error
            NSDictionary *data = [result objectForKey:@"data"];
            if ([data isKindOfClass:[NSDictionary class]]) {
                
                if (!userInfo) {
                    userInfo = [[NSMutableDictionary alloc] initWithDictionary:data];
                }
                
                if ([[data allKeys] containsObject:@"name"]) {
                    NSString *errnameString = [data objectForKey:@"name"];
                    
                    if ([errnameString isEqualToString:@"auth_failed"]) {
                        errcode = TTAccountErrCodeAuthorizationFailed;
                    } else if ([errnameString isEqualToString:@"session_expired"]) {
                        errcode = TTAccountErrCodeSessionExpired;
                    }  else if ([errnameString isEqualToString:@"name_existed"]) {
                        errcode = TTAccountErrCodeNameExisted;
                    } else if ([errnameString isEqualToString:@"user_not_exist"]) {
                        errcode = TTAccountErrCodeUserNotExisted;
                    } else if ([errnameString isEqualToString:@"connect_switch"]) {
                        errcode = TTAccountErrCodeAccountBoundForbid;
                    } else if ([errnameString isEqualToString:@"connect_exist"]) {
                        errcode = TTAccountErrCodeAuthPlatformBoundForbid;
                    } else {
                        errcode = TTAccountErrCodeUnknown;
                    }
                } else if ([[data allKeys] containsObject:@"error_code"]) {
                    NSNumber *errcodeNumber = [data objectForKey:@"error_code"];
                    errcode = [errcodeNumber integerValue];
                }
                
                if ([[data allKeys] containsObject:@"auth_token"]) {
                    NSString *authToken = [data objectForKey:@"auth_token"];
                    [userInfo setValue:authToken forKey:@"auth_token"];
                }
                
                if ([[data allKeys] containsObject:@"error_description"]) {
                    NSString *despString = [data objectForKey:@"error_description"];
                    [userInfo setValue:despString forKey:@"error_description"];
                }
                
                if ([[data allKeys] containsObject:@"dialog_tips"]) {
                    NSString *tipsString = [data objectForKey:@"dialog_tips"];
                    [userInfo setValue:tipsString forKey:@"dialog_tips"];
                }
                
                if ([[data allKeys] containsObject:@"description"]) {
                    errorMessage = [data objectForKey:@"description"];
                    if (![[userInfo allKeys] containsObject:@"error_description"]) {
                        [userInfo setValue:errorMessage forKey:@"error_description"];
                    }
                }
            }
        } else {
            errcode = TTAccountErrCodeUnknown;
        }
    } else if ([result count] > 0) {
        errcode = TTAccountErrCodeServerDataFormatInvalid;
    }
    
    
    // it's not an error, if care about this, register kPlatformExpiredNotification
    if([[result allKeys] containsObject:@"expired_platform"]) {
        NSString *platformString = [result objectForKey:@"expired_platform"];
        NSArray  *platforms __unused = [platformString componentsSeparatedByString:@","];
        
        errcode = TTAccountErrCodePlatformExpired;
    }
    
    
    if (TTAccountSuccess != errcode) {
        NSError *outError = nil;
        if (trictMode || (!trictMode && errcode != TTAccountErrCodeServerException)) {
            if (!errorMessage) errorMessage = TTAccountGetErrorCodeDescription(errcode);
            NSMutableDictionary *fullUserInfo = [NSMutableDictionary dictionary];
            [fullUserInfo setValue:errorMessage forKey:TTAccountErrMsgKey];
            [fullUserInfo setValue:errorMessage forKey:NSLocalizedDescriptionKey];
            [fullUserInfo setValue:errorMessage forKey:@"message"];
            if (userInfo && [userInfo isKindOfClass:[NSDictionary class]]) {
                [fullUserInfo addEntriesFromDictionary:userInfo];
            }
            outError = [NSError errorWithDomain:TTAccountErrorDomain
                                           code:errcode
                                       userInfo:fullUserInfo];
        }
        if (resultError) {
            *resultError = outError;
        }
        
        // 处理特殊的错误消息
        [self.class specialHandleResponseResult:result withError:outError originalURL:reqURL];
        
    } else {
        
    }
}

+ (void)validateResponseResult:(id)responseObject resultError:(NSError *__autoreleasing *)resultError
{
    if (!responseObject) {
        return;
    }
    
    if (![responseObject isKindOfClass:[NSDictionary class]]) {
        TTAccountErrCode errcode = TTAccountErrCodeServerDataFormatInvalid;
        NSError *outError =
        [NSError errorWithDomain:TTAccountErrorDomain
                            code:errcode
                        userInfo:@{
                                   TTAccountStatusCodeKey: @(errcode),
                                   TTAccountErrMsgKey: TTAccountGetErrorCodeDescription(errcode) ? : @""
                                   }];
        if (resultError) {
            *resultError = outError;
        }
        return;
    }
    
    NSNumber *errcodeNumber= [(NSDictionary *)responseObject objectForKey:@"err_no"];
    NSString *statusString = [(NSDictionary *)responseObject objectForKey:@"message"];
    if (TTAccountIsEmptyString(statusString) && !errcodeNumber) {
        TTAccountErrCode errcode = TTAccountErrCodeServerDataFormatInvalid;
        NSError *outError =
        [NSError errorWithDomain:TTAccountErrorDomain
                            code:errcode
                        userInfo:@{
                                   TTAccountStatusCodeKey: @(errcode),
                                   TTAccountErrMsgKey: TTAccountGetErrorCodeDescription(errcode) ? : @""
                                   }];
        if (resultError) {
            *resultError = outError;
        }
    }
}

+ (id)dictionaryWithJSONData:(NSData *)inData resultError:(NSError *__autoreleasing *)resultError
{
    if (inData) {
        NSError *serializationError = nil;
        id serializationObject = [NSJSONSerialization JSONObjectWithData:inData options:NSJSONReadingAllowFragments error:&serializationError];
        if (resultError) {
            *resultError = serializationError;
        }
        return serializationObject;
    }
    return nil;
}

+ (void)normalizeError:(NSError *__autoreleasing *)resultError withResponseResult:(id)responseResult
{
    if (!resultError || !(*resultError) || !responseResult) {
        return;
    }
    
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithCapacity:5];
    [userInfo setValue:responseResult forKey:@"original_response_object"];
    if ((*resultError).userInfo.count > 0) {
        [userInfo addEntriesFromDictionary:(*resultError).userInfo];
    }
    *resultError = [NSError errorWithDomain:(*resultError).domain
                                       code:(*resultError).code
                                   userInfo:userInfo];
}

+ (void)specialHandleResponseResult:(NSDictionary *)respResult withError:(NSError *)error originalURL:(NSURL *)reqURL
{
    if (TTAccountSuccess != error.code) {
        if (TTAccountErrCodeSessionExpired == error.code) {
            
            BOOL isLoggedOn = [[TTAccount sharedAccount] isLogin];
            NSString *currUserIdString = [[[TTAccount sharedAccount] userIdString] copy];
            
            // 目前会话过期会自动清理用户信息
            [[TTAccount sharedAccount] setIsLogin:NO];
            
            // construct new error
            NSMutableDictionary *userInfoInNewError = [[NSMutableDictionary alloc] initWithDictionary:error.userInfo];
            [userInfoInNewError setValue:currUserIdString forKey:@"user_id"];
            [userInfoInNewError setValue:@(isLoggedOn) forKey:@"is_login"];
            [userInfoInNewError setValue:reqURL.absoluteString forKey:@"request_url"];
            [userInfoInNewError setValue:reqURL.path forKey:@"request_url_path"];
            [userInfoInNewError setValue:respResult forKey:@"response"];
            NSError *newError = [NSError errorWithDomain:error.domain code:error.code userInfo:userInfoInNewError];
            
            // multicast
            [TTAccountMulticastDispatcher dispatchAccountSessionExpirationWithUser:currUserIdString error:newError bisectBlock:nil];
            
            // Monitor
            [TTAccountMonitorDispatcher dispatchSessionExpirationWithUser:currUserIdString error:newError originalURL:reqURL.absoluteString];
            
        } else if (TTAccountErrCodePlatformExpired == error.code) {
            
            BOOL isLoggedOn = [[TTAccount sharedAccount] isLogin];
            NSString *currUserIdString = [[[TTAccount sharedAccount] userIdString] copy];
            NSString *platformString = [respResult objectForKey:@"expired_platform"];
            
            // construct new error
            NSMutableDictionary *userInfoInNewError = [[NSMutableDictionary alloc] initWithDictionary:error.userInfo];
            [userInfoInNewError setValue:currUserIdString forKey:@"user_id"];
            [userInfoInNewError setValue:@(isLoggedOn) forKey:@"is_login"];
            [userInfoInNewError setValue:reqURL.absoluteString forKey:@"request_url"];
            [userInfoInNewError setValue:reqURL.path forKey:@"request_url_path"];
            [userInfoInNewError setValue:respResult forKey:@"response"];
            [userInfoInNewError setValue:platformString forKey:@"platforms"];
            NSError *newError = [NSError errorWithDomain:error.domain code:error.code userInfo:userInfoInNewError];
            
            // multicast
            [TTAccountMulticastDispatcher dispatchAccountExpireAuthPlatform:platformString error:newError bisectBlock:nil];
            
            // Monitor
            [TTAccountMonitorDispatcher dispatchPlatformExpirationWithUser:currUserIdString platform:platformString error:newError originalURL:reqURL.absoluteString];
        }
    }
}

+ (NSObject<TTJSONResponseSerializerProtocol> *)serializer
{
    return [[[self class] alloc] init];
}

@end
