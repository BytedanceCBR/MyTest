//
//  AKNetworkManager.m
//  Article
//
//  Created by 冯靖君 on 2018/3/2.
//  网络层封装

#import "AKNetworkManager.h"
#import "CommonURLSetting.h"
#import "AKHTTPPostRequestSerializer.h"

@implementation CommonURLSetting (AKURLSettings)

+ (NSString *)akRequestURLPrefix
{
    return [NSString stringWithFormat:@"%@/score_task/v1/", [self baseURL]];
}

+ (NSString *)akWebPageURLPrefix
{
    return [NSString stringWithFormat:@"%@/score_task/page/aikan/", [self baseURL]];
}

+ (NSString *)akActivityMainPageURL
{
    return [NSString stringWithFormat:@"%@tasks/?report=1", [self akWebPageURLPrefix]];
}

@end

@implementation AKNetworkManager

+ (void)requestForJSONWithPath:(NSString *)path
                        params:(id)params
                        method:(NSString *)method
                      callback:(AKNetworkJSONResponseFinishBlock)callback
{
    NSString *requestURLString = [NSString stringWithFormat:@"%@%@", [CommonURLSetting akRequestURLPrefix], path];
    [self requestForJSONWithURL:requestURLString params:params method:method callback:callback];
}

+ (void)requestForJSONWithURL:(NSString *)url
                       params:(id)params
                       method:(NSString *)method
                     callback:(AKNetworkJSONResponseFinishBlock)callback
{
    if (url) {
        Class<TTHTTPRequestSerializerProtocol> class = nil;
        if ([method isEqualToString:@"post"]) {
            class = [AKHTTPPostRequestSerializer class];
        }
        [[TTNetworkManager shareInstance] requestForJSONWithURL:url
                                                         params:params
                                                         method:method
                                               needCommonParams:YES
                                              requestSerializer:class
                                             responseSerializer:nil
                                                     autoResume:YES
                                                       callback:^(NSError *error, id jsonObj) {
                                                           if (callback) {
                                                               if ([jsonObj isKindOfClass:[NSDictionary class]]) {
                                                                   NSDictionary *jsonDict = (NSDictionary *)jsonObj;
                                                                   NSInteger serviceErrNum = [jsonDict tt_integerValueForKey:@"err_no"];
                                                                   NSString *serviceErrString = [jsonDict tt_stringValueForKey:@"err_tips"];
                                                                   NSDictionary *dataDict = [jsonDict tt_dictionaryValueForKey:@"data"];
                                                                   if (!dataDict) {
                                                                       dataDict = jsonObj;
                                                                   }
                                                                   callback(serviceErrNum, serviceErrString, [dataDict copy]);
                                                               } else {
                                                                   callback(error.code, error.localizedDescription, nil);
                                                               }
                                                           }
                                                       }];
    }
}

+ (void)requestSafeHttpForJSONWithURL:(NSString *)url
                               params:(id)params
                               method:(NSString *)method
                             callback:(AKNetworkJSONResponseFinishBlock)callback
{
    if (url) {
        Class<TTHTTPRequestSerializerProtocol> class = nil;
        if ([method isEqualToString:@"post"]) {
            class = [AKHTTPPostRequestSerializer class];
        }
        [[TTNetworkManager shareInstance] requestForJSONWithURL:url
                                                         params:params
                                                         method:method
                                               needCommonParams:YES
                                              requestSerializer:class
                                             responseSerializer:nil
                                                     autoResume:YES
                                                       callback:^(NSError *error, id jsonObj) {
                                                           if (callback) {
                                                               if ([jsonObj isKindOfClass:[NSDictionary class]]) {
                                                                   NSDictionary *jsonDict = (NSDictionary *)jsonObj;
                                                                   NSInteger serviceErrNum = [jsonDict tt_integerValueForKey:@"err_no"];
                                                                   NSString *serviceErrString = [jsonDict tt_stringValueForKey:@"err_tips"];
                                                                   callback(serviceErrNum, serviceErrString, [jsonObj copy]);
                                                               } else {
                                                                   callback(error.code, error.localizedDescription, nil);
                                                               }
                                                           }
                                                       }];
    }
}

@end
