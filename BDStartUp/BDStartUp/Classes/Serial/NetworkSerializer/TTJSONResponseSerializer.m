//
//  TTJSONResponseSerializer.m
//  ss_app_ios_lib_network
//
//  Created by ZhangLeonardo on 15/9/7.
//  Copyright (c) 2015年 zhangchenlong. All rights reserved.
//

#import "TTJSONResponseSerializer.h"

//#if __has_include("TTNetworkManager.h")
//
//@implementation TTJSONResponseSerializer
//
//+ (NSObject<TTJSONResponseSerializerProtocol> *)serializer;
//{
//    return [[TTJSONResponseSerializer alloc] init];
//}
//
//- (instancetype)init
//{
//    self = [super init];
//    if (self) {
//        self.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript", @"application/octet-stream",@"text/html", nil];
//    }
//    return self;
//}
//
//- (id)responseObjectForResponse:(TTHttpResponse *)response
//                        jsonObj:(id)jsonObj
//                  responseError:(NSError *)responseError
//                    resultError:(NSError *__autoreleasing *)resultError
//{
//    NSAssert([response isKindOfClass:TTHttpResponse.class], @"!!!must TTHttpResponse!!!");
//    NSError * jsonParseError = nil;
//    id responseObject = [super responseObjectForResponse:response jsonObj:jsonObj responseError:responseError resultError:resultError];
//    if (resultError) {
//        *resultError = jsonParseError;
//    }
//
//    return responseObject;
//}
//
//
//@end
//
//
//@implementation TTResponseModelResponseSerializer
//
//+ (NSObject<TTResponseModelResponseSerializerProtocol> *)serializer
//{
//    return [[TTResponseModelResponseSerializer alloc] init];
//}
//
//- (NSObject<TTResponseModelProtocol> *)responseObjectForResponse:(TTHttpResponse *)response
//                                                         jsonObj:(id)jsonObj
//                                                    requestModel:(TTRequestModel *)requestModel
//                                                   responseError:(NSError *)responseError
//                                                     resultError:(NSError *__autoreleasing *)resultError
//{
//    NSError * jsonParseError = nil;
//    NSDictionary * json = jsonObj;
//
//    if (resultError) {
//        *resultError = jsonParseError;
//    }
//
//    if (jsonParseError.code == TTNetworkErrorCodeSuccess) {
//        NSAssert(requestModel._response, @"requestModel必须包含_response信息");
//        Class class = NSClassFromString(requestModel._response);
//        if (!class) {
//            if (resultError) {
//                *resultError = [NSError errorWithDomain:kTTNetworkErrorDomain
//                                                   code:TTNetworkErrorCodeParseJSONError
//                                               userInfo:@{kTTNetworkUserinfoTipKey : kTTNetworkErrorTipParseJSONError}];
//            }
//            return nil;
//        }
//        id result = nil;
//        NSError * parseJsonModelError = nil;
//        @try {
//            result = [[class alloc] initWithDictionary:json error:&parseJsonModelError];
//        }
//        @catch (NSException *exception) {
//            result = nil;
//            NSLog(@"API出错了！！！！！%@", exception);
//        }
//        @finally {
//
//        }
//        if (!result || parseJsonModelError) {
//            if (resultError) {
//                *resultError = [NSError errorWithDomain:kTTNetworkErrorDomain
//                                                   code:TTNetworkErrorCodeParseJSONError
//                                               userInfo:@{kTTNetworkUserinfoTipKey : kTTNetworkErrorTipParseJSONError}];
//            }
//        }
//        return result;
//    }
//
//
//    return nil;
//}
//
//
//@end
//
//
//@implementation TTBinaryResponseSerializer
//
//+ (NSObject<TTBinaryResponseSerializerProtocol> *)serializer
//{
//    return [[TTBinaryResponseSerializer alloc] init];
//}
//
//- (id)responseObjectForResponse:(TTHttpResponse *)response
//                           data:(NSData *)data
//                  responseError:(NSError *)responseError
//                    resultError:(NSError *__autoreleasing *)resultError
//{
//    NSError * jsonParseError = responseError;
//    id responseObject = data;
//    if (resultError) {
//        *resultError = jsonParseError;
//    }
//    return responseObject;
//}
//
//@end
//
//#endif
