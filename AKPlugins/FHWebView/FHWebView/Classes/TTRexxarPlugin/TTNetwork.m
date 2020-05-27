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
#import <TTBaseLib/NSDictionary+TTAdditions.h>
#import "FHWebViewConfig.h"

typedef enum : NSInteger {
    FHBridgeMsgSuccess = 1,
    FHBridgeMsgFailed = 0,
    FHBridgeMsgParamError = -3,
    FHBridgeMsgNoHandler = -2,
    FHBridgeMsgNoPermission = -1
} FHBridgeMsg;

#define TTBRIDGE_CALLBACK_WITH_MSG(status, msg) \
if (callback) {\
callback(status, @{@"msg": [NSString stringWithFormat:msg]? [NSString stringWithFormat:msg] :@""});\
}\

@implementation FHCommonJSONHTTPRequestSerializer

- (TTHttpRequest *)URLRequestWithURL:(NSString *)URL
                              params:(NSDictionary *)params
                              method:(NSString *)method
               constructingBodyBlock:(TTConstructingBodyBlock)bodyBlock
                        commonParams:(NSDictionary *)commonParam
{
    TTHttpRequest *request = [super URLRequestWithURL:URL params:params method:method constructingBodyBlock:bodyBlock commonParams:commonParam];
    
    [request setValue:@"application/json; encoding=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    
    if ([@"POST" isEqualToString: method] && [params isKindOfClass:[NSDictionary class]]) {
        NSData *data = [NSJSONSerialization dataWithJSONObject:params options:kNilOptions error:nil];
        if (data) {
            request.HTTPBody = data;
        }
    }
    
    
    return request;
}

@end

@implementation TTNetwork

- (void)getNetCommonParamsWithParam:(NSDictionary *)param callback:(TTRJSBResponse)callback webView:(UIView<TTRexxarEngine> *)webview controller:(UIViewController *)controller {
    NSDictionary *commonParams = [FHWebViewConfig getRequestCommonParams];
    
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

- (void)commonParamsWithParam:(NSDictionary *)param callback:(TTRJSBResponse)callback webView:(UIView<TTRexxarEngine> *)webview controller:(UIViewController *)controller {
    NSDictionary *commonParams = [FHWebViewConfig getRequestCommonParams];
    
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

- (void)appCommonParamsWithParam:(NSDictionary *)param callback:(TTRJSBResponse)callback webView:(UIView<TTRexxarEngine> *)webview controller:(UIViewController *)controller
{
    NSDictionary *commonParams = [FHWebViewConfig getRequestCommonParams];
    
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
    if ([header.allKeys containsObject:@"content-type"]) {
        NSMutableDictionary *caseSensitiveHeader = header.mutableCopy;
        [caseSensitiveHeader setObject:header[@"content-type"] forKey:@"Content-Type"];
        header = caseSensitiveHeader.copy;
    }
    NSDictionary *params = nil;
    id tempParams = [param objectForKey:[method isEqualToString:@"GET"]? @"params": @"data"];
    if([tempParams isKindOfClass:[NSDictionary class]]){
        params = tempParams;
    }else if ([tempParams isKindOfClass:[NSString class]]) {
        NSString *stringJson = (NSString *)tempParams;
        //json字符串
        NSData *jsonData = [stringJson dataUsingEncoding:NSUTF8StringEncoding];
        NSError *err;
        @try {
            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                                options:NSJSONReadingMutableContainers
                                                                  error:&err];
            if(!err){
                params = dic;
            }
        } @catch (NSException *exception) {
            
        } @finally {
            
        }
    }
    
    BOOL needCommonParams = YES;
    if ([param isKindOfClass:[NSDictionary class]] && [param.allKeys containsObject:@"needCommonParams"]) {
        needCommonParams = [param tt_boolValueForKey:@"needCommonParams"];
    }
    
    if (!url.length) {
        TTBRIDGE_CALLBACK_WITH_MSG(FHBridgeMsgFailed, @"url不能为空");
        return;
    }
    Class seriallizerClass = [FHCommonJSONHTTPRequestSerializer class];
    if ([header isKindOfClass:[NSDictionary class]] && [header[@"Content-Type"] isKindOfClass:[NSString class]] && [header[@"Content-Type"] isEqualToString:@"application/x-www-form-urlencoded"]) {
        seriallizerClass = nil;
    }
    
    NSString *startTime = [NSString stringWithFormat:@"%.0f", [[NSDate date] timeIntervalSince1970] * 1000];
    
    [[TTNetworkManager shareInstance] requestForBinaryWithResponse:url params:params method:method needCommonParams:needCommonParams requestSerializer:seriallizerClass responseSerializer:nil autoResume:YES callback:^(NSError *error, id obj, TTHttpResponse *response) {
        if (callback) {
            NSString *result = @"";
            if([obj isKindOfClass:[NSData class]]){
                result = [[NSString alloc] initWithData:obj encoding:NSUTF8StringEncoding];
            }
            
            if(!result)
            {
                return;
            }
            
            callback(error? -1: FHBridgeMsgSuccess, @{@"headers" : (response.allHeaderFields ? response.allHeaderFields : @""),
                                                      @"response": result ? result : @"",
                                                      @"status": @(response.statusCode),
                                                      @"code": error?@(0): @(1),
                                                      @"beginReqNetTime": startTime
                                                      });
        }
    }];
}


@end
