//
//  TTNetwork.m
//  Article
//
//  Created by muhuai on 2017/7/3.
//
//

#import "TTNetwork.h"
#import <TTNetBusiness/TTNetworkUtilities.h>
#import <TTNetworkManager/TTNetworkManager.h>
#import "TTBridgeDefines.h"
#import "FHEnvContext.h"

@implementation TTNetwork

- (void)getNetCommonParamsWithParam:(NSDictionary *)param callback:(TTRJSBResponse)callback webView:(UIView<TTRexxarEngine> *)webview controller:(UIViewController *)controller {
    NSDictionary *commonParams = [[FHEnvContext sharedInstance] getRequestCommonParams];
    
    if (!commonParams) {
        if (callback) {
            callback(TTRJSBMsgFailed, @{@"msg": @"通用参数为空..请联系客户端相关人士"});
        }
        return;
    }
    
    if (callback) {
        callback(TTRJSBMsgSuccess, @{@"data": commonParams});
    }
}

- (void)fetchWithParam:(NSDictionary *)param callback:(TTRJSBResponse)callback webView:(UIView<TTRexxarEngine> *)webview controller:(UIViewController *)controller
{
    NSString *url = [param tt_stringValueForKey:@"url"];
    NSString *method = [param stringValueForKey:@"method" defaultValue:@"GET"];
    method = [method.uppercaseString isEqualToString:@"POST"]? @"POST": @"GET";
    
    NSDictionary *header = [param tt_dictionaryValueForKey:@"header"];
    NSDictionary *params = [param tt_dictionaryValueForKey:[method isEqualToString:@"GET"]? @"params": @"data"];
    
    BOOL needCommonParams = [param tt_boolValueForKey:@"needCommonParams"];
    
    if (!url.length) {
        TTBRIDGE_CALLBACK_WITH_MSG(TTBridgeMsgFailed, @"url不能为空");
        return;
    }
    
    if (![params isKindOfClass:[NSDictionary class]]) {
        if ([params isKindOfClass:[NSString class]]) {
            NSString *stringJson = (NSString *)params;
            //json字符串
            NSData *jsonData = [stringJson dataUsingEncoding:NSUTF8StringEncoding];
            NSError *err;
            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                                options:NSJSONReadingMutableContainers
                                                                  error:&err];
            if(!err){
                params = dic;
            }
        }else
        {
            return;
        }
    }
    
    /*
     if (callback) {
     callback(error? -1: TTBridgeMsgSuccess, @{@"headers" : (response.allHeaderFields ? response.allHeaderFields : @""), @"response": [obj JSONRepresentation]? : @"",
     @"status": @(response.statusCode),
     @"code": error?@(0): @(1),
     @"beginReqNetTime": startTime
     });
     }
     */
    
    NSString *startTime = [NSString stringWithFormat:@"%.0f", [[NSDate date] timeIntervalSince1970] * 1000];
    [[TTNetworkManager shareInstance] requestForBinaryWithResponse:url params:params method:method needCommonParams:needCommonParams callback:^(NSError *error, id obj, TTHttpResponse *response) {
        NSString *result = @"";
        
        if([obj isKindOfClass:[NSData class]]){
            result = [[NSString alloc] initWithData:obj encoding:NSUTF8StringEncoding];
        }
        if (callback) {
            callback(error? -1: TTBridgeMsgSuccess, @{@"headers" : (response.allHeaderFields ? response.allHeaderFields : @""), @"response": result,
                                                      @"status": @(response.statusCode),
                                                      @"code": error?@(0): @(1),
                                                      @"beginReqNetTime": startTime
                                                      });
        }
    }];
//    :url
//                                                          params:params
//                                                          method:method
//                                                needCommonParams:needCommonParams
//                                                     headerField:header
//                                               requestSerializer:nil
//                                              responseSerializer:nil
//                                                      autoResume:YES
//                                                        callback:^(NSError *error, id obj, TTHttpResponse *response) {
//                                                            if (callback) {
//                                                                callback(error? -1: TTBridgeMsgSuccess, @{@"headers" : (response.allHeaderFields ? response.allHeaderFields : @""), @"response": [obj JSONRepresentation]? : @"",
//                                                                                                                         @"status": @(response.statusCode),
//                                                                                                                         @"code": error?@(0): @(1),
//                                                                                                                         @"beginReqNetTime": startTime
//                                                                                                                         });
    
//                                                                NSLog(@"callback pramas = %@",@{@"headers" : response.allHeaderFields, @"response": [obj JSONRepresentation]? :@"",
//                                                                                                @"status": @(response.statusCode),
//                                                                                                @"code": error?@(0): @(1),
//                                                                                                @"beginReqNetTime": startTime
//                                                                                                });
//                                                            }
//
//                                                        }];
}

@end
