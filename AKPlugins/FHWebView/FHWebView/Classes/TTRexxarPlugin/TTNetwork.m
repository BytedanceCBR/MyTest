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
#import <FHHouseBase/FHCommonDefines.h>
#import <ByteDanceKit/NSURL+BTDAdditions.h>

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
    NSURL *origURL = [NSURL URLWithString:URL];
    NSDictionary *allParams = [origURL btd_queryItems];
    NSMutableDictionary *resultDict = @{}.mutableCopy;
    [commonParam enumerateKeysAndObjectsUsingBlock:^(NSString *  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        if (![allParams.allKeys containsObject:key]) {
            [resultDict setValue:obj forKey:key];
        }else {
            NSLog(@"zjing test replace key:%@, value:%@", key, obj);
        }
    }];
    
    commonParam = [self commonParams:resultDict byRemoveParams:params];
    
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

//- (NSDictionary *)queryParamsWithURL:(NSURL *)url
//{
//    NSString *urlString = [url absoluteString];
//    if (!url || IS_EMPTY_STRING(urlString)) {
//        NSAssert(NO, @"url为空，请确保url创建成功!");
//        return nil;
//    }
//
//    //先做decode才能确保url解析成功
//    //@fengjingjun 传入的URL正确做法是对query做encode，而不是整体；直接对正确encode的URL解析参数，再对各个参数逐一decode
////    [self _decodeWithEncodedURLString:&urlString];
//
//    NSString *scheme = nil;
//    NSString *host = nil;
//    NSMutableDictionary *queryParams = [NSMutableDictionary dictionary];
//
//    NSRange schemeSegRange = [urlString rangeOfString:@"://"];
//    NSString *outScheme = nil;
//    if (schemeSegRange.location != NSNotFound) {
//        scheme = [urlString substringToIndex:NSMaxRange(schemeSegRange)];
//        outScheme = [urlString substringFromIndex:NSMaxRange(schemeSegRange)];
//    }
//    else {
//        outScheme = urlString;
//    }
//
//    NSArray *substrings = [outScheme componentsSeparatedByString:@"?"];
//    NSString *path = [substrings objectAtIndex:0];
//    NSArray *hostSeg = [path componentsSeparatedByString:@"/"];
//
//    host = [hostSeg objectAtIndex:0];
//    // deal with profile page depend on is login
//    if ([substrings count] > 1) {
//        NSString *queryString =  [[substrings subarrayWithRange:NSMakeRange(1, [substrings count]-1)] componentsJoinedByString:@"?"];
//        NSArray *paramsList = [queryString componentsSeparatedByString:@"&"];
//        [paramsList enumerateObjectsUsingBlock:^(NSString *param, NSUInteger idx, BOOL *stop){
//            NSArray *keyAndValue = [param componentsSeparatedByString:@"="];
//            if ([keyAndValue count] > 1) {
//                NSString *paramKey = [keyAndValue objectAtIndex:0];
//                NSString *paramValue = [keyAndValue objectAtIndex:1];
////                if ([paramValue rangeOfString:@"%"].length > 0) {
////                    //v0.2.17 递归decode解析query参数
////                    paramValue = [TTRoute recursiveDecodeForParamValue:paramValue];
////                }
//
//                //v0.2.19 去掉递归decode，外部保证传入合法encode的url
//                [self _decodeWithEncodedURLString:&paramValue];
//
//                if (paramValue && paramKey) {
//                    [[self class] setQueryValue:paramValue forKey:paramKey toDict:queryParams];
//                }
//            }
//        }];
//    }
//    return [queryParams copy];
//}

//- (void)_decodeWithEncodedURLString:(NSString **)urlString
//{
//    if ([*urlString rangeOfString:@"%"].length == 0){
//        return;
//    }
//#pragma clang diagnostic push
//#pragma clang diagnostic ignored "-Wdeprecated-declarations"
//    *urlString = (__bridge_transfer NSString *)(CFURLCreateStringByReplacingPercentEscapesUsingEncoding(kCFAllocatorDefault, (__bridge CFStringRef)*urlString, CFSTR(""), kCFStringEncodingUTF8));
//#pragma clang diagnostic pop
//}

//+(void)setQueryValue:(nullable id)value forKey: (NSString *)key toDict:(NSMutableDictionary*)dict {
//    //判断数据是否是数组类型
//    NSString* arrayParamRegularExpressionStr = @".*%5B%5D";
//    NSRegularExpression* regex = [[NSRegularExpression alloc] initWithPattern:arrayParamRegularExpressionStr options:0 error:nil];
//    if ([regex firstMatchInString:key options:0 range:NSMakeRange(0, key.length)]) {
//        if (dict[key] != nil) {
//            NSArray* values = dict[key];
//            NSMutableArray* newValues = [[NSMutableArray alloc] initWithCapacity:values.count + 1];
//            [newValues addObjectsFromArray:values];
//            [newValues addObject:value];
//            dict[key] = newValues;
//        } else {
//            dict[key] = @[value];
//        }
//    } else {
//        dict[key] = value;
//    }
//}

-(NSDictionary *)commonParams:(NSDictionary *)commonParams byRemoveParams:(NSDictionary *)params
{
    if (params.count == 0 || commonParams.count == 0) {
        return commonParams;
    }
    
    NSSet *commonKeys = [[NSSet alloc] initWithArray:commonParams.allKeys];
    NSSet *paramKeys = [[NSSet alloc] initWithArray:params.allKeys];
    
    if ([commonKeys intersectsSet:paramKeys]) {
        
        NSMutableDictionary *mCommonParams = [[NSMutableDictionary alloc] initWithDictionary:commonParams];
        for (NSString *key in params.allKeys) {
            if ([commonKeys containsObject:key]) {
                [mCommonParams removeObjectForKey:key];
            }
        }
        return mCommonParams;
    }
    
    return commonParams;
    
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
