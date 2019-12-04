//
//  FHWebViewSchemaUtils.m
//  BDAccountSessionSDK-SessionCheck
//
//  Created by zhulijun on 2019/10/11.
//

#import "FHWebViewSchemaUtils.h"

@implementation FHWebViewSchemaUtils

+(BOOL)isWebViewSchema:(NSString*)urlStr{
    NSURL *url = [NSURL URLWithString:urlStr];
    return [self isWebViewSchemaURL:url];
}

+(BOOL)isWebViewSchemaURL:(NSURL*)url{
    return [url.host isEqualToString:@"webview"];
}

+(NSURL*)webViewSchemaAddOrReplaceParamStr:(NSString*)urlStr name:(NSString*)name param:(NSString*)param;{
    NSURL *url = [NSURL URLWithString:urlStr];
    return [self webViewSchemaURLAddOrReplaceParamStr:url name:name param:param];
}

+(NSURL*)webViewSchemaURLAddOrReplaceParamStr:(NSURL*)url name:(NSString*)name param:(NSString*)param{
    if(!url || !param){
        return url;
    }
    //schema不是webview
    if(![url.host isEqualToString:@"webview"]){
        return url;
    }
    NSURLComponents* components = [NSURLComponents componentsWithURL:url resolvingAgainstBaseURL:NO];
    NSMutableArray<NSURLQueryItem *> *queryItems = [components.queryItems mutableCopy];
    NSURLQueryItem *webViewUrlQueryItem;
    for(NSURLQueryItem *queryItem in components.queryItems){
        if([queryItem.name isEqualToString:@"url"]){
            webViewUrlQueryItem = queryItem;
            break;
        }
    }
    //没有url的query
    if(!webViewUrlQueryItem){
        return url;
    }
    [queryItems removeObject:webViewUrlQueryItem];

    //取出url添加name=param,如果已经存在，覆盖
    NSURL* webviewUrl = [NSURL URLWithString:webViewUrlQueryItem.value];
    //解析url失败，返回,[NSURLComponents componentsWithURL:resolvingAgainstBaseURL]传入nil会crash
    if(!webviewUrl){
        return url;
    }
    NSURLComponents* webViewComponents = [NSURLComponents componentsWithURL:webviewUrl resolvingAgainstBaseURL:NO];
    NSMutableArray<NSURLQueryItem *> *webViewUrlQueryItems = [NSMutableArray array];
    [webViewUrlQueryItems addObjectsFromArray:webViewComponents.queryItems];

    //有则覆盖
    NSURLQueryItem *existParamsQuery;
    for(NSURLQueryItem *queryItem in webViewUrlQueryItems){
        if([queryItem.name isEqualToString:name]){
            existParamsQuery = queryItem;
            break;
        }
    }
    [webViewUrlQueryItems removeObject:existParamsQuery];
    NSURLQueryItem* paramsQuery = [NSURLQueryItem queryItemWithName:name value:param];
    [webViewUrlQueryItems addObject:paramsQuery];
    webViewComponents.queryItems = webViewUrlQueryItems;

    //把添加完name=param的url放回
    webViewUrlQueryItem = [NSURLQueryItem queryItemWithName:@"url" value: [webViewComponents.URL absoluteString]];
    [queryItems addObject:webViewUrlQueryItem];
    components.queryItems = queryItems;

    return components.URL;
}

+(NSURL*)webViewSchemaAddReportParamDic:(NSString*)urlStr reportParams:(NSDictionary*)reportParams;{
    NSURL *url = [NSURL URLWithString:urlStr];
    return [self webViewSchemaURLAddReportParamDic:url reportParams:reportParams];
}

+(NSURL*)webViewSchemaURLAddReportParamDic:(NSURL*)url reportParams:(NSDictionary*)reportParams{
    return [self webViewSchemaURLAddOrReplaceParamDic:url name:@"report_params" params:reportParams];
}

+(NSURL*)webViewSchemaAddOrReplaceParamDic:(NSString*)urlStr name:(NSString*)name params:(NSDictionary*)params;{
    NSURL *url = [NSURL URLWithString:urlStr];
    return [self webViewSchemaURLAddOrReplaceParamDic:url name:name params:params];
}

+(NSURL*)webViewSchemaURLAddOrReplaceParamDic:(NSURL*)url name:(NSString*)name params:(NSDictionary*)params {
    if(!url || !params){
        return url;
    }
    //schema不是webview
    if(![url.host isEqualToString:@"webview"]){
        return url;
    }
    NSURLComponents* components = [NSURLComponents componentsWithURL:url resolvingAgainstBaseURL:NO];
    NSMutableArray<NSURLQueryItem *> *queryItems = [components.queryItems mutableCopy];
    NSURLQueryItem *webViewUrlQueryItem;
    for(NSURLQueryItem *queryItem in components.queryItems){
        if([queryItem.name isEqualToString:@"url"]){
            webViewUrlQueryItem = queryItem;
            break;
        }
    }
    //没有url的query
    if(!webViewUrlQueryItem){
        return url;
    }
    [queryItems removeObject:webViewUrlQueryItem];

    //取出url添加name=params,如果有name=params，合并
    NSURL* webviewUrl = [NSURL URLWithString:webViewUrlQueryItem.value];
    //解析url失败，返回. [NSURLComponents componentsWithURL:resolvingAgainstBaseURL]传入nil会crash
    if(!webviewUrl){
        return url;
    }
    NSURLComponents* webViewComponents = [NSURLComponents componentsWithURL:webviewUrl resolvingAgainstBaseURL:NO];
    NSMutableArray<NSURLQueryItem *> *webViewUrlQueryItems = [NSMutableArray array];
    [webViewUrlQueryItems addObjectsFromArray:webViewComponents.queryItems];

    //合并
    NSURLQueryItem *existParamsQuery;
    for(NSURLQueryItem *queryItem in webViewUrlQueryItems){
        if([queryItem.name isEqualToString:name]){
            existParamsQuery = queryItem;
            break;
        }
    }
    [webViewUrlQueryItems removeObject:existParamsQuery];
    NSDictionary *existParams = [self convertDicWithJSON:existParamsQuery.value];
    NSMutableDictionary *mergedParams = [NSMutableDictionary dictionary];
    [mergedParams addEntriesFromDictionary:existParams];
    [mergedParams addEntriesFromDictionary:params];

    //添加name=params
    NSString* paramsJsonStr = [self convertJSONWithDic:mergedParams];
    NSURLQueryItem* paramsQuery = [NSURLQueryItem queryItemWithName:name value:paramsJsonStr];
    [webViewUrlQueryItems addObject:paramsQuery];
    webViewComponents.queryItems = webViewUrlQueryItems;

    //把添加完name=params的url放回
    webViewUrlQueryItem = [NSURLQueryItem queryItemWithName:@"url" value: [webViewComponents.URL absoluteString]];
    [queryItems addObject:webViewUrlQueryItem];
    components.queryItems = queryItems;

    return components.URL;
}

+(NSString *)convertJSONWithDic:(NSDictionary *)dic {
    NSError *err;
    NSData *data = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONReadingAllowFragments error:&err];
    if (data && !err) {
        NSString *temp = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        return temp;
    }
    return @"";
}

+(NSDictionary *)convertDicWithJSON:(NSString *)jsonStr {
    if (jsonStr.length == 0) {
        return nil;
    }
    NSError *err;
    NSData *jsondata = [jsonStr dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsondata options:NSJSONReadingMutableContainers error:&err];
    if (!err) {
        return dic;
    }
    return nil;
}

@end
