//
//  TTAccountNetworkManager.m
//  TTAccountSDK
//
//  Created by liuzuopeng on 4/26/17.
//  Copyright © 2017 com.bytedance.news. All rights reserved.
//

#import "TTAccountNetworkManager.h"
#import "TTAccountNetworkSerializer.h"
#import "TTAccountSessionTask.h"
#import "TTAccountDefine.h"
#import "TTAccountBaseModel.h"
#import "TTAccount.h"
#import "TTAccountConfiguration_Priv.h"
#import "NSString+TTAccountUtils.h"
#import "TTAccountMonitorDispatcher.h"



@implementation TTAccountNetworkManager

#pragma mark - private

+ (id<TTAccountSessionTask>)requestForJSONWithURL:(NSString *)URLString
                                           method:(NSString *)method
                                           params:(NSDictionary * _Nullable)params
                                   extraGetParams:(NSDictionary * _Nullable)extraGetParams
                                 needCommonParams:(BOOL)needCommonParams
                                follow302Redirect:(BOOL)follow302Redirect /** 当返回302时，是否跟进302重定向地址 */
                                     needDispatch:(BOOL)dispatchNote /** 是否dispatch会话过期或平台过期消息 */
                                         callback:(TTNetworkJSONFinishBlockWithResponse)callback
{
    NSMutableDictionary *appRequiredParams = [[[TTAccount accountConf] tta_appRequiredParameters] mutableCopy];
    if ([appRequiredParams count] > 0) {
        if ([extraGetParams isKindOfClass:[NSDictionary class]]) {
            [appRequiredParams addEntriesFromDictionary:extraGetParams];
        }
        extraGetParams = [appRequiredParams copy];
    }
    
    if (needCommonParams || [extraGetParams count] > 0 || [params count] > 0) {
        
        NSMutableDictionary *mutParamsDict = [NSMutableDictionary dictionary];
        
        if (needCommonParams) {
            NSDictionary *commonParams = [[TTAccount accountConf] tta_commonNetworkParameters];
            if (commonParams && [commonParams count] > 0) {
                [mutParamsDict addEntriesFromDictionary:commonParams];
            }
        }
        
        if (params && [params isKindOfClass:[NSDictionary class]] && [[method uppercaseString] isEqualToString:@"GET"]) {
            [mutParamsDict addEntriesFromDictionary:(NSDictionary *)params];
        }
        
        if ([extraGetParams count] > 0) {
            [mutParamsDict addEntriesFromDictionary:extraGetParams];
        }
        
        NSString *tmpUrlString = [URLString tta_URLStringByAppendQueryItems:mutParamsDict];
        URLString = tmpUrlString ? : URLString;
    }
    
    TTHttpTask *task =
    [[TTNetworkManager shareInstance] requestForJSONWithResponse:URLString
                                                          params:params
                                                          method:method
                                                needCommonParams:YES
                                               requestSerializer:follow302Redirect ? [TTAccountHTTPRequestSerializer class] : [TTAccountHTTPNoRedirectRequestSerializer class]
                                              responseSerializer:dispatchNote ? [TTAccountJSONResponseSerializer class] : [TTAccountNoDispatchJSONResponseSerializer class]
                                                      autoResume:YES
                                                        callback:^(NSError *error, id jsonObj, TTHttpResponse *response) {
                                                            if (callback) {
                                                                callback(error, jsonObj, response);
                                                            }
                                                            
                                                            [TTAccountMonitorDispatcher dispatchHttpResp:jsonObj error:error originalURL:URLString];
                                                        }];
    return [[TTAccountSessionTask alloc] initWithSessionTask:task];
}

#pragma mark - public

+ (id<TTAccountSessionTask>)requestForJSONWithURL:(NSString *)URLString
                                           params:(NSDictionary *)params
                                   extraGetParams:(NSDictionary *)extraGetParams
                                           method:(NSString *)method
                                 needCommonParams:(BOOL)needCommonParams
                                         callback:(TTNetworkJSONFinishBlock)callback
{
    return [self.class requestForJSONWithURL:URLString
                                      method:method
                                      params:params
                              extraGetParams:extraGetParams
                            needCommonParams:needCommonParams
                           follow302Redirect:YES
                                needDispatch:YES
                                    callback:^(NSError *error, id obj, TTHttpResponse *response) {
                                        !callback ? : callback(error, obj);
                                    }];
}

+ (id<TTAccountSessionTask>)requestForJSONWithURL:(NSString *)URLString
                                           method:(NSString *)method
                                           params:(NSDictionary * _Nullable)params
                                   extraGetParams:(NSDictionary * _Nullable)extraGetParams
                                 needCommonParams:(BOOL)needCommonParams
                                follow302Redirect:(BOOL)follow302Redirect /** 当返回302时，是否跟进302重定向地址 */
                                         callback:(TTNetworkJSONFinishBlockWithResponse)callback
{
    return [self.class requestForJSONWithURL:URLString
                                      method:method
                                      params:params
                              extraGetParams:extraGetParams
                            needCommonParams:needCommonParams
                           follow302Redirect:follow302Redirect
                                needDispatch:YES
                                    callback:callback];
}

+ (id<TTAccountSessionTask>)requestNoDispatchForJSONWithURL:(NSString *)URLString
                                                     method:(NSString *)method
                                                     params:(NSDictionary *)params
                                             extraGetParams:(NSDictionary *)extraGetParams
                                           needCommonParams:(BOOL)needCommonParams
                                                   callback:(TTNetworkJSONFinishBlock)callback
{
    return [self.class requestForJSONWithURL:URLString
                                      method:method
                                      params:params
                              extraGetParams:extraGetParams
                            needCommonParams:needCommonParams
                           follow302Redirect:YES
                                needDispatch:NO
                                    callback:^(NSError *error, id obj, TTHttpResponse *response) {
                                        !callback ? : callback(error, obj);
                                    }];
}

+ (id<TTAccountSessionTask>)requestForJSONWithURL:(NSString *)URLString
                                           params:(NSDictionary *)params
                                           method:(NSString *)method
                                 needCommonParams:(BOOL)commonParams
                                         callback:(TTNetworkJSONFinishBlock)callback
{
    return [self requestForJSONWithURL:URLString
                                params:params
                        extraGetParams:nil
                                method:method
                      needCommonParams:commonParams
                              callback:callback];
}

+ (id<TTAccountSessionTask>)postRequestForJSONWithURL:(NSString *)URLString
                                               params:(NSDictionary *)params
                                     needCommonParams:(BOOL)commonParams
                                             callback:(TTNetworkJSONFinishBlock)callback
{
    return [self requestForJSONWithURL:URLString
                                params:params
                                method:@"POST"
                      needCommonParams:commonParams
                              callback:callback];
}

+ (id<TTAccountSessionTask>)postRequestForJSONWithURL:(NSString *)URLString
                                               params:(NSDictionary *)params
                                       extraGetParams:(NSDictionary *)extraGetParams
                                     needCommonParams:(BOOL)commonParams
                                             callback:(TTNetworkJSONFinishBlock)callback
{
    return [self requestForJSONWithURL:URLString
                                params:params
                        extraGetParams:extraGetParams
                                method:@"POST"
                      needCommonParams:commonParams
                              callback:callback];
}

+ (id<TTAccountSessionTask>)getRequestForJSONWithURL:(NSString *)URLString
                                              params:(NSDictionary *)params
                                    needCommonParams:(BOOL)commonParams
                                            callback:(TTNetworkJSONFinishBlock)callback
{
    return [self requestForJSONWithURL:URLString
                                params:params
                                method:@"GET"
                      needCommonParams:commonParams
                              callback:callback];
}

+ (id<TTAccountSessionTask>)getRequestForJSONWithURL:(NSString *)URLString
                                              params:(NSDictionary *)params
                                      extraGetParams:(NSDictionary *)extraGetParams
                                    needCommonParams:(BOOL)commonParams
                                            callback:(TTNetworkJSONFinishBlock)callback
{
    return [self requestForJSONWithURL:URLString
                                params:params
                        extraGetParams:extraGetParams
                                method:@"GET"
                      needCommonParams:commonParams
                              callback:callback];
}

+ (id<TTAccountSessionTask>)requestModel:(TTRequestModel *)model
                                callback:(TTNetworkResponseModelFinishBlock)callback
{
    NSMutableDictionary *mutParamsDict = [[[TTAccount accountConf] tta_commonNetworkParameters] mutableCopy];
    
    if ([model._additionGetParams isKindOfClass:[NSDictionary class]] && [model._additionGetParams count] > 0) {
        [mutParamsDict addEntriesFromDictionary:model._additionGetParams];
    }
    
    if ([mutParamsDict count] > 0) {
        model._additionGetParams = [mutParamsDict copy];
    }
    
    TTHttpTask *task =
    [[TTNetworkManager shareInstance] requestModel:model
                                 requestSerializer:[TTAccountHTTPRequestSerializer class]
                                responseSerializer:[TTAccountModelResponseSerializer class]
                                        autoResume:YES callback:^(NSError *error, NSObject<TTResponseModelProtocol> *responseModel) {
                                            
                                            if (responseModel && !error && [responseModel isKindOfClass:[TTABaseRespModel class]] && ![(TTABaseRespModel *)responseModel isRespSuccess]) {
                                                TTABaseRespModel *respModel = (TTABaseRespModel *)responseModel;
                                                NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithCapacity:2];
                                                [userInfo setValue:respModel.message forKey:@"message"];
                                                [userInfo setValue:respModel.errorDescription forKey:@"error_description"];
                                                [userInfo setValue:[respModel valueForKey:@"data"] forKey:@"data"];
                                                error = [NSError errorWithDomain:TTAccountErrorDomain code:respModel.errorCode userInfo:userInfo];
                                            }
                                            if (callback) {
                                                callback(error, responseModel);
                                            }
                                            
                                            NSDictionary *jsonObj = nil;
                                            if ([responseModel isKindOfClass:[TTABaseRespModel class]]) {
                                                jsonObj = [(TTABaseRespModel *)responseModel  toDictionary];
                                            }
                                            [TTAccountMonitorDispatcher dispatchHttpResp:jsonObj error:error originalURL:model._requestURL];
                                        }];
    return [[TTAccountSessionTask alloc] initWithSessionTask:task];
}

+ (id<TTAccountSessionTask>)uploadWithURL:(NSString *)URLString
                               parameters:(NSDictionary *)parameters
                constructingBodyWithBlock:(TTConstructingBodyBlock)bodyBlock
                                 progress:(NSProgress * __autoreleasing *)progress
                         needcommonParams:(BOOL)needCommonParams
                                 callback:(TTNetworkJSONFinishBlock)callback
{
    NSMutableDictionary *mutParamsDict = [[[TTAccount accountConf] tta_commonNetworkParameters] mutableCopy];
    
    if ([parameters isKindOfClass:[NSDictionary class]] && [parameters count] > 0) {
        [mutParamsDict addEntriesFromDictionary:parameters];
    }
    
    if ([mutParamsDict count] > 0) {
        parameters = [mutParamsDict copy];
    }
    
    TTHttpTask *task =
    [[TTNetworkManager shareInstance] uploadWithURL:URLString
                                         parameters:parameters
                                        headerField:nil
                          constructingBodyWithBlock:bodyBlock
                                           progress:progress
                                   needcommonParams:needCommonParams
                                  requestSerializer:[TTAccountHTTPRequestSerializer class]
                                 responseSerializer:[TTAccountJSONResponseSerializer class]
                                         autoResume:YES
                                           callback:^(NSError *error, id jsonObj) {
                                               if (callback)  {
                                                   callback(error, jsonObj);
                                               }
                                               
                                               [TTAccountMonitorDispatcher dispatchHttpResp:jsonObj error:error originalURL:URLString];
                                           }];
    return [[TTAccountSessionTask alloc] initWithSessionTask:task];
}

@end
